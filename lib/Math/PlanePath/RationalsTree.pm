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


# cf A054429 permutation reverse within binary row
#    A065249 - permutation SB X -> X/2
#    A065250 - permutation SB X -> 2X
#    A057114 - permutation SB X -> X+1
#    A057115 - permutation SB X -> X-1
#

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


#------------------------------------------------------------------------------
# HCS turn left when even number of 1-bits in N+1
#     turn right when odd number of 1-bits in N+1
#
# A010059 start=0: 1,0,0,1,0,1,1,0,0,1,1,0,1,0,0,1,0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0,0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0,1,0,0,1,0,1,1,0,0,1,1,0,1,0,0,1,0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0,1,0,0,1,0,1,1,0,0,1,1,0,1,0,0,1,1,0,0,1,0
#   match 1,0,1,1,0,0,1,1,0,1,0,0,1,0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0,0,1,1,0,1,0,0,1,1,0,0,1,0
#   PlanePathTurn planepath=RationalsTree,tree_type=HCS,  turn_type=Left
#
# A010060 start=0: 0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0,1,0,0,1,0,1,1,0,0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0,0,1,1,0,1,0,0,1,0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0,1,0,0,1,0,1,1,0,0,1,1,0,1,0,0,1,0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0,0,1,1,0,1
#   match 0,1,0,0,1,1,0,0,1,0,1,1,0,1,0,0,1,0,1,1,0,0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0,0,1,1,0,1
#   PlanePathTurn planepath=RationalsTree,tree_type=HCS,  turn_type=Right
#
# 10  |     768        50                  58       896
#  9  |     384   49        52   60        57  448       640
#  8  |     192        27        31       224       320
#  7  |      96   25   26   30   29  112       160   41   42
#  6  |      48                  56        80
#  5  |      24   13   15   28        40   21   23   44
#  4  |      12        14        20        22        36
#  3  |       6    7        10   11        18   19        34
#  2  |       3         5         9        17        33
#  1  |       1    2    4    8   16   32   64  128  256  512
# Y=0 |
#     +-----------------------------------------------------
#       X=0   1    2    3    4    5    6    7    8    9   10
#
#                               1/1
#                  /------------- -------------\
#               2/1                             1/2               2,3 L,R
#          /----   ----\                   /----   ----\
#       3/1             3/2             1/3             2/3    4,5,6,7 L,L,R,R
#      /   \           /   \           /   \           /   \      8        12
#   4/1     5/2     4/3     5/3     1/4     2/5     3/4     3/5   L,L,R,L, R,R,L,R
#  /   \   /   \   /   \   /   \   /   \   /   \   /   \   /   \
# 5/1 7/2 7/3 8/3 5/4 7/5 7/4 8/5 1/5 2/7 3/7 3/8 4/5 5/7 4/7 5/8
#
#         *
#        / \                        U=0 = X+Y, Y           shear
#       /   *                       D=1 = Y,   X+Y         shear+transpose
#      /     \a  = 0.1^k.1
#     N
#      \     /b  = 1.0^k.0
#       \   *
#        \ / \c  = 1.0^k.1         c=even bits, left
#         *
#
# F[-1]=1 F[0]=0 F[1]=1 F[2]=1 F[3]=2 F[4]=3 F[5]=5 ...
# 1^k is F[k-1]*X+F[k]*Y, F[k]*X+F[k+1]*Y
#  X   ,     Y    0
#     Y,  X+ Y    1
#  X+ Y,  X+2Y    2
#  X+2Y, 2X+3Y    3
# 2X+3Y, 3X+5Y    4
#
# then aX = F[k]*X+F[k+1]*Y + F[k+1]*X+F[k+2]*Y
#         = (F[k]+F[k+1])*X + (F[k+1]+F[k+2])*Y
#         = F[k+2]*X + F[k+3]*Y
#      aY = F[k+1]*X + F[k+2]*Y                 near X=phi*Y big
#
# 0^k is X+k*Y, Y
# so bX = Y
#    bY = X+k*Y + Y = X+(k+1)*Y                 near Y axis
#
# c1X = Y
# c1Y = X+Y
# c2X = Y + k*(X+Y) = k*X + (k+1)*Y
# c2Y = X+Y
# cX = X+Y
# cY = k*X + (k+1)*Y + X+Y = (k+1)X + (k+2)Y    near X=Y

