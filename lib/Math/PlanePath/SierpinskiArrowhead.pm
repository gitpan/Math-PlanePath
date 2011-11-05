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


# math-image --path=SierpinskiArrowhead --lines --scale=10
# math-image --path=SierpinskiArrowhead --output=numbers


package Math::PlanePath::SierpinskiArrowhead;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX qw(floor ceil);

use vars '$VERSION', '@ISA';
$VERSION = 53;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;
use constant y_negative => 0;

sub n_to_xy {
  my ($self, $n) = @_;
  ### SierpinskiArrowhead n_to_xy(): $n
  if ($n < 0) {
    return;
  }
  if (_is_infinite($n)) {
    return ($n,$n);
  }

  my $x = int($n);
  my $y = $n - $x;  # fraction part
  $n = $x;
  $x = $y;

  my $len = 1;
  while ($n) {
    my $digit = ($n % 3);

    ### odd right: "$x,$y  len=$len"
    ### $digit
    if ($digit == 0) {

    } elsif ($digit == 1) {
      $x = $len - $x;  # mirror and offset
      $y += $len;

    } else {
      ($x,$y) = (($x+3*$y)/-2,             # rotate +120
                 ($x-$y)/2    + 2*$len);
    }
    $len *= 2;

    $n = int($n/3) || last;
    $digit = ($n % 3);
    $n = int($n/3);

    ### odd left: "$x,$y  len=$len"
    ### $digit
    if ($digit == 0) {

    } elsif ($digit == 1) {
      $x = - $x - $len;  # mirror and offset
      $y += $len;

    } else {
      ($x,$y) = ((3*$y-$x)/2,              # rotate -120
                 ($x+$y)/-2  + 2*$len)
    }
    $len *= 2;
  }

  ### final: "$x,$y"
  return ($x, $y);
}

# return ($pow, $exp) where $pow = 2**$exp >= $x
# FIXME: Math::BigInt log() returns nan
# for some places an estimate is enough here
sub _round_up_pow2 {
  my ($x) = @_;
  if ($x < 1) { $x = 1; }
  my $exp = ceil (log($x) / log(2));
  my $pow = 2 ** $exp;
  if ($pow < $x) {
    return (2*$pow, $exp+1)
  } else {
    return ($pow, $exp);
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  ### SierpinskiArrowhead xy_to_n(): "$x, $y"

  if ($y < 0 || (($x^$y) & 1)) {
    return undef;
  }

  my ($len, $level) = _round_up_pow2 ($y + ($y==$x || $y==-$x));
  ### pow2 round up: ($y + ($y==$x || $y==-$x))
  ### $len
  ### $level

  if (_is_infinite($level)) {
    return $level;
  }

  my $n = 0;
  while ($level) {
    $n *= 3;
    ### at: "$x,$y  level=$level"
    ### full len: $len
    $len /= 2;
    ### half len: $len

    if ($y < 0 || $x < -$y || $x > $y) {
      ### out of range
      return undef;
    }
    if ($y < $len + !($x==$y||$x==-$y)) {
      ### digit 0, first triangle, no change

    } else {
      if ($level & 1) {
        ### odd level
        if ($x > 0) {
          ### digit 1, right triangle
          $n += 1;
          $y -= $len;
          $x = - ($x-$len);
          ### shift right and mirror to: "$x,$y"
        } else {
          ### digit 2, left triangle
          $n += 2;
          $y -= 2*$len;
          ### shift down to: "$x,$y"
          ($x,$y) = ((3*$y-$x)/2,   # rotate -120
                     ($x+$y)/-2);
          ### rotate to: "$x,$y"
        }
      } else {
        ### even level
        if ($x < 0) {
          ### digit 1, left triangle
          $n += 1;
          $y -= $len;
          $x = - ($x+$len);
          ### shift right and mirror to: "$x,$y"
        } else {
          ### digit 2, right triangle
          $n += 2;
          $y -= 2*$len;
          ### shift down to: "$x,$y"
          ($x,$y) = (($x+3*$y)/-2,             # rotate +120
                     ($x-$y)/2);
          ### now: "$x,$y"
        }
      }
    }

    $level--;
  }

  if ($x == 0 && $y == 0) {
    return $n;
  } else {
    return undef;
  }
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### SierpinskiArrowhead rect_to_n_range() ...

  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1) }
  $y2 = _round_nearest ($y2);
  if ($y2 < 0) {
    return (1,0);
  }

  $x1 = _round_nearest ($x1);
  $x2 = _round_nearest ($x2);
  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1) }

  if ($x2 < -$y2 || $x1 > $y2) {
    return (1,0);  # outside diagonals X=Y, X=-Y
  }
  my $level = _log2_ceil ($y2+1);
  ### $y2
  ### $level
  return (0, 3 ** $level - 1);
}

sub _log2_ceil {
  my ($x) = @_;
  my $exp = ceil (log(max(1, $x)) / log(2));
  return $exp + (2 ** ($exp+1) <= $x);
}

1;
__END__


rows
         *           1 \
        * *          2 |
       *   *         2 |
      * * * *        4 /
     *       *       2 \
    * *     * *      4 | 2x prev 4
   *   *   *   *     4 |
  * * * * * * * *    8 /
 *               *   2 \
* *             * *  4 | 2x prev 8

cumulative

1
3
5
9
11 \
15 | *2+9
19 |
27 /
29 \
33 | *2+27
37
45
49
57
65
81



=for stopwords eg Ryde Sierpinski Nlevel ie bitwise-AND ZOrderCurve Math-PlanePath

=head1 NAME

Math::PlanePath::SierpinskiArrowhead -- self-similar triangular path traversal

=head1 SYNOPSIS

 use Math::PlanePath::SierpinskiArrowhead;
 my $path = Math::PlanePath::SierpinskiArrowhead->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is an integer version of the Sierpinski arrowhead path.  It follows a
