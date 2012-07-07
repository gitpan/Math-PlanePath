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


# math-image --path=ImaginaryBase --lines --scale=10
# math-image --path=ImaginaryBase --all --output=numbers_dash --size=80x50
#
# cf A039724 negabinary in binary

package Math::PlanePath::ImaginaryBase;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 80;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;
*_digit_split_lowtohigh = \&Math::PlanePath::_digit_split_lowtohigh;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;

use constant parameter_info_array => [{ name      => 'radix',
                                        share_key => 'radix_2',
                                        type      => 'integer',
                                        minimum   => 2,
                                        default   => 2,
                                        width     => 3,
                                      }];

sub new {
  my $self = shift->SUPER::new(@_);

  my $radix = $self->{'radix'};
  if (! defined $radix || $radix <= 2) { $radix = 2; }
  $self->{'radix'} = $radix;

  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### ImaginaryBase n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  # ENHANCE-ME: lowest non-(r-1) determines direction to next, or something
  # like that
  {
    my $int = int($n);
    ### $int
    ### $n
    if ($n != $int) {
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $frac = $n - $int;  # inherit possible BigFloat
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int;       # BigFloat int() gives BigInt, use that
  }

  my $radix = $self->{'radix'};
  my $x = 0;
  my $y = 0;
  my $len = ($n*0)+1;  # inherit bignum 1

  if (my @digits = _digit_split_lowtohigh($n, $radix)) {
    $radix = -$radix;
    for (;;) {
      $x += (shift @digits) * $len;  # digits low to high
      @digits || last;

      $y += (shift @digits) * $len;  # digits low to high
      @digits || last;

      $len *= $radix;  # negative radix negate each time
    }
  }

  ### final: "$x,$y"
  return ($x,$y);
}

# ($x-$digit) and ($y-$digit) are multiples of $radix, but apply int() in
# case floating point rounding
#
sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### ImaginaryBase xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if (_is_infinite($x)) { return ($x); }
  if (_is_infinite($y)) { return ($y); }

  my $radix = $self->{'radix'};
  my $n = ($x * 0 * $y);  # inherit bignum 0
  my $power = $n + 1;     # inherit bignum 1

  while ($x || $y) {
    ### at: "$x,$y  digit ".($x % $radix)
    my $digit = $x % $radix;
    $n += $digit*$power;
    $power *= $radix;
    $x = - int(($x-$digit)/$radix);

    $digit = $y % $radix;
    $n += $digit*$power;
    $power *= $radix;
    $y = - int(($y-$digit)/$radix);
  }
  return $n;
}

# left xmax = (r-1) + (r^2 -r) + (r^3-r^2) + ... + (r^k - r^(k-1))
#           = r^(k-1) - 1
#
# right xmin = - (r + r^3 + ... + r^(2k+1))
#            = -r * (1 + r^2 + ... + r^2k)
#            = -r * ((r^2)^(k+1) -1) / (r^2 - 1)
#

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### ImaginaryBase rect_to_n_range(): "$x1,$y1  $x2,$y2"

  # ENHANCE-ME: Not too hard to track down the min/max block intersecting
  # the given rectangle.
  # ENHANCE-ME: Explicit formula for x/y min/max.

  foreach my $c ($x1,$y1, $x2,$y2) {
    if (_is_infinite($c)) {
      return (0, $c);
    }
    $c = _round_nearest($c);
  }
  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }

  my $radix = $self->{'radix'};
  my $xmin = 0;
  my $xmax = 0;
  my $ymin = 0;
  my $ymax = 0;
  my $width = 1;
  my $height = 1;
  my $power = 1;
  for (;;) {
    if ($xmin <= $x1 && $x2 <= $xmax
        && $ymin <= $y1 && $y2 <= $ymax) {
      return (0, $power-1);
    }
    $xmax += ($radix-1)*$width;
    $width *= $radix;
    $power *= $radix;

    if ($xmin <= $x1 && $x2 <= $xmax
        && $ymin <= $y1 && $y2 <= $ymax) {
      return (0, $power-1);
    }
    $ymax += ($radix-1)*$height;
    $height *= $radix;
    $power *= $radix;

    if ($xmin <= $x1 && $x2 <= $xmax
        && $ymin <= $y1 && $y2 <= $ymax) {
      return (0, $power-1);
    }
    $xmin -= ($radix-1)*$width;
    $width *= $radix;
    $power *= $radix;

    if ($xmin <= $x1 && $x2 <= $xmax
        && $ymin <= $y1 && $y2 <= $ymax) {
      return (0, $power-1);
    }
    $ymin -= ($radix-1)*$height;
    $height *= $radix;
    $power *= $radix;
  }
}

  # my $radix = $self->{'radix'};
  # $x1 = abs(_round_nearest($x1));
  # $y1 = abs(_round_nearest($y1));
  # $x2 = abs(_round_nearest($x2));
  # $y2 = abs(_round_nearest($y2));
  # my $xm = ($x1 > $x2 ? $x1 : $x2);
  # my $ym = ($y1 > $y2 ? $y1 : $y2);
  # my $max = ($xm > $ym ? $xm : $ym);
  #
  # my $level = 0;
  #
  # # cf $level = 2*ceil(log($max || 1) / log($radix)) + 3;
  # # $radix**$level - 1
  #
  # return (0, $max*$max * $radix**5);



1;
__END__








