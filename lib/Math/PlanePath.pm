# Copyright 2010, 2011 Kevin Ryde

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


package Math::PlanePath;
use 5.004;
use strict;

use vars '$VERSION';
$VERSION = 35;

# defaults
use constant n_start => 1;
use constant x_negative => 1;
use constant y_negative => 1;
use constant figure => 'square';

sub new {
  my $class = shift;
  return bless { @_ }, $class;
}

sub _is_infinite {
  my ($x) = @_;
  return ($x-1 == $x);
}

1;
__END__

=for stopwords SquareSpiral SacksSpiral VogelFloret PlanePath Ryde Math-PlanePath 7-gonals 8-gonal (step+2)-gonal heptagonals PentSpiral octagonals HexSpiral PyramidSides PyramidRows ArchimedeanChords

=head1 NAME

Math::PlanePath -- points on a path through the 2-D plane

=head1 SYNOPSIS

 use Math::PlanePath;
 # only a base class, see the subclasses for actual operation

=head1 DESCRIPTION

This is the base class for some mathematical paths which map an integer
position C<$n> into coordinates C<$x,$y> in the plane.  The current classes
include

    SquareSpiral           four-sided spiral
    PyramidSpiral          square based pyramid
    TriangleSpiral         equilateral triangle spiral
    TriangleSpiralSkewed   equilateral skewed for compactness
    DiamondSpiral          four-sided spiral, looping faster
    PentSpiralSkewed       five-sided spiral, compact
    HexSpiral              six-sided spiral
    HexSpiralSkewed        six-sided spiral skewed for compactness
    HeptSpiralSkewed       seven-sided spiral, compact
    OctagramSpiral         eight pointed star
    KnightSpiral           an infinite knight's tour
    GreekKeySpiral         spiral with Greek key motif

    SacksSpiral            quadratic on an Archimedean spiral
    VogelFloret            seeds in a sunflower
    TheodorusSpiral        unit steps at right angles
    ArchimedeanChords      chords on an Archimedean spiral
    MultipleRings          concentric circles
    PixelRings             concentric circles of pixels
    Hypot                  points by distance
    HypotOctant            first octant points by distance
    TriangularHypot        points by triangular lattice distance
    PythagoreanTree        primitive triples by tree

    PeanoCurve             self-similar base-3 quadrant traversal
    HilbertCurve           self-similar base-2 quadrant traversal
    ZOrderCurve            replicating Z shapes

    GosperIslands          concentric island rings
    GosperSide             single side/radial
    KochCurve              replicating triangular notches
    KochPeaks              two replicating notches
    KochSnowflakes         concentric notched snowflake rings
    SierpinskiArrowhead    self-similar triangle traversal

    Rows                   fixed-width rows
    Columns                fixed-height columns
    Diagonals              diagonals down from the Y to X axes
    Staircase              stairs down from the Y to X axes
    Corner                 expanding stripes around a corner
    PyramidRows            expanding stacked rows pyramid
    PyramidSides           along the sides of a 45-degree pyramid
    CoprimeColumns         coprime X,Y

The paths are object oriented to allow parameters, though many have none as
yet.  See C<examples/numbers.pl> for a cute way to print samples of all the
paths.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::Foo-E<gt>new (key=E<gt>value, ...)>

Create and return a new path object.  Optional key/value parameters may
control aspects of the object.

C<Foo> here is one of the various subclasses, see the list above and under
L</SEE ALSO>.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return x,y coordinates of point C<$n> on the path.  If there's no point
C<$n> then the return is an empty list, so for example

    my ($x,$y) = $path->n_to_xy (-123)
      or next;   # usually no negatives in $path

Paths start from C<$path-E<gt>n_start> below, though some will give a
position for N=0 or N=-0.5 too.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  If there's nothing at
C<$x,$y> then return C<undef>.

    my $n = $path->xy_to_n(20,20);
    if (! defined $n) {
      next;   # nothing at this x,y
    }

C<$x> and C<$y> can be fractional and the path classes will give an integer
C<$n> which contains C<$x,$y> within a unit square, circle, or intended
figure centred on the integer C<$n>.

For paths which completely tile the plane there's always an C<$n> to return,
but for the spread-out paths an C<$x,$y> position may fall in between (no
C<$n> close enough).

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

Return a range of N values which occur in a rectangle with corners at
C<$x1>,C<$y1> and C<$x2>,C<$y2>.  The range is inclusive.  For example,

     my ($n_lo, $n_hi) = $path->rect_to_n_range (-5,-5, 5,5);
     foreach my $n ($n_lo .. $n_hi) {
       my ($x, $y) = $path->n_to_xy ($n) or next;
       print "$n  $x,$y";
     }

The return may be an over-estimate of the range, and many of the points
between C<$n_lo> and C<$n_hi> may go outside the rectangle, but the range is
some bounds for N.

C<$n_hi> is usually no more than an extra partial row, revolution, or
self-similar level.  C<$n_lo> is often merely the starting point
C<$path-E<gt>n_start> below, which is correct if the origin 0,0 is in the
rectangle, but something away from the origin might actually start higher.

