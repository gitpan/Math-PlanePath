# Copyright 2010, 2011, 2012, 2013 Kevin Ryde

# This file is part of Math-PlanePath.
#
# Math-PlanePath is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-PlanePath is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-PlanePath.  If not, see <http://www.gnu.org/licenses/>.


# math-image --path=Flowsnake --lines --scale=10
# math-image --path=Flowsnake --all --output=numbers_dash
# math-image --path=Flowsnake,arms=3 --all --output=numbers_dash
#
# Martin Gardner, "In which `Monster' Curves Force Redefinition of the Word
# `Curve'", Scientific American 235, December 1976, pages 124-133.
#
# http://80386.nl/pub/gosper-level21.png
#
# http://www.mathcurve.com/fractals/gosper/gosper.shtml
#
# plain hexagonal tiling http://tilingsearch.org/HTML/data136/F666.html
#


package Math::PlanePath::Flowsnake;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 98;

# inherit: new(), rect_to_n_range(), arms_count(), n_start(),
#          parameter_info_array(), xy_is_visited()
use Math::PlanePath::FlowsnakeCentres 55; # v.55 inheritance switch-around
@ISA = ('Math::PlanePath::FlowsnakeCentres');
use Math::PlanePath;
*_divrem_mutate = \&Math::PlanePath::_divrem_mutate;

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'digit_split_lowtohigh';

# uncomment this to run the ### lines
# use Smart::Comments;


# (i,j)*(2+w) = (2i-j,2j+i+j) = (2i-j,3j+i)
# (x,y)*(2+w) = 2x + (x-3y)/2, 2y + (x+y)/2
#             = (4x + x-3y)/2, (4y + x+y)/2
#             = (5x-3y)/2, (x+5y)/2


# Table generated by tools/flowsnake-table.pl.
# next_state length 84
my @next_state = (0, 21,49,28, 0, 0,77, 70, 7, 7,35,42,14, 7,  # 0,7
                  14,35,63,42,14,14, 7,  0,21,21,49,56,28,21,  # 14,21
                  28,49,77,56,28,28,21, 14,35,35,63,70,42,35,  # 28,35
                  42,63, 7,70,42,42,35, 28,49,49,77, 0,56,49,  # 42,49
                  56,77,21, 0,56,56,49, 42,63,63, 7,14,70,63,  # 56,63
                  70, 7,35,14,70,70,63, 56,77,77,21,28, 0,77);  # 70,77
my @digit_to_i = (0,  1, 1, 0,-1, 0, 1,  0, 1, 2, 3, 2, 1, 1,  # 0,7
                  0,  0,-1,-1,-2,-2,-2,  0, 1, 1, 1, 0, 0,-1,  # 14,21
                  0, -1,-2,-1,-1,-2,-3,  0, 0,-1,-2,-2,-1,-2,  # 28,35
                  0, -1,-1, 0, 1, 0,-1,  0,-1,-2,-3,-2,-1,-1,  # 42,49
                  0,  0, 1, 1, 2, 2, 2,  0,-1,-1,-1, 0, 0, 1,  # 56,63
                  0,  1, 2, 1, 1, 2, 3,  0, 0, 1, 2, 2, 1,2);  # 70,77
my @digit_to_j = (0,  0, 1, 1, 2, 2, 2,  0,-1,-1,-1, 0, 0, 1,  # 0,7
                  0,  1, 2, 1, 1, 2, 3,  0, 0, 1, 2, 2, 1, 2,  # 14,21
                  0,  1, 1, 0,-1, 0, 1,  0, 1, 2, 3, 2, 1, 1,  # 28,35
                  0,  0,-1,-1,-2,-2,-2,  0, 1, 1, 1, 0, 0,-1,  # 42,49
                  0, -1,-2,-1,-1,-2,-3,  0, 0,-1,-2,-2,-1,-2,  # 56,63
                  0, -1,-1, 0, 1, 0,-1,  0,-1,-2,-3,-2,-1,-1);  # 70,77

# state 0 to 11
my @dir6_to_di = (1, 0,-1, -1, 0, 1);
my @dir6_to_dj = (0, 1, 1,  0,-1,-1);

