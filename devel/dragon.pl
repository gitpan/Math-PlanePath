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
  require Math::PlanePath::MathImageDragonCurve;
  my $path = Math::PlanePath::MathImageDragonCurve->new;
  my $prev_min = 1;
  for (my $level = 1; $level < 25; $level++) {
    my $n_start = 2**($level-1);
    my $n_end = 2**$level;

    my $min_hypot = 128*$n_end*$n_end;
    my $min_x = 0;
    my $min_y = 0;
    my $min_pos = '';
    print "level $level  n=$n_start .. $n_end\n";

    # my ($xend,$yend) = $path->n_to_xy($n_end);
    # print "   end $xend,$yend\n";

    my $cx = 0;
    my $cy = 0;
    # my $cx = -$yend;  # rotate +90
    # my $cy = $xend;
    # print "   rot90  $cx, $cy\n";
    # $cx *= 1.5;
    # $cy *= 1.5;
    # print "   scale  $cx, $cy\n";
    # $cx += $xend;
    # $cy += $yend;
    # print "   offset to  $cx, $cy\n";
    # printf "  centre %.1f, %.1f\n", $cx,$cy;

    foreach my $n ($n_start .. $n_end) {
      my ($x,$y) = $path->n_to_xy($n);
      my $h = ($cx-$x)**2 + ($cy-$y)**2;

      if ($h < $min_hypot) {
        $min_hypot = $h;
        $min_pos = "$x,$y";
      }
    }
    # print "  min $min_hypot   at $min_x,$min_y\n";
    my $factor = $min_hypot / $prev_min;
    print "  min $min_hypot 0b".sprintf('%b',$min_hypot)."   at $min_pos  factor $factor\n";
    $prev_min = $min_hypot;
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
