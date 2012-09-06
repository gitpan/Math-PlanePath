# Copyright 2010, 2011, 2012 Kevin Ryde

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


# http://www.cut-the-knot.org/do_you_know/hilbert.shtml
#     Java applet
#
# http://www.woollythoughts.com/afghans/peano.html
#     Knitting
#
# http://www.geom.uiuc.edu/docs/reference/CRC-formulas/node36.html
#     Closed path, curved parts
#
# http://www.wolframalpha.com/entities/calculators/Peano_curve/jh/4o/im/
#     Curved corners tilted to a diamond, or is it an 8-step pattern?
#
# http://www.davidsalomon.name/DC2advertis/AppendC.pdf
#

package Math::PlanePath::HilbertCurve;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 88;
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


use constant n_start => 0;
use constant class_x_negative => 0;
use constant class_y_negative => 0;

sub n_to_xy {
  my ($self, $n) = @_;
  ### HilbertCurve n_to_xy(): $n
  ### hex: sprintf "%#X", $n

  if ($n < 0) { return; }
  if (is_infinite($n)) { return ($n,$n); }

  my $int = int($n);
  $n -= $int;   # fraction part

  my @digits = digit_split_lowtohigh($int,4)
    or return ($n, 0);

  my $x = my $y = ($int * 0);  # inherit bigint 0
  my $len = $y + 1;            # inherit bigint 1

  for (;;) {

    ### @digits
    my $digit = shift @digits; # low to high
    if ($digit == 0) {
      $x = $n + $x;
      $n = 0;
    } elsif ($digit == 1) {
      ($x,$y) = ($y+$len,$n+$x);   # transpose and offset
      $n = 0;
    } elsif ($digit == 2) {
      ($x,$y) = (-$n+$y+$len,$x+$len);   # transpose and offset
      $n = 0;
    } else {
      $x = $len-1 - $x;  # rot 180 and offset
      $y = 2*$len-1 - $y;
    }
    unless (@digits) {
      $y = $n + $y;
      last;
    }
    $len *= 2;

    ### @digits
    $digit = shift @digits; # low to high
    if ($digit == 0) {
      $y = $n + $y;
      $n = 0;
    } elsif ($digit == 1) {
      ($x,$y) = ($n+$y,$x+$len);   # transpose and offset
      $n = 0;
    } elsif ($digit == 2) {
      ($x,$y) = ($y+$len,-$n+$x+$len);   # transpose and offset
      $n = 0;
    } else {
      $x = 2*$len-1 - $x;  # rot 180
      $y = $len-1 - $y;
    }
    unless (@digits) {
      $x = $n + $x;
      last;
    }
    $len *= 2;
  }

  ### is: "$x,$y"
  return ($x, $y);
}

#        3--2
# i=0       |
#        0--1
#
#        1--2
# i=4    |  |
#        0  3
#
#        3  0
# i=8    |  |
#        2--1
#
#        1--0
# i=12   |
#        2--3
#
# my @n_to_x = (0, 1, 1, 0,   # i=0
#               0, 0, 1, 1,   # i=4
#               1, 1, 0, 0,   # i=8
#               1, 0, 0, 1,   # i=12
#              );
# my @n_to_y = (0, 0, 1, 1,   # i=0
#               0, 1, 1, 0,   # i=4
#               1, 0, 0, 1,   # i=8
#               1, 1, 0, 0,   # i=12
#              );
my @n_to_next_i = (4,   0,  0,  8,  # i=0
                   0,   4,  4, 12,  # i=4
                   12,  8,  8,  0,  # i=8
                   8,  12, 12,  4,  # i=12
                  );
my @yx_to_n = (0, 1, 3, 2,   # i=0
               0, 3, 1, 2,   # i=4
               2, 1, 3, 0,   # i=8
               2, 3, 1, 0,   # i=12
              );

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### HilbertCurve xy_to_n(): "$x, $y"

  $x = round_nearest ($x);
  $y = round_nearest ($y);

  if ($x < 0 || $y < 0) {
    return undef;
  }
  if (is_infinite($x)) {
    return $x;
  }
  if (is_infinite($y)) {
    return $y;
  }

  (undef, my $pos) = round_down_pow (($x > $y ? $x : $y),
                                     2);
  ### $pos
  ### assert: (1 << ($pos+1)) > $x
  ### assert: (1 << ($pos+1)) > $y

  my $n = ($x * 0 * $y); # inherit bignum 0

  my $i = ($pos & 1) << 2;
  while ($pos >= 0) {
    my $nbits = $yx_to_n[$i + (($x >> $pos) & 1) + ((($y >> $pos) & 1) << 1)];
    $n = ($n << 2) | $nbits;

    ### $pos
    ### $i
    ### x bit: ($x >> ($pos)) & 1
    ### y bit: ($y >> ($pos)) & 1
    ### t: $i + (($x >> $pos) & 1) + ((($y >> $pos) & 1) << 1)
    ### yx_to_n: $yx_to_n[$i + (($x >> $pos) & 1) + ((($y >> $pos) & 1) << 1)]
    ### next_i: $n_to_next_i[$i+$nbits]
    ### n: sprintf "%#X", $n

    $i = $n_to_next_i[$i + $nbits];
    $pos--;
  }

  return $n;
}


