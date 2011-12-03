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
BEGIN { plan tests => 3317 }

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

require Math::PlanePath::GreekKeySpiral;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 57;
  ok ($Math::PlanePath::GreekKeySpiral::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::GreekKeySpiral->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::GreekKeySpiral->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::GreekKeySpiral->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::GreekKeySpiral->new;
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
  my $path = Math::PlanePath::GreekKeySpiral->new;
  ok ($path->n_start, 1, 'n_start()');
  ok ($path->x_negative, 1, 'x_negative()');
  ok ($path->y_negative, 1, 'y_negative()');

  my @pnames = map {$_->{'name'}} $path->parameter_info_list;
  ok (join(',',@pnames), '');
}

#------------------------------------------------------------------------------
# n_to_xy() fractions part way between integer points

{
  my $path = Math::PlanePath::GreekKeySpiral->new;
  foreach my $n ($path->n_start .. $path->n_start + 500) {
    my ($x,$y) = $path->n_to_xy ($n);
    my ($x2,$y2) = $path->n_to_xy ($n+1);

    foreach my $frac (0.25, 0.5, 0.75) {
      my $nfrac = $n + $frac;
      my ($got_xfrac,$got_yfrac) = $path->n_to_xy ($nfrac);
      my $want_xfrac = $x + $frac*($x2-$x);
      my $want_yfrac = $y + $frac*($y2-$y);
      ok ($got_xfrac, $want_xfrac, "x frac at n=$nfrac");
      ok ($got_yfrac, $want_yfrac, "y frac at n=$nfrac");
    }
  }
}

#------------------------------------------------------------------------------
# rect_to_n_range() first and last

{
  my $path = Math::PlanePath::GreekKeySpiral->new;
  foreach my $t (1 .. 100) {

    my $x = 3*$t + 2;
    my $y = -3*$t;
    my $n = $path->xy_to_n ($x,$y);
    my ($n_lo, $n_hi) = $path->rect_to_n_range (0,0, $x,$y);
    ok ($n_hi, $n, "rect_to_n_range t=$t hi last x=$x,y=$y  n=$n");

    $x++;
    $n++;
    ok ($path->xy_to_n($x,$y), $n);
    ($n_lo, $n_hi) = $path->rect_to_n_range ($x,$y, $x,$y);
    ok ($n_lo, $n, "rect_to_n_range t=$t lo first x=$x,y=$y  n=$n");
  }
}

exit 0;
