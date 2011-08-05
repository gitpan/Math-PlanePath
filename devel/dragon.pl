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


{
  # Midpoint fracs
  require Math::PlanePath::MathImageDragonMidpoint;
  my $path = Math::PlanePath::MathImageDragonMidpoint->new;
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
  require Math::PlanePath::MathImageDragonRounded;
  my $path = Math::PlanePath::MathImageDragonRounded->new;
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
  require Math::PlanePath::MathImageDragonRounded;
  my $path = Math::PlanePath::MathImageDragonRounded->new;
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
  require Math::PlanePath::MathImageDragonRounded;
  my $path = Math::PlanePath::MathImageDragonRounded->new;
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
  require Math::PlanePath::MathImageDragonCurve;
  my $path = Math::PlanePath::MathImageDragonCurve->new;
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
  require Math::PlanePath::MathImageDragonCurve;
  my $path = Math::PlanePath::MathImageDragonCurve->new;
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
