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




# math-image --path=SierpinskiCurve --lines --scale=10
#
# math-image --path=SierpinskiCurve --all --output=numbers_dash
#
# turn seq from low non-zero or N/2 low bit or something
# cf A039963
#


package Math::PlanePath::SierpinskiCurve;
use 5.004;
use strict;
#use List::Util 'min','max';
*min = \&Math::PlanePath::_min;
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 85;
use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_divrem_mutate = \&Math::PlanePath::_divrem_mutate;

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'round_down_pow',
  'digit_split_lowtohigh';

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;

sub x_negative {
  my ($self) = @_;
  return ($self->{'arms'} >= 3);
}
sub y_negative {
  my ($self) = @_;
  return ($self->{'arms'} >= 5);
}

use constant parameter_info_array =>
  [
   { name        => 'arms',
     share_key   => 'arms_8',
     type        => 'integer',
     minimum     => 1,
     maximum     => 8,
     default     => 1,
     width       => 1,
     description => 'Arms',
   },

   { name        => 'straight_spacing',
     display     => 'Straight Spacing',
     type        => 'integer',
     minimum     => 1,
     default     => 1,
     width       => 1,
     description => 'Spacing of the straight line points.',
   },
   { name        => 'diagonal_spacing',
     display     => 'Diagonal Spacing',
     type        => 'integer',
     minimum     => 1,
     default     => 1,
     width       => 1,
     description => 'Spacing of the diagonal points.',
   },
  ];

# Ntop = (4^level)/2 - 1
# Xtop = 3*2^(level-1) - 1
# fill = Ntop / (Xtop*(Xtop-1)/2)
#      -> 2 * ((4^level)/2 - 1) / (3*2^(level-1) - 1)^2
#      -> 2 * ((4^level)/2) / (3*2^(level-1))^2
#      =  4^level / (9*4^(level-1)
#      =  4/9 = 0.444


sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 8) { $arms = 8; }
  $self->{'arms'} = $arms;
  $self->{'straight_spacing'} ||= 1;
  $self->{'diagonal_spacing'} ||= 1;
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### SierpinskiCurve n_to_xy(): $n

  if ($n < 0) {
    return;
  }
  if (is_infinite($n)) {
    return ($n,$n);
  }

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;  # inherit possible BigFloat
    $n = $int; # BigFloat int() gives BigInt, use that
  }
  ### $frac

  my $arm = _divrem_mutate ($n, $self->{'arms'});

  my $s = $self->{'straight_spacing'};
  my $d = $self->{'diagonal_spacing'};
  my $base = 2*$d+$s;
  my $x = my $y = ($n * 0);  # inherit big 0
  my $len = $x + $base;      # inherit big

  foreach my $digit (digit_split_lowtohigh($n,4)) { # low to high base 4
    ### at: "$x,$y  digit=$digit"

    if ($digit == 0) {
      $x = $frac + $x;
      $y = $frac + $y;
      $frac = 0;

    } elsif ($digit == 1) {
      ($x,$y) = ($frac - $y + $len-$d-$s,   # rotate +90
                 $x + $d);
      $frac = 0;

    } elsif ($digit == 2) {
      # rotate -90
      ($x,$y) = ($frac + $y  + $len-$d,
                 -$frac - $x + $len-$d-$s);
      $frac = 0;

    } else { # digit==3
      $x += $len;
    }
    $len *= 2;
  }

  # n=0 or n=33..33
  $x = $frac + $x;
  $y = $frac + $y;

  $x += 1;
  if ($arm & 1) {
    ($x,$y) = ($y,$x);   # mirror 45
  }
  if ($arm & 2) {
    ($x,$y) = (-1-$y,$x);   # rotate +90
  }
  if ($arm & 4) {
    $x = -1-$x;   # rotate 180
    $y = -1-$y;
  }

  # use POSIX 'floor';
  # $x += floor($x/3);
  # $y += floor($y/3);

  # $x += floor(($x-1)/3) + floor(($x-2)/3);
  # $y += floor(($y-1)/3) + floor(($y-2)/3);


  ### final: "$x,$y"
  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### SierpinskiCurve xy_to_n(): "$x, $y"

  $x = round_nearest($x);
  $y = round_nearest($y);

  my $arm = 0;
  if ($y < 0) {
    $arm = 4;
    $x = -1-$x;  # rotate -180
    $y = -1-$y;
  }
  if ($x < 0) {
    $arm += 2;
    ($x,$y) = ($y, -1-$x);  # rotate -90
  }
  if ($y > $x) {       # second octant
    $arm++;
    ($x,$y) = ($y,$x); # mirror 45
  }

  my $arms = $self->{'arms'};
  if ($arm >= $arms) {
    return undef;
  }

  $x -= 1;
  if ($x < 0 || $x < $y) {
    return undef;
  }
  ### x adjust to zero: "$x,$y"
  ### assert: $x >= 0
  ### assert: $y >= 0

  my $s = $self->{'straight_spacing'};
  my $d = $self->{'diagonal_spacing'};
  my $base = (2*$d+$s);
  my ($len,$level) = round_down_pow (($x+$y)/$base || 1,  2);
  ### $level
  ### $len
  if (is_infinite($level)) {
    return $level;
  }

  # Xtop = 3*2^(level-1)-1
  #
  $len *= 2*$base;
  ### initial len: $len

  my $n = 0;
  foreach (0 .. $level) {
    $n *= 4;
    ### at: "loop=$_ len=$len   x=$x,y=$y  n=$n"
    ### assert: $x >= 0
    ### assert: $y >= 0

    my $len_sub_d = $len - $d;
    if ($x < $len_sub_d) {
      ### digit 0 or 1...
      if ($x+$y+$s < $len) {
        ### digit 0 ...
      } else {
        ### digit 1 ...
        ($x,$y) = ($y-$d, $len-$s-$d-$x);   # shift then rotate -90
        $n += 1;
      }
    } else {
      $x -= $len_sub_d;
      ### digit 2 or 3 to: "x=$x y=$y"
      if ($x < $y) {   # before diagonal
        ### digit 2...
        ($x,$y) = ($len-$d-$s-$y, $x);     # shift y-len then rotate +90
        $n += 2;
      } else {
        #### digit 3...
        $x -= $d;
        $n += 3;
      }
      if ($x < 0) {
        return undef;
      }
    }
    $len /= 2;
  }

  ### end at: "x=$x,y=$y   n=$n"
  ### assert: $x >= 0
  ### assert: $y >= 0

  $n *= 4;
  if ($y == 0 && $x == 0) {
    ### final digit 0 ...
  } elsif ($x == $d && $y == $d) {
    ### final digit 1 ...
    $n += 1;
  } elsif ($x == $d+$s && $y == $d) {
    ### final digit 2 ...
    $n += 2;
  } elsif ($x == $base && $y == 0) {
    ### final digit 3 ...
    $n += 3;
  } else {
    return undef;
  }

  return $n*$arms + $arm;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### SierpinskiCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = round_nearest ($x1);
  $x2 = round_nearest ($x2);
  $y1 = round_nearest ($y1);
  $y2 = round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  #   x1    *  x2 *
  #    +-----*-+y2*
  #    |      *|  *
  #    |       *  *
  #    |       |* *
  #    |       | **
  #    +-------+y1*
  #   ----------------
  #
  # arms=5 x1,y2 after X=Y-1 line, so x1 > y2-1, x1 >= y2
  # ************
  #      x1   *   x2
  #      +---*----+y2
  #      |  *     |
  #      | *      |
  #      |*       |
  #      *        |
  #     *+--------+y1
  #    *
  #
  # arms=7 x1,y1 after X=-2-Y line, so x1 > -2-y1
  # ************
  # ** +------+
  # * *|      |
  # *  *      |
  # *  |*     |
  # *  | *    |
  # *y1+--*---+
  # * x1   *
  #
  my $arms = $self->{'arms'};
  if (($arms <= 4
       ? ($y2 < 0  # y2 negative, nothing ...
          || ($arms == 1 && $x2 <= $y1)
          || ($arms == 2 && $x2 < 0)
          || ($arms == 3 && $x2 < -$y2))

       # arms >= 5
       : ($y2 < 0
          && (($arms == 5 && $x1 >= $y2)
              || ($arms == 6 && $x1 >= 0)
              || ($arms == 7 && $x1 > -2-$y1))))) {
    ### rect outside octants, for arms: $arms
    ### $x1
    ### $y2
    return (1,0);
  }

  my $max = ($x2 + $y2);
  if ($arms >= 3) {
    _apply_max ($max, -1-$x1 + $y2);

    if ($arms >= 5) {
      _apply_max ($max, -1-$x1 - $y1-1);

      if ($arms >= 7) {
        _apply_max ($max, $x2 - $y1-1);
      }
    }
  }

  # base=2d+s
  # level begins at
  #   base*(2^level-1)-s = X+Y     ... maybe
  #   base*2^level = X+base
  #   2^level = (X+base)/base
  #   level = log2((X+base)/base)
  # then
  #   Nlevel = 4^level-1

  my $base = 2 * $self->{'diagonal_spacing'} + $self->{'straight_spacing'};
  my ($power) = round_down_pow (int(($max+$base-2)/$base),
                                2);
  return (0, 4*$power*$power * $arms - 1);
}

