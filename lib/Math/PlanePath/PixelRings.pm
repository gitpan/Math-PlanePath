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


package Math::PlanePath::PixelRings;
use 5.004;
use strict;
use Math::Libm 'hypot';
#use List::Util 'min','max';
*min = \&Math::PlanePath::_min;
*max = \&Math::PlanePath::_max;

use Math::PlanePath;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use vars '$VERSION', '@ISA';
$VERSION = 80;
@ISA = ('Math::PlanePath');


# uncomment this to run the ### lines
#use Smart::Comments;


# ENHANCE-ME: What's the formula for the cumulative pixel count, and its
# inverse?  It's not floor(k*4*sqrt(2)).
use vars '@_cumul';
@_cumul = (1, 2);
my $cumul_x = 0;
my $cumul_y = 0;
my $cumul_add = 0;

sub _cumul_extend {
  ### _cumul_extend(): "length of r=$#_cumul"
  my $r = $#_cumul;
  $cumul_add += 4;
  if ($cumul_x == $cumul_y) {
    ### at: "$cumul_x,$cumul_y"
    ### step across and maybe up
    $cumul_x++;

    ### xy hypot: ($cumul_x+.5)**2 + ($cumul_y)**2
    ### r squared: $r*$r
    ### E: ($cumul_x+.5)**2 + $cumul_y*$cumul_y - $r*$r

    if (($cumul_x+.5)**2 + $cumul_y*$cumul_y < $r*$r) {
      ### midpoint of x,y inside, increment to x,y+1
      $cumul_y++;
      $cumul_add += 4;
    }

  } else {
    ### at: "$cumul_x,$cumul_y"
    ### try y+1 with x or x+1 is: ($cumul_x+.5).",".($cumul_y+1)
    $cumul_y++;
    ### xy hypot: ($cumul_x+.5)**2 + ($cumul_y)**2
    ### r squared: $r*$r
    ### E: ($cumul_x+.5)**2 + $cumul_y*$cumul_y - $r*$r
    if (($cumul_x+.5)**2 + $cumul_y*$cumul_y < $r*$r) {
      ### midpoint inside, increment x too
      $cumul_x++;
      $cumul_add += 4;
    }
  }
  ### to: "$cumul_x,$cumul_y"
  ### cumul extend: scalar(@_cumul).' = '.($_cumul[-1] + $cumul_add)
  ### $cumul_add
  push @_cumul, $_cumul[-1] + $cumul_add;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### PixelRings n_to_xy(): $n

  if ($n < 1) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  if ($n < 6) {
    if ($n < 2) {
      return ($n-1, 0);
    }
    $n -= 2;
    my $frac = $n - int($n);
    my $x = 1 - $frac;
    my $y = $frac;
    if ($n & 2) {
      $x = -$x;
      $y = -$y;
    }
    if ($n & 1) {
      ($x,$y) = (-$y, $x);
    }
    return ($x,$y);
  }

  ### search cumul for n: $n
  my $r = 1;
  for (;;) {
    if ($r >= @_cumul) {
      _cumul_extend ();
    }
    if ($_cumul[$r] > $n) {
      last;
    }
    $r++;
  }
  $r--;

  $n -= $_cumul[$r];
  my $len = $_cumul[$r+1] - $_cumul[$r];
  ### cumul: "$_cumul[$r] to $_cumul[$r+1]"
  ### $len
  ### n rem: $n
  $len /= 4;
  my $quadrant = $n / $len;
  $n %= $len;
  ### len of quadrant: $len
  ### $quadrant
  ### n into quadrant: $n

  my $rev;
  if ($rev = ($n > $len/2)) {
    $n = $len - $n;
  }
  ### $rev
  ### $n
  my $y = $n;
  my $x = int (sqrt (max (0, $r*$r - $y*$y)) + .5);
  if ($rev) {
    ($x,$y) = ($y,$x);
  }

  if ($quadrant & 2) {
    $x = -$x;
    $y = -$y;
  }
  if ($quadrant & 1) {
    ($x,$y) = (-$y, $x);
  }
  ### return: "$x, $y"
  return ($x, $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### PixelRings xy_to_n(): "$x, $y"
  $x = _round_nearest ($x);
  $y = _round_nearest ($y);

  if ($x == 0 && $y == 0) {
    return 1;
  }

  my $r;
  {
    my $xa = abs($x);
    my $ya = abs($y);
    if ($xa < $ya) {
      ($xa,$ya) = ($ya,$xa);
    }
    $r = int (hypot ($xa+.5,$ya));
    ### r frac: hypot ($xa+.5,$ya)
    ### $r
    ### r < inside frac: hypot ($xa-.5,$ya)
    if ($r < hypot ($xa-.5,$ya)) {
      ### pixel not crossed
      return undef;
    }
    if ($xa == $ya) {
      ### and pixel below for diagonal
      ### r < below frac: $r . " < " . hypot ($xa+.5,$ya-1)
      if ($r < hypot ($xa+.5,$ya-1)) {
        ### same loop, no sharp corner
        return undef;
      }
    }
  }
  if (_is_infinite($r)) {
    return undef;
  }

  while ($#_cumul <= $r) {
    ### extend cumul for r: $r
    _cumul_extend ();
  }

  my $n = $_cumul[$r];
  my $len = $_cumul[$r+1] - $n;
  ### $r
  ### n base: $n
  ### $len
  ### len/4: $len/4
  if ($y < 0) {
    ### y neg, rotate 180
    $y = -$y;
    $x = -$x;
    $n += $len/2;
  }
  if ($x < 0) {
    $n += $len/4;
    ($x,$y) = ($y,-$x);
    ### neg x, rotate 90
    ### n base now: $n + $len/4
    ### transpose: "$x,$y"
  }
  ### assert: $x >= 0
  ### assert: $y >= 0
  if ($y > $x) {
    ### top octant, reverse: "x=$x len/4=".($len/4)." gives ".($len/4 - $x)
    $y = $len/4 - $x;
  }
  ### n return: $n + $y
  return $n + $y;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### PixelRings rect_to_n_range(): "$x1,$y1 $x2,$y2"

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);

  my $r_min
    = ((($x1<0) ^ ($x2<0)) || (($y1<0) ^ ($y2<0))
       ? 0
       : max (0,
              int (hypot (min(abs($x1),abs($x2)), min(abs($y1),abs($y2))))
              - 1));
  my $r_max = 2 + int (hypot (max(abs($x1),abs($x2)), max(abs($y1),abs($y2))));
  ### $r_min
  ### $r_max

  if (_is_infinite($r_min)) {
    return ($r_min, $r_min);
  }

  my ($n_max, $r_target);
  if (_is_infinite($r_max)) {
    $n_max = $r_max;  # infinity
    $r_target = $r_min;
  } else {
    $r_target = $r_max;
  }

  while ($#_cumul < $r_target) {
    ### extend cumul for r: $r_target
    _cumul_extend ();
  }

  if (! defined $n_max) {
    $n_max = $_cumul[$r_max];
  }
  return ($_cumul[$r_min], $n_max);
}

