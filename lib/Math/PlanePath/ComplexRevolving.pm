# Copyright 2012 Kevin Ryde

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



# math-image --path=ComplexRevolving --expression='i<128?i:0' --output=numbers --size=132x40


package Math::PlanePath::ComplexRevolving;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 65;

use Math::PlanePath 54; # v.54 for _max()
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;

# b=i+1
# X+iY = b^e0 + i*b^e1 + ... + i^t * b^et
#
sub n_to_xy {
  my ($self, $n) = @_;
  ### ComplexRevolving n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

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

  my $x = my $y = my $by = ($n * 0);  # inherit bignum 0
  my $bx = $x + 1;                    # inherit bignum 1

  for (;;) {
    if ($n % 2) {
      $x += $bx;
      $y += $by;
      ($bx,$by) = (-$by,$bx);  # (bx+by*i)*i = bx*i - by,  is rotate +90
    }
    $n = int($n/2) || last;
    # (bx+by*i) * (i+1)
    #   = bx*i+bx + -by + by*i
    #   = (bx-by) + i*(bx+by)
    ($bx,$by) = ($bx - $by,
                 $bx + $by);
  }

  ### final: "$x,$y"
  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### ComplexRevolving xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  if (_is_infinite($x)) { return ($x); }
  $y = _round_nearest ($y);
  if (_is_infinite($y)) { return ($y); }

  my $n = $x * 0 * $y;  # inherit bignum 0
  my $power = $n+1;     # inherit bignum 1

  while ($x || $y) {
    ### at: "$x,$y  power=$power  n=$n"

    # (a+bi)*(i+1) = (a-b)+(a+b)i
    #
    if (($x % 2) == ($y % 2)) {  # x+y even
    } else {
      ### not multiple of 1+i, take e0=0 for b^e0=1
      $n += $power;
      ### $n

      # [(x+iy)-1]/i
      #   = [(x-1)+yi]/i
      #   = y + (x-1)/i
      #   = y + (1-x)*i    # rotate -90
      ($x,$y) = ($y, 1-$x);

      ### sub and div to: "$x,$y"
    }

    # divide i+1 = mul (i-1)/(i^2 - 1^2)
    #            = mul (i-1)/-2
    # is (i*y + x) * (i-1)/-2
    #  x = (-x - y)/-2  = (x + y)/2
    #  y = (-y + x)/-2  = (y - x)/2
    #
    ($x,$y) = (($x+$y)/2, ($y-$x)/2);
    $power *= 2;
  }

  return $n;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### ComplexRevolving rect_to_n_range(): "$x1,$y1  $x2,$y2"

  my $xm = _max(abs($x1),abs($x2));
  my $ym = _max(abs($y1),abs($y2));

  return (0, int (32*($xm*$xm + $ym*$ym)));
}

1;
__END__

=for stopwords eg Ryde Math-PlanePath ie Nstart Nlevel Seminumerical et

=head1 NAME

Math::PlanePath::ComplexRevolving -- points in revolving complex base i+1

=head1 SYNOPSIS

 use Math::PlanePath::ComplexRevolving;
 my $path = Math::PlanePath::ComplexRevolving->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path traverses points by a complex number base i+1 with turn factor i
(+90 degrees) at each 1 bit.  This is the "revolving binary representation"
of Knuth's Seminumerical Algorithms section 4.1 exercise 28.

             54 51       38 35               5
          60 53       44 37                  4
    39 46 43 58 23 30 27 42                  3
       45  8 57  4 29 56 41 52               2
          31  6  3  2 15 22 19 50            1
    16    12  5  0  1 28 21    49        <- Y=0
    55 62 59 10  7 14 11 26                 -1
       61 24  9 20 13 40 25 36              -2
          47       18 63       34           -3
    32          48 17          33           -4

                 ^
    -4 -3 -2 -1 X=0 1  2  3  4  5

The 1 bit positions of N are exponents e0 to et

    N = 2^e0 + 2^e1 + ... + 2^et

and are applied to a base b=i+1 as

    X+iY = b^e0 + i * b^e1 + i^2 * b^e2 + ... + i^t * b^et

The b^ek parts have the same exponents as the bits of N, but base b=i+1
instead of base 2.  The i^k is an extra factor i at each 1 bit of N, causing
a rotation by +90 degrees for the bits above it.  Notice the factor is i^k
not i^ek, ie. it goes only with the 1 bits of N, not the whole exponent.

A single bit N=2^k is the simplest and is X+iY=(i+1)^k.  These
N=1,2,4,8,16,etc are at successive angles 45, 90, 135, etc degrees.  But
points N=2^k+1 with two bits means X+iY=(i+1) + i*(i+1)^k and that factor
"i*" is a rotation by 90 degrees so the points N=3,5,9,17,33,etc are in the
next quadrant around from their preceding 2,4,8,16,32.

As per the exercise in Knuth it's reasonably easy to show that this
calculation is a one-to-one mapping between integer N and complex integer
X+iY, so the path covers the plane and visits all points once each.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::ComplexRevolving-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::ComplexMinus>,
L<Math::PlanePath::ComplexPlus>,
L<Math::PlanePath::DragonCurve>

Donald Knuth, "The Art of Computer Programming", volume 2 "Seminumerical
Algorithms", section 4.1 exercise 28.

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2012 Kevin Ryde

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
