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


package Math::PlanePath::PyramidRows;
use 5.004;
use strict;
use warnings;
use List::Util qw(min max);
use POSIX 'floor';

use vars '$VERSION', '@ISA';
$VERSION = 1;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant y_negative => 0;

# row line beginning at x=-0.5,
# y =          0    1    2    3     4
# N start  = -0.5  1.5  4.5  9.5  16.5
#
sub n_to_xy {
  my ($self, $n) = @_;
  ### PyramidRows n_to_xy(): $n
  return if $n < 0.5;

  my $s = int(sqrt ($n - .5));
  ### s frac: sqrt ($n - .5)
  ### $s
  ### rem: $n - $s*($s+1)
  return ($n - $s*($s+1) - 1,
          $s);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = floor ($x + 0.5);
  $y = floor ($y + 0.5);
  if ($y < 0 || $x < -$y || $x > $y) {
    return undef;
  } else {
    return $y*$y + 1 + $x+$y;
  }
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### PyramidRows rect_to_n_range()

  $x1 = floor ($x1 + 0.5);
  $y1 = floor ($y1 + 0.5);
  $x2 = floor ($x2 + 0.5);
  $y2 = floor ($y2 + 0.5);

  my $row_min = max(0, min($y1,$y2));
  my $row_max = max(0, max($y1,$y2)) + 1;

  return ($row_min*$row_min + 1,
          1 + $row_max*$row_max);
}

1;
__END__

=for stopwords pronic SacksSpiral PlanePath Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::PyramidRows -- points stacked up in a pyramid

=head1 SYNOPSIS

 use Math::PlanePath::PyramidRows;
 my $path = Math::PlanePath::PyramidRows->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path arranges points in successively wider rows going upwards so as to
form an upside-down pyramid.

    17  18  19  20  21  22  23  24  25         4
        10  11  12  13  14  15  16             3
             5   6   7   8   9                 2
                 2   3   4                     1
                     1                   <-  y=0

    -4  -3  -2  -1  x=0  1   2   3   4 ...


The right edge 1,4,9,16,etc is the perfect squares.  The vertical
2,6,12,20,etc at x=-1 is the pronic numbers s*(s+1), half way between those
successive squares.

Each row is 2 longer than the previous and in that respect this is the same
as the Corner and SacksSpiral paths.  Diagonals in the pyramid correspond to
Sacks spiral arms going to the right, and verticals in the pyramid
correspond to arms going left.

As with all the +2 stride paths a plot of the triangular numbers s*(s+1)/2
makes an attractive arcing pattern.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::PyramidRows-E<gt>new (key=E<gt>value, ...)>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> on the path.

For C<$n < 0> the return is an empty list, it being considered there are no
negative points in the pyramid.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x>,C<$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each
point in the pyramid as a square of side 1.  If C<$x>,C<$y> is outside the
pyramid the return is C<undef>.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PyramidSides>,
L<Math::PlanePath::Corner>,
L<Math::PlanePath::SacksSpiral>

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
