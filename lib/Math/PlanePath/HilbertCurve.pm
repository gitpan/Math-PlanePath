# Copyright 2010 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.


package Math::PlanePath::HilbertCurve;
use 5.004;
use strict;
use warnings;
use List::Util qw(min max);
use POSIX qw(floor ceil);

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 13;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

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
  ### hex: sprintf "%X", $n
  return if $n < 0;

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
    $n = ($n << 2) + $nbits;
    ### $pos
    ### $i
    ### x bit: ($x >> ($pos)) & 1
    ### y bit: ($y >> ($pos)) & 1
    ### t: $i + (($x >> $pos) & 1) + ((($y >> $pos) & 1) << 1)
    ### yx_to_n: $yx_to_n[$i + (($x >> $pos) & 1) + ((($y >> $pos) & 1) << 1)]
    ### next_i: $n_to_next_i[$i+$nbits]
    ### n: sprintf "%X", $n
    $i = $n_to_next_i[$i + $nbits];
    $pos--;
  }

  return $n;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  # ENHANCE-ME: tighten this up a lot
  my $m = ceil (max ($x1, $x2, $y1, $y2, 0));
  my $ret = 1;
  while ($m >= $ret) {
    $ret <<= 1;
  }
  return (0, ($ret*$ret)-1);
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
#   ### hex: sprintf "%X", $n
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
#     ### x: sprintf "%X", $x
#     ### y: sprintf "%X", $y
#     $i = $n_to_next_i[$t];
#     $pos -= 2;
#   }
# 
#   ### is: "$x,$y"
#   return ($x, $y);
# }

=for stopwords Ryde Math-Image

=head1 NAME

Math::PlanePath::HilbertCurve -- self-similar quadrant traversal

=head1 SYNOPSIS

 use Math::PlanePath::HilbertCurve;
 my $path = Math::PlanePath::HilbertCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path by David Hilbert traverses a quadrant of the plane one step at a
time in a self-similar pattern,

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

The start is a sideways U shape per 0,1,2,3, and then four of those are put
together in an upside-down U.  The orientation of the sub parts are chosen
so the starts and ends are adjacent, so 3 next to 4, 7 next to 8, and 11
next to 12.

    5,6___9,10
    4,7   8,11
     |     |
    3,2   13,12__
    0,1   14,15

The process repeats, doubling in size each time and alternately sideways or
upside-down U at the top level and invert or transponses as necessary in the
sub-parts.

The pattern can be drawn with the first step 0->1 up instead of to the
right.  Right is used here since that's what most of the other PlanePaths
do.  Swap X and Y for upwards first instead.

Within a power-of-2 square 2x2, 4x4, 8x8, 16x16 etc 2^(2^k), all the N
values 0 to 2^(2*(2^k))-1 are within the square.  The alternate top left or
bottom right corner 3, 15, 63, 255 etc of each is the 2^(2*(2^k))-1 maximum.

=head2 OEIS

The Hilbert Curve path is in Sloane's OEIS as sequences A163355, A163357,
A163359 and A163361.  They're based on numbering X,Y positions diagonally in
the style of C<Math::PlanePath::Diagonals>, but starting from N=0.  The four
sequences are whether the first Curve move is in the X or Y direction, and
then whether the diagonals are numbered from the X axis up to the Y or the
other way around.

The sequences are permutations of the integers, and A163356, A163358,
A163360 and A163362 are the corresponding inverses.

=head2 Algorithms

Converting an N to X,Y coordinates is reasonably straightforward.  The top
two bits of N is a configuration

    3--2                    1--2
       |    or transpose    |  |
    0--1                    0  3

according to whether it's an odd or even bit-pair position.  Within the "3"
sub-parts there's also inverted forms

    1--0        3  0
    |           |  |
    2--3        2--1

Working N from high to low a state variable can record whether there's a
transpose, an invert, or both (four states altogether).  A bit pair 0,1,2,3
from N then gives a bit each of X,Y according to the configuration, and a
new state which is the orientation of the sub-part.

Gosper's HAKMEM item 115 has this with tables for the state and X,Y bits,

    http://www.inwap.com/pdp10/hbaker/hakmem/topology.html#item115

And C++ code based on that in Jorg Arndt's book,

    http://www.jjj.de/fxt/#fxtbook (section 1.31.1)

It also works to process N from low to high, at each stage applying a
transpose (swap X,Y) and/or invert (bitwise negate) to the low X,Y bits
generated so far.  This approach saves locating the top bits of N, but if
using bignums then the bitwise inverts will be much more work.

The reverse X,Y to N can follow the table approach from high to low taking
one bit from X and Y each time.  The state-based table of N-pair ->
X-bit,Y-bit is reversible and the new state is based on the N-pair so
obtained (or based on the X,Y bits if that mapping is combined in).

The current code is a mixture of low to high for C<n_to_xy> but the table
high to low for the reverse C<xy_to_n>.

Each step between successive N values is by 1 up, down, left or right.  The
next direction can be calculated from the N position based on some base-4
parity of N and -N.  C++ code in Jorg Arndt's fxtbook per above.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::HilbertCurve-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.  Integer positions are always just 1 apart either
horizontally or vertically, so the effect is that the fraction part appears
either added to or subtracted from X or Y.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x,$y>.  Each integer N is
considered the centre of a unit square an C<$x,$y> within that square
returns N.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::ZOrderCurve>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Math-PlanePath is Copyright 2010 Kevin Ryde

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
