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


package Math::PlanePath::Diagonals;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 76;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant class_x_negative => 0;
use constant class_y_negative => 0;
use constant n_frac_discontinuity => .5;

# start each diagonal at 0.5 earlier
#
#     s = [   0,   1,   2,   3,    4 ]
#     n = [ 0.5, 1.5, 3.5, 6.5, 10.5 ]
#               +1   +2   +3   +4
#                  1    1    1
#
#     n = 0.5*$s*$s + 0.5*$s + 0.5
#     s = 1/2 * (-1 + sqrt(4*2n + 1 - 4))
#     s = -1/2 + sqrt(2n - 3/4)
#       = [ -1 + sqrt(8n - 3) ] / 2
#
#     remainder n - (0.5*$s*$s + 0.5*$s + 0.5)
#     is dist from x=-0.5 and y=$s+0.5
#     work the 0.5 in so
#         n - (0.5*$s*$s + 0.5*$s + 0.5) - 0.5
#       = n - (0.5*$s*$s + 0.5*$s + 1)
#       = n - 0.5*$s*($s+1) + 1
#
# starting on the integers vertical at X=0
#
#     s = [   0,  1, 2, 3,  4 ]
#     n = [   1,  2, 4, 7, 11 ]
#
#     N = (1/2 d^2 + 1/2 d + 1)
#       = ((1/2*$d + 1/2)*$d + 1)
#       = (d+1)*d/2 + 1     one past triangular
#     d = -1/2 + sqrt(2 * $n -7/4)
#       = [-1 + sqrt(8*$n - 7)] / 2
#
sub n_to_xy {
  my ($self, $n) = @_;
  ### Diagonals n_to_xy(): "$n   ".(ref $n || '')

  my $int = int($n);  # BigFloat int() gives BigInt, use that
  $n -= $int;         # frac, preserving any BigFloat

  if (2*$n >= 1) {  # $frac >= 0.5
    $n -= 1;
    $int += 1;
  }
  ### $int
  ### $n
  return if $int < 1;

  ### sqrt of: (8*$int - 7).''
  my $s = int((sqrt(8*$int-7) - 1) / 2);

  $int -= $s*($s+1)/2 + 1;

  ### s: "$s"
  ### sub: ($s*($s+1)/2 + 1).''
  ### remainder: "$int"

  return ($n + $int,
          -$n - $int + $s);   # $n first so BigFloat not BigInt from $s
}

# round y on an 0.5 downwards so that x=-0.5,y=0.5 gives n=1 which is the
# inverse of n_to_xy() ... or is that inconsistent with other classes doing
# floor() always?
#
sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### xy_to_n(): $x, $y
  $x = _round_nearest ($x);
  $y = _round_nearest (- $y);
  ### rounded
  ### $x
  ### $y
  if ($x < 0 || $y > 0) {
    return undef;  # outside 
  }
  my $s = $x - $y;
  ### $s
  return $s*($s+1)/2 + $x + 1;
}

# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }
  if ($y2 < 0 || $x2 < 0) {
    return (1, 0); # rect all negative, no N
  }

  if ($x1 < 0) { $x1 *= 0; } # preserve bignum
  if ($y1 < 0) { $y1 *= 0; } # preserve bignum

  # exact range bottom left to top right
  return ($self->xy_to_n ($x1,$y1),
          $self->xy_to_n ($x2,$y2));
}

1;
__END__

=for stopwords PlanePath Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::Diagonals -- points in diagonal stripes

=head1 SYNOPSIS

 use Math::PlanePath::Diagonals;
 my $path = Math::PlanePath::Diagonals->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path follows successive diagonals going from the Y axis down to the X
axis.

      6  |  22
      5  |  16  23
      4  |  11  17  24
      3  |   7  12  18  ...
      2  |   4   8  13  19
      1  |   2   5   9  14  20
    Y=0  |   1   3   6  10  15  21
         + ------------------------
           X=0   1   2   3   4   5

The horizontal sequence 1,3,6,10,etc at Y=0 is the triangular numbers
s*(s+1)/2.  If you plot them on a graph don't confuse that line with the
axis or border!

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::Diagonals-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n E<lt> 0.5> the return is an empty list, it being considered the
path begins at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each
point C<$n> as a square of side 1, so the quadrant x>=-0.5, y>=-0.5 is
entirely covered.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

The returned range is exact, meaning C<$n_lo> and C<$n_hi> are the smallest
and biggest in the rectangle.

=back

=head1 FORMULAS

=head2 Rectangle to N Range

Within each row increasing X is increasing N, and in each column increasing
Y is increasing N.  So in a rectangle the lower left corner is the minimum N
and the upper right is the maximum N.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::Corner>,
L<Math::PlanePath::Rows>,
L<Math::PlanePath::Columns>,
L<Math::PlanePath::DiagonalsAlternating>

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
