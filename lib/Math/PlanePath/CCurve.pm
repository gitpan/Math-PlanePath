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


# math-image --path=CCurve --output=numbers_dash
#
# pos(2^et+r) = (i+1)^et + i*pos(r)
# N=2^e0+2^e1+...+2^e(t-1)+2^et  e0 high bit
# pos = (i+1)^e0 + i*(i+1)^e1 + ... + i^(t-1)*(i+1)^e(t-1) + i^t*(i+1)^et

# Levy Plane or space curves and surfaces consisting of parts similar to the
# whole.  In Edgar classics on fractals pp 181-239.

# * Bailey, Kim, Strichartz Inside the Levy Dragon, AMM 109 2002 689-703
#   http://www.jstor.org/stable/3072395
#   http://www.mathlab.cornell.edu/twk6
#   http://www.mathlab.cornell.edu/%7Etwk6/program.html


package Math::PlanePath::CCurve;
use 5.004;
use strict;
use List::Util 'min','max','sum';

use vars '$VERSION', '@ISA';
$VERSION = 114;
use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_divrem_mutate = \&Math::PlanePath::_divrem_mutate;

use Math::PlanePath::KochCurve;
*_digit_join_hightolow = \&Math::PlanePath::KochCurve::_digit_join_hightolow;

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'round_down_pow',
  'bit_split_lowtohigh',
  'digit_split_lowtohigh',
  'digit_join_lowtohigh';

# uncomment this to run the ### lines
# use Smart::Comments;


# Not sure about this yet ... 2 or 4 ?
# use constant parameter_info_array => [ { name      => 'arms',
#                                          share_key => 'arms_2',
#                                          display   => 'Arms',
#                                          type      => 'integer',
#                                          minimum   => 1,
#                                          maximum   => 2,
#                                          default   => 1,
#                                          width     => 1,
#                                          description => 'Arms',
#                                        } ];

use constant n_start => 0;
use constant dx_minimum => -1;
use constant dx_maximum => 1;
use constant dy_minimum => -1;
use constant dy_maximum => 1;
use constant dsumxy_minimum => -1; # straight only
use constant dsumxy_maximum => 1;
use constant ddiffxy_minimum => -1;
use constant ddiffxy_maximum => 1;
use constant dir_maximum_dxdy => (0,-1); # South


#------------------------------------------------------------------------------

sub new {
  my $self = shift->SUPER::new(@_);
  $self->{'arms'} = max(1, min(2, $self->{'arms'} || 1));
  return $self;
}


sub n_to_xy {
  my ($self, $n) = @_;
  ### CCurve n_to_xy(): $n

  if ($n < 0) { return; }
  if (is_infinite($n)) { return ($n, $n); }

  my $zero = ($n * 0);  # inherit bignum 0
  my $x = $zero;
  my $y = $zero;
  {
    my $int = int($n);
    $x = $n - $int;  # inherit possible BigFloat
    $n = $int;        # BigFloat int() gives BigInt, use that
  }

  # initial rotation from arm number $n mod $arms
  my $rot = _divrem_mutate ($n, $self->{'arms'});

  my $len = $zero+1;
  foreach my $digit (digit_split_lowtohigh($n,4)) {
    ### $digit

    if ($digit == 0) {
      ($x,$y) = ($y,-$x);    # rotate -90
    } elsif ($digit == 1) {
      $y -= $len;            # at Y=-len
    } elsif ($digit == 2) {
      $x += $len;            # at X=len,Y=-len
      $y -= $len;
    } else {
      ### assert: $digit == 3
      ($x,$y) = (2*$len - $y,  # at X=2len,Y=-len and rotate +90
                 $x-$len);
    }
    $rot++; # to keep initial direction
    $len *= 2;
  }

  if ($rot & 2) {
    $x = -$x;
    $y = -$y;
  }
  if ($rot & 1) {
    ($x,$y) = (-$y,$x);
  }

  ### final: "$x,$y"
  return ($x,$y);
}

