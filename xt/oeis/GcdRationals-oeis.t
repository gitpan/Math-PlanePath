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
plan tests => 6;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::GcdRationals;

# uncomment this to run the ### lines
#use Smart::Comments '###';


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
# A000124 - Y axis triangular+1

{
  my $anum = 'A000124';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::GcdRationals->new;
    my @got;
    for (my $y = 1; @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n(1,$y);
    }

    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A000290 - diagonals_down X axis perfect squares

{
  my $anum = 'A000290';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::GcdRationals->new (pairs_order =>
                                                   'diagonals_down');
    my @got = (0);
    for (my $x = 1; @got < @$bvalues; $x++) {
      push @got, $path->xy_to_n($x,1);
    }

    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A033638 - diagonals_down Y axis quarter squares + 1, squares+pronic + 1

{
  my $anum = 'A033638';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::GcdRationals->new (pairs_order =>
                                                   'diagonals_down');
    my @got = (1);
    for (my $y = 1; @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n(1,$y);
    }

    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A002061 - diagonals_up X axis central polygonals

{
  my $anum = 'A002061';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::GcdRationals->new (pairs_order =>
                                                   'diagonals_up');
    my @got = (1);
    for (my $x = 1; @got < @$bvalues; $x++) {
      push @got, $path->xy_to_n($x,1);
    }

    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A002620 - diagonals_up Y axis squares+pronic

{
  my $anum = 'A002620';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::GcdRationals->new (pairs_order =>
                                                   'diagonals_up');
    my @got = (0,0);
    for (my $y = 1; @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n(1,$y);
    }

    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A002522 - diagonals_up Y=X+1 above diagonal squares+1

{
  my $anum = 'A002522';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::GcdRationals->new (pairs_order =>
                                                   'diagonals_up');
    my @got = (1);
    for (my $i = 1; @got < @$bvalues; $i++) {
      push @got, $path->xy_to_n($i,$i+1);
    }

    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
exit 0;
