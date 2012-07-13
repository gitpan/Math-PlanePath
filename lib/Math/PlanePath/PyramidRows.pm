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


package Math::PlanePath::PyramidRows;
use 5.004;
use strict;
#use List::Util 'min','max';
*min = \&Math::PlanePath::_min;
*max = \&Math::PlanePath::_max;

use Math::PlanePath;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use vars '$VERSION', '@ISA';
$VERSION = 81;
@ISA = ('Math::PlanePath');


# uncomment this to run the ### lines
#use Smart::Comments;


sub x_negative {
  my ($self) = @_;
  return ($self->{'step'} >= 2);
}
use constant class_y_negative => 0;
use constant n_frac_discontinuity => .5;

use constant parameter_info_array =>
  [ { name        => 'step',
      share_key   => 'step_2',
      display     => 'Step',
      type        => 'integer',
      minimum     => 0,
      default     => 2,
      width       => 2,
      description => 'How much longer each row is than the preceding.',
    } ];

sub new {
  my $class = shift;
  ### PyramidRows new(): @_
  my $self = $class->SUPER::new (@_);

  my $step = $self->{'step'};
  $step = $self->{'step'} =
    (! defined $step ? 2 # default
     : $step < 0     ? 0 # minimum
     : $step);
  ### $step
  return $self;
}

# step==2 row line beginning at x=-0.5,
# y =          0    1    2    3     4
# N start  = -0.5  1.5  4.5  9.5  16.5
#
#
# step==1
#   N = (1/2*$d^2 + 1/2*$d + 1/2)
#   s = -1/2 + sqrt(2 * $n + -3/4)
# step==2
#   N = ($d^2 + 1/2)
#   s = 0 + sqrt(1 * $n + -1/2)
# step==3
#   N = (3/2*$d^2 + -1/2*$d + 1/2)
#   s = 1/6 + sqrt(2/3 * $n + -11/36)
# step==4
#   N = (2*$d^2 + -1*$d + 1/2)
#   s = 1/4 + sqrt(1/2 * $n + -3/16)
#
# a = $step / 2
# b = 1 - $step / 2 = (2-$step)/2
# c = 0.5
#
# s = (-b + sqrt(4*a*$n + b*b - 4*a*c)) / 2*a
#   = (-b + sqrt(2*$step*$n + b*b - 2*$step*c)) / $step
#   = (-b + sqrt(2*$step*$n + b*b - $step)) / $step
#
# N = a*s*s + b*s + c
#   = $step/2 *s*s + (-$step+2)/2 * s + 1/2
#   = ($step * $d*$d - ($step-2)*$d + 1) / 2
#
# left at - 0.5 - $d*int($step/2)
# so x = $n - (($step * $d*$d - ($step-2)*$d + 1) / 2) - 0.5 - $d*int($step/2)
#      = $n - (($step * $d*$d - ($step-2)*$d + 1) / 2 + 0.5 + $d*int($step/2))
#      = $n - ($step/2 * $d*$d - ($step-2)/2*$d + 1/2 + 0.5 + $d*int($step/2))
#      = $n - ($step/2 * $d*$d - ($step-2)/2*$d + 1 + $d*int($step/2))
#      = $n - ($step/2 * $d*$d - ($step-2)/2*$d + int($step/2)*$d + 1)
#      = $n - ($step/2 * $d*$d - (($step-2)/2 - int($step/2))*$d + 1)
#      = $n - ($step/2 * $d*$d - ($step/2 - int($step/2) - 1)*$d + 1)
#      = $n - ($step/2 * $d*$d - (($step&1)/2 - 1)*$d + 1)
#      = $n - ($step * $d*$d - (($step&1) - 2)*$d + 2)/2
#
sub n_to_xy {
  my ($self, $n) = @_;
  ### PyramidRows n_to_xy(): $n

  # $n<0.5 no good for Math::BigInt circa Perl 5.12, compare in integers
  return if 2*$n < 1;

  my $step = $self->{'step'};
  if ($step == 0) {
    # step==0 is vertical line starting N=1 at Y=0
    return (0, $n-1);
  }

  my $neg_b = ($step-2);
  my $d = int (($neg_b + sqrt(int(8*$step*$n) + $neg_b*$neg_b - 4*$step))
               / (2*$step));

  ### d frac: (($neg_b + sqrt(int(8*$step*$n) + $neg_b*$neg_b - 4*$step)) / (2*$step))
  ### $d
  ### rem: $n - (($step * $d*$d - ($step-2)*$d + 1) / 2)

  return ($n - ($step * $d*$d - (($step&1) - 2)*$d + 2)/2,
          $d);
}

