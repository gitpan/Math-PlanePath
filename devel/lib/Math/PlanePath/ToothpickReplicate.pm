# working
# order within 3/4 form ?
# name 3/4 form
#
# default parts=1 ?
#
# 3/4 as 3 of 4 quads without rotate ?
#
# 3/4 half toothpick transpose to 2nd quad the different orientation



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


# A139250 total cells
#    a(2^k) = A007583(k) = (2^(2n+1) + 1)/3
#    a(2^k-1) = A000969(2^k-2), A000969=floor (2*n+3)*(n+1)/3
#

package Math::PlanePath::ToothpickReplicate;
use 5.004;
use strict;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 91;
use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_divrem = \&Math::PlanePath::_divrem;

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'round_down_pow';

# uncomment this to run the ### lines
#use Smart::Comments;

use constant default_n_start => 1;
# use constant parameter_info_array =>
#   [ { name      => 'parts',
#       share_key => 'parts_a321',
#       display   => 'Parts',
#       type      => 'enum',
#       default   => 'all',
#       choices   => ['all','3/4','half','quarter'],
#     },
#   ];

sub x_negative {
  my ($self) = @_;
  return ($self->{'parts'} ne 'quarter');
}
my %y_negative = ('all'     => 1,
                  '3/4'     => 1,
                  'half'    => 0,
                  'quarter' => 0);
sub y_negative {
  my ($self) = @_;
  return $y_negative{$self->{'parts'}};
}


# Fraction covered
# Xlevel = 2^(level+1) - 1
# Ylevel = 2^(level+1)
# Nend = (2*4^(level+1) + 1)/3 - 1
#
# Nend / (Xlevel*Ylevel)
#  -> ((2*4^(level+1) + 1)/3 - 1) / 4^(level+1)
#  -> (2*4^(level+1) + 1)/3 / 4^(level+1)
#  -> 2*4^(level+1)/3 / 4^(level+1)
#  -> 2/3

# Leading diagonal 1,3, 7,11,
#                  23,25,29,43,  +22,22,22,32
#                  87,89,93,97,  +86,86,86,86
#                  109,111,115,171,  +86,128
#                  343
# part2start = (4^level + 5)/3    = 3,7,23,87,343
# sums of part2start(level), but +2 in second half of each
# (3)/3=1
# (3+ 1+5)/3=3
# (3+ 1+5 + 4+5)/3=9


# All
#                                    |
#  ...--25--  --27--  --19--  --17--44             4
#        |       |       |       |   |
#       24--21--26      18--13--16                 3
#        |   |               |   |
#           20---7--  ---5--12                     2
#        |   |   |       |   |   |
#       23--22-  6---2---4 -14--15                 1
#        |       |   |   |       |
#                    1                        <- Y=0
#        |       |   |   |       |
#       31--30-  8---3--10 -38--39                -1
#        |   |   |       |   |   |
#           28---9--  --11--36                    -2
#        |   |               |   |
#       32--29--34      42--37--40                -3
#        |       |       |       |
#  ...--33--  --35--  --43--  --41--...           -4
#
#                    ^
#   -4   -3 -2  -1  X=0  1   2   3   4

# Half
#                                    |
#  ...--19--  --21--  --13--  --11--22             4
#        |       |       |       |   |
#       18--15--20      12---7--10                 3
#        |   |               |   |
#           14---5--  ---3---6                     2
#        |   |   |       |   |   |
#       17--16-  4---1---2 --8---9                 1
#        |       |       |       |
#                                             <- Y=0
#
#                    ^
#   -4   -3 -2  -1  X=0  1   2   3   4

# 3/4
#
#  ...--30--  --32--  --24--  --22--...            4
#        |       |       |       |
#       29--26--31      23--18--21                 3
#        |   |               |   |
#           25---8--  ---6--17                     2
#        |   |   |       |   |   |
#       28--27-  7---2---5 -19--20                 1
#        |       |   |   |       |
#                    1                        <- Y=0
#                    |   |       |
#                  --3---4 -15--16                -1
#                        |   |   |
#                   11---9--10                    -2
#                    |       |   |
#                 --12--  --13--14                -3
#                                |
#                          -  --33--              -4
#
#                    ^
#   -4   -3 -2  -1  X=0  1   2   3   4

