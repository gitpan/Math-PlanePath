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



# http://mathworld.wolfram.com/PrimeSpiral.html
#
# Mark C. Chu-Carroll "The Surprises Never Eend: The Ulam Spiral of Primes"
# http://scienceblogs.com/goodmath/2010/06/the_surprises_never_eend_the_u.php
#
# http://yoyo.cc.monash.edu.au/%7Ebunyip/primes/index.html
# including image highlighting the lines

package Math::PlanePath::SquareSpiral;
use 5.004;
use strict;
use List::Util qw(max);
use POSIX 'floor';

use vars '$VERSION', '@ISA';
$VERSION = 50;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments '###';

# http://d4maths.lowtech.org/mirage/ulam.htm
# http://d4maths.lowtech.org/mirage/img/ulam.gif
#     sample gif of primes made by APL or something
#
# http://www.sciencenews.org/view/generic/id/2696/title/Prime_Spirals
#     Ulam's sprial of primes
#
# http://yoyo.cc.monash.edu.au/%7Ebunyip/primes/primeSpiral.htm
# http://yoyo.cc.monash.edu.au/%7Ebunyip/primes/triangleUlam.htm
#     Pulchritudinous Primes of Ulam sprial.

use constant parameter_info_array => [ { name => 'wider',
                                         type => 'integer',
                                         description => 'Wider path.',
                                         minimum => 0,
                                         default => 0,
                                         width => 3,
                                       } ];

