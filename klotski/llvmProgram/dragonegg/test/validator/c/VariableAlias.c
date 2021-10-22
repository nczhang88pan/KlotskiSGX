// RUN: %dragonegg -S %s -o - | FileCheck %s

int qux;
extern int foo __attribute__ ((alias ("qux")));
// CHECK: @foo = alias i32* @qux
extern int bar __attribute__ ((weak, alias ("foo")));
// CHECK: @bar = weak alias i32* @qux
extern int baz __attribute__ ((alias ("bar")));
// CHECK: @baz = alias i32* @qux