sub n_to_xy {
  my ($self, $n) = @_;
  ### Flowsnake n_to_xy(): $n

  if ($n < 0) { return; }
  if (is_infinite($n)) { return ($n,$n); }

  my $int = int($n);
  $n -= $int;  # fraction part
  ### $int
  ### frac: $n

  my $state;
  {
    my $arm = _divrem_mutate ($int, $self->{'arms'});
    $state = 28 * $arm;  # initial rotation

    # adjust so that for arms=2 point N=1 has $int==1
    # or for arms=3 then points N=1 and N=2 have $int==1
    if ($arm) { $int += 1; }
  }
  ### initial state: $state

  my $i = my $j = $int*0;  # bignum zero

  foreach my $digit (reverse digit_split_lowtohigh($int,7)) { # high to low
    ### at: "state=$state digit=$digit  i=$i,j=$j  di=".$digit_to_i[$state+$digit]." dj=".$digit_to_j[$state+$digit]

    # (i,j) *= (2+w), being (i,j) = 2*(i,j)+rot60(i,j)
    # then add low digit pos
    #
    $state += $digit;
    ($i, $j) = (2*$i - $j + $digit_to_i[$state],
                3*$j + $i + $digit_to_j[$state]);
    $state = $next_state[$state];
  }
  ### integer: "i=$i, j=$j"

  # fraction in final $state direction
  if ($n) {
    ### apply: "frac=$n  state=$state"
    $state = int($state/14);   # divide to direction 0 to 5
    $i = $n * $dir6_to_di[$state] + $i;
    $j = $n * $dir6_to_dj[$state] + $j;
  }

  ### ret: "$i, $j  x=".(2*$i+$j)." y=$j"
  return (2*$i+$j,
          $j);

}

# Table generated by tools/flowsnake-table.pl.
my @digit_to_next_di
  = (0, -1,-1, 1, 1, 1,undef,  1, 1,-1,-1, 0, 1,undef,  # 0,7
     -1, 0,-1, 0, 0, 1,undef,  0, 0,-1, 0,-1, 0,undef,  # 14,21
     -1, 1, 0,-1,-1, 0,undef, -1,-1, 0, 1,-1,-1,undef,  # 28,35
     0,  1, 1,-1,-1,-1,undef, -1,-1, 1, 1, 0,-1,undef,  # 42,49
     1,  0, 1, 0, 0,-1,undef,  0, 0, 1, 0, 1, 0,undef,  # 56,63
     1, -1, 0, 1, 1, 0,undef,  1, 1, 0,-1, 1, 1,undef,  # 70,77
     1, -1,-1, 1, 1, 0,undef,  1, 1, 0,-1, 0, 1,undef,  # 84,91
     0, -1,-1, 0, 0, 1,undef,  1, 1,-1, 0,-1, 1,undef,  # 98,105
     -1, 0, 0,-1,-1, 1,undef,  0, 0,-1, 1,-1, 0,undef,  # 112,119
     -1, 1, 1,-1,-1, 0,undef, -1,-1, 0, 1, 0,-1,undef,  # 126,133
     0,  1, 1, 0, 0,-1,undef, -1,-1, 1, 0, 1,-1,undef,  # 140,147
     1,  0, 0, 1, 1,-1,undef,  0, 0, 1,-1, 1,0);
my @digit_to_next_dj
  = (1,  0, 1, 0, 0,-1,undef,  0, 0, 1, 0, 1, 0,undef,  # 0,7
     1, -1, 0, 1, 1, 0,undef,  1, 1, 0,-1, 1, 1,undef,  # 14,21
     0, -1,-1, 1, 1, 1,undef,  1, 1,-1,-1, 0, 1,undef,  # 28,35
     -1, 0,-1, 0, 0, 1,undef,  0, 0,-1, 0,-1, 0,undef,  # 42,49
     -1, 1, 0,-1,-1, 0,undef, -1,-1, 0, 1,-1,-1,undef,  # 56,63
     0,  1, 1,-1,-1,-1,undef, -1,-1, 1, 1, 0,-1,undef,  # 70,77
     0,  1, 1, 0, 0,-1,undef, -1,-1, 1, 0, 1,-1,undef,  # 84,91
     1,  0, 0, 1, 1,-1,undef,  0, 0, 1,-1, 1, 0,undef,  # 98,105
     1, -1,-1, 1, 1, 0,undef,  1, 1, 0,-1, 0, 1,undef,  # 112,119
     0, -1,-1, 0, 0, 1,undef,  1, 1,-1, 0,-1, 1,undef,  # 126,133
     -1, 0, 0,-1,-1, 1,undef,  0, 0,-1, 1,-1, 0,undef,  # 140,147
     -1, 1, 1,-1,-1, 0,undef, -1,-1, 0, 1, 0,-1);

