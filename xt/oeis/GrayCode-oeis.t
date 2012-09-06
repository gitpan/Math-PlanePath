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

use Test;
plan tests => 29;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::Base::Digits 'digit_split_lowtohigh';
use Math::PlanePath::GrayCode;
use Math::PlanePath::Diagonals;
use Math::PlanePath::Base::Digits
  'digit_join_lowtohigh';

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
# A003159 -- (N+1)/2 of positions of Left turns
{
  my $anum = 'A003159';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::GrayCode->new;

    for (my $n = 2; @got < @$bvalues; $n += 2) {
      if (path_n_turn($path,$n) == 1) {
        push @got, $n/2;
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
        "$anum -- left turns positions");
}

#------------------------------------------------------------------------------
# A036554 -- (N+1)/2 of positions of Left turns
{
  my $anum = 'A036554';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::GrayCode->new;

    for (my $n = 2; @got < @$bvalues; $n += 2) {
      if (path_n_turn($path,$n) == 0) {
        push @got, $n/2;
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
        "$anum -- 180deg turns positions");
}

#------------------------------------------------------------------------------
# A039963 -- Left turns
{
  my $anum = 'A039963';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::GrayCode->new;

    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      push @got, path_n_turn($path,$n);
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
        "$anum -- left turns");
}

#------------------------------------------------------------------------------
# A035263 -- Left turns undoubled, skip N even
{
  my $anum = 'A035263';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::GrayCode->new;

    for (my $n = $path->n_start + 1; @got < @$bvalues; $n += 2) {
      push @got, path_n_turn($path,$n);
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
        "$anum -- left turns undoubled");
}

#------------------------------------------------------------------------------
# A065882 -- low base4 non-zero digit
{
  my $anum = 'A065882';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::GrayCode->new;
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n += 2) {
      push @got, path_n_turn($path,$n);
    }
    foreach (@$bvalues) { $_ %= 2; }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
        "$anum -- left turns undoubled");
}

#------------------------------------------------------------------------------
# A007913 -- Left turns from square free part of N, skip N even
{
  my $anum = q{A007913};  # not xreffed in GrayCode.pm
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::GrayCode->new;
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n += 2) {
      push @got, path_n_turn($path,$n);
    }
    foreach (@$bvalues) { $_ %= 2; }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
        "$anum -- left turns undoubled");
}

# return 1 for left, 0 for right
sub path_n_turn {
  my ($path, $n) = @_;
  my $prev_dir = path_n_dir ($path, $n-1);
  my $dir = path_n_dir ($path, $n);
  my $turn = ($dir - $prev_dir) % 4;
  if ($turn == 1) { return 1; }
  if ($turn == 2) { return 0; }
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


#------------------------------------------------------------------------------
# A163233 -- permutation diagonals sF
{
  my $anum = 'A163233';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'sF');
    my $diagonal_path = Math::PlanePath::Diagonals->new (direction => 'up');

    for (my $n = $diagonal_path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $diagonal_path->n_to_xy ($n);
      my $n = $gray_path->xy_to_n ($x, $y);
      push @got, $n;
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
        "$anum -- diagonals sF");
}

# A163234 -- diagonals sF inverse
{
  my $anum = 'A163234';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got;
    my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'sF');
    my $diagonal_path = Math::PlanePath::Diagonals->new (direction => 'up');

    for (my $n = $gray_path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $gray_path->n_to_xy ($n);
      my $n = $diagonal_path->xy_to_n ($x, $y);
      push @got, $n + $gray_path->n_start - $diagonal_path->n_start;
    }

    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff, undef);
}

#------------------------------------------------------------------------------
# A163235 -- diagonals sF, opposite side start
{
  my $anum = 'A163235';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'sF');
    my $diagonal_path = Math::PlanePath::Diagonals->new (direction => 'down');

    for (my $n = $diagonal_path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $diagonal_path->n_to_xy ($n);
      my $n = $gray_path->xy_to_n ($x, $y);
      push @got, $n;
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

# A163236 -- diagonals sF inverse, opposite side start
{
  my $anum = 'A163236';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $diff;
  if ($bvalues) {
    my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'sF');
    my $diagonal_path = Math::PlanePath::Diagonals->new (direction => 'down');

    for (my $n = $gray_path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $gray_path->n_to_xy ($n);
      my $n = $diagonal_path->xy_to_n ($x, $y);
      push @got, $n + $gray_path->n_start - $diagonal_path->n_start;
    }

    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff, undef);
}

#------------------------------------------------------------------------------
# A163237 -- diagonals sF, same side start, flip base-4 digits 2,3

