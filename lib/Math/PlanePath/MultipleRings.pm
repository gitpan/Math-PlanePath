# Copyright 2010 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.


package Math::PlanePath::MultipleRings;
use 5.004;
use strict;
use warnings;
use List::Util qw(min max);
use POSIX 'floor';
use Math::Libm 'M_PI', 'asin', 'hypot';

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 8;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant figure => 'circle';

# 1/r = 2 * sin(1/2 * 2pi/points)
# points = d*step, from d=1
# r = 1 / (2 * sin(pi/(d*step)))
#   = 0.5 / sin(pi/(d*step))
#
# 2*sin(pi/(d*step)) = 1/r
# sin(pi/(d*step)) = 1/(2*r)
# pi/(d*step) = asin(1/(2*r))
# d*pi/step = asin(1/(2*r))
# 1/d * pi/step = asin(1/(2*r))
# d = pi/(step*asin(1/(2*r)))
#
#
# r1 = 0.5 / sin(pi/(d*step))
# r2 = 0.5 / sin(pi/((d+1)*step))
# r2 - r1 = 0.5 / sin(pi/(d*step)) - 0.5 / sin(pi/((d+1)*step))
# r2-r1 >= 1 when step>=7 ?

# step==0 is a straight line y==0 x=0,1,2,..., anything else whole plane
sub x_negative {
  my ($self) = @_;
  return ($self->{'step'} > 0);
}
sub y_negative {
  my ($self) = @_;
  return ($self->{'step'} > 0);
}

sub new {
  my $class = shift;
  ### MultipleRings new(): @_
  my $self = $class->SUPER::new (@_);

  my $step = $self->{'step'};
  $step = $self->{'step'} = (! defined $step ? 6  # default
                             : $step < 0     ? 0  # minimum
                             : $step);

  if ($step <= 6) {
    $self->{'base_r'} = ($step > 1 && 0.5/sin(M_PI()/$step)) - 1;
    ### base r: $self->{'base_r'}
  }
  return $self;
}

# with N decremented
# d = [ 1, 2, 3, 4,  5 ]
# N = [ 0, 1, 3, 6, 10 ]
#
# N = (1/2 d^2 - 1/2 d)
#   = (1/2*$d**2 - 1/2*$d)
#   = ((0.5*$d - 0.5)*$d)
#   = 0.5*$d*($d-1)
#
# d = 1/2 + sqrt(2 * $n + 1/4)
#   = 0.5 + sqrt(2*$n + 0.25)
#

sub n_to_xy {
  my ($self, $n) = @_;
  ### MultipleRings n_to_xy(): $n
  ### step: $self->{'step'}

  return if --$n < 0;
  ### decremented n: $n
  my $step;
  if (($step = $self->{'step'}) == 0) {
    # step==0 goes along X axis
    return ($n, 0);
  }
  $n /= $step;
  ### divided n: $n

  my $d = int(0.5 + sqrt(2*$n + 0.25));
  my $r = ($step > 6
           ? 0.5 / sin(M_PI() / ($d*$step))
           : $d + $self->{'base_r'});
  ### $d
  ### d frac: 0.5 + sqrt(2*$n + 0.25)
  ### $r
  ### base: 0.5*$d*($d-1)
  ### remainder: ($n - 0.5*$d*($d-1))
  ### theta frac: ($n - 0.5*$d*($d-1))/$d
  my $theta = ($n - 0.5*$d*($d-1))/$d * (2*M_PI());

  return ($r * cos($theta),
          $r * sin($theta));
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### MultipleRings xy_to_n(): "$x, $y"

  my $n;
  my $step;
  if (($step = $self->{'step'}) == 0) {
    $n = floor ($x + 0.5) + 1;
  } else {
    # formula above with r=hypot(x,y)
    my $r = hypot ($x, $y);
    my $d = floor (0.5
                   + ($step > 6
                      ? M_PI() / ($step * asin(1/(2 * $r)))
                      : $r - $self->{'base_r'}));

    my $theta = atan2($y,$x) / (2*M_PI());
    if ($theta < 0) { $theta++; }  # frac 0 <= $theta < 1
    my $theta_n = floor (0.5 + $theta * $d*$step);
    if ($theta_n >= $d*$step) { $theta_n = 0; }

    my $n = 1 + $theta_n + $step * 0.5*$d*($d-1);
    ### $d
    ### d frac asin: M_PI() / ($step * asin(1/(2 * $r)))
    ### d frac base: $r - ($self->{'base_r'}||0)
    ### d base: 0.5*$d*($d-1)
    ### d base M: $step * 0.5*$d*($d-1)
    ### theta frac: $theta
    ### theta offset: $theta*$d
    ### $theta_n
    ### theta_n frac: $theta * $d*$step
    ### $n
  }

  my ($nx, $ny);
  if ((($nx, $ny) = $self->n_to_xy($n))
      && hypot($x-$nx, $y-$ny) <= 0.5) {
    return $n;
  } else {
    return undef;
  }
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  my $step = $self->{'step'};
  my $r = hypot (max(abs($x1),abs($x2)), max(abs($y1),abs($y2)));
  my $d = 1 + int ($step > 6
                   ? M_PI() / ($step * asin(1/(2 * $r)))
                   : $r - $self->{'base_r'});
  return (1,
          ($step == 0
           ? $d
           : 0.5*$d*($d+1) * $step));
}

