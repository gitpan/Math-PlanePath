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
use Test;
BEGIN { plan tests => 115 }

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

require Math::PlanePath::KochSnowflakes;

  my $path = Math::PlanePath::KochSnowflakes->new;

#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 68;
  ok ($Math::PlanePath::KochSnowflakes::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::KochSnowflakes->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::KochSnowflakes->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::KochSnowflakes->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  ok ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      1,
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      1,
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# n_start, x_negative, y_negative

{
  ok ($path->n_start, 1, 'n_start()');
  ok ($path->x_negative, 1, 'x_negative()');
  ok ($path->y_negative, 1, 'y_negative()');
  ok ($path->class_x_negative, 1, 'class_x_negative()');
  ok ($path->class_y_negative, 1, 'class_y_negative()');
}

#------------------------------------------------------------------------------
# first few points

{
  my @data = (
              [ 4.5, -2,-1 ],
              [ 5.5, -.5,-1.5 ],

              [ 4, -3,-1 ],
              [ 5, -1,-1 ],
              [ 6, 0,-2 ],
             );
  my $path = Math::PlanePath::KochSnowflakes->new;
  foreach my $elem (@data) {
    my ($n, $want_x, $want_y) = @$elem;
    my ($got_x, $got_y) = $path->n_to_xy ($n);
    ok ($got_x, $want_x, "n_to_xy() x at n=$n");
    ok ($got_y, $want_y, "n_to_xy() y at n=$n");
  }

  foreach my $elem (@data) {
    my ($want_n, $x, $y) = @$elem;
    next unless $want_n==int($want_n);
    my $got_n = $path->xy_to_n ($x, $y);
    ok ($got_n, $want_n, "xy_to_n() n at x=$x,y=$y");
  }

  foreach my $elem (@data) {
    my ($n, $x, $y) = @$elem;
    $n = int($n+.5);
    my ($got_nlo, $got_nhi) = $path->rect_to_n_range (0,0, $x,$y);
    ok ($got_nlo <= $n, 1, "rect_to_n_range() nlo=$got_nlo at n=$n,x=$x,y=$y");
    ok ($got_nhi >= $n, 1, "rect_to_n_range() nhi=$got_nhi at n=$n,x=$x,y=$y");
  }
}

#------------------------------------------------------------------------------
# xy_to_n_list()

{
  my @data = (
              [ -1, 0, [1] ],
              [ -1, -.333, [1] ],
              [ -1, -.5, [1] ],

              [ -1, -.6, [1,5] ],
              [ -1, -1, [5] ],

              [ 1, 0, [2] ],
              [ 1, -.333, [2] ],
              [ 1, -.5, [2] ],

              [ 1, -.6, [2,7] ],
              [ 1, -1, [7] ],

              [ 0, .666, [3] ],
              [ 0, 1, [3] ],
              [ 0, .5, [3] ],

              [ 0, -1, [] ],
              [ 8, 0, [] ],
              [ 9, 0, [] ],
             );
  foreach my $elem (@data) {
    my ($x,$y, $want_n_aref) = @$elem;
    my $want_n_str = join(',', @$want_n_aref);
    {
      my @got_n_list = $path->xy_to_n_list($x,$y);
      ok (scalar(@got_n_list), scalar(@$want_n_aref));
      my $got_n_str = join(',', @got_n_list);
      ok ($got_n_str, $want_n_str);
    }
    {
      my $got_n = $path->xy_to_n($x,$y);
      ok ($got_n, $want_n_aref->[0]);
    }
    {
      my @got_n = $path->xy_to_n($x,$y);
      ok (scalar(@got_n), 1);
      ok ($got_n[0], $want_n_aref->[0]);
    }
  }
}
exit 0;
