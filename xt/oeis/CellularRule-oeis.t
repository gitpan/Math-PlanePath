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


# cf A094605 rule 30 period of nth diagonal
#    A094606 log2 of that period
#



use 5.004;
use strict;
use Test;
plan tests => 199;

use lib 't','xt';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }
use MyOEIS;

use Math::PlanePath::CellularRule;

# uncomment this to run the ### lines
#use Smart::Comments '###';


MyTestHelpers::diag ("OEIS dir ",MyOEIS::oeis_dir());

sub streq_array {
  my ($a1, $a2) = @_;
  if (! ref $a1 || ! ref $a2) {
    return 0;
  }
  while (@$a1 && @$a2) {
    if ($a1->[0] ne $a2->[0]) {
      MyTestHelpers::diag ("differ: ", $a1->[0], ' ', $a2->[0]);
      return 0;
    }
    shift @$a1;
    shift @$a2;
  }
  return (@$a1 == @$a2);
}


#------------------------------------------------------------------------------

foreach my $elem
  (
   [ 'A071022',  70, 'bits', 'left' ],
   [ 'A071022', 198, 'bits', 'left' ],
   [ 'A071023',  78, 'bits', 'left' ],
   [ 'A071024',  92, 'bits', 'right' ],
   [ 'A071025', 124, 'bits', 'right' ],
   [ 'A071026', 188, 'bits', 'right' ],
   [ 'A071027', 230, 'bits', 'left' ],
   [ 'A071028',  50, 'bits' ],
   [ 'A071029',  22, 'bits' ],
   [ 'A071030',  54, 'bits' ],
   [ 'A071031',  62, 'bits' ],
   [ 'A071032',  86, 'bits' ],
   [ 'A071033',  94, 'bits' ],
   [ 'A071034', 118, 'bits' ],
   [ 'A071035', 126, 'bits' ],
   [ 'A071036', 150, 'bits' ],  # same as A118110
   [ 'A071037', 158, 'bits' ],
   [ 'A071038', 182, 'bits' ],
   [ 'A071039', 190, 'bits' ],
   [ 'A071040', 214, 'bits' ],
   [ 'A071041', 246, 'bits' ],

   # [ 'A060576', 255, 'bits' ], # homeomorphically irreducibles ...

   [ 'A070909',  28, 'bits', 'right' ],
   [ 'A070909', 156, 'bits', 'right' ],

   [ 'A075437', 110, 'bits' ],

   [ 'A118101',  94, 'bignum' ],
   [ 'A118102',  94, 'bits' ],
   [ 'A118108',  54, 'bignum' ],
   [ 'A118109',  54, 'bits' ],
   [ 'A118110', 150, 'bits' ],
   [ 'A118111', 190, 'bits' ],
   [ 'A118171', 158, 'bignum' ],
   [ 'A118172', 158, 'bits' ],
   [ 'A118173', 188, 'bignum' ],
   [ 'A118174', 188, 'bits' ],
   [ 'A118175', 220, 'bits' ],
   [ 'A118175', 252, 'bits' ],

   [ 'A070887', 110, 'bits', 'left' ],

   [ 'A071042',  90, 'number_of', 0 ],
   [ 'A071043',  22, 'number_of', 0 ],
   [ 'A071044',  22, 'number_of', 1 ],
   [ 'A071045',  54, 'number_of', 0 ],
   [ 'A071046',  62, 'number_of', 0 ],
   [ 'A071047',  62, 'number_of', 1 ],
   [ 'A071049', 110, 'number_of', 1 ],
   [ 'A071048', 110, 'number_of', 0, 'left' ],
   [ 'A071050', 126, 'number_of', 0 ],
   [ 'A071051', 126, 'number_of', 1 ],
   [ 'A071052', 150, 'number_of', 0 ],
   [ 'A071053', 150, 'number_of', 1 ],
   [ 'A071054', 158, 'number_of', 1 ],
   [ 'A071055', 182, 'number_of', 0 ],

   [ 'A038184', 150, 'bignum' ],
   [ 'A038185', 150, 'bignum', 'left' ], # cut after central column

   [ 'A001045',  28, 'bignum' ], # Jacobsthal
   [ 'A110240',  30, 'bignum' ], # cf A074890 some strange form
   [ 'A117998', 102, 'bignum' ],
   [ 'A117999', 110, 'bignum' ],
   [ 'A037576', 190, 'bignum' ],
   [ 'A002450', 250, 'bignum' ],

   [ 'A006977', 230, 'bignum', 'left' ],
   [ 'A078176', 225, 'bignum', 'whole', 'inverse' ],

   [ 'A051023',  30, 'bits', 'centre' ],
   [ 'A070950',  30, 'bits' ],
   [ 'A070951',  30, 'number_of', 0 ],
   [ 'A070952',  30, 'number_of', 1 ],
   [ 'A151929',  30, 'number_of_1s_first_diff' ],
   [ 'A092539',  30, 'bignum_central_column' ],
   [ 'A094603',  30, 'trailing_number_of', 1 ],
   [ 'A094604',  30, 'new_maximum_trailing_number_of', 1 ],

   [ 'A001316',  90, 'number_of', 1 ], # Gould's sequence


   #--------------------------------------------------------------------------
   # Sierpinski triangle, 8 of whole
   
   # rule=60 right half
   [ 'A047999',  60, 'bits', 'right' ], # Sierpinski triangle  in right
   [ 'A001317',  60, 'bignum' ], # Sierpinski triangle right half
   [ 'A075438',  60, 'bits' ], # including 0s in left half

   # rule=102 left half
   [ 'A047999', 102, 'bits', 'left' ],
   [ 'A075439', 102, 'bits' ],

   [ 'A038183',  18, 'bignum' ], # Sierpinski bignums
   [ 'A038183',  26, 'bignum' ],
   [ 'A038183',  82, 'bignum' ],
   [ 'A038183',  90, 'bignum' ],
   [ 'A038183', 146, 'bignum' ],
   [ 'A038183', 154, 'bignum' ],
   [ 'A038183', 210, 'bignum' ],
   [ 'A038183', 218, 'bignum' ],

   [ 'A070886',  18, 'bits' ], # Sierpinski 0/1
   [ 'A070886',  26, 'bits' ],
   [ 'A070886',  82, 'bits' ],
   [ 'A070886',  90, 'bits' ],
   [ 'A070886', 146, 'bits' ],
   [ 'A070886', 154, 'bits' ],
   [ 'A070886', 210, 'bits' ],
   [ 'A070886', 218, 'bits' ],

   #--------------------------------------------------------------------------
   # simple stuff

   # whole solid, values 2^(2n)-1
   [ 'A083420', 151, 'bignum' ], # 8 of
   [ 'A083420', 159, 'bignum' ],
   [ 'A083420', 183, 'bignum' ],
   [ 'A083420', 191, 'bignum' ],
   [ 'A083420', 215, 'bignum' ],
   [ 'A083420', 223, 'bignum' ],
   [ 'A083420', 247, 'bignum' ],
   [ 'A083420', 254, 'bignum' ],
   # and also
   [ 'A083420', 222, 'bignum' ], # 2 of
   [ 'A083420', 255, 'bignum' ],

   # right half solid 2^n-1
   [ 'A000225', 220, 'bignum' ],
   [ 'A000225', 252, 'bignum' ],

   # left half solid, # 2^n-1
   [ 'A000225', 206, 'bignum', 'left' ], # 0xCE
   [ 'A000225', 238, 'bignum', 'left' ], # 0xEE

   # central column only, values all 1s
   [ 'A000012',   4, 'bignum', 'left' ],
   [ 'A000012',  12, 'bignum', 'left' ],
   [ 'A000012',  36, 'bignum', 'left' ],
   [ 'A000012',  44, 'bignum', 'left' ],
   [ 'A000012',  68, 'bignum', 'left' ],
   [ 'A000012',  76, 'bignum', 'left' ],
   [ 'A000012', 100, 'bignum', 'left' ],
   [ 'A000012', 108, 'bignum', 'left' ],
   [ 'A000012', 132, 'bignum', 'left' ],
   [ 'A000012', 140, 'bignum', 'left' ],
   [ 'A000012', 164, 'bignum', 'left' ],
   [ 'A000012', 172, 'bignum', 'left' ],
   [ 'A000012', 196, 'bignum', 'left' ],
   [ 'A000012', 204, 'bignum', 'left' ],
   [ 'A000012', 228, 'bignum', 'left' ],
   [ 'A000012', 236, 'bignum', 'left' ],
   #
   # central column only, central values N=1,2,3,etc all integers
   [ 'A000027', 4, 'central_column_N' ],
   [ 'A000027', 12, 'central_column_N' ],
   [ 'A000027', 36, 'central_column_N' ],
   [ 'A000027', 44, 'central_column_N' ],
   [ 'A000027', 76, 'central_column_N' ],
   [ 'A000027', 108, 'central_column_N' ],
   [ 'A000027', 132, 'central_column_N' ],
   [ 'A000027', 140, 'central_column_N' ],
   [ 'A000027', 164, 'central_column_N' ],
   [ 'A000027', 172, 'central_column_N' ],
   [ 'A000027', 196, 'central_column_N' ],
   [ 'A000027', 204, 'central_column_N' ],
   [ 'A000027', 228, 'central_column_N' ],
   [ 'A000027', 236, 'central_column_N' ],
   #
   # central column only, values 2^k
   [ 'A000079', 4, 'bignum' ],
   [ 'A000079', 12, 'bignum' ],
   [ 'A000079', 36, 'bignum' ],
   [ 'A000079', 44, 'bignum' ],
   [ 'A000079', 68, 'bignum' ],
   [ 'A000079', 76, 'bignum' ],
   [ 'A000079', 100, 'bignum' ],
   [ 'A000079', 108, 'bignum' ],
   [ 'A000079', 132, 'bignum' ],
   [ 'A000079', 140, 'bignum' ],
   [ 'A000079', 164, 'bignum' ],
   [ 'A000079', 172, 'bignum' ],
   [ 'A000079', 196, 'bignum' ],
   [ 'A000079', 204, 'bignum' ],
   [ 'A000079', 228, 'bignum' ],
   [ 'A000079', 236, 'bignum' ],

   # right diagonal only, values all 1, 16 of
   [ 'A000012', 0x10, 'bignum' ],
   [ 'A000012', 0x18, 'bignum' ],
   [ 'A000012', 0x30, 'bignum' ],
   [ 'A000012', 0x38, 'bignum' ],
   [ 'A000012', 0x50, 'bignum' ],
   [ 'A000012', 0x58, 'bignum' ],
   [ 'A000012', 0x70, 'bignum' ],
   [ 'A000012', 0x78, 'bignum' ],
   [ 'A000012', 0x90, 'bignum' ],
   [ 'A000012', 0x98, 'bignum' ],
   [ 'A000012', 0xB0, 'bignum' ],
   [ 'A000012', 0xB8, 'bignum' ],
   [ 'A000012', 0xD0, 'bignum' ],
   [ 'A000012', 0xD8, 'bignum' ],
   [ 'A000012', 0xF0, 'bignum' ],
   [ 'A000012', 0xF8, 'bignum' ],

   # left diagonal only, values 2^k
   [ 'A000079', 0x02, 'bignum', 'left' ],
   [ 'A000079', 0x0A, 'bignum', 'left' ],
   [ 'A000079', 0x22, 'bignum', 'left' ],
   [ 'A000079', 0x2A, 'bignum', 'left' ],
   [ 'A000079', 0x42, 'bignum', 'left' ],
   [ 'A000079', 0x4A, 'bignum', 'left' ],
   [ 'A000079', 0x62, 'bignum', 'left' ],
   [ 'A000079', 0x6A, 'bignum', 'left' ],
   [ 'A000079', 0x82, 'bignum', 'left' ],
   [ 'A000079', 0x8A, 'bignum', 'left' ],
   [ 'A000079', 0xA2, 'bignum', 'left' ],
   [ 'A000079', 0xAA, 'bignum', 'left' ],
   [ 'A000079', 0xC2, 'bignum', 'left' ],
   [ 'A000079', 0xCA, 'bignum', 'left' ],
   [ 'A000079', 0xE2, 'bignum', 'left' ],
   [ 'A000079', 0xEA, 'bignum', 'left' ],
   # bits, characteristic of square
   [ 'A010052', 0x02, 'bits' ],
   [ 'A010052', 0x0A, 'bits' ],
   [ 'A010052', 0x22, 'bits' ],
   [ 'A010052', 0x2A, 'bits' ],
   [ 'A010052', 0x42, 'bits' ],
   [ 'A010052', 0x4A, 'bits' ],
   [ 'A010052', 0x62, 'bits' ],
   [ 'A010052', 0x6A, 'bits' ],
   [ 'A010052', 0x82, 'bits' ],
   [ 'A010052', 0x8A, 'bits' ],
   [ 'A010052', 0xA2, 'bits' ],
   [ 'A010052', 0xAA, 'bits' ],
   [ 'A010052', 0xC2, 'bits' ],
   [ 'A010052', 0xCA, 'bits' ],
   [ 'A010052', 0xE2, 'bits' ],
   [ 'A010052', 0xEA, 'bits' ],
  ) {
  ### $elem
  my ($anum, $rule, $method, @params) = @$elem;
  my $func = main->can($method) || die "Unrecognised method $method";
  &$func ($anum, $rule, @params);
}