# point N=2^(2k) at XorY=+/-2^k  radius 2^k
#       N=2^(2k-1) at X=Y=+/-2^(k-1) radius sqrt(2)*2^(k-1)
# radius = sqrt(2^level)
# R(l)-R(l-1) = sqrt(2^level) - sqrt(2^(level-1))
#             = sqrt(2^level) * (1 - 1/sqrt(2))
# about 0.29289

# len=1 extent of lower level 0
# len=4 extent of lower level 2
# len=8 extent of lower level 4+1 = 5
# len=16 extent of lower level 8+3
# len/2 + len/4-1

my @digit_to_rot = (-1, 1, 0, 1);
my @dir4_to_dsdd = ([1,-1],[1,1],[-1,1],[-1,-1]);

sub xy_to_n {
  return scalar((shift->xy_to_n_list(@_))[0]);
}
sub xy_to_n_list {
  my ($self, $x, $y) = @_;
  ### CCurve xy_to_n(): "$x, $y"

  $x = round_nearest($x);
  $y = round_nearest($y);
  my $zero = $x*0*$y;

  ($x,$y) = ($x + $y, $y - $x);  # sum and diff
  if (is_infinite($x)) { return $x; }
  if (is_infinite($y)) { return $y; }

  my @n_list;
  foreach my $dsdd (@dir4_to_dsdd) {
    my ($ds,$dd) = @$dsdd;
    ### attempt: "ds=$ds  dd=$dd"
    my $s = $x;  # sum X+Y
    my $d = $y;  # diff Y-X
    my @nbits;

    until ($s >= -1 && $s <= 1 && $d >= -1 && $d <= 1) {
      ### at: "s=$s, d=$d   nbits=".join('',reverse @nbits)
      my $bit = $s % 2;
      push @nbits, $bit;
      if ($bit) {
        $s -= $ds;
        $d -= $dd;
        ($ds,$dd) = ($dd,-$ds); # rotate -90
      }

      # divide 1/(1+i) = (1-i)/(1^2 - i^2)
      #                = (1-i)/2
      # so multiply (s + i*d) * (1-i)/2
      #   s = (s + d)/2
      #   d = (d - s)/2
      #
      ### assert: (($s+$d)%2)==0

      # this form avoids overflow near DBL_MAX
      my $odd = $s % 2;
      $s -= $odd;
      $d -= $odd;
      $s /= 2;
      $d /= 2;
      ($s,$d) = ($s+$d+$odd, $d-$s);
    }

    # five final positions
    #      .   0,1   .       ds,dd
    #           |
    #    -1,0--0,0--1,0
    #           |
    #      .   0,-1  .
    #
    ### end: "s=$s d=$d  ds=$ds dd=$dd"

    # last step must be East dx=1,dy=0
    unless ($ds == 1 && $dd == -1) { next; }

    if ($s == $ds && $d == $dd) {
      push @nbits, 1;
    } elsif ($s != 0 || $d != 0) {
      next;
    }
    # ended s=0,d=0 or s=ds,d=dd, found an N
    push @n_list, digit_join_lowtohigh(\@nbits, 2, $zero);
    ### found N: "$n_list[-1]"
  }
  ### @n_list
  return sort {$a<=>$b} @n_list;
}

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
  ### CCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = round_nearest ($x1);
  $x2 = round_nearest ($x2);
  $y1 = round_nearest ($y1);
  $y2 = round_nearest ($y2);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  my ($len,$level) = _rect_to_k ($x1,$y1, $x2,$y2);
  if (is_infinite($level)) {
    return (0, $level);
  }
  return (0, 4*$len*$len*$self->{'arms'} - 1);
}

