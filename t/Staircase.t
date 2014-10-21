#!/usr/bin/perl -w

# Copyright 2010, 2011, 2012, 2013 Kevin Ryde

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
plan tests => 76;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }

require Math::PlanePath::Staircase;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 105;
  ok ($Math::PlanePath::Staircase::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::Staircase->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::Staircase->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::Staircase->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::Staircase->new;
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
  my $path = Math::PlanePath::Staircase->new (height => 123);
  ok ($path->n_start, 1, 'n_start()');
  ok ($path->x_negative, 0, 'x_negative() instance method');
  ok ($path->y_negative, 0, 'y_negative() instance method');
}
{
  # width not a parameter as such ...
  my @pnames = map {$_->{'name'}}
    Math::PlanePath::Staircase->parameter_info_list;
  ok (join(',',@pnames), '');
}


#------------------------------------------------------------------------------
# first few values

{
  my @data = ([ 0.75, -0.25,0 ],
              [ 1, 0,0 ],
              [ 1.25, 0,-0.25 ],

              [ 1.75,  -0.25, 2 ],
              [ 2, 0,2 ],
              [ 2.25,  0, 1.75 ],

              [ 2.75,  0, 1.25 ],
              [ 3, 0,1 ],
              [ 3.25,  0.25, 1 ],

              [ 4, 1,1 ],
              [ 4.25,  1,0.75 ],
              [ 5, 1,0 ],
              [ 5.25,  1.25, 0 ],
              [ 6, 2,0 ],
              [ 6.25,  2, -0.25 ],

              [ 6.75,  -0.25, 4 ],
              [ 7,  0,4 ],

              [ 8,  0,3 ],
              [ 9,  1,3 ],
              [ 10, 1,2 ],
              [ 11, 2,2 ],
              [ 12, 2,1 ],
              [ 13, 3,1 ],
              [ 14, 3,0 ],
              [ 15, 4,0 ],
             );
  my $path = Math::PlanePath::Staircase->new;
  foreach my $elem (@data) {
    my ($n, $want_x, $want_y) = @$elem;
    my ($got_x, $got_y) = $path->n_to_xy ($n);
    ok ($got_x, $want_x, "x at n=$n");
    ok ($got_y, $want_y, "y at n=$n");
  }

  foreach my $elem (@data) {
    my ($want_n, $x, $y) = @$elem;
    next unless $want_n == int($want_n);
    my $got_n = $path->xy_to_n ($x, $y);
    ok ($got_n, $want_n, "n at x=$x,y=$y");
  }
}

exit 0;
