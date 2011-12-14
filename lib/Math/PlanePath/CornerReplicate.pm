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


package Math::PlanePath::CornerReplicate;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 59;

use Math::PlanePath 54; # v.54 for _max()
@ISA = ('Math::PlanePath');

*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;
use constant x_negative => 0;
use constant y_negative => 0;

my @digit_to_x = (0,1,1,0);
my @digit_to_y = (0,0,1,1);

sub n_to_xy {
  my ($self, $n) = @_;
  ### CornerReplicate n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  {
    my $int = int($n);
    ### $int
    ### $n
    if ($n != $int) {
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $frac = $n - $int;  # inherit possible BigFloat
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int;       # BigFloat int() gives BigInt, use that
  }

  my $x = my $y = ($n * 0);  # inherit bignum 0
  my $len = $x + 1;          # inherit bignum 1

  while ($n) {
    my $digit = $n % 4;
    $n = int($n/4);
    ### at: "$x,$y"
    ### $digit

    $x += $digit_to_x[$digit] * $len;
    $y += $digit_to_y[$digit] * $len;
    $len *= 2;
  }

  ### final: "$x,$y"
  return ($x,$y);
}

my @yx_to_digit = ([0,1],
                   [3,2]);
sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### CornerReplicate xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($x < 0 || $y < 0) {
    return undef;
  }
  if (_is_infinite($x)) {
    return $x;
  }
  if (_is_infinite($y)) {
    return $y;
  }

  my $power = ($x * 0 * $y) + 1;  # inherit bignum 0
  my $n = 0;
  while ($x || $y) {
    ### digit: $yx_to_digit[$y % 2]->[$x % 2]

    $n = $n + $power * $yx_to_digit[$y % 2]->[$x % 2];
    $x = int($x/2);
    $y = int($y/2);
    $power *= 4;
  }
  return $n;
}

# these tables generated by tools/corner-replicate-table.pl
my @min_digit = (0,0,1, 0,0,1, 3,2,2);
my @max_digit = (0,1,1, 3,3,2, 3,3,2);

# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### CornerReplicate rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### rect: "X = $x1 to $x2, Y = $y1 to $y2"

  if ($x2 < 0 || $y2 < 0) {
    ### rectangle outside first quadrant ...
    return (1, 0);
  }

  my ($len, $level) = _round_down_pow (_max($x2,$y2), 2);
  ### $len
  ### $level
  if (_is_infinite($level)) {
    return (0,$level);
  }

  my $n_min = my $n_max
    = my $x_min = my $y_min
      = my $x_max = my $y_max
        = ($x1 * 0 * $x2 * $y1 * $y2); # inherit bignum 0

  while ($level-- >= 0) {
    ### $level

    {
      my $x_cmp = $x_max + $len;
      my $y_cmp = $y_max + $len;
      my $digit = $max_digit[($x1 >= $x_cmp ? 2 : $x2 >= $x_cmp ? 1 : 0)
                             + ($y1 >= $y_cmp ? 6 : $y2 >= $y_cmp ? 3 : 0)];
      $n_max = 4*$n_max + $digit;
      if ($digit_to_x[$digit]) { $x_max += $len; }
      if ($digit_to_y[$digit]) { $y_max += $len; }

      # my $key = ($x1 >= $x_cmp ? 2 : $x2 >= $x_cmp ? 1 : 0)
      #   + ($y1 >= $y_cmp ? 6 : $y2 >= $y_cmp ? 3 : 0);
      ### max ...
      ### len:  sprintf "%#X", $len
      ### $x_cmp
      ### $y_cmp
      # ### $key
      ### $digit
      ### n_max: sprintf "%#X", $n_max
      ### $x_max
      ### $y_max
    }

    {
      my $x_cmp = $x_min + $len;
      my $y_cmp = $y_min + $len;
      my $digit = $min_digit[($x1 >= $x_cmp ? 2 : $x2 >= $x_cmp ? 1 : 0)
                             + ($y1 >= $y_cmp ? 6 : $y2 >= $y_cmp ? 3 : 0)];
      $n_min = 4*$n_min + $digit;
      if ($digit_to_x[$digit]) { $x_min += $len; }
      if ($digit_to_y[$digit]) { $y_min += $len; }

      # my $key = ($x1 >= $x_cmp ? 2 : $x2 >= $x_cmp ? 1 : 0)
      #   + ($y1 >= $y_cmp ? 6 : $y2 >= $y_cmp ? 3 : 0);
      ### min ...
      ### len:  sprintf "%#X", $len
      ### $x_cmp
      ### $y_cmp
      # ### $key
      ### $digit
      ### n_min: sprintf "%#X", $n_min
      ### $x_min
      ### $y_min
    }
    $len /= 2;
  }

  return ($n_min, $n_max);
}

