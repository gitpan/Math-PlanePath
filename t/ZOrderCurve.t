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
use warnings;
use List::Util 'min', 'max';
use Test::More tests => 9;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Smart::Comments '###';

require Math::PlanePath::ZOrderCurve;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 16;
  is ($Math::PlanePath::ZOrderCurve::VERSION, $want_version,
      'VERSION variable');
  is (Math::PlanePath::ZOrderCurve->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::ZOrderCurve->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::ZOrderCurve->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  my $path = Math::PlanePath::ZOrderCurve->new;
  is ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# x_negative, y_negative

{
  my $path = Math::PlanePath::ZOrderCurve->new;
  ok (!$path->x_negative, 'x_negative() instance method');
  ok (!$path->y_negative, 'y_negative() instance method');
}

exit 0;
