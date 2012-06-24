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


# math-image --path=Corner --output=numbers_dash --all


package Math::PlanePath::Corner;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 78;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant class_x_negative => 0;
use constant class_y_negative => 0;
use constant n_frac_discontinuity => .5;

use Math::PlanePath::SquareSpiral;
*parameter_info_array = \&Math::PlanePath::SquareSpiral::parameter_info_array;


# same as PyramidSides, just 45 degress around

sub new {
  my $self = shift->SUPER::new (@_);
  $self->{'wider'} ||= 0;  # default
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### Corner n_to_xy: $n

  # $n<0.5 no good for Math::BigInt circa Perl 5.12, compare in integers
  if (2*$n < 1) {
    return;
  }

  my $wider = $self->{'wider'};

  # wider==0
  #   vertical at X=0 has N=1, 2, 5, 10, 17, 26
  #   but start 0.5 back so at X=-0.5 have N=0.5, 1.5, 4.5, 9.5, 16.5, 25.5
  #   N = (Y^2 + 1/2)
  #   Y = floor sqrt(N - 1/2)
  #     = floor sqrt(4*N - 2)/2   staying in integers for the sqrt()
  #
  # wider==1
  #   0.5 back so at X=-0.5 have N=0.5, 2.5, 6.5, 12.5
  #   N = (Y^2 + Y + 1/2)
  #   Y = floor -1/2 + sqrt(N - 1/4)
  #     = floor (-1 + sqrt(4*N - 1))/2
  #
  # wider==2
  #   0.5 back so at X=-0.5 have N=0.5, 3.5, 8.5, 15.5
  #   N = (Y^2 + 2 Y + 1/2)
  #   Y = floor -1 + sqrt(N + 1/2)
  #     = floor (-2 + sqrt(4*N + 2))/2
  #
  # wider==3
  #   0.5 back so at X=-0.5 have N=0.5, 4.5, 10.5, 18.5
  #   N = (Y^2 + 3 Y + 1/2)
  #   Y = floor -3/2 + sqrt(N + 7/4)
  #     = floor (-3 + sqrt(4*N + 7))/2
  #
  # 0,1,4,9
  # my $y = int((sqrt(4*$n + -1) - $wider) / 2);
  # ### y frac: (sqrt(4*$n + -1) - $wider) / 2

  my $y = int((sqrt(int(4*$n) + $wider*$wider - 2) - $wider) / 2);
  ### y frac: (sqrt(int(4*$n) + $wider*$wider - 2) - $wider) / 2
  ### $y

  # diagonal at X=Y has N=1, 3, 7, 13, 21
  # N = ((Y + 1)*Y + (Y+1)*wider + 1)
  #   = ((Y + 1 + wider)*Y + wider + 1)
  # so subtract that leaving N negative on the horizontal part, or positive
  # for the downward vertical part
  #
  $n -= $y*($y+1+$wider) + $wider + 1;
  ### corner n: $y*($y+1+$wider) + $wider + 1
  ### rem: $n
  ### assert: $n!=$n || $n >= -($y+$wider+0.5)
  # ### assert: $n <= ($y+0.5)

  if ($n < 0) {
    # top horizontal
    return ($n + $y+$wider,
            $y);
  } else {
    # right vertical
    return ($y+$wider,
            -$n + $y);
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### Corner xy_to_n(): "$x,$y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($x < 0 || $y < 0) {
    return undef;
  }

  my $wider = $self->{'wider'};
  my $xw = $x - $wider;
  if ($y >= $xw) {
    ### top edge, N left is: $y*$y + $wider*$y + 1
    return ($y*$y + $wider*$y + 1  # Y axis N value
            + $x);                 # plus X offset across
  } else {
    ### right vertical, N diag is: $xw*$xw + $xw*$wider
    ### $xw
    # Ndiag = Nleft + Y+w
    # N = xw*xw + w*xw + 1 + xw+w + (xw - y)
    #   = xw*xw + w*xw + 1 + xw+w + xw - y
    #   = xw*xw + xw*(w+2) + 1 + w - y
    #   = xw*(xw + w+2) + w+1 - y
    return $xw*($xw+$wider+2) + $wider + 1 - $y;
  }
}

# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### Corner rect_to_n_range(): "$x1,$y1, $x2,$y2"

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);
  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }

  if ($y2 < 0 || $x2 < 0) {
    return (1, 0); # rect all negative, no N
  }

  if ($x1 < 0) { $x1 = 0; }
  if ($y1 < 0) { $y1 = 0; }

  my $wider = $self->{'wider'};
  my $ylo = $y1;
  my $xw = $x1 - $wider;

  if ($y1 <= $xw) {
    # left column is partly or wholly below X=Y diagonal
    #
    # make x1,y1 the min pos
    $y1 = ($y2 < $xw

           # wholly below diag, min "*" is at top y2 of the x1 column
           #
           # |        /
           # |       /
           # |      / *------+  y2
           # |     /  |      |
           # |    /   +------+  y1
           # |   /   x1     x2
           # +------------------
           #    ^.....^
           #    wider  xw
           #
           ? $y2

           # only partly below diag, min "*" is the X=Y+wider diagonal at x1
           #
           #            /
           # |      +------+  y2
           # |      | /    |
           # |      |/     |
           # |      *      |
           # |     /|      |
           # |    / +------+  y1
           # |   /  x1     x2
           # +------------------
           #    ^...^xw
           #    wider
           #
           : $xw);
  }

  if ($y2 <= $x2 - $wider) {
    # right column entirely at or below X=Y+wider diagonal so max is at the
    # ylo bottom end of the column
    #
    # |          /
    # |       --/---+  y2
    # |      | /    |
    # |      |/     |
    # |      /      |
    # |     /|      |
    # |    / +------+  ylo
    # |   /         x2
    # +------------------
    #    ^
    #    wider
    #
    $y2 = $ylo;   # x2,y2 now the max pos
  }

  ### min xy: "$x1,$y1"
  ### max xy: "$x2,$y2"
  return ($self->xy_to_n ($x1,$y1),
          $self->xy_to_n ($x2,$y2));
}

