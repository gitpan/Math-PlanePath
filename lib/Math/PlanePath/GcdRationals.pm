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


# math-image --path=GcdRationals --expression='i<30*31/2?i:0' --text --size=40
# math-image --path=GcdRationals --output=numbers --expression='i<100?i:0'
# math-image --path=GcdRationals --all --output=numbers

# Y = v = j/g
# X = (g-1)*v + u
#   = (g-1)*j/g + i/g
#   = ((g-1)*j + i)/g

# j=5  11 ...
# j=4  7 8 9 10
# j=3  4 5 6
# j=2  2 3
# j=1  1
#
# N = (1/2 d^2 - 1/2 d + 1)
#   = (1/2*$d**2 - 1/2*$d + 1)
#   = ((1/2*$d - 1/2)*$d + 1)
# j = 1/2 + sqrt(2 * $n + -7/4)
#   = [ 1 + 2*sqrt(2 * $n + -7/4) ] /2
#   = [ 1 + sqrt(8*$n -7) ] /2
#

# Primes
# i=3*a,j=3*b
# N=3*a*(3*b-1)/2


package Math::PlanePath::GcdRationals;
use 5.004;
use strict;
use Carp;
#use List::Util 'min','max';
*min = \&Math::PlanePath::_min;
*max = \&Math::PlanePath::_max;

use Math::PlanePath;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::CoprimeColumns;
*_coprime = \&Math::PlanePath::CoprimeColumns::_coprime;

use vars '$VERSION', '@ISA';
$VERSION = 77;
@ISA = ('Math::PlanePath');


# uncomment this to run the ### lines
#use Smart::Comments;


use constant class_x_negative => 0;
use constant class_y_negative => 0;

# Not ready yet.
# use constant parameter_info_array =>
#   [ { name        => 'pairs_order',
#       type        => 'enum',
#       default     => 'rows',
#       choices     => ['rows','rows_reverse','diagonals_down','diagonals_up'],
#       choices_display => ['Rows',
#                           'Rows Reverse',
#                           'Diagonals Down',
#                           'Diagonals Up'],
#       description => 'Order in the i,j pairs.',
#     } ];

sub new {
  my $self = shift->SUPER::new(@_);

  my $pairs_order = ($self->{'pairs_order'} ||= 'rows');
  (($self->{'pairs_order_n_to_xy'}
    = $self->can("_pairs_order__${pairs_order}__n_to_xy"))
   && ($self->{'pairs_order_xyg_to_n'}
       = $self->can("_pairs_order__${pairs_order}__xyg_to_n")))
    or croak "Unrecognised pairs_order: ",$pairs_order;

  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### GcdRationals n_to_xy(): "$n"

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

  my ($x,$y) = $self->{'pairs_order_n_to_xy'}->($n);

  # if ($self->{'pairs_order'} eq 'rows'
  #     || $self->{'pairs_order'} eq 'rows_reverse') {
  #   $y = int((sqrt(8*$n-7) + 1) / 2);
  #   $x = $n - ($y - 1)*$y/2;
  # 
  #   if ($self->{'pairs_order'} eq 'rows_reverse') {
  #     $x = $y - ($x-1);
  #   }
  # 
  #   # require Math::PlanePath::PyramidRows;
  #   # my ($x,$y) = Math::PlanePath::PyramidRows->new(step=>1)->n_to_xy($n);
  #   # $x+=1;
  #   # $y+=1;
  # 
  # } else {
  #   require Math::PlanePath::DiagonalsOctant;
  #   ($x,$y) = Math::PlanePath::DiagonalsOctant->new->n_to_xy($n);
  #   if ($self->{'pairs_order'} eq 'diagonals_up') {
  #     my $d = $x+$y;      # top 0,d measure diag down by x
  #     my $e = int($d/2);  # end e,d-e
  #     ($x,$y) = ($e-$x, $d - ($e-$x));
  #   }
  #   $x+=1;
  #   $y+=1;
  # }
  ### triangle: "$x,$y"

  my $gcd = _gcd($x,$y);
  $x /= $gcd;
  $y /= $gcd;

  ### $gcd
  ### reduced: "$x,$y"
  ### push out to x: $x + ($gcd-1)*$y

  return ($x + ($gcd-1)*$y, $y);
}

