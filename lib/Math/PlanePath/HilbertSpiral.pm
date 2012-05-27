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


package Math::PlanePath::HilbertSpiral;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 75;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::BetaOmega 52;
*_y_round_down_len_level = \&Math::PlanePath::BetaOmega::_y_round_down_len_level;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;

# generated by tools/hilbert-spiral-table.pl
#
my @next_state = (8,0,0,12, 12,4,4,8, 0,8,8,4, 4,12,12,0,
                  20,0,0,12, 16,4,4,8);
my @digit_to_x = (0,1,1,0, 1,0,0,1, 0,0,1,1, 1,1,0,0,
                  0,1,1,0, 1,0,0,1);
my @digit_to_y = (0,0,1,1, 1,1,0,0, 0,1,1,0, 1,0,0,1,
                  0,0,1,1, 1,1,0,0);
my @xy_to_digit = (0,3,1,2, 2,1,3,0, 0,1,3,2, 2,3,1,0,
                   0,3,1,2, 2,1,3,0);
my @min_digit = (0,0,1,0, 0,1,3,2, 2,undef,undef,undef,
                 2,2,3,1, 0,0,1,0, 0,undef,undef,undef,
                 0,0,3,0, 0,2,1,1, 2,undef,undef,undef,
                 2,1,1,2, 0,0,3,0, 0,undef,undef,undef,
                 0,0,1,0, 0,1,3,2, 2,undef,undef,undef,
                 2,2,3,1, 0,0,1,0, 0);
my @max_digit = (0,1,1,3, 3,2,3,3, 2,undef,undef,undef,
                 2,3,3,2, 3,3,1,1, 0,undef,undef,undef,
                 0,3,3,1, 3,3,1,2, 2,undef,undef,undef,
                 2,2,1,3, 3,1,3,3, 0,undef,undef,undef,
                 0,1,1,3, 3,2,3,3, 2,undef,undef,undef,
                 2,3,3,2, 3,3,1,1, 0);
# neg state 20

