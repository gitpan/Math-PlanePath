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
use Test::More tests => 9;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

require Math::PlanePath::PixelRings;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 21;
  is ($Math::PlanePath::PixelRings::VERSION, $want_version,
      'VERSION variable');
  is (Math::PlanePath::PixelRings->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::PixelRings->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::PixelRings->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  my $path = Math::PlanePath::PixelRings->new;
  is ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      "VERSION object check $check_version");
}


#------------------------------------------------------------------------------
# x_negative, y_negative

{
  my $path = Math::PlanePath::PixelRings->new;
  is (!! $path->x_negative, 1, 'x_negative()');
  is (!! $path->y_negative, 1, 'y_negative()');
}

exit 0;