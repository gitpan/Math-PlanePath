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


# diagonals_down even/odd in wedges, and other modulo


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

use vars '$VERSION', '@ISA';
$VERSION = 84;
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

use constant parameter_info_array =>
  [ { name        => 'pairs_order',
      type        => 'enum',
      default     => 'rows',
      choices     => ['rows','rows_reverse','diagonals_down','diagonals_up'],
      choices_display => ['Rows',
                          'Rows Reverse',
                          'Diagonals Down',
                          'Diagonals Up'],
      description => 'Order in the i,j pairs.',
    } ];

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
  $x = round_nearest ($x);
  $y = round_nearest ($y);
  ### GcdRationals xy_to_n(): "$x,$y"

  if (is_infinite($x)) { return $x; }
  if (is_infinite($y)) { return $y; }
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
#
# at X=Y+1 g=2
# nhi = (y*((y-2)*g + 1) / 2 + x)*g
#     = (y*((y-2)*2 + 1) / 2 + y+1)*2
#     = (y*(2y-4 + 1) / 2 + y+1)*2
#     = (y*(2y-3) / 2 + y+1)*2
#     = y*(2y-3)  + 2y+2
#     = 2y^2 - 3y + 2y + 2
#     = 2y^2 - y + 2
#     = y*(2y-1) + 2

# 11  12  13  14      47  49  51  53     108 111 114 117     194 198 202 206     
#  7       9      30      34      69      75     124     132     195     205     
#  4   5      17  19      39  42      70  74     110 115     159 165     217
#  2       8      18      32      50      72      98     128     162     200     
#  1   3   6  10  15  21  28  36  45  55  66  78  91 105 120 136 153 171 190

# 206=20*19/2+16  i=16,j=20 gcd=4
# 19,5 is slope=floor(19/5)=3 so g=4
#
# 205=20*19/2+15  i=15,j=20 gcd=5
# 19,4 is slope=floor(19/4)=4 so g=5
#
# 217=21*20/2 + 7, i=21,j=7  gcd=7
# 19,3 is slope=floor(19/3)=6 so g=7

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = round_nearest ($x1);
  $y1 = round_nearest ($y1);
  $x2 = round_nearest ($x2);
  $y2 = round_nearest ($y2);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### $x2
  ### $y2

  if ($x2 < 1 || $y2 < 1) {
    return (1, 0);  # outside quadrant
  }

  if ($x1 < 1) { $x1 = 1; }
  if ($y1 < 1) { $y1 = 1; }

  if ($self->{'pairs_order'} =~ /^diagonals/) {
    my $d = $x2 + max($x2,$y2);
    return (1, int($d*($d+($d%2)) / 4));  # N end of diagonal d
  }

  my $nhi;
  {
    my $c = max($x2,$y2);
    $nhi = _pairs_order__rows__xyg_to_n($c,$c,2);

    # my $rev = ($self->{'pairs_order'} eq 'rows_reverse');
    # my $slope = int($x2/$y2);
    # my $g = $slope + 1;
    #
    # # within top row
    # {
    #   my $x;
    #   if ($rev) {
    #     if ($slope > 0) {
    #       $x = max ($x1, $y2*$slope);  # left-most within this wedge
    #     } else {
    #       $x = $x1;  # top-left corner
    #     }
    #   } else {
    #     # pairs_order=rows
    #     $x = $x2;  # top-right corner
    #   }
    #   $nhi = $self->{'pairs_order_xyg_to_n'}->($x, $y2, $g);
    #
    #   ### $slope
    #   ### $g
    #   ### x for hi: $x
    #   ### nhi for x,y2: $nhi
    # }
    #
    # # within x2 column, top of wedge below
    # #
    # my $yw = int(($x2+$g-1) / $g); # rounded up
    # if ($yw >= $y1) {
    #   $nhi = max ($nhi, $self->{'pairs_order_xyg_to_n'}->($x2,$yw,$g+1));
    #
    #   ### $yw
    #   ### nhi_wedge: $self->{'pairs_order_xyg_to_n'}->($x2,$yw,$g+1)
    # }
    #   my $yw = int($x2 / $g) - ($g==1);  # below X=Y diagonal when g==1
    #   if ($yw >= $y1) {
    #     $g = int($x2/$yw) + 1;  # perhaps went across more than one wedge
    #     $nhi = max ($nhi,
    #                 ($yw*(($yw-2)*($g+1) + 1) / 2 + $x2)*($g+1));
    #     ### $yw
    #     ### nhi_wedge: ($yw*(($yw-2)*($g+1) + 1) / 2 + $x2)*($g+1)
    #   }
  }

  my $nlo;
  {
    $nlo = _pairs_order__rows__xyg_to_n(1,$x1,1);

    # my $g = int($x1/$y1) + 1;
    # $nlo = $self->{'pairs_order_xyg_to_n'}->($x1,$y1,$g);
    #
    # ### glo: $g
    # ### $nlo
    #
    # if ($g > 1) {
    #   my $yw = max (int($x1 / $g),
    #                 1);
    #   ### $yw
    #   if ($yw <= $y2) {
    #     $g = int($x1/$yw); # no +1, and perhaps up across more than one wedge
    #     $nlo = min ($nlo, $self->{'pairs_order_xyg_to_n'}->($x1,$yw,$g));
    #     ### glo_wedge: $g
    #     ### nlo_wedge: $self->{'pairs_order_xyg_to_n'}->($x1,$yw,$g)
    #   }
    # }
    # if ($nlo < 1) {
    #   $nlo = 1;
    # }
  }

  ### $nhi
  ### $nlo
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



