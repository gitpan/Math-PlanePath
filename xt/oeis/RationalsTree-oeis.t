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
plan tests => 23;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::RationalsTree;

# uncomment this to run the ### lines
#use Smart::Comments '###';


# cf A059893 - bit reverse all but the high 1

sub numeq_array {
  my ($a1, $a2) = @_;
  if (! ref $a1 || ! ref $a2) {
    return 0;
  }
  my $i = 0; 
  while ($i < @$a1 && $i < @$a2) {
    if ($a1->[$i] ne $a2->[$i]) {
      return 0;
    }
    $i++;
  }
  return (@$a1 == @$a2);
}
sub diff_nums {
  my ($gotaref, $wantaref) = @_;
  my $diff;
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
      if (defined $diff) {
        return "$diff, and more diff";
      }
      $diff = "different pos=$i got=".(defined $got ? $got : '[undef]')
        ." want=".(defined $want ? $want : '[undef]');
    }
    unless ($got =~ /^[0-9.-]+$/) {
      if (defined $diff) {
        return "$diff, and more diff";
      }
      $diff = "not a number pos=$i got='$got'";
    }
    unless ($want =~ /^[0-9.-]+$/) {
      if (defined $diff) {
        return "$diff, and more diff";
      }
      $diff = "not a number pos=$i want='$want'";
    }
    if ($got != $want) {
      if (defined $diff) {
        # $diff .= ",\n";
        return "$diff, and more diff";
      }
      $diff .= "different pos=$i numbers got=$got want=$want";
    }
  }
  return $diff;
}


#------------------------------------------------------------------------------
# A072030 - subtraction steps for gcd(x,y) by triangle rows
{
  my $anum = q{A072030};
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $skip;
  my @got;
  my $diff;
  if ($bvalues) {
    require Math::PlanePath::PyramidRows;
    my $path = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
    my $triangle = Math::PlanePath::PyramidRows->new (step => 1);
    for (my $n = $triangle->n_start; @got < @$bvalues; $n++) {
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
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..30]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..30]));
    }
  }
  skip (! $bvalues,
        $diff, undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A072031 - row sums of A072030 subtraction steps for gcd(x,y) by rows
{
  my $anum = q{A072031};
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $skip;
  my @got;
  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::RationalsTree->new(tree_type => 'SB');
    for (my $y = 2; @got < @$bvalues; $y++) {
      my $total = -1;   # gcd(1,Y) taking 0 steps, maybe
      for (my $x = 1; $x < $y; $x++) {
        my $gcd = gcd($x,$y);
        my $n = $path->xy_to_n($x/$gcd,$y/$gcd);
        die unless defined $n;
        $total += $path->tree_n_to_depth($n);
      }
      push @got, $total+1;
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..30]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..30]));
    }
  }
  skip (! $bvalues,
        $diff, undef,
        "$anum");
}


#------------------------------------------------------------------------------
# A154436 -- permutation Bird->HCS, lamplighter inverse

{
  my $anum = 'A154436';
  my $cs  = Math::PlanePath::RationalsTree->new (tree_type => 'HCS');
  my $bird  = Math::PlanePath::RationalsTree->new (tree_type => 'Bird');
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got = (0);  # initial 0
  if ($bvalues) {
    for (my $n = $bird->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $bird->n_to_xy($n);
      push @got, $cs->xy_to_n($x,$y);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..30]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..30]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A003188 -- permutation SB->HCS, Gray code shift+xor

{
  my $anum = 'A003188';
  my $cs  = Math::PlanePath::RationalsTree->new (tree_type => 'HCS');
  my $sb  = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got = (0);  # initial 0
  if ($bvalues) {
    for (my $n = $sb->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $sb->n_to_xy($n);
      push @got, $cs->xy_to_n($x,$y);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..30]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..30]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A006068 -- permutation HCS->SB, Gray code inverse

{
  my $anum = 'A006068';
  my $cs  = Math::PlanePath::RationalsTree->new (tree_type => 'HCS');
  my $sb  = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got = (0);  # initial 0
  if ($bvalues) {
    for (my $n = $cs->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $cs->n_to_xy($n);
      push @got, $sb->xy_to_n($x,$y);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..30]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..30]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A154435 -- permutation HCS->Bird, lamplighter

{
  my $anum = 'A154435';
  my $cs  = Math::PlanePath::RationalsTree->new (tree_type => 'HCS');
  my $bird  = Math::PlanePath::RationalsTree->new (tree_type => 'Bird');
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got = (0);  # initial 0
  if ($bvalues) {
    for (my $n = $cs->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $cs->n_to_xy($n);
      push @got, $bird->xy_to_n($x,$y);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..30]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..30]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A153036 -- SB integer part floor(X/Y)

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
  my $anum = 'A153036';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
  my @got;
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, int($x/$y);
    }
    $diff = diff_nums(\@got, $bvalues);
      if ($diff) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..30]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..30]));
      }
  }
  skip (! $bvalues, $diff, undef, "$anum -- SB integer part");
}

