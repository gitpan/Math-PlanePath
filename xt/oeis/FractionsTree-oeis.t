#!/usr/bin/perl -w

# Copyright 2011, 2012, 2013 Kevin Ryde

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
plan tests => 2;

use lib 't','xt';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }
use MyOEIS;

use Math::PlanePath::FractionsTree;

# uncomment this to run the ### lines
#use Smart::Comments '###';

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
# A093873 -- Kepler numerators

# {
#   my $path  = Math::PlanePath::FractionsTree->new (tree_type => 'Kepler');
#   my $anum = 'A093873';
#   my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
#   my @got;
#   if ($bvalues) {
#     foreach my $n (1 .. @$bvalues) {
#       my ($x, $y) = $path->n_to_xy (int(($n+1)/2));
#       push @got, $x;
#     }
#   }
#   skip (! $bvalues,
#         numeq_array(\@got, $bvalues),
#         1, "$anum -- Kepler tree numerators");
# }
# 
# sub sans_high_bit {
#   my ($n) = @_;
#   return $n ^ high_bit($n);
# }
# sub high_bit {
#   my ($n) = @_;
#   my $bit;
#   for ($bit = 1; $bit <= $n; $bit <<= 1) {
#     $bit <<= 1;
#   }
#   return $bit >> 1;
# }

#------------------------------------------------------------------------------
# A093875 -- Kepler denominators

# {
#   my $path  = Math::PlanePath::FractionsTree->new (tree_type => 'Kepler');
#   my $anum = 'A093875';
#   my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
#   my @got;
#   if ($bvalues) {
#     foreach my $n (2 .. @$bvalues) {
#       my ($x, $y) = $path->n_to_xy (int($n/2));
#       push @got, $y;
#     }
#   }
#   skip (! $bvalues,
#         numeq_array(\@got, $bvalues),
#         1, "$anum -- Kepler tree denominators");
# }


#------------------------------------------------------------------------------
# A086593 -- Kepler half-tree denominators, every second value

{
  my $anum = 'A086593';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  {
    my $path  = Math::PlanePath::FractionsTree->new (tree_type => 'Kepler');
    my @got;
    if ($bvalues) {
      for (my $n = $path->n_start; @got < @$bvalues; $n += 2) {
        my ($x, $y) = $path->n_to_xy ($n);
        push @got, $y;
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum -- Kepler half-tree denominators every second value");
  }

  # is also the sum X+Y, skipping initial 2
  {
    my $path  = Math::PlanePath::FractionsTree->new (tree_type => 'Kepler');
    my @got;
    if ($bvalues) {
      push @got, 2;
      for (my $n = $path->n_start; @got < @$bvalues; $n++) {
        my ($x, $y) = $path->n_to_xy ($n);
        push @got, $x+$y;
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum -- as sum X+Y");
  }
}

#------------------------------------------------------------------------------
exit 0;
