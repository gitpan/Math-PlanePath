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


# could loop by more or less, eg. 4*n^2 each time like a square spiral
# (Kevin Vicklund at the_surprises_never_eend_the_u.php)

package Math::PlanePath::SacksSpiral;
use 5.004;
use strict;
use List::Util qw(min max);
use Math::Libm 'hypot';
use POSIX 'floor';
use Math::PlanePath::MultipleRings;

use vars '$VERSION', '@ISA';
$VERSION = 59;

use Math::PlanePath;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;
use constant figure => 'circle';

# sub _as_float {
#   my ($x) = @_;
#   if (ref $x) {
#     if ($x->isa('Math::BigInt')) {
#       return Math::BigFloat->new($x);
#     }
#     if ($x->isa('Math::BigRat')) {
#       return $x->as_float;
#     }
#   }
#   return $x;
# }

# Note: this is "use Math::BigFloat" not "require Math::BigFloat" because
# BigFloat 1.997 does some setups in its import() needed to tie-in to the
# BigInt back-end, or something.
use constant::defer _bigfloat => sub {
  eval "use Math::BigFloat; 1" or die $@;
  return "Math::BigFloat";
};

use constant 1.02; # for leading underscore
use constant _TWO_PI => 8 * atan2(1,1);  # similar to Math::Complex

sub n_to_xy {
  my ($self, $n) = @_;
  if ($n < 0) {
    return;
  }
  my $two_pi = _TWO_PI();

  if (ref $n) {
    if ($n->isa('Math::BigInt')) {
      $n = _bigfloat()->new($n);
    }
    if ($n->isa('Math::BigRat')) {
      $n = $n->as_float;
    }
    if ($n->isa('Math::BigFloat')) {
      $two_pi = 2 * Math::BigFloat->bpi;
    }
  }

  my $r = sqrt($n);
  my $theta = $two_pi * ($r - int($r));  # 0 <= $theta < 2*pi
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

# not exact
sub rect_to_n_range {
  my $self = shift;

  my ($rlo, $rhi) = _rect_to_radius_range(@_);
  # minimum rlo=0 for minimum N=1
  $rlo -= 0.6; if ($rlo < 0) { $rlo = 0; }
  $rhi += 0.6;

  return (int($rlo*$rlo),
          int($rhi*$rhi + 2));
}

# return ($rlo,$rhi) which is the radial distance range found in the rectangle
sub _rect_to_radius_range {
  my ($x1,$y1, $x2,$y2) = @_;

  # if opposite sign then origin x=0 covered, similarly y=0
  my $x_origin_covered = ($x1<0) != ($x2<0);
  my $y_origin_covered = ($y1<0) != ($y2<0);

  $x1 = abs($x1);
  $x2 = abs($x2);
  $y1 = abs($y1);
  $y2 = abs($y2);

  return (hypot ($x_origin_covered ? 0 : min($x1,$x2),
                 $y_origin_covered ? 0 : min($y1,$y2)),
          hypot (max($x1,$x2),
                 max($y1,$y2)));
}

1;
__END__

=for stopwords Archimedean ie pronic PlanePath Ryde Math-PlanePath XPM Euler's

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

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

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

# Local variables:
# compile-command: "math-image --path=SacksSpiral"
# End:
