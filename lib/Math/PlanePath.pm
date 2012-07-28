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


# Math::PlanePath::Base::Generic
# divrem
# divrem_mutate

# $path->n_to_dir4
# $path->n_to_dist
# $path->xy_to_dir4_list
# $path->xy_to_dxdy_list
# $path->xy_to_n_list_maxcount
# $path->xy_to_n_list_maximum
# $path->xy_to_n_list_maxnum
# $path->xy_next_in_rect($x,$y, $x1,$y1,$x2,$y2)
#    return ($x,$y) or empty
#
# $path->xy_integer
# $path->xy_integer_n_start
#
# $path->x_range('integer')
# $path->x_range('all')
# use constant x_range => (1, undef);
# x_minimum
# x_maximum
# y_minimum
# y_maximum
#
# lattice_type square,triangular,triangular_odd,pentagonal,fractional
#
# xy_unique_n_start
# figures_disjoint
# figures_disjoint_n_start
#         separate
#         unoverlapped


package Math::PlanePath;
use 5.004;
use strict;

use vars '$VERSION';
$VERSION = 83;

# uncomment this to run the ### lines
#use Smart::Comments;

# defaults
use constant figure => 'square';
use constant default_n_start => 1;
sub n_start {
  my ($self) = @_;
  if (ref $self && defined $self->{'n_start'}) {
    return $self->{'n_start'};
  } else {
    return $self->default_n_start;
  }
}
sub arms_count {
  my ($self) = @_;
  return $self->{'arms'} || 1;
}

use constant class_x_negative => 1;
use constant class_y_negative => 1;
sub x_negative { $_[0]->class_x_negative }
sub y_negative { $_[0]->class_y_negative }
use constant n_frac_discontinuity => undef;
use constant tree_n_parent => undef;
use constant tree_n_children => ();

sub new {
  my $class = shift;
  return bless { @_ }, $class;
}

use constant parameter_info_array => [];
sub parameter_info_list {
  return @{$_[0]->parameter_info_array};
}

{
  my %parameter_info_hash;
  sub parameter_info_hash {
    my ($class_or_self) = @_;
    my $class = (ref $class_or_self || $class_or_self);
    return ($parameter_info_hash{$class}
            ||= { map { $_->{'name'} => $_ }
                  $class_or_self->parameter_info_list });
  }
}

sub xy_to_n_list {
  ### xy_to_n_list() ...
  if (defined (my $n = shift->xy_to_n(@_))) {
    ### $n
    return $n;
  }
  ### empty ...
  return;
}

sub n_to_dxdy {
  my ($self, $n) = @_;
  my ($x,$y) = $self->n_to_xy ($n)
    or return;
  my ($next_x,$next_y) = $self->n_to_xy ($n + $self->arms_count)
    or return;
  return ($next_x - $x,
          $next_y - $y);
}
sub n_to_rsquared {
  my ($self, $n) = @_;
  my ($x,$y) = $self->n_to_xy($n) or return undef;
  return $x*$x + $y*$y;
}

#------------------------------------------------------------------------------
# shared internals

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

