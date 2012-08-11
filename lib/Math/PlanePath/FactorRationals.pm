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


# David M. Bradley http://arxiv.org/abs/math/0509025
#   19 Yoram Sagher, Counting the rationals, AMM Nov 1989 p823
#   http://www.jstor.org/stable/2324846
# earlier inverse
#   6 Gerald Freilich, A denumerability formula for the rationals AMM Nov
#   1965 p1013-1014
#   http://www.jstor.org/stable/2313350
# prime powers
#   17 Kevin McCrimmon, Enumeration of the positive rationals AMM Nov 1960 p868
#   http://www.jstor.org/stable/2309448
#
# prime factors q1,..qk of n
# f(m/n) = m^2*n^2/ (q1q2...qk)
#
# http://blog.computationalcomplexity.org/2004/03/counting-rationals-quickly.html
#
# pn_encoding => 'alternate'
# pn_encoding => 'negabinary'


package Math::PlanePath::FactorRationals;
use 5.004;
use strict;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 85;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';

use Math::PlanePath::CoprimeColumns;
*_coprime = \&Math::PlanePath::CoprimeColumns::_coprime;


# uncomment this to run the ### lines
#use Smart::Comments;


use constant class_x_negative => 0;
use constant class_y_negative => 0;

sub n_to_xy {
  my ($self, $n) = @_;
  ### FactorRationals n_to_xy(): "$n"

  if ($n < 1) { return; }
  if (is_infinite($n)) { return ($n,$n); }

  # FIXME: what to do for fractional $n?
  {
    my $int = int($n);
    if ($n != $int) {
      ### frac ...
      my $frac = $n - $int;  # inherit possible BigFloat/BigRat
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      ### x1,y1: "$x1, $y1"
      ### x2,y2: "$x2, $y2"
      ### dx,dy: "$dx, $dy"
      ### result: ($frac*$dx + $x1).', '.($frac*$dy + $y1)
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int;
  }

  my $x = my $y = ($n * 0) + 1;  # inherit bignum 1
  my $prime = 2;
  my ($limit,$overflow) = _limit($n);
  ### $limit

  while ($prime <= $limit) {
    if (($n % $prime) == 0) {
      my $count = 0;
      for (;;) {
        $count++;
        $n /= $prime;
        if ($n % $prime) {
          ### odd, denominator ...
          $y *= $prime ** $count;
          last;
        }
        $n /= $prime;
        if ($n % $prime) {
          ### even, numerator ...
          $x *= $prime ** $count;
          last;
        }
      }
      ($limit,$overflow) = _limit($n);
      ### $limit
    }
    $prime += 1 + ($prime&1);
  }
  if ($overflow) {
    ### n too big ...
    return;
  }
  return ($x, $y*$n);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;

  $x = round_nearest ($x);
  $y = round_nearest ($y);
  ### FactorRationals xy_to_n(): "$x,$y"

  if (is_infinite($x)) { return $x; }
  if (is_infinite($y)) { return $y; }

  if ($x < 1 || $y < 1 || ! _coprime($x,$y)) {
    return undef;
  }

  my $ychop = my $ymult = $y;
  unless ($ychop % 2) {
    $ymult /= 2;
    do {
      $ychop /= 2;
    } until ($ychop % 2);
  }
  my ($limit,$overflow) = _limit($ychop);
  for (my $prime = 3; $prime <= $limit; $prime += 2) {
    unless ($ychop % $prime) {
      $ymult /= $prime;
      do {
        $ychop /= $prime;
      } until ($ychop % $prime);
      ($limit,$overflow) = _limit($ychop);
    }
  }
  if ($overflow) {
    return undef; # too big
  }

  $ymult /= $ychop; # remainder is a prime
  return $x*$x * $y*$ymult;
}

sub _limit {
  my ($n) = @_;
  my $limit = int(sqrt($n));
  my $cap = max (int(65536 * 10 / length($n)),
                 50);
  if ($limit > $cap) {
    return ($cap, 1);
  } else {
    return ($limit, 0);
  }
}

# X=2^10 -> N=2^20 is X*X
# Y=3 -> N=3
# Y=3^2 -> N=3^3
# Y=3^3 -> N=3^5
# Y=3^4 -> N=3^7
# Y*Y / distinct prime factors

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### rect_to_n_range()

  $x1 = round_nearest ($x1);
  $y1 = round_nearest ($y1);
  $x2 = round_nearest ($x2);
  $y2 = round_nearest ($y2);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### $x2
  ### $y2

  return (1,
          $x2*$x2 * $y2*$y2);
}


1;
__END__

=for stopwords eg Ryde OEIS ie Math-PlanePath Calkin-Wilf FactorRationals McCrimmon Freilich Yoram Sagher negabinary

=head1 NAME

Math::PlanePath::FactorRationals -- rationals by prime powers

=head1 SYNOPSIS

 use Math::PlanePath::FactorRationals;
 my $path = Math::PlanePath::FactorRationals->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

