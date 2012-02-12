#!/usr/bin/perl -w

# Copyright 2010, 2011, 2012 Kevin Ryde

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
BEGIN { plan tests => 126 }

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Smart::Comments;

require Math::PlanePath::MultipleRings;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 69;
  ok ($Math::PlanePath::MultipleRings::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::MultipleRings->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::MultipleRings->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::MultipleRings->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::MultipleRings->new;
  ok ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      1,
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      1,
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# _xy_to_angle_frac()

{
  my @data = ([    1,    0,  0   ],
              [    0,    1,  .25 ],
              [   -1,    0,  .5  ],
              [    0,   -1,  .75 ],
              [    0,    0,  0   ],
              [ -0.0, -0.0,  0   ],
              [ -0.0,    0,  0   ],
              [    0, -0.0,  0   ],
             );
  foreach my $elem (@data) {
    my ($x, $y, $want) = @$elem;

    my $got = Math::PlanePath::MultipleRings::_xy_to_angle_frac($x,$y);
    ok (abs ($got - $want) < 0.001,
        1,
        "_xy_to_angle_frac() on x=$x,y=$y got $got want $want");
  }
}

#------------------------------------------------------------------------------
# n_start, x_negative(), y_negative()

{
  my $path = Math::PlanePath::MultipleRings->new;
  ok ($path->n_start, 1, 'n_start()');
  ok ($path->x_negative, 1, 'x_negative()');
  ok ($path->y_negative, 1, 'y_negative()');
  ok ($path->class_x_negative, 1, 'class_x_negative() instance method');
  ok ($path->class_y_negative, 1, 'class_y_negative() instance method');
}
{
  my $path = Math::PlanePath::MultipleRings->new (step => 0);
  ok ($path->n_start, 1, 'n_start()');
  ok (! $path->x_negative, 1, 'x_negative()');
  ok (! $path->y_negative, 1, 'y_negative()');
  ok ($path->class_x_negative, 1, 'class_x_negative() instance method');
  ok ($path->class_y_negative, 1, 'class_y_negative() instance method');
}
{
  my @pnames = map {$_->{'name'}}
    Math::PlanePath::MultipleRings->parameter_info_list;
  ok (join(',',@pnames), 'step');
}


#------------------------------------------------------------------------------
# xy_to_n()

{
  my $step = 3;
  my $n = 2;
  my $path = Math::PlanePath::MultipleRings->new (step => $step);
  my ($x,$y) = $path->n_to_xy($n);
  $y -= .1;
  ### try: "n=$n  x=$x,y=$y"
  my $got_n = $path->xy_to_n($x,$y);
  ### $got_n
  ok ($got_n, $n, "xy_to_n() back from n=$n at offset x=$x,y=$y");
}

# step=0 and step=1 centred on 0,0
# step=2 two on ring, rounds to the N=1
foreach my $step (0 .. 2) {
  my $path = Math::PlanePath::MultipleRings->new (step => $step);
  ok ($path->xy_to_n(0,0), 1, "xy_to_n(0,0) step=$step is 1");
  ok ($path->xy_to_n(-0.0, 0), 1, "xy_to_n(-0,0) step=$step is 1");
  ok ($path->xy_to_n(0, -0.0), 1, "xy_to_n(0,-0) step=$step is 1");
  ok ($path->xy_to_n(-0.0, -0.0), 1, "xy_to_n(-0,-0) step=$step is 1");
}
foreach my $step (3 .. 10) {
  my $path = Math::PlanePath::MultipleRings->new (step => $step);
  ok ($path->xy_to_n(0,0), undef,
      "xy_to_n(0,0) step=$step is undef (nothing in centre)");
  ok ($path->xy_to_n(-0.0, 0), undef,
      "xy_to_n(-0,0) step=$step is undef (nothing in centre)");
  ok ($path->xy_to_n(0, -0.0), undef,
      "xy_to_n(0,-0) step=$step is undef (nothing in centre)");
  ok ($path->xy_to_n(-0.0, -0.0), undef,
      "xy_to_n(-0,-0) step=$step is undef (nothing in centre)");
}

foreach my $step (0 .. 3) {
  my $path = Math::PlanePath::MultipleRings->new (step => $step);
  ok ($path->xy_to_n(0.1,0.1), 1, "xy_to_n(0.1,0.1) step=$step is 1");
}
foreach my $step (4 .. 10) {
  my $path = Math::PlanePath::MultipleRings->new (step => $step);
  ok ($path->xy_to_n(0.1,0.1), undef,
      "xy_to_n(0.1,0.1) step=$step is undef (nothing in centre)");
}

#------------------------------------------------------------------------------
# rect_to_n_range()

foreach my $step (0 .. 10) {
  my $path = Math::PlanePath::MultipleRings->new (step => $step);
  my ($got_lo, $got_hi) = $path->rect_to_n_range(0,0,0,0);
  ok ($got_lo >= 1,
      1, "rect_to_n_range(0,0) step=$step is lo=$got_lo");
  ok ($got_hi >= $got_lo,
      1, "rect_to_n_range(0,0) step=$step want hi=$got_hi >= lo");
}

foreach my $step (0 .. 10) {
  my $path = Math::PlanePath::MultipleRings->new (step => $step);
  my ($got_lo, $got_hi) = $path->rect_to_n_range(-0.1,-0.1, 0.1,0.1);
  ok ($got_lo >= 1,
      1, "rect_to_n_range(0,0) step=$step is lo=$got_lo");
  ok ($got_hi >= $got_lo,
      1, "rect_to_n_range(0,0) step=$step want hi=$got_hi >= lo");
}

exit 0;
