#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

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
use POSIX ();

# uncomment this to run the ### lines
use Devel::Comments;

{
  # diatomic 0,1,1,2,1,3,2,3, 1,4,3,5,2,5,3,4, 1,5,4,7,3,8,5,7,2,7,5,8,3,7,4,5,1,6,5,9,4,11,7,10,3,11,8,13,5,12,7,9,2,9,7,12,5,13,8,11,3,10,7,11,4,9,5,6,1,7,6,11,5,14,9,13,4,15,11,18,7,17,
  require Math::PlanePath::RationalsTree;
  my $ayt = Math::PlanePath::RationalsTree->new(tree_type => 'AYT');

  foreach my $level (0 .. 3) {
    foreach my $n (2**$level .. 2**($level+1)-1) {
      my ($x,$y) = $ayt->n_to_xy($n);
      print "$x,";
    }
  }
  print "\n";

  my $prev_y = 1;
  foreach my $level (0 .. 5) {
    foreach my $n (reverse 2**$level .. 2**($level+1)-1) {
      my ($x,$y) = $ayt->n_to_xy($n);
      print "$n  $x $y\n";
      if ($x != $prev_y) {
        print "diff\n";
      }
      $prev_y = $y;
    }
  }
  exit 0;
}

{
  require Math::PlanePath::RationalsTree;
  my $path = Math::PlanePath::RationalsTree->new;
  $, = ' ';
  say $path->xy_to_n (9,8);
  say $path->xy_to_n (2,3);
  say $path->rect_to_n_range (9,8, 2,3);

  exit 0;
}

{
  require Math::PlanePath::RationalsTree;
  my $path = Math::PlanePath::RationalsTree->new;
  require Math::BigInt;
  # my ($n_lo,$n_hi) = $path->xy_to_n (1000,0, 1500,200);
  my $n = $path->xy_to_n (Math::BigInt->new(1000),1);
  ### $n
  ### n: "$n"

  require Math::NumSeq::All;
  my $seq = Math::NumSeq::All->new;
  my $pred = $seq->pred($n);
  ### $pred

  exit 0;
}

{
  require Math::PlanePath::RationalsTree;
  my $cw = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
  my $drib = Math::PlanePath::RationalsTree->new(tree_type => 'Drib');

  my $level = 5;
  foreach my $an (2**$level .. 2**($level+1)-1) {
    my ($ax,$ay) = $cw->n_to_xy($an);
    my $bn = $drib->xy_to_n($ax,$ay);
    my ($z,$c) = cw_to_drib($an);
    my ($t,$u) = drib_to_cw($bn);
    printf "%5s  %b %b   %b(%b)%s    %b(%b)%s\n",
      "$ax/$ay", $an, $bn,
      $z, $c, ($z == $bn ? " eq" : ""),
      $t, $u, ($t == $an ? " eq" : "");
  }
  exit 0;

  sub cw_to_drib {
    my ($n) = @_;
    for (my $bit = 2; $bit <= (1 << ($level-1)); $bit <<= 2) {  # low to high
      $n ^= $bit;
    }
    return $n,0;
  }
  sub drib_to_cw {
    my ($n) = @_;
    for (my $bit = 2; $bit <= (1 << ($level-1)); $bit <<= 2) {  # low to high
      $n ^= $bit;
    }
    return $n,0;
  }
}

{
  require Math::PlanePath::RationalsTree;
  my $sb = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
  my $bird = Math::PlanePath::RationalsTree->new(tree_type => 'Bird');

  my $level = 5;
  foreach my $an (2**$level .. 2**($level+1)-1) {
    my ($ax,$ay) = $sb->n_to_xy($an);
    my $bn = $bird->xy_to_n($ax,$ay);
    my ($z,$c) = sb_to_bird($an);
    my ($t,$u) = bird_to_sb($bn);
    printf "%5s  %b %b   %b(%b)%s    %b(%b)%s\n",
      "$ax/$ay", $an, $bn,
      $z, $c, ($z == $bn ? " eq" : ""),
      $t, $u, ($t == $an ? " eq" : "");
  }
  exit 0;

  sub sb_to_bird {
    my ($n) = @_;
    for (my $bit = (1 << ($level-1)); $bit > 0; $bit >>= 1) {   # high to low
      $bit >>= 1;
      $n ^= $bit;
    }
    return $n,0;
  }
  sub bird_to_sb {
    my ($n) = @_;
    for (my $bit = (1 << ($level-1)); $bit > 0; $bit >>= 1) {   # high to low
      $bit >>= 1;
      $n ^= $bit;
    }
    return $n,0;
  }

  sub ayt_to_bird {
    my ($a) = @_;
    ### bird_to_ayt(): sprintf "%b", $a
    my $z = 0;
    my $flip = 1;
    $a = _reverse($a);
    for (my $bit = 1; $bit <= (1 << ($level-1)); $bit <<= 1) {  # low to high
      ### a bit: ($a & $bit)
      ### $flip
      if ($a & $bit) {
        if (! $flip) {
          $z |= $bit;
        }
      } else {
        $flip ^= 1;
        if ($flip) {
          $z |= $bit;
        }
      }
      ### z now: sprintf "%b", $z
      ### flip now: $flip
    }
    $z += (1 << $level);
    $a &= (1 << $level) - 1;
    return $z,0;
  }

  no Devel::Comments;

  sub bird_to_ayt {
    my ($b) = @_;
    $b = _reverse($b);
    $b &= (1 << $level) - 1;
    my $t = 0;
    my $flip = 1;
    for (my $bit = (1 << ($level-1)); $bit > 0; $bit >>= 1) {   # high to low
      if ($b & $bit) {
        if ($flip) {
          $t |= $bit;
        }
        $flip ^= 1;
      } else {
        if (! $flip) {
          $t |= $bit;
        }
      }
      # if ($flip) { $t ^= $bit; }
    }
    if (!$flip) { $t = ~$t; }
    $t &= (1 << $level) - 1;
    $t += (1 << $level);
    return ($t,0); # $b);
  }

  sub _reverse {
    my ($n) = @_;
    my $rev = 1;
    while ($n > 1) {
      $rev = 2*$rev + ($n % 2);
      $n = int($n/2);
    }
    return $rev;
  }
}

