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
use Test::More tests => 19;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

require Math::PlanePath::Columns;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 15;
  is ($Math::PlanePath::Columns::VERSION, $want_version,
      'VERSION variable');
  is (Math::PlanePath::Columns->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::Columns->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::Columns->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  my $path = Math::PlanePath::Columns->new;
  is ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# x_negative, y_negative

{
  my $path = Math::PlanePath::Columns->new (height => 123);
  ok (! $path->x_negative, 'x_negative() instance method');
  ok (! $path->y_negative, 'y_negative() instance method');
}

#------------------------------------------------------------------------------
# rect_to_n_range()

{
  foreach my $elem ([5,  0,0, 0,0,  1,1],
                    [5,  0,1, 0,1,  2,2],
                    [5,  -1,0, -1,1,  -4,-3],
                    [5,  0,0, 0,9999, 1,5 ],
                    [5,  0,3, 0,-9999, 1,4 ],
                   ) {
    my ($height, $x1,$y1,$x2,$y2, $want_lo, $want_hi) = @$elem;
    my $path = Math::PlanePath::Columns->new (height => $height);
    my ($got_lo, $got_hi) = $path->rect_to_n_range ($x1,$y1, $x2,$y2);
    is ($got_lo, $want_lo, "lo on $x1,$y1 $x2,$y2 height=$height");
    is ($got_hi, $want_hi, "hi on $x1,$y1 $x2,$y2 height=$height");
  }
}

exit 0;
