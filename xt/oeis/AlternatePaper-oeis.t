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
BEGIN { plan tests => 4 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::AlternatePaper;

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
  my ($x,$y) = $path->n_to_xy($n);
  my ($next_x,$next_y) = $path->n_to_xy($n+1);
  return dxdy_to_dir ($next_x - $x,
                      $next_y - $y);
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
# A020985 - Golay/Rudin/Shapiro dX and dY

{
  my $anum = 'A020985';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    my $prev_x = 0;
    my $prev_y = 0;
    for (my $n = 1; @got < @$bvalues; ) {
      {
        my ($x, $y) = $paper->n_to_xy ($n);
        push @got, $x - $prev_x;
        $prev_x = $x;
        $prev_y = $y;
        $n++;
      }
      last unless @got < @$bvalues;
      {
        my ($x, $y) = $paper->n_to_xy ($n);
        push @got, $y - $prev_y;
        $prev_x = $x;
        $prev_y = $y;
        $n++;
      }
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- dX and dY");
}

#------------------------------------------------------------------------------
# A020986 - Golay/Rudin/Shapiro cumulative is X coord undoubled, except N=0
{
  my $anum = 'A020986';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    for (my $n = 2; @got < @$bvalues; $n += 2) {
      my ($x, $y) = $paper->n_to_xy ($n);
      push @got, $x;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X coordinate undoubled");
}


#------------------------------------------------------------------------------
# A020990 - Golay/Rudin/Shapiro * (-1)^k cumulative, is Y coord undoubled,
# except N=0
{
  my $anum = 'A020990';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    for (my $n = 2; @got < @$bvalues; $n += 2) {
      my ($x, $y) = $paper->n_to_xy ($n);
      push @got, $y;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X coordinate undoubled");
}

#------------------------------------------------------------------------------
# A106665 -- turn 1=left, 0=right, starting from N=1

{
  my $anum = 'A106665';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    for (my $n = $paper->n_start + 1; @got < @$bvalues; $n++) {
      push @got, path_n_turn($paper,$n);
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- turn 1=left,0=right");
}

#------------------------------------------------------------------------------

exit 0;
