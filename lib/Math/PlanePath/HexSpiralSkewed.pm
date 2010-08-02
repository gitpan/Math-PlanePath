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


package Math::PlanePath::HexSpiralSkewed;
use 5.004;
use strict;
use warnings;
use List::Util qw(max);
use POSIX ();
use Math::PlanePath::HexSpiral;

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 6;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;


# diagonal down and to the left
# 0 1  2   3   4
#   1  6  17  34
#    +5 +11 +17
#      +6 +6
# n = 3*s*s - 4*s + 2
# s = (2 + sqrt(3*$n-2)) / 3

sub n_to_xy {
  my ($self, $n) = @_;
  #### n_to_xy: $n
  if ($n < 1) { return; }
  if ($n == 1) { return (0,0); }

  my $s = int((2 + sqrt(3*$n-2)) / 3);
  #### s frac: (2 + sqrt(3*$n-2)) / 3
  #### $s
  $n -= (3*$s - 4)*$s + 2;
  #### remainder: $n

  if ($n < $s) {
    #### bottom
    return ($n,
            -$s+1);
  }
  $n -= $s;
  if ($n < $s-1) {
    #### right lower, being 1 shorter: $n
    return ($s,
            -$s+1 + $n);
  }
  $n -= $s-1;
  if ($n < $s) {
    #### right upper: $n
    return ($s - $n,
            $n);
  }
  $n -= $s;
  if ($n < $s) {
    #### top
    return (-$n,
            $s);
  }
  $n -= $s;
  if ($n < $s) {
    #### left upper
    return (-$s,
            $s - $n);
  }
  #### left lower
  $n -= $s;
  return (-$s + $n,
          -$n);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;

  $x = POSIX::floor ($x + 0.5);
  $y = POSIX::floor ($y + 0.5);

  my $ay = abs($y);
  my $ax = abs($x);
  if ($x >= 0) {
    if ($x > -$y) {
      my $s = ($y >= 0
               ? $x + $y  # upper right diagonal
               : $x);     # lower right vertical
      ### upper diagonal and right vertical
      ### $s
      return (3*$s*$s + -2*$s + 1  # horizontal to the right 1,2,9,22,41
              + $y);               # offset up or down

    } else {
      my $s = -$y;
      ### bottom horizontal
      ### $s
      return (3*$s*$s + 2*$s + 1   # vertical downwards 1,6,17,34,57
              + $x);               # offset rightwards
    }

  } else {
    if ($x <= -$y) {
      my $s = ($y >= 0
               ? -$x         # upper left vertical
               : -($x+$y));  # lower left diagonal
      ### upper diagonal and right vertical
      ### $s
      return (3*$s*$s + 1*$s + 1   # horizontal to the right 1,5,15,31,53
              - $y);               # offset up or down
    } else {
      my $s = $y;
      ### top horizontal
      ### $s
      return (3*$s*$s + -1*$s + 1  # vertical upwards 1,3,11,25,44
              - $x);               # offset leftwards
    }
  }
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### HexSpiralSkewed xy_to_n_range(): $x1,$y1, $x2,$y2

  my $x = max(abs($x1),abs($x2));
  my $y = max(abs($y1),abs($y2));
  my $s = max($x,               # left or right vertical
              $y,               # top or bottom horizontal
              abs ($x1 + $y1),  # upper right or lower left diagonals
              abs ($x1 + $y2),
              abs ($x2 + $y1),
              abs ($x2 + $y2));
  $s = int($s);

  # diagonal downwards bottom right being the end of a revolution
  # s=0
  # s=1  n=7
  # s=2  n=19
  # s=3  n=37
  # s=4  n=61
  # n = 3*$s*$s + 3*$s + 1
  #
  ### gives: "sum $s is " . (3*$s*$s + 3*$s + 1)

  # ENHANCE-ME: find actual minimum if rect doesn't cover 0,0
  return (1,
          1 + 3*$s*$s + 3*$s + 1);
}

1;
__END__

=for stopwords HexSpiral SquareSpiral DiamondSpiral PlanePath Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::HexSpiralSkewed -- integer points in a diamond shape

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

      ^   ^  ^   ^   ^   ^ 
     -2  -1 x=0  1   2   3  ...

The sequence is the same as for the plain HexSpiral, but this arrangement
fits more points on a square grid.  It's similar to the SquareSpiral but
cuts two corners so each loop is 6 steps longer than the previous whereas
for the SquareSpiral it's 8.  See the DiamondSpiral for cutting all 4
corners.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::HexSpiral-E<gt>new ()>

Create and return a new HexSpiral spiral object.

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
L<Math::PlanePath::HexSpiral>

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
