# Copyright 2010, 2011, 2012 Kevin Ryde

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

use vars '$VERSION', '@ISA';
$VERSION = 69;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_round_nearest = \&Math::PlanePath::_round_nearest;

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

  my $s = int ((1 + sqrt(int(2*$n)-3)) / 2);
  #### $s
  #### s frac: ((1 + sqrt(int(2*$n)-3)) / 2)
  #### base: 2*$s*$s - 2*$s + 2
  #### extra: 2*$s - 1
  #### sub: 2*$s*$s +1

  $n -= 2*$s*$s + 1;
  ### rem from top: $n

  my $y = -abs($n) + $s;  # y=+$s at the top, down to y=-$s
  my $x = abs($y) - $s;  # 0 to $s on the right
  #### uncapped y: $y
  #### abs x: $x

  # cap for horiz at 5 to 6, 13 to 14 etc
  $s = -$s;
  if ($y < $s) { $y = $s; }

  return (($n >= 0 ? $x : -$x),  # negate if on the right
          $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
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

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### DiamondSpiral rect_to_n_range(): "$x1,$y1, $x2,$y2"

  $x1 = abs (_round_nearest ($x1));
  $y1 = abs (_round_nearest ($y1));
  $x2 = abs (_round_nearest ($x2));
  $y2 = abs (_round_nearest ($y2));

  my $x = ($x1 > $x2 ? $x1 : $x2);
  my $y = ($y1 > $y2 ? $y1 : $y2);
  my $s = $x + $y + 1;
  ### gives: "$x, $y  sum $s is " . (2*$s*$s - 2*$s + 1)

  # ENHANCE-ME: find actual minimum if rect doesn't cover 0,0
  # ENHANCE-ME: cf UlamWarburton _rect_to_diamond_range()
  return (1,
          1 + 2*$s*($s-1));
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

=for stopwords SquareSpiral eg DiamondSpiral PlanePath Ryde Math-PlanePath HexSpiralSkewed PentSpiralSkewed HeptSpiralSkewed 

=head1 NAME

Math::PlanePath::DiamondSpiral -- integer points around a diamond shaped spiral

=head1 SYNOPSIS

 use Math::PlanePath::DiamondSpiral;
 my $path = Math::PlanePath::DiamondSpiral->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes a diamond shaped spiral.

                            73                               6
                        74  51  72                           5
                    75  52  33  50  71                       4
                76  53  34  19  32  49  70                   3
            77  54  35  20   9  18  31  48  69               2
        78  55  36  21  10   3   8  17  30  47  68           1
    79  56  37  22  11   4   1   2   7  16  29  46  67   <- Y=0
        80  57  38  23  12   5   6  15  28  45  66          -1
            81  58  39  24  13  14  27  44  65  ...         -2
                82  59  40  25  26  43  64  89              -3
                    83  60  41  42  63  88                  -4
                        84  61  62  87                      -5
                            85  86                          -6

                             ^
    -6  -5  -4  -3  -2  -1  X=0  1   2   3   4   5   6

This is not simply the SquareSpiral rotated, it spirals around faster, with
side lengths following a pattern 1,1,1,1, 2,2,2,2, 3,3,3,3, etc, if the flat
kink at the bottom (like N=13 to N=14) is treated as part of the lower right
diagonal.

The hexagonal numbers 6,15,28,45,66,etc, k*(2k-1) from k=2 up, are the
horizontal line at Y=-1 going to the right.  The hexagonal numbers of the
"second kind" 3,10,21,36,55,78, etc k*(2k+1), are the horizontal line at Y=1
going to the left.  Combining those two is the triangular numbers
3,6,10,15,21,etc, k*(k+1)/2, alternately on one line and the other.

Going diagonally on the sides as done here is like cutting the corners of
the SquareSpiral, which is how it gets around in fewer steps than the
SquareSpiral.  See PentSpiralSkewed, HexSpiralSkewed and HeptSpiralSkewed
for similar cutting just 3, 2 or 1 of the corners.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::DiamondSpiral-E<gt>new ()>

Create and return a new diamond spiral object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n < 1> the return is an empty list, it being considered the path
starts at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each
point in the path as a square of side 1, so the entire plane is covered.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DiamondArms>,
L<Math::PlanePath::SquareSpiral>,
L<Math::PlanePath::HexSpiralSkewed>,
L<Math::PlanePath::PyramidSides>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2010, 2011, 2012 Kevin Ryde

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
# compile-command: "math-image --path=DiamondSpiral --lines --scale=10"
# End:
#
# math-image --path=DiamondSpiral --all --output=numbers --size=60x14