# # old code, rows only ...
# sub rect_to_n_range {
#   my ($self, $x1,$y1, $x2,$y2) = @_;
#   ### rect_to_n_range(): "$x1,$y1  $x2,$y2"
# 
#   $x1 = round_nearest ($x1);
#   $y1 = round_nearest ($y1);
#   $x2 = round_nearest ($x2);
#   $y2 = round_nearest ($y2);
# 
#   ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
#   ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
#   ### $x2
#   ### $y2
# 
#   if ($x2 < 1 || $y2 < 1) {
#     return (1, 0);  # outside quadrant
#   }
# 
#   if ($x1 < 1) { $x1 = 1; }
#   if ($y1 < 1) { $y1 = 1; }
# 
#   my $g = int($x2/$y2) + 1;
#   my $nhi = ($y2*(($y2-2)*$g + 1) / 2 + $x2)*$g;
#   ### ghi: $g
#   ### $nhi
# 
#   my $yw = int($x2 / $g) - ($g==1);  # below X=Y diagonal when g==1
#   if ($yw >= $y1) {
#     $g = int($x2/$yw) + 1;  # perhaps went across more than one wedge
#     $nhi = max ($nhi,
#                 ($yw*(($yw-2)*($g+1) + 1) / 2 + $x2)*($g+1));
#     ### $yw
#     ### nhi_wedge: ($yw*(($yw-2)*($g+1) + 1) / 2 + $x2)*($g+1)
#   }
# 
#   $g = int($x1/$y1) + 1;
#   my $nlo = ($y1*(($y1-2)*$g + 1) / 2 + $x1)*$g;
# 
#   ### glo: $g
#   ### $nlo
# 
#   if ($g > 1) {
#     $yw = max (int($x1 / $g),
#                1);
#     ### $yw
#     if ($yw <= $y2) {
#       $g = int($x1/$yw); # no +1, and perhaps up across more than one wedge
#       $nlo = min ($nlo,
#                   ($yw*(($yw-2)*$g + 1) / 2 + $x1)*$g);
#       ### glo_wedge: $g
#       ### nlo_wedge: ($yw*(($yw-2)*$g + 1) / 2 + $x1)*$g
#     }
#   }
# 
#   return ($nlo, $nhi);
# }


1;
__END__

=for stopwords eg Ryde OEIS ie Math-PlanePath GCD gcd PyramidRows Fortnow coprime triangulars DiagonalsOctant

=head1 NAME

Math::PlanePath::GcdRationals -- rationals by triangular GCD

=head1 SYNOPSIS

 use Math::PlanePath::GcdRationals;
 my $path = Math::PlanePath::GcdRationals->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

