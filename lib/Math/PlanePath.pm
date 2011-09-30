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
require 5;
use strict;

use vars '$VERSION';
$VERSION = 45;

# uncomment this to run the ### lines
#use Devel::Comments;

# defaults
use constant n_start => 1;
use constant x_negative => 1;
use constant y_negative => 1;
use constant figure => 'square';
use constant arms_count => 1;

sub new {
  my $class = shift;
  return bless { @_ }, $class;
}

use constant parameter_info_array => [];
sub parameter_info_list {
  return @{$_[0]->parameter_info_array};
}

# not documented yet
my %parameter_info_hash;
sub parameter_info_hash {
  my ($class_or_self) = @_;
  my $class = (ref $class_or_self || $class_or_self);
  return ($parameter_info_hash{$class}
          ||= { map { $_->{'name'} => $_ }
                $class_or_self->parameter_info_list });
}

# sub parameter_info_hash {
#   my ($class) = @_;
#   return { map { $_->{'name'}, $_ }
#            @{$class->parameter_info_array} };
# }


#------------------------------------------------------------------------------
# shared internals

sub _is_infinite {
  my ($x) = @_;
  return ($x != $x         # nan
          || $x-1 == $x);  # inf
}

# With a view to being friendly to BigRat/BigFloat.
#
# For reference, POSIX::floor() in perl 5.12.4 is a bit bizarre on UV=64bit
# and NV=53bit double.  UV=2^64-1 rounds up to NV=2^64 which floor() then
# returns, so floor() in fact increases the value of what was an integer
# already.
#
sub _floor {
  my ($x) = @_;
  ### _floor(): "$x", $x
  my $int = int($x);
  if ($x == $int) {
    ### is an integer ...
    return $x;
  }
  $x -= $int;
  ### frac: "$x"
  if ($x >= 0) {
    ### frac is non-negative ...
    return $int;
  } else {
    ### frac is negative ...
    return $int-1;
  }
}

# with a view to being friendly to BigRat/BigFloat
sub _round_nearest {
  my ($x) = @_;
  ### _round_nearest(): "$x", $x

  # BigRat through to perl 5.12.4 has some dodginess giving a bigint -0
  # which is considered !=0.  Adding +0 to numify seems to avoid the problem.
  my $int = int($x) + 0;
  if ($x == $int) {
    ### is an integer ...
    return $x;
  }
  $x -= $int;
  ### int:  "$int"
  ### frac: "$x"
  if ($x >= .5) {
    ### round up ...
    return $int + 1;
  }
  if ($x < -.5) {
    ### round down ...
    return $int - 1;
  }
  ### within +/- .5 ...
  return $int;
}

1;
__END__

=for stopwords SquareSpiral SacksSpiral VogelFloret PlanePath Ryde Math-PlanePath 7-gonals 8-gonal (step+2)-gonal heptagonals PentSpiral octagonals HexSpiral PyramidSides PyramidRows ArchimedeanChords PeanoCurve KochPeaks GosperIslands TriangularHypot bignum multi-arm SquareArms eg PerlMagick nan nans subclasses incrementing arrayref hashref filename enum radix MERCHANTABILITY

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

    SquareArms             four-arm square spiral
    DiamondArms            four-arm diamond spiral
    HexArms                six-arm hexagonal spiral
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
    RationalsTree          rationals X/Y by tree

    PeanoCurve             self-similar base-3 quadrant traversal
    HilbertCurve           self-similar base-2 quadrant traversal
    ZOrderCurve            replicating Z shapes
    ImaginaryBase          replicating in four directions

    Flowsnake              self-similar hexagonal tile traversal
    FlowsnakeCentres         likewise, but centres of hexagons
    GosperIslands          concentric island rings
    GosperSide             single side/radial

    QuintetCurve           self-similar "+" shape
    QuintetCentres           likewise, but centres of squares
    QuintetReplicate       self-similar "+" tiling

    DragonCurve            paper folding
    DragonRounded            same but rounding-off vertices
    DragonMidpoint         paper folding midpoints
    ComplexMinus           twindragon and other base i-r

    KochCurve              replicating triangular notches
    KochPeaks              two replicating notches
    KochSnowflakes         concentric notched snowflake rings
    KochSquareflakes       concentric notched 4-sided rings
    QuadricCurve           eight segment zig-zag
    QuadricIslands         rings of those zig-zags
    SierpinskiTriangle     self-similar triangle by rows
    SierpinskiArrowhead    self-similar triangle connectedly
    SierpinskiArrowheadCentres  likewise, but centres of triangles

    Rows                   fixed-width rows
    Columns                fixed-height columns
    Diagonals              diagonals down from the Y to X axes
    Staircase              stairs down from the Y to X axes
    Corner                 expanding stripes around a corner
    PyramidRows            expanding stacked rows pyramid
    PyramidSides           along the sides of a 45-degree pyramid
    CellularRule54         cellular automaton rows pattern

    CoprimeColumns         coprime X,Y
    File                   points from a disk file

