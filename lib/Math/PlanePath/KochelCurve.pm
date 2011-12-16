# Copyright 2011 Kevin Ryde

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


package Math::PlanePath::KochelCurve;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 60;
use Math::PlanePath 54; # v.54 for _max()
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;
use constant x_negative => 0;
use constant y_negative => 0;

# tables generated by tools/kochel-curve-table.pl
#
my @next_state = (63,72, 9, 99, 0,90, 36,99, 0,    # 0
                  36,81,18, 72, 9,99, 45,72, 9,    # 9
                  45,90,27, 81,18,72, 54,81,18,    # 18
                  54,99, 0, 90,27,81, 63,90,27,    # 27
                  36,81, 0, 72,36,81, 45,90,27,    # 36
                  45,90, 9, 81,45,90, 54,99, 0,    # 45
                  54,99,18, 90,54,99, 63,72, 9,    # 54
                  63,72,27, 99,63,72, 36,81,18,    # 63
                  63,72, 9, 99,90,99, 63,72, 9,    # 72
                  36,81,18, 72,99,72, 36,81,18,    # 81
                  45,90,27, 81,72,81, 45,90,27,    # 90
                  54,99, 0, 90,81,90, 54,99, 0);   # 99
my @digit_to_x = (0,0,0, 1,2,2, 1,1,2,    # 0
                  2,1,0, 0,0,1, 1,2,2,    # 9
                  2,2,2, 1,0,0, 1,1,0,    # 18
                  0,1,2, 2,2,1, 1,0,0,    # 27
                  2,1,1, 2,2,1, 0,0,0,    # 36
                  2,2,1, 1,0,0, 0,1,2,    # 45
                  0,1,1, 0,0,1, 2,2,2,    # 54
                  0,0,1, 1,2,2, 2,1,0,    # 63
                  0,0,0, 1,1,1, 2,2,2,    # 72
                  2,1,0, 0,1,2, 2,1,0,    # 81
                  2,2,2, 1,1,1, 0,0,0,    # 90
                  0,1,2, 2,1,0, 0,1,2);   # 99
my @digit_to_y = (0,1,2, 2,2,1, 1,0,0,    # 0
                  0,0,0, 1,2,2, 1,1,2,    # 9
                  2,1,0, 0,0,1, 1,2,2,    # 18
                  2,2,2, 1,0,0, 1,1,0,    # 27
                  0,0,1, 1,2,2, 2,1,0,    # 36
                  2,1,1, 2,2,1, 0,0,0,    # 45
                  2,2,1, 1,0,0, 0,1,2,    # 54
                  0,1,1, 0,0,1, 2,2,2,    # 63
                  0,1,2, 2,1,0, 0,1,2,    # 72
                  0,0,0, 1,1,1, 2,2,2,    # 81
                  2,1,0, 0,1,2, 2,1,0,    # 90
                  2,2,2, 1,1,1, 0,0,0);   # 99
my @xy_to_digit = (0,1,2, 7,6,3, 8,5,4,    # 0
                   2,3,4, 1,6,5, 0,7,8,    # 9
                   4,5,8, 3,6,7, 2,1,0,    # 18
                   8,7,0, 5,6,1, 4,3,2,    # 27
                   8,7,6, 1,2,5, 0,3,4,    # 36
                   6,5,4, 7,2,3, 8,1,0,    # 45
                   4,3,0, 5,2,1, 6,7,8,    # 54
                   0,1,8, 3,2,7, 4,5,6,    # 63
                   0,1,2, 5,4,3, 6,7,8,    # 72
                   2,3,8, 1,4,7, 0,5,6,    # 81
                   8,7,6, 3,4,5, 2,1,0,    # 90
                   6,5,0, 7,4,1, 8,3,2);   # 99
