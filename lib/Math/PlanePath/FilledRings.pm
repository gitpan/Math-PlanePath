# Copyright 2012 Kevin Ryde

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


# math-image --path=FilledRings --all --output=numbers_dash  --size=70x30


package Math::PlanePath::FilledRings;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 73;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::SacksSpiral;
*_rect_to_radius_range_points = \&Math::PlanePath::SacksSpiral::_rect_to_radius_range_points;

# uncomment this to run the ### lines
#use Smart::Comments;


# cf A000328 num points <= circle radius n
#    A046109 num points == circle radius n
#    A051132 num points <  circle radius n
#    A057655 num points x^2+y^2 <= n
#
# N(r) = 1 + 4*sum  floor(r^2/(4i+1)) - floor(r^2/(4i+3))
#
# N(r+1) - N(r)
#   = 1 + 4*sum  floor((r+1)^2/(4i+1)) - floor((r+1)^2/(4i+3))
#     - 1 + 4*sum  floor(r^2/(4i+1)) - floor(r^2/(4i+3))
#   = 4*sum  floor(((r+1)^2-r^2)/(4i+1)) - floor(((r+1)^2-r^2)/(4i+3))
#   = 4*sum  floor((2r+1)/(4i+1)) - floor((2r+1)/(4i+3))
#
# _cumul[0] index=0 is r=1/2
#  r = index+1/2
#  2r+1 = 2(index+1/2)+1
#       = 2*index+1+1
#       = 2*index+2
#
#  2r+1 >= 4i+1
#  2r >= 4i
#  i <= (2*index+2)/2
#  i <= index+1
#
#  r=3.5
#  sqrt(3*3+3*3) = 4.24 out
#  sqrt(3*3+2*2) = 3.60 out
#  sqrt(3*3+1*1) = 3.16 in
#
#      * * *  
#    * * * * *  
#  * * * * * * *
#  * * * o * * *   3+5+7+7+7+5+3 = 37
#  * * * * * * *
#    * * * * *  
#      * * *   
#
# N(r) = 1 + 4*( floor(12.25/1)-floor(12.25/3)
#          + floor(12.25/5)-floor(12.25/7)
#          + floor(12.25/9)-floor(12.25/11) )
#      = 37
#
# (index+1/2)^2 = index^2 + index + 1/4
#               >= index*(index+1)
# (end+1 + 1/2)^2
#   = (end+3/2)^2
#   = end^2 + 3*end + 9/4
#   = end*(end+3) + 2 + 1/4
#
# (r+1/2)^2 = r^2+r+1/4  floor=r*(r+1)
# (r-1/2)^2 = r^2-r+1/4  ceil=r*(r-1)+1

use vars '@_cumul';
@_cumul = (2);

