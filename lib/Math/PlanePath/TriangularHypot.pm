# Copyright 2011, 2012 Kevin Ryde

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


# math-image  --path=TriangularHypot

# A034017 - loeschian primatives xx+xy+yy, primes 3k+1 and a factor of 3
#           which is when x^2-x+1 mod n has a solution
#
# A092572 - all x^2+3*y^2
# A158937 - all x^2+3*y^2 with repetitions x>0,y>0
# A092573 - number of such solutions
#
# A092574 - x^2+3*y^2 with gcd(x,y)=1
# A092575 - number of such gcd(x,y)=1
#
# A092572 - 6n+1 primes
# A055664 - norms of Eisenstein-Jacobi primes
# A008458 - hex coordination sequence
#
# A014201 - x*x+x*y+y*y solutions excluding 0,0



#                          [27] [28] [31]
#                          [12] [13] [16] [21] [28]
#                 [7]  [4]  [3]  [4]  [7] [12] [19] [28]
# [25] [16]  [9]  [4]  [1]  [0]  [1]  [4]  [9] [16] [25] [36]
#                 [7]  [4]  [3]  [4]  [7]
#                          [12]
#                          [27]



package Math::PlanePath::TriangularHypot;
use 5.004;
use strict;
use Carp;

use vars '$VERSION', '@ISA';
$VERSION = 79;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant parameter_info_array =>
  [ { name            => 'points',
      share_type      => 'points_eoa',
      type            => 'enum',
      default         => 'even',
      choices         => ['even','odd','all'],
      choices_display => ['Even','Odd','All'],
      description     => 'Which X,Y points visit, either X+Y even, or X+Y odd, or all points.',
    },
  ];

sub new {
  ### TriangularHypot new() ...
  my $self = shift->SUPER::new(@_);
  my $points = ($self->{'points'} ||= 'even');

  if ($points eq 'all') {
    $self->{'n_to_x'} = [undef, 0];
    $self->{'n_to_y'} = [undef, 0];
    $self->{'hypot_to_n'} = [1];
    $self->{'y_next_x'} = [1-1];
    $self->{'y_next_hypot'} = [3*0**2 + 1**2];
    $self->{'x_inc'} = 1;
    $self->{'x_inc_factor'} = 2;  # ((x+1)^2 - x^2) = 2*x+1
    $self->{'x_inc_squared'} = 1;
    $self->{'opposite_parity'} = -1;

  } elsif ($points eq 'even') {
    $self->{'n_to_x'} = [undef, 0];
    $self->{'n_to_y'} = [undef, 0];
    $self->{'hypot_to_n'} = [1];
    $self->{'y_next_x'} = [2-2];
    $self->{'y_next_hypot'} = [3*0**2 + 2**2];
    $self->{'x_inc'} = 2;
    $self->{'x_inc_factor'} = 4;  # ((x+2)^2 - x^2) = 4*x+4
    $self->{'x_inc_squared'} = 4;
    $self->{'opposite_parity'} = 1;

  } elsif ($points eq 'odd') {
    $self->{'n_to_x'} = [undef];
    $self->{'n_to_y'} = [undef];
    $self->{'hypot_to_n'} = [undef];
    $self->{'y_next_x'} = [1-2];
    $self->{'y_next_hypot'} = [1];
    $self->{'x_inc'} = 2;
    $self->{'x_inc_factor'} = 4;
    $self->{'x_inc_squared'} = 4;
    $self->{'opposite_parity'} = 0;

  } else {
    croak "Unrecognised points option: ", $points;
  }

  ### $self
  ### assert: $self->{'y_next_hypot'}->[0] == (3 * 0**2 + ($self->{'y_next_x'}->[0]+$self->{'x_inc'})**2)

  return $self;
}

