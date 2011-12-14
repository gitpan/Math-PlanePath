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


package Math::PlanePath::TheodorusSpiral;
use 5.004;
use strict;
use List::Util 'min', 'max';
use Math::Libm 'hypot';

use vars '$VERSION', '@ISA';
$VERSION = 59;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;

use Math::PlanePath::SacksSpiral;
*_rect_to_radius_range = \&Math::PlanePath::SacksSpiral::_rect_to_radius_range;

# uncomment this to run the ### lines
#use Smart::Comments '###';

use constant n_start => 0;
use constant figure => 'circle';


# This adding up of unit steps isn't very good.  The last x,y,n is kept
# anticipating successively higher n, not necessarily consecutive, plus past
# x,y,n at _SAVE intervals for going backwards.
#
# The simplest formulas for the polar angle, possibly with the analytic
# continuation version don't seem much better, but theta approaches
# 2*sqrt(N) + const, or 2*sqrt(N) + 1/(6*sqrt(N+1)) + const + O(n^(3/2)), so
# more terms of that might have tolerably rapid convergence.
#
# The arctan sums for the polar angle end up as the generalized Riemann
# zeta, or the generalized minus the plain.  Is there a good formula for
# that which would converge quickly?

use constant 1.02; # for leading underscore
use constant _SAVE => 1000;

my @save_n = (1);
my @save_x = (1);
my @save_y = (0);
my $next_save = _SAVE;

sub new {
  my $class = shift;
  return $class->SUPER::new (i => 1,
                             x => 1,
                             y => 0,
                             @_);
}

sub n_to_xy {
  my ($self, $n) = @_;
  #### n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  if ($n < 1) {
    return ($n, 0);
  }
  my $frac = $n;
  $n = int($n);
  $frac -= $n;

  my $i = $self->{'i'};
  my $x = $self->{'x'};
  my $y = $self->{'y'};
  #### n_to_xy(): "$n from $i $x,$y"

  if ($i > $n) {
    for (my $pos = $#save_n; $pos >= 0; $pos--) {
      if ($save_n[$pos] <= $n) {
        $i = $save_n[$pos];
        $x = $save_x[$pos];
        $y = $save_y[$pos];
        last;
      }
    }
    ### resume: "$i  $x,$y"
  }

  while ($i < $n) {
    my $r = sqrt($i);
    ($x,$y) = ($x - $y/$r, $y + $x/$r);
    $i++;

    if ($i == $next_save) {
      push @save_n, $n;
      push @save_x, $x;
      push @save_y, $y;
      $next_save += _SAVE;
    }
  }

  $self->{'i'} = $i;
  $self->{'x'} = $x;
  $self->{'y'} = $y;

  if ($frac) {
    my $r = sqrt($n);
    return ($x - $frac*$y/$r,
            $y + $frac*$x/$r);
  } else {
    #### plain return: "$i  $x,$y"
    return ($x,$y);
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### TheodorusSpiral xy_to_n(): "$x, $y"
  my $r = hypot ($x,$y);
  my $n_lo = int (max (0, $r - .51) ** 2);
  my $n_hi = int (($r + .51) ** 2);
  ### $n_lo
  ### $n_hi

  if (_is_infinite($n_lo) || _is_infinite($n_hi)) {
    ### infinite range, r inf or too big ...
    return undef;
  }

  # for(;;) loop since $n_lo..$n_hi limited to IV range
  for (my $n = $n_lo; $n <= $n_hi; $n += 1) {
    my ($nx,$ny) = $self->n_to_xy($n);
    #### $n
    #### $nx
    #### $ny
    #### hypot: hypot ($x-$nx,$y-$ny)
    if (hypot ($x-$nx,$y-$ny) <= 0.5) {
      return $n;
    }
  }
  return undef;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  my ($rlo, $rhi) = _rect_to_radius_range ($x1,$y1, $x2,$y2);
  $rlo = max (0, $rlo-.51);
  $rhi += .51;
  return (int($rlo*$rlo),       # round down
          int($rhi*$rhi + 1));  # round up
}

1;
__END__

=for stopwords Theodorus theodorus Ryde Math-PlanePath Archimedean Nhi Nlo arctan xlo,ylo xhi,yhi rlo Nlo Nhi Nhi-Nlo

=head1 NAME

Math::PlanePath::TheodorusSpiral -- right-angle unit step spiral

=head1 SYNOPSIS

 use Math::PlanePath::TheodorusSpiral;
 my $path = Math::PlanePath::TheodorusSpiral->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path puts points on the spiral of Theodorus, also called the square
