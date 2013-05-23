# Copyright 2011, 2012, 2013 Kevin Ryde

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


package Math::PlanePath::CCurve;
use 5.004;
use strict;
use List::Util 'max','sum';

use vars '$VERSION', '@ISA';
$VERSION = 104;
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
  'digit_split_lowtohigh';


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
# use constant dir4_maximum  => 3; # South
# use constant dir_maximum_360  => 270;    # South
use constant dir_maximum_dxdy => (0,-1); # South


#------------------------------------------------------------------------------

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);

  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 2) { $arms = 2; }
  $self->{'arms'} = $arms;

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

sub xy_to_n {
  return scalar((shift->xy_to_n_list(@_))[0]);
}
sub xy_to_n_list {
  my ($self, $x, $y) = @_;
  ### CCurve xy_to_n(): "$x, $y"

  $x = round_nearest($x);
  $y = round_nearest($y);

  my ($len,$k_limit) = _rect_to_k ($x,$y, $x,$y);
  if (is_infinite($k_limit)) {
    return $k_limit;  # infinity
  }

  ### $len
  ### $k_limit
  ### assert: $len==(0*$x*$y + 2) ** $k_limit

  my $arms_count = $self->{'arms'};
  my $zero = $x*0*$y;
  my @n_list;

  foreach my $arm (0 .. $arms_count-1) {
    my @digits = (-1);
    my $tx = 0;
    my $ty = 0;
    my $rot = $k_limit + 1+2*$arm;
    my @extents = ($len + int($len/2 - 1));

    ### initial extent: $extents[0]

    for (;;) {
      my $digit = ++$digits[-1];
      ### at: "digits=".join(',',@digits)."  txty=$tx,$ty   len=$len rot=$rot"

      if ($digit > 3) {
        pop @digits;
        if (! @digits) {
          ### @n_list
          last;
        }
        ### end of this digit, backtrack ...
        $len *= 2;
        $rot--;
        next;
      }

      ### $digit
      ### rot increment: $digit_to_rot[$digit]
      $rot += $digit_to_rot[$digit];

      if ($#digits >= $k_limit) {
        ### low digit ...
        if ($x == $tx && $y == $ty) {
          ### found: _digit_join_hightolow (\@digits, 4, $zero)
          push @n_list,
            _digit_join_hightolow (\@digits, 4, $zero)
              * $arms_count + $arm;
        }
      } elsif (max(abs($x-$tx),abs($y-$ty)) <= $extents[$#digits]) {
        ### within extent, descend ...
        push @digits, -1;
        $len /= 2;
        $extents[$#digits] ||= ($len + int($len/2 - 1));

        ### new len: $len
        ### digit pos: $#digits
        ### new extent: $extents[$#digits]

        next;
      }

      ### step txty: "rot=".($rot&3)
      if ($rot & 2) {
        if ($rot & 1) {
          $ty -= $len;
        } else {
          $tx -= $len;
        }
      } else {
        if ($rot & 1) {
          $ty += $len;
        } else {
          $tx += $len;
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

This is an integer version of the "C" curve.


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
give N=1 to N=2.  Then N=0to2 is repeated likewise turned +90 degrees to
make N=2to4.  And so on doubling each time.

The 90 degree rotation is always relative to the initial N=0to1 direction
along the X axis.  So at any N=2^level the turn is +90 making the direction
upwards at each of N=1,2,4,8,16,etc.

The curve crosses itself and repeats some X,Y positions.  The first doubled
point is X=-2,Y=3 which is both N=7 and N=9.  The first tripled point is
X=18,Y=-7 which is N=189, N=279 and N=281.  The number of repeats at a given
point is always finite, but as N increases there's points where that number
of repeats becomes ever bigger (is that right?).

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
C<$x,$y> then return C<undef>.

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
direction is always +90 degrees there, ie. upwards.

=head2 Turn

At each point N the curve can turn in any direction: left, right, straight,
or 180 degrees back.  The turn is given by the number of low 0-bits of N,

    turn right = (count_low_0_bits(N) - 1) * 90degrees

For example N=8 is binary 0b100 which is 2 low 0-bits for turn=(2-1)*90=90
degrees to the right.

When N is odd there's no low zero bits and the turn is always (0-1)*90=-90
to the right in that case, which means every second turn is 90 degrees to
the left.

=head2 Next Turn

The turn at the point following N, ie. at N+1, can be calculated from the
bits of N by counting the low 1-bits,

    next turn right = (count_low_1_bits(N) - 1) * 90degrees

For example N=11 is binary 0b1011 which is 2 low one bits for
nextturn=(2-1)*90=90 degrees to the right at the following point, ie. at
N=12.

This works simply because low 1-bits like ..0111 increment to low 0-bits
..1000.  The low 1-bits at N are the low 0-bits at N+1.

=head2 N to dX,dY

C<n_to_dxdy()> is implemented using the direction described above.  If N is
an integer then direction = count_1_bits mod 4 gives the direction for
dX,dY.

    dir = count_1_bits(N) mod 4
    dx = dir_to_dx[dir]    # table 0 to 3
    dy = dir_to_dy[dir]

For fractional N the direction at int(N) can be modified by the turn at
int(N)+1 to give the direction at int(N)+1, as per L<Math::PlanePath/N to
dX,dY -- Fractional>.

    # apply turn to make direction at Nint+1
    turn = count_low_1_bits(N) - 1      # N integer part
    dir = (dir - turn) mod 4            # direction at N+1

    # adjust dx,dy by fractional amount in this direction
    dx += Nfrac * (dir_to_dx[dir] - dx)
    dy += Nfrac * (dir_to_dy[dir] - dy)

A tiny optimization can be made by working the "-1" of the turn formula into
a +90 degree rotation of the C<dir_to_dx[]> and C<dir_to_dy[]> parts by a
swap and sign change,

    turn_plus_1 = count_low_1_bits(N)     # N integer part
    dir = (dir - turn_plus_1) mod 4       # direction-1 at N+1

    # adjustment including extra +90 degrees on dir
    dx -= $n*(dir_to_dy[dir] + dx)
    dy += $n*(dir_to_dx[dir] - dy)

=head2 X,Y to N

The N values at a given X,Y can be found by traversing the curve.  At a
given digit position if X,Y is within the curve extents at that level and
position then descend to consider the next lower digit position, otherwise
step to the next digit at the current digit position.

It's convenient to consider base-4 digits since that keeps the digit steps
straight rather than diagonals.  The maximum extent of the curve at a given
even numbered level is

    k = level/2
    Lmax(level) = 2^k + floor(2^(k-1) - 1);

For example k=2 is level=4, N=0 to N=2^4=16 has extent Lmax=2^2+2^1-1=5.
That extent can be seen at points N=13,N=14,N=15.

The extents width-ways and backwards are shorter and using them would
tighten the traversal, cutting off some unnecessary descending.  But the
calculations are then a little trickier.

The first N found by this traversal is the smallest.  Continuing the search
gives all the N which are the target X,Y.

=head1 OEIS

Entries in Sloane's Online Encyclopedia of Integer Sequences related to
this path include

    http://oeis.org/A179868  (etc)

    A010059   abs(dX), count 1-bits mod 2
    A010060   abs(dY), count1bits + 1 mod 2, Thue-Morse

    A179868   direction 0to3, count 1-bits mod 4
    A000120   direction as total turn, count 1-bits

    A007814   turn-1 to the right, being count low 0s

    A003159   N positions of left or right turn, ends even num 0 bits
    A036554   N positions of straight or 180 turn, ends odd num 0 bits

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DragonCurve>,
L<Math::PlanePath::AlternatePaper>,
L<Math::PlanePath::KochCurve>

L<ccurve(6x)> back end of L<xscreensaver(1)> displaying the C curve (and
various other dragon curve and Koch curves).

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011, 2012, 2013 Kevin Ryde

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