# Quarter
#                                    - 88-
#                                      |
#                                -44- 87
#            3                     |   |
#    -40--  --42-    -32--  --30--43         8
#   2  |       |       |       |   |
#     39--36--41      31--26--29  45--46     7
#          |               |   |
#        -35--34-    -24--25                 6
#   1      |   |       |   |   |
#    -38--37- 33--12--23 -27--28             5
#                  |   |       |
#   --10--- ---8--11                         4
#      |       |   |   |       |
#      9---4---7 -13--14  21--22             3
#          |   |       |   |   |
#   ---2---3      17--15--16                 2
#      |   |   |   |       |   |
#      1 --5---6  18     -19--20             1
#      |       |               |
#                                           <- Y=0
# X=0  1   2   3   4   5   6   7   8   9

# v              v
# |      ->      |     part 3
# +---h      h---+
#
# +---v      h
# |      ->  |         part 1 rot then part 3
# h          +---v
#
#     v      v
#     |  ->  |         part 3 then part 3 again
# h---+      +---h
#

# v          +---v
# |      ->  |         part 1
# +---h      h
#
#     v      v---+
#     |  ->      |     part 3 then part 1 rot is +90
# h---+          h

# N = (2*4^level + 1)/3 + 1   is first of "level"
# 3N-3 = 2*4^level + 1
# 2*4^level = 3N-4
# 4^(level+1) = 6N-8
#
# part = (2*4^level - 2)/3  many points in "level"
# above = (2*4^(level+1) - 2)/3
#       = (4*2*4^level - 2)/3
#       = 4*(2*4^level - 2/4)/3
#       = 4*(2*4^level - 2)/3 + 4*(+ 2 - 2/4)/3
#       = 4*(2*4^level - 2)/3 + 2
#       = 4*part + 2
# part = (above-2)/4

sub new {
  my $self = shift->SUPER::new(@_);
  $self->{'parts'} ||= 'quarter';
  return $self;
}

my @quadrant_to_hdx = (1,-1, -1,1);
my @quadrant_to_vdy = (1, 1, -1,-1);

