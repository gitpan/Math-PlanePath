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


# math-image --path=DragonCurve --lines --scale=20
# math-image --path=DragonCurve --all --scale=10
#
# Harter first to show copies of the dragon fit together ...
#
# cf
#    A175337 r5 dragon turns
#    A176405 r7 dragon turns

package Math::PlanePath::DragonCurve;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX 'ceil';

use vars '$VERSION', '@ISA';
$VERSION = 44;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::SierpinskiArrowhead;
*_round_up_pow2 = \&Math::PlanePath::SierpinskiArrowhead::_round_up_pow2;

# uncomment this to run the ### lines
#use Devel::Comments;

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

my @rot_to_sx = (1,0,-1,0);
my @rot_to_sy = (0,1,0,-1);

sub n_to_xy {
  my ($self, $n) = @_;
  ### DragonCurve n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n, $n); }

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;  # inherit possible BigFloat
    $n = $int;          # BigFloat int() gives BigInt, use that
  }

  # initial rotation from arm number $n mod $arms
  my $arms = $self->{'arms'};
  my $rot = $n % $arms;
  $n = int($n/$arms);

  my @digits;
  my @sx;
  my @sy;
  {
    my $sy = ($n&0);  # inherit BigInt
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
    }
  }

  ### @digits
  my $rev = 0;
  my $x = 0;
  my $y = 0;
  while (defined (my $digit = pop @digits)) {
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

  $rot &= 3;
  $x += $frac * $rot_to_sx[$rot];
  $y += $frac * $rot_to_sy[$rot];

  ### final: "$x,$y"
  return ($x,$y);
}

# point N=2^(2k) at XorY=+/-2^k  radius 2^k
#       N=2^(2k-1) at X=Y=+/-2^(k-1) radius sqrt(2)*2^(k-1)
# radius = sqrt(2^level)
# R(l)-R(l-1) = sqrt(2^level) - sqrt(2^(level-1))
#             = sqrt(2^level) * (1 - 1/sqrt(2))
# about 0.29289
#

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### DragonMidpoint xy_to_n(): "$x, $y"

  $x = _round_nearest($x);
  $y = _round_nearest($y);

  my ($pow,$exp) = _round_up_pow2(max(abs($x),abs($y)));
  my $level_limit = 2*$exp + 5;
  if (_is_infinite($level_limit)) {
    return $level_limit;  # infinity
  }

  my $arms = $self->{'arms'};
  my @hypot = (5);
  for (my $top = 0; $top < $level_limit; $top++) {
    push @hypot, ($top % 4 ? 2 : 3) * $hypot[$top];  # little faster than 2^lev

    # start from digits=1 but subtract 1 so that n=0,1,...,$arms-1 are tried
    # too
  ARM: foreach my $arm (-$arms .. 0) {
      my @digits = (((0) x $top), 1);
      my $i = $top;
      for (;;) {
        my $n = 0;
        foreach my $digit (reverse @digits) { # high to low
          $n = 2*$n + $digit;
        }
        $n = $arms*$n + $arm;
        ### consider: "arm=$arm i=$i  digits=".join(',',reverse @digits)."  is n=$n"

        my ($nx,$ny) = $self->n_to_xy($n);
        ### at: "n $nx,$ny  cf hypot ".$hypot[$i]

        if ($i == 0 && $x == $nx && $y == $ny) {
          ### found
          return $n;
        }

        if ($i == 0 || ($x-$nx)**2 + ($y-$ny)**2 > $hypot[$i]) {
          ### too far away: "$nx,$ny target $x,$y    ".(($x-$nx)**2 + ($y-$ny)**2).' vs '.$hypot[$i]

          while (++$digits[$i] > 1) {
            $digits[$i] = 0;
            if (++$i >= $top) {
              ### backtrack past top ...
              next ARM;
            }
            ### backtrack up
          }

        } else {
          ### descend
          ### assert: $i > 0
          $i--;
          $digits[$i] = 0;
        }
      }
    }
  }
  ### not found below level limit
  return undef;
}