sub _pairs_order__rows__n_to_xy {
  my ($n) = @_;
  my $y = int((sqrt(8*$n-7) + 1) / 2);
  return ($n - ($y-1)*$y/2,
          $y);
}
sub _pairs_order__rows_reverse__n_to_xy {
  my ($n) = @_;
  my $y = int((sqrt(8*$n-7) + 1) / 2);
  return ($y*($y+1)/2 + 1 - $n,
          $y);
}
sub _pairs_order__diagonals_down__n_to_xy {
  my ($n) = @_;
  my $d = int(sqrt($n-1));  # eg. N=10 d=3
  $n -= $d*($d+1);          # eg. d=3 subtract 12
  if ($n > 0) {
    return ($n,
            2 - $n + 2*$d);
  } else {
    return ($n + $d,
            1 - $n + $d);
  }
}
sub _pairs_order__diagonals_up__n_to_xy {
  my ($n) = @_;
  my $d = int(sqrt($n-1));
  $n -= $d*($d+1);
  if ($n > 0) {
    return (-$n + $d + 2,
            $n + $d);
  } else {
    return (1 - $n,
            $n + 2*$d);
  }
}


# X=(g-1)*v+u
# Y=v
# u = x % y
# i = u*g
#   = (x % y)*g
#   = (x % y)*(floor(x/y)+1)
#
# Better:
#   g-1 = floor(x/y)
#   Y = j/g
#   X = ((g-1)*j + i)/g
#   j = Y*g
#   (g-1)*j + i = X*g
#   i = X*g - (g-1)*j
#     = X*g - (g-1)*Y*g
#   N = i + j*(j-1)/2
#     = X*g - (g-1)*Y*g + Y*g*(Y*g-1)/2
#     = X*g + Y*g * (-(g-1) + (Y*g-1)/2)    # but Y*g-1 may be odd
#     = X*g + Y*g * (Y*g-1 - (2g-2))/2
#     = X*g + Y*g * (Y*g-1 - 2g + 2))/2
#     = X*g + Y*g * (Y*g - 2g + 1))/2
#     = X*g + Y*g * ((Y-2)*g + 1) / 2
#     = g * [ X + Y*((Y-2)*g + 1) / 2 ]
#
#   N = X*g - (g-1)*Y*g + Y*g*(Y*g-1)/2
#     = [ 2*X*g - 2*(g-1)*Y*g + Y*g*(Y*g-1) ] / 2
#     = [ 2*X - 2*(g-1)*Y + Y*(Y*g-1) ] * g / 2
#     = [ 2*X + Y*(- 2*(g-1) + (Y*g-1)) ] * g / 2
#     = [ 2*X + Y*(-2g + 2 + Y*g - 1) ] * g / 2
#     = [ 2*X + Y*((Y-2)*g + 1) ] * g / 2
#     = X*g + [(Y-2)*g + 1]*Y*g/2
#
#  if Y and g both odd then (Y-2)*g+1 is odd+1 so even

