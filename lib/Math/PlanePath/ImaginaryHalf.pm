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


# math-image --path=ImaginaryHalf --lines --scale=10
# math-image --path=ImaginaryHalf --all --output=numbers_dash --size=80x50
#

package Math::PlanePath::ImaginaryHalf;
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

use vars '$VERSION', '@ISA';
$VERSION = 80;
@ISA = ('Math::PlanePath');


# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;
use constant class_y_negative => 0;

use constant parameter_info_array =>
  [{ name      => 'radix',
     share_key => 'radix_2',
     type      => 'integer',
     minimum   => 2,
     default   => 2,
     width     => 3,
   },
];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $radix = $self->{'radix'};
  if (! defined $radix || $radix <= 2) { $radix = 2; }
  $self->{'radix'} = $radix;
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### ImaginaryHalf n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  # is this sort of midpoint worthwhile? not documented yet
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

  my $radix = $self->{'radix'};
  my $xlen = my $ylen = ($n*0) + 1; # inherit bignum 1
  my $x = 0;
  my $y = 0;

  if (my @digits = _digit_split_lowtohigh($n, $radix)) {
    for (;;) {
      ### at: "n=$n  $x,$y"

      $x += (shift @digits) * $xlen;  # digits low to high
      @digits || last;
      $xlen *= $radix;

      $y += (shift @digits) * $ylen;  # digits low to high
      @digits || last;
      $ylen *= $radix;

      $x -= (shift @digits) * $xlen;  # digits low to high
      @digits || last;
      $xlen *= $radix;
    }
  }

  ### final: "$x,$y"
  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### ImaginaryHalf xy_to_n(): "$x, $y"

  $y = _round_nearest ($y);
  if (_is_infinite($y)) { return $y; }
  if ($y < 0) { return undef; }

  $x = _round_nearest ($x);
  if (_is_infinite($x)) { return $x; }

  my $radix = $self->{'radix'};
  my $n = ($x * 0 * $y);  # inherit bignum 0
  my $power = $n + 1;     # inherit bignum 1

  while ($x || $y) {
    ### xpos digit: $x % $radix
    my $digit = $x % $radix;
    $n += $digit*$power;
    $x = - int(($x-$digit)/$radix);
    $power *= $radix;

    ### y digit: $y % $radix
    $digit = $y % $radix;
    $n += $digit*$power;
    $y = int($y/$radix);
    $power *= $radix;

    $digit = $x % $radix;
    $n += $digit*$power;
    $x = - int(($x-$digit)/$radix);
    $power *= $radix;
  }
  return $n;
}

# Nlevel=2^level-1
#    66666666 55 55 5555 7.[16].7
#    66666666 55 55 5555 7.[16].7
#    66666666 33 22 4444 7.[16].7
#  9 66666666 33 01 4444 7.[16].7
#  ^        ^  ^  ^ ^    ^        ^
# -11      -3 -1  1 2    6       22
#
# X=1     when level=1
# X=1+1=2 when level=4
# X=2+4=6 when level=7
# X=6+16=22 when level=10
#
# X=0-2=-2 when level=3
# X=-2-8=-10  when level=6
# X=-10-32=-42 when level=9
#
# Y=1 k=0 want level=2
# Y=2 k=1 want level=5
# Y=4 k=2 want level=8
#
# X = 1 + 1 + 4 + 16 + 4^k
#   = 1 + (4^(k+1) - 1) / (4-1)
# X*(R2-1) = (R2-1) + R2^(k+1) - 1
# X*(R2-1) + 1 - (R2-1) = R2^(k+1)
# R2^(k+1) = (X-1)*(R2-1) + 1
# k+1 = round down pow (X-1)*(R2-1) + 1
# (1-1)*3+1=1    k+1=0   want level=1
# (2-1)*3+1=4    k+1=1   want level=4
# (6-1)*3+1=16   k+1=2   want level=7
# (22-1)*3+1=64  k+1=3   want level=10
#
# X = 1 + 2 + 8 + 32 + ... 2*4^k
#   = 1 + 2*(4^(k+1) - 1) / (4-1)
# X = 1 + R*(R2^(k+1) - 1) / (R2-1)
# R*(R2^(k+1) - 1) / (R2-1) = X-1
# R2^(k+1) - 1 = (X-1)*(R2-1)/R
# R2^(k+2) - R2 = (X-1)*(R2-1)*R
# R2^(k+2) = (X-1)*(R2-1)*R + R2
# (1-1)*3*2+4=4   k+2=1 want level=3
# (3-1)*3*2+4=16  k+2=2 want level=6
# (11-1)*3*2+4=64 k+2=3 want level=9

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### ImaginaryHalf rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $y1 = _round_nearest ($y1);
  $y2 = _round_nearest ($y2);
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  if ($y2 < 0) {
    return (1, 0);
  }

  $x1 = _round_nearest ($x1);
  $x2 = _round_nearest ($x2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;

  my $radix = $self->{'radix'};
  my $r2 = $radix*$radix;

  ### $x1
  ### $x2
  ### xpos mult: ($x2-1)*($r2-1) + 1
  ### xneg mult: (-1-$x1)*($r2-1)*$radix + $r2

  my ($xpos_len, $xpos_level)
    = ($x2 >= 0
       ? _round_down_pow (($x2-1)*($r2-1) + 1, $r2)
       : (1,0));
  $xpos_level = 3*$xpos_level + 1;

  my ($y_len, $y_level) = ($y2 > 0
                           ? _round_down_pow ($y2, $radix)
                           : (0, -1));
  $y_level = 3*$y_level + 2;

  my ($xneg_len, $xneg_level)
    = ($x1 < 0
       ? _round_down_pow ((-1-$x1)*($r2-1)*$radix + $r2, $r2)
       : (1,0));
  $xneg_level = 3*$xneg_level;

  ### $xpos_level
  ### $xneg_level
  ### $y_level
  ### $y_len

  my $zero = 0 * $x1 * $x2 * $y1 * $y2;
  my $r = $radix + $zero;

  if ($y_level > $xpos_level && $y_level > $xneg_level) {
    ### y biggest ...
    return (0, $y_len*$y_len*$y_len*$r*$r - 1);
  } else {
    return (0, $r ** max($xpos_level,$xneg_level) - 1);
  }
}

