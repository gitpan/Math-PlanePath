# Copyright 2011 Kevin Ryde

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
#
# http://www.math.ou.edu/~dmccullough/teaching/pythagoras1.pdf
# http://www.math.ou.edu/~dmccullough/teaching/pythagoras2.pdf
#
# B. Berggren 1934, "Pytagoreiska trianglar", Tidskrift
# for elementar matematik, fysik och kemi 17: 129-139.
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
use List::Util qw(min max);
use POSIX qw(floor ceil);
use Math::Libm 'hypot';

use vars '$VERSION', '@ISA';
$VERSION = 29;

use Math::PlanePath;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant x_negative => 0;
use constant y_negative => 0;

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

  if ($n < 1            # start at N=1
      || $n-1 == $n) {  # infinity
    return;
  }

  if (int($n) != $n) {
    my ($x1,$y1) = $self->n_to_xy(floor($n));
    my ($x2,$y2) = $self->n_to_xy(ceil($n));
    return (($x1+$x2)/2, ($y1+$y2)/2);
  }

  my $h = 2*($n-1)+1;
  my ($range, $level) = _round_down_pow3 ($h);
  my $base = ($range - 1)/2 + 1;
  my $rem = $n - $base;

  ### $n
  ### $h
  ### $level
  ### $range
  ### $base
  ### $rem

  my @digits;
  while ($level--) {
    push @digits, $rem%3;
    $rem = int($rem/3);
  }
  ### @digits

  my $q = 1;
  my $p = 2;

  if ($self->{'tree_type'} eq 'UAD') {
    ### UAD
    foreach my $digit (reverse @digits) {  # high digit first
      ### $p
      ### $q
      ### $digit
      if ($digit == 0) {
        ($p,$q) = (2*$p-$q, $p);
      } elsif ($digit == 1) {
        ($p,$q) = (2*$p+$q, $p);
      } else {
        $p += 2*$q;
      }
    }
  } else {
    ### FB
    foreach my $digit (reverse @digits) {  # high digit first
      ### $p
      ### $q
      ### $digit
      if ($digit == 0) {
        ($q,$p) = (2*$q, $p+$q);
      } elsif ($digit == 1) {
        ($q,$p) = ($p-$q, 2*$p);
      } else {
        ($q,$p) = ($p+$q, 2*$p);
      }
    }
  }

  ### final
  ### $p
  ### $q

  if ($self->{'coordinates'} eq 'PQ') {
    return ($p,$q);
  }

  my $a = $p*$p-$q*$q;
  my $b = 2*$p*$q;
  if ($self->{'coordinates'} eq 'BA'
      || ($self->{'coordinates'} eq 'Octant'
          && $a < $b)) {
    return ($b,$a);
  } else {
    return ($a,$b);
  }
}

