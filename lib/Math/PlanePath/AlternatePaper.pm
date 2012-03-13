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


# math-image --path=AlternatePaper --output=numbers --all
# math-image --path=AlternatePaper --expression='i<=64?i:0' --output=numbers --size=60

# sum X+Y A020986 partial sums of golay-rudin-shapiro
#   A020985 +/-1 parity of count of 11 bit pairs
#   (except initial 0)
# diff X-Y A020990 sum 0 to k of (-1)^k * GolayRudinShapiro(k)
#   (except initial 0)
#
# A134452 dX balanced ternary digital root
#            sum of digits (keeping sign)
# A056594 

package Math::PlanePath::AlternatePaper;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 72;

use Math::PlanePath 54; # v.54 for _max()
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;


use constant n_start => 0;
use constant class_x_negative => 0;
use constant class_y_negative => 0;

my @rot_to_sx = (1,0,-1,0);
my @rot_to_sy = (0,1,0,-1);

sub n_to_xy {
  my ($self, $n) = @_;
  ### AlternatePaper n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n, $n); }

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;  # inherit possible BigFloat
    $n = $int;          # BigFloat int() gives BigInt, use that
  }

  my $zero = ($n * 0);  # inherit bignum 0

  my @digits;
  my @sx;
  my @sy;
  {
    my $sy = $zero;   # inherit BigInt
    my $sx = $sy + 1; # inherit BigInt
    ### $sx
    ### $sy

    while ($n) {
      push @digits, ($n % 2);
      $n = int($n/2);
      push @sx, $sx;
      push @sy, $sy;

      # (sx,sy) + rot+90(sx,sy)
      ($sx,$sy) = ($sx - $sy,
                   $sy + $sx);

      push @digits, ($n % 2);
      $n = int($n/2);
      push @sx, $sx;
      push @sy, $sy;

      # (sx,sy) + rot-90(sx,sy)
      ($sx,$sy) = ($sx + $sy,
                   $sy - $sx);
    }
  }

  ### @digits
  my $rot = 0;
  my $rev = 0;
  my $x = $zero;
  my $y = $zero;
  while (defined (my $digit = pop @digits)) {
    {
      my $sx = pop @sx;
      my $sy = pop @sy;
      ### at: "$x,$y  $digit   side $sx,$sy"
      ### $rot

      if ($rot & 2) {
        ($sx,$sy) = (-$sx,-$sy);
      }
      if ($rot & 1) {
        ($sx,$sy) = (-$sy,$sx);
      }

      if ($rev) {
        if ($digit) {
          $x -= $sy;
          $y += $sx;
          ### rev add to: "$x,$y next is still rev"
        } else {
          $rot ++;
          $rev = 0;
        }
      } else {
        if ($digit) {
          $rot ++;
          $x += $sx;
          $y += $sy;
          $rev = 1;
          ### add to: "$x,$y next is rev"
        }
      }
    }

    $digit = pop @digits;
    last if ! defined $digit;

    {
      my $sx = pop @sx;
      my $sy = pop @sy;
      ### at: "$x,$y  $digit   side $sx,$sy"
      ### $rot

      if ($rot & 2) {
        ($sx,$sy) = (-$sx,-$sy);
      }
      if ($rot & 1) {
        ($sx,$sy) = (-$sy,$sx);
      }

      if ($rev) {
        if ($digit) {
          $x += $sy;
          $y -= $sx;
          ### rev add to: "$x,$y next is still rev"
        } else {
          $rot --;
          $rev = 0;
        }
      } else {
        if ($digit) {
          $rot --;
          $x += $sx;
          $y += $sy;
          $rev = 1;
          ### add to: "$x,$y next is rev"
        }
      }
    }
  }
  if ($rev) {
    $rot += 2;
  }
  $rot &= 3;
  $x = $frac * $rot_to_sx[$rot] + $x;
  $y = $frac * $rot_to_sy[$rot] + $y;

  ### final: "$x,$y"
  return ($x,$y);
}


#                                                      8
#
#                                          42   43     7
#
#                                    40 41/45   44     6
#
#                              34 35/39 38/46   47     5
#
#                        32-33/53-36/52-37/49---48     4
#                        | \
#                  10 11/31 30/54 51/55 50/58   59     3
#                        |       \
#             8  9/13 12/28 25/29 24/56 57/61   60     2
#                        |             \
#       2   3/7  6/14 15/27 18/26 19/23 22/62   63     1
#                        |                   \
# 0     1     4     5    16    17    20    21 ==64     0
#
# 0     1     2     3     4     5     6     7    8

