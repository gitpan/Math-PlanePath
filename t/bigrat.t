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


# Crib notes:
#
# In perl 5.8.4 "BigInt != BigRat" doesn't work, must have it other way
# around as "BigRat != BigInt".  Symptom is "uninitialized" warnings.
#


use 5.004;
use strict;
use Test;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $test_count = (tests => 251)[1];
plan tests => $test_count;

if (! eval { require Math::BigRat; 1 }) {
  MyTestHelpers::diag ('skip due to Math::BigRat not available -- ',$@);
  foreach (1 .. $test_count) {
    skip ('due to no Math::BigRat', 1, 1);
  }
  exit 0;
}
MyTestHelpers::diag ('Math::BigRat version ', Math::BigRat->VERSION);
{
  my $f = Math::BigRat->new('-1/2');
  my $int = int($f);
  if ($int == 0) {
    MyTestHelpers::diag ('BigRat int(-1/2)==0, good');
  } else {
    MyTestHelpers::diag ("BigRat has int(-1/2) != 0 dodginess: value is '$int'");
  }
}

require Math::BigInt;
MyTestHelpers::diag ('Math::BigInt version ', Math::BigInt->VERSION);
{
  my $n = Math::BigInt->new(2) ** 256;
  my $int = int($n);
  if (! ref $int) {
    MyTestHelpers::diag ('skip due to Math::BigInt no "int" operator');
    foreach (1 .. $test_count) {
      skip ('due to no Math::BigInt int() operator', 1, 1);
    }
    exit 0;
  }
}

# doesn't help sqrt(), slows down blog()
#
# require Math::BigFloat;
# Math::BigFloat->precision(-2000);  # digits right of decimal point


#------------------------------------------------------------------------------
# _round_nearest()

require Math::PlanePath;
ok (Math::PlanePath::_round_nearest(Math::BigRat->new('-7/4')) == -2, 1);
ok (Math::PlanePath::_round_nearest(Math::BigRat->new('-3/2')) == -1,  1);
ok (Math::PlanePath::_round_nearest(Math::BigRat->new('-5/4')) == -1,  1);

ok (Math::PlanePath::_round_nearest(Math::BigRat->new('-3/4')) == -1, 1);
ok (Math::PlanePath::_round_nearest(Math::BigRat->new('-1/2')) == 0,  1);
ok (Math::PlanePath::_round_nearest(Math::BigRat->new('-1/4')) == 0,  1);

ok (Math::PlanePath::_round_nearest(Math::BigRat->new('1/4')) == 0,  1);
ok (Math::PlanePath::_round_nearest(Math::BigRat->new('5/4')) == 1,  1);
ok (Math::PlanePath::_round_nearest(Math::BigRat->new('3/2')) == 2,  1);
ok (Math::PlanePath::_round_nearest(Math::BigRat->new('7/4')) == 2,  1);
ok (Math::PlanePath::_round_nearest(Math::BigRat->new('2'))   == 2,  1);

#------------------------------------------------------------------------------
# _floor()

require Math::PlanePath;
ok (Math::PlanePath::_floor(Math::BigRat->new('-7/4')) == -2,  1);
ok (Math::PlanePath::_floor(Math::BigRat->new('-3/2')) == -2,  1);
ok (Math::PlanePath::_floor(Math::BigRat->new('-5/4')) == -2,  1);

ok (Math::PlanePath::_floor(Math::BigRat->new('-3/4')) == -1,  1);
ok (Math::PlanePath::_floor(Math::BigRat->new('-1/2')) == -1,  1);
ok (Math::PlanePath::_floor(Math::BigRat->new('-1/4')) == -1,  1);

ok (Math::PlanePath::_floor(Math::BigRat->new('1/4')) == 0,  1);
ok (Math::PlanePath::_floor(Math::BigRat->new('3/4')) == 0,  1);
ok (Math::PlanePath::_floor(Math::BigRat->new('5/4')) == 1,  1);
ok (Math::PlanePath::_floor(Math::BigRat->new('3/2')) == 1,  1);
ok (Math::PlanePath::_floor(Math::BigRat->new('7/4')) == 1,  1);
ok (Math::PlanePath::_floor(Math::BigRat->new('2'))   == 2,  1);


#------------------------------------------------------------------------------
# CoprimeColumns