# N=16 is Y=4 away   k=2
# N=64 is Y=-8+1=-7 away  k=3
# N=256=4^4 is X=2^4=16-3=-7 away  k=4
# dist = 2^k - (2^(k-2)-1)
#      = 2^k - 2^(k-2) + 1
#      = 4*2^(k-2) - 2^(k-2) + 1
#      = 3*2^(k-2) + 1
#   k=2 3*2^(2-2)+1=4   len=4^2=16
#   k=3 3*2^(3-2)+1=7   len=4^3=64
#   k=4 3*2^(4-2)+1=13
# 2^(k-2) = (dist-1)/3
# 2^k = (dist-1)*4/3
#
# up = 3*2^(k-2+1) + 1
# 2^(k+1) = (dist-1)*4/3
# 2^k = (dist-1)*2/3
#
# left = 3*2^(k-2+1) + 1
# 2^(k+1) = (dist-1)*4/3
# 2^k = (dist-1)*2/3
#
# down = 3*2^(k-2+1) + 1
# 2^(k+1) = (dist-1)*4/3
# 2^k = (dist-1)*2/3
#
# m=2 4*(2-1)/3=4/3=1
# m=4 4*(4-1)/3=4
sub _rect_to_k {
  my ($x1,$y1, $x2,$y2) = @_;
  ### _rect_to_k(): $x1,$y1

  {
    my $m = max(abs($x1),abs($y1),abs($x2),abs($y2));
    if ($m < 2) {
      return (2, 1);
    }
    if ($m < 4) {
      return (4, 2);
    }
    ### round_down: 4*($m-1)/3
    my ($len, $k) = round_down_pow (4*($m-1)/3, 2);
    return ($len, $k);
  }

  my $len;
  my $k = 0;

  my $offset = -1;
  foreach my $m ($x2, $y2, -$x1, -$y1) {
    $offset++;
    ### $offset
    ### $m
    next if $m < 0;

    my ($len1, $k1);
    # if ($m < 2) {
    #   $len1 = 1;
    #   $k1 = 0;
    # } else {
    # }

    ($len1, $k1) = round_down_pow (($m-1)/3, 2);
    next if $k1 < $offset;
    my $sub = ($offset-$k1) % 4;
    $k1 -= $sub;  # round down to k1 == offset mod 4

    if ($k1 > $k) {
      $k = $k1;
      $len = $len1 / 2**$sub;
    }
  }

  ### result: "k=$k  len=$len"
  return ($len, 2*$k);
}



my @dir4_to_dx = (1,0,-1,0);
my @dir4_to_dy = (0,1,0,-1);

sub n_to_dxdy {
  my ($self, $n) = @_;
  ### n_to_dxdy(): $n

  my $int = int($n);
  $n -= $int;  # $n fraction part

  my @digits = bit_split_lowtohigh($int);
  my $dir = (sum(@digits)||0) & 3;  # count of 1-bits
  my $dx = $dir4_to_dx[$dir];
  my $dy = $dir4_to_dy[$dir];

  if ($n) {
    # apply fraction part $n

    # count low 1-bits is right turn of N+1, apply as dir-(turn-1) so decr $dir
    while (shift @digits) {
      $dir--;
    }

    # this with turn=count-1 turn which is dir++ worked into swap and negate
    # of dir4_to_dy parts
    $dir &= 3;
    $dx -= $n*($dir4_to_dy[$dir] + $dx);  # with rot-90 instead of $dir+1
    $dy += $n*($dir4_to_dx[$dir] - $dy);

    # this the equivalent with explicit dir++ for turn=count-1
    # $dir++;
    # $dir &= 3;
    # $dx += $n*($dir4_to_dx[$dir] - $dx);
    # $dy += $n*($dir4_to_dy[$dir] - $dy);
  }

  ### result: "$dx, $dy"
  return ($dx,$dy);
}

1;
__END__

=for stopwords eg Ryde Math-PlanePath ie OEIS dX,dY

=head1 NAME

Math::PlanePath::CCurve -- Levy C curve