sub xy_to_n {
  return scalar((shift->xy_to_n_list(@_))[0]);
}
sub xy_to_n_list {
  my ($self, $x, $y) = @_;
  ### AlternatePaper xy_to_n(): "$x, $y"

  $x = _round_nearest($x);
  $y = _round_nearest($y);

  my ($len,$level) = _round_down_pow($x, 2);
  ### $len
  ### $level

  if (_is_infinite($level)) {
    return $level;  # infinity
  }

  if ($y < 0 || $y > $x || $x < 0) {
    ### outside first octant ...
    return;
  }

  my $n = my $big_n = $x * 0 * $y;  # inherit bignum 0
  my $rev = 0;

  my $big_x = $x;
  my $big_y = $y;
  my $big_rev = 0;

  while ($level-- >= 0) {
    ### at: "$x,$y  len=$len  n=$n"

    {
      $n *= 4;
      if ($rev) {
        if ($x+$y < 2*$len) {
          ### rev 0 or 1 ...
          if ($x < $len) {
          } else {
            ### rev 1 ...
            $rev = 0;
            $n -= 2;
            ($x,$y) = ($len-$y, $x-$len);   # x-len,y-len then rotate +90
          }

        } else {
          ### rev 2 or 3 ...
          if ($y > $len || ($x==$len && $y==$len)) {
            ### rev 2 ...
            $n -= 2;
            $x -= $len;
            $y -= $len;
          } else {
            ### rev 3 ...
            $n -= 4;
            $rev = 0;
            ($x,$y) = ($y, 2*$len-$x);   # to origin then rotate -90
          }
        }
      } else {
        if ($x+$y <= 2*$len
            && !($x==$len && $y==$len)
            && !($x==2*$len && $y==0)) {
          ### 0 or 1 ...
          if ($x <= $len) {
          } else {
            ### 1 ...
            $n += 2;
            $rev = 1;
            ($x,$y) = ($len-$y, $x-$len);   # x-len,y-len then rotate +90
          }

        } else {
          ### 2 or 3 ...
          if ($y >= $len && !($x==2*$len && $y==$len)) {
            $n += 2;
            $x -= $len;
            $y -= $len;
          } else {
            $n += 4;
            $rev = 1;
            ($x,$y) = ($y, 2*$len-$x);   # to origin then rotate -90
          }
        }
      }
    }
    {
      $big_n *= 4;
      if ($big_rev) {
        if ($big_x+$big_y <= 2*$len
            && !($big_x==$len && $big_y==$len)
            && !($big_x==2*$len && $big_y==0)) {
          ### rev 0 or 1 ...
          if ($big_x <= $len) {
          } else {
            ### rev 1 ...
            $big_rev = 0;
            $big_n -= 2;
            ($big_x,$big_y) = ($len-$big_y, $big_x-$len);   # x-len,y-len then rotate +90
          }

        } else {
          ### rev 2 or 3 ...
          if ($big_y >= $len && !($big_x==2*$len && $big_y==$len)) {
            ### rev 2 ...
            $big_n -= 2;
            $big_x -= $len;
            $big_y -= $len;
          } else {
            ### rev 3 ...
            $big_n -= 4;
            $big_rev = 0;
            ($big_x,$big_y) = ($big_y, 2*$len-$big_x);   # to origin then rotate -90
          }
        }
      } else {
        if ($big_x+$big_y < 2*$len) {
          ### 0 or 1 ...
          if ($big_x < $len) {
          } else {
            ### 1 ...
            $big_n += 2;
            $big_rev = 1;
            ($big_x,$big_y) = ($len-$big_y, $big_x-$len);   # x-len,y-len then rotate +90
          }

        } else {
          ### 2 or 3 ...
          if ($big_y > $len || ($big_x==$len && $big_y==$len)) {
            $big_n += 2;
            $big_x -= $len;
            $big_y -= $len;
          } else {
            $big_n += 4;
            $big_rev = 1;
            ($big_x,$big_y) = ($big_y, 2*$len-$big_x);   # to origin then rotate -90
          }
        }
      }
    }
    $len /= 2;
  }

  if ($x) {
    $n += ($rev ? -1 : 1);
  }
  if ($big_x) {
    $big_n += ($big_rev ? -1 : 1);
  }

  ### final: "$x,$y  n=$n  rev=$rev"
  ### final: "$x,$y  big_n=$n  big_rev=$rev"

  return ($n, ($n == $big_n ? () : ($big_n)));
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### AlternatePaper rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = _round_nearest($x1);
  $x2 = _round_nearest($x2);
  $y1 = _round_nearest($y1);
  $y2 = _round_nearest($y2);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  if ($x2 < 0 || $y2 < 0 || $y1 > $x2) {
    # outside first octant
    return (1,0);
  }

  my ($len, $level) =_round_down_pow ($x2, 2);
  return (0, 4*$len*$len-1);
}

1;
__END__

=for stopwords eg Ryde Math-PlanePath Nlevel et al vertices doublings OEIS Online DragonCurve ZOrderCurve 0xAA

=head1 NAME

Math::PlanePath::AlternatePaper -- alternate paper folding curve