sub n_to_xy {
  my ($self, $n) = @_;
  ### ToothpickReplicate n_to_xy(): $n

  if ($n < 1) { return; }
  if (is_infinite($n)) { return ($n,$n); }

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
  my $hdx = 1;
  my $hdy = 0;
  my $vdx = 0;
  my $vdy = 1;
  {
    my $parts = $self->{'parts'};
    if ($parts eq 'all') {
      if ($n <= 3) {
        if ($n == 1) { return (0,0); }
        if ($n == 2) { return (0,1); }
        return (0,-1); # N==3
      }
      # first of a replication level
      # Nlevel = 4*(2*4^level - 2)/3 + 4
      #        = (8*4^level - 8)/3 + 4
      #        = (8*4^level - 8 + 12)/3
      #        = (8*4^level + 4)/3           12,44,172
      # 3N = 8*4^level + 4
      # 8*4^level = 3N-4
      # 4^(level+2) = 6N-8
      #
      # three count = 3*(2*4^level - 2)/3 + 2
      #             = 2*4^level
      # 44-12 = 32
      # 172-44 = 128

      my ($len,$level) = round_down_pow(6*$n-8, 4);
      my $three_parts = $len/8;

      ### all breakdown ...
      ### $level
      ### $len
      ### $three_parts

      (my $quadrant, $n) = _divrem ($n-($len+8)/6, $three_parts);
      ### $quadrant
      ### n remainder: $n
      ### assert: $quadrant >= 0
      ### assert: $quadrant <= 3

      # quarter middle
      # Nquarter = (2*4^level + 1)/3  = 3,11,43
      $n += ($len/8+1)/3;
      $hdx = $quadrant_to_hdx[$quadrant];
      $vdy = $quadrant_to_vdy[$quadrant];
      ### n in quarter: $n

    } elsif ($parts eq 'half') {
      if ($n == 1) {
        return (0,1);
      }

      # first of a replication level
      # Nlevel = 2*(2*4^level - 2)/3 + 2
      #        = (4*4^level - 4)/3 + 2
      #        = (4*4^level - 4 + 6)/3
      #        = (4*4^level + 2)/3     = 2,6,22
      # 3N = 4*4^level + 2
      # 4^(level+1) = 3N-2

      my ($len,$level) = round_down_pow(3*$n-2, 4);
      my $three_parts = $len/2;

      ### $len
      ### $level
      ### $three_parts
      ### start this level: ($len+2)/3
      ### n reduced: $n-($len+2)/3

      (my $quadrant, $n) = _divrem ($n-($len+2)/3, $three_parts);
      ### $quadrant
      ### n remainder: $n
      ### assert: $quadrant >= 0
      ### assert: $quadrant <= 1

      $n += ($len/2+1)/3;
      if ($quadrant) { $hdx = -1; }
      ### n in quarter: $n

    } elsif ($parts eq '3/4') {
      if ($n <= 2) {
        return (0,$n-1);
      }
      # Nend = 3*(2*4^level - 2)/3 + 3
      #      = (2*4^level - 2) + 3
      #      = 2*4^level + 1     = 3,9,33
      # N-1 = 2*4^level + 1
      # 4^(level+1) = 2N-2

      my ($len,$level) = round_down_pow(2*$n-2, 4);
      my $three_parts = $len/2;

      ### $len
      ### $level
      ### $three_parts
      ### start this level: ($len/2+1)
      ### n reduced: $n-($len/2+1)

      (my $quadrant, $n) = _divrem ($n-($len/2+1), $three_parts);
      ### $quadrant
      ### n remainder: $n
      ### assert: $quadrant >= 0
      ### assert: $quadrant <= 2

      $n += ($len/2+1)/3;
      ### n in quarter: $n

      if ($quadrant == 0) {
        $hdx = 0;  # rotate -90
        $hdy = -1;
        $vdx = 1;
        $vdy = 0;
        $x = -1; # offset
      } elsif ($quadrant == 2) {
        $hdx = -1;  # mirror
      }
    }
  }

  my ($len,$level) = round_down_pow(6*$n-2, 4);
  my $part_n = (2*$len-2)/3;
  ### $level
  ### $part_n

  $len = 2**$level;
  for ( ;
        $level-- >= 0;
        $len /= 2,  $part_n = ($part_n-2)/4) {

    ### at: "x=$x,y=$y level=$level hxy=$hdx,$hdy vxy=$vdx,$vdy   n=$n"
    ### $len
    ### $part_n
    ### assert: $len == 2 ** ($level+1)
    ### assert: $part_n == (2 * 4 ** ($level+1) - 2)/3

    if ($n <= $part_n) {
      ### part 0, no change ...
      next;
    }

    $n -= $part_n;
    $x += $len * ($hdx + $vdx);  # diagonal
    $y += $len * ($hdy + $vdy);

    if ($n == 1) {
      ### toothpick A ...
      last;
    }
    if ($n == 2) {
      ### toothpick B ...
      $x += $vdx;
      $y += $vdy;
      last;
    }
    $n -= 2;

    if ($n <= $part_n) {
      ### part 1, rotate ...
      $x -= $hdx; # offset
      $y -= $hdy;
      ($hdx,$hdy, $vdx,$vdy)    # rotate 90 in direction v toward h
        = (-$vdx,-$vdy, $hdx,$hdy);
      next;
    }
    $n -= $part_n;

    if ($n <= $part_n) {
      ### part 2 ...
      next;
    }
    $n -= $part_n;

    ### part 3, mirror ...
    $hdx = -$hdx;
    $hdy = -$hdy;
  }

  ### assert: $n == 1 || $n == 2

  ### final: "x=$x y=$y"
  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### ToothpickReplicate xy_to_n(): "$x, $y"

  $x = round_nearest ($x);
  $y = round_nearest ($y);

  my $parts = $self->{'parts'};
  my $rotated = ($parts eq '3/4' && $x >= 0 && $y < 0);
  if ($rotated) {
    ($x,$y) = (-$y,$x+1);  # rotate +90 and shift up
    ### rotated: "x=$x y=$y"
  }

  my ($len,$level) = round_down_pow (max(abs($x), abs($y)-1),
                                     2);
  if (is_infinite($level)) {
    return $level;
  }
  ### $level
  ### $len

  my $n = 1;
  {
    if ($parts eq 'all') {
      if ($x == 0) {
        if ($y == 0) { return 1; }
        if ($y == 1) { return 2; }
        if ($y == -1) { return 3; }
      }
      $n += (2*$len*$len+1);
      if ($x < 0) {
        $x = -$x;
        if ($y > 0) {
          $n += 2*$len*$len;  # second quad, +2, +8, +32
        } else {
          $n += 4*$len*$len;  # third quad, +4,+16
          $y = -$y;
        }
      } else {
        if ($y < 0) {
          $n += 6*$len*$len;  # fourth quad
          $y = -$y;
        }
      }

    } elsif ($parts eq 'half') {
      if ($x == 0) {
        if ($y == 1) { return 1; }
      }
      $n += (2*$len*$len+1)/3;   # +1,+3,+11,+43
      if ($x < 0) {
        $x = -$x;
        $n += 2*$len*$len;  # second quad, +2,+8,+32
      }

    } elsif ($parts eq '3/4') {
      ### 3/4 ...
      if ($x == 0) {
        if ($y == 0) { return 1; }
        if ($y == 1) { return 2; }
      }
      $n += (10*$len*$len+2)/3;   # +4,+14,+54,+214,+854,+3414
      if ($rotated) {
        $n -= 2*$len*$len;  # fourth quad, -2, -8, -32
      } elsif ($x < 0) {
        $x = -$x;
        if ($y > 0) {
          $n += 2*$len*$len;  # second quad, +2, +8, +32
        } else {
          return undef;  # third quad, empty
        }
      }
    }
  }

  #                              2^(level+1)-1
  #                              v
  #          +---------+----------+
  #          |         |          | <- 2^(level+1)
  #          |   3             2  |
  #          | mirror        same |
  #          |          --B--     | <- 2^level + 1
  #          |            |       |
  #          +--          A     --+ <- 2^level
  #                       |       |
  #                           1   |
  #                          rot  |
  #             0            +90  |
  #                       |       |
  #                       +-------+
  #                       ^
  #                      2^level

  my $part_n = (2*$len*$len - 2) / 3;
  ### $part_n

  while ($level-- > 0) {
    ### at: "x=$x,y=$y  len=$len part_n=$part_n   n=$n"
    ### assert: $len == 2 ** ($level+1)
    ### assert: $part_n == (2 * 4 ** ($level+1) - 2)/3

    if ($x == $len) {
      if ($y == $len) {
        ### toothpick A ...
        return $n + $part_n;
      }
      if ($y == $len+1) {
        ### toothpick B ...
        return $n + $part_n + 1;
      }
    }

    if ($y <= $len) {
      if ($x < $len) {
        ### part 0 ...
      } else {
        ### part 1, rotate ...
        $n += $part_n + 2;
        ($x,$y) = ($len-$y,$x-$len+1); # shift, rotate +90
      }
    } else {
      $y -= $len;
      if ($x > $len) {
        ### part 2 ...
        $n += 2*$part_n + 2;
        $x -= $len;
      } else {
        ### part 3 ...
        $n += 3*$part_n + 2;
        $x = $len-$x; # mirror
      }
    }

    $len /= 2;
    $part_n = ($part_n-2)/4;
  }

  ### end loop: "x=$x y=$y   n=$n"

  if ($x == 1) {
    if ($y == 1) {
      return $n;
    } elsif ($y == 2) {
      return $n + 1;
    }
  }

  return undef;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### ToothpickReplicate rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = round_nearest ($x1);
  $y1 = round_nearest ($y1);
  $x2 = round_nearest ($x2);
  $y2 = round_nearest ($y2);

  my $parts = $self->{'parts'};
  if ($parts eq 'all') {
    my ($len,$level) = round_down_pow (max(abs($x1),
                                           abs($x2),
                                           abs($y1)-1,
                                           abs($y2)-1),
                                       2);
    ### $level
    ### $len
    return (1,
            (32*$len*$len+1)/3);
  }

  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;

  if ($parts eq '3/4') {
    if ($x2 < 0 && $y2 < 0) {
      return (1,0);
    }
    my ($len,$level) = round_down_pow (max(-$x1, $x2,
                                           -$y1, $y2-1),
                                       2);
    ### $level
    ### $len
    return (1, 8*$len*$len);
  }

  if ($parts eq 'half') {
    if ($y2 < 0) {
      return (1,0);
    }
    my ($len,$level) = round_down_pow (max(abs($x1),
                                           abs($x2),
                                           $y2-1),
                                       2);
    ### $level
    ### $len
    return (1,
            (16*$len*$len-1)/3);
  }

  if ($x2 < 1 || $y2 < 1) {
    return (1,0);
  }

  ### assert: $parts eq 'quarter'
  my ($len,$level) = round_down_pow (max($x2, $y2-1),
                                     2);
  ### $level
  ### $len
  if (is_infinite($level)) {
    return (1, $level);
  }

  return (1, (8*$len*$len-2)/3);
}

