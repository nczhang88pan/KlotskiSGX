//===-- MainLoop.cpp --------------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/Config/config.h"

#include "lldb/Host/MainLoop.h"
#include "lldb/Utility/Error.h"
#include <algorithm>
#include <cassert>
#include <cerrno>
#include <csignal>
#include <vector>
#include <time.h>

#if HAVE_SYS_EVENT_H
#include <sys/event.h>
#elif defined(LLVM_ON_WIN32)
#include <winsock2.h>
#else
#include <poll.h>
#endif

#ifdef LLVM_ON_WIN32
#define POLL WSAPoll
#else
#define POLL poll
#endif

#if SIGNAL_POLLING_UNSUPPORTED
#ifdef LLVM_ON_WIN32
typedef int sigset_t;
typedef int siginfo_t;
#endif

int ppoll(struct pollfd *fds, size_t nfds, const struct timespec *timeout_ts,
          const sigset_t *) {
  int timeout =
      (timeout_ts == nullptr)
          ? -1
          : (timeout_ts->tv_sec * 1000 + timeout_ts->tv_nsec / 1000000);
  return POLL(fds, nfds, timeout);
}

#endif

using namespace lldb;
using namespace lldb_private;

static sig_atomic_t g_signal_flags[NSIG];

static void SignalHandler(int signo, siginfo_t *info, void *) {
  assert(signo < NSIG);
  g_signal_flags[signo] = 1;
}

MainLoop::~MainLoop() {
  assert(m_read_fds.size() == 0);
  assert(m_signals.size() == 0);
}

MainLoop::ReadHandleUP
MainLoop::RegisterReadObject(const IOObjectSP &object_sp,
                                  const Callback &callback, Error &error) {
#ifdef LLVM_ON_WIN32
  if (object_sp->GetFdType() != IOObject:: eFDTypeSocket) {
    error.SetErrorString("MainLoop: non-socket types unsupported on Windows");
    return nullptr;
  }
#endif
  if (!object_sp || !object_sp->IsValid()) {
    error.SetErrorString("IO object is not valid.");
    return nullptr;
  }

  const bool inserted =
      m_read_fds.insert({object_sp->GetWaitableHandle(), callback}).second;
  if (!inserted) {
    error.SetErrorStringWithFormat("File descriptor %d already monitored.",
                                   object_sp->GetWaitableHandle());
    return nullptr;
  }

  return CreateReadHandle(object_sp);
}

// We shall block the signal, then install the signal handler. The signal will
// be unblocked in
// the Run() function to check for signal delivery.
MainLoop::SignalHandleUP
MainLoop::RegisterSignal(int signo, const Callback &callback,
                              Error &error) {
#ifdef SIGNAL_POLLING_UNSUPPORTED
  error.SetErrorString("Signal polling is not supported on this platform.");
  return nullptr;
#else
  if (m_signals.find(signo) != m_signals.end()) {
    error.SetErrorStringWithFormat("Signal %d already monitored.", signo);
    return nullptr;
  }

  SignalInfo info;
  info.callback = callback;
  struct sigaction new_action;
  new_action.sa_sigaction = &SignalHandler;
  new_action.sa_flags = SA_SIGINFO;
  sigemptyset(&new_action.sa_mask);
  sigaddset(&new_action.sa_mask, signo);

  sigset_t old_set;
  if (int ret = pthread_sigmask(SIG_BLOCK, &new_action.sa_mask, &old_set)) {
    error.SetErrorStringWithFormat("pthread_sigmask failed with error %d\n",
                                   ret);
    return nullptr;
  }

  info.was_blocked = sigismember(&old_set, signo);
  if (sigaction(signo, &new_action, &info.old_action) == -1) {
    error.SetErrorToErrno();
    if (!info.was_blocked)
      pthread_sigmask(SIG_UNBLOCK, &new_action.sa_mask, nullptr);
    return nullptr;
  }

  m_signals.insert({signo, info});
  g_signal_flags[signo] = 0;

  return SignalHandleUP(new SignalHandle(*this, signo));
#endif
}

