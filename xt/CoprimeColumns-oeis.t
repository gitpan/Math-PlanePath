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
BEGIN { plan tests => 4 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::CoprimeColumns;
use Math::PlanePath::RationalsTree;

# uncomment this to run the ### lines
#use Smart::Comments '###';

my $path = Math::PlanePath::CoprimeColumns->new;

sub numeq_array {
  my ($a1, $a2) = @_;
  if (! ref $a1 || ! ref $a2) {
    return 0;
  }
  while (@$a1 && @$a2) {
    if ($a1->[0] ne $a2->[0]) {
      return 0;
    }
    shift @$a1;
    shift @$a2;
  }
  return (@$a1 == @$a2);
}

sub delete_second_highest_bit {
  my ($n) = @_;
  my $bit = 1;
  my $ret = 0;
  while ($bit <= $n) {
    $ret |= ($n & $bit);
    $bit <<= 1;
  }
  $bit >>= 1;
  $ret &= ~$bit;
  $bit >>= 1;
  $ret |= $bit;
  # ### $ret
  # ### $bit
  return $ret;
}
# ### assert: delete_second_highest_bit(1) == 1
# ### assert: delete_second_highest_bit(2) == 1
### assert: delete_second_highest_bit(4) == 2
### assert: delete_second_highest_bit(5) == 3


#------------------------------------------------------------------------------
# A054427 - permutation coprime columns N -> SB N 

{
  my $anum = 'A054427';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $sb = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
    my $n = 0;
    while (@got < @$bvalues) {
      my ($x,$y) = $path->n_to_xy ($n++);
      ### frac: "$x/$y"
      my $sn = $sb->xy_to_n($x,$y);
      push @got, delete_second_highest_bit($sn) + 1;
    }
    ### bvalues: join(',',@{$bvalues}[0..40])
    ### got: '    '.join(',',@got[0..40])
  } else {
    MyTestHelpers::diag ("$anum not available");
  }

  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A002088 - totient sum along X axis

{
  my $anum = 'A002088';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $good = 1;
  my $count = 0;
  if (! $bvalues) {
    MyTestHelpers::diag ("$anum not available");
  } else {
    for (my $i = 0; $i < @$bvalues; $i++) {
      my $x = $i+1;
      my $want = $bvalues->[$i];
      my $got = $path->xy_to_n($x,1);
      if ($got != $want) {
        MyTestHelpers::diag ("wrong totient sum xy_to_n($x,1)=$got want=$want at i=$i of $filename");
        $good = 0;
      }
      $count++;
    }
  }
  ok ($good, 1, "$anum count $count");
}

#------------------------------------------------------------------------------
# A054431 - by antidiagonals whether coprime

{
  my $anum = 'A054431';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $good = 1;
  my $count = 0;
  if (! $bvalues) {
    MyTestHelpers::diag ("$anum not available");
  } else {
    my $x = 1;
    my $y = 1;
    for (my $i = 0; $i < @$bvalues; $i++) {
      if ($x >= $y) {
        my $want = $bvalues->[$i];
        my $got = Math::PlanePath::CoprimeColumns::_coprime($x,$y);
        $got = ($got ? 1 : 0);
        if ($got != $want) {
          MyTestHelpers::diag ("wrong _coprime($x,$y)=$got want=$want at i=$i of $filename");
          $good = 0;
        }
      }
      $y--;
      $x++;
      if ($y < 1) {
        $y = $x;
        $x = 1;
      }
      $count++;
    }
  }
  ok ($good, 1, "$anum count $count");
}

#------------------------------------------------------------------------------
# A127368 - Y coordinate of coprimes, 0 for non-coprimes

{
  my $anum = 'A127368';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $good = 1;
  my $count = 0;
  if (! $bvalues) {
    MyTestHelpers::diag ("$anum not available");
  } else {
    # last two values of A127368.html wrong way around as of June 2011
    $bvalues->[52] = 0;
    $bvalues->[53] = 9;

    my $x = 1;
    my $y = 1;
    for (my $i = 0; $i < @$bvalues; $i++) {
      my $want = $bvalues->[$i];
      my $got = (Math::PlanePath::CoprimeColumns::_coprime($x,$y)
                 ? $y : 0);
      if ($got != $want) {
        MyTestHelpers::diag ("wrong _coprime($x,$y)=$got want=$want at i=$i of $filename");
        $good = 0;
      }
      $y++;
      if ($y > $x) {
        $x++;
        $y = 1;
      }
      $count++;
    }
  }
  ok ($good, 1, "$anum count $count");
}

exit 0;
