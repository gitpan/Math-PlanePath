#!/usr/bin/perl -w

# Copyright 2012 Kevin Ryde

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
use Math::PlanePath::AlternatePaper;
use Test;
plan tests => 11;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;


# uncomment this to run the ### lines
#use Smart::Comments '###';


my $paper = Math::PlanePath::AlternatePaper->new;

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

# return 1 for left, 0 for right
sub path_n_turn {
  my ($path, $n) = @_;
  my $prev_dir = path_n_dir ($path, $n-1);
  my $dir = path_n_dir ($path, $n);
  my $turn = ($dir - $prev_dir) % 4;
  if ($turn == 1) { return 1; }
  if ($turn == 3) { return 0; }
  die "Oops, unrecognised turn";
}
# return 0,1,2,3
sub path_n_dir {
  my ($path, $n) = @_;
  my ($dx,$dy) = $path->n_to_dxdy($n) or die "Oops, no point at ",$n;
  return dxdy_to_dir ($dx, $dy);
}
# return 0,1,2,3, with Y reckoned increasing upwards
sub dxdy_to_dir {
  my ($dx, $dy) = @_;
  if ($dx > 0) { return 0; }  # east
  if ($dx < 0) { return 2; }  # west
  if ($dy > 0) { return 1; }  # north
  if ($dy < 0) { return 3; }  # south
}


# #------------------------------------------------------------------------------
# # A014081 - count 11 pairs, mod 2 is GRS
# {
#   my $anum = 'A014081';
#   my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
#   my @got;
#   if ($bvalues) {
#     foreach (@$bvalues) { $_ %= 2 }
#     for (my $n = $paper->n_start; @got < @$bvalues; $n++) {
#       push @got, path_n_dir($paper,2*$n);;
#     }
#     if (! numeq_array(\@got, $bvalues)) {
#       MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
#       MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
#     }
#   }
#   skip (! $bvalues,
#         numeq_array(\@got, $bvalues),
#         1, "$anum");
# }

#------------------------------------------------------------------------------
# A020985 - Golay/Rudin/Shapiro dX and dY

{
  my $anum = 'A020985';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my @got;
  if ($bvalues) {
    my $prev_x = 0;
    my $prev_y = 0;
    for (my $n = $paper->n_start; @got < @$bvalues; ) {
      {
        my ($dx, $dy) = $paper->n_to_dxdy ($n++);
        push @got, $dx;
      }
      last unless @got < @$bvalues;
      {
        my ($dx, $dy) = $paper->n_to_dxdy ($n++);
        push @got, $dy;
      }
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- dX and dY");
}


#------------------------------------------------------------------------------
# A020991 - position of last occurance of n, last time of X+Y=n

{
  my $anum = 'A020991';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my @count;
    my $target = 1;
    for (my $n = 1; @got < @$bvalues; $n++) {
      my ($x, $y) = $paper->n_to_xy ($n);
      my $d = $x + $y;
      $count[$d]++;
      if ($count[$d] == $d) {
        push @got, $n-1;
        $target++;
      }
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A212591 - position of first occurance of n, first time getting to X+Y=n
# seq    0, 1, 2, 5, 8,  9, 10, 21, 32, 33, 34, 37, 40, 41, 42, 85
# N   0  1  2  3  6, 9, 10, 11, 22, ...
{
  my $anum = 'A212591';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum,
                                                      max_count => 1000);
  my @got;
  if ($bvalues) {
    my $target = 1;
    for (my $n = 1; @got < @$bvalues; $n++) {
      my ($x, $y) = $paper->n_to_xy ($n);
      my $d = $x + $y;
      if ($d == $target) {
        push @got, $n-1;
        $target++;
      }
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A093573+1 - triangle of positions where cumulative=k
#   cumulative A020986 starts n=0 for GRS(0)=0  (A020985)
# 0,
# 1,  3,
# 2,  4,  6,
# 5,  7, 13, 15,
# 8, 12, 14, 16, 26,
# 9, 11, 17, 19, 25, 27
#
# cf diagonals
# 0
# 1
# 2, 4
# 3,7, 5
# 8, 6,14, 16
# 9,13, 15,27, 17

{
  my $anum = 'A093573';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
  OUTER: for (my $sum = 1; ; $sum++) {
      my @n_list;
      foreach my $y (0 .. $sum) {
        my $x = $sum - $y;
        push @n_list, $paper->xy_to_n_list($x,$y);;
      }
      @n_list = sort {$a<=>$b} @n_list;
      foreach my $n (@n_list) {
        last OUTER if @got >= @$bvalues;
        push @got, $n-1;
      }
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X+Y");
}

#------------------------------------------------------------------------------
# A020986 - GRS cumulative is X+Y
#         - and is X coord undoubled except N=0
{
  my $anum = 'A020986';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  {
    my @got;
    if ($bvalues) {
      for (my $n = 1; @got < @$bvalues; $n++) {
        my ($x, $y) = $paper->n_to_xy ($n);
        push @got, $x+$y;
      }
      if (! numeq_array(\@got, $bvalues)) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum -- X+Y");
  }
  {
    my @got;
    if ($bvalues) {
      for (my $n = 2; @got < @$bvalues; $n += 2) {
        my ($x, $y) = $paper->n_to_xy ($n);
        push @got, $x;
      }
      if (! numeq_array(\@got, $bvalues)) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum -- X coordinate undoubled");
  }
}

#------------------------------------------------------------------------------
# A022155 - positions of -1, is S,W steps
{
  my $anum = 'A022155';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $paper->n_start; @got < @$bvalues; $n++) {
      my ($dx,$dy) = $paper->n_to_dxdy($n);
      if ($dx < 0 || $dy < 0) {
        push @got, $n;
      }
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A203463 - positions of 1, is N,E steps
{
  my $anum = 'A203463';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $paper->n_start; @got < @$bvalues; $n++) {
      my ($dx,$dy) = $paper->n_to_dxdy($n);
      if ($dx > 0 || $dy > 0) {
        push @got, $n;
      }
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A020990 - Golay/Rudin/Shapiro * (-1)^k cumulative, is Y coord undoubled,
# except N=0
{
  my $anum = 'A020990';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  {
    my @got;
    if ($bvalues) {
      for (my $n = 2; @got < @$bvalues; $n += 2) {
        my ($x, $y) = $paper->n_to_xy ($n);
        push @got, $y;
      }
      if (! numeq_array(\@got, $bvalues)) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum -- Y coordinate undoubled");
  }
  {
    my @got;
    if ($bvalues) {
      for (my $n = 1; @got < @$bvalues; $n++) {
        my ($x, $y) = $paper->n_to_xy ($n);
        push @got, $x-$y;
      }
      if (! numeq_array(\@got, $bvalues)) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum -- diff X-Y");
  }
}

#------------------------------------------------------------------------------
# A106665 -- turn 1=left, 0=right
#   first turn at N=1 is OFFSET=0 in seq

{
  my $anum = 'A106665';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $paper->n_start + 1; @got < @$bvalues; $n++) {
      push @got, path_n_turn($paper,$n);
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- turn 1=left,0=right");
}

#------------------------------------------------------------------------------

exit 0;
