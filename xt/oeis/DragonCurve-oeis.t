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
plan tests => 18;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::DragonCurve;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $dragon = Math::PlanePath::DragonCurve->new;

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

# return 1 for left, 0 for right
sub path_n_turn {
  my ($path, $n) = @_;
  my $prev_dir = path_n_dir ($path, $n-1);
  my $dir = path_n_dir ($path, $n);
  my $turn = ($dir - $prev_dir) % 4;
  if ($turn == 1) { return 1; }
  if ($turn == 3) { return 0; }
  die "Oops, unrecognised turn";
}
# return 0,1,2,3
sub path_n_dir {
  my ($path, $n) = @_;
  my ($x,$y) = $path->n_to_xy($n)
    or die "Oops, no point at ",$n;
  my ($next_x,$next_y) = $path->n_to_xy($n+1)
    or die "Oops, no point at ",$n+1;
  return dxdy_to_dir ($next_x - $x,
                      $next_y - $y);
}
# return 0,1,2,3, with Y reckoned increasing upwards
sub dxdy_to_dir {
  my ($dx, $dy) = @_;
  if ($dx > 0) { return 0; }  # east
  if ($dx < 0) { return 2; }  # west
  if ($dy > 0) { return 1; }  # north
  if ($dy < 0) { return 3; }  # south
}


#------------------------------------------------------------------------------
# A082410 -- complement reversal, is 1=left, 0=right

