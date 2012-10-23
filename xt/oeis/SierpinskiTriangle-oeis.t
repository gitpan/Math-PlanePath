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

use 5.004;
use strict;
use Test;
plan tests => 16;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();

use MyOEIS;
use Math::PlanePath::SierpinskiTriangle;

use Math::PlanePath::Base::Digits
  'digit_join_lowtohigh';

# uncomment this to run the ### lines
#use Smart::Comments '###';


sub diff_nums {
  my ($gotaref, $wantaref) = @_;
  for (my $i = 0; $i < @$gotaref; $i++) {
    if ($i > @$wantaref) {
      return "want ends prematurely pos=$i";
    }
    my $got = $gotaref->[$i];
    my $want = $wantaref->[$i];
    if (! defined $got && ! defined $want) {
      next;
    }
    if (! defined $got || ! defined $want) {
      return "different pos=$i got=".(defined $got ? $got : '[undef]')
        ." want=".(defined $want ? $want : '[undef]');
    }
    $got =~ /^[0-9.-]+$/
      or return "not a number pos=$i got='$got'";
    $want =~ /^[0-9.-]+$/
      or return "not a number pos=$i want='$want'";
    if ($got != $want) {
      return "different pos=$i numbers got=$got want=$want";
    }
  }
  return undef;
}

sub path_xy_is_visited {
  my ($path, $x,$y) = @_;
  return defined($path->xy_to_n($x,$y));
}


#------------------------------------------------------------------------------
# A067771 - number of vertices to order=n ...

# {
#   my $anum = 'A067771';
#   my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
#   my $diff;
#   if ($bvalues) {
#     my $path = Math::PlanePath::SierpinskiTriangle->new;
#     my @got;
#     my $depth = 0;
#     my $count = 0;
#     my $n = $path->n_start;
#     while (@got < @$bvalues) {
#       my $next_n_depth = $path->tree_depth_to_n($depth++);
#       for ( ; $n < $next_n_depth; $n++) {
#         $count += path_n_is_leaf($path,$n);
#       }
#       push @got, $count;
#       $depth++;
#     }
#     $diff = diff_nums(\@got, $bvalues);
#     if ($diff) {
#       MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
#       MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
#     }
#   }
#   skip (! $bvalues,
#         $diff,
#         undef,
#         "$anum");
# }
# 
# sub path_n_is_leaf {
#   my ($path, $n) = @_;
#   my $num_children = $path->tree_n_num_children($n);
#   return defined($num_children) && $num_children == 0;
# }

#------------------------------------------------------------------------------
# A001317 - rows as binary bignums, without the skipped (x^y)&1==1 points of
# triangular lattice
{
  my $anum = 'A001317';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::SierpinskiTriangle->new (align => 'right');
    my @got;
    require Math::BigInt;
    for (my $y = 0; @got < @$bvalues; $y++) {
      my $b = 0;
      foreach my $x (0 .. $y) {
        if (path_xy_is_visited($path,$x,$y)) {
          $b += Math::BigInt->new(2) ** $x;
        }
      }
      push @got, "$b";
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..3]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..3]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# breadth-first,
# bit-doubled because each leaf extended to a pair, as described in A080293
#
# A080318 decimal
# A080319 binary
# A080320 positions in A014486 list of balanced
#         10,
#         111000,
#         11111110000000,
#         1111111-11000011-0000000,
#         11111111100001111111111000000000000000,
#
#                                   . . . . . . . .
#                   . .     . .      *   *   *   *
#                                     \ /     \ /
#       . . . .      *  . .  *         *  . .  *
#                     \     /           \     /
#        *   *         *   *             *   *
#  . .    \ /           \ /               \ /
#   *      *             *                 *
#
#
# 70239893062016
# 1111111110000111111111111000000000000110000000
# . .             . .
#  *               *
#   \ . . . . . . /
#    *   *   *   *
#     \ /     \ /
#      *  . .  *
#       \     /
#        *   *
#         \ /
#          *
#
# 4603241631720636416
# 11111111100001111111111110000000000001111111111000000000000000
#   [9]     [4]     [12]        [12]      [10]      [15]#
# . . . .         . . . .
#  *   *           *   *
#   \ /             \ /
#    *               *
#     \ . . . . . . /
#      *   *   *   *
#       \ /     \ /
#        *  . .  *
#         \     /
#          *   *
#           \ /
#            *
#
# 331698516757016399905370236824584576
# 11111111100001111111111110000000000001111111111110000111100001111111\
# 11111111111110000000000000000000000000000110000000




