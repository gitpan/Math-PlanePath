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



# http://algorithmicbotany.org/papers/#abop
#

package Math::PlanePath::VogelFloret;
use 5.004;
use strict;
use Carp;
use List::Util 'min', 'max';
use Math::Libm 'M_PI', 'hypot';

use vars '$VERSION', '@ISA';
$VERSION = 39;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;

use Math::PlanePath::SacksSpiral;

# uncomment this to run the ### lines
#use Smart::Comments '###';


# http://artemis.wszib.edu.pl/~sloot/2_1.html
#
# http://www.csse.monash.edu.au/publications/2003/tr-2003-149-full.pdf
#     on 3D surfaces of revolution or some such maybe
#     14 Mbytes (or preview with google)
#

# closest two for phi are 1 and 4
#     n=1   r=sqrt(1) = 1
#           t=1/phi^2 = 0.381 around
#           x=-.72 y=.68
#     n=4   r=sqrt(4) = 2
#           t=4/phi^2 = 1.527 = .527 around
#           x=-1.97 y=-.337
#     diff angle=4/phi^2 - 1/phi^2 = 3/phi^2 = 3*(2-phi) = 1.14 = .14
#     diff dx=1.25 dy=1.017  hypot=1.61
#     dang = 2*M_PI()*(5-3*phi)
#     y = sin()
#     x = sin(2*M_PI()*(5-3*phi))

# Continued fraction
#               1
#     x = k + ------
#             k +  1
#                 ------
#                 k +  1
#                     ---
#                     k + ...
#
#     x = k + 1/x
#     (x-k/2)^2 = 1 + (k^2)/4
#
#         k + sqrt(4+k^2)
#     x = ---------------
#               2
#
#    k       x
#    1    (1+sqrt(5)) / 2
#    2    1 + sqrt(2)
#    3    (3+sqrt(13)) / 2
#    4    2 + sqrt(5)
#    5    (5 + sqrt(29)) / 2
#    6    3 + sqrt(10)
#   2e    e + sqrt(1+e^2)  even


# is N=1 the proper start?
# use constant n_start => 0;

use constant figure => 'circle';
use constant 1.02; # for leading underscore
use constant _PHI => (1 + sqrt(5)) / 2;

# not documented yet ...
use constant rotation_types =>
  { phi   => { rotation_factor => 2 - _PHI(),
               radius_factor   => 0.624239116809924,
               # closest_Ns      => [ 1,4 ],
               # continued_frac  => [ 1,1,1,1,1,... ],
             },
    sqrt2 => { rotation_factor => sqrt(2)-1,
               radius_factor   => 0.679984167849259,
               # closest_Ns      => [ 3,8 ],
               # continued_frac  => [ 2,2,2,2,2,... ],
             },
    sqrt3 => { rotation_factor => sqrt(3)-1,
               radius_factor   => 0.755560810248419,
               # closest_Ns      => [ 3,7 ],
               # continued_frac  => [ 1,2,1,2,1,2,1,2,... ],
             },
    sqrt5 => { rotation_factor => sqrt(5)-2,
               radius_factor   => 0.853488207169303,
               # closest_Ns      => [ 4,8 ],
               # continued_frac  => [ 4,4,4,4,4,4,... ],
             },
  };

sub new {
  my $self = shift->SUPER::new (@_);

  my $rotation_type = $self->{'rotation_type'} || 'phi';
  my $defaults = rotation_types()->{$rotation_type}
    || croak 'Unrecognised rotation_type';

  $self->{'rotation_factor'} ||= $defaults->{'rotation_factor'};
  $self->{'radius_factor'}  ||= ($self->{'rotation_type'}
                                 ? $defaults->{'radius_factor'}
                                 : 1.0);
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  return if $n < 0;
  my $r = sqrt($n) * $self->{'radius_factor'};

  # take the frac part of 1==circle and then convert to radians, so as not
  # to lose precision in an fmod(...,2*pi)
  #
  my $theta = $n * $self->{'rotation_factor'};    # 1==full circle
  $theta = 2 * M_PI() * ($theta - int($theta));  # radians 0 to 2*pi
  return ($r * cos($theta),
          $r * sin($theta));

  # cylindrical_to_cartesian() is only perl code, so may as well sin/cos
  # here directly
  # return (Math::Trig::cylindrical_to_cartesian($r, $theta, 0))[0,1];
}

