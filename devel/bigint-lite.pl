#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

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
use Devel::TimeThis;
use Math::BigInt::Lite;

{
  {
    my $t = Devel::TimeThis->new('main');
    foreach (1 .. 10000) {
      Math::BigInt::Lite->newXX(123);
    }
  }
  {
    my $t = Devel::TimeThis->new('lite');
    foreach (1 .. 10000) {
      Math::BigInt::Lite->new(123);
    }
  }
  exit 0;
}
