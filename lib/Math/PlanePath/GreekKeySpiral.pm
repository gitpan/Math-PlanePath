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


# math-image --path=GreekKeySpiral --lines --scale=25

# http://gwydir.demon.co.uk/jo/greekkey/corners.htm

# turns parameter
# 0 for no turns squarespiral style, default 2


package Math::PlanePath::GreekKeySpiral;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 55;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_floor = \&Math::PlanePath::_floor;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::SquareArms;
*_rect_square_range = \&Math::PlanePath::SquareArms::_rect_square_range;

# uncomment this to run the ### lines
#use Devel::Comments;

my @shape_x    = (3,4,5,5, 5, 4, 4, 3, 3,    5, 4, 4, 5, 5, 4, 3,3, 3);
my @shape_y    = (0,0,0,1, 2, 2, 1, 1, 2,    2, 2, 1, 1, 0, 0, 0,1, 2);
my @shape_xdir = (1,1,0,0,-1, 0,-1, 0, 0,   -1, 0, 1, 0,-1,-1, 0,0,-1);
my @shape_ydir = (0,0,1,1, 0,-1, 0, 1, 1,    0,-1, 0,-1, 0, 0, 1,1, 0);

### assert: do { foreach (0..7,9..15) { $shape_xdir[$_] == $shape_x[$_+1]-$shape_x[$_] or die "shape_xdir $_"}; 1}
### assert: do { foreach (0..7,9..15) { $shape_ydir[$_] == $shape_y[$_+1]-$shape_y[$_] or die "shape_ydir $_"}; 1}
### assert $shape_xdir[17] == $shape_x[9] - ($shape_x[17]+3)
### assert $shape_ydir[17] == $shape_y[9] - ($shape_y[17]+3)

sub n_to_xy {
  my ($self, $n) = @_;
  #### GreekKeySpiral n_to_xy: $n

  if ($n < 1) {
    return;
  }

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;
    $n = $int;
  }

  # sqrt() done in integers to avoid limited precision from Math::BigRat sqrt()
  #
  my $d = int (sqrt(($n-1)/9));
  #### d frac: (sqrt(($n-1)/9))
  #### $d

  $n -= 9*$d*$d + 1;
  my $mod = $n % 9;
  my $nines = int($n/9);
  ### base: 9*$d*$d
  ### remainder: $n
  ### $nines
  ### $mod
  ### $frac
  ### horiz start: 18*$d-1

  my $dh = int($d/2);
  my ($x, $y);
  if ($d==0) {
    $n = ($n + 9) % 9;
  }
  if ($n >= 9*$d+8 || $d==0) {
    # n/9 = nines >= d+1
    $x = 3*($dh - ($nines - $d));
    $y = 3*($dh + ($d&1));
    $mod += 9;
    ### horizontal: "$x,$y"
    ### now mod: $mod

  } else {
    $x = 3*$dh;
    $y = 3*($nines - $dh);
    ### vertical: "$x,$y"
  }
  ### $x
  ### $y

  ### shape: $shape_x[$mod].','.$shape_y[$mod]
  # $frac first arg so as to get BigRat from it instead of BigInt from $x,$y
  $x = ($frac * $shape_xdir[$mod] + $shape_x[$mod]) + $x;
  $y = ($frac * $shape_ydir[$mod] + $shape_y[$mod]) + $y;

  unless ($d & 1) {
    $x = 5 - $x;
    $y = 2 - $y;
    ### flip for left and bottom: "$x,$y"
  }

  ### $x
  ### $y
  return ($x, $y);
}

my @inverse_bottom = ([1,2,9],
                      [4,3,8],
                      [5,6,7]);
my @inverse_top = ([7,6,5],
                   [8,3,4],
                   [9,2,1]);
my @inverse_right = ([1,2,3],
                     [8,7,4],
                     [9,6,5]);
my @inverse_left = ([5,6,9],
                    [4,7,8],
                    [3,2,1]);
