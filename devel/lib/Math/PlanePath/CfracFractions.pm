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

# DigitSumModulo base 10 something at left
# Modulo mod 9 at left

package Math::PlanePath::CfracFractions;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 89;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'round_down_pow',
  'digit_split_lowtohigh',
  'digit_join_lowtohigh';
*_divrem = \&Math::PlanePath::_divrem;

use Math::PlanePath::RationalsTree;
*_xy_to_quotients = \&Math::PlanePath::RationalsTree::_xy_to_quotients;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;
use constant class_x_negative => 0;
use constant class_y_negative => 0;

use constant parameter_info_array =>
  [ { name      => 'radix',
      share_key => 'radix_2_1',
      type      => 'integer',
      minimum   => 1,
      default   => 2,
      width     => 3,
    },
  ];

sub new {
  my $self = shift->SUPER::new (@_);
  if (! $self->{'radix'} || $self->{'radix'} < 1) {
    $self->{'radix'} = 2;
  }
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### CfracFractions n_to_xy(): "$n"

  if ($n < 0) { return; }
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

  my $radix = $self->{'radix'};
  my $zero = ($n * 0);  # inherit bignum 0
  my $x = $zero;
  my $y = 1+$zero;  # inherit bignum 1

  foreach my $q (_n_to_quotients($n,$radix)) {  # bottom to top
    ### at: "$x,$y   q=$q"

    # 1/(q + X/Y) = 1/((qY+X)/Y)
    #             = Y/(qY+X)
    ($x,$y) = ($y, $q*$y + $x);
  }

  ### return: "$x,$y"
  return ($x,$y);
}

# Return a list of quotients in order bottom to top.  The base3 digits of N
# are split by "3" delimiters and the parts adjusted so each q>=1 and the
# first which is the bottom-most >=2.  So the values ready to be used as
# continued fraction terms.
#
sub _n_to_quotients {
  my ($n, $radix) = @_;
  ### _n_to_quotients(): $n

  my $zero = $n*0;
  my @ret;
  my @group;
  foreach my $digit (_digit_split_1toR_lowtohigh($n,$radix+1)) {
    if ($digit == $radix+1) {
      ### @group
      push @ret, _digit_join_1toR_destructive(\@group, $radix, $zero) + 1;
      @group = ();
    } else {
      push @group, $digit;
    }
  }
  ### final group: @group
  push @ret, _digit_join_1toR_destructive(\@group, $radix, $zero) + 1;

  $ret[0] += 1;  # bottom-most is +2 rather than +1

  ### _n_to_quotients result: @ret
  return @ret;
}

# Return a list of digits 1 <= d <= R which is $n written in $radix, low to
# high digits.
sub _digit_split_1toR_lowtohigh {
  my ($n, $radix) = @_;
  ### assert: $radix >= 1
  if ($radix == 1) {
    return (1) x $n;
  }

  my @digits = digit_split_lowtohigh($n,$radix);

  # mangle 0 -> R
  my $borrow = 0;
  foreach my $digit (@digits) {   # low to high
    if ($borrow = (($digit -= $borrow) <= 0)) {  # modify array contents
      $digit += $radix;
    }
  }
  if ($borrow) {
    ### assert: $digits[-1] == $radix
    pop @digits;
  }

  return @digits;
}

# $aref is a list of continued fraction quotients from top-most to
# bottom-most.  There's no initial integer term in $aref.  Each quotient is
# q >= 1 except the bottom-most which q-1 and so also >=1.
#
sub _quotients_join_hightolow {
  my ($aref, $radix, $zero) = @_;
  ### _quotients_join_hightolow(): $aref

  my @digits;
  foreach my $q (reverse @$aref) {
    ### assert: $q >= 1
    push @digits, _digit_split_1toR_lowtohigh($q-1, $radix), $radix+1;
  }
  pop @digits;  # no high delimiter
  ### groups digits 1toR: @digits
  return _digit_join_1toR_destructive(\@digits, $radix+1, $zero);
}

sub _digit_join_1toR_destructive {
  my ($aref, $radix, $zero) = @_;
  ### assert: $radix >= 1

  if ($radix == 1) {
    return scalar(@$aref);
  }

  # mangle any digit==$radix down to digit=0
  my $carry = 0;
  foreach my $digit (@$aref) {   # low to high
    if ($carry = (($digit += $carry) >= $radix)) {  # modify array contents
      $digit -= $radix;
    }
  }
  if ($carry) {
    push @$aref, 1;
  }

  ### _digit_join_1toR_destructive() result: digit_join_lowtohigh($aref, $radix, $zero)
  return digit_join_lowtohigh($aref, $radix, $zero);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = round_nearest ($x);
  $y = round_nearest ($y);
  ### CfracFractions xy_to_n(): "$x,$y"

  if (is_infinite($x)) { return $x; }
  if (is_infinite($y)) { return $y; }
  if ($x < 1 || $y < 2 || $x >= $y) {
    return undef;
  }
  my $zero = $x * 0 * $y;   # inherit bignum 0

  my @quotients = _xy_to_quotients($x,$y)
    or return undef;  # $x,$y have a common factor
  ### @quotients

  # drop initial 0 integer part
  ### assert: $quotients[0] == 0
  shift @quotients;

  return _quotients_join_hightolow(\@quotients, $self->{'radix'}, $zero);
}