# x
#
#      60  61  62  63  44  45  46  47  28  29  30  31  12  13  14  15    6
#                                                                        5
#      56  57  58  59  40  41  42  43  24  25  26  27   8   9  10  11    4
#                                                                        3
#      52  53  54  55  36  37  38  39  20  21  22  23   4   5   6   7    2
#                                                                        1
#      48  49  50  51  32  33  34  35  16  17  18  19   0   1   2   3  Y=0
#                                                                       -1
#     124 125 126 127 108 109 110 111  92  93  94  95  76  77  78  79   -2
#                                                                       -3
#     120 121 122 123 104 105 106 107  88  89  90  91  72  73  74  75   -4
#                                                                       -5
#     116 117 118 119 100 101 102 103  84  85  86  87  68  69  70  71   -6
#                                                                       -7
#     112 113 114 115  96  97  98  99  80  81  82  83  64  65  66  67   -8
#
#                                                       ^
#     -12 -11 -10 -9  -8  -7  -6  -5  -4  -3  -2  -1  X=0  1   2   3
#

=for stopwords eg Ryde Math-PlanePath quater-imaginary ZOrderCurve Radix radix ie Negabinary negabinary ImaginaryBase negaternary negadecimal

=head1 NAME

Math::PlanePath::ImaginaryBase -- replications in four directions

=head1 SYNOPSIS

 use Math::PlanePath::ImaginaryBase;
 my $path = Math::PlanePath::ImaginaryBase->new (radix => 4);
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is a simple pattern arising from complex numbers expressed in a base
i*sqrt(2) or other i*sqrt(r) bases.  The default r=2 gives

    38   39   34   35   54   55   50   51        5
    36   37   32   33   52   53   48   49        4
    46   47   42   43   62   63   58   59        3
    44   45   40   41   60   61   56   57        2
     6    7    2    3   22   23   18   19        1
     4    5    0    1   20   21   16   17    <- Y=0
    14   15   10   11   30   31   26   27       -1
    12   13    8    9   28   29   24   25       -2
               ^
    -2   -1   X=0   1    2    3    4    5

The pattern can be seen by dividing into blocks as follows,

    +---------------------------------------+
    | 38   39   34   35   54   55   50   51 |
    |                                       |
    | 36   37   32   33   52   53   48   49 |
    |                                       |
    | 46   47   42   43   62   63   58   59 |
    |                                       |
    | 44   45   40   41   60   61   56   57 |
    +---------+---------+-------------------+
    |  6    7 |  2    3 | 22   23   18   19 |
    |         +----+----+                   |
    |  4    5 |  0 |  1 | 20   21   16   17 |
    +---------+----+----+                   |
    | 14   15   10   11 | 30   31   26   27 |
    |                   |                   |
    | 12   13    8    9 | 28   29   24   25 |
    +-------------------+-------------------+

After N=0 at the origin, N=1 is to the right.  Then those two repeat above
as N=2 and N=3.  Then that 2x2 block repeats to the right as N=4 to N=7,
then 4x2 repeated below as N=8 to N=16, and 4x4 to the right as N=16 to
N=31, etc.  Each repeat is 90 degrees further around.  The orientation and
relative layout is unchanged within each replicated part, there's no
rotation etc.

=head2 Complex Base

This pattern arises from representing a complex number in "base" b=i*sqrt(r)
with digits a[i] in the range 0 to r-1.  For integer X,Y,

    X+Y*i*sqrt(r) = a[n]*b^n + ... + a[2]*b^2 + a[1]*b + a[0]

and N is a base-r integer

    N = a[n]*r^n + ... + a[2]*r^2 + a[1]*r + a[0]

The factor sqrt(r) makes the generated Y an integer.  For actual use as a
number base that factor can be omitted and instead fractional digits
a[-1]*r^-1 etc used to reach smaller Y values, as for example in Knuth's
"quater-imaginary" system of base 2*i, ie. i*sqrt(4), with digits 0,1,2,3.

The powers of i in the base give the replication direction, so i^0=1 right,
i^1=i up, i^2=-1 right, i^3=-i down, etc.  The sqrt(r) part then spreads the
replication in the respective direction.  It takes two steps to repeat
horizontally and sqrt(r)^2=r hence the doubling of 1x1 to the right, 2x2 to
the left, 4x4 to the right, etc, and similarly vertically.

=head2 Radix

The C<radix> parameter controls the "r" used to break N into X,Y.  For
example radix 3 gives 3x3 blocks, with r-1 copies of the preceding level at
each stage,

    radix => 3

    24  25  26  15  16  17   6   7   8      2
    21  22  23  12  13  14   3   4   5      1
    18  19  20   9  10  11   0   1   2  <- Y=0
    51  52  53  42  43  44  33  34  35     -1
    48  49  50  39  40  41  30  31  32     -2
    45  46  47  36  37  38  27  28  29     -3
    78  79  80  69  70  71  60  61  62     -4
    75  76  77  66  67  68  57  58  59     -5
    72  73  74  63  64  65  54  55  56     -6

                             ^
    -6  -5  -4  -3  -2  -1  X=0  1   2

=head2 Z Order and Negabinary

The pattern can be compared to the ZOrderCurve.  In Z-Order the replications
are alternately right and up, but here they progress through four directions
right, up, left, down.

The alternate positive and negative X, and alternate positive and
negative Y likewise, follow the negabinary system.  If N is at X,Y on
the ZOrderCurve then those coordinates converted to negabinary give
the ImaginaryBase.

    zX,zY = ZOrderCurve n_to_xy(N)
    nX = to_negabinary(zX)
    nY = to_negabinary(zX)
    nX,nY equals ImaginaryBase n_to_xy(N)

For a radix other than binary the conversion is likewise, to
negaternary or negadecimal etc.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::ImaginaryBase-E<gt>new ()>

=item C<$path = Math::PlanePath::ImaginaryBase-E<gt>new (radix =E<gt> $r)>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::ZOrderCurve>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011, 2012 Kevin Ryde

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