# sub xy_to_n {
#   my ($self, $x, $y) = @_;
#   ### DragonCurve xy_to_n(): "$x, $y"
#
#   $x = _round_nearest($x);
#   $y = _round_nearest($y);
#
#   my ($pow,$exp) = _round_up_pow2(max(abs($x),abs($y)));
#   my $level_limit = 2*$exp+5;
#   if (_is_infinite($level_limit)) {
#     return $level_limit;
#   }
#   ### $level_limit
#
#   my $top = 0;
#   my $i = 0;
#   my @digits = (0);
#   my @sx = (1);
#   my @sy = (0);
#   my @hypot = (3);
#   for (;;) {
#     my $n = 0;
#     foreach my $digit (reverse @digits) { # high to low
#       $n = 2*$n + $digit;
#     }
#     ### consider: "i=$i  digits=".join(',',reverse @digits)."  is n=$n"
#     my ($nx,$ny) = $self->n_to_xy($n);
#
#     if ($i == 0 && $x == $nx && $y == $ny) {
#       ### found
#       return $n;
#     }
#
#     if ($i == 0
#         || ($x-$nx)**2 + ($y-$ny)**2 > $hypot[$i]) {
#       ### too far away: "$nx,$ny target $x,$y    ".(($x-$nx)**2 + ($y-$ny)**2).' vs '.$hypot[$i]
#
#       while (++$digits[$i] > 1) {
#         $digits[$i] = 0;
#         if (++$i <= $top) {
#           ### backtrack up
#
#         } else {
#           ### backtrack extend top
#           if ($i > $level_limit) {
#             ### not found below level limit, outside curve ...
#             return undef;
#           }
#           $digits[$i] = 0;
#           $sx[$i] = ($sx[$top] - $sy[$top]);
#           $sy[$i] = ($sx[$top] + $sy[$top]);
#           $hypot[$i] = ($i % 4 ? 2 : 3) * $hypot[$top];
#           ### assert: $hypot[$i]**2 >= $sx[$i]**2 + $sy[$i]**2
#           $top++;
#         }
#       }
#
#     } else {
#       ### descend
#       ### assert: $i > 0
#       $i--;
#       $digits[$i] = 0;
#     }
#   }
# }

# f = (1 - 1/sqrt(2) = .292
# 1/f = 3.41
# N = 2^level
# Rend = sqrt(2)^level
# Rmin = Rend / 2  maybe
# Rmin^2 = (2^level)/4
# N = 4 * Rmin^2
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### DragonCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"
  $x1 = abs($x1);
  $x2 = abs($x2);
  $y1 = abs($y1);
  $y2 = abs($y2);
  my $xmax = int($x1 > $x2 ? $x1 : $x2);
  my $ymax = int($y1 > $y2 ? $y1 : $y2);
  return (0,
          $self->{'arms'} * ($xmax*$xmax + $ymax*$ymax + 1) * 7);
}

1;
__END__

=for stopwords eg Ryde Dragon Math-PlanePath Nlevel Heighway Harter et al vertices doublings OEIS Online

=head1 NAME

Math::PlanePath::DragonCurve -- dragon curve

=head1 SYNOPSIS

 use Math::PlanePath::DragonCurve;
 my $path = Math::PlanePath::DragonCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is the dragon or paper folding curve by Heighway, Harter, et al,

                 9----8    5---4               2
                 |    |    |   |
                10--11/7---6   3---2           1
                      |            |
      17---16   13---12        0---1       <- Y=0
       |    |    |
      18-19/15-14/22-23                       -1
            |    |    |
           20---21/25-24                      -2
                 |
                26---27                       -3
                      |
    --32   29---29---28                       -4
       |    |
      31---30                                 -5

       ^    ^    ^    ^    ^   ^   ^
      -5   -4   -3   -2   -1  X=0  1 ...

The curve visits "inside" X,Y points twice.  The first of these is X=-2,Y=1
which is N=7 and also N=11.  The corners N=6,7,8 and N=10,11,12 have
touched, but the path doesn't cross itself.  The doubled vertices are all
like this, touching but not crossing, and no edges repeating.

The first step N=1 is to the right along the X axis and the path then slowly
spirals counter-clockwise and progressively fatter.  The end of each
replication is N=2^level which is level*45 degrees around,

    N       X,Y     angle
   ----    -----    -----
     1      1,0        0
     2      1,1       45
     4      0,2       90
     8     -2,2      135
    16     -4,0      180
    32     -4,-4     225
   ...

