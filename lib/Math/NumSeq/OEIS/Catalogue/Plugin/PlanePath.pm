# Copyright 2011, 2012 Kevin Ryde

# Generated by Math-NumSeq tools/make-oeis-catalogue.pl -- DO NOT EDIT

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
$VERSION = 95;
use Math::NumSeq::OEIS::Catalogue::Plugin;
@ISA = ('Math::NumSeq::OEIS::Catalogue::Plugin');

## no critic (CodeLayout::RequireTrailingCommaAtNewline)

# total 143 A-numbers in 4 modules

use constant info_arrayref =>
[
  {
    'anum' => 'A174344',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'SquareSpiral',
      'coordinate_type',
      'X'
    ]
  },
  {
    'anum' => 'A214526',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'SquareSpiral',
      'coordinate_type',
      'SumAbs'
    ]
  },
  {
    'anum' => 'A180714',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'SquareSpiral,n_start=0',
      'coordinate_type',
      'Sum'
    ]
  },
  {
    'anum' => 'A010751',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'DiamondSpiral,n_start=0'
    ]
  },
  {
    'anum' => 'A000523',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'RationalsTree',
      'coordinate_type',
      'Depth'
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
    'anum' => 'A174981',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'RationalsTree,tree_type=L',
      'coordinate_type',
      'X'
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
    'anum' => 'A191379',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'ChanTree'
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
    'anum' => 'A004247',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals,n_start=0',
      'coordinate_type',
      'Product'
    ]
  },
  {
    'anum' => 'A114327',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals,n_start=0',
      'coordinate_type',
      'DiffYX'
    ]
  },
  {
    'anum' => 'A049581',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals,n_start=0',
      'coordinate_type',
      'AbsDiff'
    ]
  },
  {
    'anum' => 'A048147',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals,n_start=0',
      'coordinate_type',
      'RSquared'
    ]
  },
  {
    'anum' => 'A004198',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals,n_start=0',
      'coordinate_type',
      'BitAnd'
    ]
  },
  {
    'anum' => 'A003986',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals,n_start=0',
      'coordinate_type',
      'BitOr'
    ]
  },
  {
    'anum' => 'A003987',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals,n_start=0',
      'coordinate_type',
      'BitXor'
    ]
  },
  {
    'anum' => 'A109004',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals,n_start=0',
      'coordinate_type',
      'GCD'
    ]
  },
  {
    'anum' => 'A004197',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals,n_start=0',
      'coordinate_type',
      'Min'
    ]
  },
  {
    'anum' => 'A003984',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals,n_start=0',
      'coordinate_type',
      'Max'
    ]
  },
  {
    'anum' => 'A101080',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals,n_start=0',
      'coordinate_type',
      'HammingDist'
    ]
  },
  {
    'anum' => 'A003991',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals,x_start=1,y_start=1',
      'coordinate_type',
      'Product'
    ]
  },
  {
    'anum' => 'A003989',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals,x_start=1,y_start=1',
      'coordinate_type',
      'GCD'
    ]
  },
  {
    'anum' => 'A003983',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals,x_start=1,y_start=1',
      'coordinate_type',
      'Min'
    ]
  },
  {
    'anum' => 'A051125',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals,x_start=1,y_start=1',
      'coordinate_type',
      'Max'
    ]
  },
  {
    'anum' => 'A003988',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Diagonals,direction=up,x_start=1,y_start=1',
      'coordinate_type',
      'Int'
    ]
  },
  {
    'anum' => 'A055087',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'DiagonalsOctant,n_start=0',
      'coordinate_type',
      'X'
    ]
  },
  {
    'anum' => 'A055086',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'DiagonalsOctant,n_start=0',
      'coordinate_type',
      'Sum'
    ]
  },
  {
    'anum' => 'A082375',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'DiagonalsOctant,n_start=0',
      'coordinate_type',
      'DiffYX'
    ]
  },
  {
    'anum' => 'A053615',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'Corner,n_start=0',
      'coordinate_type',
      'AbsDiff'
    ]
  },
  {
    'anum' => 'A069011',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'PyramidRows,step=1,n_start=0',
      'coordinate_type',
      'RSquared'
    ]
  },
  {
    'anum' => 'A196199',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'PyramidRows,n_start=0',
      'coordinate_type',
      'X'
    ]
  },
  {
    'anum' => 'A000196',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'PyramidRows,n_start=0',
      'coordinate_type',
      'Y'
    ]
  },
  {
    'anum' => 'A180447',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'PyramidRows,step=3,n_start=0',
      'coordinate_type',
      'Y'
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
    'anum' => 'A019586',
    'class' => 'Math::NumSeq::PlanePathCoord',
    'parameters' => [
      'planepath',
      'WythoffArray',
      'coordinate_type',
      'Y'
    ]
  },
  {
    'anum' => 'A079813',
    'class' => 'Math::NumSeq::PlanePathDelta',
    'parameters' => [
      'planepath',
      'SquareSpiral',
      'delta_type',
      'AbsdY'
    ]
  },
  {
    'anum' => 'A070990',
    'class' => 'Math::NumSeq::PlanePathDelta',
    'parameters' => [
      'planepath',
      'RationalsTree,tree_type=L',
      'delta_type',
      'dY'
    ]
  },
  {
    'anum' => 'A010059',
    'class' => 'Math::NumSeq::PlanePathDelta',
    'parameters' => [
      'planepath',
      'CCurve',
      'delta_type',
      'AbsdX'
    ]
  },
  {
    'anum' => 'A179868',
    'class' => 'Math::NumSeq::PlanePathDelta',
    'parameters' => [
      'planepath',
      'CCurve',
      'delta_type',
      'Dir4'
    ]
  },
  {
    'anum' => 'A033999',
    'class' => 'Math::NumSeq::PlanePathDelta',
    'parameters' => [
      'planepath',
      'Rows,width=2,n_start=0',
      'delta_type',
      'dX'
    ]
  },
  {
    'anum' => 'A010673',
    'class' => 'Math::NumSeq::PlanePathDelta',
    'parameters' => [
      'planepath',
      'Rows,width=2,n_start=0',
      'delta_type',
      'TDir6'
    ]
  },
  {
    'anum' => 'A061347',
    'class' => 'Math::NumSeq::PlanePathDelta',
    'parameters' => [
      'planepath',
      'Rows,width=3',
      'delta_type',
      'dX'
    ]
  },
  {
    'anum' => 'A127949',
    'class' => 'Math::NumSeq::PlanePathDelta',
    'parameters' => [
      'planepath',
      'Diagonals',
      'delta_type',
      'dY'
    ]
  },
  {
    'anum' => 'A023531',
    'class' => 'Math::NumSeq::PlanePathDelta',
    'parameters' => [
      'planepath',
      'PyramidRows,step=1,n_start=0',
      'delta_type',
      'dY'
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
    'anum' => 'A033951',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'SquareSpiral',
      'line_type',
      'Y_neg'
    ]
  },
  {
    'anum' => 'A053755',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'SquareSpiral',
      'line_type',
      'Diagonal_NW'
    ]
  },
  {
    'anum' => 'A016754',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'SquareSpiral',
      'line_type',
      'Diagonal_SE'
    ]
  },
  {
    'anum' => 'A033991',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'SquareSpiral,n_start=0',
      'line_type',
      'Y_axis'
    ]
  },
  {
    'anum' => 'A002939',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'SquareSpiral,n_start=0',
      'line_type',
      'Diagonal'
    ]
  },
  {
    'anum' => 'A002943',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'SquareSpiral,n_start=0',
      'line_type',
      'Diagonal_SW'
    ]
  },
  {
    'anum' => 'A069894',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'SquareSpiral,wider=1',
      'line_type',
      'Diagonal_SW'
    ]
  },
  {
    'anum' => 'A062741',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'TriangleSpiral,n_start=0',
      'line_type',
      'Y_axis'
    ]
  },
  {
    'anum' => 'A117625',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'TriangleSpiralSkewed'
    ]
  },
  {
    'anum' => 'A006137',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'TriangleSpiralSkewed',
      'line_type',
      'X_neg'
    ]
  },
  {
    'anum' => 'A064225',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'TriangleSpiralSkewed',
      'line_type',
      'Y_neg'
    ]
  },
  {
    'anum' => 'A081589',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'TriangleSpiralSkewed',
      'line_type',
      'Diagonal'
    ]
  },
  {
    'anum' => 'A038764',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'TriangleSpiralSkewed',
      'line_type',
      'Diagonal_SW'
    ]
  },
  {
    'anum' => 'A081267',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'TriangleSpiralSkewed',
      'line_type',
      'Diagonal_SE'
    ]
  },
  {
    'anum' => 'A081274',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'TriangleSpiralSkewed',
      'line_type',
      'Diagonal_SW'
    ]
  },
  {
    'anum' => 'A081266',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'TriangleSpiralSkewed,n_start=0',
      'line_type',
      'Diagonal_SW'
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
    'anum' => 'A192136',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'PentSpiralSkewed'
    ]
  },
  {
    'anum' => 'A116668',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'PentSpiralSkewed',
      'line_type',
      'X_neg'
    ]
  },
  {
    'anum' => 'A158187',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'PentSpiralSkewed',
      'line_type',
      'Diagonal_NW'
    ]
  },
  {
    'anum' => 'A005891',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'PentSpiralSkewed',
      'line_type',
      'Diagonal_SE'
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
    'anum' => 'A056107',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'HexSpiralSkewed',
      'line_type',
      'Diagonal_NW'
    ]
  },
  {
    'anum' => 'A056108',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'HexSpiralSkewed',
      'line_type',
      'X_neg'
    ]
  },
  {
    'anum' => 'A056109',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'HexSpiralSkewed',
      'line_type',
      'Y_neg'
    ]
  },
  {
    'anum' => 'A003215',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'HexSpiralSkewed',
      'line_type',
      'Diagonal_SE'
    ]
  },
  {
    'anum' => 'A033570',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'AnvilSpiral'
    ]
  },
  {
    'anum' => 'A033568',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'AnvilSpiral',
      'line_type',
      'Diagonal'
    ]
  },
  {
    'anum' => 'A126587',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'AnvilSpiral',
      'line_type',
      'Y_axis',
      'i_start',
      1
    ]
  },
  {
    'anum' => 'A051132',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'Hypot,n_start=0'
    ]
  },
  {
    'anum' => 'A036702',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'HypotOctant,points=even',
      'line_type',
      'Diagonal'
    ]
  },
  {
    'anum' => 'A007051',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'PythagoreanTree',
      'line_type',
      'Depth_start'
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
    'anum' => 'A001196',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'ZOrderCurve',
      'line_type',
      'Diagonal'
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
    'anum' => 'A051022',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'ZOrderCurve,radix=10'
    ]
  },
  {
    'anum' => 'A163344',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'GrayCode,apply_type=sT,radix=3',
      'line_type',
      'X_axis'
    ]
  },
  {
    'anum' => 'A006046',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'SierpinskiTriangle,align=diagonal,n_start=0',
      'line_type',
      'Y_axis'
    ]
  },
  {
    'anum' => 'A074330',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'SierpinskiTriangle',
      'line_type',
      'Diagonal',
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
    'anum' => 'A016777',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'Rows,width=3',
      'line_type',
      'Y_axis'
    ]
  },
  {
    'anum' => 'A016813',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'Rows,width=4',
      'line_type',
      'Y_axis'
    ]
  },
  {
    'anum' => 'A016861',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'Rows,width=5',
      'line_type',
      'Y_axis'
    ]
  },
  {
    'anum' => 'A016921',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'Rows,width=6',
      'line_type',
      'Y_axis'
    ]
  },
  {
    'anum' => 'A016993',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'Rows,width=7',
      'line_type',
      'Y_axis'
    ]
  },
  {
    'anum' => 'A000124',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'Diagonals',
      'line_type',
      'Y_axis'
    ]
  },
  {
    'anum' => 'A001844',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'Diagonals',
      'line_type',
      'Diagonal'
    ]
  },
  {
    'anum' => 'A059100',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'PyramidRows,step=2,n_start=2',
      'line_type',
      'Diagonal_NW'
    ]
  },
  {
    'anum' => 'A104249',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'PyramidRows,step=3',
      'line_type',
      'Y_axis'
    ]
  },
  {
    'anum' => 'A143689',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'PyramidRows,step=3',
      'line_type',
      'Diagonal_NW'
    ]
  },
  {
    'anum' => 'A084849',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'PyramidRows,step=4',
      'line_type',
      'Y_axis'
    ]
  },
  {
    'anum' => 'A046092',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'PyramidRows,step=4,n_start=0',
      'line_type',
      'Diagonal'
    ]
  },
  {
    'anum' => 'A002522',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'PyramidSides',
      'line_type',
      'X_neg'
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
  },
  {
    'anum' => 'A147562',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'UlamWarburton,n_start=0',
      'line_type',
      'Depth_start'
    ]
  },
  {
    'anum' => 'A084471',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'DigitGroups,radix=2',
      'i_start',
      1
    ]
  },
  {
    'anum' => 'A014480',
    'class' => 'Math::NumSeq::PlanePathN',
    'parameters' => [
      'planepath',
      'PowerArray',
      'line_type',
      'Diagonal'
    ]
  },
  {
    'anum' => 'A035263',
    'class' => 'Math::NumSeq::PlanePathTurn',
    'parameters' => [
      'planepath',
      'KochCurve',
      'turn_type',
      'Left'
    ]
  },
  {
    'anum' => 'A034947',
    'class' => 'Math::NumSeq::PlanePathTurn',
    'parameters' => [
      'planepath',
      'DragonCurve',
      'turn_type',
      'LSR'
    ]
  },
  {
    'anum' => 'A137893',
    'class' => 'Math::NumSeq::PlanePathTurn',
    'parameters' => [
      'planepath',
      'GosperSide',
      'turn_type',
      'Left'
    ]
  },
  {
    'anum' => 'A129184',
    'class' => 'Math::NumSeq::PlanePathTurn',
    'parameters' => [
      'planepath',
      'Diagonals,n_start=0',
      'turn_type',
      'Left'
    ]
  }
]
;
1;
__END__
