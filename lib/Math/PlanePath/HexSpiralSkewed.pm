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


package Math::PlanePath::HexSpiralSkewed;
use 5.004;
use strict;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 90;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use Math::PlanePath::Base::Generic
  'round_nearest';

# uncomment this to run the ### lines
#use Devel::Comments;


use Math::PlanePath::SquareSpiral;
*parameter_info_array = \&Math::PlanePath::SquareSpiral::parameter_info_array;

sub new {
  my $self = shift->SUPER::new (@_);
  $self->{'wider'} ||= 0;  # default
  return $self;
}

# Same as HexSpiral, but diagonal down and to the left is the downwards
# vertical at x=-$w_left.

sub n_to_xy {
  my ($self, $n) = @_;
  ### HexSpiralSkewed n_to_xy(): $n

  if ($n < 1) { return; }
  my $w = $self->{'wider'};
  my $w_right = int($w/2);
  my $w_left = $w - $w_right;
  #### $w
  #### $w_left
  #### $w_right
  if ($n <= $w+2) {
    #### centre horizontal
    return ($n-1 - $w_left,  # n=1 at $w_left
            0);
  }

  my $d = int((sqrt(int(3*$n) + ($w+2)*$w - 2) - 1 - $w) / 3);
  #### d frac: (sqrt(int(3*$n) + ($w+2)*$w - 2) - 1 - $w) / 3
  #### $d
  $n -= (3*$d + 2 + 2*$w)*$d + 1;
  #### remainder: $n

  $d = $d + 1; # no warnings if $d==inf
  if ($n <= $d+$w) {
    #### bottom horizontal
    return ($n - $w_left,
            -$d+1);
  }
  $n -= $d+$w;
  if ($n <= $d-1) {
    #### right lower vertical, being 1 shorter: $n
    return ($d + $w_right,
            $n - $d + 1);
  }
  $n -= $d-1;
  if ($n <= $d) {
    #### right upper diagonal: $n
    return (-$n + $d + $w_right,
            $n);
  }
  $n -= $d;
  if ($n <= $d+$w) {
    #### top horizontal
    return (-$n + $w_right,
            $d);
  }
  $n -= $d+$w;
  if ($n <= $d) {
    #### left upper vertical
    return (-$d - $w_left,
            -$n + $d);
  }
  #### left lower diagonal
  $n -= $d;
  return ($n - $d - $w_left,
          -$n);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### xy_to_n(): "$x, $y"

  $x = round_nearest ($x);
  $y = round_nearest ($y);

  my $w = $self->{'wider'};
  my $w_right = int($w/2);
  my $w_left = $w - $w_right;

  if ($y > 0) {
    $x -= $w_right;
    if ($x < -$y-$w) {
      ### left upper vertical
      my $d = -$x - $w;
      ### $d
      ### base: (3*$d + 1 + 2*$w)*$d + 1
      return ((3*$d + 1 + 2*$w)*$d + 1
              - $y);
    } else {
      my $d = $y + max($x,0);
      ### right upper diagonal and top horizontal
      ### $d
      ### base: (3*$d - 1 + 2*$w)*$d + 1 - $w
      return ((3*$d - 1 + 2*$w)*$d + 1 - $w
              - $x);
    }

  } else {
    # $y < 0
    $x += $w_left;
    if ($x-$w <= -$y) {
      my $d = -$y + max(-$x,0);
      ### left lower diagonal and bottom horizontal
      ### $d
      ### base: (3*$d + 2 + 2*$w)*$d + 1
      return ((3*$d + 2 + 2*$w)*$d + 1
              + $x);
    } else {
      ### right lower vertical
      my $d = $x - $w;
      ### $d
      ### base: (3*$d - 2 + 2*$w)*$d + 1 - $w
      return ((3*$d - 2 + 2*$w)*$d + 1 - $w
              + $y);
    }
  }
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### HexSpiralSkewed rect_to_n_range(): $x1,$y1, $x2,$y2

  $x1 = round_nearest ($x1);
  $y1 = round_nearest ($y1);
  $x2 = round_nearest ($x2);
  $y2 = round_nearest ($y2);

  my $w = $self->{'wider'};
  my $w_right = int($w/2);
  my $w_left = $w - $w_right;

  my $d = 0;
  foreach my $x ($x1, $x2) {
    $x += $w_left;
    if ($x >= $w) {
      $x -= $w;
    }
    foreach my $y ($y1, $y2) {
      $d = max ($d,
                (($y > 0) == ($x > 0)
                 ? abs($x) + abs($y)      # top right or bottom left diagonals
                 : max(abs($x),abs($y)))); # top left or bottom right squares
    }
  }
  $d += 1;

  # diagonal downwards bottom right being the end of a revolution
  # s=0
  # s=1  n=7
  # s=2  n=19
  # s=3  n=37
  # s=4  n=61
  # n = 3*$d*$d + 3*$d + 1
  #
  ### gives: "sum $d is " . (3*$d*$d + 3*$d + 1)

  # ENHANCE-ME: find actual minimum if rect doesn't cover 0,0
  return (1,
          (3*$d + 3 + 2*$self->{'wider'})*$d + 1);
}