sub flip_base4_23 {
  my ($n) = @_;
  my @digits = digit_split_lowtohigh($n,4);
  foreach my $digit (@digits) {
    if ($digit == 2) { $digit = 3; }
    elsif ($digit == 3) { $digit = 2; }
  }
  return digit_join_lowtohigh(\@digits,4);
}


{
  my $anum = 'A163237';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'sF');
    my $diagonal_path = Math::PlanePath::Diagonals->new (direction => 'up');

    for (my $n = $diagonal_path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $diagonal_path->n_to_xy ($n);
      my $n = $gray_path->xy_to_n ($x, $y);
      $n = flip_base4_23($n);
      push @got, $n;
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

# A163238 -- inverse
{
  my $anum = 'A163238';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $diff;
  if ($bvalues) {
    my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'sF');
    my $diagonal_path = Math::PlanePath::Diagonals->new (direction => 'up');

    for (my $n = $gray_path->n_start; @got < @$bvalues; $n++) {
      my $n = flip_base4_23($n);
      my ($x, $y) = $gray_path->n_to_xy ($n);
      $n = $diagonal_path->xy_to_n ($x, $y);
      push @got, $n + $gray_path->n_start - $diagonal_path->n_start;
    }

    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff, undef);
}


#------------------------------------------------------------------------------
# A163239 -- diagonals sF, opposite side start, flip base-4 digits 2,3

{
  my $anum = 'A163239';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'sF');
    my $diagonal_path = Math::PlanePath::Diagonals->new (direction => 'down');

    for (my $n = $diagonal_path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $diagonal_path->n_to_xy ($n);
      my $n = $gray_path->xy_to_n ($x, $y);
      $n = flip_base4_23($n);
      push @got, $n;
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

# A163240 -- inverse
{
  my $anum = 'A163240';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $diff;
  if ($bvalues) {
    my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'sF');
    my $diagonal_path = Math::PlanePath::Diagonals->new (direction => 'down');

    for (my $n = $gray_path->n_start; @got < @$bvalues; $n++) {
      my $n = flip_base4_23($n);
      my ($x, $y) = $gray_path->n_to_xy ($n);
      $n = $diagonal_path->xy_to_n ($x, $y);
      push @got, $n + $gray_path->n_start - $diagonal_path->n_start;
    }

    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff, undef);
}