# q=int(x/y)
# x = qy+r   qy=x-r
# r = x % y
# g-1 = q
# g = q+1
# g*y = (q+1)*y
#     = q*y + y
#     = x-r + y
#
#   N = X*g + Y*g * ((Y-2)*g + 1) / 2
#     = X*g + (X+Y-r) * ((Y-2)*g + 1) / 2
#     = X*g + (X+Y-r) * ((g*Y-2*g + 1) / 2
#     = X*g + (X+Y-r) * (((X+Y-r) - 2*g + 1) / 2
#     ... not much better

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  ### GcdRationals xy_to_n(): "$x,$y"

  if (_is_infinite($x)) { return $x; }
  if (_is_infinite($y)) { return $y; }
  if ($x < 1 || $y < 1 || ! _coprime($x,$y)) {
    return undef;
  }

  my $g = int($x/$y) + 1;
  ### g: "$g"
  ### halve: ''.$y*(($y-2)*$g + 1)

  return $self->{'pairs_order_xyg_to_n'}->($x,$y,$g);



  # if ($self->{'pairs_order'} eq 'rows') {
  #   return ((($y-2)*$g + 1)*$y + 2*$x) * $g / 2;
  # 
  # } else {
  #   # X=(g-1)*v+u
  #   # Y=v
  #   # v = j/g
  #   # u = i/g
  #   #   g-1 = floor(x/y)
  #   # Y=j/g
  #   # j=Y*g
  #   #
  #   # X=4,Y=1
  #   # g-1 = floor(x/y) = 4
  #   # g=5
  #   # j=1*5 = 5
  #   # i = (X%y)*g = 0*g = 0
  #   #   j = Y*g
  #   #   (g-1)*j + i = X*g
  #   #   i = X*g - (g-1)*j
  #   #     = X*g - (g-1)*Y*g
  #   ### i: $x*$g - ($g-1)*$g*$y
  #   ### i: ($x % $y)*$g
  #   ### j: $y*$g
  #   require Math::PlanePath::DiagonalsOctant;
  #   my $i = $x*$g - ($g-1)*$g*$y;
  #   my $j = $y*$g;
  #   if ($i == 0) {
  #     $i = $g-1;
  #     $j = $g-1;
  #   }
  #   my $x = $i-1;
  #   my $y = $j-1;
  #   if ($self->{'pairs_order'} eq 'diagonals_up') {
  #     my $d = $x+$y;      # top 0,d measure diag down by x
  #     my $e = int($d/2);  # end e,d-e
  #     ($x,$y) = ($e-$x, $d - ($e-$x));
  #   }
  #   return Math::PlanePath::DiagonalsOctant->new->xy_to_n ($x,$y);
  # }
}

sub _pairs_order__rows__xyg_to_n {
  my ($x,$y,$g) = @_;
  return ((($y-2)*$g + 1)*$y + 2*$x) * $g / 2;
}
sub _pairs_order__rows_reverse__xyg_to_n {
  my ($x,$y,$g) = @_;
  my $i = $x*$g - ($g-1)*$g*$y;
  my $j = $y*$g;
  if ($i == 0) {
    $i = $g-1;
    $j = $g-1;
  }
  $i = $j-$i + 1;
  return $i + $j*($j-1)/2;

  # return ((($y-2)*$g + 1)*$y + 2*$x) * $g / 2;
}
sub _pairs_order__diagonals_down__xyg_to_n {
  my ($x,$y,$g) = @_;

  my $i = $x*$g - ($g-1)*$g*$y;
  my $j = $y*$g;
  if ($i == 0) {
    $i = $g-1;
    $j = $g-1;
  }
  $x = $i-1;
  $y = $j-1;

  my $d = $x + $y + 1;
  return ($d*$d - ($d % 2))/4 + 1 + $x;
}
sub _pairs_order__diagonals_up__xyg_to_n {
  my ($x,$y,$g) = @_;

  my $i = $x*$g - ($g-1)*$g*$y;
  my $j = $y*$g;
  if ($i == 0) {
    $i = $g-1;
    $j = $g-1;
  }
  $x = $i-1;
  $y = $j-1;

  my $d = $x + $y + 2;
  ### $d
  return ($d*$d - ($d % 2))/4 - $x;
}


# increase in rows, so right column
# in column increase within g wedge, then drop
#
# int(x2/y2) is slope of top of the wedge containing x2,y2
# g = int(x2/y2)+1 is the slope of the bottom of that wedge
# yw = floor(x2 / g) is the Y of that bottom
# N at x2,yw,g+1 is the top of the wedge underneath, bigger g smaller y
# or x2,y2,g is the top-right corner
#
# Eg.
# x=19 y=2 to 4
# g=int(19/4)+1=5
# yw=int(19/5)=3
# N(19,3,6)=

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### $x2
  ### $y2

  if ($x2 < 1 || $y2 < 1) {
    return (1, 0);  # outside quadrant
  }

  if ($x1 < 1) { $x1 = 1; }
  if ($y1 < 1) { $y1 = 1; }

  my $g = int($x2/$y2) + 1;
  my $nhi = ($y2*(($y2-2)*$g + 1) / 2 + $x2)*$g;
  ### ghi: $g
  ### $nhi

  my $yw = int($x2 / $g) - ($g==1);  # below X=Y diagonal when g==1
  if ($yw >= $y1) {
    $g = int($x2/$yw) + 1;  # perhaps went across more than one wedge
    $nhi = max ($nhi,
                ($yw*(($yw-2)*($g+1) + 1) / 2 + $x2)*($g+1));
    ### $yw
    ### nhi_wedge: ($yw*(($yw-2)*($g+1) + 1) / 2 + $x2)*($g+1)
  }

  $g = int($x1/$y1) + 1;
  my $nlo = ($y1*(($y1-2)*$g + 1) / 2 + $x1)*$g;

  ### glo: $g
  ### $nlo

  if ($g > 1) {
    $yw = max (int($x1 / $g),
               1);
    ### $yw
    if ($yw <= $y2) {
      $g = int($x1/$yw); # no +1, and perhaps up across more than one wedge
      $nlo = min ($nlo,
                  ($yw*(($yw-2)*$g + 1) / 2 + $x1)*$g);
      ### glo_wedge: $g
      ### nlo_wedge: ($yw*(($yw-2)*$g + 1) / 2 + $x1)*$g
    }
  }

  return ($nlo, $nhi);
}