{
  # double-up
  my ($one) = MyOEIS::read_values('A080268');
  my ($two) = MyOEIS::read_values('A080318');
  my $path = Math::PlanePath::SierpinskiTriangle->new;
  for (my $i = 0; $i <= $#$one && $i+1 <= $#$two; $i++) {
    my $o = $one->[$i];
    my $t = $two->[$i+1];
    my $ob = Math::BigInt->new("$o")->as_bin;
    $ob =~ s/^0b//;
    my $o2 = $ob;
    $o2 =~ s/(.)/$1$1/g;  # double
    $o2 = "1".$o2."0";
    my $tb = Math::BigInt->new("$t")->as_bin;
    $tb =~ s/^0b//;
    # print "o  $o\nob $ob\no2 $o2\ntb $tb\n\n";
    $tb eq $o2 or die "x";
  }
}


{
  # decimal
  my $anum = 'A080318';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $path = Math::PlanePath::SierpinskiTriangle->new;
  my $diff;
  if ($bvalues) {
    my @got;
    for (my $depth = 0; @got < @$bvalues; $depth++) {
      my @bits = nest_breadth_bits($path, $depth);
      push @got, Math::BigInt->new("0b".join('',@bits));
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..3]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..3]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum by path");
}
{
  # binary
  my $anum = 'A080319';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $path = Math::PlanePath::SierpinskiTriangle->new;
  my $diff;

  # foreach my $depth (0 .. 11) {
  #   my @bits = nest_breadth_bits($path, $depth);
  #   print @bits,"\n";
  # }

  if ($bvalues) {
    my @got;
    for (my $depth = 0; @got < @$bvalues; $depth++) {
      my @bits = nest_breadth_bits($path, $depth);
      push @got, join('',@bits);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..5]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..5]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum by path");
}
{
  # position in list of all balanced binary (A014486)
  my $anum = 'A080320';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $path = Math::PlanePath::SierpinskiTriangle->new;
  my $diff;
  if ($bvalues) {
    require Math::NumSeq::BalancedBinary;
    require Math::BigInt;
    my $bal = Math::NumSeq::BalancedBinary->new;
    my @got;
    for (my $depth = 0; @got < @$bvalues; $depth++) {
      my @bits = nest_breadth_bits($path, $depth);
      my $value = Math::BigInt->new("0b".join('',@bits));
      push @got, $bal->value_to_i($value);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..9]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..9]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum by path");
}

# Return a list of 0,1 bits.
#
sub nest_breadth_bits {
  my ($path, $limit) = @_;
  my @pending_x = (0);
  my @pending_y = (0);
  my @ret = (1);
  my $open = 1;
  foreach (1 .. $limit) {
    my @new_x;
    my @new_y;
    foreach my $i (0 .. $#pending_x) {
      my $x = $pending_x[$i];
      my $y = $pending_y[$i];
      if (path_xy_is_visited($path,$x,$y)) {
        push @ret, 1,1;
        $open += 2;
        push @new_x, $x-1;
        push @new_y, $y+1;
        push @new_x, $x+1;
        push @new_y, $y+1;
      } else {
        push @ret, 0,0;
        $open -= 2;
      }
    }
    @pending_x = @new_x;
    @pending_y = @new_y;
  }
  return @ret, ((0) x $open);
}

#------------------------------------------------------------------------------
# Dyck coded, depth-first