use Math::PlanePath::Base::Generic 'round_nearest';
sub _rect_for_first_quadrant {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  $x1 = round_nearest($x1);
  $y1 = round_nearest($y1);
  $x2 = round_nearest($x2);
  $y2 = round_nearest($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  if ($x2 < 0 || $y2 < 0) {
    return;
  }
  return ($x1,$y1, $x2,$y2);
}

# return ($quotient, $remainder)
sub _divrem {
  my ($n, $d) = @_;
  if (ref $n && $n->isa('Math::BigInt')) {
    my ($quot,$rem) = $n->copy->bdiv($d);
    if (! ref $d || $d < 1_000_000) {
      $rem = $rem->numify;  # plain remainder if fits
    }
    return ($quot, $rem);
  }
  my $rem = $n % $d;
  return (int(($n-$rem)/$d), # exact division stays in UV
          $rem);
}

# return $remainder, modify $n
# the scalar $_[0] is modified, but if it's a BigInt then a new BigInt is made
# and stored there, the bigint value is not changed
sub _divrem_mutate {
  my $d = $_[1];
  my $rem;
  if (ref $_[0] && $_[0]->isa('Math::BigInt')) {
    ($_[0], $rem) = $_[0]->copy->bdiv($d);  # quot,rem in array context
    if (! ref $d || $d < 1_000_000) {
      return $rem->numify;  # plain remainder if fits
    }
  } else {
    $rem = $_[0] % $d;
    $_[0] = int(($_[0]-$rem)/$d); # exact division stays in UV
  }
  return $rem;
}

1;
__END__

# Maybe:
#
# =item C<$branches = $path-E<gt>tree_constant_branches()>
# 
# If C<$path> is a tree with a constant number of children at each node then
# return that number.  For example PythagoreanTree has 3 descendants at
# each N.
# 
# If C<$path> is not a tree, or it's a tree but the number of children varies
# with N, then return 0.
#
# use constant tree_constant_branches => 0;
# use constant tree_constant_branches => 3;
# use constant tree_constant_branches => 2;
# use constant tree_constant_branches => 2;

# sub tree_n_parent {
#   my ($self, $n) = @_;
#   ### tree_n_parent() generic: $n
# 
#   if (my $branches = $self->tree_constant_branches) {
#     my $n_start = $self->n_start;
#     if ($n > $n_start) {
#       return int(($n - $n_start - 1)/$branches) + $n_start;
#     }
#   }
#   return undef;
# }
# 
# sub tree_n_children {
#   my ($self, $n) = @_;
#   ### tree_n_children() generic: ref $self, $n
#   ### branches: $self->tree_constant_branches
# 
#   if (my $branches = $self->tree_constant_branches) {
#     my $n_start = $self->n_start;
#     $n = $branches*($n-$n_start) + $n_start;
#     return map {$n+$_} 1 .. $branches;
#   } else {
#     return;
#   }
# }




=for stopwords SquareSpiral SacksSpiral VogelFloret PlanePath Ryde Math-PlanePath 7-gonals 8-gonal (step+2)-gonal heptagonals PentSpiral octagonals HexSpiral PyramidSides PyramidRows ArchimedeanChords PeanoCurve KochPeaks GosperIslands TriangularHypot bignum multi-arm SquareArms eg PerlMagick nan nans subclasses incrementing arrayref hashref filename enum radix DragonCurve TerdragonCurve NumSeq ie

=head1 NAME

Math::PlanePath -- points on a path through the 2-D plane

=head1 SYNOPSIS

 use Math::PlanePath;
 # only a base class, see the subclasses for actual operation

=head1 DESCRIPTION

This is a base class for some mathematical paths which map an integer
position C<$n> to and from coordinates C<$x,$y> in the 2D plane.

The current classes include the following.  The intention is that any
C<Math::PlanePath::Something> is a PlanePath, and supporting base classes or
related things are further down like C<Math::PlanePath::Base::Xyzzy>.

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
    CretanLabyrinth        7-circuit extended infinitely

    SquareArms             four-arm square spiral
    DiamondArms            four-arm diamond spiral
    AztecDiamondRings      four-sided rings
    HexArms                six-arm hexagonal spiral
    GreekKeySpiral         square spiral with Greek key motif
    MPeaks                 "M" shape layers

    SacksSpiral            quadratic on an Archimedean spiral
    VogelFloret            seeds in a sunflower
    TheodorusSpiral        unit steps at right angles
    ArchimedeanChords      unit chords on an Archimedean spiral
    MultipleRings          concentric circles
    PixelRings             concentric rings of midpoint pixels
    FilledRings            concentric rings of pixels
    Hypot                  points by distance
    HypotOctant            first octant points by distance
    TriangularHypot        points by triangular distance
    PythagoreanTree        X^2+Y^2=Z^2 by trees

    PeanoCurve             3x3 self-similar quadrant
    WunderlichSerpentine   transpose parts of PeanoCurve
    HilbertCurve           2x2 self-similar quadrant
    HilbertSpiral          2x2 self-similar whole-plane
    ZOrderCurve            replicating Z shapes
    GrayCode               Gray code splits
    WunderlichMeander      3x3 "R" pattern quadrant
    BetaOmega              2x2 self-similar half-plane
    AR2W2Curve             2x2 self-similar of four parts
    KochelCurve            3x3 self-similar of two parts
    CincoCurve             5x5 self-similar

    ImaginaryBase          replicate in four directions
    ImaginaryHalf          half-plane replicate three directions
    CubicBase              replicate in three directions
    SquareReplicate        3x3 replicating squares
    CornerReplicate        2x2 replicating "U"
    LTiling                self-simlar L shapes
    DigitGroups            digits grouped by zeros
    FibonacciWordFractal   turns by Fibonacci word bits

    Flowsnake              self-similar hexagonal tile traversal
    FlowsnakeCentres         likewise but centres of hexagons
    GosperReplicate        self-similar hexagonal tiling
    GosperIslands          concentric island rings
    GosperSide             single side or radial

    QuintetCurve           self-similar "+" traversal
    QuintetCentres           likewise but centres of squares
    QuintetReplicate       self-similar "+" tiling

    DragonCurve            paper folding
    DragonRounded          paper folding rounded corners
    DragonMidpoint         paper folding segment midpoints
    AlternatePaper         alternating direction folding
    AlternatePaperMidpoint alternating direction folding, midpoints
    TerdragonCurve         ternary dragon
    TerdragonRounded       ternary dragon rounded corners
    TerdragonMidpoint      ternary dragon segment midpoints
    R5DragonCurve          radix-5 dragon curve
    R5DragonMidpoint       radix-5 dragon curve midpoints
    CCurve                 "C" curve
    ComplexPlus            base i+realpart
    ComplexMinus           base i-realpart, including twindragon
    ComplexRevolving       revolving base i+1

    SierpinskiCurve        self-similar right-triangles
    SierpinskiCurveStair   self-similar right-triangles, stair-step
    HIndexing              self-similar right-triangles, squared up

    KochCurve              replicating triangular notches
    KochPeaks              two replicating notches
    KochSnowflakes         concentric notched 3-sided rings
    KochSquareflakes       concentric notched 4-sided rings
    QuadricCurve           eight segment zig-zag
    QuadricIslands           rings of those zig-zags
    SierpinskiTriangle     self-similar triangle by rows
    SierpinskiArrowhead    self-similar triangle connectedly
    SierpinskiArrowheadCentres  likewise but centres of triangles

    Rows                   fixed-width rows
    Columns                fixed-height columns
    Diagonals              diagonals between X and Y axes
    DiagonalsAlternating   diagonals Y to X and back again
    DiagonalsOctant        diagonals between Y axis and X=Y centre
    Staircase              stairs down from the Y to X axes
    StaircaseAlternating   stairs Y to X and back again
    Corner                 expanding stripes around a corner
    PyramidRows            expanding stacked rows pyramid
    PyramidSides           along the sides of a 45-degree pyramid
    CellularRule           cellular automaton by rule number
    CellularRule54         cellular automaton rows pattern
    CellularRule57         cellular automaton (rule 99 mirror too)
    CellularRule190        cellular automaton (rule 246 mirror too)
    UlamWarburton          cellular automaton diamonds
    UlamWarburtonQuarter   cellular automaton quarter-plane

    DiagonalRationals      rationals X/Y by diagonals
    FactorRationals        rationals X/Y by prime factorization
    GcdRationals           rationals X/Y by rows with GCD integer
    RationalsTree          rationals X/Y by tree
    FractionsTree          fractions 0<X/Y<1 by tree
    CoprimeColumns         coprime X,Y
    DivisibleColumns       X divisible by Y
    WythoffArray           Fibonacci recurrences
    PowerArray             powers in rows
    File                   points from a disk file

=for my_pod list end

The paths are object oriented to allow parameters, though many have none.
See C<examples/numbers.pl> in the Math-PlanePath sources for a sample
printout of numbers from selected paths or all paths.

=head2 Number Types

The C<$n> and C<$x,$y> parameters can be either integers or floating point.
The paths are meant to do something sensible with fractions but expect
rounding-off for big floating point exponents.

Floating point infinities (when available) give nan or infinite returns of
some kind (some unspecified kind as yet).  C<n_to_xy()> on negative infinity
is an empty return, the same as other negative C<$n>.  Calculations which
break an input into digits of some base don't loop infinitely on infinities.

Floating point nans (when available) give nan, infinite, or empty/undef
returns, but again of some unspecified kind as yet, but in any case not
going into infinite loops.

Many of the classes can operate on overloaded number types as inputs and
give corresponding outputs.

    Math::BigInt        maybe perl 5.8 up for ** operator
    Math::BigRat
    Math::BigFloat
    Number::Fraction    1.14 or higher (for abs())

A few classes might truncate a bignum or a fraction to a float as yet.  In
general the intention is to make the calculations generic to act on any
sensible number type.  Recent enough versions of the bignum modules might be
required, perhaps Perl 5.8 or higher for the C<**> exponentiation operator
in particular.

For reference, an C<undef> input as C<$n>, C<$x>, C<$y>, etc, is meant to
provoke an uninitialized value warning (when warnings are enabled), but
currently it doesn't croak etc.  Perhaps that will change, but the warning
at least prevents bad inputs going unnoticed.

=head1 FUNCTIONS

In the following C<Foo> is one of the various subclasses, see the list above
and under L</SEE ALSO>.

=over 4

=item C<$path = Math::PlanePath::Foo-E<gt>new (key=E<gt>value, ...)>

Create and return a new path object.  Optional key/value parameters may
control aspects of the object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return X,Y coordinates of point C<$n> on the path.  If there's no point
C<$n> then the return is an empty list.  For example

    my ($x,$y) = $path->n_to_xy (-123)
      or next;   # no negatives in $path

Paths start from C<$path-E<gt>n_start()> below, though some will give a
position for N=0 or N=-0.5 too.

=item C<($dx,$dy) = $path-E<gt>n_to_dxdy ($n)>

Return the change in X and Y going from point C<$n> to point C<$n+1>, or for
paths with multiple arms from C<$n> to C<$n+$arms_count> (thus advancing by
one along the arm of C<$n>).

    $n+1 *  $next_x,$next_y
         |
         |
         |              $dx = $next_x - $x
      $n *  $x,$y       $dy = $next_y - $y

C<$n> can be fractional and in that case the delta is from that fractional
C<$n> position to C<$n+1> (or C<$n+$arms>).
 
                $n+1
                v  $next_x,$next_y
    integer *---+---- 
            |  /
            | /
            |/            $dx = $next_x - $x
         $n +   $x,$y     $dy = $next_y - $y
            |            
    integer *

This is simply C<n_to_xy()> C<$dx=$next_x-$x, $dy=$next_y-$y>.  Currently
for most paths it's merely two such C<n_to_xy()> calls, but some paths can
or might calculate it with a little less work.

=item C<$rsquared = $path-E<gt>n_to_rsquared ($n)>

Return the radial distance R^2 of point C<$n>, or C<undef> if there's no
point C<$n>.  This is simply C<$x**2+$y**2> but for a few paths it can be
calculated with less work than C<n_to_xy()>.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the N point number at coordinates C<$x,$y>.  If there's nothing at
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
C<$n> close enough) and give C<undef>.