sub n_to_dxdy {
  my ($self, $n) = @_;
  ### Flowsnake n_to_dxdy(): $n

  if ($n < 0) { return; }
  if (is_infinite($n)) { return ($n,$n); }

  my $int = int($n);
  $n -= $int;  # fraction part
  ### $int
  ### frac: $n

  my $state;
  {
    my $arm = _divrem_mutate ($int, $self->{'arms'});
    $state = 28 * $arm;  # initial rotation

    # adjust so that for arms=2 point N=1 has $int==1
    # or for arms=3 then points N=1 and N=2 have $int==1
    if ($arm) { $int += 1; }
  }
  ### initial state: $state

  my $turn_state = $state;
  my $turn_notlow = 0;
  foreach my $digit (reverse digit_split_lowtohigh($int,7)) { # high to low
    ### $digit
    $state += $digit;

    if ($digit == 6) {
      $turn_notlow = 84;     # is not the least significant digit
    } else {
      $turn_state = $state;  # lowest non-6
      $turn_notlow = 0;      # and is the least significant digit
    }
    $state = $next_state[$state];
  }
  ### int digits state: $state
  ### $turn_state
  ### $turn_notlow

  $state = int($state/14);
  my $di = $dir6_to_di[$state];
  my $dj = $dir6_to_dj[$state];
  ### int direction: "di=$di, dj=$dj"

  # fraction in final $state direction
  if ($n) {
    $turn_state += $turn_notlow;
    my $next_di = $digit_to_next_di[$turn_state];
    my $next_dj = $digit_to_next_dj[$turn_state];

    ### $next_di
    ### $next_dj

    $di += $n*($next_di - $di);
    $dj += $n*($next_dj - $dj);

    ### with frac: "di=$di, dj=$dj"
  }

  ### ret: "dx=".(2*$di+$dj)." dy=$dj"
  return (2*$di+$dj,
          $dj);

}

my @attempt_dx = (0, -2, -1);
my @attempt_dy = (0, 0, -1);
sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### Flowsnake xy_to_n(): "$x, $y"

  $x = round_nearest($x);
  $y = round_nearest($y);
  if (($x + $y) % 2) { return undef; }
  ### round to: "$x,$y"

  my ($n, $cx, $cy);
  foreach my $i (0, 1, 2) {
    if (defined ($n = $self->SUPER::xy_to_n($x + $attempt_dx[$i],
                                            $y + $attempt_dy[$i]))
        && (($cx,$cy) = $self->n_to_xy($n))
        && $x == $cx
        && $y == $cy) {
      return $n;
    }
  }
  return undef;
}

# 0  straight
# 1  +60 rev
# 2  180 rev
# 3  +240
# 4  straight
# 5  straight
# 6  -60 rev

# 4---- 5---- 6
#  \           \
#    3---- 2    7
#        /
# 0---- 1
#
# turn(N) = tdir6(N)-tdir6(N-1)
# N-1 changes low 0s to low 6s
# N   = aaad000
# N-1 = aaac666
# low 0s no change to direction
# low 6s state 7
# N=14=20[7] dir[2]=3,dirrev[0]=5 total 3+5=2mod6
# N-1=13=16[7] dir[1]=1,dirrev[6]=0 total 1+0=1  diff 2-1=1
# dir[2]-dir[1]=2
# dirrev[0] since digit=2 goes to rev
# N=23=32[7]

my @turn6 = (1, 2,-1,-2, 0,-1,  # forward
             1, 0, 2, 1,-2,-1,  # reverse
             #
             1, 1,-1,-1, 1,-1,  # 0,0,-1,0,+1,+1,0
             1,-1, 1, 1,-1,-1,  # 0,0,-1,-1,0,+1,0
            );
