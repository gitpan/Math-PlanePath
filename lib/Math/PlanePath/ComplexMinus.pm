# Copyright 2011, 2012, 2013 Kevin Ryde

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


# math-image --path=ComplexMinus --lines --scale=10
# math-image --path=ComplexMinus --all --output=numbers_dash --size=80x50

package Math::PlanePath::ComplexMinus;
use 5.004;
use strict;
use List::Util 'min';
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 110;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'digit_split_lowtohigh',
  'digit_join_lowtohigh';

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;

use constant parameter_info_array =>
  [ { name        => 'realpart',
      display     => 'Real Part',
      type        => 'integer',
      default     => 1,
      minimum     => 1,
      width       => 2,
      description => 'Real part r in the i-r complex base.',
    } ];


sub absdx_minimum {
  my ($self) = @_;
  return ($self->{'realpart'} == 1
          ? 0   # i-1 N=3 dX=0,dY=-3
          : 1); # i-r otherwise always diff
}

# realpart=1
# dx=1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0 = (6*16^k-2)/15
# dy=1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,1 = ((9*16^5-1)/15-1)/2+1
# approaches dx=6/15=12/30, dy=9/15/2=9/30

# FIXME: are others smaller than East ?
sub dir_maximum_dxdy {
  my ($self) = @_;
  if ($self->{'realpart'} == 1) { return (12,-9); }
  else { return (0,0); }
}

#------------------------------------------------------------------------------
sub new {
  my $self = shift->SUPER::new(@_);

  my $realpart = $self->{'realpart'};
  if (! defined $realpart || $realpart < 1) {
    $self->{'realpart'} = $realpart = 1;
  }
  $self->{'norm'} = $realpart*$realpart + 1;
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### ComplexMinus n_to_xy(): $n

  if ($n < 0) { return; }
  if (is_infinite($n)) { return ($n,$n); }

  # is this sort of midpoint worthwhile? not documented yet
  {
    my $int = int($n);
    ### $int
    ### $n
    if ($n != $int) {
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $frac = $n - $int;  # inherit possible BigFloat
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int;       # BigFloat int() gives BigInt, use that
  }

  my $x = 0;
  my $y = 0;
  my $dx = 1;
  my $dy = 0;
  my $realpart = $self->{'realpart'};
  my $norm = $self->{'norm'};

  foreach my $digit (digit_split_lowtohigh($n,$norm)) {
    ### at: "$x,$y  digit=$digit"

    $x += $digit * $dx;
    $y += $digit * $dy;

    # multiply i-r, ie. (dx,dy) = (dx + i*dy)*(i-$realpart)
    $dy = -$dy;
    ($dx,$dy) = ($dy - $realpart*$dx,
                 $dx + $realpart*$dy);
  }

  ### final: "$x,$y"
  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### ComplexMinus xy_to_n(): "$x, $y"

  $x = round_nearest ($x);
  $y = round_nearest ($y);

  my $realpart = $self->{'realpart'};
  {
    my $rx = $realpart*$x;
    my $ry = $realpart*$y;
    foreach my $overflow ($rx+$ry, $rx-$ry) {
      if (is_infinite($overflow)) { return $overflow; }
    }
  }

  my $norm = $self->{'norm'};
  my $zero = ($x * 0 * $y);  # inherit bignum 0
  my @n; # digits low to high

  while ($x || $y) {
    my $new_y = $y*$realpart + $x;

    my $digit = $new_y % $norm;
    push @n, $digit;

    $x -= $digit;
    $new_y = $digit - $new_y;

    # div i-realpart,
    # is (i*y + x) * -(i+realpart)/norm
    #  x = [ x*realpart - y ] / -norm
    #    = [ y - x*realpart ] / norm
    #  y = - [ y*realpart + x ] / norm
    #

    ### assert: (($y - $x*$realpart) % $norm) == 0
    ### assert: ($new_y % $norm) == 0

    ($x,$y) = (($y - $x*$realpart) / $norm,
               $new_y / $norm);
  }
  return digit_join_lowtohigh (\@n, $norm, $zero);
}

# for i-1 need level=6 to cover 8 points surrounding 0,0
# for i-2 and higher level=3 is enough

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### ComplexMinus rect_to_n_range(): "$x1,$y1  $x2,$y2"

  my $xm = max(abs($x1),abs($x2));
  my $ym = max(abs($y1),abs($y2));

  return (0,
          int (($xm*$xm + $ym*$ym)
               * $self->{'norm'} ** ($self->{'realpart'} > 1
                                     ? 4
                                     : 8)));
}

