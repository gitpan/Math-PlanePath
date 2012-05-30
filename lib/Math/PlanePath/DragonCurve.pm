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


# math-image --path=DragonCurve --lines --scale=20
# math-image --path=DragonCurve --all --scale=10
# math-image --path=DragonCurve --output=numbers_dash
#
# Harter first to show copies of the dragon fit together ...
#
# cf A088431 run lengths of dragon turns
#    A007400 cont frac 1/2^1 + 1/2^2 + 1/2^4 + 1/2^8 + ... 1/2^(2^n)
#            = 0.8164215090218931...
#    2,4,6 values
#    a(0)=0,
#    a(1)=1,
#    a(2)=4,
#    a(8n) = a(8n+3) = 2,
#    a(8n+4) = a(8n+7) = a(16n+5) = a(16n+14) = 4,
#    a(16n+6) = a(16n+13) = 6,
#    a(8n+1) = a(4n+1),
#    a(8n+2) = a(4n+2)
#

package Math::PlanePath::DragonCurve;
use 5.004;
use strict;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use Math::PlanePath;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

use Math::PlanePath::DragonMidpoint;

use vars '$VERSION', '@ISA';
$VERSION = 76;
@ISA = ('Math::PlanePath');

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

  my $zero = ($n * 0);  # inherit bignum 0

  # initial rotation from arm number $n mod $arms
  my $arms = $self->{'arms'};
  my $rot = $n % $arms;
  $n = int($n/$arms);

  my @digits = Math::PlanePath::_digit_split_lowtohigh($n,2);
  ### @digits


  my @sx;
  my @sy;
  {
    my $sy = $zero;   # inherit BigInt 0
    my $sx = $sy + 1; # inherit BigInt 1
    ### $sx
    ### $sy

    foreach (@digits) {
      push @sx, $sx;
      push @sy, $sy;
      # (sx,sy) + rot+90(sx,sy), is multiply (i+1)
      ($sx,$sy) = ($sx - $sy,
                   $sy + $sx);
    }
  }

  my $rev = 0;
  my $x = $zero;
  my $y = $zero;
  while (defined (my $digit = pop @digits)) {  # high to low
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
  $x = $frac * $rot_to_sx[$rot] + $x;
  $y = $frac * $rot_to_sy[$rot] + $y;

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
my @try_dx = (0,0,-1,-1);
my @try_dy = (0,1,1,0);

sub xy_to_n {
  return scalar((shift->xy_to_n_list(@_))[0]);
}
sub xy_to_n_list {
  my ($self, $x, $y) = @_;
  ### DragonCurve xy_to_n(): "$x, $y"

  $x = _round_nearest($x);
  $y = _round_nearest($y);

  if (_is_infinite($x)) {
    return $x;  # infinity
  }
  if (_is_infinite($y)) {
    return $y;  # infinity
  }

  if ($x == 0 && $y == 0) {
    return (0 .. $self->arms_count - 1);
  }

  my @n_list;
  my $xm = $x+$y;  # rotate -45 and mul sqrt(2)
  my $ym = $y-$x;
  foreach my $dx (0,-1) {
    foreach my $dy (0,1) {
      my $t = $self->Math::PlanePath::DragonMidpoint::xy_to_n
        ($xm+$dx, $ym+$dy);
      next unless defined $t;

      my ($tx,$ty) = $self->n_to_xy($t)
        or next;

      if ($tx == $x && $ty == $y) {
        ### found: $t
        if (@n_list && $t < $n_list[0]) {
          unshift @n_list, $t;
        } else {
          push @n_list, $t;
        }
        if (@n_list == 2) {
          return @n_list;
        }
      }
    }
  }
  return @n_list;
}

# f = (1 - 1/sqrt(2) = .292
# 1/f = 3.41
# N = 2^level
# Rend = sqrt(2)^level
# Rmin = Rend / 2  maybe
# Rmin^2 = (2^level)/4
# N = 4 * Rmin^2
#
# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### DragonCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"
  my $xmax = int(max(abs($x1),abs($x2)));
  my $ymax = int(max(abs($y1),abs($y2)));
  return (0,
          $self->{'arms'} * ($xmax*$xmax + $ymax*$ymax + 1) * 7);
}

