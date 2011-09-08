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


# Generate the .png image files shown at
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

my $tempfh_31 = File::Temp->new;
my $tempfilename_31 = $tempfh_31->filename;
foreach (0 .. 31) { print $tempfh_31 "$_\n"; }
close $tempfh_31;

my $tempfh_1023 = File::Temp->new;
my $tempfilename_1023 = $tempfh_1023->filename;
foreach (0 .. 1023) { print $tempfh_1023 "$_\n"; }
close $tempfh_1023;

foreach my $elem
  (
   ['cellular-rule54-small.png',
    'math-image --path=CellularRule54 --all --scale=3 --size=32x32 --png'],
   ['cellular-rule54-big.png',
    'math-image --path=CellularRule54 --all --scale=4 --size=300x150 --png'],

   ['sierpinski-arrowhead-centres-small.png',
    'math-image --path=SierpinskiArrowheadCentres --lines --scale=2 --size=32 --offset=0,1 --png'],
   ['sierpinski-arrowhead-centres-big.png',
    'math-image --path=SierpinskiArrowheadCentres --lines --scale=3 --size=400x200 --png'],

   ['sierpinski-arrowhead-small.png',
    'math-image --path=SierpinskiArrowhead --lines --scale=2 --size=32 --offset=0,1 --png'],
   ['sierpinski-arrowhead-big.png',
    'math-image --path=SierpinskiArrowhead --lines --scale=3 --size=400x200 --png'],

   ['sierpinski-triangle-small.png',
    'math-image --path=SierpinskiTriangle --all --scale=2 --size=32 --offset=0,1 --png'],
   ['sierpinski-triangle-big.png',
    'math-image --path=SierpinskiTriangle --all --scale=3 --size=400x200 --png'],



   ['imaginarybase-small.png',
    'math-image --path=ImaginaryBase --lines --scale=6 --size=32 --png'],
   ['imaginarybase-big.png',
    'math-image --path=ImaginaryBase --lines --scale=16 --size=200 --png'],
   ['imaginarybase-radix5-big.png',
    'math-image --path=ImaginaryBase,radix=5 --lines --scale=16 --size=200 --png'],


   ['quadric-islands-small.png',
    'math-image --path=QuadricIslands --lines --scale=4 --size=32 --png'],
   ['quadric-islands-big.png',
    'math-image --path=QuadricIslands --lines --scale=2 --size=200x200 --png'],

   ['quadric-curve-small.png',
    'math-image --path=QuadricCurve --lines --scale=2 --size=32 --offset=3,0 --png'],
   ['quadric-curve-big.png',
    'math-image --path=QuadricCurve --lines --scale=4 --size=300x200 --offset=3,0 --png'],


   ['flowsnake-3arm-big.png',
    'math-image --path=Flowsnake,arms=4 --lines --scale=6 --size=200x200 --png'],
   ['flowsnake-small.png',
    'math-image --path=Flowsnake --lines --scale=4 --size=32x32 --offset=-5,-13 --png'],
   ['flowsnake-big.png',
    'math-image --path=Flowsnake --lines --scale=8 --size=200x200 --offset=-20,-90 --png'],

   ['flowsnake-centres-small.png',
    'math-image --path=FlowsnakeCentres --lines --scale=4 --size=32x32 --offset=-5,-13 --png'],
   ['flowsnake-centres-big.png',
    'math-image --path=FlowsnakeCentres --lines --scale=8 --size=200x200 --offset=-20,-90 --png'],


   # ['twindragon-small.png',
   #  "math-image --path=TwinDragon --values=File,filename=$tempfilename_31 --scale=2 --size=32x32 --png"],
   # ['twindragon-big.png',
   #  "math-image --path=TwinDragon --values=File,filename=$tempfilename_1023 --scale=2 --size=200x200 --png"],


   # ['zigzag-oct-small.png',
   #  'math-image --path=ZigzagOct --lines --scale=4 --size=32x32 --offset=1,0 --png'],
   # ['zigzag-oct-big.png',
   #  'math-image --path=ZigzagOct --lines --scale=3 --size=250x200 --png'],

   ['triangle-spiral-small.png',
    'math-image --path=TriangleSpiral --lines --scale=3 --size=32x32 --png'],
   ['triangle-spiral-big.png',
    'math-image --path=TriangleSpiral --lines --scale=13 --size=300x150 --png'],

   ['triangle-spiral-skewed-small.png',
    'math-image --path=TriangleSpiralSkewed --lines --scale=3 --size=32x32 --png'],
   ['triangle-spiral-skewed-big.png',
    'math-image --path=TriangleSpiralSkewed --lines --scale=13 --size=150 --png'],

   ['pyramid-rows-small.png',
    'math-image --path=PyramidRows --lines --scale=5 --size=32x32 --png'],
   ['pyramid-rows-big.png',
    'math-image --path=PyramidRows --lines --scale=15 --size=300x150 --png'],

   ['pyramid-sides-small.png',
    'math-image --path=PyramidSides --lines --scale=5 --size=32x32 --png'],
   ['pyramid-sides-big.png',
    'math-image --path=PyramidSides --lines --scale=15 --size=300x150 --png'],

   ['dragon-rounded-small.png',
    'math-image --path=DragonRounded --lines --scale=2 --size=32x32 --offset=6,-3 --png'],
   ['dragon-rounded-big.png',
    'math-image --path=DragonRounded --lines --figure=point --scale=3 --size=200x200 --offset=-20,0 --png'],
   ['dragon-rounded-3arm-big.png',
    'math-image --path=DragonRounded,arms=3 --lines --figure=point --scale=3 --size=200x200 --png'],

   ['dragon-midpoint-small.png',
    'math-image --path=DragonMidpoint --lines --scale=3 --size=32x32 --offset=7,-6 --png'],
   ['dragon-midpoint-big.png',
    'math-image --path=DragonMidpoint --lines --figure=point --scale=8 --size=200x200 --offset=-10,50 --png'],
   ['dragon-midpoint-4arm-big.png',
    'math-image --path=DragonMidpoint,arms=4 --lines --figure=point --scale=8 --size=200x200 --png'],

   ['dragon-small.png',
    'math-image --path=DragonCurve --lines --scale=4 --size=32x32 --offset=6,0 --png'],
   ['dragon-big.png',
    'math-image --path=DragonCurve --lines --figure=point --scale=8 --size=250x200 --offset=-55,0 --png'],


   ['koch-curve-small.png',
    'math-image --path=KochCurve --lines --scale=2 --size=32 --offset=0,8 --png'],
   ['koch-curve-big.png',
    'math-image --path=KochCurve --lines --scale=5 --size=250x100 --offset=0,20 --png'],

   ['koch-snowflakes-small.png',
    'math-image --path=KochSnowflakes --lines --scale=2 --size=32 --png'],
   ['koch-snowflakes-big.png',
    'math-image --path=KochSnowflakes --lines --scale=3 --size=200x150 --png'],

   ['koch-peaks-small.png',
    'math-image --path=KochPeaks --lines --scale=2 --size=32 --png'],
   ['koch-peaks-big.png',
    'math-image --path=KochPeaks --lines --scale=3 --size=200x100 --png'],


   ['gosper-side-small.png',
    'math-image --path=GosperSide --lines --scale=3 --size=32 --offset=-13,-7 --png'],
   ['gosper-side-big.png',
    'math-image --path=GosperSide --lines --scale=1 --size=250x200 --offset=95,-95 --png'],

   ['gosper-islands-small.png',
    'math-image --path=GosperIslands --lines --scale=3 --size=32 --png'],
   ['gosper-islands-big.png',
    'math-image --path=GosperIslands --lines --scale=2 --size=250x200 --png'],


   ['diamond-arms-small.png',
    'math-image --path=DiamondArms --lines --scale=5 --size=32x32 --png'],
   ['diamond-arms-big.png',
    'math-image --path=DiamondArms --lines --scale=15 --size=150x150 --png'],

   ['square-arms-small.png',
    'math-image --path=SquareArms --lines --scale=3 --size=32x32 --png'],
   ['square-arms-big.png',
    'math-image --path=SquareArms --lines --scale=10 --size=150x150 --png'],

   ['zorder-small.png',
    'math-image --path=ZOrderCurve --lines --scale=6 --size=32 --png'],
   ['zorder-big.png',
    'math-image --path=ZOrderCurve --lines --scale=14 --size=226 --png'],
   ['zorder-radix5-big.png',
    'math-image --path=ZOrderCurve,radix=5 --lines --scale=14 --size=226 --png'],

   ['peano-small.png',
    'math-image --path=PeanoCurve --lines --scale=3 --size=32 --png'],
   ['peano-big.png',
    'math-image --path=PeanoCurve --lines --scale=7 --size=192 --png'],
   ['peano-radix7-big.png',
    'math-image --path=PeanoCurve,radix=7 --values=Lines --scale=7 --size=192 --png'],

   ['hex-arms-small.png',
    'math-image --path=HexArms --lines --scale=3 --size=32x32 --png'],
   ['hex-arms-big.png',
    'math-image --path=HexArms --lines --scale=10 --size=300x150 --png'],

   ['hex-small.png',
    'math-image --path=HexSpiral --lines --scale=3 --size=32x32 --png'],
   ['hex-big.png',
    'math-image --path=HexSpiral --lines --scale=13 --size=300x150 --png'],

   ['hex-skewed-small.png',
    'math-image --path=HexSpiralSkewed --lines --scale=3 --size=32x32 --png'],
   ['hex-skewed-big.png',
    'math-image --path=HexSpiralSkewed --lines --scale=13 --size=150 --png'],

   ['hept-skewed-small.png',
    'math-image --path=HeptSpiralSkewed --lines --scale=4 --size=32x32 --png'],
   ['hept-skewed-big.png',
    'math-image --path=HeptSpiralSkewed --lines --scale=13 --size=200x200 --png'],


   ['pent-small.png',
    'math-image --path=PentSpiral --lines --scale=4 --size=32x32 --png'],
   ['pent-big.png',
    'math-image --path=PentSpiral --lines --scale=13 --size=200x200 --png'],

   ['triangular-hypot-small.png',
    'math-image --path=TriangularHypot --lines --scale=4 --size=32 --png'],
   ['triangular-hypot-big.png',
    'math-image --path=TriangularHypot --lines --scale=15 --size=200x150 --png'],

   ['hypot-octant-small.png',
    'math-image --path=HypotOctant --lines --scale=5 --size=32 --png'],
   ['hypot-octant-big.png',
    'math-image --path=HypotOctant --lines --scale=15 --size=200x150 --png'],

   ['hypot-small.png',
    'math-image --path=Hypot --lines --scale=6 --size=32 --png'],
   ['hypot-big.png',
    'math-image --path=Hypot --lines --scale=15 --size=200x150 --png'],

   ['coprime-columns-small.png',
    'math-image --path=CoprimeColumns --all --scale=3 --size=32 --png'],
   ['coprime-columns-big.png',
    'math-image --path=CoprimeColumns --all --scale=3 --size=200x200 --png'],

   ['pythagorean-small.png',
    'math-image --path=PythagoreanTree --values=LinesTree --scale=2 --size=32 --png'],
   ['pythagorean-points-big.png',
    'math-image --path=PythagoreanTree --all --scale=1 --size=200 --png'],
   ['pythagorean-tree-big.png',
    'math-image --path=PythagoreanTree --values=LinesTree --scale=4 --size=200 --png'],

   ['pixel-small.png',
    'math-image --path=PixelRings --lines --scale=4 --size=32 --png'],
   ['pixel-big.png',
    'math-image --path=PixelRings --all --figure=circle --scale=10 --size=200 --png'],

   ['theodorus-small.png',
    'math-image --path=TheodorusSpiral --lines --scale=3 --size=32 --png'],
   ['theodorus-big.png',
    'math-image --path=TheodorusSpiral --lines --scale=10 --size=200 --png'],

   ['greek-key-small.png',
    'math-image --path=GreekKeySpiral --lines --scale=4 --size=32x32 --png'],
   ['greek-key-big.png',
    'math-image --path=GreekKeySpiral --lines --scale=13 --size=200x200 --png'],

   ['square-small.png',
    'math-image --path=SquareSpiral --lines --scale=4 --size=32x32 --png'],
   ['square-big.png',
    'math-image --path=SquareSpiral --lines --scale=13 --size=200x200 --png'],

   ['knight-small.png',
    'math-image --path=KnightSpiral --lines --scale=7 --size=32x32 --png'],
   ['knight-big.png',
    'math-image --path=KnightSpiral --lines --scale=11 --size=197 --png'],

   ['octagram-small.png',
    'math-image --path=OctagramSpiral --lines --scale=4 --size=32x32 --png'],
   ['octagram-big.png',
    'math-image --path=OctagramSpiral --lines --scale=13 --size=200x200 --png'],

   ['multiple-small.png',
    'math-image --path=MultipleRings --lines --scale=4 --size=32 --png'],
   ['multiple-big.png',
    'math-image --path=MultipleRings --lines --scale=10 --size=200 --png'],

   ['vogel-small.png',
    'math-image --vogel --all --scale=3 --size=32x32 --png'],
   ['vogel-big.png',
    'math-image --vogel --all --scale=4 --size=200 --png'],

   ['sacks-small.png',
    'math-image --path=SacksSpiral --lines --scale=5 --size=32x32 --png'],
   ['sacks-big.png',
    'math-image --path=SacksSpiral --lines --scale=10 --size=200x200 --png'],

   ['hilbert-small.png',
    'math-image --path=HilbertCurve --lines --scale=3 --size=32 --png'],
   ['hilbert-big.png',
    'math-image --path=HilbertCurve --lines --scale=7 --size=226 --png'],

   ['archimedean-small.png',
    'math-image --path=ArchimedeanChords --lines --scale=5 --size=32 --png'],
   ['archimedean-big.png',
    'math-image --path=ArchimedeanChords --lines --scale=10 --size=200 --png'],

  ) {
  my ($filename, $command) = @$elem;

  $command .= " >$tempfile";
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
