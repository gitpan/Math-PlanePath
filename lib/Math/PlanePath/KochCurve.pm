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
# Sur une courbe continue sans tangente, obtenue par une construction
# g�om�trique �l�mentaire
#
# Ces�ro, "Remarques sur la courbe de von Koch." Atti della
# R. Accad. della Scienze fisiche e matem. Napoli 12, No. 15, 1-12,
# 1905. Reprinted as �228 in Opere scelte, a cura dell'Unione matematica
# italiana e col contributo del Consiglio nazionale delle ricerche, Vol. 2:
# Geometria, analisi, fisica matematica. Rome: Edizioni Cremonese,
# pp. 464-479, 1964.


package Math::PlanePath::KochCurve;
use 5.004;
use strict;
use List::Util 'max';
use POSIX 'ceil';

use vars '$VERSION', '@ISA';
$VERSION = 44;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;
use constant x_negative => 0;
use constant y_negative => 0;

sub n_to_xy {
  my ($self, $n) = @_;
  ### KochCurve n_to_xy(): $n

  # secret negatives to -.5
  if (2*$n < -1) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  my $x;
  {
    my $int = int($n);
    $x = 2 * ($n - $int);  # usually positive, but n=-0.5 gives x=-0.5
    $n = $int;             # BigFloat int() gives BigInt, use that
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

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($y < 0 || $x < 0 || (($x ^ $y) & 1)) {
    ### neg y or parity different ...
    return undef;
  }
  my ($len,$level) = _round_down_pow(($x/2)||1, 3);
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
        $n += 1;
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

  $y1 = _round_nearest ($y1);
  $y2 = _round_nearest ($y2);
  if ($y1 < 0 && $y2 < 0) {
    return (1,0);
  }
  $x1 = _round_nearest ($x1);
  $x2 = _round_nearest ($x2);
  if ($x1 < 0 && $x2 < 0) {
    return (1,0);
  }

  my $level = ceil (log ((max(2, abs($x1), abs($x2)) + 1) / 2)
                    / log(3));
  ### $level
  return (0, 4**$level);
}

#------------------------------------------------------------------------------
# generic, shared

# return ($pow, $exp) with $pow = $base**$exp <= $n,
# the next power of $base at or below $n
#
sub _round_down_pow {
  my ($n, $base) = @_;
  ### _round_down_pow(): "$n base $base"

  if ($n < $base) {
    return (1, 0);
  }

  # Math::BigInt and Math::BigRat overloaded log() return NaN, use integer
  # based blog()
  if (ref $n && ($n->isa('Math::BigInt') || $n->isa('Math::BigRat'))) {
    my $exp = $n->copy->blog($base);
    return (Math::BigInt->new(1)->blsft($exp,$base),
            $exp);
  }

  my $exp = int(log($n)/log($base));
  my $pow = $base**$exp;
  ### n:   ref($n)."  $n"
  ### exp: ref($exp)."  $exp"
  ### pow: ref($pow)."  $pow"

  # check how $pow actually falls against $n, not sure should trust float
  # rounding in log()/log($base)
  # Crib: $n as first arg in case $n==BigFloat and $pow==BigInt
  if ($n < $pow) {
    ### hmm, int(log) too big, decrease...
    $exp -= 1;
    $pow = $base**$exp;
  } elsif ($n >= $base*$pow) {
    ### hmm, int(log) too small, increase...
    $exp += 1;
    $pow *= $base;
  }
  return ($pow, $exp);
}


1;
__END__

=for stopwords eg Ryde Helge von Koch Math-PlanePath Nlevel

=head1 NAME

Math::PlanePath::KochCurve -- horizontal Koch curve

=head1 SYNOPSIS

 use Math::PlanePath::KochCurve;
 my $path = Math::PlanePath::KochCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path is an integer version of the self-similar curve by Helge von Koch
going along the X axis and making triangular excursions.

                               8                                   3
                             /  \
                      6---- 7     9----10                19-...    2
                       \              /                    \
             2           5          11          14          18     1
           /  \        /              \        /  \        /
     0----1     3---- 4                12----13    15----16    <- Y=0
     ^
    X=0   2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19

The replicating shape is the initial N=0 to N=4,

            *
           / \
      *---*   *---*

which is rotated and repeated 3 times in the same shape to give sections N=4
to N=8, N=8 to N=12, and N=12 to N=16.  Then that N=0 to N=16 is itself
replicated three times at the angles of the base pattern, and so on
infinitely.

The X,Y coordinates are arranged on a square grid using every second point,
per L<Math::PlanePath/Triangular Lattice>.  The result is flattened
triangular segments with diagonals at a 45 degree angle.

=head2 Level Ranges

Each replication adds 3 copies of the existing points and is thus 4 times
bigger, so if N=0 to N=4 is reckoned as level 1 then a given replication
level goes from

    Nstart = 0
    Nlevel = 4^level   (inclusive)

Each replication is 3 times the width.  The initial N=0 to N=4 figure is 6
wide, so in general a level runs from

    Xstart = 0
    Xlevel = 2*3^level   (at Nlevel)

The highest Y is 3 times greater at each level similarly.  The peak is at
the midpoint of each level,

    Npeak = (4^level)/2
    Ypeak = 3^level
    Xpeak = 3^level

It can be seen that the N=6 point backtracks horizontally to the same X as
the start of its section N=4 to N=8.  This happens in the further
replications too and is the maximum extent of the backtracking.

The Nlevel is multiplied by 4 to get the end of the next higher level.  The
same 4*N can be applied to all points N=0 to N=Nlevel to get the same shape
but a factor of 3 bigger X,Y coordinates.  The in-between points 4*N+1,
4*N+2 and 4*N+3 are then new finer structure in the higher level.

=head2 Fractal

Koch conceived the curve as having a fixed length and infinitely fine
structure, making it continuous everywhere but differentiable nowhere.  The
code here can be pressed into use for that sort of construction to a given
level of granularity by scaling

    X/3^level
    Y/3^level

to make it a fixed 2 wide by 1 high.  Or for unit-side equilateral triangles
then further factors 1/2 and sqrt(3)/2, as noted in
L<Math::PlanePath/Triangular Lattice>.

    (X/2) / 3^level
    (Y*sqrt(3)/2) / 3^level

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

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