# Not quite right yet ...
#
# sub rect_to_n_range {
#   my ($self, $x1,$y1, $x2,$y2) = @_;
#   ### DragonCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"
#
#
#    my ($length, $level_limit) = _round_down_pow
#      ((max(abs($x1),abs($x2))**2 + max(abs($y1),abs($y2))**2 + 1) * 7,
#       2);
#    $level_limit += 2;
#    ### $level_limit
#
#    if (_is_infinite($level_limit)) {
#      return ($level_limit,$level_limit);
#    }
#
#    $x1 = _round_nearest ($x1);
#    $y1 = _round_nearest ($y1);
#    $x2 = _round_nearest ($x2);
#    $y2 = _round_nearest ($y2);
#    ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
#    ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
#    ### sorted range: "$x1,$y1  $x2,$y2"
#
#
#    my @xend = (0, 1);
#    my @yend = (0, 0);
#    my @xmin = (0, 0);
#    my @xmax = (0, 1);
#    my @ymin = (0, 0);
#    my @ymax = (0, 0);
#    my @sidemax = (0, 1);
#    my $extend = sub {
#      my ($i) = @_;
#      ### extend(): $i
#      while ($i >= $#xend) {
#        ### extend from: $#xend
#        my $xend = $xend[-1];
#        my $yend = $yend[-1];
#        ($xend,$yend) = ($xend-$yend,  # rotate +45
#                         $xend+$yend);
#        push @xend, $xend;
#        push @yend, $yend;
#        my $xmax = $xmax[-1];
#        my $xmin = $xmin[-1];
#        my $ymax = $ymax[-1];
#        my $ymin = $ymin[-1];
#        ### assert: $xmax >= $xmin
#        ### assert: $ymax >= $ymin
#
#        #    ### at: "end=$xend,$yend   $xmin..$xmax  $ymin..$ymax"
#        push @xmax, max($xmax, $xend + $ymax);
#        push @xmin, min($xmin, $xend + $ymin);
#
#        push @ymax, max($ymax, $yend - $xmin);
#        push @ymin, min($ymin, $yend - $xmax);
#
#        push @sidemax, max ($xmax[-1], -$xmin[-1],
#                             $ymax[-1], -$ymin[-1],
#                             abs($xend),
#                             abs($yend));
#      }
#      ### @sidemax
#    };
#
#    my $rect_dist = sub {
#      my ($x,$y) = @_;
#      my $xd = ($x < $x1 ? $x1 - $x
#                : $x > $x2 ? $x - $x2
#                : 0);
#      my $yd = ($y < $y1 ? $y1 - $y
#                : $y > $y2 ? $y - $y2
#                : 0);
#      return max($xd,$yd);
#    };
#
#    my $arms = $self->{'arms'};
#    ### $arms
#    my $n_lo;
#    {
#      my $top = 0;
#      for (;;) {
#      ARM_LO: foreach my $arm (0 .. $arms-1) {
#          my $i = 0;
#          my @digits;
#          if ($top > 0) {
#            @digits = ((0)x($top-1), 1);
#          } else {
#            @digits = (0);
#          }
#
#          for (;;) {
#            my $n = 0;
#            foreach my $digit (reverse @digits) { # high to low
#              $n = 2*$n + $digit;
#            }
#            $n = $n*$arms + $arm;
#            my ($nx,$ny) = $self->n_to_xy($n);
#            my $nh = &$rect_dist ($nx,$ny);
#
#            ### lo consider: "i=$i  digits=".join(',',reverse @digits)."  is n=$n xy=$nx,$ny nh=$nh"
#
#            if ($i == 0 && $nh == 0) {
#              ### lo found inside: $n
#              if (! defined $n_lo || $n < $n_lo) {
#                $n_lo = $n;
#              }
#              next ARM_LO;
#            }
#
#            if ($i == 0 || $nh > $sidemax[$i+2]) {
#              ### too far away: "nxy=$nx,$ny   nh=$nh vs ".$sidemax[$i+2]." at i=$i"
#
#              while (++$digits[$i] > 1) {
#                $digits[$i] = 0;
#                if (++$i <= $top) {
#                  ### backtrack up ...
#                } else {
#                  ### not found within this top and arm, next arm ...
#                  next ARM_LO;
#                }
#              }
#            } else {
#              ### lo descend ...
#              ### assert: $i > 0
#              $i--;
#              $digits[$i] = 0;
#            }
#          }
#        }
#
#        # if an $n_lo was found on any arm within this $top then done
#        if (defined $n_lo) {
#          last;
#        }
#
#        ### lo extend top ...
#        if (++$top > $level_limit) {
#          ### nothing below level limit ...
#          return (1,0);
#        }
#        &$extend($top+3);
#      }
#    }
#
#    my $n_hi = 0;
#   ARM_HI: foreach my $arm (reverse 0 .. $arms-1) {
#      &$extend($level_limit+2);
#      my @digits = ((1) x $level_limit);
#      my $i = $#digits;
#      for (;;) {
#        my $n = 0;
#        foreach my $digit (reverse @digits) { # high to low
#          $n = 2*$n + $digit;
#        }
#
#        $n = $n*$arms + $arm;
#        my ($nx,$ny) = $self->n_to_xy($n);
#        my $nh = &$rect_dist ($nx,$ny);
#
#        ### hi consider: "arm=$arm  i=$i  digits=".join(',',reverse @digits)."  is n=$n xy=$nx,$ny nh=$nh"
#
#        if ($i == 0 && $nh == 0) {
#          ### hi found inside: $n
#          if ($n > $n_hi) {
#            $n_hi = $n;
#            next ARM_HI;
#          }
#        }
#
#        if ($i == 0 || $nh > $sidemax[$i+2]) {
#          ### too far away: "$nx,$ny   nh=$nh vs ".$sidemax[$i+2]." at i=$i"
#
#          while (--$digits[$i] < 0) {
#            $digits[$i] = 1;
#            if (++$i < $level_limit) {
#              ### hi backtrack up ...
#            } else {
#              ### hi nothing within level limit for this arm ...
#              next ARM_HI;
#            }
#          }
#
#        } else {
#          ### hi descend
#          ### assert: $i > 0
#          $i--;
#          $digits[$i] = 1;
#        }
#      }
#    }
#
#    if ($n_hi == 0) {
#      ### oops, lo found but hi not found
#      $n_hi = $n_lo;
#    }
#
#    return ($n_lo, $n_hi);
# }


