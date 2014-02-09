# Copyright 2011, 2012, 2013, 2014 Kevin Ryde

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



# cf A106154 terdragon 6 something
#    A105499 terdragon permute something
#     1->{2,1,2}, 2->{1,3,1}, 3->{3,2,3}.
#     212323212131212131212323212323131323212323212323


package Math::PlanePath::TerdragonCurve;
use 5.004;
use strict;
use List::Util 'first';
use List::Util 'min'; # 'max'
*max = \&Math::PlanePath::_max;

use Math::PlanePath;
*_divrem_mutate = \&Math::PlanePath::_divrem_mutate;

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest',
  'xy_is_even';
use Math::PlanePath::Base::Digits
  'digit_split_lowtohigh';

use vars '$VERSION', '@ISA';
$VERSION = 114;
@ISA = ('Math::PlanePath');

use Math::PlanePath::TerdragonMidpoint;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;
use constant parameter_info_array =>
  [ { name      => 'arms',
      share_key => 'arms_6',
      display   => 'Arms',
      type      => 'integer',
      minimum   => 1,
      maximum   => 6,
      default   => 1,
      width     => 1,
      description => 'Arms',
    } ];

sub dx_minimum {
  my ($self) = @_;
  return ($self->{'arms'} == 1 ? -1 : -2);
}
use constant dx_maximum => 2;
use constant dy_minimum => -1;
use constant dy_maximum => 1;
use constant absdx_minimum => 1;
use constant dsumxy_minimum => -2; # diagonals
use constant dsumxy_maximum => 2;
use constant ddiffxy_minimum => -2;
use constant ddiffxy_maximum => 2;

# arms=1 curve goes at 0,120,240 degrees
# arms=2 second +60 to 60,180,300 degrees
# so when arms==1 dir maximum is 240 degrees
sub dir_maximum_dxdy {
  my ($self) = @_;
  return ($self->{'arms'} == 1
          ? (-1,-1)    # 0,2,4 only           South-West
          : ( 1,-1));  # rotated to 1,3,5 too South-East
}

#------------------------------------------------------------------------------

sub new {
  my $self = shift->SUPER::new(@_);
  $self->{'arms'} = max(1, min(6, $self->{'arms'} || 1));
  return $self;
}

my @dir6_to_si = (1,0,0, -1,0,0);
my @dir6_to_sj = (0,1,0, 0,-1,0);
my @dir6_to_sk = (0,0,1, 0,0,-1);

sub n_to_xy {
  my ($self, $n) = @_;
  ### TerdragonCurve n_to_xy(): $n

  if ($n < 0) { return; }
  if (is_infinite($n)) { return ($n, $n); }

  my $zero = ($n * 0);  # inherit bignum 0

  my $i = 0;
  my $j = 0;
  my $k = 0;
  my $si = $zero;
  my $sj = $zero;
  my $sk = $zero;

  # initial rotation from arm number
  {
    my $int = int($n);
    my $frac = $n - $int;  # inherit possible BigFloat
    $n = $int;             # BigFloat int() gives BigInt, use that

    my $rot = _divrem_mutate ($n, $self->{'arms'});

    my $s = $zero + 1;  # inherit bignum 1
    if ($rot >= 3) {
      $s = -$s;         # rotate 180
      $frac = -$frac;
      $rot -= 3;
    }
    if ($rot == 0)    { $i = $frac; $si = $s; } # rotate 0
    elsif ($rot == 1) { $j = $frac; $sj = $s; } # rotate +60
    else              { $k = $frac; $sk = $s; } # rotate +120
  }

  foreach my $digit (digit_split_lowtohigh($n,3)) {
    ### at: "$i,$j,$k   side $si,$sj,$sk"
    ### $digit

    if ($digit == 1) {
      ($i,$j,$k) = ($si-$j, $sj-$k, $sk+$i);  # rotate +120 and add
    } elsif ($digit == 2) {
      $i -= $sk;   # add rotated +60
      $j += $si;
      $k += $sj;
    }

    # add rotated +60
    ($si,$sj,$sk) = ($si - $sk,
                     $sj + $si,
                     $sk + $sj);
  }

  ### final: "$i,$j,$k   side $si,$sj,$sk"
  ### is: (2*$i + $j - $k).",".($j+$k)

  return (2*$i + $j - $k, $j+$k);
}


