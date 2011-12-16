#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

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
BEGIN { plan tests => 2 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::CellularRule190;

# uncomment this to run the ### lines
#use Smart::Comments '###';


MyTestHelpers::diag ("OEIS dir ",MyOEIS::oeis_dir());

sub streq_array {
  my ($a1, $a2) = @_;
  if (! ref $a1 || ! ref $a2) {
    return 0;
  }
  for (my $i = 0; $i < @$a1 && $i < @$a2; $i++) {
    if ($a1->[$i] ne $a2->[$i]) {
      MyTestHelpers::diag ("differ: $a1->[$i] $a2->[$i] at $i");
      return 0;
    }
  }
  return (@$a1 == @$a2);
}

#------------------------------------------------------------------------------
# A118111 - 0/1 by rows rule 190
{
  my $anum = 'A118111';
  my $path = Math::PlanePath::CellularRule190->new;
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $x = 0;
    my $y = 0;
    foreach my $n (1 .. @$bvalues) {
      push @got, ($path->xy_to_n ($x, $y) ? 1 : 0);
      $x++;
      if ($x > $y) {
        $y++;
        $x = -$y;
      }
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A037576 - rows as rule 190 binary bignums (base 4 periodic ...)
{
  my $anum = 'A037576';
  my $path = Math::PlanePath::CellularRule190->new;
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    require Math::BigInt;
    my $y = 0;
    foreach my $n (1 .. @$bvalues) {
      my $b = 0;
      foreach my $i (0 .. 2*$y+1) {
        if ($path->xy_to_n ($y-$i, $y)) {
          $b += Math::BigInt->new(2) ** $i;
        }
      }
      push @got, "$b";
      $y++;
    }
    ### @got
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A071041 - 0/1 something rule 246, but what ?

# {
#   my $anum = 'A071041';
#   my $path = Math::PlanePath::CellularRule190->new (mirror => 1);
#   my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
#   my @got;
#   if ($bvalues) {
#     my $x = 0;
#     my $y = 0;
#     foreach my $n (1 .. @$bvalues) {
#       push @got, ($path->xy_to_n ($x, $y) ? 1 : 0);
#       $x++;
#       if ($x > $y) {
#         $y++;
#         $x = -$y;
#       }
#     }
#   } else {
#     MyTestHelpers::diag ("$anum not available");
#   }
#   ### bvalues: join(',',@{$bvalues}[0..40])
#   ### got: '    '.join(',',@got[0..40])
#   skip (! $bvalues,
#         streq_array(\@got, $bvalues),
#         1, "$anum");
# }


exit 0;
