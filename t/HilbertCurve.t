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

use 5.004;
use strict;
use warnings;
use List::Util 'min', 'max';
use Test::More tests => 12;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Smart::Comments '###';

require Math::PlanePath::HilbertCurve;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 14;
  is ($Math::PlanePath::HilbertCurve::VERSION, $want_version,
      'VERSION variable');
  is (Math::PlanePath::HilbertCurve->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::HilbertCurve->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::HilbertCurve->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  my $path = Math::PlanePath::HilbertCurve->new;
  is ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# x_negative, y_negative

{
  ok (!Math::PlanePath::HilbertCurve->x_negative, 'x_negative() class method');
  ok (!Math::PlanePath::HilbertCurve->y_negative, 'y_negative() class method');
  my $path = Math::PlanePath::HilbertCurve->new (height => 123);
  ok (!$path->x_negative, 'x_negative() instance method');
  ok (!$path->y_negative, 'y_negative() instance method');
}

#------------------------------------------------------------------------------
# rect_to_n_range()

{
  my $path = Math::PlanePath::HilbertCurve->new;
  my $good = 1;

  my $data;
  my $limit = 15;
  foreach my $x (0 .. $limit) {
    foreach my $y (0 .. $limit) {
      $data->[$y]->[$x] = $path->xy_to_n ($x, $y);
    }
  }
  #### $data

  my $count = 0;
  foreach my $y1 (0 .. $limit) {
    foreach my $y2 ($y1 .. $limit) {

      foreach my $x1 (0 .. $limit) {
        my $min = ($limit+1)**2;
        my $max = -1;

        foreach my $x2 ($x1 .. $limit) {
          my @col = map {$data->[$_]->[$x2]} $y1 .. $y2;
          $max = max ($max, @col);
          $min = min ($min, @col);
          ### @col
          ### $max
          ### $min

          my ($got_min, $got_max) = $path->rect_to_n_range ($x1,$y1, $x2,$y2);
          if ($got_min != $min) {
            diag "bad min $x1,$y1 $x2,$y2 got $got_min want $min";
            $good = 0;
          }
          if ($got_max != $max) {
            diag "bad max $x1,$y1 $x2,$y2 got $got_max want $max";
            $good = 0;
          }
          $count++;
        }
      }
    }
  }

  ok ($good, "rect_to_n_range(), total $count rects");
}

exit 0;
