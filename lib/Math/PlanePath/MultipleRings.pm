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


package Math::PlanePath::MultipleRings;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX 'floor';
use Math::Libm 'M_PI', 'asin', 'hypot';

use vars '$VERSION', '@ISA';
$VERSION = 44;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant figure => 'circle';

use constant parameter_info_array =>
  [{ name      => 'step',
     share_key => 'rings_step',
     type      => 'integer',
     minimum   => 0,
     default   => 6,
     width     => 3,
   }];


# Electricity transmission cable in sixes, with one at centre ?
#    7 poppy
#    19 hyacinth
#    37 marigold
#    61 cowslip
#    127 bluebonnet


# An n-gon of points many vertices has each angle
#     alpha = 2*pi/points
# The radius r to a vertex, using a line perpendicular to the line segment
#     sin(alpha/2) = (1/2)/r
#     r = 0.5 / sin(pi/points)
# And with points = d*step, starting from d=1
#     r = 0.5 / sin(pi/(d*step))
#
# step==0 is a straight line y==0 x=0,1,2,..., anything else whole plane
sub x_negative {
  my ($self) = @_;
  return ($self->{'step'} > 0);
}
*y_negative = \&x_negative;

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
# radius
#    step > 6     1 / (2 * sin(pi / ($d*$step))
#    step <= 6    Rbase + d
#
# usual polygon formula R = a / 2*sin(pi/n)
# cf inner radius  r = a / 2*tan(pi/n)
# along chord

sub n_to_xy {
  my ($self, $n) = @_;
  ### MultipleRings n_to_xy(): $n
  ### step: $self->{'step'}

  # "$n<1" separate test from decrement so as to warn on undef
  # don't have anything sensible for infinity, and M_PI / infinity would
  # throw a div by zero
  if ($n < 1) { return; }
  if (_is_infinite($n)) { return ($n,$n); }
  $n -= 1;

  ### decremented n: $n
  my $step = $self->{'step'};
  if (! $step) {
    # step==0 goes along X axis
    return ($n, 0);
  }
  $n /= $step;
  ### divided n: $n

  my $d = int(0.5 + sqrt(2*$n + 0.25));
  ### d frac: 0.5 + sqrt(2*$n + 0.25)
  ### d int: $d

  my $r = ($step > 6
           # && $d != 0 # watch out for overflow making d==0
           ? 0.5 / sin(M_PI() / ($d*$step))
           : $d + $self->{'base_r'});
  ### $r
  my $theta = ($n - 0.5*$d*($d-1))/$d * (2*M_PI());
  ### base: 0.5*$d*($d-1)
  ### remainder: ($n - 0.5*$d*($d-1))
  ### theta frac: ($n - 0.5*$d*($d-1))/$d

  return ($r * cos($theta),
          $r * sin($theta));
}

# From above
#     r = 0.5 / sin(pi/(d*step))
#
#     sin(pi/(d*step)) = 0.5/r
#     pi/(d*step) = asin(1/(2*r))
#     1/d * pi/step = asin(1/(2*r))
#     d = pi/(step*asin(1/(2*r)))
#
# r1 = 0.5 / sin(pi/(d*step))
# r2 = 0.5 / sin(pi/((d+1)*step))
# r2 - r1 = 0.5 / sin(pi/(d*step)) - 0.5 / sin(pi/((d+1)*step))
# r2-r1 >= 1 when step>=7 ?

