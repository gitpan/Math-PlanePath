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

my $test_count = (tests => 963)[1];
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
   
   ['increasing', 1, planepath => 'TheodorusSpiral', coordinate_type => 'Radius' ],
   ['increasing', 1, planepath => 'TheodorusSpiral', coordinate_type => 'RSquared' ],
   ['non_decreasing', 1, planepath => 'TheodorusSpiral', coordinate_type => 'Radius' ],
   ['non_decreasing', 1, planepath => 'TheodorusSpiral', coordinate_type => 'RSquared' ],
   ['smaller', 1, planepath => 'TheodorusSpiral', coordinate_type => 'Radius' ],
   ['smaller', 0, planepath => 'TheodorusSpiral', coordinate_type => 'RSquared' ],
   
   ['increasing', 1, planepath => 'VogelFloret', coordinate_type => 'Radius' ],
   ['increasing', 1, planepath => 'VogelFloret', coordinate_type => 'RSquared' ],
   ['non_decreasing', 1, planepath => 'VogelFloret', coordinate_type => 'Radius' ],
   ['non_decreasing', 1, planepath => 'VogelFloret', coordinate_type => 'RSquared' ],
   ['smaller', 1, planepath => 'VogelFloret', coordinate_type => 'Radius' ],
   ['smaller', 0, planepath => 'VogelFloret', coordinate_type => 'RSquared' ],
   
   ['increasing', 1, planepath => 'SacksSpiral', coordinate_type => 'Radius' ],
   ['increasing', 1, planepath => 'SacksSpiral', coordinate_type => 'RSquared' ],
   ['non_decreasing', 1, planepath => 'SacksSpiral', coordinate_type => 'Radius' ],
   ['non_decreasing', 1, planepath => 'SacksSpiral', coordinate_type => 'RSquared' ],
   ['smaller', 1, planepath => 'SacksSpiral', coordinate_type => 'Radius' ],
   ['smaller', 0, planepath => 'SacksSpiral', coordinate_type => 'RSquared' ],
   
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
   [1,undef, planepath => 'PythagoreanTree', coordinate_type => 'AbsDiff' ],
   
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

   # Y <= X-1, so X-Y >= 1
   #              Y-X <= -1
   [1,undef, planepath => 'SierpinskiCurve', coordinate_type => 'DiffXY' ],
   [undef,-1, planepath => 'SierpinskiCurve', coordinate_type => 'DiffYX' ],
   [1,undef, planepath => 'SierpinskiCurve', coordinate_type => 'AbsDiff' ],

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
# values_min(), values_max() by running values

