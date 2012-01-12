#!/usr/bin/perl -w

# Copyright 2010, 2011, 2012 Kevin Ryde

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
BEGIN { plan tests => 11 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::SquareSpiral;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $path = Math::PlanePath::SquareSpiral->new;

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

#------------------------------------------------------------------------------
# A137928 -- N values on diagonal X=1-Y positive and negative
{
  my $anum = 'A137928';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $y = 0; @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n(1-$y,$y);
      last unless @got < @$bvalues;
      if ($y != 0) {
        push @got, $path->xy_to_n(1-(-$y),-$y);
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
        1, "$anum -- X=Y+1 diagonal, positive and negative");
}

#------------------------------------------------------------------------------
# A002061 -- central polygonal numbers, N values on diagonal X=Y pos and neg
{
  my $anum = 'A002061';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $y = 0; @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n($y,$y);
      last unless @got < @$bvalues;
      push @got, $path->xy_to_n(-$y,-$y);
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
        1, "$anum -- X=Y+1 diagonal, positive and negative");
}

#------------------------------------------------------------------------------
# A016814 -- N values (4n+1)^2 on SE diagonal every second square
{
  my $anum = 'A016814';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $i = 0; @got < @$bvalues; $i+=2) {
      push @got, $path->xy_to_n($i,-$i);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X=Y diagonal");
}

# #------------------------------------------------------------------------------
# # A033952 -- AllDigits on negative Y axis
# {
#   my $anum = 'A033952';
#   my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
#   my @got;
#   if ($bvalues) {
#     for (my $y = 0; @got < @$bvalues; $y++) {
#       my $n = $path->xy_to_n (0, -$y);
#       push @got, $n % 10;
#     }
#     ### bvalues: join(',',@{$bvalues}[0..40])
#     ### got: '    '.join(',',@got[0..40])
#   } else {
#     MyTestHelpers::diag ("$anum not available");
#   }
#   skip (! $bvalues,
#         numeq_array(\@got, $bvalues),
#         1, "$anum");
# }
# 
# #------------------------------------------------------------------------------
# # A033953 -- AllDigits starting 0 on negative Y axis
# {
#   my $anum = 'A033953';
#   my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
#   my @got;
#   if ($bvalues) {
#     for (my $x = 0; @got < @$bvalues; $x++) {
#       my $n = $path->xy_to_n ($x, 0);
#       push @got, ($n-1) % 10;
#     }
#   } else {
#     MyTestHelpers::diag ("$anum not available");
#   }
#   skip (! $bvalues,
#         numeq_array(\@got, $bvalues),
#         1, "$anum -- X axis");
# }

#------------------------------------------------------------------------------
# A054556 -- N values on Y axis
{
  my $anum = 'A054556';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $y = 0; @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n(0,$y);
    }
    ### bvalues: join(',',@{$bvalues}[0..20])
    ### got: '    '.join(',',@got[0..20])
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- Y axis");
}

#------------------------------------------------------------------------------
# A054552 -- N values on X axis
{
  my $anum = 'A054552';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $x = 0; @got < @$bvalues; $x++) {
      my $n = $path->xy_to_n ($x, 0);
      push @got, $n;
    }
    ### bvalues: join(',',@{$bvalues}[0..40])
    ### got: '    '.join(',',@got[0..40])
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X axis");
}

#------------------------------------------------------------------------------
# A054567 -- N values on negative X axis
{
  my $anum = 'A054567';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $x = 0; @got < @$bvalues; $x++) {
      my $n = $path->xy_to_n (-$x, 0);
      push @got, $n;
    }
    ### bvalues: join(',',@{$bvalues}[0..40])
    ### got: '    '.join(',',@got[0..40])
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X axis");
}

#------------------------------------------------------------------------------
# A054554 -- N values on X=Y diagonal
{
  my $anum = 'A054554';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $i = 0; @got < @$bvalues; $i++) {
      push @got, $path->xy_to_n($i,$i);
    }
    ### bvalues: join(',',@{$bvalues}[0..20])
    ### got: '    '.join(',',@got[0..20])
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X=Y diagonal");
}

#------------------------------------------------------------------------------
# A054569 -- N values on negative X=Y diagonal
{
  my $anum = 'A054569';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $i = 0; @got < @$bvalues; $i++) {
      push @got, $path->xy_to_n(-$i,-$i);
    }
    ### bvalues: join(',',@{$bvalues}[0..20])
    ### got: '    '.join(',',@got[0..20])
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X=Y diagonal");
}

#------------------------------------------------------------------------------
# A180714 -- coord sum X+Y
{
  my $anum = 'A180714';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      my $sum = $x + $y;
      push @got, $sum;
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- sum coords X+Y");
}

#------------------------------------------------------------------------------
# A068225 -- N at X+1,Y
{
  my $anum = 'A068225';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $path->xy_to_n ($x+1,$y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- sum coords X+Y");
}

# A068226 -- N at X-1,Y
{
  my $anum = 'A068226';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $path->xy_to_n ($x-1,$y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- sum coords X+Y");
}


exit 0;
