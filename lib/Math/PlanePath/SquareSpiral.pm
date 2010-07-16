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


package Math::PlanePath::SquareSpiral;
use 5.004;
use strict;
use warnings;
use List::Util qw(max);
use POSIX ();

use vars '$VERSION', '@ISA';
$VERSION = 3;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments '####';


# 0   1   2   3   4
# 1   1   3   7  13  21  31
#   +0  +2  +4  +6  +8  +10
#      2   2   2   2   2
# 
# n = $s*$s - $s + 1
# s = .5 + sqrt ($n - .75)

sub n_to_xy {
  my ($self, $n) = @_;
  #### SquareSpiral n_to_xy: $n
  if ($n < 1) { return; }

  my $s = int (.5 + sqrt ($n - .75));
  #### s frac: .5 + sqrt ($n - .75)
  #### $s

  $n -= $s*($s-1) + 1;
  #### remainder: $n

  my $half = int($s*.5);
  if ($s & 1) {
    if ($n < $s) {
      #### bottom
      return (-$half + $n,
              -$half);
    } else {
      #### right
      return ($half+1,
              -$half + ($n-$s));
    }
  } else {
    if ($n < $s) {
      #### top
      return ($half - $n,
              $half);
    } else {
      #### left
      return (-$half,
              $half - ($n - $s));
    }
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = POSIX::floor ($x + 0.5);
  $y = POSIX::floor ($y + 0.5);
  my $d = max(abs($x),abs($y));
  my $n = 4*$d*$d + 1;
  if ($y == $d) {     # top
    return $n - $d - $x;
  }
  if ($y == - $d) {   # bottom
    return $n + 3*$d + $x;
  }
  if ($x == $d) {   
    ### right
    return $n - 3*$d + $y;
  }
  # ($x == - $d)    # left
  return $n + $d - $y;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  my $x = POSIX::floor(0.5 + max(abs($x1),abs($x2)));
  my $y = POSIX::floor(0.5 + max(abs($y1),abs($y2)));
  my $s = 2 * max(abs($x),abs($y)) + 2;
  ### $x
  ### $y
  ### $s
  ### is: $s*$s

  # ENHANCE-ME: find actual minimum if rect doesn't cover 0,0
  return (1,
          1 + $s*$s);
}

1;
__END__

=for stopwords Ulam SquareSpiral pronic PlanePath Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::SquareSpiral -- integer points drawn around a square

=head1 SYNOPSIS

 use Math::PlanePath::SquareSpiral;
 my $path = Math::PlanePath::SquareSpiral->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes a square spiral.

    37--36--35--34--33--32--31         3
     |                       |
    38  17--16--15--14--13  30         2
     |   |               |   |
    39  18   5---4---3  12  29         1
     |   |   |       |   |   |
    40  19   6   1---2  11  28    <- y=0
     |   |   |           |   |
    41  20   7---8---9--10  27        -1
     |   |                   |
    42  21--22--23--24--25--26        -2
     |
    43--44--45--46--47 ...
                 ^
    -3  -2  -1  x=0  1   2   3

This is quite well known from Stanislaw Ulam finding interesting straight
lines plotting the prime numbers on it.  See F<examples/ulam-spiral-xpm.pl>
in the sources for a program generating that, or see the author's
C<math-image> program using this SquareSpiral to draw Ulam's pattern and
more.

The perfect squares 1,4,9,16,25 fall on diagonals to the lower right and
upper left, one term on each alternately.  The pronic numbers
2,6,12,20,30,42 etc half way between the squares similarly fall on diagonals
to the upper right and lower left.

In general straight lines in this SquareSpiral and other stepped spirals
(meaning everything except the VogelFloret) are quadratics a*k^2+b*k+c, with
a=step/2 where step is how much longer each loop takes than the preceding,
which is 8 in the case of the SquareSpiral.  There are various interesting
properties of primes in quadratic progressions like this and some quadratics
seem to have more primes than others.

Other spirals can be formed by cutting the corners of the square for faster
looping.  The current paths doing so include

    corners cut      class
    -----------      -----
         2         HexSpiralSkewed
         3         PentSpiralSkewed
         4         DiamondSpiral

And see the PyramidSpiral for a re-shaped SquareSpiral.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::SquareSpiral-E<gt>new ()>

Create and return a new square spiral object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> on the path.

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
L<Math::PlanePath::PyramidSpiral>,
L<Math::PlanePath::DiamondSpiral>,
L<Math::PlanePath::HexSpiral>

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