sub xy_to_n {
  my ($self, $x, $y) = @_;

  # Slack approach just trying all the N values between r-.5 and r+.5.
  #
  # r = sqrt(n)*FACTOR
  # n = (r/FACTOR)^2
  #
  # The target N satisfies N = K * phi + epsilon for integer K.  What's an
  # easy way to find the first integer N >= (r-.5)**2 satisfying -small <= N
  # mod .318 <= +small ?
  #
  my $r = hypot ($x, $y);
  my $factor = $self->{'radius_factor'};
  my $n_lo = max(0, POSIX::floor( (($r-.6)/$factor)**2 ));
  my $n_hi = POSIX::ceil( (($r+.6)/$factor)**2 );
  #### $r
  #### xy: "$x,$y"
  #### $n_lo
  #### $n_hi

  if (_is_infinite($n_lo) || _is_infinite($n_hi)) {
    ### infinite range, r inf or too big
    return undef;
  }

  # for(;;) loop since "reverse $n_lo..$n_hi" limited to IV range
  for (my $n = $n_hi; $n >= $n_lo; $n--) {
    my ($nx, $ny) = $self->n_to_xy($n);
    ### hypot: "$n ".hypot($nx-$x,$ny-$y)
    if (hypot($nx-$x,$ny-$y) <= 0.5) {
      #### found: $n
      return $n;
    }
  }
  return undef;

  # my $theta_frac = Math::PlanePath::MultipleRings::_xy_to_angle_frac($x,$y);
  # ### assert: 0 <= $frac && $frac < 1
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
  my $self = shift;
  ### VogelFloret rect_to_n_range(): @_

  my ($r_lo, $r_hi) = Math::PlanePath::SacksSpiral::_rect_to_radius_range(@_);
  # minimum r_lo=1 for minimum N=1
  $r_lo = max (1, ($r_lo-0.6) / $self->{'radius_factor'});
  $r_hi = ($r_hi + 0.6) / $self->{'radius_factor'};
  ### $r_lo
  ### $r_hi

  return (int($r_lo*$r_lo),
          1 + POSIX::ceil($r_hi*$r_hi));
}

1;
__END__

=for stopwords Vogel PlanePaths VogelFloret fibonacci sqrt sqrt2 PlanePath Ryde Math-PlanePath frac repdigits straightish Vogel's builtin repunit eg phi-ness

=head1 NAME

Math::PlanePath::VogelFloret -- circular pattern like a sunflower

=head1 SYNOPSIS

 use Math::PlanePath::VogelFloret;
 my $path = Math::PlanePath::VogelFloret->new;
 my ($x, $y) = $path->n_to_xy (123);

 # other rotations
 $path = Math::PlanePath::VogelFloret->new
           (rotation_type => 'sqrt2');

=head1 DESCRIPTION

The Vogel floret arranges integer points in a spiral with points based on
the golden ratio phi = (1+sqrt(5))/2 and resembling the pattern of seeds
found in the head of a sunflower,

                27       19
                                  24

                14          11
          22                         16
                       6                   29

    30           9           3
                                   8
                       1                   21
          17              .
                    4
                                     13
       25                 2     5
             12
                    7                      26
                               10
                                     18
             20       15

                            23       31
                   28

Most of the PlanePaths are implicitly quadratic, but the VogelFloret is
instead based on integer multiples of phi (or other selected rotation
factor).

The polar coordinates for a point N are

    R = sqrt(N) * radius_factor
    angle = N / (phi**2)        in revolutions, 1==full circle
          = N * -phi            modulo 1 and since 1/phi^2 = 2-phi
    theta = 2*pi * angle        in radians

Each point N+1 is at an angle 0.382 counter-clockwise around from the
preceding point N, which is just over 1/3 of a circle.  Or equivalently it's
0.618 back clockwise which is phi=1.618 ignoring the integer part since
that's a full circle, only the fractional part determines the position.

C<radius_factor> is a scaling 0.6242 designed to put the closest points 1
apart.  The closest are N=1 and N=4.  See L</Packing> below.

=head2 Other Rotation Types

An optional C<rotation_type> parameter selects other possible floret forms.

    $path = Math::PlanePath::VogelFloret->new
               (rotation_type => 'sqrt2');

The current types are as follows.  The C<radius_factor> for each keeps
points at least 1 apart so unit circles don't overlap.

    rotation_type   rotation_factor   radius_factor
      phi          2-phi   = 0.3820     0.624
      sqrt2        sqrt(2) = 0.4142     0.680
      sqrt3        sqrt(3) = 0.7321     0.756
      sqrt5        sqrt(5) = 0.2361     0.853

