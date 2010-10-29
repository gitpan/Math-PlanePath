# Copyright 2010 Kevin Ryde

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
use warnings;

use vars '$VERSION';
$VERSION = 12;

# defaults
use constant x_negative => 1;
use constant y_negative => 1;
use constant figure => 'square';

sub new {
  my $class = shift;
  return bless { @_ }, $class;
}

1;
__END__

=for stopwords SquareSpiral SacksSpiral VogelFloret PlanePath Ryde Math-PlanePath

=head1 NAME

Math::PlanePath -- points on a path through the 2-D plane

=head1 SYNOPSIS

 use Math::PlanePath;
 # only a base class, see the subclasses for actual operation

=head1 DESCRIPTION

This is the base class for some mathematical paths which turn an integer
position C<$n> into coordinates C<$x,$y>.  The current classes include

    SquareSpiral           four-sided spiral
    PyramidSpiral          square base pyramid
    TriangleSpiral         equilateral triangle
    TriangleSpiralSkewed   equilateral skewed for compactness
    DiamondSpiral          four-sided spiral, looping faster
    PentSpiralSkewed       five-sided spiral, compact
    HexSpiral              six-sided spiral
    HexSpiralSkewed        six-sided spiral skewed for compactness
    HeptSpiralSkewed       seven-sided spiral, compact
    KnightSpiral           an infinite knight's tour

    SacksSpiral            quadratic on an Archimedean spiral
    VogelFloret            seeds in a sunflower
    TheodorusSpiral        unit steps at right angles
    MultipleRings          concentric circles

    Rows                   fixed-width rows
    Columns                fixed-height columns
    Diagonals              diagonals between X and Y axes
    Corner                 expanding stripes around a corner
    PyramidRows            expanding rows pyramid
    PyramidSides           along the sides of a 45-degree pyramid

The paths are object oriented to allow parameters though only a few
subclasses actually have any parameters.

The classes are generally based on integer C<$n> positions and the classes
designed for a square grid turn an integer C<$n> into integer C<$x,$y>.
Usually they give in-between positions for fractional C<$n> too.  Classes
not on a square grid, like SacksSpiral and VogelFloret, are scaled for a
unit circle at each C<$n> but they too can give in-between positions on
request.

In general there's no parameters for scaling, or an offset for the 0,0
origin, or a reflection up or down.  Those things are thought better done by
a general coordinate transformer that might expand or invert for display.
Even clockwise instead of counter-clockwise spiralling can be had just by
negating C<$x> (or negate C<$y> to stay starting at the right), or a quarter
turn by swapping C<$x> and C<$y>.

=head2 Loop Step

The paths can be characterized by how much longer each loop or repetition is
than the preceding one.  For example each cycle around the SquareSpiral is 8
longer than the preceding.

    Step        Path
    ----        ----
      0       Rows, Columns (fixed widths)
      1       Diagonals
      2       SacksSpiral, PyramidSides, Corner, PyramidRows default
      4       DiamondSpiral
      5       PentSpiralSkewed
      6       HexSpiral, HexSpiralSkewed
      7       HeptSpiralSkewed
      8       SquareSpiral, PyramidSpiral
      9       TriangleSpiral, TriangleSpiralSkewed
     19.74    TheodorusSpiral (approaches 2*pi^2)
     32       KnightSpiral (counting the 2-wide loop)
   variable   MultipleRings, PyramidRows

The step determines which quadratic number sequences fall on straight lines.
For example the gap between successive perfect squares increases by 2 each
time (4 to 9 is +5, 9 to 16 is +7, 16 to 25 is +9, etc), so the perfect
squares make a straight line in the paths of step 2.

A factor of 4 on the step splits a straight line into two, so for example on
the SquareSpiral of step 8 the perfect squares fall on two lines going to
the lower left and upper right.  Effectively it's one line of the even
squares (2k)^2 == 4*k^2 and another of the odd squares (2k+1)^2.  The gap
between successive even squares increases by 8 each time and likewise the
odd squares.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::Foo-E<gt>new (key=E<gt>value, ...)>

Create and return a new path object.  Optional key/value parameters may
control aspects of the object.  C<Foo> here is one of the various
subclasses, see the list under L</SEE ALSO>.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return x,y coordinates of point C<$n> on the path.  If there's no point
C<$n> then the return is an empty list, so for example

    my ($x,$y) = $path->n_to_xy (-123)
      or next;   # likely no negatives in $path

Currently all paths start from N=1, though some will give a position for N=0
or N=0.5 too.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  If there's nothing at
C<$x,$y> then return C<undef>.

    my $n = $path->xy_to_n(20,20);
    if (! defined $n) {
      next;   # nothing at this x,y
    }

C<$x> and C<$y> can be fractional and the path classes will give an integer
C<$n> which contains C<$x,$y> within a unit square, circle, or intended
figure centred on that C<$n>.

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

The return may be an over-estimate of the range, and some of the points
between C<$n_lo> and C<$n_hi> may go outside the rectangle.  C<$n_hi> is
usually no more than an extra partial row or revolution.  C<$n_lo> is often
just the starting point 1, which is correct if the origin 0,0 is in the
rectangle, but something away from the origin might in fact start higher.

C<$x1>,C<$y1> and C<$x2>,C<$y2> can be fractional and if they partly overlap
some N figures then those N's are included in the return.  If there's no
points in the rectangle then the return may be a "crossed" range like
C<$n_lo=1>, C<$n_hi=0> (which makes a C<foreach> do no loops).

=item C<$bool = $path-E<gt>x_negative>

=item C<$bool = $path-E<gt>y_negative>

Return true if the path extends into negative X coordinates and/or negative
Y coordinates respectively.

=item C<$str = $path-E<gt>figure>

Return the name of the figure (shape) intended to be drawn at each C<$n>
position.  This is a string name, currently either

    square         side 1 centred on $x,$y
    circle         diameter 1 centred on $x,$y

Of course this is only a suggestion as PlanePath doesn't draw anything
itself.  A figure like a diamond for instance could look good too.

=back

=head1 SEE ALSO

L<Math::PlanePath::SquareSpiral>,
L<Math::PlanePath::PyramidSpiral>,
L<Math::PlanePath::TriangleSpiral>,
L<Math::PlanePath::TriangleSpiralSkewed>,
L<Math::PlanePath::DiamondSpiral>,
L<Math::PlanePath::PentSpiralSkewed>,
L<Math::PlanePath::HexSpiral>,
L<Math::PlanePath::HexSpiralSkewed>,
L<Math::PlanePath::HeptSpiralSkewed>,
L<Math::PlanePath::KnightSpiral>

L<Math::PlanePath::SacksSpiral>,
L<Math::PlanePath::VogelFloret>,
L<Math::PlanePath::TheodorusSpiral>,
L<Math::PlanePath::MultipleRings>

L<Math::PlanePath::Rows>,
L<Math::PlanePath::Columns>,
L<Math::PlanePath::Diagonals>,
L<Math::PlanePath::Corner>,
L<Math::PlanePath::PyramidRows>,
L<Math::PlanePath::PyramidSides>

L<math-image> program to display various sequences on these paths.
F<examples/numbers.pl> in the sources to print all the paths.

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Math-PlanePath is Copyright 2010 Kevin Ryde

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
