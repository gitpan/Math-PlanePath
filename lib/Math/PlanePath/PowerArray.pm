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


#
# Clark Kimberling
# http://faculty.evansville.edu/ck6/integer/intersp.html
#
# Classic Sequences
# http://oeis.org/classic.html
# A035506 stolarsky by diagonals
# A035507   inverse
# A082156
# A007067 stolarsky first column
# A019586 or, for the original form, A003603
# A035612
# A020941
# A135766 -- not divisible by 2,3,5, times 5^k, by triangle

package Math::PlanePath::PowerArray;
use 5.004;
use strict;
use List::Util 'max';

use vars '$VERSION', '@ISA';
$VERSION = 82;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'parameter_info_array';

# uncomment this to run the ### lines
#use Smart::Comments;

use constant n_start => 1;
use constant class_x_negative => 0;
use constant class_y_negative => 0;

sub new {
  my $self = shift->SUPER::new (@_);
  $self->{'radix'} = max ($self->{'radix'} || 0, 2); # default 2
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### PowerArray n_to_xy(): $n

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

  my $x = $n*0;
  my $radix = $self->{'radix'};
  until ($n % $radix) {
    $x++;
    $n /= $radix;
  }
  ### $x
  ### $n

  return ($x,
          $n - int($n/$radix) - 1); # collapse out multiples of radix
}

#   | 9
#   | 8
#   | 7
# 4 | 6 30
# 3 | 4 20
# 2 | 3 15
# 1 | 2 10
# 0 | 1  5 25 125
#   +------------
#
sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### PowerArray xy_to_n(): "$x, $y"

  $x = round_nearest ($x);
  $y = round_nearest ($y);
  if ($x < 0 || $y < 0) {
    return undef;
  }
  my $radix = $self->{'radix'};
  return ($radix + 0*$y) ** $x      # $y*0 to inherit bignum in power
    * ($y+1 + int($y/($radix-1)));  # stretch multiples of radix
}

# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### PowerArray rect_to_n_range(): "$x1,$y1  $x2,$y2"

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
  if ($x1 < 0) { $x1 *= 0; }  # *=0 to preserve bigint
  if ($y1 < 0) { $y1 *= 0; }

  return ($self->xy_to_n($x1,$y1),    # bottom left
          $self->xy_to_n($x2,$y2));   # top right
}

1;
__END__

=for stopwords Ryde Math-PlanePath Radix radix ie OEIS

=head1 NAME

Math::PlanePath::PowerArray -- array by powers

=head1 SYNOPSIS

 use Math::PlanePath::PowerArray;
 my $path = Math::PlanePath::PowerArray->new (radix => 2);
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is a split of N into an odd part and power of 2,

=cut

# math-image  --path=PowerArray --output=numbers --all --size=60x15

=pod

     14  |   29    58   116   232   464   928  1856  3712  7424 14848
     13  |   27    54   108   216   432   864  1728  3456  6912 13824
     12  |   25    50   100   200   400   800  1600  3200  6400 12800
     11  |   23    46    92   184   368   736  1472  2944  5888 11776
     10  |   21    42    84   168   336   672  1344  2688  5376 10752
      9  |   19    38    76   152   304   608  1216  2432  4864  9728
      8  |   17    34    68   136   272   544  1088  2176  4352  8704
      7  |   15    30    60   120   240   480   960  1920  3840  7680
      6  |   13    26    52   104   208   416   832  1664  3328  6656
      5  |   11    22    44    88   176   352   704  1408  2816  5632
      4  |    9    18    36    72   144   288   576  1152  2304  4608
      3  |    7    14    28    56   112   224   448   896  1792  3584
      2  |    5    10    20    40    80   160   320   640  1280  2560
      1  |    3     6    12    24    48    96   192   384   768  1536
    Y=0  |    1     2     4     8    16    32    64   128   256   512
         +-----------------------------------------------------------
            X=0     1     2     3     4     5     6     7     8     9

For N=odd*2^k the coordinates are X=k, Y=(odd-1)/2.  The X coordinate is how
many factors of 2 can be divided out.  The Y coordinate counts odd integers
1,3,5,7,etc as 0,1,2,3,etc.

=head2 Radix

The C<radix> parameter can do the same dividing out in a higher base.  For
example radix 3 divides out factors of 3,

=cut

# math-image  --path=PowerArray --output=numbers --all --size=50x10

=pod

     radix => 3

      9  |   14    42   126   378  1134  3402 10206 30618
      8  |   13    39   117   351  1053  3159  9477 28431
      7  |   11    33    99   297   891  2673  8019 24057
      6  |   10    30    90   270   810  2430  7290 21870
      5  |    8    24    72   216   648  1944  5832 17496
      4  |    7    21    63   189   567  1701  5103 15309
      3  |    5    15    45   135   405  1215  3645 10935
      2  |    4    12    36   108   324   972  2916  8748
      1  |    2     6    18    54   162   486  1458  4374
    Y=0  |    1     3     9    27    81   243   729  2187
         +------------------------------------------------
            X=0     1     2     3     4     5     6     7

N=1,3,9,27,etc along the X axis is the powers of 3.  N=1,2,4,5,7,etc on the
Y axis is the integers N=1mod3 and N=2mod3, ie. those not a multiple of 3.
Notice when Y=1or2 mod 4 the N values in that row are all even, and when
Y=0or3 mod 4 the N values are all odd.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::PowerArray-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 1 and if C<$n E<lt> 0> then the return is an empty list.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the N point number at coordinates C<$x,$y>.  If C<$xE<lt>0> or
C<$yE<lt>0> then there's no N and the return is C<undef>.

N values grow rapidly with C<$x>.  Pass in a number type such as
C<Math::BigInt> to preserve precision.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

The returned range is exact, meaning C<$n_lo> and C<$n_hi> are the smallest
and biggest in the rectangle.

=back

=head1 FORMULAS

=head2 Rectangle to N Range

Within each row increasing X is increasing N, and in each column increasing
Y is increasing N.  So in a rectangle the lower left corner is the minimum N
and the upper right is the maximum N.

=head1 OEIS

Entries in Sloane's Online Encyclopedia of Integer Sequences related to this
path include

    http://oeis.org/A007814  (etc)

    radix=2
      A007814    X coordinate, count low 0 bits of N
      A006519    2^X, the power of 2 divided out

      A025480    Y coordinate of N-1, ie. seq starts from N=0
      A003602    Y+1 coordinate, k for which N=(2k-1)*2^m
      A153733    2*Y coordinate of N-1, strip low 1 bits
      A000265    2*Y+1 coordinate, strip low 0 bits

      A094267    dX, change in X coordinate
      A108715    dY, change in Y coordinate

      A000079    N on X axis, powers 2^X
      A005408    N on Y axis, the odd numbers
      A057716    N not on X axis, the non-powers-of-2

      A118417    N on X=Y+1 diagonal (ie. just below X=Y diagonal)

      A054582    N by diagonals upwards
      A075300    N-1 by diagonals upwards
      A135764    N by diagonals downwards

    radix=3
      A000244    N on X axis, powers 3^X

      A135765    odd N by diagonals, delete the Y=1,2mod4 even rows

    radix=4
      A000302    N on X axis, powers 4^X

    radix=10
      A011557    N on X axis, powers 10^X

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::WythoffArray>,
L<Math::PlanePath::ZOrderCurve>

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
