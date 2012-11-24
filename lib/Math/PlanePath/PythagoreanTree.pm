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



# Maybe
# @EXPORT_OK = ('ab_to_pq','pq_to_ab');
#
# =item C<($p,$q) = Math::PlanePath::PythagoreanTree::ab_to_pq($a,$b)>
#
# Return the P,Q coordinates for C<$a,$b>.  As described above this is
#
#     P = sqrt((C+A)/2)    where C=sqrt(A^2+B^2)
#     Q = sqrt((C-A)/2)
#
# The returned P,Q are integers PE<gt>=0,QE<gt>=0, but the further
# conditions for the path (namely PE<gt>QE<gt>=1 and no common factor) are
# not enforced.
#
# If P,Q are not integers or if BE<lt>0 then return an empty list.  This
# ensures A,B is a Pythagorean triple, ie. that C=sqrt(A^2+B^2) is an
# integer, but it might not be a primitive triple and might not have A odd B
# even.
#
# =item C<($a,$b) = Math::PlanePath::PythagoreanTree::pq_to_ab($p,$q)>
#
# Return the A,B coordinates for C<$p,$q>.  This is simply
#
#     $a = $p*$p - $q*$q
#     $b = 2*$p*$q
#
# This is intended for use with C<$p,$q> satisfying PE<gt>QE<gt>=1 and no
# common factor, but that's not enforced.


# math-image --path=PythagoreanTree --all --scale=3

# Daniel Shanks. Solved and Unsolved Problems in Number Theory, pp. 121 and
# 141, 1993.
#     http://books.google.com.au/books?id=KjhM9pZEGCkC&lpg=PR1&dq=Solved%20and%20Unsolved%20Problems%20in%20Number%20Theory&pg=PA122#v=onepage&q&f=false
#
# Euclid Book X prop 28,29 that u,v makes a triple, maybe Babylonians
#
# http://www.math.uconn.edu/~kconrad/blurbs/ugradnumthy/pythagtriple.pdf
#
# http://www.fq.math.ca/Scanned/30-2/waterhouse.pdf
# Continued fractions.
#
# http://www.math.ou.edu/~dmccullough/teaching/pythagoras1.pdf
# http://www.math.ou.edu/~dmccullough/teaching/pythagoras2.pdf
#
# B. Berggren 1934, "Pytagoreiska trianglar", Tidskrift
# for elementar matematik, fysik och kemi 17 (1934): 129-139.
#
# http://arxiv.org/abs/math/0406512
# http://www.mendeley.com/research/dynamics-pythagorean-triples/
#    Dan Romik
#
# Biscuits of Number Theory By Arthur T. Benjamin
#    Reproducing Hall, "Genealogy of Pythagorean Triads" 1970
#
# http://www.math.sjsu.edu/~alperin/Pythagoras/ModularTree.html
# http://www.math.sjsu.edu/~alperin/pt.pdf
#
# http://oai.cwi.nl/oai/asset/7151/7151A.pdf
#
# http://arxiv.org/abs/0809.4324
#
# http://www.math.ucdavis.edu/~romik/home/Publications_files/pythrevised.pdf
#
# http://www.microscitech.com/pythag_eigenvectors_invariants.pdf
#


package Math::PlanePath::PythagoreanTree;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 93;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'round_down_pow',
  'digit_split_lowtohigh';

# uncomment this to run the ### lines
#use Smart::Comments;

use constant class_x_negative => 0;
use constant class_y_negative => 0;

use constant parameter_info_array =>
  [ { name            => 'tree_type',
      share_key       => 'tree_type_uadfb',
      display         => 'Tree Type',
      type            => 'enum',
      default         => 'UAD',
      choices         => ['UAD','FB'],
      choices_display => ['UAD','FB'],
    },
    { name            => 'coordinates',
      share_key       => 'coordinates_abpq',
      display         => 'Coordinates',
      type            => 'enum',
      default         => 'AB',
      choices         => ['AB','PQ'], # 'Octant'
      choices_display => ['AB','PQ'], # 'Octant'
    },
  ];