# A080263 sierpinski 2, 50, 906, 247986
# A080264 binary    10, 110010, 1110001010, 111100100010110010
#                       (    )
#
#                                    *   *   *   *
#                                     \ /     \ /
#                    *       *         *       *  
#                     \     /           \     /   
#        *   *         *   *             *   *    
#         \ /           \ /               \ /     
#   *      *             *                 *      
#  10   110010   1,1100,0101,0   11,110010,0010,110010
#  10,  110010,   1110001010,    111100100010110010
#       (())()
#      [(())()]

{
  # binary
  my $anum = 'A080264';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $path = Math::PlanePath::SierpinskiTriangle->new;
  my $diff;
  if ($bvalues) {
    my @got;
    for (my $depth = 1; @got < @$bvalues; $depth++) {
      my @bits = dyck_tree_bits($path, 0,0, $depth);
      push @got, join('',@bits);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..4]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..4]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum by path");
}
{
  # position in list of all balanced binary (A014486)
  my $anum = 'A080265';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $path = Math::PlanePath::SierpinskiTriangle->new;
  my $diff;
  if ($bvalues) {
    require Math::NumSeq::BalancedBinary;
    require Math::BigInt;
    my $bal = Math::NumSeq::BalancedBinary->new;
    my @got;
    for (my $depth = 1; @got < @$bvalues; $depth++) {
      my @bits = dyck_tree_bits($path, 0,0, $depth);
      my $value = Math::BigInt->new("0b".join('',@bits));
      push @got, $bal->value_to_i($value);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..11]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..11]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum by path");
}

{
  # decimal
  my $anum = 'A080263';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $path = Math::PlanePath::SierpinskiTriangle->new;
  my $diff;
  if ($bvalues) {
    my @got;
    for (my $depth = 1; @got < @$bvalues; $depth++) {
      my @bits = dyck_tree_bits($path, 0,0, $depth);
      push @got, Math::BigInt->new("0b".join('',@bits));
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..3]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..3]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum by path");
}

# No-such node = 0.
# Node = 1,left,right.
# Drop very last 0 at end.
#
sub dyck_tree_bits {
  my ($path, $x,$y, $limit) = @_;
  my @ret = dyck_tree_bits_z ($path, $x,$y, $limit);
  pop @ret;
  return @ret;
}
sub dyck_tree_bits_z {
  my ($path, $x,$y, $limit) = @_;
  if ($limit > 0 && path_xy_is_visited($path,$x,$y)) {
    return (1,
            dyck_tree_bits_z($path, $x-1,$y+1, $limit-1),  # left
            dyck_tree_bits_z($path, $x+1,$y+1, $limit-1)); # right
  } else {
    return (0);
  }
}

# Doesn't distinguish left and right.
# sub parens_bits_z {
#   my ($path, $x,$y, $limit) = @_;
#   if ($limit > 0 && path_xy_is_visited($path,$x,$y)) {
#     return (1,
#             parens_bits_z($path, $x-1,$y+1, $limit-1),  # left
#             parens_bits_z($path, $x+1,$y+1, $limit-1),  # right
#             0);
#   } else {
#     return ();
#   }
# }

#------------------------------------------------------------------------------
# breath-wise "level-order"
#
# A080268 decimal 2,  56,     968,        249728,             3996680,
# A080269 binary 10, 111000, 1111001000, 111100111110000000, 1111001111110000001000,
#                            (( (()) () ))
#
# 111100111111000000111111001100111111111000000000000000
#
# cf A057118 permute depth<->breadth
#

{
  # position in list of all balanced binary (A014486)
  my $anum = 'A080270';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $path = Math::PlanePath::SierpinskiTriangle->new;
  my $diff;
  if ($bvalues) {
    require Math::NumSeq::BalancedBinary;
    require Math::BigInt;
    my $bal = Math::NumSeq::BalancedBinary->new;
    my @got;
    for (my $depth = 1; @got < @$bvalues; $depth++) {
      my @bits = level_order_bits($path, $depth);
      my $value = Math::BigInt->new("0b".join('',@bits));
      push @got, $bal->value_to_i($value);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..3]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..3]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum by path");
}

