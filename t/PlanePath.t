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
use List::Util;
use Test;
BEGIN { plan tests => 22 }

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Devel::Comments;

require Math::PlanePath;

#------------------------------------------------------------------------------
# _is_infinite()

{
  my $pos_infinity = 0;
  my $neg_infinity = 0;
  my $nan = 0;

  my $skip_inf;
  my $skip_nan;
  if (! eval { require Data::Float; 1 }) {
    MyTestHelpers::diag ("Data::Float not available");
    $skip_inf = 'due to Data::Float not available';
    $skip_nan = 'due to Data::Float not available';
  } else {
    if (Data::Float::have_infinite()) {
      $pos_infinity = Data::Float::pos_infinity();
      $neg_infinity = Data::Float::neg_infinity();
    } else {
      $skip_inf = 'due to Data::Float no infinite';
    }

    if (Data::Float::have_nan()) {
      $nan = Data::Float::nan();
      MyTestHelpers::diag ("nan is ",$nan);
    } else {
      $skip_nan = 'due to Data::Float no nan';
    }
  }

  skip ($skip_inf,
        !! Math::PlanePath::_is_infinite($pos_infinity), 1, '_is_infinte() +inf');
  skip ($skip_inf,
        !! Math::PlanePath::_is_infinite($neg_infinity), 1, '_is_infinte() -inf');
  skip ($skip_nan,
        !! Math::PlanePath::_is_infinite($nan), 1, '_is_infinte() nan');
}
{
  require POSIX;
  ok (! Math::PlanePath::_is_infinite(POSIX::DBL_MAX()), 1, '_is_infinte() DBL_MAX');
  ok (! Math::PlanePath::_is_infinite(- POSIX::DBL_MAX()), 1, '_is_infinte() neg DBL_MAX');
}

#------------------------------------------------------------------------------
# _round_nearest()

ok (Math::PlanePath::_round_nearest(-.75),  -1);
ok (Math::PlanePath::_round_nearest(-.5),   0);
ok (Math::PlanePath::_round_nearest(-0.25), 0);

ok (Math::PlanePath::_round_nearest(0.25), 0);
ok (Math::PlanePath::_round_nearest(1.25), 1);
ok (Math::PlanePath::_round_nearest(1.5),  2);
ok (Math::PlanePath::_round_nearest(1.75), 2);
ok (Math::PlanePath::_round_nearest(2),    2);

#------------------------------------------------------------------------------
# _floor()

ok (Math::PlanePath::_floor(-.75),  -1);
ok (Math::PlanePath::_floor(-.5),   -1);
ok (Math::PlanePath::_floor(-0.25), -1);

ok (Math::PlanePath::_floor(0.25), 0);
ok (Math::PlanePath::_floor(0.75), 0);
ok (Math::PlanePath::_floor(1.25), 1);
ok (Math::PlanePath::_floor(1.5),  1);
ok (Math::PlanePath::_floor(1.75), 1);
ok (Math::PlanePath::_floor(2),    2);

#------------------------------------------------------------------------------
exit 0;