my @digit_to_reverse = (-1,5,5,undef,-1,-1,5);  # -1=forward,5=reverse
sub _WORKING_BUT_SECRET__n_to_turn6 {
  my ($self, $n) = @_;
  unless ($n >= 1) {
    return undef;
  }
  if (is_infinite($n)) {
    return $n;
  }

  my $lowdigit = _divrem_mutate($n,7);
  ### $lowdigit

  # skip low 0 digits
  unless ($lowdigit) {
    while ($n) {
      last if ($lowdigit = _divrem_mutate($n,7));  # stop at non-zero
    }
    # flag that some zeros were skipped
    $lowdigit += 12;
    ### $lowdigit
  }

  # Forward/reverse reverse from lowest non-3.
  # Digit parts 0,4,5 always forward, 1,2,6 always reverse,
  # 3 is unchanged so following the digit above it.
  for (;;) {
    my $digit = _divrem_mutate($n,7);
    if ($digit != 3) {
      $lowdigit += $digit_to_reverse[$digit];
      last;
    }
  }

  ### lookup: $lowdigit
  return $turn6[$lowdigit];
}


1;
__END__

#       4-->5-->6
#       ^       ^
#        \       \
#         3-->2
#            /
#           v
#       0-->1
#
# longest to 6 is x=4,y=2 is 4*4+3*2*2 = 28
#
#             6<---
#             ^
#            /
#       0   5<--4
#        \       \
#         v       v
#         1<--2<--3
#
# longest to 3 is x=5,y=1 is 5*5+3*1*1 = 28
#
# side len 1 len sqrt(7)
# total sqrt(7)^k + ... + 1
#     = (b^(k+1) - 1) / (b - 1)
#     < b^(k+1) / (b - 1)
# squared 7^(k+1) / (7 - 2*sqrt(7) + 1)
#     = 7^k * 7/(7-2*sqrt(7)+1)
#     = 7^k * 2.584
#
# minimum = b^k - upper(k-1)
#         = b^k - b^k / (b - 1)
#         = b^k * (1 - 1/(b-1))
#         = b^k * (b-1 - 1)/(b-1)
#         = b^k * (b-2)/(b-1)
#         = b^k * 0.392
#
# sqrt((x/2)^2 + (y*sqrt(3)/2)^2)
#    = sqrt(x^2/4 + y^2*3/4)
#    = sqrt(x^2 + 3*y^2)/2

# sqrt(x^2 + 3*y^2)/2 > b^k * (b-2)/(b-1)
# sqrt(x^2 + 3*y^2) > b^k * 2*(b-2)/(b-1)
# x^2 + 3*y^2 > 7^k * (2*(b-2)/(b-1))^2
# x^2 + 3*y^2 > 7^k * (2*(b-2)/(b-1))^2
# (x^2 + 3*y^2) / (2*(b-2)/(b-1))^2 > 7^k
# 7^k < (x^2 + 3*y^2) / (2*(b-2)/(b-1))^2
# k < log7 ((x^2 + 3*y^2) / (2*(b-2)/(b-1))^2)
# k < log7 ((x^2 + 3*y^2) * 1.62
# k < log((x^2 + 3*y^2) * 1.62/log(7)
# k < log((x^2 + 3*y^2) * 0.8345



    #                     *---E
    #                    /     \
    #               *---*       *---*
    #              /     \     /     \
    #             *       *---*       *
    #              \     /     \     /
    #               *---*       *---*
    #              /     \     /     \
    #             *       *---*       *
    #              \     /     \     /
    #               *---*       *---*
    #                    \     /
    #                     *---*
    #
    #
    #                     *     *
    #                    / \   / \
    #                   /   \ /   \
    #                  *     *     *
    #                  |     |     |
    #                  |     |     |
    #                  *     *     *
    #                 / \   / \   / \
    #                /   \ /   \ /   \
    #               *     *     *     *
    #               |     |     |     |
    #               |     |     |     |
    #               *     *     *     *
    #                \   / \   / \   /
    #                 \ /   \ /   \ /
    #                  *     *     *
    #                  |     |     |
    #                  |     |     |
    #                  *     *     *
    #                   \   / \   /
    #                    \ /   \ /
    #                     *     *
    #
    #
    #
    #
    #    B
    #   / \   / \
    #  /   \ /   \
    # .  ^  .     .
    # |   | |     |
    # |    ||     |
    # .     O-->  A
    #  \   / \   /
    #   \ / | \ /
    #    . |   .
    #    | v   |
    #    |     |
    #    C     .
    #     \   /
    #      \ /


