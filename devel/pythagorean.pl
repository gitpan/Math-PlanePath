#!/usr/bin/perl -w

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

use 5.010;
use strict;
use warnings;
use Math::Matrix;
use List::Util 'min', 'max';
use Math::Libm 'hypot';
use Math::PlanePath::PythagoreanTree;
use Math::PlanePath::Base::Digits
  'round_down_pow',
  'digit_split_lowtohigh';

# uncomment this to run the ### lines
use Smart::Comments;

{
  # P,Q by rows
  require Math::BaseCnv;
  require Math::PlanePath::PythagoreanTree;
  my $path = Math::PlanePath::PythagoreanTree->new (coordinates => 'PQ');
  my $fb = Math::PlanePath::PythagoreanTree->new (coordinates => 'PQ',
                                                  tree_type => 'FB');

  my $level = 8;
  my $prev_depth = -1;
  for (my $n = $path->n_start; ; $n++) {
    my $depth = $path->tree_n_to_depth($n);
    last if $depth > 4;
    if ($depth != $prev_depth) {
      print "\n";
      $prev_depth = $depth;
    }
    my ($x,$y) = $path->n_to_xy($n);
    printf " %2d/%-2d", $x,$y;

    my ($fx,$fy) = $fb->n_to_xy($n);
    printf " %2d/%-2d", $fx,$fy;

    my $fn = $path->xy_to_n($fx,$fy);
    print "  ",n_to_treedigits_str($n);
    print "  ",n_to_treedigits_str($fn);
    print "\n";
  }
  exit 0;
}

{
  require Math::BigInt::Lite;
  my $x = Math::BigInt::Lite->new(3);
  my $y = Math::BigInt::Lite->new(4);
  Math::PlanePath::PythagoreanTree::_ab_to_pq($x,$y);
  exit 0;
}
{
  require Math::BigInt::Lite;
  my $x = Math::BigInt::Lite->new(3);
  my $low = $x & 1;
  ### $low
  exit 0;
}
{
  require Math::BigInt::Lite;
  my $x = Math::BigInt::Lite->new(3);
  my $y = Math::BigInt::Lite->new(4);
  ### $x
  ### $y
  my ($a, $b) = ($x,$y);
  ### _ab_to_pq(): "A=$a, B=$b"

  unless ($a >= 3 && $b >= 4 && ($a % 2) && !($b % 2)) {
    ### don't have A odd, B even ...
    return;
  }

  # This used to be $c=hypot($a,$b) and check $c==int($c), but libm hypot()
  # on Darwin 8.11.0 is somehow a couple of bits off being an integer, for
  # example hypot(57,176)==185 but a couple of bits out so $c!=int($c).
  # Would have thought hypot() ought to be exact on integer inputs and a
  # perfect square sum :-(.  Check for a perfect square by multiplying back
  # instead.
  #
  my $c;
  {
    my $csquared = $a*$a + $b*$b;
    $c = int(sqrt($csquared));
    ### $csquared
    ### $c
    unless ($c*$c == $csquared) {
      return;
    }
  }
  exit 0;
}

{
  require Math::BigInt::Lite;
  my $x = Math::BigInt::Lite->new(3);
  my $y = Math::BigInt::Lite->new(4);
  ### $x
  ### $y

  # my $csquared = $x*$x + $y*$y;
  # my $c = int(sqrt($csquared));
  # ### $c

  # my $mod = $x%2;
  # $mod = $y%2;
  my $eq = ($x*$x == $y*$y);
  ### $eq

  # my $x = 3;
  # my $y = 4;
  # $x = Math::BigInt::Lite->new($x);
  # $y = Math::BigInt::Lite->new($y);

  # $mod = $x%2;
  # $mod = $y%2;
  unless ($x >= 3 && $y >= 4 && ($x % 2) && !($y % 2)) {
    ### don't have A odd, B even ...
    die;
  }

  # {
  #   my $eq = ($c*$c == $csquared);
  #   ### $eq
  # }


  exit 0;
}

{
  # X/Y list
  require Math::PlanePath::PythagoreanTree;
  my $path = Math::PlanePath::PythagoreanTree->new
    (
     # tree_type => 'FB',
     # tree_type => 'UAD',
     # coordinates => 'AB',
     coordinates => 'PQ',
    );
  my $n = $path->n_start;
  foreach my $level (0 .. 4) {
    foreach (1 .. 3**$level) {
      my ($x,$y) = $path->n_to_xy($n++);
      my $flag = '';
      if ($x <= $y) {
        $flag = '  ***';
      }
      print "$x / $y$flag\n";
    }
    print "\n";
  }
  exit 0;
}