1;
__END__







# # =head1 FORMULAS
# 
# # =head2 Pixel Ring Length
# 
# When the algorithm crosses the X=Y central diagonal it might include an X=Y
# point or it might not.  The case where it doesn't looks like
# 
#           +-------+       X=Y line
#           |       |      .
#           |       |     .
#           |   *   |   ..
#           |       | ..
#           |       |.
#           +-------.-------+
#                  .|       |
#                 . |       |
#               ..  %   *   |  <- Y=k-1
#             ..    |       |
#            .      |       |
#                   +-------+
#                   ^   ^   ^
#                   |  X=k  |
#               X=k-.5     X=k+.5
# 
# The algorithm draws a pixel when the exact circle line X^2+Y^2=R^2 passes is
# within that pixel, ie. on its side of the midpoint between adjacent pixels.
# This means to the right of the X=k-0.5, Y=k-1 point marked "%" above.  So
# 
#     X^2 + Y^2 < R^2
#     (k-.5)^2 + (k-1)^2 < R^2
#     2*k^2 - 3k + 5/4 < R^2
#     k = floor (3 + sqrt(3*3 - 4*2*(5/4 - R^2)))
#       = floor (3 + sqrt(8*R^2 - 1))
# 
# The circle line is never precisely on such a "%" point, as can be seen from
# the formula since 8*R^2-1 is never a perfect square (squares are 0,1,4
# mod 8).
# 
# Now in the first octant, up to this k pixel, there's one pixel per row, and
# likewise symmetrically above the line, so the total in a ring passing the
# X=Y this way is
# 
#     ringlength = 8*k-4
# 
# The second case is when the ring includes an X=Y point,
# 
#           +-------+
#           |       |
#           |       |            ..
#           |   *   |          ..
#           |       |         .
#           |       |       |.
#           +-------+-------+-
#                   |      .|
#                   |  X=Y. |
#                   |   *   |
#                   | ..    |
#                   |.      |
#                  -+-------+-------+
#                  .|       |       |
#                .. |       |       |
#               .   %       @   *   |   <- Y=k-1
#             ..    |       |       |
#                   |       |       |
#                   +-------+-------+
#                   |  X=k  |
#               X=k-.5     X=k+.5
# 
# The two cases are distinguished by which side of the X=k+.5 midpoint "@" the
# circle line passes.  If the circle is outside the "@" then the outer pixel
# is drawn, thus giving this X=Y included case.  The test is
# 
#     X^2 + Y^2 < R^2
#     (k+.5)^2 + (k-1)^2 < R^2
#     2*k^2 - k + 5/4 < R^2
# 
# The extra X=Y pixel adds 4 to the ringlength above, one on the diagonal in
# each of the four quadrants, so
# 
#     ringlength = 8*k     if X=Y pixel included
#                  8*k-4   if X=Y pixel not included
# 
# The k calculation above is effectively asking where the circle line
# intersects a diagonal X=Y+.5 and rounding down to integer Y on that
# diagonal.  The test at X=k+.5 is asking about a different diagonal X=Y+1.5
# and it doesn't seem there's a particularly easy relation between where the
# circle falls on the first diagonal and where on the second.







