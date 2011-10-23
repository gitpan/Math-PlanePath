#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

# This file is part of Math-PlanePath.
#
# Math-PlanePath is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-PlanePath is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-PlanePath.  If not, see <http://www.gnu.org/licenses/>.


use 5.004;
use strict;
use POSIX ();

# uncomment this to run the ### lines
use Devel::Comments;

{
  require Math::Complex;
  my $c = Math::Complex->new(123);
  ### $c
  print $c,"\n";
  print $c * 0,"\n";;
### int: int($c)
  print int($c),"\n";;
  exit 0;
}

{
  require Math::BigRat;

  require Math::BigFloat;
  Math::BigFloat->precision(2000);  # digits right of decimal point
  Math::BigFloat->accuracy(2000);

  {
    my $x = Math::BigRat->new('1/2') ** 512;
    print "$x\n";
    my $r = sqrt($x);
    print "$r\n";
    print $r*$r,"\n";

    # my $r = 8*$x-3;
    # print "$r\n";
  }
  exit 0;
  {
    my $x = Math::BigInt->new(2) ** 128 - 1;
    print "$x\n";
    my $r = 8*$x-3;
    print "$r\n";
  }
  {
    my $x = Math::BigRat->new('100000000000000000000'.('0'x200));
    $x = $x*$x-1;
    print "$x\n";
    my $r = sqrt($x);
    print "$r\n";
     $r = int($r);
    print "$r\n";
  }
}
