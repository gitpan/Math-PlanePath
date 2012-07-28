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


# math-image --path=DragonMidpoint --lines --scale=20
# math-image --path=DragonMidpoint --all --output=numbers_dash

# A006466 contfrac 2*sum( 1/2^(2^n)), 1 and 2 only
#    a(5n) recurrence ...
#    1,1,1,1, 2,
#    1,1,1,1,1,1,1, 2,
#    1,1,1,1, 2,
#    1,1,1,1, 2,
#    1, 2,
#    1,1,1,1, 2,
#    1,1,1,1,1,1,1, 2,
#    1,1,1,1, 2,
#    1, 2,
#    1,1,1,1,1,1,1, 2,
#    1,1,1,1, 2,
#    1, 2,
#    1,1,1,1, 2,
#    1,1,1,1, 2,
#    1,1,1,1,1,1,1, 2,
#    1,1,1,1, 2,
#    1, 2,
#    1,1,1,1,1,1,1, 2,
#    1,1,1,1, 2,
#    1,1,1,1, 2,
#    1, 2
# A076214   in decimal
#
# A073097 number of 4s - 6s - 2s - 1 is -1,0,1
# A081769 positions of 2s
# A073088 cumulative total multiples of 4 roughly, hence (4n-3-cum)/2
#
# A088435 (contfrac+1)/2 of sum(k>=1,1/3^(2^k)).
# A007404   in decimal
#


package Math::PlanePath::DragonMidpoint;
use 5.004;
use strict;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 83;
use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_divrem_mutate = \&Math::PlanePath::_divrem_mutate;

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'digit_split_lowtohigh';

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;
use constant parameter_info_array => [ { name      => 'arms',
                                         share_key => 'arms_4',
                                         type      => 'integer',
                                         minimum   => 1,
                                         maximum   => 4,
                                         default   => 1,
                                         width     => 1,
                                         description => 'Arms',
                                       } ];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 4) { $arms = 4; }
  $self->{'arms'} = $arms;
  return $self;
}

# sub n_to_xy {
#   my ($self, $n) = @_;
#   ### DragonMidpoint n_to_xy(): $n
#
#   if ($n < 0) { return; }
#   if (is_infinite($n)) { return ($n, $n); }
#
#   {
#     my $int = int($n);
#     if ($n != $int) {
#       my ($x1,$y1) = $self->n_to_xy($int);
#       my ($x2,$y2) = $self->n_to_xy($int+$self->{'arms'});
#       my $frac = $n - $int;  # inherit possible BigFloat
#       my $dx = $x2-$x1;
#       my $dy = $y2-$y1;
#       return ($frac*$dx + $x1, $frac*$dy + $y1);
#     }
#     $n = $int; # BigFloat int() gives BigInt, use that
#   }
#
#   my ($x1,$y1) = Math::PlanePath::DragonCurve->n_to_xy($n);
#   my ($x2,$y2) = Math::PlanePath::DragonCurve->n_to_xy($n+1);
#
#   my $dx = $x2-$x1;
#   my $dy = $y2-$y1;
#   return ($x1+$y1 + ($dx+$dy-1)/2,
#           $y1-$x1 + ($dy-$dx+1)/2);
# }

