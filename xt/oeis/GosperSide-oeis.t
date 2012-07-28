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
plan tests => 12;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::GosperSide;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $path = Math::PlanePath::GosperSide->new;

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

my %dxdy_to_dir = ('2,0' => 0,
                   '1,1' => 1,
                   '-1,1' => 2,
                   '-2,0' => 3,
                   '-1,-1' => 4,
                   '1,-1' => 5);

# return 0 if X,Y's are straight, 2 if left, 1 if right
sub xy_turn_6 {
  my ($prev_x,$prev_y, $x,$y, $next_x,$next_y) = @_;
  my $prev_dx = $x - $prev_x;
  my $prev_dy = $y - $prev_y;
  my $dx = $next_x - $x;
  my $dy = $next_y - $y;

  my $prev_dir = $dxdy_to_dir{"$prev_dx,$prev_dy"};
  if (! defined $prev_dir) { die "oops, unrecognised $prev_dx,$prev_dy"; }

  my $dir = $dxdy_to_dir{"$dx,$dy"};
  if (! defined $dir) { die "oops, unrecognised $dx,$dy"; }

  return ($dir - $prev_dir) % 6;
}

# 0=left, 1=right
sub xy_left_right {
  my ($prev_x,$prev_y, $x,$y, $next_x,$next_y) = @_;
  my $turn = xy_turn_6 ($prev_x,$prev_y, $x,$y, $next_x,$next_y);
  if ($turn == 1) {
    return 0; # left;
  }
  if ($turn == 5) {
    return 1; # right;
  }
  die "unrecognised turn $turn";
}

#------------------------------------------------------------------------------
# A060032 - turn 1=left, 2=right as bignums to 3^level

{
  my $anum = 'A060032';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $level = 0; @got < @$bvalues; $level++) {
      require Math::BigInt;
      my $big = Math::BigInt->new(0);
      foreach my $n (1 .. 3**$level) {
        my $digit = xy_left_right ($path->n_to_xy($n-1),
                                   $path->n_to_xy($n),
                                   $path->n_to_xy($n+1)) + 1;
        $big = 10*$big + $digit;
      }
      push @got, $big;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - 0,1 turns");
}

#------------------------------------------------------------------------------
# A062756 - ternary count 1s, is cumulative turn

{
  my $anum = 'A062756';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $cumulative;
    push @got, 0;  # bvalues starts with an n=0
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      my $turn = xy_left_right ($path->n_to_xy($n-1),
                                $path->n_to_xy($n),
                                $path->n_to_xy($n+1));
      $cumulative += ($turn == 0 ? 1 : -1);
      push @got, $cumulative;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - cumulative turn");
}

#------------------------------------------------------------------------------
# A189640 - morphism turn 1=left, 0=right, extra initial 0

{
  my $anum = 'A189640';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got = (0);
  if ($bvalues) {
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      my $lr = xy_left_right ($path->n_to_xy($n-1),
                              $path->n_to_xy($n),
                              $path->n_to_xy($n+1));
      push @got, $lr;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - morphism 1=left,0=right");
}

#------------------------------------------------------------------------------
# A189673 - morphism turn 0=left, 1=right, extra initial 0

{
  my $anum = 'A189673';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    push @got, 0;
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      my $lr = xy_left_right ($path->n_to_xy($n-1),
                              $path->n_to_xy($n),
                              $path->n_to_xy($n+1));
      push @got, ($lr == 1 ? 0 : 1);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - morphism 1=left,0=right");
}

#------------------------------------------------------------------------------
# A137893 - morphism turn 0=left, 1=right

{
  my $anum = 'A137893';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      my $lr = xy_left_right ($path->n_to_xy($n-1),
                              $path->n_to_xy($n),
                              $path->n_to_xy($n+1));
      push @got, ($lr == 1 ? 0 : 1);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - morphism 1=left,0=right");
}

#------------------------------------------------------------------------------
# A080846 - turn 0=left, 1=right

{
  my $anum = 'A080846';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      push @got, xy_left_right ($path->n_to_xy($n-1),
                                $path->n_to_xy($n),
                                $path->n_to_xy($n+1));
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - turn 0=left,1=right");
}

#------------------------------------------------------------------------------
# A060236 - turn 1=left, 2=right

{
  my $anum = 'A060236';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      push @got, xy_left_right ($path->n_to_xy($n-1),
                                $path->n_to_xy($n),
                                $path->n_to_xy($n+1)) + 1;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - turn 1=left,2=right");
}

#------------------------------------------------------------------------------
# A038502 - taken mod 3 is 1=left, 2=right

{
  my $anum = 'A038502';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    @$bvalues = map { $_ % 3 } @$bvalues;
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      push @got, xy_left_right ($path->n_to_xy($n-1),
                                $path->n_to_xy($n),
                                $path->n_to_xy($n+1)) + 1;
    }
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - taken mod 3 for 0,1 turns");
}

#------------------------------------------------------------------------------
# A026225 - positions of left turns

{
  my $anum = 'A026225';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  {
    my @got;
    if ($bvalues) {
        for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
        if (xy_left_right ($path->n_to_xy($n-1),
                           $path->n_to_xy($n),
                           $path->n_to_xy($n+1))
            == 0) {
          push @got, $n;
        }
      }
    }
    ### bvalues: join(',',@{$bvalues}[0..20])
    ### got: '    '.join(',',@got[0..20])
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum - left turns");
  }
  {
    my @got;
    if ($bvalues) {
        for (my $n = 1; @got < @$bvalues; $n++) {
        if (digit_above_low_zeros($n) == 1) {
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
          1, "$anum - N where lowest non-zero 1");
  }
}

#------------------------------------------------------------------------------
# A026179 - positions of right turns

{
  my $anum = 'A026179';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  {
    my @got;
    if ($bvalues) {
      push @got, 1;     # extra 1 ...
      for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
        if (xy_left_right ($path->n_to_xy($n-1),
                           $path->n_to_xy($n),
                           $path->n_to_xy($n+1))
            == 1) {
          push @got, $n;
        }
      }
    }
    ### bvalues: join(',',@{$bvalues}[0..20])
    ### got: '    '.join(',',@got[0..20])
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum - right turns");
  }
  {
    my @got = (1);
    if ($bvalues) {
      for (my $n = 1; @got < @$bvalues; $n++) {
        if (digit_above_low_zeros($n) == 2) {
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
          1, "$anum - N where lowest non-zero 2");
  }
}

sub digit_above_low_zeros {
  my ($n) = @_;
  if ($n == 0) {
    return 0;
  }
  while (($n % 3) == 0) {
    $n = int($n/3);
  }
  return ($n % 3);
}

#------------------------------------------------------------------------------
exit 0;
