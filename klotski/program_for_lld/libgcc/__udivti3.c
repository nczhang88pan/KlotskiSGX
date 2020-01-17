/*
 * arch/i386/libgcc/__divdi3.c
 */

#include "libgcc.h"

__uint128_t __udivti3(__uint128_t num, __uint128_t den)
{
    __uint128_t quot = 0, qbit = 1;

  if ( den == 0 ) {
    __divide_error();
    return 0;			/* If trap returns... */
  }

  /* Left-justify denominator and count shift */
  while ( (__int128_t)den >= 0 ) {
    den <<= 1;
    qbit <<= 1;
  }

  while ( qbit ) {
    if ( den <= num ) {
      num -= den;
      quot += qbit;
    }
    den >>= 1;
    qbit >>= 1;
  }


  return quot;
}