# all even points when arms==6
sub xy_is_visited {
  my ($self, $x, $y) = @_;
  if ($self->{'arms'} == 6) {
    return xy_is_even($self,$x,$y);
  } else {
    return defined($self->xy_to_n($x,$y));
  }
}

# maximum extent -- no, not quite right
#
#          .----*
#           \
#       *----.
#
# Two triangle heights, so
#     rnext = 2 * r * sqrt(3)/2
#           = r * sqrt(3)
#     rsquared_next = 3 * rsquared
# Initial X=2,Y=0 is rsquared=4
# then X=3,Y=1 is 3*3+3*1*1 = 9+3 = 12 = 4*3
# then X=3,Y=3 is 3*3+3*3*3 = 9+3 = 36 = 4*3^2
#
my @try_dx = (2, 1, -1, -2, -1,  1);
my @try_dy = (0, 1,  1, 0,  -1, -1);

sub xy_to_n {
  return scalar((shift->xy_to_n_list(@_))[0]);
}
sub xy_to_n_list {
  my ($self, $x, $y) = @_;
  ### TerdragonCurve xy_to_n_list(): "$x, $y"

  $x = round_nearest($x);
  $y = round_nearest($y);

  if (is_infinite($x)) {
    return $x;  # infinity
  }
  if (is_infinite($y)) {
    return $y;  # infinity
  }

  my @n_list;
  my $xm = 2*$x;  # doubled out
  my $ym = 2*$y;
  foreach my $i (0 .. $#try_dx) {
    my $t = $self->Math::PlanePath::TerdragonMidpoint::xy_to_n
      ($xm+$try_dx[$i], $ym+$try_dy[$i]);

    ### try: ($xm+$try_dx[$i]).",".($ym+$try_dy[$i])
    ### $t

    next unless defined $t;

    my ($tx,$ty) = n_to_xy($self,$t)  # not a method for TerdragonRounded
      or next;

    if ($tx == $x && $ty == $y) {
      ### found: $t
      if (@n_list && $t < $n_list[0]) {
        unshift @n_list, $t;
      } elsif (@n_list && $t < $n_list[-1]) {
        splice @n_list, -1,0, $t;
      } else {
        push @n_list, $t;
      }
      if (@n_list == 3) {
        return @n_list;
      }
    }
  }
  return @n_list;
}

# minimum  -- no, not quite right
#
#                *----------*
#                 \
#                  \   *
#               *   \
#                    \
#          *----------*
#
# width = side/2
# minimum = side*sqrt(3)/2 - width
#         = side*(sqrt(3)/2 - 1)
#
# minimum 4/9 * 2.9^level roughly
# h = 4/9 * 2.9^level
# 2.9^level = h*9/4
# level = log(h*9/4)/log(2.9)
# 3^level = 3^(log(h*9/4)/log(2.9))
#         = h*9/4, but big bigger for log
#
# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### TerdragonCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"
  my $xmax = int(max(abs($x1),abs($x2)));
  my $ymax = int(max(abs($y1),abs($y2)));
  return (0,
          ($xmax*$xmax + 3*$ymax*$ymax + 1)
          * 2
          * $self->{'arms'});
}

