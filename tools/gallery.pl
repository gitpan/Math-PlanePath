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


# Usage: perl gallery.pl
#
# Creates .png files in $target_dir = "$ENV{HOME}/tux/web/math-planepath"
# which are as shown at
#
#   http://user42.tuxfamily.org/math-planepath/gallery.html
#

use 5.004;
use strict;
use warnings;
use File::Compare ();
use File::Copy;
use File::Temp;

# uncomment this to run the ### lines
#use Devel::Comments;

my $target_dir = "$ENV{HOME}/tux/web/math-planepath";
my $tempfh = File::Temp->new (SUFFIX => '.png');
my $tempfile = $tempfh->filename;
my $big_bytes = 0;
my %seen_filename;

foreach my $elem
  (
   ['l-tiling-small.png',
    'math-image --path=LTiling --all --scale=2 --size=32'],
   ['l-tiling-big.png',
    'math-image --path=LTiling --all --scale=10 --size=200'],
   ['l-tiling-ends-big.png',
    'math-image --path=LTiling,L_fill=ends --all --scale=10 --size=200'],
   ['l-tiling-all-big.png',
    'math-image --path=LTiling,L_fill=all --lines --scale=10 --size=200'],

   ['diagonals-alternating-small.png',
    'math-image --path=DiagonalsAlternating --lines --scale=6 --size=32'],
   ['diagonals-alternating-big.png',
    'math-image --path=DiagonalsAlternating --lines --scale=15 --size=200'],

   ['diagonals-small.png',
    'math-image --path=Diagonals --lines --scale=6 --size=32'],
   ['diagonals-big.png',
    'math-image --path=Diagonals --lines --scale=15 --size=200'],

   ['corner-small.png',
    'math-image --path=Corner --lines --scale=4 --size=32'],
   ['corner-big.png',
    'math-image --path=Corner --lines --scale=12 --size=200'],
   ['corner-wider4-big.png',
    'math-image --path=Corner,wider=4 --lines --scale=12 --size=200'],


   ['cinco-small.png',
    'math-image --path=CincoCurve --lines --scale=4 --size=32'],
   ['cinco-big.png',
    'math-image --path=CincoCurve --lines --scale=7 --size=192'],

   ['kochel-small.png',
    'math-image --path=KochelCurve --lines --scale=4 --size=32'],
   ['kochel-big.png',
    'math-image --path=KochelCurve --lines --scale=7 --size=192'],

   ['wunderlich-meander-small.png',
    'math-image --path=WunderlichMeander --lines --scale=4 --size=32'],
   ['wunderlich-meander-big.png',
    'math-image --path=WunderlichMeander --lines --scale=7 --size=192'],

   ['beta-omega-small.png',
    'math-image --path=BetaOmega --lines --scale=4 --size=32'],
   ['beta-omega-big.png',
    'math-image --path=BetaOmega --lines --scale=7 --size=226'],

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


   ['zorder-small.png',
    'math-image --path=ZOrderCurve --lines --scale=6 --size=32'],
   ['zorder-big.png',
    'math-image --path=ZOrderCurve --lines --scale=14 --size=226'],
   ['zorder-radix5-big.png',
    'math-image --path=ZOrderCurve,radix=5 --lines --scale=14 --size=226'],
   ['zorder-fibbinary.png',
    'math-image --path=ZOrderCurve --values=Fibbinary --scale=1 --size=704x320'],


   ['peano-small.png',
    'math-image --path=PeanoCurve --lines --scale=3 --size=32'],
   ['peano-big.png',
    'math-image --path=PeanoCurve --lines --scale=7 --size=192'],
   ['peano-radix7-big.png',
    'math-image --path=PeanoCurve,radix=7 --values=Lines --scale=7 --size=192'],


   ['fibonacci-word-fractal-small.png',
    'math-image --path=FibonacciWordFractal --lines --scale=2 --size=32 --offset=2,2'],
   ['fibonacci-word-fractal-big.png',
    'math-image --path=FibonacciWordFractal --lines --scale=2 --size=345x170 --offset=2,2'],

   ['corner-replicate-small.png',
    'math-image --path=CornerReplicate --lines --scale=4 --size=32'],
   ['corner-replicate-big.png',
    'math-image --path=CornerReplicate --lines --scale=10 --size=200'],

   ['digit-groups-small.png',
    "math-image --path=DigitGroups --expression='i<255?i:0' --scale=2 --size=32"],
   #  --foreground=red
   ['digit-groups-big.png',
    "math-image --path=DigitGroups --expression='i<2047?i:0' --scale=3 --size=200"],
   ['digit-groups-radix5-big.png',
    "math-image --path=DigitGroups,radix=5 --expression='i<15624?i:0' --scale=3 --size=200"],

   ['h-indexing-small.png',
    'math-image --path=HIndexing --scale=3 --size=32 --lines --offset=2,2'],
   ['h-indexing-big.png',
    'math-image --path=HIndexing --lines --scale=3 --size=200 --offset=2,2'],

   ['sierpinski-curve-small.png',
    'math-image --path=SierpinskiCurve,arms=2 --scale=3 --size=32 --lines --offset=2,2'],
   ['sierpinski-curve-big.png',
    'math-image --path=SierpinskiCurve --lines --scale=3 --size=200'],
   ['sierpinski-curve-8arm-big.png',
    'math-image --path=SierpinskiCurve,arms=8 --lines --scale=3 --size=200'],


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



   ['divisible-columns-small.png',
    'math-image --path=DivisibleColumns --all --scale=3 --size=32'],
   ['divisible-columns-big.png',
    'math-image --path=DivisibleColumns --all --scale=3 --size=200'],
   ['divisible-columns-proper-big.png',
    'math-image --path=DivisibleColumns,divisor_type=proper --all --scale=3 --size=200'],

   ['coprime-columns-small.png',
    'math-image --path=CoprimeColumns --all --scale=3 --size=32'],
   ['coprime-columns-big.png',
    'math-image --path=CoprimeColumns --all --scale=3 --size=200'],


   ['sierpinski-arrowhead-centres-small.png',
    'math-image --path=SierpinskiArrowheadCentres --lines --scale=2 --size=32 --offset=0,1'],
   ['sierpinski-arrowhead-centres-big.png',
    'math-image --path=SierpinskiArrowheadCentres --lines --scale=3 --size=400x200'],

   ['sierpinski-arrowhead-small.png',
    'math-image --path=SierpinskiArrowhead --lines --scale=2 --size=32 --offset=0,1'],
   ['sierpinski-arrowhead-big.png',
    'math-image --path=SierpinskiArrowhead --lines --scale=3 --size=400x200'],

   ['sierpinski-triangle-small.png',
    'math-image --path=SierpinskiTriangle --all --scale=2 --size=32 --offset=0,1'],
   ['sierpinski-triangle-big.png',
    'math-image --path=SierpinskiTriangle --all --scale=3 --size=400x200'],


   ['ulam-warburton-quarter-small.png',
    "math-image --path=UlamWarburtonQuarter --expression='i<50?i:0' --scale=2 --size=32"],
   ['ulam-warburton-quarter-big.png',
    "math-image --path=UlamWarburtonQuarter --expression='i<233?i:0' --scale=4 --size=150"],

   ['ulam-warburton-small.png',
    "math-image --path=UlamWarburton --expression='i<50?i:0' --scale=2 --size=32"],
   ['ulam-warburton-big.png',
    "math-image --path=UlamWarburton --expression='i<233?i:0' --scale=4 --size=150"],


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

   ['imaginarybase-small.png',
    'math-image --path=ImaginaryBase --lines --scale=6 --size=32'],
   ['imaginarybase-big.png',
    'math-image --path=ImaginaryBase --lines --scale=16 --size=200'],
   ['imaginarybase-radix5-big.png',
    'math-image --path=ImaginaryBase,radix=5 --lines --scale=16 --size=200'],


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


   ['vogel-small.png',
    'math-image --vogel --all --scale=3 --size=32'],
   ['vogel-big.png',
    'math-image --vogel --all --scale=4 --size=200'],
   ['vogel-sqrt5-big.png',
    'math-image --path=VogelFloret,rotation_type=sqrt5 --all --scale=4 --size=200'],


   ['square-small.png',
    'math-image --path=SquareSpiral --lines --scale=4 --size=32'],
   ['square-big.png',
    'math-image --path=SquareSpiral --lines --scale=13 --size=200'],
   ['square-wider4-big.png',
    'math-image --path=SquareSpiral,wider=4 --lines --scale=13 --size=253x200'],


   ['complexminus-small.png',
    "math-image --path=ComplexMinus --expression='i<31?i:0' --scale=2 --size=32"],
   ['complexminus-big.png',
    "math-image --path=ComplexMinus --expression='i<1023?i:0' --scale=3 --size=200"],

   ['complexminus-r2-small.png',
    "math-image --path=ComplexMinus,realpart=2 --expression='i<124?i:0' --scale=2 --size=32"],
   ['complexminus-r2-big.png',
    "math-image --path=ComplexMinus,realpart=2 --expression='i<3124?i:0' --scale=1 --size=200"],


   ['pixel-small.png',
    'math-image --path=PixelRings --lines --scale=4 --size=32'],
   ['pixel-big.png',
    'math-image --path=PixelRings --all --figure=circle --scale=10 --size=200'],
   ['pixel-lines-big.png',
    'math-image --path=PixelRings --lines --scale=10 --size=200'],

   ['quintet-replicate-small.png',
    "math-image --path=QuintetReplicate --expression='i<124?i:0' --scale=2 --size=32"],
   ['quintet-replicate-big.png',
    "math-image --path=QuintetReplicate --expression='i<3124?i:0' --scale=2 --size=200"],

   ['quintet-curve-small.png',
    'math-image --path=QuintetCurve --lines --scale=4 --size=32 --offset=-10,0'],
   ['quintet-curve-big.png',
    'math-image --path=QuintetCurve --lines --scale=7 --size=200 --offset=-20,-70'],
   ['quintet-curve-4arm-big.png',
    'math-image --path=QuintetCurve,arms=4 --lines --scale=7 --size=200'],

   ['quintet-centres-small.png',
    'math-image --path=QuintetCentres --lines --scale=4 --size=32 --offset=-10,0'],
   ['quintet-centres-big.png',
    'math-image --path=QuintetCentres --lines --scale=7 --size=200 --offset=-20,-70'],


   ['rationals-tree-lines-drib.png',
    'math-image --path=RationalsTree,tree_type=Drib --values=LinesTree,branches=2 --scale=20 --size=200'],
   ['rationals-tree-lines-sb.png',
    'math-image --path=RationalsTree,tree_type=SB --values=LinesTree,branches=2 --scale=20 --size=200'],
   ['rationals-tree-lines-cw.png',
    'math-image --path=RationalsTree,tree_type=CW --values=LinesTree,branches=2 --scale=20 --size=200'],
   ['rationals-tree-lines-ayt.png',
    'math-image --path=RationalsTree,tree_type=AYT --values=LinesTree,branches=2 --scale=20 --size=200'],
   ['rationals-tree-lines-bird.png',
    'math-image --path=RationalsTree,tree_type=Bird --values=LinesTree,branches=2 --scale=20 --size=200'],
   ['rationals-tree-small.png',
    'math-image --path=RationalsTree --all --scale=3 --size=32'],
   ['rationals-tree-big.png',
    'math-image --path=RationalsTree --all --scale=3 --size=200'],

   ['pythagorean-small.png',
    'math-image --path=PythagoreanTree --values=LinesTree --scale=2 --size=32'],
   ['pythagorean-points-big.png',
    'math-image --path=PythagoreanTree --all --scale=1 --size=200'],
   ['pythagorean-tree-big.png',
    'math-image --path=PythagoreanTree --values=LinesTree --scale=4 --size=200'],

   ['koch-squareflakes-inward-small.png',
    'math-image --path=KochSquareflakes,inward=1 --lines --scale=2 --size=32'],
   ['koch-squareflakes-inward-big.png',
    'math-image --path=KochSquareflakes,inward=1 --lines --scale=2 --size=150x150'],

   ['koch-squareflakes-small.png',
    'math-image --path=KochSquareflakes --lines --scale=1 --size=32'],
   ['koch-squareflakes-big.png',
    'math-image --path=KochSquareflakes --lines --scale=2 --size=150x150'],

   ['koch-curve-small.png',
    'math-image --path=KochCurve --lines --scale=2 --size=32 --offset=0,8'],
   ['koch-curve-big.png',
    'math-image --path=KochCurve --lines --scale=5 --size=250x100 --offset=0,20'],

   ['koch-snowflakes-small.png',
    'math-image --path=KochSnowflakes --lines --scale=2 --size=32'],
   ['koch-snowflakes-big.png',
    'math-image --path=KochSnowflakes --lines --scale=3 --size=200x150'],

   ['koch-peaks-small.png',
    'math-image --path=KochPeaks --lines --scale=2 --size=32'],
   ['koch-peaks-big.png',
    'math-image --path=KochPeaks --lines --scale=3 --size=200x100'],


   ['quadric-islands-small.png',
    'math-image --path=QuadricIslands --lines --scale=4 --size=32'],
   ['quadric-islands-big.png',
    'math-image --path=QuadricIslands --lines --scale=2 --size=200'],

   ['quadric-curve-small.png',
    'math-image --path=QuadricCurve --lines --scale=2 --size=32 --offset=3,0'],
   ['quadric-curve-big.png',
    'math-image --path=QuadricCurve --lines --scale=4 --size=300x200 --offset=3,0'],


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

   ['pyramid-rows-small.png',
    'math-image --path=PyramidRows --lines --scale=5 --size=32'],
   ['pyramid-rows-big.png',
    'math-image --path=PyramidRows --lines --scale=15 --size=300x150'],

   ['pyramid-sides-small.png',
    'math-image --path=PyramidSides --lines --scale=5 --size=32'],
   ['pyramid-sides-big.png',
    'math-image --path=PyramidSides --lines --scale=15 --size=300x150'],

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

   ['triangular-hypot-small.png',
    'math-image --path=TriangularHypot --lines --scale=4 --size=32'],
   ['triangular-hypot-big.png',
    'math-image --path=TriangularHypot --lines --scale=15 --size=200x150'],

   ['hypot-octant-small.png',
    'math-image --path=HypotOctant --lines --scale=5 --size=32'],
   ['hypot-octant-big.png',
    'math-image --path=HypotOctant --lines --scale=15 --size=200x150'],

   ['hypot-small.png',
    'math-image --path=Hypot --lines --scale=6 --size=32'],
   ['hypot-big.png',
    'math-image --path=Hypot --lines --scale=15 --size=200x150'],

   ['theodorus-small.png',
    'math-image --path=TheodorusSpiral --lines --scale=3 --size=32'],
   ['theodorus-big.png',
    'math-image --path=TheodorusSpiral --lines --scale=10 --size=200'],

   ['greek-key-small.png',
    'math-image --path=GreekKeySpiral --lines --scale=4 --size=32'],
   ['greek-key-big.png',
    'math-image --path=GreekKeySpiral --lines --scale=13 --size=200'],

   ['knight-small.png',
    'math-image --path=KnightSpiral --lines --scale=7 --size=32'],
   ['knight-big.png',
    'math-image --path=KnightSpiral --lines --scale=11 --size=197'],

   ['octagram-small.png',
    'math-image --path=OctagramSpiral --lines --scale=4 --size=32'],
   ['octagram-big.png',
    'math-image --path=OctagramSpiral --lines --scale=13 --size=200'],

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
  my ($filename, $command) = @$elem;

  if ($seen_filename{$filename}++) {
    die "Duplicate filename $filename";
  }

  $command .= " --png >$tempfile";
  ### $command
  my $status = system $command;
  if ($status) {
    die "Exit $status";
  }

  system('pngtextadd','--keyword=Author','--text=Kevin Ryde',$tempfile) == 0
    or die "system()";
  system('pngtextadd','--keyword=Generator','--text=gallery.pl and math-image',$tempfile) == 0
    or die "system()";

  my $targetfile = "$target_dir/$filename";
  if (File::Compare::compare($tempfile,$targetfile) == 0) {
    print "Unchanged $filename\n";
  } else {
    print "Update $filename\n";
    File::Copy::move($tempfile,$targetfile);
  }
  if ($filename =~ /big/) {
    $big_bytes += -s $targetfile;
  }
}

my $gallery_html_filename = "$target_dir/gallery.html";
my $gallery_html_bytes = -s $gallery_html_filename;
my $total_gallery_bytes = $big_bytes + $gallery_html_bytes;

print "total gallery bytes $total_gallery_bytes ($gallery_html_bytes html, $big_bytes \"big\" images)\n";

exit 0;
