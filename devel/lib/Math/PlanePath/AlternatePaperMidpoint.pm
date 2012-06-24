# Copyright 2011, 2012 Kevin Ryde

# This file is part of Math-PlanePath.
#
# Math-PlanePath is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-PlanePath is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-PlanePath.  If not, see <http://www.gnu.org/licenses/>.


# math-image --path=AlternatePaperMidpoint --all --output=numbers_dash
# math-image --path=AlternatePaperMidpoint --lines --scale=20

# A088435 (contfrac+1)/2 of sum(k>=1,1/3^(2^k)).
# A007404 in decimal
# A081769 positions of 2s
# A073097 number of 4s - 6s - 2s - 1 is -1,0,1
# A073088 cumulative total multiples of 4 roughly, hence (4n-3-cum)/2
# A073089 (1/2)*(4n - 3 - cumulative) is 0 or 1
# A006466 contfrac 2*sum( 1/2^(2^n)), 1 and 2 only
# A076214 in decimal
# # A073089(n) = A082410(n) xor A000035(n) xor 1


package Math::PlanePath::AlternatePaperMidpoint;
use 5.004;
use strict;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use Math::PlanePath;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;
*_digit_split_lowtohigh = \&Math::PlanePath::_digit_split_lowtohigh;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

use Math::PlanePath::AlternatePaper;

use vars '$VERSION', '@ISA';
$VERSION = 78;
@ISA = ('Math::PlanePath');


# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;
sub arms_count {
  my ($self) = @_;
  return $self->{'arms'} || 1;
}

my @x_negative = (undef,  0,0, 1,1, 1,1, 1,1);
my @y_negative = (undef,  0,0, 0,0, 1,1, 1,1);
sub x_negative {
  my ($self) = @_;
  return ($self->{'arms'} >= 3);
}
sub y_negative {
  my ($self) = @_;
  return ($self->{'arms'} >= 5);
}

use constant parameter_info_array => [ { name      => 'arms',
                                         share_key => 'arms_8',
                                         type      => 'integer',
                                         minimum   => 1,
                                         maximum   => 8,
                                         default   => 1,
                                         width     => 1,
                                         description => 'Arms',
                                       } ];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);

  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 8) { $arms = 8; }
  $self->{'arms'} = $arms;

  return $self;
}

sub XX_n_to_xy {
  my ($self, $n) = @_;
  ### AlternatePaperMidpoint n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n, $n); }

  {
    my $int = int($n);
    if ($n != $int) {
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $frac = $n - $int;  # inherit possible BigFloat
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int; # BigFloat int() gives BigInt, use that
  }

  my ($x1,$y1) = $self->Math::PlanePath::AlternatePaper::n_to_xy($n);
  my ($x2,$y2) = $self->Math::PlanePath::AlternatePaper::n_to_xy($n+1);

  my $dx = $x2-$x1;
  my $dy = $y2-$y1;
  return ($x1+$y1 + ($dx+$dy-1)/2,
          $x1-$y1 - ($dy-$dx+1)/2);
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### AlternatePaperMidpoint n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n, $n); }

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;  # inherit possible BigFloat
    $n = $int;          # BigFloat int() gives BigInt, use that
  }

  my $zero = ($n * 0);  # inherit bignum 0

  # arm as initial rotation
  ($n, my $rot) = _divrem ($n, $self->{'arms'});

  ### $arms
  ### rot from arm: $rot
  ### $n

  # ENHANCE-ME: sx,sy just from len,len
  my @digits = _digit_split_lowtohigh($n,2);
  my @sx;
  my @sy;

  {
    my $sx = $zero + 1;
    my $sy = -$sx;
    foreach (@digits) {
      push @sx, $sx;
      push @sy, $sy;

      # (sx,sy) + rot+90(sx,sy)
      ($sx,$sy) = ($sx - $sy,
                   $sy + $sx);
    }
  }

  ### @digits
  my $rev = 0;
  my $x = $zero;
  my $y = $zero;
  my $above_low_zero = 0;

  for (my $i = $#digits; $i >= 0; $i--) {     # high to low
    my $digit = $digits[$i];
    my $sx = $sx[$i];
    my $sy = $sy[$i];
    ### at: "$x,$y  $digit   side $sx,$sy"
    ### $rot

    if ($rot & 2) {
      $sx = -$sx;
      $sy = -$sy;
    }
    if ($rot & 1) {
      ($sx,$sy) = (-$sy,$sx);
    }
    ### rotated side: "$sx,$sy"

    if ($rev) {
      if ($digit) {
        $x += -$sy;
        $y += $sx;
        ### rev add to: "$x,$y next is still rev"
      } else {
        $above_low_zero = $digits[$i+1];
        $rot ++;
        $rev = 0;
        ### rev rot, next is no rev ...
      }
    } else {
      if ($digit) {
        $rot ++;
        $x += $sx;
        $y += $sy;
        $rev = 1;
        ### plain add to: "$x,$y next is rev"
      } else {
        $above_low_zero = $digits[$i+1];
      }
    }
  }

  # Digit above the low zero is the direction of the next turn, 0 for left,
  # 1 for right.
  #
  ### final: "$x,$y  rot=$rot  above_low_zero=".($above_low_zero||0)

  if ($rot & 2) {
    $frac = -$frac;  # rotate 180
    $x -= 1;
  }
  if (($rot+1) & 2) {
    # rot 1 or 2
    $y += 1;
  }
  if (!($rot & 1) && $above_low_zero) {
    $frac = -$frac;
  }
  $above_low_zero ^= ($rot & 1);
  if ($above_low_zero) {
    $y = $frac + $y;
  } else {
    $x = $frac + $x;
  }

  ### rotated return: "$x,$y"
  return ($x,$y);
}

# or tables arithmetically,
#
#   my $ax = ((($x+1) ^ ($y+1)) >> 1) & 1;
#   my $ay = (($x^$y) >> 1) & 1;
#   ### assert: $ax == - $yx_adj_x[$y%4]->[$x%4]
#   ### assert: $ay == - $yx_adj_y[$y%4]->[$x%4]
#
my @yx_adj_x = ([0,1,1,0],
                [1,0,0,1],
                [1,0,0,1],
                [0,1,1,0]);
my @yx_adj_y = ([0,0,1,1],
                [0,0,1,1],
                [1,1,0,0],
                [1,1,0,0]);

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### AlternatePaperMidpoint xy_to_n(): "$x, $y"

  return undef;

  $x = _round_nearest($x);
  $y = _round_nearest($y);

  if (_is_infinite($x)) {
    return $x;  # infinity
  }
  if (_is_infinite($y)) {
    return $y;  # infinity
  }

  my $n = ($x * 0 * $y); # inherit bignum 0
  my $npow = $n + 1;     # inherit bignum 1

  while (($x != 0 && $x != -1) || ($y != 0 && $y != 1)) {

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
  if ($arm >= $arms_count) {
    return undef;
  }
  return $n * $arms_count + $arm;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### AlternatePaperMidpoint rect_to_n_range(): "$x1,$y1  $x2,$y2  arms=$self->{'arms'}"

  $x1 = _round_nearest($x1);
  $x2 = _round_nearest($x2);
  $y1 = _round_nearest($y1);
  $y2 = _round_nearest($y2);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  if ($x2 < 0 || $y2 < 0 || $y1 > $x2) {
    # outside first octant
    return (1,0);
  }

  my ($len, $level) =_round_down_pow ($x2, 2);
  return (0, 2*$len*$len-1);
}

1;
__END__