{
  my %x_minimum = (PQ => 2,
                   AB => 3,
                   BA => 4,
                  );
  sub x_minimum {
    my ($self) = @_;
    return $x_minimum{$self->{'coordinates'}};
  }
}
{
  my %y_minimum = (PQ => 1,
                   AB => 4,
                   BA => 3,
                  );
  sub y_minimum {
    my ($self) = @_;
    return $y_minimum{$self->{'coordinates'}};
  }
}

#------------------------------------------------------------------------------

sub new {
  my $class = shift;
  my $self = $class->SUPER::new (@_);
  $self->{'tree_type'} ||= 'UAD';
  $self->{'coordinates'} ||= 'AB';
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### PythagoreanTree n_to_xy(): $n

  if ($n < 1) { return; }
  if (is_infinite($n)) { return ($n,$n); }

  {
    my $int = int($n);
    if ($n != $int) {
      my $frac = $n - $int;  # inherit possible BigFloat/BigRat
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
  }

  # @digits list of ternary digits 0,1,2 which are the position of $n within
  # its row of the tree.  This is like a mixed-radix form where the high
  # digit is binary (and so always 1, and not in @digits) and the rest are
  # ternary.
  #
  # h = 2*(n-1)+1 = 2*n-2+1 = 2*n-1
  # rowstart = (range-1)/2+1
  #
  my ($len, $level) = round_down_pow (2*$n-1, 3);

  ### h: 2*$n-1
  ### $level
  ### $len
  ### base: ($len + 1)/2
  ### rem n: $n - ($len + 1)/2

  my @digits = digit_split_lowtohigh ($n - ($len+1)/2,  3);
  $#digits = $level-1;   # pad to $level with undefs
  ### @digits

  my $q = 1;
  my $p = 2;

  if ($self->{'tree_type'} eq 'UAD') {
    ### UAD
    foreach my $digit (reverse @digits) {  # high to low, possibly $digit=undef
      ### $p
      ### $q
      ### $digit

      if ($digit) {
        if ($digit == 1) {
          ($p,$q) = (2*$p+$q, $p);      # (2p+q, p)
        } else {
          $p += 2*$q;                   # (p+2q, q)
        }
      } else {
        # $digit==0, or undef when small
        ($p,$q) = (2*$p-$q, $p);        # (2p-q, p)
      }
    }
  } else {
    ### FB
    foreach my $digit (reverse @digits) {  # high to low, possibly $digit=undef
      ### $p
      ### $q
      ### $digit

      if ($digit) {
        if ($digit == 1) {
          $q = $p-$q;                   # (2p, p-q)
          $p *= 2;
        } else {
          # ($q,$p) = ($p+$q, 2*$p);
          $q += $p;                     # (2p, p+q)
          $p *= 2;
        }
      } else {
        # $digit == 0
        # ($q,$p) = (2*$q, $p+$q);
        $p += $q;                       # (p+q, 2q)
        $q *= 2;
      }
    }
  }

  ### final
  ### $p
  ### $q

  if ($self->{'coordinates'} eq 'PQ') {
    return ($p,$q);
  }

  my ($a,$b) = _pq_to_ab($p,$q);
  if ($self->{'coordinates'} eq 'BA'
      || ($self->{'coordinates'} eq 'Octant' && $a < $b)) {
    return ($b,$a);
  } else {
    return ($a,$b);
  }
}

# (3*pow+1)/2 - (pow+1)/2
#     = (3*pow + 1 - pow - 1)/2
#     = (2*pow)/2
#     = pow
#
sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = round_nearest ($x);
  $y = round_nearest ($y);
  ### PythagoreanTree xy_to_n(): "$x, $y"

  my ($p, $q);
  if ($self->{'coordinates'} eq 'PQ') {
    $p = $x;
    $q = $y;
  } else {
    if ($self->{'coordinates'} eq 'Octant' && $y > $x) {
      return undef;
    }
    if ($self->{'coordinates'} eq 'BA'
        || ($self->{'coordinates'} eq 'Octant' && ($y&1))) {
      ($x,$y) = ($y,$x);
    }

    ($p,$q) = _ab_to_pq($x,$y)
      or return undef;    # if not a pythagorean A,B
  }

  if (is_infinite($p)) {
    return $p;  # infinity
  }
  if (is_infinite($q)) {
    return $q;  # infinity
  }
  if ($p < 1 || $q < 1           # must be positive
      || ($p % 2) == ($q % 2)) { # must be opposite parity
    return undef;
  }

  my $power = 1;
  my $n = 1;
  if ($self->{'tree_type'} eq 'UAD') {
    for (;;) {
      ### $p
      ### $q
      if ($q <= 0 || $p <= 0 || $p <= $q) {
        return undef;
      }
      last if $q <= 1 && $p <= 2;

      if ($p > 2*$q) {
        $n += $power;
        if ($p > 3*$q) {
          ### digit 2
          $n += $power;
          $p -= 2*$q;
        } else {
          ### digit 1
          ($p,$q) = ($q, $p - 2*$q);
        }

      } else {
        ### digit 0
        ($q,$p) = (2*$q-$p, $q);
      }
      ### descend: "$q / $p"
      $n += $power;  # step the base
      $power *= 3;
    }

  } else {
    for (;;) {
      if ($q <= 0 || $p <= 0) {
        return undef;
      }
      last if $q <= 1 && $p <= 2;

      if ($q % 2) {
        # q odd, p even
        $p /= 2;
        $n += $power; # digit 1 or 2
        if ($q > $p) {
          $q = $q - $p;  # opp parity of p, and < new p
          $n += $power;  # digit 2
        } else {
          $q = $p - $q;  # opp parity of p, and < p
        }
      } else {
        # q even, p odd
        $q /= 2;
        $p -= $q;  # opp parity of q
      }
      ### descend: "$q / $p"
      $n += $power;  # step the base
      $power *= 3;
    }
  }

  ### base: ($power+1)/2
  ### $n
  return $n;
}


# numprims(H) = how many with hypot < H
# limit H->inf  numprims(H) / H -> 1/2pi
#
# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### PythagoreanTree rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = round_nearest ($x1);
  $y1 = round_nearest ($y1);
  $x2 = round_nearest ($x2);
  $y2 = round_nearest ($y2);

  my $zero = ($x1 * 0 * $y1 * $x2 * $y2);  # inherit bignum

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### x2: "$x2"
  ### y2: "$y2"

  if ($self->{'coordinates'} eq 'BA') {
    ($x2,$y2) = ($y2,$x2);
  }
  if ($self->{'coordinates'} eq 'Octant') {
    if ($x2 > $y2) {   # both max
      $y2 = $x2;
    } else {
      $x2 = $y2;
    }
  }

  if ($self->{'coordinates'} eq 'PQ') {
    if ($x2 < 2 || $y2 < 1) {
      return (1,0);
    }
    # P > Q so reduce y2 to at most x2-1
    if ($y2 >= $x2) {
      $y2 = $x2-1;    # $y2 = min ($y2, $x2-1);
    }

    if ($y2 < $y1) {
      ### PQ y range all above X=Y diagonal ...
      return (1,0);
    }
  } else {
    # AB
    if ($x2 < 3 || $y2 < 0) {
      return (1,0);
    }
  }

  my $level;
  if ($self->{'tree_type'} eq 'UAD') {
    ### UAD
    if ($self->{'coordinates'} eq 'PQ') {
      ### PQ
      $level = $x2+1;
    } else {
      my $xlevel = int (($x2+1) / 2);
      my $ylevel = int (($y2+31) / 4);
      $level = ($xlevel < $ylevel ? $xlevel : $ylevel);  # min(xlevel,ylevel)
    }
  } else {
    ### FB
    if ($self->{'coordinates'} eq 'PQ') {
      $x2 *= 3;
    }
    $x2--;
    for (my $k = 1; ; $k++) {
      if ($x2 <= (3 * 2**$k + 1)) {
        $level = 2*$k+1;
        last;
      }
      if ($x2 <= (2**($k+2)) + 1) {
        $level = 2*$k+2;
        last;
      }
    }
  }
  ### level: "$level"
  return (1, ((3+$zero)**$level - 1) / 2);
}