X<Fortnow, Lance>This path enumerates X/Y rationals using a method by Lance
Fortnow taking a greatest common divisor out of a triangular position.  It
has the attraction of being both efficient to calculate (a GCD) and
completing X/Y blocks with a much smaller N range than the tree based
rationals.

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

The mapping from N to rational is

    N = i + j*(j-1)/2     upper triangle 1 <= i <= j
    gcd = GCD(i,j)
    rational = i/j + gcd-1

which means

    X = (i + j*(gcd-1)) / gcd
    Y = j/gcd

The i,j position is a numbering of points above the X=Y diagonal by rows, in
the style of PyramidRows step=1.

    j=4  7  8  9  10
    j=3  4  5  6
    j=2  2  3
    j=1  1
       i=1  2  3  4

If GCD(i,j)=1 then X/Y is simply X=i,Y=j unchanged.  This means fractions
S<X/Y E<lt> 1> are numbered by rows with increasing numerator, but skipping
positions where i,j have a common factor.

The skipped positions where i,j have a common factor become rationals
S<X/YE<gt>1>, ie. below the X=Y diagonal.  GCD(i,j)-1 is the integer part as
S<R = i/j+(gcd-1)>.  For example N=51 is at i=6,j=10 by rows and that i,j
has common factor gcd(6,10)=2 so becomes rational R = 6/10+(2-1) = 3/5+1 =
8/5, ie. X=8,Y=5.

=head2 Triangular Numbers

The bottom row Y=1 is the triangular numbers N=1,3,6,10,etc, k*(k-1)/2.
Such an N is at i=k,j=k and thus gcd(i,j)=k which divides out to Y=1.

    Y = j/gcd
      = 1       on the bottom row

    X = (i + j*(gcd-1)) / gcd
      = (k + k*(k-1)) / k
      = k-1     successive points on that bottom row

N=1,2,4,7,11,etc in the vertical at X=1 immediately following those
triangulars on the bottom row, ie.

    N on X=1 column = Y*(Y-1)/2 + 1

=head2 Primes

If N is prime then it's above the sloping line X=2*Y.  If N is composite
then it might be above or below, but the primes are always above.  Here's
the table with dots "..." for the X=2*Y line.

           primes and composites above

     6  |      16              20      68
        |                                             .... X=2*Y
     5  |      11  12  13  14      47  49  51  53 ....
        |                                     ....
     4  |       7       9      30      34 .... 69
        |                             ....
     3  |       4   5      17  19 .... 39  42      70   always
        |                     ....                      composite
     2  |       2       8 .... 18      32      50       below
        |             ....
     1  |       1 ..3.  6  10  15  21  28  36  45  55
        |     ....
    Y=0 | ....
         ---------------------------------------------
          X=0   1   2   3   4   5   6   7   8   9  10

Values below X=2*Y such as 39 and 42 are always composite.  Values above
such as 19 and 30 are either prime or composite.  Only X=2,Y=1 is exactly on
the line, which is prime N=3 as it happens.  Other X=2*k,Y=k are not an X/Y
rational in least terms because it has common factor k.

This pattern of primes and composites occurs because N is a multiple of
gcd(i,j) when gcd odd, or a multiple of gcd/2 when gcd even.

    N = i + j*(j-1)/2
    gcd = gcd(i,j)

    N = gcd   * (i/gcd + j/gcd * (j-1)/2)  when gcd odd
        gcd/2 * (2i/gcd + j/gcd * (j-1))   when gcd even

If gcd odd then either j/gcd or j-1 is even, taking the "/2".  If gcd even
then only gcd/2 can come out as a factor since the full gcd might leave both
j/gcd and j-1 odd and so the "/2" not an integer.  That happens for example
to N=70

    N = 70
    i = 4, j = 12     for 4 + 12*11/2 = 70 = N
    gcd(i,j) = 4
    but N is not a multiple of 4, only of 4/2=2

Of course knowing gcd or gcd/2 is a factor is only useful when that factor
is 2 or more, so only

    odd gcd with gcd >= 2       means gcd >= 3
    even gcd with gcd/2 >= 2    means gcd >= 4

    so N composite when gcd(i,j) >= 3