The "sqrt2" floret is quite similar to phi, but doesn't pack as tightly.
Custom rotations can be made with C<rotation_factor> and C<rotation_factor>
parameters,

    # R  = sqrt(N) * radius_factor
    # angle = N * rotation_factor     in revolutions
    # theta = 2*pi * angle            in radians
    #
    $path = Math::PlanePath::VogelFloret->new
               (rotation_factor => sqrt(37),
                radius_factor   => 2.0);

Usually C<rotation_factor> should be an irrational number.  A rational like
P/Q merely results in Q many straight lines and doesn't spread the points
enough to suit R=sqrt(N).  Irrationals which are very close to simple
rationals behave that way too.  (Of course all floating point values are
implicitly rationals, but are fine within the limits of floating point
accuracy.)

The "noble numbers" (A+B*phi)/(C+D*phi) with A*D-B*C=1, AE<lt>B, CE<lt>D
behave similar to the basic phi.  Their continued fraction expansion begins
with some arbitrary values and then becomes a repeating "1" the same as phi.
The effect is some spiral arms near the origin then the phi-ness dominating
for large N.

=head2 Packing

Each point is at an increasing distance sqrt(N) from the origin.  This is
based on how many unit figures will fit within that distance.  The area
within radius R is

    T = pi * R^2        area of circle R

so if N figures each of area A are packed into that space then

    N*A = T = pi * R^2
    R = sqrt(N) * sqrt(A/pi)

The tightest possible packing for unit circle figures is a hexagonal
honeycomb grid each of area A = sqrt(3)/2 = 0.866, for a factor sqrt(A/pi) =
0.525.  The phi floret packing is not as tight as that, needing radius
factor 0.624 per above.

Generally the tightness of the packing for a given rotation factor depends
on what fractions closely approximate that factor.  If the terms of the
continued fraction expansion are large then there's large regions of spiral
arcs with gaps between.  The density in such regions is low and a big radius
factor is needed to keep the points apart.  If the denominators are ever
increasing then there may be no factor big enough to always keep the points
a minimum distance apart ... or something like that.

The terms of the continued fraction for phi are all 1 and in that sense is,
among all irrationals, the value least well approximated by rationals.

                1
    phi = 1 + ------
              1 +  1
                  ------
              ^   1 +  1
              |       ---
              |   ^   1 +  1
              |   |       ----
              |   |   ^   ...
       terms -+---+---+

sqrt(3) is 1,2 repeating.  sqrt(13) is 3s repeating.

=head2 Fibonacci and Lucas Numbers

The Fibonacci numbers F(k) = 1,1,2,3,5,8,13,21, etc and Lucas number L(k) =
2,1,3,4,7,11,18, etc form almost straight lines on the X axis of the phi
floret.  This occurs because N*-phi is close to an integer for those N.  For
example N=13 has angle 13*-phi = -21.0344, the fractional part -0.0344 puts
it just below the X axis.

Both F(k) and L(k) grow exponentially (as phi^k) which soon outstrips the
sqrt in the R radial distance so they become widely spaced apart along the X
axis.

For interest or for reference, the angle calculation F(k)*phi is in fact the
next Fibonacci number F(k+1), per the well-known limit F(k+1)/F(k) -> phi as
k->infinity,

    angle = F(k)*-phi
          = -F(k+1) + epsilon

The Lucas numbers similarly with L(k)*phi close to L(k+1).  Epsilon
approaches zero quickly enough in both cases that the resulting Y coordinate
approaches zero.  This can be calculated as follows, writing beta = -1/phi =
-0.618 and since abs(beta)<1 the powers beta^k go to zero.

    F(k) = (phi^k - beta^k) / (phi - beta)

    angle = F(k) * -phi
          = - (phi*phi^k - phi*beta^k) / (phi - beta)
          = - (phi^(k+1) - beta^(k+1)
                         + beta^(k+1) - phi*beta^k) / (phi - beta)
          = - F(k+1) - (phi-beta)*beta^k / (phi - beta)
          = - F(k+1) - beta^k

    frac(angle) = - beta^k = 1/(-phi)^k

The arc distance away from the X axis at radius R=sqrt(F(k)) is then as
follows; simplifying using phi*(-beta)=1 and S<phi - beta> = sqrt(5).  The Y
coordinate vertical distance is a little less than the arc distance.

    arcdist = 2*pi * R * frac(angle)
            = 2*pi * sqrt((phi^k - beta^k)/sqrt(5)) * 1/(-phi)^k
            = - (-1)^k * 2*pi * sqrt((1/phi^2k*phi^k - beta^3k)/sqrt(5))
            = - (-1)^k * 2*pi * sqrt((1/phi^k - 1/(-phi)^3k)/sqrt(5))
              approaches 0 as k -> infinity

