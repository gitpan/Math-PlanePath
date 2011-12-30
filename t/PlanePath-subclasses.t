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

use 5.004;
use strict;
use List::Util;
use Test;
BEGIN { plan tests => 801 }

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Smart::Comments;

require Math::PlanePath;

my @modules = (
               # module list begin

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

               'Staircase',
               'StaircaseAlternating',
               'HilbertSpiral',
               'HilbertCurve',

               'LTiling',
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

               'HIndexing',
               'SierpinskiCurve,diagonal_spacing=5',
               'SierpinskiCurve,straight_spacing=5',
               'SierpinskiCurve,diagonal_spacing=3,straight_spacing=7',
               'SierpinskiCurve',
               'SierpinskiCurve,arms=2',
               'SierpinskiCurve,arms=3',
               'SierpinskiCurve,arms=4',
               'SierpinskiCurve,arms=5',
               'SierpinskiCurve,arms=6',
               'SierpinskiCurve,arms=7',
               'SierpinskiCurve,arms=8',

               'CellularRule190',
               'CellularRule190,mirror=1',

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
               'File',

               'UlamWarburton',
               'UlamWarburtonQuarter',
               'CellularRule54',

               'AztecDiamondRings',
               'DiamondArms',
               'SquareArms',
               'HexArms',
               'GreekKeySpiral',

               'Rows',
               'Columns',

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
               'ComplexMinus',
               'ComplexMinus,realpart=2',
               'ComplexMinus,realpart=3',
               'ComplexMinus,realpart=4',
               'ComplexMinus,realpart=5',
               'ImaginaryBase',
               'ImaginaryBase,radix=3',
               'ImaginaryBase,radix=37',

               'KochSquareflakes',
               'KochSquareflakes,inward=>1',
               'KochSnowflakes',
               'KochCurve',
               'KochPeaks',

               'SierpinskiArrowheadCentres',
               'SierpinskiArrowhead',
               'SierpinskiTriangle',
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

               'PeanoCurve',
               'PeanoCurve,radix=2',
               'PeanoCurve,radix=4',
               'PeanoCurve,radix=5',
               'PeanoCurve,radix=17',

               'ZOrderCurve',
               'ZOrderCurve,radix=3',
               'ZOrderCurve,radix=9',
               'ZOrderCurve,radix=37',

               'OctagramSpiral',
               'Hypot',
               'HypotOctant',
               'PixelRings',
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

               'SacksSpiral',
               'TheodorusSpiral',
               'ArchimedeanChords',
               'VogelFloret',
               'KnightSpiral',

               # module list end
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
      if (! $classes{$module} && $module !~ /^Math::PlanePath::MathImage/) {
        MyTestHelpers::diag ("other module ",$module);
      }
    }
  };
}


#------------------------------------------------------------------------------
# VERSION

