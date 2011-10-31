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


# math-image --path=RationalsTree --all --scale=3
# math-image --path=RationalsTree --all --output=numbers_xy --size=60x40
#
# A002487 - stern diatomic


package Math::PlanePath::RationalsTree;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 52;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

# uncomment this to run the ### lines
#use Devel::Comments;


use constant x_negative => 0;
use constant y_negative => 0;
use constant n_start => 1;

use constant parameter_info_array =>
  [ { name       => 'tree_type',
      share_key  => 'tree_type_rationals',
      type       => 'enum',
      choices    => ['SB','CW','AYT','Bird','Drib'],
      default    => 'SB',
    },
  ];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new (@_);
  $self->{'tree_type'} ||= 'SB';
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### RationalsTree n_to_xy(): "$n"

  if ($n < 1) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

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

  my $tree_type = $self->{'tree_type'};
  if ($tree_type eq 'CW') {
    ### CW tree ...
    # (x,y) -> (x+y,x) and (y,x+y) but bits in reverse

    #       X/Y
    #     /     \
    # X/(X+Y)  (X+Y)/Y
    #
    # (1 0) (x) = ( x )     (a b) (1 0) = (a+b b)   digit 0
    # (1 1) (y)   (x+y)     (c d) (1 1)   (c+d d)
    #
    # (1 1) (x) = (x+y)     (a b) (1 1) = (a a+b)   digit 1
    # (0 1) (y)   ( y )     (c d) (0 1)   (c c+d)

    my $a = $one;     # initial  (1 0)
    my $b = $zero;    #          (0 1)
    my $c = $zero;
    my $d = $one;
    while ($n > 1) {
      ### digit: ($n % 2).''
      ### at: "($a $b)"
      ### at: "($c $d)"
      if ($n % 2) {      # low to high
        $b += $a;
        $d += $c;
      } else {
        $a += $b;
        $c += $d;
      }
      $n = int($n/2);
    }
    ### final: "($a $b)"
    ### final: "($c $d)"

    # (a b) (1) = (a+b)
    # (c d) (1)   (c+d)
    return ($a+$b, $c+$d);


    # my $lx = $zero;
    # my $ly = $one;
    # my $rx = $one;
    # my $ry = $zero;
    # for (;;) {
    #   if ($n % 2) {      # low to high
    #     $lx += $rx;
    #     $ly += $ry;
    #     unless ($n = int($n/2)) {
    #       return ($lx,$ly);
    #     }
    #   } else {
    #     $rx += $lx;
    #     $ry += $ly;
    #     unless ($n = int($n/2)) {
    #       return ($rx,$ry);
    #     }
    #   }
    # }

  } elsif ($tree_type eq 'AYT') {
    ### AYT tree ...

    #       X/Y
    #     /     \
    # (X+Y)/Y  Y/(X+Y)
    #
    # (1 1) (x) = (x+y)     (a b) (1 1) = (a a+b)   digit 0
    # (0 1) (y)   ( y )     (c d) (0 1)   (c c+d)
    #
    # (0 1) (x) = ( y )     (a b) (0 1) = (b a+b)   digit 1
    # (1 1) (y)   (x+y)     (c d) (1 1)   (d c+d)

    my $a = $one;     # initial  (1 0)
    my $b = $zero;    #          (0 1)
    my $c = $zero;
    my $d = $one;
    while ($n > 1) {
      ### digit: ($n % 2).''
      ### at: "($a $b)"
      ### at: "($c $d)"
      if ($n % 2) {      # low to high
        ($a,$b) = ($b, $a+$b);
        ($c,$d) = ($d, $c+$d);
      } else {
        $b += $a;
        $d += $c;
      }
      $n = int($n/2);
    }
    ### final: "($a $b)"
    ### final: "($c $d)"

    # (a b) (1) = (a+b)
    # (c d) (1)   (c+d)
    return ($a+$b, $c+$d);


    # $n = _reverse ($n);   # high to low
    # my $x = $one;
    # my $y = $one;
    # while ($n > 1) {
    #   ### at: "$x,$y  n=$n"
    #   $x += $y;             # (x,y) -> (x+y,y)  digit 0
    #   if ($n % 2) {
    #     ($x,$y) = ($y,$x);  # (x,y) -> (y,x+y)  digit 1
    #   }
    #   $n = int($n/2);
    # }
    # return ($x,$y);

  } elsif ($tree_type eq 'Bird') {
    ### Bird tree ...

    my $x = $one;
    my $y = $one;
    while ($n > 1) {   # low to high
      ### at: "$x,$y  n=$n"
      if ($n % 2) {
        ($x,$y) = ($x+$y,$x);   # (x,y) -> (x+y,x)
      } else {
        ($x,$y) = ($y,$x+$y);   # (x,y) -> (y,x+y)
      }
      $n = int($n/2);
    }
    return ($x,$y);

  } elsif ($tree_type eq 'Drib') {
    ### Drib tree ...

    #       X/Y
    #     /     \
    # (X+Y)/X  Y/(X+Y)
    #
    # (1 1) (x) = (x+y)     (a b) (1 1) = (a+b a)   digit 0
    # (1 0) (y)   ( x )     (c d) (1 0)   (c+d c)
    #
    # (0 1) (x) = ( y )     (a b) (0 1) = (b a+b)   digit 1
    # (1 1) (y)   (x+y)     (c d) (1 1)   (d c+d)

    my $a = $one;     # initial  (1 0)
    my $b = $zero;    #          (0 1)
    my $c = $zero;
    my $d = $one;
    while ($n > 1) {
      ### digit: ($n % 2).''
      ### at: "($a $b)"
      ### at: "($c $d)"
      if ($n % 2) {      # low to high
        ($a,$b) = ($a+$b, $a);
        ($c,$d) = ($c+$d, $c);
      } else {
        ($a,$b) = ($b, $a+$b);
        ($c,$d) = ($d, $c+$d);
      }
      $n = int($n/2);
    }
    ### final: "($a $b)"
    ### final: "($c $d)"

    # (a b) (1) = (a+b)
    # (c d) (1)   (c+d)
    return ($a+$b, $c+$d);


  } else {
    ### SB tree ...
    my $x = $one;
    my $y = $one;
    while ($n > 1) {
      if ($n % 2) {
        $x += $y;     # (x,y) -> (x+y,y)
      } else {
        $y += $x;     # (x,y) -> (x,x+y)
      }
      $n = int($n/2);
    }
    return ($x,$y);
  }
}

