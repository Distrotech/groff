#include <stdio.h>

struct A {
  A() { fputs("A\n", stdout); }
  ~A() { fputs("~A\n", stdout); }
};

A a;

main()
{
  return 0;
}
