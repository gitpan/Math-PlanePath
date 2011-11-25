# Copyright 2011 Kevin Ryde

# This file is part of Math-PlanePath.
#
# Math-PlanePath is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-PlanePath is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-PlanePath.  If not, see <http://www.gnu.org/licenses/>.


package Math::PlanePath::SierpinskiArrowheadCentres;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 55;

use Math::PlanePath 37; # v.37 for _round_nearest()
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

use Math::PlanePath::CellularRule54 54; # v.54 for _rect_for_V()
*_rect_for_V = \&Math::PlanePath::CellularRule54::_rect_for_V;

# uncomment this to run the ### lines
#use Devel::Comments;


use constant n_start => 0;
use constant y_negative => 0;

sub n_to_xy {
  my ($self, $n) = @_;
  ### SierpinskiArrowheadCentres n_to_xy(): $n
  if ($n < 0) {
    return;
  }
  if (_is_infinite($n)) {
    return ($n,$n);
  }

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;
    $n = $int;
  }

  my $x = my $y = ($n * 0); # inherit bignum 0
  my $len = $x + 1; # inherit bignum 1

  for (;;) {
    unless ($n) {
      return ($frac + $x,
              $frac + $y);
    }
    my $digit = ($n % 3);

    ### odd right: "$x, $y  len=$len  frac=$frac"
    ### $digit
    if ($digit == 0) {
      $x = $frac + $x;
      $y = $frac + $y;
      $frac = 0;

    } elsif ($digit == 1) {
      $x = -2*$frac -$x + $len;  # mirror and offset
      $y += $len;
      $frac = 0;

    } else {
      ($x,$y) = (($x+3*$y)/-2 - 1,             # rotate +120
                 ($x-$y)/2    + 2*$len-1);
    }

    unless ($n = int($n/3)) {
      return (-$frac + $x,
              $frac + $y);
    }
    $len *= 2;
    $digit = ($n % 3);
    $n = int($n/3);

    ### odd left: "$x, $y  len=$len  frac=$frac"
    ### $digit
    if ($digit == 0) {
      $x = -$frac + $x;
      $y = $frac + $y;
      $frac = 0;

    } elsif ($digit == 1) {
      $x = 2*$frac + -$x - $len;  # mirror and offset
      $y += $len;
      $frac = 0;

    } else {
      ($x,$y) = ((3*$y-$x)/2 + 1,              # rotate -120
                 ($x+$y)/-2  + 2*$len-1);
    }
    $len *= 2;
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  ### SierpinskiArrowheadCentres xy_to_n(): "$x, $y"

  if ($y < 0 || (($x^$y) & 1)) {
    return undef;
  }

  my ($len, $level) = _round_down_pow ($y, 2);
  ### pow2 round up: ($y + ($y==$x || $y==-$x))
  ### $len
  ### $level
  $level += 1;

  if (_is_infinite($level)) {
    return $level;
  }

  my $n = 0;
  while ($level) {
    $n *= 3;
    ### at: "$x,$y  level=$level len=$len"

    if ($y < 0 || $x < -$y || $x > $y) {
      ### out of range ...
      return undef;
    }

    if ($y < $len) {
      ### digit 0, first triangle, no change ...

    } else {
      if ($level & 1) {
        ### odd level ...
        if ($x > 0) {
          ### digit 1, right triangle ...
          $n += 1;
          $y -= $len;
          $x = - ($x-$len);
          ### shift right and mirror to: "$x,$y"
        } else {
          ### digit 2, left triangle ...
          $n += 2;
          $x += 1;
          $y -= 2*$len-1;
          ### shift down to: "$x,$y"
          ($x,$y) = ((3*$y-$x)/2,   # rotate -120
                     ($x+$y)/-2);
          ### rotate to: "$x,$y"
        }
      } else {
        ### even level ...
        if ($x < 0) {
          ### digit 1, left triangle ...
          $n += 1;
          $y -= $len;
          $x = - ($x+$len);
          ### shift right and mirror to: "$x,$y"
        } else {
          ### digit 2, right triangle ...
          $n += 2;
          $x -= 1;
          $y -= 2*$len-1;
          ### shift down to: "$x,$y"
          ($x,$y) = (($x+3*$y)/-2,             # rotate +120
                     ($x-$y)/2);
          ### now: "$x,$y"
        }
      }
    }

    $level--;
    $len /= 2;
  }

  ### final: "$x,$y with n=$n"
  if ($x == 0 && $y == 0) {
    return $n;
  } else {
    return undef;
  }
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### SierpinskiArrowheadCentres rect_to_n_range(): "$x1,$y1, $x2,$y2"

  ($x1,$y1, $x2,$y2) = _rect_for_V ($x1,$y1, $x2,$y2)
    or return (1,0); # rect outside pyramid

  my (undef,$level) = _round_down_pow ($y2, 2);
  ### $y2
  ### $level
  return (0, 3**($level+1) - 1);
}