sub _cumul_extend {
  ### _cumul_extend() ...
  my $r2 = ($#_cumul + 3) * $#_cumul + 2;
  my $c = 0;
  for (my $d = 1; $d <= $r2; $d += 4) {
    $c += int($r2/$d) - int($r2/($d+2));
  }
  push @_cumul, 4*$c + 2;
  ### @_cumul
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### FilledRings n_to_xy(): $n

  if ($n < 1) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  if ($n < 2) {
    return ($n-1, 0);
  }

  ### search cumul for: "n=$n"
  my $r = 1;
  for (;;) {
    if ($r > $#_cumul) {
      _cumul_extend ();
    }
    if ($_cumul[$r] > $n) {
      last;
    }
    $r++;
  }
  ### $r

  $n -= $_cumul[$r-1];
  my $len = $_cumul[$r] - $_cumul[$r-1];   # length of this ring

  ### cumul: "$_cumul[$r-1] to $_cumul[$r]"
  ### $len
  ### n rem: $n

  $len /= 4;     # length of a quadrant of this ring
  my $quadrant = $n / $len;   # 0 <= q < 4
  $n %= $len;

  ### len of quadrant: $len
  ### $quadrant
  ### n into quadrant: $n

  my $rev;
  if ($rev = ($n > $len/2)) {
    $n = $len - $n;
  }
  ### $rev
  ### $n

  my $rhi = ($r+1)*$r;
  my $rlo = ($r-1)*$r+1;
  my $x = $r;
  my $y = 0;
  while ($n > 0) {
    ### at: "$x,$y n=$n"

    $y++;
    ### inc y to: $y

    if ($x*$x + $y*$y > $rhi) {
      $x--;
      ### dec x to: $x
      ### assert: $x*$x + $y*$y <= $rhi
      ### assert: $x*$x + $y*$y >= $rlo
    }
    $n--;
    last if $n <= 0;

    if (($x-1)*($x-1) + $y*$y >= $rlo) {
      ### another dec x to: $x
      $x--;
      $n--;
      last if $n <= 0;
    }
  }

  # if ($n) {
  #   ### n frac: $n
  # }

  if ($rev) {
    ($x,$y) = ($y,$x);
  }
  if ($quadrant & 2) {
    $x = -$x;
    $y = -$y;
  }
  if ($quadrant & 1) {
    ($x,$y) = (-$y, $x);
  }
  ### return: "$x, $y"
  return ($x, $y);
}


# h=x^2+y^2
# h >= (r-1/2)^2
# sqrt(h) >= r-1/2
# sqrt(h)+1/2 >= r
# r = int (sqrt(h)+1/2)
#   = int( (2*sqrt(h)+1)/2 }
#   = int( (sqrt(4*h) + 1)/2 }

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### FilledRings xy_to_n(): "$x, $y"
  $x = _round_nearest ($x);
  $y = _round_nearest ($y);

  if ($x == 0 && $y == 0) {
    return 1;
  }

  my $r = int ((sqrt(4*($x*$x+$y*$y)) + 1) / 2);
  ### $r
  if (_is_infinite($r)) {
    return undef;
  }

  while ($#_cumul < $r) {
    _cumul_extend ();
  }
  my $n = $_cumul[$r-1];
  ### n base: $n

  my $len = $_cumul[$r] - $n;
  ### $len
  $len /= 4;
  ### len/4: $len

  if ($y < 0) {
    ### y neg, rotate 180
    $y = -$y;
    $x = -$x;
    $n += 2*$len;
  }

  if ($x < 0) {
    $n += $len;
    ($x,$y) = ($y,-$x);
    ### neg x, rotate 90
    ### n base now: $n
  }

  ### assert: $x >= 0
  ### assert: $y >= 0

  my $rev;
  if ($rev = ($x < $y)) {
    ### top octant, reverse: "x=$x len/4=".($len/4)." gives ".($len/4 - $x)
    ($x,$y) = ($y,$x);
  }

  my $offset = 0;
  my $rhi = ($r+1)*$r;
  my $rlo = ($r-1)*$r+1;
  ### assert: $x*$x + $y*$y <= $rhi
  ### assert: $x*$x + $y*$y >= $rlo

  my $tx = $r;
  my $ty = 0;
  while ($ty < $y) {
    ### at: "$tx,$ty offset=$offset"

    $ty++;
    ### inc ty to: $ty
    if ($tx*$tx + $ty*$ty > $rhi) {
      $tx--;
      ### dec tx to: $tx
      ### assert: $tx*$tx + $ty*$ty <= $rhi
      ### assert: $tx*$tx + $ty*$ty >= $rlo
    }
    $offset++;
    last if $x == $tx && $y == $ty;

    if (($tx-1)*($tx-1) + $ty*$ty >= $rlo) {
      ### another dec tx to: "tx=$tx"
      $tx--;
      $offset++;
      last if $y == $ty;
    }
  }

  if ($rev) {
    return $n + $len - $offset;
  } else {
    return $n + $offset;
  }
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### FilledRings rect_to_n_range(): "$x1,$y1 $x2,$y2"

  ($x1,$y1, $x2,$y2) = _rect_to_radius_range_points ($x1,$y1, $x2,$y2);
  ### radius range: "$x1,$y1 $x2,$y2"

  if ($x1 >= 1) { $x1 -= 1; }
  if ($y1 >= 1) { $y1 -= 1; }
  $x2 += 1;
  $y2 += 1;

  return (int((21*($x1*$x1 + $y1*$y1)) / 7) + 1,
          int((22*($x2*$x2 + $y2*$y2)) / 7));
}

1;
__END__

=for stopwords Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::FilledRings -- concentric filled lattice rings

=head1 SYNOPSIS

 use Math::PlanePath::FilledRings;
 my $path = Math::PlanePath::FilledRings->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path puts points on integer X,Y pixels of filled rings of width 1 unit.

                    110-109-108-107-106                        6
                   /                   \  
            112-111  79--78--77--76--75 105-104                5
              |    /                   \      |                 
        114-113  80  48--47--46--45--44  74 103-102            4
          |    /      |               |    \      |             
        115  81  50--49  27--26--25  43--42  73 101            3
       /   /      |    /           \      |    \   \            
    116  82  52--51  28  14--13--12  24  41--40  72 100        2
      |   |   |    /   /           \   \      |   |   |         
    117  83  53  29  15   5-- 4-- 3  11  23  39  71  99        1
      |   |   |   |   |   |       |   |   |   |   |   |         
    118  84  54  30  16   6   1-- 2  10  22  38  70  98   <- Y=0
      |   |   |   |   |   |                                     
    119  85  55  31  17   7-- 8-- 9  21  37  69  97 137       -1
      |   |   |    \   \           /   /      |   |   |         
    120  86  56--57  32  18--19--20  36  67--68  96 136       -2
       \   \      |    \           /      |    /   /            
        121  87  58--59  33--34--35  65--66  95 135           -3
          |    \      |               |    /      |             
        122-123  88  60--61--62--63--64  94 133-134           -4
              |    \                   /      |                 
            124-125  89--90--91--92--93 131-132               -5
                   \                   /
                    126-127-128-129-130 

                              ^
     -6  -5  -4  -3  -2  -1  X=0  1   2   3   4   5   6

For example the ring N=22 to N=37 is all the points

    2.5 < hypot(X,Y) < 3.5
    with hypot(X,Y) = sqrt(X^2+Y^2) 

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::FilledRings-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

For C<$n < 1> the return is an empty list, it being considered there are no
negative points.

The behaviour for fractional C<$n> is unspecified as yet.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PixelRings>,
L<Math::PlanePath::Hypot>,
L<Math::PlanePath::MultipleRings>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2012 Kevin Ryde

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