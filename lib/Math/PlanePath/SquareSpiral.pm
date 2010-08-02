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
use POSIX 'floor', 'ceil';

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 6;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments '###';

sub new {
  return shift->SUPER::new (wider => 0, # default
                            @_);
}

# wider==0
# base from bottom-right corner
#   d = [ 1,  2,  3,  4 ]
#   N = [ 2, 10, 26, 50 ]
#   N = (4 d^2 - 4 d + 2)
#   d = 1/2 + sqrt(1/4 * $n + -4/16)
#
# wider==1
# base from bottom-right corner
#   d = [ 1,  2,  3,  4 ]
#   N = [ 3, 13, 31, 57 ]
#   N = (4 d^2 - 2 d + 1)
#   d = 1/4 + sqrt(1/4 * $n + -3/16)
#
# wider==2
# base from bottom-right corner
#   d = [ 1,  2,  3, 4 ]
#   N = [ 4, 16, 36, 64 ]
#   N = (4 d^2)
#   d = 0 + sqrt(1/4 * $n + 0)
#
# wider==3
# base from bottom-right corner
#   d = [ 1,  2,  3 ]
#   N = [ 5, 19, 41 ]
#   N = (4 d^2 + 2 d - 1)
#   d = -1/4 + sqrt(1/4 * $n + 5/16)
#
# N = 4*d^2 + (-4+2*w)*d + (2-w)
#   = 4*$d*$d + (-4+2*$w)*$d + (2-$w)
# d = 1/2-w/4 + sqrt(1/4*$n + b^2-4ac)
# (b^2-4ac)/(2a)^2 = [ (2w-4)^2 - 4*4*(2-w) ] / 64
#                  = [ 4w^2 - 16w + 16 - 32 + 16w ] / 64
#                  = [ 4w^2 - 16 ] / 64
#                  = [ w^2 - 4 ] / 16
# d = 1/2-w/4 + sqrt(1/4*$n + (w^2 - 4) / 16)
#   = 1/4 * (2-w + sqrt(4*$n + w^2 - 4))
#   = 0.25 * (2-$w + sqrt(4*$n + $w*$w - 4))
#
# then offset the base by +4*$d+$w-1 for top left corner for +/- remainder
# rem = $n - (4*$d*$d + (-4+2*$w)*$d + (2-$w) + 4*$d + $w - 1)
#     = $n - (4*$d*$d + (-4+2*$w)*$d + 2 - $w + 4*$d + $w - 1)
#     = $n - (4*$d*$d + (-4+2*$w)*$d + 1 - $w + 4*$d + $w)
#     = $n - (4*$d*$d + (-4+2*$w)*$d + 1 + 4*$d)
#     = $n - (4*$d*$d + (2*$w)*$d + 1)
#     = $n - ((4*$d + 2*$w)*$d + 1)
#

