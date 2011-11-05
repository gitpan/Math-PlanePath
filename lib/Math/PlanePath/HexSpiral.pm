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



# Kanga "Number Mosaics" has rotated to
#
#                ...-16---15
#                           \
#                  6----5   14
#                 /      \    \
#                7   1    4   13
#               /   /    /    /
#              8   2----3   12
#               \           /
#                9---10---11
#
#
# Could go pointy end with same loop/step, or point to the right
#                                                  
#                    13--12--11                    
#                   /         |                    
#                 14  4---3  10                    
#                /  /     |   |    
#              15  5  1---2   9    
#                \  \         |    
#                 16  6---7---8    
#                   \             |
#                    17--18--19--20
#


package Math::PlanePath::HexSpiral;
use 5.004;
use strict;
use List::Util qw(max);

use vars '$VERSION', '@ISA';
$VERSION = 53;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments '###';

use Math::PlanePath::SquareSpiral;
*parameter_info_array = \&Math::PlanePath::SquareSpiral::parameter_info_array;


sub new {
  my $self = shift->SUPER::new (@_);
  $self->{'wider'} ||= 0;  # default
  return $self;
}

# wider==0
# diagonal down and to the left
#   d = [ 0,  1,  2,  3 ]
#   N = [ 1,  6, 17,  34 ]
#   N = (3*$d**2 + 2*$d + 1)
#   d = -1/3 + sqrt(1/3 * $n + -2/9)
#     = (-1 + sqrt(3*$n - 2)) / 3
#
# wider==1
# diagonal down and to the left
#   d = [ 0,  1,  2,  3 ]
#   N = [ 1,  8, 21,  40 ]
#   N = (3*$d**2 + 4*$d + 1)
#   d = -2/3 + sqrt(1/3 * $n + 1/9)
#     = (-2 + sqrt(3*$n + 1)) / 3
#
# wider==2
# diagonal down and to the left
#   d = [ 0, 1,  2,  3,  4 ]
#   N = [ 1, 10, 25, 46, 73 ]
#   N = (3*$d**2 + 6*$d + 1)
#   d = -1 + sqrt(1/3 * $n + 2/3)
#     = (-3 + sqrt(3*$n + 6)) / 3
#
# N = 3*$d*$d + (2+2*$w)*$d + 1
#   = (3*$d + 2 + 2*$w)*$d + 1
# d = (-1-w + sqrt(3*$n + ($w+2)*$w - 2)) / 3
#   = (sqrt(3*$n + ($w+2)*$w - 2) -1-w) / 3

sub n_to_xy {
  my ($self, $n) = @_;
  #### n_to_xy: "$n   wider=$self->{'wider'}"
  if ($n < 1) { return; }
  my $w = $self->{'wider'};
  if ($n == 1) {
    #### centre horizontal: $n-1-$w
    return ($n-1-$w, 0);   # n=1 at -$w
  }

  my $d = int((sqrt(int(3*$n) + ($w+2)*$w - 2) - 1 - $w) / 3);
  #### d frac: (sqrt(int(3*$n) + ($w+2)*$w - 2) - 1 - $w) / 3
  #### $d

  $n -= (3*$d + 2 + 2*$w)*$d + 1;
  #### remainder: $n

  $d = $d + 1; # no warnings if $d==inf
  if ($n <= $d+$w) {
    #### bottom horizontal
    $d = -$d + 1;
    return (2*$n + $d - $w,
            $d);
  }
  $n -= $d+$w;
  if ($n <= $d-1) {
    #### right lower diagonal, being 1 shorter: $n
    return ($n + $d + 1 + $w,
            $n - $d + 1);
  }
  $n -= $d-1;
  if ($n <= $d) {
    #### right upper diagonal: $n
    return (-$n + 2*$d + $w,
            $n);
  }
  $n -= $d;
  if ($n <= $d+$w) {
    #### top horizontal
    return (-2*$n + $d + $w,
            $d);
  }
  $n -= $d+$w;
  if ($n <= $d) {
    #### left upper diagonal
    return (-$n - $d - $w,
            -$n + $d );
  }
  #### left lower diagonal
  $n -= $d;
  return ($n - 2*$d - $w,
          -$n);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  my $w = $self->{'wider'};
  if (($x ^ $y ^ $w) & 1) {
    return undef;  # nothing on odd squares
  }

  my $ay = abs($y);
  my $ax = abs($x) - $w;
  if ($ax > $ay) {
    my $d = ($ax + $ay)/2;  # x+y is even

    if ($x > 0) {
      ### right ends
      ### $d
      return ((3*$d - 2 + 2*$w)*$d - $w + 1 # horizontal to the right
              + $y);                        # offset up or down
    } else {
      ### left ends
      return ((3*$d + 1 + 2*$w)*$d + 1  # horizontal to the left
              - $y);                    # offset up or down
    }

  } else {
    my $d = $ay;

    if ($y > 0) {
      ### top horizontal
      ### $d
      return ((3*$d + 2*$w)*$d + 1  # diagonal up to the left
              + (-$d - $x-$w) / 2); # negative offset rightwards
    } else {
      ### bottom horizontal, and centre horizontal
      ### $d
      ### offset: $d
      return ((3*$d + 2 + 2*$w)*$d + 1  # diagonal down to the left
              + ($x + $w + $d)/2);      # offset rightwards
    }
  }
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### HexSpiral rect_to_n_range(): $x1,$y1, $x2,$y2
  my $w = $self->{'wider'};

  # symmetric in +/-y, and biggest y is biggest n
  my $y = max (abs($y1), abs($y2));

  # symmetric in +/-x, and biggest x
  my $x = max (abs($x1), abs($x2));
  if ($x >= $w) {
    $x -= $w;
  }

  # in the middle horizontal path parts y determines the loop number
  # in the end parts diagonal distance, 2 apart
  my $d = ($y >= $x
           ? $y                 # middle
           : ($x + $y + 1)/2);  # ends
  $d = int($d) + 1;

  # diagonal downwards bottom left being the end of a revolution
  # s=0
  # s=1  n=7
  # s=2  n=19
  # s=3  n=37
  # s=4  n=61
  # n = 3*$d*$d + 3*$d + 1
  #
  # ### gives: "sum $d is " . (3*$d*$d + 3*$d + 1)

  # ENHANCE-ME: find actual minimum if rect doesn't cover 0,0
  return (1,
          (3*$d + 3 + 2*$w)*$d + 1);
}

