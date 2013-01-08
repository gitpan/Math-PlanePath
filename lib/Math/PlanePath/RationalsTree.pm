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


# cf A054429 permutation reverse within binary row
#    A065249 - permutation SB X -> X/2
#    A065250 - permutation SB X -> 2X
#    A057114 - permutation SB X -> X+1
#    A057115 - permutation SB X -> X-1
#
# Math::NumSeq::PlanePathTurn
# A010059 start=0: 1,0,0,1,0,1,1,0,0,1,1,0,1,0,0,1,0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0,0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0,1,0,0,1,0,1,1,0,0,1,1,0,1,0,0,1,0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0,1,0,0,1,0,1,1,0,0,1,1,0,1,0,0,1,1,0,0,1,0
#   match 1,0,1,1,0,0,1,1,0,1,0,0,1,0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0,0,1,1,0,1,0,0,1,1,0,0,1,0
#   PlanePathTurn planepath=RationalsTree,tree_type=HCS,  turn_type=Left
#
# A010060 start=0: 0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0,1,0,0,1,0,1,1,0,0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0,0,1,1,0,1,0,0,1,0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0,1,0,0,1,0,1,1,0,0,1,1,0,1,0,0,1,0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0,0,1,1,0,1
#   match 0,1,0,0,1,1,0,0,1,0,1,1,0,1,0,0,1,0,1,1,0,0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0,0,1,1,0,1
#   PlanePathTurn planepath=RationalsTree,tree_type=HCS,  turn_type=Right


# math-image --path=RationalsTree --all --scale=3
# math-image --path=RationalsTree --all --output=numbers_xy --size=60x40
#
#                    high-to-low   low-to-high
# (X+Y)/Y  Y/(X+Y)     not-impl       AYT
# X/(X+Y)  (X+Y)/Y      CW            SB    \ alt bit flips
# Y/(X+Y)  (X+Y)/X     Drib          Bird   /
#
#     9  10                    12  10
# 8      11                 8      14
#        12  13                     9  13
#            14                        11
#            15                        15
#
# Stern-Brocot              Calkin-Wilf


package Math::PlanePath::RationalsTree;
use 5.004;
use strict;
use Carp;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 96;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'round_down_pow',
  'bit_split_lowtohigh',
  'digit_join_lowtohigh';
*_divrem = \&Math::PlanePath::_divrem;

use Math::PlanePath::CoprimeColumns;
*_coprime = \&Math::PlanePath::CoprimeColumns::_coprime;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant class_x_negative => 0;
use constant class_y_negative => 0;
use constant tree_any_leaf => 0;  # no leaves, complete tree

use constant parameter_info_array =>
  [ { name            => 'tree_type',
      share_key       => 'tree_type_rationalstree',
      display         => 'Tree Type',
      type            => 'enum',
      default         => 'SB',
      choices         => ['SB','CW','AYT','HCS','Bird','Drib','L',],
      choices_display => ['SB','CW','AYT','HCS','Bird','Drib','L',],
    },
  ];

sub x_minimum {
  my ($self) = @_;
  return ($self->{'tree_type'} eq 'L' ? 0 : 1);
}
use constant y_minimum => 1;

#------------------------------------------------------------------------------

my %attributes = (CW   => [ n_start => 1, ],
                  SB   => [ n_start => 1, reverse_bits => 1 ],
                  Drib => [ n_start => 1, alternating => 1 ],
                  Bird => [ n_start => 1, alternating => 1, reverse_bits => 1 ],
                  AYT  => [ n_start => 1, sep1s => 1 ],
                  HCS   => [ n_start => 1, sep1s => 1, reverse_bits => 1 ],
                  L    => [ n_start => 0 ],
                 );

sub new {
  my $class = shift;
  my $self = $class->SUPER::new (@_);
  my $tree_type = ($self->{'tree_type'} ||= 'SB');
  my $attributes = $attributes{$tree_type}
    || croak "Unrecognised tree type: ",$tree_type;
  %$self = (%$self, @$attributes);
  ### $self
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### RationalsTree n_to_xy(): "$n"

  if ($n < $self->{'n_start'}) { return; }
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

  my $zero = ($n * 0);  # inherit bignum 0
  my $one = $zero + 1;  # inherit bignum 1

  if ($self->{'n_start'} == 0) {
    # L tree adjust;
    $n += 2;
  }

  my @nbits = bit_split_lowtohigh($n);
  pop @nbits;
  ### lowtohigh sans high: @nbits

  if (! $self->{'reverse_bits'}) {
    @nbits = reverse @nbits;
    ### reverse to: @nbits
  }

  my $x = $one;
  my $y = $one;

  if ($self->{'sep1s'}) {
    foreach my $nbit (@nbits) {
      $x += $y;
      if ($nbit) {
        ($x,$y) = ($y,$x);
      }
    }

  } elsif ($self->{'alternating'}) {
    foreach my $nbit (@nbits) {
      ($x,$y) = ($y,$x);
      if ($nbit) {
        $x += $y;     # (x,y) -> (x+y,x), including swap
      } else {
        $y += $x;     # (x,y) -> (y,x+y), including swap
      }
    }

  } elsif ($self->{'tree_type'} eq 'L') {
    my $sub = 2;
    foreach my $nbit (@nbits) {
      if ($nbit) {
        $y += $x;     # (x,y) -> (x,x+y)
        $sub = 0;
      } else {
        $x += $y;     # (x,y) -> (x+y,y)
      }
    }
    $x -= $sub;   # -2 at N=00...000 all zero bits

  } else {
    ### nbits apply CW: @nbits
    foreach my $nbit (@nbits) {   # high to low
      if ($nbit) {
        $x += $y;     # (x,y) -> (x+y,y)
      } else {
        $y += $x;     # (x,y) -> (x,x+y)
      }
    }
  }
  ### result: "$x, $y"
  return ($x,$y);
}

