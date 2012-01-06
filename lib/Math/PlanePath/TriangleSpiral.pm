# Copyright 2010, 2011 Kevin Ryde

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


package Math::PlanePath::TriangleSpiral;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 63;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Smart::Comments;


# base at bottom right corner
#   d = [ 1,  2,  3 ]
#   n = [ 2,  11, 29 ]
#   $d = 1/2 + sqrt(2/9 * $n + -7/36)
#      = 1/2 + sqrt(8/36 * $n + -7/36)
#      = 0.5 + sqrt(8*$n + -7)/6
#      = (1 + 2*sqrt(8*$n + -7)/6) / 2
#      = (1 + sqrt(8*$n + -7)/3) / 2
#      = (3 + sqrt(8*$n - 7)) / 6
#
#   $n = (9/2*$d**2 + -9/2*$d + 2)
#      = (4.5*$d - 4.5)*$d + 2
#
# top of pyramid
#   d = [ 1,  2,  3 ]
#   n = [ 4, 16, 37 ]
#   $n = (9/2*$d**2 + -3/2*$d + 1)
# so remainder from there
#   rem = $n - (9/2*$d**2 + -3/2*$d + 1)
#       = $n - (4.5*$d*$d - 1.5*$d + 1)
#       = $n - ((4.5*$d - 1.5)*$d + 1)
#
#
sub n_to_xy {
  my ($self, $n) = @_;
  #### TriangleSpiral n_to_xy: $n
  if ($n < 1) { return; }
  if ($n < 2) { return ($n - 1, 0); }

  my $d = int ((3 + sqrt(8*$n - 7)) / 6);
  #### d frac: (0.5 + sqrt(8*$n + -7)/6)
  #### $d
  #### base: 4*$d*$d + -4*$d + 2

  $n -= ((9*$d - 3)*$d/2 + 1);
  #### remainder: $n

  if ($n <= 3*$d) {
    ### sides, remainder pos/neg from top
    return (-$n,
            2*$d - abs($n));
  } else {
    ### rightwards from bottom left
    ### remainder: $n - 3*$d
    # corner is x=-3*$d
    # so -3*$d + 2*($n - 3*$d)
    #  = -3*$d + 2*$n - 6*$d
    #  = -9*$d + 2*$n
    #  = 2*$n - 9*$d
    return (2*$n - 9*$d,
            -$d);
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  ### xy_to_n(): "$x,$y"

  if (($x ^ $y) & 1) {
    return undef;  # nothing on odd squares
  }

  if ($y < 0 && 3*$y <= $x && $x <= -3*$y) {
    ### bottom horizontal
    # negative y, at vertical x=0
    #   [  -1, -2,   -3, -4,  -5,   -6 ]
    #   [ 8.5, 25, 50.5, 85, 128.5, 181 ]
    #   $n = (9/2*$y**2 + -3*$y + 1)
    #      = (4.5*$y*$y + -3*$y + 1)
    #      = ((4.5*$y -3)*$y + 1)
    # from which $x/2
    #
    return ((9*$y - 6)*$y/2 + 1) + $x/2;

  } else {
    ### sides diagonal
    #
    # positive y, x=0 centres
    #   [ 2,  4,  6,  8 ]
    #   [ 4, 16,  37, 67 ]
    #   n = (9/8*$d**2 + -3/4*$d + 1)
    #     = (9/8*$d + -3/4)*$d + 1
    #     = (9*$d + - 6)*$d/8 + 1
    # from which -$x offset
    #
    my $d = abs($x) + $y;
    return ((9*$d - 6)*$d/8 + 1) - $x;
  }
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);
  my $d = 0;
  foreach my $x ($x1, $x2) {
    foreach my $y ($y1, $y2) {
      $d = _max ($d,
                1 + ($y < 0 && 3*$y <= $x && $x <= -3*$y
                     ? -$y                          # bottom horizontal
                     : int ((abs($x) + $y) / 2)));  # sides
    }
  }
  return (1,
          (9*$d - 9)*$d/2 + 2);
}

1;
__END__

=for stopwords TriangleSpiral PlanePath Ryde Math-PlanePath HexSpiral hendecagonal 11-gonal (s+2)-gonal

=head1 NAME

Math::PlanePath::TriangleSpiral -- integer points drawn around an equilateral triangle

=head1 SYNOPSIS

 use Math::PlanePath::TriangleSpiral;
 my $path = Math::PlanePath::TriangleSpiral->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes a spiral shaped as an equilateral triangle (each side the
same length).  Cells are spread horizontally to fit on a square grid.

                      16                                 4
                   17    15                              3
                18     4    14   ...                     2
             19     5     3    13    32                  1
          20     6     1     2    12    31          <- y=0
       21     7     8     9    10    11    30           -1
    22    23    24    25    26    27    28    29        -2

                       ^
    -6 -5 -4 -3 -2 -1 x=0 1  2  3  4  5  6  7  8

Each horizontal gap is 2, so for instance n=1 is at x=0,y=0 then n=2 is at
x=2,y=0.  The diagonals are 1 across and 1 up or down, so n=3 is at x=1,y=1.
Each alternate row is thus offset from the one above or below.  The
resulting little triangles between the points are flatter than they ought to
be.  Drawn on a square grid the angle up is 45 degrees making an isosceles
right triangle instead of 60 for an equilateral triangle, but at least the
two sides slope down at the same angle.

This grid is the same as the HexSpiral and the path is like that spiral
except instead of a flat top it extends to a triangular peak and the lower
left and right extend out similarly.  The result is a longer loop, and each
successive cycle is 9 longer than the previous (whereas the HexSpiral takes
6 more).

The triangular numbers 1, 3, 6, 10, 15, 21, 28, 36 etc, k*(k+1)/2, fall one
before the successive corners of the triangle, so when plotted make three
lines going vertically and angled down left and right.

The 11-gonal "hendecagonal" numbers 11, 30, 58, etc, k*(9k-7)/2 fall on a
straight line horizontally to the right.  (As per the general rule that a
step "s" lines up the (s+2)-gonal numbers.)

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::TriangleSpiral-E<gt>new ()>

Create and return a new triangle spiral object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n < 1> the return is an empty list, it being considered the path
starts at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each
C<$n> in the path as a square of side 1.

Only every second square in the plane has an N.  If C<$x,$y> is a
position without an N then the return is C<undef>.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::TriangleSpiralSkewed>,
L<Math::PlanePath::HexSpiral>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2010, 2011 Kevin Ryde

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
