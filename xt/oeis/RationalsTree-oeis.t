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


use 5.004;
use strict;
use Test;
plan tests => 39;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::RationalsTree;

# uncomment this to run the ### lines
#use Smart::Comments '###';


sub gcd {
  my ($x, $y) = @_;
  #### _gcd(): "$x,$y"

  if ($y > $x) {
    $y %= $x;
  }
  for (;;) {
    if ($y <= 1) {
      return ($y == 0 ? $x : 1);
    }
    ($x,$y) = ($y, $x % $y);
  }
}

#------------------------------------------------------------------------------
# A104106  AYT 2*N Left -- not quite
# a(1) = 1
# if A(k) = sequence of first 2^k -1 terms, then
#       A(k+1) = A(k), 1, A(k) if a(k) = 0
#       A(k+1) = A(k), 0, A(k) if a(k) = 1
# A104106 ,1,0,1,1,1,0,1,0,1,0,1,1,1,0,1,0,1,0,1,1,1,0,1,0,1,0,1,1,1,0,1,0,1,0,1,1,1,0,1,0,1,0,1,1,1,0,1,0,1,0,1,1,1,0,1,0,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,0,1,0,1,1,1,0,1,0,1,0,1,1,1,0,1,0,1,0,1,1,1,0,1,0,1,0,1,1,1,0,1,0,1,

# sub A104106_func {
#   my ($n) = @_;
#   my @array;
#   $array[1] = 1;
#   my $k = 1;  # initially 2^1-1 = 2-1 = 1 term
#   while ($#array < $n) {
#     my $last = $#array;
#     push @array,
#       $array[$k] ? 0 : 1,
#         @array[1 .. $last]; # array slice
#     # print "\n$k array ",join(',',@array[1..$#array]),"\n";
#     $k++;
#   }
#   return $array[$n];
# }
# print "A104106_func: ";
# foreach my $i (1 .. 20) {
#   print A104106_func($i),",";
# }
# print "\n";
#
# {
#   require Math::NumSeq::PlanePathTurn;
#   my $seq = Math::NumSeq::PlanePathTurn->new (planepath => 'RationalsTree,tree_type=AYT',
#                                               turn_type => 'Left');
#   print "seq: ";
#   foreach my $i (1 .. 20) {
#     print $seq->ith(2*$i),",";
#   }
#   print "\n";
#
#   foreach my $k (1 .. 100) {
#     my $i = 2*$k;
#     my $s = $seq->ith($i);
#     my $a = A104106_func($k+10);
#     my $diff = ($s != $a ? '  ***' : '');
#     print "$i  $s $a$diff\n";
#   }
# }

#------------------------------------------------------------------------------
# HCS num=A071585 den=A071766
# A010060 is 1=right or straight, 0=left
# straight only at i=2  1,1, 2,1, 3,1

{
  require Math::NumSeq::OEIS::File;
  require Math::NumberCruncher;
  require Math::BaseCnv;
  my $num = Math::NumSeq::OEIS::File->new(anum=>'A071585'); # OFFSET=0
  my $den = Math::NumSeq::OEIS::File->new(anum=>'A071766'); # OFFSET=0
  my $seq_A010060 = Math::NumSeq::OEIS->new(anum=>'A010060');
  (undef, my $n1) = $num->next;
  (undef, my $n2) = $num->next;
  (undef, my $d1) = $den->next;
  (undef, my $d2) = $den->next;
  # $n1 += $d1; $n2 += $d2;
  my $count = 0;
  for (;;) {
    (my $i, my $n3) = $num->next or last;
    (undef, my $d3) = $den->next;

    # Clockwise() positive for clockwise=right, negative for anti=left
    my $turn = Math::NumberCruncher::Clockwise($n1,$d1, $n2,$d2, $n3,$d3);
    if ($turn > 0) { $turn = 1; }  # 1=right
    elsif ($turn < 0) { $turn = 0; }  # 0=left, 1=right
    else { $turn = 1;
           MyTestHelpers::diag ("straight i=$i   $n1,$d1, $n2,$d2, $n3,$d3");
         }
    # print "$turn,"; next;

    my $turn_by_A010060 = $seq_A010060->ith($i);  # n of third of triplet

    if ($turn != $turn_by_A010060) {
      die "oops, wrong at i=$i";
    }

    # if (is_pow2($i)) { print "\n"; }
    # my $i2 = Math::BaseCnv::cnv($i,10,2);
    # printf "%2s %5s %2s,%-2s  %d %d\n", $i,$i2, $n3,$d3, $turn, $turn_by_A010060;

    $n1 = $n2; $n2 = $n3;
    $d1 = $d2; $d2 = $d3;
    $count++;
  }

  MyTestHelpers::diag ("HCS OEIS vs A010060 count $count");
  ok (1,1);
}

