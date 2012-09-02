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


# n_start=0 for A196199 X coord

package Math::PlanePath::PyramidSides;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 87;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use Math::PlanePath::Base::Generic
  'round_nearest';

# uncomment this to run the ### lines
#use Smart::Comments;


use constant class_y_negative => 0;
use constant n_frac_discontinuity => .5;

sub new {
  my $self = shift->SUPER::new(@_);
  if (! defined $self->{'n_start'}) {
    $self->{'n_start'} = $self->default_n_start;
  }
  return $self;
}

#                     21
#                 20  13  22
#             19  12   7  14  23
#         18  11   6   3   8  15  24
#     17  10   5   2   1   4   9  16  25
#
# starting each left side at 0.5 before
#
# s =   0,   1,   2,   3,    4
# n = 0.5, 1.5, 4.5, 9.5, 16.5
# base = $s*$s + 0.5
# s = sqrt($n - 1/2)
# peak at +$s+0.5 into the remainder
# y = $s less the +/- $n from that peak
# centre n putting 0 as the peak
#   = n - ($s+0.5) - base
#   = n - ($s*$s + 0.5 + $s + 0.5)
#   = n - ($s*($s+1) + 1)
#
sub n_to_xy {
  my ($self, $n) = @_;
  ### PyramidSides n_to_xy: $n

  # adjust to N=1 at origin X=0,Y=0
  $n = $n - $self->{'n_start'} + 1;

  # $n<0.5 no good for Math::BigInt circa Perl 5.12, compare in integers
  return if 2*$n < 1;

  my $s = int(sqrt (int(4*$n) - 2) / 2);
  $n -= $s*($s+1) + 1;   # to n=0 at centre, +/- distance from there

  ### s frac: (sqrt (int(4*$n) - 2) / 2)
  ### $s
  ### remainder: $n

  return ($n,
          - abs($n) + $s);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### PyramidSides xy_to_n(): $x, $y

  $y = round_nearest ($y);
  if ($y < 0) {
    return undef;
  }
  $x = round_nearest ($x);

  my $s = abs($x) + $y;
  return $s*$s + $x+$s + $self->{'n_start'};
}

# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = round_nearest ($x1);
  $y1 = round_nearest ($y1);
  $x2 = round_nearest ($x2);
  $y2 = round_nearest ($y2);

  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); } # swap to y1<=y2
  if ($y2 < 0) {
    return (1, 0); # rect all negative, no N
  }
  if ($y1 < 0) { $y1 = 0; }

  my ($xlo, $xhi) = (abs($x1) < abs($x2)   # lo,hi by absolute value
                     ? ($x1, $x2)
                     : ($x2, $x1));
  if ($x2 == -$x1) {
    # when say x1=-5 x2=+5 then x=+5 is the bigger N
    $xhi = abs($xhi);
  }
  if (($x1 >= 0) ^ ($x2 >= 0)) {
    # if x1>=0 and x2<0 or other way around then x=0 is covered and is the
    # smallest N
    $xlo = 0;
  }

  return ($self->xy_to_n ($xlo, $y1),
          $self->xy_to_n ($xhi, $y2));
}

1;
__END__

=for stopwords pronic PyramidRows versa PlanePath Ryde Math-PlanePath ie Euler's OEIS

=head1 NAME

Math::PlanePath::PyramidSides -- points along the sides of pyramid

=head1 SYNOPSIS

 use Math::PlanePath::PyramidSides;
 my $path = Math::PlanePath::PyramidSides->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path puts points in layers along the sides of a pyramid growing
upwards.

                        21                        4
                    20  13  22                    3
                19  12   7  14  23                2
            18  11   6   3   8  15  24            1
        17  10   5   2   1   4   9  16  25    <- Y=0
       ------------------------------------
                         ^
    ... -4  -3  -2  -1  X=0  1   2   3   4 ...

The 1,4,9,16,etc along the X axis to the right are the perfect squares.  The
vertical 2,6,12,20,etc at X=-1 is the pronic numbers k*(k+1) half way
between those successive squares.

The pattern is the same as the Corner path but turned and spread so the
single quadrant in the Corner becomes a half-plane here.

The pattern is similar to PyramidRows, just with the columns dropped down
vertically to start at the X axis.  Any pattern occurring within a column is
unchanged, but what was a row becomes a diagonal and vice versa.

=head2 Lucky Numbers of Euler

An interesting sequence for this path is Euler's k^2+k+41.  The low values
are spread around a bit, but from N=1763 (k=41) they're the vertical at
X=40.  There's quite a few primes in this quadratic and when plotting primes
that vertical stands out a little denser than its surrounds (at least for up
to the first 2500 or so values).  The line shows in other step==2 paths too,
but not as clearly.  In the PyramidRows for instance the beginning is up at
Y=40, and in the Corner path it's a diagonal.

=head2 N Start

The default is to number points starting N=1 as shown above.  An optional
C<n_start> can give a different start, in the same pyramid sequence.  For
example to start at 0,

=cut

# math-image --path=PyramidSides,n_start=0 --all --output=numbers --size=48x5

=pod

    n_start => 0

                20                    4
             19 12 21                 3
          18 11  6 13 22              2
       17 10  5  2  7 14 23           1
    16  9  4  1  0  3  8 15 24    <- Y=0
    --------------------------
    -4 -3 -2 -1 X=0 1  2  3  4

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::PyramidSides-E<gt>new ()>

=item C<$path = Math::PlanePath::PyramidSides-E<gt>new (n_start =E<gt> $integer)>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n < 0.5> the return is an empty list, it being considered there are no
negative points in the pyramid.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer which has the effect of treating points
in the pyramid as a squares of side 1, so the half-plane y>=-0.5 is entirely
covered.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

The returned range is exact, meaning C<$n_lo> and C<$n_hi> are the smallest
and biggest in the rectangle.

=back

=head1 FORMULAS

=head2 Rectangle to N Range

For C<rect_to_n_range()>, in each column N increases so the biggest N is in
the topmost row and and smallest N in the bottom row.

In each row N increases along the sequence X=0,-1,1,-2,2,-3,3, etc.  So the
biggest N is at the X of biggest absolute value and preferring the positive
X=k over the negative X=-k.

The smallest X conversely is at the X of smallest absolute value.  When the
range C<$x1> to C<$x2> crosses 0, ie. C<$x1> and C<$x2> have different
signs, then X=0 is the smallest.

=head1 OEIS

Entries in Sloane's Online Encyclopedia of Integer Sequences related to this
path include

    http://oeis.org/A196199  (etc)

    n_start=1 (the default)
      A002522    N on X negative axis, x^2+1
      A033951    N on X=Y diagonal, 4d^2+3d+1

    n_start=0
      A196199    X coordinate, runs -n to +n
      A000196    abs(X)+abs(Y), floor(sqrt(N)),
                   k repeated 2k+1 times starting 0

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PyramidRows>,
L<Math::PlanePath::Corner>,
L<Math::PlanePath::DiamondSpiral>,
L<Math::PlanePath::SacksSpiral>,
L<Math::PlanePath::MPeaks>

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
