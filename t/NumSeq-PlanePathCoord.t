#!/usr/bin/perl -w

# Copyright 2010, 2011, 2012 Kevin Ryde

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
#use Smart::Comments '###';

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

my $test_count = (tests => 434)[1];
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
  (['increasing',undef ], # default SquareSpiral X not monotonic
   ['non_decreasing', 1, planepath => 'Hypot', coordinate_type => 'Radius' ],
   ['non_decreasing', 1, planepath => 'Hypot', coordinate_type => 'Radius' ],
   ['non_decreasing', 1, planepath => 'HypotOctant', coordinate_type => 'Radius' ],
   ['non_decreasing', 1, planepath => 'HypotOctant', coordinate_type => 'RSquared' ],

   ['smaller', 1, planepath => 'SquareSpiral', coordinate_type => 'X' ],
   ['smaller', 1, planepath => 'SquareSpiral', coordinate_type => 'RSquared' ],

   ['smaller', 0, planepath => 'MultipleRings,step=0', coordinate_type => 'RSquared' ],
   ['smaller', 0, planepath => 'MultipleRings,step=1', coordinate_type => 'RSquared' ],
   ['smaller', 1, planepath => 'MultipleRings,step=2', coordinate_type => 'RSquared' ],

  ) {
  my ($key, $want, @parameters) = @$elem;

  my $seq = Math::NumSeq::PlanePathCoord->new (@parameters);
  ok ($seq->characteristic($key), $want,
      "characteristic($key) on ".join(', ',@parameters));
}


#------------------------------------------------------------------------------
# values_min(), values_max()

