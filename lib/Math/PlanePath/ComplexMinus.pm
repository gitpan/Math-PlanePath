# Copyright 2011, 2012 Kevin Ryde

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
use POSIX 'ceil';

use vars '$VERSION', '@ISA';
$VERSION = 64;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;

use constant parameter_info_array =>
  [ { name      => 'realpart',
      type      => 'integer',
      default   => 1,
      minimum   => 1,
      width     => 2,
    } ];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
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
  if (_is_infinite($n)) { return ($n,$n); }

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

  while ($n) {
    ### at: "$x,$y"
    ### digit: ($n % $norm)

    my $digit = $n % $norm;
    $n = int($n/$norm);

    $x += $digit * $dx;
    $y += $digit * $dy;

    # (dx,dy) = (dx + i*dy)*(i-$realpart)
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

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if (_is_infinite($x)) { return ($x); }
  if (_is_infinite($y)) { return ($y); }

  my $realpart = $self->{'realpart'};
  my $norm = $self->{'norm'};

  my $n = ($x * 0 * $y);  # inherit bignum 0
  my $power = $n + 1;     # inherit bignum 1

  while ($x || $y) {
    my $new_y = $y*$realpart + $x;

    my $digit = $new_y % $norm;
    $n += $digit * $power;

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
    $power *= $norm;
  }
  return $n;
}

# for i-1 need level=6 to cover 8 points surrounding 0,0
# for i-2 and higher level=3 is enough

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### ComplexMinus rect_to_n_range(): "$x1,$y1  $x2,$y2"

  my $xm = _max(abs($x1),abs($x2));
  my $ym = _max(abs($y1),abs($y2));

  return (0,
          int (($xm*$xm + $ym*$ym)
               * $self->{'norm'} ** ($self->{'realpart'} > 1
                                     ? 4
                                     : 8)));
}

1;
__END__

=for stopwords eg Ryde Math-PlanePath 0.abcde twindragon ie

=head1 NAME

Math::PlanePath::ComplexMinus -- twindragon and other complex number base i-r

=head1 SYNOPSIS

 use Math::PlanePath::ComplexMinus;
 my $path = Math::PlanePath::ComplexMinus->new (realpart=>1);
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path traverses points by a complex number base i-r for given integer r.
The default is base i-1 which is the "twindragon" shape.

           26  27          10  11                             3
               24  25           8   9                         2
   18  19  30  31   2   3  14  15                             1
       16  17  28  29   0   1  12  13                     <- Y=0
   22  23           6   7  58  59          42  43            -1
       20  21           4   5  56  57          40  41        -2
                   50  51  62  63  34  35  46  47            -3
                       48  49  60  61  32  33  44  45        -4
                   54  55          38  39                    -5
                       52  53          36  37                -6

                        ^
    -5  -4  -3  -2 -1  X=0  1   2   3   4   5   6   7

In base b=i-1 a complex integer can be represented

    X+Yi = a[n]*b^n + ... + a[2]*b^2 + a[1]*b + a[0]

The digits a[n] to a[0] are all either 0 or 1.  N is those a[i] digits as
bits and X,Y is the resulting complex number.  It can be shown that this is
a one-to-one mapping so every integer point of the plane is visited.

The shape of points N=0 to N=2^level-1 is repeated in the next N=2^level to
N=(2*2^level)-1.  For example N=0 to N=7 is repeated as N=8 to N=15, but
starting at X=2,Y=2 instead of the origin.  That 2,2 is because b^3 = 2+2i.
There's no rotations or mirroring etc in this replication, just the position
moves.

    N=0 to N=7          N=8 to N=15 repeat shape

    2   3                    10  11    
        0   1                     8   9
    6   7                    14  15                       
        4   5                    12  13

For b=i-1 each N=2^level point starts at b^level.  The powering of that b
means the start position rotates around by +135 degrees each time, and
outward by a radius factor sqrt(2) each time.  So for example b^3 = 2+2i is
followed by b^4 = -4, which is 135 degrees around, and radius |b^3|=sqrt(8)
becomes |b^4|=sqrt(16).

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

N is broken into digits of base norm=r*r+1, ie. digits 0 to r*r inclusive.
This makes horizontal runs of r*r+1 many points, such as N=0 to N=4 then N=5
to N=9 etc above.  In the default r=1 these runs are 2 long, whereas for r=2
they're 2*2+1=5 long, or r=3 would be 3*3+1=10, etc.

The offset back for each run like N=5 shown is the r in i-r, then the next
level is (i-r)^2 = (-2r*i + r^2-1) so N=25 begins at Y=-2*2=-4, X=2*2-1=3.

The successive replications tile the plane for any r, though the N values
needed to rotate around and do so might become large if norm=r*r+1 is large.

=head2 Fractal

The i-1 twindragon is usually conceived as taking fractional N like 0.abcde
in binary and giving fractional complex X+iY.  The twindragon is then all
the points of the complex plane reached by such fractional N.  The set of
points can be shown to be connected and completely cover a certain radius
around the origin.

The code here might be pressed into use for that to some finite number of
bits of N by multiplying up to an integer by a chosen power k

    Nint = Nfrac * 256^k
    Xfrac = Xint / 16^k
    Yfrac = Yint / 16^k

256 is a good power because b^8=16 is a positive real and means there's no
rotations to apply to the X,Y, just a division by (b^8)^k.  b^4=-4 for
multiplier 16^k and divisor (-4)^k would be almost as easy.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

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
complex divisions by i-r, with each digit being a remainder 0 to r*r
inclusive from that division.

As per the base formula above

    X+Yi = a[n]*b^n + ... + a[2]*b^2 + a[1]*b + a[0]

and the target is the a[0] digit 0 to r*r.  Subtracting a[0] and dividing by
b will give

    (X+Yi - digit) / (i-r)
    = - (X-digit + Y*i) * (i+r) / norm
    = (Y - (X-digit)*r)/norm
      + i * - ((X-digit) + Y*r)/norm

ie.

    X   <-   Y - (X-digit)*r)/norm
    Y   <-   -((X-digit) + Y*r)/norm

The digit must make both X and Y parts integers.  The easiest to calculate
from is the imaginary part,

    - ((X-digit) + Y*r) == 0 mod norm

so

    digit = X + Y*r mod norm

That digit value makes the real part a multiple of norm too,

    Y - (X-digit)*r
    = Y - X*r - (X+Y*r)*r
    = Y - X*r - X*r + Y*r*r
    = Y*(r*r+1)
    = Y*norm

Notice the new Y is the quotient from (X+Y*r)/norm, rounded towards negative
infinity.  Ie. in the division "X+Y*r mod norm" calculating the digit the
quotient is the new Y and the remainder is the digit.

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

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DragonCurve>,
L<Math::PlanePath::ComplexPlus>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011, 2012 Kevin Ryde

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