#------------------------------------------------------------------------------
# Stern diatomic A002487

{
  my $anum = 'A002487';

  # A002487 -- L denominators, L doesn't have initial 0,1 of diatomic
  {
    my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
    my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'L');
    my $diff;
    if ($bvalues) {
      my @got = (0,1);
      for (my $n = $path->n_start; @got < @$bvalues; $n++) {
        my ($x, $y) = $path->n_to_xy ($n);
        push @got, $y;
      }
      $diff = diff_nums(\@got, $bvalues);
      if ($diff) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..30]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..30]));
      }
    }
    skip (! $bvalues, $diff, undef, "$anum -- L numerators");
  }

  # A002487 -- CW numerators, is Stern diatomic
  {
    my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
    my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
    my @got;
    if ($bvalues) {
      shift @$bvalues; # drop initial value=0 from oeis
      for (my $n = $path->n_start; @got < @$bvalues; $n++) {
        my ($x, $y) = $path->n_to_xy ($n);
        push @got, $x;
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum -- CW tree numerators as Stern diatomic");
  }

  # A002487 -- CW denominators are Stern diatomic
  {
    my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
    my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
    my @got;
    if ($bvalues) {
      push @got,0,1; # extra initial
      for (my $n = $path->n_start; @got < @$bvalues; $n++) {
        my ($x, $y) = $path->n_to_xy ($n);
        push @got, $y;
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum -- CW tree denominators as Stern diatomic");
  }
}

#------------------------------------------------------------------------------
# A071585 -- HCS num+den

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'HCS');
  my $anum = 'A071585';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got = (1);  # extra initial 1/1 then Rat+1
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $x+$y;
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..30]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..30]));
    }
  }
  skip (! $bvalues, $diff, undef, "$anum");
}

#------------------------------------------------------------------------------
# A071766 -- HCS denominators

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'HCS');
  my $anum = 'A071766';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got = (1);  # extra initial 1/1
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $y;
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..30]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..30]));
    }
  }
  skip (! $bvalues, $diff, undef, "$anum");
}

#------------------------------------------------------------------------------
# A059893 -- permutation CW<->SB, bit reversal

{
  my $anum = 'A059893';
  my $sb  = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
  my $cw  = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  {
    my @got;
    if ($bvalues) {
      for (my $n = $cw->n_start; @got < @$bvalues; $n++) {
        my ($x, $y) = $cw->n_to_xy($n);
        push @got, $sb->xy_to_n($x,$y);
      }
      if (! numeq_array(\@got, $bvalues)) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..30]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..30]));
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum");
  }
  {
    my @got;
    if ($bvalues) {
      for (my $n = $sb->n_start; @got < @$bvalues; $n++) {
        my ($x, $y) = $sb->n_to_xy($n);
        push @got, $cw->xy_to_n($x,$y);
      }
      if (! numeq_array(\@got, $bvalues)) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..30]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..30]));
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum");
  }
}

#------------------------------------------------------------------------------
# A153153 -- permutation CW->AYT

{
  my $anum = 'A153153';
  my $ayt  = Math::PlanePath::RationalsTree->new (tree_type => 'AYT');
  my $cw  = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got = (0);  # initial 0
  if ($bvalues) {
    for (my $n = $cw->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $cw->n_to_xy($n);
      push @got, $ayt->xy_to_n($x,$y);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..30]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..30]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A153154 -- permutation AYT->CW

{
  my $anum = 'A153154';
  my $ayt  = Math::PlanePath::RationalsTree->new (tree_type => 'AYT');
  my $cw  = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got = (0);  # initial 0
  if ($bvalues) {
    for (my $n = $ayt->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $ayt->n_to_xy($n);
      push @got, $cw->xy_to_n($x,$y);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..30]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..30]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}


#------------------------------------------------------------------------------
# A154437 -- permutation AYT->Drib

{
  my $anum = 'A154437';
  my $drib  = Math::PlanePath::RationalsTree->new (tree_type => 'Drib');
  my $ayt  = Math::PlanePath::RationalsTree->new (tree_type => 'AYT');
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got = (0);  # initial 0
  if ($bvalues) {
    for (my $n = $ayt->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $ayt->n_to_xy($n);
      push @got, $drib->xy_to_n($x,$y);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..30]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..30]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}


#------------------------------------------------------------------------------
# A154438 -- permutation Drib->AYT

{
  my $anum = 'A154438';
  my $ayt  = Math::PlanePath::RationalsTree->new (tree_type => 'AYT');
  my $drib  = Math::PlanePath::RationalsTree->new (tree_type => 'Drib');
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got = (0);  # initial 0
  if ($bvalues) {
    for (my $n = $drib->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $drib->n_to_xy($n);
      push @got, $ayt->xy_to_n($x,$y);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..30]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..30]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}


#------------------------------------------------------------------------------
# A061547 -- pos of frac F(n)/F(n+1) in Stern diatomic, is CW N

# F(n)/F(n+1) in CW, extra initial 0
{
  my $anum = 'A061547';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum, max_count => 100);
  {
    my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
    my @got = (0);  # extra initial 0 in seq A061547
    if ($bvalues) {
      require Math::BigInt;
      my $f1 = Math::BigInt->new(1);
      my $f0 = Math::BigInt->new(1);
      while (@got < @$bvalues) {
        push @got, $path->xy_to_n ($f0, $f1);
        ($f1,$f0) = ($f1+$f0,$f1);
      }
      if (! numeq_array(\@got, $bvalues)) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..30]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..30]));
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum pos F(n)/F(n+1) in Stern");
  }

  # Y/1 in Drib, extra initial 0 in A061547
  {
    my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'Drib');
    my @got = (0); # extra initial 0 in A061547
    if ($bvalues) {
      for (my $y = Math::BigInt->new(1); @got < @$bvalues; $y++) {
        push @got, $path->xy_to_n (1, $y);
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum");
  }
}

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
#     for (my $n = $diag->n_start; @got < @$bvalues; $n++) {
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
# A088696 -- length of continued fraction of SB fractions

