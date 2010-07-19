#!/usr/bin/perl

# Copyright 2010 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

use 5.010;
use strict;
use warnings;
use Test::More tests => 12;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

require Math::PlanePath::SacksSpiral;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 4;
  is ($Math::PlanePath::SacksSpiral::VERSION, $want_version, 'VERSION variable');
  is (Math::PlanePath::SacksSpiral->VERSION,  $want_version, 'VERSION class method');

  ok (eval { Math::PlanePath::SacksSpiral->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::SacksSpiral->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  my $path = Math::PlanePath::SacksSpiral->new;
  is ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# xy_to_n

{
  my @data = ([ 0,0,  [0] ],
              [ 0.001,0.001,  [0] ],
              [ -0.001,0.001,  [0] ],
              [ 0.001,-0.001,  [0] ],
              [ -0.001,-0.001,  [0] ],
             );
  my $path = Math::PlanePath::SacksSpiral->new;
  foreach my $elem (@data) {
    my ($x, $y, $want_n_aref) = @$elem;
    my @got_n = $path->xy_to_n ($x,$y);
    is_deeply (\@got_n, $want_n_aref, "xy_to_n x=$x y=$y");
  }
}

exit 0;