=item C<@n_list = $path-E<gt>xy_to_n_list ($x,$y)>

Return a list of N point numbers at coordinates C<$x,$y>.  If there's
nothing at C<$x,$y> then return an empty list.

    my @n_list = $path->xy_to_n(20,20);

Most paths have just a single N for a given X,Y but for those like
DragonCurve and TerdragonCurve where multiple N's give the same X,Y this
method returns the list of those N values.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

Return a range of N values covering or exceeding a rectangle with corners at
C<$x1>,C<$y1> and C<$x2>,C<$y2>.  The range is inclusive.  For example,

     my ($n_lo, $n_hi) = $path->rect_to_n_range (-5,-5, 5,5);
     foreach my $n ($n_lo .. $n_hi) {
       my ($x, $y) = $path->n_to_xy($n) or next;
       print "$n  $x,$y";
     }

The return might be an over-estimate of the range, and many of the points
between C<$n_lo> and C<$n_hi> might be outside the rectangle even when the
range is exact.  But the range is at least an lower and upper bound on the N
values which occur in the rectangle.  Classes which can guarantee an exact
lo/hi range say so in their docs.

C<$n_hi> is usually no more than an extra partial row, revolution, or
self-similar level.  C<$n_lo> might be merely the starting
C<$path-E<gt>n_start()> -- which is fine if the origin is in the desired
rectangle but away from the origin might actually start higher.

