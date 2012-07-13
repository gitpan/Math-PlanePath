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


package Math::PlanePath::TriangleSpiralSkewed;
use 5.004;
use strict;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use Math::PlanePath;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use vars '$VERSION', '@ISA';
$VERSION = 81;
@ISA = ('Math::PlanePath');


# uncomment this to run the ### lines
#use Smart::Comments;


# base at bottom right corner
#   r = [ 1,  2,  3 ]
#   n = [ 2,  11, 29 ]
#   $d = 1/2 + sqrt(2/9 * $n + -7/36)
#      = ( 3 + 6*sqrt(8/36 * $n + -7/36) ) / 6
#      = ( 3 + sqrt(8 * $n + -7) ) / 6
#      = (3 + sqrt(8*$n - 7)) / 6
#
#   $n = (9/2*$d**2 + -9/2*$d + 2)
#
# top corner is further 3*$d-1 along, so
#   rem = $n - (9/2*$d**2 + -9/2*$d + 2) - (3*$d - 1)
#       = $n - (9/2*$d**2 + -3/2*$d + 1)
#       = $n - (9/2*$d + -3/2)*$d + 1
#       = $n - (9*$d - 3)*$d/2 + 1
#   so go rem-2*$r rightwards from x=-2*$r, is x = rem - 4*$r
#
sub n_to_xy {
  my ($self, $n) = @_;
  #### TriangleSpiralSkewed n_to_xy: $n
  if ($n < 1) { return; }
  if ($n < 2) { return ($n - 1, 0); }

  my $d = int ((3 + sqrt(8*$n - 7)) / 6);
  #### d frac: (0.5 + sqrt(8*$n + -7)/6)
  #### $d

  $n -= (9*$d - 3)*$d/2 + 1;
  #### remainder: $n

  if ($n <= 3*$d) {
    ### right slope and left vertical
    my $x = - ($d + $n);
    return (max($x,-$d),
            2*$d - abs($n));
  } else {
    ### bottom horizontal
    return ($n - 4*$d,
            -$d);
  }
}

# vertical x=0
#   [ 1,  2,  3 ]
#   [ 3, 14, 34 ]
#   n = (9/2*$d**2 + -5/2*$d + 1)
#     = 4.5*$d*$d - 2.5*$d + 1
# 
# positive y, x=0 centres
#   [ 1,  2,  3 ]
#   [ 3, 13, 31 ]
#   n = (4*$d*$d + -2*$d + 1)
# 
sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  ### xy_to_n(): "$x,$y"

  if ($y < 0 && $y <= $x && $x <= -2*$y) {
    ### bottom horizontal

    # negative y, vertical at x=0
    #   [ -1, -2, -3, -4 ]
    #   [  8, 24, 49, 83 ]
    #   n = (9/2*$d**2 + -5/2*$d + 1)
    #
    return ((9*$y - 5)*$y/2 + 1) + $x;
  }
  if ($x < 0 && $x <= $y && $y <= 2*-$x) {
    ### left vertical

    # negative x, horizontal at y=0
    #   [ -1, -2, -3, -4 ]
    #   [  6, 20, 43, 75 ]
    #   n = (9/2*$d**2 + -1/2*$d + 1)
    #
    return ((9*$x - 1)*$x/2 + 1) - $y;
  }

  my $d = $x + $y;
  ### right slope
  ### $d

  # positive y, vertical at x=0
  #   [ 1,  2,  3,  4 ]
  #   [ 3, 14, 34, 63 ]
  #   n = (9/2*$d**2 + -5/2*$d + 1)
  #
  return ((9*$d - 5)*$d/2 + 1) - $x;
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
      $d = max ($d,
                1 + ($y < 0 && $y <= $x && $x <= -2*$y
                     ? -$y                          # bottom horizontal
                     : $x < 0 && $x <= $y && $y <= 2*-$x
                     ? -$x              # left vertical
                     : abs($x) + $y));  # right slope
    }
  }
  return (1,
          (9*$d - 9)*$d + 2);
}

1;
__END__

=for stopwords TriangleSpiral TriangleSpiralSkewed PlanePath Ryde Math-PlanePath 

=head1 NAME

Math::PlanePath::TriangleSpiralSkewed -- integer points drawn around a skewed equilateral triangle

=head1 SYNOPSIS

 use Math::PlanePath::TriangleSpiralSkewed;
 my $path = Math::PlanePath::TriangleSpiralSkewed->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes an spiral shaped as an equilateral triangle (each side the
same length), but skewed to the left to fit on a square grid,

    16                              4
    17 15                           3
    18  4 14                        2
    19  5  3 13                     1
    20  6  1  2 12 ...         <- y=0
    21  7  8  9 10 11 30           -1
    22 23 24 25 26 27 28 29        -2

           ^
    -2 -1 x=0 1  2  3  4  5

The properties are the same as the spread-out TriangleSpiral.  The triangle
numbers fall on straight lines as the do in the TriangleSpiral but the skew
means the top corner goes up at an angle to the vertical and the left and
right downwards are different angles plotted (but are symmetric by N count).

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::TriangleSpiralSkewed-E<gt>new ()>

Create and return a new skewed triangle spiral object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n < 1> the return is an empty list, it being considered the path
starts at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each N
in the path as centred in a square of side 1, so the entire plane is
covered.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::TriangleSpiral>

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
