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

# math-image --path=CellularRule54 --all --scale=10
# math-image --path=CellularRule54 --all --output=numbers --size=132x50
#
# http://mathworld.wolfram.com/Rule54.html
# A118108
# A118109
#

package Math::PlanePath::CellularRule54;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 49;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant y_negative => 0;

#            left   add
# even  y=0    0     1
#         2    1     2
#         4    3     3
#         6    6     4
# left = y/2*(y/2+1)/2
#      = y*(y+2)/8   of 4-cell figures
# inverse y = -1 + sqrt(2 * $n + -1)
#
#            left   add
# odd   y=1    0     3
#         3    3     6
#         5    9     9
#         7   18    12
# left = 3*(y-1)/2*((y-1)/2+1)/2
#      = 3*(y-1)*(y+1)/8     of 4-cell figures
#
# nbase y even = y*(y+2)/8 + 3*((y+1)-1)*((y+1)+1)/8
#              = [ y*(y+2) + 3*y*(y+2) ] / 8
#              = y*(y+2)/2
# y=0  nbase=0
# y=2  nbase=4
# y=4  nbase=12
# y=6  nbase=24
#
# nbase y odd = 3*(y-1)*(y+1)/8  + (y+1)*(y+3)/8
#             = (y+1) * (3y-3 + y+3)/8
#             = (y+1)*4y/8
#             = y*(y+1)/2
# y=1  nbase=1
# y=3  nbase=6
# y=5  nbase=15
# y=7  nbase=28
# inverse y = -1/2 + sqrt(2 * $n + -7/4)
#           = sqrt(2n-7/4) - 1/2
#           = (2*sqrt(2n-7/4) - 1)/2
#           = (sqrt(4n-7)-1)/2
#
# dual
# d = [ 0, 1,  2,  3 ]
# N = [ 1, 5, 13, 25 ]
# N = (2 d^2 + 2 d + 1)
#   = ((2*$d + 2)*$d + 1)
# d = -1/2 + sqrt(1/2 * $n + -1/4)
#   = sqrt(1/2 * $n + -1/4) - 1/2
#   = [ 2*sqrt(1/2 * $n + -1/4) - 1 ] / 2
#   = [ sqrt(4/2 * $n + -4/4) - 1 ] / 2
#   = [ sqrt(2*$n - 1) - 1 ] / 2
#

sub n_to_xy {
  my ($self, $n) = @_;
  ### CellularRule54 n_to_xy(): $n

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;
    $n = $int;       # BigFloat int() gives BigInt, use that
    if ($frac >= 0.5) {
      $frac -= 1;
      $n += 1;
    }
    # -0.5 <= $frac < 0.5
    ### assert: $frac >= -0.5
    ### assert: $frac < 0.5
  }

  if ($n < 1) {
    return;
  }

  # d is the two-row group number, d=2*y, where n belongs
  # start of the two-row group is nbase = 2 d^2 + 2 d + 1
  #
  my $d = int ((sqrt(2*$n-1) - 1) / 2);
  $n -= ((2*$d + 2)*$d + 1);   # remainder within two-row
  ### $d
  ### remainder: $n
  if ($n <= $d) {
    # d+1 many points in the Y=0,2,4,6 etc even row, spaced 4*n apart
    $d *= 2;    # y=2*d
    return ($frac + 4*$n - $d,
            $d);
  } else {
    # 3*d many points in the Y=1,3,5,7 etc odd row, using 3 in 4 cells
    $n -= $d+1;    # remainder 0 upwards into odd row
    $d = 2*$d+1;   # y=2*d+1
    return ($frac + $n + int($n/3) - $d,
            $d);
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  ### CellularRule54 xy_to_n(): "$x,$y"

  if ($y < 0
      || $x < -$y
      || $x > $y) {
    return undef;
  }
  $x += $y;
  ### x centred: $x
  if ($y % 2) {
    ### odd row, 3 in 4 ...
    if (($x % 4) == 3) {
      return undef;
    }
    return $x - int($x/4) + $y*($y+1)/2 + 1;
  } else {
    ## even row, sparse ...
    if ($x % 4) {
      return undef;
    }
    return $x/4 + $y*($y+2)/2  + 1;
  }
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### CellularRule54 rect_to_n_range(): "$x1,$y1, $x2,$y2"

  $y1 = _round_nearest ($y1);
  $y2 = _round_nearest ($y2);
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); } # swap to y1<=y2
  if ($y2 < 0) {
    return (1, 0); # rect all negative, no N
  }

  $x1 = _round_nearest ($x1);
  $x2 = _round_nearest ($x2);
  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); } # swap to x1<=x2

  #     \        /
  #   y2 \      / +-----
  #       \    /  |
  #        \  /
  #         \/    x1
  #
  #        \        /
  #   ----+ \      /  y2
  #       |  \    /
  #           \  /
  #       x2   \/
  #
  my $nx2 = -$x2;
  if ($x1 > $y2
      || $nx2 > $y2) {  # x2 < -y2, done as -x2 > y2
    ### rect all off to the left or right, no N
    return (1, 0);
  }

  ### x1 to x2 top row intersects some of the pyramid
  ### assert: $x2 >= -$y2
  ### assert: $x1 <= $y2

  my $zero = ($x1 * 0 * $y1 * $x2 * $y2);  # inherit bignum

  #     \       | /
  #      \      |/
  #       \    /|       |
  #    y1  \  / +-------+
  #         \/  x1
  #
  if ($x1 > $y1) {
    ### x1 off to the right, y1 row is outside, increase y1
    $y1 = $x1;
  }

  #        \|       /
  #         \      /
  #         |\    /
  #  -------+ \  /   y1
  #        x2  \/
  if ($nx2 > $y1) {
    ### x2 off to the right, y1 row is outside, increase y1
    $y1 = $nx2;
  }
  ### new y1: "$y1"

  # nbase y even y*(y+2)/2
  # nbase y odd  y*(y+1)/2
  # y even end (y+1)*(y+2)/2
  # y odd end  (y+1)*(y+3)/2

  $y2 += 1;
  return ($zero + $y1*($y1 + 1 + ! ($y1 % 2))/2 + 1,  # even/odd left end
          $zero + $y2*($y2 + 1 + ! ($y2 % 2))/2);     # even/odd right end
}

1;
__END__

=for stopwords straight-ish PyramidRows Ryde Math-PlanePath ie hexagonals 18-gonal Xmax-Xmin

=head1 NAME

Math::PlanePath::CellularRule54 -- cellular automaton points

=head1 SYNOPSIS

 use Math::PlanePath::CellularRule54;
 my $path = Math::PlanePath::CellularRule54->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is the pattern of Stephen Wolfram's "rule 54" cellular automaton
arranged as rows.

    29  30  31   .  32  33 34    .  35  36  37   .  38  39  40     7
        25   .   .   .  26   .   .   .  27   .   .   .  28         6
            16  17  18   .  19  20  21   .  22  23  24             5
                13   .   .   .  14   .   .   .  15                 4
                     7   8   9   .  10  11  12                     3
                         5   .   .   .   6                         2
                             2   3   4                             1
                                 1                            <-  Y=0

    -7  -6  -5  -4  -3  -2  -1  X=0  1   2   3   4   5   6   7

The initial figure N=1,2,3,4 repeats in two-row groups with 1 cell gap
between figures.  Each two-row group has one extra figure, for a step of 4
more points than the previous two-row.

The rightmost N on the even rows Y=0,2,4,6 etc is the hexagonal numbers
N=1,6,15,28, etc k*(2k-1).  The hexagonal numbers of the "second kind" 1, 3,
10, 21, 36, etc j*(2j+1) are a steep sloping line upwards in the middle too.
Those two taken together are the triangular numbers 1,3,6,10,15 etc,
k*(k+1)/2.

The 18-gonal numbers 18,51,100,etc are the vertical line at X=-3 on every
fourth row Y=5,9,13,etc.

=head2 Row Ranges

The left end of each row is

    Nleft = Y*(Y+2)/2 + 1     if Y even
            Y*(Y+1)/2 + 1     if Y odd

The right end is

    Nright = (Y+1)*(Y+2)/2    if Y even
             (Y+1)*(Y+3)/2    if Y odd

           = Nleft(Y+1) - 1   ie. 1 before next Nleft

The row width Xmax-Xmin is 2*Y but with the gaps the number of visited
points in a row is less than that, being either about 1/4 or 3/4 of the
width on even or odd rows.

    rowpoints = Y/2 + 1        if Y even
                3*(Y+1)/2      if Y odd

For any Y of course the Nleft to Nright difference is the number of points
in the row too

    rowpoints = Nright - Nleft + 1

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::CellularRule54-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are each
rounded to the nearest integer, which has the effect of treating each cell
as a square of side 1.  If C<$x,$y> is outside the pyramid or on a skipped
cell the return is C<undef>.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PyramidRows>

http://mathworld.wolfram.com/Rule54.html

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