sub n_to_xy {
  my ($self, $n) = @_;
  #### SquareSpiral n_to_xy: $n
  my $w = $self->{'wider'};
  if ($n < 1) {
    #### less than one
    return;
  }
  if ($n <= $w+2) {
    #### centre horizontal
    # n=1 at w_left
    # x = $n-1 - int(($w+1)/2)
    #   = $n - int(1 + ($w+1)/2)
    #   = $n - int(($w+3)/2)
    return ($n - int(($w+3)/2),  # n=1 at w_left
            0);
  }

  my $d = int (0.25 * (2-$w + sqrt(4*$n + $w*$w - 4)));
  #### d frac: (0.25 * (2-$w + sqrt(4*$n + $w*$w - 4)))
  #### $d

  #### base: 4*$d*$d + (-4+2*$w)*$d + (2-$w)
  $n -= ((4*$d + 2*$w)*$d + 1);
  #### remainder: $n

  if ($n >= 0) {
    if ($n <= 2*$d) {
      ### left vertical
      return (-$d - ceil($w/2),
              $d - $n);
    } else {
      ### bottom horizontal
      return (- ceil($w/2) + $n - 3*$d,
              -$d);
    }
  } else {
    if ($n >= -2*$d-$w) {
      ### top horizontal
      return (-$d - ceil($w/2) - $n,
              $d);
    } else {
      ### right vertical
      return ($d + int($w/2),
              $n + 3*$d + $w);
    }
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;

  my $w = $self->{'wider'};
  my $w_right = int($w/2);
  my $w_left = $w - $w_right;
  $x = floor ($x + 0.5);
  $y = floor ($y + 0.5);
  ### xy_to_n: "x=$x, y=$y"
  ### $w_left
  ### $w_right

  my $d;
  if (($d = $x - $w_right) > abs($y)) {
    ### right vertical
    ### $d
    #
    # base bottom right per above
    ### BR: 4*$d*$d + (-4+2*$w)*$d + (2-$w)
    # then +$d-1 for the y=0 point
    # N_Y0  = 4*$d*$d + (-4+2*$w)*$d + (2-$w) + $d-1
    #       = 4*$d*$d + (-3+2*$w)*$d + (2-$w) + -1
    #       = 4*$d*$d + (-3+2*$w)*$d +  1-$w
    ### N_Y0: (4*$d + -3 + 2*$w)*$d + 1-$w
    #
    return (4*$d + -3 + 2*$w)*$d + 1-$w + $y;
  }

  if (($d = -$x - $w_left) > abs($y)) {
    ### left vertical
    ### $d
    #
    # top left per above
    ### TL: 4*$d*$d + (2*$w)*$d + 1
    # then +$d for the y=0 point
    # N_Y0  = 4*$d*$d + (2*$w)*$d + 1 + $d
    #       = 4*$d*$d + (1 + 2*$w)*$d + 1
    ### N_Y0: (4*$d + 1 + 2*$w)*$d + 1
    #
    return (4*$d + 1 + 2*$w)*$d + 1 - $y;
  }

  $d = abs($y);
  if ($y > 0) {
    ### top horizontal
    ### $d
    #
    # top left per above
    ### TL: 4*$d*$d + (2*$w)*$d + 1
    # then -($d+$w_left) for the x=0 point
    # N_X0  = 4*$d*$d + (2*$w)*$d + 1 + -($d+$w_left)
    #       = 4*$d*$d + (-1 + 2*$w)*$d + 1 - $w_left
    ### N_Y0: (4*$d - 1 + 2*$w)*$d + 1 - $w_left
    #
    return (4*$d - 1 + 2*$w)*$d + 1 - $w_left - $x;
  }

  ### bottom horizontal, and centre y=0
  ### $d
  #
  # top left per above
  ### TL: 4*$d*$d + (2*$w)*$d + 1
  # then +2*$d to bottom left, +$d+$w_left for the x=0 point
  # N_X0  = 4*$d*$d + (2*$w)*$d + 1 + 2*$d + $d+$w_left)
  #       = 4*$d*$d + (3 + 2*$w)*$d + 1 + $w_left
  ### N_Y0: (4*$d + 3 + 2*$w)*$d + 1 + $w_left
  #
  return (4*$d + 3 + 2*$w)*$d + 1 + $w_left + $x;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  my $w = $self->{'wider'};
  my $w_right = int($w/2);
  my $w_left = $w - $w_right;

  my $d = 1 + max (1,
                   floor(0.5 + max(abs($y1),abs($y2))),
                   (map {$_ = floor(0.5 + $_);
                         max ($_ - $w_right,
                              -$_ - $w_left)}
                    ($x1, $x2)));
  ### $s
  ### is: $s*$s

  # ENHANCE-ME: find actual minimum if rect doesn't cover 0,0
  return (1,
          (4*$d + -4 + 2*$w)*$d + 2);  # bottom-right
}


# old bit:
#
# wider==0
# base from two-way diagonal top-right and bottom-left
# s even for top-right diagonal doing top leftwards then left downwards
# s odd for bottom-left diagonal doing bottom rightwards then right pupwards
#   s = [ 0,  1,   2,   3,   4,   5,   6 ]
#   N = [ 1,  1,   3,   7,  13,  21,  31 ]
#         +0  +2  +4  +6  +8  +10
#            2   2   2   2   2
#
#   n = (($d - 1)*$d + 1)
#   s = 1/2 + sqrt(1 * $n + -3/4)
#     = .5 + sqrt ($n - .75)
#
#

1;
__END__

=for stopwords Ulam SquareSpiral pronic PlanePath Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::SquareSpiral -- integer points drawn around a square (or rectangle)

=head1 SYNOPSIS

 use Math::PlanePath::SquareSpiral;
 my $path = Math::PlanePath::SquareSpiral->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes a square spiral,

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

The perfect squares 1,4,9,16,25 fall on diagonals with the even perfect
squares going to the upper left and the odd ones to the lower right.  The
pronic numbers 2,6,12,20,30,42 etc (k^2+k) half way between the squares fall
on similar diagonals to the upper right and lower left.

This path is well known from Stanislaw Ulam finding interesting straight
lines plotting the prime numbers on it.  See F<examples/ulam-spiral-xpm.pl>
in the sources for a program generating that, or see L<math-image> using
this SquareSpiral to draw Ulam's pattern and more.

In general straight lines in this spiral and other stepped paths (meaning
everything except the VogelFloret currently) are quadratics a*k^2+b*k+c,
with a=step/2 where step is how much longer each loop takes than the
preceding (8 in the case of the SquareSpiral).  There are various
interesting properties of primes in quadratic progressions like this.  Some
seem to have more primes than others, for instance see PyramidSides for
Euler's k^2+k+41.  Many quadratics have no primes at all, or above a certain
point, either trivially if always a multiple of 2 or similar, or by a more
sophisticated reasoning.  See PyramidRows with step 3 for an example of a
factorization by the roots making a no-primes gap.

=head2 Wider

An optional C<wider> parameter makes the path wider, becoming a rectangle
instead of a square.  For example

    $path = Math::PlanePath::SquareSpiral->new (wider => 3);

gives

    29--28--27--26--25--24--23--22        2
     |                           |
    30  11--10-- 9-- 8-- 7-- 6  21        1
     |   |                   |   |
    31  12   1-- 2-- 3-- 4-- 5  20   <- y=0
     |   |                       |
    32  13--14--15--16--17--18--19       -1
     |
    33--34--35--36-...                   -2

                     ^
    -4  -3  -2  -1  x=0  1   2   3

The centre horizontal 1 to 2 is extended by C<wider> many further places,
then the path loops around that shape.  The starting point 1 is shifted to
the left by wider/2 places (rounded up to an integer) to keep the spiral
centred on the origin x=0,y=0.

Widening doesn't change the nature of the straight lines which arise, it
just rotates them around.  For example in this wider=3 example the perfect
squares are still on diagonals, but the even squares go towards the bottom
left (instead of top left when wider=0) and the odd squares to the top right
(instead of the bottom right).

Each loop is still 8 longer than the previous, since the widening is
basically a constant amount added into each loop.

=head2 Corners

Other spirals can be formed by cutting the corners of the square so as to go
around faster.  See the following module,

    Corners Cut    Class
    -----------    -----
         1        HeptSpiralSkewed
         2        HexSpiralSkewed
         3        PentSpiralSkewed
         4        DiamondSpiral

The PyramidSpiral is a re-shaped SquareSpiral looping at the same rate.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::SquareSpiral-E<gt>new ()>

=item C<$path = Math::PlanePath::SquareSpiral-E<gt>new (wider =E<gt> $w)>

Create and return a new square spiral object.  An optional C<wider>
parameter widens the spiral path, it defaults to 0 which is no widening.

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
L<Math::PlanePath::PyramidSpiral>

L<Math::PlanePath::DiamondSpiral>,
L<Math::PlanePath::PentSpiralSkewed>,
L<Math::PlanePath::HexSpiralSkewed>,
L<Math::PlanePath::HeptSpiralSkewed>

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
