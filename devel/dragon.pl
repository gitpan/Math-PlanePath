#!/usr/bin/perl -w

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

use 5.006;
use strict;
use warnings;
use Math::Libm 'M_PI', 'hypot';

# uncomment this to run the ### lines
#use Smart::Comments;



{
  # doublings
  require Math::PlanePath::DragonCurve;
  require Math::BaseCnv;
  my $path = Math::PlanePath::DragonCurve->new;
  my %seen;
  for (my $n = 0; $n < 2000; $n++) {
    my ($x,$y) = $path->n_to_xy($n);
    my $key = "$x,$y";
    push @{$seen{$key}}, $n;
    if (@{$seen{$key}} == 2) {
      my @v2;
      my $aref = delete $seen{$key};
      foreach my $v (@$aref) {
        my $v2 = Math::BaseCnv::cnv($v,10,2);
        push @v2, $v2;
        printf "%4s %12s\n", $v, $v2;
      }
      my $lenmatch = 0;
      foreach my $i (1 .. length($v2[0])) {
        my $want = substr ($v2[0], -$i);
        if ($v2[1] =~ /$want$/) {
          next;
        } else {
          $lenmatch = $i-1;
          last;
          last;
        }
      }
      my $zeros = ($v2[0] =~ /(0*)$/ && $1);
      my $lenzeros = length($zeros);
      my $same = ($lenmatch == $lenzeros+2 ? "same" : "diff");
      print "low same $lenmatch zeros $lenzeros   $same\n";

      my $new = $aref->[0];
      my $first_bit = my $bit = 2 * 2**$lenzeros;
      my $change = 0;
      while ($bit <= 2*$aref->[0]) {
        ### $bit
        ### $change
        if ($change) {
          $new ^= $bit;
          $change = ! ($aref->[0] & $bit);
        } else {
          $change = ($aref->[0] & $bit);
        }
        $bit *= 2;
      }
      my $new2 = Math::BaseCnv::cnv($new,10,2);
      if ($new != $aref->[1]) {
        print "flip wrong first $first_bit last $bit to $new $new2\n";
      }
      print "\n";
    }
  }
  exit 0;
}

{
  # turn
  require Math::PlanePath::DragonCurve;
  my $path = Math::PlanePath::DragonCurve->new;

   my $n = $path->n_start;
  my ($n0_x, $n0_y) = $path->n_to_xy ($n);
  $n++;
  my ($prev_x, $prev_y) = $path->n_to_xy ($n);
  my ($prev_dx, $prev_dy) = ($prev_x - $n0_x, $prev_y - $n0_y);
  $n++;

  my $pow = 4;
  for ( ; $n < 128; $n++) {
    my ($x, $y) = $path->n_to_xy ($n);
    my $dx = ($x - $prev_x);
    my $dy = ($y - $prev_y);
    my $turn;
    if ($prev_dx) {
      if ($dy == $prev_dx) {
        $turn = 0;  # left
      } else {
        $turn = 1;  # right
      }
    } else {
      if ($dx == $prev_dy) {
        $turn = 1;  # right
      } else {
        $turn = 0;  # left
      }
    }
    ($prev_dx,$prev_dy) = ($dx,$dy);
    ($prev_x,$prev_y) = ($x,$y);

    print "$turn";
    if ($n-1 == $pow) {
      $pow *= 2;
      print "\n";
    }
  }
  print "\n";
  exit 0;
}