# N = ($step * $d*$d - ($step-2)*$d + 1) / 2
#
sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  my $step = $self->{'step'};
  if ($y < 0
      || $x < -$y*int($step/2)
      || $x > $y*int(($step+1)/2)) {
    return undef;
  }
  return (($step * $y - (($step&1) - 2))*$y + 2)/2 + $x;
}

# left N   = ($step * $d*$d - ($step-2)*$d + 1) / 2
# plus .5  = ($step * $d*$d - ($step-2)*$d) / 2 + 1
#          = (($step * $d - ($step-2))*$d) / 2 + 1
#
# left X  = - $d*int($step/2)
# right X = $d * ceil($step/2)
#
# x_bottom_start = - y1 * step_left
# want x2 >= x_bottom_start
#      x2 >= - y1 * step_left
#      x2/step_left >= - y1
#      - x2/step_left <= y1
#      y1 >= - x2/step_left
#      y1 >= ceil(-x2/step_left)
#
# x_bottom_end = y1 * step_right
# want x1 <= x_bottom_end
#      x1 <= y1 * step_right
#      y1 * step_right >= x1
#      y1 >= ceil(x1/step_right)
#
# left N = (($step * $y1 - ($step-2))*$y1) / 2 + 1
# bottom_offset = $x1 - $y1 * $step_left
# N lo   = leftN + bottom_offset
#        = ((step * y1 - (step-2))*y1) / 2 + 1 + x1 - y1 * step_left
#        = ((step * y1 - (step-2)-2*step_left)*y1) / 2 + 1 + x1
# step_left = floor(step/2)
# 2*step_left = step - step&1
# N lo   = ((step * y1 - (step-2)-2*step_left)*y1) / 2 + 1 + x1

# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### PyramidRows rect_to_n_range(): "$x1,$y1, $x2,$y2  step=$self->{'step'}"

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); } # swap to y1<=y2
  if ($y2 < 0) {
    return (1, 0); # rect all negative, no N
  }
  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); } # swap to x1<=x2

  my $step = $self->{'step'};
  my $step_left = int($step/2);
  my $step_right = $step - $step_left;

  my $x_top_end = $y2 * $step_right;

  # \    |    /
  #  \   |   /
  #   \  |  /  +-----    x_top_end > x1
  #    \ | /   |x1,y2
  #     \|/
  # -----+-----------
  #
  #       \    |    x_top_start = -y2*step_left
  # -----+ \   |      x_top_start < x2
  # x2,y2|  \  |
  #          \ | /
  #           \|/
  # -----------+--
  #
  if ($x1 > $x_top_end
      || $x2 < -$y2 * $step_left) {
    ### rect all off to the left or right, no N ...
    return (1, 0);
  }

  ### x1 to x2 top row intersects some of the pyramid
  ### assert: $x2 >= -$y2*$step_left
  ### assert: $x1 <= $y2*$step_right

  $y1 = max ($y1,
              0,

              # for x2 >= x_bottom_start, round up
              $step_left && int((-$x2+$step_left-1)/$step_left),

              # for x1 <= x_bottom_end, round up
              $step_right && int(($x1+$step_right-1)/$step_right),
             );
  ### y1 for bottom left: $step_left && int((-$x2+$step_left-1)/$step_left)
  ### y1 for bottom right: $step_right && int(($x1+$step_right-1)/$step_right)
  ### $y1

  ### x1 to x2 bottom row now intersects some of the pyramid
  ### assert: $x2 >= -$y1*$step_left
  ### assert: $x1 <= $y1*$step_right


  my $sub = ($step&1) - 2;

  ### x bottom start: -$y1*$step_left
  ### x bottom end: $y1*$step_right
  ### $x1
  ### $x2
  ### bottom left x: max($x1, -$y1*$step_left)
  ### top right x: min ($x2, $x_top_end)
  ### $y1
  ### $y2
  ### n_lo: (($step * $y1 - $sub)*$y1 + 2)/2 + max($x1, -$y1*$step_left)
  ### n_hi: (($step * $y2 - $sub)*$y2 + 2)/2 + min($x2, $x_top_end)

  ### assert: $y1-1==$y1 || (($step * $y1 - $sub)*$y1 + 2) == int (($step * $y1 - $sub)*$y1 + 2)
  ### assert: $y2-1==$y2 || (($step * $y2 - $sub)*$y2 + 2) == int (($step * $y2 - $sub)*$y2 + 2)

  return ((($step * $y1 - $sub)*$y1 + 2)/2
          + max($x1, -$y1*$step_left),  # x_bottom_start

          (($step * $y2 - $sub)*$y2 + 2)/2
          + min($x2, $x_top_end));

  # return ($self->xy_to_n (max ($x1, -$y1*$step_left), $y1),
  #         $self->xy_to_n (min ($x2, $x_top_end),      $y2));
}