self-similar triangular shape leaving middle triangle gaps.

    \
     27----26          19----18          15----14              8
             \        /        \        /        \
              25    20          17----16          13           7
             /        \                          /
           24          21                11----12              6
             \        /                 /
              23----22                10                       5
                                        \
                        5---- 6           9                    4
                      /        \        /
                     4           7---- 8                       3
                      \
                        3---- 2                                2
                               \
                                 1                             1
                               /
                              0                            <- Y=0

     -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7  8

The base figure is the N=0 to N=3 shape.  It's repeated up in mirror image
as N=3 to N=6 then across as N=6 to N=9.  At the next level the same is done
with the N=0 to N=9 shape, up as N=9 to N=18 and across as N=18 to N=27,
etc.

The X,Y coordinates are on a triangular lattice done in integers by using
every second X, per L<Math::PlanePath/Triangular Lattice>.

The base pattern is a triangle like

    3---------2 - - - - .
     \         \
         C  /   \  B  /
       \      D  \
          /       \ /
         . - - - - 1
          \       /
              A  /
            \   /
               /
              0

Higher levels go into the triangles A,B,C but the middle triangle D is not
traversed.  It's hard to see that omitted middle in the initial N=0 to N=27
above.  The following is more of the visited points, making it clearer

        *   * *   * *   *                 * *   * *   * *
         * *   * *   * *                 *   * *   * *
            * *   * *                     * *     *   *
           *         *                       *     * *
            * *   * *                       *   * *
               * *                           * *   *
              *   *                             * *
               * *                             *
                  * *   * *   * *   * *   * *   *
                 *   * *   * *   * *   * *   * *
                  * *     *   *     * *   * *
                     *     * *     *         *
                    *   * *         * *   * *
                     * *   *           * *
                        * *           *   *
                       *               * *
                        * *   * *   * *
                           * *   * *   *
                          *   *     * *
                           * *     *
                              * *   *
                             *   * *
                              * *
                                 *
                                *

=head2 Sierpinski Triangle

The path is related to the Sierpinski triangle or "gasket" by treating each
line segment as the side of a little triangle.  The N=0 to N=1 segment has a
triangle on the left, N=1 to N=2 on the right, and N=2 to N=3 underneath,
which are per the A,B,C parts shown above.  Notice there's no middle little
triangle "D" in the triplets of line segments.  In general a segment N to
N+1 has its little triangle to the left if N even or to the right if N odd.

This pattern of little triangles is why the N=4 to N=5 looks like it hasn't
visited the vertex of the triangular N=0 to N=9 -- the 4 to 5 segment is
standing in for a little triangle to the left of that segment.  Similarly
N=13 to N=14 and each alternate side midway through replication levels.

There's easier ways to generate the Sierpinski triangle though.  One of the
simplest is to take X,Y coordinates which have no 1 bit on common, ie. a
bitwise-AND,

    ($x & $y) == 0

which gives the shape in the first quadrant XE<gt>=0,YE<gt>=0.  The can also
be had with the ZOrderCurve path by plotting all numbers N which have no
digit 3 in their base-4 representation (see
L<Math::PlanePath::ZOrderCurve/Power of 2 Values>), as digit 3s in that case
are X,Y points with a 1 bit in common.

The attraction of this Arrowhead path is that it makes a connected stepwise
traversal through the pattern.

=head2 Level Sizes

Counting the N=0,1,2,3 part as level 1, each level goes from

    Nstart = 0
    Nlevel = 3^level

inclusive of the final triangle corner position.  For example level 2 is
from N=0 to N=3^2=9.  Each level doubles in size,

           0  <= Y <= 2^level
    - 2^level <= X <= 2^level

The final Nlevel position is alternately on the right or left,

    Xlevel = /  2^level      if level even
             \  - 2^level    if level odd

The Y axis is crossed, ie. X=0, at N=2,6,18,etc which is is 2/3 through the
level, ie. after two replications of the previous level,

    Ncross = 2/3 * 3^level
           = 2 * 3^(level-1)

=head2 Sideways

The arrowhead is sometimes drawn on its side, with a base along the X axis.
That can be had with a -60 degree rotation (see L<Math::PlanePath/Triangular
Lattice>),

    (3Y+X)/2, (Y-X)/2       rotate -60

The first point N=1 is then along the X axis at X=2,Y=0.  Or first apply a
mirroring -X then rotate to have it go diagonally upwards first.

    (3Y-X)/2, (Y+X)/2       mirror X and rotate -60

The plain -60 rotate puts the Nlevel=3^level point on the X axis for even
number level, and at the top peak for odd level.  With the extra mirroring
it's the other way around.  If drawing successive levels then the two ways
could be alternated to have the endpoint on the X axis each time if desired.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::SierpinskiArrowhead-E<gt>new ()>

Create and return a new arrowhead path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

If C<$n> is not an integer then the return is on a straight line between the
integer points.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SierpinskiArrowheadCentres>,
L<Math::PlanePath::SierpinskiTriangle>,
L<Math::PlanePath::KochCurve>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011 Kevin Ryde

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




    #                         27 ...                           8
    #                           \
    #                       .    26                            7
    #                           /
    #                   24----25     .                         6
    #                  /
    #                23     .    20----19                      5
    #                  \        /        \
    #              .    22----21    .     18                   4
    #                                    /
    #           4---- 5     .     .    17    .                 3
    #         /        \                 \
    #        3     .     6     .     .    16----15             2
    #         \         /                         \
    #     .     2     7     .    10----11     .    14          1
    #         /        \        /        \        /
    #  0---- 1     .     8---- 9     .    12----13    .    <- Y=0
    #
    # X=0 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 ...