1;
__END__

=for stopwords HexSpiralSkewed HexSpiral SquareSpiral DiamondSpiral PlanePath Ryde Math-PlanePath OEIS

=head1 NAME

Math::PlanePath::HexSpiralSkewed -- integer points around a skewed hexagonal spiral

=head1 SYNOPSIS

 use Math::PlanePath::HexSpiralSkewed;
 my $path = Math::PlanePath::HexSpiralSkewed->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes a hexagonal spiral with points skewed so as to fit a square
grid and fully cover the plane.

    13--12--11   ...              2
     |         \   \
    14   4---3  10  23            1
     |   |     \   \   \
    15   5   1---2   9  22    <- Y=0
      \   \          |   | 
        16   6---7---8  21       -1
          \              |    
            17--18--19--20       -2

     ^   ^   ^   ^   ^   ^ 
    -2  -1  X=0  1   2   3  ...

The kinds of N=3*k^2 numbers which fall on straight lines in the plain
HexSpiral also fall on straight lines when skewed.  See
L<Math::PlanePath::HexSpiral> for notes on this.

=head2 Wider

An optional C<wider> parameter makes the path wider, stretched along the top
and bottom horizontals.  For example

    $path = Math::PlanePath::HexSpiralSkewed->new (wider => 2);

gives

    21--20--19--18--17                    2
     |                 \    
    22   8---7---6---5  16                1
     |   |             \   \    
    23   9   1---2---3---4  15        <- Y=0
      \   \                  |     
       24   10--11--12--13--14  ...      -1
          \                      |    
            25--26--27--28--29--30       -2

     ^   ^   ^   ^   ^   ^   ^   ^ 
    -4  -3  -2  -1  X=0  1   2   3  ...

The centre horizontal from N=1 is extended by C<wider> many further places,
then the path loops around that shape.  The starting point 1 is shifted to
the left by wider/2 places (rounded up to an integer) to keep the spiral
centred on the origin X=0,Y=0.

Each loop is still 6 longer than the previous, since the widening is
basically a constant amount added into each loop.  The result is the same as
the plain HexSpiral of the same widening too.  The effect looks better in
the plain HexSpiral.

=head1 Corners

HexSpiralSkewed is similar to the SquareSpiral but cuts off the top-right
and bottom-left corners so that each loop is 6 steps longer than the
previous, whereas for the SquareSpiral it's 8.  See
L<Math::PlanePath::SquareSpiral/Corners> for other corner cutting.

=head2 Skew

The skewed path is the same shape as the plain HexSpiral, but fits more
points on a square grid.  The skew pushes the top horizontal to the left, as
shown by the following parts, and the bottom horizontal is similarly skewed
but to the right.

    HexSpiralSkewed               HexSpiral

    13--12--11                   13--12--11       
     |         \                /          \      
    14          10            14            10    
     |             \         /                \  
    15               9     15                   9

    -2  -1  X=0  1   2     -4 -3 -2  X=0  2  3  4

In general the coordinates can be converted each way by

    plain X,Y -> skewed (X-Y)/2, Y

    skewed X,Y -> plain 2*X+Y, Y

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::HexSpiralSkewed-E<gt>new ()>

=item C<$path = Math::PlanePath::HexSpiralSkewed-E<gt>new (wider =E<gt> $w)>

Create and return a new hexagon spiral object.  An optional C<wider>
parameter widens the spiral path, it defaults to 0 which is no widening.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n < 1> the return is an empty list, it being considered the path
starts at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each
point in the path as a square of side 1.

=back

=head1 OEIS

Entries in Sloane's Online Encyclopedia of Integer Sequences related to
this path include

    http://oeis.org/A056105  (etc)

    A056105    N on X axis, 3n^2-2n+1
    A056106    N on Y axis, 3n^2-n+1
    A056107    N on North-West diagonal, 3n^2+1
    A056108    N on X negative axis, 3n^2+n+1
    A056109    N on Y negative axis, 3n^2+2n+1
    A003215    N on South-East diagonal, centred hexagonals

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::HexSpiral>,
L<Math::PlanePath::HeptSpiralSkewed>,
L<Math::PlanePath::PentSpiralSkewed>,
L<Math::PlanePath::DiamondSpiral>

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
