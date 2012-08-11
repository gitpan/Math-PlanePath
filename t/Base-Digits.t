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
plan tests => 51;

use lib 't','xt';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }

use Math::PlanePath::Base::Digits
  'round_down_pow',
  'bit_split_lowtohigh',
  'digit_split_lowtohigh';


#------------------------------------------------------------------------------
# round_down_pow()

foreach my $elem ([ 1, 1,0 ],
                  [ 2, 1,0 ],
                  [ 3, 3,1 ],
                  [ 4, 3,1 ],
                  [ 5, 3,1 ],

                  [ 8, 3,1 ],
                  [ 9, 9,2 ],
                  [ 10, 9,2 ],

                  [ 26, 9,2 ],
                  [ 27, 27,3 ],
                  [ 28, 27,3 ],
                 ) {
  my ($n, $want_pow, $want_exp) = @$elem;
  my ($got_pow, $got_exp)
    = round_down_pow($n,3);
  ok ($got_pow, $want_pow);
  ok ($got_exp, $want_exp);
}

{
  my $bad = 0;
  foreach my $i (2 .. 200) {
    my $p = 3**$i;
    if ($p+1 <= $p
        || $p-1 >= $p
        || ($p % 3) != 0
        || (($p+1) % 3) != 1
        || (($p-1) % 3) != 2) {
      MyTestHelpers::diag ("round_down_pow(3) tests stop for round-off at i=$i");
      last;
    }

    {
      my $n = $p-1;
      my $want_pow = $p/3;
      my $want_exp = $i-1;
      my ($got_pow, $got_exp)
        = round_down_pow($n,3);
      if ($got_pow != $want_pow
          || $got_exp != $want_exp) {
        MyTestHelpers::diag ("round_down_pow($n,3) i=$i prev got $got_pow,$want_pow want $got_exp,$want_exp");
        $bad++;
      }
    }
    {
      my $n = $p;
      my $want_pow = $p;
      my $want_exp = $i;
      my ($got_pow, $got_exp)
        = round_down_pow($n,3);
      if ($got_pow != $want_pow
          || $got_exp != $want_exp) {
        MyTestHelpers::diag ("round_down_pow($n,3) i=$i exact got $got_pow,$want_pow want $got_exp,$want_exp");
        $bad++;
      }
    }
    {
      my $n = $p+1;
      my $want_pow = $p;
      my $want_exp = $i;
      my ($got_pow, $got_exp) = round_down_pow($n,3);
      if ($got_pow != $want_pow
          || $got_exp != $want_exp) {
        MyTestHelpers::diag ("round_down_pow($n,3) i=$i post $got_pow,$want_pow want $got_exp,$want_exp");
        $bad++;
      }
    }
  }
  ok ($bad,0);
}

#------------------------------------------------------------------------------
# digit_split_lowtohigh()

ok (join(',',digit_split_lowtohigh(0,2)), '');
ok (join(',',digit_split_lowtohigh(13,2)), '1,0,1,1');

{
  my $n = ~0;
  foreach my $radix (2,3,4, 5, 6,7,8,9, 10, 16, 37) {
    my @digits = digit_split_lowtohigh($n,$radix);
    my $lowtwo = $n % ($radix * $radix);
    ok ($digits[0], $lowtwo % $radix);
    ok ($digits[1], int($lowtwo / $radix));
  }
}
{
  my $uv_max = ~0;
  my $ones = 1;
  foreach my $bit (digit_split_lowtohigh($uv_max,2)) {
    $ones &&= $bit;
  }
  ok ($ones, 1);
}
#------------------------------------------------------------------------------
# bit_split_lowtohigh()

ok (join(',',bit_split_lowtohigh(0)), '');
ok (join(',',bit_split_lowtohigh(13)), '1,0,1,1');

{
  my $uv_max = ~0;
  my $ones = 1;
  foreach my $bit (bit_split_lowtohigh($uv_max)) {
    $ones &&= $bit;
  }
  ok ($ones, 1);
}

#------------------------------------------------------------------------------
1;
__END__