C<$x1>,C<$y1> and C<$x2>,C<$y2> can be fractional and if they partly overlap
some N figures then those N's are included in the return.

If there's no points in the rectangle then the return can be a "crossed"
range like C<$n_lo=1>, C<$n_hi=0> (which makes a C<foreach> do no loops).
But C<rect_to_n_range()> might not always notice there's no points in the
rectangle and instead return some over-estimate.

=item C<$n = $path-E<gt>n_start()>

Return the first N in the path.  In the current classes this is either 0
or 1.

Some classes have secret dubious undocumented support for N values below
this (zero or negative), but C<n_start()> is the intended starting point.

=item C<$f = $path-E<gt>n_frac_discontinuity()>

Return the fraction of N at which there's discontinuities in the path.  For
example if there's a jump in the coordinates between N=7.4999 and N=7.5 then
the returned C<$f> is 0.5.  Or C<$f> is 0 if there's a discontinuity between
6.999 and 7.0.

If there's no discontinuities in the path, so that for example fractions
between N=7 to N=8 give smooth continuous X,Y values (of some kind) then the
return is C<undef>.

This is mainly of interest for drawing line segments between N points.  If
there's discontinuities then the idea is to draw from say N=7.0 to N=7.499
and then another line from N=7.5 to N=8.  The returned C<$f> is whether
there's discontinuities anywhere in C<$path>.

