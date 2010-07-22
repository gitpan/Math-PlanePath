# Copyright 2010 Kevin Ryde

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


package Math::PlanePath::DiamondSpiral;
use 5.004;
use strict;
use warnings;
use List::Util qw(max);
use POSIX 'floor';

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 5;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

# 
# start cycle at the vertical downwards from x=1,y=0
# s = [ 0, 1,  2, 3 ]
# n = [ 2, 6, 14,26 ]
# n = 2*$s*$s - 2*$s + 2
# s = .5 + sqrt(.5*$n-.75)
#
# then top of the diamond at 2*$s - 1
# so n - (2*$s*$s - 2*$s + 2 + 2*$s - 1)
#    n - (2*$s*$s + 1)
#
# gives y=$s - n
# then x=$s-abs($y) on the right or x=-$s+abs($y) on the left
#
sub n_to_xy {
  my ($self, $n) = @_;
  #### n_to_xy: $n
  if ($n < 1) { return; }
  if ($n < 2) { return ($n-1, 0); }

  my $s = int (.5 + sqrt(.5*$n-.75));
  #### $s
  #### s frac: .5 + sqrt(.5*$n-.75)
  #### base: 2*$s*$s - 2*$s + 2
  #### extra: 2*$s - 1
  #### sub: 2*$s*$s +1

  $n -= 2*$s*$s + 1;
  ### rem from top: $n

  my $y = $s - abs($n);  # y=+$s at the top, down to y=-$s
  my $x = abs($y) - $s;  # 0 to $s on the right
  #### uncapped y: $y
  #### abs x: $x

  return (($n >= 0 ? $x : -$x),  # negate if on the right
          max ($y, -$s));        # cap for horiz at 5 to 6, 13 to 14 etc
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = floor ($x + 0.5);
  $y = floor ($y + 0.5);
  my $s = abs($x) + abs($y);

  # vertical along the y>=0 axis
  # s=0  n=1
  # s=1  n=3
  # s=2  n=9
  # s=3  n=19
  # s=4  n=33
  # n = 2*$s*$s + 1
  #
  my $n = 2*$s*$s + 1;

  # then +/- $s to go to left or right x axis, and -/+ $y from there
  if ($x > 0) {
    ### right quad 1 and 4
    return $n - $s + $y;
  } else {
    # left quads 2 and 3
    return $n + $s - $y;
  }
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### DiamondSpiral xy_to_n_range()

  my $x = floor (0.5 + max(abs($x1),abs($x2)));
  my $y = floor (0.5 + max(abs($y1),abs($y2)));
  my $s = abs($x) + abs($y) + 1;
  ### gives: "$x, $y  sum $s is " . (2*$s*$s - 2*$s + 1)

  # ENHANCE-ME: find actual minimum if rect doesn't cover 0,0
  return (1,
          1 + 2*$s*$s - 2*$s + 1);
}

1;
__END__

#                 19
#               /    \
#             20   9  18
#           /    /   \   \
#         21  10   3   8  17
#       /    /   /   \  \   \
#     22  11   4   1---2   7  16    <- y=0
#       \    \   \       /   /
#         23  12   5---6  15  ...
#           \   \        /   /
#             24  13--14  27
#               \        /
#                 25--26 
# 
#                  ^
#                 x=0

=for stopwords SquareSpiral eg DiamondSpiral PlanePath Ryde Math-PlanePath HexSpiralSkewed ascii

=head1 NAME

Math::PlanePath::DiamondSpiral -- integer points in a diamond shape

=head1 SYNOPSIS

 use Math::PlanePath::DiamondSpiral;
 my $path = Math::PlanePath::DiamondSpiral->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes a diamond shaped spiral.

             19 ..
          20  9 18 ..
       21 10  3  8 17 ..
    22 11  4  1  2  7 16 ..  <- y=0
       23 12  5  6 15 ..
          24 13 14 ..
             25 26 

              ^
             x=0

This is not simply the SquareSpiral rotated, it spirals around faster, with
side lengths following a pattern 1,1,1,1, 2,2,2,2, 3,3,3,3, if the flat kink
at the bottom (like 13 to 14) is treated as part of the lower right
diagonal.

The triangular number 3,6,10,15,21,etc fall alternately on the horizontal to
the left at y=1 and the right at y=-1 (one term to the left then one term to
the right).

Going diagonal on the sides is like cutting the corners going around a
SquareSpiral, which is how it gets around in fewer steps.  See the
HexSpiralSkewed for similar cutting just two of the four corners.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::DiamondSpiral-E<gt>new ()>

Create and return a new DiamondSpiral spiral object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> on the path.

For C<$n < 1> the return is an empty list, it being considered the path
starts at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each
point in the path as a square of side 1, so the entire plane is covered.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SquareSpiral>,
L<Math::PlanePath::HexSpiralSkewed>,
L<Math::PlanePath::PyramidSides>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Math-PlanePath is Copyright 2010 Kevin Ryde

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