1;
__END__

=for stopwords Ryde Math-Image

=head1 NAME

Math::PlanePath::MultipleRings -- rings of multiples

=head1 SYNOPSIS

 use Math::PlanePath::MultipleRings;
 my $path = Math::PlanePath::MultipleRings->new (step => 6);
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path puts points on concentric rings.  Each ring is "step" many points
more then the previous, and the first is also "step" so each has a
successively increasing multiple of that many points.  For example with the
default step==6,

                24  23
             25        22
                  10
          26   11     9  21  ...

        27  12   3  2   8  20  38

       28  13   4    1   7  19  37

        29  14   5  6  18  36

          30   15    17  35
                  16
             31        24
                32  33

X,Y positions returned are fractional.  The innermost ring like the
1,2,...,6 above has points 1 unit apart.  Subsequent rings are either packed
similarly or spread out to ensure the X axis points like 1,7,19,37 above are
1 unit apart.  The latter happens for step <= 6 and for step >= 7 the rings
are big enough to separate those X points.

The layout is similar to the spiral paths of corresponding step.  For
example step==6 is like the HexSpiral, only rounded out to circles instead
of a hexagonal grid.  Similarly step==4 the DiamondSpiral or step==8 the
SquareSpiral.

The step parameter is similar to the PyramidRows with the rows stretched
around circles, though PyramidRows starts from a 1-wide initial row and
increases by the step, whereas for MultipleRings there's no initial.

The starting radial 1,7,19,37 etc for step==6 is S<6*k*(k-1)/2 + 1> (for k=1
upwards) and in general it's S<step*k*(k-1)/2 + 1> which is basically a step
multiple of the triangular numbers.  Straight line radials further around
have arise from adding multiples of k, so for example for step==6 above the
line 3,11,25 is S<6*k*(k-1)/2 + 1 + 2*k>.  Multiples of k bigger than the
step give lines in between those of the innermost ring.

=head2 Step 3 Pentagonals

For step==3 the pentagonal numbers 1,5,12,22,etc, P(k) = (3k-1)*k/2, are a
radial going up to the left, and the second pentagonal numbers 2,7,15,26,
S(k) = (3k+1)*k/2 are a radial going down to the left, respectively 1/3 and
2/3 the way around the circles.

As described in L<Math::PlanePath::PyramidRows/Step 3 Pentagonals>, those
numbers and the preceding P(k)-1, P(k)-2, and S(k)-1, S(k)-2 are all
composites, so plotting the primes on a step==3 MultipleRings has these
values as two radial gaps where there's no primes.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::MultipleRings-E<gt>new (step =E<gt> $integer)>

Create and return a new path object.

The C<step> parameter controls how many points are added in each circle.  It
defaults to 6 which is an arbitrary choice and the suggestion is to always
pass in a desired count.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> on the path.

C<$n> can be any value C<$n E<gt>= 0> and fractions give positions on the
rings in between the integer points.  For C<$n < 1> the return is an empty
list since points begin at 1.

Fractional C<$n> currently ends up on the circle arc between the integer
points.  Would straight line chords between them be better, reflecting the
unit spacing of the points?  Neither seems particularly important.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x,$y>.  Each integer N
is considered the centre of a circle of diameter 1 and an C<$x,$y> within
that circle returns N.

The unit spacing of the points means those circles don't overlap, but they
also don't cover the plane and if C<$x,$y> is not within one then the return
is C<undef>.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SacksSpiral>,
L<Math::PlanePath::TheodorusSpiral>

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
