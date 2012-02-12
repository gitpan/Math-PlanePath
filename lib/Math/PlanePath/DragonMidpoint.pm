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

# A088435 (contfrac+1)/2 of sum(k>=1,1/3^(2^k)).
# A088431 run lengths of dragon turns
# A007400 cont frac 1/2^1 + 1/2^2 + 1/2^4 + 1/2^8 + ... 1/2^(2^n)
#         = 0.8164215090218931...               
#    2,4,6 values                             
#    a(0)=0,
#    a(1)=1,
#    a(2)=4,
#    a(8n) = a(8n+3) = 2,
#    a(8n+4) = a(8n+7) = a(16n+5) = a(16n+14) = 4,
#    a(16n+6) = a(16n+13) = 6,
#    a(8n+1) = a(4n+1),
#    a(8n+2) = a(4n+2)
# A007404 in decimal
# A081769 positions of 2s
# A073097 number of 4s - 6s - 2s - 1 is -1,0,1
# A073088 cumulative total multiples of 4 roughly, hence (4n-3-cum)/2
# A073089 (1/2)*(4n - 3 - cumulative) is 0 or 1
# A006466 contfrac 2*sum( 1/2^(2^n)), 1 and 2 only
# A076214 in decimal
# # A073089(n) = A082410(n) xor A000035(n) xor 1