1;
__END__

=for stopwords eg Ryde Math-PlanePath 0.abcde twindragon ie 0xC 0,1,0xC,0xD OEIS ACM

=head1 NAME

Math::PlanePath::ComplexMinus -- twindragon and other complex number base i-r

=head1 SYNOPSIS

 use Math::PlanePath::ComplexMinus;
 my $path = Math::PlanePath::ComplexMinus->new (realpart=>1);
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

X<Penney, Walter>X<Twindragon>This path traverses points by a complex number
base i-r for given integer r.  The default is base i-1 as per

=over

Walter Penny, A "Binary" System for Complex Numbers, Journal of the ACM,
volume 12, number 2, April 1965, pages 247-248.

=back

When continued to a power-of-2 extent this has come to be called the
"twindragon" shape.

=cut

# math-image --path=ComplexMinus --expression='i<64?i:0' --output=numbers

=pod

          26 27       10 11                       3
             24 25        8  9                    2
    18 19 30 31  2  3 14 15                       1
       16 17 28 29  0  1 12 13                <- Y=0
    22 23        6  7 58 59       42 43          -1
       20 21        4  5 56 57       40 41       -2
                50 51 62 63 34 35 46 47          -3
                   48 49 60 61 32 33 44 45       -4
                54 55       38 39                -5
                   52 53       36 37             -6

                    ^
    -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7

A complex integer can be represented as a set of powers,

    X+Yi = a[n]*b^n + ... + a[2]*b^2 + a[1]*b + a[0]
    base b=i-1
    digits a[n] to a[0] either 0 or 1

    N = a[n]*2^n + ... + a[2]*2^2 + a[1]*2 + a[0]

N is those a[i] digits as bits and X,Y is the resulting complex number.  It
can be shown that this is a one-to-one mapping so every integer X,Y of the
plane is visited.

The shape of points N=0 to N=2^level-1 repeats as N=2^level to
N=2^(level+1)-1.  For example N=0 to N=7 is repeated as N=8 to N=15, but
starting at X=2,Y=2 instead of the origin.  That position 2,2 is because b^3
= 2+2i.  There's no rotations or mirroring etc in this replication, just
position offsets.

    N=0 to N=7          N=8 to N=15 repeat shape

    2   3                    10  11
        0   1                     8   9
    6   7                    14  15
        4   5                    12  13

For b=i-1 each N=2^level point starts at b^level.  The powering of that b
means the start position rotates around by +135 degrees each time and
outward by a radius factor sqrt(2) each time.  So for example b^3 = 2+2i is
followed by b^4 = -4, which is 135 degrees around and radius |b^3|=sqrt(8)
becoming |b^4|=sqrt(16).

=head2 Real Part

The C<realpart =E<gt> $r> option gives a complex base b=i-r for a given
integer rE<gt>=1.  For example C<realpart =E<gt> 2> is

    20 21 22 23 24                                               4
          15 16 17 18 19                                         3
                10 11 12 13 14                                   2
                       5  6  7  8  9                             1
             45 46 47 48 49  0  1  2  3  4                   <- Y=0
                   40 41 42 43 44                               -1
                         35 36 37 38 39                         -2
                               30 31 32 33 34                   -3
                      70 71 72 73 74 25 26 27 28 29             -4
                            65 66 67 68 69                      -5
                                  60 61 62 63 64                -6
                                        55 56 57 58 59          -7
                                              50 51 52 53 54    -8
                             ^
    -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7  8  9 10

N is broken into digits of base=norm=r*r+1, ie. digits 0 to r*r inclusive.
This makes horizontal runs of r*r+1 many points, such as N=5 to N=9 etc
above.  In the default r=1 these runs are 2 long whereas for r=2 they're
2*2+1=5 long, or r=3 would be 3*3+1=10, etc.

The offset back for each run like N=5 shown is the r in i-r, then the next
level is (i-r)^2 = (-2r*i + r^2-1) so N=25 begins at Y=-2*2=-4, X=2*2-1=3.

The successive replications tile the plane for any r, though the N values
needed to rotate around and do so become large if norm=r*r+1 is large.

=head2 X Axis Values

For base i-1, the X axis N=0,1,12,13,16,17,etc is integers using only digits
0,1,0xC,0xD in hexadecimal.  Those on the positive X axis have an odd number
of digits and on the X negative axis an even number of digits.