=head1 SYNOPSIS

 use Math::PlanePath::CCurve;
 my $path = Math::PlanePath::CCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is an integer version of the Levy "C" curve.


                          11-----10-----9,7-----6------5               3
                           |             |             |
                   13-----12             8             4------3        2
                    |                                         |
            19---14,18----17                                  2        1
             |      |      |                                  |
     21-----20     15-----16                           0------1   <- Y=0
      |
     22                                                               -1
      |
    25,23---24                                                        -2
      |
     26     35-----34-----33                                          -3
      |      |             |
    27,37--28,36          32                                          -4
      |      |             |
     38     29-----30-----31                                          -5
      |
    39,41---40                                                        -6
      |
     42                                              ...              -7
      |                                                |
     43-----44     49-----48                          64-----63       -8
             |      |      |                                  |
            45---46,50----47                                 62       -9
                    |                                         |
                   51-----52            56            60-----61      -10
                           |             |             |
                          53-----54----55,57---58-----59             -11

                                                       ^
     -7     -6     -5     -4     -3     -2     -1     X=0     1

The initial segment N=0 to N=1 is repeated with a turn +90 degrees left to
give N=1 to N=2.  Then N=0to2 is repeated likewise turned +90 degrees and
placed at N=2 to make N=2to4.  And so on doubling each time.

The 90 degree rotation is the same at each repetition, so the segment at
N=2^k is the initial N=0to1 turned +90 degrees.  This means at
N=1,2,4,8,16,etc the direction is always upwards.

If 2^k is the highest 1-bit in N then the X,Y position can be written in
complex numbers as

    XY(N) = XY(2^k) + i*XY(r)          N = 2^k + r with r<2^k
          = (1+i)^k + i*XY(r)

The effect is a change of base from binary to base 1+i but with a power of i
on each term.  Suppose the 1-bits in N are at positions k, k1, k2, etc, then

    XY(N) = b^k               N= 2^k + 2^(k1) + 2^(k2) + ... in binary
          + b^k1 * i          base b=1+i
          + b^k2 * i^2
          + b^k3 * i^3
          + ...

Notice the power of i is not the bit position k, but rather the count of how
many 1-bits are above the position.  This calculation is straightforward but
the resulting structure of boundary and shapes enclosed has many different
parts.

=head2 Level Ranges 4^k

The X,Y extents of the path through to Nlevel=2^k can be expressed as a
width and height measured relative to the endpoints.

       *------------------*       <-+
       |                  |         |
    *--*                  *--*      | height h[k]
    |                        |      |
    *   N=4^k         N=0    *    <-+
    |     |            |     |      | below l[k] 
    *--*--*            *--*--*    <-+

    ^-----^            ^-----^    Extents to N=4^k
     width     2^k      width
      w[k]               w[k]

    <------------------------>
        total width -> 2

N=4^k is on either the X or Y axis and for the extents here it's taken
rotated as necessary to be horizontal.  k=2 N=4^2=16 shown above is already
horizontal.  The next level k=3 N=64=4^3 would be rotated -90 degrees to be
horizontal.

The width w[k] is measured from the N=0 and N=4^k endpoints.  It doesn't
include the 2^k length between those endpoints.  The two ends are symmetric
so the extent is the same for each.

    h[k] = 2^k - 1                     0,1,3,7,15,31,etc

    w[k] = /  0            for k=0
           \  2^(k-1) - 1  for k>=1    0,0,1,3,7,15,etc

    l[k] = /  0            for k<=1
           \  2^(k-2) - 1  for k>=2    0,0,0,1,3,7,etc

The initial N=0 to N=0 to N=64 shown above is k=3.  h[3]=7 is the X=-7
horizontal.  l[3]=1 is the X=1 horizontal.  w[3]=3 is the vertical Y=3, and
also Y=-11 which is 3 below the endpoint N=64 at Y=8.

Expressed as a fraction of the 2^k distance between the endpoints the
extents approach total 2 wide by 1.25 high,

       *------------------*       <-+
       |                  |         |  1
    *--*                  *--*      |         total
    |                        |      |         height
    *   N=4^k         N=0    *    <-+         1+1/4
    |     |            |     |      |  1/4
    *--*--*            *--*--*    <-+

    ^-----^            ^-----^  
      1/2        1       1/2   total width 2

