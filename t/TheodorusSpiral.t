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
use Test;
BEGIN { plan tests => 44; }

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

require Math::PlanePath::TheodorusSpiral;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 27;
  ok ($Math::PlanePath::TheodorusSpiral::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::TheodorusSpiral->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::TheodorusSpiral->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::TheodorusSpiral->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::TheodorusSpiral->new;
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
  my $path = Math::PlanePath::TheodorusSpiral->new;
  ok ($path->n_start, 0, 'n_start()');
  ok ($path->x_negative, 1, 'x_negative()');
  ok ($path->y_negative, 1, 'y_negative()');
}

#------------------------------------------------------------------------------
# _rect_r_range()

foreach my $elem ([ 0,0, 0,0,   0,0 ],

                  [ 1,0, 0,0,   0,1 ],
                  [ 0,1, 0,0,   0,1 ],
                  [ 0,0, 1,0,   0,1 ],
                  [ 0,0, 0,1,   0,1 ],

                  [ 3,1, -3,4,   1,5 ],
                  [ -3,1, 3,4,   1,5 ],
                  [ -3,4, 3,1,   1,5 ],
                  [ 3,4, -3,1,   1,5 ],

                  [ 1,3, 4,-3,   1,5 ],
                  [ 1,-3, 4,3,   1,5 ],
                  [ 4,-3, 1,3,   1,5 ],
                  [ 4,3, 1,-3,   1,5 ],

                  [ -3,-4, 3,4,  0,5 ],
                  [ 3,-4, -3,4,  0,5 ],
                  [ 3,4, -3,-4,  0,5 ],
                  [ -3,4, 3,-4,  0,5 ],

                 ) {
  my ($x1,$y1, $x2,$y2, $want_rlo,$want_rhi) = @$elem;
  my ($got_rlo,$got_rhi)
    = Math::PlanePath::TheodorusSpiral::_rect_r_range ($x1,$y1, $x2,$y2);
  ok ($got_rlo, $want_rlo, '_rect_r_range() rlo');
  ok ($got_rhi, $want_rhi, '_rect_r_range() rhi');
}

exit 0;