my @dir6_to_dx   = (2, 1,-1,-2, -1, 1);
my @dir6_to_dy   = (0, 1, 1, 0, -1,-1);
my @digit_to_nextturn = (2,-2);
sub n_to_dxdy {
  my ($self, $n) = @_;
  ### n_to_dxdy(): $n

  if ($n < 0) {
    return;  # first direction at N=0
  }
  if (is_infinite($n)) {
    return ($n,$n);
  }

  my $int = int($n);  # integer part
  $n -= $int;         # fraction part

  # initial direction from arm
  my $dir6 = _divrem_mutate ($int, $self->{'arms'});

  my @ndigits = digit_split_lowtohigh($int,3);
  $dir6 += 2 * scalar(grep {$_==1} @ndigits);  # count 1s for total turn
  $dir6 %= 6;
  my $dx = $dir6_to_dx[$dir6];
  my $dy = $dir6_to_dy[$dir6];

  if ($n) {
    # fraction part

    # find lowest non-2 digit, or zero if all 2s or no digits at all
    $dir6 += $digit_to_nextturn[ first {$_!=2} @ndigits, 0];
    $dir6 %= 6;
    $dx += $n*($dir6_to_dx[$dir6] - $dx);
    $dy += $n*($dir6_to_dy[$dir6] - $dy);
  }
  return ($dx, $dy);
}

1;
__END__


# old n_to_xy()
#
# # initial rotation from arm number
# my $arms = $self->{'arms'};
# my $rot = $n % $arms;
# $n = int($n/$arms);

# my @digits;
# my (@si, @sj, @sk);  # vectors
# {
#   my $si = $zero + 1; # inherit bignum 1
#   my $sj = $zero;     # inherit bignum 0
#   my $sk = $zero;     # inherit bignum 0
#
#   for (;;) {
#     push @digits, ($n % 3);
#     push @si, $si;
#     push @sj, $sj;
#     push @sk, $sk;
#     ### push: "digit $digits[-1]   $si,$sj,$sk"
#
#     $n = int($n/3) || last;
#
#     # straight + rot120 + straight
#     ($si,$sj,$sk) = (2*$si - $sj,
#                      2*$sj - $sk,
#                      2*$sk + $si);
#   }
# }
# ### @digits
#
# my $i = $zero;
# my $j = $zero;
# my $k = $zero;
# while (defined (my $digit = pop @digits)) {  # digits high to low
#   my $si = pop @si;
#   my $sj = pop @sj;
#   my $sk = pop @sk;
#   ### at: "$i,$j,$k  $digit   side $si,$sj,$sk"
#   ### $rot
#
#   $rot %= 6;
#   if ($rot == 1)    { ($si,$sj,$sk) = (-$sk,$si,$sj); }
#   elsif ($rot == 2) { ($si,$sj,$sk) = (-$sj,-$sk,$si); }
#   elsif ($rot == 3) { ($si,$sj,$sk) = (-$si,-$sj,-$sk); }
#   elsif ($rot == 4) { ($si,$sj,$sk) = ($sk,-$si,-$sj); }
#   elsif ($rot == 5) { ($si,$sj,$sk) = ($sj,$sk,-$si); }
#
#   if ($digit) {
#     $i += $si;  # digit=1 or digit=2
#     $j += $sj;
#     $k += $sk;
#     if ($digit == 2) {
#       $i -= $sj;  # digit=2, straight+rot120
#       $j -= $sk;
#       $k += $si;
#     } else {
#       $rot += 2;  # digit=1
#     }
#   }
# }
#
# $rot %= 6;
# $i = $frac * $dir6_to_si[$rot] + $i;
# $j = $frac * $dir6_to_sj[$rot] + $j;
# $k = $frac * $dir6_to_sk[$rot] + $k;
#
# ### final: "$i,$j,$k"
# return (2*$i + $j - $k, $j+$k);


=for stopwords eg Ryde Dragon Math-PlanePath Nlevel Knuth et al vertices doublings OEIS Online terdragon ie morphism si,sj,sk dX,dY

=head1 NAME

Math::PlanePath::TerdragonCurve -- triangular dragon curve

=head1 SYNOPSIS

 use Math::PlanePath::TerdragonCurve;
 my $path = Math::PlanePath::TerdragonCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

