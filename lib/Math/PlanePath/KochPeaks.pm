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


# math-image --path=KochPeaks --lines --scale=10


package Math::PlanePath::KochPeaks;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX qw(floor ceil);

use vars '$VERSION', '@ISA';
$VERSION = 30;

use Math::PlanePath;
use Math::PlanePath::KochCurve;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;

use constant y_negative => 0;

# uncomment this to run the ### lines
#use Smart::Comments;


sub _prevpow4 {
  my ($n) = @_;
  my $pow = 0;
  while (($n /= 4) >= 1) {
    $pow++;
  }
  return $pow;
}
### _prevpow4(3): _prevpow4(3)
### _prevpow4(4): _prevpow4(4)
### _prevpow4(15): _prevpow4(15)
### _prevpow4(16): _prevpow4(16)


# N=1 to 2      2 of, level=0
# N=3 to 10     8 of, level=2
# N=11 to ..   32 of, level=3
#
# each loop = 2*4^level + 1
#
#     n_base = 1 + 2*4^0 + 1 + 2*4^1 + 1 + ... + 2*4^(level-1) + 1
#            = 1 + level + 2*[ 4^0 + 4^1 + ... + 4^(level-1) ]
#            = level+1 + 2*[ (4^level - 1)/3 ]
#            = level+1 + (2*4^level - 2)/3
#            = level + (2*4^level - 2 + 3)/3
#            = level + (2*4^level + 1)/3
#
#     3*n = 2*4^level + 1
#     3*n-1 = 2*4^level
#     (3*n-1)/2 = 4^level
#
### loop 1: (2*4**1 + 1)/3
### loop 2: (2*4**2 + 1)/3
### loop 3: (2*4**3 + 1)/3

sub n_to_xy {
  my ($self, $n) = @_;
  ### KochPeaks n_to_xy(): $n
  if ($n < 0.5 || _is_infinite($n)) {
    return;
  }

  my $frac = max (1, int ($n));
  ($n,$frac) = ($frac, $n-$frac);

  my $level = _prevpow4((3*$n-1)/2);
  my $base = $level + (2*4**$level + 1)/3;
  ### $level
  ### $base
  if ($base > $n) {
    $level--;
    $base = $level + (2*4**$level + 1)/3;
    ### $level
    ### $base
  }
  ### next base would be: ($level+1) + (2*4**($level+1) + 1)/3
  ### assert: $n >= $base
  ### assert: $n < ($level+1) + (2*4**($level+1) + 1)/3

  my $rem = $n - $base;
  ### assert: $rem>=0
  ### assert: $rem < 2 * 4 ** $level + 1

  my $x = 2*$frac;
  my $y = 0;
  my $dx = 2;
  my $dy = 0;
  my $len = 1;
  foreach (1 .. $level) {
    my $digit = $rem & 3;
    $rem >>= 2;
    ### at: "$x,$y"
    ### $digit

    if ($digit == 0) {

    } elsif ($digit == 1) {
      ($x,$y) = (($x-3*$y)/2 + 2*$len,   # rotate +60
                 ($x+$y)/2);

    } elsif ($digit == 2) {
      ($x,$y) = (($x+3*$y)/2 + 3*$len,   # rotate -60
                 ($y-$x)/2   + $len);

    } else {
      $x += 4*$len;
    }
    $len *= 3;
  }

  ### final: "$x,$y"
  ### $len
  ### $rem
  if ($rem == 2) {
    if ($x < 1) {
      $x += 2*$len;
    } else {
      $rem = 0;
      $x -= 2;
      $len *= 3;
    }
  }

  if ($rem == 0) {
    ### left ...
    return (($x-3*$y)/2 - $len,    # rotate +60
            ($x+$y)/2);

  } else {
    ### right ...
    ### assert: $rem == 1 || $rem == 2
    ### with rem: "$x,$y"
    return (($x+3*$y)/2,           # rotate -60
            ($y-$x)/2 + $len);
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### KochPeaks xy_to_n(): "$x, $y"

  $x = floor($x + 0.5);
  $y = floor($y + 0.5);
  if ($y < 0 || ! (($x ^ $y) & 1)) {
    ### neg y or parity...
    return undef;
  }
  my ($len,$level) = Math::PlanePath::KochCurve::_round_down_pow3($y+abs($x));
  ### $level
  ### $len
  if (_is_infinite($level)) {
    return $level;
  }

  my $n;
  if ($x < 0) {
    $x += $len;
    ($x,$y) = (($x+3*$y)/2,   # rotate -60
               ($y-$x)/2);
    $n = 0;
    ### left rotate -60 to: "x=$x,y=$y   n=$n"
  } else {
    $y -= $len;
    ($x,$y) = (($x-3*$y)/2,   # rotate +60
               ($x+$y)/2);
    $n = 1;
    ### right rotate +60 to: "x=$x,y=$y   n=$n"
  }

  foreach (1 .. $level) {
    $n *= 4;
    ### at: "level=$level len=$len   x=$x,y=$y  n=$n"
    if ($x < $len) {
      $len /= 3;
      my $rel = 2*$len;
      if ($x < $rel) {
        ### digit 0
      } else {
        ### digit 1 sub: "$rel to x=".($x-$rel)
        $x -= $rel;
        ($x,$y) = (($x+3*$y)/2,   # rotate -60
                   ($y-$x)/2);
        $n++;
      }
    } else {
      $len /= 3;
      $x -= 4*$len;
      if ($x < $y) {   # before diagonal
        ### digit 2...
        ($x,$y) = (($x-3*$y)/2 + 2*$len,     # rotate +60
                   ($x+$y)/2);
        $n += 2;
      } else {
        #### digit 3...
        $n += 3;
      }
    }
  }
  ### end at: "x=$x,y=$y   n=$n"
  if ($x) {
    ### endmost point
    $n++;
    $x -= 2;
  }
  if ($x != 0 || $y != 0) {
    return undef;
  }
  return $n + $level + (2*4**$level + 1)/3 + ($x == 2);
}


# level extends to x= +/- 3^level
#                  y= 0 to 3^level
#
# end of level is 1 before base of level+1
#     basenext = (level+1) + (2*4^(level+1) + 1)/3
#     basenext-1 = level + (2*4^(level+1) + 1)/3
#                = level + (8*4^level + 1)/3
#
# peak Y is at N = Nstart + (count-1)/2
#                = level + (2*4^level + 1)/3 + (2*4^level + 1 - 1)/2
#                = level + (2*4^level + 1)/3 + (2*4^level)/2
#                = level + (2*4^level + 1)/3 + 4^level
#                = level + (2*4^level + 1 + 3*4^level)/3
#                = level + (5*4^level + 1)/3
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### KochPeaks rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = floor($x1 + 0.5);
  $y1 = floor($y1 + 0.5);
  $x2 = floor($x2 + 0.5);
  $y2 = floor($y2 + 0.5);
  if ($y1 < 0 && $y2 < 0) {
    return (1,0);
  }

  my $level = ceil (log (max(1,
                             abs($x1), abs($x2),
                             $y1, $y2))
                    / log(3));
  ### $level
  return (1, $level + (8 * 4**$level + 1)/3);
}

