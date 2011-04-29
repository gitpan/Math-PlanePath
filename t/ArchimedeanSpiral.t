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
use Test;
BEGIN { plan tests => 20 }

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

require Math::PlanePath::ArchimedeanChords;


sub numeq_array {
  my ($a1, $a2) = @_;
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
  my $want_version = 23;
  ok ($Math::PlanePath::ArchimedeanChords::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::ArchimedeanChords->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::ArchimedeanChords->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::ArchimedeanChords->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::ArchimedeanChords->new;
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
  my $path = Math::PlanePath::ArchimedeanChords->new;
  ok ($path->n_start, 0, 'n_start()');
  ok (!! $path->x_negative, 1, 'x_negative() instance method');
  ok (!! $path->y_negative, 1, 'y_negative() instance method');
}

#------------------------------------------------------------------------------
# xy_to_n

{
  my @data = ([ 0,0,  0 ],
              [ 0.001,0.001,  0 ],
              [ -0.001,0.001,  0 ],
              [ 0.001,-0.001,  0 ],
              [ -0.001,-0.001,  0 ],
             );
  my $path = Math::PlanePath::ArchimedeanChords->new;
  foreach my $elem (@data) {
    my ($x, $y, $want_n) = @$elem;
    my @got_n = $path->xy_to_n ($x,$y);
    ok (scalar(@got_n), 1, "xy_to_n x=$x y=$y -- return 1 value");
    my $got_n = $got_n[0];
    ok ($got_n, $want_n, "xy_to_n x=$x y=$y -- n value");
  }
}

exit 0;