my @min_digit = (0,0,0,7,8,7,    # 0
                 0,0,0,5,5,6,
                 0,0,0,3,4,3,
                 1,1,1,3,4,3,
                 2,2,2,3,4,3,
                 1,1,1,5,5,6,
                 2,1,0,0,0,1,    # 36
                 2,1,0,0,0,1,
                 2,1,0,0,0,1,
                 3,3,3,5,7,5,
                 4,4,4,5,8,5,
                 3,3,3,6,7,6,
                 4,3,2,2,2,3,    # 72
                 4,3,1,1,1,3,
                 4,3,0,0,0,3,
                 5,5,0,0,0,6,
                 8,7,0,0,0,7,
                 5,5,1,1,1,6,
                 8,5,4,4,4,5,    # 108
                 7,5,3,3,3,5,
                 0,0,0,1,2,1,
                 0,0,0,1,2,1,
                 0,0,0,1,2,1,
                 7,6,3,3,3,6,
                 8,1,0,0,0,1,    # 144
                 7,1,0,0,0,1,
                 6,1,0,0,0,1,
                 6,2,2,2,3,2,
                 6,5,4,4,4,5,
                 7,2,2,2,3,2,
                 6,6,6,7,8,7,    # 180
                 5,2,1,1,1,2,
                 4,2,0,0,0,2,
                 4,2,0,0,0,2,
                 4,3,0,0,0,3,
                 5,2,1,1,1,2,
                 4,4,4,5,6,5,    # 216
                 3,2,2,2,6,2,
                 0,0,0,1,6,1,
                 0,0,0,1,7,1,
                 0,0,0,1,8,1,
                 3,2,2,2,7,2,
                 0,0,0,3,4,3,    # 252
                 0,0,0,2,4,2,
                 0,0,0,2,4,2,
                 1,1,1,2,5,2,
                 8,7,6,6,6,7,
                 1,1,1,2,5,2,
                 0,0,0,5,6,5,    # 288
                 0,0,0,4,6,4,
                 0,0,0,3,6,3,
                 1,1,1,3,7,3,
                 2,2,2,3,8,3,
                 1,1,1,4,7,4,
                 2,1,0,0,0,1,    # 324
                 2,1,0,0,0,1,
                 2,1,0,0,0,1,
                 3,3,3,4,5,4,
                 8,7,6,6,6,7,
                 3,3,3,4,5,4,
                 8,3,2,2,2,3,    # 360
                 7,3,1,1,1,3,
                 6,3,0,0,0,3,
                 6,4,0,0,0,4,
                 6,5,0,0,0,5,
                 7,4,1,1,1,4,
                 6,6,6,7,8,7,    # 396
                 5,4,3,3,3,4,
                 0,0,0,1,2,1,
                 0,0,0,1,2,1,
                 0,0,0,1,2,1,
                 5,4,3,3,3,4);
my @max_digit = (0,7,8,8,8,7,    # 0
                 1,7,8,8,8,7,
                 2,7,8,8,8,7,
                 2,6,6,6,5,6,
                 2,3,4,4,4,3,
                 1,6,6,6,5,6,
                 2,2,2,1,0,1,    # 36
                 3,6,7,7,7,6,
                 4,6,8,8,8,6,
                 4,6,8,8,8,6,
                 4,5,8,8,8,5,
                 3,6,7,7,7,6,
                 4,4,4,3,2,3,    # 72
                 5,6,6,6,2,6,
                 8,8,8,7,2,7,
                 8,8,8,7,1,7,
                 8,8,8,7,0,7,
                 5,6,6,6,1,6,
                 8,8,8,5,4,5,    # 108
                 8,8,8,6,4,6,
                 8,8,8,6,4,6,
                 7,7,7,6,3,6,
                 0,1,2,2,2,1,
                 7,7,7,6,3,6,
                 8,8,8,1,0,1,    # 144
                 8,8,8,3,3,2,
                 8,8,8,5,4,5,
                 7,7,7,5,4,5,
                 6,6,6,5,4,5,
                 7,7,7,3,3,2,
                 6,7,8,8,8,7,    # 180
                 6,7,8,8,8,7,
                 6,7,8,8,8,7,
                 5,5,5,3,1,3,
                 4,4,4,3,0,3,
                 5,5,5,2,1,2,
                 4,5,6,6,6,5,    # 216
                 4,5,7,7,7,5,
                 4,5,8,8,8,5,
                 3,3,8,8,8,2,
                 0,1,8,8,8,1,
                 3,3,7,7,7,2,
                 0,3,4,4,4,3,    # 252
                 1,3,5,5,5,3,
                 8,8,8,7,6,7,
                 8,8,8,7,6,7,
                 8,8,8,7,6,7,
                 1,2,5,5,5,2,
                 0,5,6,6,6,5,    # 288
                 1,5,7,7,7,5,
                 2,5,8,8,8,5,
                 2,4,8,8,8,4,
                 2,3,8,8,8,3,
                 1,4,7,7,7,4,
                 2,2,2,1,0,1,    # 324
                 3,4,5,5,5,4,
                 8,8,8,7,6,7,
                 8,8,8,7,6,7,
                 8,8,8,7,6,7,
                 3,4,5,5,5,4,
                 8,8,8,3,2,3,    # 360
                 8,8,8,4,2,4,
                 8,8,8,5,2,5,
                 7,7,7,5,1,5,
                 6,6,6,5,0,5,
                 7,7,7,4,1,4,
                 6,7,8,8,8,7,    # 396
                 6,7,8,8,8,7,
                 6,7,8,8,8,7,
                 5,5,5,4,3,4,
                 0,1,2,2,2,1,
                 5,5,5,4,3,4);