The paths are object oriented to allow parameters, though many have none as
yet.  See C<examples/numbers.pl> in the Math-PlanePath sources for a cute
sample printout of selected paths or all paths.

=head2 Number Types

The C<$n> and C<$x,$y> parameters can be either integers or floating point.
The paths are meant to do something sensible with floating point fractions.
Expect rounding-off for big exponents.

Floating point infinities (when available on the system) are meant to give
nan or infinite returns of some kind (some unspecified kind as yet).
C<n_to_xy()> on negative infinity C<$n> is generally an empty return, the
same as other negative C<$n>.  Calculations which break an input into digits
of some base are meant not to loop infinitely on infinities.

Floating point nans (when available on the system) are meant to give nan,
infinite, or empty/undef returns, but again of some unspecified kind as yet
and again not going into infinite loops.

One or two of the classes can operate on C<Math::BigInt>, C<Math::BigRat>
and C<Math::BigFloat> inputs and give corresponding outputs, but this is
experimental and many classes might truncate a bignum to a float as yet.  In
general the intention is to make the code generic enough that it can act on
overloaded number types.  Note that new enough versions of the bignum
modules might be required, perhaps Perl 5.8 and up so for instance the C<**>
exponentiation operator is available.

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
between C<$n_lo> and C<$n_hi> may go outside the rectangle, but the range at
least bounds N.

C<$n_hi> is usually no more than an extra partial row, revolution, or
self-similar level.  C<$n_lo> is often merely the starting point
C<$path-E<gt>n_start()> below, which is correct enough if the origin is in
the rectangle, but something away from the origin might actually start
higher.

C<$x1>,C<$y1> and C<$x2>,C<$y2> can be fractional and if they partly overlap
some N figures then those N's are included in the return.  If there's no
points in the rectangle then the return may be a "crossed" range like
C<$n_lo=1>, C<$n_hi=0> (and which makes a C<foreach> do no loops).  But
C<rect_to_n_range()> might not notice there's no points in the rectangle and
instead over-estimate the range.

=item C<$bool = $path-E<gt>x_negative()>

=item C<$bool = $path-E<gt>y_negative()>

Return true if the path extends into negative X coordinates and/or negative
Y coordinates respectively.

=item C<$n = $path-E<gt>n_start()>

Return the first N in the path.  In the current classes this is either 0
or 1.

Some classes have secret dubious undocumented support for N values below
this (zero or negative), but C<n_start> is the intended starting point.

=item C<$arms = $path-E<gt>arms_count()>

Return the number of arms in a "multi-arm" path.

For example in SquareArms this is 4 and each arm increments in turn, so the
first arm is N=1,5,9,13, etc, incrementing by 4 each time.

=item C<$str = $path-E<gt>figure()>

Return a string name of the figure (shape) intended to be drawn at each
C<$n> position.  This is currently either

    "square"     side 1 centred on $x,$y
    "circle"     diameter 1 centred on $x,$y

Of course this is only a suggestion since PlanePath doesn't draw anything
itself.  A figure like a diamond for instance can look good too.

=item C<$aref = Math::PlanePath::Foo-E<gt>parameter_info_array()>

=item C<@list = Math::PlanePath::Foo-E<gt>parameter_info_list()>

Return an arrayref of list describing the parameters taken by a given class.
This meant to help making widgets etc for user interaction in a GUI.  Each
element is a hashref

    {
      name        =>    parameter key arg for new()
      description =>    human readable string
      type        =>    string "integer","boolean","enum" etc
      default     =>    value
      minimum     =>    number, or undef
      maximum     =>    number, or undef
      width       =>    integer, suggested display size
      choices     =>    for enum, an arrayref     
    }

C<type> is a string, one of

    "integer"
    "enum"
    "boolean"
    "string"
    "filename"

"filename" is separate from "string" since it might require subtly different
handling to ensure it reaches Perl as a byte string, whereas a "string" type
might in principle take Perl wide chars.

For "enum" the C<choices> field is the possible values, such as

    { name => "flavour",
      type => "enum",
      choices => ["strawberry","chocolate"],
    }

C<minimum> and C<maximum> are omitted if there's no hard limit on the
parameter.

=back

=head1 GENERAL CHARACTERISTICS

The classes are mostly based on integer C<$n> positions and those designed
for a square grid turn an integer C<$n> into integer C<$x,$y>.  Usually they
give in-between positions for fractional C<$n> too.  Classes not on a square
grid but instead giving fractional X,Y such as SacksSpiral and VogelFloret
are designed for a unit circle at each C<$n> but they too can give
in-between positions on request.

