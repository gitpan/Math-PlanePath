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
use List::Util;
use Test::More tests => 254;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Smart::Comments;

require Math::PlanePath;

my @modules = qw(
                  PyramidSides
                  ZOrderCurve
                  Corner
                  Diagonals
                  PyramidRows
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

                  Staircase

                  Rows
                  Columns

                  SacksSpiral
                  TheodorusSpiral
                  KnightSpiral

                  PeanoCurve
                  HilbertCurve
               );
my @classes = map {"Math::PlanePath::$_"} @modules;

#------------------------------------------------------------------------------
# VERSION

my $want_version = 17;

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
                  'Math::PlanePath::PyramidRows' => 1,
                  'Math::PlanePath::PyramidSides' => 1,
                  'Math::PlanePath::Staircase' => 1,
                  'Math::PlanePath::Corner' => 1,
                  'Math::PlanePath::HilbertCurve' => 1,
                  'Math::PlanePath::PeanoCurve' => 1,
                  'Math::PlanePath::ZOrderCurve' => 1,
                 );

# modules for which rect_to_n_range() is exact
my %class_dxdy_allowed
  = ('Math::PlanePath::HilbertCurve' => { '1,0'  => 1,
                                          '-1,0' => 1,
                                          '0,1'  => 1,
                                          '0,-1' => 1,
                                        },
     'Math::PlanePath::PeanoCurve' => { '1,0'  => 1,
                                        '-1,0' => 1,
                                        '0,1'  => 1,
                                        '0,-1' => 1,
                                      },
     'Math::PlanePath::KnightSpiral' => { '1,2'   => 1,
                                          '-1,2'  => 1,
                                          '1,-2'  => 1,
                                          '-1,-2' => 1,
                                          '2,1'   => 1,
                                          '-2,1'  => 1,
                                          '2,-1'  => 1,
                                          '-2,-1' => 1,
                                        },
    );

