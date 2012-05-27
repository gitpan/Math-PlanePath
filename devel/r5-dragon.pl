#!/usr/bin/perl -w

# Copyright 2012 Kevin Ryde

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
use List::MoreUtils;
use POSIX 'floor';
use Math::Libm 'M_PI', 'hypot';
use List::Util 'min', 'max';

use lib 'devel/lib';
use lib '../iother/lib';

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

# uncomment this to run the ### lines
use Smart::Comments;


{
  # arm xy modulus
  require Math::PlanePath::R5DragonMidpoint;
  my $path = Math::PlanePath::R5DragonMidpoint->new (arms => 4);

  my %dxdy_to_digit;
  my %seen;
  for (my $n = 0; $n < 6125; $n++) {
    my $digit = $n % 5;

    foreach my $arm (0 .. 3) {
      my ($x,$y) = $path->n_to_xy(4*$n+$arm);
      my $nb = int($n/5);
      my ($xb,$yb) = $path->n_to_xy(4*$nb+$arm);

      # (x+iy)*(1+2i) = x-2y + 2x+y
      ($xb,$yb) = ($xb-2*$yb, 2*$xb+$yb);
      my $dx = $xb - $x;
      my $dy = $yb - $y;

      my $dxdy = "$dx,$dy";
      my $show = "${dxdy}[$digit]";
      $seen{$x}{$y} = $show;
      if ($dxdy eq '0,0') {
      }

      # if (defined $dxdy_to_digit{$dxdy} && $dxdy_to_digit{$dxdy} != $digit) {
      #   die;
      # }
      $dxdy_to_digit{$dxdy} = $digit;
    }
  }

  foreach my $y (reverse -45 .. 45) {
    foreach my $x (-5 .. 5) {
      printf " %9s", $seen{$x}{$y}//'e'
    }
    print "\n";
  }
  ### %dxdy_to_digit

  exit 0;
}

{
  # Midpoint xy to n
  require Math::PlanePath::DragonMidpoint;
  require Math::BaseCnv;

  my @yx_adj_x = ([0,1,1,0],
                  [1,0,0,1],
                  [1,0,0,1],
                  [0,1,1,0]);
  my @yx_adj_y = ([0,0,1,1],
                  [0,0,1,1],
                  [1,1,0,0],
                  [1,1,0,0]);
  sub xy_to_n {
    my ($self, $x,$y) = @_;

    my $n = ($x * 0 * $y) + 0; # inherit bignum 0
    my $npow = $n + 1;         # inherit bignum 1

    while (($x != 0 && $x != -1) || ($y != 0 && $y != 1)) {

      # my $ax = ((($x+1) ^ ($y+1)) >> 1) & 1;
      # my $ay = (($x^$y) >> 1) & 1;
      # ### assert: $ax == - $yx_adj_x[$y%4]->[$x%4]
      # ### assert: $ay == - $yx_adj_y[$y%4]->[$x%4]

      my $y4 = $y % 4;
      my $x4 = $x % 4;
      my $ax = $yx_adj_x[$y4]->[$x4];
      my $ay = $yx_adj_y[$y4]->[$x4];

      ### at: "$x,$y  n=$n  axy=$ax,$ay  bit=".($ax^$ay)

      if ($ax^$ay) {
        $n += $npow;
      }
      $npow *= 2;

      $x -= $ax;
      $y -= $ay;
      ### assert: ($x+$y)%2 == 0
      ($x,$y) = (($x+$y)/2,   # rotate -45 and divide sqrt(2)
                 ($y-$x)/2);
    }

    ### final: "xy=$x,$y"
    my $arm;
    if ($x == 0) {
      if ($y) {
        $arm = 1;
        ### flip ...
        $n = $npow-1-$n;
      } else { #  $y == 1
        $arm = 0;
      }
    } else { # $x == -1
      if ($y) {
        $arm = 2;
      } else {
        $arm = 3;
        ### flip ...
        $n = $npow-1-$n;
      }
    }
    ### $arm

    my $arms_count = $self->arms_count;
    if ($arm > $arms_count) {
      return undef;
    }
    return $n * $arms_count + $arm;
  }

  foreach my $arms (4,3,1,2) {
    ### $arms

    my $path = Math::PlanePath::DragonMidpoint->new (arms => $arms);
    for (my $n = 0; $n < 50; $n++) {
      my ($x,$y) = $path->n_to_xy($n)
        or next;

      my $rn = xy_to_n($path,$x,$y);

      my $good = '';
      if (defined $rn && $rn == $n) {
        $good .= "good N";
      }

      my $n2 = Math::BaseCnv::cnv($n,10,2);
      my $rn2 = Math::BaseCnv::cnv($rn,10,2);
      printf "n=%d xy=%d,%d got rn=%d    %s\n",
        $n,$x,$y,
          $rn,
            $good;
    }
  }
  exit 0;
}

