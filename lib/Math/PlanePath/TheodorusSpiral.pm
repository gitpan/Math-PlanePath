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


package Math::PlanePath::TheodorusSpiral;
use 5.004;
use strict;
use warnings;
use List::Util 'max';
use Math::Libm 'hypot';
use Math::Trig 'pi';

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 7;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments '###';

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

  if ($n < 0) {
    return;
  }
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
  my $n_lo = int (max (0, $r - .6) ** 2);
  my $n_hi = int (($r + .6) ** 2);
  ### $n_lo
  ### $n_hi

  foreach my $n ($n_lo .. $n_hi) {
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

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  my $r = 2 + int (hypot (max(abs($x1),abs($x2)),
                          max(abs($y1),abs($y2))));
  return (0,
          $r*$r);
}

1;
__END__

=for stopwords Theodorus Ryde Math-PlanePath Archimedean

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
              7       0  1                 54    <- y=0
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
   -6 -5 -4 -3 -2 -1 x=0 1  2  3  4  5  6  7

Each step is a unit distance at right angles to the previous radial.  So for
example,

         3        -- y=1+1/sqrt(2)
          \
           \
             2       y=1
             |
             |
       0-----1    <- y=0

       ^
      x=0   x=1

1 to 2 is a unit step at right angles to the 0 to 1 radial.  Then 2 to 3
steps at a right angle to radial 0 to 2 (menaing 45 degrees up to the left),
etc.  The distance 0 to 2 is sqrt(2), the distance 0 to 3 is sqrt(3), and in
general r(N) = sqrt(N) since each step is a right triangle, r(N+1)^2 =
S<r(N)^2 + 1>.  The resulting shape is very close to an Archimedean spiral
with successive loops increasing in radius by pi (3.14159) or thereabouts
each time.

X,Y positions returned are fractional and each integer N position is exactly
1 away from the previous.  Fractional N gives positions on the straight line
between the integer points.

Each loop is just under 2*pi^2 (19.7392) longer than the previous.  This
means quadratic points 9.8696*k^2 for integer k form an almost straight
line.  Quadratics close to 9.87 or a square multiple of it nearly line up.
For example the 22-polygonal numbers have 10*k^2 and at low values nearly
line up but then spiral away.

=head1 FUNCTIONS

The code is currently implemented by adding up unit steps in X,Y
coordinates, so it's not particularly fast.  The last X,Y is saved in the
object anticipating successively higher N (not necessarily consecutive),
plus past positions 1000 apart ready for re-use or to go back to.

=over 4

=item C<$path = Math::PlanePath::TheodorusSpiral-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> on the path.

C<$n> can be any value C<$n E<gt>= 0> and fractions give positions on the
spiral in between the integer points.

For C<$n < 0> the return is an empty list, it being currently considered
there are no negative points in the spiral.  (The analytic continuation by
Davis would be a possibility, though the resulting "inner spiral" makes
positive and negative points overlap a bit.  A spiral starting at x=-1 would
fit in between the positive points.)

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x,$y>.  Each integer N
is considered the centre of a circle of diameter 1 and an C<$x,$y> within
that circle returns N.

The unit steps of the spiral means those unit circles don't overlap, but the
loops are 3.14 apart so there's gaps in between.  If C<$x,$y> is not within
one of the unit circles then the return is C<undef>.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SacksSpiral>,
L<Math::PlanePath::MultipleRings>

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