{
  # decimal
  my $anum = 'A080268';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $path = Math::PlanePath::SierpinskiTriangle->new;
  my $diff;
  if ($bvalues) {
    my @got;
    for (my $depth = 1; @got < @$bvalues; $depth++) {
      my @bits = level_order_bits($path, $depth);
      push @got, Math::BigInt->new("0b".join('',@bits));
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..3]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..3]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum by path");
}
{
  # binary
  my $anum = 'A080269';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $path = Math::PlanePath::SierpinskiTriangle->new;
  my $diff;
  if ($bvalues) {
    my @got;
    for (my $depth = 1; @got < @$bvalues; $depth++) {
      my @bits = level_order_bits($path, $depth);
      push @got, join('',@bits);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..5]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..5]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum by path");
}

# Return a list of 0,1 bits.
# No-such node = 0.
# Node = 1.
# Nodes descend to left,right breadth-wise in next level.
# Drop very last 0 at end.
#
sub level_order_bits {
  my ($path, $limit) = @_;
  my @pending_x = (0);
  my @pending_y = (0);
  my @ret;
  foreach (1 .. $limit) {
    my @new_x;
    my @new_y;
    foreach my $i (0 .. $#pending_x) {
      my $x = $pending_x[$i];
      my $y = $pending_y[$i];
      if (path_xy_is_visited($path,$x,$y)) {
        push @ret, 1;
        push @new_x, $x-1;
        push @new_y, $y+1;
        push @new_x, $x+1;
        push @new_y, $y+1;
      } else {
        push @ret, 0;
      }
    }
    @pending_x = @new_x;
    @pending_y = @new_y;
  }
  push @ret, (0) x (scalar(@pending_x)-1);
  return @ret;
}

#------------------------------------------------------------------------------
# A106344 - by dX=-3,dY=+1 slopes upwards
# cf A106346 its matrix inverse, or something
#
# 1
# 0, 1
# 0, 1, 1,
# 0, 0, 0, 1,
# 0, 0, 1, 1, 1,
# 0, 0, 0, 1, 0, 1,
# 0, 0, 0, 1, 0, 1, 1,
# 0, 0, 0, 0, 0, 0, 0, 1,
# 0, 0, 0, 0, 1, 0, 1, 1, 1,
# 0, 0, 0, 0, 0, 1, 0, 1, 0, 1,
# 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1,
# 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1,
# 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1,
# 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1

# 19  20  21  22  23  24  25  26   
#   15      16      17      18     
#     11  12          13  14   .    
#        9              10   .      
#          5   6   7   8   .        
#            3   .   4   .          
#              1   2    .   .        
#                0    .   .   .