The extent formulas can be found by considering the self-similar blocks.
The initial k=0 is a single line segment and all its extents are 0.

                          h[0] = 0
          N=1 ----- N=0
                          l[0] = 0
                    w[0] = 0

Thereafter the replication overlap as

       +-------+---+-------+
       |       |   |       |    
    +------+   |   |   +------+
    |  | D |   | C |   | B |  |        <-+
    |  +-------+---+-------+  |          | 2^(k-1)
    |      |           |      |          | previous
    |      |           |      |          | level ends
    |    E |           | A    |        <-+
    +------+           +------+

         ^---------------^
        2^k this level ends

    w[k] =           max (h[k-1], w[k-1])  # right of A,B
    h[k] = 2^(k-1) + max (h[k-1], w[k-1])  # above B,C,D
    l[k] = max w[k-1], l[k-1]-2^(k-1)      # below A,E

Since h[k]=2^(k-1)+w[k] have S<h[k] E<gt> w[k]> for kE<gt>=1 and with the
initial h[0]=w[k]=0 have h[k]E<gt>=w[k] always.  So the max of those two
is h.

    h[k] = 2^(k-1) + h[k-1]  giving h[k] = 2^k-1     for k>=1
    w[k] = h[k-1]            giving w[k] = 2^(k-1)-1 for k>=1

The max for l[k] is always w[k-1] as l[k] is never big enough that the parts
B-C and C-D can extend down past their 2^(k-1) vertical position.
(l[0]=w[0]=0 and thereafter by induction l[k]E<lt>=w[k].)

    l[k] = w[k-1]   giving l[k] = 2^(k-2)-1 for k>=2

=head2 Repeated Points

The curve crosses itself and repeats some X,Y positions up to 4 times.  The
first doubled, tripled and quadrupled points are

     visits     first X,Y       N
    ---------   ---------    ----------------------
        2        -2,  3         7,    9
        3        18, -7       189,  279,  281
        4       -32, 55      1727, 1813, 2283, 2369

=cut

# binary
#     2        -10,     11        111,      1001
#                                  3          2
#     3      10010,   -111   10111101, 100010111, 100011001
#                                 6         5         4
#     4    -100000, 110111   11010111111,  11100010101,
#                           100011101011, 100101000001
#                                9, 6, 7, 4

=pod

Each line segment between integer points is traversed at most 2 times, once
forward and once backward.  There's 4 such lines reaching each integer point
and so the points are visited at most 4 times.

As per L</Direction> below the direction of the curve is given by the count
of 1-bits in N.  Since no line is repeated each of the N values at a given
X,Y have a different count 1-bits mod 4.  For example N=7 is 3 1-bits and
N=9 is 2 1-bits.  The full counts need not be consecutive, as for example
N=1727 is 9 1-bits and N=2369 is 4 1-bits.

The maximum 2 segment traversals can be seen from the way the curve
replicates.  Suppose the entire plane had all line segments traversed
forward and backward.

      v |         v |
    --   <--------   <-
     [0,1]       [1,1]           [X,Y] = integer points
    ->   -------->   --          each edge traversed
      | ^         | ^            forward and backward
      | |         | |
      | |         | |
      v |         v |
    --   <--------   <--
     [0,0]       [1,0]
    ->   -------->   --
      | ^         | ^

Then when each line segment expands on the right the result is the same
pattern of traversals when viewed rotated by 45-degrees and scaled by factor
sqrt(2).

     \ v / v        \ v  / v
      [0,1]           [1,1]
     / / ^ \         ^ / ^ \
    / /   \ \       / /   \ \
           \ \     / /
            \ v   / v
             [1/2,1/2]
            ^ /   ^ \
           / /     \ \
    \ \   / /       \ \   / /
     \ v / v         \ v / v
      [0,0]            1,0
     ^ / ^ \         ^ / ^ \

The curve is a subset of this pattern.  It begins as a single line segment
which has this pattern and thereafter the pattern preserves itself.  Hence
at most 2 segment traversals in the curve.