# state length 108 in each of 4 tables

sub n_to_xy {
  my ($self, $n) = @_;
  ### KochelCurve n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  my $int = int($n);
  $n -= $int;  # remaining fraction, preserve possible BigFloat/BigRat

  my @digits;
  my $len = $int*0 + 1;   # inherit bigint 1
  while ($int) {
    push @digits, $int % 9;
    $int = int($int/9);
    $len *= 3;
  }
  ### digits: join(', ',@digits)."   count ".scalar(@digits)
  ### $len

  my $state = 63;
  my $dir = 1; # default if all $digit==8
  my $x = 0;
  my $y = 0;

  while (@digits) {
    $len /= 3;
    $state += (my $digit = pop @digits);
    if ($digit != 8) {
      $dir = $state;  # lowest non-8 digit
    }

    ### $len
    ### $state
    ### digit_to_x: $digit_to_x[$state]
    ### digit_to_y: $digit_to_y[$state]
    ### next_state: $next_state[$state]

    $x += $len * $digit_to_x[$state];
    $y += $len * $digit_to_y[$state];
    $state = $next_state[$state];
  }

  ### $dir
  ### frac: $n

  # with $n fractional part
  return ($n * ($digit_to_x[$dir+1] - $digit_to_x[$dir]) + $x,
          $n * ($digit_to_y[$dir+1] - $digit_to_y[$dir]) + $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### KochelCurve xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($x < 0 || $y < 0) {
    return undef;
  }
  if (_is_infinite($x)) {
    return $x;
  }
  if (_is_infinite($y)) {
    return $y;
  }

  my ($len, $level) = _round_down_pow (_max($x,$y), 3);
  ### $len
  ### $level

  my $n = ($x * 0 * $y);
  my $state = 63;

  while ($level-- >= 0) {
    ### at: "$x,$y  len=$len level=$level"
    ### assert: $x >= 0
    ### assert: $y >= 0
    ### assert: $x < 3*$len
    ### assert: $y < 3*$len

    my $xo = int ($x / $len);
    my $yo = int ($y / $len);
    ### assert: $xo >= 0
    ### assert: $xo <= 2
    ### assert: $yo >= 0
    ### assert: $yo <= 2

    $x %= $len;
    $y %= $len;
    ### xy bits: "$xo, $yo"

    my $digit = $xy_to_digit[$state + 3*$xo + $yo];
    $state = $next_state[$state+$digit];
    $n = 9*$n + $digit;
    $len /= 3;
  }

  ### assert: $x == 0
  ### assert: $y == 0

  return $n;
}

# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### KochelCurve rect_to_n_range(): "$x1,$y1, $x2,$y2"

  $x1 = _round_nearest ($x1);
  $x2 = _round_nearest ($x2);
  $y1 = _round_nearest ($y1);
  $y2 = _round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  if ($x2 < 0 || $y2 < 0) {
    return (1, 0);
  }

  my ($len, $level) = _round_down_pow (_max($x2,$y2), 3);
  ### $len
  ### $level
  if (_is_infinite($level)) {
    return (0, $level);
  }

  # At this point an easy round-up range here would be:
  # return (0, 9*$len*$len-1);


  my $n_min = my $n_max
    = my $x_min = my $y_min
      = my $x_max = my $y_max
        = ($x1 * 0 * $x2 * $y1 * $y2); # inherit bignum 0

  my $min_state = my $max_state = 63;

  # x__  0
  # xx_  1
  # xxx  2
  # _xx  3
  # __x  4
  # _x_  5
  #
  while ($level >= 0) {
    my $l2 = 2*$len;
    {
      my $x_cmp1 = $x_min + $len;
      my $y_cmp1 = $y_min + $len;
      my $x_cmp2 = $x_min + $l2;
      my $y_cmp2 = $y_min + $l2;
      my $digit = $min_digit[4*$min_state  # 4*9=36 apart
                             + ($x1 >= $x_cmp2 ? 4
                                : $x1 >= $x_cmp1 ? ($x2 < $x_cmp2 ? 5 : 3)
                                : ($x2 < $x_cmp1 ? 0
                                   : $x2 < $x_cmp2 ? 1 : 2))
                             + ($y1 >= $y_cmp2 ? 6*4
                                : $y1 >= $y_cmp1 ? ($y2 < $y_cmp2 ? 6*5 : 6*3)
                                : ($y2 < $y_cmp1 ? 6*0
                                   : $y2 < $y_cmp2 ? 6*1 : 6*2))];

      # my $key = 4*$min_state  # 4*9=36 apart
      #   + ($x1 >= $x_cmp2 ? 4
      #      : $x1 >= $x_cmp1 ? ($x2 < $x_cmp2 ? 5 : 3)
      #      : ($x2 < $x_cmp1 ? 0
      #         : $x2 < $x_cmp2 ? 1 : 2))
      #     + ($y1 >= $y_cmp2 ? 6*4
      #        : $y1 >= $y_cmp1 ? ($y2 < $y_cmp2 ? 6*5 : 6*3)
      #        : ($y2 < $y_cmp1 ? 6*0
      #           : $y2 < $y_cmp2 ? 6*1 : 6*2));
      # ### $min_state
      # ### $len
      # ### $l2
      # ### $key
      # ### $x_cmp1
      # ### $x_cmp2
      # ### $digit


      $n_min = 9*$n_min + $digit;
      $min_state += $digit;
      $x_min += $len * $digit_to_x[$min_state];
      $y_min += $len * $digit_to_y[$min_state];
      $min_state = $next_state[$min_state];
    }
    {
      my $x_cmp1 = $x_max + $len;
      my $y_cmp1 = $y_max + $len;
      my $x_cmp2 = $x_max + $l2;
      my $y_cmp2 = $y_max + $l2;
      my $digit = $max_digit[4*$max_state  # 4*9=36 apart
                             + ($x1 >= $x_cmp2 ? 4
                                : $x1 >= $x_cmp1 ? ($x2 < $x_cmp2 ? 5 : 3)
                                : ($x2 < $x_cmp1 ? 0
                                   : $x2 < $x_cmp2 ? 1 : 2))
                             + ($y1 >= $y_cmp2 ? 6*4
                                : $y1 >= $y_cmp1 ? ($y2 < $y_cmp2 ? 6*5 : 6*3)
                                : ($y2 < $y_cmp1 ? 6*0
                                   : $y2 < $y_cmp2 ? 6*1 : 6*2))];

      # my $key = 4*$max_state  # 4*9=36 apart
      #   + ($x1 >= $x_cmp2 ? 4
      #      : $x1 >= $x_cmp1 ? ($x2 < $x_cmp2 ? 5 : 3)
      #      : ($x2 < $x_cmp1 ? 0
      #         : $x2 < $x_cmp2 ? 1 : 2))
      #     + ($y1 >= $y_cmp2 ? 4
      #        : $y1 >= $y_cmp1 ? ($y2 < $y_cmp2 ? 5 : 3)
      #        : ($y2 < $y_cmp1 ? 0
      #           : $y2 < $y_cmp2 ? 1 : 2));
      # ### $max_state
      # ### $len
      # ### $l2
      # ### $x_key
      # ### $key
      # ### $x_max
      # ### $y_max
      # ### $x_cmp1
      # ### $x_cmp2
      # ### $y_cmp1
      # ### $y_cmp2
      # ### $digit
      # ### max digit: $max_digit[$key]

      $n_max = 9*$n_max + $digit;
      $max_state += $digit;
      $x_max += $len * $digit_to_x[$max_state];
      $y_max += $len * $digit_to_y[$max_state];
      $max_state = $next_state[$max_state];
    }

    $len = int($len/3);
    $level--;
  }
  return ($n_min, $n_max);
}

1;
__END__

=for stopwords eg Ryde ie KochelCurve Math-PlanePath Haverkort Haverkort's Rrev Frev Kochel Tilings

=head1 NAME

Math::PlanePath::KochelCurve -- 3x3 self-similar R and F

=head1 SYNOPSIS

 use Math::PlanePath::KochelCurve;
 my $path = Math::PlanePath::KochelCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is an integer version of the Kochel curve by Herman Haverkort.  It
