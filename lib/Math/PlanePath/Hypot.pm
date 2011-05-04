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


package Math::PlanePath::Hypot;
use 5.004;
use strict;
use List::Util qw(min max);
use Math::Libm 'hypot';
use POSIX 'floor';

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 25;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;


# A000328 Number of points of norm <= n^2 in square lattice.
# 1, 5, 13, 29, 49, 81, 113, 149, 197, 253, 317, 377, 441, 529, 613, 709, 797
#
# a(n) = 1 + 4 * sum(j=0, n^2 / 4,    n^2 / (4*j+1) - n^2 / (4*j+3) )


my @n_to_x = (undef, 0);
my @n_to_y = (undef, 0);
my @hypot_to_n = (1);
my @y_next_x = (1, 1);
my @y_next_hypot = (1, 2);

sub _extend {
  ### _extend() n: scalar(@n_to_x)

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

  if ($y[-1] == $#y_next_x) {
    my $y = scalar(@y_next_x);
    $y_next_x[$y] = $y;
    $y_next_hypot[$y] = 2*$y*$y;
    ### assert: $y_next_hypot[$y] == $y**2 + $y_next_x[$y]**2
  }

  my @x = map {
    my $x = $y_next_x[$_]++;
    $y_next_hypot[$_] += 2*$x+1;
    ### assert: $y_next_hypot[$_] == $_**2 + $y_next_x[$_]**2
    $x
  } @y;
  ### $hypot
  ### base octant: join(' ',map{"$x[$_],$y[$_]"} 0 .. $#x)

  {
    my @base_x = @x;
    my @base_y = @y;
    unless ($y[0]) { # no transpose of x,0
      shift @base_x;
      shift @base_y;
    }
    if ($x[-1] == $y[-1]) { # no transpose of x,x
      pop @base_x;
      pop @base_y;
    }
    push @x, reverse @base_y;
    push @y, reverse @base_x;
  }
  ### with transpose q1: join(' ',map{"$x[$_],$y[$_]"} 0 .. $#x)

  {
    my @base_y = @y;
    push @y, @x;
    push @x, map {-$_} @base_y;
  }
  ### with rotate q2: join(' ',map{"$x[$_],$y[$_]"} 0 .. $#x)

  push @x, map {-$_} @x;
  push @y, map {-$_} @y;

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

  if ($n < 1
      || $n-1 == $n) {  # infinity
    return;
  }

  if ($n != int($n)) {
    my $frac = $n;
    $n = int($n);
    $frac -= $n;
    my ($x1, $y1) = $self->n_to_xy($n);
    my ($x2, $y2) = $self->n_to_xy($n+1);
    return ($x2*$frac + $x1*(1-$frac),
            $y2*$frac + $y1*(1-$frac));
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

  my $hypot = $x*$x + $y*$y;
  if ($hypot-1 == $hypot) {
    ### infinity
    return undef;
  }

  while ($hypot > $#hypot_to_n) {
    _extend();
  }
  my $n = $hypot_to_n[$hypot];
  for (;;) {
    if ($x == $n_to_x[$n] && $y == $n_to_y[$n]) {
      return $n;
    }
    $n++;

    if ($n_to_x[$n]**2 + $n_to_y[$n]**2 != $hypot) {
      ### oops, hypot_to_n no good ...
      return undef;
    }
  }

  # if ($x < 0 || $y < 0) {
  #   return undef;
  # }
  # my $h = $x*$x + $y*$y;
  #
  # while ($y_next_x[$y] <= $x) {
  #   _extend();
  # }
  # return $xy_to_n{"$x,$y"};
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = abs (floor($x1 + 0.5));
  $y1 = abs (floor($y1 + 0.5));
  $x2 = abs (floor($x2 + 0.5));
  $y2 = abs (floor($y2 + 0.5));

  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }

  # circle area pi*r^2, with r^2 = $x2**2 + $y2**2
  return (1, int (3.2 * (($x2+1)**2 + ($y2+1)**2)));
}

1;
__END__

=for stopwords Ryde Math-PlanePath ie HypotOctant hypot

=head1 NAME

Math::PlanePath::Hypot -- points in order of hypotenuse distance

=head1 SYNOPSIS

 use Math::PlanePath::Hypot;
 my $path = Math::PlanePath::Hypot->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path visits integer points X,Y in order of their distance from the
origin 0,0, or anti-clockwise from the X axis among those of equal distance,

                    84  73  83                         5
            74  64  52  47  51  63  72                 4
        75  59  40  32  27  31  39  58  71             3
        65  41  23  16  11  15  22  38  62             2
    85  53  33  17   7   3   6  14  30  50  82         1
    76  48  28  12   4   1   2  10  26  46  70    <- Y=0
    86  54  34  18   8   5   9  21  37  57  89        -1
        66  42  24  19  13  20  25  45  69            -2
        77  60  43  35  29  36  44  61  81            -3
            78  67  55  49  56  68  80                -4
                    87  79  88                        -5

                         ^
    -5  -4  -3  -2  -1  X=0  1   2   3   4   5

