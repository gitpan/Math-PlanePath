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


package Math::PlanePath::Diagonals;
use 5.004;
use strict;
use warnings;
use List::Util qw(min max);
use POSIX 'floor';

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION', '@ISA';
$VERSION = 2;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use constant x_negative => 0;
use constant y_negative => 0;

#   0    1    2    3     4
#   1    2    4    7   11
# 0.5  1.5  3.5  6.5  10.5
#    +1   +2   +3   +4
#       1    1    1
#
# n = 0.5*$s*$s + 0.5*$s + 0.5
# s = 1/2 * (-1 + sqrt(4*2n + 1 - 4))
# s = -1/2 + sqrt(2n - 3/4)

sub n_to_xy {
  my ($self, $n) = @_;
  ### Diagonals n_to_xy: $n
  return if $n < .5;

  # at $n==-.5 have s==0, so int() is as good as floor()
  my $s = int (-.5 + sqrt(2*$n - .75));
  $n -= 0.5 * ($s*($s+1) + 1);
  ### sub: 0.5 * ($s*($s+1) + 1)
  ### $s
  ### remainder: $n
  return ($n - 0.5,
          $s + 0.5 - $n);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = floor ($x + 0.5);
  $y = floor ($y + 0.5);
  if ($x < 0 || $y < 0) {
    return undef;  # outside 
  }
  my $s = $x + $y;
  return $s*($s+1)/2 + $x + 1;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = floor ($x1 + 0.5);
  $y1 = floor ($y1 + 0.5);
  $x2 = floor ($x2 + 0.5);
  $y2 = floor ($y2 + 0.5);

  my $x = max(0, $x1,$x2);
  my $y = max(0, $y1,$y2);
  my $row = $x + $y;

  # ENHANCE-ME: find actual minimum if rect doesn't cover 0,0
  return (1,
          1 + ($row + 1)**2);
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
          ----------------------
           x=0,  1   2   3   4 ...

The horizontal sequence 1,3,6,10,etc at y=0 is the triangular numbers
s*(s+1)/2.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::Diagonals-E<gt>new (key=E<gt>value, ...)>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> on the path.

For C<$n < 0.5> the return is an empty list, it being considered the path
begins at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x>,C<$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each
point C<$n> as a square of side 1, so the quadrant x>=-0.5, y>=-0.5 is
entirely covered.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::Rows>,
L<Math::PlanePath::Columns>,
L<Math::PlanePath::Corner>

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
