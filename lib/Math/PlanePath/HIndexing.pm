# Copyright 2011, 2012, 2013 Kevin Ryde

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


# http://theinf1.informatik.uni-jena.de/~niedermr/publications.html
#
# Rolf Niedermeier
# http://fpt.akt.tu-berlin.de/niedermr/publications.html
#
#
# H second part down per paper
# |
# | *--*  *  *-
# | |  |  |  |
# | *  *--*  *
# | |        |
# | *  *--*  *
# | |  |  |  |
# | O  *  *--*
# |
# +------------
#
# eight similar to AlternatePaper
#
#                |
#    *--*  *--*  *  *-
#    |  |  |  |  |  |
#  --*  *  *  *--*  *--*
#       |  |           |
#       *  *  *--*--*--*
#    |  |  |
# *--*  *  O  *--*--*--*
# |                    |
# *--*--*--*  *  *  *--*
#             |  |  |
# *--*--*--*  *  *  *-
# |           |  |
# *--*  *--*  *  *  *-
#    |  |  |  |  |  |
#          *--*  *--*
#

package Math::PlanePath::HIndexing;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 113;
use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_divrem_mutate = \&Math::PlanePath::_divrem_mutate;

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'round_down_pow',
  'digit_split_lowtohigh';


use constant n_start => 0;
use constant class_x_negative => 0;
use constant class_y_negative => 0;
use constant diffxy_maximum => 0; # upper octant X<=Y so X-Y<=0
use constant dx_minimum => -1;
use constant dx_maximum => 1;
use constant dy_minimum => -1;
use constant dy_maximum => 1;
use constant dsumxy_minimum => -1; # NSEW only
use constant dsumxy_maximum => 1;
use constant ddiffxy_minimum => -1;
use constant ddiffxy_maximum => 1;
use constant dir_maximum_dxdy => (0,-1); # South


#------------------------------------------------------------------------------

sub n_to_xy {
  my ($self, $n) = @_;
  ### HIndexing n_to_xy(): $n

  if ($n < 0) {            # negative
    return;
  }
  if (is_infinite($n)) {
    return ($n,$n);
  }

  {
    # ENHANCE-ME: get direction without full N+1 calculation
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
    $n = $int; # BigFloat int() gives BigInt, use that
  }

  my $low = _divrem_mutate ($n, 2);
  ### $low
  ### $n

  my @digits = digit_split_lowtohigh($n,4);
  my $len = ($n*0 + 2) ** scalar(@digits);  # inherit bignum 2

  my $x = 0;
  my $y = 0;
  my $rev = 0;
  my $xinvert = 0;
  my $yinvert = 0;
  while (@digits) {
    my $digit = pop @digits;

    ### $len
    ### $rev
    ### $digit

    my $new_xinvert = $xinvert;
    my $new_yinvert = $yinvert;
    my $xo = 0;
    my $yo = 0;
    if ($rev) {
      if ($digit == 1) {
        $xo = $len-1;
        $yo = $len-1;
        $rev ^= 1;
        $new_yinvert = $yinvert ^ 1;
      } elsif ($digit == 2) {
        $xo = 2*$len-2;
        $yo = 0;
        $rev ^= 1;
        $new_xinvert = $xinvert ^ 1;
      } elsif ($digit == 3) {
        $xo = $len;
        $yo = $len;
      }

    } else {
      if ($digit == 1) {
        $xo = $len-2;
        $yo = $len;
        $rev ^= 1;
        $new_xinvert = $xinvert ^ 1;
      } elsif ($digit == 2) {
        $xo = 1;
        $yo = 2*$len-1;
        $rev ^= 1;
        $new_yinvert = $yinvert ^ 1;
      } elsif ($digit == 3) {
        $xo = $len;
        $yo = $len;
      }
    }

    ### $xo
    ### $yo

    if ($xinvert) {
      $x -= $xo;
    } else {
      $x += $xo;
    }
    if ($yinvert) {
      $y -= $yo;
    } else {
      $y += $yo;
    }

    $xinvert = $new_xinvert;
    $yinvert = $new_yinvert;
    $len /= 2;
  }

  ### final: "$x,$y"

  if ($yinvert) {
    $y -= $low;
  } else {
    $y += $low;
  }

  ### is: "$x,$y"
  return ($x, $y);
}

