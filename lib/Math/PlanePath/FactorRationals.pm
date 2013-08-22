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


# Multiples of prime make grid.

# pn_type => 'even/odd'
# pn_type => 'odd_even'
# pn_type => 'negabinary'
# pn_type => 'neg_zeros'


# David M. Bradley http://arxiv.org/abs/math/0509025
# earlier inverse
# prime powers
#
# prime factors q1,..qk of n
# f(m/n) = m^2*n^2/ (q1q2...qk)

# Kevin McCrimmon, "Enumeration of the Positive Rationals", American Math
# Monthly, Nov 1960, page 868.  http://www.jstor.org/stable/2309448
#
# integer prod p[i]^a[i] -> rational prod p[i]^b[i]
# b[i] = a[2i-1] if a[2i-1]!=0
#    b[1]=a[1], b[2]=a[3], b[3]=a[5]
# b[i] = -a[2k] if a[2i-1]=0 and is kth such
#
#
# b[i] = f(a[i]) where f(n) = (-1)^(n+1) * floor((n+1)/2)
#   f(0) =  0
#   f(1) =  1
#   f(2) = -1
#   f(3) =  2
#   f(4) = -2

# Gerald Freilich, "A Denumerability Formula for the Rationals", American
# Math Monthly, Nov 1965, pages 1013-1014.
# http://www.jstor.org/stable/2313350
#
# f(n) = n/2      if n even n>=0
#      = -(n+1)/2 if n odd n>0
# f(0)=0/2      =  0
# f(1)=-(1+1)/2 = -1
# f(2)=2/2      =  1
# f(3)=-(3+1)/2 = -2
# f(4)=4/2      =  2

# Yoram Sagher, "Counting the rationals", American Math Monthly, Nov 1989,
# page 823.  http://www.jstor.org/stable/2324846
#
# m = p1^e1.p2^e2...
# n = q1^f1.q2^f2...
# f(m/n) = p1^2e1.p2^2e2... . q1^(2f1-1).q2^(2f2-1)...
# so     0 -> 0              0 ->  0
#    num 1 -> 2              1 -> -1
#        2 -> 4              2 ->  1
# den -1 1 -> 2*1-1 = 1      3 -> -2
#     -2 2 -> 2*2-1 = 3      4 ->  2

# Umberto Cerruti, "Ordinare i razionali Gli alberi di Keplero e di
# Calkin-Wilf"
#   B(2k)=-k   even=negative and zero
#   B(2k-1)=k  odd=positive
#   which is Y/X invert
# B(0 =2*0)   =  0
# B(1 =2*1-1) =  1
# B(2 =2*1)   = -1
# B(3 =2*2-1) =  2
# B(4 =2*2)   = -2


package Math::PlanePath::FactorRationals;
use 5.004;
use strict;
use Carp;
use List::Util 'min';
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 109;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'digit_join_lowtohigh';

use Math::PlanePath::CoprimeColumns;
*_coprime = \&Math::PlanePath::CoprimeColumns::_coprime;

# uncomment this to run the ### lines
# use Smart::Comments;


# Not yet.
# use constant parameter_info_array =>
#   [ { name      => 'sign_encoding',
#       display   => 'Sign Encoding',
#       type      => 'enum',
#       default   => 'even/odd',
#       choices         => ['even/odd','odd/even','negabinary','spread'],
#       choices_display => ['Even/Odd','Odd/Even','Negabinary','Spread'],
#     },
#   ];

use constant class_x_negative => 0;
use constant class_y_negative => 0;
use constant x_minimum => 1;
use constant y_minimum => 1;
use constant gcdxy_maximum => 1;  # no common factor
use constant absdy_minimum => 1;