sub xy_is_visited {
  my ($self, $x, $y) = @_;
  $x = round_nearest ($x);
  $y = round_nearest ($y);
  if ($self->{'tree_type'} eq 'L' && $x == 0 && $y == 1) {
    return 1;
  }
  if ($x < 1
      || $y < 1
      || ! _coprime($x,$y)) {
    return 0;
  }
  return 1;
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = round_nearest ($x);
  $y = round_nearest ($y);
  ### RationalsTree xy_to_n(): "$x,$y   $self->{'tree_type'}"

  if ($x < $self->{'n_start'} || $y < 1) {
    return undef;
  }
  if (is_infinite($x)) {
    return $x;
  }
  if (is_infinite($y)) {
    return $y;
  }

  my @quotients = _xy_to_quotients($x,$y)
    or return undef;  # $x,$y have a common factor
  ### @quotients

  my @nbits;
  if ($self->{'sep1s'}) {
    $quotients[0]++;  # the integer part, making it 1 or more
    foreach my $q (@quotients) {
      push @nbits, (0) x ($q-1), 1;   # runs of "000..0001"
    }
    pop @nbits;  # no high 1-bit separator

  } else {
    if ($quotients[0] < 0) {   # X=0,Y=1 in tree_type="L"
      return $self->{'n_start'};
    }

    my $bit = 1;
    foreach my $q (@quotients) {
      push @nbits, ($bit) x $q;
      $bit ^= 1;     # alternate runs of "00000" or "11111"
    }
    ### nbits in quotient order: @nbits

    if ($self->{'alternating'}) {
      # Flip every second bit, starting from the second lowest.
      for (my $i = 1; $i <= $#nbits; $i += 2) {
        $nbits[$i] ^= 1;
      }
    }

    if ($self->{'tree_type'} eq 'L') {
      # Flip all bits.
      my $anyones = 0;
      foreach my $nbit (@nbits) {
        $nbit ^= 1;   # mutate array
        $anyones ||= $nbit;
      }
      unless ($anyones) {
        push @nbits, 0,0;
      }
    }
  }

  if ($self->{'reverse_bits'}) {
    @nbits = reverse @nbits;
  }
  push @nbits, 1;   # high 1-bit

  ### @nbits
  my $n = digit_join_lowtohigh (\@nbits, 2,
                                $x*0*$y);   # inherit bignum 0
  if ($self->{'tree_type'} eq 'L') {
    return $n-2;
  } else {
    return $n;
  }
}

# Return a list of the quotients from Euclid's greatest common divisor
# algorithm on X,Y.  This is also the terms of the continued fraction
# expansion of rational X/Y.
#
# The last term, the one at the end of the list, is decremented since this
# is what the code above requires.  This term is the top-most quotient in
# for example gcd(7,1) is 7=7*1+0 with q=7 returned as 6.
#
# If $x,$y have a common factor then the return is an empty list.  If
# there's no common factor then returned list is always one or more
# quotients.
#
sub _xy_to_quotients {
  my ($x,$y) = @_;
  my @ret;
  for (;;) {
    my ($q, $r) = _divrem($x,$y);
    push @ret, $q;
    last unless $r;
    $x = $y;
    $y = $r;
  }

  if ($y > 1) {
    ### found Y>1 common factor, no N at this X,Y ...
    return;
  }
  $ret[-1]--;
  return @ret;
}


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

  if ($x2 < 1 || $y2 < 1) {
    ### no values, rect below first quadrant
    if ($self->{'n_start'}) {
      return (1,0);
    } else {
      return (0,0);
    }
  }

  my $zero = ($x1 * 0 * $y1 * $x2 * $y2);  # inherit bignum
  ### $zero

  if ($x1 < 1) { $x1 = 1; }
  if ($y1 < 1) { $y1 = 1; }

  # # big x2, small y1
  # # big y2, small x1
  # my $level = _bingcd_max ($y2,$x1);
  # ### $level
  # {
  #   my $l2 = _bingcd_max ($x2,$y1);
  #   ### $l2
  #   if ($l2 > $level) { $level = $l2; }
  # }

  my $level = max($x1,$x2,$y1,$y2);

  return ($self->{'n_start'},
          $self->{'n_start'} + (2+$zero) ** ($level + 3));
}

sub _bingcd_max {
  my ($x,$y) = @_;
  ### _bingcd_max(): "$x,$y"

  if ($x < $y) { ($x,$y) = ($y,$x) }

  ### div: int($x/$y)
  ### bingcd: int($x/$y) + $y

  return int($x/$y) + $y + 1;
}