sub xy_to_n {
  my ($self, $x, $y) = @_;

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  ### xy_to_n: "x=$x, y=$y"

  my $x3 = _floor($x/3);
  my $y3 = _floor($y/3);
  $x %= 3;
  $y %= 3;
  my $n;
  if ($x3 > -$y3) {
    ### top or right
    if ($x3 >= $y3) {
      ### right going upwards
      $n = 9*((4*$x3 - 3)*$x3 + $y3) + $inverse_right[$y]->[$x];
    } else {
      ### top going leftwards
      $n = 9*((4*$y3 - 1)*$y3 - $x3) + $inverse_top[$y]->[$x];
    }
  } else {
    ### bottom or left
    if ($x3 > $y3 || ($x3 == 0 && $y3 == 0)) {
      ### bottom going rightwards: "$x3,$y3"
      $n = 9*((4*$y3 - 3)*$y3 + $x3) + $inverse_bottom[$y]->[$x];
    } else {
      ### left going downwards
      $n = 9*((4*$x3 - 1)*$x3 - $y3) + $inverse_left[$y]->[$x];
    }
  }
  return $n;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### rect_to_n_range(): "$x1,$y1  $x2,$y2"

  # coords -1 to centre around the origin 0,0
  my ($dlo, $dhi) = _rect_square_range ($x1-1, $y1-1,
                                        $x2-1, $y2-1);
  ### d range: "$dlo, $dhi"

  # now d=0,1 is the inner thirds=0, and d=2,3,4 is the next ring thirds=1
  $dlo = int (($dlo+1) / 3);
  $dhi = int (($dhi+1) / 3);

  ### d range thirds: "$dlo, $dhi"
  ### right start: ((36*$dlo - 36)*$dlo + 10)

  return ($dlo == 0 ? 1  # special case for innermost 3x3
          : ((36*$dlo - 36)*$dlo + 10), # right vertical start

          (36*$dhi + 36)*$dhi + 9);     # bottom horizontal end
}

1;
__END__

=for stopwords GreekKeySpiral PlanePath Ryde Math-PlanePath SquareSpiral 18-gonal Edkins

=head1 NAME

Math::PlanePath::GreekKeySpiral -- square spiral with Greek key motif

=head1 SYNOPSIS

 use Math::PlanePath::GreekKeySpiral;
 my $path = Math::PlanePath::GreekKeySpiral->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes a spiral with a Greek key scroll motif,

    39--38--37--36  29--28--27  24--23                      5
     |           |   |       |   |   |                       
    40  43--44  35  30--31  26--25  22                      4
     |   |   |   |       |           |                       
    41--42  45  34--33--32  19--20--21  ...                 3
             |               |           |                   
    48--47--46   5---6-- 7  18  15--14  99  96--95          2
     |           |       |   |   |   |   |   |   |           
    49  52--53   4---3   8  17--16  13  98--97  94          1
     |   |   |       |   |           |           |           
    50--51  54   1---2   9--10--11--12  91--92--93     <- Y=0
             |                           |                   
    57--56--55  68--69--70  77--78--79  90  87--86         -1
     |           |       |   |       |   |   |   |           
    58  61--62  67--66  71  76--75  80  89--88  85         -2
     |   |   |       |   |       |   |           |           
    59--60  63--64--65  72--73--74  81--82--83--84         -3
                  
    -3  -2  -1  X=0  1   2   3   4   5   6   7   8 ...

The repeating figure is a 3x3 pattern

       |
       *   *---*
       |   |   |      left vertical
       *---*   *      going upwards
               |   
       *---*---*
       |

The turn excursion is to the outside of the 3-wide channel and forward in
the direction of the spiral.  The overall spiraling is the same as the
SquareSpiral, but composed of 3x3 sub-parts.

=head2 Sub-Part Joining

The verticals have the "entry" to each figure on the inside edge, as for
example N=90 to N=91 above.  The horizontals instead have it on the outside
edge, such as N=63 to N=64 along the bottom.  The innermost N=1 to N=9 is a
bottom horizontal going right.

      *---*---*     
      |       |        bottom horizontal
      *---*   *        going rightwards
          |   |     
    --*---*   *-->  

On the horizontals the excursion part is still "forward on the outside", as
for example N=73 through N=76, but the shape is offset.  The way the entry
is alternately on the inside and outside for the vertical and horizontal is
necessary to make the corners join.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::GreekKeySpiral-E<gt>new ()>

Create and return a new Greek key spiral object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n E<lt> 1> the return is an empty list, it being considered the path
starts at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each N
in the path as centred in a square of side 1, so the entire plane is
covered.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SquareSpiral>

Jo Edkins Greek Key pages C<http://gwydir.demon.co.uk/jo/greekkey/index.htm>

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