my @modules = (
               (map {"CellularRule,rule=$_"} 0..255),

               # module list begin

               'VogelFloret',
               'SacksSpiral',
               'TheodorusSpiral',
               'ArchimedeanChords',

               'PeanoCurve',
               'PeanoCurve,radix=2',
               'PeanoCurve,radix=4',
               'PeanoCurve,radix=5',
               'PeanoCurve,radix=17',
               'KnightSpiral',

               'Corner',
               'Diagonals',
               'PyramidRows',
               'PyramidRows,step=0',
               'PyramidRows,step=1',
               'PyramidRows,step=3',
               'PyramidRows,step=4',
               'PyramidRows,step=5',
               'PyramidRows,step=37',
               'PyramidSides',
               # 'File',

               'CellularRule,rule=6',   # left 1,2 line
               'CellularRule,rule=14',  # left 2 cell line
               'CellularRule,rule=20',  # right 1,2 line
               'CellularRule,rule=84',  # right 2 cell line

               'CellularRule',
               'CellularRule,rule=0',   # single cell
               'CellularRule,rule=8',   # single cell
               'CellularRule,rule=32',  # single cell
               'CellularRule,rule=40',  # single cell
               'CellularRule,rule=64',  # single cell
               'CellularRule,rule=72',  # single cell
               'CellularRule,rule=96',  # single cell
               'CellularRule,rule=104', # single cell
               'CellularRule,rule=128', # single cell
               'CellularRule,rule=136', # single cell
               'CellularRule,rule=160', # single cell
               'CellularRule,rule=168', # single cell
               'CellularRule,rule=192', # single cell
               'CellularRule,rule=200', # single cell
               'CellularRule,rule=224', # single cell
               'CellularRule,rule=232', # single cell

               'CellularRule,rule=2',  # left line
               'CellularRule,rule=10', # left line
               'CellularRule,rule=34', # left line

               'CellularRule,rule=4',  # centre line
               'CellularRule,rule=12', # centre line
               'CellularRule,rule=36', # centre line

               'CellularRule,rule=16', # right line
               'CellularRule,rule=24', # right line
               'CellularRule,rule=48', # right line

               'CellularRule,rule=206', # left solid
               'CellularRule,rule=50',  # solid every second cell
               'CellularRule,rule=58',  # solid every second cell

               'CellularRule,rule=57',
               'CellularRule,rule=60',
               'CellularRule,rule=18',  # Sierpinski
               'CellularRule,rule=220', # right half solid
               'CellularRule,rule=222', # solid
               'CellularRule54',
               'CellularRule57',
               'CellularRule57,mirror=1',
               'CellularRule190',
               'CellularRule190,mirror=1',

               'Hypot',
               'HypotOctant',
               'PixelRings',
               'FilledRings',
               'MultipleRings',
               'MultipleRings,step=0',
               'MultipleRings,step=1',
               'MultipleRings,step=2',
               'MultipleRings,step=3',
               'MultipleRings,step=5',
               'MultipleRings,step=6',
               'MultipleRings,step=7',
               'MultipleRings,step=8',
               'MultipleRings,step=37',

               'ZOrderCurve',
               'ZOrderCurve,radix=3',
               'ZOrderCurve,radix=9',
               'ZOrderCurve,radix=37',

               'SierpinskiCurve,diagonal_spacing=5',
               'SierpinskiCurve,straight_spacing=5',
               'SierpinskiCurve,diagonal_spacing=3,straight_spacing=7',
               'SierpinskiCurve,diagonal_spacing=3,straight_spacing=7,arms=7',
               'SierpinskiCurve',
               'SierpinskiCurve,arms=2',
               'SierpinskiCurve,arms=3',
               'SierpinskiCurve,arms=4',
               'SierpinskiCurve,arms=5',
               'SierpinskiCurve,arms=6',
               'SierpinskiCurve,arms=7',
               'SierpinskiCurve,arms=8',
               'HIndexing',

               'Staircase',
               'StaircaseAlternating',
               'StaircaseAlternating,end_type=square',

               'CretanLabyrinth',

               'KochCurve',
               'KochPeaks',
               'KochSnowflakes',
               'KochSquareflakes',
               'KochSquareflakes,inward=>1',

               'ComplexPlus',
               'ComplexPlus,realpart=2',
               'ComplexPlus,realpart=3',
               'ComplexPlus,realpart=4',
               'ComplexPlus,realpart=5',

               'TerdragonMidpoint',
               'TerdragonMidpoint,arms=2',
               'TerdragonMidpoint,arms=3',
               'TerdragonMidpoint,arms=4',
               'TerdragonMidpoint,arms=5',
               'TerdragonMidpoint,arms=6',

               'TerdragonCurve',
               'TerdragonCurve,arms=2',
               'TerdragonCurve,arms=3',
               'TerdragonCurve,arms=4',
               'TerdragonCurve,arms=5',
               'TerdragonCurve,arms=6',

               'AlternatePaper',

               'ComplexMinus',
               'ComplexMinus,realpart=2',
               'ComplexMinus,realpart=3',
               'ComplexMinus,realpart=4',
               'ComplexMinus,realpart=5',
               'ComplexRevolving',

               'OctagramSpiral',
               'AnvilSpiral',
               'AnvilSpiral,wider=1',
               'AnvilSpiral,wider=2',
               'AnvilSpiral,wider=9',
               'AnvilSpiral,wider=17',

               'FractionsTree',
               'FactorRationals',
               'GcdRationals',
               'DiagonalRationals',

               'AR2W2Curve',
               'AR2W2Curve,start_shape=D2',
               'AR2W2Curve,start_shape=B2',
               'AR2W2Curve,start_shape=B1rev',
               'AR2W2Curve,start_shape=D1rev',
               'AR2W2Curve,start_shape=A2rev',
               'BetaOmega',
               'KochelCurve',
               'CincoCurve',

               'CoprimeColumns',
               'DivisibleColumns',
               'DivisibleColumns,divisor_type=proper',

               'HilbertSpiral',
               'HilbertCurve',

               'LTiling',
               'LTiling,L_fill=ends',
               'LTiling,L_fill=all',
               'DiagonalsAlternating',
               'MPeaks',
               'WunderlichMeander',
               'FibonacciWordFractal',

               'CornerReplicate',
               'DigitGroups',
               'DigitGroups,radix=3',
               'DigitGroups,radix=4',
               'DigitGroups,radix=5',
               'DigitGroups,radix=37',

               'RationalsTree',
               'RationalsTree,tree_type=CW',
               'RationalsTree,tree_type=AYT',
               'RationalsTree,tree_type=Bird',
               'RationalsTree,tree_type=Drib',

               'TriangularHypot',
               'PythagoreanTree',
               'PythagoreanTree,coordinates=PQ',
               'PythagoreanTree,tree_type=FB',
               'PythagoreanTree,coordinates=PQ,tree_type=FB',

               'SquareSpiral',
               'SquareSpiral,wider=1',
               'SquareSpiral,wider=2',
               'SquareSpiral,wider=3',
               'SquareSpiral,wider=4',
               'SquareSpiral,wider=5',
               'SquareSpiral,wider=6',
               'SquareSpiral,wider=37',
               'DiamondSpiral',
               'PentSpiral',
               'PentSpiralSkewed',

               'HexSpiral',
               'HexSpiral,wider=1',
               'HexSpiral,wider=2',
               'HexSpiral,wider=3',
               'HexSpiral,wider=4',
               'HexSpiral,wider=5',
               'HexSpiral,wider=37',
               'HexSpiralSkewed',
               'HexSpiralSkewed,wider=1',
               'HexSpiralSkewed,wider=2',
               'HexSpiralSkewed,wider=3',
               'HexSpiralSkewed,wider=4',
               'HexSpiralSkewed,wider=5',
               'HexSpiralSkewed,wider=37',

               'HeptSpiralSkewed',
               'PyramidSpiral',
               'TriangleSpiral',
               'TriangleSpiralSkewed',

               'UlamWarburton',
               'UlamWarburtonQuarter',

               'AztecDiamondRings',
               'DiamondArms',
               'SquareArms',
               'HexArms',
               'GreekKeySpiral',

               'Rows',
               'Rows,width=1',
               'Rows,width=2',
               'Columns',
               'Columns,height=1',
               'Columns,height=2',

               'QuintetCurve',
               'QuintetCurve,arms=2',
               'QuintetCurve,arms=3',
               'QuintetCurve,arms=4',
               'QuintetCentres',
               'QuintetCentres,arms=2',
               'QuintetCentres,arms=3',
               'QuintetCentres,arms=4',
               'QuintetReplicate',

               'Flowsnake',
               'Flowsnake,arms=2',
               'Flowsnake,arms=3',
               'FlowsnakeCentres',
               'FlowsnakeCentres,arms=2',
               'FlowsnakeCentres,arms=3',

               'GosperReplicate',
               'GosperSide',
               'GosperIslands',

               'SquareReplicate',
               'ImaginaryBase',
               'ImaginaryBase,radix=3',
               'ImaginaryBase,radix=37',

               'SierpinskiTriangle',
               'SierpinskiArrowhead',
               'SierpinskiArrowheadCentres',
               'QuadricCurve',
               'QuadricIslands',

               'DragonRounded',
               'DragonRounded,arms=2',
               'DragonRounded,arms=3',
               'DragonRounded,arms=4',
               'DragonMidpoint',
               'DragonMidpoint,arms=2',
               'DragonMidpoint,arms=3',
               'DragonMidpoint,arms=4',
               'DragonCurve',
               'DragonCurve,arms=2',
               'DragonCurve,arms=3',
               'DragonCurve,arms=4',

               # module list end
              );

