# Copyright 2010 Kevin Ryde

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


package Math::PlanePath::SacksSpiral;
use 5.004;
use strict;
use warnings;
use List::Util qw(min max);
use Math::Libm 'hypot';
use Math::Trig 'pi';
use POSIX ();

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION', '@ISA';
$VERSION = 2;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use constant figure => 'circle';

sub n_to_xy {
  my ($self, $n) = @_;
  return if $n < 0;
  my $r = sqrt($n);
  my $theta = 2 * pi() * ($r - int($r));  # radians 0 to 2*pi
  return ($r * cos($theta),
          $r * sin($theta));

}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### SacksSpiral xy_to_n(): "$x, $y"

  # avoid atan2(0,0)
  if ($x == 0 && $y == 0) {
    return 0;
  }
  my $theta = atan2($y,$x) * (1 / (2 * pi()));
  if ($theta < 0) { $theta++; }  # 0 <= $theta <= 1 angle around

  # the nearest arc
  my $s = POSIX::floor (hypot($x,$y) - $theta + 0.5);

  # the nearest point on the arc
  my $n = POSIX::floor ($s*$s + $theta * (2*$s + 1) + 0.5);

  # check within 0.5 radius
  my ($nx, $ny) = $self->n_to_xy($n);

  ### $theta
  ### raw hypot: hypot($x,$y)
  ### $s
  ### $n
  ### hypot: hypot($nx-$x, $ny-$y)
  if (hypot($nx-$x,$ny-$y) <= 0.5) {
    return $n;
  } else {
    return undef;
  }
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  my $r = hypot (max(abs($x1),abs($x2)), max(abs($y1),abs($y2)));
  # ENHANCE-ME: find actual minimum r if rect doesn't cover 0,0
  return (1,
          1 + POSIX::ceil (($r+1) ** 2));
}

1;
__END__

=for stopwords Archimedean ie pronic PlanePath Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::SacksSpiral -- circular spiral squaring each revolution

=head1 SYNOPSIS

 use Math::PlanePath::SacksSpiral;
 my $path = Math::PlanePath::SacksSpiral->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

The Sacks spiral by Robert Sacks is an Archimedean spiral with points N
placed on the spiral so the perfect squares fall on a line going to the
right.  Read more at

    http://www.numberspiral.com

The polar coordinates are

    R = sqrt(N)
    theta = sqrt(N) * 2pi

which comes out roughly as

                    18
          19   11        10  17
                     5
             
    20  12  6   2
                   0  1   4   9  16  25

                   3
      21   13   7        8
                             15   24
                    14
               22        23

The X,Y positions returned are fractional, except for the perfect squares on
the right axis at X=0,1,2,3,etc.  Those perfect squares are spaced 1 apart,
other pointer are a little further apart.

The arms going to the right like 5,10,17,etc or 8,15,24,etc are constant
offsets from the perfect squares, ie. s**2 + c for a positive or negative
integer c.  The central arm 2,6,12,20,etc going left is the pronic numbers
s**2 + s, half way between the successive perfect squares.  Other arms going
to the left are offsets from that, ie. s**2 + s + c for integer c.

Plotting quadratic sequences in the points can form attractive patterns.
For example the triangular numbers (s**2 + s)/2 come out as spiral arms
going clockwise and counter-clockwise.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::SacksSpiral-E<gt>new (key=E<gt>value, ...)>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> on the path.

C<$n> can be any value C<$n E<gt>= 0> and fractions give positions on the
spiral in between the integer points.

For C<$n < 0> the return is an empty list, it being considered there are no
negative points in the spiral.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x>,C<$y>.  Each integer N
is considered the centre of a circle of diameter 1 and an C<$x>,C<$y> within
that circle returns N.

The unit spacing of the spiral means those circles don't overlap, but they
also don't cover the plane and if C<$x>,C<$y> is not within one then the
return is C<undef>.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PyramidRows>
L<Math::PlanePath::VogelFloret>

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
