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


package Math::PlanePath::PyramidSides;
use 5.004;
use strict;
use warnings;
use List::Util qw(max);
use POSIX 'floor';

use vars '$VERSION', '@ISA';
$VERSION = 1;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant y_negative => 0;

# Going 0 based
#                         20
#                     19  12  21
#                 18  11   6  13  22
#             17  10   5   2   7  14  23
#         16   9   4   1   0   3   8  15  24     y=0
#
# puts the squares at y=0 going x negative, with length s=floor(sqrt(n)) up
# to the peak.

sub n_to_xy {
  my ($self, $n) = @_;
  ### PyramidSides n_to_xy: $n
  return if $n < 0.5;

  my $s = int(sqrt ($n - .5));
  ### s frac: sqrt ($n - .5)
  ### $s
  $n -= $s*($s+1) + 1;
  ### rem: $n
  if ($n < 0) {
    return ($n,
            $s + $n);
  } else {
    return ($n,
            $s - $n);
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### PyramidSides xy_to_n(): $x, $y

  $y = floor ($y + 0.5);
  if ($y < 0) {
    return undef;
  }
  $x = floor ($x + 0.5);

  my $s = abs($x) + $y;
  return $s*$s + $x+$s + 1;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = floor ($x1 + 0.5);
  $y1 = floor ($y1 + 0.5);
  $x2 = floor ($x2 + 0.5);
  $y2 = floor ($y2 + 0.5);

  my $y = max ($y1, $y2);
  if ($y < 0) {
    return (1, 1);
  }
  my $x = max (abs($x1),abs($x2));
  my $s = $x + $y;

  # ENHANCE-ME: actual minimum something at centre if not covering y=0
  return (1,
          1 + ($s+1)**2);
}

1;
__END__

=for stopwords pronic PyramidRows versa PlanePath Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::PyramidSides -- points along the sides of pyramid

=head1 SYNOPSIS

 use Math::PlanePath::PyramidSides;
 my $path = Math::PlanePath::PyramidSides->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path puts points in layers along the sides of a pyramid growing
upwards.

                        21                          4
                    20  13  22                      3
                19  12   7  14  23                  2
            18  11   6   3   8  15  24              1
        17  10   5   2   1   4   9  16  25    <-  y=0

                         ^
    ... -4  -3  -2  -1  x=0  1   2   3   4 ...

The horizontal 1,4,9,16,etc at the bottom going right is the perfect
squares.  The vertical 2,6,12,20,etc at x=-1 is the pronic numbers s*(s+1),
half way between those successive squares.

The pattern is the same as the Corner path but widened out so that the
single quadrant in the Corner becomes a half-plane here.

The pattern is similar to PyramidRows, just with the columns dropped down
vertically to start at the X axis.  Any pattern occurring within a column is
unchanged, but what was a row becomes a diagonal and vice versa.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::PyramidSides-E<gt>new (key=E<gt>value, ...)>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> on the path.

For C<$n < 0.5> the return is an empty list, it being considered there are no
negative points in the pyramid.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x>,C<$y>.  C<$x> and C<$y> are
each rounded to the nearest integer which has the effect of treating points
in the pyramid as a squares of side 1, so the half-plane y>=-0.5 is entirely
covered.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PyramidRows>,
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
