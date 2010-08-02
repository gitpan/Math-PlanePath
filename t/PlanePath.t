#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

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

use 5.010;
use strict;
use warnings;
use Test::More tests => 164;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

require Math::PlanePath;

my @modules = qw(TheodorusSpiral

                 SquareSpiral
                 DiamondSpiral
                 PentSpiral
                 PentSpiralSkewed
                 HexSpiral
                 HexSpiralSkewed
                 HeptSpiralSkewed
                 PyramidSpiral
                 TriangleSpiral
                 TriangleSpiralSkewed

                 PyramidRows
                 PyramidSides

                 Rows
                 Columns
                 Diagonals
                 Corner

                 SacksSpiral
                 VogelFloret
                 KnightSpiral
               );
my @classes = map {"Math::PlanePath::$_"} @modules;

#------------------------------------------------------------------------------
# VERSION

my $want_version = 6;

is ($Math::PlanePath::VERSION, $want_version, 'VERSION variable');
is (Math::PlanePath->VERSION,  $want_version, 'VERSION class method');

ok (eval { Math::PlanePath->VERSION($want_version); 1 },
    "VERSION class check $want_version");
my $check_version = $want_version + 1000;
ok (! eval { Math::PlanePath->VERSION($check_version); 1 },
    "VERSION class check $check_version");

#------------------------------------------------------------------------------
# new and VERSION

foreach my $class (@classes) {
  use_ok ($class);

  ok (eval { $class->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  ok (! eval { $class->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  my $path = $class->new;
  is ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# n_to_xy, xy_to_n

foreach my $module (@modules) {
  my $class = "Math::PlanePath::$module";
  use_ok ($class);

  my @steps = (-1);
  if ($class eq 'Math::PlanePath::PyramidRows') {
    @steps = (0, 1, 2, 3, 4, 5);
  }

  my @wider = (-1);
  if ($class eq 'Math::PlanePath::SquareSpiral') {
    @wider = (0, 1, 2, 3, 4, 5, 6, 7);
  }

  my ($step, $wider);
  my $good = 1;

  my $report = sub {
    my $name = $module;
    if (defined $step && $step >= 0) {
      $name .= " step=$step";
    }
    if (defined $wider && $wider >= 0) {
      $name .= " wider=$wider";
    }
    diag $name, ' ', @_;
    $good = 0;
  };

  foreach $step (@steps) {
    foreach $wider (@wider) {

      my $path = $class->new (width  => 20,
                              height => 20,
                              step   => $step,
                              wider  => $wider);

      my %saw_n_to_xy;
      my $got_x_negative = 0;
      my $got_y_negative = 0;
      foreach my $n (1 .. 10000) {
        my ($x, $y) = $path->n_to_xy ($n);
        defined $x or &$report("n_to_xy($n) X undef");
        defined $y or &$report("n_to_xy($n) Y undef");

        if ($x < 0) { $got_x_negative = 1; }
        if ($y < 0) { $got_y_negative = 1; }

        foreach my $coord ($x, $y) {
          if (defined $coord) {
            if (int($coord) != $coord) {
              $coord = int ($coord * 10 + .5);
              $coord = $coord.'e-1';
            }
          } else {
            $coord = 'undef';
          }
        }
        my $k = "$x,$y";
        if ($saw_n_to_xy{$k}) {
          &$report ("n_to_xy($n) duplicate k=$k");
        }
        $saw_n_to_xy{$k} = $n;

        my ($limit_lo, $limit_hi) = $path->rect_to_n_range
          (0,0,
           $x + ($x >= 0 ? .4 : -.4),
           $y + ($y >= 0 ? .4 : -.4));
        $limit_lo <= $n
          or &$report ("rect_to_n_range() start n=$n k=$k, got $limit_lo");
        $limit_hi >= $n
          or &$report ("rect_to_n_range() stop n=$n k=$k, got $limit_hi");
        $limit_lo == int($limit_lo)
          or &$report ("rect_to_n_range() start n=$n k=$k, got $limit_lo, integer");
        $limit_hi == int($limit_hi)
          or &$report ("rect_to_n_range() stop n=$n k=$k, got $limit_hi, integer");

        # next if $name eq 'KnightSpiral';
        my $rev_n = $path->xy_to_n ($x,$y);
        defined $rev_n && $n == $rev_n
          or &$report ("xy_to_n() n=$n k=$k got $rev_n");
      }

      # various bogus values only have to return 0 or 2 values and not crash
      foreach my $n (-100, -2, -1, -0.6, -0.5, -0.4,
                     0, 0.4, 0.5, 0.6) {
        my @xy = $path->n_to_xy ($n);
        (@xy == 0 || @xy == 2)
          or &$report ("n_to_xy() n=$n got ",scalar(@xy)," values");
      }

      foreach my $x (-100, -99) {
        my @n = $path->xy_to_n ($x,-1);
        (scalar(@n) == 1)
          or &$report ("xy_to_n($x,-1) array context got ",scalar(@n)," values but should be 1, possibly undef");
      }

      (!!$path->x_negative == !!$got_x_negative)
        or &$report ("x_negative()");
      (!!$path->y_negative == !!$got_y_negative)
        or &$report ("y_negative()");
    }
  }

  ok ($good);
}

exit 0;
