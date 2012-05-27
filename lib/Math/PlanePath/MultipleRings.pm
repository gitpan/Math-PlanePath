# Copyright 2010, 2011, 2012 Kevin Ryde

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



# math-image --path=MultipleRings --lines
# math-image --path=MultipleRings,step=1 --all --output=numbers --size=80x50
#
# math-image --wx --path=MultipleRings,ring_shape=polygon,step=5  --scale=50 --figure=ring --all

package Math::PlanePath::MultipleRings;
use 5.004;
use strict;

# Math::Trig has asin_real() too, but it just runs the blob of code in
# Math::Complex -- prefer libm
use Math::Libm 'asin', 'hypot';

use vars '$VERSION', '@ISA';
$VERSION = 75;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_min = \&Math::PlanePath::_min;
*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;

use Math::PlanePath::SacksSpiral; # for _bigfloat()

# uncomment this to run the ### lines
#use Smart::Comments;


use constant figure => 'circle';
use constant n_frac_discontinuity => 0;

use constant parameter_info_array =>
  [{ name        => 'step',
     share_key   => 'step_6',
     type        => 'integer',
     minimum     => 0,
     default     => 6,
     width       => 3,
     description => 'How much longer each ring is than the preceding.',
   },

   { name        => 'ring_shape',
     type        => 'enum',
     default     => 'circle',
     choices     => ['circle','polygon'],
     choices_display => ['Circle','Polygon'],
     description     => 'The shape of each ring, either a circle or a polygon of "step" many sides.',
   },
  ];


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

# v1.02 for leading underscore
# this used in PlanePathDelta.pm too
use constant 1.02 _PI => 4 * atan2(1,1);  # similar to Math::Complex