sub tree_n_children {
  my ($self, $n) = @_;
  unless ($n >= 1) {
    return;
  }
  $n *= 3;
  return ($n-1, $n, $n+1);
}
sub tree_n_num_children {
  my ($self, $n) = @_;
  return ($n >= 1 ? 3 : undef);
}
sub tree_n_parent {
  my ($self, $n) = @_;
  unless ($n >= 2) {
    return undef;
  }
  return int(($n+1)/3);
}
sub tree_n_to_depth {
  my ($self, $n) = @_;
  ### PythagoreanTree tree_n_to_depth(): $n
  unless ($n >= 1) {
    return undef;
  }
  my ($len, $level) = round_down_pow (2*$n-1, 3);
  return $level;
}
sub tree_depth_to_n {
  my ($self, $depth) = @_;
  return ($depth >= 0 ? (3**$depth + 1)/2 : undef);
}
# (3^(d+1)+1)/2-1 = (3^(d+1)-1)/2
sub tree_depth_to_n_end {
  my ($self, $depth) = @_;
  return ($depth >= 0 ? (3**($depth+1) - 1)/2 : undef);
}

#------------------------------------------------------------------------------

# a=p^2-q^2, b=2pq
# Done as a=(p-q)*(p+q) for one multiply instead of two squares, and to work
# close to a=UINT_MAX.
#
sub _pq_to_ab {
  my ($p, $q) = @_;
  return (($p-$q)*($p+$q), 2*$p*$q);
}

# a = p^2 - q^2
# b = 2pq
# c = p^2 + q^2
#
# q = b/2p
# a = p^2 - (b/2p)^2
#   = p^2 - b^2/4p^2
# 4ap^2 = 4p^4 - b^2
# 4(p^2)^2 - 4a*p^2 - b^2 = 0
# p^2 = [ 4a +/- sqrt(16a^2 + 16*b^2) ] / 2*4
#     = [ a +/- sqrt(a^2 + b^2) ] / 2
#     = (a +/- c) / 2   where c=sqrt(a^2+b^2)
# p = sqrt((a+c)/2)    since c>a
#
# a = (a+c)/2 - q^2
# q^2 = (a+c)/2 - a
#     = (c-a)/2
# q = sqrt((c-a)/2)
#
# if c^2 = a^2+b^2 is a perfect square then a,b,c is a pythagorean triple
# p^2 = (a+c)/2
#     = (a + sqrt(a^2+b^2))/2
# 2p^2 = a + sqrt(a^2+b^2)
#
# p>q so a>0
# a+c even is a odd, c odd or a even, c even
# if a odd then c=a^2+b^2 is opp of b parity, must have b even to make c+a even
# if a even then c=a^2+b^2 is same as b parity, must have b even to c+a even
#
# a=6,b=8 is c=sqrt(6^2+8^2)=10
# a=0,b=4 is c=sqrt(0+4^4)=4 p^2=(a+c)/2 = 2 not a square
# a+c even, then (a+c)/2 == 0,1 mod 4 so a+c==0,2 mod 4
# 
sub _ab_to_pq {
  my ($a, $b) = @_;
  ### _ab_to_pq(): "A=$a, B=$b"

  unless ($b >= 0) {
    ### B is negative ...
    return;
  }

  # This used to be $c=hypot($a,$b) and check $c==int($c), but libm hypot()
  # on Darwin 8.11.0 is somehow a couple of bits off being an integer, for
  # example hypot(57,176)==185 but a couple of bits out so $c!=int($c).
  # Would have thought hypot() ought to be exact on integer inputs and a
  # perfect square sum :-(.  Check for a perfect square by multiplying back
  # instead.
  #
  # The condition is "$csquared != $c*$c" with operands that way around
  # since the other way is bad for Math::BigInt::Lite 0.14.
  #
  my $c;
  {
    my $csquared = $a*$a + $b*$b;
    $c = int(sqrt($csquared));
    ### $csquared
    ### $c
    if ($csquared != $c*$c) {
      return;
    }
  }

  # B even means C^2 is same parity as A and so C+A is even
  ### assert: ! ($c < $a)
  ### assert: $c+1==$c || (($c+$a) % 2) == 0

  my $p;
  {
    # If a,b is a triple but not primitive then can have psquared not an
    # integer.  Eg. a=9,b=12 has c=15 giving psquared=(9+15)/2=12 is not a
    # perfect square.  So notice that here.
    #
    my $psquared = ($c+$a)/2;
    $p = int(sqrt($psquared));
    ### $psquared
    ### $p
    if ($psquared != $p*$p) {
      return;
    }
  }

  my $q;
  {
    # If a,b is a triple but not primitive then can have qsquared not an
    # integer.  Eg. a=15,b=36 has c=39 giving qsquared=(39-15)/2=12 is not a
    # perfect square.  So notice that here.
    #
    my $qsquared = ($c-$a)/2;
    $q = int(sqrt($qsquared));
    ### $qsquared
    ### $q
    if ($qsquared != $q*$q) {
      return;
    }
  }

  # Might have a common factor between P,Q here.  Eg.
  #     A=27 = 3*3*3, B=36 = 4*3*3
  #     A=45 = 3*3*5, B=108 = 4*3*3*3
  #     A=63, B=216
  #     A=75 =3*5*5  B=100 = 4*5*5
  #     A=81, B=360

  return ($p, $q);
}