=item C<$bool = $path-E<gt>x_negative()>

=item C<$bool = $path-E<gt>y_negative()>

Return true if the path extends into negative X coordinates and/or negative
Y coordinates respectively.

=item C<$bool = Math::PlanePath::Foo-E<gt>class_x_negative()>

=item C<$bool = Math::PlanePath::Foo-E<gt>class_y_negative()>

=item C<$bool = $path-E<gt>class_x_negative()>

=item C<$bool = $path-E<gt>class_y_negative()>

Return true if any paths made by this class extend into negative X
coordinates and/or negative Y coordinates, respectively.

For some classes the X or Y extent may depend on parameter values.

=item C<$arms = $path-E<gt>arms_count()>

Return the number of arms in a "multi-arm" path.

For example in SquareArms this is 4 and each arm increments in turn, so the
first arm is N=1,5,9,13, etc, starting from C<$path-E<gt>n_start()> and
incrementing by 4 each time.

=item C<$str = $path-E<gt>figure()>

Return a string name of the figure (shape) intended to be drawn at each
C<$n> position.  This is currently either

    "square"     side 1 centred on $x,$y
    "circle"     diameter 1 centred on $x,$y

Of course this is only a suggestion since PlanePath doesn't draw anything
itself.  A figure like a diamond for instance can look good too.

=back

=head2 Tree Methods

=over

=item C<@n_children = $path-E<gt>tree_n_children($n)>

Return a list of N values which are the child nodes of C<$n>, or return an
empty list if C<$n> has no children.  The could be no children either
because C<$path> is not a tree or because there's no children at a
particular C<$n>.

=item C<$n_parent = $path-E<gt>tree_n_parent($n)>

Return the parent node of C<$n>, or C<undef> if it has no parent.  There
could be no parent either because C<$path> is not a tree or because C<$n> is
the top of the tree (or one of the tops).

=back

=head2 Parameter Methods

=over

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
handling to reach Perl as a byte string, whereas a "string" type might in
principle take Perl wide chars.

For "enum" the C<choices> field is the possible values, such as

    { name => "flavour",
      type => "enum",
      choices => ["strawberry","chocolate"],
    }

C<minimum> and/or C<maximum> are omitted if there's no hard limit on the
parameter.

