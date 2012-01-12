# Copyright 2010, 2011, 2012 Kevin Ryde

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
$VERSION = 64;

# uncomment this to run the ### lines
#use Devel::Comments;

# defaults
use constant n_start => 1;
use constant figure => 'square';
use constant arms_count => 1;

use constant class_x_negative => 1;
use constant class_y_negative => 1;
sub x_negative { $_[0]->class_x_negative }
sub y_negative { $_[0]->class_y_negative }

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
          || ($x != 0 && $x == 2*$x));  # inf
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

sub _max {
  my $max = 0;
  foreach my $i (1 .. $#_) {
    if ($_[$i] > $_[$max]) {
      $max = $i;
    }
  }
  return $_[$max];
}
sub _min {
  my $min = 0;
  foreach my $i (1 .. $#_) {
    if ($_[$i] < $_[$min]) {
      $min = $i;
    }
  }
  return $_[$min];
}

sub _rect_for_first_quadrant {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  $x1 = _round_nearest($x1);
  $y1 = _round_nearest($y1);
  $x2 = _round_nearest($x2);
  $y2 = _round_nearest($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  if ($x2 < 0 || $y2 < 0) {
    return;
  }
  return ($x1,$y1, $x2,$y2);
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
position C<$n> to and from coordinates C<$x,$y> in the plane.  The current
classes include

=for my_pod list begin

    SquareSpiral           four-sided spiral
    PyramidSpiral          square base pyramid
    TriangleSpiral         equilateral triangle spiral
    TriangleSpiralSkewed   equilateral skewed for compactness
    DiamondSpiral          four-sided spiral, looping faster
    PentSpiral             five-sided spiral
    PentSpiralSkewed       five-sided spiral, compact
    HexSpiral              six-sided spiral
    HexSpiralSkewed        six-sided spiral skewed for compactness
    HeptSpiralSkewed       seven-sided spiral, compact
    AnvilSpiral            anvil shape
    OctagramSpiral         eight pointed star
    KnightSpiral           an infinite knight's tour

    SquareArms             four-arm square spiral
    DiamondArms            four-arm diamond spiral
    AztecDiamondRings      four-sided rings
    HexArms                six-arm hexagonal spiral
    GreekKeySpiral         spiral with Greek key motif
    MPeaks                 "M" shape layers

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

    PeanoCurve             3x3 self-similar quadrant traversal
    HilbertCurve           2x2 self-similar quadrant traversal
    HilbertSpiral          2x2 self-similar whole-plane traversal
    ZOrderCurve            replicating Z shapes
    WunderlichMeander      3x3 "R" pattern quadrant traversal
    BetaOmega              2x2 self-similar half-plane traversal
    AR2W2Curve             2x2 self-similar of four shapes
    KochelCurve            3x3 self-similar two shapes
    CincoCurve             5x5 self-similar

    ImaginaryBase          replicating in four directions
    SquareReplicate        3x3 replicating squares
    CornerReplicate        2x2 replicating squares
    LTiling                self-simlar L shapes
    DigitGroups            digit groups of high zero
    FibonacciWordFractal   turns by Fibonacci word bits

    Flowsnake              self-similar hexagonal tile traversal
    FlowsnakeCentres         likewise, but centres of hexagons
    GosperReplicate        self-similar hexagonal tiling
    GosperIslands          concentric island rings
    GosperSide             single side or radial

    QuintetCurve           self-similar "+" shape
    QuintetCentres           likewise, but centres of squares
    QuintetReplicate       self-similar "+" tiling

    DragonCurve            paper folding
    DragonRounded            same but rounding-off vertices
    DragonMidpoint         paper folding midpoints
    AlternatePaper         paper folding in alternating directions
    TerdragonCurve         ternary dragon
    ComplexPlus            base i+r
    ComplexMinus           base i-r, including twindragon
    ComplexRevolving       revolving base i+1

    SierpinskiCurve        self-similar right-triangles
    HIndexing              self-similar right-triangles, squared up

    KochCurve              replicating triangular notches
    KochPeaks              two replicating notches
    KochSnowflakes         concentric notched 3-sided rings
    KochSquareflakes       concentric notched 4-sided rings
    QuadricCurve           eight segment zig-zag
    QuadricIslands           rings of those zig-zags
    SierpinskiTriangle     self-similar triangle by rows
    SierpinskiArrowhead    self-similar triangle connectedly
    SierpinskiArrowheadCentres  likewise, but centres of triangles

    Rows                   fixed-width rows
    Columns                fixed-height columns
    Diagonals              diagonals down from the Y to X axes
    DiagonalsAlternating   diagonals Y to X and back again
    Staircase              stairs down from the Y to X axes
    StaircaseAlternating   stairs Y to X and back again
    Corner                 expanding stripes around a corner
    PyramidRows            expanding stacked rows pyramid
    PyramidSides           along the sides of a 45-degree pyramid
    CellularRule           cellular automaton by rule number
    CellularRule54         cellular automaton rows pattern
    CellularRule190        cellular automaton rows pattern
    UlamWarburton          cellular automaton diamonds
    UlamWarburtonQuarter   cellular automaton quarter-plane

    DiagonalRationals      rationals X/Y by diagonals
    FactorRationals        rationals X/Y by prime factorization
    GcdRationals           rationals X/Y by rows with GCD integer
    RationalsTree          rationals X/Y by tree
    FractionsTree          fractions 0<X/Y<1 by tree
    CoprimeColumns         coprime X,Y
    DivisibleColumns       X divisible by Y
    File                   points from a disk file

=for my_pod list end

The paths are object oriented to allow parameters, though many have none.
See C<examples/numbers.pl> in the Math-PlanePath sources for a cute sample
printout of the numbering for selected paths or all paths.

=head2 Number Types

The C<$n> and C<$x,$y> parameters can be either integers or floating point.
The paths are meant to do something sensible with floating point fractions.
Expect rounding-off for big exponents.

Floating point infinities (when available) are meant to give nan or infinite
returns of some kind (some unspecified kind as yet).  C<n_to_xy()> on
negative infinity C<$n> is an empty return, the same as other negative
C<$n>.  Calculations which break an input into digits of some base are meant
not to loop infinitely on infinities.

Floating point nans (when available) are meant to give nan, infinite, or
empty/undef returns, but again of some unspecified kind as yet but in any
case not going into infinite loops.

Many of the classes can operate on overloaded number types as inputs and
give corresponding outputs.

    Math::BigInt        maybe perl 5.8 up, for ** operator
    Math::BigRat
    Math::BigFloat
    Number::Fraction    1.14 or higher (for abs())

This is slightly experimental and some classes might truncate a bignum or a
fraction to a float as yet.  In general the intention is to make the code
generic enough that it can act on sensible number types.  Recent versions of
the bignum modules might be required, perhaps Perl 5.8 and up for the C<**>
exponentiation operator in particular.

For reference, an C<undef> input to C<$n>, C<$x,$y>, etc, is meant to
provoke an uninitialized value warnings (when warnings are enabled), but
currently doesn't croak etc.  Perhaps that will change, but the warning at
least prevents bad inputs going unnoticed.

=head1 FUNCTIONS

In the following C<Foo> is one of the various subclasses, see the list above
and under L</SEE ALSO>.

=over 4

=item C<$path = Math::PlanePath::Foo-E<gt>new (key=E<gt>value, ...)>

Create and return a new path object.  Optional key/value parameters may
control aspects of the object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return X,Y coordinates of point C<$n> on the path.  If there's no point
C<$n> then the return is an empty list, so for example

    my ($x,$y) = $path->n_to_xy (-123)
      or next;   # usually no negatives in $path

Paths start from C<$path-E<gt>n_start> below, though some will give a
position for N=0 or N=-0.5 too.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the N point number for coordinates C<$x,$y>.  If there's nothing at
C<$x,$y> then return C<undef>.

    my $n = $path->xy_to_n(20,20);
    if (! defined $n) {
      next;   # nothing at this X,Y
    }

C<$x> and C<$y> can be fractional and the path classes will give an integer
C<$n> which contains C<$x,$y> within a unit square, circle, or intended
figure centred on the integer C<$n>.

For paths which completely tile the plane there's always an C<$n> to return,
but for the spread-out paths an C<$x,$y> position may fall in between (no
C<$n> close enough).

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

Return a range of N values covering or exceeding a rectangle with corners at
C<$x1>,C<$y1> and C<$x2>,C<$y2>.  The range is inclusive.  For example,

     my ($n_lo, $n_hi) = $path->rect_to_n_range (-5,-5, 5,5);
     foreach my $n ($n_lo .. $n_hi) {
       my ($x, $y) = $path->n_to_xy ($n) or next;
       print "$n  $x,$y";
     }

The return may be an over-estimate of the range, and in all cases many of
the points between C<$n_lo> and C<$n_hi> might be outside the rectangle.
But the range at least bounds the N values which occur in the rectangle.
Classes which guarantee an exact lo/hi range say so in their docs.

C<$n_hi> is usually no more than an extra partial row, revolution, or
self-similar level.  C<$n_lo> is often merely the starting
C<$path-E<gt>n_start()>, which is fine if the origin is in the rectangle but
something away from the origin might actually start higher.

C<$x1>,C<$y1> and C<$x2>,C<$y2> can be fractional and if they partly overlap
some N figures then those N's are included in the return.

If there's no points in the rectangle then the return can be a "crossed"
range like C<$n_lo=1>, C<$n_hi=0> (and which makes a C<foreach> do no
loops).  Though C<rect_to_n_range()> might not notice there's no points in
the rectangle and instead over-estimate the range.

=item C<$n = $path-E<gt>n_start()>

Return the first N in the path.  In the current classes this is either 0
or 1.

Some classes have secret dubious undocumented support for N values below
this (zero or negative), but C<n_start()> is the intended starting point.

=item C<$bool = $path-E<gt>x_negative()>

=item C<$bool = $path-E<gt>y_negative()>

Return true if the path extends into negative X coordinates and/or negative
Y coordinates respectively.

=item C<$bool = Math::PlanePath::Foo-E<gt>class_x_negative()>

=item C<$bool = Math::PlanePath::Foo-E<gt>class_y_negative()>

=item C<$bool = $path-E<gt>class_x_negative()>

=item C<$bool = $path-E<gt>class_y_negative()>

Return true if any paths made by this class extends into negative X
coordinates and/or negative Y coordinates, respectively.

For some classes the X or Y extent may depend on parameter values.

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
      share_key   =>    string, or undef
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

C<minimum> and/or C<maximum> are omitted if there's no hard limit on the
parameter.

C<share_key> is designed to indicate when parameters from different NumSeq
classes can be a single control widget in a GUI etc.  Normally the C<name>
is enough, but when the same name has slightly different meanings in
different classes a C<share_key> allows the same meanings to be matched up.

=back

=head1 GENERAL CHARACTERISTICS

The classes are mostly based on integer C<$n> positions and those designed
for a square grid turn an integer C<$n> into integer C<$x,$y>.  Usually they
give in-between positions for fractional C<$n> too.  Classes not on a square
grid but instead giving fractional X,Y such as SacksSpiral and VogelFloret
are designed for a unit circle at each C<$n> but they too can give
in-between positions on request.

All X,Y positions are calculated by separate C<n_to_xy()> calls.  To follow
a path use successive C<$n> values starting from C<$path-E<gt>n_start()>.

    foreach my $n ($path->n_start .. 100) {
      my ($x,$y) = $path->n_to_xy($n);
      print "$n  $x,$y\n";
    }

The separate C<n_to_xy()> calls were motivated by plotting just some points
of a path, such as just the primes or the perfect squares.  Successive
positions in paths could be done in an iterator style more efficiently.  The
paths with a quadratic "step" are not much worse than a C<sqrt()> to break N
into a segment and offset, but the self-similar paths which chop N into
digits of some radix might increment instead of recalculate.

A disadvantage of an iterator is that if you're only interested in a
particular rectangular or similar region then the iteration may stray
outside for a long time, making it much less useful than it seems.  For wild
paths it can be better to apply C<xy_to_n()> by rows or similar, on the
square-grid paths at least.

=head2 Scaling and Orientation

The paths generally make a first move horizontally to the right or from the
X axis anti-clockwise, unless there's some more natural orientation.

There's no parameters for scaling, offset or reflection as those things are
thought better left to a general coordinate transformer, for example to
expand or invert for display.  But some easy transformations can be had just
from the X,Y with

    -X,Y        flip horizontally (mirror image)
    X,-Y        flip vertically (across the X axis)

    -Y,X        rotate +90 degrees  (anti-clockwise)
    Y,-X        rotate -90 degrees  (clockwise)
    -X,-Y       rotate 180 degrees

Flip vertically makes the spirals go clockwise instead of anti-clockwise, or
a flip horizontally the same but starting on the left at the negative X
axis.  See L</Triangular Lattice> below for 60 degree rotations of the
triangular grid paths.

The Rows and Columns paths are slight exceptions to the rule of not having
rotated versions of paths.  They began as ways to pass in width and height
as generic parameters and let the path use the one or the other.

For scaling and shifting see L<Transform::Canvas> or to rotate as well see
L<Geometry::AffineTransform>.

=head2 Loop Step

The paths can be characterized by how much longer each loop or repetition is
than the preceding one.  For example each cycle around the SquareSpiral is 8
more N points than the preceding.

=for my_pod step begin

      Step        Path
      ----        ----
        0       Rows, Columns (fixed widths)
        1       Diagonals
        2       SacksSpiral, PyramidSides, Corner, PyramidRows (default)
        4       DiamondSpiral, AztecDiamondRings, Staircase
       4/2      CellularRule54, DiagonalsAlternating (2 rows for +4)
        5       PentSpiral, PentSpiralSkewed
       5.65     PixelRings (average about 4*sqrt(2))
        6       HexSpiral, HexSpiralSkewed, MPeaks,
                  MultipleRings (default)
       6/2      CellularRule190 (2 rows for +6)
       6.28     ArchimedeanChords (approaching 2*pi)
        7       HeptSpiralSkewed
        8       SquareSpiral, PyramidSpiral
      16/2      StaircaseAlternating (up and back for +16)
        9       TriangleSpiral, TriangleSpiralSkewed
       12       AnvilSpiral
       16       OctagramSpiral
      19.74     TheodorusSpiral (approaching 2*pi^2)
      32/4      KnightSpiral (4 loops 2-wide for +32)
       64       DiamondArms (each arm)
       72       GreekKeySpiral
      128       SquareArms (each arm)
      216       HexArms (each arm)
    parameter   MultipleRings, PyramidRows

    totient     CoprimeColumns, DiagonalRationals
    divcount    DivisibleColumns
    various     CellularRule

=for my_pod step end

The step determines which quadratic number sequences make straight lines.
For example the gap between successive perfect squares increases by 2 each
time (4 to 9 is +5, 9 to 16 is +7, 16 to 25 is +9, etc), so the perfect
squares make a straight line in the paths of step 2.

In general straight lines on stepped paths are quadratics

   N = a*k^2 + b*k + c    where a=step/2

The polygonal numbers are like this, with the (step+2)-gonal numbers making
a straight line on a "step" path.  For example the 7-gonals (heptagonals)
are 5/2*k^2-3/2*k and make a straight line on the step=5 PentSpiral.  Or the
8-gonal octagonal numbers 6/2*k^2-4/2*k on the step=6 HexSpiral.

There are various interesting properties of primes in quadratic
progressions.  Some quadratics seem to have more primes than others.  For
example see L<Math::PlanePath::PyramidSides/Lucky Numbers of Euler>.  Many
quadratics have no primes at all, or none above a certain point, either
trivially if always a multiple of 2 etc, or by a more sophisticated
reasoning.  See L<Math::PlanePath::PyramidRows/Step 3 Pentagonals> for a
factorization on the roots making a no-primes gap.

A 4*step path splits a straight line in two, so for example the perfect
squares are a straight line on the step=2 "Corner" path, and then on the
step=8 SquareSpiral they instead fall on two lines (lower left and upper
right).  In that bigger step there's one line of the even squares (2k)^2 ==
4*k^2 and another of the odd squares (2k+1)^2.  The gap between successive
even squares increases by 8 each time and likewise between odd squares.

=head2 Self-Similar Powers

The self-similar patterns such as PeanoCurve generally have a base pattern
which repeats at powers N=base^level, or some multiple or relationship to
such a power for things like KochPeaks and GosperIslands.

=for my_pod base begin

    Base          Path
    ----          ----
      2         HilbertCurve, HilbertSpiral, ZOrderCurve (default),
                  BetaOmega, AR2W2Curve, SierpinskiCurve, HIndexing
                  ImaginaryBase (default), CornerReplicate,
                  ComplexMinus (default), ComplexPlus (default),
                  ComplexRevolving,
                  DragonCurve, DragonRounded, DragonMidpoint,
                  AlternatePaper, DigitGroups (default)
      3         PeanoCurve (default), GosperIslands, GosperSide
                  WunderlichMeander, KochelCurve,
                  SierpinskiTriangle, SierpinskiArrowhead,
                  SierpinskiArrowheadCentres, TerdragonCurve,
                  UlamWarburton, UlamWarburtonQuarter (each level)
      4         KochCurve, KochPeaks, KochSnowflakes, KochSquareflakes,
                  LTiling
      5         QuintetCurve, QuintetCentres, QuintetReplicate,
                  CincoCurve
      7         Flowsnake, FlowsnakeCentres, GosperReplicate
      8         QuadricCurve, QuadricIslands
      9         SquareReplicate
    Fibonacci   FibonacciWordFractal
    parameter   PeanoCurve, ZOrderCurve, ImaginaryBase, DigitGroups
                  ComplexPlus, ComplexMinus

=for my_pod base end

Many number sequences plotted on these paths tend to be fairly random, or
merely show the tiling or path layout rather than much about the number
sequence.  Sequences related to the base can make holes or patterns picking
out parts of the path.  For example numbers without a particular digit (or
digits) in the relevant base show up as holes.  See for example
L<Math::PlanePath::ZOrderCurve/Power of 2 Values>.

=head2 Triangular Lattice

Some paths are on triangular or "A2" lattice points like

      *   *   *   *   *   *
    *   *   *   *   *   *
      *   *   *   *   *   *
    *   *   *   *   *   *
      *   *   *   *   *   *
    *   *   *   *   *   *

These are done in integer X,Y on a square grid using every second square and
offset on alternate rows so X and Y are either both even or both odd.

    . * . * . * . * . * . *
    * . * . * . * . * . * .
    . * . * . * . * . * . *
    * . * . * . * . * . * .
    . * . * . * . * . * . *
    * . * . * . * . * . * .

The X axis and the diagonals X=Y and X=-Y divide the plane into six parts.

       X=-Y     X=Y
         \     /
          \   /
           \ /
    ----------------- X=0
           / \
          /   \
         /     \

The diagonal X=3*Y is the middle of the first sixth, representing a twelfth
of the plane.

The resulting triangles are a little flatter than they should be.  The
triangle base is width=2 and top is height=1, whereas height=sqrt(3) would
be equilateral triangles.  That sqrt(3) factor can be applied if desired,

    X, Y*sqrt(3)          side length 2

    X/2, Y*sqrt(3)/2      side length 1

Integer Y values have the advantage of fitting pixels on the usual kind of
raster computer screen, and not losing precision in floating point results.

If doing a general-purpose coordinate rotation then be sure to apply the
sqrt(3) scale factor first or the rotation will be wrong.  60 degree
rotations can be made within the integer X,Y coordinates directly as follows
(all giving integer results),

    (X-3Y)/2, (X+Y)/2       rotate +60   (anti-clockwise)
    (X+3Y)/2, (Y-X)/2       rotate -60   (clockwise)
    -(X+3Y)/2, (X-Y)/2      rotate +120
    (3Y-X)/2, -(X+Y)/2      rotate -120
    -X,-Y                   rotate 180

    (X+3Y)/2, (X-Y)/2       mirror across the X=3*Y twelfth line

The sqrt(3) factor can be worked into a hypotenuse radial distance
calculation as follows if comparing distances from the origin.

    hypot = sqrt(X*X + 3*Y*Y)

See for instance TriangularHypot which is triangular points ordered by this
radial distance.

=head1 FORMULAS

=head2 Triangular Calculations

For a triangular lattice the rotation formulas above allow calculations to
be done in the rectangular X,Y coordinates which are the inputs and outputs
of the PlanePath functions.  An alternative is to number vertically on a 60
degree angle with coordinates i,j,

          ...
          *   *   *      2
        *   *   *       1
      *   *   *      j=0
    i=0  1   2

Such coordinates are sometimes used for hexagonal grid board games etc, and
using this internally can simplify rotations a little,

    -j, i+j         rotate +60   (anti-clockwise)
    i+j, -i         rotate -60   (clockwise)
    -i-j, i         rotate +120
    j, -i-j         rotate -120
    -i, -j          rotate 180

Conversions between i,j and the rectangular X,Y are

    X = 2*i + j         i = (X-Y)/2
    Y = j               j = Y

A third coordinate k at a +120 degrees angle can be used too,

     k=0  k=1 k=2
        *   *   *
          *   *   *
            *   *   *
             0   1   2

This is redundant since it doesn't number anything i,j alone can't already,
but it the advantage of turning rotations into just sign changes and swaps,

    -k, i, j        rotate +60
    j, k, -i        rotate -60
    -j, -k, i       rotate +120
    k, -i, -j       rotate -120
    -i, -j, -k      rotate 180

The conversions between i,j,k and the rectangular X,Y are similar to the i,j
above with k worked into the X,Y.

    X = 2i + j - k        i = (X-Y)/2        i = (X+Y)/2
    Y = j + k             j = Y         or   j = 0
                          k = 0              k = Y

=head1 SEE ALSO

=for my_pod see_also begin

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
L<Math::PlanePath::AnvilSpiral>,
L<Math::PlanePath::OctagramSpiral>,
L<Math::PlanePath::KnightSpiral>

L<Math::PlanePath::HexArms>,
L<Math::PlanePath::SquareArms>,
L<Math::PlanePath::DiamondArms>,
L<Math::PlanePath::AztecDiamondRings>,
L<Math::PlanePath::GreekKeySpiral>,
L<Math::PlanePath::MPeaks>

L<Math::PlanePath::SacksSpiral>,
L<Math::PlanePath::VogelFloret>,
L<Math::PlanePath::TheodorusSpiral>,
L<Math::PlanePath::ArchimedeanChords>,
L<Math::PlanePath::MultipleRings>,
L<Math::PlanePath::PixelRings>,
L<Math::PlanePath::Hypot>,
L<Math::PlanePath::HypotOctant>,
L<Math::PlanePath::TriangularHypot>,
L<Math::PlanePath::PythagoreanTree>

L<Math::PlanePath::PeanoCurve>,
L<Math::PlanePath::HilbertCurve>,
L<Math::PlanePath::HilbertSpiral>,
L<Math::PlanePath::ZOrderCurve>,
L<Math::PlanePath::WunderlichMeander>,
L<Math::PlanePath::AR2W2Curve>,
L<Math::PlanePath::BetaOmega>,
L<Math::PlanePath::KochelCurve>,
L<Math::PlanePath::CincoCurve>,

L<Math::PlanePath::ImaginaryBase>,
L<Math::PlanePath::SquareReplicate>,
L<Math::PlanePath::CornerReplicate>,
L<Math::PlanePath::LTiling>,
L<Math::PlanePath::DigitGroups>,
L<Math::PlanePath::FibonacciWordFractal>

L<Math::PlanePath::Flowsnake>,
L<Math::PlanePath::FlowsnakeCentres>,
L<Math::PlanePath::GosperReplicate>,
L<Math::PlanePath::GosperIslands>,
L<Math::PlanePath::GosperSide>

L<Math::PlanePath::QuintetCurve>,
L<Math::PlanePath::QuintetCentres>,
L<Math::PlanePath::QuintetReplicate>

L<Math::PlanePath::KochCurve>,
L<Math::PlanePath::KochPeaks>,
L<Math::PlanePath::KochSnowflakes>,
L<Math::PlanePath::KochSquareflakes>

L<Math::PlanePath::QuadricCurve>,
L<Math::PlanePath::QuadricIslands>

L<Math::PlanePath::SierpinskiCurve>,
L<Math::PlanePath::HIndexing>

L<Math::PlanePath::SierpinskiTriangle>,
L<Math::PlanePath::SierpinskiArrowhead>,
L<Math::PlanePath::SierpinskiArrowheadCentres>

L<Math::PlanePath::DragonCurve>,
L<Math::PlanePath::DragonRounded>,
L<Math::PlanePath::DragonMidpoint>,
L<Math::PlanePath::AlternatePaper>,
L<Math::PlanePath::TerdragonCurve>,
L<Math::PlanePath::ComplexPlus>,
L<Math::PlanePath::ComplexMinus>,
L<Math::PlanePath::ComplexRevolving>

L<Math::PlanePath::Rows>,
L<Math::PlanePath::Columns>,
L<Math::PlanePath::Diagonals>,
L<Math::PlanePath::DiagonalsAlternating>,
L<Math::PlanePath::Staircase>,
L<Math::PlanePath::StaircaseAlternating>,
L<Math::PlanePath::Corner>

L<Math::PlanePath::PyramidRows>,
L<Math::PlanePath::PyramidSides>,
L<Math::PlanePath::CellularRule>,
L<Math::PlanePath::CellularRule54>,
L<Math::PlanePath::CellularRule190>,
L<Math::PlanePath::UlamWarburton>,
L<Math::PlanePath::UlamWarburtonQuarter>

L<Math::PlanePath::DiagonalRationals>,
L<Math::PlanePath::FactorRationals>,
L<Math::PlanePath::GcdRationals>,
L<Math::PlanePath::RationalsTree>,
L<Math::PlanePath::FractionsTree>,
L<Math::PlanePath::CoprimeColumns>,
L<Math::PlanePath::DivisibleColumns>,
L<Math::PlanePath::File>

=for my_pod see_also end

L<Math::NumSeq::PlanePathCoord>,
L<Math::NumSeq::PlanePathDelta>

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

Copyright 2010, 2011, 2012 Kevin Ryde

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