#------------------------------------------------------------------------------
# A010060 -- HCS turn right is (-1)^count1bits of N+1, Thue-Morse +/-1
# OFFSET=0, extra initial n=0,1,2 then n=3 is N=2
MyOEIS::compare_values
  (anum => 'A010060',
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath => 'RationalsTree,tree_type=HCS',
                                                 turn_type => 'Right');
     my @got = (0,1,1);
     while (@got < $count) {
       my ($i,$value) = $seq->next;
       push @got, $value;
     }
     return \@got;
   });

# A106400 -- HCS left +/-1 thue-morse parity, OFFSET=0
MyOEIS::compare_values
  (anum => 'A106400',
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath => 'RationalsTree,tree_type=HCS',
                                                 turn_type => 'Left');
     my @got = (1,-1,-1);
     while (@got < $count) {
       my ($i,$value) = $seq->next;
       push @got, 2*$value-1;
     }
     return \@got;
   });

# +/-1 OFFSET=1, extra initial n=1,n=2 then n=3 is N=2
MyOEIS::compare_values
  (anum => 'A108784',
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath => 'RationalsTree,tree_type=HCS',
                                                 turn_type => 'Right');
     my @got = (1,1);
     while (@got < $count) {
       my ($i,$value) = $seq->next;
       push @got, 2*$value-1;
     }
     return \@got;
   });

