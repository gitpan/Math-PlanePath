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
use warnings;
use Test::More tests => 234;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Smart::Comments;

require Math::PlanePath;

my @modules = qw(
                  MultipleRings
                  VogelFloret

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
                  TheodorusSpiral
                  KnightSpiral

                  ZOrderCurve
                  HilbertCurve
               );
my @classes = map {"Math::PlanePath::$_"} @modules;

#------------------------------------------------------------------------------
# VERSION

my $want_version = 15;

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
# x_negative, y_negative

foreach my $module (@modules) {
  my $class = "Math::PlanePath::$module";
  use_ok ($class);
  my $path = $class->new;
  $path->x_negative;
  $path->y_negative;
  ok (1, 'x_negative(),y_negative() methods run');
}

#------------------------------------------------------------------------------
# n_to_xy, xy_to_n

# modules for which rect_to_n_range() is exact
my %rect_exact = ('Math::PlanePath::Rows' => 1,
                  'Math::PlanePath::Columns' => 1,
                  'Math::PlanePath::Diagonals' => 1,
                  'Math::PlanePath::Corner' => 1,
                  'Math::PlanePath::HilbertCurve' => 1,
                  'Math::PlanePath::ZOrderCurve' => 1,
                 );

{
  my $limit = $ENV{'MATH_PLANEPATH_TEST_LIMIT'} || 1000;
  my $rect_limit = $ENV{'MATH_PLANEPATH_TEST_RECT_LIMIT'} || 15;
  diag "test limit $limit, rect limit $rect_limit";

  foreach my $module (@modules) {
    my $class = "Math::PlanePath::$module";
    use_ok ($class);

    my @steps = (-1);
    if ($class eq 'Math::PlanePath::PyramidRows') {
      @steps = (0, 1, 2, 3, 4, 5);
    } elsif ($class eq 'Math::PlanePath::MultipleRings') {
      @steps = (0, 1, 2, 3, 6, 7, 8, 21);
    }

    my @wider = (0);
    if ($class eq 'Math::PlanePath::SquareSpiral'
        || $class eq 'Math::PlanePath::HexSpiral'
        || $class eq 'Math::PlanePath::HexSpiralSkewed') {
      @wider = (0, 1, 2, 3, 4, 5, 6, 7);
    }

    my $good = 1;

    ## no critic (RequireLexicalLoopIterators)
    foreach my $step (@steps) {
      foreach my $wider (@wider) {
        ### $step
        ### $wider

        my $report = sub {
          my $name = $module;
          if (@steps > 1) {
            $name .= ' step='.(defined $step ? $step : 'undef');
          }
          if (@wider > 1) {
            $name .= ' wider='.(defined $wider ? $wider : 'undef');
          }
          diag $name, ' ', @_;
          $good = 0;
           exit 1;
        };

        my $rw = '';
        if (@wider > 1) {
          $rw = ",wid=$wider ";
        }

        my $path = $class->new (width  => 20,
                                height => 20,
                                step   => $step,
                                wider  => $wider);

        {
          my $saw_warning = 0;
          local $SIG{'__WARN__'} = sub {
            $saw_warning = 1;
          };
          $path->n_to_xy(undef);
          $saw_warning
            or &$report("n_to_xy(undef) doesn't give a warning");
        }

        my %saw_n_to_xy;
        my $got_x_negative = 0;
        my $got_y_negative = 0;
        foreach my $n (1 .. 5000) {
          my ($x, $y) = $path->n_to_xy ($n);
          defined $x or &$report("n_to_xy($n)$rw X undef");
          defined $y or &$report("n_to_xy($n)$rw Y undef");

          if ($x < 0) { $got_x_negative = 1; }
          if ($y < 0) { $got_y_negative = 1; }

          my $k = (int($x) == $x && int($y) == $y
                   ? sprintf('%d,%d', $x,$y)
                   : sprintf('%.3f,%.3f', $x,$y));
          if ($saw_n_to_xy{$k}) {
            &$report ("n_to_xy($n)$rw duplicate k=$k");
          }
          $saw_n_to_xy{$k} = $n;

          {
            my ($limit_lo, $limit_hi) = $path->rect_to_n_range
              (0,0,
               $x + ($x >= 0 ? .4 : -.4),
               $y + ($y >= 0 ? .4 : -.4));
            $limit_lo <= $n
              or &$report ("rect_to_n_range()$rw start n=$n k=$k, got $limit_lo");
            $limit_hi >= $n
              or &$report ("rect_to_n_range()$rw stop n=$n k=$k, got $limit_hi");
            $limit_lo == int($limit_lo)
              or &$report ("rect_to_n_range()$rw start n=$n k=$k, got $limit_lo, integer");
            $limit_hi == int($limit_hi)
              or &$report ("rect_to_n_range()$rw stop n=$n k=$k, got $limit_hi, integer");
          }
          {
            my ($limit_lo, $limit_hi) = $path->rect_to_n_range ($x,$y, $x,$y);
            ($rect_exact{$class} ? $limit_lo == $n : $limit_lo <= $n)
              or &$report ("rect_to_n_range()$rw start n=$n k=$k, got $limit_lo");
            ($rect_exact{$class} ? $limit_hi == $n : $limit_hi >= $n)
              or &$report ("rect_to_n_range()$rw stop n=$n k=$k, got $limit_hi");
            $limit_lo == int($limit_lo)
              or &$report ("rect_to_n_range()$rw start n=$n k=$k, got $limit_lo, integer");
            $limit_hi == int($limit_hi)
              or &$report ("rect_to_n_range()$rw stop n=$n k=$k, got $limit_hi, integer");
          }

          # next if $name eq 'KnightSpiral';

          foreach my $x_offset (0) { # bit slow: , -0.2, 0.2) {
            foreach my $y_offset (0, -0.2) { # bit slow: , 0.2) {
              my $rev_n = $path->xy_to_n ($x + $x_offset, $y + $y_offset);
              ### try xy_to_n from: "step=$step n=$n  xy=$x,$y k=$k  x_offset=$x_offset y_offset=$y_offset"
              ### $rev_n
              unless (defined $rev_n && $n == $rev_n) {
                &$report ("xy_to_n()$rw n=$n k=$k x_offset=$x_offset y_offset=$y_offset got ".(defined $rev_n ? $rev_n : 'undef'));
              }
            }
          }
        }

        # various bogus values only have to return 0 or 2 values and not crash
        foreach my $n (-100, -2, -1, -0.6, -0.5, -0.4,
                       0, 0.4, 0.5, 0.6) {
          my @xy = $path->n_to_xy ($n);
          (@xy == 0 || @xy == 2)
            or &$report ("n_to_xy()$rw n=$n got ",scalar(@xy)," values");
        }

        foreach my $elem ([-1,-1, -1,-1],
                         ) {
          my ($x1,$y1,$x2,$y2) = @$elem;
          my ($got_lo, $got_hi) = $path->rect_to_n_range ($x1,$y1, $x2,$y2);
          (defined $got_lo && defined $got_hi)
            or &$report ("rect_to_n_range()$rw x1=$x1,y1=$y1, x2=$x2,y2=$y2 undefs");
        }

        foreach my $x (-100, -99) {
          my @n = $path->xy_to_n ($x,-1);
          (scalar(@n) == 1)
            or &$report ("xy_to_n($x,-1)$rw array context got ",scalar(@n)," values but should be 1, possibly undef");
        }

        (!!$path->x_negative == !!$got_x_negative)
          or &$report ("x_negative()$rw");
        (!!$path->y_negative == !!$got_y_negative)
          or &$report ("y_negative()$rw");

        if ($path->figure ne 'circle') {
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

          require List::Util;
          foreach my $y1 ($y_min .. $y_max) {
            foreach my $y2 ($y1 .. $y_max) {

              foreach my $x1 ($x_min .. $x_max) {
                my $min;
                my $max;

                foreach my $x2 ($x1 .. $x_max) {
                  my @col = map {$data->{$_}->{$x2}} $y1 .. $y2;
                  $max = List::Util::max (grep {defined} $max, @col);
                  $min = List::Util::min (grep {defined} $min, @col);
                  my $want_min = (defined $min ? $min : 1);
                  my $want_max = (defined $max ? $max : 0);
                  ### rect: "$x1,$y1  $x2,$y2  is N=$want_min..$want_max"
                  # ### @col

                  my ($got_min, $got_max)
                    = $path->rect_to_n_range ($x1,$y1, $x2,$y2);
                  defined $got_min
                    or &$report ("rect_to_n_range()$rw got_min undef");
                  defined $got_max
                    or &$report ("rect_to_n_range()$rw got_max undef");

                  next if ! defined $min || ! defined $max; # outside

                  unless ($rect_exact{$class}
                          ? $got_min == $want_min : $got_min <= $want_min) {
                    &$report ("rect_to_n_range()$rw bad min $x1,$y1 $x2,$y2 got $got_min want $want_min");
                  }
                  unless ($rect_exact{$class}
                          ? $got_max == $want_max : $got_max >= $want_max) {
                    &$report ("rect_to_n_range()$rw bad max $x1,$y1 $x2,$y2 got $got_max want $want_max");
                  }
                }
              }
            }
          }
        }
      }
    }

    ok ($good);
  }
}

exit 0;
