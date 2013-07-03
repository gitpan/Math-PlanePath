#!/usr/bin/perl -w

# Copyright 2011, 2012, 2013 Kevin Ryde

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

use 5.006;
use strict;
use warnings;
use POSIX;
use List::Util 'min', 'max';
use Math::PlanePath::Base::Digits 'digit_split_lowtohigh';
use Math::PlanePath::ComplexMinus;
use lib 'xt';
use MyOEIS;

# uncomment this to run the ### lines
# use Smart::Comments;

{
  my @dir4_to_dx = (1,0,-1,0);
  my @dir4_to_dy = (0,1,0,-1);
  sub path_boundary_length {
    my ($path, $n_below) = @_;
    ### $n_below
    my $boundary = 0;
    my %seen;
    my @pending_x = (0);
    my @pending_y = (0);
    while (@pending_x) {
      my $x = pop @pending_x;
      my $y = pop @pending_y;
      next if $seen{$x}{$y};
      foreach my $i (0 .. $#dir4_to_dx) {
        my $ox = $x + $dir4_to_dx[$i];
        my $oy = $y + $dir4_to_dy[$i];
        ### consider: "$x,$y   to $ox,$oy"
        my $n = $path->xy_to_n($ox,$oy);
        if ($n >= $n_below) {
          ### outside ...
          $boundary++;
        } else {
          ### inside ...
          push @pending_x, $ox;
          push @pending_y, $oy;
        }
      }
      $seen{$x}{$y} = 1;
    }
    return $boundary;
  }

  # (2n-1      0   2n     ) (a)
  # (n^2-2n+2  0  (n-1)^2 ) (b)
  # (0         1   0      ) (c)
  #
  # inverse [ (n^2 - 2*n + 1)/(-n^2 - 1)       -2*n/(-n^2 - 1)   0]
  #         [ 0                               0                  1]
  #         [(-n^2 + 2*n - 2)/(-n^2 - 1)  (2*n - 1)/(-n^2 - 1)   0]
  #
  # c[k] = b[k-1]
  # a[k] = (2n-1)a[k-1] + 2n*c[k-1]
  #
  # m = [2*n-1,0,2*n; n^2-2*n+2,0,(n-1)^2; 0,1,0]
  # v = [n;n^2+1-n;1]
  # m^-1*v = [n ; 1; 1-n]
  # t=[0,0,0;0,0,0;1,1,1]
  # f=[0,1,0;0,0,1;1,0,0]
  # s=(t + f*t*m + f^2*t*m^2)
  # s*abc = l210
  # s*m*abc = r*l210
  # s*m*abc = r*s*abc
  # s*m = r*s
  # r = s*m*s^-1
  # r=s*m*s^-1 = [ 2*n-1,   n^2+1 - 2*n,   n^2+1]
  #              [1 0 0]
  #              [0 1 0]
  #
  #  (1  0  2) (  0    1  0)   r=1     initial (1) prev (1)
  #  (1  0  0) (  0    0  1)                   (1)      (1)
  #  (0  1  0) ( 1/2 -1/2 0)                   (1)      (0)
  # m=[1,0,2;1,0,0;0,1,0]
  #
  #  (3  0  4) (-1/5  4/5 0)   r=2     initial (2) prev -2+4*3 = 2
  #  (2  0  1) (  0    0  1)                   (3)             = 1
  #  (0  1  0) ( 2/5 -3/5 0)                   (1)             = -1
  # m=[3,0,4;2,0,1;0,1,0]
  # 20 21 22 23 24
  #       15 16 17 18 19
  #             10 11 12 13 14
  #                    5  6  7  8  9
  #                          0  1  2  3  4
  # 0 -> 4
  # 5 -> 12
  # 25 -> (5+8+5)*2 = 36
  # l2 = 2*(norm          # top
  #         + r*(norm-1)  # steps
  #         + norm)       # side
  #    = 2*(norm + r*norm - r + norm)
  #    = 2*(2*norm + r*norm - r)
  #    = 2*((r+2)*norm - r)
  #    = 2*((r+2)*norm - r-2 +2))
  #    = 2*((r+2)*norm - (r+2) +2))
  #    = 2*(r+2)*(norm-1) + 4

  my $r = 2;
  my $norm = $r*$r+1;

  sub boundary_by_recurrence {
    my ($k) = @_;

    # my $l2 = 2*$r**3 + 4*$r**2 + 4;
    my $l2 = 2*($norm-1)*($r+2) + 4;
    my $l1 = 2*$norm + 2;
    my $l0 = 4;

    foreach (1 .. $k) {
      ($l2,$l1,$l0) = ((2*$r-1)         * $l2
                       + ($norm - 2*$r) * $l1
                       + $norm          * $l0,

                       $l2, $l1);

      # ($l2,$l1,$l0) = ((2*$r-1)*$l2
      #                  + ($r**2+1 - 2*$r)*$l1
      #                  + ($r**2+1)*$l0,
      #
      #                  $l2, $l1);
    }
    return $l0;
  }

  sub abc_pow {
    my ($k) = @_;

    # my $a = 2*2;
    # my $b = 1*2;
    # my $c = -1*2;
    # my $a = $r*2;
    # my $b = ($norm-$r)*2;
    # my $c = 1*2;
    # my $a = 2 * $r / ($r*$r+1);
    # my $b = 2 * ($r*$r+1 - $r) / ($r*$r+1);
    # my $c = 2 * 1;

    my $a = $r;
    my $b = 1;
    my $c = (1-$r);

    foreach (1 .. $k) {
      ($a,$b,$c) = ((2*$r-1)*$a       + 0  + 2*$r*$c,
                    ($r*$r-2*$r+2)*$a + 0 + ($r-1)*($r-1)*$c,
                    0                 + $b);
    }
    return ($a,$b,$c);
  }
  sub boundary_by_pow {
    my ($k) = @_;
    my ($a,$b,$c) = abc_pow($k);
    return 2*($a+$b+$c);
  }

  my @values;
  my $path = Math::PlanePath::ComplexMinus->new (realpart => $r);
  my $prev_len = 1;
  my $prev_ratio = 1;
  foreach my $k (0 .. 30) {
    my $pow = $norm**$k;
    my $len = 0; #path_boundary_length($path,$pow);
    my $len_by_pow = boundary_by_pow($k);
    my $len_by_rec = boundary_by_recurrence($k);
    my $ratio = $pow / $len_by_pow;
    my $f = 2* log($len_by_pow / $prev_len) / log($norm);
    printf "%2d %s %s %s   %.6f\n", $k, $len, $len_by_pow, $len_by_rec, $f;
    push @values, $len_by_pow;
    $prev_len = $len_by_pow;
    $prev_ratio = $ratio;
  }
  print join(', ',@values),"\n";
  print MyOEIS->grep_for_values_aref(\@values);
  exit 0;
}

{
  # neighbours across 2^k blocks

  # counting all 4 directions, is boundary length
  # 2 * A003476 a(n) = a(n-1) + 2a(n-3).
  #                           1, 2, 3,  5,  9, 15, 25, 43,  73, 123, 209, 355,
  # A203175 nX2 arrays  1, 1, 2, 4, 6, 10, 18, 30, 50, 86, 146, 246, 418, 710,

  # 4,6,10,18,30,50,86,146,246,418,710,1202,2038,3458
  #
  # 30 = 18+2*6
  #

  my @dir4_to_dx = (1,0,-1,0);
  my @dir4_to_dy = (0,1,0,-1);
  my @dir8_to_dx = (1, 1, 0,-1, -1, -1,  0, 1);
  my @dir8_to_dy = (0, 1, 1, 1,  0, -1, -1,-1);

  my $path = Math::PlanePath::ComplexMinus->new;
  my @values;
  my $prev_count = 0;
  foreach my $k (0 .. 13) {
    my $pow = 2**$k;
    my $count = 0;
    foreach my $n (2 .. $pow-1) {
      my ($x,$y) = $path->n_to_xy($n);
      # foreach my $i (0 .. $#dir4_to_dx) {
      foreach my $i (0, 2) {
        my $n2 = $path->xy_to_n($x+$dir4_to_dx[$i],
                                $y+$dir4_to_dy[$i]);
        if (defined $n2 && $n2 >= $pow) {  # num boundary
          $count++;
          last;
        }
        # if (defined $n2 && $n2 >= $pow && $n2 < 2*$pow) {
        #   $count++;
        #   last;
        # }
      }
    }
    # my $value = ($count - $prev_count)/4;
    # my $value = $count/2;
    my $value = $count;

    printf "%2d %4d %10b\n", $k, $value, $value;
    push @values, $value;
    $prev_count = $count;
  }

  shift @values;
  shift @values;
  print join(',',@values),"\n";
  print MyOEIS->grep_for_values_aref(\@values);
  exit 0;
}