X<Davis>X<Knuth, Donald>This is the terdragon curve by Davis and Knuth,


              30                28                                  7
            /     \           /     \
           /       \         /       \
     31,34 -------- 26,29,32 ---------- 27                          6
          \        /         \
           \      /           \
           24,33,42 ---------- 22,25                                5
           /      \           /     \
          /        \         /       \
    40,43,46 ------ 20,23,44 -------- 12,21            10           4
          \        /        \        /      \        /     \
           \      /          \      /        \      /       \
             18,45 --------- 13,16,19 ------ 8,11,14 -------- 9     3
                  \          /       \      /       \
                   \        /         \    /         \
                       17              6,15 --------- 4,7           2
                                            \        /    \
                                             \      /      \
                                               2,5 ---------- 3     1
                                                   \
                                                    \
                                         0 ----------- 1         <-Y=0

       ^       ^        ^        ^       ^      ^      ^      ^
      -4      -3       -2       -1      X=0     1      2      3

Points are a triangular grid using every second integer X,Y as per
L<Math::PlanePath/Triangular Lattice>.

The base figure is an "S" shape

       2-----3
        \
         \
    0-----1

which then repeats in self-similar style, so N=3 to N=6 is a copy rotated
+120 degrees, which is the angle of the N=1 to N=2 edge,

    6      4          base figure repeats
     \   / \          as N=3 to N=6,
      \/    \         rotated +120 degrees
      5 2----3
        \
         \
    0-----1

Then N=6 to N=9 is a plain horizontal, which is the angle of N=2 to N=3,

          8-----9       base figure repeats
           \            as N=6 to N=9,
            \           no rotation
       6----7,4
        \   / \
         \ /   \
         5,2----3
           \
            \
       0-----1

Notice X=1,Y=1 is visited twice, as N=2 and N=5.  Similarly X=2,Y=2 as N=4
and N=7.  Each point can repeat up to 3 times.  "Inner" points are 3 times
and on the edges of the curve area up to 2 times.  The first tripled point
is X=1,Y=3 which as shown above is N=8, N=11 and N=14.

The curve never crosses itself.  The vertices touch as triangular corners
and no edges repeat.

The shape is the same as the C<GosperSide>, but the turns here are by 120
degrees each whereas the C<GosperSide> is by 60 degrees each.  The extra
angle here tightens up the shape.

=head2 Spiralling

The first step N=1 is to the right along the X axis and the path then slowly
spirals anti-clockwise and progressively fatter.  The end of each
replication is

    Nlevel = 3^level

That point is at level*30 degrees around (as reckoned with Y*sqrt(3) for a
triangular grid).

    Nlevel      X, Y     Angle (degrees)
    ------    -------    -----
       1        1, 0        0
       3        3, 1       30
       9        3, 3       60
      27        0, 6       90
      81       -9, 9      120
     243      -27, 9      150
     729      -54, 0      180

The following is points N=0 to N=3^6=729 going half-circle around to 180
degrees.  The N=0 origin is marked "0" and the N=729 end is marked "E".

=cut

# the following generated by
#   math-image --path=TerdragonCurve --expression='i<=729?i:0' --text --size=132x40

=pod

                               * *               * *
                            * * * *           * * * *
                           * * * *           * * * *
                            * * * * *   * *   * * * * *   * *
                         * * * * * * * * * * * * * * * * * * *
                        * * * * * * * * * * * * * * * * * * *
                         * * * * * * * * * * * * * * * * * * * *
                            * * * * * * * * * * * * * * * * * * *
                           * * * * * * * * * * * *   * *   * * *
                      * *   * * * * * * * * * * * *           * *
     * E           * * * * * * * * * * * * * * * *           0 *
    * *           * * * * * * * * * * * *   * *
     * * *   * *   * * * * * * * * * * * *
    * * * * * * * * * * * * * * * * * * *
     * * * * * * * * * * * * * * * * * * * *
        * * * * * * * * * * * * * * * * * * *
       * * * * * * * * * * * * * * * * * * *
        * *   * * * * *   * *   * * * * *
                 * * * *           * * * *
                * * * *           * * * *
                 * *               * *