root spiral.


                                   61                 6
                                     60
               27 26 25 24                            5
            28            23           59
          29                 22          58           4

       30                      21         57          3
      31                         20
                   4                       56         2
     32          5    3          19
               6         2                 55         1
    33                            18
              7       0  1                 54    <- Y=0
    34                           17
              8                            53        -1
    35                          16
               9                          52         -2
     36                       15
                 10         14           51          -3
      37           11 12 13            50
                                                     -4
        38                           49
          39                       48                -5
            40                  47
               41             46                     -6
                  42 43 44 45


                      ^
   -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7

Each step is a unit distance at right angles to the previous radial spoke.
So for example,

       3        -- Y=1+1/sqrt(2)
        \
         \
         ..2       Y=1
       ..  |
      .    |
     0-----1    <- Y=0

     ^
    X=0   X=1

1 to 2 is a unit step at right angles to the 0 to 1 radial.  Then 2 to 3
steps at a right angle to radial 0 to 2 (which is 45 degrees), etc.  The
distance 0 to 2 is sqrt(2), the distance 0 to 3 is sqrt(3), and in general
r(N) = sqrt(N) since each step is a right triangle with radius(N+1)^2 =
S<radius(N)^2 + 1>.  The resulting shape is very close to an Archimedean
spiral with successive loops increasing in radius by pi = 3.14159 or
thereabouts each time.

X,Y positions returned are fractional and each integer N position is exactly
1 away from the previous.  Fractional N values give positions on the
straight line between the integer points.  (An analytic continuation for a
rounded curve between points is possible, but not currently implemented.)

Each loop is just under 2*pi^2 = 19.7392 many N points longer than the
previous.  This means quadratic values 9.8696*k^2 for integer k are an
almost straight line.  Quadratics close to 9.87 (or a square multiple of
that) nearly line up.  For example the 22-polygonal numbers have 10*k^2 and
at low values are nearly straight, but then spiral away.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

The code is currently implemented by adding unit steps in X,Y coordinates,
so it's not particularly fast.  The last X,Y is saved in the object
anticipating successively higher N (not necessarily consecutive), and
previous positions 1000 apart are saved for re-use or to go back to.

=over 4

=item C<$path = Math::PlanePath::TheodorusSpiral-E<gt>new ()>

Create and return a new theodorus spiral object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

C<$n> can be any value C<$n E<gt>= 0> and fractions give positions on the
spiral in between the integer points.

For C<$n < 0> the return is an empty list, it being currently considered
there are no negative points in the spiral.  (The analytic continuation by
Davis would be a possibility, though the resulting "inner spiral" makes
positive and negative points overlap a bit.  A spiral starting at X=-1 would
fit in between the positive points.)

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x,$y>.  Each integer N
is considered the centre of a circle of diameter 1 and an C<$x,$y> within
that circle returns N.

The unit steps of the spiral means those unit circles don't overlap, but the
loops are 3.14 apart so there's gaps in between.  If C<$x,$y> is not within
one of the unit circles then the return is C<undef>.

=item C<$n = $path-E<gt>figure ()>

Return "circle".

=back

=head1 FORMULAS

=head2 X,Y to N

For a given X,Y the radius r=hypot(X,Y) determines the N position as N=r^2.
An N point up to 0.5 away radially might above cover X,Y, so the range of N
to consider is

    Nlo = (r-.5)^2
    Nhi = (r+.5)^2

A simple search through those N's checking for which, if any, covers X,Y is
then done.  The number of N's there is Nhi-Nlo = 2*r+1 which is about 1/3 of
a loop around the spiral (2*r/2*pi*r ~= 1/3).  Actually 0.51 is used to
guard against floating point round-off, which is then about 4*.51 = 2.04*r.

The angle of the X,Y position determines which part of the spiral is
intersected, but using that doesn't seem particularly easy.  The angle for a
given N is an arctan sum and don't yet have a good closed-form for that to
invert, or some Newton's method, or whatever.

=head2 Rectangle to N Range

For C<rect_to_n_range()> the corner furthest from the origin determines the
high N.  For that corner

    rhi=hypot(xhi,yhi)
    Nhi = (rhi+.5)^2

The extra .5 is since a unit circle figure centred as much as .5 further out
might intersect the xhi,yhi.  The worst case for this estimate is when Nhi
doesn't intersect the xhi,yhi corner but is just before it,
counter-clockwise.  It's then a full revolution bigger than it need be
(depending where the other corners fall).

Similarly for the corner nearest the origin,

    rlo = hypot(xlo,ylo)
    Nlo = (rlo-.5)^2, or 0 if origin covered by rectangle

The worst case is when this Nlo doesn't intersect the xlo,ylo corner but is
just after it counter-clockwise, so Nlo is a full revolution smaller than it
need be (depending where the other corners fall).

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::ArchimedeanChords>,
L<Math::PlanePath::SacksSpiral>,
L<Math::PlanePath::MultipleRings>

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
