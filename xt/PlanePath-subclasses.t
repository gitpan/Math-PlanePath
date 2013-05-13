#!/usr/bin/perl -w

# Copyright 2010, 2011, 2012, 2013 Kevin Ryde

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
use List::Util;
use Test;
plan tests => 575;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }

# uncomment this to run the ### lines
# use Smart::Comments;

require Math::PlanePath;

my $verbose = 1;

my @modules = (

               # 'PeninsulaBridge',

               # 'ToothpickTree,parts=3',
               # 'ToothpickTree,parts=octant',
               # 'ToothpickTree,parts=octant_up',
               # 'ToothpickTree,parts=wedge',
               # 'ToothpickTree',
               # 'ToothpickTree,parts=1',
               # 'ToothpickTree,parts=2',
               
               # 'ToothpickReplicate',
               # 'ToothpickReplicate,parts=1',
               # 'ToothpickReplicate,parts=2',
               # 'ToothpickReplicate,parts=3',
               
               # 'OneOfEight,parts=octant_up',
               # 'OneOfEight,parts=wedge',
               # 'OneOfEight',
               # 'OneOfEight,parts=4',
               # 'OneOfEight,parts=1',
               # 'OneOfEight,parts=octant',
               # 'OneOfEight,parts=3mid',
               # 'OneOfEight,parts=3side',
               # 
               # 'LCornerTree,parts=diagonal-1',
               # 'LCornerTree,parts=diagonal',
               # 'LCornerTree,parts=wedge',
               # 'LCornerTree,parts=octant_up',
               # 'LCornerTree,parts=octant',
               # 'LCornerTree', # parts=4
               # 'LCornerTree,parts=1',
               # 'LCornerTree,parts=2',
               # 'LCornerTree,parts=3',

               # 'ToothpickUpist',

               # 'LCornerReplicate',

               # module list begin

               'PythagoreanTree,coordinates=SM',
               'PythagoreanTree,coordinates=SC',
               'PythagoreanTree,coordinates=MC',
               'PythagoreanTree,tree_type=FB,coordinates=SM',
               'PythagoreanTree,tree_type=FB,coordinates=SC',
               'PythagoreanTree,tree_type=FB,coordinates=MC',
               'PythagoreanTree',
               'PythagoreanTree,coordinates=AC',
               'PythagoreanTree,coordinates=BC',
               'PythagoreanTree,coordinates=PQ',
               'PythagoreanTree,tree_type=FB',
               'PythagoreanTree,tree_type=FB,coordinates=AC',
               'PythagoreanTree,tree_type=FB,coordinates=BC',
               'PythagoreanTree,tree_type=FB,coordinates=PQ',

               # Math::PlanePath::CellularRule::Line
               'CellularRule,rule=2',  # left line
               'CellularRule,rule=2,n_start=0',
               'CellularRule,rule=2,n_start=37',
               'CellularRule,rule=4',  # centre line
               'CellularRule,rule=4,n_start=0',
               'CellularRule,rule=4,n_start=37',
               'CellularRule,rule=16', # right line
               'CellularRule,rule=16,n_start=0',
               'CellularRule,rule=16,n_start=37',

               'UlamWarburton,parts=1',
               'UlamWarburton,parts=2',
               'UlamWarburton',
               'UlamWarburton,n_start=0',
               'UlamWarburton,n_start=0,parts=2',
               'UlamWarburton,n_start=0,parts=1',
               'UlamWarburton,n_start=37',
               'UlamWarburton,n_start=37,parts=2',
               'UlamWarburton,n_start=37,parts=1',
               'UlamWarburtonQuarter',
               'UlamWarburtonQuarter,n_start=0',
               'UlamWarburtonQuarter,n_start=37',

               'MultipleRings,ring_shape=polygon,step=3',
               'MultipleRings,ring_shape=polygon,step=5',
               'MultipleRings,ring_shape=polygon,step=6',
               'MultipleRings,ring_shape=polygon,step=7',
               'MultipleRings,ring_shape=polygon,step=8',
               'MultipleRings,ring_shape=polygon,step=37',
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

               'DiagonalRationals',
               'DiagonalRationals,n_start=37',
               'DiagonalRationals,direction=up',
               'DiagonalRationals,direction=up,n_start=37',

               'TerdragonRounded',
               'TerdragonRounded,arms=2',
               'TerdragonRounded,arms=3',
               'TerdragonRounded,arms=4',
               'TerdragonRounded,arms=5',
               'TerdragonRounded,arms=6',

               'CellularRule,rule=6',   # left 1,2 line
               'CellularRule,rule=6,n_start=0',
               'CellularRule,rule=6,n_start=37',
               'CellularRule,rule=20',  # right 1,2 line
               'CellularRule,rule=20,n_start=0',
               'CellularRule,rule=20,n_start=37',

               'CellularRule54',
               'CellularRule54,n_start=0',
               'CellularRule54,n_start=37',

               'CellularRule57',
               'CellularRule57,n_start=0',
               'CellularRule57,n_start=37',
               'CellularRule57,mirror=1',
               'CellularRule57,mirror=1,n_start=0',
               'CellularRule57,mirror=1,n_start=37',

               'CellularRule190',
               'CellularRule190,n_start=0',
               'CellularRule190,n_start=37',
               'CellularRule190,mirror=1',
               'CellularRule190,mirror=1,n_start=0',
               'CellularRule190,mirror=1,n_start=37',

               'CellularRule',
               'CellularRule,n_start=0',
               'CellularRule,n_start=37',

               'CellularRule,rule=206', # left solid
               'CellularRule,rule=206,n_start=0',
               'CellularRule,rule=206,n_start=37',

               'CellularRule,rule=18',  # Sierpinski
               'CellularRule,rule=18,n_start=0',
               'CellularRule,rule=18,n_start=37',

               'CellularRule,rule=14',  # left 2 cell line
               'CellularRule,rule=14,n_start=0',
               'CellularRule,rule=14,n_start=37',
               'CellularRule,rule=84',  # right 2 cell line
               'CellularRule,rule=84,n_start=0',
               'CellularRule,rule=84,n_start=37',

               'CellularRule,rule=0',   # blank
               'CellularRule,rule=60',
               'CellularRule,rule=220', # right half solid
               'CellularRule,rule=222', # full solid

               'PeanoCurve',
               'PeanoCurve,radix=2',
               'PeanoCurve,radix=4',
               'PeanoCurve,radix=5',
               'PeanoCurve,radix=17',

               'TriangleSpiralSkewed',
               'TriangleSpiralSkewed,n_start=0',
               'TriangleSpiralSkewed,n_start=37',
               'TriangleSpiralSkewed,skew=right',
               'TriangleSpiralSkewed,skew=right,n_start=0',
               'TriangleSpiralSkewed,skew=right,n_start=37',
               'TriangleSpiralSkewed,skew=up',
               'TriangleSpiralSkewed,skew=up,n_start=0',
               'TriangleSpiralSkewed,skew=up,n_start=37',
               'TriangleSpiralSkewed,skew=down',
               'TriangleSpiralSkewed,skew=down,n_start=0',
               'TriangleSpiralSkewed,skew=down,n_start=37',

               'TriangleSpiral',
               'TriangleSpiral,n_start=0',
               'TriangleSpiral,n_start=37',

               'SierpinskiTriangle',
               'SierpinskiTriangle,n_start=37',
               'SierpinskiTriangle,align=left',
               'SierpinskiTriangle,align=right',
               'SierpinskiTriangle,align=diagonal',

               'WythoffArray',
               'WythoffArray,x_start=1',
               'WythoffArray,y_start=1',
               'WythoffArray,x_start=1,y_start=1',
               'WythoffArray,x_start=5,y_start=7',

               'HexSpiral',
               'HexSpiral,n_start=0',
               'HexSpiral,n_start=37',
               'HexSpiral,wider=10,n_start=37',
               'HexSpiral,wider=1',
               'HexSpiral,wider=2',
               'HexSpiral,wider=3',
               'HexSpiral,wider=4',
               'HexSpiral,wider=5',
               'HexSpiral,wider=37',

               'HexSpiralSkewed',
               'HexSpiralSkewed,n_start=0',
               'HexSpiralSkewed,n_start=37',
               'HexSpiralSkewed,wider=10,n_start=37',
               'HexSpiralSkewed,wider=1',
               'HexSpiralSkewed,wider=2',
               'HexSpiralSkewed,wider=3',
               'HexSpiralSkewed,wider=4',
               'HexSpiralSkewed,wider=5',
               'HexSpiralSkewed,wider=37',

               'VogelFloret',

               'Rows',
               'Rows,width=1',
               'Rows,width=2',
               'Rows,n_start=0',
               'Rows,width=37,n_start=0',
               'Rows,width=37,n_start=123',
               'Columns',
               'Columns,height=1',
               'Columns,height=2',
               'Columns,n_start=0',
               'Columns,height=37,n_start=0',
               'Columns,height=37,n_start=123',

               'ChanTree',
               'ChanTree,n_start=1234',
               'ChanTree,k=2',
               'ChanTree,k=2,n_start=1234',
               'ChanTree,k=4',
               'ChanTree,k=5',
               'ChanTree,k=7',
               'ChanTree,reduced=1',
               'ChanTree,reduced=1,k=2',
               'ChanTree,reduced=1,k=4',
               'ChanTree,reduced=1,k=5',
               'ChanTree,reduced=1,k=7',

               'CoprimeColumns',
               'CoprimeColumns,n_start=37',
               'DivisibleColumns',
               'DivisibleColumns,n_start=37',
               'DivisibleColumns,divisor_type=proper',

               'FilledRings',
               'FilledRings,n_start=0',
               'FilledRings,n_start=37',

               'AnvilSpiral,n_start=0',
               'AnvilSpiral,n_start=37',
               'AnvilSpiral,n_start=37,wider=9',
               'AnvilSpiral,wider=17',
               'AnvilSpiral',
               'AnvilSpiral,wider=1',
               'AnvilSpiral,wider=2',
               'AnvilSpiral,wider=9',
               'AnvilSpiral,wider=17',

               'Flowsnake',
               'Flowsnake,arms=2',
               'Flowsnake,arms=3',
               'FlowsnakeCentres',
               'FlowsnakeCentres,arms=2',
               'FlowsnakeCentres,arms=3',

               'SierpinskiCurve',
               'SierpinskiCurve,diagonal_spacing=5',
               'SierpinskiCurve,straight_spacing=5',
               'SierpinskiCurve,diagonal_spacing=3,straight_spacing=7',
               'SierpinskiCurve,diagonal_spacing=3,straight_spacing=7,arms=7',
               'SierpinskiCurve,arms=2',
               'SierpinskiCurve,arms=3',
               'SierpinskiCurve,arms=4',
               'SierpinskiCurve,arms=5',
               'SierpinskiCurve,arms=6',
               'SierpinskiCurve,arms=7',
               'SierpinskiCurve,arms=8',
               'SierpinskiCurveStair',
               'SierpinskiCurveStair,diagonal_length=2',
               'SierpinskiCurveStair,diagonal_length=3',
               'SierpinskiCurveStair,diagonal_length=4',
               'SierpinskiCurveStair,arms=2',
               'SierpinskiCurveStair,arms=3,diagonal_length=2',
               'SierpinskiCurveStair,arms=4',
               'SierpinskiCurveStair,arms=5',
               'SierpinskiCurveStair,arms=6,diagonal_length=5',
               'SierpinskiCurveStair,arms=7',
               'SierpinskiCurveStair,arms=8',
               'HIndexing',

               'R5DragonCurve',
               'R5DragonCurve,arms=2',
               'R5DragonCurve,arms=3',
               'R5DragonCurve,arms=4',

               'R5DragonMidpoint',
               'R5DragonMidpoint,arms=2',
               'R5DragonMidpoint,arms=3',
               'R5DragonMidpoint,arms=4',

               'TerdragonCurve',
               'TerdragonCurve,arms=2',
               'TerdragonCurve,arms=3',
               'TerdragonCurve,arms=6',

               'TerdragonMidpoint',
               'TerdragonMidpoint,arms=2',
               'TerdragonMidpoint,arms=3',
               'TerdragonMidpoint,arms=6',

               'KochCurve',
               'KochPeaks',
               'KochSnowflakes',
               'KochSquareflakes',
               'KochSquareflakes,inward=>1',

               'ImaginaryHalf',
               'ImaginaryHalf,radix=3',
               'ImaginaryHalf,radix=4',
               'ImaginaryHalf,radix=5',
               'ImaginaryHalf,radix=37',
               'ImaginaryHalf,digit_order=XXY',
               'ImaginaryHalf,digit_order=YXX',
               'ImaginaryHalf,digit_order=XnXY',
               'ImaginaryHalf,digit_order=XnYX',
               'ImaginaryHalf,digit_order=YXnX',
               'ImaginaryHalf,digit_order=XXY,radix=3',

               'Hypot,n_start=37',
               'Hypot,points=even,n_start=37',
               'Hypot',
               'Hypot,points=even',
               'Hypot,points=odd',
               'HypotOctant',
               'HypotOctant,points=even',
               'HypotOctant,points=odd',

               'TriangularHypot',
               'TriangularHypot,n_start=0',
               'TriangularHypot,n_start=37',
               'TriangularHypot,points=odd',
               'TriangularHypot,points=all',
               'TriangularHypot,points=hex',
               'TriangularHypot,points=hex_rotated',
               'TriangularHypot,points=hex_centred',

               'DigitGroups',
               'DigitGroups,radix=3',
               'DigitGroups,radix=4',
               'DigitGroups,radix=5',
               'DigitGroups,radix=37',

               'HilbertCurve',

               'SierpinskiArrowheadCentres',
               'SierpinskiArrowheadCentres,align=right',
               'SierpinskiArrowheadCentres,align=left',
               'SierpinskiArrowheadCentres,align=diagonal',

               'RationalsTree',
               'RationalsTree,tree_type=CW',
               'RationalsTree,tree_type=AYT',
               'RationalsTree,tree_type=Bird',
               'RationalsTree,tree_type=Drib',
               'RationalsTree,tree_type=L',
               'RationalsTree,tree_type=HCS',

               'CubicBase',
               'CubicBase,radix=3',
               'CubicBase,radix=4',
               'CubicBase,radix=37',

               'CfracDigits,radix=1',
               'CfracDigits',
               'CfracDigits,radix=3',
               'CfracDigits,radix=4',
               'CfracDigits,radix=10',
               'CfracDigits,radix=37',

               'DiagonalsAlternating',
               'DiagonalsAlternating,n_start=0',
               'DiagonalsAlternating,n_start=37',
               'DiagonalsAlternating,x_start=5',
               'DiagonalsAlternating,x_start=2,y_start=5',

               'Diagonals',
               'Diagonals,direction=up',
               'Diagonals,n_start=0',
               'Diagonals,direction=up,n_start=0',
               'Diagonals,n_start=37',
               'Diagonals,direction=up,n_start=37',
               'Diagonals,x_start=5',
               'Diagonals,direction=up,x_start=5',
               'Diagonals,x_start=2,y_start=5',
               'Diagonals,direction=up,x_start=2,y_start=5',

               'GcdRationals',
               'GcdRationals,pairs_order=rows_reverse',
               'GcdRationals,pairs_order=diagonals_down',
               'GcdRationals,pairs_order=diagonals_up',

               'ZOrderCurve,radix=5',
               'ZOrderCurve',
               'ZOrderCurve,radix=3',
               'ZOrderCurve,radix=9',
               'ZOrderCurve,radix=37',

               'GosperIslands',

               'AR2W2Curve',
               'AR2W2Curve,start_shape=D2',
               'AR2W2Curve,start_shape=B2',
               'AR2W2Curve,start_shape=B1rev',
               'AR2W2Curve,start_shape=D1rev',
               'AR2W2Curve,start_shape=A2rev',
               'BetaOmega',
               'KochelCurve',
               'CincoCurve',
               'WunderlichMeander',

               'SacksSpiral',
               'TheodorusSpiral',
               'ArchimedeanChords',

               'ComplexRevolving',
               'ComplexPlus',
               'ComplexPlus,realpart=2',
               'ComplexPlus,realpart=3',
               'ComplexPlus,realpart=4',
               'ComplexPlus,realpart=5',
               'ComplexMinus',
               'ComplexMinus,realpart=2',
               'ComplexMinus,realpart=3',
               'ComplexMinus,realpart=4',
               'ComplexMinus,realpart=5',

               'OctagramSpiral',

               'LTiling',
               'LTiling,L_fill=ends',
               'LTiling,L_fill=all',
               'FibonacciWordFractal',

               'CornerReplicate',
               'HeptSpiralSkewed',
               'PyramidSpiral',

               'GosperReplicate',
               'GosperSide',

               'SquareReplicate',

               'QuadricCurve',
               'QuadricIslands',

               'PowerArray',
               'PowerArray,radix=3',
               'PowerArray,radix=4',

               'PixelRings',
               'HilbertSpiral',

               'CCurve',

               'AztecDiamondRings',
               'DiamondArms',
               'SquareArms',
               'HexArms',

               'GrayCode',
               'GrayCode,radix=3',
               'GrayCode,radix=4',
               'GrayCode,radix=37',
               'GrayCode,apply_type=FsT',
               'GrayCode,apply_type=Fs',
               'GrayCode,apply_type=Ts',
               'GrayCode,apply_type=sF',
               'GrayCode,apply_type=sT',
               'GrayCode,radix=4,gray_type=modular',

               'WunderlichSerpentine',
               'WunderlichSerpentine,serpentine_type=100_000_000',
               'WunderlichSerpentine,serpentine_type=000_000_001',
               'WunderlichSerpentine,radix=2',
               'WunderlichSerpentine,radix=4',
               'WunderlichSerpentine,radix=5,serpentine_type=coil',

               'DragonMidpoint',
               'DragonMidpoint,arms=2',
               'DragonMidpoint,arms=3',
               'DragonMidpoint,arms=4',

               'QuintetCurve',
               'QuintetCurve,arms=2',
               'QuintetCurve,arms=3',
               'QuintetCurve,arms=4',
               'QuintetCentres',
               'QuintetCentres,arms=2',
               'QuintetCentres,arms=3',
               'QuintetCentres,arms=4',

               'QuintetReplicate',

               'DekkingCurve',
               'DekkingCentres',

               'DragonCurve',
               'DragonCurve,arms=2',
               'DragonCurve,arms=3',
               'DragonCurve,arms=4',

               'DiamondSpiral',
               'DiamondSpiral,n_start=0',
               'DiamondSpiral,n_start=37',

               'FractionsTree',
               'FactorRationals',

               'AlternatePaper,arms=2',
               'AlternatePaper',
               'AlternatePaper,arms=3',
               'AlternatePaper,arms=4',
               'AlternatePaper,arms=5',
               'AlternatePaper,arms=6',
               'AlternatePaper,arms=7',
               'AlternatePaper,arms=8',

               'PentSpiral',
               'PentSpiralSkewed',
               'KnightSpiral',

               'SierpinskiArrowhead',
               'SierpinskiArrowhead,align=right',
               'SierpinskiArrowhead,align=left',
               'SierpinskiArrowhead,align=diagonal',

               'DragonRounded',
               'DragonRounded,arms=2',
               'DragonRounded,arms=3',
               'DragonRounded,arms=4',

               'MPeaks',

               'PyramidRows,align=right',
               'PyramidRows,align=right,step=0',
               'PyramidRows,align=right,step=1',
               'PyramidRows,align=right,step=3',
               'PyramidRows,align=right,step=4',
               'PyramidRows,align=right,step=5',
               'PyramidRows,align=right,step=37',
               'PyramidRows,align=left',
               'PyramidRows,align=left,step=0',
               'PyramidRows,align=left,step=1',
               'PyramidRows,align=left,step=3',
               'PyramidRows,align=left,step=4',
               'PyramidRows,align=left,step=5',
               'PyramidRows,align=left,step=37',
               'PyramidRows',
               'PyramidRows,step=0',
               'PyramidRows,step=1',
               'PyramidRows,step=3',
               'PyramidRows,step=4',
               'PyramidRows,step=5',
               'PyramidRows,step=37',
               'PyramidRows,step=0,n_start=37',
               'PyramidRows,step=1,n_start=37',
               'PyramidRows,step=2,n_start=37',
               'PyramidRows,align=right,step=5,n_start=37',
               'PyramidRows,align=left,step=3,n_start=37',

               'DiagonalsOctant',
               'DiagonalsOctant,direction=up',
               'DiagonalsOctant,n_start=0',
               'DiagonalsOctant,direction=up,n_start=0',
               'DiagonalsOctant,n_start=37',
               'DiagonalsOctant,direction=up,n_start=37',

               'Corner',
               'Corner,wider=1',
               'Corner,wider=2',
               'Corner,wider=37',
               'Corner,n_start=0',
               'Corner,wider=1,n_start=0',
               'Corner,wider=2,n_start=0',
               'Corner,wider=37,n_start=0',
               'Corner,n_start=37',
               'Corner,wider=1,n_start=37',
               'Corner,wider=2,n_start=37',
               'Corner,wider=13,n_start=37',

               'PyramidSides',
               'PyramidSides,n_start=0',
               'PyramidSides,n_start=37',

               'File',

               'SquareSpiral,n_start=0',
               'SquareSpiral,n_start=37',
               'SquareSpiral,wider=5,n_start=0',
               'SquareSpiral,wider=5,n_start=37',
               'SquareSpiral,wider=6,n_start=0',
               'SquareSpiral,wider=6,n_start=37',
               'SquareSpiral',
               'SquareSpiral,wider=1',
               'SquareSpiral,wider=2',
               'SquareSpiral,wider=3',
               'SquareSpiral,wider=4',
               'SquareSpiral,wider=5',
               'SquareSpiral,wider=6',
               'SquareSpiral,wider=37',

               'ImaginaryBase',
               'ImaginaryBase,radix=3',
               'ImaginaryBase,radix=4',
               'ImaginaryBase,radix=5',
               'ImaginaryBase,radix=37',

               'GreekKeySpiral',
               'GreekKeySpiral,turns=0',
               'GreekKeySpiral,turns=1',
               'GreekKeySpiral,turns=3',
               'GreekKeySpiral,turns=4',
               'GreekKeySpiral,turns=5',
               'GreekKeySpiral,turns=6',
               'GreekKeySpiral,turns=7',
               'GreekKeySpiral,turns=8',
               'GreekKeySpiral,turns=37',

               'AlternatePaperMidpoint',
               'AlternatePaperMidpoint,arms=2',
               'AlternatePaperMidpoint,arms=3',
               'AlternatePaperMidpoint,arms=4',
               'AlternatePaperMidpoint,arms=5',
               'AlternatePaperMidpoint,arms=6',
               'AlternatePaperMidpoint,arms=7',
               'AlternatePaperMidpoint,arms=8',

               'StaircaseAlternating,end_type=square',
               'StaircaseAlternating',
               'Staircase',

               'CretanLabyrinth',

               # module list end

               # cellular 0 to 255
               (map {("CellularRule,rule=$_",
                      "CellularRule,rule=$_,n_start=0",
                      "CellularRule,rule=$_,n_start=37")} 0..255),
              );