C<share_key> is designed to indicate when parameters from different NumSeq
classes can done by a single control widget in a GUI etc.  Normally the
C<name> is enough, but when the same name has slightly different meanings in
different classes a C<share_key> allows the same meanings to be matched up.

=item C<$hashref = Math::PlanePath::Foo-E<gt>parameter_info_hash()>

Return a hashref mapping parameter names C<$info-E<gt>{'name'}> to their
C<$info> records.

    { wider => { name => "wider",
                 type => "integer",
                 ...
               },
    }

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

The separate C<n_to_xy()> calls were motivated by plotting just some N
points of a path, such as just the primes or the perfect squares.
Successive positions in paths could perhaps be done more efficiently in an
iterator style.  Paths with a quadratic "step" are not much worse than a
C<sqrt()> to break N into a segment and offset, but the self-similar paths
which chop N into digits of some radix could increment instead of
recalculate.

A disadvantage of an iterator is that if you're only interested in a
particular rectangle or similar region then the iteration may stray outside
for a long time, making it much less useful than it seems.  For wild paths
it can be better to apply C<xy_to_n()> by rows or similar in the desired
region.

The L<Math::NumSeq::PlanePathCoord> and similar classes offer the PlanePath
coordinates, directions, turns, etc as sequences.  The iterator forms there
simply make repeated calls to C<n_to_xy()> etc.

=head2 Scaling and Orientation

The paths generally make a first move horizontally to the right and/or
anti-clockwise around from the X axis, unless there's some more natural
orientation.  Anti-clockwise is the usual direction for mathematical
spirals.

There's no parameters for scaling, offset or reflection as those things are
thought better left to a general coordinate transformer, for example to
expand or invert for display.  But some easy transformations can be had just
from the X,Y with

    -X,Y        flip horizontally (mirror image)
    X,-Y        flip vertically (across the X axis)

    -Y,X        rotate +90 degrees  (anti-clockwise)
    Y,-X        rotate -90 degrees  (clockwise)
    -X,-Y       rotate 180 degrees

Flip vertically makes spirals go clockwise instead of anti-clockwise, or a
flip horizontally the same but starting on the left at the negative X axis.
See L</Triangular Lattice> below for 60 degree rotations of the triangular
grid paths too.

The Rows and Columns paths are exceptions to the rule of not having rotated
versions of paths.  They began as ways to pass in width and height as
generic parameters and let the path use the one or the other.

For scaling and shifting see for example L<Transform::Canvas>, and to rotate
as well see L<Geometry::AffineTransform>.

=head2 Loop Step

The paths can be characterized by how much longer each loop or repetition is
than the preceding one.  For example each cycle around the SquareSpiral is 8
more N points than the preceding.

=for my_pod step begin

      Step        Path
      ----        ----
        0       Rows, Columns (fixed widths)
       2/2      DiagonalsOctant (2 rows for +2)
        1       Diagonals
        2       SacksSpiral, PyramidSides, Corner, PyramidRows (default)
        4       DiamondSpiral, AztecDiamondRings, Staircase
       4/2      CellularRule54, CellularRule57,
                  DiagonalsAlternating (2 rows for +4)
        5       PentSpiral, PentSpiralSkewed
       5.65     PixelRings (average about 4*sqrt(2))
        6       HexSpiral, HexSpiralSkewed, MPeaks,
                  MultipleRings (default)
       6/2      CellularRule190 (2 rows for +6)
       6.28     ArchimedeanChords (approaching 2*pi),
                  FilledRings (average)
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
     128/4      CretanLabyrinth (4 loops for +128)
      216       HexArms (each arm)

    totient     CoprimeColumns, DiagonalRationals
    numdivisors DivisibleColumns
    various     CellularRule

    parameter   MultipleRings, PyramidRows

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
right).  In the bigger step there's one line of the even squares (2k)^2 ==
4*k^2 and another of the odd squares (2k+1)^2.  The gap between successive
even squares increases by 8 each time and likewise between odd squares.

=head2 Self-Similar Powers

The self-similar patterns such as PeanoCurve generally have a base pattern
which repeats at powers N=base^level.  Or some multiple or relationship to
such a power for things like KochPeaks and GosperIslands.