For example N=58 is at X=4,Y=-1 is sqrt(4*4+1*1) = sqrt(17) from the origin.
The next furthest from the origin is X=3,Y=3 at sqrt(18).

In general the X,Y points are the sums of two squares X^2+Y^2 taken in
increasing order of that hypotenuse, with negative X or Y and swapped Y,X
included.

=head2 Equal Distances

Points with the same distance are taken in anti-clockwise order around from
the X axis.  For example X=3,Y=1 is sqrt(10) from the origin, as are the
swapped X=1,Y=3, and negative X=-1,Y=3 etc in other quadrants, for a total 8
points N=30 to N=37 all the same distance.

When one of X or Y is 0 there's no negative, so just four negations like
N=10 to 13 points X=2,Y=0 through X=0,Y=-2.  Or on the diagonal X==Y there's
no swap, so just four like N=22 to N=25 points X=3,Y=3 through X=3,Y=-3.

There can be more than one way for the same distance to arise.
A Pythagorean triple like 3^2 + 4^2 == 5^2 has 8 points from the 3,4 plus 4
points from the 5,0 giving a total 12 points N=70 to N=81.  Other
combinations like 20^2 + 15^2 == 24^2 + 7^2 occur, and with more than two
different ways to have the same sum too.

=head2 Multiples of 4

The first point of a given distance from the origin is either on the X axis
or somewhere in the first octant.  The row Y=1 just above the axis is always
first from X>=2 onwards, and similarly further rows for big enough X.

Since there's always a multiple of 4 many points with the same distance, the
first point has N=4*k+2, and similarly on the negative X side N=4*j.  If you
plot the prime numbers on the path then those even number N's (composites)
are just above the X axis, and on and just below the negative X axis.

=head2 Circle Lattice

Gauss's circle lattice problem asks how many integer X,Y points there are
within a circle of radius R.

The points on the X axis N=2,10,26,46, etc are the first for which
X^2+Y^2==R^2 (integer X==R), so N-1 there is the number of points strictly
inside, ie. X^2+Y^2 E<lt> R^2 (Sloane's A051132 C<http://oeis.org/A051132>).

The last point satisfying X^2+Y^2==R^2 is either in the octant just below
the X axis, or is on the negative Y axis.  Those N's are the number of
points X^2+Y^2E<lt>=R^2, Sloane's A000328.

When that A000328 is plotted on the path a straight line can be seen in the
fourth quadrant extending down just above the diagonal.  It arises from
multiples of the Pythagorean 3^2 + 4^2, first X=4,Y=-3, then X=8,Y=-6, etc
X=4*k,Y=-3*k.  Sometimes the multiple is not the last among those of that
5*k radius though, so there's gaps in the line.  For example 20,-15 is not
the last since 24,-7 is also 25 away from the origin.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::Hypot-E<gt>new ()>

Create and return a new hypot path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n E<lt> 1> the return is an empty list, it being considered the first
point at X=0,Y=0 is N=1.

Currently it's unspecified what happens if C<$n> is not an integer.
Successive points are a fair way apart, so it may not make much sense to say
give an X,Y position in between the integer C<$n>.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x,$y>.  Each integer N is
considered the centre of a unit square and an C<$x,$y> within that square
returns N.

=back

=head1 FORMULAS

The calculations are not particularly efficient currently.  Private arrays
are built similar to what's described for HypotOctant, but with replication
for negative and swapped X,Y.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::HypotOctant>,
L<Math::PlanePath::PixelRings>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Math-PlanePath is Copyright 2011 Kevin Ryde

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



# Quadrant style ...
#
#      9      73  75  79  83  85
#      8      58  62  64  67  71  81  ...
#      7      45  48  52  54  61  69  78  86
#      6      35  37  39  43  50  56  65  77  88
#      5      26  28  30  33  41  47  55  68  80
#      4      17  19  22  25  31  40  49  60  70  84
#      3      11  13  15  20  24  32  42  53  66  82
#      2       6   8   9  14  21  29  38  51  63  76
#      1       3   4   7  12  18  27  36  46  59  74
#     Y=0      1   2   5  10  16  23  34  44  57  72
# 
#             X=0  1   2   3   4   5   6   7   8   9  ...
# 
# For example N=37 is at X=1,Y=6 which is sqrt(1*1+6*6) = sqrt(37) from the
# origin.  The next closest to the origin is X=6,Y=2 at sqrt(40).  In general
# it's the sums of two squares X^2+Y^2 taken in order from smallest to biggest.
# 
# Points X,Y and swapped Y,X are the same distance from the origin.  The one
# with bigger X is taken first, then the swapped Y,X (as long as X!=Y).  For
# example N=21 is X=4,Y=2 and N=22 is X=2,Y=4.