1;
__END__

=for stopwords eg Ryde Dragon Math-PlanePath Nlevel Heighway Harter et al vertices doublings OEIS Online Jorg Arndt fxtbook DragonMidpoint versa PlanePath

=head1 NAME

Math::PlanePath::DragonCurve -- dragon curve

=head1 SYNOPSIS

 use Math::PlanePath::DragonCurve;
 my $path = Math::PlanePath::DragonCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is the dragon or paper folding curve by Heighway, Harter, et al,

=cut

# math-image --path=DragonCurve --all --output=numbers_dash --size=70x30

=pod

                 9----8    5---4               2
                 |    |    |   |
                10--11,7---6   3---2           1
                      |            |
      17---16   13---12        0---1       <- Y=0
       |    |    |
      18-19,15-14,22-23                       -1
            |    |    |
           20--21,25-24                       -2
                 |
                26---27                       -3
                      |
         --32   29---28                       -4
            |    |
           31---30                            -5

       ^    ^    ^    ^    ^   ^   ^
      -5   -4   -3   -2   -1  X=0  1 ...

The curve visits "inside" X,Y points twice.  The first of these is X=-2,Y=1
which is N=7 and also N=11.  The segments N=6,7,8 and N=10,11,12 have
touched, but the path doesn't cross itself.  The doubled vertices are all
like this, touching but not crossing, and no edges repeating.

=head2 Arms

The curve fills a quarter of the plane and four copies mesh together
perfectly when rotated by 90, 180 and 270 degrees.  The C<arms> parameter
can choose 1 to 4 curve arms successively advancing.

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

=head2 Level Angle

The first step N=1 is to the right along the X axis and the path then slowly
spirals counter-clockwise and progressively fatter.  The end of each
replication is N=2^level which is at level*45 degrees around,

    N       X,Y     angle
   ----    -----    -----
     1      1,0        0
     2      1,1       45
     4      0,2       90
     8     -2,2      135
    16     -4,0      180
    32     -4,-4     225
   ...

