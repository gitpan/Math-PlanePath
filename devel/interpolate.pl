#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

use 5.010;
use strict;
use warnings;
use Math::BigRat;
use Math::Polynomial 1;

use Smart::Comments;

{
  my $p = Math::Polynomial->new(Math::BigRat->new(0));
  $p->string_config({ variable => '$s',
                      times => '*',
                    });
  $p = $p->interpolate([0,1,2,3,4],
                       [0.5, 1.5, 4.5, 9.5, 16.5 ]);
  print 'N = ',$p,"\n";

  my $a = $p->coeff(2);
  my $b = $p->coeff(1);
  my $c = $p->coeff(0);

  my $x = -$b/(2*$a);
  my $y = 4*$a / ((2*$a) ** 2);
  my $z = ($b*$b-4*$a*$c) / ((2*$a) ** 2);
  print "s = $x + sqrt($y * \$n + $z)\n";

  my $s_to_n = sub {
    my ($s) = @_;
    return $p->evaluate($s);
  };

  $x = $x->numify;
  $y = $y->numify;
  $z = $z->numify;
  my $n_to_s = sub {
    my ($n) = @_;
    my $root = $y * $n + $z;
    if ($root < 0) {
      return 'neg sqrt';
    }
    return ($x + sqrt($root));
  };
  for (my $i = 0; $i < 20; $i += 0.5) {
    printf "%4s  s=%s\n", $i, $n_to_s->($i);
  }
  exit 0;
}
{
  my $f1 = 1.5;
  my $f2 = 4.5;
  my $f3 = 9.5;
  my $f4 = 16.5;

  foreach ($f1, $f2, $f3, $f4) {
    $_ = Math::BigRat->new($_);
  }

  my $a = $f4/2 - $f3 + $f2/2;
  my $b = $f4*-5/2 + $f3*6 - $f2*7/2;
  my $c = $f4*3 - $f3*8 + $f2*6;

  print "$a\n";
  print "$b\n";
  print "$c\n";

  print "$a*\$s*\$s + $b*\$s + $c\n";
  exit 0;
}

{
  my $subr = sub {
    my ($s) = @_;
     return 3*$s*$s - 4*$s + 2;
    return 2*$s*$s - 2*$s + 2;
    return $s*$s + .5;
    return $s*$s - $s + 1;
    return $s*($s+1)*.5 + 0.5;
  };
  my $back = sub {
    my ($n) = @_;
    return (2 + sqrt(3*$n - 2)) / 3;
    return .5 + sqrt(.5*$n-.75);
    return sqrt ($n - .5);
    # return -.5 + sqrt(2*$n - .75);
    #    return int((sqrt(4*$n-1) - 1) / 2);
  };
  my $prev = 0;
  foreach (1..15) {
    my $this = $subr->($_);
    printf("%2d  %.2f  %.2f  %.2f\n", $_, $this, $this-$prev,$back->($this));
    $prev = $this;
  }
  for (my $n = 1; $n < 23; $n++) {
    printf "%.2f  %.2f\n", $n,$back->($n);
  }
  exit 0;
}