{
  my $anum = 'A088696';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $skip;
  my @got;
  my $diff;
  if (! $bvalues) {
    $skip = "$anum not available";
  } elsif (! eval { require Math::ContinuedFraction; 1 }) {
    $skip = "$anum - Math::ContinuedFraction not available";
    MyTestHelpers::diag ($skip);
  } else {
    my $path = Math::PlanePath::RationalsTree->new(tree_type => 'SB');
  OUTER: for (my $k = 1; @got < @$bvalues; $k++) {
      foreach my $n (2**$k .. 2**$k + 2**($k-1) - 1) {
        my ($x,$y) = $path->n_to_xy ($n);
        my $cf = Math::ContinuedFraction->from_ratio($x,$y);
        my $cfaref = $cf->to_array;
        my $cflen = scalar(@$cfaref);
        push @got, $cflen-1;  # -1 to skip initial 0 term in $cf

        ### cf: "n=$n xy=$x/$y cflen=$cflen ".$cf->to_ascii
        last OUTER if @got >= @$bvalues;
      }
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..30]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..30]));
    }
  }
  skip (! $bvalues,
        $diff, undef,
        "$anum - SB continued fraction length");
}

#------------------------------------------------------------------------------
# A000975 -- 010101 without consecutive equal bits, Bird tree X=1 column

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'Bird');
  my $anum = 'A000975';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum, max_count => 100);
  my @got;
  if ($bvalues) {
    push @got, 0;  # extra initial 0 in A000975
    require Math::BigInt;
    for (my $y = Math::BigInt->new(1); @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n (1, $y);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A086893 -- pos of frac F(n+1)/F(n) in Stern diatomic, is CW N

{
  my $anum = 'A086893';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
  my @got;
  if ($bvalues) {
    my $f1 = 1;
    my $f0 = 1;
    while (@got < @$bvalues) {
      push @got, $path->xy_to_n ($f1, $f0);
      ($f1,$f0) = ($f1+$f0,$f1);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A007305 -- SB numerators

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
  my $anum = 'A007305';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    push @got, 0,1;  # extra initial
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $x;
    }
  }
  ### bvalues: join(',',@{$bvalues}[0..10])
  ### got: '    '.join(',',@got[0..10])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- SB tree numerators");
}

#------------------------------------------------------------------------------
# A047679 -- SB denominators

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
  my $anum = 'A047679';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $y;
    }
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- SB tree denominators");
}

#------------------------------------------------------------------------------
# A007306 -- SB num+den

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
  my $anum = 'A007306';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    push @got,1,1; # extra initial
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $x+$y;
    }
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- SB tree num+den");
}


#------------------------------------------------------------------------------
# A070990 -- CW Y-X is Stern diatomic first diffs

{
  my $path = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
  my $anum = 'A070990';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    unshift @$bvalues, 0;   # extra 0 in RationalsTree
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $y - $x;
    }
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- CW tree Y-X as Stern diatomic first diffs");
}

#------------------------------------------------------------------------------
# A162911 -- Drib tree numerators = Bird tree reverse N

{
  my $anum = q{A162911};
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'Bird');
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $path->n_to_xy (bit_reverse ($n));
      push @got, $x;
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- Drib tree numerators by bit reversal");
}

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

{
  my $anum = q{A162912};
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'Bird');
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $path->n_to_xy (bit_reverse ($n));
      push @got, $y;
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- Drib tree denominators by bit reversal");
}


#------------------------------------------------------------------------------
exit 0;