#   ### fib: _fib_log($y)
# # ENHANCE-ME: log base PHI, or something close for BigInt
# # 2*log2() means log base sqrt(2)=1.4 instead of PHI=1.6
# #
# # use constant 1.02; # for leading underscore
# # use constant _PHI => (1 + sqrt(5)) / 2;
# #
# sub _fib_log {
#   my ($x) = @_;
#   ### _fib_log(): $x
#   my $f0 = ($x * 0);
#   my $f1 = $f0 + 1;
#   my $count = 0;
#   while ($x > $f0) {
#     $count++;
#     ($f0,$f1) = ($f1,$f0+$f1);
#   }
#   return $count;
# }

# N=1 basis children 2N,2N+1
# N=S basis 2(N-(S-1))+(S-1)
#           = 2N - 2(S-1) + (S-1)
#           = 2N - (S-1)
sub tree_n_children {
  my ($self, $n) = @_;
  unless ($n >= $self->{'n_start'}) {
    return;
  }
  $n *= 2;
  $n -= $self->{'n_start'} - 1;
  return ($n, $n+1);
}
sub tree_n_num_children {
  my ($self, $n) = @_;
  return ($n >= $self->{'n_start'} ? 2 : undef);
}
sub tree_n_parent {
  my ($self, $n) = @_;
  unless (($n -= $self->{'n_start'}) > 0) {
    return undef;
  }
  return int(($n-1)/2) + $self->{'n_start'};
}
sub tree_n_to_depth {
  my ($self, $n) = @_;
  ### RationalsTree tree_n_to_depth(): $n
  $n = $n - $self->{'n_start'};
  unless ($n >= 0) {
    return undef;
  }
  my ($pow, $exp) = round_down_pow ($n+1, 2);
  return $exp;
}
sub tree_depth_to_n {
  my ($self, $depth) = @_;
  return ($depth >= 0 ? 2**$depth + $self->{'n_start'}-1 : undef);
}
# (2^(d+1)+s-1)-1 = 2^(d+1)+s-2
sub tree_depth_to_n_end {
  my ($self, $depth) = @_;
  return ($depth >= 0 ? 2**($depth+1) + $self->{'n_start'}-2 : undef);
}

1;
__END__


  # xy_to_n() post-processing CW to make AYT
  #
  # if ($self->{'tree_type'} eq 'AYT') {
  #   # AYT shift-xor "N xor (N<<1)" each bit xor with the one below it.  But
  #   # the high 1-bit is left unchanged, hence "$#nbits-1".  At the low end
  #   # for "N<<1" a 1-bit is shifted in, which is arranged by letting $i-1
  #   # become -1 to get the endmost array element which is the high 1-bit.
  #   foreach my $i (reverse 0 .. $#nbits-1) {
  #     $nbits[$i] ^= $nbits[$i-1];
  #   }
  # }


=for stopwords eg Ryde OEIS ie Math-PlanePath coprime encodings PlanePath Moritz Achille Brocot Stern-Brocot mediant Calkin Wilf Calkin-Wilf 1abcde 1edcba Andreev Yu-Ting Shen AYT Ralf Hinze Haskell subtrees xoring Drib RationalsTree unflipped FractionsTree GCD Luschny Jerzy Czyz Minkowski Nstart Shallit's HCS Ndepth Nparent

=head1 NAME

Math::PlanePath::RationalsTree -- rationals by tree

=head1 SYNOPSIS

 use Math::PlanePath::RationalsTree;
 my $path = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path enumerates rational fractions X/Y in reduced form, ie. X and Y
having no common factor.

The rationals are traversed by rows of a binary tree which effectively
represents a coprime pair X,Y by steps of a subtraction-only greatest common
divisor algorithm proving them coprime.  Or equivalently by bit runs with
lengths which are the quotients in the Euclidean GCD algorithm, which are
also the terms in the continued fraction representation of X/Y.

The SB, CW, Bird, Drib and AYT trees all have the same set of X/Y fractions
in a row, but in a different order due to different encodings of the N
value, high to low or low to high and possible bit flips.  The L tree has a
shift which visits zero as 0/1 too.

The bit runs mean that N values are quite large for relatively modest sized
rationals.  For example 167/3 is N=288230376151711741, a 58-bit number.  The
tendency is for the tree to travel out to large rationals while yet to fill
in small ones.  The worst is the integer X/1 has N with X many bits, and
similarly 1/Y has Y bits.

See F<examples/rationals-tree.pl> in the PlanePath sources for a printout of
all the trees.

=head2 Stern-Brocot Tree

X<Stern, Moritz>X<Brocot, Achille>The default C<tree_type=E<gt>"SB"> is the
tree of Moritz Stern and Achille Brocot.  The rows are fractions of
increasing value.

    N=1                             1/1
                              ------   ------
    N=2 to N=3             1/2               2/1
                          /    \            /   \
    N=4 to N=7         1/3      2/3      3/2      3/1
                       | |      | |      | |      | |
    N=8 to N=15     1/4  2/5  3/5 3/4  4/3 5/3  5/2 4/1

Writing the parents between the children as an "in-order" tree traversal to
a given depth has all values in increasing order too,

                 1/1
         1/2      |      2/1
     1/3  |  2/3  |  3/2  |  3/1
      |   |   |   |   |   |   |

     1/3 1/2 2/3 1/1 3/2 2/1 3/1
                    ^
                    |
                    4/3 next level = (1+3)/(1+2)

New values are a "mediant" (x1+x2)/(y1+y2) formed from the left and right
parent in this flattening.  So the next level 4/3 is left parent 1/1 and
right parent 3/2 forming mediant (1+3)/(1+2)=4/3.  At the left end is
imagined a preceding 0/1 and at the right a following 1/0, so as to add
1/level and level/1 at the ends for a total 2^level many new values.

Plotting the N values by X,Y is as follows.  The unused X,Y positions are
where X and Y have a common factor.  For example X=6,Y=2 has common factor 2
so is never reached.

    10  |    512        35                  44       767
     9  |    256   33        39   40        46  383       768
     8  |    128        18        21       191       384
     7  |     64   17   19   20   22   95       192   49   51
     6  |     32                  47        96
     5  |     16    9   10   23        48   25   26   55
     4  |      8        11        24        27        56
     3  |      4    5        12   13        28   29        60
     2  |      2         6        14        30        62
     1  |      1    3    7   15   31   63  127  255  511 1023
    Y=0 |
         ----------------------------------------------------
         X=0   1    2    3    4    5    6    7    8    9   10

The X=1 vertical is the fractions 1/Y which is at the left of each tree row,
at N value

    Nstart = 2^level

The Y=1 horizontal is the X/1 integers at the end each row which is

    Nend = 2^(level+1)-1

=head2 Calkin-Wilf Tree

X<Calkin, Neil>X<Wilf, Herbert>C<tree_type=E<gt>"CW"> selects the tree of
Neil Calkin and Herbert Wilf,

=over

"Recounting the Rationals",
http://www.math.upenn.edu/~wilf/website/recounting.pdf

=back

As noted above, the values within each row are the same as the Stern-Brocot,
but in a different order.

    N=1                             1/1
                              ------   ------
    N=2 to N=3             1/2               2/1
                          /    \            /    \
    N=4 to N=7         1/3      3/2      2/3      3/1
                       | |      | |      | |      | |
    N=8 to N=15     1/4  4/3  3/5 5/2  2/5 5/3  3/4 4/1

Going across by rows the denominator of one value becomes the numerator of
the next.  So at 4/3 the denominator 3 becomes the numerator of the 3/5 to
the right.  These values are Stern's diatomic sequence.

Each row is symmetric in reciprocals, ie. reading from right to left is the
reciprocals of reading left to right.  The numerators read left to right are
the denominators read right to left.

A node descends as

          X/Y
        /     \
    X/(X+Y)  (X+Y)/Y

Taking these formulas in reverse up the tree shows how it relates to a
subtraction-only greatest common divisor.  At a given node the smaller of P
or Q is subtracted from the bigger,

       P/(Q-P)         (P-Q)/P
      /          or        \
    P/Q                    P/Q

Plotting the N values by X,Y is as follows.  The X=1 vertical and Y=1
horizontal are the same as the SB above, but the values in between are
re-ordered.

    tree_type => "CW"

    10  |      512        56                  38      1022
     9  |      256   48        60   34        46  510       513
     8  |      128        20        26       254       257
     7  |       64   24   28   18   22  126       129   49   57
     6  |       32                  62        65
     5  |       16   12   10   30        33   25   21   61
     4  |        8        14        17        29        35
     3  |        4    6         9   13        19   27        39
     2  |        2         5        11        23        47
     1  |        1    3    7   15   31   63  127  255  511 1023
    Y=0 |
         -------------------------------------------------------------
           X=0   1    2    3    4    5    6    7    8    9   10

In each node left leg is X/(X+Y) E<lt> 1 and the right leg is (X+Y)/Y E<gt>
1, which means even N is above the X=Y diagonal and odd N is below.

N values for the SB and CW trees are converted by reversing bits.  At a
given X,Y position if N = binary "1abcde" in the SB tree then at that same
X,Y in the CW has N = binary "1edcba".  For example at X=3,Y=4 the SB tree
has N=11=0b1011 and the CW has N=14=0b1110, a reversal of the bits below the
high 1.

N to X/Y in the CW tree can be calculated keeping track of just an X,Y pair
and descending to X/(X+Y) or (X+Y)/Y using the bits of N from high to low.
The relationship between the SB and CW N's means the same can be used to
calculate the SB tree by taking the bits of N from low to high instead.

=head2 Andreev and Yu-Ting Tree

X<Andreev, D.N.>X<Yu-Ting, Shen>C<tree_type=E<gt>"AYT"> selects the tree
described (independently is it?) by D. N. Andreev and Shen Yu-Ting.

=over

http://files.school-collection.edu.ru/dlrstore/d62f7b96-a780-11dc-945c-d34917fee0be/i2126134.pdf

Shen Yu-Ting, "A Natural Enumeration of Non-Negative Rational Numbers
-- An Informal Discussion", American Mathematical Monthly, 87, 1980,
pages 25-29.
http://www.jstor.org/stable/2320374

=back

Their constructions are a one-to-one mapping between integer N and
rational X/Y as a way of enumerating the rationals.  It's not designed
to be a tree as such, but the result is the same sort of 2^level rows
as the above trees.  The X/Y values within each row are again the
same, but in a further different order.

    N=1                             1/1
                              ------   ------
    N=2 to N=3             2/1               1/2
                          /    \            /    \
    N=4 to N=7         3/1      1/3      3/2      2/3
                       | |      | |      | |      | |
    N=8 to N=15     4/1  1/4  4/3 3/4  5/2 2/5  5/3 3/5

