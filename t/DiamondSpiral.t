#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

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
use Test::More tests => 63;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

require Math::PlanePath::DiamondSpiral;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 15;
  is ($Math::PlanePath::DiamondSpiral::VERSION, $want_version,
      'VERSION variable');
  is (Math::PlanePath::DiamondSpiral->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::DiamondSpiral->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::DiamondSpiral->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  my $path = Math::PlanePath::DiamondSpiral->new;
  is ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      "VERSION object check $check_version");
}


#------------------------------------------------------------------------------
# x_negative, y_negative

{
  my $path = Math::PlanePath::DiamondSpiral->new (height => 123);
  ok ($path->x_negative, 'x_negative() instance method');
  ok ($path->y_negative, 'y_negative() instance method');
}

#------------------------------------------------------------------------------
# xy_to_n

{
  my @data = ([1, 0,0 ],

              [2, 1,0 ],
              [3, 0,1 ],
              [4, -1,0 ],
              [5, 0,-1 ],
              [5.25, 0.25,-1 ],
              [5.75, 0.75,-1 ],

              [6, 1,-1 ],
              [7, 2,0 ],
              [8, 1,1 ],
              [9, 0,2 ],
              [10, -1,1 ],
              [11, -2,0 ],
              [12, -1,-1 ],
              [13, 0,-2 ],
              [13.25, 0.25,-2 ],
              [13.75, 0.75,-2 ],

              [14, 1,-2 ],
             );
  my $path = Math::PlanePath::DiamondSpiral->new;
  foreach my $elem (@data) {
    my ($n, $want_x, $want_y) = @$elem;
    my ($got_x, $got_y) = $path->n_to_xy ($n);
    is ($got_x, $want_x, "x at n=$n");
    is ($got_y, $want_y, "y at n=$n");
  }

  foreach my $elem (@data) {
    my ($want_n, $x, $y) = @$elem;
    $want_n = int ($want_n + 0.5);
    my $got_n = $path->xy_to_n ($x, $y);
    is ($got_n, $want_n, "n at x=$x,y=$y");
  }
}

exit 0;