# generated by tools/hilbert-curve-table.pl
#
my @next_state = (4,0,0,12, 0,4,4,8, 12,8,8,4, 8,12,12,0);
my @digit_to_x = (0,1,1,0, 0,0,1,1, 1,0,0,1, 1,1,0,0);
my @digit_to_y = (0,0,1,1, 0,1,1,0, 1,1,0,0, 1,0,0,1);
my @min_digit = (0,0,1,0, 0,1,3,2, 2,undef,undef,undef,
                 0,0,3,0, 0,2,1,1, 2,undef,undef,undef,
                 2,2,3,1, 0,0,1,0, 0,undef,undef,undef,
                 2,1,1,2, 0,0,3,0, 0);
my @max_digit = (0,1,1,3, 3,2,3,3, 2,undef,undef,undef,
                 0,3,3,1, 3,3,1,2, 2,undef,undef,undef,
                 2,3,3,2, 3,3,1,1, 0,undef,undef,undef,
                 2,2,1,3, 3,1,3,3, 0);


# This finds the exact minimum/maximum N in the given rectangle.
#
# The strategy is similar to xy_to_n(), except that at each bit position
# instead of taking a bit of x,y from the input instead those bits are
# chosen from among the 4 sub-parts according to which has the maximum N and
# is within the given target rectangle.  The final result is both an $n_max
# and a $x_max,$y_max which is its position, but only the $n_max is
# returned.
#
# At a given sub-part the comparisons ask whether x1 is above or below the
# midpoint, and likewise x2,y1,y2.  Since x2>=x1 and y2>=y1 there's only 3
# combinations of x1>=cmp,x2>=cmp, not 4.
#

# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### HilbertCurve rect_to_n_range(): "$x1,$y1, $x2,$y2"

  $x1 = round_nearest ($x1);
  $y1 = round_nearest ($y1);
  $x2 = round_nearest ($x2);
  $y2 = round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  if ($x2 < 0 || $y2 < 0) {
    return (1, 0); # rectangle outside first quadrant
  }

  my $n_min = my $n_max
    = my $x_min = my $y_min
      = my $x_max = my $y_max
        = ($x1 * 0 * $x2 * $y1 * $y2); # inherit bignum 0

  my ($len, $level) = round_down_pow (($x2 > $y2 ? $x2 : $y2),
                                      2);
  ### $len
  ### $level
  if (is_infinite($level)) {
    return (0, $level);
  }
  my $min_state = my $max_state = ($level & 1 ? 4 : 0);

  while ($level >= 0) {
    {
      my $x_cmp = $x_min + $len;
      my $y_cmp = $y_min + $len;
      my $digit = $min_digit[3*$min_state
                             + ($x1 >= $x_cmp ? 2 : $x2 >= $x_cmp ? 1 : 0)
                             + ($y1 >= $y_cmp ? 6 : $y2 >= $y_cmp ? 3 : 0)];

      $n_min = 4*$n_min + $digit;
      $min_state += $digit;
      if ($digit_to_x[$min_state]) { $x_min += $len; }
      $y_min += $len * $digit_to_y[$min_state];
      $min_state = $next_state[$min_state];
    }
    {
      my $x_cmp = $x_max + $len;
      my $y_cmp = $y_max + $len;
      my $digit = $max_digit[3*$max_state
                             + ($x1 >= $x_cmp ? 2 : $x2 >= $x_cmp ? 1 : 0)
                             + ($y1 >= $y_cmp ? 6 : $y2 >= $y_cmp ? 3 : 0)];

      $n_max = 4*$n_max + $digit;
      $max_state += $digit;
      if ($digit_to_x[$max_state]) { $x_max += $len; }
      $y_max += $len * $digit_to_y[$max_state];
      $max_state = $next_state[$max_state];
    }

    $len = int($len/2);
    $level--;
  }

  return ($n_min, $n_max);
}

