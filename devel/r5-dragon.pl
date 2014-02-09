#!/usr/bin/perl -w

# Copyright 2012, 2014 Kevin Ryde

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
use lib 'xt';

# uncomment this to run the ### lines
# use Smart::Comments;


{
  # at N=29
  require Math::NumSeq::PlanePathDelta;
  require Math::PlanePath::R5DragonMidpoint;
  my $path = Math::PlanePath::R5DragonMidpoint->new;
  my $n = 29;
  my ($x,$y) = $path->n_to_xy($n);
  my ($dx,$dy) = $path->n_to_dxdy($n);
  my $tradius = Math::NumSeq::PlanePathCoord::_path_n_to_tradius($path,$n);
  my $next_tradius = Math::NumSeq::PlanePathCoord::_path_n_to_tradius($path,$n + $path->arms_count);
  my $dtradius = Math::NumSeq::PlanePathDelta::_path_n_to_dtradius($path,$n);
  print "$n  x=$x,y=$y   $dx,$dy  dtradius=$dtradius\n";
  print "   tradius $tradius to $next_tradius\n";
  exit 0;
}

{
  # first South step dY=-1 on Y axis

  require Math::PlanePath::R5DragonMidpoint;
  my $path = Math::PlanePath::R5DragonMidpoint->new;

  require Math::NumSeq::PlanePathDelta;
  my $seq = Math::NumSeq::PlanePathDelta->new (path => $path);

  my @values;
  my $n = 0;
 OUTER: for ( ; ; $n++) {
    my ($x,$y) = $path->n_to_xy($n);
    my ($dx,$dy) = $path->n_to_dxdy($n);

    if ($x == 0 && $dx == 0 && $dy == -($y < 0 ? -1 : 1)) {
      my $tradius = Math::NumSeq::PlanePathCoord::_path_n_to_tradius($path,$n);
      my $next_tradius = Math::NumSeq::PlanePathCoord::_path_n_to_tradius($path,$n + $path->arms_count);
      my $dtradius = Math::NumSeq::PlanePathDelta::_path_n_to_dtradius($path,$n);
      print "$n  $x,$y   $dx,$dy  dtradius=$dtradius\n";
      print "   tradius $tradius to $next_tradius\n";
      push @values, $n;
      last OUTER if @values > 20;
    }
  }

  print join(',',@values),"\n";
  require MyOEIS;
  print MyOEIS->grep_for_values(array => \@values);
  exit 0;
}
{
  # any South step dY=-1 on Y axis

  # use Math::BigInt try => 'GMP';
  # use Math::BigFloat;

  require Math::PlanePath::R5DragonMidpoint;
  my $path = Math::PlanePath::R5DragonMidpoint->new;

  require Math::NumSeq::PlanePathDelta;
  my $seq = Math::NumSeq::PlanePathDelta->new (path => $path);

  my @values;
  my $x = 0;
  my $y = 0;
  # $x = Math::BigFloat->new($x);
  # $y = Math::BigFloat->new($y);

  OUTER: for ( ; ; $y++) {
    ### y: "$y"
    foreach my $sign (1,-1) {
      ### at: "$x, $y  sign=$sign"
      if (defined (my $n = $path->xy_to_n($x,$y))) {
        my ($dx,$dy) = $path->n_to_dxdy($n);
        ### dxdy: "$dx, $dy"
        if ($dx == 0 && $dy == $sign) {
          my $tradius = Math::NumSeq::PlanePathCoord::_path_n_to_tradius($path,$n);
          my $next_tradius = Math::NumSeq::PlanePathCoord::_path_n_to_tradius($path,$n + $path->arms_count);
          my $dtradius = Math::NumSeq::PlanePathDelta::_path_n_to_dtradius($path,$n);
          print "$n  $x,$y   $dx,$dy  dtradius=$dtradius\n";
          print "   tradius $tradius to $next_tradius\n";
          push @values, $y;
          last OUTER if @values > 20;
        }
      }
      $y = -$y;
    }
  }

  print join(',',@values),"\n";
  require MyOEIS;
  print MyOEIS->grep_for_values(array => \@values);
  exit 0;
}
{
  # boundary join 4,13,40,121,364
  # A003462 (3^n - 1)/2.

  require Math::PlanePath::R5DragonCurve;
  my $path = Math::PlanePath::R5DragonCurve->new;
  my @values;
  $| = 1;
  foreach my $exp (2 .. 6) {
    my $t_lo = 5**$exp;
    my $t_hi = 2*5**$exp - 1;
    my $count = 0;
    foreach my $n (0 .. $t_lo-1) {
      my ($x,$y) = $path->n_to_xy($n);
      my @n_list = $path->xy_to_n_list($x,$y);
      if (@n_list >= 2
          && $n_list[0] < $t_lo
          && $n_list[1] >= $t_lo
          && $n_list[1] < $t_hi) {
        $count++;
      }
    }
    push @values, $count;
    print "$count,";
  }
  print "\n";
  require MyOEIS;
  print MyOEIS->grep_for_values(array => \@values);
  exit 0;
}
{
  # overlaps
  require Math::PlanePath::R5DragonCurve;
  require Math::BaseCnv;

  my $path = Math::PlanePath::R5DragonCurve->new;
  my $width = 5;
  foreach my $n (0 .. 5**($width-1)) {
    my ($x,$y) = $path->n_to_xy($n);
    my @n_list = $path->xy_to_n_list($x,$y);
    next unless @n_list >= 2;

    if ($n_list[1] == $n) { ($n_list[0],$n_list[1]) = ($n_list[1],$n_list[0]); }
    my $n_list = join(',',@n_list);
    my @n5_list = map { sprintf '%*s', $width, Math::BaseCnv::cnv($_,10,5) } @n_list;
    print "$n5_list[0]  $n5_list[1]  ($n_list)\n";
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

  foreach my $x (0 .. $width-1) {
    foreach my $y (0 .. $height-1) {
      next unless $image->xy($x,$y) eq '+';

      if ($x > 0 && $image->xy($x-1,$y) eq ' ') {
        $image->xy($x,$y, '|');
      } elsif ($x < $width-1 && $image->xy($x+1,$y) eq ' ') {
        $image->xy($x,$y, '|');

      } elsif ($y > 0 && $image->xy($x,$y-1) eq ' ') {
        $image->xy($x,$y, '-');
      } elsif ($y < $height-1 && $image->xy($x,$y+1) eq ' ') {
        $image->xy($x,$y, '-');
      }
    }
  }
  $image->save('/dev/stdout');
  exit 0;
}
{
  # area recurrence
  foreach my $i (0 .. 10) {
    print recurrence($i),",";
  }
  print "\n";

  print "wrong():              ";
  foreach my $i (0 .. 10) { print wrong($i),","; }
  print "\n";

  print "recurrence_area815(): ";
  foreach my $i (0 .. 10) { print recurrence_area815($i),","; }
  print "\n";

  print "recurrence_area43():  ";
  foreach my $i (0 .. 10) { print recurrence_area43($i),","; }
  print "\n";
  print "formula_pow():        ";
  foreach my $i (0 .. 10) { print formula_pow($i),","; }
  print "\n";

  print "recurrence_areaSU():  ";
  foreach my $i (0 .. 10) { print recurrence_areaSU($i),","; }
  print "\n";
  print "recurrence_area2S():  ";
  foreach my $i (0 .. 10) { print recurrence_area2S($i),","; }
  print "\n";
  exit 0;

  # A[n+1] = 4*A[n] - 3*A[n-1] + 4*5^(n-1)
  # - A[n+1] + 4*A[n] + 4*5^(n-1) = 3*A[n-1]
  # 3*A[n-1] = - A[n+1] + 4*A[n] + 4*5^(n-1)
  # 3*A[n-2] = - A[n] + 4*A[n-1] + 4*5^(n-2)

  # D[n+1] = 4*A[n] - 3*A[n-1]            + 4*5^(n-1)
  #          -       (4*A[n-1] - 3*A[n-2] + 4*5^(n-2))
  #        = 4*A[n] - 3*A[n-1]            + 4*5^(n-1)
  #                 - 4*A[n-1] + 3*A[n-2] - 4*5^(n-2))
  #        = 4*A[n] - 3*A[n-1]            + 4*5^(n-1)
  #                 - 4*A[n-1] - A[n] + 4*A[n-1] + 4*5^(n-2) - 4*5^(n-2))
  #        = 4*A[n] - 3*A[n-1]            + 4*5^(n-1)
  #          - A[n]
  # D[n+1] = 4*A[n] - 3*A[n-1]            + 4*5^(n-1)
  #          - A[n]
  # D[n+1] = 3*A[n] - 3*A[n-1]            + 4*5^(n-1)
  # D[n+1] = 3*D[n] + 4*5^(n-1)

  #      = 4*A[n] - 7*A[n-1] + 3*A[n-2] + (4*5-4)*5^(n-2)
  #      = 4*A[n] - 7*A[n-1] + 3*A[n-2] + 16*5^(n-2)
  #      = 4*A[n] - 7*A[n-1] + A[n] + 4*A[n-1] + 4*5^(n-2) + 16*5^(n-2)
  #      = 3*A[n] - 3*A[n-1] + 20*5^(n-2)
  # 4*A[n] - 12*A[n-1] + 4 - 4*5^(n-1) = 0 ??

  sub wrong {
    my ($n) = @_;
    if ($n <= 0) { return 0; }
    if ($n == 1) { return 0; }
    return 4*wrong($n-1) + 4*5**($n-2);
  }


  # A[n] = (5^k - 2*3^k + 1)/2
  sub formula_pow {
    my ($n) = @_;
    return (5**$n - 2*3**$n + 1) / 2;
  }

  sub recurrence_area43 {
    my ($n) = @_;
    if ($n <= 0) { return 0; }
    if ($n == 1) { return 0; }
    return 4*recurrence_area43($n-1) - 3*recurrence_area43($n-2) + 4*5**($n-2);
  }

  # A[n+1] = 8*A[n] - 15*A[n-1] + 4
  sub recurrence_area815 {
    my ($n) = @_;
    if ($n <= 0) { return 0; }
    if ($n == 1) { return 0; }
    return 8*recurrence_area815($n-1) - 15*recurrence_area815($n-2) + 4;
  }
  sub recurrence {
    my ($n) = @_;
    if ($n <= 0) { return 0; }
    if ($n == 1) { return 2; }
    return 8*recurrence($n-1) - 15*recurrence($n-2) + 2;
  }

  sub recurrence_area2S {
    my ($n) = @_;
    return 2*recurrence_S($n+1);
  }
  sub recurrence_areaSU {
    my ($n) = @_;
    return 4*recurrence_S($n) + 2*recurrence_U($n);
  }
  sub recurrence_S {
    my ($n) = @_;
    if ($n <= 0) { return 0; }
    if ($n == 1) { return 0; }
    return 2*recurrence_S($n-1) + recurrence_U($n-1);
  }
  sub recurrence_U {
    my ($n) = @_;
    if ($n <= 0) { return 0; }
    if ($n == 1) { return 0; }
    return recurrence_S($n-1) + 2*recurrence_U($n-1) + 2*5**($n-2);
  }

  # A(n)=a(n)*2
  # A(n)/2 = 8*A(n-1)/2 - 15*A(n-2)/2 + 2
  # A(n) = 8*A(n-1) - 15*A(n-2) + 4
}
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
