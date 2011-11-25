# Copyright 2011 Kevin Ryde

# Generated by tools/make-oeis-catalogue.pl -- DO NOT EDIT

# This file is part of Math-PlanePath.
#
# Math-PlanePath is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-PlanePath is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-PlanePath.  If not, see <http://www.gnu.org/licenses/>.

package Math::NumSeq::OEIS::Catalogue::Plugin::PlanePath;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 55;
use Math::NumSeq::OEIS::Catalogue::Plugin;
@ISA = ('Math::NumSeq::OEIS::Catalogue::Plugin');

## no critic (CodeLayout::RequireTrailingCommaAtNewline)

# total 43 A-numbers in 1 modules

use constant info_arrayref =>
[
  {
    'anum' => 'A180714',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'SquareSpiral',
      'coordinate_type',
      'Sum'
    ]
  },
  {
    'anum' => 'A059253',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'HilbertCurve',
      'coordinate_type',
      'X'
    ]
  },
  {
    'anum' => 'A059252',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'HilbertCurve',
      'coordinate_type',
      'Y'
    ]
  },
  {
    'anum' => 'A059261',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'HilbertCurve',
      'coordinate_type',
      'Sum'
    ]
  },
  {
    'anum' => 'A059285',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'HilbertCurve',
      'coordinate_type',
      'DiffXY'
    ]
  },
  {
    'anum' => 'A163547',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'HilbertCurve',
      'coordinate_type',
      'RSquared'
    ]
  },
  {
    'anum' => 'A163528',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'PeanoCurve',
      'coordinate_type',
      'X'
    ]
  },
  {
    'anum' => 'A163529',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'PeanoCurve',
      'coordinate_type',
      'Y'
    ]
  },
  {
    'anum' => 'A163530',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'PeanoCurve',
      'coordinate_type',
      'Sum'
    ]
  },
  {
    'anum' => 'A163531',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'PeanoCurve',
      'coordinate_type',
      'RSquared'
    ]
  },
  {
    'anum' => 'A047679',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'RationalsTree',
      'coordinate_type',
      'Y'
    ]
  },
  {
    'anum' => 'A070871',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'RationalsTree,tree_type=CW',
      'coordinate_type',
      'Product'
    ]
  },
  {
    'anum' => 'A020650',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'RationalsTree,tree_type=AYT',
      'coordinate_type',
      'X'
    ]
  },
  {
    'anum' => 'A020651',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'RationalsTree,tree_type=AYT',
      'coordinate_type',
      'Y'
    ]
  },
  {
    'anum' => 'A086592',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'RationalsTree,tree_type=AYT',
      'coordinate_type',
      'Sum'
    ]
  },
  {
    'anum' => 'A162909',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'RationalsTree,tree_type=Bird',
      'coordinate_type',
      'X'
    ]
  },
  {
    'anum' => 'A162910',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'RationalsTree,tree_type=Bird',
      'coordinate_type',
      'Y'
    ]
  },
  {
    'anum' => 'A162911',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'RationalsTree,tree_type=Drib',
      'coordinate_type',
      'X'
    ]
  },
  {
    'anum' => 'A162912',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'RationalsTree,tree_type=Drib',
      'coordinate_type',
      'Y'
    ]
  },
  {
    'anum' => 'A002262',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals',
      'coordinate_type',
      'X'
    ]
  },
  {
    'anum' => 'A025581',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals',
      'coordinate_type',
      'Y'
    ]
  },
  {
    'anum' => 'A003056',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals',
      'coordinate_type',
      'Sum'
    ]
  },
  {
    'anum' => 'A114327',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals',
      'coordinate_type',
      'DiffYX'
    ]
  },
  {
    'anum' => 'A049581',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals',
      'coordinate_type',
      'AbsDiff'
    ]
  },
  {
    'anum' => 'A048147',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals',
      'coordinate_type',
      'RSquared'
    ]
  },
  {
    'anum' => 'A051162',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'PyramidRows,step=1',
      'coordinate_type',
      'Sum'
    ]
  },
  {
    'anum' => 'A069011',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'PyramidRows,step=1',
      'coordinate_type',
      'RSquared'
    ]
  },
  {
    'anum' => 'A196199',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'PyramidRows',
      'coordinate_type',
      'X'
    ]
  },
  {
    'anum' => 'A000196',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'PyramidRows',
      'coordinate_type',
      'Y'
    ]
  },
  {
    'anum' => 'A053186',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'PyramidRows',
      'coordinate_type',
      'Sum'
    ]
  },
  {
    'anum' => 'A180447',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'PyramidRows,step=3',
      'coordinate_type',
      'Y'
    ]
  },
  {
    'anum' => 'A059905',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'ZOrderCurve',
      'coordinate_type',
      'X'
    ]
  },
  {
    'anum' => 'A059906',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'ZOrderCurve',
      'coordinate_type',
      'Y'
    ]
  },
  {
    'anum' => 'A163325',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'ZOrderCurve,radix=3',
      'coordinate_type',
      'X'
    ]
  },
  {
    'anum' => 'A163326',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'ZOrderCurve,radix=3',
      'coordinate_type',
      'Y'
    ]
  },
  {
    'anum' => 'A080463',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'ZOrderCurve,radix=10',
      'coordinate_type',
      'Sum',
      'i_start',
      1
    ]
  },
  {
    'anum' => 'A080464',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'ZOrderCurve,radix=10',
      'coordinate_type',
      'Product',
      'i_start',
      10
    ]
  },
  {
    'anum' => 'A080465',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'ZOrderCurve,radix=10',
      'coordinate_type',
      'AbsDiff',
      'i_start',
      10
    ]
  },
  {
    'anum' => 'A061017',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'DivisibleColumns',
      'coordinate_type',
      'X'
    ]
  },
  {
    'anum' => 'A027750',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'DivisibleColumns',
      'coordinate_type',
      'Y'
    ]
  },
  {
    'anum' => 'A038567',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'CoprimeColumns',
      'coordinate_type',
      'X'
    ]
  },
  {
    'anum' => 'A038566',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'CoprimeColumns',
      'coordinate_type',
      'Y'
    ]
  },
  {
    'anum' => 'A020653',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'CoprimeColumns',
      'coordinate_type',
      'DiffXY',
      'i_start',
      1
    ]
  }
]
;
1;
__END__
