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
plan tests => 8;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::TheodorusSpiral;

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
        return "$diff, and more diff";
      }
      $diff = "different pos=$i numbers got=$got want=$want";
    }
  }
  return $diff;
}



#------------------------------------------------------------------------------
# A172164 -- differences of loop lengths

{
  my $anum = 'A172164';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::TheodorusSpiral->new;
    my $n = $path->n_start + 1;
    my ($prev_x, $prev_y) = $path->n_to_xy ($n);
    my $prev_n = 1;
    my $prev_looplen = 0;
    my $first = 1;
    for ($n++; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      if ($y > 0 && $prev_y < 0) {
        my $looplen = $n-$prev_n;
        if ($first) {
          $first = 0;
        } else {
          push @got, $looplen - $prev_looplen;
        }
        $prev_n = $n;
        $prev_looplen = $looplen;
      }
      ($prev_x, $prev_y) = ($x, $y);
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
# A137515 -- right triangles in n turns
# 16, 53, 109, 185, 280, 395, 531, 685, 860, 1054, 1268, 1502, 1756,
{
  my $anum = 'A137515';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::TheodorusSpiral->new;
    my $n = $path->n_start + 1;
    my ($prev_x, $prev_y) = $path->n_to_xy ($n);
    for ($n++; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      if ($y > 0 && $prev_y < 0) {
        push @got, $n-2;
      }
      ($prev_x, $prev_y) = ($x, $y);
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
# A072895 -- points to complete n revolutions
# 17, 54, 110, 186, 281, 396, 532, 686, 861, 1055, 1269, 1503, 1757,

{
  my $anum = 'A072895';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::TheodorusSpiral->new;
    my $n = $path->n_start + 2;
    my ($prev_x, $prev_y) = $path->n_to_xy ($n);
    for ($n++; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      if ($y >= 0 && $prev_y <= 0) {
        push @got, $n-1;
      }
      ($prev_x, $prev_y) = ($x, $y);
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
