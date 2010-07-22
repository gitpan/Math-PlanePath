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
use Test::More tests => 19;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

require Math::PlanePath::HexSpiralSkewed;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 5;
  is ($Math::PlanePath::HexSpiralSkewed::VERSION, $want_version, 'VERSION variable');
  is (Math::PlanePath::HexSpiralSkewed->VERSION,  $want_version, 'VERSION class method');

  ok (eval { Math::PlanePath::HexSpiralSkewed->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::HexSpiralSkewed->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  my $path = Math::PlanePath::HexSpiralSkewed->new;
  is ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# xy_to_n

{
  my @data = ([1,    0,0 ],
              [1.25, .25,0 ],
              [1.5,  .5,0 ],
              [1.75, .75,0 ],

             );
  my $path = Math::PlanePath::HexSpiralSkewed->new;
  foreach my $elem (@data) {
    my ($n, $want_x, $want_y) = @$elem;
    my ($got_x, $got_y) = $path->n_to_xy ($n);
    is ($got_x, $want_x, "x at n=$n");
    is ($got_y, $want_y, "y at n=$n");
  }

  foreach my $elem (@data) {
    my ($want_n, $x, $y) = @$elem;
    $want_n = int ($want_n + 0.5);
    my $got_n = $path->xy_to_n ($x, $y);
    is ($got_n, $want_n, "n at x=$x,y=$y");
  }
}

exit 0;