=head2 Tiling

The little "S" shapes of the base figure N=0 to N=3 can be thought of as a
rhombus

       2-----3
      .     .
     .     .
    0-----1

The "S" shapes of each 3 points make a tiling of the plane with those rhombi

        \     \ /     /   \     \ /     /
         *-----*-----*     *-----*-----*
        /     / \     \   /     / \     \
     \ /     /   \     \ /     /   \     \ /
    --*-----*     *-----*-----*     *-----*--
     / \     \   /     / \     \   /     / \
        \     \ /     /   \     \ /     /
         *-----*-----*     *-----*-----*
        /     / \     \   /     / \     \
     \ /     /   \     \ /     /   \     \ /
    --*-----*     *-----o-----*     *-----*--
     / \     \   /     / \     \   /     / \
        \     \ /     /   \     \ /     /
         *-----*-----*     *-----*-----*
        /     / \     \   /     / \     \

As per for example

=over

L<http://tilingsearch.org/HTML/data23/C07A.html>

=back

=head2 Arms

The curve fills a sixth of the plane and six copies rotated by 60, 120, 180,
240 and 300 degrees mesh together perfectly.  The C<arms> parameter can
choose 1 to 6 such curve arms successively advancing.

For example C<arms =E<gt> 6> begins as follows.  N=0,6,12,18,etc is the
first arm (the same shape as the plain curve above), then N=1,7,13,19 the
second, N=2,8,14,20 the third, etc.

                  \         /             \           /
                   \       /               \         /
                --- 8/13/31 ---------------- 7/12/30 ---
                  /        \               /         \
     \           /          \             /           \          /
      \         /            \           /             \        /
    --- 9/14/32 ------------- 0/1/2/3/4/5 -------------- 6/17/35 ---
      /         \            /           \             /        \
     /           \          /             \           /          \
                  \        /               \         /
               --- 10/15/33 ---------------- 11/16/34 ---
                  /        \               /         \
                 /          \             /           \

With six arms every X,Y point is visited three times, except the origin 0,0
where all six begin.  Every edge between points is traversed once.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::TerdragonCurve-E<gt>new ()>

=item C<$path = Math::PlanePath::TerdragonCurve-E<gt>new (arms =E<gt> 6)>

Create and return a new path object.

The optional C<arms> parameter can make 1 to 6 copies of the curve, each arm
successively advancing.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  If there's nothing at
C<$x,$y> then return C<undef>.

The curve can visit an C<$x,$y> up to three times.  In the current code the
smallest of the these N values is returned.  Is that the best way?

=item C<@n_list = $path-E<gt>xy_to_n_list ($x,$y)>

Return a list of N point numbers for coordinates C<$x,$y>.  There can be
none, one, two or three N's for a given C<$x,$y>.

=back

=head2 Descriptive Methods

=over

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=item C<$dx = $path-E<gt>dx_minimum()>

=item C<$dx = $path-E<gt>dx_maximum()>

=item C<$dy = $path-E<gt>dy_minimum()>

=item C<$dy = $path-E<gt>dy_maximum()>

The dX,dY values, on the first arm, take three possible combinations, at 120
degree angles.

    dX,dY
    -----
     2, 0        dX minimum = -1, maximum = +2  for arms=1
    -1, 1        dY minimum = -1, maximum = +1
     1,-1

For 2 or more arms the second arm is rotated by 60 degrees so giving the
following additional combinations, for a total six.  This changes the dX,dY
minima.

    dX,dY also
    -----
    -2, 0        dX minimum = -2, maximum = +2   arms >= 2
     1, 1        dY minimum = -1, maximum = +1
    -1,-1

=back

=head1 FORMULAS

=head2 N to X,Y

