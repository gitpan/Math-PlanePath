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

# uncomment this to run the ### lines
#use Devel::Comments '###';

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

my $test_count = (tests => 59)[1];
plan tests => $test_count;

if (! eval { require Math::NumSeq; 1 }) {
  MyTestHelpers::diag ('skip due to Math::NumSeq not available -- ',$@);
  foreach (1 .. $test_count) {
    skip ('due to no Math::NumSeq', 1, 1);
  }
  exit 0;
}

require Math::NumSeq::PlanePathCoord;


#------------------------------------------------------------------------------
# characteristic()

foreach my $elem
  (['monotonic',undef ], # default SquareSpiral X not monotonic
   ['monotonic', 1, planepath => 'Hypot', coordinate_type => 'Radius' ],
   ['monotonic', 1, planepath => 'Hypot', coordinate_type => 'Radius' ],
   ['monotonic', 1, planepath => 'HypotOctant', coordinate_type => 'Radius' ],
   ['monotonic', 1, planepath => 'HypotOctant', coordinate_type => 'RSquared' ],
  ) {
  my ($key, $want, @parameters) = @$elem;

  my $seq = Math::NumSeq::PlanePathCoord->new (@parameters);
  ok ($seq->characteristic($key), $want);
}


#------------------------------------------------------------------------------
# values_min(), values_max()

foreach my $elem
  ([undef, undef ], # default undef for SquareSpiral X
   [0,undef, coordinate_type => 'Radius' ],
   [0,undef, coordinate_type => 'RSquared' ],
   [0,undef, planepath => 'HilbertCurve', coordinate_type => 'X' ],
   [0,undef, planepath => 'HilbertCurve', coordinate_type => 'Y' ],
   [0,undef, planepath => 'HilbertCurve', coordinate_type => 'Sum' ],
   [0,undef, planepath => 'HypotOctant', coordinate_type => 'X' ],

   [undef,undef, planepath => 'CellularRule54', coordinate_type => 'X' ],
   [0,undef, planepath => 'CellularRule54', coordinate_type => 'Y' ],
   [0,undef, planepath => 'CellularRule54', coordinate_type => 'Sum' ],
   [0,undef, planepath => 'CellularRule54', coordinate_type => 'Radius' ],
   [0,undef, planepath => 'CellularRule54', coordinate_type => 'RSquared' ],

   [undef,undef, planepath => 'CellularRule190', coordinate_type => 'X' ],
   [0,undef, planepath => 'CellularRule190', coordinate_type => 'Y' ],
   [0,undef, planepath => 'CellularRule190', coordinate_type => 'Sum' ],
   [0,undef, planepath => 'CellularRule190', coordinate_type => 'Radius' ],
   [0,undef, planepath => 'CellularRule190', coordinate_type => 'RSquared' ],

   [undef,undef, planepath => 'UlamWarburton', coordinate_type => 'X' ],
   [undef,undef, planepath => 'UlamWarburton', coordinate_type => 'Y' ],
   [undef,undef, planepath => 'UlamWarburton', coordinate_type => 'Sum' ],
   [0,undef, planepath => 'UlamWarburton', coordinate_type => 'Radius' ],
   [0,undef, planepath => 'UlamWarburton', coordinate_type => 'RSquared' ],

   [0,undef, planepath => 'UlamWarburtonQuarter', coordinate_type => 'X' ],
   [0,undef, planepath => 'UlamWarburtonQuarter', coordinate_type => 'Y' ],
   [0,undef, planepath => 'UlamWarburtonQuarter', coordinate_type => 'Sum' ],
   [0,undef, planepath => 'UlamWarburtonQuarter', coordinate_type => 'Radius' ],
   [0,undef, planepath => 'UlamWarburtonQuarter', coordinate_type => 'RSquared' ],

  ) {
  my ($want_min,$want_max, @parameters) = @$elem;

  my $seq = Math::NumSeq::PlanePathCoord->new (@parameters);
  ok ($seq->values_min, $want_min, "values_min() ".join(',',@parameters));
  ok ($seq->values_max, $want_max, "values_max() ".join(',',@parameters));
}


#------------------------------------------------------------------------------
exit 0;
