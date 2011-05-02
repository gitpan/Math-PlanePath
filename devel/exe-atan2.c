/* Copyright 2011 Kevin Ryde

   This file is part of Math-PlanePath.

   Math-PlanePath is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the Free
   Software Foundation; either version 3, or (at your option) any later
   version.

   Math-PlanePath is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
   or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
   for more details.

   You should have received a copy of the GNU General Public License along
   with Math-PlanePath.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

void
dump (double d)
{
  union { double d; unsigned char byte[8]; } u;
  u.d = d;
  printf ("%02X %02X %02X %02X %02X %02X %02X %02X\n",
          u.byte[0], u.byte[1], u.byte[2], u.byte[3],
          u.byte[4], u.byte[5], u.byte[6], u.byte[7]);
}

int
main (void)
{
  volatile double zero = 0;
  volatile double negzero = -zero;
  dump (zero);
  dump (negzero);
  printf ("%la %la\n", zero,negzero);

  printf ("%la\n", atan2(zero,zero));
  printf ("%la\n", atan2(negzero,zero));
  printf ("\n");
  printf ("%la\n", atan2(zero,negzero));
  printf ("%la\n", atan2(negzero,negzero));
  exit (0);
}
