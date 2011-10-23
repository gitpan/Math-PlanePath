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


# math-image --path=GosperReplicate --lines --scale=10
# math-image --path=GosperReplicate --all --output=numbers_dash
#

package Math::PlanePath::GosperReplicate;
use 5.004;
use strict;
use List::Util qw(max);
use POSIX 'ceil';
use Math::Libm 'hypot';
use Math::PlanePath::SacksSpiral;

use vars '$VERSION', '@ISA';
$VERSION = 49;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;

sub n_to_xy {
  my ($self, $n) = @_;
  ### GosperReplicate n_to_xy(): $n

  if ($n < 0) {
    return;
  }
  if (_is_infinite($n)) {
    return ($n,$n);
  }

  {
    my $int = int($n);
    ### $int
    ### $n
    if ($n != $int) {
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $frac = $n - $int;  # inherit possible BigFloat
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int;       # BigFloat int() gives BigInt, use that
  }

  my $x = 0;
  my $y = 0;
  my $sx = 2;
  my $sy = 0;

  # digit
  #       3   2
  #        \ /
  #     4---0---1
  #        / \
  #       5   6

  while ($n) {
    my $digit = $n % 7;
    $n = int($n/7);
    ### digit: "$digit  $x,$y  side $sx,$sy"

    if ($digit == 1) {
      ### right ...
      # $x = -$x;  # rotate 180
      # $y = -$y;
      $x += $sx;
      $y += $sy;
    } elsif ($digit == 2) {
      ### up right ...
      # ($x,$y) = ((3*$y-$x)/2,   # rotate -120
      #            ($x+$y)/-2);
      $x += ($sx - 3*$sy)/2;    # at +60
      $y += ($sx + $sy)/2;

    } elsif ($digit == 3) {
      ### up left ...
      # ($x,$y) = (($x+3*$y)/2,   # -60
      #            ($y-$x)/2);
      $x += ($sx + 3*$sy)/-2;   # at +120
      $y += ($sx - $sy)/2;

    } elsif ($digit == 4) {
      ### left
      $x -= $sx;                # at -180
      $y -= $sy;

    } elsif ($digit == 5) {
      ### down left
      # ($x,$y) = (($x-3*$y)/2,    # rotate +60
      #            ($x+$y)/2);
      $x += (3*$sy - $sx)/2;    # at -120
      $y += ($sx + $sy)/-2;

    } elsif ($digit == 6) {
      ### down right
      # ($x,$y) = (($x+3*$y)/-2,  # rotate +120
      #            ($x-$y)/2);
      $x += ($sx + 3*$sy)/2;    # at -60
      $y += ($sy - $sx)/2;
    }

    # 2*(sx,sy) + rot+60(sx,sy)
    ($sx,$sy) = ((5*$sx - 3*$sy) / 2,
                 ($sx + 5*$sy) / 2);
  }
  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### GosperReplicate xy_to_n(): "$x, $y"

  $x = _round_nearest($x);
  $y = _round_nearest($y);
  if (($x + $y) % 2) {
    return undef;
  }

  my $level = _xy_to_level_ceil($x,$y);
  if (_is_infinite($level)) {
    return $level;
  }

  # modulus
  #       1   3
  #        \ /
  #     5---0---2
  #        / \
  #       4   6

  my $n = ($x * 0 * $y);   # inherit bignum 0
  my $power = $n+1;        # inherit bignum 1

  while ($level-- >= 0 && ($x || $y)) {
    ### at: "$x,$y"
    if (my $m = ($x + 2*$y) % 7) {
      ### mod remainder: $m

      if ($m == 2) {  # 2,0  = 2
        $n += $power;
        # $m = 1;
        $x -= 2;
      } else {
        if ($m == 3) {  # 1,1 = 1+2 = 3
          $m = 2;
          $x -= 1;
          $y -= 1;
        } elsif ($m == 1) {  # -1,1 = -1+2 = 1
          $m = 3;
          $x += 1;
          $y -= 1;
        } elsif ($m == 5) {  # -2,0 = -2 = 5
          $m = 4;
          $x += 2;
        } elsif ($m == 4) {  # -1,-1 = -1-2 = -3 = 4
          $m = 5;
          $x += 1;
          $y += 1;
        } elsif ($m == 6) {  # 1,-1 = 1-2 = -1 = 6
          $m = 6;
          $x -= 1;
          $y += 1;
        }
        $n += $m * $power;
      }
    }
    $power *= 7;

    ### digit: "to $x,$y"
    ### assert: (3*$y + 5*$x) % 14 == 0
    ### assert: (5*$y - $x) % 14 == 0

    # shrink
    ($x,$y) = ((3*$y + 5*$x) / 14,
               (5*$y - $x) / 14);
  }


  # my @digits;
  #   push @digits, $m;
  # # digit
  # #       3   2
  # #        \ /
  # #     4---0---1
  # #        / \
  # #       5   6
  #
  # # my @rot = (1,2,3,4,5,6);
  # my $n = 0;
  # # my $rot = 0;
  # while (@digits) {
  #   my $digit = pop @digits;
  #   ### $digit
  #   ### $rot
  #   $n *= 7;
  #
  #   if ($digit) {
  #     $digit = (($digit - $rot - 1) % 6) + 1;
  #     $n += $digit;
  #     $rot += $digit - 4;
  #     ### rotated digit: $digit
  #     ### rot now: $rot
  #   }
  # }
  return $n;
}


sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  $y1 *= sqrt(3);
  $y2 *= sqrt(3);
  my ($r_lo, $r_hi) = Math::PlanePath::SacksSpiral::_rect_to_radius_range
    ($x1,$y1, $x2,$y2);
  $r_hi *= 2;
  my $level_plus_1 = ceil( log(max(1,$r_hi/4)) / log(sqrt(7)) ) + 2;
  return (0, 7**$level_plus_1 - 1);
}