{
  # turn
  require Math::PlanePath::DragonCurve;
  my $path = Math::PlanePath::DragonCurve->new;

  my $n = 0;
  my ($n0_x, $n0_y) = $path->n_to_xy ($n);
  $n++;
  my ($prev_x, $prev_y) = $path->n_to_xy ($n);
  my ($prev_dx, $prev_dy) = ($prev_x - $n0_x, $prev_y - $n0_y);
  $n++;

  for ( ; $n < 40; $n++) {
    my ($x, $y) = $path->n_to_xy ($n);
    my $dx = ($x - $prev_x);
    my $dy = ($y - $prev_y);

    my $turn;
    if ($prev_dx) {
      if ($dy == $prev_dx) {
        $turn = 0;  # left
      } else {
        $turn = 1;  # right
      }
    } else {
      if ($dx == $prev_dy) {
        $turn = 1;  # right
      } else {
        $turn = 0;  # left
      }
    }
    ### $n
    ### $prev_dx
    ### $prev_dy
    ### $dx
    ### $dy
    # ### is: "$got[-1]   at idx $#got"

    ($prev_dx,$prev_dy) = ($dx,$dy);
    ($prev_x,$prev_y) = ($x,$y);

    my $zero = bit_above_lowest_zero($n-1);
    my $one  = bit_above_lowest_one($n-1);
    print "$n $turn   $one $zero\n";
    # if ($turn != $bit) {
    #   die "n=$n got $turn bit $bit\n";
    # }
  }
  print "n=$n ok\n";

  sub bit_above_lowest_zero {
    my ($n) = @_;
    for (;;) {
      if (($n % 2) == 0) {
        last;
      }
    $n = int($n/2);
    }
    $n = int($n/2);
    return ($n % 2);
  }
  sub bit_above_lowest_one {
    my ($n) = @_;
    for (;;) {
      if (! $n || ($n % 2) != 0) {
        last;
      }
      $n = int($n/2);
    }
    $n = int($n/2);
    return ($n % 2);
  }

  exit 0;
}

{
  # BigFloat log()
  use Math::BigFloat;
  my $b = Math::BigFloat->new(3)**64;
  my $log = log($b);
  my $log3 = $log/log(3);
  # $b->blog(undef,100);
  print "$b\n$log\n$log3\n";
  exit 0;
}
{
  # BigInt log()
  use Math::BigInt;
  use Math::BigFloat;
  my $b = Math::BigInt->new(1025);
  my $log = log($b);
  $b->blog(undef,100);
  print "$b $log\n";
  exit 0;
}

{
  require Image::Base::Text;
  my $width = 132;
  my $height = 50;
  my $ox = $width/2;
  my $oy = $height/2;
  my $image = Image::Base::Text->new (-width => $width, -height => $height);
  require Math::PlanePath::DragonCurve;
  my $path = Math::PlanePath::DragonCurve->new;
  my $store = sub {
    my ($x,$y,$c) = @_;
    $x *= 2;
    $x += $ox;
    $y += $oy;
    if ($x >= 0 && $y >= 0 && $x < $width && $y < $height) {
      my $o = $image->xy($x,$y);
      # if (defined $o && $o ne ' ' && $o ne $c) {
      #   $c = '*';
      # }
      $image->xy($x,$y,$c);
    } else {
      die "$x,$y";
    }
  };
  my ($x,$y);
  for my $n (0 .. 2**9) {
    ($x,$y) = $path->n_to_xy($n);
    $y = -$y;
    $store->($x,$y,'*');
  }
  $store->($x,$y,'+');
  $store->(0,0,'+');
  $image->save('/dev/stdout');
  exit 0;
}

{
  # Midpoint fracs
  require Math::PlanePath::DragonMidpoint;
  my $path = Math::PlanePath::DragonMidpoint->new;
  for my $n (0 .. 64) {
    my $frac = .125;
    my ($x1,$y1) = $path->n_to_xy($n);
    my ($x2,$y2) = $path->n_to_xy($n+1);
    my ($x,$y) = $path->n_to_xy($n+$frac);
    my $dx = $x2-$x1;
    my $dy = $y2-$y1;
    my $xm = $x1 + $frac*$dx;
    my $ym = $y1 + $frac*$dy;
    my $wrong = '';
    if ($x != $xm) {
      $wrong .= " X";
    }
    if ($y != $ym) {
      $wrong .= " Y";
    }
    print "$n   $dx,$dy    $x, $y  want $xm, $ym     $wrong\n"
  }
  exit 0;
}