{
  # min/max rectangle
  #
  # repeat at dx,dy

  require Math::BaseCnv;
  my $xmin = 0;
  my $xmax = 0;
  my $ymin = 0;
  my $ymax = 0;
  my $dx = 1;
  my $dy = 0;
  my $realpart = 2;
  my $norm = $realpart*$realpart + 1;
  printf "level  xmin       xmax   xdiff   | ymin     ymax      ydiff\n";
  for (0 .. 22) {
    my $xminR = Math::BaseCnv::cnv($xmin,10,$norm);
    my $yminR = Math::BaseCnv::cnv($ymin,10,$norm);
    my $xmaxR = Math::BaseCnv::cnv($xmax,10,$norm);
    my $ymaxR = Math::BaseCnv::cnv($ymax,10,$norm);
    my $xdiff = $xmax - $xmin;
    my $ydiff = $ymax - $ymin;
    my $xdiffR = Math::BaseCnv::cnv($xdiff,10,$norm);
    my $ydiffR = Math::BaseCnv::cnv($ydiff,10,$norm);
    printf "%2d %11s %11s =%11s | %11s %11s =%11s\n",
      $_,
        $xminR,$xmaxR,$xdiffR,
          $yminR,$ymaxR,$ydiffR;

    $xmax = max ($xmax, $xmax + $dx*($norm-1));
    $ymax = max ($ymax, $ymax + $dy*($norm-1));
    $xmin = min ($xmin, $xmin + $dx*($norm-1));
    $ymin = min ($ymin, $ymin + $dy*($norm-1));

    ### assert: $xmin <= 0
    ### assert: $ymin <= 0
    ### assert: $xmax >= 0
    ### assert: $ymax >= 0

    # multiply i-r, ie. (dx,dy) = (dx + i*dy)*(i-$realpart)
    $dy = -$dy;
    ($dx,$dy) = ($dy - $realpart*$dx,
                 $dx + $realpart*$dy);
  }
  # print 3*$xmin/$len+.001," / 3\n";
  # print 6*$xmax/$len+.001," / 6\n";
  # print 3*$ymin/$len+.001," / 3\n";
  # print 3*$ymax/$len+.001," / 3\n";
  exit 0;

  sub to_bin {
    my ($n) = @_;
    return ($n < 0 ? '-' : '') . sprintf('%b', abs($n));
  }
}

