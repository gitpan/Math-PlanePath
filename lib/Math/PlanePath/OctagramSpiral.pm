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


# ENHANCE-ME: n_to_xy() might be done with some rotates etc around its
# symmetry instead of 8 or 16 cases.
#


package Math::PlanePath::OctagramSpiral;
use 5.004;
use strict;
use List::Util 'max';

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 52;
@ISA = ('Math::PlanePath');
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Smart::Comments;

sub n_to_xy {
  my ($self, $n) = @_;
  #### OctagramSpiral n_to_xy: $n

  if ($n <= 2) {
    if ($n < 1) {
      return;
    } else {
      return ($n-1, 0);
    }
  }

  # sqrt() done in integers to avoid limited precision from Math::BigRat sqrt()
  #
  my $d = int ((sqrt(int(32*$n) + 17) + 7) / 16);
  #### d frac: ((sqrt(int(32*$n) + 17) + 7) / 16)
  #### $d

  #### base: ((8*$d - 7)*$d + 1)
  $n -= ((8*$d - 7)*$d + 1);
  #### remainder: $n

  if ($n < $d) {
    return ($d + $n, $n);
  }
  $n -= 2*$d;
  if ($n < $d) {
    if ($n < 0) {
      return (- $n + $d,
              $d);
    } else {
      return ($d,
              $n + $d);
    }
  }
  $n -= 2*$d;

  if ($n < $d) {
    return (-$n,
            abs($n) + $d);
  }
  $n -= 2*$d;

  if ($n < $d) {
    if ($n < 0) {
      return (-$d,
              -$n + $d);
    } else {
      return (-$n - $d,
              $d);
    }
  }
  $n -= 2*$d;

  if ($n < $d) {
    return (-$d-abs($n), -$n);
  }
  $n -= 2*$d;

  if ($n < $d) {
    if ($n < 0) {
      return (-$d + $n,
              -$d);
    } else {
      return (-$d,
              -$d - $n);
    }
  }
  $n -= 2*$d;

  if ($n < $d) {
    return ($n,
            - abs($n) - $d);
  }
  $n -= 2*$d;

  if ($n < $d+1) {
    if ($n < 0) {
      return ($d,
              $n - $d);
    } else {
      return ($n + $d,
              -$d);
    }
  }

  # $n >= $d+1 through to 2*$d+1
  return (-$n + 3*$d+2, $n - 2*$d-1);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  ### xy_to_n: "x=$x, y=$y"

  my $n;
  if ($x > 0 && $y < 0 && -2*$y < $x) {
    ### longer bottom right horiz
    $x--;
    $n = 1;
  } else {
    $n = 0;
  }

  my $d_offset = 0;
  if ($y < 0) {
    $y = -$y;
    $x = -$x;
    $d_offset = 8;
    ### rotate 180 back: "$x, $y"
  }
  if ($x < 0) {
    ($x, $y) = ($y, -$x);
    $d_offset += 4;
    ### rotate 90 back: "$x, $y"
  }
  if ($y > $x) {
    ($x, $y) = ($y, $y-$x);
    $d_offset += 2;
    ### rotate 45 back: "$x, $y"
  }

  my $d;
  if (2*$y < $x) {
    ### diag up
    $d = $x - $y;
    $n += $y;
  } else {
    ### horiz back
    $d = $y;
    $n -= $x;
    $d_offset += 3;
  }
  ### final
  ### $d
  ### $d_offset
  ### $n

  # horiz base 2,19,54,...
  return $n + (8*$d - 7 + $d_offset)*$d + 1;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  my $d = max (1, map {abs(_round_nearest($_))} $x1,$y1,$x2,$y2);
  ### $d

  # ENHANCE-ME: find actual minimum if rect doesn't cover 0,0
  return (1,
          (8*$d + 7)*$d + 1);  # bottom-right inner corner 16,47,94,...
}

1;
__END__

=for stopwords OctagramSpiral PlanePath Ryde Math-PlanePath PyramidSides PyramidRows PyramidSpiral octagram SquareSpiral 18-gonal

