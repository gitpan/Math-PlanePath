#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

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

use strict;
use warnings;
use POSIX 'fmod';
use Math::Libm 'hypot';
use Math::Trig 'pi';

use Smart::Comments;

use constant PHI => (1 + sqrt(5)) / 2;

{
  # 609 631   0.624053229799566 1.60242740883046
  # 2 7   1.47062247517163 0.679984167849259

  my @x;
  my @y;
  foreach my $n (1 .. 10000) {
    my $r = sqrt($n);
    # my $theta = 2 * $n;  # radians
    my $theta = $n * sqrt(2) * 2*pi();  # radians
    push @x, $r * cos($theta);
    push @y, $r * sin($theta);
  }
  # ### @x
  my $min_d = 999;
  my $min_i = 0;
  my $min_j = 0;
  foreach my $i (0 .. $#x-1) {
    foreach my $j ($i+1 .. $#x) {
      my $d = hypot ($x[$i]-$x[$j], $y[$i]-$y[$j]);
      if ($d < $min_d) {
        $min_d = $d;
        $min_i = $i;
        $min_j = $j;
      }
    }
  }
  print "$min_i $min_j   $min_d ", 1/$min_d, "\n";
  exit 0;
}

{
  foreach my $n (18239,19459,25271,28465,31282,35552,43249,74592,88622,
                 101898,107155,116682) {
    my $theta = $n / (PHI * PHI);  # 1==full circle
    printf "%6d  %.2f\n", $n, $theta;
  }
  exit 0;
}

foreach my $i (2 .. 5000) {
  my $rem = fmod ($i, PHI*PHI);
  if ($rem > 0.5) {
    $rem = $rem - 1;
  }
  if (abs($rem) < 0.02) {
    printf "%4d  %6.3f  %s\n", $i,$rem,factorize($i);
  }
}


sub factorize {
  my ($n) = @_;
  my @factors;
  foreach my $f (2 .. int(sqrt($n)+1)) {
    if (($n % $f) == 0) {
      push @factors, $f;
      $n /= $f;
      while (($n % $f) == 0) {
        $n /= $f;
      }
    }
  }
  return join ('*',@factors);
}
exit 0;