=for my_pod base begin

    Base          Path
    ----          ----
      2         HilbertCurve, HilbertSpiral, ZOrderCurve (default),
                  GrayCode (default), BetaOmega, AR2W2Curve,
                  SierpinskiCurve, HIndexing, SierpinskiCurveStair,
                  ImaginaryBase (default), ImaginaryHalf (default),
                  CubicBase (default) CornerReplicate,
                  ComplexMinus (default), ComplexPlus (default),
                  ComplexRevolving, DragonCurve, DragonRounded,
                  DragonMidpoint, AlternatePaper, AlternatePaperMidpoint,
                  CCurve, DigitGroups (default), PowerArray (default)
      3         PeanoCurve (default), WunderlichSerpentine (default),
                  WunderlichMeander, KochelCurve,
                  GosperIslands, GosperSide
                  SierpinskiTriangle, SierpinskiArrowhead,
                  SierpinskiArrowheadCentres,
                  TerdragonCurve, TerdragonRounded, TerdragonMidpoint,
                  UlamWarburton, UlamWarburtonQuarter (each level)
      4         KochCurve, KochPeaks, KochSnowflakes, KochSquareflakes,
                  LTiling
      5         QuintetCurve, QuintetCentres, QuintetReplicate,
                  CincoCurve, R5DragonCurve, R5DragonMidpoint
      7         Flowsnake, FlowsnakeCentres, GosperReplicate
      8         QuadricCurve, QuadricIslands
      9         SquareReplicate
    Fibonacci   FibonacciWordFractal, WythoffArray
    parameter   PeanoCurve, WunderlichSerpentine, ZOrderCurve, GrayCode,
                  ImaginaryBase, ImaginaryHalf, CubicBase, ComplexPlus,
                  ComplexMinus, DigitGroups, PowerArray

=for my_pod base end

Many number sequences plotted on these paths tend to be fairly random, or
merely show the tiling or path layout rather than much about the number
sequence.  Sequences related to the base can make holes or patterns picking
out parts of the path.  For example numbers without a particular digit (or
digits) in the relevant base show up as holes.  See for example
L<Math::PlanePath::ZOrderCurve/Power of 2 Values>.

=head2 Triangular Lattice

Some paths are on triangular or "A2" lattice points like

      *---*---*---*---*---*
     / \ / \ / \ / \ / \ / 
    *---*---*---*---*---*
     \ / \ / \ / \ / \ / \
      *---*---*---*---*---*
     / \ / \ / \ / \ / \ / 
    *---*---*---*---*---*
     \ / \ / \ / \ / \ / \
      *---*---*---*---*---*
     / \ / \ / \ / \ / \ / 
    *---*---*---*---*---*

This is done in integer X,Y on a square grid by using every second square
and offsetting alternate rows.  This means sum X+Y is even, ie. X and Y
either both even or both odd, not of opposite parity.

    . * . * . * . * . * . *
    * . * . * . * . * . * .
    . * . * . * . * . * . *
    * . * . * . * . * . * .
    . * . * . * . * . * . *
    * . * . * . * . * . * .

The X axis and diagonals X=Y and X=-Y divide the plane into six equal parts
in this grid.

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

The resulting triangles are flatter than they should be.  The triangle base
is width=2 and top is height=1, whereas it would be height=sqrt(3) for an
equilateral triangle.  That sqrt(3) factor can be applied if desired,

    X, Y*sqrt(3)          side length 2

    X/2, Y*sqrt(3)/2      side length 1

Integer Y values have the advantage of fitting pixels on the usual kind of
raster computer screen, and not losing precision in floating point results.

If doing a general-purpose coordinate rotation then be sure to apply the
sqrt(3) scale factor first, otherwise the rotation will be wrong.  60 degree
rotations can be made within the integer X,Y coordinates directly as
follows, all giving integer X,Y results.

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
be done in the rectangular X,Y coordinates which are inputs and outputs of
the PlanePath functions.  An alternative is to number vertically on a 60
degree angle with coordinates i,j,

          ...
          *   *   *      2
        *   *   *       1
      *   *   *      j=0
    i=0  1   2