{
  my $anum = 'A082410';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    push @got, 0;
    for (my $n = $dragon->n_start + 1; @got < @$bvalues; $n++) {
      push @got, path_n_turn($dragon,$n); # 1=left,0=right
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- reversal complement");
}

#------------------------------------------------------------------------------
# A003460 -- turn 1=left,0=right packed as octal high to low, in 2^n levels

{
  my $anum = 'A003460';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    require Math::BigInt;
    my $bits = Math::BigInt->new(0);
    my $target_n_level = 2;
    my $n = 1;
    while (@got < @$bvalues) {
      if ($n >= $target_n_level) {  # not including n=2^level point itself
        my $octal = $bits->as_oct;  # new enough Math::BigInt
        $octal =~ s/^0+//;  # strip leading "0"
        push @got, Math::BigInt->new("$octal");
        $target_n_level *= 2;
      }

      my $turn = path_n_turn($dragon,$n++);
      my $bit;
      if ($turn == 1) { # left
        $bit = 1;
      } elsif ($turn == 0) { # right
        $bit = 0;
      } else {
        die "Oops, unrecognised turn $turn";
      }
      $bits = 2*$bits + $bit;
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..$#$bvalues]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..$#got]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- relative direction 1,3");
}

#------------------------------------------------------------------------------
# A099545 -- relative direction 1=left, 3=right

{
  my $anum = 'A099545';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $dragon->n_start + 1; @got < @$bvalues; $n++) {
      my $turn = path_n_turn($dragon,$n);
      if ($turn == 1) { # left
        push @got, 1;
      } elsif ($turn == 0) { # right
        push @got, 3;
      } else {
        die "Oops, unrecognised turn $turn";
      }
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- relative direction 1,3");
}


#------------------------------------------------------------------------------
# A007400 - 2 * run lengths, extra initial 0,1

{
  my $anum = 'A007400';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $prev_turn = path_n_turn($dragon,1);
    my $run = 1; # count for initial $prev_turn
    push @got, 0,1; 
    for (my $n = 2; @got < @$bvalues; $n++) {
      my $turn = path_n_turn($dragon,$n);
      if ($turn == $prev_turn) {
        $run++;
      } else {
        push @got, 2 * $run;
        $run = 1; # count for new $turn value
      }
      $prev_turn = $turn;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- 2 * turn run lengths");
}

#------------------------------------------------------------------------------
# A088431 - dragon turns run lengths

{
  my $anum = 'A088431';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $prev_turn = path_n_turn($dragon,1);
    my $run = 1; # count for initial $prev_turn
    for (my $n = 2; @got < @$bvalues; $n++) {
      my $turn = path_n_turn($dragon,$n);
      if ($turn == $prev_turn) {
        $run++;
      } else {
        push @got, $run;
        $run = 1; # count for new $turn value
      }
      $prev_turn = $turn;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- turn run lengths");
}


#------------------------------------------------------------------------------
# A014707 -- relative direction 1=left, 0=right, starting from 1

{
  my $anum = 'A014707';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $dragon->n_start + 1; @got < @$bvalues; $n++) {
      my $turn = path_n_turn($dragon,$n);
      if ($turn == 1) { # left
        push @got, 0;
      } elsif ($turn == 0) { # right
        push @got, 1;
      } else {
        die "Oops, unrecognised turn $turn";
      }
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- relative direction");
}


#------------------------------------------------------------------------------
# A014710 -- relative direction 2=left, 1=right

{
  my $anum = 'A014710';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $dragon->n_start + 1; @got < @$bvalues; $n++) {
      my $turn = path_n_turn($dragon,$n);
      if ($turn == 1) { # left
        push @got, 2;
      } elsif ($turn == 0) { # right
        push @got, 1;
      } else {
        die "Oops, unrecognised turn $turn";
      }
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- relative direction");
}



#------------------------------------------------------------------------------
# A014709 -- relative direction 1=left, 2=right

{
  my $anum = 'A014709';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $dragon->n_start + 1; @got < @$bvalues; $n++) {
      my $turn = path_n_turn($dragon,$n);
      if ($turn == 1) { # left
        push @got, 1;
      } elsif ($turn == 0) { # right
        push @got, 2;
      } else {
        die "Oops, unrecognised turn $turn";
      }
    }

  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- relative direction");
}



#------------------------------------------------------------------------------
# A014577 -- relative direction 0=left, 1=right, starting from 1
#
# cf A059125 is almost but not quite the same, the 8,24,or some such entries
# differ

{
  my $anum = 'A014577';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $dragon->n_start + 1; @got < @$bvalues; $n++) {
      push @got, path_n_turn($dragon,$n);
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- relative direction");
}


#------------------------------------------------------------------------------
# A166242 - doubling/halving, is 2^(total turn)

{
  my $anum = 'A166242';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    push @got, 1;
    my $cumulative = 1;
    for (my $n = $dragon->n_start + 1; @got < @$bvalues; $n++) {
      my $turn = path_n_turn($dragon,$n);
      if ($turn == 1) {
        $cumulative *= 2;
      } elsif ($turn == 0) {
        $cumulative /= 2;
      } else {
        die;
      }
      push @got, $cumulative;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- cumulative turn");
}

#------------------------------------------------------------------------------
# A088748 - dragon cumulative turn +/-1

{
  my $anum = 'A088748';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $cumulative = 1;
    for (my $n = $dragon->n_start + 1; @got < @$bvalues; $n++) {
      push @got, $cumulative;

      my $turn = path_n_turn($dragon,$n);
      if ($turn == 1) { # left
        $cumulative += 1;
      } elsif ($turn == 0) { # right
        $cumulative -= 1;
      } else {
        die "Oops, unrecognised turn $turn";
      }
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- cumulative +/-1 turn");
}

#------------------------------------------------------------------------------
# A112347 - Kronecker -1/n is 1=left,-1=right, extra initial 0

{
  my $anum = 'A112347';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    push @got, 0;
    for (my $n = 1; @got < @$bvalues; $n++) {
      my $turn = path_n_turn($dragon,$n);
      if ($turn == 1) {
        push @got, 1;  # left
      } elsif ($turn == 0) {
        push @got, -1; # right
      } else {
        die;
      }
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- Kronecker -1/n");
}

#------------------------------------------------------------------------------
# A121238 - -1 power something is 1=left,-1=right, extra initial 1
# A088585
# A088567
# A088575

{
  my $anum = 'A121238';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    push @got, 1;
    for (my $n = 1; @got < @$bvalues; $n++) {
      my $turn = path_n_turn($dragon,$n);
      if ($turn == 1) {
        push @got, 1;  # left
      } elsif ($turn == 0) {
        push @got, -1; # right
      } else {
        die;
      }
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- -1 power something");
}


#------------------------------------------------------------------------------
# A164910 - dragon cumulative turn +/-1, then partial sums

{
  my $anum = 'A164910';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $cumulative = 1;
    my $partial_sum = $cumulative;
    for (my $n = $dragon->n_start + 1; @got < @$bvalues; $n++) {
      push @got, $partial_sum;

      my $turn = path_n_turn($dragon,$n);
      if ($turn == 1) { # left
        $cumulative += 1;
      } elsif ($turn == 0) { # right
        $cumulative -= 1;
      } else {
        die "Oops, unrecognised turn $turn";
      }
      $partial_sum += $cumulative;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@$bvalues));
      MyTestHelpers::diag ("got:     ",join(',',@got));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- partial sums cumulative turn");
}



#------------------------------------------------------------------------------
# A038189 -- bit above lowest 1, is 0=left,1=right

{
  my $anum = 'A038189';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    push @got, 0;
    for (my $n = $dragon->n_start + 1; @got < @$bvalues; $n++) {
      my $turn = path_n_turn($dragon,$n);
      if ($turn == 1) { # left
        push @got, 0;
      } elsif ($turn == 0) { # right
        push @got, 1;
      } else {
        die "Oops, unrecognised turn $turn";
      }
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
# A091072 -- N positions of left turns

{
  my $anum = 'A091072';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $dragon->n_start + 1; @got < @$bvalues; $n++) {
      my $turn = path_n_turn($dragon,$n);
      if ($turn == 1) { # left
        push @got, $n;
      } elsif ($turn == 0) { # right
      } else {
        die "Oops, unrecognised turn $turn";
      }
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- left turn N positions");
}

#------------------------------------------------------------------------------
# A126937 -- points numbered as SquareSpiral

{
  my $anum = 'A126937';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    require Math::PlanePath::SquareSpiral;
    my $square  = Math::PlanePath::SquareSpiral->new;

    for (my $n = $dragon->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $dragon->n_to_xy ($n);
      my $square_n = $square->xy_to_n ($x, -$y) - 1;
      push @got, $square_n;
    }
    ### bvalues: join(',',@{$bvalues}[0..40])
    ### got: '    '.join(',',@got[0..40])
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- relative direction");
}


#------------------------------------------------------------------------------
# A005811 -- total rotation, count runs of bits in binary

{
  my $anum = 'A005811';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $cumulative = 0;
    for (my $n = $dragon->n_start + 1; @got < @$bvalues; $n++) {
      push @got, $cumulative;

      my $turn = path_n_turn($dragon,$n);
      if ($turn == 1) { # left
         $cumulative += 1;
      } elsif ($turn == 0) { # right
         $cumulative -= 1;
      } else {
        die "Oops, unrecognised turn $turn";
      }
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- total rotation");
}


#------------------------------------------------------------------------------
exit 0;
