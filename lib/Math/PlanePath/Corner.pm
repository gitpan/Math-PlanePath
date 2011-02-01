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


package Math::PlanePath::Corner;
use 5.004;
use strict;
use warnings;
use List::Util 'min','max';
use POSIX 'floor';

use vars '$VERSION', '@ISA';
$VERSION = 20;

use Math::PlanePath;
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
    $x = $x + 1; # no warnings if $d==inf
    return $x*$x - $y;
  }
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = floor ($x1 + 0.5);
  $y1 = floor ($y1 + 0.5);
  $x2 = floor ($x2 + 0.5);
  $y2 = floor ($y2 + 0.5);
  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }
  if ($y2 < 0 || $x2 < 0) {
    return (1, 0); # rect all negative, no N
  }

  $x1 = max($x1,0);
  $y1 = max($y1,0);

  my $y_min = $y1;
  if ($y_min <= $x1) {
    $y1 = min ($y2, $x1);
  }
  if ($y2 <= $x2) {
    $y2 = $y_min;
  }

  # exact range left column to right column
  return ($self->xy_to_n ($x1,$y1),
          $self->xy_to_n ($x2,$y2));
}

1;
__END__

=for stopwords pronic SacksSpiral PyramidSides PlanePath Ryde Math-PlanePath ie

=head1 NAME

Math::PlanePath::Corner -- points shaped in a corner

=head1 SYNOPSIS

 use Math::PlanePath::Corner;
 my $path = Math::PlanePath::Corner->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path puts points in layers working outwards from the corner of the
first quadrant.

      5  |  26 ...
      4  |  17  18  19  20  21
      3  |  10  11  12  13  22
      2  |   5   6   7  14  23
      1  |   2   3   8  15  24
    y=0  |   1   4   9  16  25
          ----------------------
           x=0   1   2   3   4

The horizontal 1,4,9,16,etc along Y=0 are the perfect squares, which is
simply because each further row/column stripe makes a one-bigger square,

                            10 11 12 13
               5  6  7       5  6  7 14
    2  3       2  3  8       2  3  8 15
    1  4       1  4  9       1  4  9 16

The diagonal 2,6,12,20,etc upwards from X=0,Y=1 are the pronic numbers
k*(k+1), half way between those squares.

Each row/column stripe is 2 longer than the previous, similar to the
PyramidRows, PyramidSides and SacksSpiral paths.  The Corner and the
PyramidSides are the same, just the PyramidSides stretched out to two
quadrants instead of one for this Corner.

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

=head1 FORMULAS

=head2 N to X,Y

Counting d=0 for the first row at y=0, then the start of that row
N=1,2,5,10,17,etc is

    StartN(d) = d^2 + 1

The current C<n_to_xy> code extends to the left by an extra 0.5 for
fractional N, so for example N=9.5 is at x=-0.5,y=3.  With this the starting
N for each d row is

    StartNfrac(d) = d^2 + 0.5

Inverting gives the row for an N,

    d = floor(sqrt(N - 0.5))

And subtracting that start gives an offset into the row

    RemStart = N - StartNfrac(d)

The corner point 1,3,7,13,etc where the row turns down is at d+0.5 into that
remainder, and it's convenient to subtract that, giving a negative for the
horizontal or positive for the vertical,

    Rem = RemStart - (d+0.5)
        = N - (d*(d+1) + 1)

And the x,y coordinates thus

    if (Rem < 0)  then x=d+Rem, y=d
    if (Rem >= 0) then x=d, y=d-Rem

=head2 X,Y to N

For a given x,y the bigger of x or y determines the d row.  If y>=x then x,y
is on the horizontal part with d=y and in that case StartN(d) above is the N
for x=0, and the given x can be added to that,

    N = StartN(d) + x
      = y^2 + 1 + x

Or otherwise if y<x then x,y is on the vertical and d=x.  In that case the
y=0 is the last point on the row and is one back from the start of the
following row,

    LastN(d) = StartN(d+1) - 1
             = (d+1)^2

    N = LastN(d) - y
      = (x+1)^2 - y

=head2 N Range

For C<rect_to_n_range>, in each row increasing X is increasing N so the
smallest N is in the leftmost column and the biggest in the rightmost.

Going up a column, N values decrease until reaching X=Y, and then increase,
with those values above X=Y all bigger than the ones below.  This means the
biggest N is the top right corner if it has YE<gt>=X, otherwise the bottom
right corner.

For the smallest N, if the bottom left corner has YE<gt>X then it's in the
"increasing" part and that bottom left corner is the smallest N.  Otherwise
YE<lt>=X means some of the "decreasing" part is covered and the smallest N
is at Y=min(X,Ymax), ie. either the Y=X diagonal if it's in the rectangle or
the top right corner otherwise.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PyramidRows>,
L<Math::PlanePath::PyramidSides>,
L<Math::PlanePath::SacksSpiral>,
L<Math::PlanePath::Diagonals>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Math-PlanePath is Copyright 2010, 2011 Kevin Ryde

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