Here's points N=0 to N=2^9=512.  "0" is the origin and "+" is N=512.  Notice
it's spiralled around full-circle to angle 45 degrees up again, like the
initial N=2.

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

At a power of two Nlevel=2^level for N=2 or higher, the curve always goes
upward from Nlevel-1 to Nlevel, then leaves it to the left for Nlevel+1.
For example at N=16 the curve goes up from N=15 to N=16, then goes left for
N=16 to N=17.  Likewise at N=32, etc.  The spiral is curls around ever
further but the self-similar twist back again means the Nlevel endpoint is
always at the same up/left orientation.  See L</Total Turn> below for the
net direction in general.

=head2 Level Ranges

The X,Y extents of the path through to Nlevel=2^level can be expressed as a
length in the direction of the Xlevel,Ylevel endpoint and a width across it.

    level even, so endpoint is a straight line
    k = level/2

       +-+     <- Lmax
       | |
       | E     <- Lend = 2^k at Nlevel=2^level
       |
       +---+
           |
         O |   <- Lstart=0
         | |
         +-+   <- Lmin

       ^   ^
    Wmin   Wmax

    Lmax = (7*2^k - 4)/6 if k even
           (7*2^k - 2)/6 if k odd

    Lmin = - (2^k - 1)/3 if k even
           - (2^k - 2)/3 if k odd

    Wmax = (2*2^k - 1) / 3 if k even
           (2*2^k - 2) / 3 if k odd

    Wmin = Lmin

For example level=2 is to Nlevel=2^2=4 and k=level/2=1 is odd so it measures
as follows,

    4      <- Lmax = (7*2^1 - 2)/6 = 2
    |
    3--2
       |
    0--1   <- Lmin = -(2^1 - 2)/3 = 0

    ^  ^Wmax = (2*2^1 - 1)/3 = 1
    |
    Wmin = Lmin = 0

Or level=4 is to Nlevel=2^4=16 and k=4/2=2 is even.  It measures as follows.
The lengthways "L" measures are in the direction of the N=16 endpoint and
the "W" measures are across.

          9----8    5---4        <- Wmax = (2*2^2 - 2)/3 = 2
          |    |    |   |
         10--11,7---6   3---2
               |            |
    16   13---12        0---1
     |    |
    15---14                      <- Wmin = -(2^2 - 1)/3 = -1

     ^                      ^Lmin = Wmin = -1
     |
     Lmax = (7*2^2 - 4)/6 = 4

The formulas are all integer values but the fractions 7/6, 1/3 and 2/3 show
the limits as the level increases.  If scaled so that length Lend=2^k is
reckoned as 1 unit then Lmax extends 1/6 past the end, Lmin and Wmin extend
1/3, and Wmax extends across 2/3.

    +--------+ --
    | -      | 1/6   total length
    || |     |          = 1/6+1+1/3 = 3/2
    || E     | --
    ||       |
    ||       |
    | \      |  1
    |  \     |
    |   --\  |
    |      \ |
    |       ||
    |  O    || --
    |  |    ||
    |  |    || 1/3
    |   ---- |
    +--------+ --
    1/3|  2/3 

    total width = 1/3+2/3 = 1

=head2 Paper Folding

The path is called a paper folding curve because it can be generated by
thinking of a long strip of paper folded in half repeatedly and then
unfolded so each crease is a 90 degree angle.  The effect is that the curve
repeats in successive doublings turned by 90 degrees and reversed.

The first segment unfolds, pivoting at the "1",

                                          2
                                     ->   |
                     unfold         /     |
                      ===>         |      |
                                          |
    0-------1                     0-------1

Then the same again with that L shape, pivoting at the "2", then next
pivoting at the "4", and so on.

                                 4
                                 |
                                 |
                                 |
                                 3--------2
           2                              |
           |        unfold          ^     |
           |         ===>            \_   |
           |                              |
    0------1                     0--------1

It can be shown that this unfolding doesn't overlap itself but the corners
may touch, such as at the X=-2,Y=1 etc noted above.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::DragonCurve-E<gt>new ()>

=item C<$path = Math::PlanePath::DragonCurve-E<gt>new (arms =E<gt> 4)>

