#!/usr/bin/perl -w

# Copyright 2011, 2012 Kevin Ryde

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
use POSIX ();
use Math::PlanePath::SierpinskiArrowhead;

# uncomment this to run the ### lines
use Smart::Comments;

{
  # filled fraction

  require Math::PlanePath::SierpinskiCurve;
  require Number::Fraction;
  my $path = Math::PlanePath::SierpinskiCurve->new;
  foreach my $level (1 .. 20) {
    my $Ntop = 4**$level / 2 - 1;
    my ($x,$y) = $path->n_to_xy($Ntop);
    my $Xtop = 3*2**($level-1) - 1;
    $x == $Xtop or die "x=$x Xtop=$Xtop";
    my $frac = $Ntop / ($x*($x-1)/2);
    print "  $level  $frac\n";
  }
  my $nf = Number::Fraction->new(4,9);
  my $limit = $nf->to_num;
  print "  limit  $nf = $limit\n";
  exit 0;
}

{
  # filled fraction

  require Math::PlanePath::SierpinskiCurveStair;
  require Number::Fraction;
  foreach my $L (1 .. 5) {
    print "L=$L\n";
    my $path = Math::PlanePath::SierpinskiCurveStair->new (diagonal_length=>$L);
    foreach my $level (1 .. 10) {
      my $Nlevel = ((6*$L+4)*4**$level - 4) / 3;
      my ($x,$y) = $path->n_to_xy($Nlevel);
      my $Xlevel = ($L+2)*2**$level - 1;
      $x == $Xlevel or die "x=$x Xlevel=$Xlevel";
      my $frac = $Nlevel / ($x*($x-1)/2);
      print "  $level  $frac\n";
    }
    my $nf = Number::Fraction->new((12*$L+8),(3*$L**2+12*$L+12));
    my $limit = $nf->to_num;
    print "  limit  $nf = $limit\n";
  }
  exit 0;
}

{
  my $path = Math::PlanePath::SierpinskiCurve->new;
  my @rows = ((' ' x 79) x 64);
  foreach my $n (0 .. 3 * 3**4) {
    my ($x, $y) = $path->n_to_xy ($n);
    $x += 32;
    substr ($rows[$y], $x,1, '*');
  }
  local $,="\n";
  print reverse @rows;
  exit 0;
}

{
  my @rows = ((' ' x 64) x 32);
  foreach my $p (0 .. 31) {
    foreach my $q (0 .. 31) {
      next if ($p & $q);

      my $x = $p-$q;
      my $y = $p+$q;
      next if ($y >= @rows);
      $x += 32;
      substr ($rows[$y], $x,1, '*');
    }
  }
  local $,="\n";
  print reverse @rows;
  exit 0;
}