my $want_version = 62;

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
      "VERSION class check $want_version");
  ok (! eval { $class->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = $class->new;
  ok ($path->VERSION, $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      1,
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      1,
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# x_negative, y_negative

foreach my $mod (@modules) {
  my $path = module_to_pathobj($mod);
  $path->x_negative;
  $path->y_negative;
  $path->n_start;
  ok (1,1, 'x_negative(),y_negative(),n_start() methods run');
}

#------------------------------------------------------------------------------
# n_to_xy, xy_to_n

my %xy_maximum_duplication =
  ('Math::PlanePath::DragonCurve' => 2,
  );

# modules for which rect_to_n_range() is exact
my %rect_exact = (
                  # rect_to_n_range exact begin
                  'Math::PlanePath::CincoCurve' => 1,
                  'Math::PlanePath::DiagonalsAlternating' => 1,
                  'Math::PlanePath::CornerReplicate' => 1,
                  'Math::PlanePath::Rows' => 1,
                  'Math::PlanePath::Columns' => 1,
                  'Math::PlanePath::Diagonals' => 1,
                  'Math::PlanePath::PyramidRows' => 1,
                  'Math::PlanePath::PyramidSides' => 1,
                  'Math::PlanePath::CellularRule190' => 1,
                  'Math::PlanePath::Staircase' => 1,
                  'Math::PlanePath::Corner' => 1,
                  'Math::PlanePath::HilbertCurve' => 1,
                  'Math::PlanePath::HilbertSpiral' => 1,
                  'Math::PlanePath::PeanoCurve' => 1,
                  'Math::PlanePath::ZOrderCurve' => 1,
                  'Math::PlanePath::Flowsnake' => 1,
                  'Math::PlanePath::FlowsnakeCentres' => 1,
                  'Math::PlanePath::QuintetCurve' => 1,
                  'Math::PlanePath::QuintetCentres' => 1,
                  'Math::PlanePath::AztecDiamondRings' => 1,
                  'Math::PlanePath::BetaOmega' => 1,
                  'Math::PlanePath::AR2W2Curve' => 1,
                  'Math::PlanePath::KochelCurve' => 1,
                  'Math::PlanePath::WunderlichMeander' => 1,
                  'Math::PlanePath::File' => 1,
                  # rect_to_n_range exact end
                 );
my %rect_exact_hi = (%rect_exact,
                     # high is exact but low is not
                     'Math::PlanePath::SquareArms' => 1,
                    );
my %rect_before_n_start = ('Math::PlanePath::Rows' => 1,
                           'Math::PlanePath::Columns' => 1,
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

     'Math::PlanePath::HexSpiral'        => $dxdy_hex,
     'Math::PlanePath::Flowsnake'        => $dxdy_hex,
     'Math::PlanePath::FlowsnakeCentres' => $dxdy_hex,
     'Math::PlanePath::GosperSide'       => $dxdy_hex,

     'Math::PlanePath::KochCurve'   => $dxdy_hex,
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
     'Math::PlanePath::BetaOmega'      => $dxdy_square,
     'Math::PlanePath::AR2W2Curve'     => $dxdy_one,
     'Math::PlanePath::DragonCurve'    => $dxdy_square,
     'Math::PlanePath::DragonMidpoint' => $dxdy_square,
     'Math::PlanePath::DragonRounded'  => $dxdy_one,
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
sub dbl_max {
  require POSIX;
  return POSIX::DBL_MAX();
}
sub dbl_max_neg {
  require POSIX;
  return - POSIX::DBL_MAX();
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
  my $default_limit = $ENV{'MATH_PLANEPATH_TEST_LIMIT'} || 30;
  my $rect_limit = $ENV{'MATH_PLANEPATH_TEST_RECT_LIMIT'} || 4;
  MyTestHelpers::diag ("test limit $default_limit, rect limit $rect_limit");

  foreach my $mod (@modules) {
    my ($class, %parameters) = module_parse($mod);
    eval "require $class" or die;

    my $xy_maximum_duplication = $xy_maximum_duplication{$class} || 0;

    my $good = 1;

    ### $class

    my $dxdy_allowed = $class_dxdy_allowed{$class};
    if ($mod =~ /^PeanoCurve/ && $parameters{'radix'}
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
      MyTestHelpers::diag ($name, ' ', @_);
      $good = 0;
      # exit 1;
    };

    my $path = $class->new (width  => 20,
                            height => 20,
                            %parameters);
    my $n_start = $path->n_start;
    my $got_arms = $path->arms_count;

    if ($parameters{'arms'} && $got_arms != $parameters{'arms'}) {
      &$report("arms_count()==$got_arms expect $parameters{'arms'}");
    }
    unless ($got_arms >= 1) {
      &$report("arms_count()==$got_arms should be >=1");
    }

    {
      my $n_start = $path->n_start;
      { my ($x,$y) = $path->n_to_xy($n_start);
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
      if ($n_start != 0
          # VogelFloret has a secret undocumented return for N=0
          && ! $path->isa('Math::PlanePath::VogelFloret')
          # Rows/Columns secret undocumented extend into negatives ...
          && ! $path->isa('Math::PlanePath::Rows')
          && ! $path->isa('Math::PlanePath::Columns')) {
        my $n = $n_start - 1;
        my ($x,$y) = $path->n_to_xy($n);
        if (defined $x) {
          &$report("n_start()-1==$n has an n_to_xy() but should not");
        }
      }
    }

    {
      my $saw_warning = 0;
      local $SIG{'__WARN__'} = sub { $saw_warning = 1; };
      $path->n_to_xy(undef);
      $saw_warning or &$report("n_to_xy(undef) doesn't give a warning");
    }

    # undef ok if nothing sensible
    # +/-inf ok
    # nan not intended, but might be ok
    # finite could be a fixed x==0
    if (defined $pos_infinity) {
      ### n_to_xy pos_infinity
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
      ($x==$pos_infinity || $x==$neg_infinity || &$is_nan($x))
        or &$report("n_to_xy($pos_infinity) x is $x");
      ($y==$pos_infinity || $y==$neg_infinity || &$is_nan($y))
        or &$report("n_to_xy($pos_infinity) y is $y");
    }

    if (defined $neg_infinity) {
      ### n_to_xy() on $neg_infinity
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

    # nan input documented loosely as yet ...
    if (defined $nan) {
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

    foreach my $x
      ($pos_infinity, $neg_infinity,

       # no DBL_MAX on these
       ($path->isa('Math::PlanePath::CoprimeColumns')
        || $path->isa('Math::PlanePath::DiagonalRationals')
        || $path->isa('Math::PlanePath::DivisibleColumns')
        ? (dbl_max_neg())
        : (dbl_max(), dbl_max_neg()))) {

      next if ! defined $x;
      foreach my $y ($pos_infinity, $neg_infinity) {
        next if ! defined $y;
        ### xy_to_n: $x, $y
        my @n = $path->xy_to_n($x,$y);
        scalar(@n) == 1
          or &$report("xy_to_n($x,$y) want 1 value, got ",scalar(@n));
        # my $n = $n[0];
        # &$is_infinity($n) or &$report("xy_to_n($x,$y) n not inf, got ",$n);
      }
    }

    foreach my $x1
      ($pos_infinity, $neg_infinity,

       # no DBL_MAX on these
       ($path->isa('Math::PlanePath::CoprimeColumns')
        || $path->isa('Math::PlanePath::DiagonalRationals')
        || $path->isa('Math::PlanePath::DivisibleColumns')
        ? (dbl_max_neg())
        : (dbl_max(), dbl_max_neg()))) {
      next if ! defined $x1;

      foreach my $x2
        ($pos_infinity, $neg_infinity,

         # no DBL_MAX on these
         ($path->isa('Math::PlanePath::CoprimeColumns')
          || $path->isa('Math::PlanePath::DiagonalRationals')
          || $path->isa('Math::PlanePath::DivisibleColumns')
          ? (dbl_max_neg())
          : (dbl_max(), dbl_max_neg()))) {
        next if ! defined $x2;

        foreach my $y1 ($pos_infinity, $neg_infinity) {
          next if ! defined $y1;

          foreach my $y2 ($pos_infinity, $neg_infinity) {
            next if ! defined $y2;

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
    foreach my $n (1 .. $limit) {
      my ($x, $y) = $path->n_to_xy ($n)
        or next;
      defined $x or &$report("n_to_xy($n) X undef");
      defined $y or &$report("n_to_xy($n) Y undef");

      if ($x < 0) { $got_x_negative = 1; }
      if ($y < 0) { $got_y_negative = 1; }

      my $k = (int($x) == $x && int($y) == $y
               ? sprintf('%d,%d', $x,$y)
               : sprintf('%.3f,%.3f', $x,$y));
      if ($count_n_to_xy{$k}++ > $xy_maximum_duplication) {
        &$report ("n_to_xy($n) duplicate$count_n_to_xy{$k} xy=$k prev n=$saw_n_to_xy{$k}");
      }
      $saw_n_to_xy{$k} = $n;

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
          or &$report ("rect_to_n_range() lo n=$n xy=$k, got $n_lo");
        $n_hi >= $n
          or &$report ("rect_to_n_range() hi n=$n xy=$k, got $n_hi");
        $n_lo == int($n_lo)
          or &$report ("rect_to_n_range() lo n=$n xy=$k, got $n_lo, integer");
        $n_hi == int($n_hi)
          or &$report ("rect_to_n_range() hi n=$n xy=$k, got $n_hi, integer");
        $n_lo >= $n_start
          or &$report ("rect_to_n_range(0,0,$x,$y)+.4 n_lo=$n_lo is before n_start=$n_start");
      }
      {
        my ($n_lo, $n_hi) = $path->rect_to_n_range ($x,$y, $x,$y);
        ($rect_exact{$class} ? $n_lo == $n : $n_lo <= $n)
          or &$report ("rect_to_n_range() lo n=$n xy=$k, got $n_lo");
        ($rect_exact_hi{$class} ? $n_hi == $n : $n_hi >= $n)
          or &$report ("rect_to_n_range() hi n=$n xy=$k, got $n_hi");
        $n_lo == int($n_lo)
          or &$report ("rect_to_n_range() lo n=$n xy=$k, got n_lo=$n_lo, should be an integer");
        $n_hi == int($n_hi)
          or &$report ("rect_to_n_range() hi n=$n xy=$k, got n_hi=$n_hi, should be an integer");
        $n_lo >= $n_start
          or &$report ("rect_to_n_range() n_lo=$n_lo is before n_start=$n_start");
      }

      unless ($xy_maximum_duplication > 0) {
        foreach my $x_offset (0) { # bit slow: , -0.2, 0.2) {
          foreach my $y_offset (0, +0.2) { # bit slow: , -0.2) {
            my $rev_n = $path->xy_to_n ($x + $x_offset, $y + $y_offset);
            ### try xy_to_n from: "n=$n  xy=$x,$y xy=$k  x_offset=$x_offset y_offset=$y_offset"
            ### $rev_n
            unless (defined $rev_n && $n == $rev_n) {
              &$report ("xy_to_n() rev n=$n xy=$k x_offset=$x_offset y_offset=$y_offset got ".(defined $rev_n ? $rev_n : 'undef'));
              pythagorean_diag($path,$x,$y);
            }
          }
        }
      }
    }


    ### various bogus values only have to return 0 or 2 values and not crash ...
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
      $got_lo >= $n_start
        or &$report ("rect_to_n_range() got_lo=$got_lo is before n_start=$n_start");
    }

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
          || $mod eq 'GreekKeySpiral',
         ) {
        # these don't get to X negative in small rectangle
        $got_x_negative = 1;
      }

      ($path_x_negative == $got_x_negative)
        or &$report ("x_negative() $path_x_negative but in rect got $got_x_negative");
    }
    {
      my $path_y_negative = ($path->y_negative ? 1 : 0);
      $got_y_negative = ($got_y_negative ? 1 : 0);

      if ($path->isa('Math::PlanePath::GosperSide')
          || $path->isa('Math::PlanePath::FlowsnakeCentres')
          || $path->isa('Math::PlanePath::GreekKeySpiral')
          || $path->isa('Math::PlanePath::ComplexMinus')
          || $mod eq 'SquareSpiral,wider=37'
          || $mod eq 'HexSpiral,wider=37'
          || $mod eq 'HexSpiralSkewed,wider=37'
          || $mod eq 'ImaginaryBase,radix=37'
          || $mod eq 'ComplexMinus,realpart=5'
         ) {
        # GosperSide and Flowsnake take a long time to get
        # to Y negative, not reached by the rectangle
        # considered here.  ComplexMinus doesn't get there
        # on realpart==5 or bigger too.
        $got_y_negative = 1;
      }

      ($path_y_negative == $got_y_negative)
        or &$report ("y_negative() $path_y_negative but in rect got $got_y_negative");
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
                    or &$report ("rect_to_n_range() got_min undef");
                  defined $got_max
                    or &$report ("rect_to_n_range() got_max undef");
                  $got_min >= $n_start
                    or $rect_before_n_start{$class}
                      or &$report ("rect_to_n_range() got_min=$got_min is before n_start=$n_start");

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
                    &$report ("rect_to_n_range() bad min $x1,$y1 $x2,$y2 got_min=$got_min want_min=$want_min".(defined $min ? '' : '[nomin]')
                             );
                  }
                  unless ($rect_exact_hi{$class}
                          ? $got_max == $want_max
                          : $got_max >= $want_max) {
                    &$report ("rect_to_n_range() bad max $x1,$y1 $x2,$y2 got $got_max want $want_max".(defined $max ? '' : '[nomax]'));
                  }
                }
              }
            }
          }
        }
      }
    }
    ok ($good, 1, "exercise $class");
  }
}

exit 0;
