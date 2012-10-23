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
use Math::Prime::XS 0.23 'is_prime'; # version 0.23 fix for 1928099

use Test;
plan tests => 4;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::LCornerTree;

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
# A160410 - total cells parts=4

{
  my $anum = 'A160410';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::LCornerTree->new;
    my @got;
    for (my $depth = 0; @got < @$bvalues; $depth++) {
      push @got, $path->tree_depth_to_n($depth);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@$bvalues));
      MyTestHelpers::diag ("got:     ",join(',',@got));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A161411 - added cells parts=4

{
  my $anum = 'A161411';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::LCornerTree->new;
    my @got;
    for (my $depth = 1; @got < @$bvalues; $depth++) {
      push @got,
        $path->tree_depth_to_n($depth) - $path->tree_depth_to_n($depth-1);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@$bvalues));
      MyTestHelpers::diag ("got:     ",join(',',@got));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A160412 - total cells parts=3

{
  my $anum = 'A160412';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::LCornerTree->new (parts => 3);
    my @got;
    for (my $depth = 0; @got < @$bvalues; $depth++) {
      push @got, $path->tree_depth_to_n($depth);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@$bvalues));
      MyTestHelpers::diag ("got:     ",join(',',@got));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A162349 - added cells parts=3

{
  my $anum = 'A162349';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::LCornerTree->new (parts => 3);
    my @got;
    for (my $depth = 1; @got < @$bvalues; $depth++) {
      push @got,
        $path->tree_depth_to_n($depth) - $path->tree_depth_to_n($depth-1);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@$bvalues));
      MyTestHelpers::diag ("got:     ",join(',',@got));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A130665 - total cells parts=1

{
  my $anum = 'A130665';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::LCornerTree->new (parts => 1);
    my @got;
    for (my $depth = 1; @got < @$bvalues; $depth++) {
      push @got, $path->tree_depth_to_n($depth);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@$bvalues));
      MyTestHelpers::diag ("got:     ",join(',',@got));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A048883 - added cells parts=1

{
  my $anum = 'A048883';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::LCornerTree->new (parts => 1);
    my @got;
    for (my $depth = 1; @got < @$bvalues; $depth++) {
      push @got,
        $path->tree_depth_to_n($depth) - $path->tree_depth_to_n($depth-1);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@$bvalues));
      MyTestHelpers::diag ("got:     ",join(',',@got));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
exit 0;
