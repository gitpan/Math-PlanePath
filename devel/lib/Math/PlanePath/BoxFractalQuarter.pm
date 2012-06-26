# Copyright 2012 Kevin Ryde

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


# A147610 - 3^(ones(n-1) - 1)
# A048883 - 3^(ones n)


# Local variables:
# compile-command: "math-image --path=BoxFractalQuarter --all"
# End:
#
# math-image --path=BoxFractalQuarter --all --output=numbers --size=80x50


package Math::PlanePath::BoxFractalQuarter;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 79;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;
*_divrem = \&Math::PlanePath::_divrem;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

# uncomment this to run the ### lines
#use Devel::Comments;


use constant class_x_negative => 0;
use constant class_y_negative => 0;

#
#
# 9   9       9   9
#   8           8
# 9   7       7   9
#       6   6
#         5
#       4   6
# 3   3       7   9
#   2           8
# 1   3       9   9
#
# 1+1+3=5
# 1+1+3=5
# 3+3+9=15 total 25
#
#         0
#  1  0  +1
#  2  1  +1       <- 1
#  3  2  +3
#  4  5  +1       <- 1+1+3 = 5
#  5  6  +1
#  6  7  +3
#  7  10 +3
#  8  13 +3
#  9  16 +9
# 10  25         <- 5+5+3*5 = 25

# 1+3 = 4  power 2
# 1+3+3+9 = 16    power 3
# 1+3+3+9+3+9+9+27 = 64    power 4
#
# (1+4+16+...+4^(l-1)) = (4^l-1)/3
#    l=1 total=(4-1)/3 = 1
#    l=2 total=(16-1)/3 = 5
#    l=3 total=(64-1)/3=63/3 = 21
#
# n = 1 + (4^l-1)/3
# n-1 = (4^l-1)/3
# 3n-3 = (4^l-1)
# 3n-2 = 4^l
#
# 3^0+3^1+3^1+3^2 = 1+3+3+9=16
# x+3x+3x+9x = 16x = 256
#
#               22
# 20  19  18  17
#   12      11
# 21   9   8  16
#        6
#  5   4   7  15
#    2      10
#  1   3  13  14
#

sub n_to_xy {
  my ($self, $n) = @_;
  ### BoxFractalQuarter n_to_xy(): $n

  if ($n < 1) { return; }
  if (_is_infinite($n)) { return ($n,$n); }
  if ($n == 1) { return (0,0); }

  {
    my $int = int($n);
    ### $int
    ### $n
    if ($n != $int) {
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $frac = $n - $int;  # inherit possible BigFloat
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int;       # BigFloat int() gives BigInt, use that
  }

  my ($power, $exp) = _round_down_pow ($n, 5);

  ### $power
  ### $exp
  ### pow base: 1 + (4**$exp - 1)/3

  $n -= ($power - 1)/3 + 1;
  ### n less pow base: $n

  my @levelbits = (2**$exp);
  $power = 3**$exp;

  # find the cumulative levelpoints total <= $n, being the start of the
  # level containing $n
  #
  my $factor = 1;
  while (--$exp >= 0) {
    $power /= 3;
    my $sub = 4**$exp * $factor;
    ### $sub
    # $power*$factor;
    my $rem = $n - $sub;

    ### $n
    ### $power
    ### $factor
    ### consider subtract: $sub
    ### $rem

    if ($rem >= 0) {
      $n = $rem;
      push @levelbits, 2**$exp;
      $factor *= 3;
    }
  }

  ### @levelbits
  ### remaining n: $n
  ### assert: $n >= 0
  ### assert: $n < $factor

  my $x = 0;
  my $y = 0;
  while (@levelbits) {
    ($n, my $digit) = _divrem ($n, 3);
    ### levelbits: $levelbits[-1]
    ### $digit

    my $lbit = pop @levelbits;
    $x += $lbit;
    $y += $lbit;
    if (@levelbits) {
      if ($digit == 0) {
        ($x,$y) = ($y,-$x);   # rotate -90
      } elsif ($digit == 2) {
        ($x,$y) = (-$y,$x);   # rotate +90
      }
    }
    ### rotate to: "$x,$y"
    ### bit to x: "$x,$y"
  }

  ### final: "$x,$y"
  return $x-1,$y-1;
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### BoxFractalQuarter xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($x < 0 || $y < 0) {
    return undef;
  }
  if ($x == 0 && $y == 0) {
    return 1;
  }
  $x += 1;  # pushed away by 1 ...
  $y += 1;

  my ($len, $exp) = _round_down_pow ($x + $y, 2);
  if (_is_infinite($exp)) { return ($exp); }

  my $level =
    my $n =
      my $zero = ($x * 0 * $y);  # inherit bignum 0

  while ($exp-- >= 0) {
    ### at: "$x,$y  n=$n len=$len"

    # first quadrant square
    ### assert: $x >= 0
    ### assert: $y >= 0
    ### assert: $x < 2*$len
    ### assert: $y < 2*$len

    if ($x >= $len || $y >= $len) {
      # one of three quarters away from origin
      #     +---+---+
      #     | 2 | 1 |
      #     +---+---+
      #     |   | 0 |
      #     +---+---+

      $x -= $len;
      $y -= $len;
      ### shift to: "$x,$y"

      if ($x) {
        unless ($y) {
          return undef;  # x==0, y!=0, nothing
        }
      } else {
        if ($y) {
          return undef;  # x!=0, y-=0, nothing
        }
      }

      $level += $len;
      if ($x || $y) {
        $n *= 3;
        if ($y < 0) {
          ### bottom right, digit 0 ...
          ($x,$y) = (-$y,$x);  # rotate +90
        } elsif ($x >= 0) {
          ### top right, digit 1 ...
          $n += 1;
        } else {
          ### top left, digit 2 ...
          ($x,$y) = ($y,-$x);  # rotate -90
          $n += 2;
        }
      }
    }

    $len /= 2;
  }

  ### $n
  ### $level
  ### level n: _n_start($level)
  ### xy_to_n: $n + _n_start($level)

  return $n + _n_start($level);
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### BoxFractalQuarter rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  if ($x2 < 0 || $y2 < 0) {
    return (1, 0);  # nothing in first quadrant
  }

  if ($x1 < 0) { $x1 *= 0; }
  if ($y1 < 0) { $y1 *= 0; }

  # level numbers
  my $dlo = ($x1 > $y1 ? $x1 : $y1)+1;
  my $dhi = ($x2 > $y2 ? $x2 : $y2);
  ### $dlo
  ### $dhi

  # round down to level=2^k numbers
  if ($dlo) {
    ($dlo) = _round_down_pow ($dlo,2);
  }
  ($dhi) = _round_down_pow ($dhi,2);

  ### rounded to pow2: "$dlo  ".(2*$dhi)

  return (_n_start($dlo), _n_start(2*$dhi));
}

