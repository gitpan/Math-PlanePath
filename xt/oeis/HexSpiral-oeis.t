#!/usr/bin/perl -w

# Copyright 2010, 2011, 2012, 2013 Kevin Ryde

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
plan tests => 1;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use List::Util 'min', 'max';
use Math::PlanePath::HexSpiral;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $path = Math::PlanePath::HexSpiral->new;

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
# A063436 -- N on slope=3 WSW

MyOEIS::compare_values
  (anum => 'A063436',
   func => sub {
     my ($count) = @_;
     my @got;
     my $path = Math::PlanePath::HexSpiral->new (n_start => 0);
     my $x = 0;
     my $y = 0;
     while (@got < $count) {
       push @got, $path->xy_to_n ($x,$y);
       $x -= 3;
       $y -= 1;
     }
     return \@got;
   });


#------------------------------------------------------------------------------
# A063178 -- a(n) is sum of existing numbers in row of a(n-1)

#                   42
#                     \
#           2-----1    33
#         /        \     \
#        3     0-----1    23
#         \              /
#           5-----8----10
#
#        ^  ^  ^  ^  ^  ^  ^

{
  my $anum = 'A063178';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum,
                                                      max_value => 'unlimited');
  my @got;
  if ($bvalues) {
    require Math::BigInt;
    my %plotted;
    $plotted{2,0} = Math::BigInt->new(1);
    my $xmin = 0;
    my $ymin = 0;
    my $xmax = 2;
    my $ymax = 0;
    push @got, 1;

    for (my $n = $path->n_start + 2; @got < @$bvalues; $n++) {
      my ($prev_x, $prev_y) = $path->n_to_xy ($n-1);
      my ($x, $y) = $path->n_to_xy ($n);
      ### at: "$x,$y  prev $prev_x,$prev_y"

      my $total = 0;
      if (($y > $prev_y && $x < $prev_x)
          || ($y < $prev_y && $x > $prev_x)) {
        ### forward diagonal ...
        foreach my $y ($ymin .. $ymax) {
          my $delta = $y - $prev_y;
          my $x = $prev_x + $delta;
          $total += $plotted{$x,$y} || 0;
        }
      } elsif (($y == $prev_y && $x < $prev_x)
               || ($y == $prev_y && $x > $prev_x)) {
        ### opp diagonal ...
        foreach my $y ($ymin .. $ymax) {
          my $delta = $y - $prev_y;
          my $x = $prev_x - $delta;
          $total += $plotted{$x,$y} || 0;
        }
      } else {
        ### row: "$xmin .. $xmax at y=$prev_y"
        foreach my $x ($xmin .. $xmax) {
          $total += $plotted{$x,$prev_y} || 0;
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
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- sum of rows");
}


#------------------------------------------------------------------------------
exit 0;
