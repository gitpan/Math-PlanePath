# Copyright 2011 Kevin Ryde

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


# math-image --path=FlowsnakeCentres --lines --scale=10
# math-image --path=FlowsnakeCentres --all --output=numbers_dash
#
# http://80386.nl/projects/flowsnake/
#


package Math::PlanePath::FlowsnakeCentres;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 39;

use Math::PlanePath::Flowsnake;
@ISA = ('Math::PlanePath::Flowsnake');
use Math::PlanePath;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;


#       4-->5
#       ^    ^
#     /       \
#    3--- 2    6--
#          \
#           v
#       0-->1
#

my @digit_reverse = (0,1,1,0,0,0,1);   # 1,2,6

sub n_to_xy {
  my ($self, $n) = @_;
  ### FlowsnakeCentres n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  # ENHANCE-ME: work $frac into initial $x,$y somehow
  # my $frac;
  # {
  #   my $int = int($n);
  #   $frac = $n - $int;  # inherit possible BigFloat/BigRat
  #   $n = $int;  # BigInt instead of BigFloat
  # }
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
    $n = $int; # BigFloat int() gives BigInt, use that
  }

  my @n;
  my $x = 0;
  my $y = 0;
  {
    while ($n) {
      push @n, ($n % 7);
      $n = int($n/7);
    }
    ### @n

    # if (! @n || $n[0] == 0) {
    #   $x = 2*$frac;
    # } elsif ($n[0] == 1) {
    #   $x = $frac;
    #   $y = -$frac;
    # } elsif ($n[0] == 2) {
    #   $x = -2*$frac;
    # } elsif ($n[0] == 3) {
    #   $x = $frac;
    #   $y = -$frac;
    # } elsif ($n[0] == 4) {
    #   $x = 2*$frac;
    # } elsif ($n[0] == 5) {
    #   $x = $frac;
    #   $y = -$frac;
    # } elsif ($n[0] == 6) {
    #   $x = -$frac;
    #   $y = -$frac;
    # }

    my $rev = 0;
    for (my $i = $#n; $i >= 0; $i--) {  # high to low
      ### digit: $n[$i]
      if ($rev) {
        ### reverse: "$n[$i] to ".(6 - $n[$i])
        $n[$i] = 6 - $n[$i];
      }
      if ($i > 0) {
        $rev ^= $digit_reverse[$n[$i]];
      }
      ### now rev: $rev
    }
    ### reversed n: @n
  }

  my $ox = 0;
  my $oy = 0;
  my $sx = 2;
  my $sy = 0;

  while (@n) {
    my $digit = shift @n;  # low to high
    ### digit: "$digit  $x,$y  side $sx,$sy  origin $ox,$oy"

    if ($digit == 0) {
      $x += (3*$sy - $sx)/2;    # at -120
      $y += ($sx + $sy)/-2;

    } elsif ($digit == 1) {
      ($x,$y) = ((3*$y-$x)/2,   # rotate -120
                 ($x+$y)/-2);
      $x += ($sx + 3*$sy)/2;    # at -60
      $y += ($sy - $sx)/2;

    } elsif ($digit == 2) {
      # centre

    } elsif ($digit == 3) {
      ($x,$y) = (($x+3*$y)/-2,  # rotate +120
                 ($x-$y)/2);
      $x -= $sx;                # at -180
      $y -= $sy;

    } elsif ($digit == 4) {
      $x += ($sx + 3*$sy)/-2;   # at +120
      $y += ($sx - $sy)/2;

    } elsif ($digit == 5) {
      $x += ($sx - 3*$sy)/2;    # at +60
      $y += ($sx + $sy)/2;

    } elsif ($digit == 6) {
      ($x,$y) = (($x+3*$y)/-2,  # rotate +120
                 ($x-$y)/2);
      $x += $sx;                # at X axis
      $y += $sy;
    }

    $ox += $sx;
    $oy += $sy;

    # 2*(sx,sy) + rot+60(sx,sy)
    ($sx,$sy) = ((5*$sx - 3*$sy) / 2,
                 ($sx + 5*$sy) / 2);
  }


  ### digits to: "$x,$y"
  ### origin sum: "$ox,$oy"
  ### origin rotated: (($ox-3*$oy)/2).','.(($ox+$oy)/2)
  $x += ($ox-3*$oy)/2;     # rotate +60
  $y += ($ox+$oy)/2;

  ### final: "$x,$y"
  return ($x,$y);
}

