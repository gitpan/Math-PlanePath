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


package Math::PlanePath::VogelFloret;
use 5.004;
use strict;
use warnings;
use List::Util qw(min max);
use Math::Libm 'hypot';
use Math::Trig 'pi';

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 4;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;


# n=1   r=sqrt(1) = 1
#       t=1/phi^2 = 0.38 around
#       x=-.72 y=.68
# n=4   r=sqrt(4) = 2
#       t=4/phi^2 = 1.527 = .527 around
#       x=-1.97 y=-.337
# diff dx=1.25 dy=1.017  hypot=1.61


use constant figure => 'circle';

use constant PHI => (1 + sqrt(5)) / 2;
use constant FACTOR => do {
  my @c = map {
    my $r = sqrt($_);
    my $theta = $_ * 2*pi() / (PHI * PHI);
    ### $r
    ### $theta
    Math::Trig::cylindrical_to_cartesian($r, $theta, 0);
  } 1, 4;
  ### @c
  1 / hypot ($c[0]-$c[3], $c[1]-$c[4])
};
### FACTOR: FACTOR()

sub n_to_xy {
  my ($self, $n) = @_;
  return if $n < 0;
  my $r = sqrt($n) * FACTOR;
  my $theta = $n / (PHI * PHI);  # 1==full circle
  $theta = 2 * pi() * ($theta - int($theta));  # radians 0 to 2*pi
  return ($r * cos($theta),
          $r * sin($theta));

  # return (Math::Trig::cylindrical_to_cartesian($r, $theta, 0))[0,1];
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  my $r = hypot ($x, $y) * (1 / FACTOR);

  # Slack approach just trying all the N values between r-.5 and r+.5, which
  # is about 2*$r many.
  #
  # The target N is a short distance from an integer multiple, less theta,
  # of PHI*PHI.  What's an easy way to find the first integer N >= (r-.5)**2
  # satisfying -small <= N mod 2.618034 <= +small ?
  # 
  foreach my $n (reverse POSIX::ceil((max(0,$r-.5))**2)
                 .. POSIX::floor(($r+.5)**2)) {
    my ($nx, $ny) = $self->n_to_xy($n);
    ### hypot: "$n ".hypot($nx-$x,$ny-$y)
    if (hypot($nx-$x,$ny-$y) <= 0.5) {
      return $n;
    }
  }
  return undef;

  #   my $theta = atan2 ($y, $x) * (1 / (2*pi()));  # -0.5 to +0.5
  #   if ($theta < 0) { $theta++; }   # 0 to 1
  #
  #   # seeking integer k where (k+theta)*PHIPHI == $r*$r == $n or nearby
  #   my $k = $r*$r / (PHI*PHI) - $theta;
  #
  #   ### $x
  #   ### $y
  #   ### $r
  #   ### $theta
  #   ### $k
  #
  #   foreach my $ki (POSIX::floor($k), POSIX::ceil($k)) {
  #     my $n = int (($ki+$theta)*PHI*PHI + 0.5);
  #
  #     # look for within 0.5 radius
  #     my ($nx, $ny) = $self->n_to_xy($n);
  #     ### $ki
  #     ### n frac: ($ki+$theta)*PHI*PHI
  #     ### $n
  #     ### hypot: hypot($nx-$x,$ny-$y)
  #     if (hypot($nx-$x,$ny-$y) <= 0.5) {
  #       return $n;
  #     }
  #   }
  #   return;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  my $r = max (hypot ($x1, $y1),
               hypot ($x1, $y2),
               hypot ($x2, $y1),
               hypot ($x2, $y2))
    + 1;
  # ENHANCE-ME: find actual minimum r if rect doesn't cover 0,0
  return (1,
          1 + POSIX::ceil (((1/FACTOR) * $r) ** 2));
}

1;
__END__

=for stopwords Vogel PlanePaths VogelFloret fibonacci sqrt PlanePath Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::VogelFloret -- circular spiral like a sunflower

=head1 SYNOPSIS

 use Math::PlanePath::VogelFloret;
 my $path = Math::PlanePath::VogelFloret->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

The Vogel spiral arranges integer points in a spiraling pattern so they
align to resemble the pattern of seeds found in the head of a sunflower.

The polar coordinates are

    R = sqrt(N) * FACTOR
    theta = (N / (PHI**2)) * 2pi

where PHI is the golden ratio (1+sqrt(5))/2 and FACTOR is a scaling factor
of about 1.6 designed to put the points 1 apart (or a little more).

Most of the other PlanePaths are implicitly quadratic, but the VogelFloret
is instead essentially based on near-integer multiples of PHI**2 (which is
PHI+1)..

The fibonacci numbers fall close to the X axis to the right because they're
roughly powers of the golden ratio, F(k) ~= (PHI**k)/sqrt(5).  The
exponential grows faster than the sqrt in the R radial distance so they soon
become widely spaced though.  The Lucas numbers similarly.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::VogelFloret-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> on the path.

C<$n> can be any value C<$n E<gt>= 0> and fractions give positions on the
spiral in between the integer points.

For C<$n < 0> the return is an empty list, it being considered there are no
negative points in the spiral.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x,$y>.  Each integer N
is considered the centre of a circle of diameter 1 and an C<$x,$y> within
that circle returns N.

The path is scaled so no two points are closer than 1 apart so the circles
don't overlap, but they also don't cover the plane and if C<$x,$y> is not
within one of those circles then the return is C<undef>.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SacksSpiral>

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