Each fraction descends as follows.  The left is an increment and the right
is the reciprocal of the increment.

            X/Y
          /     \
    X/Y + 1     1/(X/Y + 1)

which means

          X/Y
        /     \
    (X+Y)/Y  Y/(X+Y)

The left leg (X+Y)/Y is the same as in the CW has on the right.  But Y/(X+Y)
is not the same as the CW (the other there being X/(X+Y)).

X<Fibonacci Numbers>The Y/(X+Y) right leg forms the Fibonacci numbers
F(k)/F(k+1) at the end of each row, ie. at Nend=2^(level+1)-1.  And as noted
by Andreev, successive right leg fractions N=4k+1 and N=4k+3 add up to 1,
ie.

    X/Y at N=4k+1  +  X/Y at N=4k+3  =  1
    Eg. 2/5 at N=13 and 3/5 at N=15 add up to 1

Plotting the N values by X,Y gives

=cut

# math-image --path=RationalsTree,tree_type=AYT --all --output=numbers_xy --size=70x11

=pod

    tree_type => "AYT"

    10  |     513        41                  43       515
     9  |     257   49        37   39        51  259       514
     8  |     129        29        31       131       258
     7  |      65   25   21   23   27   67       130   50   42
     6  |      33                  35        66
     5  |      17   13   15   19        34   26   30   38
     4  |       9        11        18        22        36
     3  |       5    7        10   14        20   28        40
     2  |       3         6        12        24        48
     1  |       1    2    4    8   16   32   64  128  256  512
    Y=0 |
         ----------------------------------------------------
          X=0   1    2    3    4    5    6    7    8    9   10

N=1,2,4,8,etc on the Y=1 horizontal is the X/1 integers at
Nstart=2^level=2^X.  N=1,3,5,9,etc in the X=1 vertical is the 1/Y
fractions.  Those fractions always immediately follow the
corresponding integer, so N=Nstart+1=2^(Y-1)+1 in that column.

In each node the left leg (X+Y)/Y E<gt> 1 and the right leg Y/(X+Y) E<lt> 1,
which means odd N is above the X=Y diagonal and even N is below.

X<Kepler, Johannes>The tree structure corresponds to Johannes Kepler's
tree of fractions (see L<Math::PlanePath::FractionsTree>).  That tree
starts from 1/2 and makes fractions A/B with AE<lt>B by descending to
A/(A+B) and B/(A+B).  This is the same as the AYT tree with

    A = Y        AYT denominator is Kepler numerator
    B = X+Y      AYT sum num+den is the Kepler denominator

    X = B-A      inverse
    Y = A

=head2 Continued Fraction High to Low

X<Hanna, Paul D.>X<Czyz, Jerzy>X<Self, Will>C<tree_type=E<gt>"HCS"> selects
continued fraction terms coded as bit runs 1000...00 from high to low, as
per Paul D. Hanna and independently Jerzy Czyz and Will Self.

    http://oeis.org/A071766
    http://www.cut-the-knot.org/do_you_know/countRatsCF.shtml
    http://www.dm.unito.it/~cerruti/doc-html/tremattine/tre_mattine.pdf

This arises too in a radix=1 variation of Jeffrey Shallit's digit-based
continued fraction encoding too (see L<Math::PlanePath::CfracDigits/Radix
1>).

If the continued fraction of X/Y is

                 1
    X/Y = a + ------------
                     1
              b + -----------
                        1
                  c + -------
                    ... +  1
                          ---
                           z

then the N value is bit runs of lengths a,b,c etc.

    N = 1000 1000 1000 ... 1000
        \--/ \--/ \--/     \--/
         a+1   b    c       z-1

Each group is 1 or more bits.  Using a+1 for the first group makes it 1 or
more, since a=0 occurs for any X/YE<lt>=1.  Using z-1 in the last ensures
it's 1 or more since zE<gt>=2.

    N=1                             1/1
                              ------   ------
    N=2 to N=3             2/1               1/2
                          /    \            /    \
    N=4 to N=7         3/1      3/2      1/3      2/3
                       | |      | |      | |      | |
    N=8 to N=15      4/1 5/2  4/3 5/3  1/4 2/5  3/4 3/5

The result is a bit reversal of the AYT tree N values.  If N = binary
"1abcde" in the AYT tree then at that same X,Y the HCS has N = binary
"1edcba".  For example at X=4,Y=7 the AYT tree has N=11=0b10111 and the HCS
has N=30=0b11110, a reversal of the bits below the high 1.

Plotting by X,Y gives

=cut

# math-image --path=RationalsTree,tree_type=HCS --all --output=numbers_xy --size=70x11

=pod

    tree_type => "HCS"

    10  |     768        50                  58       896
     9  |     384   49        52   60        57  448       640
     8  |     192        27        31       224       320
     7  |      96   25   26   30   29  112       160   41   42
     6  |      48                  56        80
     5  |      24   13   15   28        40   21   23   44
     4  |      12        14        20        22        36
     3  |       6    7        10   11        18   19        34
     2  |       3         5         9        17        33
     1  |       1    2    4    8   16   32   64  128  256  512
    Y=0 |
        +-----------------------------------------------------
          X=0   1    2    3    4    5    6    7    8    9   10

N=1,2,4,etc in the row Y=1 are powers-of-2 for integers X/1 having
just a single group of bits N=1000..000.