{
  # tiling

  require Image::Base::Text;
  require Math::PlanePath::R5DragonCurve;
  my $path = Math::PlanePath::R5DragonCurve->new;

  my $width = 37;
  my $height = 21;
  my $image = Image::Base::Text->new (-width => $width,
                                      -height => $height);
  my $xscale = 3;
  my $yscale = 2;
  my $w2 = int(($width+1)/2);
  my $h2 = int($height/2);
  $w2 -= $w2 % $xscale;
  $h2 -= $h2 % $yscale;

  my $affine = sub {
    my ($x,$y) = @_;
    return ($x*$xscale + $w2,
            -$y*$yscale + $h2);
  };

  my ($n_lo, $n_hi) = $path->rect_to_n_range(-$w2/$xscale, -$h2/$yscale,
                                             $w2/$xscale, $h2/$yscale);
  print "n to $n_hi\n";
  foreach my $n ($n_lo .. $n_hi) {
    next if ($n % 5) == 2;
    my ($x,$y) = $path->n_to_xy($n);
    my ($next_x,$next_y) = $path->n_to_xy($n+1);
    foreach (1 .. 4) {
      $image->line ($affine->($x,$y),
                    $affine->($next_x,$next_y),
                    ($x==$next_x ? '|' : '-'));

      $image->xy ($affine->($x,$y),
                  '+');
      $image->xy ($affine->($next_x,$next_y),
                  '+');

      ($x,$y) = (-$y,$x); # rotate +90
      ($next_x,$next_y) = (-$next_y,$next_x); # rotate +90
    }
  }
  $image->xy ($affine->(0,0),
              'o');

  $image->save('/dev/stdout');
  exit 0;
}

{
  # min/max for level

  # radial extent
  #
  # dist0to5 = sqrt(1*1+2*2) = sqrt(5)
  #
  #   4-->5
  #   ^
  #   |
  #   3<--2
  #       ^
  #       |
  #   0-->1
  #
  # Rlevel = sqrt(5)^level + Rprev
  #        = sqrt(5) + sqrt(5)^2 + ... + sqrt(5)^(level-1) + sqrt(5)^level
  # if level 
  #        = sqrt(5) + sqrt(5)^2 + sqrt(5)*sqrt(5)^2 + ... 
  #        = sqrt(5) + (1+sqrt(5))*5^1 + (1+sqrt(5))*5^2 + ... 
  #        = sqrt(5) + (1+sqrt(5))* [ 5^1 + 5^2 + ... ]
  #        = sqrt(5) + (1+sqrt(5))* (5^k - 1)/4
  #        <= 5^k
  # Rlevel^2 <= 5^level

  require Math::BaseCnv;
  require Math::PlanePath::R5DragonCurve;
  my $path = Math::PlanePath::R5DragonCurve->new;
  my $prev_min = 1;
  my $prev_max = 1;
  for (my $level = 1; $level < 10; $level++) {
    my $n_start = 5**($level-1);
    my $n_end = 5**$level;

    my $min_hypot = 128*$n_end*$n_end;
    my $min_x = 0;
    my $min_y = 0;
    my $min_pos = '';

    my $max_hypot = 0;
    my $max_x = 0;
    my $max_y = 0;
    my $max_pos = '';

    print "level $level  n=$n_start .. $n_end\n";

    foreach my $n ($n_start .. $n_end) {
      my ($x,$y) = $path->n_to_xy($n);
      my $h = $x*$x + $y*$y;

      if ($h < $min_hypot) {
        $min_hypot = $h;
        $min_pos = "$x,$y";
      }
      if ($h > $max_hypot) {
        $max_hypot = $h;
        $max_pos = "$x,$y";
      }
    }
    # print "  min $min_hypot   at $min_x,$min_y\n";
    # print "  max $max_hypot   at $max_x,$max_y\n";
    {
      my $factor = $min_hypot / $prev_min;
      my $min_hypot_5 = Math::BaseCnv::cnv($min_hypot,10,5);
      print "  min r^2 $min_hypot ${min_hypot_5}[5]  at $min_pos  factor $factor\n";
    }
    {
      my $factor = $max_hypot / $prev_max;
      my $max_hypot_5 = Math::BaseCnv::cnv($max_hypot,10,5);
      print "  max r^2 $max_hypot ${max_hypot_5}[5])  at $max_pos  factor $factor\n";
    }
    $prev_min = $min_hypot;
    $prev_max = $max_hypot;
  }
  exit 0;
}

{
  # 2i+1 powers
  my $x = 1;
  my $y = 0;
  foreach (1 .. 10) {
    ($x,$y) = ($x - 2*$y,
                 $y + 2*$x);
    print "$x  $y\n";
  }
  exit 0;
}

{
  # turn sequence
  require Math::NumSeq::PlanePathTurn;
  my @want = (0);
  foreach (1 .. 5) {
    @want = map { $_ ? (0,0,1,1,1) : (0,0,1,1,0) } @want;
  }

  my @got;
  foreach my $i (1 .. @want) {
    push @got, calc_n_turn($i);
  }
  # my $seq = Math::NumSeq::PlanePathTurn->new (planepath => 'R5DragonCurve',
  #                                             turn_type => 'Right');
  # while (@got < @want) {
  #   my ($i,$value) = $seq->next;
  #   push @got, $value;
  # }

  my $got = join(',',@got);
  my $want = join(',',@want);
  print "$got\n";
  print "$want\n";

  if ($got ne $want) {
    die;
  }
  exit 0;

  # return 0 for left, 1 for right
  sub calc_n_turn {
    my ($n) = @_;
    $n or die;
    for (;;) {
      if (my $digit = $n % 5) {
        return ($digit >= 3 ? 1 : 0);
      }
      $n = int($n/5);
    }
  }
}