=head2 Tiling

The segment traversal argument above can also be made by taking the line
segments as triangles which are a quarter of a unit square with peak
pointing to the right of the traversal direction.

       to  *
           ^\
           | \
           |  \   triangle peak
           |  /
           | /
           |/
      from *

These triangles in the two directions tile the plane.  On expansion each
splits into 2 halves in new positions.  Those parts don't overlap and the
plane is still tiled.  See for example Larry Riddle's pages

=over

L<http://www.agnesscott.edu/lriddle/levy.html>
L<http://www.agnesscott.edu/lriddle/tiling.html>

=back

For the integer version of the curve this kind of tiling can be used to
combine copies of the curve so that each every point is visited precisely 4
times.  The h[k], w[k] and l[k] extents above are less than the 2^k endpoint
length, so a square of side 2^k can be fully tiled with copies of the curve
at each corner,

             | ^         | ^
             | |         | |               24 copies of the curve
             | |         | |               to visit all points of the
             v |         v |               inside square precisely
    <-------    <--------   <--------      4 times each
              *           *
    -------->   -------->   -------->      points N=0 to N=4^k-1
             | ^         | ^               rotated and shifted
             | |         | |               suitably
             | |         | |
             v |         v |
    <--------   <--------   <--------
              *           *
    --------    -------->   -------->
             | ^         | ^
             | |         | |
             | |         | |
             v |         v |

The four innermost copies of the curve cover most of the inside square, but
the other copies surrounding them loop into the square and fill in the
remainder to make 4 visits at every point.

=cut

# If doing this tiling note that only points N=0 to N=4^k-1 are used.  If
# N=4^k was included then it would duplicate the N=0 at the "*" endpoints,
# resulting in 8 visits there rather than the intended 4.

=pod

It's interesting to note that a set of 8 curves at the origin only covers
the axes with 4-fold visits,

                   _ _ _
             | ^              8 arms at the origin
             | |              cover only X,Y axes
             v |              with 4-visits
    <--------   <--------
             0,0              away from the axes
    --------    -------->     some points < 4 visits
             | ^
             | |
             v |

The S<"_ _ _"> line shown which is part of the 24-pattern above but omitted
here.  This line is at Y=2^k.  The extents described above mean that it
extends down to Y=2^k - h[k] = 2^k-(2^k-1)=1, so it visits some points in
row Y=1 and higher.  Omitting the curve means there are YE<gt>=1 not visited
4 times.  Similarly YE<lt>=-1 and XE<lt>-1 and XE<gt>=+1.

This means that if the path had some sort of "arms" of multiple curves
extending from the origin then it would visit all points on the axes X=0 Y=0
a full 4 times, but there would be infinitely many points off the axes
without full 4 visits.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::CCurve-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  If there's nothing at
C<$x,$y> then return C<undef>.  If C<$x,$y> is visited more than once then
return the smallest C<$n> which visits it.

=item C<@n_list = $path-E<gt>xy_to_n_list ($x,$y)>

Return a list of N point numbers at coordinates C<$x,$y>.  If there's
nothing at C<$x,$y> then return an empty list.

A given C<$x,$y> is visited at most 4 times so the returned list is at most
4 values.

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 FORMULAS

=head2 Direction

The direction or net turn of the curve is the count of 1 bits in N,

    direction = count_1_bits(N) * 90degrees

For example N=11 is binary 1011 has three 1 bits, so direction 3*90=270
degrees, ie. to the south.

This bit count is because at each power-of-2 position the curve is a copy of
the lower bits but turned +90 degrees, so +90 for each 1-bit.

For powers-of-2 N=2,4,8,16, etc, there's only a single 1-bit so the
direction is always +90 degrees there, ie. always upwards.

=head2 Turn

At each point N the curve can turn in any direction: left, right, straight,
or 180 degrees back.  The turn is given by the number of low 0-bits of N,

    turn right = (count_low_0_bits(N) - 1) * 90degrees

