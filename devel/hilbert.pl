#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

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

use strict;
use warnings;
use Math::PlanePath::HilbertCurve;

#use Smart::Comments;

my $path = Math::PlanePath::HilbertCurve->new;

sub want {
  my ($n) = @_;
  my ($x1,$y1) = $path->n_to_xy($n);
  my ($x2,$y2) = $path->n_to_xy($n+1);
  return ($x2-$x1, $y2-$y1);
}

sub try {
  my ($n) = @_;
  my $dx = 0;
  my $dy = 1;
  do {
    my $bits = $n & 3;

    if ($bits == 0) {
      ($dx,$dy) = ($dy,$dx);
      ### d swap: "$dx,$dy"
    } elsif ($bits == 1) {
      # ($dx,$dy) = ($dy,$dx);
      # ### d swap: "$dx,$dy"
    } elsif ($bits == 2) {
      ($dx,$dy) = ($dy,$dx);
      ### d swap: "$dx,$dy"
      $dx = -$dx;
      $dy = -$dy;
      ### d invert: "$dx,$dy"
    } elsif ($bits == 3) {
      ### d unchanged
    }

    my $prevbits = $bits;
    $n >>= 2;
    return ($dx,$dy) if ! $n;
    $bits = $n & 3;

    if ($bits == 0) {
      ### d unchanged
    } elsif ($bits == 1) {
      ($dx,$dy) = ($dy,$dx);
      ### d swap: "$dx,$dy"
    } elsif ($bits == 2) {
      if ($prevbits >= 2) {
      }
      # $dx = -$dx;
      # $dy = -$dy;
      ($dx,$dy) = ($dy,$dx);
      ### d swap: "$dx,$dy"
    } elsif ($bits == 3) {
      ($dx,$dy) = ($dy,$dx);
      ### d invert and swap: "$dx,$dy"
    }
    $n >>= 2;
  } while ($n);
  return ($dx,$dy);
}

my @n_to_next_i = (4,   0,  0,  8,  # i=0
                   0,   4,  4, 12,  # i=4
                   12,  8,  8,  0,  # i=8
                   8,  12, 12,  4,  # i=12
                  );
my @n_to_x = (0, 1, 1, 0,   # i=0
              0, 0, 1, 1,   # i=4
              1, 1, 0, 0,   # i=8
              1, 0, 0, 1,   # i=12
             );
my @n_to_y = (0, 0, 1, 1,   # i=0
              0, 1, 1, 0,   # i=4
              1, 0, 0, 1,   # i=8
              1, 1, 0, 0,   # i=12
             );

my @i_to_dx = (1, 0, -1, 3, 0, 1,  0, 7,-1, 1, 10, 0,-1, 0,1,15);
my @i_to_dy = (0, 1,  0, 3, 1, 0, -1, 7, 0, 0, 10, 1, 0,-1,0,15);

# unswapped
# my @i_to_dx = (1, 0, -1, 3, 0, 1,  0, 7,-1, 1, 10, 0,-1, 0,1,15);
# my @i_to_dy = (0, 1,  0, 3, 1, 0, -1, 7, 0, 0, 10, 1, 0,-1,0,15);
# my @i_to_dx = (0 .. 15);
# my @i_to_dy = (0 .. 15);
sub Xtry {
  my ($n) = @_;
  ### HilbertCurve n_to_xy(): $n
  ### hex: sprintf "%#X", $n
  return if $n < 0;

  my $x = my $y = ($n & 0); # inherit
  my $pos = 0;
  {
    my $pow = $x + 4;        # inherit
    while ($n >= $pow) {
      $pow <<= 2;
      $pos += 2;
    }
  }
  ### $pos

  my $dx = 9;
  my $dy = 9;
  my $i = ($pos & 2) << 1;
  my $t;
  while ($pos >= 0) {
    my $nbits = (($n >> $pos) & 3);
    $t = $i + $nbits;
    $x = ($x << 1) | $n_to_x[$t];
    $y = ($y << 1) | $n_to_y[$t];
    ### $pos
    ### $i
    ### bits: ($n >> $pos) & 3
    ### $t
    ### n_to_x: $n_to_x[$t]
    ### n_to_y: $n_to_y[$t]
    ### next_i: $n_to_next_i[$t]
    ### x: sprintf "%#X", $x
    ### y: sprintf "%#X", $y
    # if ($nbits == 0) {
    # } els
    if ($nbits == 3) {
      if ($pos & 2) {
        ($dx,$dy) = ($dy,$dx);
      }
    } else {
      ($dx,$dy) = ($i_to_dx[$t], $i_to_dy[$t]);
    }
    $i = $n_to_next_i[$t];
    $pos -= 2;
  }

  print "final i $i\n";
  return ($dx,$dy);
}

sub base4 {
  my ($n) = @_;
  my $ret = '';
  do {
    $ret .= ($n & 3);
  } while ($n >>= 2);
  return reverse $ret;
}
    
foreach my $n (0 .. 64) {
  my $n4 = base4($n);
  my ($wdx,$wdy) = want($n);
  my ($tdx,$tdy) = try($n);
  my $diff = ($wdx!=$tdx || $wdy!=$tdy ? " ***" : "");
  print "$n $n4  $wdx,$wdy  $tdx,$tdy $diff\n";
}
exit 0;



# p=dx+dy    +/-1
# m=dx-dy    +/-1
#
# p = count 3s in N, odd/even
# m = count 3s in -N, odd/even
#
# p==m is dx
# p!=m then p is dy
