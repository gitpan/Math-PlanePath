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
use Test;
BEGIN { plan tests => 75 }

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

require Math::PlanePath::SacksSpiral;


sub numeq_array {
  my ($a1, $a2) = @_;
  if (! ref $a1 || ! ref $a2) {
    return 0;
  }
  while (@$a1 && @$a2) {
    if ($a1->[0] ne $a2->[0]) {
      return 0;
    }
    shift @$a1;
    shift @$a2;
  }
  return (@$a1 == @$a2);
}

#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 32;
  ok ($Math::PlanePath::SacksSpiral::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::SacksSpiral->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::SacksSpiral->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::SacksSpiral->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::SacksSpiral->new;
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
  my $path = Math::PlanePath::SacksSpiral->new;
  ok ($path->n_start, 0, 'n_start()');
  ok (!! $path->x_negative, 1, 'x_negative() instance method');
  ok (!! $path->y_negative, 1, 'y_negative() instance method');
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
    ok (numeq_array (\@got_n, $want_n_aref),
        1, "xy_to_n x=$x y=$y");
  }
}

#------------------------------------------------------------------------------
# _rect_to_radius_range()

{
  foreach my $elem (
                    # single isolated point
                    [ 0,0, 0,0,  0,0 ],
                    [ 1,0, 1,0,  1,1 ],
                    [ -1,0, -1,0,  1,1 ],
                    [ 0,1, 0,1,  1,1 ],
                    [ 0,-1, 0,-1,  1,1 ],

                    [ 0,0, 1,0,  0,1 ],  # strip of x axis
                    [ 1,0, 0,0,  0,1 ],
                    [ 6,0, 3,0,   3,6 ],
                    [ -6,0, -3,0, 3,6 ],
                    [ -6,0, 3,0,  0,6 ],
                    [ 6,0, -3,0,  0,6 ],

                    [ 0,0, 0,1,  0,1 ],  # strip of y axis
                    [ 0,1, 0,0,  0,1 ],
                    [ 0,6, 0,3,   3,6 ],
                    [ 0,-6, 0,3,  0,6 ],
                    [ 0,-6, 0,-3, 3,6 ],
                    [ 0,6, 0,-3,  0,6 ],


                    [ 0,0, 3,4, 0,5 ],
                    [ 0,0, 3,-4, 0,5 ],
                    [ 0,0, -3,4, 0,5 ],
                    [ 0,0, -3,-4, 0,5 ],

                    [ 6,8, 3,4, 5,10 ],
                    [ 6,8, -3,-4, 0,10 ],
                    [ -6,-8, 3,4, 0,10 ],

                    [ -3,0, 3,4, 0,5 ],
                    [ 0,-3, 4,3, 0,5 ],

                    [ -6,1, 6,8,   1,10 ],  # x both, y positive
                    [ -6,-1, 6,-8, 1,10 ],  # x both, y negative
                    [ 1,-6, 8,6, 1,10 ],    # y both, x positive
                    [ -1,-6, -8,6, 1,10 ],  # y both, x negative

                   ) {
    ### no critic (ProtectPrivateSubs)

    my ($x1,$y1, $x2,$y2, $want_rlo,$want_rhi) = @$elem;
    my ($got_rlo,$got_rhi)
      = Math::PlanePath::SacksSpiral::_rect_to_radius_range ($x1,$y1, $x2,$y2);

    my $name = "_rect_to_radius_range()  $x1,$y1, $x2,$y2";
    ok ($got_rlo, $want_rlo, "$name, r lo");
    ok ($got_rhi, $want_rhi, "$name, r hi");
  }
}

exit 0;
