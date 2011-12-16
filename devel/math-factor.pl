#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

# This file is part of Math-PlanePath.
#
# Math-PlanePath is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
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
use Math::Factor::XS 'factors','matches';

# uncomment this to run the ### lines
use Smart::Comments;

{
  print join(', ', factors(30)),"\n";
  ### factors(): factors(12345)
  ### factors(): factors(65536)
  ### factors(): factors(2*3*5*7)
  exit 0;
}

{
  foreach my $i (1 .. 32) {
    my $sign = 1;
    my $t = 0;
    for (my $bit = 1; $bit <= $i; $bit <<= 1, $sign = -$sign) {
      if ($i & $bit) {
        $t += $sign * $bit;
      }
    }
    print "$i  $t\n";
  }
  exit  0;
}

{
  { package MyTie;
    sub TIESCALAR {
      my ($class) = @_;
      return bless {}, $class;
    }
    sub FETCH {
      print "fetch\n";
      return { skip_multiples => 1 };
    }
  }
  my $t;
  tie $t, 'MyTie';

  {
    my @ret = matches(12,[2,2,3,4,6],{ skip_multiples => 1 });
    ### matches(): @ret
  }
  {
    my @ret = matches(12,[2,2,3,4,6],$t);
    ### matches(): @ret
  }
  for (;;) { matches(12,[2,2,3,4,6]); }
  exit 0;
}



{
  for (;;) {
    factors(12345);
  }
  exit 0;
}
