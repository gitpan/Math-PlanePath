#!/usr/bin/perl -w

# Copyright 2011, 2012 Kevin Ryde

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
use Math::PlanePath::SierpinskiArrowhead;

# uncomment this to run the ### lines
use Smart::Comments;


{
  # direction sequence
  require Math::NumSeq::PlanePathDelta;
  require Math::BaseCnv;
  my $seq = Math::NumSeq::PlanePathDelta->new
    (planepath => 'SierpinskiArrowhead',
     delta_type => 'TDir6');
  foreach (1 .. 3**4+1) {
    my ($i, $value) = $seq->next;
    # $value %= 6;
    my $i3 = Math::BaseCnv::cnv($i,10,3);
    my $calc = calc_dir6($i);
    print "$i $i3 $value $calc\n";
  }

  sub calc_dir6 {   # works
    my ($n) = @_;
    my $dir = 1;

    while ($n) {
      if (($n % 9) == 0) {
      } elsif (($n % 9) == 1) {
        $dir = 3 - $dir;
      } elsif (($n % 9) == 2) {
        $dir = $dir + 2;

      } elsif (($n % 9) == 3) {
        $dir = 3 - $dir;
      } elsif (($n % 9) == 4) {
      } elsif (($n % 9) == 5) {
        $dir = 1 - $dir;

      } elsif (($n % 9) == 6) {
        $dir = $dir - 2;
      } elsif (($n % 9) == 7) {
        $dir = 1 - $dir;
      } elsif (($n % 9) == 8) {
      }
      $n = int($n/9);
    }
    return $dir % 6;
  }

  sub Xcalc_dir6 {  # works
    my ($n) = @_;
    my $dir = 1;

    while ($n) {
      if (($n % 3) == 0) {
      }
      if (($n % 3) == 1) {
        # mirror
        $dir = 3 - $dir;
      }
      if (($n % 3) == 2) {
        $dir = $dir + 2;
      }
      $n = int($n/3);


      if (($n % 3) == 0) {
      }
      if (($n % 3) == 1) {
        # mirror
        $dir = 3 - $dir;
      }
      if (($n % 3) == 2) {
        $dir = $dir - 2;
      }
      $n = int($n/3);
    }
    return $dir % 6;
  }
  exit 0;
}

{
  # turn sequence

  require Math::NumSeq::PlanePathTurn;
  require Math::BaseCnv;
  my $seq = Math::NumSeq::PlanePathTurn->new
    (planepath => 'SierpinskiArrowhead',
     turn_type => 'Left');
  foreach (1 .. 40) {
    my ($i, $value) = $seq->next;
    my $i3 = Math::BaseCnv::cnv($i,10,3);
    my $calc = calc($i);
    print "$i $i3 $value $calc\n";
  }

  sub calc { # works
    my ($n) = @_;
    my $ret = 1;
    while ($n && ($n % 3) == 0) {  # low zeros
      $ret ^= 1;
      $n = int($n/3);
    }
    $n = int($n/3);
    while ($n) {
      if (($n % 3) == 1) {   # any 1s above lowest non-zero
        $ret ^= 1;
      }
      $n = int($n/3);
    }
    return $ret;
  }

  sub count_digits {
    my ($n) = @_;
    my $count = 0;
    while ($n) {
      $count++;
      $n = int($n/3);
    }
    return $count;
  }
  sub count_ones {
    my ($n) = @_;
    my $count = 0;
    while ($n) {
      $count += (($n % 3) == 1);
      $n = int($n/3);
    }
    return $count;
  }
  exit 0;
}