{
  # min/max hypot for level
  $|=1;
  my $realpart = 2;
  my $norm = $realpart**2 + 1;
  my $path = Math::PlanePath::ComplexMinus->new (realpart => $realpart);
  my $prev_min = 1;
  my $prev_max = 1;
  for (my $level = 1; $level < 25; $level++) {
    my $n_start = $norm**($level-1);
    my $n_end = $norm**$level;

    my $min_hypot = POSIX::DBL_MAX();
    my $min_x = 0;
    my $min_y = 0;
    my $min_pos = '';

    my $max_hypot = 0;
    my $max_x = 0;
    my $max_y = 0;
    my $max_pos = '';

    print "level $level  n=$n_start .. $n_end\n";

    foreach my $n ($n_start .. $n_end) {
      my ($x,$y) = $path->n_to_xy($n);
      my $h = $x*$x + $y*$y;

      if ($h < $min_hypot) {
        $min_hypot = $h;
        $min_pos = "$x,$y";
      }
      if ($h > $max_hypot) {
        $max_hypot = $h;
        $max_pos = "$x,$y";
      }
    }
    # print "$min_hypot,";

    # print "  min $min_hypot   at $min_x,$min_y\n";
    # print "  max $max_hypot   at $max_x,$max_y\n";
    {
      my $factor = $min_hypot / $prev_min;
      print "  min r^2 $min_hypot 0b".sprintf('%b',$min_hypot)."   at $min_pos  factor $factor\n";
      print "  cf formula ", 2**($level-7), "\n";
    }
    # {
    #   my $factor = $max_hypot / $prev_max;
    #   print "  max r^2 $max_hypot 0b".sprintf('%b',$max_hypot)."   at $max_pos  factor $factor\n";
    # }
    $prev_min = $min_hypot;
    $prev_max = $max_hypot;
  }
  exit 0;
}

{
  # covered inner rect
  # depends on which coord extended first
  require Math::BaseCnv;
  $|=1;
  my $realpart = 1;
  my $norm = $realpart**2 + 1;
  my $path = Math::PlanePath::ComplexMinus->new (realpart => $realpart);
  my %seen;
  my $xmin = 0;
  my $xmax = 0;
  my $ymin = 0;
  my $ymax = 0;
  for (my $level = 1; $level < 25; $level++) {
    my $n_start = $norm**($level-1);
    my $n_end = $norm**$level - 1;

    foreach my $n ($n_start .. $n_end) {
      my ($x,$y) = $path->n_to_xy($n);
      $seen{"$x,$y"} = 1;
      $xmin = min ($xmin, $x);
      $xmax = max ($xmax, $x);
      $ymin = min ($ymin, $y);
      $ymax = max ($ymax, $y);
    }
    my $x1 = 0;
    my $y1 = 0;
    my $x2 = 0;
    my $y2 = 0;
    for (;;) {
      my $more = 0;
      {
        my $x = $x1-1;
        my $good = 1;
        foreach my $y ($y1 .. $y2) {
          if (! $seen{"$x,$y"}) {
            $good = 0;
            last;
          }
        }
        if ($good) {
          $more = 1;
          $x1 = $x;
        }
      }
      {
        my $x = $x2+1;
        my $good = 1;
        foreach my $y ($y1 .. $y2) {
          if (! $seen{"$x,$y"}) {
            $good = 0;
            last;
          }
        }
        if ($good) {
          $more = 1;
          $x2 = $x;
        }
      }
      {
        my $y = $y1-1;
        my $good = 1;
        foreach my $x ($x1 .. $x2) {
          if (! $seen{"$x,$y"}) {
            $good = 0;
            last;
          }
        }
        if ($good) {
          $more = 1;
          $y1 = $y;
        }
      }
      {
        my $y = $y2+1;
        my $good = 1;
        foreach my $x ($x1 .. $x2) {
          if (! $seen{"$x,$y"}) {
            $good = 0;
            last;
          }
        }
        if ($good) {
          $more = 1;
          $y2 = $y;
        }
      }
      last if ! $more;
    }
    printf "%2d  %10s %10s   %10s %10s\n",
      $level,
        Math::BaseCnv::cnv($x1,10,2),
            Math::BaseCnv::cnv($x2,10,2),
                Math::BaseCnv::cnv($y1,10,2),
                    Math::BaseCnv::cnv($y2,10,2);
  }
  exit 0;
}