1;
__END__



  # my $a = 1;
  # my $b = 1;
  # my $c = 2;
  # my $d = 3;

    # ### at: "$a,$b,$c,$d   digit $digit"
    # if ($digit == 0) {
    #   ($a,$b,$c) = ($a,2*$b,$d);
    # } elsif ($digit == 1) {
    #   ($a,$b,$c) = ($d,$a,2*$c);
    # } else {
    #   ($a,$b,$c) = ($a,$d,2*$c);
    # }
    # $d = $b+$c;
  #   ### final: "$a,$b,$c,$d"
  # #  print "$a,$b,$c,$d\n";
  #   my $x = $c*$c-$b*$b;
  #   my $y = 2*$b*$c;
  #   return (max($x,$y), min($x,$y));

  # return $x,$y;




=for stopwords eg Ryde UAD FB Berggren Barning ie PQ parameterized parameterization Math-PlanePath someP someQ Q's octant coprime mixed-radix

=head1 NAME

Math::PlanePath::PythagoreanTree -- primitive Pythagorean triples by tree

=head1 SYNOPSIS

 use Math::PlanePath::PythagoreanTree;
 my $path = Math::PlanePath::PythagoreanTree->new
              (tree_type => 'UAD',
               coordinates => 'AB');
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path enumerates primitive Pythagorean triples by a breadth-first
traversal of a ternary tree, either a "UAD" or "FB" tree.  Each point is an
integer X,Y=A,B with an integer hypotenuse, and primitive in the sense that
A and B have no common factor.

     A^2 + B^2 = C^2
     gcd(A,B)=1  ie. no common factor

Such a triple always has one of A,B odd and the other even.  The trees here
give them ordered as A odd and B even.

The breadth-first traversal goes out to rather large A,B values while
smaller ones have yet to be reached.  The UAD tree goes out further than the
FB.

=head2 UAD Tree

