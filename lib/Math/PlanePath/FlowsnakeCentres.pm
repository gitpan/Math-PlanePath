# Copyright 2011, 2012 Kevin Ryde

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
# math-image --path=FlowsnakeCentres,arms=3 --all --output=numbers_dash
#
# http://80386.nl/projects/flowsnake/
#


package Math::PlanePath::FlowsnakeCentres;
use 5.004;
use strict;
use List::Util 'max';
use POSIX 'ceil';

use vars '$VERSION', '@ISA';
$VERSION = 67;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::SacksSpiral;
*_rect_to_radius_range = \&Math::PlanePath::SacksSpiral::_rect_to_radius_range;

# uncomment this to run the ### lines
#use Devel::Comments;


use constant n_start => 0;
sub arms_count {
  my ($self) = @_;
  return $self->{'arms'} || 1;
}

use constant parameter_info_array => [ { name      => 'arms',
                                         share_key => 'arms_3',
                                         type      => 'integer',
                                         minimum   => 1,
                                         maximum   => 3,
                                         default   => 1,
                                         width     => 1,
                                         description => 'Arms',
                                       } ];


#         *
#        / \
#       /   \
#      *-----*
#
# (b/2)^2 + h^2 = s
# (1/2)^2 + h^2 = 1
# h^2 = 1 - 1/4
# h = sqrt(3)/2 = 0.866
#

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 3) { $arms = 3; }
  $self->{'arms'} = $arms;
  return $self;
}


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

  my $arms = $self->{'arms'};
  my $rot = ($n % $arms);
  $n = int($n/$arms);

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

  my ($ox,$oy,$sx,$sy);
  if ($rot == 0) {
    $ox = 0;
    $oy = 0;
    $sx = 2;
    $sy = 0;
  } elsif ($rot == 1) {
    $ox = -1;  # at +120
    $oy = 1;
    $sx = -1;  # rot to +120
    $sy = 1;
  } else {
    $ox = -2;   # at 180
    $oy = 0;
    $sx = -1;  # rot to +240
    $sy = -1;
  }

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
  = (0,3,1,2,4,6,5,    0,42,14,28, 0,56, 0,      # 0   right forw 0
     0,5,1,4,6,2,3,    0,42,14,70,14,14,28,    # 14  +120 rev   1
     6,3,5,4,2,0,1,   28,56,70, 0,28,42,28,    # 28  left rev   2
     4,5,3,2,6,0,1,   42,42,70,56,14,42,28,   # 42  +60 forw   3
     2,1,3,4,0,6,5,   56,56,14,42,70,56, 0,    # 56  -60 rev    6
     6,1,5,2,0,4,3,   28,56,70,14,70,70, 0,    # 70      forw
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
  if (_is_infinite($level_limit)) { return $level_limit; }

  my @digits;
  my $arm;
  my $state;
  for (;;) {
    if ($level_limit-- < 0) {
      ### oops, level limit ...
      return undef;
    }
    if ($x == 0 && $y == 0) {
      ### found first arm 0,0 ...
      $arm = 0;
      $state = 0;
      last;
    }
    if ($x == -2 && $y == 0) {
      ### found second arm -2,0 ...
      $arm = 1;
      $state = 42;
      last;
    }
    if ($x == -1 && $y == -1) {
      ### found third arm -1,-1 ...
      $arm = 2;
      $state = 70;
      last;
    }

    # if ((($x == -1 || $x == 1) && $y == -1)
    #     || ($x == 0 && $y == -2)) {
    #   ### below island ...
    #   return undef;
    # }

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
  my $arms = $self->{'arms'};
  if ($arm >= $arms) {
    return undef;
  }

  my $n = 0;
  foreach my $m (reverse @digits) {  # high to low
    ### $m
    ### digit: $modulus_to_digit[$state + $m]
    ### state: $state
    ### next state: $modulus_to_digit[$state+7 + $m]

    $n = 7*$n + $modulus_to_digit[$state + $m];
    $state = $modulus_to_digit[$state+7 + $m];
  }
  ### final n along arm: $n

  return $n*$arms + $arm;
}

# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### FlowsnakeCentres rect_to_n_range(): "$x1,$y1  $x2,$y2"

  my ($r_lo, $r_hi) = _rect_to_radius_range ($x1,$y1*sqrt(3), $x2,$y2*sqrt(3));
  $r_hi *= 2;
  my $level_plus_1 = ceil( log(max(1,$r_hi/4)) / log(sqrt(7)) ) + 2;
  # return (0, 7**$level_plus_1);


  my $level_limit = $level_plus_1;
  ### $level_limit
  if (_is_infinite($level_limit)) { return ($level_limit,$level_limit); }

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### sorted range: "$x1,$y1  $x2,$y2"

  my $rect_dist = sub {
    my ($x,$y) = @_;
    my $xd = ($x < $x1 ? $x1 - $x
              : $x > $x2 ? $x - $x2
              : 0);
    my $yd = ($y < $y1 ? $y1 - $y
              : $y > $y2 ? $y - $y2
              : 0);
    return ($xd*$xd + 3*$yd*$yd);
  };

  my $arms = $self->{'arms'};
  ### $arms
  my $n_lo;
  {
    my @hypot = (6);
    my $top = 0;
    for (;;) {
    ARM_LO: foreach my $arm (0 .. $arms-1) {
        my $i = 0;
        my @digits;
        if ($top > 0) {
          @digits = ((0)x($top-1), 1);
        } else {
          @digits = (0);
        }

        for (;;) {
          my $n = 0;
          foreach my $digit (reverse @digits) { # high to low
            $n = 7*$n + $digit;
          }
          $n = $n*$arms + $arm;
          ### lo consider: "i=$i  digits=".join(',',reverse @digits)."  is n=$n"

          my ($nx,$ny) = $self->n_to_xy($n);
          my $nh = &$rect_dist ($nx,$ny);
          if ($i == 0 && $nh == 0) {
            ### lo found inside: $n
            if (! defined $n_lo || $n < $n_lo) {
              $n_lo = $n;
            }
            next ARM_LO;
          }

          if ($i == 0 || $nh > $hypot[$i]) {
            ### too far away: "nxy=$nx,$ny   nh=$nh vs ".$hypot[$i]

            while (++$digits[$i] > 6) {
              $digits[$i] = 0;
              if (++$i <= $top) {
                ### backtrack up ...
              } else {
                ### not found within this top and arm, next arm ...
                next ARM_LO;
              }
            }
          } else {
            ### lo descend ...
            ### assert: $i > 0
            $i--;
            $digits[$i] = 0;
          }
        }
      }

      # if an $n_lo was found on any arm within this $top then done
      if (defined $n_lo) {
        last;
      }

      ### lo extend top ...
      if (++$top > $level_limit) {
        ### nothing below level limit ...
        return (1,0);
      }
      $hypot[$top] = 7 * $hypot[$top-1];
    }
  }

  my $n_hi = 0;
 ARM_HI: foreach my $arm (reverse 0 .. $arms-1) {
    my @digits = ((6) x $level_limit);
    my $i = $#digits;
    for (;;) {
      my $n = 0;
      foreach my $digit (reverse @digits) { # high to low
        $n = 7*$n + $digit;
      }
      $n = $n*$arms + $arm;
      ### hi consider: "arm=$arm  i=$i  digits=".join(',',reverse @digits)."  is n=$n"

      my ($nx,$ny) = $self->n_to_xy($n);
      my $nh = &$rect_dist ($nx,$ny);
      if ($i == 0 && $nh == 0) {
        ### hi found inside: $n
        if ($n > $n_hi) {
          $n_hi = $n;
          next ARM_HI;
        }
      }

      if ($i == 0 || $nh > (6 * 7**$i)) {
        ### too far away: "$nx,$ny   nh=$nh vs ".(6 * 7**$i)

        while (--$digits[$i] < 0) {
          $digits[$i] = 6;
          if (++$i < $level_limit) {
            ### hi backtrack up ...
          } else {
            ### hi nothing within level limit for this arm ...
            next ARM_HI;
          }
        }

      } else {
        ### hi descend
        ### assert: $i > 0
        $i--;
        $digits[$i] = 6;
      }
    }
  }

  if ($n_hi == 0) {
    ### oops, lo found but hi not found
    $n_hi = $n_lo;
  }

  return ($n_lo, $n_hi);
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




=for stopwords eg Ryde flowsnake Gosper Schouten's lookup Math-PlanePath DragonCurve multi-arm

=head1 NAME

Math::PlanePath::FlowsnakeCentres -- self-similar path of hexagon centres

=head1 SYNOPSIS

 use Math::PlanePath::FlowsnakeCentres;
 my $path = Math::PlanePath::FlowsnakeCentres->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path is a variation of the flowsnake curve by William Gosper which
follows the flowsnake tiling the same way but the centres of the hexagons
instead of corners across.  The result is the same overall shape, but a
symmetric base figure.

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

The base pattern is the seven points 0 to 6,

        4---- 5
      /        \
     3---- 2     6---
             \
        0---- 1

This repeats at 7-fold increasing scale, with sub-sections rotated according
to the edge direction, and the 1, 2 and 6 sub-sections in reverse.  Eg. N=7
to N=13 is the "1" part taking the base figure in reverse and rotated so the
end points towards the "2".

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

=head2 Arms

The optional C<arms> parameter can give up to three copies of the curve,
each advancing successively.  For example C<arms=E<gt>3> is as follows.
Notice the N=3*k points are the plain curve, and N=3*k+1 and N=3*k+2 are
rotated copies of it.

                            84---...    48----45                   5
                           /           /        \
                         81    66    51----54    42                4
                        /     /  \           \     \
          28----25    78    69    63----60----57    39    30       3
         /        \     \     \                    /     /  \
       31----34    22    75----72    12----15    36----33    27    2
               \     \              /        \              /
          40----37    19     4     9---- 6    18----21----24       1
         /           /     /  \           \
       43    58    16     7     1     0---- 3    77----80      <- Y=0
      /     /  \     \     \                    /        \
    46    55    61    13----10     2    11    74----71    83      -1
      \     \     \              /     /  \           \     \
       49----52    64    73     5---- 8    14    65----68    86   -2
                  /     /  \              /     /           /
          ...   67----70    76    20----17    62    53   ...      -3
            \              /     /           /     /  \
             85----82----79    23    38    59----56    50         -4
                              /     /  \              /
                            26    35    41----44----47            -5
                              \     \
                               29----32                           -6

                                      ^
          -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7  8  9

As described in L<Math::PlanePath::Flowsnake/Arms> the flowsnake essentially
fills a hexagonal shape with wiggly sides.  For this Centres variation the
start of each arm corresponds to the centre of a little hexagon.  The N=0
little hexagon is at the origin, and the 1 and 2 beside and below,

    ^ / \   / \
     \   \ /   \
    | \   |     |
    |  1  |  0--->
    |     |     |
     \   / \   /
      \ /   \ /
       |     |
       |  2  |
       | /   |
        /   /
      v  \ /

Like the main Flowsnake the sides of the arms mesh perfectly and three arms
fill the plane.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::FlowsnakeCentres-E<gt>new ()>

Create and return a new path object.

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

The C<n_to_xy()> calculation follows Ed Schouten's method

    http://80386.nl/projects/flowsnake/

breaking N into base-7 digits, applying reversals from high to low according
to digits 1, 2, or 6, then applying rotation and position according to the
resulting digits.

Unlike Ed's code, the path here starts from N=0 at the edge of the Gosper
island shape and for that reason doesn't cover the plane.  An offset of
N-2*7^21 and suitable X,Y offset can be applied to get the same result.

=head2 X,Y to N

The C<xy_to_n()> calculation also follows Ed Schouten's method.  It's based
on a nice observation that the seven cells of the base figure can be
identified from their X,Y coordinates, and the centre of those seven cell
figures then shrunk down a level to be a unit apart, thus generating digits
of N from low to high.

In triangular grid X,Y a remainder is formed

    m = (x + 2*y) mod 7

Taking the base figure's N=0 at 0,0 the remainders are

        4---- 6
      /        \
     1---- 3     5
             \
        0---- 2

The remainders are unchanged when the shape is moved by some multiple of the
next level X=5,Y=1 or the same at 120 degrees X=1,Y=3 or 240 degrees
X=-4,Y=1.  Those vectors all have X+2*Y==0 mod 7.

From the m remainder an offset can be applied to move X,Y to the 0 position,
leaving X,Y a multiple of the next level vectors X=5,Y=1 etc.  Those vectors
can then be shrunk down with

    Xshrunk = (3*Y + 5*X) / 14
    Yshrunk = (5*Y - X) / 14

This gives integers since 3*Y+5*X and 5*Y-X are always multiples of 14.  For
example the N=35 point at X=2,Y=6 reduces to X = (3*6+5*2)/14 = 2 and Y =
(5*6-2)/14 = 2, which is then the "5" part of the base figure.

The remainders can be mapped to digits and then reversals and rotations
applied, from high to low, according to the edge orientation.  Those steps
can be combined in a single lookup table with 6 states (three rotations, and
each one forward or reverse).

For the main curve the reduction ends at 0,0.  For the multi-arm form the
second arm ends to the right at -2,0 and the third below at -1,-1.  Notice
the modulo and shrink procedure maps those three points back to themselves
unchanged.  The calculation can be done without paying attention to which
arms are supposed to be in use.  On reaching one of the three ends the "arm"
is determined and the original X,Y can be rejected or accepted accordingly.

The key to this approach is that the base figure is symmetric around a
central point, so the tiling can be broken down first, and the rotations or
reversals in the path applied afterwards.  Can it work on a non-symmetric
base figure like the "across" style of the main Flowsnake, or something like
the DragonCurve for that matter?

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::Flowsnake>,
L<Math::PlanePath::GosperIslands>

L<Math::PlanePath::KochCurve>,
L<Math::PlanePath::HilbertCurve>,
L<Math::PlanePath::PeanoCurve>,
L<Math::PlanePath::ZOrderCurve>

http://80386.nl/projects/flowsnake/ -- Ed Schouten's code

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011, 2012 Kevin Ryde

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
