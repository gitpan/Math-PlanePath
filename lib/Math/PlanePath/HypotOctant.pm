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


package Math::PlanePath::HypotOctant;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 72;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Smart::Comments;


# A000328 Number of points of norm <= n^2 in square lattice.
# 1, 5, 13, 29, 49, 81, 113, 149, 197, 253, 317, 377, 441, 529, 613, 709, 797
#
# a(n) = 1 + 4 * sum(j=0, n^2 / 4,    n^2 / (4*j+1) - n^2 / (4*j+3) )


use constant class_x_negative => 0;
use constant class_y_negative => 0;

my @n_to_x = (undef, 0);
my @n_to_y = (undef, 0);
my @hypot_to_n = (1);
my @y_next_x = (1, 1);
my @y_next_hypot = (1, 2);

sub _extend {
  ### _extend() n: scalar(@n_to_x)

  my @y = (0);
  my $hypot = $y_next_hypot[0];
  for (my $i = 1; $i < @y_next_x; $i++) {
    if ($hypot == $y_next_hypot[$i]) {
      push @y, $i;
    } elsif ($hypot > $y_next_hypot[$i]) {
      @y = ($i);
      $hypot = $y_next_hypot[$i]
    }
  }

  if ($y[-1] == $#y_next_x) {
    my $y = scalar(@y_next_x);
    $y_next_x[$y] = $y;
    $y_next_hypot[$y] = 2*$y*$y;
    ### assert: $y_next_hypot[$y] == $y**2 + $y_next_x[$y]**2
  }

  ### store: join(' ',map{"$x[$_],$y[$_]"} 0 .. $#x)
  ### at n: scalar(@n_to_x)
  ### hypot_to_n: "h=$hypot n=".scalar(@n_to_x)
  $hypot_to_n[$hypot] = scalar(@n_to_x);
  push @n_to_y, @y;
  push @n_to_x,
    map {
      my $x = $y_next_x[$_]++;
      $y_next_hypot[$_] += 2*$x+1;
      ### assert: $y_next_hypot[$_] == $_**2 + $y_next_x[$_]**2
      $x
    } @y;

  # ### hypot_to_n now: join(' ',map {defined($hypot_to_n[$_]) && "h=$_,n=$hypot_to_n[$_]"} 0 .. $#hypot_to_n)
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### Hypot n_to_xy(): $n

  if ($n < 1) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  {
    my $int = int($n);
    if ($n != $int) {
      my $frac = $n - $int;  # inherit possible BigFloat/BigRat
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
  }

  while ($n > $#n_to_x) {
    _extend();
  }

  return ($n_to_x[$n], $n_to_y[$n]);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### Hypot xy_to_n(): "$x, $y"
  ### hypot_to_n last: $#hypot_to_n

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);

  my $hypot = $x*$x + $y*$y;
  if (_is_infinite($hypot)) {
    return $hypot;
  }

  if ($x < 0 || $y < 0 || $y > $x) {
    ### outside first octant ...
    return undef;
  }

  while ($hypot > $#hypot_to_n) {
    _extend();
  }
  my $n = $hypot_to_n[$hypot];
  for (;;) {
    if ($x == $n_to_x[$n] && $y == $n_to_y[$n]) {
      return $n;
    }
    $n += 1;

    if ($n_to_x[$n]**2 + $n_to_y[$n]**2 != $hypot) {
      ### oops, hypot_to_n no good ...
      return undef;
    }
  }
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);
  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }

  if ($x2 < 0 || $y2 < 0) {
    return (1, 0);
  }

  # circle area pi*r^2, with r^2 = $x2**2 + $y2**2
  return (1, 1 + int (3.2/8 * (($x2+1)**2 + ($y2+1)**2)));
}

1;
__END__

=for stopwords Ryde Math-PlanePath hypot octant

=head1 NAME

Math::PlanePath::HypotOctant -- octant of points in order of hypotenuse distance

=head1 SYNOPSIS

 use Math::PlanePath::HypotOctant;
 my $path = Math::PlanePath::HypotOctant->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path visits an octant of integer points X,Y in order of their distance
from the origin 0,0.  The points are a rising triangle 0E<lt>=YE<lt>=X,

     8                                   61
     7                               47  54
     6                           36  43  49
     5                       27  31  38  44
     4                   18  23  28  34  39
     3               12  15  19  24  30  37
     2            6   9  13  17  22  29  35
     1        3   5   8  11  16  21  26  33
    Y=0   1   2   4   7  10  14  20  25  32  ...

         X=0  1   2   3   4   5   6   7   8
  

For example N=11 at X=4,Y=1 is sqrt(4*4+1*1) = sqrt(17) from the origin.
The next furthest from the origin is X=3,Y=3 at sqrt(18).

In general the X,Y points are the sums of two squares X^2+Y^2 taken in
increasing order of that hypotenuse, but only the "primitive" X,Y
combinations, primitive in the sense of excluding mere negative X or Y or
swapped Y,X.

=head2 Equal Distances

Points with the same distance from the origin are taken in anti-clockwise
order from the X axis, which means by increasing Y.  Points the same
distance arise when there's more than one way to express a given distance as
the sum of two squares.

Pythagorean triples give a point on the X axis and also above it at the same
distance.  For example 5^2 == 4^2 + 3^2 has N=14 at X=5,Y=0 and N=15 at
X=4,Y=3, both 5 away from the origin.

Combinations like 20^2 + 15^2 == 24^2 + 7^2 occur too, and also with three
or more different ways to have the same sum distance.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::HypotOctant-E<gt>new ()>

Create and return a new hypot octant path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n E<lt> 1> the return is an empty list, it being considered the first
point at X=0,Y=0 is N=1.

Currently it's unspecified what happens if C<$n> is not an integer.
Successive points are a fair way apart, so it may not make much sense to say
give an X,Y position in between the integer C<$n>.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x,$y>.  Each integer N is
considered the centre of a unit square and an C<$x,$y> within that square
returns N.

=back

=head1 FORMULAS

The calculations are not very efficient currently.  For each Y row a current
X and the corresponding hypotenuse X^2+Y^2 are maintained.  To find the next
furthest a search through those hypotenuses is made seeking the smallest,
including equal smallest, which then become the next N points.

For C<n_to_xy()> an array is built and re-used for repeat calculations.  For
C<xy_to_n()> an array of hypot to N gives a the first N of given X^2+Y^2
distance.  A search is then made through the next few N for the case there's
more than one X,Y of that hypot.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::Hypot>,
L<Math::PlanePath::PixelRings>,
L<Math::PlanePath::PythagoreanTree>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011, 2012 Kevin Ryde

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