# X/Y = F[k]/F[k+1] quotients all 1
# N = all delimiter digits R
#   = R ** k
# k = log(Y)/log(phi)
# N = Y ** (log(R)/log(phi))

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


  #   |    /
  #   |   / x1
  #   |  /  +-----y2
  #   | /   |
  #   |/    +-----
  #
  if ($x2 < 1 || $y2 < 2 || $x1 >= $y2) {
    ### no values, rect outside upper octant ...
    return (1,0);
  }

  my $zero = ($x1 * 0 * $y1 * $x2 * $y2);  # inherit bignum
  my $radix = $self->{'radix'};

  return (0,
          ($radix+1 + $zero) ** ($radix == 1
                                 ? $y2
                                 : _log_phi_estimate($y2) + 2));
}

# Return an estimate of log base phi of $x, ie. log($x)/log(phi), where
# phi=(1+sqrt(5))/2 the golden ratio.
#
sub _log_phi_estimate {
  my ($x) = @_;
  my ($pow,$exp) = round_down_pow ($x, 2);
  return int ($exp * (log(2) / log((1+sqrt(5))/2)));
}


1;
__END__

=for stopwords eg Ryde OEIS ie Math-PlanePath coprime RationalsTree Harmonices Mundi octant onwards Aiton

=head1 NAME

Math::PlanePath::CfracFractions -- fractions by continued fraction encoding

=head1 SYNOPSIS

 use Math::PlanePath::CfracFractions;
 my $path = Math::PlanePath::CfracFractions->new (tree_type => 'Kepler');
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

X<Shallit, Jeffrey>This path enumerates fractions X/Y in the range
S<0 E<lt> X/Y E<lt> 1>, with X,Y no common factor, using a method by Jeffrey
Shallit.

    "Number Theory and Formal Languages"
    https://cs.uwaterloo.ca/~shallit/Papers/ntfl.ps

A fraction is mapped to an integer N by a radix encoding of the quotients in
its continued fraction form.  Fractions up to a given maximum denominator
are covered by roughly N=den^2.28.  This is a much smaller range than the
run-length encoding in RationalsTree and FractionsTree (but is bigger than
GcdRationals).

=cut

# math-image --path=CfracFractions --output=numbers_xy --all --size=78x17

=pod

    15  |    25  27      91          61 115         307     105 104
    14  |    23      48      65             119     111     103
    13  |    22  24  46  29  66  59 113 120 101 109  99  98
    12  |    17              60     114              97
    11  |    16  18  30  64  58 112 118 102  96  95
    10  |    14      28             100      94
     9  |    13  15      20  38      36  35
     8  |     8      21      39      34
     7  |     7   9  19  37  33  32
     6  |     5              31
     5  |     4   6  12  11
     4  |     2      10
     3  |     1   3
     2  |     0
     1  |
    Y=0 |
         ----------------------------------------------------------
        X=0   1   2   3   4   5   6   7   8   9  10  11  12  13  14

Any fraction S<0E<lt>X/YE<lt>1> has a finite continued fraction form

                      1
    X/Y = 0 + ---------------------
                            1
              q[k] + -----------------
                                  1
                     q[k-1] + -----------

                          ....
                                      1
                              q[1] + ----
                                     q[0]
    where q[i] >= 1
    and   q[0] >= 2

The terms are collected up as a sequence of integers each E<gt>=0 by
subtracting 1, or subtracting 2 from the lowest.

    q[k]-1,  q[k-1]-1, ..., q[2]-1, q[1]-1, q[0]-2

These integers are written in base2 using digits 1,2 and a digit 3 in
between each as a separator.

    base2(q[k]-1), 3, base2(q[k-1]-1), 3, ..., 3, base2(q[0]-2)

If a q[i]-1 etc term is 0 then its base2 form is empty and there's adjacent
3s in that case.  Or a bare high 3 or low 3 if the high q[k]-1 or low q[0]-2
are zero.  If there's just a single term q[0]-2 and it's 0 then the string
is completely empty.  That's so for X/Y=1/2 having q[0]=2.

This string of 1s,2s,3s is reckoned as a base3 value with digits 1,2,3 and
the result is N.  All strings of 1s,2s,3s occur and hence all integers
NE<gt>=0 correspond to some X/Y fraction.

Using digits 1,2 means writing an integer Q in the form

    Q = d[m]*2^m + d[m-1]*2^(m-1) + ... + d[2]*2^2 + d[1]*2 + d[0]
    where each d[i]=1 or 2

and similarly base3 with digits 1,2,3 as used for N,

    N = d[m]*3^m + d[m-1]*3^(m-1) + ... + d[2]*3^2 + d[1]*3 + d[0]
    where each d[i]=1, 2 or 3

This is not the same as the radix representation with digits 0 to R-1.  The
effect is to convert any 0 digits to instead 2 in base2, or 3 in base3, and
decrement the rest of the value above that position.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over

=item C<$path = Math::PlanePath::CfracFractions-E<gt>new ()>

Create and return a new path object.

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::FractionsTree>,
L<Math::PlanePath::CoprimeColumns>

L<Math::PlanePath::RationalsTree>,
L<Math::PlanePath::GcdRationals>,
L<Math::PlanePath::DiagonalRationals>

L<Math::ContinuedFraction>

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