If gcdE<lt>3 then the "factor" coming out is only 1 and says nothing about
whether N is prime or composite.  There are both prime and composite N for
gcdE<lt>3, as can be seen among the values above the X=2*Y line in the table
above.

=head2 Rows Reverse

Option C<pairs_order =E<gt> "rows_reverse"> reverses the order of points
within the rows of i,j pairs,

    j=4  10  9  8  7
    j=3   6  5  4
    j=2   3  2
    j=1   1
        i=1  2  3  4

The point numbering becomes

=cut

# math-image --path=GcdRationals,pairs_order=rows_reverse --all --output=numbers

=pod

    pairs_order => "rows_reverse"

    11  |      66  65  64  63  62  61  60  59  58  57
    10  |      55      53              49      47     209
     9  |      45  44      42  41      39  38     170 168
     8  |      36      34      32      30     135     131
     7  |      28  27  26  25  24  23     104 102 100  98
     6  |      21              17      77              69
     5  |      15  14  13  12      54  52  50  48     118
     4  |      10       8      35      31      76      70
     3  |       6   5      20  18      43  40      75  71
     2  |       3       9      19      33      51      73
     1  |       1   2   4   7  11  16  22  29  37  46  56
    Y=0 |
         ------------------------------------------------
          X=0   1   2   3   4   5   6   7   8   9  10  11

The triangular numbers per L</Triangular Numbers> above are now in the X=1
column, ie. at the left rather than the bottom.  The Y=1 bottom row is the
next after each triangular, ie. T(X)+1.

=head2 Diagonals

Option C<pairs_order =E<gt> "diagonals_down"> takes the i,j pairs by
diagonals down from the Y axis.  C<pairs_order =E<gt> "diagonals_up">
likewise but upwards from the X=Y centre up to the Y axis.  This is in the
style of the DiagonalsOctant path.

    diagonals_down                    diagonals_up

    j=7  13                           j=7  16
    j=6  10 14                        j=6  12 15
    j=5   7 11 15                     j=5   9 11 14
    j=4   5  8 12 16                  j=4   6  8 10 13
    j=3   3  6  9                     j=3   4  5  7
    j=2   2  4                        j=2   2  3
    j=1   1                           j=1   1
        i=1  2  3  4                      i=1  2  3  4

The resulting path becomes

=cut

# math-image --path=GcdRationals,pairs_order=diagonals_down --all --output=numbers --size=40x10
# math-image --path=GcdRationals,pairs_order=diagonals_up --all --output=numbers --size=40x10

=pod

    pairs_order => "diagonals_down"

     9  |     21 27    40 47    63 72
     8  |     17    28    41    56    74
     7  |     13 18 23 29 35 42    58 76
     6  |     10          30    44
     5  |      7 11 15 20    32 46 62 80
     4  |      5    12    22    48    52
     3  |      3  6    14 24    33 55
     2  |      2     8    19    34    54
     1  |      1  4  9 16 25 36 49 64 81
    Y=0 |
         --------------------------------
          X=0  1  2  3  4  5  6  7  8  9

    pairs_order => "diagonals_up"

     9  |     25 29    39 45    58 65
     8  |     20    28    38    50    80
     7  |     16 19 23 27 32 37    63 78
     6  |     12          26    48
     5  |      9 11 14 17    35 46 59 74
     4  |      6    10    24    44    54
     3  |      4  5    15 22    34 51
     2  |      2     8    18    33    52
     1  |      1  3  7 13 21 31 43 57 73
    Y=0 |
         --------------------------------
          X=0  1  2  3  4  5  6  7  8  9

For "diagonals_down" the Y=1 bottom row is the perfect squares which are at
i=j in the DiagonalsOctant and have gcd(i,j)=i thus becoming X=i,Y=1.

The gcd shears moves points downwards and shears them across horizontally.

      | 1
      |   1     gcd=1 slope=-1
      |     1
      |       1
      |         1
      |           1
      |             1
      |               1
      |                 1
      |                 .    gcd=2 slope=0
      |               .   2
      |             .     2     3  gcd=3 slope=1
      |           .       2   3           gcd=4 slope=2
      |         .         2 3         4
      |       .           3       4       5     gcd=5 slope=3
      |     .                 4      5
      |   .               4     5
      | .                 5
      +-------------------------------