C<$x1>,C<$y1> and C<$x2>,C<$y2> can be fractional and if they partly overlap
some N figures then those N's are included in the return.  If there's no
points in the rectangle then the return may be a "crossed" range like
C<$n_lo=1>, C<$n_hi=0> (and which makes a C<foreach> do no loops).

=item C<$bool = $path-E<gt>x_negative()>

=item C<$bool = $path-E<gt>y_negative()>

Return true if the path extends into negative X coordinates and/or negative
Y coordinates respectively.

=item C<$n = $path-E<gt>n_start()>

Return the first N in the path.  In the current classes this is either 0
or 1.

Some classes have secret dubious undocumented support for N values below
this (zero or negative), but C<n_start> is the intended starting point.

=item C<$str = $path-E<gt>figure()>

Return a string name of the figure (shape) intended to be drawn at each
C<$n> position.  This is currently either

    "square"     side 1 centred on $x,$y
    "circle"     diameter 1 centred on $x,$y

Of course this is only a suggestion since PlanePath doesn't draw anything
itself.  A figure like a diamond for instance can look good too.

=back

=head1 GENERAL CHARACTERISTICS

The classes are mostly based on integer C<$n> positions and those designed
for a square grid turn an integer C<$n> into integer C<$x,$y>.  Usually they
give in-between positions for fractional C<$n> too.  Classes not on a square
grid but instead giving fractional X,Y, such as SacksSpiral and VogelFloret,
are designed for a unit circle at each C<$n> but they too can give
in-between positions on request.

All X,Y positions are calculated by separate C<n_to_xy()> calls.  To follow
a path use successive C<$n> values starting from C<$path-E<gt>n_start>.

This separate C<n_to_xy()> calls were motivated by plotting just some points
on a path, such as just the primes or the perfect squares.  Perhaps
successive positions in some paths could be followed in an iterator style
more efficiently.  The quadratic "step" based paths are not much more than a
C<sqrt()> to break N into a segment and offset, but the self-similar paths
chop into base 2 or base 3 digits which might be incremented instead of
recalculated.

=head2 Scaling and Orientation

The paths generally start horizontally to the right or from the X axis on
the right unless there's some more natural orientation.  There's no
parameters for scaling, offset or reflection.  Those things are thought
better left to a general coordinate transformer to expand or invert for
display.  Some easy transformations can be had just from the X,Y with

    -x,y        flip horizontally (mirror image)
    x,-y        flip vertically

    -y,x        rotate +90 degrees
    y,-x        rotate -90 degrees
    -x,-y       rotate 180 degrees

A vertical flip makes the spirals go clockwise instead of anti-clockwise, or
a horizontal flip likewise but starting on the left at the negative X axis.

The Rows and Columns paths are slight exceptions to the rule of not having
rotated versions of paths.  They started as ways to pass in width and height
as generic parameters, and use the one or the other.

See L<Transform::Canvas> and L<Geometry::AffineTransform> for scaling and
shifting.  C<AffineTransform> can rotate too.

=head2 Loop Step

The paths can be characterized by how much longer each loop or repetition is
than the preceding one.  For example each cycle around the SquareSpiral is 8
longer than the preceding.

    Step        Path
    ----        ----
      0       Rows, Columns (fixed widths)
      1       Diagonals
      2       SacksSpiral, PyramidSides, Corner, PyramidRows default
      4       DiamondSpiral, Staircase
      5       PentSpiral, PentSpiralSkewed
      5.65    PixelRings (average about 4*sqrt(2))
      6       HexSpiral, HexSpiralSkewed, MultipleRings default
      6.28    ArchimedeanChords (approaches 2*pi)
      7       HeptSpiralSkewed
      8       SquareSpiral, PyramidSpiral
      9       TriangleSpiral, TriangleSpiralSkewed
     16       OctagramSpiral
     19.74    TheodorusSpiral (approaches 2*pi^2)
     32       KnightSpiral (counting the 2-wide loop)
     72       GreekKeySpiral
   variable   MultipleRings, PyramidRows
    phi(n)    CoprimeColumns


The step determines which quadratic number sequences fall on straight lines.
For example the gap between successive perfect squares increases by 2 each
time (4 to 9 is +5, 9 to 16 is +7, 16 to 25 is +9, etc), so the perfect
squares make a straight line in the paths of step 2.

In general straight lines on the stepped paths are quadratics a*k^2+b*k+c
with a=step/2.  The polygonal numbers are like this, with the (step+2)-gonal
numbers making a straight line on a "step" path.  For example the 7-gonals
(heptagonals) are 5/2*k^2-3/2*k and make a straight line on the step=5
PentSpiral.  Or the 8-gonal octagonals 6/2*k^2-4/2*k on the step=6
HexSpiral.

There are various interesting properties of primes in quadratic
progressions.  Some quadratics seem to have more primes than others, for
instance see PyramidSides for Euler's k^2+k+41.  Many quadratics have no
primes at all, or above a certain point, either trivially if always a
multiple of 2 etc, or by a more sophisticated reasoning.  See PyramidRows
with step 3 for an example of a factorization by the roots giving a
no-primes gap.

