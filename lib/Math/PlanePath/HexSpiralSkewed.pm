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


package Math::PlanePath::HexSpiralSkewed;
use 5.004;
use strict;
use List::Util qw(max);
use POSIX ();

use vars '$VERSION', '@ISA';
$VERSION = 22;

use Math::PlanePath;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments '###';


sub new {
  my $self = shift->SUPER::new (@_);
  $self->{'wider'} ||= 0;  # default
  return $self;
}

# Same as HexSpiral, but diagonal down and to the left is the downwards
# vertical at x=-$w_left.

sub n_to_xy {
  my ($self, $n) = @_;
  #### n_to_xy: $n
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

  my $d = int((sqrt(3*$n + ($w+2)*$w - 2) - 1 - $w) / 3);
  #### d frac: (sqrt(3*$n + ($w+2)*$w - 2) - 1 - $w) / 3
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
            -$d+1 + $n);
  }
  $n -= $d-1;
  if ($n <= $d) {
    #### right upper diagonal: $n
    return ($d - $n + $w_right,
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
            $d - $n);
  }
  #### left lower diagonal
  $n -= $d;
  return (-$d + $n - $w_left,
          -$n);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### xy_to_n(): "$x, $y"

  $x = POSIX::floor ($x + 0.5);
  $y = POSIX::floor ($y + 0.5);
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

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### HexSpiralSkewed xy_to_n_range(): $x1,$y1, $x2,$y2

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
  $d = int($d) + 1;

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

=for stopwords HexSpiralSkewed HexSpiral SquareSpiral DiamondSpiral PlanePath Ryde Math-PlanePath

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
    15   5   1---2   9  22    <- y=0
      \   \          |   | 
        16   6---7---8  21       -1
          \              |    
            17--18--19--20       -2

     ^   ^   ^   ^   ^   ^ 
    -2  -1  x=0  1   2   3  ...

The sequence is the same as the plain HexSpiral, but this arrangement fits
more points on a square grid.  The skew pushes the top horizontal to the
left, as illustrated by the following parts of the two.  The bottom
horizontal is similarly skewed but to the right.

    HexSpiralSkewed               HexSpiral

    13--12--11                   13--12--11       
     |         \                /          \      
    14          10            14            10    
     |             \         /                \  
    15               9     15                  9

The kinds of 3*k^2 number sequences which fall on straight lines in the
plain HexSpiral also fall on straight lines when skewed.  See
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
    23   9   1---2---3---4  15        <- y=0
      \   \                  |     
       24   10--11--12--13--14  ...      -1
          \                      |    
            25--26--27--28--29--30       -2

     ^   ^   ^   ^   ^   ^   ^   ^ 
    -4  -3  -2  -1  x=0  1   2   3  ...

The centre horizontal 1 to 2 is extended by C<wider> many further places,
then the path loops around that shape.  The starting point 1 is shifted to
the left by wider/2 places (rounded up to an integer) to keep the spiral
centred on the origin x=0,y=0.

Each loop is still 6 longer than the previous, since the widening is
basically a constant amount added into each loop.  The result is the same as
the plain HexSpiral of the same widening too.  The effect looks better in
that plain HexSpiral.

=head1 Corners

HexSpiralSkewed is similar to the SquareSpiral but cuts off the top right
and bottom left corners so that each loop is 6 steps longer than the
previous whereas for the SquareSpiral it's 8.  See
L<Math::PlanePath::SquareSpiral/Corners> for other corner cutting.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::HexSpiralSkewed-E<gt>new ()>

=item C<$path = Math::PlanePath::HexSpiralSkewed-E<gt>new (wider =E<gt> $w)>

Create and return a new hexagon spiral object.  An optional C<wider>
parameter widens the spiral path, it defaults to 0 which is no widening.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> on the path.

For C<$n < 1> the return is an empty list, it being considered the path
starts at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each
point in the path as a square of side 1.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::HexSpiral>,
L<Math::PlanePath::HeptSpiralSkewed>,
L<Math::PlanePath::PentSpiralSkewed>,
L<Math::PlanePath::DiamondSpiral>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Math-PlanePath is Copyright 2010, 2011 Kevin Ryde

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