sub _extend {
  my ($self) = @_;
  ### _extend() ...

  my $n_to_x       = $self->{'n_to_x'};
  my $n_to_y       = $self->{'n_to_y'};
  my $hypot_to_n   = $self->{'hypot_to_n'};
  my $y_next_x     = $self->{'y_next_x'};
  my $y_next_hypot = $self->{'y_next_hypot'};

  # set @y to the Y with the smallest $y_next_hypot->[$y], and if there's some
  # Y's with equal smallest hypot then all those Y's in ascending order
  ### $y_next_x
  ### $y_next_hypot
  my @y = (0);
  my $hypot = $y_next_hypot->[0];
  for (my $i = 1; $i < @$y_next_x; $i++) {
    if ($hypot == $y_next_hypot->[$i]) {
      push @y, $i;
    } elsif ($hypot > $y_next_hypot->[$i]) {
      @y = ($i);
      $hypot = $y_next_hypot->[$i];
    }
  }

  # if the endmost of the @$y_next_x, @y_next_hypot arrays are used then
  # extend them by one
  if ($y[-1] == $#$y_next_x) {
    my $y = scalar(@$y_next_x);
    if ($self->{'points'} eq 'even') {
      # h = (3 * $y**2 + $x**2)
      #   = (3 * $y**2 + ($3*y)**2)
      #   = (3*$y*$y + 9*$y*$y)
      #   = (12*$y*$y)
      $y_next_x->[$y] = 3*$y - $self->{'x_inc'};      # X=3*Y, so X-2=3*Y-2
      $y_next_hypot->[$y] = 12*$y*$y;
    } elsif ($self->{'points'} eq 'odd') {
      my $odd = ! ($y%2);
      $y_next_x->[$y] = $odd - $self->{'x_inc'};
      $y_next_hypot->[$y] = 3*$y*$y + $odd;
    } else { # points eq 'all'
      $y_next_x->[$y] = - $self->{'x_inc'};      # X=0, so X-1=0
      $y_next_hypot->[$y] = 3*$y*$y;
    }

    ### taking y: $y[-1]
    ### so grow y: $y
    ### new y_next_x: $y_next_x->[$y]+$self->{'x_inc'}
    ### new y_next_hypot: $y_next_hypot->[$y]
    ### assert: ($self->{'points'} ne 'even' || (($y ^ ($y_next_x->[$y]+$self->{'x_inc'})) & 1) == 0)
    ### assert: $y_next_hypot->[$y] == (3 * $y**2 + ($y_next_x->[$y]+$self->{'x_inc'})**2)
  }

  # @x is the $y_next_x->[$y] for each of the @y smallests, and step those
  # selected elements next X and hypot for that new X,Y
  my @x = map {
    ### assert: (3 * $_**2 + ($y_next_x->[$_]+$self->{'x_inc'})**2) == $y_next_hypot->[$_]

    my $x = ($y_next_x->[$_] += $self->{'x_inc'});
    $y_next_hypot->[$_]
      += $self->{'x_inc_factor'}*$x + $self->{'x_inc_squared'};

    ### y _: $_
    ### y_next_x (adj inc): $y_next_x->[$_]+$self->{'x_inc'}
    ### y_next_hypot[]: $y_next_hypot->[$_]
    ### assert: $y_next_hypot->[$_] == (3 * $_**2 + ($y_next_x->[$_]+$self->{'x_inc'})**2)

    $x
  } @y;
  ### $hypot

  my $p2;
  if ($self->{'points'} eq 'even') {
    ### base twelvth: join(' ',map{"$x[$_],$y[$_]"} 0 .. $#x)
    my $p1 = scalar(@y);
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
    $#x = $#y = ($p1+scalar(@base_x))*6-1;  # pre-extend arrays
    for (my $i = $#base_x; $i >= 0; $i--) {
      $x[$p1]   = ($base_x[$i] + 3*$base_y[$i]) / 2;
      $y[$p1++] = ($base_x[$i] - $base_y[$i]) / 2;
    }
    ### with mirror: join(' ',map{"$x[$_],$y[$_]"} 0 .. $p1-1)

    $p2 = 2*$p1;
    foreach my $i (0 .. $p1-1) {
      $x[$p1]   = ($x[$i] - 3*$y[$i])/2;   # rotate +60
      $y[$p1++] = ($x[$i] + $y[$i])/2;

      $x[$p2]   = ($x[$i] + 3*$y[$i])/-2;  # rotate +120
      $y[$p2++] = ($x[$i] - $y[$i])/2;
    }
    ### with rotates 60,120: join(' ',map{"$x[$_],$y[$_]"} 0 .. $p2-1)

  } else {
    ### base quarter: join(' ',map{"$x[$_],$y[$_]"} 0 .. $#x)
    my $p1 = $#x;
    push @y, reverse @y;
    push @x, map {-$_} reverse @x;
    if ($x[$p1] == 0) {
      splice @x, $p1, 1;  # don't duplicate X=0 in mirror
      splice @y, $p1, 1;
    }
    if ($y[-1] == 0) {
      pop @y;  # omit final Y=0 ready for rotate
      pop @x;
    }
    $p2 = scalar(@y);
    ### with mirror +90: join(' ',map{"$x[$_],$y[$_]"} 0 .. $p2-1)
  }

  foreach my $i (0 .. $p2-1) {
    $x[$p2]   = -$x[$i];        # rotate 180
    $y[$p2++] = -$y[$i];
  }
  ### with rotate 180: join(' ',map{"$x[$_],$y[$_]"} 0 .. $#x)

  ### store: join(' ',map{"$x[$_],$y[$_]"} 0 .. $#x)
  ### at n: scalar(@$n_to_x)
  ### hypot_to_n: "h=$hypot n=".scalar(@$n_to_x)
  $hypot_to_n->[$hypot] = scalar(@$n_to_x);
  push @$n_to_x, @x;
  push @$n_to_y, @y;

  # ### hypot_to_n now: join(' ',map {defined($hypot_to_n->[$_]) && "h=$_,n=$hypot_to_n->[$_]"} 0 .. $#hypot_to_n)
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

  my $n_to_x = $self->{'n_to_x'};
  while ($n > $#$n_to_x) {
    _extend($self);
  }
  return ($n_to_x->[$n], $self->{'n_to_y'}->[$n]);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### TriangularHypot xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);

  if ((($x%2) ^ ($y%2)) == $self->{'opposite_parity'}) {
    ### XY wrong parity, no point ...
    return undef;
  }

  my $hypot = 3*$y*$y + $x*$x;
  if (_is_infinite($hypot)) {
    # avoid infinite loop extending @hypot_to_n
    return undef;
  }
  ### $hypot

  my $hypot_to_n = $self->{'hypot_to_n'};
  my $n_to_x     = $self->{'n_to_x'};
  my $n_to_y     = $self->{'n_to_y'};

  while ($hypot > $#$hypot_to_n) {
    _extend($self);
  }
  my $n = $hypot_to_n->[$hypot];
  for (;;) {
    if ($x == $n_to_x->[$n] && $y == $n_to_y->[$n]) {
      return $n;
    }
    $n += 1;

    if ($n_to_x->[$n]**2 + 3*$n_to_y->[$n]**2 != $hypot) {
      ### oops, hypot_to_n no good ...
      return undef;
    }
  }
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = abs (_round_nearest ($x1));
  $y1 = abs (_round_nearest ($y1));
  $x2 = abs (_round_nearest ($x2));
  $y2 = abs (_round_nearest ($y2));

  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }

  # xyradius r^2 = 1/4 * $x2**2 + 3/4 * $y2**2
  # (r+1/2)^2 = r^2 + r + 1/4
  # circlearea = pi*(r+1/2)^2
  # each hexagon area outradius 1/2 is hexarea = sqrt(27/64)
  my $r2 = $x2*$x2 + 3*$y2*$y2;
  my $n = (3.15 / sqrt(27/64) / 4) * ($r2 + sqrt($r2))
    * (3 - $self->{'x_inc'});  # *2 for odd or even, *1 for all
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
distance from the origin 0,0 and anti-clockwise around from the X axis among
those of equal distance.