{
  # graphical N values
  require Math::PlanePath::PythagoreanTree;
  my $path = Math::PlanePath::PythagoreanTree->new
    (
     # tree_type => 'FB',
      tree_type => 'UAD',
     # coordinates => 'AB',
     coordinates => 'PQ',
    );
  my @rows;
  foreach my $n (1 .. 18) {
    my ($x,$y) = $path->n_to_xy($n);
    $y /= 3;
    print "$x,$y\n";
    $rows[$y] ||= ' 'x1000;
    substr($rows[$y],$x,length($n)) = $n;
  }
  for (my $y = $#rows; $y >= 0; $y--) {
    $rows[$y] ||= '';
    $rows[$y] =~ s/ +$//;
    print $rows[$y],"\n";
  }
  exit 0;
}

{
  # P,Q continued fraction quotients
  require Math::BaseCnv;
  require Math::ContinuedFraction;
  require Math::PlanePath::PythagoreanTree;
  my $path = Math::PlanePath::PythagoreanTree->new (coordinates => 'PQ');

  my $level = 8;
  foreach my $n (1 .. 3**$level) {
    my ($x,$y) = $path->n_to_xy($n);
    my $cfrac = Math::ContinuedFraction->from_ratio($x,$y);
    my $cfrac_str = $cfrac->to_ascii;
    # my $nbits = Math::BaseCnv::cnv($n,10,3);
    my $nbits = n_to_treedigits_str($n);
    printf "%3d %7s %2d/%-2d  %s\n", $n, $nbits, $x,$y, $cfrac_str;
  }
  exit 0;

  sub n_to_treedigits_str {
    my ($n) = @_;
    return "~".join('',n_to_treedigits($n));
  }
  sub n_to_treedigits {
    my ($n) = @_;
    my ($len, $level) = round_down_pow (2*$n-1, 3);
    my @digits = digit_split_lowtohigh ($n - ($len+1)/2,  3);
    $#digits = $level-1;   # pad to $level with undefs
    foreach (@digits) { $_ ||= 0 }
    return @digits;
  }
}
{
  require Math::PlanePath::PythagoreanTree;
  my $path = Math::PlanePath::PythagoreanTree->new (coordinates => 'PQ');
  require Math::BigInt;
  # my ($n_lo,$n_hi) = $path->rect_to_n_range (1000,0, 1500,200);
  my ($n_lo,$n_hi) = $path->rect_to_n_range (Math::BigInt->new(1000),0, 1500,200);
  ### $n_hi
  ### n_hi: "$n_hi"
  exit 0;
}

{
  require Math::PlanePath::PythagoreanTree;
#   my $path = Math::PlanePath::PythagoreanTree->new
#     (
#      # tree_type => 'FB',
#      tree_type => 'UAD',
#      coordinates => 'AB',
#     );
#   my ($x,$y) = $path->n_to_xy(1121);
# #  exit 0;
  foreach my $k (1 .. 10) {
    print 3 * 2**$k + 1,"\n";
    print 2**($k+2)+1,"\n";
  }

  sub minpos {
    my $min = $_[0];
    my $pos = 0;
    foreach my $i (1 .. $#_) {
      if ($_[$i] < $min) {
        $min = $_[$i];
        $pos = 1;
      }
    }
    return $pos;
  }

  require Math::BaseCnv;
  require Math::PlanePath::PythagoreanTree;
  my $path = Math::PlanePath::PythagoreanTree->new
    (
     # tree_type => 'UAD',
     tree_type => 'FB',
     # coordinates => 'AB',
     coordinates => 'PQ',
    );
  my $n = 1;
  foreach my $level (1 .. 100) {
    my @x;
    my @y;
    print "level $level  base n=$n\n";
    my $base = $n;

    my ($min_x, $min_y) = $path->n_to_xy($n);
    my $min_x_n = $n;
    my $min_y_n = $n;
    foreach my $rem (0 .. 3**($level-1)-1) {
      my ($x,$y) = $path->n_to_xy($n);
      if ($x < $min_x) {
        $min_x = $x;
        $min_x_n = $n;
      }
      if ($y < $min_y) {
        $min_y = $y;
        $min_y_n = $n;
      }
      $n++;
    }
    my $min_x_rem = $min_x_n - $base;
    my $min_y_rem = $min_y_n - $base;
    my $min_x_rem_t = sprintf '%0*s', $level-1, Math::BaseCnv::cnv($min_x_rem,10,3);
    my $min_y_rem_t = sprintf '%0*s', $level-1, Math::BaseCnv::cnv($min_y_rem,10,3);
    print "  minx=$min_x at n=$min_x_n rem=$min_x_rem [$min_x_rem_t]\n";
    print "  miny=$min_y at n=$min_y_n rem=$min_y_rem [$min_y_rem_t]\n";
    local $,='..';
    print $path->rect_to_n_range(0,0, $min_x,$min_y),"\n";
  }
  exit 0;
}


{
  my $path = Math::PlanePath::PythagoreanTree->new
    (tree_type => 'UAD');
  foreach my $level (1 .. 20) {
    # my $n = 3 ** $level;
    my $n = (3 ** $level - 1) / 2;
    my ($x,$y) = $path->n_to_xy($n);
    print "$x, $y\n";
  }
  exit 0;
}

{
  # low zeros p=q+1 q=2^k
  my $p = 2;
  my $q = 1;
  ### initial
  ### $p
  ### $q

  foreach (1 .. 3) {
    ($p,$q) = (2*$p-$q, $p);
    ### $p
    ### $q
  }

  ($p,$q) = (2*$p+$q, $p);
  ### mid
  ### $p
  ### $q

  foreach (1 .. 3) {
    ($p,$q) = (2*$p-$q, $p);
    ### $p
    ### $q
  }
  exit 0;
}




{
  require Math::PlanePath::PythagoreanTree;
  my $path = Math::PlanePath::PythagoreanTree->new;
  my (undef, $n_hi) = $path->rect_to_n_range(0,0, 1000,1000);
  ### $n_hi
  my @count;
  foreach my $n (1 .. $n_hi) {
    my ($x,$y) = $path->n_to_xy($n);
    my $z = hypot($x,$y);
    $count[$z]++;
  }
  my $total = 0;
  foreach my $i (1 .. $#count) {
    if ($count[$i]) {
      $total += $count[$i];
      my $ratio = $total/$i;
      print "$i $total   $ratio\n";
    }
  }

  exit 0;
}


{
  require Math::PlanePath::PythagoreanTree;
  my $path = Math::PlanePath::PythagoreanTree->new;
  my $n = 1;
  foreach my $x (0 .. 10000) {
    foreach my $y (0 .. $x) {
      my $n = $path->xy_to_n($x,$y);
      next unless defined $n;
      my ($nx,$ny) = $path->n_to_xy($n);
      if ($nx != $x || $ny != $y) {
        ### $x
        ### $y
        ### $n
        ### $nx
        ### $ny
      }
    }
  }
  exit 0;
}


{
  my ($q,$p) = (21,46);
  print "$q / $p\n";
  {
    my $a = $p*$p - $q*$q;
    my $b = 2*$p*$q;
    my $c = $p*$p + $q*$q;
    print "$a $b $c\n";

    {
      require Math::BaseCnv;
      require Math::PlanePath::PythagoreanTree;
      my $path = Math::PlanePath::PythagoreanTree->new;
      my $n = 1;
      for ( ; $n < 3**11; $n++) {
        my ($x,$y) = $path->n_to_xy($n);
        if (($x == $a && $y == $b)
            || ($x == $b && $y == $a)) {
          print "n=$n\n";
          last;
        }
      }
      my $level = 1;
      $n -= 2;
      while ($n >= 3**$level) {
        $n -= 3**$level;
        $level++;
      }
      my $remt = sprintf "%0*s", $level, Math::BaseCnv::cnv($n,10,3);
      print "level $level remainder $n [$remt]\n";
    }
  }

  my $power = 1;
  my $rem = 0;
  foreach (1..8) {
    my $digit;
    if ($q & 1) {
      $p /= 2;
      if ($q > $p) {
        $q = $q - $p;
        $digit = 2;
      } else {
        $q = $p - $q;
        $digit = 1;
      }
    } else {
      $q /= 2;
      $p -= $q;
      $digit = 0;
    }
    print "$digit  $q / $p\n";
    $rem += $power * $digit;
    $power *= 3;
    last if $q == 1 && $p == 2;
  }
  print "digits $rem\n";
  exit 0;
}
{
  # my ($a, $b, $c) = (39, 80, 89);
  my ($a, $b, $c) = (36,77,85);
  if (($a ^ $c) & 1) {
    ($a,$b) = ($b,$a);
  }
  print "$a $b $c\n";

  my $p = sqrt (($a+$c)/2);
  my $q = $b/(2*$p);
  print "$p $q\n";

  $a = $p*$p - $q*$q;
  $b = 2*$p*$q;
  $c = $p*$p + $q*$q;
  print "$a $b $c\n";

  exit 0;
}



{
  my $f = Math::Matrix->new ([2,0],
                             [1,1]);
  my $g = Math::Matrix->new ([-1,1],
                             [0,2]);
  my $h = Math::Matrix->new ([1,1],
                             [0,2]);
  my $fi = $f->invert;
  print $fi,"\n";
  my $gi = $g->invert;
  print $gi,"\n";
  my $hi = $h->invert;
  print $hi,"\n";
  exit 0;
}

{
  require Math::PlanePath::PythagoreanTree;
  my $path = Math::PlanePath::PythagoreanTree->new;
  my $n = 1;
  foreach my $i (1 .. 100) {
    my ($x,$y) = $path->n_to_xy($n);
    # print 2**($i),"\n";
    # print 2*2**$i*(2**$i-1),"\n";
    my $z = hypot($x,$y);
    printf "%3d  %4d,%4d,%4d\n", $n, $x, $y, $z;
    $n += 3**$i;
  }
  exit 0;
}

{
  sub round_down_pow_3 {
    my ($n) = @_;
    my $p = 3 ** (int(log($n)/log(3)));
    return (3*$p <= $n ? 3*$p
            : $p > $n ? $p/3
            : $p);
  }

  require Math::BaseCnv;

  # base = (range-1)/2
  # range = 2*base + 1
  #
  # newbase = ((2b+1)/3 - 1) / 2
  #         = (2b+1-3)/3 / 2
  #         = (2b-2)/2/3
  #         = (b-1)/3
  #
  # deltarem = b-(b-1)/3
  #          = (3b-b+1)/3
  #          = (2b+1)/3
  #

  foreach my $n (1 .. 32) {
    my $h = 2*($n-1)+1;
    my $level = int(log($h)/log(3));
    $level--;
    my $range = 3**$level;
    my $base = ($range - 1)/2 + 1;
    my $rem = $n - $base;

    if ($rem < 0) {
      $rem += $range/3;
      $level--;
      $range /= 3;
    }
    if ($rem >= $range) {
      $rem -= $range;
      $level++;
      $range *= 3;
    }

    my $remt = Math::BaseCnv::cnv($rem,10,3);
    $remt = sprintf ("%0*s", $level, $remt);
    print "$n $h $level  $range base=$base $rem $remt\n";
  }
  exit 0;
}

{
  my $sum = 0;
  foreach my $k (0 .. 10) {
    $sum += 3**$k;
    my $f = (3**($k+1) - 1) / 2;
    print "$k $sum $f\n";
  }
  exit 0;
}


{
  require Math::PlanePath::PythagoreanTree;
  my $path = Math::PlanePath::PythagoreanTree->new;
  my $x_limit = 500;
  my @max_n;
  foreach my $n (0 .. 500000) {
    my ($x,$y) = $path->n_to_xy($n);
    if ($x <= $x_limit) {
      $max_n[$x] = max($max_n[$x] || $n, $n);
    }
  }
  foreach my $x (0 .. $x_limit) {
    if ($max_n[$x]) {
      print "$x   $max_n[$x]\n";
    }
  }
  exit 0;
}
{
  require Math::PlanePath::PythagoreanTree;
  my $path = Math::PlanePath::PythagoreanTree->new;
  my $x_limit = 500;
  my @max_n;
  foreach my $n (0 .. 500000) {
    my ($x,$y) = $path->n_to_xy($n);
    if ($x <= $x_limit) {
      $max_n[$x] = max($max_n[$x] || $n, $n);
    }
  }
  foreach my $x (0 .. $x_limit) {
    if ($max_n[$x]) {
      print "$x   $max_n[$x]\n";
    }
  }
  exit 0;
}



{
  my $u = Math::Matrix->new ([1,2,2],
                             [-2,-1,-2],
                             [2,2,3]);
  my $a = Math::Matrix->new ([1,2,2],
                             [2,1,2],
                             [2,2,3]);
  my $d = Math::Matrix->new ([-1,-2,-2],
                             [2,1,2],
                             [2,2,3]);
  my $ui = $u->invert;
  print $ui;
  exit 0;
}

{
  my (@x) = 3;
  my (@y) = 4;
  my (@z) = 5;

  for (1..3) {
    for my $i (0 .. $#x) {
      print "$x[$i], $y[$i], $z[$i]    ",sqrt($x[$i]**2+$y[$i]**2),"\n";
    }
    print "\n";

    my @new_x;
    my @new_y;
    my @new_z;
    for my $i (0 .. $#x) {
      my $x = $x[$i];
      my $y = $y[$i];
      my $z = $z[$i];
      push @new_x,   $x - 2*$y + 2*$z;
      push @new_y, 2*$x -   $y + 2*$z;
      push @new_z, 2*$x - 2*$y + 3*$z;

      push @new_x,   $x + 2*$y + 2*$z;
      push @new_y, 2*$x +   $y + 2*$z;
      push @new_z, 2*$x + 2*$y + 3*$z;

      push @new_x,  - $x + 2*$y + 2*$z;
      push @new_y, -2*$x +   $y + 2*$z;
      push @new_z, -2*$x + 2*$y + 3*$z;
    }
    @x = @new_x;
    @y = @new_y;
    @z = @new_z;
  }
  exit 0;
}