sub n_to_xy {
  my ($self, $n) = @_;
  ### DragonMidpoint n_to_xy(): $n

  if ($n < 0) { return; }
  if (is_infinite($n)) { return ($n, $n); }

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;  # inherit possible BigFloat
    $n = $int;          # BigFloat int() gives BigInt, use that
  }
  my $zero = ($n * 0);  # inherit bignum 0

  # arm as initial rotation
  my $rot = _divrem_mutate ($n, $self->{'arms'});

  ### $arms
  ### rot from arm: $rot
  ### $n

  # ENHANCE-ME: sx,sy just from len,len
  my @digits = digit_split_lowtohigh($n,2);
  my @sx;
  my @sy;

  {
    my $sx = $zero + 1;
    my $sy = -$sx;
    foreach (@digits) {
      push @sx, $sx;
      push @sy, $sy;

      # (sx,sy) + rot+90(sx,sy)
      ($sx,$sy) = ($sx - $sy,
                   $sy + $sx);
    }
  }

  ### @digits
  my $rev = 0;
  my $x = $zero;
  my $y = $zero;
  my $above_low_zero = 0;

  for (my $i = $#digits; $i >= 0; $i--) {     # high to low
    my $digit = $digits[$i];
    my $sx = $sx[$i];
    my $sy = $sy[$i];
    ### at: "$x,$y  $digit   side $sx,$sy"
    ### $rot

    if ($rot & 2) {
      $sx = -$sx;
      $sy = -$sy;
    }
    if ($rot & 1) {
      ($sx,$sy) = (-$sy,$sx);
    }
    ### rotated side: "$sx,$sy"

    if ($rev) {
      if ($digit) {
        $x += -$sy;
        $y += $sx;
        ### rev add to: "$x,$y next is still rev"
      } else {
        $above_low_zero = $digits[$i+1];
        $rot ++;
        $rev = 0;
        ### rev rot, next is no rev ...
      }
    } else {
      if ($digit) {
        $rot ++;
        $x += $sx;
        $y += $sy;
        $rev = 1;
        ### plain add to: "$x,$y next is rev"
      } else {
        $above_low_zero = $digits[$i+1];
      }
    }
  }

  # Digit above the low zero is the direction of the next turn, 0 for left,
  # 1 for right.
  #
  ### final: "$x,$y  rot=$rot  above_low_zero=".($above_low_zero||0)

  if ($rot & 2) {
    $frac = -$frac;  # rotate 180
    $x -= 1;
  }
  if (($rot+1) & 2) {
    # rot 1 or 2
    $y += 1;
  }
  if (!($rot & 1) && $above_low_zero) {
    $frac = -$frac;
  }
  $above_low_zero ^= ($rot & 1);
  if ($above_low_zero) {
    $y = $frac + $y;
  } else {
    $x = $frac + $x;
  }

  ### rotated return: "$x,$y"
  return ($x,$y);
}

# or tables arithmetically,
#
#   my $ax = ((($x+1) ^ ($y+1)) >> 1) & 1;
#   my $ay = (($x^$y) >> 1) & 1;
#   ### assert: $ax == - $yx_adj_x[$y%4]->[$x%4]
#   ### assert: $ay == - $yx_adj_y[$y%4]->[$x%4]
#
my @yx_adj_x = ([0,1,1,0],
                [1,0,0,1],
                [1,0,0,1],
                [0,1,1,0]);
my @yx_adj_y = ([0,0,1,1],
                [0,0,1,1],
                [1,1,0,0],
                [1,1,0,0]);

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### DragonMidpoint xy_to_n(): "$x, $y"

  $x = round_nearest($x);
  $y = round_nearest($y);

  if (is_infinite($x)) {
    return $x;  # infinity
  }
  if (is_infinite($y)) {
    return $y;  # infinity
  }

  my $n = ($x * 0 * $y); # inherit bignum 0
  my $npow = $n + 1;     # inherit bignum 1

  while (($x != 0 && $x != -1) || ($y != 0 && $y != 1)) {

    my $y4 = $y % 4;
    my $x4 = $x % 4;
    my $ax = $yx_adj_x[$y4]->[$x4];
    my $ay = $yx_adj_y[$y4]->[$x4];

    ### at: "$x,$y  n=$n  axy=$ax,$ay  bit=".($ax^$ay)

    if ($ax^$ay) {
      $n += $npow;
    }
    $npow *= 2;

    $x -= $ax;
    $y -= $ay;
    ### assert: ($x+$y)%2 == 0
    ($x,$y) = (($x+$y)/2,   # rotate -45 and divide sqrt(2)
               ($y-$x)/2);
  }

  ### final: "xy=$x,$y"
  my $arm;
  if ($x == 0) {
    if ($y) {
      $arm = 1;
      ### flip ...
      $n = $npow-1-$n;
    } else { #  $y == 1
      $arm = 0;
    }
  } else { # $x == -1
    if ($y) {
      $arm = 2;
    } else {
      $arm = 3;
      ### flip ...
      $n = $npow-1-$n;
    }
  }
  ### $arm

  my $arms_count = $self->arms_count;
  if ($arm >= $arms_count) {
    return undef;
  }
  return $n * $arms_count + $arm;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### DragonMidpoint rect_to_n_range(): "$x1,$y1  $x2,$y2  arms=$self->{'arms'}"
  $x1 = abs($x1);
  $x2 = abs($x2);
  $y1 = abs($y1);
  $y2 = abs($y2);
  my $xmax = int(max($x1,$x2));
  my $ymax = int(max($y1,$y2));
  return (0,
          ($xmax*$xmax + $ymax*$ymax + 1) * $self->{'arms'} * 5);
}

