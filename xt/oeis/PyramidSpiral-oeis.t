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
plan tests => 1;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::PyramidSpiral;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $path = Math::PlanePath::PyramidSpiral->new;

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
# A053615 -- distance to pronic is abs(X)

{
  my $anum = 'A053615';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, abs($x);
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

# Not quite, it goes from N=1 to a baseline
#
# #------------------------------------------------------------------------------
# # A214227 -- sum of 4 neighbours
# {
#   my $anum = 'A214227';
#   my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
#   my @got;
#   require Math::Prime::XS;
#   if ($bvalues) {
#     for (my $n = 1; @got < @$bvalues; $n++) {
#       my ($x,$y) = $path->n_to_xy ($n);
#       push @got, ($path->xy_to_n($x+1,$y)
#                   + $path->xy_to_n($x-1,$y)
#                   + $path->xy_to_n($x,$y+1)
#                   + $path->xy_to_n($x,$y-1)
#                  );
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
# A214250 -- sum of 8 neighbours
{
  my $anum = 'A214250';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  require Math::Prime::XS;
  if ($bvalues) {
    for (my $n = 1; @got < @$bvalues; $n++) {
      my ($x,$y) = $path->n_to_xy ($n);
      push @got, ($path->xy_to_n($x+1,$y)
                  + $path->xy_to_n($x-1,$y)
                  + $path->xy_to_n($x,$y+1)
                  + $path->xy_to_n($x,$y-1)
                  + $path->xy_to_n($x+1,$y+1)
                  + $path->xy_to_n($x-1,$y-1)
                  + $path->xy_to_n($x-1,$y+1)
                  + $path->xy_to_n($x+1,$y-1)
                 );
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
exit 0;