#       4-->5
#       ^    ^      forw
#     /       \
#    3--- 2    6---
#          \
#           v
#       0-->1
#
#       5   3
#            \       rev
#     /  \ /  v
#  --6    4    2
#             /
#           v
#       0-->1
#

my @modulus_to_digit
  = (0,3,1,2,4,6,5,   0,42,14,28,0,56,0,      # 0   right forw 0
     0,5,1,4,6,2,3,   0,42,14,70,14,14,28,    # 14  +120 rev   1
     6,3,5,4,2,0,1,   28,56,70,0,28,42,28,    # 28  left rev   2
     4,5,3,2,6,0,1,   42,42,70,56,14,42,28,   # 42  +60 forw   3
     2,1,3,4,0,6,5,   56,56,14,42,70,56,0,    # 56  -60 rev    6
     6,1,5,2,0,4,3,   28,56,70,14,70,70,0,    # 70      forw
    );
sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### FlowsnakeCentres xy_to_n(): "$x, $y"

  $x = _round_nearest($x);
  $y = _round_nearest($y);
  if (($x ^ $y) & 1) {
    ### odd x,y ...
    return undef;
  }

  my $level_limit = log($x*$x + 3*$y*$y + 1) * 0.835 * 2;
  if (_is_infinite($x)) { return $level_limit; }

  # my $sx = 1;
  # my $sy = -1;

  my @digits;
  my $power = 1;
  for (;;) {
    if ($level_limit-- < 0) {
      ### oops, level limit ...
      return undef;
    }
    if ($x == 0 && $y == 0) {
      ### found 0,0 ...
      last;
    }
    if ((($x == -1 || $x == 1) && $y == -1)
        || ($x == 0 && $y == -2)) {
      ### below island ...
      return undef;
    }
    my $m = ($x + 2*$y) % 7;
    ### at: "$x,$y   digits=".join(',',@digits)
    ### mod remainder: $m

    # 0,0 is m=0
    if ($m == 2) {  # 2,0  = 2
      $x -= 2;
    } elsif ($m == 3) {  # 1,1 = 1+2 = 3
      $x -= 1;
      $y -= 1;
    } elsif ($m == 1) {  # -1,1 = -1+2 = 1
      $x += 1;
      $y -= 1;
    } elsif ($m == 4) {  # 0,2 = 0+2*2 = 4
      $y -= 2;
    } elsif ($m == 6) {  # 2,2 = 2+2*2 = 6
      $x -= 2;
      $y -= 2;
    } elsif ($m == 5) {  # 3,1 = 3+2*1 = 5
      $x -= 3;
      $y -= 1;
    }
    push @digits, $m;

    ### digit: "$m  to $x,$y"
    ### shrink to: ((3*$y + 5*$x) / 14).','.((5*$y - $x) / 14)
    ### assert: (3*$y + 5*$x) % 14 == 0
    ### assert: (5*$y - $x) % 14 == 0

    # shrink
    ($x,$y) = ((3*$y + 5*$x) / 14,
               (5*$y - $x) / 14);
  }

  ### @digits

  my $n = 0;
  my $state = 0;
  foreach my $m (reverse @digits) {  # high to low
    ### $m
    ### digit: $modulus_to_digit[$state + $m]
    ### state: $state
    ### next state: $modulus_to_digit[$state+7 + $m]

    $n = 7*$n + $modulus_to_digit[$state + $m];
    $state = $modulus_to_digit[$state+7 + $m];
  }

  ### final n: $n
  return $n;
}