=head1 SYNOPSIS

 use Math::PlanePath::AlternatePaper;
 my $path = Math::PlanePath::AlternatePaper->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is the alternate paper folding curve (a variation on the DragonCurve
paper folding),

      8 |                                                      128
        |                                                       |
      7 |                                                42---43/127 
        |                                                |      |
      6 |                                         40---41/45--44/124
        |                                         |      |      |
      5 |                                  34---35/39--38/46--47/123
        |                                  |      |      |      |
      4 |                           32---33/53--36/52--37/49--48/112
        |                           |      |      |      |      | 
      3 |                    10---11/31--30/54--51/55--50/58--59/111 
        |                    |      |      |      |      |      |  
      2 |              8----9/13--12/28--29/25--24/56--57/61--60/108 
        |              |     |      |      |      |      |      |          
      1 |        2----3/7---6/14--15/27--26/18--19/23---22/62--63/107
        |        |     |     |      |      |      |      |      |
    Y=0 |  0-----1     4-----5     16-----17     20-----21     64---..
        |
        +------------------------------------------------------------
          X=0    1     2     3      4      5      6      7      8

The curve visits the X axis and X=Y diagonal points once each, and visits
"inside" points between there twice.  The first doubled point is X=2,Y=1
which is N=3 and also N=7.  The segments N=2,3,4 and N=6,7,8 have touched,
but the curve doesn't cross over itself.  The doubled vertices are all like
this, touching but not crossing, and no edges repeat.

The first step N=1 is to the right along the X axis and the path fills the
eighth of the plane up to the X=Y diagonal, inclusive.

The X axis N=0,1,4,5,16,17,etc are the integers which have only digits 0 and
1 in base 4, or equivalently those which have a 0 bit at each even numbered
bit position.

The X=Y diagonal N=0,2,8,10,32,etc are the integers which have only digits 0
and 2 in base 4, or equivalently which have a 0 bit at each odd numbered bit
position.

The X axis values are the same as on the ZOrderCurve X axis, and the X=Y
diagonal is the same as the ZOrderCurve Y axis, but in between the two are
quite different.

=head2 Paper Folding

The curve arises from thinking of a strip of paper folded in half
alternately one way and the other, then unfolded so each crease is a 90
degree angle.  The effect is that the curve repeats in successive doublings
turned by 90 degrees and reversed.

The first segment N=0 to N=1 unfolds, pivoting at the end "1",

                                    2
                               ->   |
                 unfold       /     |
                  ===>       |      |
                                    |
    0------1                0-------1

Then that "L" shape unfolds again, pivoting at the end "2", but on the
opposite side to the first unfold,

                                    2-------3
           2                        |       |
           |     unfold             |   ^   |
           |      ===>              | _/    |
           |                        |       |
    0------1                0-------1       4

In general after each unfold the shape is a triangle,

               .                       .
              /|                      / \
             / |                     /   \
            /  |                    /     \
           /   |                   /       \
          /    |                  /         \
         /_____|                 /___________\
        0,0                     0,0

    after even number          after odd number
       of unfolds,                of unfolds,
     N=0 to N=2^even            N=0 to N=2^odd

For an even number of unfolds, the triangle consists of 4 sub-parts numbered
by the high digit of N in base 4.  Those sub-parts are self-similar in the
direction "E<gt>" etc shown, and with a reversal for parts 1 and 3.

              +
             /|
            / |
           /  |
          / 2>|
         +----+
        /|\  3|
       / | \ v|
      /  |^ \ |
     / 0>| 1 \|
    +----+----+

=head2 Turns

At each point N the curve always turns either to the left or right, it never
goes straight ahead.  The turn is given by the bit above the lowest 1 bit in
N and whether that position is odd or even.

    N = 0b...z100..00   (possibly no trailing 0s)
             ^
             pos, counting from 0 for least significant bit

    (z bit) XOR (pos&1)   Turn
    -------------------   ----
             0            right
             1            left

For example N=10 binary 0b1010, the lowest 1 bit is the 0b__1_ and the bit
above that is a 0 at even number pos=2, so turn to the right.

The bits also give the turn after next by looking at the bit above the
lowest 0.

    N = 0b...w011..11    (possibly no trailing 1s)
             ^
             pos, counting from 0 for least significant bit

    (w bit) XOR (pos&1)    Next Turn
    -------------------    ---------
             0             right
             1             left

For example at N=10=0b1010 the lowest 0 is the least significant bit, and
above that is a 1 at odd pos=1, so turn right.

The inversion for odd bit positions can be applied with an xor 0xAA..AA,
after which the calculations are the sames as the DragonCurve (see
L<Math::PlanePath::DragonCurve/Turns>).

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::AlternatePaper-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer points.

=item C<@n_list = $path-E<gt>xy_to_n_list ($x,$y)>

Return a list of N point numbers for coordinates C<$x,$y>.  There can be
none, one or two N's for a given C<$x,$y>.

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 OEIS

The alternate paper folding curve is in Sloane's Online Encyclopedia of
Integer Sequences as,

    http://oeis.org/A106665

    A106665 -- turn, 1=left,0=right, starting at N=1

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DragonCurve>,
L<Math::PlanePath::ZOrderCurve>

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