The line of "1"s is the diagonal with gcd=1 and thus X,Y=i,j unchanged.

The line of "2"s is when gcd=2 so X=(i+j)/2,Y=j/2.  Since i+j=d is constant
within the diagonal this makes X=d fixed, ie. a vertical.

Then gcd=3 becomes X=(i+2j)/3 which slopes across by +1 for each i, or gcd=4
X=(i+3j)/4 slope +2, etc.

Of course only some of the points in a diagonal have a given gcd, but those
which do are transformed this way.  The effect is that for N up to a given
diagonal row all the "*" points in the following are traversed, plus extras
in wedge shaped arms out to the side.

     | *
     | * *                 up to a given diagonal points "*"
     | * * *               all visited, plus some wedges out
     | * * * *             to the right
     | * * * * *
     | * * * * *   /
     | * * * * * /  --
     | * * * * *  --
     | * * * * *--
     +--------------

In terms of the rationals X/Y the effect is that up to N=d^2 diagonal d=2j
the fractions enumerated are

    N=d^2
    enumerates to num <= d and num+den <= 2*d

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over

=item C<$path = Math::PlanePath::GcdRationals-E<gt>new ()>

=item C<$path = Math::PlanePath::GcdRationals-E<gt>new (pairs_order =E<gt> $str)>

Create and return a new path object.  The C<pairs_order> option can be

    "rows"               (default)
    "rows_reverse"
    "diagonals_down"
    "diagonals_up"

=back

=head1 FORMULAS

=head2 X,Y to N

The defining formula above for X,Y can be reversed

    X/Y = i/j + g-1
    g-1 = floor(X/Y)

    Y = j/g
    X = ((g-1)*j + i)/g

so

    j = Y*g
    i = X*g - (g-1)*Y*g

So
    N = i + j*(j-1)/2
      = X*g - (g-1)*Y*g + Y*g*(Y*g-1)/2
      = X*g + ((Y-2)*g + 1)*Y*g/2
      = (((Y-2)*g + 1)*Y + 2X)*g/2

The /2 division is exact.  If Y and g are both odd and so don't take that
divisor then the term (Y-2)*g+1 is odd*odd+1 so even.

Y*g in the formulas is the first multiple of Y which is strictly greater
than X.  It can be formed from the g-1=floor(X/Y) division,

    X = Y*quot + rem     division
    g = quot+1
    Y*g = Y*(q+1) = X+Y-rem
        = X+Y-rem

If a division gives quotient and remainder for the same price then X+Y-rem
instead of Y*g might reduce a multiply to instead an add or subtract.

=cut

# No, not quite
#
# =head2 Rectangle N Range -- Rows
# 
# An over-estimate of the N range can be calculated just from the X,Y to N
# formula above.
# 
# Within a row N increases with increasing X, so for a rectangle the minimum
# is in the left column and the maximum in the right column.
# 
# Within a column N values increase until reaching the end of a "g" wedge,
# then drop down a bit.  So the maximum is either the top-right corner of the
# rectangle, or the top of the next lower wedge, ie. smaller Y but bigger g.
# Conversely the minimum is either the bottom right of the rectangle, or the
# bottom of the next higher wedge, ie. smaller g but bigger Y.  (Is that
# right?)
# 
# This is an over-estimate because it ignores which X,Y points are coprime and
# thus actually should have N values.
# 
# =head2 Rectangle N Range -- Rows Reverse
# 
# When row pairs are taken in reverse order increasing X is not increasing N,
# but rather the maximum N of a row is at the left end of the wedge.

=pod

=head1 OEIS

This enumeration of rationals is in Sloane's Online Encyclopedia of Integer
Sequences in the following forms

    http://oeis.org/A054531   (etc)

    A054531  - Y coordinate, ie. denominators

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DiagonalRationals>,
L<Math::PlanePath::RationalsTree>,
L<Math::PlanePath::CoprimeColumns>,
L<Math::PlanePath::DiagonalsOctant>

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