To be on the X axis the imaginary parts of the base powers b^k must cancel
out to leave just a real part.  The powers repeat in an 8-long cycle

    k    b^k for b=i-1
    0        +1
    1      i -1
    2    -2i +0   \ pair cancel
    3     2i +2   /
    4        -4
    5    -4i +4
    6     8i +0   \ pair cancel
    7    -8i -8   /

The k=0 and k=4 bits are always reals and can always be included.  Bits k=2
and k=3 have imaginary parts -2i and 2i which cancel out, so they can be
included together.  Similarly k=6 and k=7 with 8i and -8i.  The two blocks
k=0to3 and k=4to7 differ only in a negation so the bits can be reckoned in
groups of 4, which is hexadecimal.  Bit 1 is digit value 1 and bits 2,3
together are digit value 0xC, so adding one or both of those gives
combinations are 0,1,0xC,0xD.

The high hex digit determines the sign, positive or negative, of the total
real part.  Bits k=0 or k=2,3 are positive.  Bits k=4 or k=6,7 are negative,
so

    N for X>0   N for X<0

      0x01..     0x1_..     even number of hex 0,1,C,D following
      0x0C..     0xC_..     "_" digit any of 0,1,C,D
      0x0D..     0xD_..

which is equivalent to XE<gt>0 is an odd number of hex digits or XE<lt>0 is
an even number.  For example N=28=0x1C is at X=-2 since that N is XE<lt>0
form "0x1_".

The order of the values on the positive X axis is obtained by taking the
digits in reverse order on alternate positions

    0,1,C,D   high digit
    D,C,1,0
    0,1,C,D
    ...
    D,C,1,0
    0,1,C,D   low digit

For example in the following notice the first and third digit increases, but
the middle digit decreases,

    X=4to7     N=0x1D0,0x1D1,0x1DC,0x1DD
    X=8to11    N=0x1C0,0x1C1,0x1CC,0x1CD
    X=12to15   N=0x110,0x111,0x11C,0x11D
    X=16to19   N=0x100,0x101,0x10C,0x10D
    X=20to23   N=0xCD0,0xCD1,0xCDC,0xCDD

For the negative X axis it's the same if reading by increasing X,
ie. upwards toward +infinity, or the opposite way around if reading
decreasing X, ie. more negative downwards toward -infinity.

=head2 Fractal

The i-1 twindragon is usually conceived as taking fractional N like 0.abcde
in binary and giving fractional complex X+iY.  The twindragon is then all
the points of the complex plane reached by such fractional N.  This set of
points can be shown to be connected and to fill a certain radius around the
origin.

The code here might be pressed into use for that to some finite number of
bits by multiplying up to make an integer N

    Nint = Nfrac * 256^k
    Xfrac = Xint / 16^k
    Yfrac = Yint / 16^k

256 is a good power because b^8=16 is a positive real and so there's no
rotations to apply to the resulting X,Y, just a power-of-16 division
(b^8)^k=16^k each.  Using b^4=-4 for a multiplier 16^k and divisor (-4)^k
would be almost as easy too, requiring just a sign change if k odd.

=head2 Boundary Length

X<Gilbert, William J.>The length of the boundary of the first norm^k many
points (N=0 to norm^k-1 inclusive) is calculated in

=over

William J. Gilbert, "The Fractal Dimension of Sets Derived From Complex
Bases", Canadian Math Bulletin, volume 29(4), 1986.
L<http://www.math.uwaterloo.ca/~wgilbert/Research/GilbertFracDim.pdf>

=back

The result is a 3rd-order recurrence.  For the twindragon it is

    realpart=1
    boundary[k] = boundary[k-1] + 2*boundary[k-3]

    4, 6, 10, 18, 30, 50, 86, 146, 246, 418, 710, ...

The first three boundaries are as follows.  Then the recurrence gives the
next boundary[3] = 10+2*4 = 18.

     k      area     boundary[k]
    ---     ----     -----------
                                       +---+
     0     2^k = 1       4             | 0 |
                                       +---+

                                       +---+---+
     1     2^k = 2       6             | 0   1 |
                                       +---+---+

                                   +---+---+
                                   | 2   3 |
     2     2^k = 4      10         +---+   +---+
                                       | 0   1 |
                                       +---+---+

