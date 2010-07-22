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

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 5;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

sub x_negative {
  my ($self) = @_;
  return ($self->{'step'} >= 2);
}
use constant y_negative => 0;

sub new {
  return shift->SUPER::new (step => 2, # default
                            @_);
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
  return if $n < 0.5;

  my $step = $self->{'step'};
  if ($step == 0) {
    return (0, $n-1);
  }
  my $neg_b = ($step-2) * 0.5;
  my $d = int (($neg_b + sqrt(2*$step*$n + $neg_b*$neg_b - $step)) / $step);
  ### s frac: (($neg_b + sqrt(2*$step*$n + $neg_b*$neg_b - $step)) / $step)
  ### $d
  ### rem: $n - (($step * $d*$d - ($step-2)*$d + 1) / 2)

  return ($n - ($step * $d*$d - (($step&1) - 2)*$d + 2)/2,
          $d);
}

# N = ($step * $d*$d - ($step-2)*$d + 1) / 2
#
sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = floor ($x + 0.5);
  $y = floor ($y + 0.5);
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
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### PyramidRows rect_to_n_range()

  $x1 = floor ($x1 + 0.5);
  $y1 = floor ($y1 + 0.5);
  $x2 = floor ($x2 + 0.5);
  $y2 = floor ($y2 + 0.5);

  my $step = $self->{'step'};
  my $row_min = max(0, min($y1,$y2));
  my $row_max = max(0, max($y1,$y2)) + 1;

  return ((($step * $row_min - ($step-2))*$row_min) / 2 - 1,
          (($step * $row_max - ($step-2))*$row_max) / 2 + 1);
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

    11  12  13  14  15
     7   8   9  10                    3
     4   5   6                        2
     2   3                            1
     1                          <-  y=0

    x=0  1   2   3   4 ...

Step 0 means simply a vertical, each row 1 wide and not increasing.  This is
unlikely to be much use.  The Rows path with C<width> 1 does this too.

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

For step 3 the pentagonal numbers 1,5,12,22,etc, (3k-1)*k/2, are at the
rightmost end of each row.  The "second pentagonal numbers" 2,7,15,26, S(k)
= (3k+1)*k/2 are the vertical at x=-1.  (Those second numbers are obtained
by taking negative k in the plain pentagonal (3k-1)*k/2, and the two
together are the "generalized pentagonal numbers".)

The second pentagonals are not prime beyond 7 since they're (3k+1)*k/2 with
the denominator 2 dividing into one or the other part.  Numbers S(k)-1
immediately to the left are never prime either since S(k)-1 =
(3*k-2)(k+1)/2.  Likewise S(k)-2 = (3*k+4)(k-1)/2 beyond 13.  If you plot
the primes on a step 3 PyramidRows then these sequences make a 3-wide
vertical gap at x=-1,-2,-3 where there's no primes.

               no primes in these three columns
               except the low values 2,7,13
               |  |  |
     52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70
        36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51
           23 24 25 26 27 28 29 30 31 32 33 34 35
              13 14 15 16 17 18 19 20 21 22
                  6  7  8  9 10 11 12
                     2  3  4  5
                        1
     -6 -5 -4 -3 -2 -1 x=0 1  2  3  4 ...

In general a constant offset c from S(k) is a column and the simple
factorization above using the roots of the quadratic S(k)-c = (3/2)*k^2 +
S<(1/2)*k - c> is possible whenever 24*c+1 is a perfect square.  This means
the further columns S(k)-5, S(k)-7, S(k)-12, etc have no primes either.  The
S(k), S(k)-1, S(k)-2 ones are the most prominent because they're adjacent.
There's no other adjacent columns of this type because the squares become
too far apart for successive 24*c+1.  Of course there could be many other
reasons for other columns to be prime-free or nearly so or above a certain
point, etc.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::PyramidRows-E<gt>new ()>

=item C<$path = Math::PlanePath::PyramidRows-E<gt>new (step =E<gt> $s)>

Create and return a new path object.  The default step is 2.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> on the path.

For C<$n < 0> the return is an empty list, it being considered there are no
negative points in the pyramid.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each
point in the pyramid as a square of side 1.  If C<$x,$y> is outside the
pyramid the return is C<undef>.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PyramidSides>,
L<Math::PlanePath::Corner>,
L<Math::PlanePath::SacksSpiral>

L<Math::PlanePath::Diagonals>,
L<Math::PlanePath::Rows>

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