#------------------------------------------------------------------------------
# A163242 -- sF diagonal sums
{
  my $anum = 'A163242';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $gray_path = Math::PlanePath::GrayCode->new
      (apply_type => 'sF');
    for (my $y = 0; @got < @$bvalues; $y++) {
      my $sum = 0;
      foreach my $i (0 .. $y) {
        $sum += $gray_path->xy_to_n ($i, $y-$i);
      }
      push @got, $sum;
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A163478 -- sF diagonal sums, divided by 3

{
  my $anum = 'A163478';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $gray_path = Math::PlanePath::GrayCode->new
      (apply_type => 'sF');
    for (my $y = 0; @got < @$bvalues; $y++) {
      my $sum = 0;
      foreach my $i (0 .. $y) {
        $sum += $gray_path->xy_to_n ($i, $y-$i);
      }
      push @got, $sum / 3;
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A003188 - binary gray reflected
# modular and reflected same in binary

{
  my $anum = 'A003188';
  my $radix = 2;
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  {
    my @got;
    if ($bvalues) {
      for (my $n = 0; @got < @$bvalues; $n++) {
        my $digits = [ digit_split_lowtohigh($n,$radix) ];
        Math::PlanePath::GrayCode::_digits_to_gray_reflected($digits,$radix);
        push @got, digit_join_lowtohigh($digits,$radix);
      }

      if (! numeq_array(\@got, $bvalues)) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum - binary gray reflected");
  }

  {
    my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
    my @got;
    if ($bvalues) {
      for (my $n = 0; @got < @$bvalues; $n++) {
        my $digits = [ digit_split_lowtohigh($n,$radix) ];
        Math::PlanePath::GrayCode::_digits_to_gray_modular($digits,$radix);
        push @got, digit_join_lowtohigh($digits,$radix);
      }

      if (! numeq_array(\@got, $bvalues)) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum - binary gray reflected");
  }
}

# A014550 - binary gray reflected, in binary
{
  my $anum = 'A014550';
  my $radix = 2;
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  {
    my @got;
    if ($bvalues) {
      for (my $n = 0; @got < @$bvalues; $n++) {
        my $digits = [ digit_split_lowtohigh($n,$radix) ];
        Math::PlanePath::GrayCode::_digits_to_gray_reflected($digits,$radix);
        push @got, digit_join_lowtohigh($digits,10);
      }

      if (! numeq_array(\@got, $bvalues)) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum - binary gray, in binary");
  }

  {
    my @got;
    if ($bvalues) {
      for (my $n = 0; @got < @$bvalues; $n++) {
        my $digits = [ digit_split_lowtohigh($n,$radix) ];
        Math::PlanePath::GrayCode::_digits_to_gray_modular($digits,$radix);
        push @got, digit_join_lowtohigh($digits,10);
      }

      if (! numeq_array(\@got, $bvalues)) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum - binary gray, in binary");
  }
}

# A006068 - binary gray reflected inverse
{
  my $anum = 'A006068';
  my $radix = 2;
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  {
    my @got;
    if ($bvalues) {
      for (my $n = 0; @got < @$bvalues; $n++) {
        my $digits = [ digit_split_lowtohigh($n,$radix) ];
        Math::PlanePath::GrayCode::_digits_from_gray_reflected($digits,$radix);
        push @got, digit_join_lowtohigh($digits,$radix);
      }
      if (! numeq_array(\@got, $bvalues)) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum - binary gray inverse");
  }

  {
    my @got;
    if ($bvalues) {
      for (my $n = 0; @got < @$bvalues; $n++) {
        my $digits = [ digit_split_lowtohigh($n,$radix) ];
        Math::PlanePath::GrayCode::_digits_from_gray_modular($digits,$radix);
        push @got, digit_join_lowtohigh($digits,$radix);
      }
      if (! numeq_array(\@got, $bvalues)) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum - binary gray inverse");
  }
}

#------------------------------------------------------------------------------
# A105530 - ternary gray modular

{
  my $anum = 'A105530';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $radix = 3;
  my @got;
  if ($bvalues) {
    for (my $n = 0; @got < @$bvalues; $n++) {
      my $digits = [ digit_split_lowtohigh($n,$radix) ];
      Math::PlanePath::GrayCode::_digits_to_gray_modular($digits,$radix);
      push @got, digit_join_lowtohigh($digits,$radix);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - ternary gray modular");
}

# A105529 - ternary gray modular inverse
{
  my $anum = 'A105529';
  my $radix = 3;
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = 0; @got < @$bvalues; $n++) {
      my $digits = [ digit_split_lowtohigh($n,$radix) ];
      Math::PlanePath::GrayCode::_digits_from_gray_modular($digits,$radix);
      push @got, digit_join_lowtohigh($digits,$radix);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - ternary gray modular inverse");
}

#------------------------------------------------------------------------------
# A128173 - ternary gray reflected
# odd radix to and from are the same

{
  my $anum = 'A128173';
  my $radix = 3;
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  {
    my @got;
    if ($bvalues) {
      for (my $n = 0; @got < @$bvalues; $n++) {
        my $digits = [ digit_split_lowtohigh($n,$radix) ];
        Math::PlanePath::GrayCode::_digits_to_gray_reflected($digits,$radix);
        push @got, digit_join_lowtohigh($digits,$radix);
      }
      if (! numeq_array(\@got, $bvalues)) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum - ternary gray reflected");
  }

  {
    my @got;
    if ($bvalues) {
      for (my $n = 0; @got < @$bvalues; $n++) {
        my $digits = [ digit_split_lowtohigh($n,$radix) ];
        Math::PlanePath::GrayCode::_digits_from_gray_reflected($digits,$radix);
        push @got, digit_join_lowtohigh($digits,$radix);
      }
      if (! numeq_array(\@got, $bvalues)) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum - ternary gray reflected");
  }
}

#------------------------------------------------------------------------------
# A003100 - decimal gray reflected

{
  my $anum = 'A003100';
  my $radix = 10;
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = 0; @got < @$bvalues; $n++) {
      my $digits = [ digit_split_lowtohigh($n,$radix) ];
      Math::PlanePath::GrayCode::_digits_to_gray_reflected($digits,$radix);
      push @got, digit_join_lowtohigh($digits,$radix);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - decimal gray reflected");
}

# A174025 - decimal gray reflected inverse
{
  my $anum = 'A174025';
  my $radix = 10;
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = 0; @got < @$bvalues; $n++) {
      my $digits = [ digit_split_lowtohigh($n,$radix) ];
      Math::PlanePath::GrayCode::_digits_from_gray_reflected($digits,$radix);
      push @got, digit_join_lowtohigh($digits,$radix);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - decimal gray reflected inverse");
}

#------------------------------------------------------------------------------
# A098488 - decimal gray modular

{
  my $anum = 'A098488';
  my $radix = 10;
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = 0; @got < @$bvalues; $n++) {
      my $digits = [ digit_split_lowtohigh($n,$radix) ];
      Math::PlanePath::GrayCode::_digits_to_gray_modular($digits,$radix);
      push @got, digit_join_lowtohigh($digits,$radix);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - decimal gray modular");
}

#------------------------------------------------------------------------------
exit 0;
