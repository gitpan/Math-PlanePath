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


# math-image --path=KochSnowflakes --lines --scale=10

# area approaches sqrt(48)/10


package Math::PlanePath::KochSnowflakes;
use 5.004;
use strict;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use Math::PlanePath;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

use vars '$VERSION', '@ISA';
$VERSION = 81;
@ISA = ('Math::PlanePath');


# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_frac_discontinuity => 0;

# N=1 to 3      3 of, level=1
# N=4 to 15    12 of, level=2
# N=16 to ..   48 of, level=3
#
# each loop = 3*4^level
#
#     n_base = 1 + 3*4^0 + 3*4^1 + ... + 3*4^(level-1)
#            = 1 + 3*[ 4^0 + 4^1 + ... + 4^(level-1) ]
#            = 1 + 3*[ (4^level - 1)/3 ]
#            = 1 + (4^level - 1)
#            = 4^level
#
# each side = loop/3
#           = 3*4^level / 3
#           = 4^level
#

### loop 1: 3* 4**1
### loop 2: 3* 4**2
### loop 3: 3* 4**3

# sub _level_to_base {
#   my ($level) = @_;
#   return -3*$level + 4**($level+1) - 2;
# }
# ### level_to_base(1): _level_to_base(1)
# ### level_to_base(2): _level_to_base(2)
# ### level_to_base(3): _level_to_base(3)

sub n_to_xy {
  my ($self, $n) = @_;
  ### KochSnowflakes n_to_xy(): $n
  if ($n < 1) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  my ($base, $level) = _round_down_pow ($n, 4);
  ### $level
  ### $base
  ### next base would be: 4**($level+1)

  my $rem = $n - $base;
  ### $rem

  ### assert: $n >= $base
  ### assert: $n < 4**($level+1)
  ### assert: $rem>=0
  ### assert: $rem < 3 * 4 ** $level

  my $side = int($rem / $base);
  ### $side
  ### $rem
  $rem -= $side*$base;

  ### assert: $side >= 0 && $side < 3

  my ($x, $y) = Math::PlanePath::KochCurve->n_to_xy ($rem);
  ### $x
  ### $y

  my $len = 3**($level-1);
  if ($side < 1) {
    ### horizontal rightwards
    return ($x - 3*$len,
            -$y - $len);
  } elsif ($side < 2) {
    ### right slope upwards
    return (($x-3*$y)/-2 + 3*$len,  # flip vert and rotate +120
            ($x+$y)/2 - $len);
  } else {
    ### left slope downwards
    ($x,$y) = ((-3*$y-$x)/2,  # flip vert and rotate -120
               ($y-$x)/2 + 2*$len);
  }
}