1;
__END__

=for :stopwords Ryde Math-PlanePath PlanePaths OEIS ZOrderCurve Gosper's HAKMEM Jorg Arndt's bitwise bignums fxtbook Ueber stetige Abbildung einer Linie auf ein FlE<228>chenstE<252>ck Mathematische Annalen DOI ascii lookup Arndt PlanePath ie

=head1 NAME

Math::PlanePath::HilbertCurve -- 2x2 self-similar quadrant traversal

=head1 SYNOPSIS

 use Math::PlanePath::HilbertCurve;
 my $path = Math::PlanePath::HilbertCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

X<Hilbert, David>This path is an integer version of the curve described by
David Hilbert in 1891 for filling a unit square.  It traverses a quadrant of
the plane one step at a time in a self-similar 2x2 pattern,

             ...
              |
      y=7    63--62  49--48--47  44--43--42
                  |   |       |   |       |
      y=6    60--61  50--51  46--45  40--41
              |           |           |
      y=5    59  56--55  52  33--34  39--38
              |   |   |   |   |   |       |
      y=4    58--57  54--53  32  35--36--37
                              |
      y=3     5---6   9--10  31  28--27--26
              |   |   |   |   |   |       |
      y=2     4   7---8  11  30--29  24--25
              |           |           |
      y=1     3---2  13--12  17--18  23--22
                  |   |       |   |       |
      y=0     0---1  14--15--16  19--20--21

            x=0   1   2   3   4   5   6   7

The start is a sideways U shape N=0 to N=3, then four of those are put
together in an upside-down U as

    5,6    9,10
    4,7--- 8,11
      |      |
    3,2   13,12
    0,1   14,15--

The orientation of the sub parts are chosen so the starts and ends are
adjacent, 3 next to 4, 7 next to 8, and 11 next to 12.

The process repeats, doubling in size each time and alternately sideways or
upside-down U with invert and/or transpose as necessary in the sub-parts.

The pattern is sometimes drawn with the first step 0->1 upwards instead of
to the right.  Right is used here since that's what most of the other
PlanePaths do.  Swap X and Y for upwards first instead.

See F<examples/hilbert-path.pl> in the Math-PlanePath sources for a sample
program printing the path pattern in ascii.

=head2 Level Ranges

Within a power-of-2 square 2x2, 4x4, 8x8, 16x16 etc (2^k)x(2^k) at the
origin, all the N values 0 to 2^(2*k)-1 are within the square.  The maximum
3, 15, 63, 255 etc 2^(2*k)-1 is alternately at the top left or bottom right
corner.

Because each step is by 1, the distance along the curve between two X,Y
points is the difference in their N values (as from C<xy_to_n()>).

On the X=Y diagonal N=0,2,8,10,32,etc is the integers using only digits 0
and 2 in base 4, or equivalently have even-numbered bits 0, like x0y0...z0.

=head2 Locality

The Hilbert curve is fairly well localized in the sense that a small
rectangle (or other shape) is usually a small range of N.  This property is
used in some database systems to store X,Y coordinates with the Hilbert N as
an index.  A search through an 2-D region is then usually a fairly modest
linear search through N values.  C<rect_to_n_range()> gives exact N range
for a rectangle, or see L<Rectangle to N Range> below for calculating on any
shape.

The N range can be large when crossing sub-parts.  In the sample above it
can be seen for instance adjacent points X=0,Y=3 and X=0,Y=4 have rather
widely spaced N values 5 and 58.

Fractional X,Y values can be indexed by extending the N calculation down
into X,Y binary fractions.  The code here doesn't do this, but could be
pressed into service by moving the binary point in X and Y an even number of
places, the same amount in each.  (An odd number of bits would require
swapping X,Y to compensate for the alternating transpose in part 0.)  The
resulting integer N is then divided down by a corresponding multiple of 4
binary places.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::HilbertCurve-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.  Integer positions are always just 1 apart either
horizontally or vertically, so the effect is that the fraction part is an
offset along either X or Y.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x,$y>.  Each integer N is
considered the centre of a unit square and an C<$x,$y> within that square
returns N.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

The returned range is exact, meaning C<$n_lo> and C<$n_hi> are the smallest
and biggest in the rectangle.

=back

=head1 FORMULAS

=head2 N to X,Y