For example N=8 is binary 0b100 which is 2 low 0-bits for turn=(2-1)*90=90
degrees to the right.

When N is odd there's no low zero bits and the turn is always (0-1)*90=-90
to the right, so every second turn is 90 degrees to the left.

=head2 Next Turn

The turn at the point following N, ie. at N+1, can be calculated by counting
the low 1-bits of N,

    next turn right = (count_low_1_bits(N) - 1) * 90degrees

For example N=11 is binary 0b1011 which is 2 low one bits for
nextturn=(2-1)*90=90 degrees to the right at the following point, ie. at
N=12.

This works simply because low 1-bits like ..0111 increment to low 0-bits
..1000 to become N+1.  The low 1-bits at N are thus the low 0-bits at N+1.

=head2 N to dX,dY

C<n_to_dxdy()> is implemented using the direction described above.  For
integer N the count mod 4 gives the direction for dX,dY.

    dir = count_1_bits(N) mod 4
    dx = dir_to_dx[dir]    # table 0 to 3
    dy = dir_to_dy[dir]

For fractional N the direction at int(N)+1 can be obtained from combining
the direction at int(N) and the turn at int(N)+1, that being the low 1-bits
of N per L</Next Turn> above.  Those two directions can then be combined as
described in L<Math::PlanePath/N to dX,dY -- Fractional>.

    # apply turn to make direction at Nint+1
    turn = count_low_1_bits(N) - 1      # N integer part
    dir = (dir - turn) mod 4            # direction at N+1

    # adjust dx,dy by fractional amount in this direction
    dx += Nfrac * (dir_to_dx[dir] - dx)
    dy += Nfrac * (dir_to_dy[dir] - dy)

A small optimization can be made by working the "-1" of the turn formula
into a +90 degree rotation of the C<dir_to_dx[]> and C<dir_to_dy[]> parts by
swap and sign change,

    turn_plus_1 = count_low_1_bits(N)     # on N integer part
    dir = (dir - turn_plus_1) mod 4       # direction-1 at N+1

    # adjustment including extra +90 degrees on dir
    dx -= $n*(dir_to_dy[dir] + dx)
    dy += $n*(dir_to_dx[dir] - dy)

=head2 X,Y to N

The N values at a given X,Y can be found by taking terms low to high from
the complex number formula (as given above),

    X+iY = b^k            N = 2^k + 2^(k1) + 2^(k2) + ... in binary
         + b^k1 * i       base b=1+i
         + b^k2 * i^2
         + ...

If the lowest term is b^0 then X+iY has X+Y odd.  If the lowest term is not
b^0 but instead some power b^n then X+iY has X+Y even.  This is because a
multiple of b=1+i,

    X+iY = (x+iy)*(1+i)
         = (x-y) + (x+y)i
    so X=x-y Y=x+y
    sum X+Y = 2x is even   if X+iY a multiple of 1+i

So the lowest bit of N is found by

    bit = (X+Y) mod 2

If bit=1 then a power i^p is to be subtracted from X+iY.  p is how many
1-bits are above that point, and this is not yet known.  It represents a
direction to move X,Y to put it on an even position.  It's also the
direction of the step N-2^l to N, where 2^l is the lowest 1-bit of N.

The reduction should be attempted with p as each of the four possible
directions N,S,E,W.  Some or all will lead to an N.  For quadrupled points
(such as X=-32, Y=55 described above) all four will lead to an N.

    for p 0 to 3
      dX,dY = i^p   # directions [1,0]  [0,1]  [-1,0]  [0,-1]

      loop until X,Y = [0,0] or [1,0] or [-1,0] or [0,1] or [0,-1] 
      {
        bit = X+Y mod 2       # bits of N from low to high
        if bit == 1 {
          X -= dX             # move to "even" X+Y == 0 mod 2
          Y -= dY
          (dX,dY) = (dY,-dX)         # rotate -90
        }
        (X,Y) = (X+Y)/2, (Y-X)/2   # divide (X+iY)/(1+i)
      }
      if not (dX=1 and dY=0)
        wrong final direction, try next p
      if X=dX and Y=dY
        further high 1-bit for N
        found an N
      if X=0 and Y=0
        found an N