# a = p^2 - q^2
# b = 2pq
# q = b/2p
# a = p^2 - (b/2p)^2
#   = p^2 - b^2/4p^2
# 4ap^2 = 4p^4 - b^2
# 4(p^2)^2 - 4a(p^2) - b^2 = 0
# p^2 = [ 4a +/- sqrt(16a^2 + 16*b^2) ] / 2*4
#     = [ a +/- sqrt(a^2 - b^2) ] / 2
#     = (a +/- c) / 2
# p = sqrt((a+c)/2)    since c>a
# a = (a+c)/2 - q^2
# q^2 = (a+c)/2 - a
#     = (c-a)/2
# q = sqrt((c-a)/2)
#
# (3*pow+1)/2 - (pow+1)/2
#     = (3*pow + 1 - pow - 1)/2
#     = (2*pow)/2
#     = pow
#
sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = floor($x + 0.5);
  $y = floor($y + 0.5);
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

    if (! ($x & 1) || ($y & 1)) {
      ### don't have A odd, B even: "$x, $y"
      return undef;
    }

    my $z = hypot ($x, $y);
    ### $z
    if (int($z) != $z || ! ($z & 1)) {
      return undef;
    }

    $p = sqrt(($z+$x)/2);
    ### p^2: ($z+$x)/2
    ### $p
    if ($p != int($p)) {
      return undef;
    }

    $q = sqrt(($z-$x)/2);
    ### $q
    if ($q != int($q)) {
      return undef;
    }
  }

  if ($p-1 == $p || $q-1 == $q  # infinity
      || $p < 1 || $q < 1       # negatives
      || ! (($p ^ $q) & 1)      # must be oppostite parity
     ) {
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

      if ($q & 1) {
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
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### rect_to_n_range()

  $x1 = floor($x1 + 0.5);
  $y1 = floor($y1 + 0.5);
  $x2 = floor($x2 + 0.5);
  $y2 = floor($y2 + 0.5);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### $x2
  ### $y2

  if ($self->{'coordinates'} eq 'BA') {
    ($x2,$y2) = ($y2,$x2);
  }
  if ($self->{'coordinates'} eq 'Octant') {
    $x2 = $y2 = max($x2,$y2);
  }

  if ($self->{'coordinates'} eq 'PQ') {
    if ($x2 < 2 || $y2 < 1) {
      return (1,0);
    }
    # P > Q so drop y2
    $y2 = min ($y2, $x2-1);
    if ($y2 < $y1) {
      ### PQ y range all above X=Y diagonal
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
      $level = min (int (($x2+1) / 2),
                    int (($y2+31) / 4));
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
  ### $level
  return (1, (3**$level - 1) / 2);
}

# return ($pow, $exp) with $pow = 3**$exp <= $n, the next power of 3 at or
# below $n
sub _round_down_pow3 {
  my ($n) = @_;
  my $exp = int(log($n)/log(3));
  my $pow = 3**$exp;

  # check how $pow actually falls against $n, not sure should trust float
  # rounding in log()/log(3)
  if ($pow > $n) {
    ### hmm, int(log) too big, decrease
    $exp--;
    $pow = 3**$exp;
  } elsif (3*$pow <= $n) {
    ### hmm, int(log) too small, increase
    $exp++;
    $pow *= 3;
  }
  return ($pow, $exp);
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




=for stopwords eg Ryde OEIS UAD FB Berggren Barning ie PQ parameterized parameterization Math-PlanePath

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
traversal of a ternary tree, either a "UAD" or "FB" tree.

Each point is an integer X,Y = A,B with integer hypotenuse A^2+B^2=C^2 and
primitive because A and B have no common factor.  Such a triple always has
one of A,B odd and the other even.  The trees here give them ordered as A
odd and B even.

The breadth-first traversal goes out to rather large A,B values while
smaller ones have yet to be reached.  The UAD tree goes out further than the
FB.

=head2 UAD Tree

The UAD tree by Berggren (1934) and later independently by Barning (1963),
Hall (1970), and a number of others, uses three matrices U, A and D which
can be multiplied onto an existing primitive triple to form three new
primitive triples.

    my $path = Math::PlanePath::PythagoreanTree->new
                 (tree_type => 'UAD');

Starting from A=3,B=4,C=5, the well-known 3^2 + 4^2 = 5^2, the tree visits
all and only primitive triples.

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

For the path the starting point N=1 is X=3,Y=4 and from it three further
N=2,3,4 are derived, then three more from each of those, etc,

     N=1     N=2..4      N=5..13    N=14...

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

    N = 1 + 3 + 3^2 + ... + 3^(level-1)
    N = (3^level + 1) / 2

Taking the middle "A" direction at each node, ie. 21,20 then 119,120 then
697,696, etc, gives the triples with legs differing by 1, so just below the
X=Y leading diagonal.  These are at N=3^level.

Taking the lower "D" direction at each node, ie. 15,8 then 35,12 then 63,16,
etc, is the primitives among a sequence of triples known to the ancients,

     A = k^2-1,  B = 2*k,  C = k^2+1

When k is even these are primitive.  (If k is odd then A and B are both
even, ie. a common factor of 2, so not primitive.)  These points are the
last of each level, so N=(3^(level+1)-1)/2.

=head2 FB Tree

The FB tree by H. Lee Price is based on expressing triples in certain
"Fibonacci boxes" with q',q,p,p' having p=q+q' and p'=p+q, each the sum of
the preceding two in a fashion similar to the Fibonacci sequence.  Any box
where p and q have no common factor corresponds to a primitive triple (see
L</PQ Coordinates> below).

    my $path = Math::PlanePath::PythagoreanTree->new
                 (tree_type => 'FB');

For a given box three transformations can be applied to go to new boxes
corresponding to new primitive triples.  This visits all and only primitive
triples, but in a different order and different tree structure to the UAD
above.

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

Primitive Pythagorean triples can be parameterized as follows, taking A odd
and B even.

    A = P^2 - Q^2,  B = 2*P*Q,  C = P^2 + Q^2
    with P>Q>=1, one odd, one even, and no common factor

And conversely,

    P = sqrt((C+A)/2),  Q = sqrt((C-A)/2)

The first P=2,Q=1 is the triple A=3,B=4,C=5.  The C<coordinates> option on
the path gives these P,Q values as the returned X,Y coordinates,

    my $path = Math::PlanePath::PythagoreanTree->new
                  (tree_type   => 'UAD',    # or 'FB'
                   coordinates => 'PQ');
    my ($p,$q) = $path->n_to_xy(1);  # P=2,Q=1

Since P>Q>=1, the values fall in an octant below the X=Y diagonal,

    11 |                      *
    10 |                    *  
     9 |                  *    
     8 |                *   *  
     7 |              *   *   *
     6 |            *       *  
     5 |          *   *       *
     4 |        *   *   *   *  
     3 |      *       *   *    
     2 |    *   *   *   *   *  
     1 |  *   *   *   *   *   *
       +------------------------
          2 3 4 5 6 7 8 9 ...

The correspondence between P,Q and A,B means the trees visit all P,Q pairs
with no common factor and one of them even.  Of course there's other ways to
iterate through such P,Q, such as simply P=2,3,etc, and which would generate
triples too, in a different order from the trees here.

Incidentally letters P and Q used here are a little bit arbitrary.  This
parameterization is often found as m,n or u,v, but don't want to confuse
that with the N numbered points or the U matrix in UAD.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::PythagoreanTree-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.  Integer positions are always just 1 apart either
horizontally or vertically, so the effect is that the fraction part appears
either added to or subtracted from X or Y.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  If there's nothing at
C<$x,$y> then return C<undef>.

The return is C<undef> if C<$x,$y> is not a primitive Pythagorean triple, or
with the PQ option if if C<$x,$y> doesn't satisfy the PQ constraints
described above (L</PQ Coordinates>).

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

Return a range of N values which occur in a rectangle with corners at
C<$x1>,C<$y1> and C<$x2>,C<$y2>.  The range is inclusive.

Both trees visit large X,Y coordinates while yet to finish values closer to
the origin which means the N range for a rectangle can be quite large.  For
UAD C<$n_hi> is roughly C<3**max(x/2)>, or for FB smaller at roughly
C<3**log2(x)>.

=back

=head1 FORMULAS

=head2 UAD Matrices

The three UAD matrices are as follows

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

But internally the code uses P,Q and calculates an A,B at the end as
necessary.  The transformations in P,Q coordinates are

    U     P -> 2P-Q
          Q -> P

    A     P -> 2P+Q
          Q -> P

    D     P -> P+2Q
          Q -> unchanged

The advantage of P,Q for the calculation is that it's 2 values instead of 3.
The transformations could be written as 2x2 matrix multiplications if
desired, but explicit steps are enough for the code.

=head2 FB Transformations

The FB tree is calculated in P,Q and an A,B calculated at the end.  The
three transformation are

    K1     P -> P+Q
           Q -> 2Q

    K2     P -> 2P
           Q -> P-Q

    K3     P -> 2P
           Q -> P+Q

Price's paper shows rearrangements of four values q',q,p,p', but just the p
and q are enough for a calculation.

=head2 X,Y to N for UAD

An A,B or P,Q point can be reversed up the tree to its parent as follows,

    if P > 3Q    reverse "D"   P -> P-2Q
                               Q -> unchanged
    if P > 2Q    reverse "A"   P -> Q
                               Q -> P-2Q
    otherwise    reverse "U"   P -> Q
                               Q -> 2Q-P

This gives a ternary digit 2, 1, 0 respectively for N and the number of
steps is the level and a starting N for the digits.  If at any stage the P,Q
aren't one odd the other even and PE<gt>Q then it means the original point,
either an A,B or a P,Q, was not a primitive triple.  For a primitive triple
the endpoint is always P=2,Q=1.

=head2 X,Y to N for FB

An A,B or P,Q point can be reversed up the tree to its parent as follows,

    if P odd     reverse K1    P -> P-Q
     (so Q even)               Q -> Q/2

    if Q < P/2   reverse K2    P -> P/2
                               Q -> P/2 - Q

    otherwise    reverse K3    P -> P/2
                               Q -> Q - P/2

This is rather similar to the binary greatest common divisor algorithm, but
designed for one value odd and the other even.  As for the UAD ascent above
if that opposite parity doesn't hold at any stage then the initial point
wasn't a primitive triple.

=head2 N Range for UAD

For the UAD tree, the smallest A,B within each level is found at the topmost
"U" steps for the smallest A or the bottommost "D" steps for the smallest
B.  For example in the table above of level 2, N=5..13, the smallest A is in
the top A=7,B=24, and the smallest B is in the bottom A=35,B=12.  In general

    Amin = 2*level + 1
    Bmin = 4*level

In P,Q coordinates the same topmost line is the smallest P and bottommost
the smallest Q.  The values are

    Pmin = level+1
    Qmin = 1

The fixed Q=1 arises from the way the "D" transformation sends Q-E<gt>Q
unchanged, so every level includes a Q=1.  This means if you ask what range
of N is needed to cover all Q E<lt> someQ then there isn't one, only a P
E<lt> someP has an N to go up to.

=head2 N Range, FB

For the FB tree, the smallest A,B within each level is found in the topmost
two final positions.  For example in the table above of level 2, N=5..13,
the smallest A is in the top A=9,B=40, and the smallest B is in the next row
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

    P=2 + 1+2+4+8+...+2^(level-2) = 2 + 2^(level-1) - 1
    Q=2^(level-1)

and then the K2 step Q -E<gt> P-Q = 1.  As for the UAD above this means
small Q's always remain no matter how big N gets, only a P range determines
an N range.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::Hypot>

H. Lee Price, "The Pythagorean Tree: A New Species", 2008,
<http://arxiv.org/abs/0809.4324>.

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Math-PlanePath is Copyright 2011 Kevin Ryde

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