# sub _reverse {
#   my ($n) = @_;
#   my $rev = 1;
#   while ($n > 1) {
#     $rev = 2*$rev + ($n % 2);
#     $n = int($n/2);
#   }
#   return $rev;
# }

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  ### RationalsTree xy_to_n(): "$x,$y   $self->{'tree_type'}"

  if (_is_infinite($x)) {  # ($x == 0 && $y == 0)
    return $x;
  }
  if (_is_infinite($y)) {
    return $y;
  }
  if ($x < 1 || $y < 1) {
    return undef;
  }

  # ($x,$y) = ($y,$x);

  my $zero = $x * 0 * $y;   # inherit bignum 0
  my $one = ($zero + 1);    # inherit bignum 1

  if ($self->{'tree_type'} eq 'AYT') {

    my $n = 0;
    my $power = $one;   # bits generated low to high
    for (;;) {
      ### CW at: "$x,$y n=$n power=$power"
      if ($x <= 1 && $y <= 1) {
        last;
      }
      if ($x == $y) {
        return undef;
      }
      $n *= 1;
      if ($x > $y) {
        $x -= $y;               # (x-y,y)   inverse of (x+y,y)
      } else {
        ($x,$y) = ($y-$x,$x);   # (y-x,x)   inverse of (y,x+y)
        $n += $power;
      }
      $power *= 2;
    }
    return $n + $power;  # plus high bit

  } elsif ($self->{'tree_type'} eq 'CW') {

    my $n = $zero;
    my $power = $one;   # bits generated low to high
    for (;;) {
      ### at: "$x,$y n=$n"
      if ($x <= 1 && $y <= 1) {
        last;
      }
      if ($x == $y) {
        return undef;
      }
      if ($x > $y) {
        $x -= $y;   # (x,y) <- (x-y, y)
        $n += $power;
      } else {
        $y -= $x;   # (x,y) <- (x, y-x)
      }
      $power *= 2;
    }
    return $n + $power;  # plus high bit

  } elsif ($self->{'tree_type'} eq 'Drib') {

    my $n = $zero;
    my $power = $one;   # bits generated low to high
    for (;;) {
      ### at: "$x,$y n=$n"
      if ($x <= 1 && $y <= 1) {
        last;
      }
      if ($x == $y) {
        return undef;
      }

      #       X/Y
      #     /     \
      # (X+Y)/X  Y/(X+Y)
      #
      if ($x > $y) {
        ($x,$y) = ($y, $x-$y);    # (x,y) <- (y, x-y)  digit 1
        $n += $power;
      } else {
        ($x,$y) = ($y-$x, $x);    # (x,y) <- (y-x, x)  digit 0
      }
      $power *= 2;
    }
    return $n + $power;  # plus high bit

  } elsif ($self->{'tree_type'} eq 'Bird') {

    my $n = $one;  # bits generated high to low, this is the high bit
    for (;;) {
      ### at: "$x,$y n=$n"
      if ($x <= 1 && $y <= 1) {
        last;
      }
      if ($x == $y) {
        return undef;
      }

      #       X/Y
      #     /     \
      # (X+Y)/X  Y/(X+Y)
      #
      $n *= 2;
      if ($x > $y) {
        ($x,$y) = ($y, $x-$y);    # (x,y) <- (y, x-y)  digit 1
        $n += 1;
      } else {
        ($x,$y) = ($y-$x, $x);    # (x,y) <- (y-x, x)  digit 0
      }
    }
    return $n;

  } else { # SB

    my $n = $one;  # bits generated high to low, this is the high bit
    for (;;) {
      ### at: "$x,$y n=$n"
      if ($x <= 1 && $y <= 1) {
        last;
      }
      $n *= 2;
      if ($x == $y) {
        return undef;
      }
      if ($x > $y) {
        $x -= $y;   # (x,y) <- (x-y, y)
        $n += 1;
      } else {
        $y -= $x;   # (x,y) <- (x, y-x)
      }
    }
    ### xy_to_n() result: $n
    return $n;
  }
}


# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### rect_to_n_range()

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### $x2
  ### $y2

  if ($x2 < 1 || $y2 < 1) {
    ### no values, rect below first quadrant
    return (1,0);
  }

  my $zero = ($x1 * 0 * $y1 * $x2 * $y2);  # inherit bignum
  ### $zero

  if ($x1 < 1) { $x1 = 1; }
  if ($y1 < 1) { $y1 = 1; }

  # big x2, small y1
  # big y2, small x1
  my $level = _bingcd_max ($y2,$x1);
  ### $level
  {
    my $l2 = _bingcd_max ($x2,$y1);
    ### $l2
    if ($l2 > $level) { $level = $l2; }
  }

  return (1, ($zero+2) ** ($level + 3));
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

1;
__END__

=for stopwords eg Ryde OEIS ie Math-PlanePath

=head1 NAME

Math::PlanePath::RationalsTree -- rationals by tree

=head1 SYNOPSIS

 use Math::PlanePath::RationalsTree;
 my $path = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path enumerates rational fractions X/Y in reduced form, ie. having no
common factor between X and Y, by one of five different binary trees.

The trees effectively represent a coprime pair X,Y by the steps of the
binary greatest common divisor algorithm which would prove X,Y coprime.  The
different encoding of those steps in N gives a different order for the X/Y
values in the tree types.  In the current tree types the set of X/Y values
in a tree row is the same in all cases, just the order within the row
varies.