N=1,3,6,12,etc in the column X=1 are 3*2^(Y-1) corresponding to continued
fraction S<1/Y = 0 + 1/Y> so the high group is a single bit for the 0 term
and then final group length Y-1, so bits N=11000...00.

=head2 Bird Tree

X<Hinze, Ralf>C<tree_type=E<gt>"Bird"> selects the Bird tree by Ralf Hinze

=over

"Functional Pearls: The Bird tree",
http://www.cs.ox.ac.uk/ralf.hinze/publications/Bird.pdf

=back

It's expressed recursively, illustrating Haskell programming features.  The
subtrees are tree plus one reciprocal on the left, and tree reciprocal plus
one on the right,

    1/(tree + 1)  and  (1/tree) + 1

which means Y/(X+Y) and (X+Y)/X taking N bits low to high.

    N=1                             1/1
                              ------   ------
    N=2 to N=3             1/2               2/1
                          /    \            /    \
    N=4 to N=7         2/3      1/3      3/1      3/2
                       | |      | |      | |      | |
    N=8 to N=15     3/5  3/4  1/4 2/5  5/2 4/1  4/3 5/3

Plotting by X,Y gives

    tree_type => "Bird"

    10  |     682        41                  38       597
     9  |     341   43        45   34        36  298       938
     8  |     170        23        16       149       469
     7  |      85   20   22   17   19   74       234   59   57
     6  |      42                  37       117
     5  |      21   11    8   18        58   28   31   61
     4  |      10         9        29        30        50
     3  |       5    4        14   15        25   24        54
     2  |       2         7        12        27        52
     1  |       1    3    6   13   26   53  106  213  426  853
    Y=0 |
         ----------------------------------------------------
          X=0   1    2    3    4    5    6    7    8    9   10

Notice that unlike the other trees N=1,2,5,10,etc in the X=1 vertical of
fractions 1/Y is not the row start or end, but instead are on a zigzag
through the middle of the tree giving binary N=1010...etc alternate 1 and 0
bits.  The integers X/1 in the Y=1 vertical are similar, but N=11010...etc
starting the alternation from a 1 in the second highest bit, since those
integers are in the right hand half of the tree.

The Bird tree N values are related to the SB tree by inverting every second
bit starting from the second after the high 1-bit, ie. xor "001010...".  So
if N=1abcdefg binary then b,d,f are inverted, ie. an xor with binary
00101010.  For example 3/4 in the SB tree is at N=11 = binary 1011.  Xor
with 0010 for binary 1001 N=9 which is the 3/4 in the Bird tree.  The same
xor goes back the other way Bird tree to SB tree.

This xoring is a mirroring in the tree, swapping left and right at each
level.  Only every second bit is inverted because mirroring twice puts it
back to the ordinary way on even rows.

=head2 Drib Tree

X<Hinze, Ralf>C<tree_type=E<gt>"Drib"> selects the Drib tree by Ralf Hinze.

=over

http://oeis.org/A162911

=back

It reverses the bits of N in the Bird tree (in a similar way that the SB and
CW are bit reversals of each other).

    N=1                             1/1
                              ------   ------
    N=2 to N=3             1/2               2/1
                          /    \            /    \
    N=4 to N=7         2/3      3/1      1/3      3/2
                       | |      | |      | |      | |
    N=8 to N=15     3/5  5/2  1/4 4/3  3/4 4/1  2/5 5/3

The descendants of each node are

          X/Y
        /     \
    Y/(X+Y)  (X+Y)/X

X<Fibonacci Numbers>The endmost fractions of each row are Fibonacci numbers,
F(k)/F(k+1) on the left and F(k+1)/F(k) on the right.

=cut

# math-image --path=RationalsTree,tree_type=Drib --all --output=numbers_xy

=pod

    tree_type => "Drib"

    10  |     682        50                  44       852
     9  |     426   58        54   40        36  340       683
     8  |     170        30        16       212       427
     7  |     106   18   22   24   28   84       171   59   51
     6  |      42                  52       107
     5  |      26   14    8   20        43   19   31   55
     4  |      10        12        27        23        41
     3  |       6    4        11   15        25   17        45
     2  |       2         7         9        29        37
     1  |       1    3    5   13   21   53   85  213  341  853
    Y=0 |
         -------------------------------------------------------
         X=0    1    2    3    4    5    6    7    8    9   10

In each node descent the left Y/(X+Y) E<lt> 1 and the right (X+Y)/X E<gt> 1,
which means even N is above the X=Y diagonal and odd N is below.

Because Drib/Bird are bit reversals like CW/SB are bit reversals, the xor
procedure described above which relates BirdE<lt>-E<gt>SB applies to
DribE<lt>-E<gt>CW, but working from the second lowest bit upwards, ie. xor
binary "0..01010".  For example 4/1 is at N=15 binary 1111 in the CW tree.
Xor with 0010 for 1101 N=13 which is 4/1 in the Drib tree.

=head2 L Tree

X<Luschny, Peter>C<tree_type=E<gt>"L"> selects the L-tree by Peter Luschny.

=over

http://www.oeis.org/wiki/User:Peter_Luschny/SternsDiatomic

=back

