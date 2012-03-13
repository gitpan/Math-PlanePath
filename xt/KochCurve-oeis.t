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
BEGIN { plan tests => 6 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::KochCurve;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $koch  = Math::PlanePath::KochCurve->new;

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

# return 1 for left, 0 for right
sub path_n_turn6 {
  my ($path, $n) = @_;
  return xy_turn_6 ($path->n_to_xy($n-1),
                    $path->n_to_xy($n),
                    $path->n_to_xy($n+1));
}

my %dxdy_to_dir = ('2,0' => 0,
                   '1,1' => 1,
                   '-1,1' => 2,
                   '-2,0' => 3,
                   '-1,-1' => 4,
                   '1,-1' => 5);

# return 0 if X,Y's are straight, 2 if left, 1 if right
sub xy_turn_6 {
  my ($prev_x,$prev_y, $x,$y, $next_x,$next_y) = @_;
  my $prev_dx = $x - $prev_x;
  my $prev_dy = $y - $prev_y;
  my $dx = $next_x - $x;
  my $dy = $next_y - $y;

  my $prev_dir = $dxdy_to_dir{"$prev_dx,$prev_dy"};
  if (! defined $prev_dir) { die "oops, unrecognised $prev_dx,$prev_dy"; }

  my $dir = $dxdy_to_dir{"$dx,$dy"};
  if (! defined $dir) { die "oops, unrecognised $dx,$dy"; }

  return ($dir - $prev_dir) % 6;
}

# 0=left, 1=right
sub xy_left_right {
  my ($prev_x,$prev_y, $x,$y, $next_x,$next_y) = @_;
  my $turn = xy_turn_6 ($prev_x,$prev_y, $x,$y, $next_x,$next_y);
  if ($turn == 2) {
    return 0; # left;
  }
  if ($turn == 4) {
    return 1; # right;
  }
  die "unrecognised turn $turn";
}

#------------------------------------------------------------------------------
# A096268 - morphism turn 1=right,0=left

{
  my $anum = 'A096268';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    for (my $n = 1; @got < @$bvalues; $n++) {
      my $turn = path_n_turn6($koch,$n);
      if ($turn == 1) {
        push @got, 0; # left
      } elsif ($turn == 4) {
        push @got, 1; # right
      } else {
        die "unrecognised turn $turn";
      }
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
        1, "$anum -- morphism");
}

#------------------------------------------------------------------------------
# A035263 - morphism turn 1=left,0=right

{
  my $anum = 'A035263';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    for (my $n = 1; @got < @$bvalues; $n++) {
      my $turn = path_n_turn6($koch,$n);
      if ($turn == 1) {
        push @got, 1; # left
      } elsif ($turn == 4) {
        push @got, 0; # right
      } else {
        die "unrecognised turn $turn";
      }
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
        1, "$anum -- morphism");
}

#------------------------------------------------------------------------------
# A029883 - Thue-Morse first diffs

{
  my $anum = 'A029883';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    @$bvalues = map {abs} @$bvalues;
    for (my $n = 1; @got < @$bvalues; $n++) {
      my $turn = path_n_turn6($koch,$n);
      if ($turn == 1) {
        push @got, 1; # left
      } elsif ($turn == 4) {
        push @got, 0; # right
      } else {
        die "unrecognised turn $turn";
      }
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
        1, "$anum -- Thue-Morse first diffs");
}

#------------------------------------------------------------------------------
# A089045 - +/- increment

{
  my $anum = 'A089045';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    @$bvalues = map {abs} @$bvalues;
    for (my $n = 1; @got < @$bvalues; $n++) {
      my $turn = path_n_turn6($koch,$n);
      if ($turn == 1) {
        push @got, 1; # left
      } elsif ($turn == 4) {
        push @got, 0; # right
      } else {
        die "unrecognised turn $turn";
      }
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
        1, "$anum -- increment");
}

#------------------------------------------------------------------------------
# A003159 - N end in even number of 0 bits, is positions of left turn

{
  my $anum = 'A003159';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    for (my $n = 1; @got < @$bvalues; $n++) {
      my $turn = path_n_turn6($koch,$n);
      if ($turn == 1) {
        push @got, $n; # left
      }
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
        1, "$anum -- even number of low 0 bits");
}

#------------------------------------------------------------------------------
# A036554 - N end in odd number of 0 bits, position of right turns

{
  my $anum = 'A036554';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    for (my $n = 1; @got < @$bvalues; $n++) {
      my $turn = path_n_turn6($koch,$n);
      if ($turn == 4) {
        push @got, $n; # right
      }
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
        1, "$anum -- even number of low 0 bits");
}

exit 0;