=head1 NAME

Math::PlanePath::OctagramSpiral -- integer points drawn around an octagram

=head1 SYNOPSIS

 use Math::PlanePath::OctagramSpiral;
 my $path = Math::PlanePath::OctagramSpiral->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes a spiral around an octagram (8-pointed star),

          29          25                 4
           | \       / |
          30 28    26 24    ...56-55     3       
           |   \  /    |         /
    33-32-31  7 27  5 23-22-21 54        2
      \       |\  / |      /  /
       34  9- 8  6  4- 3 20 53           1
         \  \        /  /  /
          35 10  1--2 19 52          <- Y=0
         /  /           \  \  
       36 11-12 14 16-17-18 51          -1
      /       |/  \ |         \
    37-38-39 13 43 15 47-48-49-50       -2
           |   /  \    |
          40 42    44 46                -3
           |/        \ |
          41          45                -4

                 ^
    -4 -3 -2 -1 X=0 1  2  3  4  5 ...

Each loop is 16 longer than the previous.  The 18-gonal numbers
18,51,100,etc fall on the horizontal at Y=-1.

The inner corners like 23, 31, 39, 47 are similar to the SquareSpiral path,
but instead of going directly between them the octagram takes a detour out
to make the points of the star.  Those excursions make each loops 8 longer
(1 per excursion), hence a step of 16 here as compared to 8 for the
SquareSpiral.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::OctagramSpiral-E<gt>new ()>

Create and return a new octagram spiral object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n < 1> the return is an empty list, it being considered the path
starts at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each N
in the path as centred in a square of side 1, so the entire plane is
covered.

=back

=head1 FORMULAS

=head2 X,Y to N

The symmetry of the octagram can be used by rotating a given X,Y back to the
first star excursion such as N=19 to N=23.  If Y is negative then rotate
back by 180 degrees, then if X is negative rotate back by 90, and if Y>=X
then by a further 45 degrees.  Each such rotation, if needed, is counted as
a multiple of the side-length to be added to the final N.  For example at
N=19 the side length is 2.  Rotating by 180 degrees is 8 side lengths, by 90
degrees 4 sides, and by 45 degrees is 2 sides.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SquareSpiral>,
L<Math::PlanePath::PyramidSpiral>

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






    #         29              25                      4
    #          |  \         /  |
    #         30  28      26  24      ...-56--55      3       
    #          |     \   /     |             /
    # 33--32--31   7  27   5  23--22--21  54          2
    #   \          | \   / |         /  /
    #     34   9-- 8   6   4-- 3  20  53              1
    #       \   \            /   /   /
    #         35  10   1---2  19  52             <- y=0
    #       /   /                \   \  
    #     36  11--12  14  16--17--18  51             -1
    #   /          | /   \ |            \
    # 37--38--39  13  43  15  47--48--49--50         -2
    #          |    /   \      |
    #         40  42      44  46                     -3
    #          | /          \  |
    #         41              45                     -4
    # 
    #                  ^
    # -4  -3  -2  -1  x=0  1   2   3   4   5  ...
    # 
    # 
    # 
    # 
    # 
    # 
    # 
    # 
    # 
    #         28              24                      4
    #          |  \         /  |
    #         29  27      25  23      ...-54--53      3       
    #          |     \   /     |            /
    # 32--31--30   7  26   5  22--21--20  52          2
    #   \          | \   / |         /  /
    #     33   9-- 8   6   4-- 3  19  51              1
    #       \   \            /   /  /
    #         34  10   1---2  18  50             <- y=0
    #       /   /              |   |    
    #     35  11--12  14  16--17  49                 -1
    #   /          | /   \ |         \   
    # 36--37--38  13  42  15  46--47--48             -2
    #          |    /   \      |
    #         39  41      43  45                     -3
    #          | /          \  |
    #         40              44                     -4
    # 
    #                  ^
    # -4  -3  -2  -1  x=0  1   2   3   4   5  ...