{
  require Math::PlanePath::CoprimeColumns;
  my $path = Math::PlanePath::CoprimeColumns->new;

  {
    my $n = Math::BigRat->new('-2/3');
    my @ret = $path->n_to_xy($n);
    ok (scalar(@ret), 0);
  }
  {
    my $n = Math::BigRat->new(0);
    my $want_x = 1;
    my $want_y = 1;

    my ($got_x,$got_y) = $path->n_to_xy($n);
    ok ($got_x == $want_x, 1, "got $got_x want $want_x");
    ok ($got_y == $want_y);

    my $got_n = $path->xy_to_n($want_x,$want_y);
    ok ($got_n == 0, 1);
  }
  # pending int(-1/2)==0 dodginess
  # {
  #   my $n = Math::BigRat->new('-1/3');
  #   my $want_x = 1;
  #   my $want_y = Math::BigRat->new('1/3');
  # 
  #   my ($got_x,$got_y) = $path->n_to_xy($n);
  #   ok ($got_x == $want_x, 1, "got $got_x want $want_x");
  #   ok ($got_y == $want_y);
  # 
  #   my $got_n = $path->xy_to_n($want_x,$want_y);
  #   ok ($got_n == 0, 1);
  # }
  {
    my $n = Math::BigRat->new('1/2');
    my $want_x = 2;
    my $want_y = Math::BigRat->new('1/2');

    my ($got_x,$got_y) = $path->n_to_xy($n);
    ok ($got_x == $want_x, 1, "got $got_x want $want_x");
    ok ($got_y == $want_y);

    my $got_n = $path->xy_to_n($want_x,$want_y);
    ok ($got_n == 1, 1);
  }
}


#------------------------------------------------------------------------------
# DiagonalRationals

{
  require Math::PlanePath::DiagonalRationals;
  my $path = Math::PlanePath::DiagonalRationals->new;

  {
    my $n = Math::BigRat->new('1/3');
    my @ret = $path->n_to_xy($n);
    ok (scalar(@ret), 0);
  }
  {
    my $n = Math::BigRat->new('1/2');
    my $want_x = Math::BigRat->new('1/2');
    my $want_y = Math::BigRat->new('3/2');

    my ($got_x,$got_y) = $path->n_to_xy($n);
    ok ($got_x == $want_x, 1,
        "DiagonalRationals n_to_xy() from 4/3, X got $got_x want $want_x");
    ok ($got_y == $want_y, 1,
        "DiagonalRationals n_to_xy() from 4/3, Y got $got_y want $want_y");

    my $got_n = $path->xy_to_n($want_x,$want_y);
    ok ($got_n == 1, 1, 'DiagonalRationals xy_to_n($want_x,$want_y) from 1/2');
  }
  {
    my $n = Math::BigRat->new('4/3');
    my $want_x = Math::BigRat->new('4/3');
    my $want_y = Math::BigRat->new('2/3');

    my ($got_x,$got_y) = $path->n_to_xy($n);
    ok ($got_x == $want_x, 1,
        "DiagonalRationals n_to_xy() from 4/3, X got $got_x want $want_x");
    ok ($got_y == $want_y, 1,
        "DiagonalRationals n_to_xy() from 4/3, Y got $got_y want $want_y");

    my $got_n = $path->xy_to_n($want_x,$want_y);
    ok ($got_n == 1, 1, 'DiagonalRationals xy_to_n($want_x,$want_y) from 4/3');
  }
}

#------------------------------------------------------------------------------
# Rows

{
  require Math::PlanePath::Rows;
  my $width = 5;
  my $path = Math::PlanePath::Rows->new (width => $width);

  {
    my $y = Math::BigRat->new(2) ** 128;
    my $x = 4;
    my $n = $y*$width + $x + 1;

    my ($got_x,$got_y) = $path->n_to_xy($n);
    ok ($got_x == $x, 1, "got $got_x want $x");
    ok ($got_y == $y);

    my $got_n = $path->xy_to_n($x,$y);
    ok ($got_n == $n, 1);
  }
  {
    my $n = Math::BigRat->new('4/3');
    my ($got_x,$got_y) = $path->n_to_xy($n);
    ok ("$got_x", '1/3');
    ok ($got_y == 0, 1);
  }
  {
    my $n = Math::BigRat->new('4/3') + 15;
    my ($got_x,$got_y) = $path->n_to_xy($n);
    ok ("$got_x", '1/3');
    ok ($got_y == 3, 1);
  }
  {
    my $n = Math::BigRat->new('4/3') - 15;
    my ($got_x,$got_y) = $path->n_to_xy($n);
    ok ("$got_x", '1/3');
    ok ($got_y == -3, 1);
  }
}

#------------------------------------------------------------------------------
# Diagonals

