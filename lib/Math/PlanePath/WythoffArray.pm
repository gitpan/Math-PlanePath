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


# Classic Sequences
# http://oeis.org/classic.html
# 
# A000201 spectrum rows with k=1
#
# A175004 similar but rows r(n-1)+r(n-2)+1 extra +1 in each step

package Math::PlanePath::WythoffArray;
use 5.004;
use strict;
use List::Util 'max';

use vars '$VERSION', '@ISA';
$VERSION = 83;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 1;
use constant class_x_negative => 0;
use constant class_y_negative => 0;

sub new {
  my $self = shift->SUPER::new (@_);
  $self->{'base'} = max (2, $self->{'base'}||0); # default and minimum 2
  return $self;
}

#   4  |  12   20   32   52   84  136  220  356  576  932 1508
#   3  |   9   15   24   39   63  102  165  267  432  699 1131
#   2  |   6   10   16   26   42   68  110  178  288  466  754
#   1  |   4    7   11   18   29   47   76  123  199  322  521
# Y=0  |   1    2    3    5    8   13   21   34   55   89  144
#      +-------------------------------------------------------
#        X=0    1    2    3    4    5    6    7    8    9   10
# 13,8,5,3,2,1
# 4 = 3+1     -> 1
# 6 = 5+1     -> 2
# 9 = 8+1     -> 3
# 12 = 8+3+1  -> 3+1=4
# 14 = 13+1   -> 5

sub n_to_xy {
  my ($self, $n) = @_;
  ### WythoffArray n_to_xy(): $n

  if ($n < 1) { return; }
  if (is_infinite($n) || $n == 0) { return ($n,$n); }

  {
    # fractions on straight line ?
    my $int = int($n);
    if ($n != $int) {
      my $frac = $n - $int;  # inherit possible BigFloat/BigRat
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int;
  }

  # f1+f0 > i
  # f0 > i-f1
  # check i-f1 as the stopping point, so that if i=UV_MAX then won't
  # overflow a UV trying to get to f1>=i
  #
  my @fibs;
  {
    my $f0 = ($n * 0);  # inherit bignum 0
    my $f1 = $f0 + 1;   # inherit bignum 1
    while ($f0 <= $n-$f1) {
      ($f1,$f0) = ($f1+$f0,$f1);
      push @fibs, $f1;      # starting $fibs[0]=1
    }
  }
  ### @fibs

  # indices into fib[] which are the Fibonaccis adding up to $n
  my @indices;
  for (my $i = $#fibs; $i >= 0; $i--) {
    ### at: "n=$n f=".$fibs[$i]
    if ($n >= $fibs[$i]) {
      push @indices, $i;
      $n -= $fibs[$i];
      ### sub: "$fibs[$i] to n=$n"
      --$i;
    }
  }
  ### @indices

  # X is low index, ie. how many low 0 bits in Zeckendorf form
  my $x = pop @indices;
  ### $x

  # Y is indices shifted down by $x and 2 more
  my $y = 0;
  my $shift = $x+2;
  foreach my $i (@indices) {
    ### y add: "ishift=".($i-$shift)." fib=".$fibs[$i-$shift]
    $y += $fibs[$i-$shift];
  }
  ### $shift
  ### $y

  return ($x,$y);
}

# phi = (sqrt(5)+1)/2
# (y+1)*phi = (y+1)*(sqrt(5)+1)/2
#           = ((y+1)*sqrt(5)+(y+1))/2
#           = (sqrt(5*(y+1)^2)+(y+1))/2
#
# from x=0,y=0
# N = floor((y+1)*Phi) * Fib(x+2) + y*Fib(x+1)
#
sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### WythoffArray xy_to_n(): "$x, $y"

  $x = round_nearest ($x);
  $y = round_nearest ($y);
  if ($x < 0 || $y < 0) {
    return undef;
  }
  if (is_infinite($x)) { return $x; }
  if (is_infinite($y)) { return $y; }

  # FIXME: power up f0,f1 by bits of $x
  my $zero = $x * 0 * $y;
  my $yplus1 = $zero + $y+1; # bigint from $x perhaps
  my $f0 = int((sqrt(5*$yplus1*$yplus1) + $yplus1) / 2);
  my $f1 = $f0 + $y;
  for ( ; $x > 0; $x -= 1) {
    ($f1,$f0) = ($f1+$f0,$f1);  # step
  }
  ### $f1
  return $f1;
}

# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### WythoffArray rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = round_nearest ($x1);
  $y1 = round_nearest ($y1);
  $x2 = round_nearest ($x2);
  $y2 = round_nearest ($y2);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  if ($x2 < 0 || $y2 < 0) {
    ### all outside first quadrant ...
    return (1, 0);
  }

  # bottom left into first quadrant
  if ($x1 < 0) { $x1 *= 0; }
  if ($y1 < 0) { $y1 *= 0; }

  return ($self->xy_to_n($x1,$y1),    # bottom left
          $self->xy_to_n($x2,$y2));   # top right
}

1;
__END__

=for stopwords eg Ryde ie PeanoHalf Math-PlanePath Moore Wythoff Zeckendorf concecutive fibbinary PowerArray bignum OEIS

=head1 NAME

Math::PlanePath::WythoffArray -- table of Fibonacci recurrences

=head1 SYNOPSIS

 use Math::PlanePath::WythoffArray;
 my $path = Math::PlanePath::WythoffArray->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path is the Wythoff array of Fibonacci recurrences.

=cut

# math-image  --path=WythoffArray --output=numbers --all --size=60x16

=pod

     15  |  40   65  105  170  275  445  720 1165 1885 3050 4935
     14  |  38   62  100  162  262  424  686 1110 1796 2906 4702
     13  |  35   57   92  149  241  390  631 1021 1652 2673 4325
     12  |  33   54   87  141  228  369  597  966 1563 2529 4092
     11  |  30   49   79  128  207  335  542  877 1419 2296 3715
     10  |  27   44   71  115  186  301  487  788 1275 2063 3338
      9  |  25   41   66  107  173  280  453  733 1186 1919 3105
      8  |  22   36   58   94  152  246  398  644 1042 1686 2728
      7  |  19   31   50   81  131  212  343  555  898 1453 2351
      6  |  17   28   45   73  118  191  309  500  809 1309 2118
      5  |  14   23   37   60   97  157  254  411  665 1076 1741
      4  |  12   20   32   52   84  136  220  356  576  932 1508
      3  |   9   15   24   39   63  102  165  267  432  699 1131
      2  |   6   10   16   26   42   68  110  178  288  466  754
      1  |   4    7   11   18   29   47   76  123  199  322  521
    Y=0  |   1    2    3    5    8   13   21   34   55   89  144
         +-------------------------------------------------------
           X=0    1    2    3    4    5    6    7    8    9   10

N=1,2,3,5,8,etc along the X axis is the Fibonacci numbers.  N=4,7,11,18,etc
along the Y=1 row is the Lucas numbers.

All rows have the Fibonacci style recurrence F(X+1) = F(X)+F(X-1).  For
example in the Y=2 row N=42 at X=4 is 16+26, the two values to its left.

N=1,4,6,9,12,etc along the Y axis is the "spectrum" of phi, the golden
ratio, meaning its rounded down integer multiples.

    phi = (sqrt(5)+1)/2
    spectrum(k) = floor(phi*k)
    N_Yaxis = Y + spectrum(Y+1)

For example the Y=5 row has N_Yaxis = 5+floor((5+1)*phi)=14.  The recurrence
starts as if there were values Y and spectrum(Y+1) to the left, and then
N_Yaxis+spectrum(Y+1) in the X=1 column.

Every integer N from 1 upwards occurs precisely once in the table.  The
recurrence means in the rows N grows as roughly phi^X, the same as the
Fibonacci numbers, so they become large quite quickly.

=head2 Zeckendorf Base