# path(x,y) = binomial(y,(x+y)/2)
# T(n,k)=binomial(k,n-k)
# y=k
# (x+y)/2=n-k
# x+k=2n-2k
# x=2n-3k
{
  my $anum = 'A106344';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  {
    # align="left" is dX=1,dY=1 diagonals
    my $diff;
    if ($bvalues) {
      my $path = Math::PlanePath::SierpinskiTriangle->new (align => 'left');
      my @got;
      my $xstart = 0;
      my $x = 0;
      my $y = 0;
      while (@got < @$bvalues) {
        my $n = $path->xy_to_n($x,$y);
        push @got, (defined $n ? 1 : 0);

        $x += 1;
        $y += 1;
        if ($x > 0) {
          $xstart--;
          $x = $xstart;
          $y = 0;
        }
      }
      $diff = diff_nums(\@got, $bvalues);
      if ($diff) {
        MyTestHelpers::diag ("bvalues: ",join('',@{$bvalues}[0..60]));
        MyTestHelpers::diag ("got:     ",join('',@got[0..60]));
      }
    }
    skip (! $bvalues,
          $diff,
          undef,
          "$anum by path");
  }
  {
    # align="right" is dX=2,dY=1 slopes, chess knight moves
    my $diff;
    if ($bvalues) {
      my $path = Math::PlanePath::SierpinskiTriangle->new (align => 'right');
      my @got;
      my $xstart = 0;
      my $x = 0;
      my $y = 0;
      while (@got < @$bvalues) {
        my $n = $path->xy_to_n($x,$y);
        push @got, (defined $n ? 1 : 0);

        $x += 2;
        $y += 1;
        if ($x > $y) {
          $xstart--;
          $x = $xstart;
          $y = 0;
        }
      }
      $diff = diff_nums(\@got, $bvalues);
      if ($diff) {
        MyTestHelpers::diag ("bvalues: ",join('',@{$bvalues}[0..60]));
        MyTestHelpers::diag ("got:     ",join('',@got[0..60]));
      }
    }
    skip (! $bvalues,
          $diff,
          undef,
          "$anum by path");
  }
  {
    my $diff;
    if ($bvalues) {
      my $path = Math::PlanePath::SierpinskiTriangle->new;
      my @got;
      my $xstart = 0;
      my $x = 0;
      my $y = 0;
      while (@got < @$bvalues) {
        my $n = $path->xy_to_n($x,$y);
        push @got, (defined $n ? 1 : 0);

        $x += 3;
        $y += 1;
        if ($x > $y) {
          $xstart -= 2;
          $x = $xstart;
          $y = 0;
        }
      }
      $diff = diff_nums(\@got, $bvalues);
      if ($diff) {
        MyTestHelpers::diag ("bvalues: ",join('',@{$bvalues}[0..60]));
        MyTestHelpers::diag ("got:     ",join('',@got[0..60]));
      }
    }
    skip (! $bvalues,
          $diff,
          undef,
          "$anum by path");
  }
  {
    my $diff;
    if ($bvalues) {
      my $path = Math::PlanePath::SierpinskiTriangle->new;
      my @got;
    OUTER: for (my $n = 0; ; $n++) {
        for (my $k = 0; $k <= $n; $k++) {
          my $n = $path->xy_to_n(2*$n-3*$k,$k);
          push @got, (defined $n ? 1 : 0);
          if (@got >= @$bvalues) {
            last OUTER;
          }
        }
      }
      $diff = diff_nums(\@got, $bvalues);
      if ($diff) {
        MyTestHelpers::diag ("bvalues: ",join('',@{$bvalues}[0..60]));
        MyTestHelpers::diag ("got:     ",join('',@got[0..60]));
      }
    }
    skip (! $bvalues,
          $diff,
          undef,
          "$anum by path");
  }
  {
    my $diff;
    if ($bvalues) {
      my $path = Math::PlanePath::SierpinskiTriangle->new;
      my @got;
      require Math::BigInt;
    OUTER: for (my $n = 0; ; $n++) {
        for (my $k = 0; $k <= $n; $k++) {

          # my $b = Math::BigInt->new($k);
          # $b->bnok($n-$k);   # binomial(k,k-n)
          # $b->bmod(2);
          # push @got, $b;

          push @got, binomial_mod2 ($k, $n-$k);
          if (@got >= @$bvalues) {
            last OUTER;
          }
        }
      }
      $diff = diff_nums(\@got, $bvalues);
      if ($diff) {
        MyTestHelpers::diag ("bvalues: ",join('',@{$bvalues}[0..60]));
        MyTestHelpers::diag ("got:     ",join('',@got[0..60]));
      }
    }
    skip (! $bvalues,
          $diff,
          undef,
          "$anum by bnok()");
  }
}

# my $b = Math::BigInt->new($k);
# $b->bnok($n-$k);   # binomial(k,k-n)
# $b->bmod(2);
sub binomial_mod2 {
  my ($n, $k) = @_;
  return Math::BigInt->new($n)->bnok($k)->bmod(2)->numify;
}


