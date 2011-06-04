# Copyright 2010, 2011 Kevin Ryde

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
use List::Util qw(min max);
use POSIX qw(floor ceil);

use vars '$VERSION', '@ISA';
$VERSION = 31;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant n_start => 0;
use constant x_negative => 0;
use constant y_negative => 0;

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
my @n_to_next_i = (4,   0,  0,  8,  # i=0
                   0,   4,  4, 12,  # i=4
                   12,  8,  8,  0,  # i=8
                   8,  12, 12,  4,  # i=12
                  );
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

my @yx_to_n = (0, 1, 3, 2,   # i=0
               0, 3, 1, 2,   # i=4
               2, 1, 3, 0,   # i=8
               2, 3, 1, 0,   # i=12
              );

sub n_to_xy {
  my ($self, $n) = @_;
  ### HilbertCurve n_to_xy(): $n
  ### hex: sprintf "%#X", $n
  if ($n < 0 || _is_infinite($n)) {
    return;
  }

  if (int($n) != $n) {
    my ($x1,$y1) = $self->n_to_xy(floor($n));
    my ($x2,$y2) = $self->n_to_xy(ceil($n));
    return (($x1+$x2)/2, ($y1+$y2)/2);
  }
  # $n = floor ($n - 0.5);

  my $x = my $y = ($n & 0); # inherit

  my $invert = $x; # inherit
  my $add = 1;
  my $bits;
  for (;;) {
    ### bits: $n & 3
    if (($bits = ($n & 3)) == 3) {
      $x ^= $invert;
      $y ^= $invert;
    } elsif ($bits) {      # 1,2
      ($x,$y) = ($y,$x);
      $x += $add;
    }
    if ($bits & 2) {       # 2,3
      $y += $add;
    }
    last unless $n >>= 2;
    ($invert <<= 1)++;
    $add <<= 1;

    ### bits: $n & 3
    if (($bits = ($n & 3)) == 3) {
      $x ^= $invert;
      $y ^= $invert;
    } elsif ($bits) {      # 1,2
      ($x,$y) = ($y,$x);
      $y += $add;
    }
    if ($bits & 2) {       # 2,3
      $x += $add;
    }
    last unless $n >>= 2;
    ($invert <<= 1)++;
    $add <<= 1;
  }

  ### is: "$x,$y"
  return ($x, $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### HilbertCurve xy_to_n(): "$x, $y"

  $x = floor($x + 0.5);
  $y = floor($y + 0.5);
  if ($x < 0 || $y < 0) {
    return undef;
  }
  my $n = ($x & 0); # inherit

  my $pos = 0;
  {
    my $m = max ($x, $y);
    if (_is_infinite($m)) {
      return undef;
    }

    my $pow = $n + 2;        # inherit
    while ($m >= $pow) {
      $pow <<= 1;
      $pos++;
    }
  }
  ### $pos

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


# This is a bit bloated, but the result is the exact minimum/maximum N in
# the given rectangle.
#
# The strategy is similar to xy_to_n(), except that at each bit position
# instead of taking a bit of x,y from the input instead those bits are
# chosen from among the 4 sub-parts according to which has the maximum N and
# is within the given target rectangle.  The final result is both an $n_max
# and a $x_max,$y_max which is its position, but only the $n_max is
# returned.
#
# Similarly for the minimum.  There's separate N and X,Y for the min and
# max, including a different "i" state corresponding to the two Ns.
#
# If a sub-part is completely within the target rectangle then the remaining
# bits are min N=0 and max N=0b11..111.  The N=0 will happen if 0,0 is in
# the rectangle, but the max might only skip low 1-bits of the target
# rectangle, which usually won't be many.
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = floor($x1 + 0.5);
  $y1 = floor($y1 + 0.5);
  $x2 = floor($x2 + 0.5);
  $y2 = floor($y2 + 0.5);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  if ($x2 < 0 || $y2 < 0) {
    return (1, 0); # rectangle outside first quadrant
  }

  my $n_min = my $n_max
    = my $x_min = my $y_min
      = my $x_max = my $y_max
        = ($x1 & 0); # 0 inherit

  my $pos = 0;
  my $bit = $n_min + 2;  # inherit
  {
    my $m = max ($x1, $x2, $y1, $y2);
    if ($m-1 == $m) {
      return (0,$m); # infinity
    }
    while ($m >= $bit) {
      $bit <<= 1;
      $pos++;
    }
  }
  ### $pos

  my $i_min = my $i_max = ($pos & 1) << 2;
  while ($pos >= 0) {
    $bit >>= 1;

    {
      my $x_cmp = $x_max + $bit;
      my $y_cmp = $y_max + $bit;

      my $nbits = -1;
      my $yx;

      my $this_yx = 0;
      foreach my $incl (($x1 <  $x_cmp && $y1 <  $y_cmp),    # bot left
                        ($x2 >= $x_cmp && $y1 <  $y_cmp),    # bot right
                        ($x1 <  $x_cmp && $y2 >= $y_cmp),    # top left
                        ($x2 >= $x_cmp && $y2 >= $y_cmp)) {  # top right
        if ($incl) {  # sub-quadrant included in target rectangle
          my $this_nbits = $yx_to_n[$i_max + $this_yx];
          if ($this_nbits > $nbits) {
            $nbits = $this_nbits;
            $yx = $this_yx;
          }
        }
        $this_yx++;
      }

      $n_max = ($n_max << 2) | $nbits;
      $x_max |= ($yx & 1) << $pos;
      $y_max |= (($yx & 2) >> 1) << $pos;
      ### $pos
      ### $yx
      ### $nbits
      ### next_i: $n_to_next_i[$i_max+$nbits]
      ### n_max: sprintf "%#X", $n_max
      ### bit:  sprintf "%#X", $bit
      $i_max = $n_to_next_i[$i_max + $nbits];
    }

    {
      my $x_cmp = $x_min + $bit;
      my $y_cmp = $y_min + $bit;

      my $nbits = 4;
      my $yx;

      my $this_yx = 0;
      foreach my $incl (($x1 <  $x_cmp && $y1 <  $y_cmp),    # bot left
                        ($x2 >= $x_cmp && $y1 <  $y_cmp),    # bot right
                        ($x1 <  $x_cmp && $y2 >= $y_cmp),    # top left
                        ($x2 >= $x_cmp && $y2 >= $y_cmp)) {  # top right
        if ($incl) {  # sub-quadrant included in target rectangle
          my $this_nbits = $yx_to_n[$i_min + $this_yx];
          if ($this_nbits < $nbits) {
            $nbits = $this_nbits;
            $yx = $this_yx;
          }
        }
        $this_yx++;
      }

      $n_min = ($n_min << 2) | $nbits;
      $x_min |= ($yx & 1) << $pos;
      $y_min |= (($yx & 2) >> 1) << $pos;
      ### $pos
      ### $yx
      ### $nbits
      ### next_i: $n_to_next_i[$i_min+$nbits]
      ### n_min: sprintf "%#X", $n_min
      ### bit:  sprintf "%#X", $bit
      $i_min = $n_to_next_i[$i_min + $nbits];
    }

    $pos--;
  }

  return ($n_min, $n_max);
}

1;
__END__


  # my $n = int($nf);
  # my $frac = $nf - $n;

    # if ($bits == 0) {
    #   ### d unchanged
    # } elsif ($bits == 1) {
    #   ($dx,$dy) = ($dy,$dx);
    #   ### d swap: "$dx,$dy"
    # } elsif ($bits == 2) {
    #   $dx = -$dx;
    #   $dy = -$dy;
    #   ### d invert: "$dx,$dy"
    # } elsif ($bits == 3) {
    #   ($dx,$dy) = ($dy,$dx);
    #   ### d swap: "$dx,$dy"
    # }
    # my $prevbits = $bits;

    # if ($bits == 0) {
    #   ### d unchanged
    # } elsif ($bits == 1) {
    #   ($dx,$dy) = ($dy,$dx);
    #   ### d swap: "$dx,$dy"
    # } elsif ($bits == 2) {
    #   if ($prevbits == 3) {
    #     ($dx,$dy) = ($dy,$dx);
    #     ### d swap: "$dx,$dy"
    #   }
    #   ($dx,$dy) = ($dy,$dx);
    #   ### d swap: "$dx,$dy"
    # } elsif ($bits == 3) {
    #   if ($prevbits == 3) {
    #     ($dx,$dy) = ($dy,$dx);
    #     ### d swap: "$dx,$dy"
    #   }
    #   $dx = -$dx;
    #   $dy = -$dy;
    #   ### d invert: "$dx,$dy"
    # }
  # my $dx = 1;
  # my $dy = 0;
  # $x += $dx * $frac;
  # $y += $dy * $frac;
  # ### d: "$dx,$dy"









# sub Z_n_to_xy {
#   my ($self, $n) = @_;
#   ### HilbertCurve n_to_xy(): $n
#   ### hex: sprintf "%#X", $n
#   return if $n < 0;
# 
#   if (int($n) != $n) {
#     my ($x1,$y1) = $self->n_to_xy(floor($n));
#     my ($x2,$y2) = $self->n_to_xy(ceil($n));
#     return (($x1+$x2)/2, ($y1+$y2)/2);
#   }
#   # $n = floor ($n - 0.5);
# 
#   my $x = my $y = ($n & 0); # inherit
#   my $pos = 0;
#   {
#     my $pow = $x + 4;        # inherit
#     while ($n >= $pow) {
#       $pow <<= 2;
#       $pos += 2;
#     }
#   }
#   ### $pos
# 
#   my $i = ($pos & 2) << 1;
#   while ($pos >= 0) {
#     my $t = $i + (($n >> $pos) & 3);
#     $x = ($x << 1) | $n_to_x[$t];
#     $y = ($y << 1) | $n_to_y[$t];
#     ### $pos
#     ### $i
#     ### bits: ($n >> $pos) & 3
#     ### $t
#     ### n_to_x: $n_to_x[$t]
#     ### n_to_y: $n_to_y[$t]
#     ### next_i: $n_to_next_i[$t]
#     ### x: sprintf "%#X", $x
#     ### y: sprintf "%#X", $y
#     $i = $n_to_next_i[$t];
#     $pos -= 2;
#   }
# 
#   ### is: "$x,$y"
#   return ($x, $y);
# }

=for stopwords Ryde Math-PlanePath PlanePaths OEIS ZOrderCurve Gosper's HAKMEM Jorg Arndt's bitwise bignums fxtbook Ueber stetige Abbildung einer Linie auf ein Flächenstück Mathematische Annalen DOI

=head1 NAME

Math::PlanePath::HilbertCurve -- 2x2 self-similar quadrant traversal

=head1 SYNOPSIS

 use Math::PlanePath::HilbertCurve;
 my $path = Math::PlanePath::HilbertCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path is an integer version of the curve described by David Hilbert in
1891 for filling a unit square.  It traverses a quadrant of the plane one
step at a time in a self-similar 2x2 pattern,

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

The start is a sideways U shape per N=0 to N=3, and then four of those are
put together in an upside-down U as follows,

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

Within a power-of-2 square 2x2, 4x4, 8x8, 16x16 etc (2^k)x(2^k) at the
origin, all the N values 0 to 2^(2*k)-1 are within the square.  The maximum
3, 15, 63, 255 etc 2^(2*k)-1 is alternately at the top left or bottom right
corner.

Because each step is by 1, the distance along the curve between two X,Y
points is the difference in their N values (as given by C<xy_to_n>).

See F<examples/hilbert-path.pl> in the Math-PlanePath sources for a sample
program printing the path pattern in ascii.

=head2 Locality

The Hilbert curve is fairly well localized in the sense that a small
rectangle (or other shape) is usually a small range of N.  This property is
used in some database systems to store X,Y coordinates with the Hilbert N as
an index.  A search through an 2-D region is then usually a fairly modest
linear search through N values.  C<rect_to_n_range> gives N bounds for a
rectangle, or see L<N Range> below for calculating on any shape.

The N range can be large when crossing Hilbert sub-parts.  In the sample
above it can be seen for instance adjacent points X=0,Y=3 and X=0,Y=4 have
rather widely spaced N values 5 and 58.

Fractional X,Y values can be indexed by extending the N calculation down
into the X,Y binary fractions.  The code here doesn't do this, but can be
pressed into service by moving the binary point in X and Y up an even number
of places, the same amount in each, and shifting the resulting integer N
back down by a corresponding multiple of 4 binary places.

=head1 FUNCTIONS

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

Return a range of N values which occur in a rectangle with corners at
C<$x1>,C<$y1> and C<$x2>,C<$y2>.  If the X,Y values are not integers then
the curve is treated as unit squares centred on each integer point and
squares which are partly covered by the given rectangle are included.

The returned range is exact, meaning C<$n_lo> is the smallest in the
rectangle and C<$n_hi> is the biggest.  Of course not all the N's in that
range are necessarily in the rectangle.

=back

=head1 FORMULAS

=head2 N to X,Y

Converting N to X,Y coordinates is reasonably straightforward.  The top two
bits of N is a configuration

    3--2                    1--2
       |    or transpose    |  |
    0--1                    0  3

according to whether it's an odd or even bit-pair position.  Within each of
the "3" sub-parts there's also inverted forms

    1--0        3  0
    |           |  |
    2--3        2--1

Working N from high to low with a state variable can record whether there's
a transpose, an invert, or both, being four states altogether.  A bit pair
0,1,2,3 from N then gives a bit each of X,Y according to the configuration,
and a new state which is the orientation of the sub-part.  Gosper's HAKMEM
item 115 has this with tables for the state and X,Y bits,

    http://www.inwap.com/pdp10/hbaker/hakmem/topology.html#item115

And C++ code based on that in Jorg Arndt's book,

    http://www.jjj.de/fxt/#fxtbook (section 1.31.1)

It also works to process N from low to high, at each stage applying any
transpose (swap X,Y) and/or invert (bitwise NOT) to the low X,Y bits
generated so far.  This saves locating the top bits of N, but if using
bignums then bitwise inverts will be much more work.

=head2 X,Y to N

The reverse X,Y to N can follow the table approach from high to low taking
one bit from X and Y each time.  The state table of N-pair -> X-bit,Y-bit is
reversible, and a new state is based on the N-pair thus obtained (or could
be based on the X,Y bits if that mapping is combined into the state
transition table).

The current code is a mixture of the low to high for C<n_to_xy> but the
table high to low for the reverse C<xy_to_n>.

=head2 N Range

An easy over-estimate of the maximum N in a region can be had by going to
the next bigger (2^k)x(2^k) square enclosing the region.  This means the
biggest X or Y rounded up to the next power of 2 (perhaps with a "count
leading zeros" CPU instruction), so

    find k with 2^k > max(X,Y)
    N_max = 2^(2k) - 1

An exact N range can be found by following the high to low N-to-X,Y
procedure above.  Start at the 2^(2k) bit pair position in an N bigger than
the desired region and choose 2 bits for N to give a bit each of X and Y.
The X,Y bits are based on the state table as above and the bits chosen for N
are those for which the resulting X,Y sub-square overlaps some of the target
region.  The smallest N similarly, choosing the smallest bit pair which
overlaps.

Biggest and smallest N must be calculated separately as they track down
different N bits and thus different state transitions.  The N range for any
shape can be done this way, not just a rectangle like C<rect_to_n_range>,
since it only depends on asking when a sub-square for two bits of N overlaps
the target area.

=head2 Direction

Each step between successive N values is by 1 up, down, left or right.  The
next direction can be calculated from the N position with on some base-4
digit-3s parity of N and -N (twos complement).  C++ code in Jorg Arndt's
fxtbook per above.

=head1 OEIS

This Hilbert Curve path is in Sloane's OEIS in several forms,

    http://oeis.org/A059252  (etc)

    A059252    Y coord    \ if first move horizontal
    A059253    X coord    / per the code here
    A163365    diagonal sums
    A163477    diagonal sums, divided by 4
    A163482    row at Y=0
    A163483    column at X=0
    A163538    X change -1,0,1
    A163539    Y change -1,0,1
    A163540    absolute direction of each step (up,down,left,right)
    A163541    absolute direction, transpose X,Y
    A163542    relative direction (ahead,left,right)
    A163543    relative direction, transpose X,Y

And taking squares of the plane in various orders, each value in the
sequence being the N of the Hilbert curve at those positions.

    A163355    in the ZOrderCurve sequence
    A163357    in diagonals like Math::PlanePath::Diagonals with
               first Hilbert step along same axis the diagonals start
    A163359    in diagonals, transposed start along the opposite axis
    A163361    A163357 + 1, numbering the Hilbert N's from N=1
    A163363    A163355 + 1, numbering the Hilbert N's from N=1

The sequences are in each case permutations of the integers since all X,Y
positions of the first quadrant are reached eventually.  The inverses are as
follows.  They can be thought of taking X,Y positions in the Hilbert order
and asking what N the ZOrderCurve or Diagonals path would put there.

    A163356    inverse of A163355
    A163358    inverse of A163357
    A163360    inverse of A163359
    A163362    inverse of A163361

See F<examples/hilbert-oeis.pl> in the Math-PlanePath sources for a sample
program printing A163359 values.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PeanoCurve>,
L<Math::PlanePath::ZOrderCurve>,
L<Math::PlanePath::KochCurve>

L<Math::Curve::Hilbert>,
L<Algorithm::QuadTree>

David Hilbert, "Ueber die stetige Abbildung einer Line auf ein
FlE<228>chenstE<252>ck", Mathematische Annalen, volume 38, number 3,
p459-460,

    http://www.springerlink.com/content/v1u6427kk33k8j56/
    DOI 10.1007/BF01199431
    http://notendur.hi.is/oddur/hilbert/gcs-wrapper-1.pdf

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2010, 2011 Kevin Ryde

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
