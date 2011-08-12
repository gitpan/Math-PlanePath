# Copyright 2011 Kevin Ryde

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


# math-image --all --output=numbers --path=TriangularHypot
# math-image  --path=TriangularHypot

# A003136 - Loeschian hypot norms of hex lattice

# A092572 - all x^2+3*y^2
# A158937 - all x^2+3*y^2 with repetitions x>0,y>0
# A092573 - number of such solutions

# A092574 - x^2+3*y^2 with gcd(x,y)=1
# A092575 - number of such gcd(x,y)=1

# A092572 - 6n+1 primes
# A055664 - norms of Eisenstein-Jacobi primes
# A008458 - hex coordination sequence


package Math::PlanePath::TriangularHypot;
use 5.004;
use strict;
use List::Util qw(min max);
use Math::Libm 'hypot';
use POSIX 'floor';

use vars '$VERSION', '@ISA';
$VERSION = 39;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;

# uncomment this to run the ### lines
#use Smart::Comments;


my @n_to_x = (undef, 0);
my @n_to_y = (undef, 0);
my @hypot_to_n = (1);
my @y_next_x = (2-2);
my @y_next_hypot = ((3*0**2 + 2**2) / 4);

### assert: $y_next_hypot[0] == (3 * 0**2 + ($y_next_x[0]+2)**2)/4
### assert: $y_next_hypot[0] == 1

