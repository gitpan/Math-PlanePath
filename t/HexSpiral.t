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
use Test::More tests => 35;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

require Math::PlanePath::HexSpiral;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 11;
  is ($Math::PlanePath::HexSpiral::VERSION, $want_version,
      'VERSION variable');
  is (Math::PlanePath::HexSpiral->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::HexSpiral->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::HexSpiral->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  my $path = Math::PlanePath::HexSpiral->new;
  is ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# x_negative, y_negative

{
  ok (Math::PlanePath::HexSpiral->x_negative, 'x_negative() class method');
  ok (Math::PlanePath::HexSpiral->y_negative, 'y_negative() class method');
  my $path = Math::PlanePath::HexSpiral->new (height => 123);
  ok ($path->x_negative, 'x_negative() instance method');
  ok ($path->y_negative, 'y_negative() instance method');
}

#------------------------------------------------------------------------------
# n_to_xy

#              28 -- 27 -- 26 -- 25                  3
#             /                    \
#           29    13 -- 12 -- 11    24               2
#          /     /              \     \
#        30    14     4 --- 3    10    23            1
#       /     /     /         \     \    \
#     31    15     5     1 --- 2     9    22    <- y=0
#       \     \     \              /     /
#        32    16     6 --- 7 --- 8    21           -1
#          \     \                    /
#           33    17 -- 18 -- 19 -- 20              -2
#             \
#              34 -- 35 ...                         -3
# 
#      ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^
#     -6 -5 -4 -3 -2 -1 x=0 1  2  3  4  5  6

{
  my @data = ([ 1, 0,0 ],

              [ 2, 2,0 ],
              [ 3, 1,1 ],

              [ 4, -1,1 ],
              [ 5, -2,0 ],

              [ 6, -1,-1 ],
              [ 7,  1,-1 ],
              [ 8,  3,-1 ],
             );
  my $path = Math::PlanePath::HexSpiral->new;
  foreach my $elem (@data) {
    my ($n, $want_x, $want_y) = @$elem;
    my ($got_x, $got_y) = $path->n_to_xy ($n);
    is ($got_x, $want_x, "x at n=$n");
    is ($got_y, $want_y, "y at n=$n");
  }

  foreach my $elem (@data) {
    my ($want_n, $x, $y) = @$elem;
    my $got_n = $path->xy_to_n ($x, $y);
    is ($got_n, $want_n, "n at x=$x,y=$y");
  }
}

 0;
