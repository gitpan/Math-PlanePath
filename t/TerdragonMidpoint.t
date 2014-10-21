#!/usr/bin/perl -w

# Copyright 2011, 2012, 2013 Kevin Ryde

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
plan tests => 25;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Devel::Comments;

require Math::PlanePath::TerdragonMidpoint;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 99;
  ok ($Math::PlanePath::TerdragonMidpoint::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::TerdragonMidpoint->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::TerdragonMidpoint->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::TerdragonMidpoint->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::TerdragonMidpoint->new;
  ok ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      1,
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      1,
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# xy_to_n()

{
  my $path = Math::PlanePath::TerdragonMidpoint->new;
  foreach my $elem (
                    [ -1,0,  undef ],
                    [ 0,0,  undef ],
                    [ 1,0,  undef ],
                    [ 2,0,  0 ],
                    [ 3,0,  undef ],
                    
                    [ -1,1,  undef ],
                    [ 0,1,  undef ],
                    [ 1,1,  undef ],
                    [ 2,1,  undef ],
                    [ 3,1,  1 ],
                    [ 4,1,  undef ],
                    
                    [ -1,2,  undef ],
                    [ 0,2,  undef ],
                    [ 1,2,  undef ],
                    [ 2,2,  undef ],
                    [ 3,2,  undef ],
                    [ 4,2,  2 ],
                    [ 5,2,  undef ],

                   ) {
    my ($x,$y, $want_n) = @$elem;
    my $got_n = $path->xy_to_n ($x,$y);
    ok ($got_n, $want_n, "xy_to_n($x,$y)");
  }
}

exit 0;
