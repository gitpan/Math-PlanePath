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


# math-image --path=CornerReplicate --all --output=numbers_dash --size=80x50
#


package Math::PlanePath::CornerReplicate;
use 5.004;
use strict;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 86;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'round_down_pow',
  'bit_split_lowtohigh',
  'digit_split_lowtohigh';

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;
use constant class_x_negative => 0;
use constant class_y_negative => 0;

my @digit_to_x = (0,1,1,0);
my @digit_to_y = (0,0,1,1);

sub n_to_xy {
  my ($self, $n) = @_;
  ### CornerReplicate n_to_xy(): $n

  if ($n < 0) { return; }
  if (is_infinite($n)) { return ($n,$n); }

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

  foreach my $digit (digit_split_lowtohigh($n,4)) {
    ### at: "$x,$y  digit=$digit"

    $x += $digit_to_x[$digit] * $len;
    $y += $digit_to_y[$digit] * $len;
    $len *= 2;
  }

  ### final: "$x,$y"
  return ($x,$y);
}

# my @yx_to_digit = ([0,1],
#                    [3,2]);
sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### CornerReplicate xy_to_n(): "$x, $y"

  $x = round_nearest ($x);
  $y = round_nearest ($y);
  if ($x < 0 || $y < 0) {
    return undef;
  }
  if (is_infinite($x)) {
    return $x;
  }
  if (is_infinite($y)) {
    return $y;
  }

  my @x = bit_split_lowtohigh($x);
  my @y = bit_split_lowtohigh($y);

  my $n = ($x * 0 * $y); # inherit bignum 0
  foreach my $i (reverse 0 .. max($#x,$#y)) {  # high to low
    $n *= 4;
    my $ydigit = $y[$i] || 0;
    $n += 2*$ydigit + (($x[$i]||0) ^ $ydigit);
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

  $x1 = round_nearest ($x1);
  $y1 = round_nearest ($y1);
  $x2 = round_nearest ($x2);
  $y2 = round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### rect: "X = $x1 to $x2, Y = $y1 to $y2"

  if ($x2 < 0 || $y2 < 0) {
    ### rectangle outside first quadrant ...
    return (1, 0);
  }

  my ($len, $level) = round_down_pow (max($x2,$y2), 2);
  ### $len
  ### $level
  if (is_infinite($level)) {
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
#   $x = round_nearest ($x);
#   $y = round_nearest ($y);
#   if ($x < 0 || $y < 0) {
#     return undef;
#   }
# 
#   my ($len, $level) = round_down_pow (max($x,$y),
#                                        2);
#   if (is_infinite($level)) {
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


=for stopwords eg Ryde Math-PlanePath SierpinskiCurve ZOrderCurve OEIS

=head1 NAME

Math::PlanePath::CornerReplicate -- replicating U parts

=head1 SYNOPSIS

 use Math::PlanePath::CornerReplicate;
 my $path = Math::PlanePath::CornerReplicate->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path is a self-similar replicating corner fill with 2x2 blocks.  It's
sometimes called a "U order".

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

The X axis N=0,1,4,5,16,17,etc is all the integers which use only
digits 0 and 1 in base 4.  For example N=17 is 101 in base 4.

The Y axis N=0,3,12,15,48,etc is all the integers which use only digits 0
and 3 in base 4.  For example N=51 is 303 in base 4.

And the X=Y diagonal values N=0,2,8,10,32,34,etc is all the integers which
use only digits 0 and 2 in base 4.

The X axis is the same as the ZOrderCurve, and the Y axis here is the X=Y
diagonal of the ZOrderCurve, and conversely the X=Y diagonal here is the Y
axis of the ZOrderCurve.  In general the N value at a given X,Y is converted
to or from the ZOrderCurve by changing base 4 digit values 2 to 3 and 3
to 2.

=head2 Level Ranges

A given replication extends to

    Nlevel = 4^level - 1
    - (2^level - 1) <= X <= (2^level - 1)
    - (2^level - 1) <= Y <= (2^level - 1)

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

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

=head1 OEIS

This path is in Sloane's Online Encyclopedia of Integer Sequences as

    http://oeis.org/A000695  (etc)

    A059906    Y coordinate

    A000695    N on X axis, base 4 digits 0,1 only
    A001196    N on Y axis, base 4 digits 0,3 only
    A062880    N on diagonal, base 4 digits 0,2 only
    A163241    base-4 flip 2<->3,
                 converts N to ZOrderCurve N (and back)

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::LTiling>,
L<Math::PlanePath::SquareReplicate>,
L<Math::PlanePath::GosperReplicate>,
L<Math::PlanePath::ZOrderCurve>,
L<Math::PlanePath::GrayCode>

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