#
#         *
#        / \ /a  = 0.1^k.0
#       /   *
#      /     \b  = 0.1^k.1
#     N
#      \     /c  = 1.0^k.1     c=even bits, left
#       \   *
#        \ /
#         *
#------------------------------------------------------------------------------

package Math::PlanePath::RationalsTree;
use 5.004;
use strict;
use Carp;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 103;
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

use constant class_x_negative => 0;
use constant class_y_negative => 0;
sub x_minimum {
  my ($self) = @_;
  return ($self->{'tree_type'} eq 'L' ? 0 : 1);
}
use constant y_minimum => 1;
use constant tree_any_leaf => 0;  # no leaves, complete tree
use constant tree_num_children_minimum => 2; # complete binary tree
use constant tree_num_children_maximum => 2;
use constant tree_n_to_height => undef; # complete tree, all infinity

{
  my %absdy_minimum = (# SB   => 0,
                       CW   => 1,
                       # AYT  => 0,
                       # Bird => 0,
                       # Drib => 0,
                       L    => 1);
  sub absdy_minimum {
    my ($self) = @_;
    return $absdy_minimum{$self->{'tree_type'}} || 0;
  }
}

{
  # Drib apparent minimum dX=k dY=2*k+1 approaches dX=1,dY=2
  my %dir_minimum_dxdy = (CW   => [0,1],
                          Drib => [1,2],
                          L    => [1,1], # N=0 dX=1,dY=1
                         );
  sub dir_minimum_dxdy {
    my ($self) = @_;
    return @{$dir_minimum_dxdy{$self->{'tree_type'}} || [1,0]};
  }
}
{
  # AB apparent maximum dX=-6,dY=-12 at N=3
  # AC apparent maximum dX=-6,dY=-12 at N=3 same
  # PQ apparent maximum dX=-1,dY=-1
  my %dir_maximum_dxdy
    = (SB   => [1,-1],
       Bird => [1,-1],
       # CW   => [0,0],
       # AYT  => [0,0],
       # Drib => [0,0],
       # L    => [0,0], # at 2^k-1 dX=k+1,dY=-1 so approach Dir=4
       HCS  => [2,-1],
      );
  sub dir_maximum_dxdy {
    my ($self) = @_;
    return @{$dir_maximum_dxdy{$self->{'tree_type'}} || [0,0]};
  }
}

#------------------------------------------------------------------------------