sub _n_start {
  my ($level) = @_;
  ### BoxFractalQuarter _n_start(): $level

  my ($power, $exp) = _round_down_pow ($level, 2);
  if (_is_infinite($power)) {
    return $power;
  }
  my $n = 1 + ($power*$power - 1)/3  - ($level==0);

  ### $power
  ### $exp
  ### $n

  $level -= $power;
  my $factor = 1;
  while ($exp--) {
    $power /= 2;
    if ($level >= $power) {
      $level -= $power;
      $n += $power*$power*$factor;
      ### add: $power*$factor
      $factor *= 3;
    }
  }
  ### n_start result: $n
  return $n;
}
### assert: _n_start(1) == 1
### assert: _n_start(2) == 2
### assert: _n_start(3) == 3
### assert: _n_start(4) == 6
### assert: _n_start(5) == 7
### assert: _n_start(6) == 10
### assert: _n_start(7) == 13
### assert: _n_start(8) == 22

1;
__END__

=for stopwords eg Ryde Math-PlanePath Ulam Warburton Nstart Nend

=head1 NAME

Math::PlanePath::BoxFractalQuarter -- growth of a 2-D cellular automaton

=head1 SYNOPSIS

 use Math::PlanePath::BoxFractalQuarter;
 my $path = Math::PlanePath::BoxFractalQuarter->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress ...>

This is the "box fractal" in a quarter of the plane.  Cells are numbered by
growth level and anti-clockwise within the level.


   13 |                                         ...
   12 |                                      31
   11 |                             30    29
   10 |                                27
    9 |                             26    28
    8 |  24    23          22    21
    7 |     16                15
    6 |  25    13          12    20
    5 |           10     9
    4 |               7
    3 |            6     8
    2 |   5     4          11    19
    1 |      2                14
   Y=0|   1     3          17    18
      |
      +--------------------------------------------
        X=0  1  2  3  4  5  6  7  8  9 10 11 12 13

In general each level always grows by 1 along the leading diagonal X=Y and
travels into the sides with a sort of diamond shaped tree pattern.

=head2 Level Ranges

Counting level 1 as the N=1 at the origin, level 2 as the next N=2, etc, the
number of new cells added in a growth level is

    levelcells(level) = 3^((count ternary 2s in level) - 1)

So level 1 has 3^(1-1)=1 cell, as does level 2 N=2.  Then level 3 has
3^(2-1)=3 cells N=3,N=4,N=5 because 3=0b11 has two 1 bits in binary.  The N
start and end for a level is the cumulative total of those before it,

    Nstart(level) = 1 + (levelcells(0) + ... + levelcells(level-1))

    Nend(level) = levelcells(0) + ... + levelcells(level)

For example level 3 ends at N=(1+1+3)=5.

    level    Nstart   levelcells     Nend
      1          1         1           1
      2          2         1           2
      3          3         3           5
      4          6         1           6
      5          7         3           9
      6         10         3          12
      7         13         9          21
      8         22         1          22
      9         23         3          25

For a power-of-2 level the Nstart sum is

    Nstart(2^a) = 1 + (4^a-1)/3

For example level=4=2^2 starts at N=1+(4^2-1)/3=6, or level=8=2^3 starts
N=1+(4^3-1)/3=22.

Further bits in the level value contribute powers-of-4 with a tripling for
each bit above.  So if the level number has bits a,b,c,d,etc in descending
order,

    level = 2^a + 2^b + 2^c + 2^d ...       a>b>c>d...
    Nstart = 1 + (4^a-1)/3
               +       4^b
               +   3 * 4^c
               + 3^2 * 4^d + ...

For example level=6 = 2^2+2^1 is Nstart = 1+(4^2-1)/3 + 4^1 = 10.  Or
level=7 = 2^2+2^1+2^0 is Nstart = 1+(4^2-1)/3 + 4^1 + 3*4^0 = 13.

=head2 Self-Similar Replication

The square shape growth up to a level 2^a repeats three times.  For example
a 5-cell "a" part,

    |  d   d   c   c
    |    d       c
    |  d   d   c   c
    |        *
    |  a   a   b   b
    |    a       b
    |  a   a   b   b
    +--------------------

The 2x2 square "a" repeats, pointing SE, NE and NW as "b", "c" and "d".
This resulting 4x4 square then likewise repeats.  The points in the path
here are numbered by growth level rather than by this sort of replication,
but the replication helps to see the structure of the pattern.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::BoxFractalQuarter-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 1 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::UlamWarburtonQuarter>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2012 Kevin Ryde

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