Converting N to X,Y coordinates is reasonably straightforward.  The top two
bits of N is a configuration

    3--2                    1--2
       |    or transpose    |  |
    0--1                    0  3

according to whether it's an odd or even bit-pair position.  Then within
each of the "3" sub-parts there's also inverted forms

    1--0        3  0
    |           |  |
    2--3        2--1

Working N from high to low with a state variable can record whether there's
a transpose, an invert, or both, being four states altogether.  A bit pair
0,1,2,3 from N then gives a bit each of X,Y according to the configuration
and a new state which is the orientation of that sub-part.  William Gosper's
HAKMEM item 115 has this with tables for the state and X,Y bits,

    http://www.inwap.com/pdp10/hbaker/hakmem/topology.html#item115

And C++ code based on that in Jorg Arndt's book,

    http://www.jjj.de/fxt/#fxtbook   (section 1.31.1)

It also works to process N from low to high, at each stage applying any
transpose (swap X,Y) and/or invert (bitwise NOT) to the low X,Y bits
generated so far.  This works because there's no "reverse" sections, or
since the curve is the same forward and reverse.  Low to high saves locating
the top bits of N, but if using bignums then the bitwise inverts of the full
X,Y values will be much more work.

=head2 X,Y to N

X,Y to N can follow the table approach from high to low taking one bit from
X and Y each time.  The state table of N-pair -> X-bit,Y-bit is reversible,
and a new state is based on the N-pair thus obtained (or could be based on
the X,Y bits if that mapping is combined into the state transition table).

=head2 Rectangle to N Range

An easy over-estimate of the maximum N in a region can be had by finding the
next bigger (2^k)x(2^k) square enclosing the region.  This means the biggest
X or Y rounded up to the next power of 2, so

    find lowest k with 2^k > max(X,Y)
    N_max = 2^(2k) - 1

Or equivalently rounding down to the next lower power of 2,

    find highest k with 2^k <= max(X,Y)
    N_max = 2^(2*(k+1)) - 1

An exact N range can be found by following the high to low N to X,Y
procedure above.  Start at the 2^(2k) bit pair position in an N bigger than
the desired region and choose 2 bits for N to give a bit each of X and Y.
The X,Y bits are based on the state table as above and the bits chosen for N
are those for which the resulting X,Y sub-square overlaps some of the target
region.  The smallest N similarly, choosing the smallest bit pair for N
which overlaps.

The biggest and smallest N digit for a sub-part can be found with a lookup
table.  The X range might cover one or both sub-parts, and the Y range
similarly, for a total 9 possible configurations.  Then a table of
state+coverage -E<gt> digit gives the minimum and maximum N bit-pair, and
state+digit gives a new state the same as X,Y to N.

Biggest and smallest N must be calculated with separate state and X,Y values
since they track down different N bits and thus different states.  But they
take the same number of steps from an enclosing level down to level 0 and
can thus be done in a single loop.

The N range for any shape can be found this way, not just a rectangle like
C<rect_to_n_range()>.  At each level the procedure only depends on asking
which combination of the four sub-parts overlaps some of the target area.

=head2 Direction

Each step between successive N values is always 1 up, down, left or right.
The next direction can be calculated from N in the high-to-low procedure
above by watching for the lowest non-3 digit and noting the direction from
that digit towards digit+1.  That can be had from the state+digit -E<gt> X,Y
table looking up digit and digit+1, or alternatively a further table
encoding state+digit -E<gt> direction.

The reason for taking only the lowest non-3 digit is that in a 3 sub-part
the direction it goes is determined by the next higher level.  For example
at N=11 the direction is down for the inverted-U of the next higher level
N=0,4,8,12.

This non-3 (or non whatever highest digit) is a general procedure and can be
used on any state-based high-to-low procedure of self-similar curves.  In
the current code it's used to apply a fractional part of N in the correct
direction but is not otherwise made directly available.

Because the Hilbert curve has no "reversal" sections it also works to build
a direction from low to high N digits.  1 and 2 digits make no change to the
orientation, 0 digit is a transpose, and a 3 digit is a rotate and
transpose, except that low 3s are transpose-only (no rotate) for the same
reason as taking the lowest non-3 above.

Jorg Arndt in the fxtbook above notes the direction can be obtained just by
counting 3s in n and twos-complement -n.  The only thing to note is that the
numbering there starts n=1, unlike the PlanePath starting N=0, so it becomes

    N+1 count 3s  / 0 mod 2   S or E
                  \ 1 mod 2   N or W

    -(N+1) count 3s  / 0 mod 2   N or E
                     \ 1 mod 2   S or W