There's no reversals or reflections in the curve so C<n_to_xy()> can take
the digits of N either low to high or high to low and apply what is
effectively powers of the N=3 position.  The current code goes low to high
using i,j,k coordinates as described in L<Math::PlanePath/Triangular
Calculations>.

    si = 1    # position of endpoint N=3^level
    sj = 0    #    where level=number of digits processed
    sk = 0

    i = 0     # position of N for digits so far processed
    j = 0
    k = 0

    loop base 3 digits of N low to high
       if digit == 0
          i,j,k no change
       if digit == 1
          (i,j,k) = (si-j, sj-k, sk+i)  # rotate +120, add si,sj,sk
       if digit == 2
          i -= sk      # add (si,sj,sk) rotated +60
          j += si
          k += sj

       (si,sj,sk) = (si - sk,      # add rotated +60
                     sj + si,
                     sk + sj)

The digit handling is a combination of rotate and offset,

    digit==1                   digit 2
    rotate and offset          offset at si,sj,sk rotated

         ^                          2------>
          \
           \                          \
    *---  --1                  *--   --*

The calculation can also be thought of in term of w=1/2+I*sqrt(3)/2, a
complex number sixth root of unity.  i is the real part, j in the w
direction (60 degrees), and k in the w^2 direction (120 degrees).  si,sj,sk
increase as if multiplied by w+1.

=head2 Turn

At each point N the curve always turns 120 degrees either to the left or
right, it never goes straight ahead.  If N is written in ternary then the
lowest non-zero digit gives the turn

   ternary lowest
   non-zero digit     turn
   --------------     -----
         1            left
         2            right

At N=3^level or N=2*3^level the turn follows the shape at that 1 or 2 point.
The first and last unit step in each level are in the same direction, so the
next level shape gives the turn.

       2*3^k-------3^(k+1)
          \
           \
    0-------1*3^k

=head2 Next Turn

The next turn, ie. the turn at position N+1, can be calculated from the
ternary digits of N similarly.  The lowest non-2 digit gives the turn.

   ternary lowest
     non-2 digit       turn
   --------------      -----
          0            left
          1            right

If N is all 2s then the lowest non-2 is taken to be a 0 above the high end.
For example N=8 is 22 ternary so considered 022 for lowest non-2 digit=0 and
turn left after the segment at N=8, ie. at point N=9 turn left.

This rule works for the same reason as the plain turn above.  The next turn
of N is the plain turn of N+1 and adding +1 turns trailing 2s into trailing
0s and increments the 0 or 1 digit above them to be 1 or 2.

=head2 Total Turn

The direction at N, ie. the total cumulative turn, is given by the number of
1 digits when N is written in ternary,

    direction = (count 1s in ternary N) * 120 degrees

For example N=12 is ternary 110 which has two 1s so the cumulative turn at
that point is 2*120=240 degrees, ie. the segment N=16 to N=17 is at angle
240.

The segments for digit 0 or 2 are in the "current" direction unchanged.  The
segment for digit 1 is rotated +120 degrees.

=head2 X,Y to N

The current code applies C<TerdragonMidpoint> C<xy_to_n()> to calculate six
candidate N from the six edges around a point.  Those N values which convert
back to the target X,Y by C<n_to_xy()> are the results for
C<xy_to_n_list()>.

The six edges are three going towards the point and three going away.  The
midpoint calculation gives N-1 for the towards and N for the away.  Is there
a good way to tell which edge will be the smaller?  Or just which 3 edges
lead away?  It would be directions 0,2,4 for the even arms and 1,3,5 for the
odd ones, but identifying the boundaries of those arms to know which is
which is tricky.

=head2 X,Y Visited

When arms=6 all "even" points of the plane are visited.  As per the
triangular representation of X,Y this means

    X+Y mod 2 == 0        "even" points

=head2 Boundary Length

The length of the boundary of the terdragon on points N=0 to N=3^k
inclusive, taking each line segment as length 1, is

    boundary[k] = / 2      if k=0     (N=0 to N=1)
                  \ 3*2^k  if k>=1    (N=0 to N=3^k)
                = 2, 6, 12, 24, 48, ...