# uncomment this to run the ### lines
#use Smart::Comments;

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### HIndexing xy_to_n(): "$x, $y"

  $x = round_nearest ($x);
  $y = round_nearest ($y);

  if ($x < 0 || $y < 0 || $x > $y - ($y&1)) {
    return undef;
  }
  if (is_infinite($x)) {
    return $x;
  }
  my ($len, $level) = round_down_pow (int($y/1), 2);
  ### $len
  ### $level
  if (is_infinite($level)) {
    return $level;
  }

  my $n = 0;
  my $npower = $len*$len/2;
  my $rev = 0;
  while (--$level >= 0) {
    ### at: "$x,$y rev=$rev  len=$len n=$n"
    my $digit;
    my $new_rev = $rev;
    if ($y >= $len) {
      $y -= $len;
      if ($x >= $len) {
        ### digit 3 ...
        $digit = 3;
        $x -= $len;
      } else {
        my $yinv = $len-1-$y;
        ### digit 1 or 2: "y reduce to $y,  x cmp ".($yinv-($yinv&1))
        if ($x > $yinv-($yinv&1)) {
          ### digit 2, x invert to: $len-1-$x
          $digit = 2;
          $x = $len-1-$x;
        } else {
          ### digit 1, y invert to: $yinv
          $digit = 1;
          $y = $yinv;
        }
        $new_rev ^= 1;
      }
    } else {
      ### digit 0 ...
      $digit = 0;
    }

    if ($rev) {
      $digit = 3 - $digit;
      ### reversed digit: $digit
    }
    $rev = $new_rev;

    ### add n: $npower*$digit
    $n += $npower*$digit;
    $len /= 2;
    $npower /= 4;
  }

  ### end at: "$x,$y  n=$n rev=$rev"
  ### assert: $x == 0
  ### assert: $y == 0 || $y == 1

  return $n + $y^$rev;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = round_nearest ($x1);
  $y1 = round_nearest ($y1);
  $x2 = round_nearest ($x2);
  $y2 = round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### HIndexing rect_to_n_range(): "$x1,$y1 to $x2,$y2"

  # y2 & 1 excluding the X=Y diagonal on odd Y rows
  if ($x2 < 0 || $y2 < 0 || $x1 > $y2 - ($y2&1)) {
    return (1, 0);
  }

  my ($len, $level) = round_down_pow (($y2||1), 2);
  return (0, 2*$len*$len-1);
}

1;
__END__

=for stopwords eg Ryde ie Math-PlanePath Rolf Niedermeier octant Indexings OEIS

=head1 NAME

Math::PlanePath::HIndexing -- self-similar right-triangle traversal

=head1 SYNOPSIS

 use Math::PlanePath::HIndexing;
 my $path = Math::PlanePath::HIndexing->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

X<Niedermeier, Rolf>X<Reinhardt, Klaus>X<Sanders, Peter>This is an infinite
integer version of the H-indexing by Rolf Niedermeier, Klaus Reinhardt and
Peter Sanders.

=over

"Towards Optimal Locality In Mesh Indexings", Discrete Applied Mathematics,
volume 117, March 2002.
L<http://theinf1.informatik.uni-jena.de/publications/dam01a.pdf>

=back