For the twos-complement negation an even number of base-4 digits of N must
be taken.  Because -(N+1) = ~N, ie. a ones-complement, the second part is
also

    N count 0s         / 0 mod 2   N or E
    [even num digits]  \ 1 mod 2   S or W

Putting the two together then

    N count 0s   N+1 count 3s    direction (0=E,1=N,etc)
     
      0 mod 2      0 mod 2          0
      1 mod 2      0 mod 2          3
      0 mod 2      1 mod 2          1
      1 mod 2      1 mod 2          2

=head1 OEIS

This path is in Sloane's OEIS in many forms,

    http://oeis.org/A059252  (etc)

    A059252    Y coord
    A059253    X coord
    A059261    X+Y
    A059285    X-Y
    A163547    X^2+Y^2 radius squared
    A163365    sum N on diagonal
    A163477    sum N on diagonal, divided by 4
    A163482    N values on X axis
    A163483    N values on Y axis
    A062880    N values on diagonal X=Y (digits 0,2 in base 4)
    A163538    X change -1,0,1
    A163539    Y change -1,0,1
    A163540    absolute direction of each step (0=E,1=S,2=W,3=N)
    A163541    absolute direction, swapped X,Y
    A163542    relative direction (ahead=0,right=1,left=2)
    A163543    relative direction, swapped X,Y
    A163900    distance dX^2+dY^2 between Hilbert and ZOrder

The following take points of the plane in various orders, each value in the
sequence being the N of the Hilbert curve at those positions.

    A163355    in the ZOrderCurve sequence
    A163357    in diagonals like Math::PlanePath::Diagonals with
               first Hilbert step along same axis the diagonals start
    A163359    in diagonals, transposed start along the opposite axis
    A163361    A163357 + 1, numbering the Hilbert N's from N=1
    A163363    A163355 + 1, numbering the Hilbert N's from N=1

These sequences are in each case permutations of the integers since all X,Y
positions of the first quadrant are covered by each path.  The inverse
permutations are as follows.  They can be thought of taking X,Y positions in
the Hilbert order and asking what N the ZOrderCurve or Diagonals path would
put there.

    A163356    inverse of A163355  (ZOrderCurve)
    A163358    inverse of A163357  (Diagonals same axis)
    A163360    inverse of A163359  (Diagonals opposite)
    A163362    inverse of A163361  (Diagonals N=1)
    A163364    inverse of A163363  (Diagonals N=1 opposite)

The A163355 ZOrderCurve ordering is a permutation of the integers and
repeats or cycles can be considered,

    A163905    ZOrderCurve permutation A163355 applied twice
    A163915    ZOrderCurve permutation A163355 applied three times
    A163901    fixed points (N where X,Y same in both curves)
    A163902    2-cycle points
    A163903    3-cycle points
    A163890    cycle lengths, points by N
    A163904    cycle lengths, points by diagonals
    A163910    count of cycles in 4^k blocks
    A163911    max cycle length in 4^k blocks
    A163912    LCM of cycle lengths in 4^k blocks
    A163914    count of 3-cycles in 4^k blocks
    A163909      those counts for even k only
    A163891    N of previously unseen cycle length
    A163893      first differences of those A163891
    A163894    smallest value not an n-cycle
    A163895      position of new high in A163894
    A163896      value of new high in A163894

    A163907    ZOrderCurve permutation twice, on points by diagonals
    A163908      inverse of this

See F<examples/hilbert-oeis.pl> in the Math-PlanePath sources for a sample
program printing the A163359 permutation values.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PeanoCurve>,
L<Math::PlanePath::ZOrderCurve>,
L<Math::PlanePath::BetaOmega>,
L<Math::PlanePath::KochCurve>

L<Math::Curve::Hilbert>,
L<Algorithm::SpatialIndex::Strategy::QuadTree>

David Hilbert, "Ueber die stetige Abbildung einer Line auf ein
FlE<228>chenstE<252>ck", Mathematische Annalen, volume 38, number 3,
p459-460,

    http://www.springerlink.com/content/v1u6427kk33k8j56/
    DOI 10.1007/BF01199431
    http://notendur.hi.is/oddur/hilbert/gcs-wrapper-1.pdf

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2010, 2011, 2012 Kevin Ryde

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


# Local variables:
# compile-command: "math-image --path=HilbertCurve --lines --scale=20"
# End:

# math-image --path=HilbertCurve --all --output=numbers_dash --size=70x30