=for stopwords eg Ryde flowsnake Gosper ie Fukuda Shimizu Nakamura Math-PlanePath FlowsnakeCentres Ns

=head1 NAME

Math::PlanePath::Flowsnake -- self-similar path through hexagons

=head1 SYNOPSIS

 use Math::PlanePath::Flowsnake;
 my $path = Math::PlanePath::Flowsnake->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

X<Gosper, William>This path is an integer version of the flowsnake curve by
William Gosper,

=cut

# math-image --path=Flowsnake --all --output=numbers_dash

=pod

                         39----40----41                        8
                           \           \
          32----33----34    38----37    42                     7
            \           \        /     /
             31----30    35----36    43    47----48            6
                  /                    \     \     \
          28----29    17----16----15    44    46    49--..     5
         /              \           \     \  /
       27    23----22    18----19    14    45                  4
         \     \     \        /     /
          26    24    21----20    13    11----10               3
            \  /                    \  /     /
             25     4---- 5---- 6    12     9                  2
                     \           \         /
                       3---- 2     7---- 8                     1
                           /
                    0---- 1                                  y=0

     x=-4 -3 -2 -1  0  1  2  3  4  5  6  7  8  9 10 11

The points are spread out on every second X coordinate to make little
triangles with integer coordinates, per L<Math::PlanePath/Triangular
Lattice>.

The basic pattern is the seven points 0 to 6,

    4---- 5---- 6
     \           \
       3---- 2
           /
    0---- 1

This repeats at 7-fold increasing scale, with sub-sections rotated according
to the edge direction and the 1, 2 and 6 sections in reverse.  The next
level can be seen at the multiple-of-7 points N=0,7,14,21,28,35,42,49.

                                  42
                      -----------    ---
                   35                   ---
       -----------                         ---
    28                                        49 ---
      ---
         ----                  14
             ---   -----------  |
                21              |
                               |
                              |
                              |
                        ---- 7
                   -----
              0 ---

Notice this is the same shape as N=0 to N=6, but rotated by atan(1/sqrt(7))
= 20.68 degrees anti-clockwise.  Each level rotates further and for example
after about 18 levels it goes all the way around and back to the first
quadrant.

The rotation doesn't fill the plane though, only 1/3 of it.  The shape
fattens as it curls around, but leaves a spiral gap beneath (see L</Arms>
below).

=head2 Tiling