sub _apply_max {
  ### _apply_max(): "$_[0] cf $_[1]"
  unless ($_[0] > $_[1]) {
    $_[0] = $_[1];
  }
}

1;
__END__







   #                                              63-64            14
   #                                               |  |
   #                                              62 65            13
   #                                             /     \
   #                                        60-61       66-67      12
   #                                         |              |
   #                                        59-58       69-68      11
   #                                             \     /
   #                                  51-52       57 70            10
   #                                   |  |        |  |
   #                                  50 53       56 71       ...   9
   #                                 /     \     /     \     /
   #                            48-49       54-55       72-73       8
   #                             |
   #                            47-46       41-40                   7
   #                                 \     /     \
   #                      15-16       45 42       39                6
   #                       |  |        |  |        |
   #                      14 17       44-43       38                5
   #                     /     \                 /
   #                12-13       18-19       36-37                   4
   #                 |              |        |
   #                11-10       21-20       35-34                   3
   #                     \     /                 \
   #           3--4        9 22       27-28       33                2
   #           |  |        |  |        |  |        |
   #           2  5        8 23       26 29       32                1
   #         /     \     /     \     /     \     /
   #     0--1        6--7       24-25       30-31                 Y=0
   #
   #  ^
   # X=0 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 ...


# The factor of 3 arises because there's a gap between each level, increasing
# it by a fixed extra each time,
#
#     length(level) = 2*length(level-1) + 2
#                   = 2^level + (2^level + 2^(level-1) + ... + 2)
#                   = 2^level + (2^(level+1)-1 - 1)
#                   = 3*2^level - 2




=for stopwords eg Ryde Waclaw Sierpinski Sierpinski's Math-PlanePath Nlevel CornerReplicate Nend Ntop Xlevel

=head1 NAME

Math::PlanePath::SierpinskiCurve -- Sierpinski curve

=head1 SYNOPSIS

 use Math::PlanePath::SierpinskiCurve;
 my $path = Math::PlanePath::SierpinskiCurve->new (arms => 2);
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