{
  # n=2^k bits
  require Math::BaseCnv;
  my $path = Math::PlanePath::ComplexMinus->new;
  foreach my $i (0 .. 16) {
    my $n = 2**$i;
    my ($x,$y) = $path->n_to_xy($n);
    my $x2 = Math::BaseCnv::cnv($x,10,2);
    my $y2 = Math::BaseCnv::cnv($y,10,2);
    printf "%#7X %12s %12s\n", $n, $x2, $y2;
  }
  print "\n";

  # X axis bits
  require Math::BaseCnv;
  foreach my $x (0 .. 400) {
    my $n = $path->xy_to_n($x,0);
    my $w = int(log($n||1)/log(2)) + 2;
    my $n2 = Math::BaseCnv::cnv($n,10,2);
    print "x=$x n=$n = $n2\n";
    for (my $bit = 1; $bit <= $n; $bit <<= 1) {
      if ($n & $bit) {
        my ($x,$y) = $path->n_to_xy($bit);
        my $x2 = Math::BaseCnv::cnv($x,10,2);
        my $y2 = Math::BaseCnv::cnv($y,10,2);
        printf "  %#*X %*s %*s\n", $w, $bit, $w, $x2, $w, $y2;
      }
    }
  }
  print "\n";
  exit 0;
}

{
  # X axis generating
  # hex  1 any                X=0x1 or -1
  #      2 never
  #      C bits 4,8 together  X=0x2 or -2
  my @ns = (0, 1, 0xC, 0xD);
  my @xseen;
  foreach my $pos (1 .. 5) {
    push @ns, map {16*$_+0, 16*$_+1, 16*$_+0xC, 16*$_+0xD} @ns;
  }
  my $path = Math::PlanePath::ComplexMinus->new;
  require Set::IntSpan::Fast;
  my $set = Set::IntSpan::Fast->new;
  foreach my $n (@ns) {
    my ($x,$y) = $path->n_to_xy($n);
    $y == 0 or die "n=$n x=$x y=$y";
    $set->add($x);
  }
  print "ok $#ns\n";
  print "x span ",$set->as_string,"\n";
  print "x card ",$set->cardinality,"\n";
  exit 0;
}

{
  # n=2^k bits
  require Math::BaseCnv;
  my $path = Math::PlanePath::ComplexMinus->new;
  foreach my $i (0 .. 20) {
    my $n = 2**$i;
    my ($x,$y) = $path->n_to_xy($n);
    my $x2 = Math::BaseCnv::cnv($x,10,2);
    my $y2 = Math::BaseCnv::cnv($y,10,2);
    printf "%6X %20s %11s\n", $n, $x2, $y2;
  }
  print "\n";
  exit 0;
}

{
  # X axis
  require Math::BaseCnv;
  require Math::NumSeq::PlanePathN;
  my $seq = Math::NumSeq::PlanePathN->new (planepath=> 'ComplexMinus',
                                           line_type => 'X_axis');
  foreach my $i (0 .. 150) {
    my ($i,$value) = $seq->next;
    my $v2 = Math::BaseCnv::cnv($value,10,2);
    printf "%4d %20s\n", $value, $v2;
  }
  print "\n";
  exit 0;
}

{
  require Math::NumSeq::PlanePathDelta;
  my $seq = Math::NumSeq::PlanePathDelta->new (planepath=> 'ComplexMinus',
                                               delta_type => 'dX');
  foreach my $i (0 .. 50) {
    my ($i,$value) = $seq->next;
    print "$value,";
  }
  print "\n";
  exit 0;
}

{
  # max Dir4

  require Math::BaseCnv;

  print 4-atan2(2,1)/atan2(1,1)/2,"\n";

  require Math::NumSeq::PlanePathDelta;
  my $realpart = 3;
  my $radix = $realpart*$realpart + 1;
  my $seq = Math::NumSeq::PlanePathDelta->new (planepath => "ComplexPlus,realpart=$realpart",
                                               delta_type => 'Dir4');
  my $dx_seq = Math::NumSeq::PlanePathDelta->new (planepath => "ComplexPlus,realpart=$realpart",
                                                  delta_type => 'dX');
  my $dy_seq = Math::NumSeq::PlanePathDelta->new (planepath => "ComplexPlus,realpart=$realpart",
                                                  delta_type => 'dY');
  my $max = 0;
  for (1 .. 1000000) {
    my ($i, $value) = $seq->next;

  # foreach my $k (1 .. 1000000) {
  #   my $i = $radix ** (4*$k+3) - 1;
  #   my $value = $seq->ith($i);

    if ($value > $max) {
      my $dx = $dx_seq->ith($i);
      my $dy = $dy_seq->ith($i);
      my $ri = Math::BaseCnv::cnv($i,10,$radix);
      my $rdx = Math::BaseCnv::cnv($dx,10,$radix);
      my $rdy = Math::BaseCnv::cnv($dy,10,$radix);
      my $f = $dy && $dx/$dy;
      printf "%d %s %.5f  %s %s   %.3f\n", $i, $ri, $value, $rdx,$rdy, $f;
      $max = $value;
    }
  }

  exit 0;
}

