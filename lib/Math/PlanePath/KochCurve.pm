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


# math-image --path=KochCurve --lines --scale=10
# math-image --path=KochCurve --all --scale=10

# continuous but nowhere differentiable
#

# Cesàro, E. "Remarques sur la courbe de von Koch." Atti della
# R. Accad. della Scienze fisiche e matem. Napoli 12, No. 15, 1-12,
# 1905. Reprinted as §228 in Opere scelte, a cura dell'Unione matematica
# italiana e col contributo del Consiglio nazionale delle ricerche, Vol. 2:
# Geometria, analisi, fisica matematica. Rome: Edizioni Cremonese,
# pp. 464-479, 1964.

# Sur une courbe continue sans tangente, obtenue par une construction
# géométrique élémentaire


package Math::PlanePath::KochCurve;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX qw(floor ceil);

use vars '$VERSION', '@ISA';
$VERSION = 36;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;

use constant n_start => 0;
use constant x_negative => 0;
use constant y_negative => 0;

# return ($pow, $exp) with $pow = 3**$exp <= $n, the next power of 3 at or
# below $n
# shared with PythagoreanTree ...
sub _round_down_pow3 {
  my ($n) = @_;
  my $exp = int(log($n)/log(3));
  my $pow = 3**$exp;

  # check how $pow actually falls against $n, not sure should trust float
  # rounding in log()/log(3)
  if ($pow > $n) {
    ### hmm, int(log) too big, decrease...
    $exp -= 1;
    $pow = 3**$exp;
  } elsif (3*$pow <= $n) {
    ### hmm, int(log) too small, increase...
    $exp += 1;
    $pow *= 3;
  }
  return ($pow, $exp);
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### KochCurve n_to_xy(): $n

  # secret negatives to -.5
  if ($n < -.5 || _is_infinite($n)) {
    return;
  }

  my $x;
  {
    my $int = int($n);
    $x = 2 * ($n - $int);
    $n = $int;
  }
  my $y = 0;
  my $len = 1;
  while ($n) {
    my $digit = $n % 4;
    $n = int($n/4);
    ### at: "$x,$y"
    ### $digit

    if ($digit == 0) {

    } elsif ($digit == 1) {
      ($x,$y) = (($x-3*$y)/2 + 2*$len,     # rotate +60
                 ($x+$y)/2);

    } elsif ($digit == 2) {
      ($x,$y) = (($x+3*$y)/2 + 3*$len,    # rotate -60
                 ($y-$x)/2   + $len);

    } else {
      ### assert: $digit==3
      $x += 4*$len;
    }
    $len *= 3;
  }

  ### final: "$x,$y"
  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### KochPeaks xy_to_n(): "$x, $y"

  $x = floor($x + 0.5);
  $y = floor($y + 0.5);
  if ($y < 0 || $x < 0 || (($x ^ $y) & 1)) {
    ### neg y or parity different ...
    return undef;
  }
  my ($len,$level) = _round_down_pow3(($x/2)||1);
  ### $level
  ### $len
  if (_is_infinite($level)) {
    return $level;
  }

  my $n = 0;
  foreach (0 .. $level) {
    $n *= 4;
    ### at: "level=$level len=$len   x=$x,y=$y  n=$n"
    if ($x < 3*$len) {
      if ($x < 2*$len) {
        ### digit 0 ...
      } else {
        ### digit 1 ...
        $x -= 2*$len;
        ($x,$y) = (($x+3*$y)/2,   # rotate -60
                   ($y-$x)/2);
        $n++;
      }
    } else {
      $x -= 4*$len;
      ### digit 2 or 3 to: "x=$x"
      if ($x < $y) {   # before diagonal
        ### digit 2...
        $x += $len;
        $y -= $len;
        ($x,$y) = (($x-3*$y)/2,     # rotate +60
                   ($x+$y)/2);
        $n += 2;
      } else {
        #### digit 3...
        $n += 3;
      }
    }
    $len /= 3;
  }
  ### end at: "x=$x,y=$y   n=$n"
  if ($x != 0 || $y != 0) {
    return undef;
  }
  return $n;
}

# level extends to x= 2*3^level
#                  level = log3(x/2)
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### KochCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $y1 = floor($y1 + 0.5);
  $y2 = floor($y2 + 0.5);
  if ($y1 < 0 && $y2 < 0) {
    return (1,0);
  }

  $x1 = floor($x1 + 0.5);
  $x2 = floor($x2 + 0.5);

  my $level = ceil (log ((max(2, abs($x1), abs($x2)) + 1) / 2)
                    / log(3));
  ### $level
  return (0, 4**$level);
}

1;
__END__

=for stopwords eg Ryde Helge von Koch Math-PlanePath

=head1 NAME

Math::PlanePath::KochCurve -- horizontal Koch curve

=head1 SYNOPSIS

 use Math::PlanePath::KochCurve;
 my $path = Math::PlanePath::KochCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path is an integer version of the self-similar curve by Helge von Koch
going along the X axis and making triangular excursions.

                              8
                            /  \
                     6---- 7     9----10                19-...
                      \              /                    \
            2           5          11          14          18
          /  \        /              \        /  \        /
    0----1     3---- 4                12----13    15----16
    ^
    X=0  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19

The replicating shape is the initial section N=0 to N=4,

            *
           / \
      *---*   *---*

which is rotated and repeated 3 times in the same shape to give sections N=4
to N=8, N=8 to N=12, and N=12 to N=16.  Then that N=0 to N=16 is itself
replicated three times at the angles of the -side pattern, and so on
infinitely.

The X,Y coordinates are arranged on a square grid using every second point,
see L<Math::PlanePath/Triangular Lattice>.  The result is flattened
triangular segments with diagonals at a 45 degree angle.

=head2 Level Ranges

Each replication in adds 3 times the existing points and is thus 4 times
bigger, so if N=0 to N=4 is reckoned as level 1 then a given replication
level goes from

    Nstart = 0
    Nlevel = 4^level   (inclusive)

Each replication is 3 times the width.  The initial N=0 to N=4 figure is 6
wide, so in general a level runs from

    Xstart = 0
    Xlevel = 2*3^level   (at Nlevel)

The highest Y is 3 times greater at each level similarly, for peak

    X=3^level
    Y=3^level
    at N=(4^level)/2

It can be seen that the N=6 point backtracks horizontally to the same X as
the start of its section N=4 to N=8.  This happens in the replications too
and is the maximum extent of the backtracking.

The Nlevel value is multiplied by 4 to get the end of the next higher level.
The same 4*N can be applied to all points N=0 to N=Nlevel to get the same
shape but a factor of 3 on the X,Y coordinates.  The in-between points
4*N+1, 4*N+2 and 4*N+3 are the new finer structure in the higher level.

=head2 Fractal

Koch conceived the curve as having a fixed length and infinitely fine
structure, so it's continuous everywhere but differentiable nowhere.  The
code here can be pressed into service for that sort of construction of a
given level by scaling

    X/3^level
    Y/3^level

to make it a fixed 2 wide by 1 high.  Or apply factors 1/2 and sqrt(3)/2 as
above for unit-side equilateral triangles.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::KochCurve-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PeanoCurve>,
L<Math::PlanePath::HilbertCurve>,
L<Math::PlanePath::KochPeaks>,
L<Math::PlanePath::KochSnowflakes>

L<Math::Fractal::Curve>

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