my @classes = map {(module_parse($_))[0]} @modules;
{ my %seen; @classes = grep {!$seen{$_}++} @classes } # uniq

sub module_parse {
  my ($mod) = @_;
  my ($class, @parameters) = split /,/, $mod;
  return ("Math::PlanePath::$class",
          map {/(.*?)=(.*)/ or die; ($1 => $2)} @parameters);
}
sub module_to_pathobj {
  my ($mod) = @_;
  my ($class, @parameters) = module_parse($mod);
  ### $mod
  ### @parameters
  eval "require $class" or die;
  return $class->new (@parameters);
}

{
  eval {
    require Module::Util;
    my %classes = map {$_=>1} @classes;
    foreach my $module (Module::Util::find_in_namespace('Math::PlanePath')) {
      next if $classes{$module};  # listed, good
      next if $module =~ /^Math::PlanePath::[^:]+::/; # skip Base etc submods
      MyTestHelpers::diag ("other module ",$module);
    }
  };
}


#------------------------------------------------------------------------------
# VERSION

my $want_version = 103;

ok ($Math::PlanePath::VERSION, $want_version, 'VERSION variable');
ok (Math::PlanePath->VERSION,  $want_version, 'VERSION class method');

ok (eval { Math::PlanePath->VERSION($want_version); 1 },
    1,
    "VERSION class check $want_version");