foreach my $elem
  ([undef,undef, planepath => 'SquareSpiral' ], # default coordinate_type=>X
   [0,undef, planepath => 'SquareSpiral', coordinate_type => 'Radius' ],
   [0,undef, planepath => 'SquareSpiral', coordinate_type => 'RSquared' ],

   [0,undef, planepath => 'HilbertCurve', coordinate_type => 'X' ],
   [0,undef, planepath => 'HilbertCurve', coordinate_type => 'Y' ],
   [0,undef, planepath => 'HilbertCurve', coordinate_type => 'Sum' ],
   [0,undef, planepath => 'HilbertCurve', coordinate_type => 'Product' ],

   [undef,undef, planepath => 'CellularRule54', coordinate_type => 'X' ],
   [0,undef,     planepath => 'CellularRule54', coordinate_type => 'Y' ],
   [0,undef,     planepath => 'CellularRule54', coordinate_type => 'Sum' ],
   [undef,undef, planepath => 'CellularRule54', coordinate_type => 'Product' ],
   [0,undef,     planepath => 'CellularRule54', coordinate_type => 'Radius' ],
   [0,undef,     planepath => 'CellularRule54', coordinate_type => 'RSquared' ],
   [undef,0,     planepath => 'CellularRule54', coordinate_type => 'DiffXY' ],
   [0,undef,     planepath => 'CellularRule54', coordinate_type => 'DiffYX' ],
   [0,undef,     planepath => 'CellularRule54', coordinate_type => 'AbsDiff' ],

   [undef,undef, planepath => 'CellularRule190', coordinate_type => 'X' ],
   [0,undef,     planepath => 'CellularRule190', coordinate_type => 'Y' ],
   [0,undef,     planepath => 'CellularRule190', coordinate_type => 'Sum' ],
   [undef,undef, planepath => 'CellularRule190', coordinate_type => 'Product' ],
   [0,undef,   planepath => 'CellularRule190', coordinate_type => 'Radius' ],
   [0,undef,   planepath => 'CellularRule190', coordinate_type => 'RSquared' ],

   [undef,undef, planepath => 'UlamWarburton', coordinate_type => 'X' ],
   [undef,undef, planepath => 'UlamWarburton', coordinate_type => 'Y' ],
   [undef,undef, planepath => 'UlamWarburton', coordinate_type => 'Sum' ],
   [undef,undef, planepath => 'UlamWarburton', coordinate_type => 'Product' ],
   [0,undef, planepath => 'UlamWarburton', coordinate_type => 'Radius' ],
   [0,undef, planepath => 'UlamWarburton', coordinate_type => 'RSquared' ],

   [0,undef, planepath => 'UlamWarburtonQuarter', coordinate_type => 'X' ],
   [0,undef, planepath => 'UlamWarburtonQuarter', coordinate_type => 'Y' ],
   [0,undef, planepath => 'UlamWarburtonQuarter', coordinate_type => 'Sum' ],
   [0,undef, planepath => 'UlamWarburtonQuarter', coordinate_type => 'Product' ],
   [0,undef, planepath => 'UlamWarburtonQuarter', coordinate_type => 'Radius' ],
   [0,undef, planepath => 'UlamWarburtonQuarter', coordinate_type => 'RSquared' ],


   [3,undef, planepath => 'PythagoreanTree', coordinate_type => 'X' ],
   [4,undef, planepath => 'PythagoreanTree', coordinate_type => 'Y' ],
   [7,undef, planepath => 'PythagoreanTree', coordinate_type => 'Sum' ],
   [3*4,undef, planepath => 'PythagoreanTree', coordinate_type => 'Product' ],
   [5,undef, planepath => 'PythagoreanTree', coordinate_type => 'Radius' ],
   [25,undef, planepath => 'PythagoreanTree', coordinate_type => 'RSquared' ],
   [undef,undef, planepath => 'PythagoreanTree', coordinate_type => 'DiffXY' ],
   [undef,undef, planepath => 'PythagoreanTree', coordinate_type => 'DiffYX' ],
   [0,undef, planepath => 'PythagoreanTree', coordinate_type => 'AbsDiff' ],

   [2,undef, planepath => 'PythagoreanTree,coordinates=PQ', coordinate_type => 'X' ],
   [1,undef, planepath => 'PythagoreanTree,coordinates=PQ', coordinate_type => 'Y' ],
   [3,undef, planepath => 'PythagoreanTree,coordinates=PQ', coordinate_type => 'Sum' ],
   [2,undef, planepath => 'PythagoreanTree,coordinates=PQ', coordinate_type => 'Product' ],
   #[sqrt(5),undef, planepath => 'PythagoreanTree,coordinates=PQ', coordinate_type => 'Radius' ],
   [5,undef, planepath => 'PythagoreanTree,coordinates=PQ', coordinate_type => 'RSquared' ],
   [1,undef, planepath => 'PythagoreanTree,coordinates=PQ', coordinate_type => 'DiffXY' ],
   [undef,-1, planepath => 'PythagoreanTree,coordinates=PQ', coordinate_type => 'DiffYX' ],
   [1,undef, planepath => 'PythagoreanTree,coordinates=PQ', coordinate_type => 'AbsDiff' ],


   [0,undef, planepath => 'HypotOctant', coordinate_type => 'X' ],
   [0,undef, planepath => 'HypotOctant', coordinate_type => 'Y' ],
   [0,undef, planepath => 'HypotOctant', coordinate_type => 'Sum' ],
   [0,undef, planepath => 'HypotOctant', coordinate_type => 'Product' ],
   [0,undef, planepath => 'HypotOctant', coordinate_type => 'Radius' ],
   [0,undef, planepath => 'HypotOctant', coordinate_type => 'RSquared' ],
   [0,undef, planepath => 'HypotOctant', coordinate_type => 'DiffXY' ],
   [undef,0, planepath => 'HypotOctant', coordinate_type => 'DiffYX' ],
   [0,undef, planepath => 'HypotOctant', coordinate_type => 'AbsDiff' ],


   [2,undef, planepath => 'DivisibleColumns,divisor_type=proper', coordinate_type => 'X' ],
   [1,undef, planepath => 'DivisibleColumns,divisor_type=proper', coordinate_type => 'Y' ],
   [3,undef, planepath => 'DivisibleColumns,divisor_type=proper', coordinate_type => 'Sum' ],
   [2,undef, planepath => 'DivisibleColumns,divisor_type=proper', coordinate_type => 'Product' ],
   # [sqrt(5),undef, planepath => 'DivisibleColumns,divisor_type=proper', coordinate_type => 'Radius' ],
   [5,undef, planepath => 'DivisibleColumns,divisor_type=proper', coordinate_type => 'RSquared' ],
   [1,undef, planepath => 'DivisibleColumns,divisor_type=proper', coordinate_type => 'DiffXY' ],
   [undef,-1, planepath => 'DivisibleColumns,divisor_type=proper', coordinate_type => 'DiffYX' ],
   [1,undef, planepath => 'DivisibleColumns,divisor_type=proper', coordinate_type => 'AbsDiff' ],

   [1,undef, planepath => 'DivisibleColumns', coordinate_type => 'X' ],
   [1,undef, planepath => 'DivisibleColumns', coordinate_type => 'Y' ],
   [2,undef, planepath => 'DivisibleColumns', coordinate_type => 'Sum' ],
   [1,undef, planepath => 'DivisibleColumns', coordinate_type => 'Product' ],
   # [sqrt(2),undef, planepath => 'DivisibleColumns', coordinate_type => 'Radius' ],
   [2,undef, planepath => 'DivisibleColumns', coordinate_type => 'RSquared' ],
   [0,undef, planepath => 'DivisibleColumns', coordinate_type => 'DiffXY' ],
   [undef,0, planepath => 'DivisibleColumns', coordinate_type => 'DiffYX' ],
   [0,undef, planepath => 'DivisibleColumns', coordinate_type => 'AbsDiff' ],


   [1,undef, planepath => 'CoprimeColumns', coordinate_type => 'X' ],
   [1,undef, planepath => 'CoprimeColumns', coordinate_type => 'Y' ],
   [2,undef, planepath => 'CoprimeColumns', coordinate_type => 'Sum' ],
   [1,undef, planepath => 'CoprimeColumns', coordinate_type => 'Product' ],
   # [sqrt(2),undef, planepath => 'CoprimeColumns', coordinate_type => 'Radius' ],
   [2,undef, planepath => 'CoprimeColumns', coordinate_type => 'RSquared' ],
   [0,undef, planepath => 'CoprimeColumns', coordinate_type => 'DiffXY' ],
   [undef,0, planepath => 'CoprimeColumns', coordinate_type => 'DiffYX' ],
   [0,undef, planepath => 'CoprimeColumns', coordinate_type => 'AbsDiff' ],

   [1,undef, planepath => 'RationalsTree', coordinate_type => 'X' ],
   [1,undef, planepath => 'RationalsTree', coordinate_type => 'Y' ],
   # X>=1 and Y>=1 always so Sum>=2
   [2,undef, planepath => 'RationalsTree', coordinate_type => 'Sum' ],
   [1,undef, planepath => 'RationalsTree', coordinate_type => 'Product' ],
   # [sqrt(2),undef, planepath => 'RationalsTree', coordinate_type => 'Radius' ],
   [2,undef, planepath => 'RationalsTree', coordinate_type => 'RSquared' ],
   # whole first quadrant so diff positive and negative
   [undef,undef, planepath => 'RationalsTree', coordinate_type => 'DiffXY' ],
   [undef,undef, planepath => 'RationalsTree', coordinate_type => 'DiffYX' ],
   [0,undef,     planepath => 'RationalsTree', coordinate_type => 'AbsDiff' ],

   [0,undef, planepath => 'QuadricCurve', coordinate_type => 'X' ],
   [undef,undef, planepath => 'QuadricCurve', coordinate_type => 'Y' ],
   [0,undef, planepath => 'QuadricCurve', coordinate_type => 'Sum' ],
   [undef,undef, planepath => 'QuadricCurve', coordinate_type => 'Product' ],
   [0,undef, planepath => 'QuadricCurve', coordinate_type => 'Radius' ],
   [0,undef, planepath => 'QuadricCurve', coordinate_type => 'RSquared' ],
   [0,undef, planepath => 'QuadricCurve', coordinate_type => 'DiffXY' ],
   [undef,0, planepath => 'QuadricCurve', coordinate_type => 'DiffYX' ],
   [0,undef, planepath => 'QuadricCurve', coordinate_type => 'AbsDiff' ],

   [0,5,      planepath => 'Rows,width=6', coordinate_type => 'X' ],
   [0,undef,  planepath => 'Rows,width=6', coordinate_type => 'Y' ],
   [0,undef,  planepath => 'Rows,width=6', coordinate_type => 'Sum' ],
   [0,undef,  planepath => 'Rows,width=6', coordinate_type => 'Product' ],
   [0,undef,  planepath => 'Rows,width=6', coordinate_type => 'Radius' ],
   [0,undef,  planepath => 'Rows,width=6', coordinate_type => 'RSquared' ],
   [undef,5,  planepath => 'Rows,width=6', coordinate_type => 'DiffXY' ],
   [-5,undef, planepath => 'Rows,width=6', coordinate_type => 'DiffYX' ],
   [0,undef,  planepath => 'Rows,width=6', coordinate_type => 'AbsDiff' ],

   [0,undef,  planepath => 'Columns,height=6', coordinate_type => 'X' ],
   [0,5,      planepath => 'Columns,height=6', coordinate_type => 'Y' ],
   [0,undef,  planepath => 'Columns,height=6', coordinate_type => 'Sum' ],
   [0,undef,  planepath => 'Columns,height=6', coordinate_type => 'Product' ],
   [0,undef,  planepath => 'Columns,height=6', coordinate_type => 'Radius' ],
   [0,undef,  planepath => 'Columns,height=6', coordinate_type => 'RSquared' ],
   [-5,undef, planepath => 'Columns,height=6', coordinate_type => 'DiffXY' ],
   [undef,5,  planepath => 'Columns,height=6', coordinate_type => 'DiffYX' ],
   [0,undef,  planepath => 'Columns,height=6', coordinate_type => 'AbsDiff' ],

   # step=0 vertical on Y axis only
   [0,0,     planepath=>'PyramidRows,step=0', coordinate_type => 'X' ],
   [0,undef, planepath=>'PyramidRows,step=0', coordinate_type => 'Y' ],
   [0,undef, planepath=>'PyramidRows,step=0', coordinate_type => 'Sum' ],
   [0,0,     planepath=>'PyramidRows,step=0', coordinate_type => 'Product' ],
   [0,undef, planepath=>'PyramidRows,step=0', coordinate_type => 'Radius' ],
   [0,undef, planepath=>'PyramidRows,step=0', coordinate_type => 'RSquared' ],
   [undef,0, planepath=>'PyramidRows,step=0', coordinate_type => 'DiffXY' ],
   [0,undef, planepath=>'PyramidRows,step=0', coordinate_type => 'DiffYX' ],
   [0,undef, planepath=>'PyramidRows,step=0', coordinate_type => 'AbsDiff' ],

   [0,undef, planepath=>'PyramidRows,step=1', coordinate_type => 'X' ],
   [0,undef, planepath=>'PyramidRows,step=1', coordinate_type => 'Y' ],
   [0,undef, planepath=>'PyramidRows,step=1', coordinate_type => 'Sum' ],
   [0,undef, planepath=>'PyramidRows,step=1', coordinate_type => 'Product' ],
   [0,undef, planepath=>'PyramidRows,step=1', coordinate_type => 'Radius' ],
   [0,undef, planepath=>'PyramidRows,step=1', coordinate_type => 'RSquared' ],
   [undef,0, planepath=>'PyramidRows,step=1', coordinate_type => 'DiffXY' ],
   [0,undef, planepath=>'PyramidRows,step=1', coordinate_type => 'DiffYX' ],
   [0,undef, planepath=>'PyramidRows,step=1', coordinate_type => 'AbsDiff' ],

   [undef,undef, planepath=>'PyramidRows,step=2', coordinate_type=>'X' ],
   [0,undef,     planepath=>'PyramidRows,step=2', coordinate_type=>'Y' ],
   [0,undef,     planepath=>'PyramidRows,step=2', coordinate_type=>'Sum' ],
   [undef,undef, planepath=>'PyramidRows,step=2', coordinate_type=>'Product' ],
   [0,undef,     planepath=>'PyramidRows,step=2', coordinate_type=>'Radius' ],
   [0,undef,     planepath=>'PyramidRows,step=2', coordinate_type=>'RSquared'],
   [undef,0,     planepath=>'PyramidRows,step=2', coordinate_type=>'DiffXY' ],
   [0,undef,     planepath=>'PyramidRows,step=2', coordinate_type=>'DiffYX' ],
   [0,undef,     planepath=>'PyramidRows,step=2', coordinate_type=>'AbsDiff' ],

   [undef,undef, planepath => 'PyramidRows,step=3', coordinate_type => 'X' ],
   [0,undef, planepath => 'PyramidRows,step=3', coordinate_type => 'Y' ],
   [undef,undef, planepath => 'PyramidRows,step=3', coordinate_type => 'Sum' ],
   [undef,undef, planepath => 'PyramidRows,step=3', coordinate_type => 'Product' ],
   [0,undef, planepath => 'PyramidRows,step=3', coordinate_type => 'Radius' ],
   [0,undef, planepath => 'PyramidRows,step=3', coordinate_type => 'RSquared' ],
   [undef,undef, planepath => 'PyramidRows,step=3', coordinate_type => 'DiffXY' ],
   [undef,undef, planepath => 'PyramidRows,step=3', coordinate_type => 'DiffYX' ],
   [0,undef, planepath => 'PyramidRows,step=3', coordinate_type => 'AbsDiff' ],

   # Y <= X, so X-Y >= 0
   #            Y-X < 0
   [0,undef, planepath => 'SierpinskiCurve', coordinate_type => 'DiffXY' ],
   [undef,0, planepath => 'SierpinskiCurve', coordinate_type => 'DiffYX' ],
   [0,undef, planepath => 'SierpinskiCurve', coordinate_type => 'AbsDiff' ],

   [0,undef, planepath => 'HIndexing', coordinate_type => 'X' ],
   [0,undef, planepath => 'HIndexing', coordinate_type => 'Y' ],
   [0,undef, planepath => 'HIndexing', coordinate_type => 'Sum' ],
   [0,undef, planepath => 'HIndexing', coordinate_type => 'Product' ],
   [0,undef, planepath => 'HIndexing', coordinate_type => 'Radius' ],
   [0,undef, planepath => 'HIndexing', coordinate_type => 'RSquared' ],
   [undef,0, planepath => 'HIndexing', coordinate_type => 'DiffXY' ],
   [0,undef, planepath => 'HIndexing', coordinate_type => 'DiffYX' ],
   [0,undef, planepath => 'HIndexing', coordinate_type => 'AbsDiff' ],

   # right line
   [0,undef, planepath=>'CellularRule,rule=16', coordinate_type=>'X' ],
   [0,undef, planepath=>'CellularRule,rule=16', coordinate_type=>'Y' ],
   [0,undef, planepath=>'CellularRule,rule=16', coordinate_type=>'Sum' ],
   [0,undef, planepath=>'CellularRule,rule=16', coordinate_type=>'Product' ],
   [0,undef, planepath=>'CellularRule,rule=16', coordinate_type=>'Radius' ],
   [0,undef, planepath=>'CellularRule,rule=16', coordinate_type=>'RSquared' ],
   [0,0,     planepath=>'CellularRule,rule=16', coordinate_type=>'DiffXY' ],
   [0,0,     planepath=>'CellularRule,rule=16', coordinate_type=>'DiffYX' ],
   [0,0,     planepath=>'CellularRule,rule=16', coordinate_type=>'AbsDiff' ],

   # centre line Y axis only
   [0,0,     planepath=>'CellularRule,rule=4', coordinate_type => 'X' ],
   [0,undef, planepath=>'CellularRule,rule=4', coordinate_type => 'Y' ],
   [0,undef, planepath=>'CellularRule,rule=4', coordinate_type => 'Sum' ],
   [0,0,     planepath=>'CellularRule,rule=4', coordinate_type => 'Product' ],
   [0,undef, planepath=>'CellularRule,rule=4', coordinate_type => 'Radius' ],
   [0,undef, planepath=>'CellularRule,rule=4', coordinate_type => 'RSquared' ],
   [undef,0, planepath=>'CellularRule,rule=4', coordinate_type => 'DiffXY' ],
   [0,undef, planepath=>'CellularRule,rule=4', coordinate_type => 'DiffYX' ],
   [0,undef, planepath=>'CellularRule,rule=4', coordinate_type => 'AbsDiff' ],

   # left line
   [undef,0, planepath=>'CellularRule,rule=2', coordinate_type=>'X' ],
   [0,undef, planepath=>'CellularRule,rule=2', coordinate_type=>'Y' ],
   [0,0,     planepath=>'CellularRule,rule=2', coordinate_type=>'Sum' ],
   [undef,0, planepath=>'CellularRule,rule=2', coordinate_type=>'Product' ],
   [0,undef, planepath=>'CellularRule,rule=2', coordinate_type=>'Radius' ],
   [0,undef, planepath=>'CellularRule,rule=2', coordinate_type=>'RSquared' ],
   [undef,0, planepath=>'CellularRule,rule=2', coordinate_type=>'DiffXY' ],
   [0,undef, planepath=>'CellularRule,rule=2', coordinate_type=>'DiffYX' ],
   [0,undef, planepath=>'CellularRule,rule=2', coordinate_type=>'AbsDiff' ],

   # left solid
   [undef,0, planepath=>'CellularRule,rule=206', coordinate_type=>'X' ],
   [0,undef, planepath=>'CellularRule,rule=206', coordinate_type=>'Y' ],
   [0,undef, planepath=>'CellularRule,rule=206', coordinate_type=>'Sum' ],
   [undef,0, planepath=>'CellularRule,rule=206', coordinate_type=>'Product' ],
   [0,undef, planepath=>'CellularRule,rule=206', coordinate_type=>'Radius' ],
   [0,undef, planepath=>'CellularRule,rule=206', coordinate_type=>'RSquared' ],
   [undef,0, planepath=>'CellularRule,rule=206', coordinate_type=>'DiffXY' ],
   [0,undef, planepath=>'CellularRule,rule=206', coordinate_type=>'DiffYX' ],
   [0,undef, planepath=>'CellularRule,rule=206', coordinate_type=>'AbsDiff' ],

   # odd solid
   [undef,undef, planepath=>'CellularRule,rule=50',coordinate_type=>'X' ],
   [0,undef,     planepath=>'CellularRule,rule=50',coordinate_type=>'Y' ],
   [0,undef,     planepath=>'CellularRule,rule=50',coordinate_type=>'Sum' ],
   [undef,undef, planepath=>'CellularRule,rule=50',coordinate_type=>'Product'],
   [0,undef,    planepath=>'CellularRule,rule=50',coordinate_type=>'Radius' ],
   [0,undef,    planepath=>'CellularRule,rule=50',coordinate_type=>'RSquared'],
   [undef,0,    planepath=>'CellularRule,rule=50',coordinate_type=>'DiffXY' ],
   [0,undef,    planepath=>'CellularRule,rule=50',coordinate_type=>'DiffYX' ],
   [0,undef,    planepath=>'CellularRule,rule=50',coordinate_type=>'AbsDiff' ],
  ) {
  my ($want_min,$want_max, @parameters) = @$elem;
  ### @parameters
  ### $want_min
  ### $want_max

  my $seq = Math::NumSeq::PlanePathCoord->new (@parameters);
  ok ($seq->values_min, $want_min,
      "values_min() ".join(',',@parameters));
  ok ($seq->values_max, $want_max,
      "values_max() ".join(',',@parameters));
}


#------------------------------------------------------------------------------
exit 0;