1;
__END__

=for stopwords eg Ryde OEIS

=head1 NAME

Math::PlanePath::KochPeaks -- Koch curve peaks

=head1 SYNOPSIS

 use Math::PlanePath::KochPeaks;
 my $path = Math::PlanePath::KochPeaks->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path traces out concentric peaks made from integer versions of the
self-similar Koch curve at successively greater iteration levels.

                               29                                 9
                              /  \
                      27----28    30----31                        8
                        \              /
             23          26          32          35               7
            /  \        /              \        /  \
    21----22    24----25                33----34    36----37      6
      \                                                  /
       20                                              38         5
      /                                                  \
    19----18                                        40----39      4
            \                                      /
             17                 8                41               3
            /                 /  \                 \
    15----16           6---- 7     9----10          42----43      2
      \                 \              /                 /
       14                 5     2    11                44         1
      /                 /     /  \     \                 \
    13                 4     1    3     12                45  <- Y=0

                                ^
    -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7  8  9 ...

The initial figure is the peak N=1,2,3 then for the next level each straight
side expands to 3x longer with a notch like N=4 through N=8,

                                  *
                                 / \
      *---*     becomes     *---*   *---*

The angle is maintained in each replacement,

                                  *
                                 /
                            *---*
                             \
        *                     *
       /        becomes      /
      *                     *

So the segment N=1 to N=2 becomes N=4 to N=8, or in the next level N=5 to
N=6 becomes N=17 to N=21.

=head2 Triangular Coordinates

The X,Y coordinates are arranged as integers on a square grid.  Each
horizontal segment is X=+/-2 apart and the diagonals are X=+/-1,Y=+/-1.  The
result is flattened triangular segments with diagonals at a 45 degree angle.
To get 60 degree equilateral triangles of side length 1 use X/2 and
Y*sqrt(3)/2, or just Y*sqrt(3) for side length 2.

=head2 Level Ranges

Counting the innermost peak as level 0, each peak is

    Nstart = level + (2*4^level + 1)/3
    length = 2*4^level + 1       including endpoints

For example the outer ring shown above is level 2 starting at
N=2+(2*4^2+1)/3=13 and having length=2*4^2+1=9 many points through to N=12
(inclusive).  The X range at a given level is the endpoints at

    Xlo = -(3^level)
    Xhi = +(3^level)

For example the level 2 above runs from X=-9 to X=+9.  The highest Y is the
centre peak at

    Ypeak = 3^level
    Npeak = level + (5*4^level + 1)/3

Notice that for each level the extents grow by a factor of 3.  But the new
triangular notch in each segment is not big enough to go past the X start
and end points.  They can equal the ends, such as N=6 or N=19, but not
beyond.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::KochPeaks-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional C<$n> gives an X,Y position along a straight line between the
integer positions.

=back

=head1 FORMULAS

=head2 N Range

As noted above (L</Level Ranges>), for a given level

    -(3^level) <= X <= 3^level

So the maximum X in a rectangle gives a level,

    level = ceil (log3 (max(x1,x2)))

and the endpoint in that level is simply 1 before the start of the next, so

     Nlast = Nstart(level+1) - 1
           = (level+1) + (2*4^(level+1) + 1)/3 - 1
           = level + (8*4^level + 1)/3

Using this Nlast is an over-estimate of the N range needed, but an easy
calculation.  It's not too difficult to work down for an exact range.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::KochCurve>,
L<Math::PlanePath::PeanoCurve>,
L<Math::PlanePath::HilbertCurve>,
L<Math::PlanePath::KochCurve>,
L<Math::PlanePath::KochSnowflakes>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011 Kevin Ryde

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