Such coordinates are sometimes used for hexagonal grids in board games etc,
and using this internally can simplify rotations a little,

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

This is redundant in that it doesn't number anything i,j alone can't
already, but it has the advantage of turning rotations into just sign
changes and swaps,

    -k, i, j        rotate +60
    j, k, -i        rotate -60
    -j, -k, i       rotate +120
    k, -i, -j       rotate -120
    -i, -j, -k      rotate 180

The conversions between i,j,k and the rectangular X,Y are like the i,j above
but with k worked in too.

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
L<Math::PlanePath::KnightSpiral>,
L<Math::PlanePath::CretanLabyrinth>

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
L<Math::PlanePath::FilledRings>,
L<Math::PlanePath::Hypot>,
L<Math::PlanePath::HypotOctant>,
L<Math::PlanePath::TriangularHypot>,
L<Math::PlanePath::PythagoreanTree>

L<Math::PlanePath::PeanoCurve>,
L<Math::PlanePath::WunderlichSerpentine>,
L<Math::PlanePath::WunderlichMeander>,
L<Math::PlanePath::HilbertCurve>,
L<Math::PlanePath::HilbertSpiral>,
L<Math::PlanePath::ZOrderCurve>,
L<Math::PlanePath::GrayCode>,
L<Math::PlanePath::AR2W2Curve>,
L<Math::PlanePath::BetaOmega>,
L<Math::PlanePath::KochelCurve>,
L<Math::PlanePath::CincoCurve>,

L<Math::PlanePath::ImaginaryBase>,
L<Math::PlanePath::ImaginaryHalf>,
L<Math::PlanePath::CubicBase>,
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
L<Math::PlanePath::SierpinskiCurveStair>,
L<Math::PlanePath::HIndexing>

L<Math::PlanePath::SierpinskiTriangle>,
L<Math::PlanePath::SierpinskiArrowhead>,
L<Math::PlanePath::SierpinskiArrowheadCentres>

L<Math::PlanePath::DragonCurve>,
L<Math::PlanePath::DragonRounded>,
L<Math::PlanePath::DragonMidpoint>,
L<Math::PlanePath::AlternatePaper>,
L<Math::PlanePath::AlternatePaperMidpoint>,
L<Math::PlanePath::TerdragonCurve>,
L<Math::PlanePath::TerdragonRounded>,
L<Math::PlanePath::TerdragonMidpoint>,
L<Math::PlanePath::R5DragonCurve>,
L<Math::PlanePath::R5DragonMidpoint>,
L<Math::PlanePath::CCurve>

L<Math::PlanePath::ComplexPlus>,
L<Math::PlanePath::ComplexMinus>,
L<Math::PlanePath::ComplexRevolving>

L<Math::PlanePath::Rows>,
L<Math::PlanePath::Columns>,
L<Math::PlanePath::Diagonals>,
L<Math::PlanePath::DiagonalsAlternating>,
L<Math::PlanePath::DiagonalsOctant>,
L<Math::PlanePath::Staircase>,
L<Math::PlanePath::StaircaseAlternating>,
L<Math::PlanePath::Corner>

L<Math::PlanePath::PyramidRows>,
L<Math::PlanePath::PyramidSides>,
L<Math::PlanePath::CellularRule>,
L<Math::PlanePath::CellularRule54>,
L<Math::PlanePath::CellularRule57>,
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
L<Math::PlanePath::WythoffArray>,
L<Math::PlanePath::PowerArray>,
L<Math::PlanePath::File>

=for my_pod see_also end

L<Math::NumSeq::PlanePathCoord>,
L<Math::NumSeq::PlanePathDelta>,
L<Math::NumSeq::PlanePathTurn>,
L<Math::NumSeq::PlanePathN>

L<math-image>, displaying various sequences on these paths.

F<examples/numbers.pl> in the Math-PlanePath source code, to print all the
paths.

=head2 Other Ways To Do It

L<Math::Fractal::Curve>,
L<Math::Curve::Hilbert>,
L<Algorithm::SpatialIndex::Strategy::QuadTree>

PerlMagick (L<Image::Magick>) demo scripts F<lsys.pl> and F<tree.pl>

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