It's a row-reversal of the CW tree with a shift to include zero as 0/1.

    N=0                             0/1
                              ------   ------
    N=1 to N=2             1/2               1/1
                          /    \            /    \
    N=3 to N=8         2/3      3/2      1/3      2/1
                       | |      | |      | |      | |
    N=9 to N=16     3/4  5/3  2/5 5/2  3/5 4/3  1/4 3/1

Notice in the N=9 to N=16 row rationals 3/4 to 1/4 are the same as in the CW
tree but read right-to-left.

=cut

# math-image --path=RationalsTree,tree_type=L --all --output=numbers_xy --size=70x11

=pod

    tree_type => "L"

    10  |    1021        37                  55       511
     9  |     509   45        33   59        47  255      1020
     8  |     253        25        19       127       508
     7  |     125   21   17   27   23   63       252   44   36
     6  |      61                  31       124
     5  |      29    9   11   15        60   20   24   32
     4  |      13         7        28        16        58
     3  |       5    3        12    8        26   18        54
     2  |       1         4        10        22        46
     1  |  0    2    6   14   30   62  126  254  510 1022 2046
    Y=0 |
         -------------------------------------------------------
         X=0    1    2    3    4    5    6    7    8    9   10

N=0,2,6,14,30,etc along the row at Y=1 are powers 2^(X+1)-2.
N=1,5,13,29,etc in the column at X=1 are similar powers 2^Y-3.

=head2 Common Characteristics

The SB, CW, Bird, Drib, AYT and HCS trees have the same set of rationals in
each row, just in different orders.  The properties of Stern's diatomic
sequence mean that within a row the totals are

    row N=2^level to N=2^(level+1)-1 inclusive

    sum X/Y     = (3 * 2^level - 1) / 2
    sum X       = 3^level
    sum 1/(X*Y) = 1

For example the SB tree level=2, N=4 to N=7,

    sum X/Y     = 1/3 + 2/3 + 3/2 + 3/1 = 11/2 = (3*2^2-1)/2
    sum X       = 1+2+3+3 = 9 = 3^2
    sum 1/(X*Y) = 1/(1*3) + 1/(2*3) + 1/(3*2) + 1/(3*1) = 1

Many permutations are conceivable within a row, but the ones here have some
relationship to X/Y descendants, tree sub-forms or continued fractions.  As
an encoding of continued fraction terms by bit runs the combinations are

     bit encoding       high to low    low to high
    ----------------    -----------    -----------
    runs 000 or 111         SB             CW
    alternating 0101       Bird           Drib
    runs 10000              HCS            AYT

The runs of alternating 101010 end at a kind of phase shift, where the bit
is not the expected alternating 0,1 but instead a doubled 00 or 11.

=head2 Minkowski Question Mark

The Minkowski question mark function is a +/- sum of the quotients in the
continued fraction of a real number,

                     1         1            1
    ?(r) = 2 * (1 - ---- + --------- - ------------ + ... )
                    2^q0   2^(q0+q1)   2^(q0+q1+q2)

For a rational r the continued fraction is finite and so the sum is rational
too.  The pattern of + and - in the terms gives runs of bits the same as the
N values in the Stern-Brocot tree.  The code here can calculate the ? function
on a rational r=X/Y using

    N = xy_to_n(X,Y) tree_type=>"SB"
    depth = floor(log2(N))       # row containing N (depth=0 at top)
    Ndepth = 2^depth             # start of row containing N

             2*(N-Ndepth) + 1
    ?(X/Y) = ----------------
                  Ndepth

The effect of N-Ndepth is to remove the high 1-bit, and 2*()+1 appends an
extra 1-bit at the end.  The division /Ndepth scales down from integer N to
a fraction.

    N = 1abcdef      in binary
    ? = a.bcdef1     binary fraction

For example ?(2/3) is X=2,Y=3 which is N=5 in SB.  It has depth=2,
Ndepth=2^2=4, and so ?(2/3)=(2*(5-4)+1)/4=3/4.  Or in binary N=101 gives
Ndepth=100 and N-Ndepth=01 so 2*(N-Ndepth)+1=011 and divide Ndepth=100 for
?=0.11.

In practice this is not a very efficient way to handle the question
function, since the bit runs in the N values may become quite large for
relatively modest continued fraction terms.  (L<Math::ContinuedFraction> may
be better, and in particular allows repeating patterns of quadratic
irrationals to be represented exactly.)

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over

=item C<$path = Math::PlanePath::RationalsTree-E<gt>new ()>

=item C<$path = Math::PlanePath::RationalsTree-E<gt>new (tree_type =E<gt> $str)>

Create and return a new path object.  C<tree_type> (a string) can be

    "SB"      Stern-Brocot
    "CW"      Calkin-Wilf
    "Bird"
    "Drib"
    "AYT"     Andreev, Yu-Ting
    "HCS"
    "L"

=item C<$n = $path-E<gt>n_start()>

Return the first N in the path.  This is 1 for SB, CW, Bird, Drib and AYT,
but 0 for L.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

Return a range of N values which occur in a rectangle with corners at
C<$x1>,C<$y1> and C<$x2>,C<$y2>.  The range is inclusive.

For reference, C<$n_hi> can be quite large because within each row there's
only one new X/1 integer and 1/Y fraction.  So if X=1 or Y=1 is included
then roughly C<$n_hi = 2**max(x,y)>.  If min(x,y) is bigger than 1 then it
reduces a little to roughly 2**(max/min + min).

=back

=head2 Tree Methods

=over

