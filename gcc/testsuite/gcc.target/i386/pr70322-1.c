/* PR target/70322 */
/* { dg-do compile { target ia32 } } */
/* { dg-options "-O2 -msse2 -mstv -mbmi -mno-stackrealign" } */
/* { dg-final { scan-assembler "pandn" } } */

extern long long z;

void
foo (long long x, long long y)
{
  z = ~x & y;
}
