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
plan tests => 307;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

use Math::PlanePath::GrayCode;

# uncomment this to run the ### lines
#use Smart::Comments;


sub binary_to_decimal {
  my ($str) = @_;
  my $ret = 0;
  foreach my $digit (split //, $str) {
    $ret = ($ret << 1) + $digit;
  }
  return $ret;
}

#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 73;
  ok ($Math::PlanePath::GrayCode::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::GrayCode->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::GrayCode->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::GrayCode->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");
}


#------------------------------------------------------------------------------
# to/from binary Gray

sub to_gray_reflected {
  my ($n, $radix) = @_;
  my $digits = Math::PlanePath::GrayCode::_digit_split($n,$radix);
  Math::PlanePath::GrayCode::_digits_to_gray_reflected($digits,$radix);
  return Math::PlanePath::GrayCode::_digit_join($digits,$radix);
}
sub from_gray_reflected {
  my ($n, $radix) = @_;
  my $digits = Math::PlanePath::GrayCode::_digit_split($n,$radix);
  Math::PlanePath::GrayCode::_digits_from_gray_reflected($digits,$radix);
  return Math::PlanePath::GrayCode::_digit_join($digits,$radix);
}

sub to_gray_modular {
  my ($n, $radix) = @_;
  my $digits = Math::PlanePath::GrayCode::_digit_split($n,$radix);
  Math::PlanePath::GrayCode::_digits_to_gray_modular($digits,$radix);
  return Math::PlanePath::GrayCode::_digit_join($digits,$radix);
}
sub from_gray_modular {
  my ($n, $radix) = @_;
  my $digits = Math::PlanePath::GrayCode::_digit_split($n,$radix);
  Math::PlanePath::GrayCode::_digits_from_gray_modular($digits,$radix);
  return Math::PlanePath::GrayCode::_digit_join($digits,$radix);
}

{
  my @gray = (binary_to_decimal('00000'),
              binary_to_decimal('00001'),
              binary_to_decimal('00011'),
              binary_to_decimal('00010'),
              binary_to_decimal('00110'),
              binary_to_decimal('00111'),
              binary_to_decimal('00101'),
              binary_to_decimal('00100'),

              binary_to_decimal('01100'),
              binary_to_decimal('01101'),
              binary_to_decimal('01111'),
              binary_to_decimal('01110'),
              binary_to_decimal('01010'),
              binary_to_decimal('01011'),
              binary_to_decimal('01001'),
              binary_to_decimal('01000'),

              binary_to_decimal('11000'),
              binary_to_decimal('11001'),
              binary_to_decimal('11011'),
              binary_to_decimal('11010'),
              binary_to_decimal('11110'),
              binary_to_decimal('11111'),
              binary_to_decimal('11101'),
              binary_to_decimal('11100'),

              binary_to_decimal('10100'),
              binary_to_decimal('10101'),
              binary_to_decimal('10111'),
              binary_to_decimal('10110'),
              binary_to_decimal('10010'),
              binary_to_decimal('10011'),
              binary_to_decimal('10001'),
              binary_to_decimal('10000'),
             );
  ### @gray

  foreach my $i (0 .. $#gray) {
    my $gray = $gray[$i];
    if ($i > 0) {
      my $prev_gray = $gray[$i-1];
      my $xor = $gray ^ $prev_gray;
      ok (is_pow2($xor), 1,
          "at i=$i   $gray ^ $prev_gray = $xor");
    }

    my $got_gray = to_gray_reflected($i,2);
    ok ($got_gray, $gray);
    $got_gray = to_gray_modular($i,2);
    ok ($got_gray, $gray);

    my $got_i = from_gray_reflected($gray,2);
    ok ($got_i, $i);
    $got_i = from_gray_modular($gray,2);
    ok ($got_i, $i);
  }
}

sub is_pow2 {
  my ($n) = @_;
  while (($n & 1) == 0) {
    if ($n == 0) {
      return 0;
    }
    $n >>= 1;
  }
  return ($n == 1);
}

#------------------------------------------------------------------------------
# to/from modular Gray

{
  my @gray = (000,
              001,
              002,
              003,
              004,
              005,
              006,
              007,

              017,
              010,
              011,
              012,
              013,
              014,
              015,
              016,

              026,
              027,
              020,
              021,
              022,
              023,
              024,
              025,

              035,
              036,
              037,
              030,
              031,
              032,
              033,
              034,

              044,
              045,
              046,
              047,
              040,
              041,
              042,
              043,

              053,
              054,
              055,
              056,
              057,
              050,
              051,
              052,

              062,
              063,
              064,
              065,
              066,
              067,
              060,
              061,

              071,
              072,
              073,
              074,
              075,
              076,
              077,
              070,

              0170,
              0171,
              0172,
              0173,
              0174,
              0175,
              0176,
              0177,
             );
  ### @gray

  foreach my $i (0 .. $#gray) {
    my $gray = $gray[$i];

    my $got_gray = to_gray_modular($i,8);
    ok ($got_gray, $gray);

    my $got_i = from_gray_modular($gray,8);
    ok ($got_i, $i);
  }
}

exit 0;