=item C<@n_children = $path-E<gt>tree_n_children($n)>

Return the two children of C<$n>, or an empty list if C<$n E<lt> 1>
(ie. before the start of the path).

This is simply C<2*$n, 2*$n+1>.  The children are C<$n> with an extra bit
appended, either a 0-bit or a 1-bit.

=item C<$num = $path-E<gt>tree_n_num_children($n)>

Return 2, since every node has two children.  If C<$nE<lt>1> (ie. before the
start of the path) then return C<undef>.

=item C<$n_parent = $path-E<gt>tree_n_parent($n)>

Return the parent node of C<$n>.  Or return C<undef> if C<$n E<lt>= 1> (the
top of the tree).

This is simply Nparent = floor(N/2), ie. strip the least significant bit
from C<$n> (undoing what C<tree_n_children()> appends).

=item C<$depth = $path-E<gt>tree_n_to_depth($n)>

Return the depth of node C<$n>, or C<undef> if there's no point C<$n>.  The
top of the tree at N=1 is depth=0, then its children depth=1, etc.

This is simply floor(log2(N)) since the tree has 2 nodes per point.  For
example N=4 through N=7 are all depth=2.

The L tree starts at N=0 and the calculation becomes floor(log2(N+1)) there.

=item C<$n = $path-E<gt>tree_depth_to_n($depth)>

=item C<$n = $path-E<gt>tree_depth_to_n_end($depth)>

Return the first or last N at tree level C<$depth> in the path, or C<undef>
if nothing at that depth or not a tree.  The top of the tree is depth=0.

The structure of the tree means the first N is at C<2**$depth>, or for the L
tree S<C<2**$depth - 1>>.  The last N is C<2**($depth+1)-1>, or for the L
tree C<2**($depth+1)>.

=back

=head1 OEIS

The trees are in Sloane's Online Encyclopedia of Integer Sequences in
various forms,

    http://oeis.org/A007305   (etc)

    A007305  SB X numerators, Farey fractions (extra 0,1)
    A047679  SB Y denominators
    A007306  SB X+Y sum, Farey 0 to 1 part (extra 1,1)
    A153036  SB floor(X/Y), ie. integer part
    A002487  CW X and Y, Stern diatomic sequence (extra 0)
    A070990  CW Y-X diff, Stern diatomic first diffs (less 0)
    A070871  CW X*Y product
    A020650  AYT X
    A020651  AYT Y (Kepler X)
    A086592  AYT X+Y sum (Kepler denominators)
    A071766  HCS Y
    A071585  HCS X+Y sum (sum giving rationals >= 1)
    A162909  Bird X
    A162910  Bird Y
    A162911  Drib X
    A162912  Drib Y
    A174981  L-tree X
    A002487  L-tree Y, same as CW X,Y, Stern diatomic

    A000523  tree_n_to_depth(), being floor(log2(n))

    A086893  position Fibonacci F[n+1],F[n] in Stern diatomic,
               CW N of F[n+1]/F[n]
               Drib N on row Y=1, being X/1
    A061547  position Fibonacci F[n],F[n+1] in Stern diatomic,
               CW N of F[n]/F[n+1]
               Drib N in column X=1, being 1/Y

    A081254  Bird N in row Y=1, binary 110101010...10
    A000975  Bird N in column X=1, binary 1010..1010
    A088696  length of continued fraction SB left half (X/Y<1)

    A059893  permutation SB<->CW, reverse bits below highest
    A153153  permutation CW->AYT, reverse and un-Gray
    A153154  permutation AYT->CW, reverse and Gray code
    A154437  permutation AYT->Drib, Lamplighter low to high
    A154438  permutation Drib->AYT, un-Lamplighter low to high
    A003188  permutation SB->HCS, Gray code shift+xor
    A006068  permutation HCS->SB, Gray code inverse
    A154435  permutation HCS->Bird, Lamplighter bit flips
    A154436  permutation Bird->HCS, Lamplighter variant

    A054429  permutation SB,CW,Bird,Drib N at transpose Y/X, 
               (mirror binary tree, runs 0b11..11 down to 0b10..00)
    A004442  permutation AYT N at transpose Y/X, from N=2 onwards
               (xor 1, ie. flip least significant bit)
    A063946  permutation HCS N at transpose Y/X, extra initial 0
               (xor 2, ie. flip second least significant bit)

    A054424  permutation DiagonalRationals -> SB
    A054426  permutation SB -> DiagonalRationals
    A054425  DiagonalRationals -> SB with 0s at non-coprimes
    A054427  permutation coprimes -> SB right hand X/Y>1

The sequences marked "extra ..." have one or two extra initial values over
what the RationalsTree here gives, but are the same after that.  And the
Stern first differences "less ..." means it has one less term than what the
code here gives.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::FractionsTree>,
L<Math::PlanePath::CfracDigits>,
L<Math::PlanePath::CoprimeColumns>,
L<Math::PlanePath::DiagonalRationals>,
L<Math::PlanePath::FactorRationals>,
L<Math::PlanePath::GcdRationals>,
L<Math::PlanePath::PythagoreanTree>

L<Math::NumSeq::SternDiatomic>,
L<Math::ContinuedFraction>

Jerzy Czyz and William Self, "The Rationals Are Countable: Euclid's Proof",
The College Mathematics Journal, volume 34, number 5, November 2003, page
367.

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