sub _xy_to_level_ceil {
  my ($x,$y) = @_;
  my $r = hypot($x,$y);
  $r *= 2;
  return ceil( log(max(1,$r/4)) / log(sqrt(7)) ) + 1;
}

1;
__END__

=for stopwords eg Ryde Gosper FlowsnakeCentres Flowsnake Math-PlanePath

=head1 NAME

Math::PlanePath::GosperReplicate -- self-similar hexagon replications

=head1 SYNOPSIS

 use Math::PlanePath::GosperReplicate;
 my $path = Math::PlanePath::GosperReplicate->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is a self-similar hexagonal tiling of the plane.  At each level the
shape is the Gosper island.

                         17----16                     4  
                        /        \                       
          24----23    18    14----15                  3  
         /        \     \                                
       25    21----22    19----20    10---- 9         2  
         \                          /        \           
          26----27     3---- 2    11     7---- 8      1  
                     /        \     \                    
       31----30     4     0---- 1    12----13     <- Y=0 
      /        \     \                                   
    32    28----29     5---- 6    45----44           -1  
      \                          /        \              
       33----34    38----37    46    42----43        -2  
                  /        \     \                       
                39    35----36    47----48           -3  
                  \                                      
                   40----41                          -4  

                          ^
    -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7

The points are spread out on every second X coordinate to make a a
triangular lattice in integer coordinates (see L<Math::PlanePath/Triangular
Lattice>).

The basic pattern is the inner N=0 to N=6, then six copies of that shape are
arranged around as the N=7,14,21,28,35,42 blocks.  Then six copies of the
N=0 to N=48 shape are replicated around, etc.

Each point represents a little hexagon, thus tiling the plane with hexagons.
The innermost N=0 to N=6 are for instance,

          *     *
         / \   / \
        /   \ /   \
       *     *     *
       |  3  |  2  |
       *     *     *
      / \   / \   / \
     /   \ /   \ /   \
    *     *     *     *
    |  4  |  0  |  1  |
    *     *     *     *
     \   / \   / \   /
      \ /   \ /   \ /
       *     *     *
       |  5  |  6  |
       *     *     *
        \   / \   /
         \ /   \ /
          *     *

The FlowsnakeCentres path is this same replicating shape, but starting from
a side instead of the middle and with rotations and reflections to make
points adjacent.  The Flowsnake curve itself is this replication too, but
following edges.

=head2 Complex Base

The path corresponds to expressing complex integers X+i*Y in a base
b=5/2+i*sqrt(3)/2 with a bit of scaling to fit equilateral triangles to a
square grid.  So for integer X,Y both odd or both even,

    X/2 + i*Y*sqrt(3)/2 = a[n]*b^n + ... + a[2]*b^2 + a[1]*b + a[0]

where each digit a[i] is either 0 or a sixth root of unity encoded into N as
base 7 digits,

     N digit     a[i]
       0          0
       1         e^(0/3 * pi * i) = 1
       2         e^(1/3 * pi * i) = 1/2 + i*sqrt(3)/2
       3         e^(2/3 * pi * i) = -1/2 + i*sqrt(3)/2
       4         e^(3/3 * pi * i) = -1
       5         e^(4/3 * pi * i) = -1/2 - i*sqrt(3)/2
       6         e^(5/3 * pi * i) = 1/2 - i*sqrt(3)/2

7 digits suffice because

     norm(b) = (5/2)^2 + (sqrt(3)/2)^2 = 7

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::GosperReplicate-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::GosperIslands>,
L<Math::PlanePath::QuintetReplicate>,
L<Math::PlanePath::Flowsnake>,
L<Math::PlanePath::FlowsnakeCentres>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011 Kevin Ryde

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







# old rotating version:
#
#                                      19  ....  18
#                                    /               \
#             25        24        20        14        17
#                                         /         /
#        26        21        23        15  ----  16        13  ----  12
#                     \                                                 \
#             27        22         3   ---   2         8   ----  7        11
#                               /              \         \              /
#        31        30         4         0  ---    1         9  ----  10
#                                \
#   32        28  ---   29         5  ----   6        43        48
#                                                       \
#        33        34        37        36        44        42        47
#                                    /
#                       38        35        41        45        46
#
#                            39        40