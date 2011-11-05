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
$VERSION = 53;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;


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

# (x mod 2) + 2*(y mod 2)
#
#  2 3    3 2
#  0 1    0 1
#
my @mod_to_digit = (0,3,1,2);

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### CornerReplicate xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($x < 0 || $y < 0) {
    return undef;
  }

  my ($len, $level) = _round_down_pow (($x > $y ? $x : $y) || 1,
                                       2);
  if (_is_infinite($level)) {
    return $level;
  }

  my $n = ($x * 0 * $y);  # inherit bignum 0
  while ($level-- >= 0) {
    ### $level
    ### $len
    ### n: sprintf '0x%X', $n
    ### $x
    ### $y

    $n *= 4;
    if ($x < $len) {
      # left
      if ($y >= $len) {
        $n += 3;  # top left
        $y -= $len;
      }
    } else {
      # right
      $x -= $len;
      if ($y < $len) {
        $n += 1;  # bottom right
      } else {
        $n += 2;  # top right
        $y -= $len;
      }
    }
    $len /= 2;
  }
  return $n;
}

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

  my ($len, $level) = _round_down_pow (($x2 > $y2 ? $x2 : $y2),
                                       2);
  ### $len
  ### $level
  if (_is_infinite($level)) {
    return (0,$level);
  }

  my $n_min = my $n_max
    = my $x_min = my $y_min
      = my $x_max = my $y_max
        = ($x1 * 0 * $x2 * $y1 * $y2); # inherit bignum 0

  my $i_min = my $i_max = ($level & 1) << 2;
  while ($level-- >= 0) {
    ### $len
    ### $level

    {
      my $x_cmp = $x_max + $len;
      my $y_cmp = $y_max + $len;

      my $digit;
      if ($y2 < $y_cmp) {
        # only bottom half covered
        if ($x2 < $x_cmp) {
          $digit = 0;  # bottom left only
        } else {
          $digit = 1;  # bottom right included
          $x_max += $len;
        }
      } else {
        # top half included
        $y_max += $len;
        if ($x1 >= $x_cmp) {
          $digit = 2;  # top right only
          $x_max += $len;
        } else {
          $digit = 3;  # top left included
        }
      }

      $n_max = 4*$n_max + $digit;
      ### max ...
      ### $digit
      ### n_max: sprintf "%#X", $n_max
      ### $x_max
      ### $y_max
      ### len:  sprintf "%#X", $len
    }

    {
      my $x_cmp = $x_min + $len;
      my $y_cmp = $y_min + $len;

      my $digit;
      if ($y1 >= $y_cmp) {
        # top half only
        $y_min += $len;
        if ($x2 < $x_cmp) {
          $digit = 3;  # top left only
        } else {
          # top included
          $digit = 2;  # top right included
          $x_min += $len;
        }
      } else {
        # bottom half included
        if ($x1 >= $x_cmp) {
          $digit = 1;  # bottom right only
          $x_min += $len;
        } else {
          $digit = 0;  # bottom left included
        }
      }

      $n_min = 4*$n_min + $digit;
      ### min ...
      ### $digit
      ### n_min: sprintf "%#X", $n_min
      ### $x_min
      ### $y_min
      ### len:  sprintf "%#X", $len
    }
    $len /= 2;
  }

  return ($n_min, $n_max);
}


1;
__END__

=for stopwords eg Ryde Math-PlanePath

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

=back

=head1 SEE ALSO

L<Math::PlanePath>,
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
