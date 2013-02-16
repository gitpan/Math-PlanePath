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


# Usage: perl gallery.pl
#
# Create the .png files in $target_dir = "$ENV{HOME}/tux/web/math-planepath"
# as appearing at http://user42.tuxfamily.org/math-planepath/gallery.html
#

use 5.004;
use strict;
use warnings;
use File::Compare ();
use File::Copy;
use File::Temp;
use Image::Base::GD;

# uncomment this to run the ### lines
#use Smart::Comments;

my $target_dir = "$ENV{HOME}/tux/web/math-planepath";
my $tempfh = File::Temp->new (SUFFIX => '.png');
my $tempfile = $tempfh->filename;
my $big_bytes = 0;
my %seen_filename;

foreach my $elem
  (
   ['rationals-tree-lines-ayt.png',
    'math-image --path=RationalsTree,tree_type=AYT --values=LinesTree --scale=20 --size=200'],
   ['rationals-tree-lines-hcs.png',
    'math-image --path=RationalsTree,tree_type=HCS --values=LinesTree --scale=20 --size=200'],
   ['rationals-tree-lines-l.png',
    'math-image --path=RationalsTree,tree_type=L --values=LinesTree --scale=20 --size=200'],
   ['rationals-tree-small.png',
    'math-image --path=RationalsTree --values=LinesTree --scale=8 --size=32 --offset=-8,-8'],
   ['rationals-tree-big.png',
    'math-image --path=RationalsTree --all --scale=3 --size=200'],
   ['rationals-tree-lines-sb.png',
    'math-image --path=RationalsTree,tree_type=SB --values=LinesTree --scale=20 --size=200'],
   ['rationals-tree-lines-cw.png',
    'math-image --path=RationalsTree,tree_type=CW --values=LinesTree --scale=20 --size=200'],
   ['rationals-tree-lines-bird.png',
    'math-image --path=RationalsTree,tree_type=Bird --values=LinesTree --scale=20 --size=200'],
   ['rationals-tree-lines-drib.png',
    'math-image --path=RationalsTree,tree_type=Drib --values=LinesTree --scale=20 --size=200'],


   ['one-of-eight-1-nonleaf.png',
    'math-image --path=OneOfEight,parts=1 --values=PlanePathCoord,planepath=\"OneOfEight,parts=1\",coordinate_type=IsNonLeaf --scale=3 --size=99'],
   ['one-of-eight-small.png',
    'math-image --path=OneOfEight --values=LinesTree --scale=4 --size=32'],
   ['one-of-eight-big.png',
    'math-image --path=OneOfEight --values=LinesTree --scale=6 --size=200'],
   ['one-of-eight-1.png',
    'math-image --path=OneOfEight,parts=1 --all --scale=3 --size=99'],
   ['one-of-eight-octant.png',
    'math-image --path=OneOfEight,parts=octant --all --scale=3 --size=99'],
   ['one-of-eight-3mid.png',
    'math-image --path=OneOfEight,parts=3mid --all --scale=3 --size=99'],
   ['one-of-eight-3side.png',
    'math-image --path=OneOfEight,parts=3side --all --scale=3 --size=99'],

   ['koch-curve-small.png',
    'math-image --path=KochCurve --lines --scale=2 --size=32 --offset=0,8'],
   ['koch-curve-big.png',
    'math-image --path=KochCurve --lines --scale=5 --size=250x100 --offset=0,5'],

   ['ulam-warburton-tree-big.png',
    "math-image --path=UlamWarburton --values=LinesTree --scale=7 --figure=point --size=150"],
   ['ulam-warburton-quarter-small.png',
    "math-image --path=UlamWarburtonQuarter --expression='i<50?i:0' --scale=2 --size=32"],
   ['ulam-warburton-quarter-big.png',
    "math-image --path=UlamWarburtonQuarter --expression='i<233?i:0' --scale=4 --size=150"],

   ['ulam-warburton-small.png',
    "math-image --path=UlamWarburton --expression='i<50?i:0' --scale=2 --size=32"],
   ['ulam-warburton-big.png',
    "math-image --path=UlamWarburton --expression='i<233?i:0' --scale=4 --size=150"],


   ['pythagorean-tree-fb-big.png',
    'math-image --path=PythagoreanTree,tree_type=FB --values=LinesTree --scale=4 --size=200'],
   ['pythagorean-tree-big.png',
    'math-image --path=PythagoreanTree --values=LinesTree --scale=4 --size=200'],
   ['pythagorean-points-bc-big.png',
    'math-image --path=PythagoreanTree,coordinates=BC --all --scale=1 --size=200'],
   ['pythagorean-points-ac-big.png',
    'math-image --path=PythagoreanTree,coordinates=AC --all --scale=1 --size=200'],
   ['pythagorean-small.png',
    'math-image --path=PythagoreanTree --values=LinesTree --scale=1 --size=32'],
   ['pythagorean-points-big.png',
    'math-image --path=PythagoreanTree --all --scale=1 --size=200'],

   ['toothpick-upist-small.png',
    'math-image --path=ToothpickUpist --values=LinesTree --scale=4 --size=32 --figure=toothpick --offset=0,5'],
   ['toothpick-upist-big.png',
    'math-image --path=ToothpickUpist --values=LinesTree --scale=5 --size=300x150 --figure=toothpick'],

   ['lcorner-tree-small.png',
    'math-image --path=LCornerTree --values=LinesTree --scale=4 --size=32'],
   ['lcorner-tree-big.png',
    'math-image --path=LCornerTree --values=LinesTree --scale=7 --size=200'],

   ['lcorner-replicate-small.png',
    'math-image --path=LCornerReplicate --lines --scale=4 --size=32'],
   ['lcorner-replicate-big.png',
    'math-image --path=LCornerReplicate --lines --scale=7 --size=200'],

   ['toothpick-tree-small.png',
    'math-image --path=ToothpickTree --values=LinesTree --scale=4 --size=32'],
   ['toothpick-tree-big.png',
    'math-image --path=ToothpickTree --values=LinesTree --scale=6 --size=200'],

   ['toothpick-replicate-small.png',
    'math-image --path=ToothpickReplicate --lines --scale=4 --size=32 --figure=toothpick'],
   ['toothpick-replicate-big.png',
    'math-image --path=ToothpickReplicate --all --scale=6 --size=200 --figure=toothpick'],


   ['imaginaryhalf-small.png',
    'math-image --path=ImaginaryHalf --lines --scale=7 --size=32'],
   ['imaginaryhalf-big.png',
    'math-image --path=ImaginaryHalf --lines --scale=18 --size=200'],
   ['imaginaryhalf-radix5-big.png',
    'math-image --path=ImaginaryHalf,radix=5 --lines --scale=18 --size=200'],
   ['imaginaryhalf-xxy-big.png',
    'math-image --path=ImaginaryHalf,digit_order=XXY --lines --scale=10 --size=75'],
   ['imaginaryhalf-yxx-big.png',
    'math-image --path=ImaginaryHalf,digit_order=YXX --lines --scale=10 --size=75'],
   ['imaginaryhalf-xnyx-big.png',
    'math-image --path=ImaginaryHalf,digit_order=XnYX --lines --scale=10 --size=75'],
   ['imaginaryhalf-xnxy-big.png',
    'math-image --path=ImaginaryHalf,digit_order=XnXY --lines --scale=10 --size=75'],
   ['imaginaryhalf-yxnx-big.png',
    'math-image --path=ImaginaryHalf,digit_order=YXnX --lines --scale=10 --size=75'],


   ['imaginarybase-small.png',
    'math-image --path=ImaginaryBase --lines --scale=7 --size=32'],
   ['imaginarybase-big.png',
    'math-image --path=ImaginaryBase --lines --scale=18 --size=200'],
   ['imaginarybase-radix5-big.png',
    'math-image --path=ImaginaryBase,radix=5 --lines --scale=18 --size=200'],


   ['cfrac-digits-small.png',
    'math-image --path=CfracDigits --lines --scale=4 --size=32 --offset=-4,-8'],
   ['cfrac-digits-big.png',
    'math-image --path=CfracDigits --lines --scale=10 --size=200'],
   ['cfrac-digits-radix3.png',
    'math-image --path=CfracDigits,radix=3 --lines --scale=10 --size=200'],
   ['cfrac-digits-radix4.png',
    'math-image --path=CfracDigits,radix=4 --lines --scale=10 --size=200'],

   ['chan-tree-small.png',
    'math-image --path=ChanTree --all --scale=2 --size=32'],
   ['chan-tree-big.png',
    'math-image --path=ChanTree --all --scale=3 --size=200'],
   ['chan-tree-lines.png',
    'math-image --path=ChanTree --values=LinesTree --scale=8 --size=200'],
   ['chan-tree-k4.png',
    'math-image --path=ChanTree,k=4 --all --scale=3 --size=200'],
   ['chan-tree-k5.png',
    'math-image --path=ChanTree,k=5 --all --scale=3 --size=200'],

   ['h-indexing-small.png',
    'math-image --path=HIndexing --scale=3 --size=32 --lines --figure=point'],
   ['h-indexing-big.png',
    'math-image --path=HIndexing --lines --scale=5 --size=200 --figure=point'],

   ['sierpinski-curve-small.png',
    'math-image --path=SierpinskiCurve,arms=2 --scale=3 --size=32 --lines --figure=point'],
   ['sierpinski-curve-big.png',
    'math-image --path=SierpinskiCurve --lines --scale=3 --size=200 --figure=point'],
   ['sierpinski-curve-8arm-big.png',
    'math-image --path=SierpinskiCurve,arms=8 --lines --scale=3 --size=200 --figure=point'],


   ['alternate-paper-midpoint-small.png',
    'math-image --path=AlternatePaperMidpoint --lines --scale=3 --size=32'],
   ['alternate-paper-midpoint-big.png',
    'math-image --path=AlternatePaperMidpoint --lines --figure=point --scale=4 --size=200'],
   ['alternate-paper-midpoint-8arm-big.png',
    'math-image --path=AlternatePaperMidpoint,arms=8 --lines --figure=point --scale=4 --size=200'],


   ['sierpinski-curve-stair-small.png',
    'math-image --path=SierpinskiCurveStair,arms=2 --scale=3 --size=32 --lines --figure=point'],
   ['sierpinski-curve-stair-big.png',
    'math-image --path=SierpinskiCurveStair --lines --scale=5 --size=200 --figure=point'],
   ['sierpinski-curve-stair-8arm-big.png',
    'math-image --path=SierpinskiCurveStair,arms=8 --lines --scale=5 --size=200 --figure=point'],


   ['alternate-paper-small.png',
    'math-image --path=AlternatePaper --lines --scale=4 --size=32'],
   ['alternate-paper-big.png',
    'math-image --path=AlternatePaper --lines --figure=point --scale=8 --size=200'],
   ['alternate-paper-rounded-big.png',
    'math-image --path=AlternatePaper --values=Lines,lines_type=rounded,midpoint_offset=0.4 --figure=point --scale=16 --size=200'],


   ['pyramid-rows-small.png',
    'math-image --path=PyramidRows --lines --scale=5 --size=32'],
   ['pyramid-rows-big.png',
    'math-image --path=PyramidRows --lines --scale=15 --size=300x150'],
   ['pyramid-rows-right-big.png',
    'math-image --path=PyramidRows,step=4,align=right --lines --scale=15 --size=300x150'],
   ['pyramid-rows-left-big.png',
    'math-image --path=PyramidRows,step=1,align=left --lines --scale=15 --size=160x150 --offset=65,0'],

   ['sierpinski-triangle-small.png',
    'math-image --path=SierpinskiTriangle --all --scale=2 --size=32'],
   ['sierpinski-triangle-big.png',
    'math-image --path=SierpinskiTriangle --all --scale=3 --size=400x200'],
   ['sierpinski-triangle-right-big.png',
    'math-image --path=SierpinskiTriangle,align=right --all --scale=3 --size=200x200'],
   ['sierpinski-triangle-left-big.png',
    'math-image --path=SierpinskiTriangle,align=left --all --scale=3 --size=200x200 --offset=98,0'],
   ['sierpinski-triangle-diagonal-big.png',
    'math-image --path=SierpinskiTriangle,align=diagonal --values=LinesTree --scale=4 --size=200x200'],


   ['sierpinski-arrowhead-centres-small.png',
    'math-image --path=SierpinskiArrowheadCentres --lines --scale=2 --size=32'],
   ['sierpinski-arrowhead-centres-big.png',
    'math-image --path=SierpinskiArrowheadCentres --lines --scale=3 --size=400x200'],
   ['sierpinski-arrowhead-centres-right-big.png',
    'math-image --path=SierpinskiArrowheadCentres,align=right --lines --scale=4 --size=200x200'],
   ['sierpinski-arrowhead-centres-left-big.png',
    'math-image --path=SierpinskiArrowheadCentres,align=left --lines --scale=4 --size=200x200 --offset=98,0'],
   ['sierpinski-arrowhead-centres-diagonal-big.png',
    'math-image --path=SierpinskiArrowheadCentres,align=diagonal --lines --scale=5 --size=200x200 --figure=point'],


   ['sierpinski-arrowhead-small.png',
    'math-image --path=SierpinskiArrowhead --lines --scale=2 --size=32'],
   ['sierpinski-arrowhead-big.png',
    'math-image --path=SierpinskiArrowhead --lines --scale=3 --size=400x200'],
   ['sierpinski-arrowhead-right-big.png',
    'math-image --path=SierpinskiArrowhead,align=right --lines --scale=4 --size=200x200'],
   ['sierpinski-arrowhead-left-big.png',
    'math-image --path=SierpinskiArrowhead,align=left --lines --scale=4 --size=200x200 --offset=98,0'],
   ['sierpinski-arrowhead-diagonal-big.png',
    'math-image --path=SierpinskiArrowhead,align=diagonal --lines --scale=5 --size=200x200 --figure=point'],


   ['wunderlich-meander-small.png',
    'math-image --path=WunderlichMeander --lines --scale=4 --size=32 --figure=point'],
   ['wunderlich-meander-big.png',
    'math-image --path=WunderlichMeander --lines --scale=7 --size=192 --figure=point'],

   ['hilbert-small.png',
    'math-image --path=HilbertCurve --lines --scale=3 --size=32 --figure=point'],
   ['hilbert-big.png',
    'math-image --path=HilbertCurve --lines --scale=7 --size=225 --figure=point'],

   ['hilbert-spiral-small.png',
    'math-image --path=HilbertSpiral --lines --scale=3 --size=32 --figure=point'],
   ['hilbert-spiral-big.png',
    'math-image --path=HilbertSpiral --lines --scale=7 --size=230 --figure=point'],

   ['cinco-small.png',
    'math-image --path=CincoCurve --lines --scale=6 --size=32 --figure=point'],
   ['cinco-big.png',
    'math-image --path=CincoCurve --lines --scale=7 --size=176 --figure=point'],

   ['dekking-curve-small.png',
    'math-image --path=DekkingCurve --lines --scale=5 --size=32 --figure=point'],
   ['dekking-curve-big.png',
    'math-image --path=DekkingCurve --lines --scale=7 --size=183 --figure=point'],

   ['dekking-centres-small.png',
    'math-image --path=DekkingCentres --lines --scale=6 --size=32 --figure=point'],
   ['dekking-centres-big.png',
    'math-image --path=DekkingCentres --lines --scale=7 --size=176 --figure=point'],

   # ['hilbert-midpoint-small.png',
   #  'math-image --path=HilbertMidpoint --lines --scale=2 --size=32'],
   # ['hilbert-midpoint-big.png',
   #  'math-image --path=HilbertMidpoint --lines --scale=3 --size=190'],


   ['power-array-small.png',
    'math-image --path=PowerArray --lines --scale=8 --size=32'],
   ['power-array-big.png',
    'math-image --path=PowerArray --lines --scale=16 --size=200'],
   ['power-array-radix5-big.png',
    'math-image --path=PowerArray,radix=5 --lines --scale=16 --size=200'],

   ['wythoff-array-small.png',
    'math-image --path=WythoffArray --lines --scale=8 --size=32'],
   ['wythoff-array-big.png',
    'math-image --path=WythoffArray --lines --scale=16 --size=200'],


   ['complexminus-small.png',
    "math-image --path=ComplexMinus --expression='i<32?i:0' --scale=2 --size=32"],
   ['complexminus-big.png',
    "math-image --path=ComplexMinus --expression='i<1024?i:0' --scale=3 --size=200"],
   ['complexminus-r2-small.png',
    "math-image --path=ComplexMinus,realpart=2 --expression='i<125?i:0' --scale=2 --size=32"],
   ['complexminus-r2-big.png',
    "math-image --path=ComplexMinus,realpart=2 --expression='i<3125?i:0' --scale=1 --size=200"],


   ['pyramid-sides-small.png',
    'math-image --path=PyramidSides --lines --scale=5 --size=32'],
   ['pyramid-sides-big.png',
    'math-image --path=PyramidSides --lines --scale=15 --size=300x150'],


   ['triangular-hypot-small.png',
    'math-image --path=TriangularHypot --lines --scale=4 --size=32'],
   ['triangular-hypot-big.png',
    'math-image --path=TriangularHypot --lines --scale=15 --size=200x150'],
   ['triangular-hypot-odd-big.png',
    'math-image --path=TriangularHypot,points=odd --lines --scale=15 --size=200x150'],
   ['triangular-hypot-all-big.png',
    'math-image --path=TriangularHypot,points=all --lines --scale=15 --size=200x150'],
   ['triangular-hypot-hex-big.png',
    'math-image --path=TriangularHypot,points=hex --lines --scale=15 --size=200x150'],
   ['triangular-hypot-hex-rotated-big.png',
    'math-image --path=TriangularHypot,points=hex_rotated --lines --scale=15 --size=200x150'],
   ['triangular-hypot-hex-centred-big.png',
    'math-image --path=TriangularHypot,points=hex_centred --lines --scale=15 --size=200x150'],

   ['greek-key-small.png',
    'math-image --path=GreekKeySpiral --lines --scale=4 --size=32'],
   ['greek-key-big.png',
    'math-image --path=GreekKeySpiral --lines --scale=8 --size=200'],
   ['greek-key-turns1-big.png',
    'math-image --path=GreekKeySpiral,turns=1 --lines --scale=8 --figure=point --size=200'],
   ['greek-key-turns5-big.png',
    'math-image --path=GreekKeySpiral,turns=5 --lines --scale=8 --figure=point --size=200'],


   ['c-curve-small.png',
    'math-image --path=CCurve --lines --scale=3 --size=32 --offset=8,0'],
   ['c-curve-big.png',
    'math-image --path=CCurve --lines --figure=point --scale=3 --size=250x250 --offset=20,-70'],


   ['gcd-rationals-small.png',
    'math-image --path=GcdRationals --lines --scale=6 --size=32 --offset=-4,-4'],
   ['gcd-rationals-big.png',
    'math-image --path=GcdRationals --lines --scale=15 --size=200'],
   ['gcd-rationals-reverse-big.png',
    'math-image --path=GcdRationals,pairs_order=rows_reverse --lines --scale=15 --size=200'],
   ['gcd-rationals-diagonals-big.png',
    "math-image --path=GcdRationals,pairs_order=diagonals_down --expression='i<=@{[47**2]}?i:0' --scale=2 --size=160x200"],

   ['diagonals-octant-small.png',
    'math-image --path=DiagonalsOctant --lines --scale=6 --size=32'],
   ['diagonals-octant-big.png',
    'math-image --path=DiagonalsOctant --lines --scale=15 --size=195'],

   ['diagonals-alternating-small.png',
    'math-image --path=DiagonalsAlternating --lines --scale=6 --size=32'],
   ['diagonals-alternating-big.png',
    'math-image --path=DiagonalsAlternating --lines --scale=15 --size=195'],

   ['diagonals-small.png',
    'math-image --path=Diagonals --lines --scale=6 --size=32'],
   ['diagonals-big.png',
    'math-image --path=Diagonals --lines --scale=15 --size=195'],

   ['terdragon-rounded-small.png',
    'math-image --path=TerdragonRounded --lines --scale=2 --size=32 --offset=-5,-10'],
   ['terdragon-rounded-big.png',
    'math-image --path=TerdragonRounded --lines --figure=point --scale=3 --size=200 --offset=65,-20'],
   ['terdragon-rounded-6arm-big.png',
    'math-image --path=TerdragonRounded,arms=6 --lines --figure=point --scale=5 --size=200'],


   ['terdragon-small.png',
    'math-image --path=TerdragonCurve --lines --scale=5 --size=32 --offset=-3,-7'],
   ['terdragon-big.png',
    'math-image --path=TerdragonCurve --lines --figure=point --scale=4 --size=200 --offset=75,50'],
   # ['terdragon-6arm-big.png',
   #  'math-image --path=TerdragonCurve,arms=6 --lines --figure=point --scale=4 --size=200'],
   # ['terdragon-rounded-big.png',
   #  'math-image --path=TerdragonCurve --values=Lines,lines_type=rounded,midpoint_offset=.4 --figure=point --scale=16 --size=200 --offset=35,-30'],
   # ['terdragon-rounded-6arm-big.png',
   #  'math-image --path=TerdragonCurve,arms=6 --values=Lines,lines_type=rounded,midpoint_offset=.4 --figure=point --scale=10 --size=200'],


   ['terdragon-midpoint-6arm-big.png',
    'math-image --path=TerdragonMidpoint,arms=6 --lines --figure=circle --scale=4 --size=200'],
   ['terdragon-midpoint-small.png',
    'math-image --path=TerdragonMidpoint --lines --scale=2 --size=32 --offset=2,-9'],
   ['terdragon-midpoint-big.png',
    'math-image --path=TerdragonMidpoint --lines --figure=circle --scale=8 --size=200 --offset=50,-50'],


   ['r5dragon-small.png',
    'math-image --path=R5DragonCurve --lines --scale=4 --size=32 --offset=6,-5'],
   ['r5dragon-big.png',
    'math-image --path=R5DragonCurve --lines --figure=point --scale=10 --size=200x200 --offset=20,45'],
   ['r5dragon-rounded-big.png',
    'math-image --path=R5DragonCurve --values=Lines,lines_type=rounded,midpoint_offset=.6 --figure=point --scale=10 --size=200x200 --offset=20,45'],
   ['r5dragon-rounded-4arm-big.png',
    'math-image --path=R5DragonCurve,arms=4 --values=Lines,lines_type=rounded,midpoint_offset=.6 --figure=point --scale=20 --size=200x200'],


   ['r5dragon-midpoint-small.png',
    'math-image --path=R5DragonMidpoint --lines --scale=3 --size=32 --offset=3,-9'],
   ['r5dragon-midpoint-big.png',
    'math-image --path=R5DragonMidpoint --lines --figure=point --scale=8 --size=200 --offset=65,-15'],
   ['r5dragon-midpoint-4arm-big.png',
    'math-image --path=R5DragonMidpoint,arms=4 --lines --figure=point --scale=12 --size=200'],


   ['cubicbase-small.png',
    'math-image --path=CubicBase --lines --scale=5 --size=32'],
   ['cubicbase-big.png',
    'math-image --path=CubicBase --lines --scale=18 --size=200'],
   ['cubicbase-radix5-big.png',
    'math-image --path=CubicBase,radix=5 --lines --scale=18 --size=200'],


   ['peano-small.png',
    'math-image --path=PeanoCurve --lines --scale=3 --size=32'],
   ['peano-big.png',
    'math-image --path=PeanoCurve --lines --scale=7 --size=192'],
   ['peano-radix7-big.png',
    'math-image --path=PeanoCurve,radix=7 --values=Lines --scale=5 --size=192'],


   ['gray-code-small.png',
    'math-image --path=GrayCode --lines --scale=6 --size=32'],
   ['gray-code-big.png',
    'math-image --path=GrayCode --lines --scale=14 --size=226'],
   ['gray-code-radix4-big.png',
    'math-image --path=GrayCode,radix=4 --lines --scale=14 --size=226'],

   ['zorder-small.png',
    'math-image --path=ZOrderCurve --lines --scale=6 --size=32'],
   ['zorder-big.png',
    'math-image --path=ZOrderCurve --lines --scale=14 --size=226'],
   ['zorder-radix5-big.png',
    'math-image --path=ZOrderCurve,radix=5 --lines --scale=14 --size=226'],
   ['zorder-fibbinary.png',
    'math-image --path=ZOrderCurve --values=Fibbinary --scale=1 --size=704x320'],

   ['wunderlich-serpentine-small.png',
    'math-image --path=WunderlichSerpentine --lines --scale=4 --size=32'],
   ['wunderlich-serpentine-big.png',
    'math-image --path=WunderlichSerpentine --lines --scale=7 --size=192'],
   ['wunderlich-serpentine-coil-big.png',
    'math-image --path=WunderlichSerpentine,serpentine_type=coil --values=Lines --scale=7 --size=192'],
   ['wunderlich-serpentine-radix7-big.png',
    'math-image --path=WunderlichSerpentine,radix=7 --values=Lines --scale=5 --size=192'],


   ['cretan-labyrinth-small.png',
    'math-image --path=CretanLabyrinth --lines --scale=3 --size=32'],
   ['cretan-labyrinth-big.png',
    'math-image --path=CretanLabyrinth --lines --scale=9 --size=185x195 --offset=5,0'],


   ['theodorus-small.png',
    'math-image --path=TheodorusSpiral --lines --scale=3 --size=32'],
   ['theodorus-big.png',
    'math-image --path=TheodorusSpiral --lines --scale=10 --size=200'],


   ['filled-rings-small.png',
    'math-image --path=FilledRings --lines --scale=4 --size=32'],
   ['filled-rings-big.png',
    'math-image --path=FilledRings --lines --scale=10 --size=200'],


   ['pixel-small.png',
    'math-image --path=PixelRings --lines --scale=4 --size=32'],
   ['pixel-big.png',
    'math-image --path=PixelRings --all --figure=circle --scale=10 --size=200',
    border => 1 ],
   ['pixel-lines-big.png',
    'math-image --path=PixelRings --lines --scale=10 --size=200'],

   ['staircase-small.png',
    'math-image --path=Staircase --lines --scale=4 --size=32'],
   ['staircase-big.png',
    'math-image --path=Staircase --lines --scale=12 --size=200x200'],

   ['staircase-alternating-square-small.png',
    'math-image --path=StaircaseAlternating,end_type=square --lines --scale=4 --size=32'],
   ['staircase-alternating-big.png',
    'math-image --path=StaircaseAlternating --lines --scale=12 --size=200x200'],
   ['staircase-alternating-square-big.png',
    'math-image --path=StaircaseAlternating,end_type=square --lines --scale=12 --size=200x200'],


   ['cellular-rule-30-small.png',
    'math-image --path=CellularRule,rule=30 --all --scale=2 --size=32'],
   ['cellular-rule-30-big.png',
    'math-image --path=CellularRule,rule=30 --all --scale=4 --size=300x150'],
   ['cellular-rule-73-big.png',
    'math-image --path=CellularRule,rule=73 --all --scale=4 --size=300x150'],

   ['cellular-rule190-small.png',
    'math-image --path=CellularRule190 --all --scale=3 --size=32'],
   ['cellular-rule190-big.png',
    'math-image --path=CellularRule190 --all --scale=4 --size=300x150'],
   ['cellular-rule190-mirror-big.png',
    'math-image --path=CellularRule190,mirror=1 --all --scale=4 --size=300x150'],

   ['cellular-rule54-small.png',
    'math-image --path=CellularRule54 --all --scale=3 --size=32'],
   ['cellular-rule54-big.png',
    'math-image --path=CellularRule54 --all --scale=4 --size=300x150'],


   ['complexplus-small.png',
    "math-image --path=ComplexPlus --all --scale=2 --size=32"],
   ['complexplus-big.png',
    "math-image --path=ComplexPlus --all --scale=3 --size=200",
    border => 1],
   ['complexplus-r2-small.png',
    "math-image --path=ComplexPlus,realpart=2 --all --scale=2 --size=32"],
   ['complexplus-r2-big.png',
    "math-image --path=ComplexPlus,realpart=2 --all --scale=1 --size=200",
    border => 1],


   ['digit-groups-small.png',
    "math-image --path=DigitGroups --expression='i<256?i:0' --scale=2 --size=32"],
   #  --foreground=red
   ['digit-groups-big.png',
    "math-image --path=DigitGroups --expression='i<2048?i:0' --scale=3 --size=200",
    border => 1],
   ['digit-groups-radix5-big.png',
    "math-image --path=DigitGroups,radix=5 --expression='i<15625?i:0' --scale=3 --size=200",
    border => 1],

   ['l-tiling-small.png',
    'math-image --path=LTiling --all --scale=2 --size=32' ],
   ['l-tiling-big.png',
    'math-image --path=LTiling --all --scale=10 --size=200',
    border => 1 ],
   ['l-tiling-ends-big.png',
    'math-image --path=LTiling,L_fill=ends --all --scale=10 --size=200',
    border => 1],
   ['l-tiling-all-big.png',
    'math-image --path=LTiling,L_fill=all --lines --scale=10 --size=200'],

   ['dragon-rounded-small.png',
    'math-image --path=DragonRounded --lines --scale=2 --size=32 --offset=6,-3'],
   ['dragon-rounded-big.png',
    'math-image --path=DragonRounded --lines --figure=point --scale=3 --size=200 --offset=-20,0'],
   ['dragon-rounded-3arm-big.png',
    'math-image --path=DragonRounded,arms=3 --lines --figure=point --scale=3 --size=200'],

   ['dragon-midpoint-small.png',
    'math-image --path=DragonMidpoint --lines --scale=3 --size=32 --offset=7,-6'],
   ['dragon-midpoint-big.png',
    'math-image --path=DragonMidpoint --lines --figure=point --scale=8 --size=200 --offset=-10,50'],
   ['dragon-midpoint-4arm-big.png',
    'math-image --path=DragonMidpoint,arms=4 --lines --figure=point --scale=8 --size=200'],

   ['dragon-small.png',
    'math-image --path=DragonCurve --lines --scale=4 --size=32 --offset=6,0'],
   ['dragon-big.png',
    'math-image --path=DragonCurve --lines --figure=point --scale=8 --size=250x200 --offset=-55,0'],


   ['cellular-rule57-small.png',
    'math-image --path=CellularRule57 --all --scale=3 --size=32'],
   ['cellular-rule57-big.png',
    'math-image --path=CellularRule57 --all --scale=4 --size=300x150'],
   ['cellular-rule57-mirror-big.png',
    'math-image --path=CellularRule57,mirror=1 --all --scale=4 --size=300x150'],

   ['quadric-islands-small.png',
    'math-image --path=QuadricIslands --lines --scale=4 --size=32'],
   ['quadric-islands-big.png',
    'math-image --path=QuadricIslands --lines --scale=2 --size=200'],

   ['quadric-curve-small.png',
    'math-image --path=QuadricCurve --lines --scale=2 --size=32'],
   ['quadric-curve-big.png',
    'math-image --path=QuadricCurve --lines --scale=4 --size=300x200'],


   ['divisible-columns-small.png',
    'math-image --path=DivisibleColumns --all --scale=3 --size=32'],
   ['divisible-columns-big.png',
    'math-image --path=DivisibleColumns --all --scale=3 --size=200'],
   ['divisible-columns-proper-big.png',
    'math-image --path=DivisibleColumns,divisor_type=proper --all --scale=3 --size=400x200'],


   ['vogel-small.png',
    'math-image --path=VogelFloret --all --scale=3 --size=32'],
   ['vogel-big.png',
    'math-image --path=VogelFloret --all --scale=4 --size=200'],
   ['vogel-sqrt2-big.png',
    'math-image --path=VogelFloret,rotation_type=sqrt2 --all --scale=4 --size=200'],
   ['vogel-sqrt5-big.png',
    'math-image --path=VogelFloret,rotation_type=sqrt5 --all --scale=4 --size=200'],


   ['anvil-small.png',
    'math-image --path=AnvilSpiral --lines --scale=4 --size=32'],
   ['anvil-big.png',
    'math-image --path=AnvilSpiral --lines --scale=13 --size=200'],
   ['anvil-wider4-big.png',
    'math-image --path=AnvilSpiral,wider=4 --lines --scale=13 --size=200'],

   ['octagram-small.png',
    'math-image --path=OctagramSpiral --lines --scale=4 --size=32'],
   ['octagram-big.png',
    'math-image --path=OctagramSpiral --lines --scale=13 --size=200'],


   ['complexrevolving-small.png',
    "math-image --path=ComplexRevolving --expression='i<64?i:0' --scale=2 --size=32"],
   ['complexrevolving-big.png',
    "math-image --path=ComplexRevolving --expression='i<4096?i:0' --scale=2 --size=200"],


   ['fractions-tree-small.png',
    'math-image --path=FractionsTree --values=LinesTree --scale=8 --size=32 --offset=-8,-12'],
   ['fractions-tree-big.png',
    'math-image --path=FractionsTree --all --scale=3 --size=200'],
   ['fractions-tree-lines-kepler.png',
    'math-image --path=FractionsTree,tree_type=Kepler --values=LinesTree --scale=20 --size=200'],

   ['factor-rationals-small.png',
    'math-image --path=FactorRationals --lines --scale=6 --size=32 --offset=-4,-4'],
   ['factor-rationals-big.png',
    'math-image --path=FactorRationals --lines --scale=15 --size=200'],

   ['ar2w2-small.png',
    'math-image --path=AR2W2Curve --lines --scale=4 --size=32 --figure=point'],
   ['ar2w2-a1-big.png',
    'math-image --path=AR2W2Curve --lines --scale=7 --size=225 --figure=point'],
   ['ar2w2-d2-big.png',
    'math-image --path=AR2W2Curve,start_shape=D2 --lines --scale=7 --size=113 --figure=point'],
   ['ar2w2-b2-big.png',
    'math-image --path=AR2W2Curve,start_shape=B2 --lines --scale=7 --size=113 --figure=point'],
   ['ar2w2-b1rev-big.png',
    'math-image --path=AR2W2Curve,start_shape=B1rev --lines --scale=7 --size=113 --figure=point'],
   ['ar2w2-d1rev-big.png',
    'math-image --path=AR2W2Curve,start_shape=D1rev --lines --scale=7 --size=113 --figure=point'],
   ['ar2w2-a2rev-big.png',
    'math-image --path=AR2W2Curve,start_shape=A2rev --lines --scale=7 --size=113 --figure=point'],


   ['diagonal-rationals-small.png',
    'math-image --path=DiagonalRationals --lines --scale=4 --size=32'],
   ['diagonal-rationals-big.png',
    'math-image --path=DiagonalRationals --lines --scale=10 --size=200'],

   ['coprime-columns-small.png',
    'math-image --path=CoprimeColumns --all --scale=3 --size=32'],
   ['coprime-columns-big.png',
    'math-image --path=CoprimeColumns --all --scale=3 --size=200'],


   ['corner-small.png',
    'math-image --path=Corner --lines --scale=4 --size=32'],
   ['corner-big.png',
    'math-image --path=Corner --lines --scale=12 --size=200'],
   ['corner-wider4-big.png',
    'math-image --path=Corner,wider=4 --lines --scale=12 --size=200'],


   ['kochel-small.png',
    'math-image --path=KochelCurve --lines --scale=4 --size=32 --figure=point'],
   ['kochel-big.png',
    'math-image --path=KochelCurve --lines --scale=7 --size=192 --figure=point'],

   ['beta-omega-small.png',
    'math-image --path=BetaOmega --lines --scale=4 --size=32 --figure=point'],
   ['beta-omega-big.png',
    'math-image --path=BetaOmega --lines --scale=7 --size=226 --figure=point'],

   ['mpeaks-small.png',
    'math-image --path=MPeaks --lines --scale=4 --size=32'],
   ['mpeaks-big.png',
    'math-image --path=MPeaks --lines --scale=13 --size=200x180'],

   ['hex-small.png',
    'math-image --path=HexSpiral --lines --scale=3 --size=32'],
   ['hex-big.png',
    'math-image --path=HexSpiral --lines --scale=13 --size=300x150'],
   ['hex-wider4-big.png',
    'math-image --path=HexSpiral,wider=4 --lines --scale=13 --size=300x150'],

   ['hex-arms-small.png',
    'math-image --path=HexArms --lines --scale=3 --size=32'],
   ['hex-arms-big.png',
    'math-image --path=HexArms --lines --scale=10 --size=300x150'],

   ['hex-skewed-small.png',
    'math-image --path=HexSpiralSkewed --lines --scale=3 --size=32'],
   ['hex-skewed-big.png',
    'math-image --path=HexSpiralSkewed --lines --scale=13 --size=150'],
   ['hex-skewed-wider4-big.png',
    'math-image --path=HexSpiralSkewed,wider=4 --lines --scale=13 --size=150'],


   ['fibonacci-word-fractal-small.png',
    'math-image --path=FibonacciWordFractal --lines --scale=2 --size=32 --offset=2,2'],
   ['fibonacci-word-fractal-big.png',
    'math-image --path=FibonacciWordFractal --lines --scale=2 --size=345x170'],

   ['corner-replicate-small.png',
    'math-image --path=CornerReplicate --lines --scale=4 --size=32'],
   ['corner-replicate-big.png',
    'math-image --path=CornerReplicate --lines --scale=10 --size=200'],

   ['aztec-diamond-rings-small.png',
    'math-image --path=AztecDiamondRings --lines --scale=4 --size=32 --offset=3,3'],
   ['aztec-diamond-rings-big.png',
    'math-image --path=AztecDiamondRings --lines --scale=13 --size=200x200'],

   ['diamond-spiral-small.png',
    'math-image --path=DiamondSpiral --lines --scale=4 --size=32'],
   ['diamond-spiral-big.png',
    'math-image --path=DiamondSpiral --lines --scale=13 --size=200x200'],


   ['square-replicate-small.png',
    'math-image --path=SquareReplicate --lines --scale=4 --size=32'],
   ['square-replicate-big.png',
    'math-image --path=SquareReplicate --lines --scale=10 --size=215'],


   ['gosper-replicate-small.png',  # 7^2-1=48
    "math-image --path=GosperReplicate --expression='i<48?i:0' --scale=2 --size=32"],
   ['gosper-replicate-big.png',  # 7^4-1=16806
    "math-image --path=GosperReplicate --expression='i<16806?i:0' --scale=1 --size=320x200"],

   ['gosper-side-small.png',
    'math-image --path=GosperSide --lines --scale=3 --size=32 --offset=-13,-7'],
   ['gosper-side-big.png',
    'math-image --path=GosperSide --lines --scale=1 --size=250x200 --offset=95,-95'],

   ['gosper-islands-small.png',
    'math-image --path=GosperIslands --lines --scale=3 --size=32'],
   ['gosper-islands-big.png',
    'math-image --path=GosperIslands --lines --scale=2 --size=250x200'],


   ['square-small.png',
    'math-image --path=SquareSpiral --lines --scale=4 --size=32'],
   ['square-big.png',
    'math-image --path=SquareSpiral --lines --scale=13 --size=200'],
   ['square-wider4-big.png',
    'math-image --path=SquareSpiral,wider=4 --lines --scale=13 --size=253x200'],


   ['quintet-replicate-small.png',
    "math-image --path=QuintetReplicate --expression='i<125?i:0' --scale=2 --size=32"],
   ['quintet-replicate-big.png',
    "math-image --path=QuintetReplicate --expression='i<3125?i:0' --scale=2 --size=200"],

   ['quintet-curve-small.png',
    'math-image --path=QuintetCurve --lines --scale=4 --size=32 --offset=-10,0 --figure=point'],
   ['quintet-curve-big.png',
    'math-image --path=QuintetCurve --lines --scale=7 --size=200 --offset=-20,-70 --figure=point'],
   ['quintet-curve-4arm-big.png',
    'math-image --path=QuintetCurve,arms=4 --lines --scale=7 --size=200 --figure=point'],

   ['quintet-centres-small.png',
    'math-image --path=QuintetCentres --lines --scale=4 --size=32 --offset=-10,0 --figure=point'],
   ['quintet-centres-big.png',
    'math-image --path=QuintetCentres --lines --scale=7 --size=200 --offset=-20,-70 --figure=point'],


   ['koch-squareflakes-inward-small.png',
    'math-image --path=KochSquareflakes,inward=1 --lines --scale=2 --size=32'],
   ['koch-squareflakes-inward-big.png',
    'math-image --path=KochSquareflakes,inward=1 --lines --scale=2 --size=150x150'],

   ['koch-squareflakes-small.png',
    'math-image --path=KochSquareflakes --lines --scale=1 --size=32'],
   ['koch-squareflakes-big.png',
    'math-image --path=KochSquareflakes --lines --scale=2 --size=150x150'],

   ['koch-snowflakes-small.png',
    'math-image --path=KochSnowflakes --lines --scale=2 --size=32'],
   ['koch-snowflakes-big.png',
    'math-image --path=KochSnowflakes --lines --scale=3 --size=200x150'],

   ['koch-peaks-small.png',
    'math-image --path=KochPeaks --lines --scale=2 --size=32'],
   ['koch-peaks-big.png',
    'math-image --path=KochPeaks --lines --scale=3 --size=200x100'],


   ['flowsnake-3arm-big.png',
    'math-image --path=Flowsnake,arms=4 --lines --scale=6 --size=200'],
   ['flowsnake-small.png',
    'math-image --path=Flowsnake --lines --scale=4 --size=32 --offset=-5,-13'],
   ['flowsnake-big.png',
    'math-image --path=Flowsnake --lines --scale=8 --size=200 --offset=-20,-90'],

   ['flowsnake-centres-small.png',
    'math-image --path=FlowsnakeCentres --lines --scale=4 --size=32 --offset=-5,-13'],
   ['flowsnake-centres-big.png',
    'math-image --path=FlowsnakeCentres --lines --scale=8 --size=200 --offset=-20,-90'],


   ['triangle-spiral-small.png',
    'math-image --path=TriangleSpiral --lines --scale=3 --size=32'],
   ['triangle-spiral-big.png',
    'math-image --path=TriangleSpiral --lines --scale=13 --size=300x150'],

   ['triangle-spiral-skewed-small.png',
    'math-image --path=TriangleSpiralSkewed --lines --scale=3 --size=32'],
   ['triangle-spiral-skewed-big.png',
    'math-image --path=TriangleSpiralSkewed --lines --scale=13 --size=150'],


   ['diamond-arms-small.png',
    'math-image --path=DiamondArms --lines --scale=5 --size=32'],
   ['diamond-arms-big.png',
    'math-image --path=DiamondArms --lines --scale=15 --size=150x150'],

   ['square-arms-small.png',
    'math-image --path=SquareArms --lines --scale=3 --size=32'],
   ['square-arms-big.png',
    'math-image --path=SquareArms --lines --scale=10 --size=150x150'],

   ['hept-skewed-small.png',
    'math-image --path=HeptSpiralSkewed --lines --scale=4 --size=32'],
   ['hept-skewed-big.png',
    'math-image --path=HeptSpiralSkewed --lines --scale=13 --size=200'],


   ['pent-small.png',
    'math-image --path=PentSpiral --lines --scale=4 --size=32'],
   ['pent-big.png',
    'math-image --path=PentSpiral --lines --scale=13 --size=200'],

   ['hypot-octant-small.png',
    'math-image --path=HypotOctant --lines --scale=5 --size=32'],
   ['hypot-octant-big.png',
    'math-image --path=HypotOctant --lines --scale=15 --size=200x150'],

   ['hypot-small.png',
    'math-image --path=Hypot --lines --scale=6 --size=32'],
   ['hypot-big.png',
    'math-image --path=Hypot --lines --scale=15 --size=200x150'],

   ['knight-small.png',
    'math-image --path=KnightSpiral --lines --scale=7 --size=32'],
   ['knight-big.png',
    'math-image --path=KnightSpiral --lines --scale=11 --size=197'],

   ['multiple-small.png',
    'math-image --path=MultipleRings --lines --scale=4 --size=32'],
   ['multiple-big.png',
    'math-image --path=MultipleRings --lines --scale=10 --size=200'],

   ['sacks-small.png',
    'math-image --path=SacksSpiral --lines --scale=5 --size=32'],
   ['sacks-big.png',
    'math-image --path=SacksSpiral --lines --scale=10 --size=200'],

   ['archimedean-small.png',
    'math-image --path=ArchimedeanChords --lines --scale=5 --size=32'],
   ['archimedean-big.png',
    'math-image --path=ArchimedeanChords --lines --scale=10 --size=200'],

  ) {
  my ($filename, $command, %option) = @$elem;

  if ($seen_filename{$filename}++) {
    die "Duplicate filename $filename";
  }

  $command .= " --png >$tempfile";
  ### $command
  my $status = system $command;
  if ($status) {
    die "Exit $status";
  }

  if ($option{'border'}) {
    png_border($tempfile);
  }
  system('pngtextadd','--keyword=Author','--text=Kevin Ryde',$tempfile) == 0
    or die "system(pngtextadd)";
  system('pngtextadd','--keyword=Generator','--text=Math-PlanePath tools/gallery.pl running math-image',$tempfile) == 0
    or die "system(pngtextadd)";

  $command =~ /--path=([^ ]+)/ or die "Oops no --path in command: $command";
  my $title = $1;
  if ($command =~ /--values=(Fibbinary)/) {
    $title .= " $1";
  }
  system('pngtextadd','--keyword=Title',"--text=$title",$tempfile) == 0
    or die "system(pngtextadd)";

  my $targetfile = "$target_dir/$filename";
  if (File::Compare::compare($tempfile,$targetfile) == 0) {
    print "Unchanged $filename\n";
  } else {
    print "Update $filename\n";
    File::Copy::copy($tempfile,$targetfile);
  }
  if ($filename !~ /small/) {
    $big_bytes += -s $targetfile;
  }
}

foreach my $filename (<*.png>) {
  $filename =~ s{.*/}{};
  if (! $seen_filename{$filename}) {
    print "leftover file: $filename\n";
  }
}


my $gallery_html_filename = "$target_dir/gallery.html";
my $gallery_html_bytes = -s $gallery_html_filename;
my $total_gallery_bytes = $big_bytes + $gallery_html_bytes;

print "total gallery bytes $total_gallery_bytes ($gallery_html_bytes html, $big_bytes \"big\" images)\n";

exit 0;


sub png_border {
  my ($filename) = @_;
  my $image = Image::Base::GD->new(-file => $filename);
  $image->rectangle (0,0,
                     $image->get('-width') - 1,
                     $image->get('-height') - 1,
                     'black');
  $image->save;
}