1;
__END__

=for stopwords pronic SacksSpiral PlanePath Ryde Math-PlanePath PyramidSides PyramidRows ie Pentagonals onwards factorizations OEIS

=head1 NAME

Math::PlanePath::PyramidRows -- points stacked up in a pyramid

=head1 SYNOPSIS

 use Math::PlanePath::PyramidRows;
 my $path = Math::PlanePath::PyramidRows->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path arranges points in successively wider rows going upwards so as to
form an upside-down pyramid.  The default step is 2, ie. each row 2 wider
than the preceding, one square each side,

    17  18  19  20  21  22  23  24  25         4
        10  11  12  13  14  15  16             3
             5   6   7   8   9                 2
                 2   3   4                     1
                     1                   <-  y=0

    -4  -3  -2  -1  x=0  1   2   3   4 ...

The right end here 1,4,9,16,etc is the perfect squares.  The vertical
2,6,12,20,etc at x=-1 is the pronic numbers s*(s+1), half way between those
successive squares.

The step 2 is the same as the PyramidSides, Corner and SacksSpiral paths.
For the SacksSpiral, spiral arms going to the right correspond to diagonals
in the pyramid, and arms to the left correspond to verticals.

=head2 Step Parameter

A C<step> parameter controls how much wider each row is than the preceding,
to make wider pyramids.  For example step 4

    my $path = Math::PlanePath::PyramidRows->new (step => 4);

makes each row 2 wider on each side successively

   29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45        4
         16 17 18 19 20 21 22 23 24 25 26 27 28              3
                7  8  9 10 11 12 13 14 15                    2
                      2  3  4  5  6                          1
                            1                          <-  y=0

         -6 -5 -4 -3 -2 -1 x=0 1  2  3  4  5  6 ...

If the step is an odd number then the extra is at the right, so step 3 gives

    13  14  15  16  17  18  19  20  21  22        3
         6   7   8   9  10  11  12                2
             2   3   4   5                        1
                 1                          <-  y=0

    -3  -2  -1  x=0  1   2   3   4 ...

Or step 1 goes solely to the right.  This is equivalent to the Diagonals
path, but columns shifted up to make horizontal rows.

    step => 1

    11  12  13  14  15
     7   8   9  10                    3
     4   5   6                        2
     2   3                            1
     1                          <-  y=0

    x=0  1   2   3   4 ...

Step 0 means simply a vertical, each row 1 wide and not increasing.  This is
unlikely to be much use.  The Rows path with C<width> 1 does this too.

    step => 0

     5        4
     4        3
     3        2
     2        1
     1    <-y=0

    x=0

Various number sequences fall in regular patterns positions depending on the
step.  Large steps are not particularly interesting and quickly become very
wide.  A limit might be desirable in a user interface, but there's no limit
in the code as such.

=head2 Step 3 Pentagonals

For step 3 the pentagonal numbers 1,5,12,22,etc, P(k) = (3k-1)*k/2, are at
the rightmost end of each row.  The second pentagonal numbers 2,7,15,26,
S(k) = (3k+1)*k/2 are the vertical at x=-1.  Those second numbers are
obtained by P(-k), and the two together are the "generalized pentagonal
numbers".