# sub rect_to_n_range {
#   my ($self, $x1,$y1, $x2,$y2) = @_;
#   ### DragonMidpoint rect_to_n_range(): "$x1,$y1  $x2,$y2"
#
#   return Math::PlanePath::DragonCurve->rect_to_n_range
#     (sqrt(2)*$x1, sqrt(2)*$y1, sqrt(2)*$x2, sqrt(2)*$y2);
# }

1;
__END__




# wider drawn arms ...
#
#
# ...            36---32             59---63-...        5
#  |              |    |              |
# 60             40   28             55                 4
#  |              |    |              |
# 56---52---48---44   24---20---16   51                 3
#                                |    |
#           17---13----9----5   12   47---43---39       2
#            |              |    |              |
#           21    6--- 2    1    8   27---31---35       1
#            |    |              |    |
# 33---29---25   10    3    0--- 4   23             <- Y=0
#  |              |    |              |
# 37---41---45   14    7---11---15---19                -1
#            |    |
#           49   18---22---26   46---50---54---58      -2
#            |              |    |              |
#           53             30   42             62      -3
#            |              |    |              |
# ...--61---57             34---38             ...     -4
#
#
#
#  ^    ^    ^    ^    ^    ^    ^    ^    ^    ^
# -5   -4   -3   -2   -1   X=0   1    2    3    4



# DragonMidpoint abs(dY) is A073089, but that seq has an extra leading 0
#
#   --*--+   dy=+/-1  vert and left
#        |            horiz and right
#        *
#        |
#   |
#   *
#   |
#   +--*--   dy=+/-1
#
#   +--*--   dx=+/-1  vert and right
#   |                 horiz and left
#   *
#   |
#        |   dx=+/-1
#        *
#        |
#   --*--+
#
# left turn  ...01000
# right turn ...11000
# vert           ...1
# horiz          ...0

# Offset=1  0,0,1,1,1,0,0,1,1,0,1,1,0,0,0,1,1,0,1,1,1,0,0,1,0,0,1,1,0,0,0,1,1,0,1,1,1,0,0,1,1,0,1,1,0,0,0,1,

# mod16
# 0     1
# 1        8n+1=4n+1
# 2  0
# 3      1
# 4     1
# 5       1
# 6  0
# 7   0
# 8     1
# 9       8n+1=4n+1
# 10 0
# 11     1
# 12    1
# 13   0
# 14 0
# 15  0
#
# a(1) = a(4n+2) = a(8n+7) = a(16n+13) = 0,
# a(4n) = a(8n+3) = a(16n+5) = 1
# a(8n+1) = a(4n+1)

# N=0   0,1,1,1,0,0,1,1,0,1,1,0,0,0,1,1,0,1,1,1,0,0,1,0,0,1,1,0,0,0,1,1,0,1,1,1,0,0,1,1,0,1,1,0,0,0,1,0,0,1,1,





=for stopwords eg Ryde Dragon Math-PlanePath Nlevel Heighway Harter et al DragonCurve DragonMidpoint bignum Xadj,Yadj lookup OEIS 0b.zz111 0b..zz11 ie

=head1 NAME

Math::PlanePath::DragonMidpoint -- dragon curve midpoints

=head1 SYNOPSIS

 use Math::PlanePath::DragonMidpoint;
 my $path = Math::PlanePath::DragonMidpoint->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is the midpoints of each segment of the dragon or paper folding curve
