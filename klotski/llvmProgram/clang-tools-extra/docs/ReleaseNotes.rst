===================================================
Extra Clang Tools 5.0.0 (In-Progress) Release Notes
===================================================

.. contents::
   :local:
   :depth: 3

Written by the `LLVM Team <http://llvm.org/>`_

.. warning::

   These are in-progress notes for the upcoming Extra Clang Tools 5 release.
   Release notes for previous releases can be found on
   `the Download Page <http://releases.llvm.org/download.html>`_.

Introduction
============

This document contains the release notes for the Extra Clang Tools, part of the
Clang release 5.0.0. Here we describe the status of the Extra Clang Tools in
some detail, including major improvements from the previous release and new
feature work. All LLVM releases may be downloaded from the `LLVM releases web
site <http://llvm.org/releases/>`_.

For more information about Clang or LLVM, including information about
the latest release, please see the `Clang Web Site <http://clang.llvm.org>`_ or
the `LLVM Web Site <http://llvm.org>`_.

Note that if you are reading this file from a Subversion checkout or the
main Clang web page, this document applies to the *next* release, not
the current one. To see the release notes for a specific release, please
see the `releases page <http://llvm.org/releases/>`_.

What's New in Extra Clang Tools 5.0.0?
======================================

Some of the major new features and improvements to Extra Clang Tools are listed
here. Generic improvements to Extra Clang Tools as a whole or to its underlying
infrastructure are described first, followed by tool-specific sections.

Major New Features
------------------

...

Improvements to clang-query
---------------------------

The improvements are...

Improvements to clang-rename
----------------------------

The improvements are...

Improvements to clang-tidy
--------------------------

- New `cert-dcl58-cpp
  <http://clang.llvm.org/extra/clang-tidy/checks/cert-dcl58-cpp.html>`_ check

  Finds modification of the ``std`` or ``posix`` namespace.

- Improved `cppcoreguidelines-no-malloc
  <http://clang.llvm.org/extra/clang-tidy/checks/cppcoreguidelines-no-malloc.html>`_ check

  Allow custom memory management functions to be considered as well.

- New `readability-misleading-indentation
  <http://clang.llvm.org/extra/clang-tidy/checks/readability-misleading-indentation.html>`_ check

  Finds misleading indentation where braces should be introduced or the code should be reformatted.

- Added `ParameterThreshold` to `readability-function-size`.

  Finds functions that have more then `ParameterThreshold` parameters and emits a warning.

- New `hicpp` module

  Adds checks that implement the `High Integrity C++ Coding Standard <http://www.codingstandard.com/section/index/>`_ and other safety
  standards. Many checks are aliased to other modules.

- New `modernize-replace-random-shuffle
  <http://clang.llvm.org/extra/clang-tidy/checks/modernize-replace-random-shuffle.html>`_ check

  Finds and fixes usage of ``std::random_shuffle`` as the function has been removed from C++17.

- New `modernize-return-braced-init-list
  <http://clang.llvm.org/extra/clang-tidy/checks/modernize-return-braced-init-list.html>`_ check

  Finds and replaces explicit calls to the constructor in a return statement by
  a braced initializer list so that the return type is not needlessly repeated.
  
- New `misc-forwarding-reference-overload
  <http://clang.llvm.org/extra/clang-tidy/checks/misc-forwarding-reference-overload.html>`_ check

  Finds perfect forwarding constructors that can unintentionally hide copy or move constructors.

- Support clang-formatting of the code around applied fixes (``-format-style``
  command-line option).

- New `performance-inefficient-vector-operation
  <http://clang.llvm.org/extra/clang-tidy/checks/performance-inefficient-vector-operation.html>`_ check

  Finds possible inefficient vector operations in for loops that may cause
  unnecessary memory reallocations.

Improvements to include-fixer
-----------------------------

The improvements are...

Improvements to modularize
--------------------------

The improvements are...