void MainLoop::UnregisterReadObject(IOObject::WaitableHandle handle) {
  bool erased = m_read_fds.erase(handle);
  UNUSED_IF_ASSERT_DISABLED(erased);
  assert(erased);
}

void MainLoop::UnregisterSignal(int signo) {
#if SIGNAL_POLLING_UNSUPPORTED
  Error("Signal polling is not supported on this platform.");
#else
  // We undo the actions of RegisterSignal on a best-effort basis.
  auto it = m_signals.find(signo);
  assert(it != m_signals.end());

  sigaction(signo, &it->second.old_action, nullptr);

  sigset_t set;
  sigemptyset(&set);
  sigaddset(&set, signo);
  pthread_sigmask(it->second.was_blocked ? SIG_BLOCK : SIG_UNBLOCK, &set,
                  nullptr);

  m_signals.erase(it);
#endif
}

Error MainLoop::Run() {
  std::vector<int> signals;
  m_terminate_request = false;
  signals.reserve(m_signals.size());
  
#if HAVE_SYS_EVENT_H
  int queue_id = kqueue();
  if (queue_id < 0)
    Error("kqueue failed with error %d\n", queue_id);

  std::vector<struct kevent> events;
  events.reserve(m_read_fds.size() + m_signals.size());
#else
  sigset_t sigmask;
  std::vector<struct pollfd> read_fds;
  read_fds.reserve(m_read_fds.size());
#endif

  // run until termination or until we run out of things to listen to
  while (!m_terminate_request && (!m_read_fds.empty() || !m_signals.empty())) {
    // To avoid problems with callbacks changing the things we're supposed to
    // listen to, we
    // will store the *real* list of events separately.
    signals.clear();

#if HAVE_SYS_EVENT_H
    events.resize(m_read_fds.size() + m_signals.size());
    int i = 0;
    for (auto &fd: m_read_fds) {
      EV_SET(&events[i++], fd.first, EVFILT_READ, EV_ADD, 0, 0, 0);
    }

    for (const auto &sig : m_signals) {
      signals.push_back(sig.first);
      EV_SET(&events[i++], sig.first, EVFILT_SIGNAL, EV_ADD, 0, 0, 0);
    }

    struct kevent event_list[4];
    int num_events =
        kevent(queue_id, events.data(), events.size(), event_list, 4, NULL);

    if (num_events < 0)
      return Error("kevent() failed with error %d\n", num_events);

#else
    read_fds.clear();

#if !SIGNAL_POLLING_UNSUPPORTED
    if (int ret = pthread_sigmask(SIG_SETMASK, nullptr, &sigmask))
      return Error("pthread_sigmask failed with error %d\n", ret);

    for (const auto &sig : m_signals) {
      signals.push_back(sig.first);
      sigdelset(&sigmask, sig.first);
    }
#endif

    for (const auto &fd : m_read_fds) {
      struct pollfd pfd;
      pfd.fd = fd.first;
      pfd.events = POLLIN;
      pfd.revents = 0;
      read_fds.push_back(pfd);
    }

    if (ppoll(read_fds.data(), read_fds.size(), nullptr, &sigmask) == -1 &&
        errno != EINTR)
      return Error(errno, eErrorTypePOSIX);
#endif

    for (int sig : signals) {
      if (g_signal_flags[sig] == 0)
        continue; // No signal
      g_signal_flags[sig] = 0;

      auto it = m_signals.find(sig);
      if (it == m_signals.end())
        continue; // Signal must have gotten unregistered in the meantime

      it->second.callback(*this); // Do the work

      if (m_terminate_request)
        return Error();
    }

#if HAVE_SYS_EVENT_H
    for (int i = 0; i < num_events; ++i) {
      auto it = m_read_fds.find(event_list[i].ident);
#else
    for (auto fd : read_fds) {
      if ((fd.revents & POLLIN) == 0)
        continue;

      auto it = m_read_fds.find(fd.fd);
#endif
      if (it == m_read_fds.end())
        continue; // File descriptor must have gotten unregistered in the
                  // meantime
      it->second(*this); // Do the work

      if (m_terminate_request)
        return Error();
    }
  }
  return Error();
}
