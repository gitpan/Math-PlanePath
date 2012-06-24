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


# math-image --path=PyramidSpiral --all --output=numbers_dash


package Math::PlanePath::PyramidSpiral;
use 5.004;
use strict;
#use List::Util 'min','max';
*min = \&Math::PlanePath::_min;
*max = \&Math::PlanePath::_max;

use Math::PlanePath;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use vars '$VERSION', '@ISA';
$VERSION = 78;
@ISA = ('Math::PlanePath');


# uncomment this to run the ### lines
#use Smart::Comments;


# bottom right corner
#   r = [ 1,  2,  3,  4 ]
#   n = [ 2, 10, 26, 50 ]
#   $r = 1/2 + sqrt(1/4 * $n + -1/4)
#
#   $n = 4*$r^2 + -4*$r + 2
#   and top of pyramid at further +(2*$r-1) so relative to there
#   rem = $n - (4*$r^2 + -4*$r + 2) - (2*$r - 1)
#       = $n - (4*$r^2 + -2*$r + 1)
#
# bottom left corner is then rem==2*$r,
#   so go rem-2*$r rightwards from x=-2*$r, is x = rem - 4*$r

#
sub n_to_xy {
  my ($self, $n) = @_;
  #### PyramidSpiral n_to_xy: $n
  if ($n < 1) { return; }
  if ($n < 2) { return ($n - 1, 0); }

  my $r = int (.5 + sqrt (($n-1)/4));
  #### r frac: (.5 + sqrt (($n-1)/4))
  #### $r
  #### base: 4*$r*$r + -4*$r + 2

  $n -= (4*$r*$r + -2*$r + 1);
  #### remainder: $n

  if ($n < 2*$r) {
    ### sides, remainder pos/neg from top
    return (-$n,
            $r - abs($n));
  } else {
    ### rightwards from bottom left corner: $n - 2*$r
    ### bottom left at: "x=-2*$r"
    return ($n - 4*$r,
            -$r);
  }
}

# negative y, x=0 centres
#   [ 1,  2,  3 ]
#   [ 7, 21, 43 ]
#   n = (4*$y*$y + 2*abs($y) + 1)
#
# positive y, x=0 centres
#   [ 1,  2,  3 ]
#   [ 3, 13, 31 ]
#   n = (4*$r*$r + -2*$r + 1)
#

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  ### xy_to_n(): "$x,$y"

  if ($y < 0 && abs($x) <= 2*-$y) {
    ### bottom horizontal
    return (4*$y*$y - 2*$y + 1) + $x;
  }

  ### sides diagonal
  my $k = 2 * (abs($x) + $y);
  return $k*($k-1) + 1 - $x;
}

# final n of each loop
#   r = [ 1,  2,  3 ]
#   n = [ 10, 26, 50 ]
#   n = (4*$r**2 + 4*$r + 2)
#
# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = abs (_round_nearest ($x1));
  $x2 = abs (_round_nearest ($x2));
  my $x = ($x1 > $x2 ? $x1 : $x2);  # max

  $y1 = _round_nearest ($y1);
  $y2 = _round_nearest ($y2);

  my $r = max (map {
    my $y = $_;
    my $r;
    if ($y < 0 && $x <= 2*-$y) {
      ### bottom horizontal
      $r = abs($y);
    } else {
      ### sides diagonal
      $r = abs($x) + $y;
    }
    ### $x
    ### $y
    ### $r
    $r
  } max($y1,$y2), min($y1,$y2));
  ### $r

  # ENHANCE-ME: find actual minimum if rect doesn't cover 0,0
  return (1,
          4*$r*($r+1) + 2);
}

1;
__END__

=for stopwords PyramidSpiral pronic PlanePath Ryde Math-PlanePath SquareSpiral DiamondSpiral OctagramSpiral OEIS

=head1 NAME

Math::PlanePath::PyramidSpiral -- integer points drawn around a pyramid

=head1 SYNOPSIS

 use Math::PlanePath::PyramidSpiral;
 my $path = Math::PlanePath::PyramidSpiral->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes a pyramid shaped spiral,

                      31                         3
                     /  \
                   32 13 30                      2
                  /  /  \  \
                33 14  3 12 29                   1
               /  /  /  \  \  \
             34 15  4  1--2 11 28 ...        <- Y=0
            /  /  /           \  \  \
          35 16  5--6--7--8--9-10 27 52         -1
         /  /                       \  \
       36 17-18-19-20-21-22-23-24-25-26 51      -2
      /                                   \
    37-38-39-40-41-42-43-44-45-46-47-48-49-50   -3

                       ^
    -5 -4 -3  -2  -1  X=0 1  2  3  4  5  6  7

The perfect squares 1,4,9,16 fall one before the bottom left corner of each
loop, and the pronic numbers 2,6,12,20,30,etc are the vertical upwards from
X=1,Y=0.

=head2 Square Spiral

This spiral goes around at the same rate as the SquareSpiral.  It's as if
two corners are cut off (like the DiamondSpiral) and two others extended
(like the OctagramSpiral).  The net effect is the same looping rate but the
points pushed around a bit.

Taking points up to a perfect square shows the similarity.  The two
triangular cut-off corners marked by "."s are matched by the two triangular
extensions.

            +--------------------+   7x7 square
            | .  .  . 31  .  .  .|
            | .  . 32 13 30  .  .|
            | . 33 14  3 12 29  .|
            |34 15  4  1  2 11 28|
          35|16  5  6  7  8  9 10|27
       36 17|18 19 20 21 22 23 24|25 26
    37 38 39|40 41 42 43 44 45 46|47 48 49
            +--------------------+

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::PyramidSpiral-E<gt>new ()>

Create and return a new pyramid spiral object.

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

=head1 OEIS

This path is in Sloane's Online Encyclopedia of Integer Sequences as

    http://oeis.org/A053615  (etc)

    A053615    abs(X), distance to next pronic, but starts n=0

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SquareSpiral>,
L<Math::PlanePath::PyramidRows>

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