Create and return a new path object.

The optional C<arms> parameter can make 1 to 4 copies of the curve, each arm
successively advancing.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  If there's nothing at
C<$x,$y> then return C<undef>.

The curve visits an C<$x,$y> twice for various points (all the "inside"
points).  In the current code the smaller of the two N values is returned.
Is that the best way?

=item C<@n_list = $path-E<gt>xy_to_n_list ($x,$y)>

Return a list of N point numbers for coordinates C<$x,$y>.  There may be up
to two Ns for a given C<$x,$y>.

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 FORMULAS

=head2 X,Y to N

The current code uses the DragonMidpoint C<xy_to_n()> by rotating -45
degrees and offsetting to the midpoints of the four edges around the target
X,Y.  The DragonMidpoint algorithm then gives four candidate N values and
those which convert back to the desired X,Y in the DragonCurve C<n_to_xy()>
are the results for C<xy_to_n_list()>.

    Xmid,Ymid = X+Y, Y-X    # rotate -45 degrees
    dx = 0 or -1
      dy = 0 or 1
        N candidate = DragonMidpoint xy_to_n(Xmid+dx,Ymid+dy)

Since there's at most two DragonCurve Ns at a given X,Y the loop can stop
when two Ns are found.

Only the "leaving" edges will convert back to the target N, so only two of
the four edges actually need to be considered.  Is there a way to identify
them?  For arms 1 and 3 the leaving edges are up,down on odd points (meaning
sum X+Y odd) and right,left for even points (meaning sum X+Y even).  But for
arms 2 and 4 it's the other way around.  Without an easy way to determine
the arm this doesn't seem to help.

=head2 Turns

At each point the curve always turns either left or right, it never goes
straight ahead.  The bit above the lowest 1 in N gives the turn direction.

    N = 0b...z10000   (possibly no trailing 0s)

    z bit    Turn
    -----    ----
      0      left
      1      right

For example N=12 is binary 0b1100, the lowest 1 bit is 0b_1__ and the bit
above that is a 1, which means turn to the right.  Or N=18 is binary
0b10010, the lowest 1 is 0b___1_ and the bit above that is 0, so turn left
there.

This z bit can be picked out with some bit twiddling

    $mask = $n & -$n;          # lowest 1 bit, 000100..00
    $z = $n & ($mask << 1);    # the bit above it
    $turn = ($z == 0 ? 'left' : 'right');

The bits also give the turn after next by looking at the bit above the
lowest 0.

    N = 0b...w01111    (possibly no trailing 1s)

    w bit    Next Turn
    ----     ---------
      0       left
      1       right

For example at N=12=0b1100 the lowest 0 is the least significant bit 0b___0,
and above that is a 0 too, so at N=13 the turn is to the left.  Or for
N=18=0b10010 the lowest 0 is again the least significant bit, but above it
is a 1, so at N=19 the turn is to the right.

This too can be found with some bit twiddling, as for example

    $mask = $n ^ ($n+1);      # low one and below 000111..11
    $w = $n & ($mask + 1);    # the bit above there
    $turn = ($w == 0 ? 'left' : 'right');

There's nothing in the current code directly calculating a turn in this way.

=head2 Total Turn

The total turn can be calculated from the segment replacements resulting
from the bits of N,

    N bits from high to low, start in "plain" state

    plain state
     0 bit -> no change
     1 bit -> turn left, go to reversed state

    reversed state
     1 bit -> no change
     0 bit -> turn left, go to plain state

The 0 or 1 counting arises from the different side a segment expands on in
plain or reversed state.  Segment A to B expands to an "L" shape bend which
is on the right in plain state, but on the left in reversed state.

      plain state             reverse state

      A = = = = B                    +
       \       ^              0bit  / \
        \     /               turn /   \ 1bit
    0bit \   / 1bit           left/     \
          \ /  turn              /       v
           +   left             A = = = = B

In both cases a rotate of +45 degrees keeps the very first segment of the
whole curve in a fixed direction (along the X axis), which means the
south-east slope shown is no-change, which is the 0 of plain or the 1 of
reversed.  And the north-east slope which is the other new edge is a turn
towards the left.