sub _gcd {
  my ($x, $y) = @_;
  #### _gcd(): "$x,$y"

  # bgcd() available in even the earliest Math::BigInt
  if (ref $y && $y->isa('Math::BigInt')) {
    return Math::BigInt::bgcd($x,$y);
  }

  if ($y > $x) {
    $y %= $x;
  }
  for (;;) {
    if ($y <= 1) {
      return ($y == 0 ? $x : 1);
    }
    ($x,$y) = ($y, $x % $y);
  }
}

1;
__END__

=for stopwords eg Ryde OEIS ie Math-PlanePath GCD gcd PyramidRows Fortnow coprime

=head1 NAME

Math::PlanePath::GcdRationals -- rationals by triangular GCD

=head1 SYNOPSIS

 use Math::PlanePath::GcdRationals;
 my $path = Math::PlanePath::GcdRationals->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

X<Fortnow, Lance>
This path enumerates rationals X/Y using a method by Lance Fortnow taking a
GCD out of a triangular position.

    http://blog.computationalcomplexity.org/2004/03/counting-rationals-quickly.html

    13  |      79  80  81  82  83  84  85  86  87  88  89  90
    12  |      67              71      73              77     278
    11  |      56  57  58  59  60  61  62  63  64  65     233 235
    10  |      46      48              52      54     192     196
     9  |      37  38      40  41      43  44     155 157     161
     8  |      29      31      33      35     122     126     130
     7  |      22  23  24  25  26  27      93  95  97  99 101 103
     6  |      16              20      68              76     156
     5  |      11  12  13  14      47  49  51  53     108 111 114
     4  |       7       9      30      34      69      75     124
     3  |       4   5      17  19      39  42      70  74     110
     2  |       2       8      18      32      50      72      98
     1  |       1   3   6  10  15  21  28  36  45  55  66  78  91
    Y=0 |
         --------------------------------------------------------
          X=0   1   2   3   4   5   6   7   8   9  10  11  12  13

The mapping from N to X/Y is

    N = i + j*(j-1)/2     upper triangle 1 <= i <= j
    gcd = GCD(i,j)
    rational = i/j + gcd-1

    X = (i + j*(gcd-1)) / gcd
    Y = j/gcd

The i,j position is a numbering of points above the X=Y diagonal by rows,

    j=4  7  8  9  10
    j=3  4  5  6
    j=2  2  3
    j=1  1
       i=1  2  3  4

When gcd=1, X/Y is simply X=i,Y=j.  So the fractions S<X/Y E<lt> 1> above
the X=Y diagonal are numbered by rows, so increasing numerator, skipping
positions where X,Y have a common factor.

The skipped positions where i,j have a common factor become rationals
S<RE<gt>1> below the X=Y diagonal.  gcd(i,j)-1 is made the integer part as
S<R = i/j+(gcd-1)>.  For example N=51 is at i=6,j=10 by rows, but they have
common factor gcd=2 so R = 6/10+(2-1) = 3/5+1 = 8/5, ie. X=8,Y=5.

=head2 Triangular Numbers

The bottom row Y=1 is the triangular numbers N=1,3,6,10,etc, k*(k-1)/2.
Such an N has i=k,j=k and thus gcd(i,j)=k,

    Y = j/gcd
      = 1       on the bottom row

    X = (i + j*(gcd-1)) / gcd
      = (k + k*(k-1)) / k
      = k-1     successive points on that row