See F<examples/rationals-tree.pl> in the PlanePath sources for a simple
print of all the trees.

=head2 Stern-Brocot Tree

The default C<tree_type=E<gt>"SB"> is the tree of Moritz Stern and Achille
Brocot.  The rows are fractions of increasing value.

    N=1                             1/1
                              ------   ------
    N=2 to N=3             1/2               2/1
                          /    \            /   \
    N=4 to N=7         1/3      2/3      3/2      3/1
                       | |      | |      | |      | |
    N=8 to N=15     1/4  2/4  3/5 3/4  4/3 5/3  5/2 4/1

Writing the parents in between the children as an "in-order" traversal of
given depth has the values in increasing order too,

                 1/1
         1/2      |      2/1
     1/3  |  2/3  |  3/2  |  3/1
      |   |   |   |   |   |   |

     1/3 1/2 2/3 1/1 3/2 2/1 3/1
                    ^
                   4/3

New values are a "mediant" value (x1+x2)/(y1+y2) of the left and right
parents in this flattening.  The 4/3 above is formed from left parent 1/1
and right parent 3/2 as mediant (1+3)/(1+2)=4/3.

Plotting the N values by X,Y is as follows.  The unused X,Y positions are
where X and Y have a common factor.  For example X=6,Y=2 has common factor 2
so is never reached.

    10  |  512        35                  44       767
     9  |  256   33        39   40        46  383       768
     8  |  128        18        21       191       384
     7  |   64   17   19   20   22   95       192   49   51
     6  |   32                  47        96
     5  |   16    9   10   23        48   25   26   55
     4  |    8        11        24        27        56
     3  |    4    5        12   13        28   29        60
     2  |    2         6        14        30        62
    Y=1 |    1    3    7   15   31   63  127  255  511 1023
        |
         -------------------------------------------------------------
           X=1    2    3    4    5    6    7    8    9   10

The X=1 vertical is the 1/Y fractions at the left of each tree row, being
Nstart=2^level.  The Y=1 horizontal is the Y/1 integers at the end each row
which is Nend=2^(level+1)-1.

=head2 Calkin-Wilf Tree

C<tree_type=E<gt>"CW"> selects the tree of Neil Calkin and Herbert Wilf.

    http://www.math.upenn.edu/%7Ewilf/website/recounting.pdf

The values within each row are the same as the Stern-Brocot, but in a
different order.

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
reciprocals of reading left to right.

A node descends as

          X/Y
        /     \             (N bits high to low)
    X/(X+Y)  (X+Y)/Y

This can can be viewed in reverse to see how it relates to the binary
greatest common divisor algorithm.  The smaller of P,Q is subtracted from
the bigger,

       P/(Q-P)         (P-Q)/P
      /          or        \
    P/Q                    P/Q

Plotting the N values by X,Y has the same X=1 vertical and Y=1 horizontal as
the SB above, but the values in between are re-ordered.

    10  |  512        56                  38      1022
     9  |  256   48        60   34        46  510       513
     8  |  128        20        26       254       257
     7  |   64   24   28   18   22  126       129   49   57
     6  |   32                  62        65
     5  |   16   12   10   30        33   25   21   61
     4  |    8        14        17        29        35
     3  |    4    6         9   13        19   27        39
     2  |    2         5        11        23        47
    Y=1 |    1    3    7   15   31   63  127  255  511 1023
        |
         -------------------------------------------------------------
           X=1    2    3    4    5    6    7    8    9   10

N values for the SB and CW trees are converted by reversing bits.  If N is
binary "1abcde" is at a particular X,Y in the SB tree then at that X,Y in
the CW the N value is "1edcba".  For example at X=3,Y=4 the SB tree has
N=11=0b1011 and the CW has N=14=0b1110, a reversal of the bits below the
high 1.

N to X/Y in the CW tree can be calculated keeping track of just an X,Y pair
and descending to X/(X+Y) or (X+Y)/Y using the bits of N from high to low.
The relationship between the SB and CW N's means the same can be used to
calculate the SB tree, by taking the bits of N from low to high instead.

