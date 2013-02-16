#!/usr/bin/perl -w

# Copyright 2010, 2011, 2012, 2013 Kevin Ryde

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
use List::Util 'sum';
plan tests => 5;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::PyramidRows;

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
# A050873 -- step=1 GCD(X+1,Y+1) by rows

MyOEIS::compare_values
  (anum => 'A050873',
   func => sub {
     my ($count) = @_;
     require Math::PlanePath::GcdRationals;
     my $path = Math::PlanePath::PyramidRows->new (step => 1);
     my @got;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x,$y) = $path->n_to_xy ($n);
       push @got, Math::PlanePath::GcdRationals::_gcd($x+1,$y+1);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A051173 -- step=1 LCM(X+1,Y+1) by rows

MyOEIS::compare_values
  (anum => 'A051173',
   func => sub {
     my ($count) = @_;
     require Math::PlanePath::GcdRationals;
     my $path = Math::PlanePath::PyramidRows->new (step => 1);
     my @got;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x,$y) = $path->n_to_xy ($n);
       push @got, ($x+1) * ($y+1)
         / Math::PlanePath::GcdRationals::_gcd($x+1,$y+1);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A215200 -- Kronecker(n-k,k) by rows, n>=1   1<=k<=n

MyOEIS::compare_values
  (anum => q{A215200},
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::PyramidRows->new (step => 1);
     require Math::NumSeq::PlanePathCoord;
     my @got;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x,$y) = $path->n_to_xy ($n);
       next if $x == 0 || $y == 0;
       my $n = $y;
       my $k = $x;
       push @got, Math::NumSeq::PlanePathCoord::_kronecker_symbol($n-$k,$k);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A004201 -- N for which X>=0, step=2

{
  my $anum = 'A004201';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::PyramidRows->new (step => 2);
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      if ($x >= 0) {
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
# A079824 -- diagonal sums
# cf A079825 with rows numbered alternately left and right
# a(21)=(n/6)*(7*n^2-6*n+5)
{
  my $anum = 'A079824';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got;
    my $path = Math::PlanePath::PyramidRows->new(step=>1);
    for (my $y = 0; @got < @$bvalues; $y++) {
      my @diag;
      foreach my $i (0 .. $y) {
        my $n = $path->xy_to_n($i,$y-$i);
        next if ! defined $n;
        push @diag, $n;
      }
      my $total = sum(@diag);
      push @got, $total;

      # if ($y <= 21) {
      #   MyTestHelpers::diag (join('+',@diag)," = $total");
      # }
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
# A000217 -- step=1 X=Y diagonal, the triangular numbers from 1

{
  my $anum = 'A000217';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got = (0);
  if ($bvalues) {
    my $path = Math::PlanePath::PyramidRows->new (step => 1);
    for (my $i = 0; @got < @$bvalues; $i++) {
      push @got, $path->xy_to_n($i,$i);
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
# A000290 -- step=2 X=Y diagonal, the squares from 1

{
  my $anum = 'A000290';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got = (0);
  if ($bvalues) {
    my $path = Math::PlanePath::PyramidRows->new (step => 2);
    for (my $i = 0; @got < @$bvalues; $i++) {
      push @got, $path->xy_to_n($i,$i);
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
# A167407 -- dDiffXY step=1, extra initial 0

{
  my $anum = 'A167407';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::PyramidRows->new (step => 1);
    @got = (0);
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($dx, $dy) = $path->n_to_dxdy ($n);
      push @got, $dx-$dy;
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
# A010052 -- step=2 dY, 1 at squares

{
  my $anum = 'A010052';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::PyramidRows->new (step => 2);
    push @got, 1;
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      my ($next_x, $next_y) = $path->n_to_xy ($n+1);
      push @got, $next_y - $y;
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