The boundary follows the curve edges around from the origin until returning
there.  So the single line segment N=0 to N=1 is boundary length 2, or the
"S" shape of N=0 to N=3 is length 6.  This first "S" is 3x the length of the
preceding but thereafter the way the curve touches itself means the boundary
grows by less than that (only 2x per level).

The boundary formula can be calculated from the way the curve meets when it
replicates.  Consider the level N=0 to N=3^(k-1) and take its boundary
length in two parts as a short side R on the right and the "V" shaped
indentation L on the left.  These are shown as plain lines here but are
wiggly as the curve becomes bigger and fatter.

             R         R[k] = right side boundary length
          2-----3      L[k] = left side boundary length
           \ L       initial
         L  \          R[0] = 1
       0-----1         L[0] = 2
          R          boundary[k+1] = 2*R[k] + 2*L[k]
                       boundary[1] = 6

By symmetry the two sides of the terdragon are the same length, so the total
boundary is twice the right side,

    boundary[k] = 2*R[k+1]

When the curve is tripled out to the next level N=3^k the boundary length
does not triple because the sides marked "===" in the following diagram
enclose lengths 2*R and 2*L which would have been boundary, leaving only 4*R
and 4*L.

             R          for k >= 0
          *-----3       R[k+1] = R[k] + L[k]    # per 0 to 1
           \ L          L[k+1] = R[k] + L[k]    # per 0 to 2
          L \
       2=====@        
        \   / \ R     
      R  \ /   \        initial boundary[1] = 6
          @=====1       so  boundary[k]
           \ L          except boundary[0] = 2
          L \
       0-----*
         R

The two recurrences for R and L are the same, so R[k]=L[k] for k>=1 and
hence

    R[k+1] = 2*R[k]                    k >= 1

    boundary[k] = 2*boundary[k-1]      k >= 2
                = 3*2^k          from initial boundary[1] = 6

=head2 Area

The area enclosed by the curve from N=0 to N=3^k inclusive is

    area[k] = / 0                      if k=0
              \ 2*(3^(k-1) - 2^(k-1))  if k >=1
            = 0, 0, 2, 10, 38, 130, 422, 1330, 4118, ...

=cut

# perl -e '$,=", "; print map{2*(3**($_-1)-2**($_-1))} 1 .. 8'
# Pari: for(n=1,8,print(2*(3^(n-1)-2^(n-1)),","))

=pod

The area can be calculated from the number of line segments less the
boundary segments.  Imagine an equilateral triangle on each side of a line
segment

       *      
      / \       triangular area each side of line 0--1
     /   \
    0-----1
     \   /
      \ /
       *

A line which is on the boundary of the curve should count as only 1
triangle, not 2.  Then the area inside the curve will have 3 triangles
overlapping in each area, one for each line segment surrounding, so divide
by 3.

              2*3^k - boundary[k]
    area[k] = ------------------- = 2*(3^(k-1) + 2^(k-1))
                      3

This works because the inside of the curve always has every edge traversed
exactly once and hence always 3 line segments surrounding each enclosed
triangle.

=head2 Area vs Rhombus

The area of the curve approaches the area of a rhombus made of two triangles
between the endpoints.

       *-----N
      . \   .          side = sqrt(3)^k
     .   \ .           rhombus area = 2 * side^2 = 2*3^k
    O-----*

    terdragon    2*(3^k - 2^k)
    --------- =  ------------- -> 1 as k->infinity
    rhombus          2*3^k

This is as if the area of the A-B and C-D endpoints became negligible and
only the centre triangles above mattered.

This ratio is exact when the terdragon is reckoned as a fractal with unit
length and infinitely smaller wiggles, ie. the area of the dragon is the
same as the area of the rhombus.

=head2 Area by Replication

