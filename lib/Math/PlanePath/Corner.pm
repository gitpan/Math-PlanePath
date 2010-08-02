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


package Math::PlanePath::Corner;
use 5.004;
use strict;
use warnings;
use List::Util qw(max);
use POSIX 'floor';

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 6;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant x_negative => 0;
use constant y_negative => 0;

# same as PyramidSides, just 45 degress around

sub n_to_xy {
  my ($self, $n) = @_;
  ### Corner n_to_xy: $n
  return if $n < 0.5;

  my $s = int(sqrt ($n - .5));
  ### s frac: sqrt ($n - .5)
  ### $s
  $n -= $s*($s+1) + 1;
  ### rem: $n
  if ($n < 0) {
    return ($s + $n,
            $s);
  } else {
    return ($s,
            $s - $n);
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = floor ($x + 0.5);
  $y = floor ($y + 0.5);
  if ($x < 0 || $y < 0) {
    return undef;
  }

  if ($y >= $x) {
    # top edge
    return $y*$y + $x + 1;
  } else {
    # right edge
    $x++;
    return $x*$x - $y;
  }
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = floor ($x1 + 0.5);
  $y1 = floor ($y1 + 0.5);
  $x2 = floor ($x2 + 0.5);
  $y2 = floor ($y2 + 0.5);

  my $row = max($x1,$x2,$y1,$y2);
  if ($row < 0) {
    return (1, 1);
  }

  # n_max is the perfect square along the y=0 horizontal
  # ENHANCE-ME: find actual minimum if rect doesn't cover 0,0
  return (1,
          1 + POSIX::ceil($row + 1)**2);
}

1;
__END__

=for stopwords pronic SacksSpiral PyramidSides PlanePath Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::Corner -- points shaped in a corner

=head1 SYNOPSIS

 use Math::PlanePath::Corner;
 my $path = Math::PlanePath::Corner->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path puts points in layers working outwards from the corner of the
first quadrant.

    ...
      5  |  26 ................
      4  |  17  18  19  20  21 .
      3  |  10  11  12  13  22 .
      2  |   5   6   7  14  23 .
      1  |   2   3   8  15  24 .
    y=0  |   1   4   9  16  25 .
          ----------------------
           x=0,  1   2   3   4 ...

The horizontal 1,4,9,16,etc at y=0 is the perfect squares.  The diagonal
2,6,12,20,etc starting x=0,y=1 is the pronic numbers s*(s+1), half way
between those squares.

Each stripe across then down is 2 longer than the previous and in that
respect the corner is the same as the Pyramid and SacksSpiral paths.  The
Corner and the PyramidSides are the same thing, just with a stretch from a
single quadrant to two.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::Corner-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> on the path.

For C<$n < 0.5> the return is an empty list, it being considered there are
no points before 1 in the corner.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each
point as a square of side 1, so the quadrant x>=-0.5 and y>=-0.5 is entirely
covered.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PyramidRows>,
L<Math::PlanePath::PyramidSides>,
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