my ($pos_infinity, $neg_infinity, $nan);
my ($is_infinity, $is_nan);
if (! eval { require Data::Float; 1 }) {
  diag "Data::Float not available";
} elsif (! Data::Float::have_infinite()) {
  diag "Data::Float have_infinite() is false";
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

{
  my $limit = $ENV{'MATH_PLANEPATH_TEST_LIMIT'} || 1000;
  my $rect_limit = $ENV{'MATH_PLANEPATH_TEST_RECT_LIMIT'} || 15;
  diag "test limit $limit, rect limit $rect_limit";

  foreach my $module (@modules) {
    my $class = "Math::PlanePath::$module";
    use_ok ($class);
    my $dxdy_allowed = $class_dxdy_allowed{$class};

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

        if (defined $step) {
          if ($limit < 6*$step) {
            $limit = 6*$step; # so goes into x/y negative
          }
        }

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
          # exit 1;
        };

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

        # undef ok if nothing sensible
        # +/-inf ok
        # nan not intended, but might be ok
        # finite could be a fixed x==0
        if (defined $pos_infinity) {
          my ($x, $y) = $path->n_to_xy($pos_infinity);
          # defined($x) or &$report("n_to_xy($pos_infinity) x is undef");
          # defined($y) or &$report("n_to_xy($pos_infinity) y is undef");
        }
        if (defined $neg_infinity) {
          my ($x, $y) = $path->n_to_xy($neg_infinity);
        }
        # not sure nan input should be allowed
        # if (defined $nan) {
        #   my ($x, $y) = $path->n_to_xy($nan);
        #   &$is_nan($x) or &$report("n_to_xy($nan) x not nan, got ", $x);
        #   &$is_nan($y) or &$report("n_to_xy($nan) y not nan, got ", $y);
        # }

        foreach my $x ($pos_infinity, $neg_infinity, dbl_max(), dbl_max_neg()) {
          next if ! defined $x;
          foreach my $y ($pos_infinity, $neg_infinity) {
            next if ! defined $y;
            my @n = $path->xy_to_n($x,$y);
            scalar(@n) == 1
              or &$report("xy_to_n($x,$y) want 1 value, got ",scalar(@n));
            # my $n = $n[0];
            # &$is_infinity($n) or &$report("xy_to_n($x,$y) n not inf, got ",$n);
          }
        }

        foreach my $x1 ($pos_infinity, $neg_infinity, dbl_max(), dbl_max_neg()) {
          next if ! defined $x1;
          foreach my $x2 ($pos_infinity, $neg_infinity, dbl_max(), dbl_max_neg()) {
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
        my $got_x_negative = 0;
        my $got_y_negative = 0;
        my ($prev_x, $prev_y);
        foreach my $n (1 .. $limit) {
          my ($x, $y) = $path->n_to_xy ($n);
          defined $x or &$report("n_to_xy($n) X undef");
          defined $y or &$report("n_to_xy($n) Y undef");

          if ($x < 0) { $got_x_negative = 1; }
          if ($y < 0) { $got_y_negative = 1; }

          my $k = (int($x) == $x && int($y) == $y
                   ? sprintf('%d,%d', $x,$y)
                   : sprintf('%.3f,%.3f', $x,$y));
          if ($saw_n_to_xy{$k}) {
            &$report ("n_to_xy($n) duplicate k=$k");
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
              or &$report ("rect_to_n_range() lo n=$n k=$k, got $n_lo");
            $n_hi >= $n
              or &$report ("rect_to_n_range() hi n=$n k=$k, got $n_hi");
            $n_lo == int($n_lo)
              or &$report ("rect_to_n_range() lo n=$n k=$k, got $n_lo, integer");
            $n_hi == int($n_hi)
              or &$report ("rect_to_n_range() hi n=$n k=$k, got $n_hi, integer");
          }
          {
            my ($n_lo, $n_hi) = $path->rect_to_n_range ($x,$y, $x,$y);
            ($rect_exact{$class} ? $n_lo == $n : $n_lo <= $n)
              or &$report ("rect_to_n_range() lo n=$n k=$k, got $n_lo");
            ($rect_exact{$class} ? $n_hi == $n : $n_hi >= $n)
              or &$report ("rect_to_n_range() hi n=$n k=$k, got $n_hi");
            $n_lo == int($n_lo)
              or &$report ("rect_to_n_range() lo n=$n k=$k, got $n_lo, integer");
            $n_hi == int($n_hi)
              or &$report ("rect_to_n_range() hi n=$n k=$k, got $n_hi, integer");
          }

          # next if $name eq 'KnightSpiral';

          foreach my $x_offset (0) { # bit slow: , -0.2, 0.2) {
            foreach my $y_offset (0, -0.2) { # bit slow: , 0.2) {
              my $rev_n = $path->xy_to_n ($x + $x_offset, $y + $y_offset);
              ### try xy_to_n from: "step=$step n=$n  xy=$x,$y k=$k  x_offset=$x_offset y_offset=$y_offset"
              ### $rev_n
              unless (defined $rev_n && $n == $rev_n) {
                &$report ("xy_to_n() n=$n k=$k x_offset=$x_offset y_offset=$y_offset got ".(defined $rev_n ? $rev_n : 'undef'));
              }
            }
          }
        }

        # various bogus values only have to return 0 or 2 values and not crash
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
        }

        foreach my $x (-100, -99) {
          my @n = $path->xy_to_n ($x,-1);
          (scalar(@n) == 1)
            or &$report ("xy_to_n($x,-1) array context got ",scalar(@n)," values but should be 1, possibly undef");
        }

        {
          my $path_x_negative = ($path->x_negative ? 1 : 0);
          $got_x_negative = ($got_x_negative ? 1 : 0);
          ($path_x_negative == $got_x_negative)
            or &$report ("x_negative() $path_x_negative but got $got_x_negative");
        }
        {
          my $path_y_negative = ($path->y_negative ? 1 : 0);
          $got_y_negative = ($got_y_negative ? 1 : 0);
          ($path_y_negative == $got_y_negative)
            or &$report ("y_negative() $path_y_negative but got $got_y_negative");
        }

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
                  ### rect: "$x1,$y1  $x2,$y2  expect N=$want_min..$want_max"
                  # ### @col

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

                      if (! defined $min || ! defined $max) {
                        if (! $rect_exact{$class}) {
                          next; # outside
                        }
                      }

                      unless ($rect_exact{$class}
                              ? $got_min == $want_min : $got_min <= $want_min) {
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
                        &$report ("rect_to_n_range() bad min $x1,$y1 $x2,$y2 got $got_min want $want_min".(defined $min ? '' : '[nomin]')
                                 );
                      }
                      unless ($rect_exact{$class}
                              ? $got_max == $want_max : $got_max >= $want_max) {
                        &$report ("rect_to_n_range() bad max $x1,$y1 $x2,$y2 got $got_max want $want_max".(defined $max ? '' : '[nomax]'));
                      }
                    }
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