1;
__END__

=for stopwords pronic SacksSpiral PyramidSides PyramidRows PlanePath Ryde Math-PlanePath ie

=head1 NAME

Math::PlanePath::Corner -- points shaped around in a corner

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
    Y=0  |   1   4   9  16  25
          ----------------------
           X=0   1   2   3   4

The horizontal 1,4,9,16,etc along Y=0 is the perfect squares.  This is since
each further row/column stripe makes a one-bigger square,

                            10 11 12 13
               5  6  7       5  6  7 14
    2  3       2  3  8       2  3  8 15
    1  4       1  4  9       1  4  9 16

     2x2        3x3           4x4

The diagonal 2,6,12,20,etc upwards from X=0,Y=1 is the pronic numbers
k*(k+1), half way between those squares.

Each row/column stripe is 2 longer than the previous, similar to the
PyramidRows, PyramidSides and SacksSpiral paths.  The Corner and the
PyramidSides are the same, just the PyramidSides stretched out to two
quadrants instead of one for this Corner.

=head2 Wider

An optional C<wider =E<gt> $integer> makes the path wider horizontally,
becoming a rectangle.  For example

    $path = Math::PlanePath::Corner->new (wider => 3);

gives

     4  |  29--30--31--...
        |
     3  |  19--20--21--22--23--24--25
        |                           |
     2  |  11--12--13--14--15--16  26
        |                       |   |
     1  |   5-- 6-- 7-- 8-- 9  17  27
        |                   |   |   |
    Y=0 |   1-- 2-- 3-- 4  10  18  28
        |
         -----------------------------
            ^
           X=0  1   2   3   4   5   6

The initial N=1 is C<wider> many further places to the right before going up
to the Y axis, then the path makes corners around that shape.

Each loop is still 2 longer than the previous, as the widening is a constant
amount in each loop.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::Corner-E<gt>new ()>

=item C<$path = Math::PlanePath::Corner-E<gt>new (wider =E<gt> $w)>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n < 0.5> the return is an empty list, it being considered there are
no points before 1 in the corner.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each
point as a square of side 1, so the quadrant x>=-0.5 and y>=-0.5 is entirely
covered.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

The returned range is exact, meaning C<$n_lo> and C<$n_hi> are the smallest
and biggest in the rectangle.

=back

=head1 FORMULAS

=head2 N to X,Y

Counting d=0 for the first row at Y=0, then the start of that row
N=1,2,5,10,17,etc is

    StartN(d) = d^2 + 1

The current C<n_to_xy()> code extends to the left by an extra 0.5 for
fractional N, so for example N=9.5 is at X=-0.5,Y=3.  With this the starting
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

And the X,Y coordinates thus

    if (Rem < 0)  then X=d+Rem, Y=d
    if (Rem >= 0) then X=d, Y=d-Rem

=head2 X,Y to N

For a given X,Y the bigger of X or Y determines the d row.  If YE<gt>=X then
X,Y is on the horizontal part with d=Y and in that case StartN(d) above is
the N for X=0, and the given X can be added to that,

    N = StartN(d) + X
      = Y^2 + 1 + X

Or otherwise if YE<lt>X then X,Y is on the vertical and d=X.  In that case
the Y=0 is the last point on the row and is one back from the start of the
following row,

    LastN(d) = StartN(d+1) - 1
             = (d+1)^2

    N = LastN(d) - Y
      = (X+1)^2 - Y

=head2 Rectangle N Range

For C<rect_to_n_range()>, in each row X increasing is N increasing so the
smallest N is in the leftmost column and the biggest in the rightmost.

Going up a column, N values decrease until reaching X=Y, and then increase,
with the values above X=Y all bigger than the ones below.  This means the
biggest N is the top right corner if it has YE<gt>=X, otherwise the bottom
right corner.

For the smallest N, if the bottom left corner has YE<gt>X then it's in the
"increasing" part and that bottom left corner is the smallest N.  Otherwise
YE<lt>=X means some of the "decreasing" part is covered and the smallest N
is at Y=min(X,Ymax), ie. either the Y=X diagonal if it's in the rectangle or
the top right corner otherwise.

=head1 OEIS

This path is in Sloane's Online Encyclopedia of Integer Sequences as,

    http://oeis.org/A053188  (etc)

    A196199    X-Y, being runs -n to +n
    A053615    abs(X-Y), distance to next pronic
    A053188    wider=1 abs(X-Y), distance to nearest square
                 (extra initial 0)

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PyramidRows>,
L<Math::PlanePath::PyramidSides>,
L<Math::PlanePath::SacksSpiral>,
L<Math::PlanePath::Diagonals>

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

# Local variables:
# compile-command: "math-image --path=Corner,wider=1 --all --output=numbers"
# End:
