#!/usr/bin/perl -w

# Copyright 2010, 2011, 2012 Kevin Ryde

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

use 5.010;
use strict;
use Math::PlanePath::HilbertCurve;

#use Smart::Comments;


{
  require Math::NumSeq::PlanePathCoord;
  require Math::PlanePath::AR2W2Curve;
  foreach my $start_shape (@{Math::PlanePath::AR2W2Curve
      ->parameter_info_hash->{'start_shape'}->{'choices'}}) {

    my $hseq = Math::NumSeq::PlanePathCoord->new (planepath => 'HilbertCurve',
                                                  coordinate_type => 'RSquared');
    my $aseq = Math::NumSeq::PlanePathCoord->new
      (planepath => "AR2W2Curve,start_shape=$start_shape",
       coordinate_type => 'RSquared');
    foreach my $i ($hseq->i_start .. 10000) {
      if ($hseq->ith($i) != $aseq->ith($i)) {
        print "$start_shape different at $i\n";
        last;
      }
    }
  }
  exit 0;
}

{
  require Math::PlanePath::ZOrderCurve;
  my $hilbert  = Math::PlanePath::HilbertCurve->new;
  my $zorder   = Math::PlanePath::ZOrderCurve->new;
  sub zorder_perm {
    my ($n) = @_;
    my ($x, $y) = $zorder->n_to_xy ($n);
    return $hilbert->xy_to_n ($x, $y);
  }
  sub cycle_length {
    my ($n) = @_;
    my %seen;
    my $count = 1;
    my $p = $n;
    for (;;) {
      $p = zorder_perm($p);
      if ($p == $n) {
        last;
      }
      $count++;
    }
    return $count;
  }
  foreach my $n (0 .. 128) {
    my $perm = zorder_perm($n);
    my $len = cycle_length($n);
    print "$n $perm   $len\n";
  }
  exit 0;
}



{
  require Math::BaseCnv;
  require Math::NumSeq::PlanePathDelta;
  my $seq = Math::NumSeq::PlanePathDelta->new (delta_type => 'Dir4',
                                               planepath => 'HilbertCurve');
  foreach my $n (0 .. 256) {
    my $n4 = Math::BaseCnv::cnv($n,10,4);
    my $want = $seq->ith($n);
    my $got = dir_try($n);
    my $str = ($want == $got ? '' : '   ***');
    printf "%2d %3s  %d %d%s\n", $n, $n4, $want, $got, $str;
  }
  exit 0;


# my @next_state = (4,0,0,12, 0,4,4,8, 12,8,8,4, 8,12,12,0);
# my @digit_to_x = (0,1,1,0, 0,0,1,1, 1,0,0,1, 1,1,0,0);
# my @digit_to_y = (0,0,1,1, 0,1,1,0, 1,1,0,0, 1,0,0,1);

#     dx  dy  dir
# 0   +1   0   0,1,2     4,0,0,12    0=XYswap dir^1   3 y=-x  dir^3  low^1 or ^3
# 4    0  +1   1,0,3     0,4,4,8                      3 x=-y
# 8   -1   0   2,3,0    12,8,8,4,
# 12   0  -1   3,2,1    8,12,12,0    0=XYswap dir^1

#  [012]3333
#  [123]0000

# p = count 3s   0 if dx+dy=-1 so dx=-1 or dy=-1 SW,  1 if dx+dy=1 NE
# m = count 3s in -n    0 if dx-dy=-1 NW, 1 if dx-dy=1 SE
# 1023200 neg = 2310133+1 = 2310200  count 0s except trailing 0s


  sub dir_try {
    my ($n) = @_;
    ### dir_try(): $n



    # p = count 3s   0 if dx+dy=-1 so dx=-1 or dy=-1 SW,  1 if dx+dy=1 NE
    # m = count 3s in -n    0 if dx-dy=-1 NW, 1 if dx-dy=1 SE
    # 1023200 neg = 2310133+1 = 2310200  count 0s except trailing 0s

    $n++;
    my $p = count_3s($n) & 1;
    my $m = count_3s((-$n) & 0xFF) & 1;
    ### n  : sprintf "%8b", $n
    ### neg: sprintf "%8b", (-$n) & 0xFF
    ### $p
    ### $m
    if ($p == 0) {
      if ($m == 0) {
        return 0; # E
      } else {
        return 1; # S
      }
    } else {
      if ($m == 0) {
        return 3; # N
      } else {
        return 2; # W
      }
    }



    # my $state = 0;
    # my @digits = digits($n);
    # if (@digits & 1) {
    #   #      $state ^= 1;
    # }
    # # unshift @digits, 0;
    # ### @digits
    #
    # my $flip = 0;
    # my $dir = 0;
    # for (;;) {
    #   if (! @digits) {
    #     return $flip;
    #   }
    #   $dir = pop @digits;
    #   if ($dir == 3) {
    #     $flip ^= 1;
    #   } else {
    #     last;
    #   }
    # }
    # if ($flip) {
    #   $dir = 1-$dir;
    # }
    #
    # while (@digits) {
    #   my $digit = pop @digits;
    #   ### at: "state=$state  digit=$digit  dir=$dir"
    #
    #   if ($digit == 0) {
    #   }
    #   if ($digit == 1) {
    #     $dir = 1-$dir;
    #   }
    #   if ($digit == 2) {
    #     $dir = 1-$dir;
    #   }
    #   if ($digit == 3) {
    #     $dir = $dir+2;
    #   }
    # }
    #
    # ### $dir
    # return $dir % 4;





    # works ...
    #
    # while (@digits && $digits[-1] == 3) {
    #   $state ^= 1;
    #   pop @digits;
    # }
    # # if (@digits) {
    # #   push @digits, $digits[-1];
    # # }
    #
    # while (@digits > 1) {
    #   my $digit = shift @digits;
    #   ### at: "state=$state  digit=$digit  dir=$dir"
    #
    #   if ($digit == 0) {
    #   }
    #   if ($digit == 1) {
    #     $state ^= 1;
    #   }
    #   if ($digit == 2) {
    #     $state ^= 1;
    #   }
    #   if ($digit == 3) {
    #     $state ^= 2;
    #   }
    # }
    #
    # ### $state
    # ### $digit
    # my $dir = $digits[0] // return $state^1;
    # if ($state & 1) {
    #   $dir = 1-$dir;
    # }
    # if ($state & 2) {
    #   $dir = $dir+2;
    # }
    # ### $dir
    #
    #
    # ### $dir
    # return $dir % 4;






    # my $digit = $digits[-1];
    # if ($digit == 0) {
    #   $dir = 0;
    # }
    # if ($digit == 1) {
    #   $dir = 2;
    # }
    # if ($digit == 2) {
    #   $dir = 1;
    # }
    # if ($digit == 3) {
    #   $dir = 1;
    # }
    # if (@digits & 1) {
    #   $dir = 1-$dir;
    # }
    # my $ret = $dir;
    #
    # while (@digits) {
    #   my $digit = shift @digits;
    #   if ($digit == 0) {
    #     $dir = 1-$dir;
    #     $ret = $dir;
    #   }
    #   if ($digit == 1) {
    #     $ret = $dir;
    #   }
    #   if ($digit == 2) {
    #     $ret = $dir;
    #   }
    #   if ($digit == 3) {
    #     $dir = $dir + 2;
    #   }
    # }
    # return $ret % 4;


    # $ret = 0;
    # while (($n & 3) == 3) {
    #   $n >>= 2;
    #   $ret ^= 1;
    # }
    #
    # my $digit = ($n & 3);
    # $n >>= 2;
    # if ($digit == 0) {
    # }
    # if ($digit == 1) {
    #   $ret++;
    # }
    # if ($digit == 2) {
    #   $ret += 2;
    # }
    # if ($digit == 3) {
    # }
    #
    # while ($n) {
    #   my $digit = ($n & 3);
    #   $n >>= 2;
    #
    #   if ($digit == 0) {
    #     $ret = 1-$ret;
    #   }
    #   if ($digit == 1) {
    #     $ret = -$ret;
    #     #        $ret = 1-$ret;
    #   }
    #   if ($digit == 2) {
    #     $ret = 1-$ret;
    #   }
    #   if ($digit == 3) {
    #     $ret = $ret + 2;
    #   }
    # }
    # return $ret % 4;
    #
    #
    #
    # if (($n & 3) == 3) {
    #   while (($n & 15) == 15) {
    #     $n >>= 4;
    #   }
    #   if (($n & 3) == 3) {
    #     $ret = 1;
    #   }
    #   $n >>= 2;
    # } elsif (($n & 3) == 1) {
    #   $ret = 0;
    #   $n >>= 2;
    # } elsif (($n & 3) == 2) {
    #   $ret = 2;
    #   $n >>= 2;
    # }
    #
    # while ($n) {
    #   if (($n & 3) == 0) {
    #     $ret ^= 1;
    #   }
    #   if (($n & 3) == 3) {
    #     $ret ^= 2;
    #   }
    #   $n >>= 2;
    # }
    # return $ret;
  }

  sub digits {
    my ($n) = @_;
    my @ret;
    while ($n) {
      unshift @ret, $n & 3;
      $n >>= 2;
    } ;  #  || @ret&1
    return @ret;
  }

  sub count_3s {
    my ($n) = @_;
    my $count = 0;
    while ($n) {
      $count += (($n & 3) == 3);
      $n >>= 2;
      $count += (($n & 3) == 3);
      $n >>= 2;
    }
    return $count;
  }
}


{
  my $path = Math::PlanePath::HilbertCurve->new;
  my @range = $path->rect_to_n_range (1,2, 2,4);
  ### @range
  exit 0;
}

{
  my $path = Math::PlanePath::HilbertCurve->new;

  sub want {
    my ($n) = @_;
    my ($x1,$y1) = $path->n_to_xy($n);
    my ($x2,$y2) = $path->n_to_xy($n+1);
    return ($x2-$x1, $y2-$y1);
  }

  sub try {
    my ($n) = @_;
    ### try(): $n

    while (($n & 15) == 15) {
      $n >>= 4;
    }

    my $pos = 0;
    my $mask = 16;
    while ($n >= $mask) {
      $pos += 4;
      $mask <<= 4;
    }
    ### $pos

    my $dx = 1;
    my $dy = 0;
    ### d initial: "$dx,$dy"

    while ($pos >= 0) {
      my $bits = ($n >> $pos) & 15;
      ### $bits

      if ($bits == 1
          || $bits == 2
          || $bits == 3
          || $bits == 4
          || $bits == 8
         ) {
        ($dx,$dy) = ($dy,$dx);
        ### d swap to: "$dx,$dy"

      } elsif ($bits == 2
               || $bits == 12
              ) {
        $dx = -$dx;
        $dy = -$dy;
        ### d invert: "$dx,$dy"

      } elsif ($bits == 2
               || $bits == 10
               || $bits == 11
               || $bits == 13
              ) {
        ($dx,$dy) = ($dy,$dx);
        $dx = -$dx;
        $dy = -$dy;
        ### d swap and invert: "$dx,$dy"

      } elsif ($bits == 0
               || $bits == 5
              ) {
        ### d unchanged

      }

      $pos -= 4;
    }

    return ($dx,$dy);
  }

  sub Wtry {
    my ($n) = @_;
    ### try(): $n

    my $pos = 0;
    my $mask = 16;
    while ($n >= $mask) {
      $pos += 4;
      $mask <<= 4;
    }
    ### $pos

    my $dx = 1;
    my $dy = 0;
    ### d initial: "$dx,$dy"

    while ($pos >= 0) {
      my $bits = ($n >> $pos) & 15;
      ### $bits

      if ($bits == 1
          || $bits == 3
          || $bits == 4
          || $bits == 8
         ) {
        ($dx,$dy) = ($dy,$dx);
        ### d swap to: "$dx,$dy"

      } elsif ($bits == 2
               || $bits == 12
              ) {
        $dx = -$dx;
        $dy = -$dy;
        ### d invert: "$dx,$dy"

      } elsif ($bits == 2
               || $bits == 6
               || $bits == 10
               || $bits == 11
               || $bits == 13
              ) {
        ($dx,$dy) = ($dy,$dx);
        $dx = -$dx;
        $dy = -$dy;
        ### d swap and invert: "$dx,$dy"

      } elsif ($bits == 0
               || $bits == 5
              ) {
        ### d unchanged

      }

      $pos -= 4;
    }

    return ($dx,$dy);
  }

  sub ZZtry {
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

    my $x = my $y = ($n * 0); # inherit
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

  foreach my $n (0 .. 256) {
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
}
