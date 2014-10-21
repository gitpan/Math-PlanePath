#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

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

## no critic (RequireUseStrict, RequireUseWarnings)
use Math::PlanePath::Rows;
my $path = Math::PlanePath::Rows->new (width => 1000);
$path->n_to_xy(123);
$path->xy_to_n(0,0);
$path->rect_to_n_range(0,0, 1,1);

use Test::More tests => 1;
ok (1, 'Math::PlanePath::Rows load as first thing');
exit 0;