my %attributes = (CW   => [ n_start => 1, ],
                  SB   => [ n_start => 1, reverse_bits => 1 ],
                  Drib => [ n_start => 1, alternating => 1 ],
                  Bird => [ n_start => 1, alternating => 1, reverse_bits => 1 ],
                  AYT  => [ n_start => 1, sep1s => 1 ],
                  HCS  => [ n_start => 1, sep1s => 1, reverse_bits => 1 ],
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
# If $x,$y have a common factor then the return is an empty list.
# If $x,$y have no common factor then the returned list is always one or
# more quotients.
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
  $n = $n - $self->{'n_start'}; # N=0 basis, and warn if $n==undef
  if ($n > 0) {
    return int(($n-1)/2) + $self->{'n_start'};
  } else {
    return undef;
  }
}
sub tree_n_to_depth {
  my ($self, $n) = @_;
  ### RationalsTree tree_n_to_depth(): $n
  $n = $n - $self->{'n_start'}; # N=0 basis, and warn if $n==undef
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


=for stopwords eg Ryde OEIS ie Math-PlanePath coprime encodings Moritz Achille Brocot Stern-Brocot mediant Calkin Wilf Calkin-Wilf 1abcde 1edcba Andreev Yu-Ting Shen AYT Ralf Hinze Haskell subtrees xoring Drib RationalsTree unflipped GCD Luschny Jerzy Czyz Minkowski Nstart Shallit's HCS Ndepth N-Ndepth Nparent subtree LRRL

=head1 NAME

Math::PlanePath::RationalsTree -- rationals by tree

=head1 SYNOPSIS

 use Math::PlanePath::RationalsTree;
 my $path = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path enumerates reduced rational fractions X/Y E<gt> 0, ie. X and Y
having no common factor.

The rationals are traversed by rows of a binary tree which effectively
represents a coprime pair X,Y by steps of a subtraction-only greatest common
divisor algorithm which proves them coprime.  Or equivalently by bit runs
with lengths which are the quotients in the division based Euclidean GCD
algorithm, which are also the terms in the continued fraction representation
of X/Y.

The SB, CW, AYT, HCS, Bird and Drib trees all have the same set of X/Y
rationals in a row, but in a different order due to different encodings of
the N value, either high to low or low to high and some bit flips.  The L
tree has a shift which visits 0/1 too.

The bit runs mean that N values are quite large for relatively modest sized
rationals.  For example in the SB tree 167/3 is N=288230376151711741, a
58-bit number.  The tendency is for the tree to make excursions out to large
rationals while only slowly filling in small ones.  The worst is the integer
X/1 which is an N with X many bits, and similarly 1/Y is Y bits.

See F<examples/rationals-tree.pl> in the Math-PlanePath sources for a
printout of all the trees.

=head2 Stern-Brocot Tree

X<Stern, Moritz>X<Brocot, Achille>The default C<tree_type=E<gt>"SB"> is the
tree of Moritz Stern and Achille Brocot.  The rows are fractions of
increasing value.

                                               N       depth
                                             -------   -----
                    1/1                        1         0
              ------   ------
           1/2               2/1             2 to 3      1
          /    \            /   \
       1/3      2/3      3/2      3/1        4 to 7      2
       | |      | |      | |      | |
    1/4  2/5  3/5 3/4  4/3 5/3  5/2 4/1      8 to 15     3

Each row of the tree is a repeat of the previous row, first as X/(X+Y) and
then (X+Y)/Y.  For example

    depth=1 row 1/2, 2/1

    depth=2 row 1/3, 2/3    X/(X+Y) of previous row
            and 3/2, 3/1    (X+Y)/Y of previous row

Plotting the N values by X,Y is as follows.  The unused X,Y positions are
where X and Y have a common factor.  For example X=6,Y=2 has common factor 2
so is never reached.

    tree_type => "SB"

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

    Nstart = 2^depth

The Y=1 horizontal is the X/1 integers at the end each row which is

    Nend = 2^(depth+1)-1

Numbering nodes of the tree by rows starting from 1 means N without the high
1 bit is the offset into the row.  For example binary N="1011" is "011"=3
into the row.  Those bits after the high 1 are also the directions to follow
down the tree to a node, with 0=left and 1=right.  So N="1011" binary goes
from the root 0=left then twice 1=right to reach X/Y=3/4 at N=11 decimal.

=head2 Stern-Brocot Turn Sequence

Each row makes a path from the Y axis across and down to the X.  Each row is
further from the origin than the previous row and doesn't intersect any
other row.  The X/(X+Y) first half is an upward "shear" to the X,Y points of
the previous row.  Similarly the second half (X+Y)/Y shears to the right.
For example,

                                N=8 to N=11
                               previous row
                               sheared up X,X+Y
      depth=2 N=4to7
    |                     |      9--10      .     depth=3 N=8to15
    |                     |    /     |    .
    |                     |  8      11  .
    |                     |           .
    |  4---5              |         .   12--13    N=12 to N=15
    |        \            |       .          |    previous row
    |          6          |     .           14    sheared right
    |          |          |   .            /      as X+Y,Y
    |          7          |             15
    |                     |
    +---------------      +----------------

The sequence of turns left or right is unchanged by the shears.  So at N=5
the path turns towards the right and this is unchanged in the sheared copies
at N=9 and N=13.  The angle of the turn is different, but it's still to the
right.

The first and last points of each row are always a turn to the right.  For
example the turn at N=4 (going N=3 to N=4 to N=5) is to the right, and
likewise at N=7.  This is because the second of the row such as N=5 is above
a 45-degree line down from N=4, and similarly the second last such as N=6.

The middle two points in each row for depthE<gt>=3 are always a turn to the
left.  N=11 and N=12 shown above are the first such middle pair, both
turning to the left.  This is because the middle two are transposes across
the leading diagonal and so make a 45-degree line.  The second-from-middle
points are above that line (N=10 and N=13).

The middle left turns are copied into successive rows and the result is a
repeating pattern "LRRL" except for the first and last in the row which are
always right instead of left.

    N=3                                left
    otherwise if N=2^k or N=2^k-1      right

    otherwise if N=0 mod 4             left
                 N=1 mod 4             right
                 N=2 mod 4             right
                 N=3 mod 4             left

Pairs N=2m and N=2m-1 can be treated together by taking ceil(N/2),

    N=3                                left
    otherwise if Nhalf=2^k             right

    otherwise if Nhalf=0 mod 2         left
    otherwise if Nhalf=1 mod 2         right
      where Nhalf = ceil(N/2)

=head2 Stern-Brocot Mediant

Writing the parents between the children as an "in-order" tree traversal to
a given depth has all values in increasing order, the same as each row
individually is in increasing order.

                 1/1
         1/2      |      2/1
     1/3  |  2/3  |  3/2  |  3/1
      |   |   |   |   |   |   |

     1/3 1/2 2/3 1/1 3/2 2/1 3/1
                    ^
                    |
                    next level (1+3)/(1+2) = 4/3 mediant

New values at the next level of this flattening are a "mediant"
(x1+x2)/(y1+y2) formed from the left and right parent.  So the next level
4/3 shown is left parent 1/1 and right parent 3/2 giving mediant
(1+3)/(1+2)=4/3.  At the left end a preceding 0/1 is imagined.  At the right
a following 1/0 is imagined, so as to have 1/(depth+1) and (depth+1)/1 at
the ends for a total 2^depth many new values.

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

Going by rows the denominator of one value becomes the numerator of the
next.  So at 4/3 the denominator 3 becomes the numerator of 3/5 to the
right.  These values are Stern's diatomic sequence.

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

At each node the left leg is S<X/(X+Y) E<lt> 1> and the right leg is
S<(X+Y)/Y E<gt> 1>, which means N is even above the X=Y diagonal and odd
below.  In general each right leg increments the integer part of the
fraction,

    X/Y                       right leg each time
    (X+Y)/Y   = 1 + X/Y
    (X+2Y)/Y  = 2 + X/Y
    (X+3Y)/Y  = 3 + X/Y
    etc

This means the integer part is the trailing 1-bits of N,

    floor(X/Y) = count trailing 1-bits of N
    eg. 7/2 is at N=23 binary "10111"
        which has 3 trailing 1-bits for floor(7/2)=3

N values for the SB and CW trees are converted by reversing bits except the
highest.  So at a given X,Y position

    SB  N = 1abcde      SB <-> CW by reversing bits
    CW  N = 1edcba      except the high 1-bit

For example at X=3,Y=4 the SB tree has N=11 = "1011" binary and the CW has
N=14 binary "1110", a reversal of the bits below the high 1.

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

Their constructions are a one-to-one mapping between integer N and rational
X/Y as a way of enumerating the rationals.  It's not designed to be a tree
as such, but the result is the same 2^level rows as the above trees.  The
X/Y values within each row are again the same, but in a further different
order.

    N=1                             1/1
                              ------   ------
    N=2 to N=3             2/1               1/2
                          /    \            /    \
    N=4 to N=7         3/1      1/3      3/2      2/3
                       | |      | |      | |      | |
    N=8 to N=15     4/1  1/4  4/3 3/4  5/2 2/5  5/3 3/5

Each fraction descends as follows.  The left is an increment and the right
is reciprocal of the increment.

            X/Y
          /     \
    X/Y + 1     1/(X/Y + 1)

which means

          X/Y
        /     \
    (X+Y)/Y  Y/(X+Y)

The left leg (X+Y)/Y is the same the CW has on its right leg.  But Y/(X+Y)
is not the same as the CW (the other there being X/(X+Y)).

The left leg increments the integer part, so the integer part is given by
(in a fashion similar to CW 1-bits above)

    floor(X/Y) = count trailing 0-bits of N
                 plus one extra if N=2^k

N=2^k is one extra because its trailing 0-bits started from N=1 where
floor(1/1)=1 whereas any other odd N starts from some floor(X/Y)=0.

X<Fibonacci numbers>The Y/(X+Y) right leg forms the Fibonacci numbers
F(k)/F(k+1) at the end of each row, ie. at Nend=2^(level+1)-1.  And as noted
by Andreev, successive right leg fractions N=4k+1 and N=4k+3 add up to 1,

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

X<Kepler, Johannes>The tree structure corresponds to Johannes Kepler's tree
of fractions (see L<Math::PlanePath::FractionsTree>).  That tree starts from
1/2 and makes fractions A/B with AE<lt>B by descending to A/(A+B) and
B/(A+B).  Those descents are the same as the AYT tree and the two are
related simply by

    A = Y        AYT denominator is Kepler numerator
    B = X+Y      AYT sum num+den is the Kepler denominator

    X = B-A      inverse
    Y = A

=head2 HCS Continued Fraction

X<Hanna, Paul D.>X<Czyz, Jerzy>X<Self, Will>C<tree_type=E<gt>"HCS"> selects
continued fraction terms coded as bit runs 1000...00 from high to low, as
per Paul D. Hanna and independently Jerzy Czyz and Will Self.

=over

http://oeis.org/A071766

http://www.cut-the-knot.org/do_you_know/countRatsCF.shtml
http://www.dm.unito.it/~cerruti/doc-html/tremattine/tre_mattine.pdf

Jerzy Czyz and William Self, "The Rationals Are Countable: Euclid's
Proof", The College Mathematics Journal, volume 34, number 5,
November 2003, page 367.

=back

This arises also in a radix=1 variation of Jeffrey Shallit's digit-based
continued fraction encoding.  See L<Math::PlanePath::CfracDigits/Radix 1>.

If the continued fraction of X/Y is

                 1
    X/Y = a + ------------             a >= 0
                     1
              b + -----------         b,c,etc >= 1
                        1
                  c + -------
                    ... +  1
                          ---          z >= 2
                           z

then the N value is bit runs of lengths a,b,c etc.

    N = 1000 1000 1000 ... 1000
        \--/ \--/ \--/     \--/
         a+1   b    c       z-1

Each group is 1 or more bits.  The +1 in "a+1" makes the first group 1 or
more bits, since a=0 occurs for any X/YE<lt>=1.  The -1 in "z-1" makes the
last group 1 or more since zE<gt>=2.

    N=1                             1/1
                              ------   ------
    N=2 to N=3             2/1               1/2
                          /    \            /    \
    N=4 to N=7         3/1      3/2      1/3      2/3
                       | |      | |      | |      | |
    N=8 to N=15      4/1 5/2  4/3 5/3  1/4 2/5  3/4 3/5

The result is a bit reversal of the N values in the AYT tree.

    AYT  N = binary "1abcde"      AYT <-> HCS bit reversal
    HCS  N = binary "1edcba"

For example at X=4,Y=7 the AYT tree is N=11 binary "10111" whereas HCS there
has N=30 binary "11110", a reversal of the bits below the high 1.

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

N=1,2,4,etc in the row Y=1 are powers-of-2, being integers X/1 having just a
single group of bits N=1000..000.

N=1,3,6,12,etc in the column X=1 are 3*2^(Y-1) corresponding to continued
fraction S<0 + 1/Y> so terms 0,Y making runs 1,Y-1 and so bits N=11000...00.

=head2 HCS Turn Sequence

X<Thue-Morse>The turn sequence left or right following successive X,Y points
is the Thue-Morse sequence.

    count 1-bits in N+1      turn at N
    -------------------      ---------
           odd                 right
           even                left

This works because each row is two copies of the preceding.  The first copy
is (X+Y)/Y so just a shear.  This is N=10xxxxx introducing a 0-bit at the
top of N.  The second copy is Y/(X+Y) so a shear and then transpose.  This
is N=11xxxxx introducing a further 1-bit at the top of N, so the transpose
swapping leftE<lt>-E<gt>right corresponds to an extra 1-bit.

For the last point of a row and the first of the next the points are

                    N binary
                    --------
    second last       11110     Lucas     L[n]/L[n+1] eg. 4/7
    last              11111     Fibonacci F[n]/F[n+1] eg. 8/13
    first            100000     d+1 / 1               eg. 6/1
    second           100001     2d-1 / 2              eg. 9/2

The second last of a row 11110 is a pair of Lucas numbers and the last of a
row 11111 is a pair of Fibonacci numbers bigger than those lucas numbers.
Plotting the examples shows the layout,
 
    13 |                __*  Fib 
       |             __/  /  [Right]
       |          __/    /
       |         /      /
     7 |        *       /
       |      Luc      /
       |              /
     2 |              /  ___* 2nd
     1 |         1st *---
       |        [Left]
       +--------------------------
                4    6    8 9

The Lucas and Fibonacci pairs are both on a slope roughly Y=X*phi for
phi=(1+sqrt(5))/2 the golden ratio.  The first and second points of the next
row are then off towards X=d+1 and hence a right turn at the last of the
row, and it corresponds to N+1 = binary "100000" having an odd number of
1-bits (a single 1-bit).  Then at the first of the next row the turn is left
corresponding to N=1 = binary "100001" having an even number of 1-bits (two
1-bits).

The cases for the middle of a row, where the two copies of the previous row
meet, behave similarly,

    middle prev     1011110    Lucas     L[n+1]/L[n]
    middle end      1011111    Fibonacci F[n+1]/F[n]
    middle          1100000    1 / d+1
    middle second   1100001    2 / 2d-1

These points are like a transpose of the first/last shown above, though the
Lucas and Fibonacci pairs are one depth further on.  The "middle end"
1011111 turns to the right, corresponding to N+1=1100000 having even 1-bits,
and then at the "middle" 1100000 turn left corresponding to N+1=1100001
having odd 1-bits.

=cut

#       X/Y              low to high
#     /     \
# (X+Y)/Y  Y/(X+Y)

#         d=0    d=1    d=2    d=3    d=4    d=5
#  11110  1/1 -> 2/1 -> 1/3 -> 3/4 -> 4/7           Ld / Ld+1
#  11111  1/1 -> 1/2 -> 2/3 -> 3/5 -> 5/8           Fd / Fd+1       R
# 100000  1/1 -> 2/1 -> 3/1 -> 4/1 -> 5/1 -> 6/1    d+1+1 / 1       L
# 100001  1/1 -> 1/2 -> 3/2 -> 5/2 -> 7/2 -> 9/2    2(d+1)-1 / 2

# 101110  1/1 -> 2/1 -> 1/3 -> 3/4 -> 4/7 -> 11/7   Ld+1 / Ld
# 101111  1/1 -> 1/2 -> 2/3 -> 3/5 -> 5/8 -> 13/8   Fd+1 / Fd       R
# 110000  1/1 -> 2/1 -> 3/1 -> 4/1 -> 5/1 -> 1/6    1 / d+1         L
# 110001  1/1 -> 1/2 -> 3/2 -> 5/2 -> 7/2 -> 2/9    2 / 2d-1

# 9                               9    d
# 8              b                8                                   b
# 7           a  R                7  L                          a     R
# 6                               6  c
# 5                               5
# 4                               4
# 3                               3
# 2                 L     d       2
# 1                 c             1
#    1  2  3  4  5  6  7  9          1  2  3  4  5  6  7  9 10 11 12 13

#  1111110  1/1 -> 2/1 -> 1/3 -> 3/4 -> 4/7 -> 7/11 -> 11/18      Ld / Ld+1
#  1111111  1/1 -> 1/2 -> 2/3 -> 3/5 -> 5/8 -> 8,13 -> 13/21      Fd / Fd+1
#
# L[d+2] = 2*F[d] + F[d+1]
# L[d] = 2*F[d-2] + F[d-1]
#      = 2*(F[d]-F[d-1]) + F[d-1]
#      = 2*F[d] - 2*F[d-1] + F[d-1]
#      = - F[d-1] + 2*F[d]                       -8+2*13=18
#      = - (F[d+1]-F[d]) + 2*F[d]
#      = - F[d+1] + F[d] + 2*F[d]
#      = 3*F[d] - F[d+1]
#      = 3*(F[d+2]-F[d+1]) - F[d+1]
#      = 3*F[d+2] - 3*F[d+1] - F[d+1]
#      = -4*F[d+1] + 3*F[d+2]
# L[d]   = -4*F[d] + 3*F[d+1]                   -4*13 + 3*21 = 11
# L[d+1] = 3*F[d] - F[d+1]                        3*13 - 21 = 18
# L[d+1] = - F[d] + 2*F[d+1]                     -13 + 2*21
#
# F[d]-L[d] = F[d] - (-4*F[d] + 3*F[d+1])
#           = F[d] + 4*F[d] - 3*F[d+1]
#           = 5*F[d] - 3*F[d+1]                  dX = 5*13 - 3*21 = 2
# F[d+1]-L[d+1] = F[d+1] - (3*F[d] - F[d+1])
#               = F[d+1] - 3*F[d] + F[d+1]
#               = -3*F[d] + 2*F[d+1]            dY = -3*13+2*21 = 3
#               = -3*F[d] + 2*(F[d-1]+F[d])
#               = -3*F[d] + 2*F[d-1] + 2*F[d]
#               = -F[d] + 2*F[d-1]
#               = -(F[d-2]+F[d-1]) + 2*F[d-1]
#               = - F[d-2] - F[d-1] + 2*F[d-1]
#               = - F[d-2] + F[d-1]
#               = - F[d-2] + F[d-3] + F[d-2]
#               = F[d-3]
# dX = F[d-4]
# dY = F[d-3]

=pod

=head2 Bird Tree

X<Hinze, Ralf>C<tree_type=E<gt>"Bird"> selects the Bird tree by Ralf Hinze

=over

"Functional Pearls: The Bird tree",
http://www.cs.ox.ac.uk/ralf.hinze/publications/Bird.pdf

=back

It's expressed recursively, illustrating Haskell programming features.  The
left subtree is the tree plus one then take the reciprocal.  The right
subtree is conversely the tree reciprocal then plus one,

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
through the middle of the tree giving binary N=1010...etc with alternate 1
and 0 bits.  The integers X/1 in the Y=1 vertical are similar, but
N=11010...etc starting the alternation from a 1 in the second highest bit,
since those integers are in the right hand half of the tree.

The Bird tree N values are related to the SB tree by inverting every second
bit starting from the second after the high 1-bit,

    Bird N=1abcdefg..    binary
             101010..    xor, so b,d,f etc flip 0<->1
    SB   N=1aBcDeFg..         to make B,D,F

For example 3/4 in the SB tree is at N=11 = binary 1011.  Xor with 0010 for
binary 1001 N=9 which is 3/4 in the Bird tree.  The same xor goes back the
other way Bird tree to SB tree.

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

X<Fibonacci numbers>The endmost fractions of each row are Fibonacci numbers,
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

    row N=2^depth to N=2^(depth+1)-1 inclusive

      sum X/Y     = (3 * 2^depth - 1) / 2
      sum X       = 3^depth
      sum 1/(X*Y) = 1

For example the SB tree depth=2, N=4 to N=7,

    sum X/Y     = 1/3 + 2/3 + 3/2 + 3/1 = 11/2 = (3*2^2-1)/2
    sum X       = 1+2+3+3 = 9 = 3^2
    sum 1/(X*Y) = 1/(1*3) + 1/(2*3) + 1/(3*2) + 1/(3*1) = 1

Many permutations are conceivable within a row, but the ones here have some
relationship to X/Y descendants, tree sub-forms or continued fractions.  As
an encoding of continued fraction terms by bit runs the combinations are

     bit encoding           high to low    low to high
    ----------------        -----------    -----------
    0000,1111 runs              SB             CW
    0101,1010 alternating       Bird           Drib
    1000,1000 runs              HCS            AYT

A run of alternating 101010 ends where the next bit is the oppose of the
expected alternating 0,1.  This is a doubled bit 00 or 11.  An electrical
engineer would think of it as a phase shift.

=head2 Minkowski Question Mark

The Minkowski question mark function is a sum of the terms in the continued
fraction representation of a real number.  If q0,q1,q2,etc are those terms
then the question mark function "?(r)" is

                     1           1           1
    ?(r) = 2 * (1 - ---- * (1 - ---- * (1 - ---- * (1 - ...
                    2^q0        2^q1        2^q2

                     1         1            1
         = 2 * (1 - ---- + --------- - ------------ + ... )
                    2^q0   2^(q0+q1)   2^(q0+q1+q2)

For rational r the continued fraction q0,q1,q2,etc is finite and so the ?(r)
sum is finite and rational.  The pattern of + and - in the terms gives runs
of bits the same as the N values in the Stern-Brocot tree.  The
RationalsTree code can calculate the ?(r) function by

    rational r=X/Y
    N = xy_to_n(X,Y) tree_type=>"SB"
    depth = floor(log2(N))       # row containing N (depth=0 at top)
    Ndepth = 2^depth             # start of row containing N

           2*(N-Ndepth) + 1
    ?(r) = ----------------
                Ndepth

The effect of N-Ndepth is to remove the high 1-bit, leaving an offset into
the row.  2*(..)+1 appends an extra 1-bit at the end.  The division by
Ndepth scales down from integer N to a fraction.

    N    = 1abcdef      integer, in binary
    ?(r) = a.bcdef1     binary fraction

For example ?(2/3) is X=2,Y=3 which is N=5 in the SB tree.  It is at
depth=2, Ndepth=2^2=4, and so ?(2/3)=(2*(5-4)+1)/4=3/4.  Or written in
binary N=101 gives Ndepth=100 and N-Ndepth=01 so 2*(N-Ndepth)+1=011 and
divide by Ndepth=100 for ?=0.11.

In practice this is not a very efficient way to handle the question
function, since the bit runs in the N values may become quite large for
relatively modest fractions.  (L<Math::ContinuedFraction> may be better, and
also allows repeating terms from quadratic irrationals to be represented
exactly.)

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over

=item C<$path = Math::PlanePath::RationalsTree-E<gt>new ()>

=item C<$path = Math::PlanePath::RationalsTree-E<gt>new (tree_type =E<gt> $str)>

Create and return a new path object.  C<tree_type> (a string) can be

    "SB"      Stern-Brocot
    "CW"      Calkin-Wilf
    "AYT"     Andreev, Yu-Ting
    "HCS"
    "Bird"
    "Drib"
    "L"

=item C<$n = $path-E<gt>n_start()>

Return the first N in the path.  This is 1 for SB, CW, AYT, HCS, Bird and
Drib, but 0 for L.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

Return a range of N values which occur in a rectangle with corners at
C<$x1>,C<$y1> and C<$x2>,C<$y2>.  The range is inclusive.

For reference, C<$n_hi> can be quite large because within each row there's
only one new X/1 integer and 1/Y fraction.  So if X=1 or Y=1 is included
then roughly C<$n_hi = 2**max(x,y)>.  If min(x,y) is bigger than 1 then it
reduces a little to roughly 2**(max/min + min).

=back

=head2 Tree Methods

X<Complete binary tree>Each point has 2 children, so the path is a complete
binary tree.

=over

=item C<@n_children = $path-E<gt>tree_n_children($n)>

Return the two children of C<$n>, or an empty list if C<$n E<lt> 1>
(ie. before the start of the path).

This is simply C<2*$n, 2*$n+1>.  Written in binary the children are C<$n>
with an extra bit appended, a 0-bit or a 1-bit.

=item C<$num = $path-E<gt>tree_n_num_children($n)>

Return 2, since every node has two children.  If C<$nE<lt>1>, ie. before the
start of the path, then return C<undef>.

=item C<$n_parent = $path-E<gt>tree_n_parent($n)>

Return the parent node of C<$n>.  Or return C<undef> if C<$n E<lt>= 1> (the
top of the tree).

This is simply Nparent = floor(N/2), ie. strip the least significant bit
from C<$n>.  (Undo what C<tree_n_children()> appends.)

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

=head2 Tree Descriptive Methods

=over

=item C<$num = $path-E<gt>tree_num_children_minimum()>

=item C<$num = $path-E<gt>tree_num_children_maximum()>

Return 2 since every node has 2 children so that's both the minimum and
maximum.

=item C<$bool = $path-E<gt>tree_any_leaf()>

Return false, since there are no leaf nodes in the tree.

=back

=head1 OEIS

The trees are in Sloane's Online Encyclopedia of Integer Sequences in
various forms,

    http://oeis.org/A007305   (etc)

    tree_type=SB
      A007305   X, Farey fractions (extra 0,1)
      A047679   Y
      A007306   X+Y sum, Farey 0 to 1 part (extra 1,1)
      A153036   int(X/Y), integer part
      A088696  length of continued fraction SB left half (X/Y<1)

    tree_type=CW
      A002487   X and Y, Stern diatomic sequence (extra 0)
      A070990   Y-X diff, Stern diatomic first diffs (less 0)
      A070871   X*Y product
      A007814   int(X/Y), integer part, count trailing 1-bits
                  which is count trailing 0-bits of N+1
      A086893   N position of Fibonacci F[n+1]/F[n], N = binary 1010..101
      A061547   N position of Fibonacci F[n]/F[n+1], N = binary 11010..10

    tree_type=AYT
      A020650   X
      A020651   Y (Kepler numerator)
      A086592   X+Y sum (Kepler denominator)
      A135523   int(X/Y), integer part,
                   count trailing 0-bits plus 1 extra if N=2^k

    tree_type=HCS
      A071585   X+Y sum (X+Y giving rationals >= 1)
      A071766   Y

    tree_type=Bird
      A162909   X
      A162910   Y
      A081254   N of row Y=1,    N = binary 1101010...10
      A000975   N of column X=1, N = binary  101010...10

    tree_type=Drib
      A162911   X
      A162912   Y
      A086893   N of row Y=1,    N = binary 1101010...101
      A000975   N of column X=1, N = binary  101010..1010

    tree_type=L
      A174981   X
      A002487   Y, same as CW X,Y, Stern diatomic

    A000523  tree_n_to_depth(), being floor(log2(N))

    A059893  permutation SB<->CW, AYT<->HCS, Bird<->Drib
               reverse bits below highest
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