{
  # innermost points coverage
  require Math::BaseCnv;
  foreach my $realpart (1 .. 20) {
    my $norm = $realpart**2 + 1;
    my $path = Math::PlanePath::ComplexMinus->new (realpart => $realpart);
    my $n_max = 0;
    my $show = sub {
      my ($x,$y) = @_;
      my $n = $path->xy_to_n($x,$y);
      print "$x,$y n=$n\n";
      if ($n > $n_max) {
        $n_max = $n;
      }
    };
    $show->(1,0);
    $show->(1,1);
    $show->(0,1);
    $show->(-1,1);
    $show->(-1,0);
    $show->(-1,-1);
    $show->(0,-1);
    $show->(1,-1);
    my $n_max_base = to_base($n_max,$norm);
    my $n_max_log = log($n_max)/log($norm);
    print "n_max $n_max  $n_max_base  $n_max_log\n";
    print "\n";
  }
  exit 0;

  sub to_base {
    my ($n, $radix) = @_;
    my $ret = '';
    do {
      my $digit = $n % $radix;
      $ret = "[$digit]$ret";
    } while ($n = int($n/$radix));
    return $ret;
  }
}


{
  require Math::PlanePath::ComplexPlus;
  require Math::BigInt;
  my $realpart = 10;
  my $norm = $realpart*$realpart + 1;
  ### $norm
  my $path = Math::PlanePath::ComplexPlus->new (realpart=>$realpart);
  my $prev_dist = 1;
  print sqrt($norm),"\n";
  foreach my $level (1 .. 10) {
    my $n = Math::BigInt->new($norm) ** $level - 1;
    my ($x,$y) = $path->n_to_xy($n);
    my $radians = atan2($y,$x);
    my $degrees = $radians / 3.141592 * 180;
    my $dist = sqrt($x*$x+$y*$y);
    my $f = $dist / $prev_dist;
    printf "%2d %.2f %.4f  %.2f\n",
      $level, $dist, $f, $degrees;
    $prev_dist = $dist;
  }
  exit 0;
}

{
  require Math::PlanePath::ComplexPlus;
  my $path = Math::PlanePath::ComplexPlus->new (realpart=>2);
  foreach my $i (0 .. 10) {
    {
      my $x = $i;
      my $y = 1;
      my $n = $path->xy_to_n($x,$y);
      if (! defined $n) { $n = 'undef'; }
      print "xy_to_n($x,$y) = $n\n";
    }
  }
  foreach my $i (0 .. 10) {
    {
      my $n = $i;
      my ($x,$y) = $path->n_to_xy($n);
      print "n_to_xy($n) = $x,$y\n";
    }
  }
  exit 0;
}

{
  my $count = 0;
  my $realpart = 5;
  my $norm = $realpart*$realpart+1;
  foreach my $x (-200 .. 200) {
    foreach my $y (-200 .. 200) {
      my $new_x = $x;
      my $neg_y = $x - $y*$realpart;
      my $digit = $neg_y % $norm;
      $new_x -= $digit;
      $neg_y -= $digit;

      next unless ($new_x*$realpart+$y)/$norm == $x;
      next unless -$neg_y/$norm == $y;

      print "$x,$y  digit=$digit\n";
      $count++;
    }
  }
  print "count $count\n";
  exit 0;
}