sub _extend {
  ### _extend() n: scalar(@n_to_x)

  # set @y to the Y with the smallest $y_next_hypot[$y], and if there's some
  # Y's with equal smallest hypot then all those Y's in ascending order
  ### @y_next_x
  ### @y_next_hypot
  my @y = (0);
  my $hypot = $y_next_hypot[0];
  for (my $i = 1; $i < @y_next_x; $i++) {
    if ($hypot == $y_next_hypot[$i]) {
      push @y, $i;
    } elsif ($hypot > $y_next_hypot[$i]) {
      @y = ($i);
      $hypot = $y_next_hypot[$i]
    }
  }

  # if the endmost of the @y_next_x, @y_next_hypot arrays are used then
  # extend them by one
  if ($y[-1] == $#y_next_x) {
    my $y = scalar(@y_next_x);
    $y_next_x[$y] = 3*$y-2;      # X=3*Y, so X-2=3*Y-2
    # h = (3 * $y**2 + $x**2) / 4
    #   = (3 * $y**2 + ($3*y)**2) / 4
    #   = (3*$y*$y + 9*$y*$y) / 4
    #   = (12*$y*$y)/4
    #   = 3*$y*$y
    $y_next_hypot[$y] = 3*$y*$y;
    ### taking y: $y[-1]
    ### so new y: $y
    ### new y_next_x: $y_next_x[$y]+2
    ### new y_next_hypot: $y_next_hypot[$y]
    ### assert: (($y ^ ($y_next_x[$y]+2)) & 1) == 0
    ### assert: $y_next_hypot[$y] == (3 * $y**2 + ($y_next_x[$y]+2)**2)/4
  }

  # @x is the $y_next_x[$y] for each of the @y smallests, and step those
  # selected elements next X and hypot for that new X,Y
  my @x = map {
    my $x = ($y_next_x[$_] += 2);
    $y_next_hypot[$_] += $x+1;   # ((x+2)^2 - x^2)/4 = x+1
    # ### $_
    # ### $x
    # ### y_next_x[]: $y_next_x[$_]
    # ### y_next_hypot[]: $y_next_hypot[$_]
    # ### hypot expr: 0.75 * $_**2 + (0.5 * $y_next_x[$_])**2
    ### assert: $y_next_hypot[$_] == (3 * $_**2 + ($y_next_x[$_]+2)**2)/4
    $x
  } @y;
  ### $hypot
  ### base sixth: join(' ',map{"$x[$_],$y[$_]"} 0 .. $#x)

  my $p1 = scalar(@y);
  {
    my @base_x = @x;
    my @base_y = @y;
    unless ($y[0]) { # no mirror of x,0
      shift @base_x;
      shift @base_y;
    }
    if ($x[-1] == 3*$y[-1]) { # no mirror of x=3*y line
      pop @base_x;
      pop @base_y;
    }
    $#x = $#y = ($p1+scalar(@base_x))*6-1;
    for (my $i = $#base_x; $i >= 0; $i--) {
      $x[$p1]   = ($base_x[$i] + 3*$base_y[$i]) / 2;
      $y[$p1++] = ($base_x[$i] - $base_y[$i]) / 2;
    }
  }
  ### with mirror: join(' ',map{"$x[$_],$y[$_]"} 0 .. $p1-1)

  my $p2 = 2*$p1;
  foreach my $i (0 .. $p1-1) {
    $x[$p1]   = ($x[$i] - 3*$y[$i])/2;   # rotate +60
    $y[$p1++] = ($x[$i] + $y[$i])/2;

    $x[$p2]   = ($x[$i] + 3*$y[$i])/-2;  # rotate +120
    $y[$p2++] = ($x[$i] - $y[$i])/2;
  }
  ### with rotates 60,120: join(' ',map{"$x[$_],$y[$_]"} 0 .. $p2-1)

  foreach my $i (0 .. $p2-1) {
    $x[$p2]   = -$x[$i];        # rotate 180
    $y[$p2++] = -$y[$i];
  }
  ### with rotate 180: join(' ',map{"$x[$_],$y[$_]"} 0 .. $#x)

  ### store: join(' ',map{"$x[$_],$y[$_]"} 0 .. $#x)
  ### at n: scalar(@n_to_x)
  ### hypot_to_n: "h=$hypot n=".scalar(@n_to_x)
  $hypot_to_n[$hypot] = scalar(@n_to_x);
  push @n_to_x, @x;
  push @n_to_y, @y;

  # ### hypot_to_n now: join(' ',map {defined($hypot_to_n[$_]) && "h=$_,n=$hypot_to_n[$_]"} 0 .. $#hypot_to_n)


  # my $x = $y_next_x[0];
  #
  # $x = $y_next_x[$y];
  # $n_to_x[$next_n] = $x;
  # $n_to_y[$next_n] = $y;
  # $xy_to_n{"$x,$y"} = $next_n++;
  #
  # $y_next_x[$y]++;
  # $y_next_hypot[$y] = $y*$y + $y_next_x[$y]**2;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### Hypot n_to_xy(): $n

  if ($n < 1) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  {
    my $int = int($n);
    if ($n != $int) {
      my $frac = $n - $int;  # inherit possible BigFloat/BigRat
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
  }

  while ($n > $#n_to_x) {
    _extend();
  }

  return ($n_to_x[$n], $n_to_y[$n]);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### Hypot xy_to_n(): "$x, $y"
  ### hypot_to_n last: $#hypot_to_n

  $x = floor($x + 0.5);
  $y = floor($y + 0.5);
  if (($x ^ $y) & 1) {
    ### diff parity...
    return undef;
  }

  my $hypot4 = 3*$y*$y + $x*$x;
  if (_is_infinite($hypot4)) {
    # avoid infinite loop extending @hypot_to_n
    return undef;
  }
  ### assert: ($hypot4 % 4) == 0
  my $hypot = $hypot4/4;
  ### $hypot4
  ### $hypot

  while ($hypot > $#hypot_to_n) {
    _extend();
  }
  my $n = $hypot_to_n[$hypot];
  for (;;) {
    if ($x == $n_to_x[$n] && $y == $n_to_y[$n]) {
      return $n;
    }
    $n++;

    if ($n_to_x[$n]**2 + 3*$n_to_y[$n]**2 != $hypot4) {
      ### oops, hypot_to_n no good ...
      return undef;
    }
  }
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = abs (floor($x1 + 0.5));
  $y1 = abs (floor($y1 + 0.5));
  $x2 = abs (floor($x2 + 0.5));
  $y2 = abs (floor($y2 + 0.5));

  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }

  # xyradius r^2 = 1/4 * $x2**2 + 3/4 * $y2**2
  # (r+1/2)^2 = r^2 + r + 1/4
  # circlearea = pi*(r+1/2)^2
  # each hexagon area outradius 1/2 is hexarea = sqrt(27/64)
  my $r2 = $x2*$x2 + 3*$y2*$y2;
  my $n = (3.15 / sqrt(27/64) / 4) * ($r2 + sqrt($r2));
  return (1, 1 + int($n));
}