by Heighway, Harter, et al, per L<Math::PlanePath::DragonCurve>.


                    17--16           9---8                5
                     |   |           |   |
                    18  15          10   7                4
                     |   |           |   |
                    19  14--13--12--11   6---5---4        3
                     |                           |
                    20--21--22                   3        2
                             |                   |
    33--32          25--24--23                   2        1
     |   |           |                           |
    34  31          26                       0---1    <- Y=0
     |   |           |
    35  30--29--28--27                                   -1
     |
    36--37--38  43--44--45--46                           -2
             |   |           |
            39  42  49--48--47                           -3
             |   |   |
            40--41  50                                   -4
                     |
                    51                                   -5
                     |
                    52--53--54                           -6
                             |
    ..--64          57--56--55                           -7
         |           |
        63          58                                   -8
         |           |
        62--61--60--59                                   -9


     ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^
    -10 -9  -8  -7  -6  -5  -4  -3  -2  -1  X=0  1

The dragon curve begins as follows and the midpoints are numbered from 0,

               +--8--+     +--4--+
               |     |     |     |
               9     7     5     3
               |     |     |     |
               +-10--+--6--+     +--2--+
                     |                 |
                    11                 1
                     |                 |
               +-12--+           *--0--+
               |
              ...

These midpoints are on fractions X=0.5,Y=0, X=1,Y=0.5, etc.  For this
DragonMidpoint they're turned clockwise 45 degrees and shrunk by sqrt(2) to
be integer X,Y values 1 apart.

The midpoints are distinct X,Y positions because the dragon curve traverses
each edge only once.

The dragon curve is self-similar in 2^level sections due to its unfolding.
This can be seen in the midpoints as for example the above N=0 to N=16 is
the same shape as N=16 to N=32, the latter half rotated 90 degrees and in
reverse.

=head2 Arms

Like the DragonCurve the midpoints fill a quarter of the plane and four
copies mesh together perfectly when rotated by 90, 180 and 270 degrees.  The
C<arms> parameter can choose 1 to 4 curve arms, successively advancing.

For example C<arms =E<gt> 4> begins as follows, with N=0,4,8,12,etc being
the first arm (the same as the plain curve above), N=1,5,9,13 the second,
N=2,6,10,14 the third and N=3,7,11,15 the fourth.

                    ...-107-103  83--79--75--71             6
                              |   |           |
     68--64          36--32  99  87  59--63--67             5
      |   |           |   |   |   |   |
     72  60          40  28  95--91  55                     4
      |   |           |   |           |
     76  56--52--48--44  24--20--16  51                     3
      |                           |   |
     80--84--88  17--13---9---5  12  47--43--39 ...         2
              |   |           |   |           |  |
    100--96--92  21   6---2   1   8  27--31--35 106         1
      |           |   |           |   |          |
    104  33--29--25  10   3   0---4  23  94--98-102    <- Y=0
      |   |           |   |           |   |
    ...  37--41--45  14   7--11--15--19  90--86--82        -1
                  |   |                           |
                 49  18--22--26  46--50--54--58  78        -2
                  |           |   |           |   |
                 53  89--93  30  42          62  74        -3
                  |   |   |   |   |           |   |
         65--61--57  85  97  34--38          66--70        -4
          |           |   |
         69--73--77--81 101-105-...                        -5

                              ^
     -6  -5  -4  -3  -2  -1  X=0  1   2   3   4   5

With four arms like this every X,Y point is visited exactly once, because
four arms of the DragonCurve traverse every edge exactly once.

=head2 Tiling

Taking pairs of points N=2k and N=2k+1 gives little rectangles with the
following tiling of the plane.

         +---+---+---+-+-+---+-+-+---+
         |   | | |   | | |   | | |   |
         +---+ | +---+ | +---+ | +---+
         |   | | |9 8| | |   | | |   |
         +-+-+---+-+-+-+-+-+-+-+-+-+-+
         | | |   | |7|   | | |   | | |
         | | +---+ | +---+ | +---+ | |
         | | |   | |6|5 4| | |   | | |
         +---+-+-+-+-+-+-+-+-+-+-+-+-+
         |   | | |   | |3|   | | |   |
         +---+ | +---+ | +---+ | +---+
         |   | | |   | |2|   | | |   |
         +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
         | | |   | | |0 1| | |   | | |   <- Y=0
         | | +---+ | +---+ | +---+ | |
         | | |   | | |   | | |   | | |
         +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
         |   | | |   | | |   | | |   |
         +---+ | +---+ | +---+ | +---+
         |   | | |   | | |   | | |   |
         +---+-+-+---+-+-+---+-+-+---+
                      ^
                     X=0