=cut

# math-image --all --output=numbers --path=TriangularHypot

=pod

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
L<Math::PlanePath/Triangular Lattice>.  With scaling X/2, Y*sqrt(3)/2 to
give equilateral triangles of side length 1 the distance from X,Y to the
origin is

    dist^2 = (X/2^2 + (Y*sqrt(3)/2)^2
           = (X^2 + 3*Y^2) / 4

For example N=19 at X=2,Y=-2 is sqrt((2**2+3*-2**2)/4) = sqrt(4) from the
origin.  The next smallest after that is X=5,Y=1 at sqrt(7).  The key part
is X^2 + 3*Y^2 as the distance measure to order the points.

=head2 Equal Distances

Points with the same distance are taken in anti-clockwise order around from
the X axis.  For example N=14 at X=4,Y=0 is sqrt(4) from the origin, as are
the rotated X=2,Y=2 and X=-2,Y=2 etc in other sixths, for a total 6 points
N=14 to N=19 all the same distance.

In general there's either 6 or 12 symmetric points so the number of points
of the same distance is always a multiple of 6 or 12.  There are 6 points
when on the six radial lines X=0, X=Y or X=-Y, or on the lines Y=0, X=3*Y or
X=-3*Y which are midway between them.  Then there's 12-way symmetry for
anything else, ie. anything in the twelve slices between those twelve lines.
For example the first 12 equal is N=20 to N=31 all at sqrt(28).

There can also be further ways for the same distance to arise, but the 6-way
or 12-way symmetry means always a multiple of 6 or 12.

=head2 Odd Points

Option C<points =E<gt> "odd"> visits just the odd points, meaning sum X+Y
odd, so X,Y one odd the other even.

=cut

# math-image --path=TriangularHypot,points=odd --output=numbers --expression='i<=70?i:0'

=pod

    points => "odd"

                         69                              5
          66    50    45    44    49    65               4
       58    40    28    25    27    39    57            3
    54    32    20    12    11    19    31    53         2
       36    16     6     3     5    15    35            1
    46    24    10     2     1     9    23    43    <- Y=0
       37    17     7     4     8    18    38           -1
    55    33    21    13    14    22    34    56        -2
       59    41    29    26    30    42    60           -3
          67    51    47    48    52    68              -4
                         70                             -5

                          ^
       -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6

=head2 All Points

Option C<points =E<gt> "all"> visits all integer X,Y points.

=cut

# math-image --path=TriangularHypot,points=all --output=numbers --expression='i<=71?i:0'

=pod

    points => "all"

                64 59 49 44 48 58 63                  3
          69 50 39 30 25 19 24 29 38 47 68            2
          51 35 20 13  8  4  7 12 18 34 46            1
       65 43 31 17  9  3  1  2  6 16 28 42 62    <- Y=0
          52 36 21 14 10  5 11 15 23 37 57           -1
          70 53 40 32 26 22 27 33 41 56 71           -2
                66 60 54 45 55 61 67                 -3

                          ^
       -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::TriangularHypot-E<gt>new ()>

=item C<$path = Math::PlanePath::TriangularHypot-E<gt>new (points =E<gt> $str)>

Create and return a new hypot path object.  The C<points> option can be

    "even"        only points with X+Y even (the default)
    "odd"         only points with X+Y odd
    "all"         all integer X,Y

Create and return a new triangular hypot path object.

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

=head1 OEIS

Entries in Sloane's Online Encyclopedia of Integer Sequences related to this
path include,

    http://oeis.org/A035019

    A003136  norms X^2+3*Y^2 which occur
    A004016  count of points of norm n
    A035019    skipping zero counts
    A088534    counting only in the twelfth 0<=X<=Y

The counts in these sequences are expressed as norm = x^2+x*y+y^2.  That x,y
is related to the "even" X,Y on the path here by a -45 degree rotation,

    x = (Y-X)/2           X = 2*(x+y)
    y = (X+Y)/2           Y = 2*(y-x)

The norm is then

    norm = x^2+x*y+y^2
         = ((Y-X)/2)^2 + (Y-X)/2 * (X+Y)/2 + ((X+Y)/2)^2
         = (X^2 + 3*Y^2) / 4

X^2+3*Y^2 is the dist^2 described above for equilateral triangles of unit
side.  The factor of /4 doesn't affect the count of how many points.

Sequences A092572, A092573 and A158937 are based on x^2+3*y^2 but they're
not applicable to this TriangularHypot since they're all integer x,y whereas
the path here is every second point, ie. x,y both odd or both even.  The
latter condition gives the x^2+x*y+y^2 form.

=cut

# ((Y-X)/2)^2 + (Y-X)/2 * (X+Y)/2 + ((X+Y)/2)^2
#  = YY-2XY+XX + YY-XX + XX+2XY+YY   / 4
#  = 3YY + XX

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::Hypot>,
L<Math::PlanePath::HypotOctant>,
L<Math::PlanePath::PixelRings>,
L<Math::PlanePath::HexSpiral>

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