=head2 Andreev and Yu-Ting Tree

C<tree_type=E<gt>"AYT"> selects the tree described (independently is it?)
by D. N. Andreev and Shen Yu-Ting.

   http://files.school-collection.edu.ru/dlrstore/d62f7b96-a780-11dc-945c-d34917fee0be/i2126134.pdf
   http://www.jstor.org/stable/2320374

Their constructions are a one-to-one mapping between integer N and rational
X/Y as a way of enumerating the rationals.  It's not designed to be a tree
as such, but the result is the same sort of 2^level rows as the above trees.
The X/Y values within each row are the same as SB and CW, but in a further
different order.

    N=1                             1/1
                              ------   ------
    N=2 to N=3             2/1               1/2
                          /    \            /    \
    N=4 to N=7         3/1      1/3      3/2      2/3
                       | |      | |      | |      | |
    N=8 to N=15     4/1  1/4  4/3 3/4  5/2 2/5  5/3 3/5

Each fraction descends as follows.  The left increments and the right is
increment then reciprocal.

            X/Y
          /     \
    X/Y + 1     1/(X/Y + 1)

which means

          X/Y
        /     \               (N bits high to low)
    (X+Y)/Y  Y/(X+Y)

The (X+Y)/Y leg is the same as in the CW (on the right instead of left).
But Y/(X+Y) is not the same as X/(X+Y) of the CW.

The Y/(X+Y) right leg forms the Fibonacci numbers F(k)/F(k+1) at the end of
each row, ie. at Nend=2^(level+1)-1.  And as noted by Andreev successive
right legs at points N=4k+1 and N=4k+3 add up to 1, ie.

    X/Y at N=4k+1   +   X/Y at N=4k+3   =  1
    Eg. 2/5 at N=13 and 3/5 at N=15 add up to 1

Plotting the N values by X,Y gives

    10  |  513        41                  43       515
     9  |  257   49        37   39        51  259       514
     8  |  129        29        31       131       258
     7  |   65   25   21   23   27   67       130   50   42
     6  |   33                  35        66
     5  |   17   13   15   19        34   26   30   38
     4  |    9        11        18        22        36
     3  |    5    7        10   14        20   28        40
     2  |    3         6        12        24        48
    Y=1 |    1    2    4    8   16   32   64  128  256  512
        |
         ----------------------------------------------------
           X=1    2    3    4    5    6    7    8    9   10

The Y=1 horizontal is the X/1 integers at Nstart=2^level.  The X=1 vertical
is the 1/Y fractions.  Those fractions always immediately follow the
corresponding integer, at N=Nstart+1.

=head2 Bird Tree

C<tree_type=E<gt>"Bird"> selects the Bird tree by Ralf Hinze.

    http://www.cs.ox.ac.uk/ralf.hinze/publications/Bird.pdf

It's expressed recursively (illustrating Haskell features) and ends up as

    N=1                             1/1
                              ------   ------
    N=2 to N=3             1/2               2/1
                          /    \            /    \
    N=4 to N=7         2/3      1/3      3/1      3/2
                       | |      | |      | |      | |
    N=8 to N=15     3/5  3/4  1/4 2/5  5/2 4/1  4/3 5/3

The subtrees are plus one and reciprocal, or reciprocal and plus one
(ie. the other way around),

    1/(tree + 1)  and  (1/tree) + 1

which ends up meaning Y/(X+Y) and (X+Y)/X taking N bits low to high.

Plotting the N values by X,Y gives,

    10  |  682        41                  38       597      
     9  |  341   43        45   34        36  298       938 
     8  |  170        23        16       149       469      
     7  |   85   20   22   17   19   74       234   59   57 
     6  |   42                  37       117                
     5  |   21   11    8   18        58   28   31   61      
     4  |   10         9        29        30        50      
     3  |    5    4        14   15        25   24        54 
     2  |    2         7        12        27        52      
    Y=1 |    1    3    6   13   26   53  106  213  426  853 
         ----------------------------------------------------
           X=1    2    3    4    5    6    7    8    9   10