# A010059 -- HCS Left, count0bits mod 2 of N+1
MyOEIS::compare_values
  (anum => 'A010059',
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath => 'RationalsTree,tree_type=HCS',
                                                 turn_type => 'Left');
     my @got = (1,0,0);
     while (@got < $count) {
       my ($i,$value) = $seq->next;
       push @got, $value;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A070990 -- CW Y-X is Stern diatomic first diffs, starting from N=2

MyOEIS::compare_values
  (anum => 'A070990',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
     my @got;
     for (my $n = $path->n_start + 1; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, $y - $x;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A007814 -- CW floor(X/Y) is count trailing 1-bits
#            A007814 count trailing 0-bits is same, at N+1

MyOEIS::compare_values
  (anum => 'A007814',
   func => sub {
     my ($count) = @_;
     my @got = (0);
     my $path = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, int($x/$y);
     }
     return \@got;
   });

# A007814 -- AYT floor(X/Y) is count trailing 0-bits,
#            except at N=2^k where 1 fewer
MyOEIS::compare_values
  (anum => 'A007814',
   func => sub {
     my ($count) = @_;
     my @got;
     my $path = Math::PlanePath::RationalsTree->new (tree_type => 'AYT');
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       my $i = int($x/$y);
       if (is_pow2($n)) {
         $i--;
       }
       push @got, $i;
     }
     return \@got;
   });

sub is_pow2 {
  my ($n) = @_;
  while ($n > 1) {
    if ($n & 1) {
      return 0;
    }
    $n >>= 1;
  }
  return ($n == 1);
}

#------------------------------------------------------------------------------
# A004442 -- AYT N at transpose Y,X, flip low bit

MyOEIS::compare_values
  (anum => 'A004442',
   func => sub {
     my ($count) = @_;
     my @got = (1,0);
     my $path = Math::PlanePath::RationalsTree->new (tree_type => 'AYT');
     for (my $n = 2; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, $path->xy_to_n ($y, $x);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A063946 -- HCS N at transpose Y,X, flip second lowest bit

MyOEIS::compare_values
  (anum => 'A063946',
   func => sub {
     my ($count) = @_;
     my @got = (0);
     my $path = Math::PlanePath::RationalsTree->new (tree_type => 'HCS');
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, $path->xy_to_n ($y, $x);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A054429 -- N at transpose Y,X, row right to left

foreach my $tree_type ('SB','CW','Bird','Drib') {
  MyOEIS::compare_values
      (anum => 'A054429',
       func => sub {
         my ($count) = @_;
         my @got;
         my $path = Math::PlanePath::RationalsTree->new (tree_type => $tree_type);
         for (my $n = $path->n_start; @got < $count; $n++) {
           my ($x, $y) = $path->n_to_xy ($n);
           push @got, $path->xy_to_n ($y, $x);
         }
         return \@got;
       });
}

#------------------------------------------------------------------------------
# A072030 - subtraction steps for gcd(x,y) by triangle rows

MyOEIS::compare_values
  (anum => q{A072030},
   func => sub {
     my ($count) = @_;
     require Math::PlanePath::PyramidRows;
     my $path = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
     my $triangle = Math::PlanePath::PyramidRows->new (step => 1);
     my @got;
     for (my $n = $triangle->n_start; @got < $count; $n++) {
       my ($x,$y) = $triangle->n_to_xy ($n);
       next unless $x < $y;  # so skipping GCD(x,x)==x taking 0 steps
       $x++;
       $y++;
       my $gcd = gcd($x,$y);
       $x /= $gcd;
       $y /= $gcd;
       my $n = $path->xy_to_n($x,$y);
       die unless defined $n;
       my $depth = $path->tree_n_to_depth($n);
       push @got, $depth;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A072031 - row sums of A072030 subtraction steps for gcd(x,y) by rows

MyOEIS::compare_values
  (anum => q{A072031},
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::RationalsTree->new(tree_type => 'SB');
     my @got;
     for (my $y = 2; @got < $count; $y++) {
       my $total = -1;   # gcd(1,Y) taking 0 steps, maybe
       for (my $x = 1; $x < $y; $x++) {
         my $gcd = gcd($x,$y);
         my $n = $path->xy_to_n($x/$gcd,$y/$gcd);
         die unless defined $n;
         $total += $path->tree_n_to_depth($n);
       }
       push @got, $total+1;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A154436 -- permutation Bird->HCS, lamplighter inverse

MyOEIS::compare_values
  (anum => 'A154436',
   func => sub {
     my ($count) = @_;
     my $cs  = Math::PlanePath::RationalsTree->new (tree_type => 'HCS');
     my $bird  = Math::PlanePath::RationalsTree->new (tree_type => 'Bird');
     my @got = (0);  # initial 0
     for (my $n = $bird->n_start; @got < $count; $n++) {
       my ($x, $y) = $bird->n_to_xy($n);
       push @got, $cs->xy_to_n($x,$y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A003188 -- permutation SB->HCS, Gray code shift+xor

MyOEIS::compare_values
  (anum => 'A003188',
   func => sub {
     my ($count) = @_;
     my $cs  = Math::PlanePath::RationalsTree->new (tree_type => 'HCS');
     my $sb  = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
     my @got = (0);  # initial 0
     for (my $n = $sb->n_start; @got < $count; $n++) {
       my ($x, $y) = $sb->n_to_xy($n);
       push @got, $cs->xy_to_n($x,$y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A006068 -- permutation HCS->SB, Gray code inverse

MyOEIS::compare_values
  (anum => 'A006068',
   func => sub {
     my ($count) = @_;
     my $cs  = Math::PlanePath::RationalsTree->new (tree_type => 'HCS');
     my $sb  = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
     my @got = (0);  # initial 0
     for (my $n = $cs->n_start; @got < $count; $n++) {
       my ($x, $y) = $cs->n_to_xy($n);
       push @got, $sb->xy_to_n($x,$y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A154435 -- permutation HCS->Bird, lamplighter

MyOEIS::compare_values
  (anum => 'A154435',
   func => sub {
     my ($count) = @_;
     my $cs  = Math::PlanePath::RationalsTree->new (tree_type => 'HCS');
     my $bird  = Math::PlanePath::RationalsTree->new (tree_type => 'Bird');
     my @got = (0);  # initial 0
     for (my $n = $cs->n_start; @got < $count; $n++) {
       my ($x, $y) = $cs->n_to_xy($n);
       push @got, $bird->xy_to_n($x,$y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# Stern diatomic A002487

# A002487 -- L denominators, L doesn't have initial 0,1 of diatomic
MyOEIS::compare_values
  (anum => 'A002487',
   func => sub {
     my ($count) = @_;
     my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'L');
     my @got = (0,1);
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, $y;
     }
     return \@got;
   });

# A002487 -- CW numerators, is Stern diatomic
MyOEIS::compare_values
  (anum => 'A002487',
   func => sub {
     my ($count) = @_;
     my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
     my @got = (0);
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, $x;
     }
     return \@got;
   });

# A002487 -- CW denominators are Stern diatomic
MyOEIS::compare_values
  (anum => 'A002487',
   func => sub {
     my ($count) = @_;
     my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
     my @got = (0,1);  # extra initial
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, $y;
     }
     return \@got;
   });


#------------------------------------------------------------------------------
# A071585 -- HCS num+den

MyOEIS::compare_values
  (anum => 'A071585',
   func => sub {
     my ($count) = @_;
     my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'HCS');
     my @got = (1);  # extra initial 1/1 then Rat+1
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, $x+$y;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A071766 -- HCS denominators

MyOEIS::compare_values
  (anum => 'A071766',
   func => sub {
     my ($count) = @_;
     my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'HCS');
     my @got = (1);  # extra initial 1/1
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, $y;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A059893 -- permutation CW<->SB, bit reversal

MyOEIS::compare_values
  (anum => 'A059893',
   func => sub {
     my ($count) = @_;
     my $sb  = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
     my $cw  = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
     my @got;
     for (my $n = $cw->n_start; @got < $count; $n++) {
       my ($x, $y) = $cw->n_to_xy($n);
       push @got, $sb->xy_to_n($x,$y);
     }
     return \@got;
   });

MyOEIS::compare_values
  (anum => 'A059893',
   func => sub {
     my ($count) = @_;
     my @got;
     my $sb  = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
     my $cw  = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
     for (my $n = $sb->n_start; @got < $count; $n++) {
       my ($x, $y) = $sb->n_to_xy($n);
       push @got, $cw->xy_to_n($x,$y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A153153 -- permutation CW->AYT

MyOEIS::compare_values
  (anum => 'A153153',
   func => sub {
     my ($count) = @_;
     my $ayt  = Math::PlanePath::RationalsTree->new (tree_type => 'AYT');
     my $cw  = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
     my @got = (0);  # initial 0
     for (my $n = $cw->n_start; @got < $count; $n++) {
       my ($x, $y) = $cw->n_to_xy($n);
       push @got, $ayt->xy_to_n($x,$y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A153154 -- permutation AYT->CW

MyOEIS::compare_values
  (anum => 'A153154',
   func => sub {
     my ($count) = @_;
     my $ayt  = Math::PlanePath::RationalsTree->new (tree_type => 'AYT');
     my $cw  = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
     my @got = (0);  # initial 0
     for (my $n = $ayt->n_start; @got < $count; $n++) {
       my ($x, $y) = $ayt->n_to_xy($n);
       push @got, $cw->xy_to_n($x,$y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A154437 -- permutation AYT->Drib

MyOEIS::compare_values
  (anum => 'A154437',
   func => sub {
     my ($count) = @_;
     my $drib  = Math::PlanePath::RationalsTree->new (tree_type => 'Drib');
     my $ayt  = Math::PlanePath::RationalsTree->new (tree_type => 'AYT');
     my @got = (0);  # initial 0
     for (my $n = $ayt->n_start; @got < $count; $n++) {
       my ($x, $y) = $ayt->n_to_xy($n);
       push @got, $drib->xy_to_n($x,$y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A154438 -- permutation Drib->AYT

MyOEIS::compare_values
  (anum => 'A154438',
   func => sub {
     my ($count) = @_;
     my $ayt  = Math::PlanePath::RationalsTree->new (tree_type => 'AYT');
     my $drib  = Math::PlanePath::RationalsTree->new (tree_type => 'Drib');
     my @got = (0);  # initial 0
     for (my $n = $drib->n_start; @got < $count; $n++) {
       my ($x, $y) = $drib->n_to_xy($n);
       push @got, $ayt->xy_to_n($x,$y);
     }
     return \@got;
   });


#------------------------------------------------------------------------------
# A061547 -- pos of frac F(n)/F(n+1) in Stern diatomic, is CW N

# F(n)/F(n+1) in CW, extra initial 0

MyOEIS::compare_values
  (anum => 'A061547',
   max_count => 100,
   func => sub {
     my ($count) = @_;
     my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
     my @got = (0);  # extra initial 0 in seq A061547
     require Math::BigInt;
     my $f1 = Math::BigInt->new(1);
     my $f0 = Math::BigInt->new(1);
     while (@got < $count) {
       push @got, $path->xy_to_n ($f0, $f1);
       ($f1,$f0) = ($f1+$f0,$f1);
     }
     return \@got;
   });

# Y/1 in Drib, extra initial 0 in A061547
MyOEIS::compare_values
  (anum => 'A061547',
   max_count => 100,
   func => sub {
     my ($count) = @_;
     my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'Drib');
     my @got = (0); # extra initial 0 in A061547
     for (my $y = Math::BigInt->new(1); @got < $count; $y++) {
       push @got, $path->xy_to_n (1, $y);
     }
     return \@got;
   });

# #------------------------------------------------------------------------------
# # A113881
# # different as n=49
#
# {
#   my $anum = 'A113881';
#   my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
#   my $skip;
#   my @got;
#   my $diff;
#   if ($bvalues) {
#     require Math::PlanePath::Diagonals;
#     my $path = Math::PlanePath::RationalsTree->new(tree_type => 'SB');
#     my $diag = Math::PlanePath::Diagonals->new;
#     for (my $n = $diag->n_start; @got < $count; $n++) {
#       my ($x,$y) = $diag->n_to_xy ($n);
#       $x++;
#       $y++;
#       my $gcd = gcd($x,$y);
#       $x /= $gcd;
#       $y /= $gcd;
#       my $n = $path->xy_to_n($x,$y);
#       my $nbits = sprintf '%b', $n;
#       push @got, length($nbits);
#     }
#     $diff = diff_nums(\@got, $bvalues);
#     if ($diff) {
#       MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..30]));
#       MyTestHelpers::diag ("got:     ",join(',',@got[0..30]));
#     }
#   }
#   skip (! $bvalues,
#         $diff, undef,
#         "$anum");
# }

#------------------------------------------------------------------------------
# A088696 -- length of continued fraction of SB fractions

if (! eval { require Math::ContinuedFraction; 1 }) {
  skip ("Math::ContinuedFraction not available",
        0,0);
} else {
  MyOEIS::compare_values
      (anum => 'A088696',
       func => sub {
         my ($count) = @_;
         my @got;
         my $path = Math::PlanePath::RationalsTree->new(tree_type => 'SB');
       OUTER: for (my $k = 1; @got < $count; $k++) {
           foreach my $n (2**$k .. 2**$k + 2**($k-1) - 1) {
             my ($x,$y) = $path->n_to_xy ($n);
             my $cf = Math::ContinuedFraction->from_ratio($x,$y);
             my $cfaref = $cf->to_array;
             my $cflen = scalar(@$cfaref);
             push @got, $cflen-1;  # -1 to skip initial 0 term in $cf

             ### cf: "n=$n xy=$x/$y cflen=$cflen ".$cf->to_ascii
             last OUTER if @got >= $count;
           }
         }
         return \@got;
       });
}

#------------------------------------------------------------------------------
# A000975 -- 010101 without consecutive equal bits, Bird tree X=1 column

MyOEIS::compare_values
  (anum => 'A000975',
   max_count => 100,
   func => sub {
     my ($count) = @_;
     my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'Bird');
     my @got = (0);  # extra initial 0 in A000975
     require Math::BigInt;
     for (my $y = Math::BigInt->new(1); @got < $count; $y++) {
       push @got, $path->xy_to_n (1, $y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A086893 -- pos of frac F(n+1)/F(n) in Stern diatomic, is CW N

MyOEIS::compare_values
  (anum => 'A086893',
   func => sub {
     my ($count) = @_;
     my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
     my @got;
     my $f1 = 1;
     my $f0 = 1;
     while (@got < $count) {
       push @got, $path->xy_to_n ($f1, $f0);
       ($f1,$f0) = ($f1+$f0,$f1);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A007305 -- SB numerators

MyOEIS::compare_values
  (anum => 'A007305',
   func => sub {
     my ($count) = @_;
     my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
     my @got = (0,1);  # extra initial
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, $x;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A047679 -- SB denominators

MyOEIS::compare_values
  (anum => 'A047679',
   func => sub {
     my ($count) = @_;
     my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
     my @got;
     foreach my $n (1 .. $count) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, $y;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A007306 -- SB num+den

MyOEIS::compare_values
  (anum => 'A007306',
   func => sub {
     my ($count) = @_;
     my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
     my @got = (1,1); # extra initial
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, $x+$y;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A162911 -- Drib tree numerators = Bird tree reverse N

MyOEIS::compare_values
  (anum => q{A162911},
   func => sub {
     my ($count) = @_;
     my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'Bird');
     my @got;
     foreach my $n (1 .. $count) {
       my ($x, $y) = $path->n_to_xy (bit_reverse ($n));
       push @got, $x;
     }
     return \@got;
   });

sub bit_reverse {
  my ($n) = @_;
  my $rev = 1;
  while ($n > 1) {
    $rev = 2*$rev + ($n % 2);
    $n = int($n/2);
  }
  return $rev;
}

#------------------------------------------------------------------------------
# A162912 -- Drib tree denominators = Bird tree reverse

MyOEIS::compare_values
  (anum => q{A162912},
   func => sub {
     my ($count) = @_;
     my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'Bird');
     my @got;
     foreach my $n (1 .. $count) {
       my ($x, $y) = $path->n_to_xy (bit_reverse ($n));
       push @got, $y;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
exit 0;