Both these sequences are composites from 12 and 15 onwards, respectively,
and the preceding values P(k)-1, P(k)-2, S(k)-1 and S(k)-2 are too.  They
factorize simply as

    P(k)   = (3*k-1)*k/2
    P(k)-1 = (3*k+2)*(k-1)/2
    P(k)-2 = (3*k-4)*(k-1)/2
    S(k)   = (3*k+1)*k/2
    S(k)-1 = (3*k-2)*(k+1)/2
    S(k)-2 = (3*k+4)*(k-1)/2

If you plot the primes on a step 3 PyramidRows then these second pentagonal
sequences make a 3-wide vertical gap of no primes at x=-1,-2,-3. and the
plain pentagonal sequences make the endmost three N of each row non-prime.
The vertical is much more noticeable in a plot.

       no primes these three columns         no primes these end three
         except the low 2,7,13                     except low 5,11
               |  |  |                                /  /  /
     52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70
        36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51
           23 24 25 26 27 28 29 30 31 32 33 34 35
              13 14 15 16 17 18 19 20 21 22
                  6  7  8  9 10 11 12
                     2  3  4  5
                        1
     -6 -5 -4 -3 -2 -1 x=0 1  2  3  4 ...

In general a constant offset c from S(k) is a column and from P(k) a
diagonal going 2 to the right each time.  The simple factorizations above
using the roots of the quadratic P(k)-c or S(k)-c is possible whenever
24*c+1 is a perfect square.  This means the further columns S(k)-5, S(k)-7,
S(k)-12, etc have no primes either.

The columns S(k), S(k)-1, S(k)-2 are prominent because they're adjacent.
There's no other adjacent ones of this type because the squares after 49 are
too far apart for successive 24*c+1.  Of course there could be other reasons
for other columns or diagonals to have few or many primes, perhaps above a
certain point, etc.

=cut

# (3/2)*k^2 + (1/2)*k - c
# roots (-1/2 +/- sqrt ((1/2)^2 - 4*(3/2)*-c)) / (2*(3/2))
#     = (-1/2 +/- sqrt (1/4 + (12/2)*c)) / 3
#     = -1/6 +/- sqrt (1/4 + (12/2)*c)/3
#     = -1/6 +/- sqrt (1/4 + 6*c)/3
#     = -1/6 +/- sqrt (1/4 + 6*c)*2/6
#     = -1/6 +/- sqrt (4*(1/4 + 6*c))/6
#     = -1/6 +/- sqrt(1 + 24c)/6
#     must have 1+24c a perfect square to factorize by roots
#
# i   i^2   i^2 mod 24
#  0    0    0
#  1    1    1          1+0*24
#  2    4    4
#  3    9    9
#  4   16   16
#  5   25    1          1+1*24
#  6   36   12
#  7   49    1          1+2*24
#  8   64   16
#  9   81    9
# 10  100    4
# 11  121    1          1+5*24
# 12  144    0
# 13  169    1          1+7*24
# 14  196    4
# 15  225    9
# 16  256   16
# 17  289    1          1+12*24
# 18  324   12
# 19  361    1          1+15*24
# 20  400   16
# 21  441    9
# 22  484    4
# 23  529    1          1+22*24
#

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::PyramidRows-E<gt>new ()>

=item C<$path = Math::PlanePath::PyramidRows-E<gt>new (step =E<gt> $s)>

Create and return a new path object.  The default step is 2.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n <= 0> the return is an empty list since the path starts at N=1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each
point in the pyramid as a square of side 1.  If C<$x,$y> is outside the
pyramid the return is C<undef>.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

The returned range is exact, meaning C<$n_lo> and C<$n_hi> are the smallest
and biggest in the rectangle.

=back

=head1 OEIS

Entries in Sloane's Online Encyclopedia of Integer Sequences related to this
path include

    http://oeis.org/A023531  (etc)

     step=1
    A023531    dY, being 1 at row end, but starting n=0
    A079824    N total along each diagonal

     step=2
    A196199    X coordinate, runs -n to +n
    A000196    Y coordinate, n appears 2n+1 times
    A053186    X+Y, being distance to next higher square
    A010052    dY,  being 1 at perfect square row end

     step=3
    A180447    Y coordinate, n appears 3n+1 times

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PyramidSides>,
L<Math::PlanePath::Corner>,
L<Math::PlanePath::SacksSpiral>,
L<Math::PlanePath::MultipleRings>

L<Math::PlanePath::Diagonals>,
L<Math::PlanePath::DiagonalsOctant>,
L<Math::PlanePath::Rows>

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