It traverses an octant of the plane by self-similar right triangles.  Notice
the "H" shapes that arise from the backtracking, for example N=8 to N=23,
and repeating above it.

        |                                                           |
     15 |  63--64  67--68  75--76  79--80 111-112 115-116 123-124 127
        |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
     14 |  62  65--66  69  74  77--78  81 110 113-114 117 122 125-126
        |   |           |   |           |   |           |   |
     13 |  61  58--57  70  73  86--85  82 109 106-105 118 121
        |   |   |   |   |   |   |   |   |   |   |   |   |   |
     12 |  60--59  56  71--72  87  84--83 108-107 104 119-120
        |           |           |                   |
     11 |  51--52  55  40--39  88  91--92  99-100 103
        |   |   |   |   |   |   |   |   |   |   |   |
     10 |  50  53--54  41  38  89--90  93  98 101-102
        |   |           |   |           |   |
      9 |  49  46--45  42  37  34--33  94  97
        |   |   |   |   |   |   |   |   |   |
      8 |  48--47  44--43  36--35  32  95--96
        |                           |
      7 |  15--16  19--20  27--28  31
        |   |   |   |   |   |   |   |
      6 |  14  17--18  21  26  29--30
        |   |           |   |
      5 |  13  10-- 9  22  25
        |   |   |   |   |   |
      4 |  12--11   8  23--24
        |           |
      3 |   3-- 4   7
        |   |   |   |
      2 |   2   5-- 6
        |   |
      1 |   1
        |   |
    Y=0 |   0
        +-------------------------------------------------------------
           X=0  1   2   3   4   5   6   7   8   9  10  11  12  13  14

The tiling is essentially the same as the Sierpinski curve (see
L<Math::PlanePath::SierpinskiCurve>).  The following is with two points per
triangle.  Or equally well it could be thought of with those triangles
further divided to have one point each, a little skewed.

    +---------+---------+--------+--------/
    |  \      |      /  | \      |       /
    | 15 \  16| 19  /20 |27\  28 |31    /
    |  |  \  ||  | /  | | | \  | | |  /
    | 14   \17| 18/  21 |26  \29 |30 /
    |       \ | /       |     \  |  /
    +---------+---------+---------/
    |       / |  \      |       /
    | 13  /10 | 9 \  22 | 25   /
    |  | /  | | |  \  | |  |  /
    | 12/  11 | 8   \23 | 24/
    |  /      |      \  |  /
    +-------------------/
    |  \      |       /
    | 3 \   4 | 7    /
    | |  \  | | |  /
    | 2   \ 5 | 6 /
    |       \ |  /
    +----------/
    |         /
    | 1     /
    | |   /
    | 0  /
    |  /
    +/

The correspondence to the C<SierpinskiCurve> is as follows.  The 4-point
verticals like N=0 to N=3 are a Sierpinski horizontal, and the 4-point "U"
parts like N=4 to N=7 are a Sierpinski vertical.  In both cases there's an
X,Y transpose and bit of stretching.


    3                                       7
    |                                      /
    2         1--2             5--6       6
    |  <=>   /    \            |  |  <=>  |
    1       0      3           4  7       5
    |                                      \
    0                                       4

=head2 Level Ranges

Counting the initial N=0 to N=7 section as level 1, the X,Y ranges for a
given level is

    Nlevel = 2*4^level - 1
    Xmax = 2*2^level - 2
    Ymax = 2*2^level - 1

For example level=3 is N through to Nlevel=2*4^3-1=127 and X,Y ranging up to
Xmax=2*2^3-2=14 and Xmax=2*2^3-1=15.

On even Y rows, the N on the X=Y diagonal is found by duplicating each bit
in Y except the low zero (which is unchanged).  For example Y=10 decimal is
1010 binary, duplicate to binary 1100110 is N=102.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::HIndexing-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 OEIS

Entries in Sloane's Online Encyclopedia of Integer Sequences related to
this path include

=over

L<http://oeis.org/A097110> (etc)

=back

    A097110    Y at N=2^k, being successively 2^j-1, 2^j

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SierpinskiCurve>

=head1 HOME PAGE

L<http://user42.tuxfamily.org/math-planepath/index.html>

=head1 LICENSE

Copyright 2011, 2012, 2013 Kevin Ryde

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