Basically the radius increases as phi^(k/2) but the angle frac decreases as
(1/phi)^k so their product goes to zero.  The (-1)^k in the formula puts the
points alternately just above and just below the X axis.

The calculation for the Lucas numbers is very similar, with term +(beta^k)
instead of -(beta^k) and an extra factor sqrt(5).

    L(k) = phi^k + beta^k

    angle = L(k) * -phi
          = -phi*phi^k - phi*beta^k
          = -phi^(k+1) - beta^(k+1) + beta^(k+1) - phi*beta^k
          = -L(k) + beta^k * (beta - phi)
          = -L(k) - sqrt(5) * beta^k

    frac(angle) = -sqrt(5) * beta^k = -sqrt(5) / (-phi)^k

    arcdist = 2*pi * R * frac(angle)
            = 2*pi * sqrt(L(k)) * sqrt(5)*beta^k
            = 2*pi * sqrt(phi^k + 1/(-phi)^k) * sqrt(5)*beta^k
            = (-1)*k * 2*pi * sqrt(5) * sqrt((-beta)^2k * phi^k + beta^3k)
            = (-1)*k * 2*pi * sqrt(5) * sqrt((-beta)^k + beta^3k)

=head2 Repdigits in Decimal

Some of the decimal repdigits 11, 22, ..., 99, 111, ..., 999, etc make
nearly straight radial lines on the phi floret.  For example 11, 66, 333,
888 make a line upwards to the right.

11 and 66 are at the same polar angle because the difference is 55 and
55*phi = 88.9919 is nearly an integer meaning the angle is nearly unchanged
when added.  Similarly 66 to 333 difference 267 has 267*phi = 432.015, or
333 to 888 difference 555 has 555*phi = 898.009.  The 55 is a Fibonacci
number, the 123 between 99 and 222 is a Lucas number, and 267 = 144+123 =
F(12)+L(10).

The 55 and 555 differences apply to between pairs 22 to 77, 33 to 88, 666 to
1111, etc, making four straightish arms.  55 and 555 themselves are near the
X axis.

A separate spiral arm arises from 11111 falling moderately close to the X
axis since 11111*-phi = -17977.9756, or about 0.024 of a circle upwards.
The subsequent 22222, 33333, 44444, etc make a little arc of nine values
going about a quarter turn (9*0.024 = 0.219) upwards.

=head2 Repdigits in Other Bases

By choosing a radix so that "11" (or similar repunit) is close to the X
axis, spirals like the decimal 11111 above can be created.  This includes
when "11" is a Fibonacci number or Lucas number, such as base 12 making "11"
equal to 13.  If "11" is near the negative X axis then there's two spiral
arms, one going out on the X negative side and one X positive, eg. base 16
has "11"=17 which is near the negative X axis.  A four-arm shape can be
formed similarly if "11" is near the Y axis, eg. base 107.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::VogelFloret-E<gt>new ()>

=item C<$path = Math::PlanePath::VogelFloret-E<gt>new (key =E<gt> value, ...)>

Create and return a new path object.

The default is Vogel's phi floret.  Optional parameters can vary the
pattern,

    rotation_type   => string, choices above
    rotation_factor => number
    radius_factor   => number

The available C<rotation_type> values are listed above (see L</Other
Rotation Types>).  C<radius_factor> can be given on top of a type to scale
it differently.

If a C<rotation_factor> is given then the default C<radius_factor> is not
yet quite settled.  Currently it's 1.0, but perhaps something suiting at
least the first few N positions would be better.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

C<$n> can be any value C<$n E<gt>= 0> and fractions give positions on the
spiral in between the integer points, though the principle interest for the
floret is where the integers fall.

For C<$n < 0> the return is an empty list, it being considered there are no
negative points in the spiral.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x,$y>.  Each integer N
is considered the centre of a circle of diameter 1 and an C<$x,$y> within
that circle returns N.

The builtin C<rotation_type> choices are scaled so no two points are closer
than 1 apart so the circles don't overlap, but they also don't cover the
plane and if C<$x,$y> is not within one of those circles then the return is
C<undef>.

With C<rotation_factor> and C<radius_factor> parameters it's possible for
unit circles to overlap.  In the current code the return is the largest N
covering C<$x,$y>, but perhaps that will change.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SacksSpiral>,
L<Math::PlanePath::TheodorusSpiral>

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