1;
__END__

=for stopwords eg Ryde Sierpinski Nlevel ie SierpinskiTriangle Math-PlanePath

=head1 NAME

Math::PlanePath::SierpinskiArrowheadCentres -- self-similar triangular path traversal

=head1 SYNOPSIS

 use Math::PlanePath::SierpinskiArrowheadCentres;
 my $path = Math::PlanePath::SierpinskiArrowheadCentres->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is a version of the Sierpinski arrowhead path taking the centres of
each triangle represented by the arrowhead segments.  The effect is to
traverse the Sierpinski triangle.

              ...                                 ...
               /                                   /
        .    30     .     .     .     .     .    65     .   ...
            /                                      \        /
    28----29     .     .     .     .     .     .    66    68     9
      \                                               \  /
       27     .     .     .     .     .     .     .    67        8
         \
          26----25    19----18----17    15----14----13           7
               /        \           \  /           /
             24     .    20     .    16     .    12              6
               \        /                       /
                23    21     .     .    10----11                 5
                  \  /                    \
                   22     .     .     .     9                    4
                                          /
                       4---- 5---- 6     8                       3
                        \           \  /
                          3     .     7                          2
                           \
                             2---- 1                             1
                                 /
                                0                            <- Y=0

    -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7

The base figure is the N=0 to N=2 shape.  It's repeated up in mirror image
as N=3 to N=6 then across rotated as N=6 to N=9.  At the next level the same
is done with the N=0 to N=8 shape, up mirrored as N=9 to N=17 and across
rotated as N=18 to N=26, etc.

The X,Y coordinates are on a triangular lattice using every second integer
X, per L<Math::PlanePath/Triangular Lattice>.

The base pattern is a triangle like

      .-------.-------.
       \     / \     /
        \ 2 / m \ 1 /
         \ /     \ /
          .- - - -.
           \     /
            \ 0 /
             \ /
              .

Higher levels replicate this within the triangles 0,1,2 but the middle "m"
is not traversed.  The result is the familiar Sierpinski triangle by
connected steps 2 across or 1 diagonal.

    * * * * * * * * * * * * * * * *
     *   *   *   *   *   *   *   *
      * *     * *     * *     * *
       *       *       *       *
        * * * *         * * * *
         *   *           *   *
          * *             * *
           *               *
            * * * * * * * *
             *   *   *   *
              * *     * *
               *       *
                * * * *
                 *   *
                  * *
                   *

See the SierpinskiTriangle path to traverse by rows instead.

=head2 Level Ranges

Counting the N=0,1,2 part as level 1, each replication level goes from

    Nstart = 0
    Nlevel = 3^level - 1     inclusive

For example level 2 from N=0 to N=3^2-1=9.  Each level doubles in size,

                 0  <= Y <= 2^level - 1
    - (2^level - 1) <= X <= 2^level - 1

The Nlevel position is alternately on the right or left,

    Xlevel = /  2^level - 1      if level even
             \  - 2^level + 1    if level odd

The Y axis ie. X=0, is crossed just after N=1,5,17,etc which is is 2/3
through the level, which is after two replications of the previous level,

    Ncross = 2/3 * 3^level - 1
           = 2 * 3^(level-1) - 1

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::SierpinskiArrowheadCentres-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

If C<$n> is not an integer then the return is on a straight line between the
integer points.

=back

=head1 FORMULAS

=head2 Rectangle to N Range

An easy over-estimate of the range can be had from inverting the Nlevel
formulas in L</Level Ranges> above.

    level = floor(log2(Ymax)) + 1
    Nmax = 3^level - 1

For example Y=5, level=floor(log2(11))+1=3, so Nmax=3^3-1=26, which is the
left end of the Y=7 row, ie. rounded up to the end of the Y=4 to Y=7
replication.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SierpinskiArrowhead>,
L<Math::PlanePath::SierpinskiTriangle>

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

# Local variables:
# compile-command: "math-image --path=SierpinskiArrowheadCentres --lines --scale=10"
# End:
# 
# math-image --path=SierpinskiArrowheadCentres --all --output=numbers_dash
# math-image --path=SierpinskiArrowheadCentres --all --text --size=80