1;
__END__

=for stopwords Ryde Math-PlanePath hypot HexSpiral ie

=head1 NAME

Math::PlanePath::TriangularHypot -- points of triangular lattice in order of hypotenuse distance

=head1 SYNOPSIS

 use Math::PlanePath::TriangularHypot;
 my $path = Math::PlanePath::TriangularHypot->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path visits X,Y points on a triangular "A2" lattice in order of their
distance from the origin 0,0, and anti-clockwise around from the X axis
among those of equal distance,


             58    47    39    46    57                 4

          48    34    23    22    33    45              3

       40    24    16     9    15    21    38           2

    49    25    10     4     3     8    20    44        1

       35    17     5     1     2    14    32      <- Y=0

    50    26    11     6     7    13    31    55       -1

       41    27    18    12    19    30    43          -2

          51    36    28    29    37    54             -3

             60    52    42    53    61                -4

                          ^
    -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7

The lattice is put on a square X,Y grid using every second point per
L<Math::PlanePath/Triangular Lattice>.  With a scaling X/2, Y*sqrt(3)/2 to
give equilateral triangles with side length 1 the X,Y distance from the
origin is

    dist^2 = (X/2^2 + (Y*sqrt(3)/2)^2  =  (X^2 + 3*Y^2) / 4

For example N=19 at X=2,Y=-2 is sqrt((2**2+3*-2**2)/4) = sqrt(4) from the
origin.  The next smallest after that is X=5,Y=1 at sqrt(7).  The key part
is X^2 + 3*Y^2 as the distance measure to order the points.

=head2 Equal Distances

Points with the same distance are taken in anti-clockwise order around from
the X axis.  For example N=14 at X=4,Y=0 is sqrt(4) from the origin, as are
the rotated X=2,Y=2 and X=--2,Y=2 etc in other sixths, for a total 6 points
N=14 to N=19 all the same distance.

In general there's either 6 or 12 symmetric points.  6 when on the six
radial lines X=0, X=Y or X=-Y.  And 6 also when on the six radial lines Y=0,
X=3*Y or X=-3*Y (these are midway between the first six).  And then 12 for
anything in the twelve slices in between those lines, for example the first
being N=20 through N=31 all at sqrt(28).

There can also be multiple ways for the same distance to arise, but the
6-way or 12-way symmetry means always a multiple of 6 or 12.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::TriangularHypot-E<gt>new ()>

Create and return a new hypot path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n E<lt> 1> the return is an empty list as the first point at X=0,Y=0
is N=1.

Currently it's unspecified what happens if C<$n> is not an integer.
Successive points are a fair way apart, so it may not make much sense to say
give an X,Y position in between the integer C<$n>.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x,$y>.  Each integer N is
considered the centre of a unit square and an C<$x,$y> within that square
returns N.

Only every second square in the plane has an N, being those where X,Y both
odd or both even.  If C<$x,$y> is a position without an N, ie. one of X,Y
odd the other even, then the return is C<undef>.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::Hypot>,
L<Math::PlanePath::HypotOctant>,
L<Math::PlanePath::PixelRings>,
L<Math::PlanePath::HexSpiral>

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