fills the first quadrant in a 3x3 self-similar pattern made from two base
shapes.

            |
      8    80--79  72--71--70--69  60--59--58
                |   |           |   |       |
      7    77--78  73  66--67--68  61  56--57
            |       |   |           |   |
      6    76--75--74  65--64--63--62  55--54
                                            |
      5    11--12  17--18--19--20  47--48  53
            |   |   |           |   |   |   |
      4    10  13  16  25--24  21  46  49  52
            |   |   |   |   |   |   |   |   |
      3     9  14--15  26  23--22  45  50--51
            |           |           |
      2     8-- 7-- 6  27--28--29  44--43--42
                    |           |           |
      1     1-- 2   5  32--31--30  37--38  41
            |   |   |   |           |   |   |
    Y=0->   0   3-- 4  33--34--35--36  39--40

            X=0  1   2   3   4   5   6   7   8   9  10  11  12  13  14

The two base shapes are an R and an F.  The R goes along an edge, the F goes
diagonally across.

          R pattern                      F pattern   ^
    +------+-----+-----+           +------+-----+----|+
    |    | | \   | 4   |           |    | | \   |    ||
    |  R | |  F  |   R |           |  R | |  F  |  R ||
    | 2  | | 3 \ |-----|           | 2  | | 2 \ | 8  ||
    +------+-----+-----+           +------+-----+-----+
    |   /  |  6  | 5 / |           |   /  | 4 / |   / |
    |  F 1 | Rrev|  F  |           |  F   |  F  |  F  |
    | /    |-----| /   |           | / 1  | /   | / 7 |
    +------+-----+-----+           +------+-----+-----+
    | |  0 | \ 7 |   8 |           | | 0  | \ 5 ||    |
    | |Rrev|  F  |  R  |           | |Rrev|  F  ||Rrev|
    | o    |   \ |------>          | o    |   \ || 6  |
    +------+-----+-----+           +------+-----+-----+

"Rrev" means the R pattern followed in reverse, which is

    +------+-----+-----+ 
    | <----| \ 7 |   6 |    Rrev pattern
    |   R  |  F  | Rrev|
    |  8   |   \ |-----|    turned -90 degrees
    +------+-----+-----+    so as to start at
    |   /  ||    |   / |    bottom left 
    |  F   || R  |  F  | 
    | / 1  || 2  | / 5 | 
    +------+-----+-----+ 
    | | 0  | \ 3 ||    | 
    | |Rrev|  F  ||Rrev| 
    | o    |   \ ||  4 | 
    +------+-----+-----+ 

The F pattern is symmetric, the same forward or reverse, including its
sub-parts in reverse, so there's no separate "Frev" pattern.

The initial N=0 to N=8 is the Rrev turned -90, and N=9 to N=17 is the F
shape.  The next higher level N=0,N=9,N=18 to N=72 is the Rrev too, as is
any N=9^k to N=8*9^k.

=head2 Fractal

The curve is conceived by Haverkort for filling a unit square by descending
into ever-smaller replacements like other space-filling curves.  For that
the top-level can be any of the patterns.  But for the outward expanding
version here the starting pattern must occur at the start of its next higher
level, which means Rrev is the only choice since it's the only start in any
of the three patterns.

But all of the patterns can be found in the curve at any desired level of
detail.  For example the "1" part of Rrev is an F, which means F to a
desired level can be found at

    NFstart = 1 * 9^level
    NFlast = NFstart + 9^level - 1
           = 2 * 9^level - 1
    XFstart = 3^level
    YFstart = 0

level=3 for N=729 to N=1457 is a 27x27 which is the level-three F shown in
Haverkort's paper, starting at XFstart=27,YFstart=0.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::KochelCurve-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PeanoCurve>,
L<Math::PlanePath::WunderlichMeander>

Herman Haverkort, "Recursive Tilings and Space-Filling Curves with Little
Fragmentation", Journal of Computational Geometry, 2(1), 92-127, 2011.

    http://jocg.org/index.php/jocg/article/view/68
    http://jocg.org/index.php/jocg/article/download/68/20
    http://arxiv.org/abs/1002.1843

    http://alexandria.tue.nl/openaccess/Metis239505.pdf
    (slides)
    http://www.win.tue.nl/~hermanh/stack/h-rtslf-eurocg2010-talk.pdf
    (short form)

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011 Kevin Ryde

This file is part of Math-PlanePath.

Math-PlanePath is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

Math-PlanePath is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-PlanePath.  If not, see <http://www.gnu.org/licenses/>.

=cut


# Local variables:
# compile-command: "math-image --path=KochelCurve --lines --scale=20"
# End:
#
# math-image --path=KochelCurve --all --output=numbers_dash