All X,Y positions are calculated by separate C<n_to_xy()> calls.  To follow
a path use successive C<$n> values starting from C<$path-E<gt>n_start>.

The separate C<n_to_xy()> calls were motivated by plotting just some points
on a path, such as just the primes or the perfect squares.  Perhaps
successive positions in some paths could be done in an iterator style more
efficiently.  The paths with a quadratic "step" are not much worse than a
C<sqrt()> to break N into a segment and offset, but the self-similar paths
which chop into digits of some radix might increment instead of recalculate.

=head2 Scaling and Orientation

The paths generally make a first move horizontally to the right, or from the
X axis anti-clockwise, unless there's some more natural orientation.
There's no parameters for scaling, offset or reflection as those things are
thought better left to a general coordinate transformer to expand or invert
for display.  But some easy transformations can be had just from the X,Y
with

    -X,Y        flip horizontally (mirror image)
    X,-Y        flip vertically (across the X axis)

    -Y,X        rotate +90 degrees  (anti-clockwise)
    Y,-X        rotate -90 degrees
    -X,-Y       rotate 180 degrees

A vertical flip makes the spirals go clockwise instead of anti-clockwise, or
a horizontal flip the same but starting on the left at the negative X axis.

The Rows and Columns paths are slight exceptions to the rule of not having
rotated versions of paths.  They started as ways to pass in width and height
as generic parameters, and have the path use the one or the other.

For scaling and shifting see for example L<Transform::Canvas>, or for
rotating as well see L<Geometry::AffineTransform>.

=head2 Loop Step

The paths can be characterized by how much longer each loop or repetition is
than the preceding one.  For example each cycle around the SquareSpiral is 8
more N points than the preceding.

      Step        Path
      ----        ----
        0       Rows, Columns (fixed widths)
        1       Diagonals
        2       SacksSpiral, PyramidSides, Corner, PyramidRows (default)
        4       DiamondSpiral, Staircase, CellularRule54 (two rows)
        5       PentSpiral, PentSpiralSkewed
        5.65    PixelRings (average about 4*sqrt(2))
        6       HexSpiral, HexSpiralSkewed, MultipleRings (default)
        6.28    ArchimedeanChords (approaching 2*pi)
        7       HeptSpiralSkewed
        8       SquareSpiral, PyramidSpiral
        9       TriangleSpiral, TriangleSpiralSkewed
       16       OctagramSpiral
       19.74    TheodorusSpiral (approaching 2*pi^2)
       32       KnightSpiral (counting the 2-wide loop)
       64       DiamondArms (each arm)
       72       GreekKeySpiral
      128       SquareArms (each arm)
      216       HexArms (each arm)
    parameter   MultipleRings, PyramidRows
     totient    CoprimeColumns


The step determines which quadratic number sequences fall on straight lines.
For example the gap between successive perfect squares increases by 2 each
time (4 to 9 is +5, 9 to 16 is +7, 16 to 25 is +9, etc), so the perfect
squares make a straight line in the paths of step 2.

In general straight lines on the stepped paths are quadratics a*k^2+b*k+c
with a=step/2.  The polygonal numbers are like this, with the (step+2)-gonal
numbers making a straight line on a "step" path.  For example the 7-gonals
(heptagonals) are 5/2*k^2-3/2*k and make a straight line on the step=5
PentSpiral.  Or the 8-gonal octagonal numbers 6/2*k^2-4/2*k on the step=6
HexSpiral.

There are various interesting properties of primes in quadratic
progressions.  Some quadratics seem to have more primes than others,
eg. L<Math::PlanePath::PyramidSides/Lucky Numbers of Euler>.  Many
quadratics have no primes at all, or none above a certain point, either
trivially if always a multiple of 2 etc, or by a more sophisticated
reasoning.  See L<Math::PlanePath::PyramidRows/Step 3 Pentagonals> for a
factorization by the roots making a no-primes gap.

A step factor 4 splits a straight line in two, so for example the perfect
squares are a straight line on the step=2 "Corner" path, and then on the
step=8 SquareSpiral they instead fall on two lines (lower left and upper
right).  Effectively in that bigger step it's one line of the even squares
(2k)^2 == 4*k^2 and another of the odd squares (2k+1)^2.  The gap between
successive even squares increases by 8 each time and likewise between odd
squares.

=head2 Self-Similar Powers

The self-similar patterns such as PeanoCurve generally have a base pattern
which repeats at powers N=base^level (or some multiple or relation to that
for things like KochPeaks and GosperIslands).

    Base          Path
    ----          ----
      2         HilbertCurve, ZOrderCurve (default),
                  ImaginaryBase (default),
                  DragonCurve, DragonRounded, DragonMidpoint,
      3         PeanoCurve (default), GosperIslands, GosperSide
                  SierpinskiTriangle,
                  SierpinskiArrowhead, SierpinskiArrowheadCentres,
      4         KochCurve, KochPeaks, KochSnowflakes, KochSquareflakes
      8         QuadricCurve, QuadricIslands
    parameter   PeanoCurve, ZOrderCurve, ImaginaryBase