{
  require Math::PlanePath::Diagonals;
  my $path = Math::PlanePath::Diagonals->new;

  {
    my $x = Math::BigRat->new(2) ** 128 - 1;
    my $n = ($x+1)*($x+2)/2;  # triangular numbers on Y=0 horizontal

    my ($got_x,$got_y) = $path->n_to_xy($n);
    ok ($got_x == $x, 1, "got $got_x want $x");
    ok ($got_y == 0);

    my $got_n = $path->xy_to_n($x,0);
    ok ($got_n == $n, 1);
  }
  {
    my $x = Math::BigRat->new(2) ** 128 - 1;
    my $n = ($x+1)*($x+2)/2;  # Y=0 horizontal

    my ($got_x,$got_y) = $path->n_to_xy($n);
    ok ($got_x == $x, 1);
    ok ($got_y == 0, 1);

    my $got_n = $path->xy_to_n($x,0);
    ok ($got_n == $n, 1);
  }
  {
    my $y = Math::BigRat->new(2) ** 128 - 1;
    my $n = $y*($y+1)/2 + 1;  # X=0 vertical

    my ($got_x,$got_y) = $path->n_to_xy($n);
    ok ($got_x == 0, 1);
    ok ($got_y == $y, 1);
 
    my $got_n = $path->xy_to_n(0,$y);
    ok ($got_n, $n);
  }

  {
    my $n = Math::BigRat->new(-1);
    my ($got_x,$got_y) = $path->n_to_xy($n);
    ok ($got_x, undef);
    ok ($got_y, undef);
  }
  {
    my $n = Math::BigRat->new(0.5);
    my ($got_x,$got_y) = $path->n_to_xy($n);
    ok (!! $got_x->isa('Math::BigRat'), 1);
    ok (!! $got_y->isa('Math::BigRat'), 1);
    ok ($got_x == -0.5, 1);
    ok ($got_y == 0.5, 1);
  }
}

#------------------------------------------------------------------------------
# PeanoCurve

require Math::PlanePath::PeanoCurve;
{
  my $path = Math::PlanePath::PeanoCurve->new;

  require Math::BigRat;
  my $n = Math::BigRat->new(9) ** 128 + Math::BigRat->new('4/3');
  my $want_x = Math::BigRat->new(3) ** 128 + Math::BigRat->new('4/3');
  my $want_y = Math::BigRat->new(3) ** 128 - 1;

  my ($got_x,$got_y) = $path->n_to_xy($n);
  ok ($got_x, $want_x);
  ok ($got_y, $want_y);
}

#------------------------------------------------------------------------------
# ZOrderCurve

require Math::PlanePath::ZOrderCurve;
{
  my $path = Math::PlanePath::ZOrderCurve->new;

  require Math::BigRat;
  my $n = Math::BigRat->new(4) ** 128 + Math::BigRat->new('1/3');
  $n->isa('Math::BigRat') || die "Oops, n not a BigRat";
  my $want_x = Math::BigRat->new(2) ** 128 + Math::BigRat->new('1/3');
  my $want_y = 0;

  my ($got_x,$got_y) = $path->n_to_xy($n);
  ok ($got_x, $want_x);
  ok ($got_y, $want_y);
}

#------------------------------------------------------------------------------
# KochCurve _round_down_pow()

### KochCurve ...
require Math::PlanePath::KochCurve;
{
  my $orig = Math::BigRat->new(3) ** 128 + Math::BigRat->new('1/7');
  my $n    = Math::BigRat->new(3) ** 128 + Math::BigRat->new('1/7');
  my ($pow,$exp) = Math::PlanePath::KochCurve::_round_down_pow($n,3);

  ok ($n, $orig);
  ok ($pow, Math::BigRat->new(3) ** 128);
  ok ($exp, 128);
}
{
  my $orig = Math::BigRat->new(3) ** 128;
  my $n    = Math::BigRat->new(3) ** 128;
  my ($pow,$exp) = Math::PlanePath::KochCurve::_round_down_pow($n,3);
  
  ok ($n, $orig);
  ok ($pow, Math::BigRat->new(3) ** 128);
  ok ($exp, 128);
}

#------------------------------------------------------------------------------