{
  # min/max for level
  require Math::PlanePath::DragonRounded;
  my $path = Math::PlanePath::DragonRounded->new;
  my $prev_min = 1;
  my $prev_max = 1;
  for (my $level = 1; $level < 25; $level++) {
    my $n_start = 2**($level-1);
    my $n_end = 2**$level;

    my $min_hypot = 128*$n_end*$n_end;
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
    # print "  min $min_hypot   at $min_x,$min_y\n";
    # print "  max $max_hypot   at $max_x,$max_y\n";
    {
      my $factor = $min_hypot / $prev_min;
      print "  min r^2 $min_hypot 0b".sprintf('%b',$min_hypot)."   at $min_pos  factor $factor\n";
    }
    {
      my $factor = $max_hypot / $prev_max;
      print "  max r^2 $max_hypot 0b".sprintf('%b',$max_hypot)."   at $max_pos  factor $factor\n";
    }
    $prev_min = $min_hypot;
    $prev_max = $max_hypot;
  }
  exit 0;
}

{
  # points N=2^level
  require Math::PlanePath::DragonRounded;
  my $path = Math::PlanePath::DragonRounded->new;
  for my $n (0 .. 50) {
    my ($x,$y) = $path->n_to_xy($n);
    my ($x2,$y2) = $path->n_to_xy($n+1);
    my $dx = $x2 - $x;
    my $dy = $y2 - $y;

    my ($xm,$ym) = $path->n_to_xy($n+.5);

    # my $dir = 0;
    # for (my $bit = 1; ; ) {
    #   $dir += ((($n ^ ($n>>1)) & $bit) != 0);
    #   $bit <<= 1;
    #   last if $bit > $n;
    #   # $dir += 1;
    # }
    # $dir %= 4;
    $x += $dx/2;
    $y += $dy/2;
    print "$n  $x,$y   $xm,$ym\n";
  }
  exit 0;
}

{
  # reverse checking
  require Math::PlanePath::DragonRounded;
  my $path = Math::PlanePath::DragonRounded->new;
  for my $n (1 .. 50000) {
    my ($x,$y) = $path->n_to_xy($n);
    my $rev = $path->xy_to_n($x,$y);
    if (! defined $rev || $rev != $n) {
      if (! defined $rev) { $rev = 'undef'; }
      print "$n  $x,$y   $rev\n";
    }
  }
  exit 0;
}

{
  require Image::Base::Text;
  my $width = 78;
  my $height = 40;
  my $ox = $width/2;
  my $oy = $height/2;
  my $image = Image::Base::Text->new (-width => $width, -height => $height);
  require Math::PlanePath::DragonCurve;
  my $path = Math::PlanePath::DragonCurve->new;
  my $store = sub {
    my ($x,$y,$c) = @_;
    $x *= 2;
    $x += $ox;
    $y += $oy;
    if ($x >= 0 && $y >= 0 && $x < $width && $y < $height) {
      my $o = $image->xy($x,$y);
      if (defined $o && $o ne ' ' && $o ne $c) {
        $c = '.';
      }
      $image->xy($x,$y,$c);
    }
  };
  for my $n (0 .. 16*256) {
    my ($x,$y) = $path->n_to_xy($n);
    $y = -$y;
    {
      $store->($x,$y,'a');
    }
    {
      $store->(-$y,$x,'b');
    }
    {
      $store->(-$x,-$y,'c');
    }
    {
      $store->($y,-$x,'d');
    }
  }
  $image->xy($ox,$oy,'+');
  $image->save('/dev/stdout');
  exit 0;
}

{
  # points N=2^level
  require Math::PlanePath::DragonCurve;
  my $path = Math::PlanePath::DragonCurve->new;
  for my $level (0 .. 50) {
    my $n = 2**$level;
    my ($x,$y) = $path->n_to_xy($n);
    print "$level  $n  $x,$y\n";
  }
  exit 0;
}

{
  # sx,sy
  my $sx = 1;
  my $sy = 0;
  for my $level (0 .. 50) {
    print "$level  $sx,$sy\n";
    ($sx,$sy) = ($sx - $sy,
                 $sy + $sx);
  }
  exit 0;
}
