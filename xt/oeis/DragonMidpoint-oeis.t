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
plan tests => 3;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::DragonMidpoint;

# uncomment this to run the ### lines
#use Smart::Comments '###';


#------------------------------------------------------------------------------
# A073089 -- abs(dY), so 1 if step vertical, 0 if horizontal
#            with extra leading 0

MyOEIS::compare_values
  (anum => 'A073089',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::DragonMidpoint->new;
     my @got = (0);
     my ($prev_x, $prev_y) = $path->n_to_xy (0);
     for (my $n = $path->n_start + 1; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       if ($x == $prev_x) {
         push @got, 1;  # vertical
       } else {
         push @got, 0;  # horizontal
       }
       ($prev_x,$prev_y) = ($x,$y);
     }
     return \@got;
   });

# A073089_func vs b-file
MyOEIS::compare_values
  (anum => 'A073089',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = 1; @got < $count; $n++) {
       push @got, A073089_func($n);
     }
     return \@got;
   });


# A073089_func vs path
{
  my $path = Math::PlanePath::DragonMidpoint->new;
  my ($prev_x, $prev_y) = $path->n_to_xy (0);
  my $n = 0;
  my $bad = 0;
  foreach my $n (0 .. 0x2FFF) {
    my ($x, $y) = $path->n_to_xy ($n);
    my ($nx, $ny) = $path->n_to_xy ($n+1);
    my $path_value = ($x == $nx
                      ? 1   # vertical
                      : 0); # horizontal

    my $a_value = A073089_func($n+2);

    if ($path_value != $a_value) {
      MyTestHelpers::diag ("diff n=$n path=$path_value acalc=$a_value");
      MyTestHelpers::diag ("  xy=$x,$y  nxy=$nx,$ny");
      last if ++$bad > 10;
    }
  }
  ok ($bad, 0, "A073089_func()");
}

sub A073089_func {
  my ($n) = @_;
  ### A073089_func: $n
  for (;;) {
    if ($n <= 1) { return 0; }
    if (($n % 4) == 2) { return 0; }
    if (($n % 8) == 7) { return 0; }
    if (($n % 16) == 13) { return 0; }

    if (($n % 4) == 0) { return 1; }
    if (($n % 8) == 3) { return 1; }
    if (($n % 16) == 5) { return 1; }

    if (($n % 8) == 1) {
      $n = ($n-1)/2+1;  # 8n+1 -> 4n+1
      next;
    }
    die "oops";
  }
}

#------------------------------------------------------------------------------
exit 0;