Here's points N=0 to N=2^9=512 with the N=512 end at the "+" mark.  It's
gone full-circle around to to 45 degrees up again like the initial N=2.

                                    * *     * *
                                  * * *   * * *
                                  * * * * * * * * *
                                  * * * * * * * * *
                            * *   * * * *       * *
                          * * *   * * * *     + * *
                          * * * * * *         * *
                          * * * * * * *
                          * * * * * * * *
                              * * * * * *
                              * * * *
                                  * * * * * * *
                            * *   * * * * * * * *
                          * * *   * * * * * * * *
                          * * * * * * * * * *
                          * * * * * * * * * * * * * * *
                          * * * * * * * * * * * * * * * *
                              * * * * * * * * * * * * * *
                              * * * * * * * * * * * *
        * * * *                   * * * * * * * * * * *
        * * * * *           * *   * * * *       * * * * *
    * * * *   0 *         * * *   * * * *   * * * * * * *
    * * * *               * * * * * *       * * * * *
      * * *               * * * * * * *       * * * *
        * * * *     * *   * * * * * * * *
    * * * * * *   * * *   * * * * * * * *
    * * * * * * * * * * * * * * * * *
      * * * * * * * * * * * * * * * * *
                * * * * *       * * * * *
            * * * * * * *   * * * * * * *
            * * * * *       * * * * *
              * * * *         * * * *

=head2 Paper Folding

The path is called a paper folding curve because it can be generated by
thinking of a long strip of paper folded in half repeatedly then unfolded so
each crease is a 90 degree angle.  The effect is that the curve repeats in
successive doublings turned by 90 degrees and reversed.  For example the
first segment unfolds,

                                          2
                                     ->   |
                     unfold         /     |
                                   |      |
                                          |
    0-------1                     0-------1

Then same again with that L shape, etc,

                                 4
                                 |
                                 |
                                 |
                                 3--------2
           2                              |
           |        unfold          ^     |
           |                         \_   |
           |                              |
    0------1                     0--------1

It can be shown that this unfolding doesn't overlap itself, but the corners
may touch, such as at the X=-2,Y=1 etc noted above.

=head2 Turns

At each point N the curve always turns either to the left or right, it never
goes straight ahead.  The bit above the lowest 1 bit in N gives the turn
direction.  For example at N=11 shown above the curve has just gone
downwards from N=11.  N=12 is binary 0b1100, the lowest 1 bit is the
0b.1.. and the bit above that is a 1, which means turn to the right.
Whereas later at N=18 which has gone downwards from N=17 it's N=18 in binary
0b10010, the lowest 1 is 0b...1., and the bit above that is 0, so turn left.

The bits also give turn after the next by taking the bit above the lowest 0.
For example at N=12 the lowest 0 is the least significant bit, and above
that is a 0 too, so after going to N=13 the next turn is then to the left to
go to N=14.  Or for N=18 the lowest 0 is again the least significant bit,
but above that is a 1 too, so after going to N=19 the next turn is to the
right to go to N=20.

=head2 Arms

The curve fills a quarter of the plane and four copies mesh together
perfectly when rotated by 90, 180 and 270 degrees.  The C<arms> parameter
can choose 1 to 4 curve arms, successively advancing.

For example C<arms =E<gt> 4> begins as follows, with N=0,4,8,12,etc being
one arm, N=1,5,9,13 the second, N=2,6,10,14 the third and N=3,7,11,15 the
fourth.

             20 ------ 16        
                        |
              9 ------5/12 -----  8       23
              |         |         |        |
     17 --- 13/6 --- 0/1/2/3 --- 4/15 --- 19
      |       |         |         |  
     21      10 ----- 14/7 ----- 11
                        |
                       18 ------ 22

With four arms every X,Y point is visited twice (except the origin 0,0 where
all four begin) and every edge between the points is traversed once.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::DragonCurve-E<gt>new ()>

=item C<$path = Math::PlanePath::DragonCurve-E<gt>new (arms =E<gt> 2)>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

The optional C<arms> parameter can 1 to 4 copies of the curve, each arm
successively advancing.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  If there's nothing at
C<$x,$y> then return C<undef>.

The curve visits an C<$x,$y> twice for various points (all the "inside"
points).  In the current code the smaller of the two N values is returned.
Is that the best way?

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 OEIS

The Dragon curve is in Sloane's Online Encyclopedia of Integer Sequences as
turns or a total rotation at each line segment,

    http://oeis.org/A005811  (etc)

    A005811 -- total rotation, 0 up
    A014577 -- turn, 0=left, 1=right
    A014707 -- turn, 1=left, 0=right
    A014709 -- turn, 2=left, 1=right
    A014710 -- turn, 1=left, 2=right
    A082410 -- turn, same as A014577 plus leading 0

The four turn sequences differ only in being 0 and 1 or 1 and 2, and which
is treated as left or right.

For reference, A059125 is almost the same as A014577, but differs at some
positions.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DragonRounded>,
L<Math::PlanePath::DragonMidpoint>,
L<Math::PlanePath::ComplexMinus>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011 Kevin Ryde

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