The loop ends at one of the five points

            0,1
             |
    -1,0 -- 0,0 -- 1,0
             |
            0,-1

It's not possible to wait for X=0,Y=0 to be reached because some dX,dY
directions will step infinitely among the four non-zeros.  Only the case
X=dX,Y=dY is sure to reach 0,0.

The successive p decrements which are dX,dY rotate -90 must end at p == 0
mod 4 for highest term in the X+iY formula having i^0=1.  This means must
end dX=1,dY=0 East.

The number of 1-bits in N is == p mod 4.  So the order the N values are
obtained follows the order the p directions are attempted.  In general the N
values will not be smallest to biggest N so a little sort is necessary if
that's desired.

It can be seen that sum X+Y is used for the bit calculation and then again
in the divide by 1+i.  It's convenient to write the whole loop in terms of
sum S=X+Y and difference D=Y-X.

    for dS = +1 or -1      # four directions
      for dD = +1 or -1    #
        S = X+Y
        D = Y-X

        loop until -1 <= S <= 1 and -1 <= D <= 1 {
          bit = S mod 2       # bits of N from low to high
          if bit == 1 {
            S -= dS              # move to "even" S+D == 0 mod 2
            D -= dD
            (dS,dD) = (dD,-dS)   # rotate -90
          }
          (S,D) = (S+D)/2, (D-S)/2   # divide (S+iD)/(1+i)
        }
        if not (dS=1 and dD=-1)
          wrong final direction, try next dS,dD direction
        if S=dS and D=dD
          further high 1-bit for N
          found an N
        if S=0 and D=0
          found an N

The effect of S=X+Y, D=Y-D is to rotate by -45 degrees and use every second
point of the plane.

    D= 2                      X=0,Y=2       .              rotate -45

    D= 1            X=0,Y=1      .       X=1,Y=2       .

    D= 0  X=0,Y=0      .      X=1,Y=1       .       X=2,Y=2

    D=-1            X=1,Y=0      .       X=2,Y=1       .

    D=-2                      X=2,Y=0       .

           S=0        S=1       S=2        S=3        S=4

The final five points described above are then in a 3x3 block at the origin.
The four in-between points S=0,D=1 etc don't occur so ranges tests
-1E<lt>=SE<lt>=1 and -1E<lt>=DE<lt>=1 can be used.

     S=-1,D=1      .      S=1,D=1
                
        .       S=0,D=0      .   
                
     S=-1,D=-1     .      S=1,D=-1

=head1 OEIS

Entries in Sloane's Online Encyclopedia of Integer Sequences related to
this path include

=over

L<http://oeis.org/A179868> (etc)

=back

    A010059   abs(dX), count1bits(N) mod 2
    A010060   abs(dY), count1bits(N)+1 mod 2, being Thue-Morse

    A000120   direction, being total turn, count 1-bits
    A179868   direction 0to3, count 1-bits mod 4

    A035263   turn 0=straight or 180, 1=left or right,
                being (count low 0-bits + 1) mod 2
    A096268   next turn 1=straight or 180, 0=left or right,
                being count low 1-bits mod 2
    A007814   turn-1 to the right,
                being count low 0-bits

    A003159   N positions of left or right turn, ends even num 0 bits
    A036554   N positions of straight or 180 turn, ends odd num 0 bits

    A146559   X at N=2^k, being Re((i+1)^k)
    A009545   Y at N=2^k, being Im((i+1)^k)

    A191689   fractal dimension of the boundary

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DragonCurve>,
L<Math::PlanePath::AlternatePaper>,
L<Math::PlanePath::KochCurve>

L<ccurve(6x)> back-end of L<xscreensaver(1)> displaying the C curve (and
various other dragon curve and Koch curves).

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
