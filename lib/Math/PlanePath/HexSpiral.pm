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


package Math::PlanePath::HexSpiral;
use 5.004;
use strict;
use warnings;
use List::Util qw(max);
use POSIX ();

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 8;
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
    $s = -$s + 1;
    return ($s + 2*$n,
            $s);
  }
  $n -= $s;
  if ($n < $s-1) {
    #### right lower, being 1 shorter: $n
    return (1+$s + $n,
            -$s+1 + $n);
  }
  $n -= $s-1;
  if ($n < $s) {
    #### right upper: $n
    return (2*$s - $n,
            $n);
  }
  $n -= $s;
  if ($n < $s) {
    #### top
    return ($s - 2*$n,
            $s);
  }
  $n -= $s;
  if ($n < $s) {
    #### left upper
    return (-$s - $n,
            $s - $n);
  }
  #### left lower
  $n -= $s;
  return (-2*$s + $n,
          -$n);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = POSIX::floor ($x + 0.5);
  $y = POSIX::floor ($y + 0.5);
  if (($x ^ $y) & 1) {
    return undef;  # nothing on odd squares
  }

  my $ay = abs($y);
  my $ax = abs($x);
  if ($ax > $ay) {
    my $s = ($ax + $ay)/2;  # x+y is even

    if ($x > 0) {
      ### right end
      return (3*$s*$s + -2*$s + 1  # horizontal to the right
              + $y);               # offset up or down
    } else {
      ### left end
      return (3*$s*$s + 1*$s + 1   # horizontal to the left
              - $y);               # offset up or down
    }

  } else {
    # top or bottom horizontals
    my $s = $ay;

    if ($y >= 0) {
      ### top
      ### $s
      return (3*$s*$s - $s + 1   # diagonal up to the right
              + ($y - $x) / 2    # offset leftwards
             );
    } else {
      ### bottom
      ### $s
      return (3*$s*$s + 2*$s + 1   # diagonal down to the left
              + ($x - $y)/2        # offset rightwards
             );
    }
  }
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### HexSpiral xy_to_n_range(): $x1,$y1, $x2,$y2

  # symmetric in +/-y, and biggest y is biggest n
  my $y = max (abs($y1), abs($y2));

  # symmetric in +/-x, and biggest x
  my $x = max (abs($x1), abs($x2));

  # in the middle horizontal path parts y determines the loop number
  # in the end parts diagonal distance, 2 apart
  my $s = ($y >= $x
           ? $y         # middle
           : ($x + $y + 1)/2);  # ends
  $s = int($s);

  # diagonal downwards bottom left being the end of a revolution
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

=for stopwords HexSpiral PlanePath Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::HexSpiral -- integer points in a diamond shape

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
    31    15     5     1 --- 2     9    22    <- y=0
      \     \     \              /     /
       32    16     6 --- 7 --- 8    21           -1
         \     \                    /
          33    17 -- 18 -- 19 -- 20              -2
            \
             34 -- 35 ...                         -3

     ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^
    -6 -5 -4 -3 -2 -1 x=0 1  2  3  4  5  6

Each horizontal gap is 2, so for instance n=1 is at x=0,y=0 then n=2 is at
x=2,y=0.  The diagonals are just 1 across, so n=3 is at x=1,y=1.  Each
alternate row is offset from the one above or below.  The resulting
"triangles" between the points are flatter than they ought to be.  Drawn on
a square grid the angle up is 45 degrees making an isosceles right triangle
instead of 60 for an equilateral triangle.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::HexSpiral-E<gt>new ()>

Create and return a new HexSpiral path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> on the path.

For C<$n < 1> the return is an empty list, it being considered the path
starts at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each
C<$n> in the path as a square of side 1.

Only every second square in the plane has an N.  If C<$x,$y> is a
position without an N then the return is C<undef>.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::HexSpiralSkewed>,
L<Math::PlanePath::TriangleSpiral>

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