sub _xy_to_d {
  my ($self, $x, $y) = @_;

  my $r = hypot ($x, $y);
  if ($r < 0.5) {
    ### r smaller than 0.5 ring, treat as d=1
    # 1/(2*r) could be div-by-zero
    # or 1/(2*r) > 1 would be asin()==-nan
    return 1;
  }
  if (_is_infinite($r)) {
    ### infinity avoid div-by-zero in 1/(2*$r)
    return $r;
  }
  ### $r
  if ((my $step = $self->{'step'}) > 6) {
    ### d frac by asin: M_PI() / ($step * asin(1/(2*$r)))
    return M_PI() / ($step * asin(1/(2*$r)));
  }
  # $step <= 6
  ### d frac by base: $r - $self->{'base_r'}
  return $r - $self->{'base_r'};
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### MultipleRings xy_to_n(): "$x, $y  step=$self->{'step'}"

  my $n;
  my $step;
  if (($step = $self->{'step'})) {
    # formula above with r=hypot(x,y)
    my $d = floor (0.5 + _xy_to_d ($self, $x, $y));

    my $theta_frac = _xy_to_angle_frac($x,$y);
    ### assert: 0 <= $theta_frac && $theta_frac < 1

    my $theta_n = floor (0.5 + $theta_frac * $d*$step);
    if ($theta_n >= $d*$step) { $theta_n = 0; }

    $n = 1 + $theta_n + $step * 0.5*$d*($d-1);
    ### $d
    ### d base: 0.5*$d*($d-1)
    ### d base M: $step * 0.5*$d*($d-1)
    ### $theta_frac
    ### theta offset: $theta_frac*$d
    ### $theta_n
    ### theta_n frac: $theta_frac * $d*$step
    ### $n
  } else {
    # step==0
    $n = floor ($x + 0.5) + 1;
  }

  ### trial n: $n
  my ($nx, $ny);
  if ((($nx, $ny) = $self->n_to_xy($n))
      && hypot($x-$nx, $y-$ny) <= 0.5) {
    return $n;
  } else {
    return undef;
  }
}

# ENHANCE-ME: step>=3 small rectangles around 0,0 don't cover any pixels
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MultipleRings rect_to_n_range(): "$x1,$y1, $x2,$y2  step=$self->{'step'}"

  my $zero = ($x1<0) != ($x2<0) || ($y1<0) != ($y2<0);
  foreach ($x1,$x2,$y1,$y2) {
    $_ = abs($_);
  }
  # if x1,x2 pos and neg then 0 is covered and it's the minimum
  # ENHANCE-ME: might be able to be a little tighter on $d_lo
  my $d_lo = ($zero
              ? 1
              : max (1, -2 + int (_xy_to_d ($self,
                                            min($x1,$x2),
                                            min($y1,$y2)))));
  my $d_hi = 1 + int (_xy_to_d ($self,
                                max($x1,$x2),
                                max($y1,$y2)));
  ### $d_lo
  ### $d_hi
  if ((my $step = $self->{'step'})) {
    # start of ring is N= 0.5*$d*($d-1) * $step + 1
    ### n_lo: 0.5*$d_lo*($d_lo-1) * $step + 1
    ### n_hi: 0.5*$d_hi*($d_hi+1) * $step
    return (0.5*$d_lo*($d_lo-1) * $step + 1,
            0.5*$d_hi*($d_hi+1) * $step);
  } else {
    # $step == 0
    return ($d_lo, $d_hi);
  }
}

#------------------------------------------------------------------------------
# generic

# perlfunc.pod warns atan2(0,0) is implementation dependent.
# The c99 spec is atan2(+/-0, -0) returns +/-pi, which would come out 0.5 here
# Prefer 0 for any +/-0,+/-0.
sub _xy_to_angle_frac {
  my ($x, $y) = @_;
  if ($x == 0 && $y == 0) {
    return 0;
  }
  my $frac = atan2($y,$x) * (1 / (2 * M_PI()));
  return ($frac + ($frac < 0));
}


1;
__END__

=for stopwords Ryde HexSpiral DiamondSpiral SquareSpiral PyramidRows MultipleRings Math-PlanePath

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

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MultipleRings-E<gt>new (step =E<gt> $integer)>

Create and return a new path object.

The C<step> parameter controls how many points are added in each circle.  It
defaults to 6 which is an arbitrary choice and the suggestion is to always
pass in a desired count.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

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
L<Math::PlanePath::TheodorusSpiral>,
L<Math::PlanePath::PixelRings>

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
