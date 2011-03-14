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

use 5.006;
use strict;
use warnings;
use SVG;

my $svg =  SVG->new (width => 800, height => 500);
my @x = (0,800);
my @y = (250.5,250);
my $points = $svg->get_path(x=>\@x,
                            y=>\@y,
                            -type=>'polyline',
                           );
my $tag = $svg->polyline (
                          %$points,
                          id=>'level_1',
                          style=>{
                                  'fill-opacity'=>0,
                                  'stroke-color'=>'rgb(255,0,0)',
                                 },
                         );

print $svg->xmlify(
                   # -namespace => "svg",
                   # -pubid => "-//W3C//DTD SVG 1.0//EN",
                   # -inline   => 1
                  );