# N=1 overlaps N=5
# N=2 overlaps N=7
#      +---------+         +---------+   Y=1.5
#      |         |         |         |
#      |         +---------+         |   Y=7/6 = 1.166
#      |         |         |         |
#      |    * 13 |         |    * 11 |   Y=1
#      |         |         |         |
#      |         |    * 3  |         |   Y=2/3 = 0.666
#      |         |         |         |
#      +---------+         +---------+   Y=0.5
#                |         |
#      +---------+---------+---------+   Y=1/6 = 0.166
#      |         |    O    |         | --Y=0
#      |         |         |         |
#      |         |         |         |
#      |    * 1  |         |    * 2  |   Y=-1/3 = -0.333
#      |         |         |         |
#      +---------+         +---------+   Y=-3/6 = -0.5
#      |         |         |         |
#      +---------+         +---------+   Y=-5/6 = -0.833
#      |         |         |         |
#      |    * 5  |         |    * 7  |   Y=-1
#      |         |         |         |
#      |         |         |         |
#      +---------+         +---------+   Y=-1.5
#
sub xy_to_n {
  return scalar((shift->xy_to_n_list(@_))[0]);
}
sub xy_to_n_list {
  my ($self, $x, $y) = @_;
  ### KochSnowflakes xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  if (abs($x) <= 1) {
    if ($x == 0) {
      my $y6 = 6*$y;
      if ($y6 >= 1 && $y6 < 7) {
        # Y = 2/3-1/2=1/6 to 2/3+1/2=7/6
        return 3;
      }
    } else {
      my $y6 = 6*$y;
      if ($y6 >= -5 && $y6 < 1) {
        # Y = -1/3-1/2=-5/6 to -1/3+1/2=+1/6
        return (1 + ($x > 0),
                ($y6 < -3 ? (5+2*($x>0)) : ()));   # 5 or 7 up to Y<-1/2
      }
    }
  }

  $y = _round_nearest ($y);
  if (($x % 2) != ($y % 2)) {
    ### diff parity...
    return;
  }

  my $high;
  if ($x > 0 && $x >= -3*$y) {
    ### right upper third n=2 ...
    ($x,$y) = ((3*$y-$x)/2,   # rotate -120 and flip vert
               ($x+$y)/2);
    $high = 2;
  } elsif ($x <= 0 && 3*$y > $x) {
    ### left upper third n=3 ...
    ($x,$y) = (($x+3*$y)/-2,             # rotate +120 and flip vert
               ($y-$x)/2);
    $high = 3;
  } else {
    ### lower third n=1 ...
    $y = -$y;  # flip vert
    $high = 1;
  }
  ### rotate/flip is: "$x,$y"

  if ($y <= 0) {
    return;
  }

  my ($len,$level) = _round_down_pow($y, 3);
  $level += 1;
  ### $level
  ### $len
  if (_is_infinite($level)) {
    return $level;
  }


  $y -= $len;  # shift to Y=0 basis
  $len *= 3;

  ### compare for end: ($x+$y)." >= 3*len=".$len
  if ($x + $y >= $len) {
    ### past end of this level, no points ...
    return;
  }
  $x += $len;  # shift to X=0 basis

  my $n = Math::PlanePath::KochCurve->xy_to_n($x, $y);

  ### plain curve on: ($x+3*$len).",".($y-$len)."  n=".(defined $n && $n)
  ### $high
  ### high: (4**$level)*$high

  if (defined $n) {
    return (4**$level)*$high + $n;
  } else {
    return;
  }
}

# level extends to x= +/- 3^level
#                  y= +/- 2*3^(level-1)
#                   =     2/3 * 3^level
#                  1.5*y = 3^level
#
# ENHANCE-ME: use _round_down_pow() to be bigint friendly
# ENHANCE-ME: share KochCurve segment checker to find actual min/max
#
# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### KochSnowflakes rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  #
  #          |
  # +------  .   -----+
  # |x1,y2  /|\  x2,y2|
  #        / | \
  #       /  |  \
  # -----/---m---\-----
  #     /    |    \
  #    .-----------.
  #          |
  #           y1
  #        -------
  #
  # -y1 bottom horizontal
  # (x2+y2)/2 right side
  # (-x1+y2)/2 left side
  # each giving a power of 3 of the level
  #
  ### right: ($x2+$y2)/2
  ### left: (-$x1+$y2)/2
  ### bottom: -$y1

  my ($len, $level) = _round_down_pow (max (int(($x2+$y2)/2),
                                            int((-$x1+$y2)/2),
                                            -$y1),
                                       3);
  ### $level
  # end of $level is 1 before base of $level+1
  return (1, 4**($level+2) - 1);
}

1;
__END__

=for stopwords eg Ryde ie SVG Math-PlanePath Ylo

=head1 NAME

Math::PlanePath::KochSnowflakes -- Koch snowflakes as concentric rings

=head1 SYNOPSIS

 use Math::PlanePath::KochSnowflakes;
 my $path = Math::PlanePath::KochSnowflakes->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path traces out concentric integer versions of the Koch snowflake at
successively greater iteration levels.

                               48                                6
                              /  \
                      50----49    47----46                       5
                        \              /
             54          51          45          42              4
            /  \        /              \        /  \
    56----55    53----52                44----43    41----40     3
      \                                                  /
       57                      12                      39        2
      /                       /  \                       \
    58----59          14----13    11----10          37----38     1
            \           \       3      /           /
             60          15  1----2   9          36         <- Y=0
            /                          \           \
    62----61           4---- 5    7---- 8           35----34    -1
      \                       \  /                       /
       63                       6                      33       -2
                                                         \
    16----17    19----20                28----29    31----32    -3
            \  /        \              /        \  /
             18          21          27          30             -4
                        /              \
                      22----23    25----26                      -5
                              \  /
                               24                               -6

                                ^
    -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7  8  9

The initial figure is the triangle N=1,2,3 then for the next level each
straight side expands to 3x longer and a notch like N=4 through N=8,

      *---*     becomes     *---*   *---*
                                 \ /
                                  *

The angle is maintained in each replacement, for example the segment N=5 to
N=6 becomes N=20 to N=24 at the next level.

=head2 Triangular Coordinates

The X,Y coordinates are arranged as integers on a square grid per
L<Math::PlanePath/Triangular Lattice>, except the Y coordinates of the
innermost triangle which is

                    N=3
                X=0, Y=+0.666
               /             \
              /               \
             /                 \
            /                   \
         N=1                     N=2
    X=-1, Y=-0.333  ------   X=1, Y=-0.333

These values are not integers, but they're consistent with the
centring and scaling of the higher levels.  If all-integer is desired
then rounding gives Y=0 or Y=1 and doesn't overlap the subsequent
points.

=head2 Level Ranges

Counting the innermost triangle as level 0, each ring is

    Nstart = 4^level
    length = 3*(4^level)   many points

For example the outer ring shown above is level 2 starting N=4^2=16 and
having length=3*4^2=48 points (through to N=63 inclusive).

The X range at a given level is the initial triangle baseline iterated out.
Each level expands the sides by a factor of 3 so

     Xlo = -(3^level)
     Xhi = +(3^level)

For example level 2 above runs from X=-9 to X=+9.  The Y range is the
points N=6 and N=12 iterated out.  Ylo in level 0 since there's no
downward notch on that innermost triangle.

    Ylo = / -(2/3)*3^level if level >= 1
          \ -1/3           if level == 0
    Yhi = +(2/3)*3^level

Notice that for each level the extents grow by a factor of 3 but the
notch introduced in each segment is not big enough to go past the
corner positions.  They can equal the extents horizontally, for
example in level 1 N=14 is at X=-3 the same as the corner N=4, and on
the right N=10 at X=+3 the same as N=8, but they don't go past.

The snowflake is an example of a fractal curve with ever finer
structure.  The code here can be used for that by going from N=Nstart
to N=Nstart+length-1 and scaling X/3^level Y/3^level to give a 2-wide
1-high figure of desired fineness.  See F<examples/koch-svg.pl> in the
Math-PlanePath sources for a complete program doing that as an SVG
image file.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::KochSnowflakes-E<gt>new ()>

Create and return a new path object.

=back

=head1 FORMULAS

=head2 Rectangle to N Range

As noted in L</Level Ranges> above, for a given level

          -(3^level) <= X <= 3^level
    -(2/3)*(3^level) <= Y <= (2/3)*(3^level)

So the maximum X,Y in a rectangle gives

    level = ceil(log3(max(abs(x1), abs(x2), abs(y1)*3/2, abs(y2)*3/2)))

and the last point in that level is

    Nlevel = 4^(level+1) - 1

Using this as an N range is an over-estimate, but an easy calculation.  It's
not too difficult to trace down for an exact range

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PeanoCurve>,
L<Math::PlanePath::HilbertCurve>,
L<Math::PlanePath::KochCurve>,
L<Math::PlanePath::KochPeaks>

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