1;
__END__


  # if (@n) {
  #   my $digit = shift @n;
  #
  #   $ox += $sx;
  #   $oy += $sy;
  #
  #   if ($rev) {
  #     if ($digit == 0) {
  #       $x += $sx;                # at X axis
  #       $y += $sy;
  #       # $x += ($sx + 3*$sy)/2;    # at -60
  #       # $y += ($sy - $sx)/2;
  #       # $x += ($sx + 3*$sy)/-2;   # at +120
  #       # $y += ($sx - $sy)/2;
  #       # $x += (3*$sy - $sx)/2;    # at -120
  #       # $y += ($sx + $sy)/-2;
  #
  #     } elsif ($digit == 1) {
  #       ($x,$y) = ((3*$y-$x)/2,   # rotate -120
  #                  ($x+$y)/-2);
  #       return;
  #
  #     } elsif ($digit == 2) {
  #       return;
  #     } elsif ($digit == 3) {
  #       $x = -$x;                 # rotate 180
  #       $y = -$y;
  #       $x += $sx + ($sx - 3*$sy)/2;    # at +60 + X axis
  #       $y += $sy + ($sx + $sy)/2;
  #       return;
  #     } elsif ($digit == 4) {
  #       ($x,$y) = ((3*$y-$x)/2,   # rotate -120
  #                  ($x+$y)/-2);
  #       $x += ($sx - 3*$sy)/2;    # at +60
  #       $y += ($sx + $sy)/2;
  #       return;
  #     } elsif ($digit == 5) {
  #       ($x,$y) = (($x+3*$y)/-2,  # rotate +120
  #                  ($x-$y)/2);
  #       # centre
  #       return;
  #     } elsif ($digit == 6) {
  #       ($x,$y) = (($x-3*$y)/2,     # rotate +60
  #                  ($x+$y)/2);
  #       return;
  #     }
  #
  #   } else {
  #     if ($digit == 0) {
  #       $x += (3*$sy - $sx)/2;    # at -120
  #       $y += ($sx + $sy)/-2;
  #
  #     } elsif ($digit == 1) {
  #       ($x,$y) = ((3*$y-$x)/2,   # rotate -120
  #                  ($x+$y)/-2);
  #       $x += ($sx + 3*$sy)/2;    # at -60
  #       $y += ($sy - $sx)/2;
  #
  #     } elsif ($digit == 2) {
  #       $x = -$x;                 # rotate 180
  #       $y = -$y;
  #       $x += $sx;                # at X axis
  #       $y += $sy;
  #
  #     } elsif ($digit == 3) {
  #       ($x,$y) = (($x+3*$y)/-2,  # rotate +120
  #                  ($x-$y)/2);
  #       # centre
  #
  #     } elsif ($digit == 4) {
  #       $x += ($sx + 3*$sy)/-2;   # at +120
  #       $y += ($sx - $sy)/2;
  #
  #     } elsif ($digit == 5) {
  #       $x += ($sx - 3*$sy)/2;    # at +60
  #       $y += ($sx + $sy)/2;
  #
  #     } elsif ($digit == 6) {
  #       ($x,$y) = (($x+3*$y)/-2,  # rotate +120
  #                  ($x-$y)/2);
  #       $x += $sx + ($sx - 3*$sy)/2;    # at +60 + X axis
  #       $y += $sy + ($sx + $sy)/2;
  #     }
  #   }
  #
  #   # 2*(sx,sy) + rot+60(sx,sy)
  #   ($sx,$sy) = ((5*$sx - 3*$sy) / 2,
  #                ($sx + 5*$sy) / 2);
  # }




=for stopwords eg Ryde flowsnake Gosper Schouten's lookup

=head1 NAME

Math::PlanePath::FlowsnakeCentres -- self-similar path of hexagon centres

=head1 SYNOPSIS

 use Math::PlanePath::FlowsnakeCentres;
 my $path = Math::PlanePath::FlowsnakeCentres->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path is a variation of the flowsnake curve by William Gosper which