#------------------------------------------------------------------------------
# A106345 - 
# k=0..floor(n/2) of binomial(k, n-2k)
#
# path(x,y) = binomial(y,(x+y)/2)
# T(n,k)=binomial(k,n-2k)
# y=k
# (x+y)/2=n-2k
# x+k=2n-4k
# x=2n-5k

{
  my $anum = 'A106345';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum,
                                                      # touch slow, shorten
                                                      max_count => 1000);
  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::SierpinskiTriangle->new;
    my @got;
    for (my $xstart = 0; @got < @$bvalues; $xstart -= 2) {
      my $x = $xstart;
      my $y = 0;
      my $total = 0;
      while ($x <= $y) {
        my $n = $path->xy_to_n($x,$y);
        if (defined $n) {
          $total++;
        }
        $x += 5;
        $y += 1;
      }
      push @got, $total;
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..10]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..10]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum by path");
}

#------------------------------------------------------------------------------
# A002487 - stern diatomic count along of dX=3,dY=1 slopes

{
  my $anum = 'A002487';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum,
                                                      # touch slow, shorten
                                                      max_count => 1000);
  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::SierpinskiTriangle->new;
    my @got = (0);
    for (my $xstart = 0; @got < @$bvalues; $xstart -= 2) {
      my $x = $xstart;
      my $y = 0;
      my $total = 0;
      while ($x <= $y) {
        my $n = $path->xy_to_n($x,$y);
        if (defined $n) {
          $total++;
        }
        $x += 3;
        $y += 1;
      }
      push @got, $total;
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..10]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..10]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum by path");
}


#------------------------------------------------------------------------------
# A001316 - Gould's sequence number of 1s in each row
{
  my $anum = 'A001316';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::SierpinskiTriangle->new;
    my @got;
    my $prev_y = 0;
    my $count = 0;
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x,$y) = $path->n_to_xy($n);
      if ($y == $prev_y) {
        $count++;
      } else {
        push @got, $count;
        $prev_y = $y;
        $count = 1;
      }
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A047999 - 1/0 by rows, without the skipped (x^y)&1==1 points of triangular
# lattice
{
  my $anum = 'A047999';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  {
    my $diff;
    if ($bvalues) {
      my $path = Math::PlanePath::SierpinskiTriangle->new;
      my @got;
      my $x = 0;
      my $y = 0;
      foreach my $n (1 .. @$bvalues) {
        push @got, (path_xy_is_visited($path,$x,$y) ? 1 : 0);
        $x += 2;
        if ($x > $y) {
          $y++;
          $x = -$y;
        }
      }
    }
    skip (! $bvalues,
          $diff,
          undef,
          "$anum");
  }
  {
    my $diff;
    if ($bvalues) {
      my $path = Math::PlanePath::SierpinskiTriangle->new (align => "right");
      my @got;
      my $x = 0;
      my $y = 0;
      foreach my $n (1 .. @$bvalues) {
        push @got, (path_xy_is_visited($path,$x,$y) ? 1 : 0);
        $x++;
        if ($x > $y) {
          $y++;
          $x = 0;
        }
      }
    }
    skip (! $bvalues,
          $diff,
          undef,
          "$anum");
  }
}


#------------------------------------------------------------------------------
# A075438 - 1/0 by rows of "right", including blank 0s in left of pyramid
{
  my $anum = 'A075438';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  {
    my $diff;
    if ($bvalues) {
      my $path = Math::PlanePath::SierpinskiTriangle->new (align => 'right');
      my @got;
      my $x = 0;
      my $y = 0;
      foreach my $n (1 .. @$bvalues) {
        push @got, (path_xy_is_visited($path,$x,$y) ? 1 : 0);
        $x++;
        if ($x > $y) {
          $y++;
          $x = -$y;
        }
      }
    }
    skip (! $bvalues,
          $diff,
          undef,
          "$anum");
  }
}

#------------------------------------------------------------------------------

exit 0;