1;
__END__

# This version going top down.
#
# sub xy_to_n {
#   my ($self, $x, $y) = @_;
#   ### CornerReplicate xy_to_n(): "$x, $y"
# 
#   $x = _round_nearest ($x);
#   $y = _round_nearest ($y);
#   if ($x < 0 || $y < 0) {
#     return undef;
#   }
# 
#   my ($len, $level) = _round_down_pow (_max($x,$y),
#                                        2);
#   if (_is_infinite($level)) {
#     return $level;
#   }
# 
#   my $n = ($x * 0 * $y);  # inherit bignum 0
#   while ($level-- >= 0) {
#     ### $level
#     ### $len
#     ### n: sprintf '0x%X', $n
#     ### $x
#     ### $y
#     ### assert: $x >= 0
#     ### assert: $y >= 0
#     ### assert: $x < 2*$len
#     ### assert: $x < 2*$len
# 
#     $n *= 4;
#     if ($x < $len) {
#       # left
#       if ($y >= $len) {
#         $n += 3;  # top left
#         $y -= $len;
#       }
#     } else {
#       # right
#       $x -= $len;
#       if ($y < $len) {
#         $n += 1;  # bottom right
#       } else {
#         $n += 2;  # top right
#         $y -= $len;
#       }
#     }
#     $len /= 2;
#   }
#   return $n;
# }


=for stopwords eg Ryde Math-PlanePath SierpinskiCurve

=head1 NAME

Math::PlanePath::CornerReplicate -- replicating squares

=head1 SYNOPSIS

 use Math::PlanePath::CornerReplicate;
 my $path = Math::PlanePath::CornerReplicate->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path is a self-similar replicating corner fill,

     7  | 63--62  59--58  47--46  43--42  
        |      |       |       |       |  
     6  | 60--61  56--57  44--45  40--41  
        |          |               |      
     5  | 51--50  55--54  35--34  39--38  
        |      |       |       |       |  
     4  | 48--49  52--53  32--33  36--37  
        |                  |              
     3  | 15--14  11--10  31--30  27--26  
        |      |       |       |       |  
     2  | 12--13   8-- 9  28--29  24--25  
        |          |               |      
     1  |  3-- 2   7-- 6  19--18  23--22  
        |      |       |       |       |  
    Y=0 |  0-- 1   4-- 5  16--17  20--21  
        +--------------------------------
          X=0  1   2   3   4   5   6   7

The pattern is the initial N=0 to N=3 section,

    +-------+-------+
    |       |       |
    |   3   |   2   |
    |       |       |
    +-------+-------+
    |       |       |
    |   0   |   1   |
    |       |       |
    +-------+-------+

It then repeats as 2x2 blocks arranged in the same pattern, then 4x4 blocks,
etc.

The N values along the Y axis 0,3,12,15,48,etc are all the numbers which use
only digits 0 and 3 in base 4.  For example N=51 is 303 in base 4.  Or
equivalently the values all have repeating bit pairs in binary, for example
N=48 is 110000 binary.  (Compare the SierpinskiCurve which has these along
the X axis.)

=head2 Level Ranges

A given replication extends to

    Nlevel = 4^level - 1
    - (2^level - 1) <= X <= (2^level - 1)
    - (2^level - 1) <= Y <= (2^level - 1)

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::CornerReplicate-E<gt>new ()>

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
L<Math::PlanePath::LTiling>,
L<Math::PlanePath::SquareReplicate>,
L<Math::PlanePath::GosperReplicate>,
L<Math::PlanePath::ZOrderCurve>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011 Kevin Ryde

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
# compile-command: "math-image --path=CornerReplicate --lines --scale=10"
# End:
#
# math-image --path=CornerReplicate --all --output=numbers_dash --size=80x50