=for stopwords Ryde pixellated DiamondSpiral SquareSpiral Math-PlanePath

=head1 NAME

Math::PlanePath::PixelRings -- pixellated concentric circles

=head1 SYNOPSIS

 use Math::PlanePath::PixelRings;
 my $path = Math::PlanePath::PixelRings->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path puts points on the pixels of concentric circles using the midpoint
ellipse drawing algorithm.

                63--62--61--60--59                     5
              /                    \
            64  .   40--39--38   .  58                 4
          /       /            \       \
        65  .   41  23--22--21  37   .  57             3
      /       /   /            \   \       \
    66  .   42  24  10-- 9-- 8  20  36   .  56         2
     |    /   /   /            \   \   \     |
    67  43  25  11   .   3   .   7  19  35  55         1
     |   |   |   |     /   \     |   |   |   |
    67  44  26  12   4   1   2   6  18  34  54       y=0
     |   |   |   |     \   /
    68  45  27  13   .   5   .  17  33  53  80        -1
     |    \   \   \            /   /   /     |
    69  .   46  28  14--15--16  32  52   .  79        -2
      \       \   \            /   /       /
        70  .   47  29--30--31  51   .  78            -3
          \       \            /       /
            71  .   48--49--50   .  77                -4
              \                    /
                72--73--74--75--76                    -5

    -5  -4  -3  -2  -1  x=0  1   2   3   4   5

The way the algorithm works means the rings don't overlap.  Each is 4 or 8
pixels longer than the preceding.  If the ring follows the preceding tightly
then it's 4 longer, like the N=18 to N=33 ring.  If it goes wider then it's
8 longer, like the N=54 to N=80 ring.  The average extra is 4*sqrt(2) or
thereabouts.

The rings can be thought of as part-way between the diagonals of the
DiamondSpiral and the corners of the SquareSpiral.


     *           **           *****
      *            *              *
       *            *             *
        *            *            *
         *           *            *
   
    diagonal     ring         corner
    5 points    6 points     9 points

For example the N=54 to N=80 ring has a vertical corner-type part N=54,55,56
then a diagonal part N=56,57,58,59.  In bigger rings the verticals are
intermingled with the diagonals but the principle is the same.  The number
of vertical steps determines where it crosses the 45-degree line, at
R*sqrt(2) but rounded according to the midpoint algorithm.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::PixelRings-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

For C<$n < 1> the return is an empty list, it being considered there are no
negative points.

The behaviour for fractional C<$n> is unspecified as yet.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x,$y>.  Each integer N is
considered the centre of a unit square and an C<$x,$y> within that square
returns N.

Not every point of the plane is covered (like those marked by a "." in the
sample above).  If C<$x,$y> is not reached then the return is C<undef>.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::Hypot>,
L<Math::PlanePath::MultipleRings>

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
