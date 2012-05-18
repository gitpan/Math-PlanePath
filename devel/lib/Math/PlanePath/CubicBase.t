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
BEGIN { plan tests => 10 }

use lib 't',                    'devel/lib';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Devel::Comments;

require Math::PlanePath::CubicBase;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 74;
  ok ($Math::PlanePath::CubicBase::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::CubicBase->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::CubicBase->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::CubicBase->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::CubicBase->new;
  ok ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      1,
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      1,
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# n_start, x_negative, y_negative

{
  my $path = Math::PlanePath::CubicBase->new;
  ok ($path->n_start, 0, 'n_start()');
  ok ($path->x_negative, 1, 'x_negative()');
  ok ($path->y_negative, 1, 'y_negative()');
}


#------------------------------------------------------------------------------
# X axis claimed in the POD

# sub calc_x_to_n {
#   my ($x, $radix) = @_;
#   my $n = 0;
#   my $power = 1;
#   while ($x) {
#     my $digit = ($x % $radix);
#     $x = int($x/$radix);
# 
#     $n += $power*$digit;
#     $power *= $radix*$radix*$radix;
#   }
#   return $n;
# }
# 
# foreach my $radix (2, 3, 4) {
#   my $path = Math::PlanePath::CubicBase->new (radix => $radix);
#   foreach my $x (0 .. 10) {
#     my $path_n = $path->xy_to_n ($x,0);
#     my $calc_n = calc_x_to_n($x,$radix);
#     ok ($calc_n, $path_n);
#   }
# }

exit 0;