# even/odd
#   dir_minimum_dxdy() suspect dir approaches 0.
#   Eg. N=5324   = 2^2.11^3     dx=3,dy=92   0.97925
#       N=642735 = 3^5.23^2     dX=45 dY=4    Dir4=0.05644  
#         642736 = 2^4.17^2.139
#   dir_maximum_dxdy() suspect approaches 360 degrees
#   use constant dir_maximum_dxdy => (0,0);  # the default
#
# negabinary
#   dir_minimum_dxdy() = East 1,0 at N=1
#   dir_maximum_dxdy() believe approaches 360 degrees
#   Eg. N=40=2^3.5 X=5, Y=2
#       N=41=41    X=41, Y=1
#   N=multiple 8 and solitary primes, followed by N+1=prime is dX=big, dY=-1 
#


# $n>=0, return a positive if even or negative if odd
#   $n==0  return  0
#   $n==1  return -1
#   $n==2  return +1
#   $n==3  return -2
#   $n==4  return +2
sub _pos_to_pn__even_odd {
  my ($n) = @_;
  return ($n % 2 ? -1-$n : $n) / 2;
}

# $n>=0, return a positive if even or negative if odd
#   $n==0  return  0
#   $n==1  return +1
#   $n==2  return -1
#   $n==3  return +2
#   $n==4  return -2
sub _pos_to_pn__odd_even {
  my ($n) = @_;
  return ($n % 2 ? $n+1 : -$n) / 2;
}

#----------

# $n is positive or negative, return even for positive or odd for negative.
#   $n==0   return 0
#   $n==-1  return 1
#   $n==+1  return 2
#   $n==-2  return 3
#   $n==+2  return 4
sub _pn_to_pos__even_odd {
  my ($n) = @_;
  return ($n >= 0 ? 2*$n : -1-2*$n);
}

# $n is positive or negative, return odd for positive or even for negative.
#   $n==0   return 0
#   $n==+1  return 1
#   $n==-1  return 2
#   $n==+2  return 3
#   $n==-2  return 4
sub _pn_to_pos__odd_even {
  my ($n) = @_;
  return ($n <= 0 ? -2*$n : 2*$n-1);
}

sub _pn_to_pos__negabinary {
  my ($n) = @_;
  my @bits;
  while ($n) {
    my $bit = ($n % 2);
    push @bits, $bit;
    $n -= $bit;
    $n /= 2;
    $n = -$n;
  }
  return digit_join_lowtohigh(\@bits, 2,
                              $n); # zero
}
sub _pos_to_pn__negabinary {
  my ($n) = @_;
  return (($n & 0x55555555) - ($n & 0xAAAAAAAA));
}

my %sign_encoding__pos_to_pn = ('even/odd' => \&_pos_to_pn__even_odd,
                                'odd/even' => \&_pos_to_pn__odd_even,
                                negabinary => \&_pos_to_pn__negabinary,
                                spread     => 1,
                               );

