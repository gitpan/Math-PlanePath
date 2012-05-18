#!/usr/bin/perl -w

# Copyright 2010, 2011, 2012 Kevin Ryde

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
use Test;
BEGIN { plan tests => 1 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use List::Util 'min', 'max';
use Math::PlanePath::TriangleSpiral;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $path = Math::PlanePath::TriangleSpiral->new;

sub numeq_array {
  my ($a1, $a2) = @_;
  if (! ref $a1 || ! ref $a2) {
    return 0;
  }
  my $i = 0;
  while ($i < @$a1 && $i < @$a2) {
    if ($a1->[$i] ne $a2->[$i]) {
      return 0;
    }
    $i++;
  }
  return (@$a1 == @$a2);
}


#------------------------------------------------------------------------------
# A063177 -- a(n) is sum of existing numbers in row of a(n-1)

{
  my $anum = 'A063177';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum,
                                                      max_value => 'unlimited');
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    require Math::BigInt;
    my %plotted;
    $plotted{0,0} = Math::BigInt->new(1);
    my $xmin = 0;
    my $ymin = 0;
    my $xmax = 0;
    my $ymax = 0;
    push @got, 1;

    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      my ($prev_x, $prev_y) = $path->n_to_xy ($n-1);
      my ($x, $y) = $path->n_to_xy ($n);
      ### at: "$x,$y  prev $prev_x,$prev_y"

      my $total = 0;
      if ($x > $prev_x) {
        ### forward diagonal ...
        foreach my $y ($ymin .. $ymax) {
          my $delta = $y - $prev_y;
          my $x = $prev_x + $delta;
          $total += $plotted{$x,$y} || 0;
        }
      } elsif ($y > $prev_y) {
        ### row: "$xmin .. $xmax at y=$prev_y"
        foreach my $x ($xmin .. $xmax) {
          $total += $plotted{$x,$prev_y} || 0;
        }
      } else {
        ### opp diagonal ...
        foreach my $y ($ymin .. $ymax) {
          my $delta = $y - $prev_y;
          my $x = $prev_x - $delta;
          $total += $plotted{$x,$y} || 0;
        }
      }
      ### total: "$total"

      $plotted{$x,$y} = $total;
      $xmin = min($xmin,$x);
      $xmax = max($xmax,$x);
      $ymin = min($ymin,$y);
      $ymax = max($ymax,$y);
      push @got, $total;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- sum of rows");
}


#------------------------------------------------------------------------------
exit 0;