1;
__END__

=for stopwords eg Ryde Math-PlanePath Nstart Nend

=head1 NAME

Math::PlanePath::ToothpickReplicate -- toothpick sequence

=head1 SYNOPSIS

 use Math::PlanePath::ToothpickReplicate;
 my $path = Math::PlanePath::ToothpickReplicate->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress ...>

This is the "toothpick" pattern arranged as a self-similar replicating
pattern

=cut

# math-image --path=ToothpickReplicate --all --output=numbers --size=60x10

=pod

    ..-25--  --27--  --19--  --17--..         4
        |       |       |       |
       24--21--26      18--13--16             3
        |   |               |   |
           20---7--  ---5--12                 2
        |   |   |       |   |   |
       23--22-  6---2---4 -14--15             1
        |       |   |   |       |
                    1                    <- Y=0
        |       |   |   |       |
       31--30-  8---3--10 -38--39            -1
        |   |   |       |   |   |
           28---9--  --11--36                -2
        |   |               |   |
       32--29--34      42--37--40            -3
        |       |       |       |
    ..-33--  --35--  --43--  --41--..        -4

                    ^
        -3 -2  -1  X=0  1   2   3

=head2 Quarter

Option C<parts =E<gt> "quarter"> selects replications just in a quarter of
the plane,