A step factor 4 splits a straight line into two, so for example the perfect
squares are a straight line on the step=2 "Corner" path, and then on the
step=8 SquareSpiral they instead fall on two lines (lower left and upper
right).  Effectively in that bigger step it's one line of the even squares
(2k)^2 == 4*k^2 and another of the odd squares (2k+1)^2.  The gap between
successive even squares increases by 8 each time and likewise between odd
squares.

=head2 Self-Similar Powers

The self-similar patterns such as PeanoCurve generally have a base pattern
which repeats at powers N=base^level (or some relation to that for things
like KochPeaks and GosperIslands).

    Base        Path
    ----        ----
      2       HilbertCurve, ZOrderCurve
      3       PeanoCurve, SierpinskiArrowhead,
                GosperIslands, GosperSide
      4       KochCurve, KochPeaks, KochSnowflakes

=head2 Triangular Lattice

Some paths are on triangular or "A2" lattice points like

      *   *   *   *   *   *
    *   *   *   *   *   *
      *   *   *   *   *   *
    *   *   *   *   *   *
      *   *   *   *   *   *
    *   *   *   *   *   *

These are done in integer X,Y on a square grid using every second square,

    . * . * . * . * . * . *
    * . * . * . * . * . * .
    . * . * . * . * . * . *
    * . * . * . * . * . * .
    . * . * . * . * . * . *
    * . * . * . * . * . * .

In these coordinates X,Y are either both even or both odd.  The X axis and
the diagonals X=Y and X=-Y divide the plane into six parts.  The diagonal
X=3*Y is the midpoint of the first sixth, representing a twelfth of the
plane.

The resulting triangles are a little flatter than they should be.  The base
is width=2 and peak is height=1, whereas height=sqrt(3) would be equilateral
triangle.  That factor can be applied if desired,

    X, Y*sqrt(3)          side length 2
    X/2, Y*sqrt(3)/2      side length 1

The integer Y values have the advantage of fitting on pixels of a rasterized
display, and not losing precision in floating point.

If using a general-purpose coordinate rotation then be sure to apply the
above sqrt(3) scale factor first, or the rotation is wrong.  Rotations can
be made in the integer X,Y coordinates directly as follows (all resulting in
integers too),

    (X-3Y)/2, (X+Y)/2       rotate +60
    (X+3Y)/2, (Y-X)/2       rotate -60
    -(X+3Y), (X-Y)/2        rotate +120
    (3Y-X), -(X+Y)/2        rotate -120
    -X,-Y                   rotate 180

    (X+3Y)/2, (X-Y)/2       flip across the X=3*Y twelfth line

The sqrt(3) factor can be worked into a hypotenuse radial distance
calculation as

    hypot = sqrt(X*X + 3*Y*Y)

if comparing distances from the origin of points at different angles.  See
for instance TriangularHypot taking triangular points by radial distance.

=head1 SEE ALSO

L<Math::PlanePath::SquareSpiral>,
L<Math::PlanePath::PyramidSpiral>,
L<Math::PlanePath::TriangleSpiral>,
L<Math::PlanePath::TriangleSpiralSkewed>,
L<Math::PlanePath::DiamondSpiral>,
L<Math::PlanePath::PentSpiral>,
L<Math::PlanePath::PentSpiralSkewed>,
L<Math::PlanePath::HexSpiral>,
L<Math::PlanePath::HexSpiralSkewed>,
L<Math::PlanePath::HeptSpiralSkewed>,
L<Math::PlanePath::OctagramSpiral>,
L<Math::PlanePath::KnightSpiral>
L<Math::PlanePath::GreekKeySpiral>

L<Math::PlanePath::SacksSpiral>,
L<Math::PlanePath::VogelFloret>,
L<Math::PlanePath::TheodorusSpiral>,
L<Math::PlanePath::MultipleRings>,
L<Math::PlanePath::PixelRings>,
L<Math::PlanePath::Hypot>,
L<Math::PlanePath::HypotOctant>,
L<Math::PlanePath::TriangularHypot>,
L<Math::PlanePath::PythagoreanTree>,
L<Math::PlanePath::CoprimeColumns>

L<Math::PlanePath::PeanoCurve>,
L<Math::PlanePath::HilbertCurve>,
L<Math::PlanePath::ZOrderCurve>,
L<Math::PlanePath::GosperIslands>,
L<Math::PlanePath::GosperSide>,
L<Math::PlanePath::KochCurve>,
L<Math::PlanePath::KochPeaks>,
L<Math::PlanePath::KochSnowflakes>,
L<Math::PlanePath::SierpinskiArrowhead>

L<Math::PlanePath::Rows>,
L<Math::PlanePath::Columns>,
L<Math::PlanePath::Diagonals>,
L<Math::PlanePath::Staircase>,
L<Math::PlanePath::Corner>,
L<Math::PlanePath::PyramidRows>,
L<Math::PlanePath::PyramidSides>

L<math-image>, displaying various sequences on these paths.

F<examples/numbers.pl> in the sources to print all the paths.

L<Math::Fractal::Curve>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

http://user42.tuxfamily.org/math-planepath/gallery.html

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
