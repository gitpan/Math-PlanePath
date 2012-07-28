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
use Test;
plan tests => 3;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::DragonMidpoint;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $path = Math::PlanePath::DragonMidpoint->new;

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
# A073089 -- abs(dY), so 1 if step vertical, 0 if horizontal
#            with extra leading 0

{
  my $anum = 'A073089';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  {
    my @got = (0);
    if ($bvalues) {
      my ($prev_x, $prev_y) = $path->n_to_xy (0);
      for (my $n = 1; @got < @$bvalues; $n++) {
        my ($x, $y) = $path->n_to_xy ($n);
        if ($x == $prev_x) {
          push @got, 1;  # vertical
        } else {
          push @got, 0;  # horizontal
        }
        ($prev_x,$prev_y) = ($x,$y);
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

  # A073089_func vs file
  {
    my @got;
    if ($bvalues) {
      for (my $n = 1; @got < @$bvalues; $n++) {
        push @got, A073089_func($n);
      }
      if (! numeq_array(\@got, $bvalues)) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum -- bvalues against A-func");
  }


  # A073089_func vs path
  {
    my ($prev_x, $prev_y) = $path->n_to_xy (0);
    my $n = 0;
    my $bad = 0;
    foreach my $n (0 .. 0x2FFF) {
      my ($x, $y) = $path->n_to_xy ($n);
      my ($nx, $ny) = $path->n_to_xy ($n+1);
      my $path_value = ($x == $nx
                        ? 1   # vertical
                        : 0); # horizontal

      my $a_value = A073089_func($n+2);

      if ($path_value != $a_value) {
        MyTestHelpers::diag ("diff n=$n path=$path_value acalc=$a_value");
        MyTestHelpers::diag ("  xy=$x,$y  nxy=$nx,$ny");
        last if ++$bad > 10;
      }
    }
    ok ($bad, 0, "$anum -- calculated");
  }
}

sub A073089_func {
  my ($n) = @_;
  ### A073089_func: $n
  for (;;) {
    if ($n <= 1) { return 0; }
    if (($n % 4) == 2) { return 0; }
    if (($n % 8) == 7) { return 0; }
    if (($n % 16) == 13) { return 0; }

    if (($n % 4) == 0) { return 1; }
    if (($n % 8) == 3) { return 1; }
    if (($n % 16) == 5) { return 1; }

    if (($n % 8) == 1) {
      $n = ($n-1)/2+1;  # 8n+1 -> 4n+1
      next;
    }
    die "oops";
  }
}

#------------------------------------------------------------------------------
exit 0;