=head2 Primes

All prime N values are above the sloping line X=2*Y.  There's composites
both above and below, but the primes are all above.  Here's the table with
"..." marking the X=2*Y line.

                 primes and composites above

     6  |      16              20      68
        |                                             .... X=2*Y
     5  |      11  12  13  14      47  49  51  53 ....
        |                                     ....
     4  |       7       9      30      34 .... 69
        |                             ....
     3  |       4   5      17  19 .... 39  42      70   composites
        |                     ....                      below
     2  |       2       8 .... 18      32      50
        |             ....
     1  |       1 ..3.  6  10  15  21  28  36  45  55
        |     ....
    Y=0 | ....
         ---------------------------------------------
          X=0   1   2   3   4   5   6   7   8   9  10

Only X=2,Y=1 is exactly on the line, which is prime N=3 as it happens.
Other X=2*k,Y=k is not an X/Y rational in least terms because it has common
factor k.  Values below X=2*Y such as 39 and 42 are all composites, values
above like 19 and 30 are either prime or composite.

This occurs because N is a multiple of gcd(i,j) when gcd odd, or a multiple
of gcd/2 when gcd even.

    N = i + j*(j-1)/2
    gcd = gcd(i,j)

    N = gcd   * (i/gcd + j/gcd * (j-1)/2)  when gcd odd
        gcd/2 * (2i/gcd + j/gcd * (j-1))   when gcd even

For gcd odd either j/gcd or j-1 is even to take the "/2".  When gcd is even
only gcd/2 can come out as a factor since the full gcd might leave both
j/gcd and j-1 odd and so the "/2" not an integer.  That happens for example
with N=70

    N = 70
    i = 4, j = 12   for  4 + 12*11/2 = 70
    gcd = 4
    but N is not a multiple of 4, only of 4/2=2

Of course the calculation only shows N is composite for odd gcdE<gt>=3 or
even gcd/2E<gt>=2, together meaning gcdE<gt>=3.  If gcdE<lt>3 then the
"factor" coming out is only 1 and so says nothing about whether N is prime
or composite.  There are in fact both prime and composite N for
gcdE<lt>3, as per the values above the X=2*Y line in the sample above.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over

=item C<$path = Math::PlanePath::GcdRationals-E<gt>new ()>

Create and return a new path object.

=back

=head1 FORMULAS

=head2 X,Y to N

The defining formula above can be reversed

    X/Y = i/j + g-1
    g-1 = floor(X/Y)

    Y = j/g
    X = ((g-1)*j + i)/g

    j = Y*g
    i = X*g - (g-1)*Y*g
    N = i + j*(j-1)/2

So

    N = X*g - (g-1)*Y*g + Y*g*(Y*g-1)/2
      = X*g + ((Y-2)*g + 1)*Y*g/2
      = (((Y-2)*g + 1)*Y + 2X)*g/2

The /2 division is exact.  If Y and g are both odd then (Y-2)*g+1 is
odd*odd+1 so even.

Y*g in the formulas is the next multiple of Y strictly greater than X.  It
can be formed from the g-1=floor(X/Y) division,

    X = Y*q + r     division
    g = q+1
    Y*g = Y*(q+1) = X+Y-r
        = X+Y-r

If you get the remainder for free in the X/Y division then using X+Y-r
instead of Y*g in the N formula might reduce a multiply to an add or
subtract.

=head2 Rectangle N Range

An over-estimate of the N range can be calculated just from the X,Y to N
formula above ignoring which X,Y points are coprime and thus actually should
have N values.

Within a row N increases with increasing X, so for a rectangle the minimum
is in the left column and the maximum in the right column.

Within a column N values increase until reaching the end of a "g" wedge,
then drop down a bit.  So the maximum is either the top-right corner or the
top of the next lower wedge, ie. smaller Y but bigger g.  And conversely the
minimum is either the bottom right, or the bottom of the next higher wedge,
ie. smaller g but bigger Y.  (That's right is it?)

=head1 OEIS

This enumeration of rationals is in Sloane's Online Encyclopedia of Integer
Sequences in the following forms

    http://oeis.org/A054531   (etc)

    A054531  - Y coordinate, ie. denominators

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DiagonalRationals>,
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