The N values are arranged according to how many trailing zero bits when N is
represented in the Zeckendorf base.  This base makes N a sum of Fibonacci
numbers.  At each stage the largest possible F is chosen, so the
representation is unique.  For example

    F[0]=1, F[1]=2, F[2]=3, F[3]=5, etc

    45 = 34 + 8 + 3
       = F[7] + F[4] + F[2]
       = 10010100       as bits

The array in Zeckendorf base is

      8  |  101010  1010100  10101000 101010000 1010100000 
      7  |  101001  1010010  10100100 101001000 1010010000 
      6  |  100101  1001010  10010100 100101000 1001010000 
      5  |  100001  1000010  10000100 100001000 1000010000 
      4  |   10101   101010   1010100  10101000  101010000 
      3  |   10001   100010   1000100  10001000  100010000 
      2  |    1001    10010    100100   1001000   10010000 
      1  |     101     1010     10100    101000    1010000 
    Y=0  |       1       10       100      1000      10000 
         +--------------------------------------------------
               X=0        1         2         3          4  

The X coordinate is the number of trailing zeros, the index of the lowest
Fibonacci used in the sum.  The Y coordinate is the index of the "odd"
Zeckendorf remaining.

The Y index is formed by stripping the trailing zero bits, and the lowest 1,
and then one more 0 above that.  For example,

    N = 45 = Zeck(10010100)
                      ^^^^ strip low zeros, lowest 1, and the 0 above
    Y = Zeck(1001) = F[3]+F[0] = 5+1 = 6

The Zeckendorf form never has consecutive "11" bits, because after
subtracting an F[k] the remainder is smaller than the immediately following
F[k-1].  Numbers with no concecutive "11" are also called the fibbinary
numbers (L<Math::NumSeq::Fibbinary>).

Stripping of low zeros is similar to what the PowerArray does with low zero
digits in an ordinary base such as binary.  Doing it in the Zeckendorf base
is like taking out powers of the golden ratio phi=1.618.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::WythoffArray-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 1 and if C<$n E<lt> 0> then the return is an empty list.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the N point number at coordinates C<$x,$y>.  If C<$xE<lt>0> or
C<$yE<lt>0> then there's no N and the return is C<undef>.

N values grow rapidly with C<$x>.  Pass in a bignum type such as
C<Math::BigInt> for full precision.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

The returned range is exact, meaning C<$n_lo> and C<$n_hi> are the smallest
and biggest in the rectangle.

=back

=head1 FORMULAS

=head2 Rectangle to N Range

Within each row increasing X is increasing N, and in each column increasing
Y is increasing N.  So in a rectangle the lower left corner is the minimum N
and the upper right is the maximum N.

=head2 OEIS

The Wythoff array is in Sloane's Online Encyclopedia of Integer Sequences
in various forms,

    http://oeis.org/A019586    etc

    A035614     X coordinate
    A035612     X+1 coordinate, first column numbered 1
    A139764     X axis N for successive N values,
                  being the lowest Fibonacci in Zeckendorf form

    A019586     Y coordinate, the Wythoff row containing N
    A003603     Y+1 coordinate, fractalized Fibonacci numbers

    A000045     N on X axis, Fibonacci numbers skipping initial 0,1
    A000204     N on Y=1 row, Lucas numbers skipping initial 1,3

    A003622     N on Y axis, odd Zeckendorfs
    A001950     N+1 of those N on Y axis, anti-spectrum of phi
    A022342     N not on Y axis, even Zeckendorfs
    A000201     N+1 of those N not on Y axis, spectrum of phi
    A003849     1,0 if N on Y axis or not, being the Fibonacci word

    A035336     N in X=1 column
    A020941     N on X=Y diagonal

    A083412     N by Diagonals from Y axis downwards
    A035513     N by Diagonals from X axis upwards
    A064274       inverse permutation

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::FibonacciWordFractal>

L<Math::NumSeq::Fibbinary>,
L<Math::NumSeq::Fibonacci>,
L<Math::NumSeq::LucasNumbers>,
L<Math::Fibonacci>,
L<Math::Fibonacci::Phi>

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