{
  require Math::NumSeq::PlanePathDelta;
  require Math::NumSeq::PlanePathTurn;
  require Math::NumSeq::PlanePathN;

  foreach my $mod (@modules) {
    my $bad = 0;
    foreach my $elem (['Math::NumSeq::PlanePathCoord','coordinate_type'],
                      # ['Math::NumSeq::PlanePathDelta','delta_type'],
                      # ['Math::NumSeq::PlanePathTurn','turn_type'],
                      ['Math::NumSeq::PlanePathN','line_type']) {
      my ($class, $pname) = @$elem;
      foreach my $param (@{$class->parameter_info_hash
                             ->{$pname}->{'choices'}}) {
        ### $mod
        ### $param

        my $seq = $class->new (planepath => $mod,
                               $pname => $param);

        my $i_start = $seq->i_start;
        my $saw_values_min   = 999999999;
        my $saw_values_max   = -1;
        my $saw_values_min_i = 'sentinel';
        my $saw_values_max_i = 'sentinel';
        my $saw_increasing = 1;
        my $saw_non_decreasing = 1;
        my $saw_increasing_at = '';
        my $saw_non_decreasing_at = '';
        my $prev_value;

        my $count = 0;
        foreach my $i ($i_start .. $i_start + 50) {
          my $value = $seq->ith($i);
          next if ! defined $value;
          $count++;

          if ($value < $saw_values_min) {
            $saw_values_min = $value;
            if (my ($x,$y) = $seq->{'planepath_object'}->n_to_xy($i)) {
              $saw_values_min_i = "i=$i xy=$x,$y";
            } else {
              $saw_values_min_i = "i=$i";
            }
          }
          if ($value > $saw_values_max) {
            $saw_values_max = $value;
            $saw_values_max_i = $i;
          }

          ### $value
          ### $prev_value
          if (defined $prev_value) {
            if (abs($value - $prev_value) < 0.0000001) {
              $prev_value = $value;
            }
            if ($value <= $prev_value) {
              ### not increasing ...
              $saw_increasing = 0;
              $saw_increasing_at = "i=$i value=$value prev_value=$prev_value";
              if ($value < $prev_value) {
                $saw_non_decreasing = 0;
                $saw_non_decreasing_at = "i=$i";
              }
            }
          }
          $prev_value = $value;
        }
        next if $count == 0;

        my $values_min = $seq->values_min;
        my $values_max = $seq->values_max;
        if (! defined $values_min) {
          $values_min = $saw_values_min;
        }
        if (! defined $values_max) {
          $values_max = $saw_values_max;
        }

        # these come arbitrarily close to X=Y, in general, probably
        if (($mod eq 'VogelFloret'
             || $mod eq 'MultipleRings,step=2'
             || $mod eq 'MultipleRings,step=3'
             || $mod eq 'MultipleRings,step=5'
             || $mod eq 'MultipleRings,step=7'
             || $mod eq 'MultipleRings,step=37'
            )
            && $param eq 'AbsDiff') {
          $saw_values_min = 0;
          $saw_values_min_i = 'override';
        }

        if (abs ($values_min - $saw_values_min) > 0.0000001) {
          MyTestHelpers::diag ("$mod $param values_min=$values_min vs saw_values_min=$saw_values_min at $saw_values_min_i");
          $bad++;
        }
        if (abs ($values_max - $saw_values_max) > 0.0000001) {
          MyTestHelpers::diag ("$mod $param values_max=$values_max vs saw_values_max=$saw_values_max at i=$saw_values_max_i");
          $bad++;
        }

        my $increasing = $seq->characteristic('increasing');
        my $non_decreasing = $seq->characteristic('non_decreasing');
        $increasing ||= 0;
        $non_decreasing ||= 0;

        # not enough values to see these decreasing
        if (($mod eq 'ZOrderCurve,radix=9'
             || $mod eq 'ZOrderCurve,radix=37'
             || $mod eq 'PeanoCurve,radix=17'
             || $mod eq 'DigitGroups,radix=37'
             || $mod eq 'SquareSpiral,wider=37'
             || $mod eq 'HexSpiral,wider=37'
             || $mod eq 'HexSpiralSkewed,wider=37'
             || $mod eq 'ImaginaryBase,radix=37'
             || $mod eq 'ComplexPlus,realpart=2'
             || $mod eq 'ComplexPlus,realpart=3'
             || $mod eq 'ComplexPlus,realpart=4'
             || $mod eq 'ComplexPlus,realpart=5'
             || $mod eq 'ComplexMinus,realpart=3'
             || $mod eq 'ComplexMinus,realpart=4'
             || $mod eq 'ComplexMinus,realpart=5'
            )
            && ($param eq 'Y'
                || $param eq 'Product')) {
          $saw_increasing = 0;
          $saw_non_decreasing = 0;
        }

        # not enough values to see these decreasing
        if (($mod eq 'ImaginaryBase,radix=37'
             || $mod eq 'ComplexPlus,realpart=2'
             || $mod eq 'ComplexPlus,realpart=3'
             || $mod eq 'ComplexPlus,realpart=4'
             || $mod eq 'ComplexPlus,realpart=5'
             || $mod eq 'ComplexMinus,realpart=5'
             || $mod eq 'TerdragonMidpoint'
             || $mod eq 'TerdragonMidpoint,arms=2'
             || $mod eq 'TerdragonMidpoint,arms=3'
             || $mod eq 'TerdragonCurve'
             || $mod eq 'TerdragonCurve,arms=2'
             || $mod eq 'TerdragonCurve,arms=3'
             || $mod eq 'Flowsnake'
             || $mod eq 'Flowsnake,arms=2'
             || $mod eq 'FlowsnakeCentres'
             || $mod eq 'FlowsnakeCentres,arms=2'
             || $mod eq 'GosperSide'
             || $mod eq 'GosperIslands'
             || $mod eq 'QuintetCentres'
             || $mod eq 'QuintetCentres,arms=2'
             || $mod eq 'QuintetCentres,arms=3'
            )
            && ($param eq 'X_axis'
                || $param eq 'Y_axis'
                || $param eq 'Diagonal'
               )) {
          $saw_increasing = 0;
          $saw_non_decreasing = 0;
        }

        # not enough values to see these decreasing
        if (($mod eq 'DigitGroups,radix=37'
            )
            && ($param eq 'X_axis'
                || $param eq 'Y_axis'
               )) {
          $saw_increasing = 0;
          $saw_non_decreasing = 0;
        }

        # not enough values to see these decreasing
        if (($mod eq 'PeanoCurve,radix=2'
             || $mod eq 'PeanoCurve,radix=4'
             || $mod eq 'PeanoCurve,radix=5'
             || $mod eq 'PeanoCurve,radix=17'
            )
            && ($param eq 'Diagonal'
               )) {
          $saw_increasing = 0;
          $saw_non_decreasing = 0;
        }

        if ($increasing ne $saw_increasing) {
          MyTestHelpers::diag ("$mod $param increasing=$increasing vs saw_increasing=$saw_increasing at $saw_increasing_at");
          $bad++;
        }
        if ($non_decreasing ne $saw_non_decreasing) {
          MyTestHelpers::diag ("$mod $param non_decreasing=$non_decreasing vs saw_non_decreasing=$saw_non_decreasing at $saw_non_decreasing_at");
          $bad++;
        }
      }
    }
    ok ($bad, 0);
  }
}


#------------------------------------------------------------------------------
exit 0;