my $check_version = $want_version + 1000;
ok (! eval { Math::PlanePath->VERSION($check_version); 1 },
    1,
    "VERSION class check $check_version");

#------------------------------------------------------------------------------
# new and VERSION

foreach my $class (@classes) {
  eval "require $class" or die;

  ok (eval { $class->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version in $class");
  ok (! eval { $class->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version in $class");

  my $path = $class->new;
  ok ($path->VERSION, $want_version,
      "VERSION object method in $class");

  ok (eval { $path->VERSION($want_version); 1 },
      1,
      "VERSION object check $want_version in $class");
  ok (! eval { $path->VERSION($check_version); 1 },
      1,
      "VERSION object check $check_version in $class");
}

#------------------------------------------------------------------------------
# x_negative, y_negative

foreach my $mod (@modules) {
  my $path = module_to_pathobj($mod);
  $path->x_negative;
  $path->y_negative;
  $path->n_start;
  # ok (1,1, 'x_negative(),y_negative(),n_start() methods run');
}

#------------------------------------------------------------------------------
# n_to_xy, xy_to_n

my %xy_maximum_duplication =
  ('Math::PlanePath::DragonCurve' => 2,
   'Math::PlanePath::R5DragonCurve' => 2,
   'Math::PlanePath::CCurve' => 9999,
   'Math::PlanePath::AlternatePaper' => 2,
   'Math::PlanePath::TerdragonCurve' => 3,
   'Math::PlanePath::KochSnowflakes' => 2,
   'Math::PlanePath::QuadricIslands' => 2,
  );
my %xy_maximum_duplication_at_origin =
  ('Math::PlanePath::DragonCurve' => 4,
   'Math::PlanePath::TerdragonCurve' => 6,
   'Math::PlanePath::R5DragonCurve' => 4,
  );

# modules for which rect_to_n_range() is exact
my %rect_exact = (
                  # rect_to_n_range exact begin
                  'Math::PlanePath::ImaginaryBase' => 1,
                  'Math::PlanePath::CincoCurve' => 1,
                  'Math::PlanePath::DiagonalsAlternating' => 1,
                  'Math::PlanePath::CornerReplicate' => 1,
                  'Math::PlanePath::Rows' => 1,
                  'Math::PlanePath::Columns' => 1,
                  'Math::PlanePath::Diagonals' => 1,
                  'Math::PlanePath::DiagonalsOctant' => 1,
                  'Math::PlanePath::Staircase' => 1,
                  'Math::PlanePath::StaircaseAlternating' => 1,
                  'Math::PlanePath::PyramidRows' => 1,
                  'Math::PlanePath::PyramidSides' => 1,
                  'Math::PlanePath::CellularRule190' => 1,
                  'Math::PlanePath::Corner' => 1,
                  'Math::PlanePath::HilbertCurve' => 1,
                  'Math::PlanePath::HilbertSpiral' => 1,
                  'Math::PlanePath::PeanoCurve' => 1,
                  'Math::PlanePath::ZOrderCurve' => 1,
                  'Math::PlanePath::Flowsnake' => 1,
                  'Math::PlanePath::FlowsnakeCentres' => 1,
                  'Math::PlanePath::QuintetCurve' => 1,
                  'Math::PlanePath::QuintetCentres' => 1,
                  'Math::PlanePath::DiamondSpiral' => 1,
                  'Math::PlanePath::AztecDiamondRings' => 1,
                  'Math::PlanePath::BetaOmega' => 1,
                  'Math::PlanePath::AR2W2Curve' => 1,
                  'Math::PlanePath::KochelCurve' => 1,
                  'Math::PlanePath::WunderlichMeander' => 1,
                  'Math::PlanePath::File' => 1,
                  'Math::PlanePath::KochCurve' => 1,
                  # rect_to_n_range exact end
                 );
my %rect_exact_hi = (%rect_exact,
                     # high is exact but low is not
                     'Math::PlanePath::SquareSpiral' => 1,
                     'Math::PlanePath::SquareArms' => 1,
                     'Math::PlanePath::TriangleSpiralSkewed' => 1,
                     'Math::PlanePath::MPeaks' => 1,
                    );
my %rect_before_n_start = ('Math::PlanePath::Rows' => 1,
                           'Math::PlanePath::Columns' => 1,
                          );

my %non_linear_frac = (
                       'Math::PlanePath::SacksSpiral' => 1,
                       'Math::PlanePath::VogelFloret' => 1,
                      );

# possible X,Y deltas
my $dxdy_square = {
                   # "square" steps
                   '1,0'  => 1,  # N
                   '-1,0' => 1,  # S
                   '0,1'  => 1,  # E
                   '0,-1' => 1,  # W
                  };
my $dxdy_diagonal = {
                     # "diagonal" steps
                     '1,1'   => 1, # NE
                     '1,-1'  => 1, # NW
                     '-1,1'  => 1, # SE
                     '-1,-1' => 1, # SW
                    };
my $dxdy_one = {
                # by one diagonal or square
                %$dxdy_square,
                %$dxdy_diagonal,
               };
my $dxdy_hex = {
                # hexagon steps X=+/-2, or diagonally
                '2,0'   => 1,  # Ex2
                '-2,0'  => 1,  # Wx2
                %$dxdy_diagonal,
               };
my %class_dxdy_allowed
  = (
     'Math::PlanePath::SquareSpiral'   => $dxdy_square,
     'Math::PlanePath::GreekKeySpiral' => $dxdy_square,

     'Math::PlanePath::PyramidSpiral' => { '-1,1' => 1,  # NE
                                           '-1,-1' => 1, # SW
                                           '1,0' => 1,   # E
                                         },
     'Math::PlanePath::TriangleSpiral' => { '-1,1' => 1,  # NE
                                            '-1,-1' => 1, # SW
                                            '2,0' => 1,   # Ex2
                                          },
     'Math::PlanePath::TriangleSpiralSkewed' => { '-1,1' => 1, # NE
                                                  '0,-1' => 1, # S
                                                  '1,0'  => 1, # E
                                                },
     'Math::PlanePath::TriangleSpiralSkewed,skew=right' => { '0,1' => 1, # N
                                                             '-1,-1' => 1, # SW
                                                             '1,0'  => 1, # E
                                                           },
     'Math::PlanePath::TriangleSpiralSkewed,skew=up' => { '1,1' => 1, # NE
                                                          '-1,0' => 1, # W
                                                          '0,-1' => 1, # S
                                                        },
     'Math::PlanePath::TriangleSpiralSkewed,skew=down' => { '1,-1' => 1, # SE
                                                            '0,1'   => 1, # N
                                                            '-1,0'  => 1, # W
                                                          },

     'Math::PlanePath::DiamondSpiral' => { '1,0' => 1,   # E at bottom
                                           %$dxdy_diagonal,
                                         },
     'Math::PlanePath::PentSpiralSkewed' => {
                                             '-1,1'  => 1, # NW
                                             '-1,-1' => 1, # SW
                                             '1,-1'  => 1, # SE
                                             '1,0'   => 1, # E
                                             '0,1'   => 1, # N
                                            },

     'Math::PlanePath::HexSpiral'         => $dxdy_hex,
     'Math::PlanePath::Flowsnake'         => $dxdy_hex,
     'Math::PlanePath::FlowsnakeCentres'  => $dxdy_hex,
     'Math::PlanePath::GosperSide'        => $dxdy_hex,
     'Math::PlanePath::TerdragonCurve'    => $dxdy_hex,
     'Math::PlanePath::TerdragonMidpoint' => $dxdy_hex,

     'Math::PlanePath::KochCurve'        => $dxdy_hex,
     # except for jumps at ends/rings
     # 'Math::PlanePath::KochPeaks'      => $dxdy_hex,
     # 'Math::PlanePath::KochSnowflakes' => $dxdy_hex,
     # 'Math::PlanePath::GosperIslands'  => $dxdy_hex,

     'Math::PlanePath::QuintetCurve'   => $dxdy_square,
     'Math::PlanePath::QuintetCentres' => $dxdy_one,
     # Math::PlanePath::QuintetReplicate -- mucho distance

     # 'Math::PlanePath::SierpinskiCurve' => $dxdy_one, # only spacing==1
     'Math::PlanePath::HIndexing'       => $dxdy_square,

     'Math::PlanePath::HexSpiralSkewed'    => {
                                               '-1,1' => 1, # NW
                                               '1,-1' => 1, # SE
                                               %$dxdy_square,
                                              },
     'Math::PlanePath::HeptSpiralSkewed' => {
                                             '-1,1' => 1,  # NW
                                             %$dxdy_square,
                                            },
     'Math::PlanePath::OctagramSpiral' => $dxdy_one,

     'Math::PlanePath::KnightSpiral' => { '1,2'   => 1,
                                          '-1,2'  => 1,
                                          '1,-2'  => 1,
                                          '-1,-2' => 1,
                                          '2,1'   => 1,
                                          '-2,1'  => 1,
                                          '2,-1'  => 1,
                                          '-2,-1' => 1,
                                        },
     'Math::PlanePath::PixelRings' => {
                                       %$dxdy_one,
                                       '2,1' => 1, # from N=5 to N=6
                                      },

     'Math::PlanePath::HilbertCurve'   => $dxdy_square,
     'Math::PlanePath::HilbertSpiral'  => $dxdy_square,
     'Math::PlanePath::PeanoCurve'     => $dxdy_square,
     'Math::PlanePath::WunderlichSerpentine' => $dxdy_square,
     'Math::PlanePath::BetaOmega'      => $dxdy_square,
     'Math::PlanePath::AR2W2Curve'     => $dxdy_one,
     'Math::PlanePath::DragonCurve'    => $dxdy_square,
     'Math::PlanePath::DragonMidpoint' => $dxdy_square,
     'Math::PlanePath::DragonRounded'  => $dxdy_one,
     'Math::PlanePath::R5DragonCurve'    => $dxdy_square,
     'Math::PlanePath::R5DragonMidpoint' => $dxdy_square,
     'Math::PlanePath::CCurve'         => $dxdy_square,
     'Math::PlanePath::HilbertMidpoint' => { %$dxdy_diagonal,
                                             '2,0'   => 1,
                                             '0,2'   => 1,
                                             '-2,0'   => 1,
                                             '0,-2'   => 1,
                                           },
    );

#------------------------------------------------------------------------------
my ($pos_infinity, $neg_infinity, $nan);
my ($is_infinity, $is_nan);
if (! eval { require Data::Float; 1 }) {
  MyTestHelpers::diag ("Data::Float not available");
} elsif (! Data::Float::have_infinite()) {
  MyTestHelpers::diag ("Data::Float have_infinite() is false");
} else {
  $is_infinity = sub {
    my ($x) = @_;
    return defined($x) && Data::Float::float_is_infinite($x);
  };
  $is_nan = sub {
    my ($x) = @_;
    return defined($x) && Data::Float::float_is_nan($x);
  };
  $pos_infinity = Data::Float::pos_infinity();
  $neg_infinity = Data::Float::neg_infinity();
  $nan = Data::Float::nan();
}
sub pos_infinity_maybe {
  return (defined $pos_infinity ? $pos_infinity : ());
}
sub neg_infinity_maybe {
  return (defined $neg_infinity ? $neg_infinity : ());
}

sub dbl_max {
  require POSIX;
  return POSIX::DBL_MAX();
}
sub dbl_max_neg {
  require POSIX;
  return - POSIX::DBL_MAX();
}
sub dbl_max_for_class_xy {
  my ($path) = @_;
  ### dbl_max_for_class_xy(): "$path"
  if ($path->isa('Math::PlanePath::CoprimeColumns')
      || $path->isa('Math::PlanePath::DiagonalRationals')
      || $path->isa('Math::PlanePath::DivisibleColumns')
      || $path->isa('Math::PlanePath::CellularRule')
      || $path->isa('Math::PlanePath::DragonCurve')
      || $path->isa('Math::PlanePath::PixelRings')
     ) {
    ### don't try DBL_MAX on this path xy_to_n() ...
    return ();
  }
  return dbl_max();
}
sub dbl_max_neg_for_class_xy {
  my ($path) = @_;
  if (dbl_max_for_class_xy($path)) {
    return dbl_max_neg();
  } else {
    return ();
  }
}
sub dbl_max_for_class_rect {
  my ($path) = @_;
  # no DBL_MAX on these
  if ($path->isa('Math::PlanePath::CoprimeColumns')
      || $path->isa('Math::PlanePath::DiagonalRationals')
      || $path->isa('Math::PlanePath::DivisibleColumns')
      || $path->isa('Math::PlanePath::CellularRule')
      || $path->isa('Math::PlanePath::PixelRings')
     ) {
    ### don't try DBL_MAX on this path rect_to_n_range() ...
    return ();
  }
  return dbl_max();
}
sub dbl_max_neg_for_class_rect {
  my ($path) = @_;
  if (dbl_max_for_class_rect($path)) {
    return dbl_max_neg();
  } else {
    return ();
  }
}

sub is_pos_infinity {
  my ($n) = @_;
  return defined $n && defined $pos_infinity && $n == $pos_infinity;
}
sub is_neg_infinity {
  my ($n) = @_;
  return defined $n && defined $neg_infinity && $n == $neg_infinity;
}

sub pythagorean_diag {
  my ($path,$x,$y) = @_;
  $path->isa('Math::PlanePath::PythagoreanTree')
    or return;

  my $z = Math::Libm::hypot ($x, $y);
  my $z_not_int = (int($z) != $z);
  my $z_even = ! ($z & 1);

  MyTestHelpers::diag ("x=$x y=$y, hypot z=$z z_not_int='$z_not_int' z_even='$z_even'");

  my $psq = ($z+$x)/2;
  my $p = sqrt(($z+$x)/2);
  my $p_not_int = ($p != int($p));
  MyTestHelpers::diag ("psq=$psq p=$p p_not_int='$p_not_int'");

  my $qsq = ($z-$x)/2;
  my $q = sqrt(($z-$x)/2);
  my $q_not_int = ($q != int($q));
  MyTestHelpers::diag ("qsq=$qsq q=$q q_not_int='$q_not_int'");
}

{
  my $default_limit = ($ENV{'MATH_PLANEPATH_TEST_LIMIT'} || 30);
  my $rect_limit = $ENV{'MATH_PLANEPATH_TEST_RECT_LIMIT'} || 4;
  MyTestHelpers::diag ("test limit $default_limit, rect limit $rect_limit");
  my $good = 1;

  foreach my $mod (@modules) {
    if ($verbose) {
      MyTestHelpers::diag ($mod);
    }

    my ($class, %parameters) = module_parse($mod);
    ### $class
    eval "require $class" or die;

    my $xy_maximum_duplication = $xy_maximum_duplication{$class} || 0;

    my $dxdy_allowed
      = $class_dxdy_allowed{$class.",skew=".($parameters{'skew'}||'')}
        || $class_dxdy_allowed{$class};
    if ($mod =~ /^PeanoCurve|^WunderlichSerpentine/
        && $parameters{'radix'}
        && ($parameters{'radix'} % 2) == 0) {
      undef $dxdy_allowed;  # even radix doesn't join up
    }
    if ($parameters{'arms'} && $parameters{'arms'} > 1) {
      # ENHANCE-ME: watch for dxdy within each arm
      undef $dxdy_allowed;
    }

    #
    # MyTestHelpers::diag ($mod);
    #

    my $limit = $default_limit;
    if (defined (my $step = $parameters{'step'})) {
      if ($limit < 6*$step) {
        $limit = 6*$step; # so goes into x/y negative
      }
    }
    if ($mod =~ /^ArchimedeanChords/) {
      if ($limit > 1100) {
        $limit = 1100;  # bit slow otherwise
      }
    }
    if ($mod =~ /^CoprimeColumns|^DiagonalRationals/) {
      if ($limit > 1100) {
        $limit = 1100;  # bit slow otherwise
      }
    }

    my $report = sub {
      my $name = $mod;
      MyTestHelpers::diag ($name, ' oops ', @_);
      $good = 0;
      # exit 1;
    };

    my $path = $class->new (width  => 20,
                            height => 20,
                            %parameters);
    my $got_arms = $path->arms_count;

    if ($parameters{'arms'} && $got_arms != $parameters{'arms'}) {
      &$report("arms_count()==$got_arms expect $parameters{'arms'}");
    }
    unless ($got_arms >= 1) {
      &$report("arms_count()==$got_arms should be >=1");
    }

    my $arms_count = $path->arms_count;
    my $n_start = $path->n_start;
    my $n_frac_discontinuity = $path->n_frac_discontinuity;
    {
      my ($x,$y) = $path->n_to_xy($n_start);
      if (! defined $x) {
        unless ($path->isa('Math::PlanePath::File')) {
          &$report("n_start()==$n_start doesn't have an n_to_xy()");
        }
      } else {
        my ($n_lo, $n_hi) = $path->rect_to_n_range ($x,$y, $x,$y);
        if ($n_lo > $n_start || $n_hi < $n_start) {
          &$report("n_start()==$n_start outside rect_to_n_range() $n_lo..$n_hi");
        }
      }
    }

    if (# VogelFloret has a secret undocumented return for N=0
        ! $path->isa('Math::PlanePath::VogelFloret')
        # Rows/Columns secret undocumented extend into negatives ...
        && ! $path->isa('Math::PlanePath::Rows')
        && ! $path->isa('Math::PlanePath::Columns')) {
      my $n = $n_start - 1;
      {
        my @xy = $path->n_to_xy($n);
        if (scalar @xy) {
          &$report("n_to_xy() at n_start()-1 has X,Y but should not");
        }
      }
      {
        my @rsquared = $path->n_to_rsquared($n);
        if (scalar(@rsquared) != 1) {
          &$report("n_to_rsquared() at n_start()-1 return not one value");
        } elsif (defined $rsquared[0]) {
          &$report("n_to_rsquared() at n_start()-1 has defined value but should not");
        }
      }
    }
    foreach my $offset (1, 2, 123) {
      ### n_to_rsquared(n_start - offset): $offset
      my $n = $n_start - $offset;
      my @rsquared = $path->n_to_rsquared($n);
      if ($path->isa('Math::PlanePath::File')) {
        @rsquared = (undef);  # all undefs for File
      }
      my $num_values = scalar(@rsquared);
      $num_values == 1
        or &$report("n_to_rsquared(n_start - $offset) got $num_values values, want 1");
      if ($path->isa('Math::PlanePath::Rows')
          || $path->isa('Math::PlanePath::Columns')) {
        ### Rows,Columns has secret values for negative N, pretend not ...
        @rsquared = (undef);
      }
      if ($offset == 1 && $path->isa('Math::PlanePath::VogelFloret')) {
        ### VogelFloret has a secret undocumented return for N=0 ...
        @rsquared = (undef);
      }
      my ($rsquared) = @rsquared;
      if (defined $rsquared) {
        &$report("n_to_rsquared($n) n_start-$offset is $rsquared expected undef");
      }
    }

    {
      my $saw_warning;
      local $SIG{'__WARN__'} = sub { $saw_warning = 1; };
      foreach my $method ('n_to_xy','n_to_dxdy',
                          'n_to_rsquared',
                          ($path->tree_n_num_children($n_start)
                           ? ('tree_n_to_depth',
                              'tree_depth_to_n',
                              'tree_depth_to_n_end',
                              'tree_n_parent',
                              'tree_n_children',
                              'tree_n_num_children',
                             )
                           : ())){
        $saw_warning = 0;
        $path->$method(undef);
        $saw_warning or &$report("$method(undef) doesn't give a warning");
      }
      {
        $saw_warning = 0;
        $path->xy_to_n(0,undef);
        $saw_warning or &$report("xy_to_n(0,undef) doesn't give a warning");
      }
      {
        $saw_warning = 0;
        $path->xy_to_n(undef,0);
        $saw_warning or &$report("xy_to_n(undef,0) doesn't give a warning");
      }

      # No warning if xy_is_visited() is a constant.
      # {
      #   $saw_warning = 0;
      #   $path->xy_is_visited(0,undef);
      #   $saw_warning or &$report("xy_is_visited(0,undef) doesn't give a warning");
      # }
      # {
      #   $saw_warning = 0;
      #   $path->xy_is_visited(undef,0);
      #   $saw_warning or &$report("xy_is_visited(undef,0) doesn't give a warning");
      # }
    }

    # undef ok if nothing sensible
    # +/-inf ok
    # nan not intended, but might be ok
    # finite could be a fixed x==0
    if (defined $pos_infinity) {
      {
        ### n_to_xy($pos_infinity) ...
        my ($x, $y) = $path->n_to_xy($pos_infinity);
        if ($path->isa('Math::PlanePath::File')) {
          # all undefs for File
          if (! defined $x) { $x = $pos_infinity }
          if (! defined $y) { $y = $pos_infinity }
        } elsif ($path->isa('Math::PlanePath::PyramidRows')
                 && ! $parameters{'step'}) {
          # x==0 normal from step==0, fake it up to pass test
          if (defined $x && $x == 0) { $x = $pos_infinity }
        }
        (is_pos_infinity($x) || is_neg_infinity($x) || &$is_nan($x))
          or &$report("n_to_xy($pos_infinity) x is $x");
        (is_pos_infinity($y) || is_neg_infinity($y) || &$is_nan($y))
          or &$report("n_to_xy($pos_infinity) y is $y");
      }
      {
        ### n_to_dxdy($pos_infinity) ...
        my @dxdy = $path->n_to_xy($pos_infinity);
        if ($path->isa('Math::PlanePath::File')) {
          # all undefs for File
          @dxdy = ($pos_infinity, $pos_infinity);
        }
        my $num_values = scalar(@dxdy);
        $num_values == 2
          or &$report("n_to_dxdy(pos_infinity) got $num_values values, want 2");
        my ($dx,$dy) = @dxdy;
        (is_pos_infinity($dx) || is_neg_infinity($dx) || &$is_nan($dx))
          or &$report("n_to_dxdy($pos_infinity) dx is $dx");
        (is_pos_infinity($dy) || is_neg_infinity($dy) || &$is_nan($dy))
          or &$report("n_to_dxdy($pos_infinity) dy is $dy");
      }
      {
        ### n_to_rsquared($pos_infinity) ...
        my @rsquared = $path->n_to_rsquared($pos_infinity);
        if ($path->isa('Math::PlanePath::File')) {
          # all undefs for File
          @rsquared = ($pos_infinity);
        }
        my $num_values = scalar(@rsquared);
        $num_values == 1
          or &$report("n_to_rsquared(pos_infinity) got $num_values values, want 1");
        my ($rsquared) = @rsquared;
        # allow NaN too, since sqrt(+inf) in various classes gives nan
        (is_pos_infinity($rsquared) || &$is_nan($rsquared))
          or &$report("n_to_rsquared($pos_infinity) ",$rsquared," expected +infinity");
      }
      {
        ### tree_n_children($pos_infinity) ...
        my @children = $path->tree_n_children($pos_infinity);
      }
      {
        ### tree_n_num_children($pos_infinity) ...
        my $num_children = $path->tree_n_num_children($pos_infinity);
      }
      {
        ### tree_n_to_height($pos_infinity) ...
        my $height = $path->tree_n_to_height($pos_infinity);
        if ($path->tree_n_num_children($n_start)) {
          unless (! defined $height || is_pos_infinity($height)) {
            &$report("tree_n_to_height($pos_infinity) ",$height," expected +inf");
          }
        } else {
          unless (equal(0,$height)) {
            &$report("tree_n_to_height($pos_infinity) ",$height," expected 0");
          }
        }
      }
    }

    if (defined $neg_infinity) {
      {
        ### n_to_xy($neg_infinity) ...
        my @xy = $path->n_to_xy($neg_infinity);
        if ($path->isa('Math::PlanePath::Rows')) {
          # secret negative n for Rows
          my ($x, $y) = @xy;
          ($x==$pos_infinity || $x==$neg_infinity || &$is_nan($x))
            or &$report("n_to_xy($neg_infinity) x is $x");
          ($y==$neg_infinity)
            or &$report("n_to_xy($neg_infinity) y is $y");
        } elsif ($path->isa('Math::PlanePath::Columns')) {
          # secret negative n for Columns
          my ($x, $y) = @xy;
          ($x==$neg_infinity)
            or &$report("n_to_xy($neg_infinity) x is $x");
          ($y==$pos_infinity || $y==$neg_infinity || &$is_nan($y))
            or &$report("n_to_xy($neg_infinity) y is $y");
        } else {
          scalar(@xy) == 0
            or &$report("n_to_xy($neg_infinity) xy is ",join(',',@xy));
        }
      }
      {
        ### n_to_dxdy($neg_infinity) ...
        my @dxdy = $path->n_to_xy($neg_infinity);
        my $num_values = scalar(@dxdy);
        if (($path->isa('Math::PlanePath::Rows')
             || $path->isa('Math::PlanePath::Columns'))
            && $num_values == 2) {
          # Rows,Columns has secret values for negative N, pretend not
          $num_values = 0;
        }
        $num_values == 0
          or &$report("n_to_dxdy(neg_infinity) got $num_values values, want 0");
      }
      {
        ### n_to_rsquared(neg_infinity) ...
        my @rsquared = $path->n_to_rsquared($neg_infinity);
        if ($path->isa('Math::PlanePath::File')) {
          @rsquared = (undef);  # all undefs for File
        }
        my $num_values = scalar(@rsquared);
        $num_values == 1
          or &$report("n_to_rsquared($neg_infinity) got $num_values values, want 1");
        if ($path->isa('Math::PlanePath::Rows')
            || $path->isa('Math::PlanePath::Columns')) {
          ### Rows,Columns has secret values for negative N, pretend not ...
          @rsquared = (undef);
        }
        my ($rsquared) = @rsquared;
        if (defined $rsquared) {
          &$report("n_to_rsquared($neg_infinity) $rsquared expected undef");
        }
      }
      {
        ### tree_n_children($neg_infinity) ...
        my @children = $path->tree_n_children($neg_infinity);
        if (@children) {
          &$report("tree_n_children($neg_infinity) ",@children," expected none");
        }
      }
      {
        ### tree_n_num_children($neg_infinity) ...
        my $num_children = $path->tree_n_num_children($neg_infinity);
        if (defined $num_children) {
          &$report("tree_n_children($neg_infinity) ",$num_children," expected undef");
        }
      }
      {
        ### tree_n_to_height($neg_infinity) ...
        my $height = $path->tree_n_to_height($neg_infinity);
        if ($path->tree_n_num_children($n_start)) {
          if (defined $height) {
            &$report("tree_n_to_height($neg_infinity) ",$height," expected undef");
          }
        }
      }
    }

    # nan input documented loosely as yet ...
    if (defined $nan) {
      {
        my @xy = $path->n_to_xy($nan);
        if ($path->isa('Math::PlanePath::File')) {
          # allow empty from File without filename
          if (! @xy) { @xy = ($nan, $nan); }
        } elsif ($path->isa('Math::PlanePath::PyramidRows')
                 && ! $parameters{'step'}) {
          # x==0 normal from step==0, fake it up to pass test
          if (defined $xy[0] && $xy[0] == 0) { $xy[0] = $nan }
        }
        my ($x, $y) = @xy;
        &$is_nan($x) or &$report("n_to_xy($nan) x not nan, got ", $x);
        &$is_nan($y) or &$report("n_to_xy($nan) y not nan, got ", $y);
      }
      {
        my @dxdy = $path->n_to_xy($nan);
        if ($path->isa('Math::PlanePath::File')
            && @dxdy == 0) {
          # allow empty from File without filename
          @dxdy = ($nan, $nan);
        }
        my $num_values = scalar(@dxdy);
        $num_values == 2
          or &$report("n_to_dxdy(nan) got $num_values values, want 2");
        my ($dx,$dy) = @dxdy;
        &$is_nan($dx) or &$report("n_to_dxdy($nan) dx not nan, got ", $dx);
        &$is_nan($dy) or &$report("n_to_dxdy($nan) dy not nan, got ", $dy);
      }
      {
        ### tree_n_children($nan) ...
        my @children = $path->tree_n_children($nan);
        # ENHANCE-ME: what should nan return?
        # if (@children) {
        #   &$report("tree_n_children($nan) ",@children," expected none");
        # }
      }
      {
        ### tree_n_num_children($nan) ...
        my $num_children = $path->tree_n_num_children($nan);
        # ENHANCE-ME: what should nan return?
        # &$is_nan($num_children)
        #   or &$report("tree_n_children($nan) ",$num_children," expected nan");
      }
      {
        ### tree_n_to_height($nan) ...
        my $height = $path->tree_n_to_height($nan);
        if ($path->tree_n_num_children($n_start)) {
          (! defined $height || &$is_nan($height))
            or &$report("tree_n_to_height($nan) ",$height," expected nan");
        }
      }
    }

    foreach my $x
      (0,
       pos_infinity_maybe(),
       neg_infinity_maybe(),
       dbl_max_for_class_xy($path),
       dbl_max_neg_for_class_xy($path)) {
      foreach my $y (0,
                     pos_infinity_maybe(),
                     neg_infinity_maybe(),,
                     dbl_max_for_class_xy($path),
                     dbl_max_neg_for_class_xy($path)) {
        next if ! defined $y;
        ### xy_to_n: $x, $y
        my @n = $path->xy_to_n($x,$y);
        scalar(@n) == 1
          or &$report("xy_to_n($x,$y) want 1 value, got ",scalar(@n));
        # my $n = $n[0];
        # &$is_infinity($n) or &$report("xy_to_n($x,$y) n not inf, got ",$n);
      }
    }

    foreach my $x1 (0,
                    pos_infinity_maybe(),
                    neg_infinity_maybe(),
                    dbl_max_for_class_rect($path),
                    dbl_max_neg_for_class_rect($path)) {
      foreach my $x2 (0,
                      pos_infinity_maybe(),
                      neg_infinity_maybe(),
                      dbl_max_for_class_rect($path),
                      dbl_max_neg_for_class_rect($path)) {
        foreach my $y1 (0,
                        pos_infinity_maybe(),
                        neg_infinity_maybe(),
                        dbl_max_for_class_rect($path),
                        dbl_max_neg_for_class_rect($path)) {
          foreach my $y2 (0,
                          pos_infinity_maybe(),
                          neg_infinity_maybe(),
                          dbl_max_for_class_rect($path),
                          dbl_max_neg_for_class_rect($path)) {

            my @nn = $path->rect_to_n_range($x1,$y1, $x2,$y2);
            scalar(@nn) == 2
              or &$report("rect_to_n_range($x1,$y1, $x2,$y2) want 2 values, got ",scalar(@nn));
            # &$is_infinity($n) or &$report("xy_to_n($x,$y) n not inf, got ",$n);
          }
        }
      }
    }

    my %saw_n_to_xy;
    my %count_n_to_xy;
    my $got_x_negative = 0;
    my $got_y_negative = 0;
    my ($prev_x, $prev_y);
    my @n_to_x;
    my @n_to_y;
    foreach my $n ($n_start .. $n_start + $limit) {
      my ($x, $y) = $path->n_to_xy ($n)
        or next;
      $n_to_x[$n] = $x;
      $n_to_y[$n] = $y;
      defined $x or &$report("n_to_xy($n) X undef");
      defined $y or &$report("n_to_xy($n) Y undef");

      if ($x < 0) { $got_x_negative = 1; }
      if ($y < 0) { $got_y_negative = 1; }

      my $xystr = (int($x) == $x && int($y) == $y
                   ? sprintf('%d,%d', $x,$y)
                   : sprintf('%.3f,%.3f', $x,$y));
      if ($count_n_to_xy{$xystr}++ > $xy_maximum_duplication) {
        unless ($x == 0 && $y == 0
                && $count_n_to_xy{$xystr} <= $xy_maximum_duplication_at_origin{$class}) {
          &$report ("n_to_xy($n) duplicate$count_n_to_xy{$xystr} xy=$xystr prev n=$saw_n_to_xy{$xystr}");
        }
      }
      $saw_n_to_xy{$xystr} = $n;

      if ($dxdy_allowed) {
        if (defined $prev_x) {
          my $dx = $x - $prev_x;
          my $dy = $y - $prev_y;
          my $dxdy = "$dx,$dy";
          $dxdy_allowed->{$dxdy}
            or &$report ("n=$n dxdy=$dxdy not allowed");
        }
        ($prev_x, $prev_y) = ($x, $y);
      }

      {
        my ($n_lo, $n_hi) = $path->rect_to_n_range
          (0,0,
           $x + ($x >= 0 ? .4 : -.4),
           $y + ($y >= 0 ? .4 : -.4));
        $n_lo <= $n
          or &$report ("rect_to_n_range() lo n=$n xy=$xystr, got $n_lo");
        $n_hi >= $n
          or &$report ("rect_to_n_range() hi n=$n xy=$xystr, got $n_hi");
        $n_lo == int($n_lo)
          or &$report ("rect_to_n_range() lo n=$n xy=$xystr, got $n_lo, integer");
        $n_hi == int($n_hi)
          or &$report ("rect_to_n_range() hi n=$n xy=$xystr, got $n_hi, integer");
        $n_lo >= $n_start
          or &$report ("rect_to_n_range(0,0,$x,$y)+.4 n_lo=$n_lo is before n_start=$n_start");
      }
      {
        my ($n_lo, $n_hi) = $path->rect_to_n_range ($x,$y, $x,$y);
        ($rect_exact{$class} ? $n_lo == $n : $n_lo <= $n)
          or &$report ("rect_to_n_range() lo n=$n xy=$xystr, got $n_lo");
        ($rect_exact_hi{$class} ? $n_hi == $n : $n_hi >= $n)
          or &$report ("rect_to_n_range() hi n=$n xy=$xystr, got $n_hi");
        $n_lo == int($n_lo)
          or &$report ("rect_to_n_range() lo n=$n xy=$xystr, got n_lo=$n_lo, should be an integer");
        $n_hi == int($n_hi)
          or &$report ("rect_to_n_range() hi n=$n xy=$xystr, got n_hi=$n_hi, should be an integer");
        $n_lo >= $n_start
          or &$report ("rect_to_n_range() n_lo=$n_lo is before n_start=$n_start");
      }

      unless ($xy_maximum_duplication > 0) {
        foreach my $x_offset (0) { # bit slow: , -0.2, 0.2) {
          foreach my $y_offset (0, +0.2) { # bit slow: , -0.2) {
            my $rev_n = $path->xy_to_n ($x + $x_offset, $y + $y_offset);
            ### try xy_to_n from: "n=$n  xy=$x,$y xy=$xystr  x_offset=$x_offset y_offset=$y_offset"
            ### $rev_n
            unless (defined $rev_n && $n == $rev_n) {
              &$report ("xy_to_n() rev n=$n xy=$xystr x_offset=$x_offset y_offset=$y_offset got ".(defined $rev_n ? $rev_n : 'undef'));
              pythagorean_diag($path,$x,$y);
            }
          }
        }
      }
    }

    #--------------------------------------------------------------------------
    ### n_to_xy() fractional ...

    unless ($non_linear_frac{$class}
            || defined $n_frac_discontinuity) {
      foreach my $n ($n_start .. $#n_to_x - $arms_count) {
        my $x = $n_to_x[$n];
        my $y = $n_to_y[$n];
        my $next_x = $n_to_x[$n+$arms_count];
        my $next_y = $n_to_y[$n+$arms_count];
        next unless defined $x && defined $next_x;
        my $dx = $next_x - $x;
        my $dy = $next_y - $y;
        foreach my $frac (0.25, 0.75) {
          my $n_frac = $n + $frac;
          my ($got_x,$got_y) = $path->n_to_xy($n_frac);
          my $want_x = $x + $frac*$dx;
          my $want_y = $y + $frac*$dy;
          abs($want_x - $got_x) < 0.00001
            or &$report ("n_to_xy($n_frac) got_x=$got_x want_x=$want_x");
          abs($want_y - $got_y) < 0.00001
            or &$report ("n_to_xy($n_frac) got_y=$got_y want_y=$want_y");
        }
      }
    }

    #--------------------------------------------------------------------------
    ### n_to_dxdy() ...

    if ($path->can('n_to_dxdy') != Math::PlanePath->can('n_to_dxdy')) {
      MyTestHelpers::diag ($mod, ' n_to_dxdy()');
      foreach my $n ($n_start .. $#n_to_x - $arms_count) {
        my $x = $n_to_x[$n];
        my $y = $n_to_y[$n];
        my $next_x = $n_to_x[$n+$arms_count];
        my $next_y = $n_to_y[$n+$arms_count];
        next unless defined $x && defined $next_x;
        my $want_dx = $next_x - $x;
        my $want_dy = $next_y - $y;
        my ($got_dx,$got_dy) = $path->n_to_dxdy($n);
        $want_dx == $got_dx
          or &$report ("n_to_dxdy($n) got_dx=$got_dx want_dx=$want_dx  (next_x=$n_to_x[$n+$arms_count], x=$n_to_x[$n])");
        $want_dy == $got_dy
          or &$report ("n_to_dxdy($n) got_dy=$got_dy want_dy=$want_dy");
      }

      foreach my $n ($n_start .. $n_start + $limit) {
        foreach my $offset (0.25, 0.75) {
          my $n = $n + $offset;
          my ($x,$y) = $path->n_to_xy($n);
          my ($next_x,$next_y) = $path->n_to_xy($n+$arms_count);
          my $want_dx = ($next_x - $x);
          my $want_dy = ($next_y - $y);
          my ($got_dx,$got_dy) = $path->n_to_dxdy($n);
          $want_dx == $got_dx
            or &$report ("n_to_dxdy($n) got_dx=$got_dx want_dx=$want_dx");
          $want_dy == $got_dy
            or &$report ("n_to_dxdy($n) got_dy=$got_dy want_dy=$want_dy");
        }
      }
    }

    #--------------------------------------------------------------------------
    ### n_to_rsquared() vs X^2,Y^2 ...

    if ($path->can('n_to_rsquared') != Math::PlanePath->can('n_to_rsquared')) {
      foreach my $n ($n_start .. $#n_to_x) {
        my $x = $n_to_x[$n];
        my $y = $n_to_y[$n];
        my ($n_to_rsquared) = $path->n_to_rsquared($n);
        my $xy_to_rsquared = $x*$x + $y*$y;
        if (abs($n_to_rsquared - $xy_to_rsquared) > 0.0000001) {
          &$report ("n_to_rsquared() at n=$n,x=$x,y=$y got $n_to_rsquared whereas x^2+y^2=$xy_to_rsquared");
        }
      }
    }

    #--------------------------------------------------------------------------
    ### n_to_xy() various bogus values return 0 or 2 values and not crash ...

    foreach my $n (-100, -2, -1, -0.6, -0.5, -0.4,
                   0, 0.4, 0.5, 0.6) {
      my @xy = $path->n_to_xy ($n);
      (@xy == 0 || @xy == 2)
        or &$report ("n_to_xy() n=$n got ",scalar(@xy)," values");
    }

    foreach my $elem ([-1,-1, -1,-1],
                     ) {
      my ($x1,$y1,$x2,$y2) = @$elem;
      my ($got_lo, $got_hi) = $path->rect_to_n_range ($x1,$y1, $x2,$y2);
      (defined $got_lo && defined $got_hi)
        or &$report ("rect_to_n_range() x1=$x1,y1=$y1, x2=$x2,y2=$y2 undefs");
      if ($got_hi >= $got_lo) {
        $got_lo >= $n_start
          or &$report ("rect_to_n_range() got_lo=$got_lo is before n_start=$n_start");
      }
    }

    #--------------------------------------------------------------------------
    ### x negative xy_to_n() ...

    foreach my $x (-100, -99) {
      ### $x
      my @n = $path->xy_to_n ($x,-1);
      ### @n
      (scalar(@n) == 1)
        or &$report ("xy_to_n($x,-1) array context got ",scalar(@n)," values but should be 1, possibly undef");
    }

    {
      my $path_x_negative = ($path->x_negative ? 1 : 0);
      $got_x_negative = ($got_x_negative ? 1 : 0);

      if ($path->isa('Math::PlanePath::GosperSide')
          || $path->isa('Math::PlanePath::FlowsnakeCentres')
          || $path->isa('Math::PlanePath::QuintetCentres')
          || $mod eq 'ImaginaryBase,radix=37'
          || $mod eq 'ImaginaryHalf,radix=37'
          || $mod eq 'CubicBase,radix=37'
          || $mod eq 'ComplexPlus,realpart=2'
          || $mod eq 'ComplexPlus,realpart=3'
          || $mod eq 'ComplexPlus,realpart=4'
          || $mod eq 'ComplexPlus,realpart=5'
          || ($mod eq 'GreekKeySpiral' && $limit < 37)
          || ($mod eq 'GreekKeySpiral,turns=3' && $limit < 65)
          || ($mod eq 'GreekKeySpiral,turns=4' && $limit < 101)
          || ($mod eq 'GreekKeySpiral,turns=5' && $limit < 145)
          || ($mod eq 'GreekKeySpiral,turns=6' && $limit < 197)
          || $mod eq 'GreekKeySpiral,turns=7'
          || $mod eq 'GreekKeySpiral,turns=8'
          || $mod eq 'GreekKeySpiral,turns=37'
         ) {
        # these don't get to X negative in small rectangle
        $got_x_negative = 1;
      }

      ($path_x_negative == $got_x_negative)
        or &$report ("x_negative() $path_x_negative but in rect to n=$limit got $got_x_negative");
    }
    {
      my $path_y_negative = ($path->y_negative ? 1 : 0);
      $got_y_negative = ($got_y_negative ? 1 : 0);

      if ($path->isa('Math::PlanePath::GosperSide')
          || $path->isa('Math::PlanePath::FlowsnakeCentres')
          || ($mod eq 'GreekKeySpiral' && $limit < 55)
          || ($mod eq 'GreekKeySpiral,turns=3' && $limit < 97)
          || ($mod eq 'GreekKeySpiral,turns=4' && $limit < 151)
          || ($mod eq 'GreekKeySpiral,turns=5' && $limit < 217)
          || ($mod eq 'GreekKeySpiral,turns=6' && $limit < 295)
          || $mod eq 'GreekKeySpiral,turns=7'
          || $mod eq 'GreekKeySpiral,turns=8'
          || $mod eq 'GreekKeySpiral,turns=37'
          || $mod eq 'SquareSpiral,wider=37'
          || $mod eq 'HexSpiral,wider=37'
          || $mod eq 'HexSpiralSkewed,wider=37'
          || ($mod eq 'ImaginaryBase,radix=3' && $limit < 3**3) # first Y negs
          || ($mod eq 'ImaginaryBase,radix=4' && $limit < 4**3)
          || ($mod eq 'ImaginaryBase,radix=5' && $limit < 5**3)
          || ($mod eq 'ImaginaryBase,radix=37' && $limit < 37**3)
          || $mod eq 'CubicBase,radix=37'
          || ($mod eq 'ComplexPlus' && $limit < 32) # first y_neg at N=32
          || $mod eq 'ComplexPlus,realpart=2'  # y_neg big
          || $mod eq 'ComplexPlus,realpart=3'
          || $mod eq 'ComplexPlus,realpart=4'
          || $mod eq 'ComplexPlus,realpart=5'
          || $mod eq 'ComplexMinus,realpart=3'
          || $mod eq 'ComplexMinus,realpart=4'
          || $mod eq 'ComplexMinus,realpart=5'
          || ($mod eq 'AnvilSpiral,wider=17' && $limit < 41) # first y_neg at N=41
          || $mod eq 'TerdragonCurve'
          || $mod eq 'TerdragonCurve,arms=2'
          || $mod eq 'TerdragonMidpoint'
          || $mod eq 'TerdragonMidpoint,arms=2'
          || $mod eq 'TerdragonRounded'
          || $mod eq 'TerdragonRounded,arms=2'
          || $mod eq 'TerdragonRounded,arms=3'
          || ($mod eq 'AlternatePaper,arms=5' && $limit < 44) # first y_neg at N=44
          || ($mod eq 'AlternatePaper,arms=8' && $limit < 14) # first y_neg at N=14
          || $mod eq 'R5DragonCurve'
          || $mod eq 'R5DragonMidpoint'
          || $mod eq 'R5DragonMidpoint,arms=2'
         ) {
        # GosperSide and Flowsnake take a long time to get
        # to Y negative, not reached by the rectangle
        # considered here.  ComplexMinus doesn't get there
        # on realpart==5 or bigger too.
        $got_y_negative = 1;
      }

      ($path_y_negative == $got_y_negative)
        or &$report ("y_negative() $path_y_negative but in rect to n=$limit got $got_y_negative");
    }

    if ($path->figure ne 'circle'
        # bit slow
        && ! ($path->isa('Math::PlanePath::Flowsnake'))) {

      my $x_min = ($path->x_negative ? - int($rect_limit/2) : -2);
      my $y_min = ($path->y_negative ? - int($rect_limit/2) : -2);
      my $x_max = $x_min + $rect_limit;
      my $y_max = $y_min + $rect_limit;
      my $data;
      foreach my $x ($x_min .. $x_max) {
        foreach my $y ($y_min .. $y_max) {
          $data->{$y}->{$x} = $path->xy_to_n ($x, $y);
        }
      }
      #### $data

      # MyTestHelpers::diag ("rect check ...");
      foreach my $y1 ($y_min .. $y_max) {
        foreach my $y2 ($y1 .. $y_max) {

          foreach my $x1 ($x_min .. $x_max) {
            my $min;
            my $max;

            foreach my $x2 ($x1 .. $x_max) {
              my @col = map {$data->{$_}->{$x2}} $y1 .. $y2;
              @col = grep {defined} @col;
              $min = List::Util::min (grep {defined} $min, @col);
              $max = List::Util::max (grep {defined} $max, @col);
              my $want_min = (defined $min ? $min : 1);
              my $want_max = (defined $max ? $max : 0);
              ### @col
              ### rect: "$x1,$y1  $x2,$y2  expect N=$want_min..$want_max"

              foreach my $x_swap (0, 1) {
                my ($x1,$x2) = ($x_swap ? ($x1,$x2) : ($x2,$x1));
                foreach my $y_swap (0, 1) {
                  my ($y1,$y2) = ($y_swap ? ($y1,$y2) : ($y2,$y1));

                  my ($got_min, $got_max)
                    = $path->rect_to_n_range ($x1,$y1, $x2,$y2);
                  defined $got_min
                    or &$report ("rect_to_n_range($x1,$y1, $x2,$y2) got_min undef");
                  defined $got_max
                    or &$report ("rect_to_n_range($x1,$y1, $x2,$y2) got_max undef");
                  if ($got_max >= $got_min) {
                    $got_min >= $n_start
                      or $rect_before_n_start{$class}
                        or &$report ("rect_to_n_range() got_min=$got_min is before n_start=$n_start");
                  }

                  if (! defined $min || ! defined $max) {
                    if (! $rect_exact_hi{$class}) {
                      next; # outside
                    }
                  }

                  unless ($rect_exact{$class}
                          ? $got_min == $want_min
                          : $got_min <= $want_min) {
                    ### $x1
                    ### $y1
                    ### $x2
                    ### $y2
                    ### got: $path->rect_to_n_range ($x1,$y1, $x2,$y2)
                    ### $want_min
                    ### $want_max
                    ### $got_min
                    ### $got_max
                    ### @col
                    ### $data
                    &$report ("rect_to_n_range($x1,$y1, $x2,$y2) bad min  got_min=$got_min want_min=$want_min".(defined $min ? '' : '[nomin]')
                             );
                  }
                  unless ($rect_exact_hi{$class}
                          ? $got_max == $want_max
                          : $got_max >= $want_max) {
                    &$report ("rect_to_n_range($x1,$y1, $x2,$y2 ) bad max got $got_max want $want_max".(defined $max ? '' : '[nomax]'));
                  }
                }
              }
            }
          }
        }
      }

      if ($path->can('xy_is_visited') != Math::PlanePath->can('xy_is_visited')) {
        # MyTestHelpers::diag ("xy_is_visited() check ...");
        foreach my $y ($y_min .. $y_max) {
          foreach my $x ($x_min .. $x_max) {
            my $got_visited = ($path->xy_is_visited($x,$y) ? 1 : 0);
            my $want_visited = (defined($data->{$y}->{$x}) ? 1 : 0);
            unless ($got_visited == $want_visited) {
              &$report ("xy_is_visited($x,$y) got $got_visited want $want_visited");
            }
          }
        }
      }
    }

    my $is_a_tree;
    {
      my @n_children = $path->tree_n_children($n_start);
      if (@n_children) {
        $is_a_tree = 1;
      }
    }


    ### tree_n_children before n_start ...
    foreach my $n ($n_start-5 .. $n_start-1) {
      {
        my @n_children = $path->tree_n_children($n);
        (@n_children == 0)
          or &$report ("tree_n_children($n) before n_start=$n_start unexpectedly got ",scalar(@n_children)," values:",@n_children);
      }
      {
        my $num_children = $path->tree_n_num_children($n);
        if (defined $num_children) {
          &$report ("tree_n_num_children($n) before n_start=$n_start unexpectedly $num_children not undef");
        }
      }
    }

    ### tree_n_parent() before n_start ...
    foreach my $n ($n_start-5 .. $n_start) {
      my $n_parent = $path->tree_n_parent($n);
      if (defined $n_parent) {
        &$report ("tree_n_parent($n) <= n_start=$n_start unexpectedly got parent ",$n_parent);
      }
    }
    ### tree_n_children() look at tree_n_parent of each ...
    foreach my $n ($n_start .. $n_start+$limit) {
      ### $n
      my @n_children = $path->tree_n_children($n);
      ### @n_children
      foreach my $n_child (@n_children) {
        my $got_n_parent = $path->tree_n_parent($n_child);
        ($got_n_parent == $n)
          or &$report ("tree_n_parent($n_child) got $got_n_parent want $n");
      }
    }

    ### tree_n_to_depth() before n_start ...
    foreach my $n ($n_start-5 .. $n_start-1) {
      my $depth = $path->tree_n_to_depth($n);
      if (defined $depth) {
        &$report ("tree_n_to_depth($n) < n_start=$n_start unexpectedly got depth ",$depth);
      }
    }
    ### tree_n_to_depth matching parent count ...
    if ($path->can('tree_n_to_depth')
        != Math::PlanePath->can('tree_n_to_depth')) {
      # MyTestHelpers::diag ($mod, ' tree_n_to_depth()');
      foreach my $n ($n_start .. $n_start+$limit) {
        my $want_depth = path_tree_n_to_depth_by_parents($path,$n);
        my $got_depth = $path->tree_n_to_depth($n);
        if (! defined $got_depth || ! defined $want_depth
            || $got_depth != $want_depth) {
          &$report ("tree_n_to_depth($n) got ",$got_depth," want ",$want_depth);
        }
      }
    }

    if ($path->can('tree_n_to_height')
        != Math::PlanePath->can('tree_n_to_height')) {
      # MyTestHelpers::diag ($mod, ' tree_n_to_height()');
      foreach my $n ($n_start .. $n_start+$limit) {
        my $want_height = path_tree_n_to_height_by_search($path,$n);
        my $got_height = $path->tree_n_to_height($n);
        if (! equal($got_height,$want_height)) {
          &$report ("tree_n_to_height($n) got ",$got_height," want ",$want_height);
        }
      }
    }

    ### tree_depth_to_n() on depth<0 ...
    foreach my $depth (-2 .. -1) {
      my $n = $path->tree_depth_to_n($depth);
      if (defined $n) {
        &$report ("tree_depth_to_n($depth) unexpectedly got n=",$n);
      }
    }

    ### tree_depth_to_n() ...
    if ($is_a_tree) {
      foreach my $depth (0 .. 10) {
        my $n = $path->tree_depth_to_n($depth);
        if (! defined $n) {
          &$report ("tree_depth_to_n($depth) should not be undef");
          next;
        }
        if ($n != int($n)) {
          &$report ("tree_depth_to_n($depth) not an integer: ",$n);
          next;
        }
        {
          my $got_depth = $path->tree_n_to_depth($n);
          if (! defined $got_depth || $got_depth != $depth) {
            &$report ("tree_depth_to_n($depth)=$n reverse got_depth=",$got_depth);
          }
        }
        {
          my $got_depth = $path->tree_n_to_depth($n-1);
          if (defined $got_depth && $got_depth >= $depth) {
            &$report ("tree_depth_to_n($depth)=$n reverse of n-1 got_depth=",$got_depth);
          }
        }
      }
    }

    ### done mod: $mod
  }
  ok ($good, 1);
}

sub path_tree_n_to_depth_by_parents {
  my ($path, $n) = @_;
  if ($n < $path->n_start) {
    return undef;
  }
  my $depth = 0;
  for (;;) {
    my $parent_n = $path->tree_n_parent($n);
    last if ! defined $parent_n;
    if ($parent_n >= $n) {
      die "Oops, tree parent $parent_n >= child $n in ", ref $path;
    }
    $n = $parent_n;
    $depth++;
  }
  return $depth;
}

sub path_tree_n_to_height_by_search {
  my ($self, $n) = @_;
  my @n = ($n);
  my $height = 0;
  for (;;) {
    @n = map {$self->tree_n_children($_)} @n
      or return $height;
    $height++;
    if (@n > 200 || $height > 200) {
      return undef;  # presumed infinite
    }
  }
}

sub equal {
  my ($x,$y) = @_;
  return ((! defined $x && ! defined $y)
          || (defined $x && defined $y && $x == $y));
}

exit 0;
