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
BEGIN { plan tests => 1 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::AlternatePaper;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $paper  = Math::PlanePath::AlternatePaper->new;

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

sub xy_is_straight {
  my ($prev_x,$prev_y, $x,$y, $next_x,$next_y) = @_;
  return (($x - $prev_x) == ($next_x - $x)
          && ($y - $prev_y) == ($next_y - $y));
}

# with Y reckoned increasing upwards
sub dxdy_to_direction {
  my ($dx, $dy) = @_;
  if ($dx > 0) { return 0; }  # east
  if ($dx < 0) { return 2; }  # west
  if ($dy > 0) { return 1; }  # north
  if ($dy < 0) { return 3; }  # south
}


#------------------------------------------------------------------------------
# A106665 -- turn 1=left, 0=right, starting from N=1

{
  my $anum = 'A106665';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    my ($n0_x, $n0_y) = $paper->n_to_xy (0);
    my ($prev_x, $prev_y) = $paper->n_to_xy (1);
    my $prev_dir = dxdy_to_direction ($prev_x - $n0_x,
                                      $prev_y - $n0_y);
    foreach my $n (2 .. @$bvalues + 1) {
      my ($x, $y) = $paper->n_to_xy ($n);
      my $dir = dxdy_to_direction ($x - $prev_x,
                                   $y - $prev_y);
      my $turn = ($dir - $prev_dir) % 4;
      if ($turn == 1) {
        push @got, 1;  # left
      } elsif ($turn == 3) {
        push @got, 0;  # right
      } else {
        die "Oops, unrecognised turn";
      }

      ($prev_x,$prev_y) = ($x,$y);
      $prev_dir = $dir;
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
        1, "$anum -- turn 0,1");
}

#------------------------------------------------------------------------------
exit 0;
