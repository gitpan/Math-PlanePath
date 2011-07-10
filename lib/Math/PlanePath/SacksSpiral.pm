# Copyright 2010, 2011 Kevin Ryde

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
use List::Util qw(min max);
use Math::Libm 'hypot', 'M_PI';
use POSIX 'floor';
use Math::PlanePath::MultipleRings;

use vars '$VERSION', '@ISA';
$VERSION = 34;

use Math::PlanePath;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant n_start => 0;
use constant figure => 'circle';

sub n_to_xy {
  my ($self, $n) = @_;
  if ($n < 0) {
    return ();
  }
  my $r = sqrt($n);
  my $theta = 2 * M_PI() * ($r - int($r));  # radians 0 to 2*pi
  return ($r * cos($theta),
          $r * sin($theta));

}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### SacksSpiral xy_to_n(): "$x, $y"

  my $theta_frac = Math::PlanePath::MultipleRings::_xy_to_angle_frac($x,$y);
  ### assert: 0 <= $theta_frac && $theta_frac < 1

  # the nearest arc, integer
  my $s = floor (hypot($x,$y) - $theta_frac + 0.5);

  # the nearest N on the arc
  my $n = floor ($s*$s + $theta_frac * (2*$s + 1) + 0.5);

  # check within 0.5 radius
  my ($nx, $ny) = $self->n_to_xy($n);

  ### $theta_frac
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
  my $self = shift;

  my ($rlo, $rhi) = _rect_to_radius_range(@_);
  # minimum rlo=0 for minimum N=1
  $rlo = max (0, $rlo-0.6);
  $rhi += 0.6;

  return (int($rlo*$rlo),
          1 + POSIX::ceil($rhi*$rhi));
}

sub _rect_to_radius_range {
  my ($x1,$y1, $x2,$y2) = @_;

  return (hypot((($x1 > 0) == ($x2 > 0)
                 # x range doesn't include x=0, so low is min abs value
                 ? min(abs($x1),abs($x2))
                 # x range includes x=0, so that's the minimum
                 : 0),

                (($y1 > 0) == ($y2 > 0)  # same for y
                 ? min(abs($y1),abs($y2))
                 : 0)),

          hypot (max(abs($x1),abs($x2)),
                 max(abs($y1),abs($y2))));
}

1;
__END__

=for stopwords Archimedean ie pronic PlanePath Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::SacksSpiral -- circular spiral, squaring each revolution

=head1 SYNOPSIS

 use Math::PlanePath::SacksSpiral;
 my $path = Math::PlanePath::SacksSpiral->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

The Sacks spiral by Robert Sacks is an Archimedean spiral with points N
placed on the spiral so the perfect squares fall on a line going to the
right.  Read more at

    http://www.numberspiral.com

An Archimedean spiral means each loop is a constant distance from the
preceding, in this case 1 unit.  The polar coordinates are

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
the right axis at X=0,1,2,3,etc spaced 1 apart.  Other points are a little
further apart.

The arms going to the right like 5,10,17,etc or 8,15,24,etc are constant
offsets from the perfect squares, ie. S<s^2 + c> for positive or negative
integer c.  To the left the central arm 2,6,12,20,etc is the pronic numbers
S<s^2 + s>, half way between the successive perfect squares.  Other arms
going to the left are offsets from that, ie. s^2 + s + c for integer c.

Euler's quadratic s^2+s+41 is one such arm going left.  Low values loop
around a few times before straightening out at about y=-127.  This quadratic
has relatively many primes and in a plot of the primes on the spiral it can
be seen standing out from its surrounds.

Plotting various quadratic sequences of points can form attractive patterns.
For example the triangular numbers s*(s+1)/2 come out as spiral arcs going
clockwise and counter-clockwise.

See F<examples/sacks-xpm.pl> in the Math-PlanePath sources for a complete
program plotting the spiral points to an XPM image file.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::SacksSpiral-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

C<$n> can be any value C<$n E<gt>= 0> and fractions give positions on the
spiral in between the integer points.

For C<$n < 0> the return is an empty list, it being considered there are no
negative points in the spiral.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x,$y>.  Each integer N
is considered the centre of a circle of diameter 1 and an C<$x,$y> within
that circle returns N.

The unit spacing of the spiral means those circles don't overlap, but they
also don't cover the plane and if C<$x,$y> is not within one then the
return is C<undef>.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PyramidRows>,
L<Math::PlanePath::ArchimedeanChords>,
L<Math::PlanePath::TheodorusSpiral>,
L<Math::PlanePath::VogelFloret>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

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