follows the flowsnake tiling the same way but follows the centres of
hexagons instead of corners and across.  The result is the same overall
shape, but a symmetric base figure.

                         39----40                          8
                        /        \
          32----33    38----37    41                       7
         /        \           \     \
       31----30    34----35----36    42    47              6
               \                    /     /  \
          28----29    16----15    43    46    48--...      5
         /           /        \     \     \
       27    22    17----18    14    44----45              4
      /     /  \           \     \
    26    23    21----20----19    13    10                 3
      \     \                    /     /  \
       25----24     4---- 5    12----11     9              2
                  /        \              /
                 3---- 2     6---- 7---- 8                 1
                        \
                    0---- 1                            <- Y=0

    -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7  8  9

The points are spread out on every second X coordinate to make little
triangles with integer coordinates, per L<Math::PlanePath/Triangular
Lattice>.

The basic pattern is the seven points 0 to 6,

        4---- 5
      /        \
     3---- 2     6---
             \
        0---- 1

This repeats at 7-fold increasing scale, with sub-sections rotated according
to the edge direction, and the 1, 2 and 6 sub-sections in reverse.  Eg. N=7
to N=13 is the "1" part, taking the base figure in reverse, and rotated so
the end points towards the "2".

The next level can be seen at the midpoints of each such group, being
N=2,11,18,23,30,37,46.

                 ---- 37                 
             ----       ---    
       30----              ---           
       |                      ---       
      |                           46     
      |                              
      |        ----18                    
     |    -----      ---        
    23---               ---              
                           ---        
                           --- 11        
                      -----          
                 2 ---                   

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::FlowsnakeCentres-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=back

=head1 FORMULAS

=head2 N to X,Y

The C<n_to_xy()> calculation follows Ed Schouten's method

    http://80386.nl/projects/flowsnake/

breaking N into base-7 digits, applying reversals from high to low according
to digits 1, 2, or 6, then applying rotation and position according to the
resulting digits.

Unlike Ed's code, the path here starts from N=0 at the edge of the Gosper
island shape and for that reason doesn't cover the plane.  An offset of
N-2*7^21 and suitable X,Y offset can be applied to get the same result.

=head2 X,Y to N

The C<xy_to_n()> calculation also follows Ed Schouten's method which is
based on a nice observation that the seven cells of the base figure can be
identified from their coordinates, and the centres of those figures then
shrunk down to unit coordinates, thus generating digits of N from low to
high.

In triangular grid style X,Y a remainder can be formed as

    m = (x + 2*y) mod 7

With the base figure 0 at 0,0 the remainders are

        4---- 6
      /        \
     1---- 3     5
             \
        0---- 2

The remainders are the same when the shape is moved by some multiple of the
next level X=5,Y=1 or its rotated forms X=1,Y=3 and X=-4,Y=1 etc.  Those
vectors all have X+2*Y==0 mod 7.

From the m remainder an offset can be applied to move X,Y to the 0 position,
leaving X,Y a multiple of the next level vector X=5,Y=1 etc.  That vector
can then be shrunk down with

    Xshrunk = (3*Y + 5*X) / 14
    Yshrunk = (5*Y - X) / 14

These are integers as 3*Y+5*X and 5*Y-X are always multiples of 14.  For
example the N=35 point at X=2,Y=6 reduces to X = (3*6+5*2)/14 = 2 and Y =
(5*6-2)/14 = 2, which is then the "5" part of the base figure.

The remainders can be mapped to digits then reversals and rotations applied,
from high to low, according to the edge orientation.  These steps can be
combined in a single lookup table with 6 states (three rotations and forward
or reverse).

The key to this approach is that the base figure is symmetric around a
central point, so the rotations or reversals in the path can be applied
after breaking down the tiling.  Can it be made to work on non-symmetric
like the "across" style C<Math::PlanePath::Flowsnake>?

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::Flowsnake>,
L<Math::PlanePath::GosperIslands>

L<Math::PlanePath::KochCurve>,
L<Math::PlanePath::HilbertCurve>,
L<Math::PlanePath::PeanoCurve>,
L<Math::PlanePath::ZOrderCurve>

http://80386.nl/projects/flowsnake/

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