sub new {
  my $class = shift;
  ### MultipleRings new(): @_
  my $self = $class->SUPER::new (@_);

  my $ring_shape = ($self->{'ring_shape'} ||= 'circle');

  my $step = $self->{'step'};
  $step = $self->{'step'} = (! defined $step ? 6  # default
                             : $step < 0     ? 0  # minimum
                             : $step);

  if ($ring_shape eq 'polygon') {
    $self->{'base_r'} = 0.5/sin(_PI/$step);
  } else {
    # circles
    if ($step <= 6) {
      $self->{'base_r'} = ($step == 6 ? 1
                           : $step > 1 && 0.5/sin(_PI/$step)) - 1;
    }
  }
  ### base r: $self->{'base_r'}

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
#   = [ 1 + 2*sqrt(2n + 1/4) ] / 2
#   = [ 1 + sqrt(8n + 1) ] / 2
#
# (d+1)d/2 - d(d-1)/2
#     = [ (d^2 + d) - (d^2-d) ] / 2
#     = [ d^2 + d - d^2 + d ] / 2
#     = 2d/2 = d
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
  ### MultipleRings n_to_xy(): "$n"
  ### step: $self->{'step'}

  # "$n<1" separate test from decrement so as to warn on undef
  # don't have anything sensible for infinity, and _PI / infinity would
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

  my $d = int((1 + sqrt(int(8*$n/$step) + 1)) / 2);

  ### d frac: (1 + sqrt(int(8*$n) + 1)) / 2
  ### d int: "$d"
  ### base: ($d*($d-1)/2).''
  ### next base: (($d+1)*$d/2).''
  ### assert: $n >= ($d*($d-1)/2)
  ### assert: $n < ($step * ($d+1) * $d / 2)

  $n -= $d*($d-1)/2 * $step;
  ### n remainder: "$n"
  ### assert: $n >= 0
  ### assert: $n < $d*$step

  my $base_r = $self->{'base_r'};
  if ($self->{'ring_shape'} eq 'polygon' && $step >= 3) {
    my $r = ($step >= 6 ? $base_r*$d
             # : $step >= 4 ? $d+$base_r-1
             : ($d-1)/cos(_PI/$step) + $base_r);
    $n /= $d;
    my $side = int ($n);
    $n -= $side;

    my $theta = $side*2*_PI/$step;
    my $fx = $r * cos($theta);
    my $fy = $r * sin($theta);
    $theta = ($side+1)*2*_PI/$step;
    my $tx = $r * cos($theta);
    my $ty = $r * sin($theta);

    ### $side
    ### $r
    ### from: "$fx, $fy"
    ### to: "$tx, $ty"

    return ($fx + $n*($tx-$fx),
            $fy + $n*($ty-$fy));
  }

  my $pi = _PI;
  if (ref $n) {
    if ($n->isa('Math::BigInt')) {
      $n = Math::PlanePath::SacksSpiral::_bigfloat()->new($n);
    } elsif ($n->isa('Math::BigRat')) {
      $n = $n->as_float;
    }
    if ($n->isa('Math::BigFloat')) {
      $d = Math::BigFloat->new($d);
      $pi = Math::BigFloat->bpi;
      $base_r = Math::BigFloat->new($base_r);
    }
  }

  # && $d != 0 # watch out for overflow making d==0 ??
  #
  my $d_step = $d*$step;
  my $r = ($step > 6
           ? 0.5 / sin($pi / $d_step)
           : $base_r + $d);
  ### r: "$r"

  my $n2 = 2*$n;

  if ($n2 == int($n2)) {
    if (($n2 % $d_step) == 0) {
      ### theta=0 or theta=pi, exactly on X axis ...
      return ($n ? -$r : $r,  # n remainder 0 means +ve X axis, non-zero -ve
              0);
    }
    if (($d_step % 2) == 0) {
      my $n2sub = $n2 - $d_step/2;
      if (($n2sub % $d_step) == 0) {
        ### theta=pi/2 or theta=3pi/2, exactly on Y axis ...
        return (0,
                $n2sub ? -$r : $r);
      }
    }
  }

  my $theta = $n2 * $pi / $d_step;

  ### theta frac: (($n - $d*($d-1)/2)/$d).''
  ### theta: "$theta"

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
    ### avoid div-by-zero in 1/(2*$r) ...
    return $r;
  }
  ### $r

  my $step = $self->{'step'};
  if ($self->{'ring_shape'} eq 'polygon' && $step >= 6) {
    my $step = $self->{'step'};
    my $a = _xy_to_angle_frac($x,$y);
    $a -= int($a/$step) * $step;
    return $r / ($self->{'base_r'} * cos($a*2*_PI));
  }

  if ($step > 6) {
    ### d frac by asin: _PI / ($step * asin(1/(2*$r)))
    return _PI / ($step * asin(1/(2*$r)));
  } else {
    # $step <= 6
    ### d frac by base: $r - $self->{'base_r'}
    return $r - $self->{'base_r'};
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### MultipleRings xy_to_n(): "$x, $y  step=$self->{'step'}"

  my $n;
  my $step;
  if (($step = $self->{'step'})) {
    # formula above with r=hypot(x,y)
    my $d = int (0.5 + _xy_to_d ($self, $x, $y));

    my $theta_frac = _xy_to_angle_frac($x,$y);
    ### assert: 0 <= $theta_frac && $theta_frac < 1

    my $theta_n = int (0.5 + $theta_frac * $d*$step);
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
    $n = int ($x + 1.5);
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
# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MultipleRings rect_to_n_range(): "$x1,$y1, $x2,$y2  step=$self->{'step'}"

  my $zero = ($x1<0) != ($x2<0) || ($y1<0) != ($y2<0);

  $x1 = abs($x1);
  $x2 = abs($x2);
  $y1 = abs($y1);
  $y2 = abs($y2);

  # if x1,x2 pos and neg then 0 is covered and it's the minimum
  # ENHANCE-ME: might be able to be a little tighter on $d_lo
  my $d_lo = ($zero
              ? 1
              : _max (1, -2 + int (_xy_to_d ($self,
                                             _min($x1,$x2),
                                             _min($y1,$y2)))));
  my $d_hi = 1 + int (_xy_to_d ($self,
                                _max($x1,$x2),
                                _max($y1,$y2)));
  ### $d_lo
  ### $d_hi
  if ((my $step = $self->{'step'})) {
    # start of ring is N= 0.5*$d*($d-1) * $step + 1
    ### n_lo: 0.5*$d_lo*($d_lo-1) * $step + 1
    ### n_hi: 0.5*$d_hi*($d_hi+1) * $step
    return ($d_lo*($d_lo-1)/2 * $step + 1,
            $d_hi*($d_hi+1)/2 * $step);
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
  my $frac = atan2($y,$x) * (1 / (2 * _PI));
  return ($frac + ($frac < 0));
}


1;
__END__

=for stopwords Ryde HexSpiral DiamondSpiral SquareSpiral PyramidRows MultipleRings Math-PlanePath Pentagonals

=head1 NAME

Math::PlanePath::MultipleRings -- rings of multiples

=head1 SYNOPSIS

 use Math::PlanePath::MultipleRings;
 my $path = Math::PlanePath::MultipleRings->new (step => 6);
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path puts points on concentric rings.  Each ring is "step" many points
more than the previous, and the first is also "step" so a successively
increasing multiple of that many points.  For example with the default
step==6,

                24  23
             25        22
                  10
          26   11     9  21  ...

        27  12   3  2   8  20  38

       28  13   4    1   7  19  37        <- Y=0

        29  14   5  6  18  36

          30   15    17  35
                  16
             31        24
                32  33

                  ^
                 X=0

X,Y positions returned are fractional.  The innermost ring like the
1,2,...,6 above has points 1 unit apart.  Subsequent rings are either packed
similarly or spread out to ensure the X axis points like 1,7,19,37 above are
1 unit apart.  The latter happens for step <= 6.  For step >= 7 the rings
are big enough to separate those X points.

The layout is similar to the spiral paths of corresponding step.  For
example step=6 is like the HexSpiral, but rounded out to circles instead of
a hexagonal grid.  Similarly step=4 the DiamondSpiral or step=8 the
SquareSpiral.

The step parameter is similar to the PyramidRows with the rows stretched
around circles, though PyramidRows starts from a 1-wide initial row and
increases by the step, whereas for MultipleRings there's no initial.

The starting radial 1,7,19,37 etc on the X axis for step=6 is
S<6*d*(d-1)/2 + 1>, counting the innermost ring as d=1.  In general it's a
multiple of the triangular numbers, plus 1,

    Nstart = step*d*(d-1)/2 + 1

Straight line radials further around have arise from adding multiples of d,
so for example in step=6 shown above the line N=3,11,25,etc is
S<Nstart + 2*d>.  Multiples of d bigger than the step give lines which are
in between the base ones extending out from the innermost ring.

=head2 Ring Shape

Option C<ring_shape =E<gt> 'polygon'> puts the points on concentric polygons
of "step" many sides, so successive polygons have 1 more point on each side
than the previous polygon.  For example step=4 gives 4-sided polygons,
ie. diamonds,

    ring_shape=>'polygon', step=>4

                  16
                /    \
             17    7   15    
           /    /     \   \   
        18    8    2    6   14 
      /    /    /     \    \   \ 
    19   9    3         1    5   13 
      \     \   \    /     /   /
        20   10    4   12   24
           \     \    /   /
             21   11   23
                \    /
                  22

The polygons are scaled to keep points 1 unit apart.  For stepE<gt>=6 this
means 1 unit apart sideways.  step=6 is in fact a honeycomb grid where each
points is 1 away its six neighbours.

For step=3, 4 and 5 the polygon sides are 1 apart radially, as measured in
the centre of each side.  This makes points a little more than 1 apart.
Squeezing them up to make the closest points exactly 1 apart is possible,
but may require iterating a square root for each ring.  step=3 squeezed down
would in fact become a variable spacing with four close then one wider.

For step=2 and step=1 in the current code the default circle shape is used.
Should that change?  Is there a polygon style with 2 sides or 1 side?

The polygon layout is only a little different from a circle, but it lines up
points on the sides and that might help show a structure for some sets of
points plotted on the path.

=head2 Step 3 Pentagonals

For step=3 the pentagonal numbers 1,5,12,22,etc, P(k) = (3k-1)*k/2, are a
radial going up to the left, and the second pentagonal numbers 2,7,15,26,
S(k) = (3k+1)*k/2 are a radial going down to the left, respectively 1/3 and
2/3 the way around the circles.

As described in L<Math::PlanePath::PyramidRows/Step 3 Pentagonals>, those
P(k) and preceding P(k)-1, P(k)-2, and S(k) and preceding S(k)-1, S(k)-2 are
all composites, so plotting the primes on a step=3 MultipleRings has two
radial gaps where there's no primes.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::MultipleRings-E<gt>new (step =E<gt> $integer)>

=item C<$path = Math::PlanePath::MultipleRings-E<gt>new (step =E<gt> $integer, ring_shape =E<gt> $str)>

Create and return a new path object.

The C<step> parameter controls how many points are added in each circle.  It
defaults to 6 which is an arbitrary choice and the suggestion is to always
pass in a desired count.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

C<$n> can be any value C<$n E<gt>= 1> and fractions give positions on the
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

=head1 FORMULAS

=head2 N to X,Y - Circle

Points on the rings are spaced so they're at least 1 unit apart.  The
innermost ring has "step" many points which means the vertices of a polygon
with "step" many sides each of length 1.  The "base_r" radius to such a
vertex is

      base_r     ___---*
           ___---      |
     ___--- alpha      | 1/2 = half the polygon side
    o------------------+

    alpha = 2pi/step * 1/2      # "step" many sides
    sin(alpha) = (1/2) / base_r

    base_r = 0.5 / sin(pi/step)

Subsequent rings are then either 1 bigger to keep the points on the X axis 1
unit apart, or they're at the vertices of a polygon with d*step many sides
so as to keep the points 1 apart sideways.  Reckoning the innermost ring as
d=1 (at base_r), the second as d=2, etc, this means

    r = max /  base_r + (d-1)
            \  0.5 / sin(pi/(d*step))

The sin() polygon case is the maximum whenever stepE<gt>6, so

    if step<=6   r = base_r + (d-1)
    if step>6    r = 0.5 / sin(pi/(d*step))

The angle theta around the ring for N is determined by how much N exceeds
the Nstart of that ring (Nstart as described above).  d can be found by a
square root.  (N-1)/step in the formula effectively converts the start into
triangular number style.

    d = floor (1 + sqrt(8*(N-1)/step + 1)) / 2

Then the remainder into the ring is

    Nrem = N - Nstart
    theta = 2pi * Nrem / (d*step)

    X = r * cos(theta)
    Y = r * sin(theta)

For a few cases X or Y are exact integers.  Special case code for these
cases ensures floating point rounding of pi doesn't give small offsets from
integers.

If step=6 then base_r=1 exactly since the innermost ring is a little hexagon
in this case.  This means the points on the X axis are all integers
X=1,2,3,etc.

       P-----P
      /   1 / \ 1  <-- innermost points 1 apart
     /     /   \
    P     o-----P   <--  base_r = 1
     \      1  /
      \       /
       P-----P

If theta=pi, which is 2*Nrem==d*step, then the point is on the negative X
axis.  Returning Y=0 exactly for that avoids sin(pi) generally being some
small non-zero due to rounding.

If theta=pi/2 or theta=3pi/2, which is 4*Nrem==d*step or 4*Nrem==3*d*step,
then N is on the positive or negative Y axis (respectively).  Returning X=0
exactly avoids cos(pi/2) or cos(3pi/2) generally being some small non-zero.

Points on the negative X axis points occur when the step is even.  Points on
the Y axis points occur when the step is a multiple of 4.

If theta=pi/4, 3pi/4, 5pi/4 or 7pi/4, which is 8*Nrem==d*step, 3*d*step,
5*d*step or 7*d*step then the points are on the 45-degree lines X=Y or X=-Y.
The current code doesn't try to ensure X==Y in these cases.  The values are
not integers and floating point rounding might make them them unequal due to
sin(pi/4)!=cos(pi/4).

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SacksSpiral>,
L<Math::PlanePath::TheodorusSpiral>,
L<Math::PlanePath::PixelRings>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2010, 2011, 2012 Kevin Ryde

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
