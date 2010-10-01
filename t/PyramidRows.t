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
use Test::More tests => 11;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

require Math::PlanePath::PyramidRows;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 9;
  is ($Math::PlanePath::PyramidRows::VERSION, $want_version,
      'VERSION variable');
  is (Math::PlanePath::PyramidRows->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::PyramidRows->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::PyramidRows->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  my $path = Math::PlanePath::PyramidRows->new;
  is ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# rect_to_n_range()

{
  foreach my $elem ([2,      0,0, 0,0,  1,1],
                    [undef,  0,1, 0,1,  2,4],
                   ) {
    my ($step, $x1,$y1,$x2,$y2, $want_lo, $want_hi) = @$elem;
    my $path = Math::PlanePath::PyramidRows->new (step => $step);
    my ($got_lo, $got_hi) = $path->rect_to_n_range ($x1,$y1, $x2,$y2);
    is ($got_lo, $want_lo,
        "lo on $x1,$y1 $x2,$y2 step=".(defined $step ? $step : 'undef'));
    is ($got_hi, $want_hi,
        "hi on $x1,$y1 $x2,$y2 step=".(defined $step ? $step : 'undef'));
  }
}

exit 0;