X<Sierpinski, Waclaw>This is an integer version of the self-similar curve by
Waclaw Sierpinski traversing the plane by right triangles.  The default is a
single arm of the curve in an eighth of the plane.


    10  |                                  31-32
        |                                 /     \
     9  |                               30       33
        |                                |        |
     8  |                               29       34
        |                                 \     /
     7  |                         25-26    28 35    37-38
        |                        /     \  /     \  /     \
     6  |                      24       27       36       39
        |                       |                          |
     5  |                      23       20       43       40
        |                        \     /  \     /  \     /
     4  |                 7--8    22-21    19 44    42-41    55-...
        |               /     \           /     \           /
     3  |              6        9       18       45       54
        |              |        |        |        |        |
     2  |              5       10       17       46       53
        |               \     /           \     /           \
     1  |        1--2     4 11    13-14    16 47    49-50    52
        |      /     \  /     \  /     \  /     \  /     \  /
    Y=0 |  .  0        3       12       15       48       51
        |
        +-----------------------------------------------------------
           ^
          X=0 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16

The tiling it represents is

                    /
                   /|\
                  / | \
                 /  |  \
                /  7| 8 \
               / \  |  / \
              /   \ | /   \
             /  6  \|/  9  \
            /-------|-------\
           /|\  5  /|\ 10  /|\
          / | \   / | \   / | \
         /  |  \ /  |  \ /  |  \
        /  1| 2 X 4 |11 X 13|14 \
       / \  |  / \  |  / \  |  / \ ...
      /   \ | /   \ | /   \ | /   \
     /  0  \|/  3  \|/  12 \|/  15 \
    ----------------------------------

The points are on a square grid with integer X,Y.  4 points are used in each
3x3 block.  In general a point is used if

    X%3==1 or Y%3==1 but not both

    which means
    ((X%3)+(Y%3)) % 2 == 1

The X axis N=0,3,12,15,48,etc are all the integers which use only digits 0
and 3 in base 4.  For example N=51 is 303 base 4.  Or equivalently the
values all have doubled bits in binary, for example N=48 is 110000 binary.
(Compare the CornerReplicate which also has these values along the X axis.)

=head2 Level Ranges

Counting the N=0 to N=3 as level=1, N=0 to N=15 as level 2, etc, the end of
each level, back at the X axis, is

    Nlevel = 4^level - 1
    Xlevel = 3*2^level - 2
    Ylevel = 0

For example level=2 is Nend = 2^(2*2)-1 = 15 at X=3*2^2-2 = 10.

The top of each level is half way along,

    Ntop = (4^level)/2 - 1
    Xtop = 3*2^(level-1) - 1
    Ytop = 3*2^(level-1) - 2

For example level=3 is Ntop = 2^(2*3-1)-1 = 31 at X=3*2^(3-1)-1 = 11 and
Y=3*2^(3-1)-2 = 10.

The factor of 3 arises from the three steps which make up the N=0,1,2,3
section.  The Xlevel width grows as

    Xlevel(1) = 3
    Xlevel(level+1) = 2*Xwidth(level) + 3

which dividing out the factor of 3 is 2*w+1, given 2^k-1 (in binary a left
shift and bring in a new 1 bit, giving 2^k-1).

Notice too the Nlevel points as a fraction of the triangular area
Xlevel*(Xlevel-1)/2 gives the 4 out of 9 points filled,

    FillFrac = Nlevel / (Xlevel*(Xlevel-1)/2)
            -> 4/9

=head2 Arms

The optional C<arms> parameter can draw multiple curves, each advancing
successively.  For example C<arms =E<gt> 2>,

                                  ...
                                   |
       33       39       57       63         11
      /  \     /  \     /  \     /
    31    35-37    41 55    59-61    62-..   10
      \           /     \           /
       29       43       53       60          9
        |        |        |        |
       27       45       51       58          8
      /           \     /           \
    25    21-19    47-49    50-52    56       7
      \  /     \           /     \  /
       23       17       48       54          6
                 |        |
        9       15       46       40          5
      /  \     /           \     /  \
     7    11-13    14-16    44-42    38       4
      \           /     \           /
        5       12       18       36          3
        |        |        |        |
        3       10       20       34          2
      /           \     /           \
     1     2--4     8 22    26-28    32       1
         /     \  /     \  /     \  /
        0        6       24       30      <- Y=0

     ^
    X=0 1  2  3  4  5  6  7  8  9 10 11