sub n_to_xy {
  my ($self, $n) = @_;
  ### HilbertSpiral n_to_xy(): $n
  ### hex: sprintf "%#X", $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  my $int = int($n);
  $n -= $int;

  my @digits;
  my $len = $n*0 + 1;   # inherit possible bigint 1
  do {
    push @digits, $int % 4;
    $len *= 2;
  } while ($int = int($int/4));

  my $state = ($#digits & 1 ? 4 : 0);
  my $dir = $state + 2; # default if all $digit==3
  ### @digits

  my $x = my $y = 0;

  while (defined (my $digit = pop @digits)) {  # high to low
    $len /= 2;
    $state += $digit;
    if ($digit != 3) {
      $dir = $state;  # lowest non-3 digit
    }

    ### at: "$x,$y len=$len"
    ### $state
    ### $dir
    ### digit_to_x: $digit_to_x[$state]
    ### digit_to_y: $digit_to_y[$state]
    ### next_state: $next_state[$state]

    my $offset = scalar(@digits) & 1;
    $x += $len * ($digit_to_x[$state] - $offset);
    $y += $len * ($digit_to_y[$state] - $offset);
    $state = $next_state[$state];
  }


  ### frac: $n
  ### $dir
  ### dir dx: ($digit_to_x[$dir+1] - $digit_to_x[$dir])
  ### dir dy: ($digit_to_y[$dir+1] - $digit_to_y[$dir])
  ### x: $n * ($digit_to_x[$dir+1] - $digit_to_x[$dir]) + $x
  ### y: $n * ($digit_to_y[$dir+1] - $digit_to_y[$dir]) + $y

  # with $n fractional part
  return ($n * ($digit_to_x[$dir+1] - $digit_to_x[$dir]) + $x,
          $n * ($digit_to_y[$dir+1] - $digit_to_y[$dir]) + $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### HilbertSpiral xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);

  my $n = ($x * 0 * $y);

  my ($len, $level) = _y_round_down_len_level ($x);
  {
    my ($ylen, $ylevel) = _y_round_down_len_level ($y);
    ### y len/level: "$ylen  $ylevel"
    if ($ylevel > $level) {
      $level = $ylevel;
      $len = $ylen;
    }
  }
  if (_is_infinite($len)) {
    return $len;
  }

  ### $len
  ### $level

  my $state;
  {
    my $offset;
    if ($level & 1) {
      $state = 4;
      $offset = 4*$len;
    } else {
      $state = 0;
      $offset = 2*$len;
    }
    $offset -= 2;
    $offset /= 3;
    $y += $offset;
    $x += $offset;
    # $x,$y now relative to Xmin(level),Ymin(level),
    # so in range 0 <= $x,$y < 2*len
  }
  ### offset x,y to: "$x, $y"

  for (;;) {
    ### at: "$x,$y  len=$len"
    ### assert: $x >= 0
    ### assert: $y >= 0
    ### assert: $x < 2*$len
    ### assert: $y < 2*$len

    my $xo;
    if ($xo = ($x >= $len)) {
      $x -= $len;
    }
    my $yo;
    if ($yo = ($y >= $len)) {
      $y -= $len;
    }
    ### xy bits: ($xo+0).", ".($yo+0)

    my $digit = $xy_to_digit[$state + 2*$xo + $yo];
    $n = 4*$n + $digit;
    $state = $next_state[$state+$digit];

    last if --$level < 0;
    $len /= 2;
  }

  ### assert: $x == 0
  ### assert: $y == 0

  return $n;
}


# This finds the exact minimum/maximum N in the given rectangle.
#
# The strategy is similar to xy_to_n(), except that at each bit position
# instead of taking a bit of x,y from the input instead those bits are
# chosen from among the 4 sub-parts according to which has the maximum N and
# is within the given target rectangle.  The final result is both an $n_max
# and a $x_max,$y_max which is its position, but only the $n_max is
# returned.
#
# At a given sub-part the comparisons ask whether x1 is above or below the
# midpoint, and likewise x2,y1,y2.  Since x2>=x1 and y2>=y1 there's only 3
# combinations of x1>=cmp,x2>=cmp, not 4.

# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### HilbertSpiral rect_to_n_range(): "$x1,$y1, $x2,$y2"

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  # If y1/y2 both positive or both negative then only look at the bigger of
  # the two.  If y1 negative and y2 positive then consider both.
  my $len = 1;
  my $level = 0;
  foreach my $z (($x2 > 0 ? ($x2) : ()),
                 ($x1 < 0 ? ($x1) : ()),
                 ($y2 > 0 ? ($y2) : ()),
                 ($y1 < 0 ? ($y1) : ())) {
    my ($zlen, $zlevel) = _y_round_down_len_level ($z);
    ### y len/level: "$zlen  $zlevel"
    if ($zlevel > $level) {
      $level = $zlevel;
      $len = $zlen;
    }
  }
  if (_is_infinite($len)) {
    return (0, $len);
  }

  # At this point an easy over-estimate would be:
  # return (0, $len*$len*4-1);

  my $n_min = my $n_max = 0;
  my $x_min = my $x_max = my $y_min = my $y_max
    = - (4**int(($level+1)/2) - 1) * 2 / 3;
  my $min_state = my $max_state = ($level & 1 ? 20 : 16);
  ### $x_min
  ### $y_min

  while ($level >= 0) {
    ### $level
    ### $len
    {
      my $x_cmp = $x_min + $len;
      my $y_cmp = $y_min + $len;
      my $digit = $min_digit[3*$min_state
                             + ($x1 >= $x_cmp ? 2 : $x2 >= $x_cmp ? 1 : 0)
                             + ($y1 >= $y_cmp ? 6 : $y2 >= $y_cmp ? 3 : 0)];

      $n_min = 4*$n_min + $digit;
      $min_state += $digit;
      if ($digit_to_x[$min_state]) { $x_min += $len; }
      $y_min += $len * $digit_to_y[$min_state];
      $min_state = $next_state[$min_state];
    }
    {
      my $x_cmp = $x_max + $len;
      my $y_cmp = $y_max + $len;
      my $digit = $max_digit[3*$max_state
                             + ($x1 >= $x_cmp ? 2 : $x2 >= $x_cmp ? 1 : 0)
                             + ($y1 >= $y_cmp ? 6 : $y2 >= $y_cmp ? 3 : 0)];

      $n_max = 4*$n_max + $digit;
      $max_state += $digit;
      if ($digit_to_x[$max_state]) { $x_max += $len; }
      $y_max += $len * $digit_to_y[$max_state];
      $max_state = $next_state[$max_state];
    }

    $len = int($len/2);
    $level--;
  }

  return ($n_min, $n_max);
}

1;
__END__


=for stopwords HilbertCurve eg Ryde ie BetaOmega Math-PlanePath HilbertSpiral

=head1 NAME

Math::PlanePath::HilbertSpiral -- 2x2 self-similar spiral

=head1 SYNOPSIS

 use Math::PlanePath::HilbertSpiral;
 my $path = Math::PlanePath::HilbertSpiral->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is a Hilbert curve variation which fills the plane by spiralling around
into negative X,Y on every second replication level.

    ..--63--62  49--48--47  44--43--42        5
             |   |       |   |       |
        60--61  50--51  46--45  40--41        4
         |           |           |
        59  56--55  52  33--34  39--38        3
         |   |   |   |   |   |       |
        58--57  54--53  32  35--36--37        2
                         |
         5-- 4-- 3-- 2  31  28--27--26        1
         |           |   |   |       |
         6-- 7   0-- 1  30--29  24--25    <- Y=0
             |                   |
         9-- 8  13--14  17--18  23--22       -1
         |       |   |   |   |       |
        10--11--12  15--16  19--20--21       -2

        -2  -1  X=0  1   2   3   4   5

The curve starts with the same N=0 to N=3 as the HilbertCurve, then the
following 2x2 blocks N=4 to N=15 go around in negative X,Y.  The top-left
corner for this negative direction is at Ntopleft=4^level-1 for an odd
numbered level.

The parts of the curve in the X,Y negative parts are the same as the plain
HilbertCurve, just mirrored along the anti-diagonal.  For example. N=4 to
N=15

    HilbertSpiral             HilbertCurve
     (mirror)                    (plain)

                  \        5---6   9--10
                   \       |   |   |   |
                    \      4   7---8  11
                     \                 |
      5-- 4           \           13--12
      |                \           |
      6-- 7             \         14--15
          |              \
      9-- 8  13--14       \
      |       |   |        \
     10--11--12  15

This mirroring has the effect of mapping

    HilbertCurve X,Y  ->  -Y,-X for HilbertSpiral

Notice the coordinate difference (-Y)-(-X) = X-Y so that difference,
representing a projection onto the X=-Y diagonal, is the same in both paths.

=head2 Level Ranges

Reckoning the initial N=0 to N=3 as level 1, a replication level extends to

    Nstart = 0
    Nlevel = 4^level - 1    (inclusive)

    Xmin = Ymin = - (4^floor(level/2) - 1) * 2 / 3
                = binary 1010...10
    Xmax = Ymax = (4^ceil(level/2) - 1) / 3
                = binary 10101...01

    width = height = Xmax - Xmin
                   = Ymax - Ymin
                   = 2^level - 1

The X,Y range doubles alternately above and below, so the result is a 1 bit
going alternately to the max or min, starting with the max for level 1.

    level     X,Ymin   binary      X,Ymax  binary
    -----     ---------------      --------------
      0         0                    0
      1         0          0         1 =       1
      2        -2 =      -10         1 =      01
      3        -2 =     -010         5 =     101
      4       -10 =    -1010         5 =    0101
      5       -10 =   -01010        21 =   10101
      6       -42 =  -101010        21 =  010101
      7       -42 = -0101010        85 = 1010101

The power-of-4 formulas above for Ymin/Ymax have the effect of producing
alternating bit patterns like this.

This is the same sort of level range as BetaOmega has on its Y coordinate,
but on this HilbertSpiral it applies to both X and Y.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::HilbertSpiral-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

The returned range is exact, meaning C<$n_lo> and C<$n_hi> are the smallest
and biggest in the rectangle.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::HilbertCurve>,
L<Math::PlanePath::BetaOmega>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011, 2012 Kevin Ryde

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

# Local variables:
# compile-command: "math-image --path=HilbertSpiral --lines"
# End:

# math-image --path=HilbertSpiral --all --output=numbers_dash