The effect for the bits of N is to count a left turn at each transition from
0 to 1 or from 1 to 0.  Initial "plain" state means the infinite zero bits
at the high end of N are included.  For example N=9 is 0b1001 so three left
turns for curve direction south to go to N=10, as can be seen in the diagram
above.

     1 00 1   N=9
    ^ ^  ^
    +-+--+---three transitions,
             so three left turns for direction south

The transitions can be viewed as a count of how many runs of contiguous 0s
or 1s,

    1 00 1   three blocks of 0s and 1s

X<Arndt, Jorg>
This can be calculated by some bit twiddling with a shift and xor to turn
transitions into 1 bits which can then be counted, as noted by Jorg Arndt
(fxtbook section 1.31.3.1 "The Dragon Curve").

    total turn = count_1_bits ($n ^ ($n >> 1))

The reversing structure of the curve shows up in the total turn at each
point.  The total turns for a block of 2^N is followed by its own reversal
plus 1.  For example,

                    ------->
    N=0 to N=7    0, 1, 2, 1, 2, 3, 2, 1

    N=15 to N=8   1, 2, 3, 2, 3, 4, 3, 2    each is +1
                               <-------

=head1 OEIS

The Dragon curve is in Sloane's Online Encyclopedia of Integer Sequences in
various forms (and see DragonMidpoint for its forms too),

    http://oeis.org/A014577  (etc)

    A014577 -- turn, 0=left,1=right
    A014707 -- turn, 1=left,0=right
    A014709 -- turn, 2=left,1=right
    A014710 -- turn, 1=left,2=right
    A038189 -- bit above lowest 1, is 0=left,1=right (extra initial 0)
    A099545 -- (odd part n) mod 4, is 1=left,3=right
    A082410 -- reversing complement, is 1=left,0=right (extra initial 0)
    A034947 -- Jacobi (-1/n), is 1=left,-1=right
    A112347 -- Jacobi (-1/n), is 1=left,-1=right (extra initial 0)
    A121238 -- -1^(n + some partitions), is 1=left,-1=right (extra 1)

The above turn sequences differ only in having left or right represented as
0, 1, -1, etc, and possible extra initial 0 or 1 arising from the
definitions.

    A003460 -- turns 1 to 2^level-1 in octal

    A005811 -- total turn
    A088748 -- total turn + 1
    A164910 --   cumulative total turn (with the +1)
    A166242 -- double/halving, is 2^(total turn)

    A088431 -- turn sequence run lengths
    A007400 --   2*runlength

    A091072 -- odd part is 4K+1, is N positions of the left turns
    A126937 -- points numbered like SquareSpiral (N-1 and flip Y)

The run lengths A088431 and A007400 are in fact from a continued fraction
expansion of an infinite sum

        1   1   1     1      1              1
    1 + - + - + -- + --- + ----- + ... + ------- + ...
        2   4   16   256   65536         2^(2^k)

X<Shallit, Jeffrey>
X<Kmosek>
Jeffrey Shallit, and independently by M. Kmosek too, shows how continued
fraction terms repeated in reverse gives rise to this sort of value,

    http://www.cs.uwaterloo.ca/~shallit/Papers/scf.ps

The A126937 SquareSpiral numbering has the dragon curve and square
spiralling with their Y axes in opposite directions, as shown in its
F<a126937.pdf>.  So the dragon curve turns up towards positive Y but the
square spiral is numbered down towards negative Y (or vice versa).
PlanePath code for this starting at C<$i=0> would be

      my $dragon = Math::PlanePath::DragonCurve->new;
      my $square = Math::PlanePath::SquareSpiral->new;
      my ($x, $y) = $dragon->n_to_xy ($i);
      my $A126937_of_i = $square->xy_to_n ($x, -$y) - 1;

For reference, "dragon-like" A059125 is similar to the turn sequence
A014707, but differs in having the "middle" value for each replication come
from successive values of the sequence itself, or something like that.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DragonRounded>,
L<Math::PlanePath::DragonMidpoint>,
L<Math::PlanePath::R5DragonCurve>,
L<Math::PlanePath::TerdragonCurve>

L<Math::PlanePath::ComplexMinus>,
L<Math::PlanePath::ComplexPlus>,
L<Math::PlanePath::CCurve>

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
