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
use Math::BigInt try=>'GMP';
use Test;
plan tests => 17;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::WythoffArray;

# uncomment this to run the ### lines
#use Smart::Comments '###';


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

#------------------------------------------------------------------------------
# A035612 -- X coord, starting 1
{
  my $anum = 'A035612';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::WythoffArray->new;
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $x+1;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
        "$anum");
}

#------------------------------------------------------------------------------
# A035614 -- X coord, starting 0
{
  my $anum = 'A035614';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::WythoffArray->new;
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $x;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
        "$anum");
}

#------------------------------------------------------------------------------
# A019586 -- Y coord
{
  my $anum = 'A019586';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::WythoffArray->new;
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $y;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
        "$anum");
}

#------------------------------------------------------------------------------
# A003603 -- Y+1 coord
{
  my $anum = 'A003603';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::WythoffArray->new;
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $y+1;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
        "$anum");
}

#------------------------------------------------------------------------------
# A139764 -- lowest Zeckendorf term fibonacci value,
#   is X axis value of the column containing n
{
  my $anum = 'A139764';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got;
    my $path = Math::PlanePath::WythoffArray->new;
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $path->xy_to_n($x,0);   # down to axis
    }
    $diff = diff_nums(\@got,$bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff, undef);
}

#------------------------------------------------------------------------------
# A064274 -- inverse perm of by diagonals up from X axis
{
  my $anum = 'A064274';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got = (0);  # extra 0
    require Math::PlanePath::Diagonals;
    my $diagonals  = Math::PlanePath::Diagonals->new (direction => 'up');
    my $wythoff = Math::PlanePath::WythoffArray->new;
    for (my $n = $diagonals->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $wythoff->n_to_xy ($n);
      $x = Math::BigInt->new($x);
      $y = Math::BigInt->new($y);
      push @got, $diagonals->xy_to_n($x,$y);
    }
    $diff = diff_nums(\@got,$bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff, undef);
}

#------------------------------------------------------------------------------
# A003849 -- Fibonacci word
{
  my $anum = 'A003849';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got = (0);
  if ($bvalues) {
    my $path = Math::PlanePath::WythoffArray->new;
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x,$y) = $path->n_to_xy($n);
      push @got, ($x == 0 ? 1 : 0);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
        "$anum");
}

#------------------------------------------------------------------------------
# A000201 -- N+1 for N not on Y axis, spectrum of phi
{
  my $anum = 'A000201';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got = (1);
  if ($bvalues) {
    my $path = Math::PlanePath::WythoffArray->new;
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x,$y) = $path->n_to_xy($n);
      if ($x != 0) {
        push @got, $n+1;
      }
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
        "$anum");
}

#------------------------------------------------------------------------------
# A022342 -- N not on Y axis, even Zeckendorfs
{
  my $anum = 'A022342';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got = (0);
  if ($bvalues) {
    my $path = Math::PlanePath::WythoffArray->new;
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x,$y) = $path->n_to_xy($n);
      if ($x != 0) {
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
        1,
        "$anum");
}

#------------------------------------------------------------------------------
# A001950 -- N+1 of the N's on Y axis, spectrum
{
  my $anum = 'A001950';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::WythoffArray->new;
    for (my $y = 0; @got < @$bvalues; $y++) {
      my $n = $path->xy_to_n(0,$y);
      push @got, $n+1;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
        "$anum");
}

#------------------------------------------------------------------------------
# A083412 -- by diagonals, down from Y axis
{
  my $anum = 'A083412';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    require Math::PlanePath::Diagonals;
    my $diagonals  = Math::PlanePath::Diagonals->new (direction => 'down');
    my $wythoff = Math::PlanePath::WythoffArray->new;
    for (my $n = $diagonals->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $diagonals->n_to_xy ($n);
      push @got, $wythoff->xy_to_n($x,$y);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
        "$anum");
}

#------------------------------------------------------------------------------
# A175004 -- by diagonals, something W-1 and shift ...

# {
#   my $anum = 'A175004';
#   my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
#   my @got;
#   if ($bvalues) {
#     require Math::PlanePath::Diagonals;
#     my $diagonals  = Math::PlanePath::Diagonals->new (direction => 'up');
#     my $wythoff = Math::PlanePath::WythoffArray->new;
#     for (my $n = $diagonals->n_start + 1; @got < @$bvalues; $n++) {
#       my ($x, $y) = $diagonals->n_to_xy ($n);
#       push @got, $wythoff->xy_to_n($x,$y) - 1;
#     }
#     if (! numeq_array(\@got, $bvalues)) {
#       MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
#       MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
#     }
#   }
#   skip (! $bvalues,
#         numeq_array(\@got, $bvalues),
#         1,
#         "$anum");
# }

#------------------------------------------------------------------------------
# A035513 -- by diagonals, up from X axis
{
  my $anum = 'A035513';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got;
    require Math::PlanePath::Diagonals;
    my $diagonals  = Math::PlanePath::Diagonals->new (direction => 'up');
    my $wythoff = Math::PlanePath::WythoffArray->new;
    for (my $n = $diagonals->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $diagonals->n_to_xy ($n);
      $x = Math::BigInt->new($x);
      $y = Math::BigInt->new($y);
      push @got, $wythoff->xy_to_n($x,$y);
    }
    $diff = diff_nums(\@got,$bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff, undef);
}

#------------------------------------------------------------------------------
# A000045 -- N on X axis, Fibonacci numbers
{
  my $anum = 'A000045';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum,
                                                     max_count => 150);
  my @got = (0,1); # initial skipped
  if ($bvalues) {
    my $path = Math::PlanePath::WythoffArray->new;
    require Math::BigInt;
    for (my $x = Math::BigInt->new(0); @got < @$bvalues; $x++) {
      push @got, $path->xy_to_n ($x, 0);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
        "$anum");
}

#------------------------------------------------------------------------------
# A000204 -- N on Y=1 row, Lucas numbers
{
  my $anum = 'A000204';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum,
                                                      max_count => 150);
  my @got = (1, 3); # initial skipped
  if ($bvalues) {
    my $path = Math::PlanePath::WythoffArray->new;
    require Math::BigInt;
    for (my $x = Math::BigInt->new(0); @got < @$bvalues; $x++) {
      push @got, $path->xy_to_n ($x, 1);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
        "$anum");
}

#------------------------------------------------------------------------------
# A035336 -- N in X=1 column (and A066097 is a duplicate)
{
  my $anum = 'A035336';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::WythoffArray->new;
    for (my $y = 0; @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n (1, $y);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
        "$anum");
}

#------------------------------------------------------------------------------
# A003622 -- N on Y axis
{
  my $anum = 'A003622';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::WythoffArray->new;
    for (my $y = 0; @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n (0, $y);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
        "$anum");
}

#------------------------------------------------------------------------------
# A020941 -- N on X=Y diagonal
{
  my $anum = 'A020941';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::WythoffArray->new;
    for (my $i = 0; @got < @$bvalues; $i++) {
      push @got, $path->xy_to_n ($i,$i);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
        "$anum");
}

#------------------------------------------------------------------------------
exit 0;
