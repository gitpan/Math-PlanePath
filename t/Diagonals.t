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
use Test::More tests => 52;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

require Math::PlanePath::Diagonals;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 22;
  is ($Math::PlanePath::Diagonals::VERSION, $want_version,
      'VERSION variable');
  is (Math::PlanePath::Diagonals->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::Diagonals->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::Diagonals->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  my $path = Math::PlanePath::Diagonals->new;
  is ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      "VERSION object check $check_version");
}


#------------------------------------------------------------------------------
# n_start, x_negative, y_negative

{
  my $path = Math::PlanePath::Diagonals->new;
  is ($path->n_start, 1, 'n_start()');
  ok (! $path->x_negative, 'x_negative()');
  ok (! $path->y_negative, 'y_negative()');
}

#------------------------------------------------------------------------------
# xy_to_n

{
  my @data = ([0.5, -0.5,0.5 ],
              [0.75, -0.25,0.25 ],
              [1, 0,0 ],
              [1.25, .25,-.25 ],

              [1.5, -.5,1.5 ],
              [2, 0,1 ],
              [3, 1,0 ],

              [4, 0,2 ],
              [5, 1,1 ],
              [6, 2,0 ],

              [7,  0,3 ],
              [8,  1,2 ],
              [9,  2,1 ],
              [10, 3,0 ],

             );
  my $path = Math::PlanePath::Diagonals->new;
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