my @modules = (
               'TerdragonMidpoint',
               'TerdragonMidpoint,arms=1',
               'TerdragonMidpoint,arms=2',
               'TerdragonMidpoint,arms=6',

               'TerdragonCurve',
               'TerdragonCurve,arms=1',
               'TerdragonCurve,arms=2',
               'TerdragonCurve,arms=6',

               'OctagramSpiral',
               'AnvilSpiral',
               'AnvilSpiral,wider=1',
               'AnvilSpiral,wider=2',
               'AnvilSpiral,wider=9',
               'AnvilSpiral,wider=17',

               'AR2W2Curve',
               'AR2W2Curve,start_shape=D2',
               'AR2W2Curve,start_shape=B2',
               'AR2W2Curve,start_shape=B1rev',
               'AR2W2Curve,start_shape=D1rev',
               'AR2W2Curve,start_shape=A2rev',
               'BetaOmega',
               'KochelCurve',
               'CincoCurve',

               'HilbertSpiral',
               'HilbertCurve',

               'LTiling',
               'DiagonalsAlternating',
               'MPeaks',   # but not across gap
               'WunderlichMeander',
               'FibonacciWordFractal',
               # 'CornerReplicate',    # not defined yet
               'DigitGroups',
               'PeanoCurve',
               'ZOrderCurve',
               
               'HIndexing',
               'SierpinskiCurve',
               'AztecDiamondRings',     # but not across ring end
               'DiamondArms',
               'SquareArms',
               'HexArms',
               'GreekKeySpiral',
               
               # 'UlamWarburton',         # not really defined yet
               # 'UlamWarburtonQuarter',  # not really defined yet
               'CellularRule54',      # but not across gap
               # 'CellularRule57',           # but not across gap
               # 'CellularRule57,mirror=1',  # but not across gap
               'CellularRule190',     # but not across gap
               'CellularRule190,mirror=1',   # but not across gap
               
               'Rows',
               'Columns',
               
               'SquareSpiral',
               'DiamondSpiral',
               'PentSpiral',
               'PentSpiralSkewed',
               'HexSpiral',
               'HexSpiralSkewed',
               'HeptSpiralSkewed',
               'PyramidSpiral',
               'TriangleSpiral',
               'TriangleSpiralSkewed',
               
               # 'SacksSpiral',         # sin/cos
               # 'TheodorusSpiral',     # counting by N
               # 'ArchimedeanChords',   # counting by N
               # 'VogelFloret',         # sin/cos
               'KnightSpiral',
               
               'SierpinskiArrowheadCentres',
               'SierpinskiArrowhead',
               # 'SierpinskiTriangle',  # not really defined yet
               'QuadricCurve',
               'QuadricIslands',
               
               'AlternatePaper',
               'DragonRounded',
               'DragonMidpoint',
               'DragonCurve',
               
               'KochSquareflakes',
               'KochSnowflakes',
               'KochCurve',
               'KochPeaks',
               
               'FlowsnakeCentres',
               'GosperReplicate',
               'GosperSide',
               'GosperIslands',
               'Flowsnake',
               
               'RationalsTree',
               'FractionsTree',
               # 'DivisibleColumns', # counting by N
               # 'CoprimeColumns',   # counting by N
               # 'DiagonalRationals',# counting by N
               # 'GcdRationals',     # counting by N
               # 'FactorRationals',  # counting by N
               # 'TriangularHypot',  # counting by N
               'PythagoreanTree',
               
               # 'Hypot',            # searching by N
               # 'HypotOctant',      # searching by N
               # 'PixelRings',       # searching by N
               # 'MultipleRings',    # sin/cos, maybe
               
               'QuintetCentres',
               'QuintetCurve',
               'QuintetReplicate',
               
               'SquareReplicate',
               'ComplexPlus',
               'ComplexMinus',
               'ComplexRevolving',
               'ImaginaryBase',
               
               # 'File',  # not applicable
               'Diagonals',
               'Corner',
               'PyramidRows',
               'PyramidSides',
               'Staircase',
               'StaircaseAlternating',
              );
my @classes = map {"Math::PlanePath::$_"} @modules;

sub module_parse {
  my ($mod) = @_;
  my ($class, @parameters) = split /,/, $mod;
  return ("Math::PlanePath::$class",
          map {/(.*?)=(.*)/ or die; ($1 => $2)} @parameters);
}

foreach my $module (@modules) {
  ### $module
  my ($class, %parameters) = module_parse($module);
  eval "require $class" or die;
  
  my $path = $class->new (width => 23,
                          height => 17);
  my $arms = $path->arms_count;
  
  my $n    = Math::BigRat->new(2) ** 256 + 3;
  if ($path->isa('Math::PlanePath::CellularRule190')) {
    $n += 1; # not across gap
  }
  my $frac = Math::BigRat->new('1/3');
  my $n_frac = $frac + $n;
  my $orig = $n_frac->copy;
  
  my ($x1,$y1) = $path->n_to_xy($n);
  ### xy1: "$x1,$y1"
  my ($x2,$y2) = $path->n_to_xy($n+$arms);
  ### xy2: "$x2,$y2"
  
  my $dx = $x2 - $x1;
  my $dy = $y2 - $y1;
  ### dxy: "$dx, $dy"

  my $want_x = $frac * Math::BigRat->new ($dx) + $x1;
  my $want_y = $frac * Math::BigRat->new ($dy) + $y1;

  my ($x_frac,$y_frac) = $path->n_to_xy($n_frac);
  ### xy frac: "$x_frac, $y_frac"

  ok ("$x_frac", "$want_x", "$module arms=$arms X frac");
  ok ("$y_frac", "$want_y", "$module arms=$arms Y frac");
}

exit 0;
