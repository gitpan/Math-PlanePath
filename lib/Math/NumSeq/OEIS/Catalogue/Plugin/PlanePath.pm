# Copyright 2011, 2012 Kevin Ryde

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
$VERSION = 70;
use Math::NumSeq::OEIS::Catalogue::Plugin;
@ISA = ('Math::NumSeq::OEIS::Catalogue::Plugin');

## no critic (CodeLayout::RequireTrailingCommaAtNewline)

# total 49 A-numbers in 4 modules

use constant info_arrayref =>
[
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
    'anum' => 'A086592',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'FractionsTree',
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
    'anum' => 'A020652',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'DiagonalRationals',
      'coordinate_type',
      'X'
    ]
  },
  {
    'anum' => 'A020653',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'DiagonalRationals',
      'coordinate_type',
      'Y'
    ]
  },
  {
    'anum' => 'A071974',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'FactorRationals',
      'coordinate_type',
      'X'
    ]
  },
  {
    'anum' => 'A071975',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'FactorRationals',
      'coordinate_type',
      'Y'
    ]
  },
  {
    'anum' => 'A019554',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'FactorRationals',
      'coordinate_type',
      'Product'
    ]
  },
  {
    'anum' => 'A054531',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'GcdRationals',
      'coordinate_type',
      'Y'
    ]
  },
  {
    'anum' => 'A163480',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'PeanoCurve'
    ]
  },
  {
    'anum' => 'A163481',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'PeanoCurve',
      'line_type',
      'Y_axis'
    ]
  },
  {
    'anum' => 'A163343',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'PeanoCurve',
      'line_type',
      'Diagonal'
    ]
  },
  {
    'anum' => 'A163482',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'HilbertCurve'
    ]
  },
  {
    'anum' => 'A163483',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'HilbertCurve',
      'line_type',
      'Y_axis'
    ]
  },
  {
    'anum' => 'A000695',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'ZOrderCurve'
    ]
  },
  {
    'anum' => 'A062880',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'ZOrderCurve',
      'line_type',
      'Y_axis'
    ]
  },
  {
    'anum' => 'A037314',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'ZOrderCurve,radix=3',
      'i_start',
      1
    ]
  },
  {
    'anum' => 'A066321',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'ComplexMinus'
    ]
  },
  {
    'anum' => 'A130883',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'DiamondSpiral'
    ]
  },
  {
    'anum' => 'A058331',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'DiamondSpiral',
      'line_type',
      'Y_axis'
    ]
  },
  {
    'anum' => 'A102631',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'FactorRationals',
      'line_type',
      'Y_axis'
    ]
  },
  {
    'anum' => 'A056105',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'HexSpiralSkewed'
    ]
  },
  {
    'anum' => 'A056106',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'HexSpiralSkewed',
      'line_type',
      'Y_axis'
    ]
  },
  {
    'anum' => 'A192136',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'PentSpiral'
    ]
  },
  {
    'anum' => 'A081254',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'RationalsTree,tree_type=Bird'
    ]
  },
  {
    'anum' => 'A086893',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'RationalsTree,tree_type=Drib'
    ]
  },
  {
    'anum' => 'A054552',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'SquareSpiral'
    ]
  },
  {
    'anum' => 'A061925',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'CellularRule,rule=5',
      'line_type',
      'Y_axis'
    ]
  }
]
;
1;
__END__