Notice that unlike the other trees the X=1 vertical of fractions 1/Y are not
the Nstart=2^level or Nend=2^(level+1)-1 row endpoints.  Those 1/Y fractions
are instead on a zigzag through the middle of the tree giving binary
N=1010...etc of alternate 1 and 0 bits.  The integers X/1 in the Y=1
vertical are similar, but N=11010...etc starting the alternation from a 1 in
the second highest bit, since those integers are in the right hand half of
the tree.

The Bird tree N values are related to the SB tree by inverting every second
bit, starting from the second after the highest 1, ie. xor "001010...".  So
if N=1abcdefg binary then b,d,f are inverted, ie. an xored with binary
00101010.  For example 3/4 in the SB tree is at N=11 = binary 1011.  Xor
with 0010 for binary 1001 N=9 which is the 3/4 in the Bird tree.  The same
xor goes back the other way Bird tree to SB tree.

This xoring reflects the way the tree is mirrored, swapping left and right
at each level.  Only every second bit is inverted because mirroring twice
(or any even number of times) puts it back to the ordinary way.

=head2 Drib Tree

C<tree_type=E<gt>"Drib"> selects the Drib tree by Ralf Hinze.  It reverses
the bits of N in the Bird tree (in a similar way that the SB and CW are bit
reversals).

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

Both ends have Fibonacci numbers, being F(k)/F(k+1) on the left and
F(k+1)/F(k) on the right.

Because Drib/Bird are bit reversals like CW/SB are bit reversals, the xor
procedure described above for BirdE<lt>-E<gt>SB applies to
DribE<lt>-E<gt>CW, but working from the second lowest bit upwards, ie. xor
binary "0..01010".  For example 4/1 is at N=15 binary 1111 in the CW tree.
Xor with 0010 for 1101 N=13 which is 4/1 in the Drib tree.

=head2 Common Characteristics

In all the trees the rows are permutations of the fractions arising from the
SB tree and Stern diatomic sequence.  The properties of the diatomic
sequence mean that within a level from Nstart=2^level to Nend=2^(level+1)-1
the fractions have totals

    sum fractions = (3 * 2^level - 1) / 2

    sum numerators = 3^level

For example at level=2, N=4 to N=7, the fractions are 1/3, 2/3, 3/2, 3/1.
The numerators 1+2+3+3 = 9 is 3^2.  The sum as fractions 1/3+2/3+3/2+3/1 =
11/2 is (3*2^2-1)/2=11/2.

=head1 OEIS

Some of the trees are in Sloane's Online Encyclopedia of Integer Sequences.

    http://oeis.org/A002487  (etc)

    A002487  - Stern's diatomic sequence, num/den of CW tree
    A162909  - Bird tree numerators
    A162910  - Bird tree denominators
    A068611  - Drib tree numerators
    A068612  - Drib tree denominators

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over

=item C<$path = Math::PlanePath::RationalsTree-E<gt>new ()>

=item C<$path = Math::PlanePath::RationalsTree-E<gt>new (tree_type =E<gt> $str)>

Create and return a new path object.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

Return a range of N values which occur in a rectangle with corners at
C<$x1>,C<$y1> and C<$x2>,C<$y2>.  The range is inclusive.

For reference, C<$n_hi> can be quite large because within each row there's
only one new X/1 integer and 1/Y fraction.  So if X=1 or Y=1 is included
then roughly C<$n_hi = 2**max(x,y)>.  If min(x,y) is bigger than 1 then it
reduces a little to roughly 2**(max/min + min).

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::CoprimeColumns>,
L<Math::PlanePath::PythagoreanTree>

L<Math::NumSeq::SternDiatomic>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011 Kevin Ryde

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





#     9  10                    12  10
# 8      11                 8      14
#        12  13                     9  13
#            14                        11
#            15                        15
#
# Stern-Brocot              Calkin-Wilf