X<McCrimmon, Kevin>X<Freilich, Gerald>X<Sagher, Yoram>This path enumerates
rationals X/Y with no common factor, based on the prime powers in numerator
and denominator.  This idea might have been first by Kevin McCrimmon then
independently (was it?) by Gerald Freilich in reverse, and again by Yoram
Sagher.

    15  |      15   60       240            735  960           1815      
    14  |      14       126       350                1134      1694
    13  |      13   52  117  208  325  468  637  832 1053 1300 1573
    12  |      24                 600      1176                2904
    11  |      11   44   99  176  275  396  539  704  891 1100     
    10  |      10        90                 490       810      1210
     9  |      27  108       432  675      1323 1728      2700 3267
     8  |      32       288       800      1568      2592      3872
     7  |       7   28   63  112  175  252       448  567  700  847
     6  |       6                 150       294                 726
     5  |       5   20   45   80       180  245  320  405       605
     4  |       8        72       200       392       648       968
     3  |       3   12        48   75       147  192       300  363
     2  |       2        18        50        98       162       242
     1  |       1    4    9   16   25   36   49   64   81  100  121
    Y=0 |
         ----------------------------------------------------------
          X=0   1    2    3    4    5    6    7    8    9   10   11

An X,Y is mapped to N by

             X^2 * Y^2
    N = --------------------
        distinct primes in Y

The effect is to distinguish prime factors coming from the numerator or
denominator by making odd or even powers of those primes in N.

A rational X/Y has prime factor p with exponent p^s for either positive or
negative s.  Positive is in the numerator X, negative in the denominator Y.
This is turned into a power p^k in N,

    k = /  2*s      if s >= 0
        \  1-2*s    if s < 0

The effect is to map a signed s to positive k,

     s           k
    -1    <->    1
     1    <->    2
    -2    <->    3
     2    <->    4
    etc

For example (and other primes multiply in similarly),

   N=3   ->  3^-1 = 1/3
   N=9   ->  3^1  = 3/1
   N=27  ->  3^-2 = 1/9
   N=81  ->  3^2  = 9/1

Thinking in terms of X and Y values, the key is that since X and Y have no
common factor a prime p appears in one of X or Y but not both.  The
oddness/evenness of the p^k exponent in N can then encode which of the two
it appears in.

=head2 Various Values

The leftmost column at X=1 is integers with odd powers of prime factors.
That column is the fractions 1/Y so the s exponents of the primes there are
all negative and thus all exponents in N are odd.

The bottom row at Y=1 is the perfect squares.  That row is the integers X/1
so the s exponents there are all positive and thus in N become 2*s, giving
simply N=X^2.

As noted by David M. Bradley, other mappings of signed E<lt>-E<gt> unsigned
powers could give other enumerations.  The "negabinary" a[k]*(-2)^k is one
possibility, or the "reversing binary representation" (-1)^k*2^ek of Knuth
vol 2 section 4.1 exercise 27.  But the alternating + and - here keeps the
growth of N down to roughly X^2*Y^2, per the N=X^2*Y^2/Yprimes above.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over

=item C<$path = Math::PlanePath::FactorRationals-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return X,Y coordinates of point C<$n> on the path.  If there's no point
C<$n> then the return is an empty list.

This depends on factorizing C<$n> and in the current code there's a hard
limit on the amount of factorizing attempted.  If C<$n> is too big then the
return is an empty list.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the N point number for coordinates C<$x,$y>.  If there's nothing at
C<$x,$y>, such as when they have a common factor, then return C<undef>.

This depends on factorizing C<$y> and in the current code there's a hard
limit on the amount of factorizing attempted.  If C<$y> is too big then the
return is C<undef>.

=back

The current factorizing limits handle anything up to 2^32, and above that
numbers comprised of small factors, but big numbers with big factors are not
handled.  Is this a good idea?  For large inputs there's no merit in
disappearing into a nearly-infinite loop.  But perhaps the limits could be
configurable and/or some advanced factoring modules tried for a while
if/when available.

=head1 OEIS

This enumeration of the rationals is in Sloane's Online Encyclopedia of
Integer Sequences in the following forms

    http://oeis.org/A071974   (etc)

    A071974 - numerators, X
    A071975 - denominators, Y
    A019554 - product num*den, ie. X*Y
    A102631 - n^2/squarefreekernel(n), column at X=1
    A060837 - permutation DiagonalRationals -> FactorRationals
    A071970 - permutation Stern/CW -> FactorRationals

The last A071970 is rationals taken in order of the Stern diatomic sequence
stern[i]/stern[i+1], which is also the order of the Calkin-Wilf tree rows
(L<Math::PlanePath::RationalsTree/Calkin-Wilf Tree>).

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::GcdRationals>,
L<Math::PlanePath::RationalsTree>,
L<Math::PlanePath::CoprimeColumns>

David M. Bradley, "Counting the Positive Rationals: A Brief Survey",

    http://arxiv.org/abs/math/0509025

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011, 2012 Kevin Ryde

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
# compile-command: "math-image --path=FactorRationals --all --scale=10"
# End:
#
# math-image --path=FactorRationals --all --output=numbers