=cut

# math-image --path=ToothpickReplicate --all --output=numbers --size=80x50

=pod

     8  |  --40--  --42--  --32--  --30--...
        |     |       |       |       |
     7  |    39--36--41      31--26--29
        |         |               |   |
     6  |        35--34--   -24--25
        |         |   |       |   |   |
     5  |  --38--37- 33--12--23 -27--28
        |                 |   |       |
     4  |  --10--- ---8--11
        |     |       |   |   |       |
     3  |     9---4---7 -13--14  21--22
        |         |   |       |   |   |
     2  |  ---2---3      17--15--16
        |     |   |   |   |       |   |
     1  |     1 --5---6  18    --19--20
        |     |       |               |
    Y=0 |
        +------------------------------
        X=0   1   2   3   4   5   6   7

=head2 Replication

The points visited are the same as L<Math::PlanePath::ToothpickTree>, but in
a self-similar order.  The pattern within each quarter repeats at 2^level
size blocks.

    +------------+------------+
    |            |            |
    |  block 3       block 2  |
    |   mirror        same    |
    |                         |
    |          --B--          |
    |            |            |
    +----------  A         ---+
    |            |            |
    |  block 0       block 1  |
    |            |   rot +90  |
    |            |            |
    |            |            |
    +------------+------------+

In the parts=quarter above

    N=1 to N=10     "0" block
    N=11            "A" middle point
    N=12            "B" middle point
    N=13 to N=22    "1" block, rotated +90 degrees
    N=23 to N=32    "2" block, same layout as the "0" block
    N=33 to N=42    "3" block, mirror image of "0" block

The very first points N=1 and N=2 are effectively the "A" and "B" middle
toothpicks with no points at all in the 0,1,2,3 lower blocks.

The full parts=all form is four quarters, each advancing by a replication
level each time.

=head2 Level Ranges

Counting the very first N=1,2 as level 0, a new quarter level begins at

    Nlevel = (2*4^level + 1)/3

For example level=1 begins at N=(2*4^1+1)/3=3, or level=2 which is the
points shown above begins (2*4^2+1)/3=11, and extends through to Nlevel(3)-1
= (2*4^3+1)/3-1=42.

The X,Y extent of a level is

    Xlevel = 2^(level+1) - 1        inclusive
    Ylevel = 2^(level+1)

For example level=1 extends to X=3,Y=4, or level 2 which is the points shown
above to X=7,Y=8.

As level increases the points visited approach 2/3 of the X,Y extent,
ie. Nlevel(k+1)/Xlevel(l)*Ylevel(l) -> 2/3.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::ToothpickReplicate-E<gt>new ()>

Create and return a new path object.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::UlamWarburton>

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