sub new {
  my $self = shift->SUPER::new (@_);
  $self->{'wider'} ||= 0;  # default
  return $self;
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

  if ($n < 1) {
    #### less than one
    return;
  }

  my $w = $self->{'wider'};
  my $w_right = int($w/2);
  my $w_left = $w - $w_right;
  if ($n <= $w+2) {
    #### centre horizontal
    # n=1 at w_left
    # x = $n-1 - int(($w+1)/2)
    #   = $n - int(1 + ($w+1)/2)
    #   = $n - int(($w+3)/2)
    return ($n-1 - $w_left,  # n=1 at w_left
            0);
  }

  my $d = int ((2-$w + sqrt(int(4*$n) + $w*$w - 4)) / 4);
  #### d frac: ((2-$w + sqrt(int(4*$n) + $w*$w - 4)) / 4)
  #### $d

  #### base: 4*$d*$d + (-4+2*$w)*$d + (2-$w)
  $n -= ((4*$d + 2*$w)*$d + 1);
  #### remainder: $n

  if ($n >= 0) {
    if ($n <= 2*$d) {
      ### left vertical
      return (-$d - $w_left,
              -$n + $d);
    } else {
      ### bottom horizontal
      return ($n - $w_left - 3*$d,
              -$d);
    }
  } else {
    if ($n >= -2*$d-$w) {
      ### top horizontal
      return (-$n - $d - $w_left,
              $d);
    } else {
      ### right vertical
      return ($d + $w_right,
              $n + 3*$d + $w);
    }
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;

  my $w = $self->{'wider'};
  my $w_right = int($w/2);
  my $w_left = $w - $w_right;
  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
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
  ### $d
  ### is: $d*$d

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

=for stopwords Stanislaw Ulam SquareSpiral pronic PlanePath Ryde Math-PlanePath Ulam's VogelFloret PyramidSides PyramidRows PyramidSpiral Honaker's decagonal

=head1 NAME

Math::PlanePath::SquareSpiral -- integer points drawn around a square (or rectangle)

=head1 SYNOPSIS

 use Math::PlanePath::SquareSpiral;
 my $path = Math::PlanePath::SquareSpiral->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes a square spiral,

    37--36--35--34--33--32--31              3
     |                       |
    38  17--16--15--14--13  30              2
     |   |               |   |
    39  18   5---4---3  12  29              1
     |   |   |       |   |   |
    40  19   6   1---2  11  28  ...    <- Y=0
     |   |   |           |   |   |
    41  20   7---8---9--10  27  52         -1
     |   |                   |   |
    42  21--22--23--24--25--26  51         -2
     |                           |
    43--44--45--46--47--48--49--50         -3

                 ^
    -3  -2  -1  X=0  1   2   3   4

See F<examples/square-numbers.pl> in the sources for a simple program
printing these numbers.

This path is well known from Stanislaw Ulam finding interesting straight
lines when plotting the prime numbers on it.  See
F<examples/ulam-spiral-xpm.pl> in the sources for a program generating that,
or see L<math-image> using this SquareSpiral to draw Ulam's pattern and
more.

=head2 Straight Lines

The perfect squares 1,4,9,16,25 fall on diagonals with the even perfect
squares going to the upper left and the odd ones to the lower right.  The
pronic numbers 2,6,12,20,30,42 etc k^2+k half way between the squares fall
on similar diagonals to the upper right and lower left.  The decagonal
numbers 10,27,52,85 etc 4*k^2-3*k go horizontally to the right at y=-1.

In general straight lines and diagonals are 4*k^2 + b*k + c.  b=0 is the
even perfect squares up to the left, then b is an eighth turn
counter-clockwise, or clockwise if negative.  So b=1 is horizontally to the
left, b=2 diagonally down to the left, b=3 down vertically, etc.

Honaker's prime-generating polynomial 4*k^2 + 4*k + 59 goes down to the
right, after the first 30 or so values loop around a bit.

=head2 Wider

An optional C<wider> parameter makes the path wider, becoming a rectangle
spiral instead of a square.  For example

    $path = Math::PlanePath::SquareSpiral->new (wider => 3);

gives

    29--28--27--26--25--24--23--22        2
     |                           |
    30  11--10-- 9-- 8-- 7-- 6  21        1
     |   |                   |   |
    31  12   1-- 2-- 3-- 4-- 5  20   <- Y=0
     |   |                       |
    32  13--14--15--16--17--18--19       -1
     |
    33--34--35--36-...                   -2

                     ^
    -4  -3  -2  -1  X=0  1   2   3

The centre horizontal 1 to 2 is extended by C<wider> many further places,
then the path loops around that shape.  The starting point 1 is shifted to
the left by ceil(wider/2) places to keep the spiral centred on the origin
x=0,y=0.

Widening doesn't change the nature of the straight lines which arise, it
just rotates them around.  For example in this wider=3 example the perfect
squares are still on diagonals, but the even squares go towards the bottom
left (instead of top left when wider=0) and the odd squares to the top right
(instead of the bottom right).

Each loop is still 8 longer than the previous, as the widening is basically
a constant amount in each loop.

=head2 Corners

Other spirals can be formed by cutting the corners of the square so as to go
around faster.  See the following modules,

    Corners Cut    Class
    -----------    -----
         1        HeptSpiralSkewed
         2        HexSpiralSkewed
         3        PentSpiralSkewed
         4        DiamondSpiral

The PyramidSpiral is a re-shaped SquareSpiral looping at the same rate.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::SquareSpiral-E<gt>new ()>

=item C<$path = Math::PlanePath::SquareSpiral-E<gt>new (wider =E<gt> $w)>

Create and return a new square spiral object.  An optional C<wider>
parameter widens the spiral path, it defaults to 0 which is no widening.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n E<lt> 1> the return is an empty list, as the path starts at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each N
in the path as centred in a square of side 1, so the entire plane is
covered.

=back

=head1 FORMULAS

=head2 N to X,Y

There's a few ways to break an N into a side and offset into the side.  One
convenient way is to treat a loop as starting at the bottom right corner, so
N=2,10,26,50,etc,  If the first at N=2 is reckoned loop number d=1 then

    Nbase = 4*d^2 - 4*d + 2

For example d=3 is Nbase=4*3^2-4*3+2=26 at X=3,Y=-2.  The biggest d with
Nbase E<lt>= N can be found by inverting with the usual quadratic formula

    d = floor (1/2 + sqrt(N/4 - 1/4))

For Perl it's good to keep the sqrt argument an integer (when a UV integer
is bigger than an NV float, and for BigRat accuracy), so rearranging

    d = floor ((1+sqrt(N-1)) / 2)

So Nbase from this d leaves a remainder which is an offset into the loop

    Nrem = N - Nbase
         = N - (4*d^2 - 4*d + 2)

The loop starts at X=d,Y=d-1 and has sides length 2d, 2d+1, 2d+1 and 2d+2,

             2d      
         +------------+        <- Y=d
         |            |
    2d   |            |  2d-1
         |     .      |
         |            |
         |            + X=d,Y=-d+1
         |
         +---------------+     <- Y=-d
             2d+1

         ^
       X=-d

The X,Y for an Nrem is then

     side      Nrem range            X,Y result
     ----      ----------            ----------
    right           Nrem <= 2d-1     X = d
                                     Y = -d+1+Nrem
    top     2d-1 <= Nrem <= 4d-1     X = d-(Nrem-(2d-1)) = 3d-1-Nrem
                                     Y = d
    left    4d-1 <= Nrem <= 6d-1     X = -d
                                     Y = d-(Nrem-(4d-1)) = 5d-1-Nrem
    bottom  6d-1 <= Nrem             X = -d+(Nrem-(6d-1)) = -7d+1+Nrem
                                     Y = -d

The corners Nrem=2d-1, Nrem=4d-1 and Nrem=6d-1 get the same result from the
two sides that meet so it doesn't matter if the high comparison is "E<lt>"
or "E<lt>=".

The bottom edge runs through to Nrem E<lt> 8d, but there's no need to
check that since d=floor(sqrt()) above ensures Nrem is within the loop.

A small simplification can be had by subtracting an extra 4d-1 from Nrem to
make negatives for the right and top sides and positives for the left and
bottom.

    Nsig = N - Nbase - (4d-1)
         = N - (4*d^2 - 4*d + 2) - (4d-1)
         = N - (4*d^2 + 1)

     side      Nsig range            X,Y result
     ----      ----------            ----------
    right           Nsig <= -2d      X = d
                                     Y = d+(Nsig+2d) = 3d+Nsig
    top      -2d <= Nsig <= 0        X = -d-Nsig
                                     Y = d
    left       0 <= Nsig <= 2d       X = -d
                                     Y = d-Nsig
    bottom    2d <= Nsig             X = -d+1+(Nsig-(2d+1)) = Nsig-3d
                                     Y = -d

=head2 N to X,Y with Wider

With the C<wider> parameter stretching the spiral loops the formulas above
become

    Nbase = 4*d^2 + (-4+2w)*d + 2-w

    d = floor ((2-w + sqrt(4N + w^2 - 4)) / 4)

Notice for Nbase the w is a term 2*w*d, being an extra 2*w for each loop.

The left offset ceil(w/2) described above (L</Wider>) for the N=1 starting
position is written here as wl, and the other half wr arises too,

    wl = ceil(w/2)
    wr = floor(w/2) = w - wl

The horizontal lengths increase by w, and positions shift by wl or wr, but
the verticals are unchanged.

             2d+w      
         +------------+        <- Y=d
         |            |
    2d   |            |  2d-1
         |     .      |
         |            |
         |            + X=d+wr,Y=-d+1
         |
         +---------------+     <- Y=-d
             2d+1+w

         ^
       X=-d-wl

The Nsig formulas then have w, wl or wr variously inserted.  In all cases if
w=wl=wr=0 then they simplify to the plain versions.

    Nsig = N - Nbase - (4d-1+w)
         = N - ((4d + 2w)*d + 1)

     side      Nsig range            X,Y result
     ----      ----------            ----------
    right         Nsig <= -(2d+w)    X = d+wr
                                     Y = d+(Nsig+2d+w) = 3d+w+Nsig
    top      -(2d+w) <= Nsig <= 0    X = -d-wl-Nsig
                                     Y = d
    left       0 <= Nsig <= 2d       X = -d-wl
                                     Y = d-Nsig
    bottom    2d <= Nsig             X = -d+1-wl+(Nsig-(2d+1)) = Nsig-wl-3d
                                     Y = -d

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PyramidSpiral>

L<Math::PlanePath::DiamondSpiral>,
L<Math::PlanePath::PentSpiralSkewed>,
L<Math::PlanePath::HexSpiralSkewed>,
L<Math::PlanePath::HeptSpiralSkewed>

X11 cursor font "box spiral" cursor which is this style (but going
clockwise).

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