The base pattern corresponds to a tiling by hexagons as follows, with the
"***" lines being the base figure.

          .     .
         / \   / \
        /   \ /   \
       .     .     .
       |     |     |
       |     |     |
       4*****5*****6
      /*\   / \   /*\
     / * \ /   \ / * \
    .   * .     .   * .
    |   * |     |    *|
    |    *|     |    *|
    .     3*****2     7...
     \   / \   /*\   /
      \ /   \ / * \ /
       .     . *   .
       |     | *   |
       |     |*    |
       0*****1     .
        \   / \   /
         \ /   \ /
          .     .

In the next level the parts corresponding to 1, 2 and 6 are reversed because
they have their hexagon tile to the right of the line segment, rather than
to the left.

=head2 Arms

The optional C<arms> parameter can give up to three copies of the flowsnake,
each advancing successively.  For example C<arms=E<gt>3> is as follows.

    arms => 3                        51----48----45                 5
                                       \           \
                      ...   69----66    54----57    42              4
                        \     \     \        /     /
       28----25----22    78    72    63----60    39    33----30     3
         \           \     \  /                    \  /     /
          31----34    19    75    12----15----18    36    27        2
               /     /              \           \        /
       40----37    16     4---- 1     9---- 6    21----24           1
      /              \     \              /
    43    55----58    13     7     0---- 3    74----77---...    <- Y=0
      \     \     \     \  /                    \
       46    52    61    10     2     8----11    71----68          -1
         \  /     /              \  /     /           /
          49    64    70----73     5    14    62----65             -2
                  \  /     /           /     /
                   67    76    20----17    59    53----50          -3
                        /     /              \  /     /
                      ...   23    35----38    56    47             -4
                              \     \     \        /
                               26    32    41----44                -5
                                 \  /
                                  29                               -6

                                   ^
       -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7  8  9

Notice the N=3*k points are the plain curve, N=3*k+1 is a copy rotated by
120 degrees (1/3 around), and N=3*k+2 is a copy rotated by 240 degrees (2/3
around).  The initial N=1 of the second arm and N=2 of the third correspond
to N=3 of the first arm, rotated around.

Essentially the flowsnake fills an ever expanding hexagon with one corner at
the origin, and wiggly sides.  In the following picture the plain curve
fills "A" and there's room for two more arms to fill B and C, rotated 120
and 240 degrees respectively.

            *---*
           /     \
      *---*   A   *
     /     \     /
    *   B   O---*
     \     /     \
      *---*   C   *
           \     /
            *---*

The sides of these "hexagons" are not straight lines but instead wild wiggly
spiralling S shapes, and the endpoints rotate around by the angle described
above at each level.  Opposing sides are symmetric, so they mesh perfectly
and with three arms fill the plane.

=head2 Fractal

The flowsnake can also be thought of as successively subdividing line
segments with suitably scaled copies of the 0 to 7 figure (or its reversal).

The code here could be used for that by taking points N=0 to N=7^level.  The
Y coordinates should be multiplied by sqrt(3) to make proper equilateral
triangles, then a rotation and scaling to make the endpoint come out at some
desired point, such as X=1,Y=0.  With such a scaling the path is confined to
a finite fractal boundary.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::Flowsnake-E<gt>new ()>

=item C<$path = Math::PlanePath::Flowsnake-E<gt>new (arms =E<gt> $a)>

Create and return a new flowsnake path object.

The optional C<arms> parameter gives between 1 and 3 copies of the curve
successively advancing.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

In the current code the returned range is exact, meaning C<$n_lo> and
C<$n_hi> are the smallest and biggest in the rectangle, but don't rely on
that yet since finding the exact range is a touch on the slow side.  (The
advantage of which though is that it helps avoid very big ranges from a
simple over-estimate.)

=back

=head1 FORMULAS

=head2 N to X,Y

The position of a given N can be calculated from the base-7 digits of N from
high to low.  At a given digit position the state maintained is

    direction 0 to 5, multiple of 60-degrees
    plain or reverse pattern

It's convenient to work in the "i,j" coordinates per
L<Math::PlanePath/Triangular Calculations>.  This represents a point in the
triangular grid as i+j*w where w=1/2+I*sqrt(3)/2 the a complex sixth root of
unity at +60 degrees.

    foreach base-7 digit high to low
      (i,j) = (2i-j, i+3j)   # multiply by 2+w
      (i,j) += position of digit in plain or reverse,
               and rotated by "direction"

The multiply by 2+w scales up i,j by that vector, so for instance i=1,j=0
becomes i=2,j=1.  This spreads the points as per the multiple-of-7 diagram
shown above, so what was at N scales up to 7*N.

The digit is then added as either the plain or reversed base figure,

      plain             reverse

    4-->5-->6
    ^       ^
     \       \
      3-->2   *             6<---*
         /                  ^
        v                  /
    0-->1             0   5<--4
                       \       \
                        v       v
                        1<--2<--3


The arrow shown in each part is whether the state becomes plain or reverse.
For example in plain state at digit=1 the arrow points backwards so if
digit=1 then the state changes to reverse for the next digit.  The direction
likewise follows the direction of each segment in the pattern.

Notice the endpoint "*" is at at 2+w in both patterns.  When considering the
rotation it's convenient to reckon the direction by this endpoint.

The combination of direction and plain/reverse is a total of 14 different
states, and for each there's 7 digit values (0 to 6) for a total 84 i,j.

=head2 X,Y to N

The current approach uses the FlowsnakeCentres code.  The tiling in
Flowsnake and FlowsnakeCentres is the same so the X,Y of a given N are no
more than 1 away in the grid of the two forms.

The way the two lowest shapes are arranged in fact means that if the
Flowsnake N is at X,Y then the same N in FlowsnakeCentres is at one of three
locations

    X, Y         same
    X-2, Y       left      (+180 degrees)
    X-1, Y-1     left down (+240 degrees)

This is true even when the rotated "arms" multiple paths (the same number of
arms in both paths).

Is there an easy way to know which of the three offsets is right?  The
current approach is to put each through FlowsnakeCentres to make an N, and
put that N back through Flowsnake C<n_to_xy()> to see if it's the target
C<$n>.

=head2 Rectangle to N Range

The current code calculates an exact C<rect_to_n_range()> by searching for
the highest and lowest Ns which are in the rectangle.

The curve at a given level is bounded by the Gosper island shape but the
wiggly sides make it difficult to calculate, so a bounding radius
sqrt(7)^level, plus a bit, is used.  The portion of the curve comprising a
given set of high digits of N can be excluded if the N point is more than
that radius away from the rectangle.

When a part of the curve is excluded it prunes a whole branch of the digits
tree.  When the lowest digit is reached then a check for that point being
actually within the rectangle is made.  The radius calculation is a bit
rough, and it doesn't take into account the direction of the curve, so it's
a rather large over-estimate, but it works.

The same sort of search can be applied for highest and lowest N in a
non-rectangular shapes, calculating a radial distance away from the shape.
The distance calculation doesn't have to be exact either, it can go from
something bounding the shape until the lowest digit is reached and an
individual X,Y is considered as a candidate for high or low N.

=head2 N to Turn

The turn made by the curve at a point NE<gt>=1 can be calculated from the
lowest non-0 digit and the plain/reverse state per the lowest non-3 above
there.

   N digits in base-7
   strip low 0 digits
   digit = take low digit
   strip low 3 digits
   plain if lowdigit=0,4,5, reverse if lowdigit=1,2,6

             if no low 0s       if low 0s
   digit    plain reverse     plain   reverse
   -----    ----- -------     -----   -------
     1        1      1          1        1     turn left
     2        2      0          1       -1     multiple of
     3       -1      2         -1        1     60 degrees
     4       -2      1         -1        1
     5        0     -2          1       -1
     6        1     -1         -1       -1

For example N=9079 is base-7 "35320" so strip the low 0 to "3532", take
digit=2 leaving "353", skip low 3s for "35", lowdigit=5 which is "plain".
So table "plain" with "low 0s" (the third column) and digit=2 is turn=+1.

The turns in the "no low 0s" columns follow the turns of the base pattern
shown above.  For example digit=1 is as per N=1 turning 120 degrees left,
so +2.  For the reverse pattern the turns are negated and the digit value
reversed, so the reverse column read 6 to 1 is the same as the plain column
read 1 to 6 and negated.

Low 0s are stripped because the turn at a point such as N=7 ("10" in base-7)
is determined by the pattern above it, the self-similar multiple-of-7s
shape.  But when this occurs there's an adjustment to apply because the last
segment of the base pattern is not in the same direction as the first, but
instead at -60 degrees.  Likewise the first segment of the reverse pattern.
At some digit positions those two cancel out, such as at digit=1 where a
plain and reverse meet, but others it's not so and hence a separate table
for with or without low 0s.

The plain or reverse pattern is determined by the lowest non-3 digit.  This
works because the digit=0, digit=4, and digit=5 segments of the base pattern
have their sub-parts "plain", in both the plain and reverse forms.
Conversely digit=1, digit=2 and digit=6 segments are "reverse", in both
plain and reverse forms.  The digit=3 part is plain in plain and reverse in
reverse, so it inherits the orientation of the digit above.

When taking digits, N is treated as having infinite 0-digits at the high
end.  This only affects the plain/reverse step.  If N has a single non-zero
such as "5000" then it's taken as digit=5 and above that for the
plain/reverse step a "0" is then assumed.  The first turn is at N=1 so
there's always at least one non-0 for the "digit" step.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::FlowsnakeCentres>,
L<Math::PlanePath::GosperIslands>

L<Math::PlanePath::KochCurve>,
L<Math::PlanePath::HilbertCurve>,
L<Math::PlanePath::PeanoCurve>,
L<Math::PlanePath::ZOrderCurve>

"New Gosper Space Filling Curves" by Fukuda, Shimizu and Nakamura, on
flowsnake variations in bigger hexagons (with wiggly sides too).

    http://kilin.clas.kitasato-u.ac.jp/museum/gosperex/343-024.pdf
      or if down then at archive.org
    http://web.archive.org/web/20070630031400/http://kilin.u-shizuoka-ken.ac.jp/museum/gosperex/343-024.pdf

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2010, 2011, 2012, 2013 Kevin Ryde

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