sub new {
  my $self = shift->SUPER::new(@_);

  my $sign_encoding = ($self->{'sign_encoding'} ||= 'even/odd');
  $sign_encoding__pos_to_pn{$sign_encoding}
    or croak "Unrecognised sign_encoding: ",$sign_encoding;

  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### FactorRationals n_to_xy(): "$n"

  if ($n < 1) { return; }
  if (is_infinite($n)) { return ($n,$n); }

  # what to do for fractional $n?
  {
    my $int = int($n);
    if ($n != $int) {
      ### frac ...
      my $frac = $n - $int;  # inherit possible BigFloat/BigRat
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int;
  }

  my $zero = $n * 0;

  if ($self->{'sign_encoding'} eq 'spread') {
    # N = 2^e1 * 3^e2 * 5^e3 * 7^e4 * 11^e5 * 13^e6 * 17^e7
    # X = 2^e1 * 3^e3 * 5^e5 * 7^e7,  Y = 1
    #
    # X = 2^e1        * 5^e5          e3=0,e7=0
    # Y =        3^e2        * 7^e4
    #
    # 22 = 1,0,0,0,1
    # num = 1,0,1 = 2*5 = 10
    # den = 0
    #
    my $nexps = _factors_split($n)
      or return;  # too big
    ### $nexps
    my @dens;
    my (@xexps, @yexps);
    while (@$nexps || @dens) {
      my $exp = shift @$nexps;
      if (@$nexps)  {
        push @dens, shift @$nexps;
      }

      if ($exp) {
        ### to num: $exp
        push @xexps, $exp;
        push @yexps, 0;
      } else {
        ### zero take den: $dens[0]
        push @xexps, 0;
        push @yexps, shift @dens;
      }
    }
    ### @xexps
    ### @yexps
    return (_factors_join(\@xexps,$zero),
            _factors_join(\@yexps,$zero));

  } else {
    my $pos_to_pn = $sign_encoding__pos_to_pn{$self->{'sign_encoding'}};
    my $x = my $y = ($n * 0) + 1;  # inherit bignum 1
    my ($limit,$overflow) = _limit($n);
    ### $limit
    my $divisor = 2;
    my $dstep = 1;
    while ($divisor <= $limit) {
      if (($n % $divisor) == 0) {
        my $count = 0;
        for (;;) {
          $count++;
          $n /= $divisor;
          if ($n % $divisor) {
            my $pn = &$pos_to_pn($count);
            ### $count
            ### $pn
            my $pow = ($divisor+$zero) ** abs($pn);
            if ($pn >= 0) {
              $x *= $pow;
            } else {
              $y *= $pow;
            }
            last;
          }
        }
        ($limit,$overflow) = _limit($n);
        ### $limit
      }
      $divisor += $dstep;
      $dstep = 2;
    }
    if ($overflow) {
      ### n too big ...
      return;
    }

    ### remaining $n is prime, count=1: "n=$n"
    my $pn = &$pos_to_pn(1);
    ### $pn
    my $pow = $n ** abs($pn);
    if ($pn >= 0) {
      $x *= $pow;
    } else {
      $y *= $pow;
    }

    ### result: "$x, $y"
    return ($x, $y);
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;

  $x = round_nearest ($x);
  $y = round_nearest ($y);
  ### FactorRationals xy_to_n(): "x=$x y=$y"

  if ($x < 1 || $y < 1) {
    return undef;  # negatives and -infinity
  }
  if (is_infinite($x)) { return $x; } # +infinity or nan
  if (is_infinite($y)) { return $y; } # +infinity or nan

  if ($self->{'sign_encoding'} eq 'spread') {
    # N = 2^e1 * 3^e2 * 5^e3 * 7^e4 * 11^e5 * 13^e6 * 17^e7
    # X = 2^e1 * 3^e3 * 5^e5 * 7^e7,  Y = 1
    #
    # X = 2^e1        * 5^e5          e3=0,e7=0
    # Y =        3^e2        * 7^e4
    #
    # X=1,0,1
    # Y=0,0,0
    # 22 = 1,0,0,0,1
    # num = 1,0,1 = 2*5 = 10
    #
    my $xexps = _factors_split($x)
      or return undef;  # overflow
    my $yexps = _factors_split($y)
      or return undef;  # overflow
    ### $xexps
    ### $yexps

    my @nexps;
    my $denpos = -1; # to store first at $nexps[1]
    while (@$xexps || @$yexps) {
      my $xexp = shift @$xexps || 0;
      my $yexp = shift @$yexps || 0;
      ### @nexps
      ### $xexp
      ### $yexp
      push @nexps, $xexp, 0;
      if ($xexp) {
        if ($yexp) {
          ### X,Y common factor ...
          return undef;
        }
      } else {
        ### den store to: "denpos=".($denpos+2)."  yexp=$yexp"
        $nexps[$denpos+=2] = $yexp;
      }
    }
    ### @nexps
    return (_factors_join(\@nexps, $x*0*$y));

  } elsif ($self->{'sign_encoding'} eq 'negabinary') {
    ### negabinary ...
    my $n = 1;
    my $zero = $x * 0 * $y;

    # Factorize both $x and $y and apply their negabinary encoded powers to
    # make $n.  A common factor between $x and $y is noticed if $divisor
    # divides both.

    my ($limit,$overflow) = _limit(max($x,$y));
    my $dstep = 1;
    for (my $divisor = 2; $divisor <= $limit; $divisor += $dstep, $dstep=2) {
      my $count = 0;
      if ($x % $divisor == 0) {
        if ($y % $divisor == 0) {
          return undef;  # common factor
        }
        while ($x % $divisor == 0) {
          $count++;
          $x /= $divisor;  # mutate loop variable
        }
      } elsif ($y % $divisor == 0) {
        while ($y % $divisor == 0) {
          $count--;
          $y /= $divisor;  # mutate loop variable
        }
      } else {
        next;
      }

      # Here $count > 0 if from $x or $count < 0 if from $y.
      ### $count
      ### negabinary: _pn_to_negabinary($count)

      $count = _pn_to_pos__negabinary($count);
      $n *= ($divisor+$zero) ** $count;

      # new search limit, perhaps smaller than before
      ($limit,$overflow) = _limit(max($x,$y));
    }

    if ($overflow) {
      ### x,y too big to find all primes ...
      return undef;
    }

    # Here $x and $y are primes.
    if ($x > 1 && $x == $y) {
      ### common factor final remaining prime x,y ...
      return undef;
    }

    # $x is power p^1 which is negabinary=1 so multiply into $n.  $y is
    # power p^-1 and -1 is negabinary=3 so cube and multiply into $n.
    $n *= $x;
    $n *= $y*$y*$y;

    return $n;

  } else {
    ### assert: $self->{'sign_encoding'} eq 'even/odd' || $self->{'sign_encoding'} eq 'odd/even'
    if ($self->{'sign_encoding'} eq 'odd/even') {
      ($x,$y) = ($y,$x);
    }

    # Factorize $y so as to make an odd power of its primes.  Only need to
    # divide out one copy of each prime, but by dividing out them all the
    # $limit to search up to is reduced, usually by a lot.
    #
    # $ymult is $y with one copy of each prime factor divided out.
    # $ychop is $y with all primes divided out as they're found.
    # $y itself is unchanged.
    #
    my $ychop = my $ymult = $y;

    my ($limit,$overflow) = _limit($ychop);
    my $dstep = 1;
    for (my $divisor = 2; $divisor <= $limit; $divisor += $dstep, $dstep=2) {
      next if $ychop % $divisor;

      if ($x % $divisor == 0) {
        ### common factor with X ...
        return undef;
      }
      $ymult /= $divisor;           # one of $divisor divided out
      do {
        $ychop /= $divisor;         # all of $divisor divided out
      } until ($ychop % $divisor);
      ($limit,$overflow) = _limit($ychop);  # new lower $limit, perhaps
    }

    if ($overflow) {
      return undef; # Y too big to find all primes
    }

    # remaining $ychop is a prime, or $ychop==1
    if ($ychop > 1) {
      if ($x % $ychop == 0) {
        ### common factor with X ...
        return undef;
      }
      $ymult /= $ychop;
    }

    return $x*$x * $y*$ymult;
  }
}

#------------------------------------------------------------------------------

# all rationals X,Y >= 1 no common factor
use Math::PlanePath::DiagonalRationals;
*xy_is_visited = Math::PlanePath::DiagonalRationals->can('xy_is_visited');

#------------------------------------------------------------------------------

# _limit() returns ($limit,$overflow).
#
# $limit is the biggest divisor to attempt trial division of $n.  If $n <
# 2^32 then $limit=sqrt($n) and that will find all primes.  If $n is bigger
# than $limit is smaller, based on the length of $n so as to make a roughly
# constant amount of time doing divisions.  But $limit is always at least 50
# so as to divide by primes up to 50.
#
# $overflow is a boolean, true if $n is too big to search for all primes and
# $limit is something smaller than sqrt($n).  $overflow is false if $limit
# has not been capped and is enough to find all primes.
#
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


my @primes = (2,3,5,7);
sub _extend_primes {
  for (my $p = $primes[-1] + 2; ; $p += 2) {
    if (_is_prime($p)) {
      push @primes, $p;
      return;
    }
  }
}
sub _is_prime {
  my ($n) = @_;
  my $limit = int(sqrt($n));
  for (my $i = 0; ; $i++) {
    if ($i > $#primes) { _extend_primes(); }
    my $prime = $primes[$i];
    if ($n % $prime == 0) { return 0; }
    if ($prime > $limit) { return 1; }
  }
}
   
# $aref is an arrayref of prime exponents, [a,b,c,...]      
# Return their product 2**a * 3**b * 5**c * ...
#
sub _factors_join {
  my ($aref, $zero) = @_;
  ### _factors_join(): $aref
  my $n = $zero + 1;
  for (my $i = 0; $i <= $#$aref; $i++) {
    if ($i > $#primes) { _extend_primes(); }
    $n *= ($primes[$i] + $zero) ** $aref->[$i];
  }
  ### join: $n
  return $n;
}

# Return an arrayref of prime exponents of $n.
# Eg. [a,b,c,...] for $n == 2**a * 3**b * 5**c * ...
sub _factors_split {
  my ($n) = @_;
  ### _factors_split(): $n
  my @ret;
  for (my $i = 0; $n > 1; $i++) {
    if ($i > 6541) {
      ### stop, primes too big ...
      return;
    }
    if ($i > $#primes) { _extend_primes(); }

    my $count = 0;
    while ($n % $primes[$i] == 0) {
      $n /= $primes[$i];
      $count++;
    }
    push @ret, $count;
  }
  return \@ret;
}

# ### f: 2*3*3*5*19
# ### f: _factors_split(2*3*3*5*19)
# ### f: _factors_join(_factors_split(2*3*3*5*19),0)


#------------------------------------------------------------------------------

# even/odd
#   X=2^10 -> N=2^20 is X*X
#   Y=3 -> N=3
#   Y=3^2 -> N=3^3
#   Y=3^3 -> N=3^5
#   Y=3^4 -> N=3^7
#   Y*Y / distinct prime factors
#
# negabinary
#   X=prime^2 -> N=prime^6       is X^3
#   X=prime^6 -> N=prime^26      is X^4.33
#   maximum 101010...10110 -> 1101010...10 approaches factor 5
#   same for negatives

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

  my $n = $x2 * $y2;
  my $n_squared = $n * $n;
  return (1,
          ($self->{'sign_encoding'} eq 'even/odd'
           ? $n_squared                      # X^2*Y^2
           : $n_squared*$n_squared * $n));   # X^5*Y^5

}


1;
__END__

=for stopwords eg Ryde OEIS ie Math-PlanePath Calkin-Wilf McCrimmon Freilich Yoram Sagher negabinary

=head1 NAME

Math::PlanePath::FactorRationals -- rationals by prime powers

=head1 SYNOPSIS

 use Math::PlanePath::FactorRationals;
 my $path = Math::PlanePath::FactorRationals->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

X<McCrimmon, Kevin>X<Freilich, Gerald>X<Sagher, Yoram>This path enumerates
rationals X/Y with no common factor, based on the prime powers in numerator
and denominator.  This is per Kevin McCrimmon, and independently Gerald
Freilich, and also Yoram Sagher.

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

A given fraction X/Y with no common factor has a prime factorization

    X/Y = p1^e1 * p2^e2 * ...

The exponents e[i] are either positive or negative, being positive when the
prime is in the numerator or negative when in the denominator.  Those
exponents are represented in an integer N by

    N = p1^f(e1) * p2^f(e2) * ...

    f(e) = 2*e      if e >= 0
         = 1-2*e    if e < 0

    f(e)      e
    ---      --- 
     0        0
     1       -1  
     2        1  
     3       -2  
     4        2  

 For example

    X/Y = 125/7 = 5^3 * 7^(-1)
    encoded as N = 5^(2*3) * 7^(1-2*(-1)) = 5^6 * 7^1 = 5359375

    N=3   ->  3^-1 = 1/3
    N=9   ->  3^1  = 3/1
    N=27  ->  3^-2 = 1/9
    N=81  ->  3^2  = 9/1

The effect is to distinguish prime factors of the numerator or denominator
by odd or even exponents of those primes in N.  Since X and Y have no common
factor a given prime appears in one and not the other.  The oddness or
evenness of the p^f exponent in N can then encode which of the two X or Y it
came from.

The exponent f(e) in N has 2*e in both cases, with those from Y reduced
by 1.  This can be expressed in the following form, which shows how going
from X,Y to N doesn't need to factorize X, only Y.

             X^2 * Y^2
    N = --------------------
        distinct primes in Y

The exponents mapped positiveE<lt>-E<gt>even and negativeE<lt>->odd is the
form given by Freilich and Sagher.  McCrimmon has them the opposite, as
positiveE<lt>-E<gt>odd negativeE<lt>->even.  The only difference in the two
is to swap Y/X.

=head2 Various Values

N=1,2,3,8,5,6,etc in the column X=1 is integers with odd powers of prime
factors.  These are the fractions 1/Y so the exponents of the primes are all
negative and thus all exponents in N are odd.

X<Square numbers>N=1,4,9,16,etc in row Y=1 are the perfect squares.  That
row is the integers X/1 so the s exponents there are all positive and thus
in N become 2*s, giving simply N=X^2.

X<Bradley, David M.>As noted by David M. Bradley, other mappings of signed
E<lt>-E<gt> unsigned powers could give other enumerations.  The "negabinary"
a[k]*(-2)^k is one possibility, or the "reversing binary representation"
(-1)^k*2^ek of Knuth vol 2 section 4.1 exercise 27.  But the alternating "+"
and "-" here keeps the growth of N down to roughly X^2*Y^2, per the
N=X^2*Y^2/Yprimes formula above.

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
disappearing into a nearly-infinite loop.  Perhaps the limits could be
configurable and/or some advanced factoring modules attempted for a while
if/when available.

=head1 OEIS

This enumeration of the rationals is in Sloane's Online Encyclopedia of
Integer Sequences in the following forms

    http://oeis.org/A071974   (etc)

    A071974   X coordinate, numerators
    A071975   Y coordinate, denominators
    A019554   X*Y product
    A102631   N in column X=1, n^2/squarefreekernel(n)
    A072345   X and Y at N=2^k, being alternately 1 and 2^k

    A011262   permutation N at transpose Y/X (exponents mangle odd<->even)

    A060837   permutation DiagonalRationals -> FactorRationals
    A071970   permutation RationalsTree CW -> FactorRationals

The last A071970 is rationals taken in order of the Stern diatomic sequence
stern[i]/stern[i+1], which is also the order of the Calkin-Wilf tree rows
(L<Math::PlanePath::RationalsTree/Calkin-Wilf Tree>).

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::GcdRationals>,
L<Math::PlanePath::RationalsTree>,
L<Math::PlanePath::CoprimeColumns>

Kevin McCrimmon, "Enumeration of the Positive Rationals", American Math
Monthly, Nov 1960, page 868.  http://www.jstor.org/stable/2309448

Gerald Freilich, "A Denumerability Formula for the Rationals", American Math
Monthly, Nov 1965, pages 1013-1014.  http://www.jstor.org/stable/2313350

Yoram Sagher, "Counting the rationals", American Math Monthly, Nov 1989,
page 823.  http://www.jstor.org/stable/2324846

David M. Bradley, "Counting the Positive Rationals: A Brief Survey",
http://arxiv.org/abs/math/0509025

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011, 2012, 2013 Kevin Ryde

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
