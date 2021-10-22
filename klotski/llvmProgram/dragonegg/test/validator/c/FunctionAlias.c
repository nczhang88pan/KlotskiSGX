// RUN: %dragonegg -S %s -o - | FileCheck %s

void qux(void) { }
void foo(void) __attribute__ ((alias ("qux")));
// CHECK: @foo = alias void ()* @qux
void bar(void) __attribute__ ((weak, alias ("foo")));
// CHECK: @bar = weak alias void ()* @qux
void baz(void) __attribute__ ((alias ("bar")));
// CHECK: @baz = alias void ()* @qux