Many number sequences on these paths tend to come out fairly random, or
merely show the tiling or nature of the path layout rather than much about
the number sequence.  Number sequences related to the base can make holes or
patterns picking out parts of the path.  For example numbers without a
particular digit (or digits) in the relevant base show up as holes,
eg. L<Math::PlanePath::ZOrderCurve/Power of 2 Values>.

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
X=3*Y is the middle of the first sixth, representing a twelfth of the plane.

The resulting triangles are a little flatter than they should be.  The base
is width=2 and peak is height=1, where height=sqrt(3) would be equilateral
triangles.  That sqrt(3) factor can be applied if desired,

    X, Y*sqrt(3)          side length 2
      or
    X/2, Y*sqrt(3)/2      side length 1

The integer Y values have the advantage of fitting pixels of the usual kind
of raster screen, and not losing precision in floating point results.

If doing a general-purpose coordinate rotation then be sure to apply the
sqrt(3) scale factor first, or the rotation is wrong.  Rotations can be made
within the integer X,Y coordinates directly as follows (all resulting in
integers),

    (X-3Y)/2, (X+Y)/2       rotate +60   (anti-clockwise)
    (X+3Y)/2, (Y-X)/2       rotate -60
    -(X+3Y)/2, (X-Y)/2      rotate +120
    (3Y-X)/2, -(X+Y)/2      rotate -120
    -X,-Y                   rotate 180

    (X+3Y)/2, (X-Y)/2       mirror across the X=3*Y twelfth line

The sqrt(3) factor can be worked into a hypotenuse radial distance
calculation as follows if comparing distances from the origin of points at
different angles.  See for instance TriangularHypot taking triangular points
by radial distance.

    hypot = sqrt(X*X + 3*Y*Y)

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

L<Math::PlanePath::HexArms>,
L<Math::PlanePath::SquareArms>,
L<Math::PlanePath::DiamondArms>,
L<Math::PlanePath::GreekKeySpiral>

L<Math::PlanePath::SacksSpiral>,
L<Math::PlanePath::VogelFloret>,
L<Math::PlanePath::TheodorusSpiral>,
L<Math::PlanePath::MultipleRings>,
L<Math::PlanePath::PixelRings>,
L<Math::PlanePath::Hypot>,
L<Math::PlanePath::HypotOctant>,
L<Math::PlanePath::TriangularHypot>

L<Math::PlanePath::PeanoCurve>,
L<Math::PlanePath::HilbertCurve>,
L<Math::PlanePath::ZOrderCurve>,
L<Math::PlanePath::ImaginaryBase>,
L<Math::PlanePath::Flowsnake>,
L<Math::PlanePath::FlowsnakeCentres>,
L<Math::PlanePath::GosperIslands>,
L<Math::PlanePath::GosperSide>

L<Math::PlanePath::QuintetCurve>,
L<Math::PlanePath::QuintetCentres>,
L<Math::PlanePath::QuintetReplicate>

L<Math::PlanePath::KochCurve>,
L<Math::PlanePath::KochPeaks>,
L<Math::PlanePath::KochSnowflakes>,
L<Math::PlanePath::KochSquareflakes>,
L<Math::PlanePath::QuadricCurve>,
L<Math::PlanePath::QuadricIslands>

L<Math::PlanePath::SierpinskiArrowhead>,
L<Math::PlanePath::SierpinskiArrowheadCentres>,
L<Math::PlanePath::DragonCurve>,
L<Math::PlanePath::DragonRounded>,
L<Math::PlanePath::DragonMidpoint>

L<Math::PlanePath::Rows>,
L<Math::PlanePath::Columns>,
L<Math::PlanePath::Diagonals>,
L<Math::PlanePath::Staircase>,
L<Math::PlanePath::Corner>,
L<Math::PlanePath::PyramidRows>,
L<Math::PlanePath::PyramidSides>,
L<Math::PlanePath::CellularRule54>

L<Math::PlanePath::PythagoreanTree>,
L<Math::PlanePath::RationalsTree>,
L<Math::PlanePath::CoprimeColumns>,
L<Math::PlanePath::File>

L<math-image>, displaying various sequences on these paths.

F<examples/numbers.pl> in the Math-PlanePath source code, to print all the
paths.

L<Math::Fractal::Curve>,
L<Math::Curve::Hilbert>,
L<Algorithm::SpatialIndex::Strategy::QuadTree>

PerlMagick (L<Image::Magick>) demo scripts F<lsys.pl> and C<tree.pl>

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



#     ZigzagOct              zig-zag of eight segments
#       8       ZigzagOct
# L<Math::PlanePath::ZigzagOct>