Gilbert calculates the boundary of any i-r by taking it in three parts A,B,C
and showing how in the next replication level those parts transform into
multiple copies of the preceding level parts.  The replication is a little
easier to visualize for a bigger "r" than for the twindragon.  In bigger r
it's clearer how the A, B and C parts differ.

    A -> A * (2*realpart-1)             + C * 2*realpart
    B -> A * (realpart^2-2*realpart+2)  + C * (realpart-1)^2
    C -> B

    starting from
      A = 2*realpart
      B = 2
      C = 2 - 2*realpart

    total boundary = A+B+C

For the twindragon realpart=1 these A,B,C are already in the form of a
recurrence A-E<gt>A+2*C, B-E<gt>A, C-E<gt>B, per the formula above.  For
other real parts a little matrix rearrangement gives the recurrence

    boundary[k] = boundary[k-1] * (2*realpart - 1)   
                + boundary[k-2] * (norm - 2*realpart)
                + boundary[k-3] * norm               

    starting from
      boundary[0] = 4
      boundary[1] = 2*norm + 2
      boundary[2] = 2*(norm-1)*(realpart+2) + 4

For example

    realpart=2
    boundary[k] = 3*boundary[k-1] + 1*boundary[k-2] + 5*boundary[k-1]

    4, 12, 36, 140, 516, 1868, 6820, 24908, ...

As with all such recurrences, for large k values can be calculated by
powering up the matrix form.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::ComplexMinus-E<gt>new ()>

=item C<$path = Math::PlanePath::ComplexMinus-E<gt>new (realpart =E<gt> $r)>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

C<$n> should be an integer, it's unspecified yet what will be done for a
fraction.

=back

=head1 FORMULAS

=head2 X,Y to N

A given X,Y representing X+Yi can be turned into digits of N by successive
complex divisions by i-r.  Each digit of N is a real remainder 0 to r*r
inclusive from that division.

As per the base formula above

    X+Yi = a[n]*b^n + ... + a[2]*b^2 + a[1]*b + a[0]

and we will want the a[0]=digit to be a real 0 to r*r.  Subtracting a[0] and
dividing by b will give

    (X+Yi - digit) / (i-r)
    = - (X-digit + Y*i) * (i+r) / norm
    = (Y - (X-digit)*r)/norm
      + i * - ((X-digit) + Y*r)/norm

which is

    X   <-   Y - (X-digit)*r)/norm
    Y   <-   -((X-digit) + Y*r)/norm

The a[0] digit must make both X and Y parts integers.  The easiest to
calculate from is the imaginary part,

    - ((X-digit) + Y*r) == 0 mod norm

so

    digit = X + Y*r mod norm

This digit value makes the real part a multiple of norm too, as can be seen
from

    Y - (X-digit)*r
    = Y - X*r - (X+Y*r)*r
    = Y - X*r - X*r + Y*r*r
    = Y*(r*r+1)
    = Y*norm

Notice the new Y is the quotient from (X+Y*r)/norm rounded towards negative
infinity.  Ie. in the division "X+Y*r mod norm" which calculates the digit,
the quotient is the new Y and the remainder is the digit.

=cut

# Is this quite right ? ...
#
# =head2 Radius Range
#
# In general for base i-1 after the first few innermost levels each
# N=2^level increases the covered radius around by a factor sqrt(2), ie.
#
#     N = 0 to 2^level-1
#     Xmin,Ymin closest to origin
#     Xmin^2+Ymin^2 approx 2^(level-7)
#
# The "level-7" is since the innermost few levels take a while to cover the
# points surrounding the origin.  Notice for example X=1,Y=-1 is not reached
# until N=58.  But after that it grows like N approx = pi*R^2.

=head1 OEIS

Entries in Sloane's Online Encyclopedia of Integer Sequences related to
this path include

=over

L<http://oeis.org/A066321> (etc)

=back

    realpart=1 (the default)
      A066321    N on X axis, being the base i-1 positive reals
      A066323    N on X axis, in binary
      A066322    diffs (N at X=16k+4) - (N at X=16k+3)
     
      A003476    boundary length / 2
                   recurrence a(n) = a(n-1) + 2*a(n-3)
      A203175    boundary length, starting from 4
                   if its conjectured recurrence is true
      A052537    boundary length part A, B or C per Gilbert's paper

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DragonCurve>,
L<Math::PlanePath::ComplexPlus>

=head1 HOME PAGE

L<http://user42.tuxfamily.org/math-planepath/index.html>

=head1 LICENSE

Copyright 2011, 2012, 2013 Kevin Ryde

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