package Math::PlanePath::DragonMidpoint;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 69;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant n_start => 0;
sub arms_count {
  my ($self) = @_;
  return $self->{'arms'} || 1;
}

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
#   if (_is_infinite($n)) { return ($n, $n); }
#
#   {
#     my $int = int($n);
#     if ($n != $int) {
#       my ($x1,$y1) = $self->n_to_xy($int);
#       my ($x2,$y2) = $self->n_to_xy($int+1);
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
  if (_is_infinite($n)) { return ($n, $n); }

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;  # inherit possible BigFloat
    $n = $int;          # BigFloat int() gives BigInt, use that
  }

  my $zero = ($n * 0);  # inherit bignum 0

  my $arms = $self->{'arms'};
  my $rot = $n % $arms;
  $n = int($n/$arms);

  ### $arms
  ### rot from arm: $rot
  ### $n

  # ENHANCE-ME: sx,sy just from len,len
  my @digits;
  my @sx;
  my @sy;
  {
    my $sx = $zero + 1;
    my $sy = -$sx;
    while ($n) {
      push @digits, ($n % 2);
      push @sx, $sx;
      push @sy, $sy;
      $n = int($n/2);

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

  $x = _round_nearest($x);
  $y = _round_nearest($y);

  if (_is_infinite($x)) {
    return $x;  # infinity
  }
  if (_is_infinite($y)) {
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
  my $xmax = int(_max($x1,$x2));
  my $ymax = int(_max($y1,$y2));
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





=for stopwords eg Ryde Dragon Math-PlanePath Nlevel Heighway Harter et al DragonCurve DragonMidpoint

=head1 NAME

Math::PlanePath::DragonMidpoint -- dragon curve midpoints

=head1 SYNOPSIS

 use Math::PlanePath::DragonMidpoint;
 my $path = Math::PlanePath::DragonMidpoint->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is an integer version of the dragon or paper folding curve by Heighway,
Harter, et al, following the midpoint of each edge of the curve segments.



                    17--16           9---8                    5
                     |   |           |   |
                    18  15          10   7                    4
                     |   |           |   |
                    19  14--13--12--11   6---5---4            3
                     |                           |
                    20--21--22                   3            2
                             |                   |
    33--32          25--24--23                   2            1
     |   |           |                           |
    34  31          26                       0---1        <- Y=0
     |   |           |
    35  30--29--28--27                                       -1
     |
    36--37--38  43--44--45--46                               -2
             |   |           |
            39  42  49--48--47                               -3
             |   |   |
            40--41  50                                       -4
                     |
                    51                                       -5
                     |
                    52--53--54                               -6
                             |
    ..--64          57--56--55                               -7
         |           |
        63          58                                       -8
         |           |
        62--61--60--59                                       -9


     ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^
    -10 -9  -8  -7  -6  -5  -4  -3  -2  -1  X=0  1

The dragon curve itself begins as follows and the edge midpoints at each
"*",

                --*--       --*--
               |     |     |     |
               *     *     *     *
               |     |     |     |
                --*--+--*--       --*--
                     |                 |
                     *                 *
                     |                 |
                --*--+            --*--
               |
              ...

The midpoints are on fractions X=0.5,Y=0, X=1,Y=0.5, etc.  Those positions
can be had from the DragonCurve module by asking for N=0.5, 1.5, 2.5, etc.
For this DragonMidpoint curve they're turned clockwise 45 degrees and shrunk
by sqrt(2) to be integer X,Y values 1 apart.

Because the dragon curve traverses each edge only once, all the midpoints
are distinct X,Y positions.

=head2 Arms

The midpoints fill a quarter of the plane and four copies mesh together
perfectly when rotated by 90, 180 and 270 degrees.  The C<arms> parameter
can choose 1 to 4 curve arms, successively advancing.

For example C<arms =E<gt> 4> begins as follows, with N=0,4,8,12,etc being
the first arm (the same as above), N=1,5,9,13 the second, N=2,6,10,14 the
third and N=3,7,11,15 the fourth.

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

With four arms like this every X,Y point is visited exactly once,
corresponding to the way four copies of the dragon curve traversing each
edge exactly once.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

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

An X,Y point can be turned into N by dividing out digits of a base complex
i+1.  An adjustment is applied at each step to put X,Y onto a multiple of
i+1 and this gives a bit for N, from low to high.

The adjustment from X mod 4 and Y mod 4 is per the following tables.
(Arising essentially because at successive levels of greater detail segments
cannot cross and don't go straight ahead.)

           Xadj           Yadj

      3 | 0 1 1 0     3 | 1 1 0 0
      2 | 1 0 0 1     2 | 1 1 0 0
      1 | 1 0 0 1     1 | 0 0 1 1
    Y=0 | 0 1 1 0   Y=0 | 0 0 1 1
        +--------       +--------
        X=0 1 2 3       X=0 1 2 3

So

    Xm = X + Xadj(X%4,Y%4)
    Ym = Y + Yadj(X%4,Y%4)

    new X,Y = (Xm+i*Ym) / (i+1)
            = (Xm+i*Ym) * (1-i)/2
            = (Xm+Ym)/2, (Ym-Xm)/2

    Nbit = Xadj xor Yadj
    new N = N + Nbit << count++

Each Nbit is a bit for N, from low to high.  The X,Y reduction stops on
reaching one of the four points X=0,-1 and Y=0,1 which are the N=0,1,2,3
points of the 4-arms shown above.  That final N is thus the curve arm, eg.
X=0,Y=0 is the first arm.  For endpoints X=0,Y=1 and X=-1,Y=0 the N bits
must be flipped.

The table represents moving X,Y which is a curve midpoint K to K+1 to the
midpoint of either K to K+2 or K+1 to K+3, whichever of those two are even.
In terms of N it moves to int(N/2), and Nbit the remainder,
ie. N=2*newN+Nbit.

There's probably no need for the "/2" dividing out for the new X,Y at each
step, if the Xadj,Yadj lookup were taken at, and applied to, a suitably
higher bit position each time.

=head1 OEIS

The DragonMidpoint is in Sloane's Online Encyclopedia of Integer Sequences as


    http://oeis.org/A073089

    A073089 -- 0=horizontal, 1=vertical (extra initial 0)

The midpoint curve is vertical when the DragonCurve has a vertical followed
by left turn or horizontal followed by right turn.  The DragonCurve
verticals are whenever N is odd, and the following turn is either the bit
above the lowest 0 in N as per L<Math::PlanePath::DragonCurve/Turns>.

The mod-16 definitions in A073089 express the combinations of N odd/even and
bit-above-low-0 which make a vertical.  But note the n of A073089 is n=N+2
in the numbering of this DragonMidpoint, and the initial value at n=1 has no
corresponding point in DragonMidpoint (it would be N=-1).

The recursion a(8n+1)=a(4n+1) in A073089 works to reduce an N=0b..0111 to
0b..011 to bring the bit above the lowest 0 into range of the mod-16
conditions (n=1 mod 8 corresponds to N=7 mod 8).  In terms of N it could be
expressed as stripping low 1 bits unless there's no more than two of them.
In terms of n it's a strip of zeros above a low 1 bit n=0b...00001 -E<gt>
0b...01.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DragonCurve>,
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