The area can also be calculated directly from the replication.  When the
curve triplicates the area enclosed by the end two copies A-B and C-D are
unchanged.  In the middle two triangles of area 2*3^k are enclosed.

       *-----D
        \              A[k] = 2 * A[k-1]     # AB and CD
         \                  + 2 * 3^(k-2)    # centre triangles
    C-----f                 - 2 * A[k-2]/2   # Cf, Be insides
     \   / \                + 2 * A[k-2]/2   # Ce, Bf outsides
      \ /   \
       e-----B              = 2*A[k-1] + 2*3^(k-2)
        \
         \             sum to
    A-----*            A[k] = 2*(3^(k-1) - 2^(k-1))

=cut

# A[0] to N=1   0
# A[1] to N=2   0
# A[2] to N=9   k=2; 2*0 + 2*3^(k-2) == 2
# A[2] to N=27  k=3; 2*2 + 2*3^(k-2) == 10
# A[2] to N=81  k=4; 2*10 + 2*3^(k-2) == 38

=pod

The centre triangles duplicate the area on the underside of the C-f curve
segment and upper side of the B-e segment.  The terdragon is symmetric on
the two sides of the line between its endpoints so the part on the upper
side is half the curve, so subtract 2*A[k-2]/2.

But then there are 2 similar half curve A[k-2]/2 areas on the outer sides of
the B-f and C-e segments to be added.  Those extra insides and omitted
outsides cancel out.

=cut

# A[k] = 2^1*3^(k-1) + 2^2*3^(k-2) + ... + 2^k*3^0
#      = 2* (3^k - 2^k)/(3-2)
#
#            *
#           / \       area = base^2
#   *      *---*
#  / \    / \ / \
# *---*  *---*---*
#
#       *-----D
#        \
#         \
#    *-----*                  R[3] = -1+1+1 = 1
#     \   / \                 L[3] = -1+1-1+1+1+1 = 4
#      \ /   \                A[3] = 2R+2L = 10
#       *-----*     *
#        \   / \   / \
#         \ /   \ /   \
#    C-----*-----*-----B
#     \   / \   / \
#      \ /   \ /   \
#       *     *-----*
#              \   / \
#               \ /   \
#                *-----*
#                 \
#                  \
#             A-----*
#
#  2*(3^k - 2^k) / 3^k -> 2

=pod

=head1 OEIS

The terdragon is in Sloane's Online Encyclopedia of Integer Sequences as,

=over

L<http://oeis.org/A080846> (etc)

=back

    A080846   next turn 0=left,1=right, by 120 degrees
                (n=0 is turn at N=1)

    A060236   turn 1=left,2=right, by 120 degrees
                (lowest non-zero ternary digit)
    A137893   turn 1=left,0=right (morphism)
    A189640   turn 0=left,1=right (morphism, extra initial 0)
    A189673   turn 1=left,0=right (morphism, extra initial 0)
    A038502   strip trailing ternary 0s,
                taken mod 3 is turn 1=left,2=right

A189673 and A026179 start with extra initial values arising from their
morphism definition.  That can be skipped to consider the turns starting
with a left turn at N=1.

    A026225   N positions of left turns,
                being (3*i+1)*3^j so lowest non-zero digit is a 1
    A026179   N positions of right turns (except initial 1)
    A060032   bignum turns 1=left,2=right to 3^level

    A062756   total turn, count ternary 1s
    A005823   N positions where total turn == 0, ternary no 1s

    A007283   boundary length N=0 to N=3^k for k>=1, being 3*2^k
    A056182   area enclosed N=0 to N=3^k, being 2*(3^k-2^k)
    A081956     same

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::TerdragonRounded>,
L<Math::PlanePath::TerdragonMidpoint>,
L<Math::PlanePath::GosperSide>

L<Math::PlanePath::DragonCurve>,
L<Math::PlanePath::R5DragonCurve>

Larry Riddle's Terdragon page, for boundary and area calculations of the
terdragon as an infinite fractal
L<http://ecademy.agnesscott.edu/~lriddle/ifs/heighway/terdragon.htm>

=head1 HOME PAGE

L<http://user42.tuxfamily.org/math-planepath/index.html>

=head1 LICENSE

Copyright 2011, 2012, 2013, 2014 Kevin Ryde

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
