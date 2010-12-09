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
use Test::More tests => 92;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

require Math::PlanePath::SquareSpiral;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 14;
  is ($Math::PlanePath::SquareSpiral::VERSION, $want_version,
      'VERSION variable');
  is (Math::PlanePath::SquareSpiral->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::SquareSpiral->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::SquareSpiral->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  my $path = Math::PlanePath::SquareSpiral->new;
  is ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# x_negative, y_negative

{
  ok (Math::PlanePath::SquareSpiral->x_negative,
      'x_negative() class method');
  ok (Math::PlanePath::SquareSpiral->y_negative,
      'y_negative() class method');
  my $path = Math::PlanePath::SquareSpiral->new (height => 123);
  ok ($path->x_negative, 'x_negative() instance method');
  ok ($path->y_negative, 'y_negative() instance method');
}

#------------------------------------------------------------------------------
# n_to_xy

#   17 16 15 14 13
#   18  5  4  3 12
#   19  6  1  2 11
#   20  7  8  9 10
#   21 22 23 24 25 26
{
  my @data = ([ 1, 0,0 ],
              [ 2, 1,0 ],

              [ 3, 1,1 ], # top
              [ 4, 0,1 ],

              [ 5, -1,1 ],  # left
              [ 6, -1,0 ],

              [ 7, -1,-1 ], # bottom
              [ 8,  0,-1 ],
              [ 9,  1,-1 ],

              [ 10,  2,-1 ], # right
              [ 11,  2, 0 ],
              [ 12,  2, 1 ],

              [ 13,   2,2 ], # top
              [ 14,   1,2 ],
              [ 15,   0,2 ],
              [ 16,  -1,2 ],

              [ 17,  -2, 2 ], # left
              [ 18,  -2, 1 ],
              [ 19,  -2, 0 ],
              [ 20,  -2,-1 ],

              [ 21,  -2,-2 ], # bottom
              [ 22,  -1,-2 ],
              [ 23,   0,-2 ],
              [ 24,   1,-2 ],
              [ 25,   2,-2 ],

              [ 26,   3,-2 ], # right
              [ 27,   3,-1 ],
             );
  my $path = Math::PlanePath::SquareSpiral->new;
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

exit 0;