{
  require Math::PlanePath::RationalsTree;
  my $cw = Math::PlanePath::RationalsTree->new(tree_type => 'CW');
  my $ayt = Math::PlanePath::RationalsTree->new (tree_type => 'AYT');

  my $level = 6;
  foreach my $cn (2**$level .. 2**($level+1)-1) {
    my ($cx,$cy) = $cw->n_to_xy($cn);
    my $an = $ayt->xy_to_n($cx,$cy);
    my ($z,$c) = cw_to_ayt($cn);
    my ($t,$u) = ayt_to_cw($an);
    printf "%5s  %b %b   %b(%b)%s    %b(%b)%s\n",
      "$cx/$cy", $cn, $an,
        $z, $c, ($z == $an ? " eq" : ""),
          $t, $u, ($t == $cn ? " eq" : "");
  }
  exit 0;

  sub cw_to_ayt {
    my ($c) = @_;
    my $z = 0;
    my $flip = 0;
    for (my $bit = 1; $bit <= (1 << ($level-1)); $bit <<= 1) {  # low to high
      if ($flip) { $c ^= $bit; }
      if ($c & $bit) {

      } else {
        $z |= $bit;
        $flip ^= 1;
      }
    }
    $z += (1 << $level);
    $c &= (1 << $level) - 1;
    return $z,0;
  }

  sub ayt_to_cw {
    my ($a) = @_;
    $a &= (1 << $level) - 1;
    my $t = 0;
    my $flip = 0;
    for (my $bit = (1 << ($level-1)); $bit > 0; $bit >>= 1) {   # high to low
      if ($a & $bit) {
        $a ^= $bit;
        $t |= $bit;
        $flip ^= 1;
      } else {
      }
      if ($flip) { $t ^= $bit; }
    }
    if (!$flip) { $t = ~$t; }
    $t &= (1 << $level) - 1;
    $t += (1 << $level);
    return ($t,$a);
  }
}

{
  require Math::PlanePath::RationalsTree;
  my $path = Math::PlanePath::RationalsTree->new
    (
     tree_type => 'AYT',
     tree_type => 'CW',
     tree_type => 'SB',
    );

  foreach my $y (reverse 1 .. 10) {
    foreach my $x (1 .. 10) {
      my $n = $path->xy_to_n($x,$y);
      if (! defined $n) { $n = '' }
      printf (" %4s", $n);
    }
    print "\n";
  }
  exit 0;
}

{
  require Math::PlanePath::RationalsTree;
  my $path = Math::PlanePath::RationalsTree->new
    (
     tree_type => 'AYT',
     tree_type => 'CW',
     tree_type => 'SB',
    );

  foreach my $y (2 .. 10) {
    my $prev = 0;
    foreach my $x (1 .. 100) {
      my $n = $path->xy_to_n($x,$y) || next;
      if ($n < $prev) {
        print "not monotonic at X=$x,Y=$y n=$n prev=$prev\n";
      }
      $prev = $n;
    }
  }
  exit 0;
}


{
  require Math::PlanePath::RationalsTree;
  my $path = Math::PlanePath::RationalsTree->new
    (
     tree_type => 'AYT',
     tree_type => 'CW',
     tree_type => 'SB',
    );

  my $non_monotonic = '';
  foreach my $level (0 .. 4) {
    my $nstart = 2**$level;
    my $nend = 2**($level+1)-1;
    my $prev_x = 1;
    my $prev_y = 0;
    foreach my $n ($nstart .. $nend) {
      if ($n != $nstart) { print " "; }
      my ($x,$y) = $path->n_to_xy($n);
      print "$y/$x";
      unless (frac_lt($prev_y,$prev_x, $y,$x)) {
        $non_monotonic ||= "at $y/$x";
      }
      $prev_x = $x;
      $prev_y = $y;
    }
    print "\n";
    print " non-monotonic $non_monotonic\n";
  }
  exit 0;
}

sub frac_lt {
  my ($p1,$q1, $p2,$q2) = @_;
  return ($p1*$q2 < $p2*$q1);
}