The pairs follow this pattern both for the main curve N=0 etc shown, and
also for the rotated copies per L</Arms> above.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::DragonMidpoint-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 FORMULAS

=head2 X,Y to N

An X,Y point is turned into N by dividing out digits of a complex base i+1.
This base is per the doubling of the DragonCurve at each level.  In midpoint
coordinates an adjustment subtracting 0 or 1 must be applied to move an X,Y
for N=2k or N=2k+1 to the point where dividing out i+1 gives the N=k
position.

The adjustment is in a repeating pattern of 4x4 blocks.  Points N=2k and
N=2k+1 both move to the same place corresponding to N=k times i+1.  The
adjustment pattern is related to the pair tiling shown above, except for
some pairs both the N=2k and N=2k+1 positions must move, it's not just a
matter of shifting the N=2k+1 to the N=2k.

           Xadj               Yadj
    Ymod4              Ymod4
      3 | 0 1 1 0        3 | 1 1 0 0
      2 | 1 0 0 1        2 | 1 1 0 0
      1 | 1 0 0 1        1 | 0 0 1 1
      0 | 0 1 1 0        0 | 0 0 1 1
        +--------          +--------
          0 1 2 3            0 1 2 3
           Xmod4              Xmod4

The same tables work for both the main curve and for the rotated copies per
L</Arms> above.

    Xm = X - Xadj(X mod 4, Y mod 4)
    Ym = Y - Yadj(X mod 4, Y mod 4)

    new X,Y = (Xm+i*Ym) / (i+1)
            = (Xm+i*Ym) * (1-i)/2
            = (Xm+Ym)/2, (Ym-Xm)/2     # Xm+Ym, Ym-Xm are even

    Nbit = Xadj xor Yadj
    new N = N + (Nbit << count++)      # new low bit

The X,Y reduction stops at one of the start points for the four arms

    X,Y endpoint   Arm
        0, 0        0
        0, 1        1
       -1, 1        2
       -1, 0        3

For arms 1 and 3 the N bits must be flipped 0E<lt>-E<gt>1.  The arm number
and hence whether this flip is needed is not known until reaching the
endpoint.

For bignum calculations there's no need to apply the "/2" shift in
newX=(Xm+Ym)/2 and newY=(Ym-Xm)/2.  Instead keep a bit position which is the
logical low end and pick out two bits from there for the Xadj,Yadj lookup.
A whole word can be dropped when the bit position becomes a multiple of 32
or 64 or whatever.

=head1 OEIS

The DragonMidpoint is in Sloane's Online Encyclopedia of Integer Sequences as

    http://oeis.org/A073089

    A073089 -- segments 0=horizontal, 1=vertical (extra initial 0)

The midpoint curve is vertical when the DragonCurve has a vertical followed
by a left turn or a horizontal followed by a right turn.  DragonCurve
verticals are whenever N is odd, and the turn is the bit above the lowest 0
in N, as described in L<Math::PlanePath::DragonCurve/Turns>.

The n of A073089 is offset by 2 from the N numbering of the DragonMidpoint
here, ie. n=N+2.  The A073089 initial value at n=1 has no corresponding N
(it would be N=-1).

The mod-16 definitions in A073089 express combinations of N odd/even and
bit-above-low-0 which are the vertical midpoint segments.  The recursion
a(8n+1)=a(4n+1) works to reduce an N=0b.zz111 to 0b..zz11 in order to bring
the bit above the lowest 0 into range of the mod-16 conditions.  n=1 mod 8
corresponds to N=7 mod 8.  In terms of N it could be expressed as stripping
low 1 bits down to at most 2 of them.  In terms of n it's a strip of zeros
above a low 1 bit, ie. n=0b...00001 -E<gt> 0b...01.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DragonCurve>,

L<Math::PlanePath::AlternatePaperMidpoint>,
L<Math::PlanePath::R5DragonMidpoint>,
L<Math::PlanePath::TerdragonMidpoint>

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