1;
__END__

=for stopwords eg Ryde Math-PlanePath quater-imaginary ZOrderCurve Radix ie ImaginaryBase radix Proth

=head1 NAME

Math::PlanePath::ImaginaryHalf -- half-plane replications in three directions

=head1 SYNOPSIS

 use Math::PlanePath::ImaginaryBase;
 my $path = Math::PlanePath::ImaginaryBase->new (radix => 4);
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is a half-plane variation on the ImaginaryBase path.

     54-55 50-51 62-63 58-59 22-23 18-19 30-31 26-27       3
       \     \     \     \     \     \     \     \
     52-53 48-49 60-61 56-57 20-21 16-17 28-29 24-25       2

     38-39 34-35 46-47 42-43  6--7  2--3 14-15 10-11       1
       \     \     \     \     \     \     \     \
     36-37 32-33 44-45 40-41  4--5  0--1 12-13  8--9   <- Y=0

    -------------------------------------------------
    -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5

The pattern can be seen by dividing into the following blocks,

    +---------------------------------------+
    | 22   23   18   19   30   31   26   27 |
    |                                       |
    | 20   21   16   17   28   29   24   25 |
    +---------+---------+-------------------+
    |  6    7 |  2    3 | 14   15   10   11 |
    |         +----+----+                   |
    |  4    5 |  0 |  1 | 12   13    8    9 |
    +---------+----+----+-------------------+

N=0 is at the origin, then N=1 is to the right.  Those two are repeated
above as N=2 and N=3.  Then that 2x2 repeated to the right as N=4 to N=7,
then 4x2 repeated below N=8 to N=16, and 4x4 to the right as N=16 to N=31,
etc.  The repetitions are successively to the right, above, left.  The
relative layout within a replication is unchanged.

This is similar to the ImaginaryBase, but where it repeats in 4 directions
there's only 3 here.  The ZOrderCurve is a 2 direction replication.

=head2 Radix

The C<radix> parameter controls the "r" used to break N into X,Y.  For
example C<radix =E<gt> 4> gives 4x4 blocks, with r-1 copies of the preceding
level at each stage.

     radix => 4  

     60 61 62 63 44 45 46 47 28 29 30 31 12 13 14 15      3
     56 57 58 59 40 41 42 43 24 25 26 27  8  9 10 11      2
     52 53 54 55 36 37 38 39 20 21 22 23  4  5  6  7      1
     48 49 50 51 32 33 34 35 16 17 18 19  0  1  2  3  <- Y=0

    --------------------------------------^-----------
    -12-11-10 -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3

Notice for X negative the parts replicate successively towards -infinity, so
the block N=16 to N=31 is first at X=-4, then N=32 at X=-8, N=48 at X=-12,
and N=64 at X=-16 (not shown).

=head2 Axis Values

N=0,1,4,5,8,9,etc on the X axis (positive and negative) are those integers
with a 0 at every third bit, starting from the second least significant bit.
This is simply demanding that the bits going to the Y coordinate must be 0.

    X axis Ns = binary ...__0__0__0_     with _ either 0 or 1
    in octal, digits 0,1,4,5 only

The N=0,1,8,9,etc on the X positive axis have the high 1 bit in the first
slot of a 3-bit group.  N=0,4,5,etc on the X negative axis have the high 1
bit in the second slot,

    X pos Ns = binary 1_0__0__0__0...0__0__0_
    in octal, high octal digit 1

    X neg Ns = binary  10__0__0__0...0__0__0_
    in octal, high octal digit 4 or 5

N=0,2,16,18,etc on the Y axis are conversely those integers with a 0s in
each two of three bits, again simply demanding the bits going to the X
coordinate must be 0.

    Y axis Ns = binary ..._00_00_00_0    with _ either 0 or 1
    in octal, digits 0,2 only

For a radix other than binary the pattern is the same.  Each "_" is any
digit of the given radix, and each 0 must be 0.  The high 1 bit for X
positive and negative becomes the high non-zero digit, 1 to radix-1.

=head2 Level Ranges

Because the X direction replicates twice for each once in the Y direction
the width grows at twice the rate, so width = height*height, after each 3
replications.  For this reason N values for a given Y grow quite rapidly.

=head2 Proth Numbers

The Proth numbers fall in columns on the path.

=cut

# the following image generated with
#   math-image --path=ImaginaryHalf --values=ProthNumbers --text --size=70x25

=pod

    *                               *                               *



    *                               *                               *



    *                               *                               *



    *               *               *               *               *



    *               *               *               *               *

                            *       *       *       *

    *       *       *       *       *       *       *       *       *

                            *   *   *   *   *       *
                                    *
    *       *       *       *   * *   * *   *       *       *       *

    -----------------------------------------------------------------
    -31    -23     -15     -7  -3-1 0 3 5   9      17       25     33

The height of the column follows the position of the number of zeros in X
ending ...1000..0001 in binary as this limits the "k" part of the Proth
numbers which can have N ending suitably.  Or for X negative the ending
...10111...11.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::ImaginaryBase-E<gt>new ()>

=item C<$path = Math::PlanePath::ImaginaryBase-E<gt>new (radix =E<gt> $r)>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::ImaginaryBase>,
L<Math::PlanePath::ZOrderCurve>

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
