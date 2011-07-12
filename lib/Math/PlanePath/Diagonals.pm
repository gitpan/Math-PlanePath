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


package Math::PlanePath::Diagonals;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX 'floor';

use vars '$VERSION', '@ISA';
$VERSION = 35;

use Math::PlanePath;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant x_negative => 0;
use constant y_negative => 0;

# start each diagonal at 0.5 earlier
#
# s = [   0,   1,   2,   3,    4 ]
# n = [ 0.5, 1.5, 3.5, 6.5, 10.5 ]
#           +1   +2   +3   +4
#              1    1    1
#
# n = 0.5*$s*$s + 0.5*$s + 0.5
# s = 1/2 * (-1 + sqrt(4*2n + 1 - 4))
# s = -1/2 + sqrt(2n - 3/4)
#
# remainder n - (0.5*$s*$s + 0.5*$s + 0.5)
# is dist from x=-0.5 and y=$s+0.5
# work the 0.5 in so
#     n - (0.5*$s*$s + 0.5*$s + 0.5) - 0.5
#   = n - (0.5*$s*$s + 0.5*$s + 1)
#   = n - 0.5*$s*($s+1) + 1

sub n_to_xy {
  my ($self, $n) = @_;
  ### Diagonals n_to_xy: $n
  return if $n < .5;

  my $s = int (-.5 + sqrt(2*$n - .75));
  $n -= $s*($s+1)/2 + 1;
  ### sub: $s*($s+1)/2 + 1
  ### $s
  ### remainder: $n

  return ($n,
          $s - $n);
}

# round y on an 0.5 downwards so that x=-0.5,y=0.5 gives n=1 which is the
# inverse of n_to_xy() ... or is that inconsistent with other classes doing
# floor() always?
#
sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### xy_to_n(): $x, $y
  $x = floor ($x + 0.5);
  $y = floor (0.5 - $y);
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

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }
  if ($y2 < 0 || $x2 < 0) {
    return (1, 0); # rect all negative, no N
  }

  # exact range bottom left to top right
  return ($self->xy_to_n (max($x1,0),max($y1,0)),
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

    ...
      6  |  22
      5  |  16  23
      4  |  11  17  ...
      3  |   7  12  18  ...
      2  |   4   8  13  19  ...
      1  |   2   5   9  14  20  ...
    y=0  |   1   3   6  10  15  21  ...
          --------------------------
           x=0,  1   2   3   4 ...

The horizontal sequence 1,3,6,10,etc at y=0 is the triangular numbers
s*(s+1)/2.  If you plot them on a graph don't confuse that line with the
axis or border!

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::Diagonals-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n < 0.5> the return is an empty list, it being considered the path
begins at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each
point C<$n> as a square of side 1, so the quadrant x>=-0.5, y>=-0.5 is
entirely covered.

=back

=head1 FORMULAS

=head2 N Range

Within each row increasing X is increasing N, and each column increasing Y
is increasing N.  On that basis in a rectangle for C<rect_to_n_range> the
lower left corner is the minimum N and the upper right is the maximum N.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::Corner>,
L<Math::PlanePath::Rows>,
L<Math::PlanePath::Columns>

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