1;
__END__

=for stopwords HexSpiral PlanePath Ryde Math-PlanePath ie

=head1 NAME

Math::PlanePath::HexSpiral -- integer points around a hexagonal spiral

=head1 SYNOPSIS

 use Math::PlanePath::HexSpiral;
 my $path = Math::PlanePath::HexSpiral->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes a hexagonal spiral, with points spread out horizontally to
fit on a square grid.

             28 -- 27 -- 26 -- 25                  3
            /                    \
          29    13 -- 12 -- 11    24               2
         /     /              \     \
       30    14     4 --- 3    10    23            1
      /     /     /         \     \    \
    31    15     5     1 --- 2     9    22    <- Y=0
      \     \     \              /     /
       32    16     6 --- 7 --- 8    21           -1
         \     \                    /
          33    17 -- 18 -- 19 -- 20              -2
            \
             34 -- 35 ...                         -3

     ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^
    -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6

Each horizontal gap is 2, so for instance n=1 is at x=0,y=0 then n=2 is at
x=2,y=0.  The diagonals are just 1 across, so n=3 is at x=1,y=1.  Each
alternate row is offset from the one above or below.  The result is a
triangular lattice per L<Math::PlanePath/Triangular Lattice>.

The octagonal numbers 8,21,40,65, etc 3*k^2-2*k fall on a horizontal
straight line at y=-1.  In general straight lines are 3*k^2 + b*k + c.  The
3*k^2 goes diagonally up to the left, then b is a 1/6 turn
counter-clockwise, or clockwise if negative.  So b=1 goes horizontally to
the left, b=2 diagonally down to the left, b=3 diagonally down to the right,
etc.

=head2 Wider

An optional C<wider> parameter makes the path wider, stretched along the top
and bottom horizontals.  For example

    $path = Math::PlanePath::HexSpiral->new (wider => 2);

gives

                                ... 36----35                   3
                                            \
                21----20----19----18----17    34               2
               /                          \     \
             22     8---- 7---- 6---- 5    16    33            1
            /     /                    \     \    \
          23     9     1---- 2---- 3---- 4    15    32    <- Y=0
            \     \                          /     /
             24    10----11----12----13----14    31           -1
               \                               /
                25----26----27----28---29----30               -2

           ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^
          -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7

The centre horizontal from N=1 is extended by C<wider> many extra places,
then the path loops around that shape.  The starting point N=1 is shifted to
the left by wider many places to keep the spiral centred on the origin
x=0,y=0.  Each horizontal gap is still 2.

Each loop is still 6 longer than the previous, since the widening is
basically a constant amount added into each loop.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::HexSpiral-E<gt>new ()>

=item C<$path = Math::PlanePath::HexSpiral-E<gt>new (wider =E<gt> $w)>

Create and return a new hex spiral object.  An optional C<wider> parameter
widens the path, it defaults to 0 which is no widening.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n < 1> the return is an empty list, it being considered the path
starts at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each
C<$n> in the path as a square of side 1.

Only every second square in the plane has an N, being those where X,Y both
odd or both even.  If C<$x,$y> is a position without an N, ie. one of X,Y
odd the other even, then the return is C<undef>.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::HexSpiralSkewed>,
L<Math::PlanePath::HexArms>,
L<Math::PlanePath::TriangleSpiral>,
L<Math::PlanePath::TriangularHypot>

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