#------------------------------------------------------------------------------
# number of 0s or 1s in row

sub number_of {
  my ($anum, $rule, $want_value, $half) = @_;
  $half ||= 'whole';
  my $path = Math::PlanePath::CellularRule->new (rule => $rule);
  my $max_count;
  if ($anum eq 'A070952') {
    $max_count = 400; # shorten
  }
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum number_of");
    if ($anum eq 'A071049') {  # extra initial 0
      push @got, 0;
    }
    if ($anum eq 'A070952') {  # extra initial 0
      push @got, 0;
    }

    for (my $y = 0; @got < @$bvalues; $y++) {
      my $count = 0;
      foreach my $x (($half eq 'right' || $half eq 'centre' ? 0 : -$y)
                     .. ($half eq 'left' || $half eq 'centre' ? 0 : $y)) {
        my $n = $path->xy_to_n ($x, $y);
        my $got_value = (defined $n ? 1 : 0);
        if ($got_value == $want_value) {
          $count++;
        }
      }
      push @got, $count;
    }
    if (! streq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum number of ${want_value}s in rows rule $rule, $half");
}

sub number_of_1s_first_diff {
  my ($anum, $rule) = @_;
  my $path = Math::PlanePath::CellularRule->new (rule => $rule);
  my $max_count;
  if ($anum eq 'A151929') {
    $max_count = 400; # shorten
  }
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum number_of first diffs");
    my $prev_count = 0;
    for (my $y = 0; @got < @$bvalues; $y++) {
      my $count = 0;
      foreach my $x (-$y .. $y) {
        if ($path->xy_to_n ($x, $y)) {
          $count++;
        }
      }
      push @got, $count - $prev_count;
      $prev_count = $count;
    }
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum number of 1s first differences");
}

#------------------------------------------------------------------------------
# number of 0s or 1s in row at the rightmost end

sub trailing_number_of {
  my ($anum, $rule, $want_value) = @_;
  my $path = Math::PlanePath::CellularRule->new (rule => $rule);
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum trailing_number_of");

    for (my $y = 0; @got < @$bvalues; $y++) {
      my $count = 0;
      for (my $x = $y; $x >= -$y; $x--) {
        my $n = $path->xy_to_n ($x, $y);
        my $got_value = (defined $n ? 1 : 0);
        if ($got_value == $want_value) {
          $count++;
        } else {
          last;
        }
      }
      push @got, $count;
    }
    if (! streq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum trailing number of ${want_value}s in rows rule $rule");
}

sub new_maximum_trailing_number_of {
  my ($anum, $rule, $want_value) = @_;
  my $path = Math::PlanePath::CellularRule->new (rule => $rule);
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum new_maximum_trailing_number_of");

    if ($anum eq 'A094604') {
      # new max only at Y=2^k, so limit search
      if ($#$bvalues > 10) {
        $#$bvalues = 10;
      }
    }

    my $prev = 0;
    for (my $y = 0; @got < @$bvalues; $y++) {
      my $count = 0;
      for (my $x = $y; $x >= -$y; $x--) {
        my $n = $path->xy_to_n ($x, $y);
        my $got_value = (defined $n ? 1 : 0);
        if ($got_value == $want_value) {
          $count++;
        } else {
          last;
        }
      }
      if ($count > $prev) {
        push @got, $count;
        $prev = $count;
      }
    }
    if (! streq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# bignum rows

sub bignum {
  my ($anum, $rule, $half, $inverse) = @_;
  $half ||= 'whole';
  $inverse ||= '';    # 'inverse' for bitwise invert

  my $path = Math::PlanePath::CellularRule->new (rule => $rule);
  ### $path

  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum bignum");
    my $y_start = 0;

    if ($anum eq 'A078176') {  # no initial 0 for row 0
      $y_start = 1;
    }
    if ($anum eq 'A000012') {  # trim all-ones
      if ($#$bvalues > 50) { $#$bvalues = 50; }
    }
    if ($anum eq 'A001045') {  # Jacobsthal extra 0,1
      push @got, 0,1;
    }
    if ($anum eq 'A002450') {  # (4^n-1)/3 10101 extra 0 at start
      push @got, 0;
    }
    if ($anum eq 'A000225') {  # 2^n-1 want start from 1
      push @got, 0;
    }

    require Math::BigInt;
    for (my $y = $y_start; @got < @$bvalues; $y++) {
      my $b = Math::BigInt->new(0);
      foreach my $x (($half eq 'right' ? 0 : -$y)
                     .. ($half eq 'left' ? 0 : $y)) {
        my $bit = ($path->xy_is_visited($x,$y) ? 1 : 0);
        if ($inverse eq 'inverse') { $bit ^= 1; }
        $b = 2*$b + $bit;
      }
      push @got, "$b";
    }
    if (! streq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum bignums $half");
}

#------------------------------------------------------------------------------
# 0/1 by rows

sub bits {
  my ($anum, $rule, $half) = @_;
  ### bits(): @_
  $half ||= 'whole';

  my $path = Math::PlanePath::CellularRule->new (rule => $rule);
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum bits");

  OUTER: for (my $y = 0; ; $y++) {
      foreach my $x (($half eq 'right' || $half eq 'centre' ? 0 : -$y)
                     .. ($half eq 'left' || $half eq 'centre' ? 0 : $y)) {
        last OUTER if @got >= @$bvalues;

        push @got, ($path->xy_to_n ($x, $y) ? 1 : 0);
      }
    }
    if (! streq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum 0/1 rows rule $rule, $half");
}


#------------------------------------------------------------------------------
# bignum central vertical column

sub bignum_central_column {
  my ($anum, $rule) = @_;

  my $path = Math::PlanePath::CellularRule->new (rule => $rule);
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum central column bignum");
    require Math::BigInt;
    my $b = Math::BigInt->new(0);
    for (my $y = 0; @got < @$bvalues; $y++) {
      my $bit = ($path->xy_to_n (0, $y) ? 1 : 0);
      $b = 2*$b + $bit;
      push @got, "$b";
    }
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# N values of central vertical column

sub central_column_N {
  my ($anum, $rule) = @_;
  my $path = Math::PlanePath::CellularRule->new (rule => $rule);
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum central column N");
    for (my $y = 0; @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n (0, $y);
    }
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A071029 rule 22 ... ?
#
# 22 = 00010110
#     111 -> 0
#     110 -> 0
#     101 -> 0
#     100 -> 1
#     011 -> 0
#     010 -> 1
#     001 -> 1
#     000 -> 0
#                            0,
#                         1, 0, 1,
#                      0, 1, 0, 1, 0,
#                   1, 0, 1, 0, 1, 0, 1,
#                0, 1, 0, 1, 0, 1, 0, 1, 0,
#             1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1,
#          1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1,
#       0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0,
#    1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0,
# 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0

#                            0,
#                            1,
#                         0, 1, 0,
#                      1, 0, 1, 0, 1,
#                   0, 1, 0, 1, 0, 1, 0,
#                1, 0, 1, 0, 1, 0, 1, 0, 1,
#             0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1,
#          0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0,
#       1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1,
#    0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1,
# 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0

# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0, 1,
# 0

# A071043  Number of 0's in n-th row of triangle in A071029.
#    0, 0, 3, 1, 7, 5, 9, 3, 15, 13, 17, 11, 21, 15, 21, 7, 31, 29, 33, 27,
#    37, 31, 37, 23, 45, 39, 45, 31, 49, 35, 45, 15, 63, 61, 65, 59, 69, 63,
#    69, 55, 77, 71, 77, 63, 81, 67, 77, 47, 93, 87, 93, 79, 97, 83, 93, 63,
#    105, 91, 101, 71, 105, 75, 93, 31, 127, 125, 129
#
# A071044         Number of 1's in n-th row of triangle in A071029.
#    1, 3, 2, 6, 2, 6, 4, 12, 2, 6, 4, 12, 4, 12, 8, 24, 2, 6, 4, 12, 4, 12,
#    8, 24, 4, 12, 8, 24, 8, 24, 16, 48, 2, 6, 4, 12, 4, 12, 8, 24, 4, 12,
#    8, 24, 8, 24, 16, 48, 4, 12, 8, 24, 8, 24, 16, 48, 8, 24, 16, 48, 16,
#    48, 32, 96, 2, 6, 4, 12, 4, 12, 8, 24, 4, 12, 8, 24, 8, 24, 16, 48
#
# *** *** *** ***
#  *   *   *   *
#   ***     ***
#    *       *
#     *** ***
#      *   *
#       ***
#        *


#------------------------------------------------------------------------------
# A071026 rule 188
# rows n+1
#
# 1,
# 1, 0,
# 0, 1, 1,
# 0, 1, 0, 1,
# 1, 1, 1, 1, 0,
# 0, 0, 1, 1, 0, 1,
# 1, 1, 1, 1, 1, 1, 1,
# 1, 0, 1, 1, 0, 0, 1, 1,
# 1, 1, 0, 0, 0, 0, 0, 0, 1,
# 1, 1, 1, 1, 1, 1, 0, 1, 0, 0,
# 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1,
# 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0,
# 0, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0,
# 0, 1, 1, 1, 0, 1, 1, 0
#
# * *** *
# ** ***
# *** *
# ****
# * *
# **
# *


#------------------------------------------------------------------------------
# A071023 rule 78

# *** * * *               
#  ** * * *               
#   *** * *               
#    ** * *               
#     *** *               
#      ** *               
#       ***               
#        **               
#         *               

# 1, 1, 1,
# 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1,
# 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0,
# 1, 1, 1,
# 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0,
# 1, 1, 1, 1, 1, 1, 1, 1, 1,
# 0, 1, 1, 1, 1,
# 0, 1, 1, 1,
# 0, 1, 0,
# 1, 1, 1


#     111 -> 
#     110 -> 
#     101 -> 
#     100 -> 
#     011 -> 
#     010 -> 1
#     001 -> 1
#     000 -> 
#                      1,
#                   1, 1,
#                0, 1, 0,
#             1, 0, 1, 0,
#          1, 0, 1, 0, 1,
#       0, 1, 0, 1, 0, 1,
#    0, 1, 0, 1, 1, 0, 1,
# 0, 1, 0, 1, 0, 1, 0, 1,
# 0, 1, 0, 1, 0, 1, 0, 1, 0,
# 1, 0, 1, 0, 1, 1, 1, 0, 1, 0,
# 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1,
# 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1,
# 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1,
# 1, 1, 0, 1, 0, 1, 1, 1


#------------------------------------------------------------------------------
# A071024 rule 92

# 0, 1, 0, 1, 0,
# 1, 1, 1,
# 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0,
# 1, 1, 1, 1,
# 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0,
# 1, 1, 1,
# 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0,
# 1, 1, 1, 1,
# 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0

#------------------------------------------------------------------------------
# A071027 rule 230

     # * *** *** *               
     #  *** *** **               
     #   * *** ***               
     #    *** ****               
     #     * *** *               
     #      *** **               
     #       * ***               
     #        ****               
     #         * *               
     #          **               
     #           *               

# 1, 1, 1, 1, 1, 1, 0,
# 1, 1, 1, 0,
# 1, 1, 1, 0,
# 1, 1, 1, 0,
# 1, 1, 1, 0,
# 1, 1, 1, 0,
# 1, 1, 1, 1, 0,
# 1, 1, 1, 0,
# 1, 1, 1, 0,
# 1, 1, 1, 0,
# 1, 1, 1, 1, 1, 0,
# 1, 1, 1, 0,
# 1, 1, 1, 0,
# 1, 1, 1, 1, 1, 1, 0,
# 1, 1, 1, 0,
# 1, 1, 1, 0,
# 1, 1, 1, 0,
# 1, 1, 1, 0,
# 1, 1, 1, 0,
# 1, 1, 1, 0,
# 1, 1, 1, 0,
# 1, 1, 1, 1, 0,
# 1

#------------------------------------------------------------------------------
# # A071035 rule 126 sierpinski
#
#          1,
#       1, 0, 1,
#       1, 0, 1,
#    1, 0, 0, 0, 1,
# 1, 1, 1, 0, 1, 0, 1, 1, 1,
# 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1,
# 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 0, 
# 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 
# 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0


#------------------------------------------------------------------------------
# A071022 rule 70,198

# ** * * * *               
#  * * * * *               
#   ** * * *               
#    * * * *               
#     ** * *               
#      * * *               
#       ** *               
#        * *               
#         **               
#          *               

# 1, 0,
# 1, 0,
# 1, 0,
# 1, 0,
# 1, 0,
# 1, 0,
# 1, 0,
# 1, 0,
# 1, 0,
# 1, 0,
# 1, 0,
# 1, 0,
# 1, 1, 1, 1, 1, 1, 0,
# 1, 1, 1, 0,
# 1, 1, 0,
# 1, 0,
# 1, 1, 1, 0,
# 1, 0,
# 1, 1, 0,
# 1, 0,
# 1, 0,
# 1, 1, 1, 0,
# 1, 0,
# 1, 0,
# 1, 1, 0,
# 1, 0,
# 1, 0,
# 1, 0,
# 1, 1, 1, 0,
# 1, 0,
# 1, 0,
# 1, 0,
# 1, 1, 0,
# 1, 0,
# 1, 0,
# 1, 0,
# 1, 0,
# 1, 1, 1, 0,
# 1, 0,
# 1, 0


#------------------------------------------------------------------------------
# A071030 - rule 54, rows 2n+1

#                            0,
#                         1, 0, 1,
#                      0, 1, 0, 1, 0,
#                   1, 0, 1, 0, 1, 0, 1,
#                0, 1, 0, 1, 0, 1, 0, 1, 0,
#             1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1,
#          1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0,
#       0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0,
#    0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1,
# 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0

#------------------------------------------------------------------------------
# A071039 rule 190, rows 2n+1

#                            1,
#                         0, 1, 0,
#                      1, 1, 1, 1, 1,
#                   0, 1, 0, 1, 0, 1, 0,
#                1, 0, 1, 0, 1, 0, 1, 1, 1,
#             1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0,
#          1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1,
#       0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0,
#    1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1,
# 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1


#------------------------------------------------------------------------------
# A071036 rule 150

# ** ** *** ** **        
#  * *   *   * *         
#   *** *** ***          
#    *   *   *           
#     ** * **            
#      * * *             
#       ***              
#        *               

#                            1,
#                         0, 1, 1,
#                      0, 1, 1, 0, 0,
#                   0, 1, 1, 1, 1, 0, 1,
#                0, 1, 1, 0, 0, 0, 1, 1, 1,
#             1, 0, 0, 1, 1, 1, 0, 1, 1, 0, 1,
#          1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1,
#       0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1,
#    0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1,
# 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1

#------------------------------------------------------------------------------

# A071022 rule 70,198
# A071023 rule 78
# A071024 rule 92
# A071025 rule 124
# A071026 rule 188
# A071027 rule 230
# A071028 rule 50   ok
# A071029 rule 22
# A071030 rule 54 -- cf A118109 bits and A118108 bignum
# A071031 rule 62
# A071032 rule 86
# A071033 rule 94
# A071034 rule 118
# A071035 rule 126 sierpinski
# A071036 rule 150
# A071037 rule 158
# A071038 rule 182
# A071039 rule 190
# A071040 rule 214
# A071041 rule 246
#
# A071042 num 0s in A070886 rule 90 sierpinski ok
# A071043 num 0s in A071029 rule 22  ok
# A071044 num 1s in A071029 rule 22  ok
# A071045 num 0s in A071030 rule 54  ok
# A071046 num 0s in A071031 rule 62  ok
# A071047
# A071048
# A071049
# A071050
# A071051 num 1s in A071035 rule 126 sierpinski
# A071052
# A071053
# A071054
# A071055
#
exit 0;