The UAD tree by Berggren (1934) and later independently by Barning (1963),
Hall (1970), and a number of others, uses three matrices U, A and D which
can be multiplied onto an existing primitive triple to form three new
primitive triples.  See L</UAD Matrices> below for details of the tree
descent.

    tree_type => "UAD"   (the default

    Y=40 |          14
         |
         |
         |
         |                                              7
    Y=24 |        5
         |
    Y=20 |                      3
         |
    Y=12 |      2                             13
         |
         |                4
     Y=4 |    1
         |
         +--------------------------------------------------
            X=3         X=15  X=20           X=35      X=45

The starting point is N=1 at X=3,Y=4 which is the well-known 3^2 + 4^2 =
5^2.  From there further N=2, N=3, N=4 are derived, then three more from
each of those, etc,

     N=1     N=2..4      N=5..13     N=14...

                      +-> 7,24
          +-> 5,12  --+-> 55,48
          |           +-> 45,28
          |
          |           +-> 39,80
    3,4 --+-> 21,20 --+-> 119,120
          |           +-> 77,36
          |
          |           +-> 33,56
          +-> 15,8  --+-> 65,72
                      +-> 35,12

Counting the N=1 point as level 1, each level has 3^(level-1) many points
and the first N of the level is at

    Nstart = 1 + 3 + 3^2 + ... + 3^(level-1)
           = (3^level + 1) / 2

These levels are like a mixed-radix representation of N where the high digit
is binary, and so since the high is non-zero thus always 1, and further
digits below in ternary.  The number of digits is the level and the ternary
digits are the position within the level.

N=1,3,9,27,etc 3^level is the middle "A" matrix at each node, giving 3,4
then 21,20 then 119,120 then 697,696, etc, which are the triples with legs
differing by 1, and thus just below the X=Y leading diagonal.

Taking the lower "D" matrix at each node, ie. 3,4 to 15,8 to 35,12 to 63,16,
etc, is the primitives among a sequence of triples known to the ancients,

     A = k^2-1,  B = 2*k,  C = k^2+1

When k is even these are primitive.  (If k is odd then A and B are both
even, ie. a common factor of 2, so not primitive.)  These points are the
last of each level, so N=(3^(level+1)-1)/2.

=head2 FB Tree

The FB tree by H. Lee Price

    "The Pythagorean Tree: A New Species", 2008
    http://arxiv.org/abs/0809.4324

is based on expressing triples in certain "Fibonacci boxes" with a box of
four values q',q,p,p' having p=q+q' and p'=p+q, each the sum of the
preceding two in a fashion similar to the Fibonacci sequence.  Any box where
p and q have no common factor corresponds to a primitive triple (see L</PQ
Coordinates> below).

    tree_type => "FB"

    Y=40 |         5
         |
         |
         |
         |                                             17
    Y=24 |       4
         |
         |                     8
         |
    Y=12 |     2                             6
         |
         |               3
    Y=4  |   1
         |
         +----------------------------------------------
           X=3         X=15   x=21         X=35

For a given box three transformations can be applied to go to new boxes
corresponding to new primitive triples.  This visits all and only primitive
triples, but in a different order and different tree structure to the UAD
above.

The first point N=1 is again at X=3,Y=4, from which three further points
N=2,3,4 are derived, then three more from each of those, etc.

    N=1      N=2..4      N=5..13     N=14...

                      +-> 9,40
          +-> 5,12  --+-> 35,12
          |           +-> 11,60
          |
          |           +-> 21,20
    3,4 --+-> 15,8  --+-> 55,48
          |           +-> 39,80
          |
          |           +-> 13,84
          +-> 7,24  --+-> 63,16
                      +-> 15,112

=head2 PQ Coordinates

Primitive Pythagorean triples can be parameterized as follows, for A odd and
B even.

    A = P^2 - Q^2
    B = 2*P*Q
    C = P^2 + Q^2
    with P > Q >= 1, one odd, one even, and no common factor

Or conversely,

    P = sqrt((C+A)/2)
    Q = sqrt((C-A)/2)

The first P=2,Q=1 is the triple A=3,B=4,C=5.  The C<coordinates> option on
the path gives these P,Q values as the returned X,Y (for either tree type),
Since PE<gt>QE<gt>=1, the values fall in the eighth of the plane below the
X=Y diagonal,

    coordinates => "PQ"

    11 |                         *
    10 |                       *  
     9 |                     *    
     8 |                   *   *  
     7 |                 *   *   *
     6 |               *       *  
     5 |             *   *       *
     4 |           *   *   *   *  
     3 |         *       *   *    
     2 |       *   *   *   *   *  
     1 |     *   *   *   *   *   *
     0 |
       +------------------------
         0 1 2 3 4 5 6 7 8 9 ...

The correspondence between P,Q and A,B means the trees visit all P,Q pairs
with no common factor and one of them even.  There's other ways to iterate
through such coprime pairs P,Q, and that would generate triples too, in a
different order from the trees here.

Incidentally letters P and Q used here are a little bit arbitrary.  This
parameterization is often found as m,n or u,v, but don't want "n" to be
confused that with the N point numbering or "u" confused with the U matrix
in UAD.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::PythagoreanTree-E<gt>new ()>

=item C<$path = Math::PlanePath::PythagoreanTree-E<gt>new (tree_type =E<gt> $str, coordinates =E<gt> $str)>

Create and return a new path object.  The C<tree_type> option can be

    "UAD"  (the default)
    "FB"

The C<coordinates> option can be

    "AB"   (the default)
    "PQ"

=item C<$n = $path-E<gt>n_start()>

Return 1, the first N in the path.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 1 and if C<$nE<lt>1> then the return is an empty list.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  If there's nothing at
C<$x,$y> then return C<undef>.

The return is C<undef> if C<$x,$y> is not a primitive Pythagorean triple, or
for the PQ option if C<$x,$y> doesn't satisfy the PQ constraints described
above (L</PQ Coordinates>).

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

Return a range of N values which occur in a rectangle with corners at
C<$x1>,C<$y1> and C<$x2>,C<$y2>.  The range is inclusive.

Both trees go off into large X,Y coordinates while yet to finish values
close to the origin which means the N range for a rectangle can be quite
large.  For UAD C<$n_hi> is roughly C<3**max(x/2)>, or for FB smaller at
roughly C<3**log2(x)>.

=back

=head2 Tree Methods

=over

=item C<@n_children = $path-E<gt>tree_n_children($n)>

Return the three children of C<$n>, or an empty list if C<$n E<lt> 1>
(ie. before the start of the path).

This is simply C<3*$n-1, 3*$n, 3*$n+1>.  This is like appending an extra
ternary digit to go to the next level, but onto N+1 rather than N and then
adjusting back.

=item C<$num = $path-E<gt>tree_n_num_children($n)>

Return 3, since every node has three children, or return C<undef> if
C<$nE<lt>1> (ie. before the start of the path).

=item C<$n_parent = $path-E<gt>tree_n_parent($n)>

Return the parent node of C<$n>, or C<undef> if C<$n E<lt>= 1> (the top of
the tree).

This is simply C<floor(($n+1)/3)>, reversing the C<tree_n_children()>
calculation.

=item C<$depth = $path-E<gt>tree_n_to_depth($n)>

Return the depth of node C<$n>, or C<undef> if there's no point C<$n>.  The
top of the tree at N=1 is depth=0, then its children depth=1, etc.

The structure of the tree with 3 nodes per point means the depth is
floor(log3(2N-1)), so for example N=5 through N=13 all have depth=2.

=item C<$n = $path-E<gt>tree_depth_to_n($depth)>

=item C<$n = $path-E<gt>tree_depth_to_n_end($depth)>

Return the first or last N at tree level C<$depth> in the path, or C<undef>
if nothing at that depth or not a tree.  The top of the tree is depth=0.

=back

=head1 FORMULAS

=head2 UAD Matrices

The UAD matrices are

        /  1   2   2  \
    U = | -2  -1  -2  |
        \  2   2   3  /

        /  1   2   2  \
    A = |  2   1   2  |
        \  2   3   3  /

        / -1  -2  -2  \
    D = |  2   1   2  |
        \  2   2   3  /

They're multiplied on the right of an (A,B,C) vector, for example

    (3, 4, 5) * U = (5, 12, 13)

Internally the code uses P,Q and calculates an A,B at the end as necessary.
The UAD transformations in P,Q coordinates are

    U     P -> 2P-Q
          Q -> P

    A     P -> 2P+Q
          Q -> P

    D     P -> P+2Q
          Q -> Q unchanged

The advantage of P,Q for the calculation is that it's 2 values instead of 3.
The transformations could be written as 2x2 matrix multiplications if
desired, but explicit steps are enough for the code.

=head2 FB Transformations

The FB tree is calculated in P,Q and converted to A,B at the end as
necessary.  Its three transformations are

    K1     P -> P+Q
           Q -> 2Q

    K2     P -> 2P
           Q -> P-Q

    K3     P -> 2P
           Q -> P+Q

Price's paper shows rearrangements of a set of four values q',q,p,p', but
just the p and q are enough for the calculation.

=head2 X,Y to N -- UAD

C<xy_to_n()> works in P,Q coordinates and converts an A,B input.  A P,Q
point can be reversed up the UAD tree to its parent point

    if P > 3Q    reverse "D"   P -> P-2Q
                               Q -> unchanged
    if P > 2Q    reverse "A"   P -> Q
                               Q -> P-2Q
    otherwise    reverse "U"   P -> Q
                               Q -> 2Q-P

This gives a ternary digit 2, 1, 0 respectively for N (low to high), plus a
high "1" digit.  The number of steps is the level.

If at any stage P,Q doesn't satisfy PE<gt>Q, one odd, the other even, then
it means the original point, whether it was an A,B or a P,Q, was not a
primitive triple.  For a primitive triple the endpoint is always P=2,Q=1.

=head2 X,Y to N -- FB

After converting A,B to P,Q if necessary, a P,Q point can be reversed up the
FB tree to its parent

    if P odd     reverse K1    P -> P-Q
     (so Q even)               Q -> Q/2

    if Q < P/2   reverse K2    P -> P/2
                               Q -> P/2 - Q

    otherwise    reverse K3    P -> P/2
                               Q -> Q - P/2

This is a little like the binary greatest common divisor algorithm, but
designed for one value odd and the other even.  Like the UAD ascent above,
if at any stage P,Q doesn't satisfy PE<gt>Q, one odd, the other even, then
the initial point wasn't a primitive triple.

=head2 Rectangle to N Range -- UAD

For the UAD tree, the smallest A,B within each level is found at the topmost
"U" steps for the smallest A or the bottom-most "D" steps for the smallest
B.  For example in the table above of level=2 N=5..13 the smallest A is
the top A=7,B=24, and the smallest B is in the bottom A=35,B=12.  In general

    Amin = 2*level + 1
    Bmin = 4*level

In P,Q coordinates the same topmost line is the smallest P and bottom-most
the smallest Q.  The values are

    Pmin = level+1
    Qmin = 1

The fixed Q=1 arises from the way the "D" transformation sends Q-E<gt>Q
unchanged, so every level includes a Q=1.  This means if you ask what range
of N is needed to cover all Q E<lt> someQ then there isn't one, only a P
E<lt> someP has an N to go up to.

=head2 Rectangle to N Range -- FB

For the FB tree, the smallest A,B within each level is found in the topmost
two final positions.  For example in the table above of level=2 N=5..13 the
smallest A is in the top A=9,B=40, and the smallest B is in the next row
A=35,B=12.  In general,

    Amin = 2^level + 1
    Bmin = 2^level + 4

In P,Q coordinates a Q=1 is found in that second row which is the minimum B,
and the smallest P is found by taking K1 steps half-way then a K2 step, then
K1 steps for the balance.  This is a slightly complicated

    Pmin = /  3*2^(k-1) + 1    if even level = 2*k
           \  2^(k+1) + 1      if odd level = 2*k+1
    Q = 1

The fixed Q=1 arises from the K1 steps giving

    P = 2 + 1+2+4+8+...+2^(level-2)
      = 2 + 2^(level-1) - 1
      = 2^(level-1) + 1
    Q = 2^(level-1)

    followed by K2 step
    Q -> P-Q
         = 1

As for the UAD above this means small Q's always remain no matter how big N
gets, only a P range determines an N range.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::Hypot>,
L<Math::PlanePath::RationalsTree>,
L<Math::PlanePath::CoprimeColumns>

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
