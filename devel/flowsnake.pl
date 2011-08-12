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

use 5.010;
use strict;
use warnings;
use Math::Libm 'M_PI', 'hypot';


{
  # xy_to_n
  require Math::PlanePath::Flowsnake;
  require Math::PlanePath::FlowsnakeCentres;
  my $path = Math::PlanePath::FlowsnakeCentres->new;
  my $y = 0;
  for (my $x = 6; $x >= -5; $x-=2) {
    $x -= ($x^$y)&1;
    my $n = $path->xy_to_n($x,$y);
    print "$x,$y   ",($n//'undef'),"\n";
  }
  exit 0;
}

{
  # modulo
  require Math::PlanePath::Flowsnake;
  my $path = Math::PlanePath::Flowsnake->new;
  for (my $n = 0; $n <= 49; $n++) {
    if (($n % 7) == 0) { print "\n"; }
    my ($x,$y) = $path->n_to_xy($n);
    my $c = $x + 2*$y;
    my $m = $c % 7;
    print "$n  $x,$y  $c  $m\n";
  }
  exit 0;
}
{
  require Math::PlanePath::Flowsnake;
  my $path = Math::PlanePath::Flowsnake->new;
  for (my $n = 0; $n <= 49; $n+=7) {
    my ($x,$y) = $path->n_to_xy($n);
    my ($rx,$ry) = ((3*$y + 5*$x) / 14,
                    (5*$y - $x) / 14);
    print "$n  $x,$y  $rx,$ry\n";
  }
  exit 0;
}
  
{
  # radius
  require Math::PlanePath::Flowsnake;
  my $path = Math::PlanePath::Flowsnake->new;
  my $prev_max = 1;
  for (my $level = 1; $level < 10; $level++) {
    print "level $level\n";

    my ($x2,$y2) = $path->n_to_xy(2 * 7**($level-1));
    my ($x3,$y3) = $path->n_to_xy(3 * 7**($level-1));
    my $cx = ($x2+$x3)/2;
    my $cy = ($y2+$y3)/2;
    my $max_hypot = 0;
    my $max_pos = '';
    foreach my $n (0 .. 7**$level - 1) {
      my ($x,$y) = $path->n_to_xy($n);
      my $h = ($x-$cx)**2 + 3*($y-$cy);
      if ($h > $max_hypot) {
        $max_hypot = $h;
        $max_pos = "$x,$y";
      }
    }
    my $factor = $max_hypot / $prev_max;
    $prev_max = $max_hypot;
    print "  cx=$cx,cy=$cy  max $max_hypot   at $max_pos  factor $factor\n";
  }
  exit 0;
}


{
  require Math::PlanePath::Flowsnake;
  my $path = Math::PlanePath::Flowsnake->new;
  my $prev_max = 1;
  for (my $level = 1; $level < 10; $level++) {
    my $n_start = 0;
    my $n_end = 7**$level - 1;
    my $min_hypot = $n_end;
    my $min_x = 0;
    my $min_y = 0;
    my $max_hypot = 0;
    my $max_pos = '';
    print "level $level\n";
    my ($xend,$yend) = $path->n_to_xy(7**($level-1));
    print "   end $xend,$yend\n";
    $yend *= sqrt(3);
    my $cx = -$yend;  # rotate +90
    my $cy = $xend;
    print "   rot90  $cx, $cy\n";
    # $cx *= sqrt(3/4) * .5;
    # $cy *= sqrt(3/4) * .5;
    $cx *= 1.5;
    $cy *= 1.5;
    print "   scale  $cx, $cy\n";
    $cx += $xend;
    $cy += $yend;
    print "   offset to  $cx, $cy\n";
    $cy /= sqrt(3);
    printf "  centre %.1f, %.1f\n", $cx,$cy;
    foreach my $n ($n_start .. $n_end) {
      my ($x,$y) = $path->n_to_xy($n);
      my $h = ($cx-$x)**2 + 3*($cy-$y)**2;

      if ($h > $max_hypot) {
        $max_hypot = $h;
        $max_pos = "$x,$y";
      }
      # if ($h < $min_hypot) {
      #   $min_hypot = $h;
      #   $min_x = $x;
      #   $min_y = $y;
      # }
    }
    # print "  min $min_hypot   at $min_x,$min_y\n";
    my $factor = $max_hypot / $prev_max;
    print "  max $max_hypot   at $max_pos  factor $factor\n";
    $prev_max = $max_hypot;
  }
  exit 0;
}

{
  # diameter
  require Math::PlanePath::Flowsnake;
  my $path = Math::PlanePath::Flowsnake->new;
  my $prev_max = 1;
  for (my $level = 1; $level < 10; $level++) {
    print "level $level\n";
    my $n_start = 0;
    my $n_end = 7**$level - 1;
    my ($xend,$yend) = $path->n_to_xy($n_end);
    print "   end $xend,$yend\n";
    my @x;
    my @y;
    foreach my $n ($n_start .. $n_end) {
      my ($x,$y) = $path->n_to_xy($n);
      push @x, $x;
      push @y, $y;
    }
    my $max_hypot = 0;
    my $max_pos = '';
    my ($cx,$cy);
    foreach my $i (0 .. $#x-1) {
      foreach my $j (1 .. $#x) {
        my $h = ($x[$i]-$x[$j])**2 + 3*($y[$i]-$y[$j]);
        if ($h > $max_hypot) {
          $max_hypot = $h;
          $max_pos = "$x[$i],$y[$i], $x[$j],$y[$j]";
          $cx = ($x[$i] + $x[$j]) / 2;
          $cy = ($y[$i] + $y[$j]) / 2;
        }
      }
    }
    my $factor = $max_hypot / $prev_max;
    print "  max $max_hypot   at $max_pos  factor $factor\n";
    $prev_max = $max_hypot;
  }

  exit 0;
}

{
  require Math::PlanePath::GosperIslands;
  my $path = Math::PlanePath::GosperIslands->new;
  foreach my $level (0 .. 20) {
    my $n_start = 3**($level+1) - 2;
    my $n_end = 3**($level+2) - 2 - 1;
    my ($prev_x) = $path->n_to_xy($n_start);
    foreach my $n ($n_start .. $n_end) {
      my ($x,$y) = $path->n_to_xy($n);

      # if ($y == 0 && $x > 0) {
      #   print "level $level  x=$x y=$y n=$n\n";
      # }

      if (($prev_x>0) != ($x>0) && $y > 0) {
        print "level $level  x=$x y=$y n=$n\n";
      }
      $prev_x = $x;
    }
    print "\n";
  }
  exit 0;
}



sub hij_to_xy {
  my ($h, $i, $j) = @_;
  return ($h*2 + $i - $j,
          $i+$j);
}

{
  # y<0 at n=8598  x=-79,y=-1
  require Math::PlanePath::Flowsnake;
  my $path = Math::PlanePath::Flowsnake->new;
  for (my $n = 3; ; $n++) {
    my ($x,$y) = $path->n_to_xy($n);
    if ($y == 0) {
      print "zero n=$n  $x,$y\n";
    }
    if ($y < 0) {
      print "yneg n=$n  $x,$y\n";
      exit 0;
    }
    # if ($y < 0 && $x >= 0) {
    #   print "yneg n=$n  $x,$y\n";
    #   exit 0;
    # }
  }
  exit 0;
}

{
  {
    my $sh = 1;
    my $si = 0;
    my $sj = 0;
    my $n = 1;
    foreach my $level (1 .. 20) {
      $n *= 7;
      ($sh, $si, $sj) = (2*$sh - $sj,
                         2*$si + $sh,
                         2*$sj + $si);
      my ($x, $y) = hij_to_xy($sh,$si,$sj);
      $n = sprintf ("%f",$n);
      print "$level $n  $sh,$si,$sj  $x,$y\n";
    }
  }
  exit 0;
}


our $level;

my $n = 0;
my $x = 0;
my $y = 0;

my %seen;
my @row;
my $x_offset = 8;
my $dir = 0;

sub step {
  $dir %= 6;
  print "$n  $x, $y   dir=$dir\n";
  my $key = "$x,$y";
  if (defined $seen{$key}) {
    print "repeat   $x, $y  from $seen{$key}\n";
  }
  $seen{"$x,$y"} = $n;
  if ($y >= 0) {
    $row[$y]->[$x+$x_offset] = $n;
  }

  if ($dir == 0) { $x += 2; }
  elsif ($dir == 1) { $x++, $y++; }
  elsif ($dir == 2) { $x--, $y++; }
  elsif ($dir == 3) { $x -= 2; }
  elsif ($dir == 4) { $x--, $y--; }
  elsif ($dir == 5) { $x++, $y--; }
  else { die; }
  $n++;
}

sub forward {
  if ($level == 1) {
    step ();
    return;
  }
  local $level = $level-1;
  forward(); $dir++;           # 0
  backward(); $dir += 2;       # 1
  backward(); $dir--;          # 2
  forward(); $dir -= 2;           # 3
  forward();                   # 4
  forward();  $dir--;                 # 5
  backward(); $dir++;          # 6
}

sub backward {
  my ($dir) = @_;
  if ($level == 1) {
    step ();
    return;
  }
  print "backward\n";
  local $level = $level-1;

  $dir += 2;
  forward();
  forward();
  $dir--;                 # 5
  forward();
  $dir--;                 # 5
  forward();
  $dir--;                 # 5
  backward();
  $dir--;                 # 5
  backward();
  $dir--;                 # 5
  forward();
  $dir--;                 # 5
}

$level = 3;
forward (2);


foreach my $y (reverse 0 .. $#row) {
  my $aref = $row[$y];
  foreach my $x (0 .. $#$aref) {
    printf ('%*s', 3, (defined $aref->[$x] ? $aref->[$x] : ''));
  }
  print "\n";
}