The N=0 point is at X=1,Y=0 (in all arms forms) so that the second arm is
within the first quadrant.

Anywhere between 1 and 8 arms can be done this way.  C<arms=E<gt>8> is as
follows.

           ...                       ...           6
            |                          |
           58       34       33       57           5
             \     /  \     /  \     /
    ...-59    50-42    26 25    41-49    56-...    4
          \           /     \           /
           51       18       17       48           3
            |        |        |        |
           43       10        9       40           2
          /           \     /           \
        35    19-11     2  1     8-16    32        1
          \  /     \           /     \  /
           27        3     .  0       24       <- Y=0

           28        4        7       31          -1
          /  \     /           \     /  \
        36    20-12     5  6    15-23    39       -2
          \           /     \           /
           44       13       14       47          -3
            |        |        |        |
           52       21       22       55          -4
          /           \     /           \
    ...-60    53-45    29 30    46-54    63-...   -5
             /     \  /     \  /     \
           61       37       38       62          -6
            |                          |
           ...                       ...          -7

                           ^
     -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6

The middle "." is the origin X=0,Y=0.  It would be more symmetrical to make
the origin the middle of the eight arms, at X=-0.5,Y=-0.5 in the above, but
that would give fractional X,Y values.  Apply an offset as X+0.5,Y+0.5 if
desired.

=head2 Spacing

The optional C<diagonal_spacing> and C<straight_spacing> can increase the
space between points diagonally or vertically/horizontally.  The default for
each is 1.

    $path = Math::PlanePath::SierpinskiCurve->new
               (straight_spacing => 2,
               (diagonal_spacing => 1)

The effect is only to spread the points.  In the level formulas above the
"3" factor becomes 2*d+s, effectively being the N=0 to N=3 section being
d+s+d.

    d = diagonal_spacing
    s = straight_spacing

    Xlevel = (2d+s)*(2^level - 1)  + 1

    Xtop = (2d+s)*2^(level-1) - d - s + 1
    Ytop = (2d+s)*2^(level-1) - d - s

=head2 Closed Curve

Sierpinski's original conception was a closed curve filling a unit square by
ever greater self-similar detail,

    /\_/\ /\_/\ /\_/\ /\_/\
    \   / \   / \   / \   /
     | |   | |   | |   | |
    / _ \_/ _ \ / _ \_/ _ \
    \/ \   / \/ \/ \   / \/
       |  |         | |
    /\_/ _ \_/\ /\_/ _ \_/\
    \   / \   / \   / \   /
     | |   | |   | |   | |
    / _ \ / _ \_/ _ \ / _ \
    \/ \/ \/ \   / \/ \/ \/
              | |
    /\_/\ /\_/ _ \_/\ /\_/\
    \   / \   / \   / \   /
     | |   | |   | |   | |
    / _ \_/ _ \ / _ \_/ _ \
    \/ \   / \/ \/ \   / \/
       |  |         | |
    /\_/ _ \_/\ /\_/ _ \_/\
    \   / \   / \   / \   /
     | |   | |   | |   | |
    / _ \ / _ \ / _ \ / _ \
    \/ \/ \/ \/ \/ \/ \/ \/

The code here might be pressed into use for this by drawing a mirror image
of the curve (N=0 through Nlevel above).  Or using the C<arms=E<gt>2> form
(N=0 to N=4^level, inclusive) and joining up the ends.

The curve is usually conceived as scaling down by quarters.  This can be had
with C<straight_spacing =E<gt> 2>, and then an offset to X+1,Y+1 to centre
in a 4*2^level square

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::SierpinskiCurve-E<gt>new ()>

=item C<$path = Math::PlanePath::SierpinskiCurve-E<gt>new (arms =E<gt> 8)>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SierpinskiCurveStair>,
L<Math::PlanePath::SierpinskiArrowhead>,
L<Math::PlanePath::KochCurve>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011, 2012 Kevin Ryde

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
