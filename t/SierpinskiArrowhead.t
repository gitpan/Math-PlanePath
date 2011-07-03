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
BEGIN { plan tests => 11 }

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Smart::Comments;

require Math::PlanePath::SierpinskiArrowhead;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 33;
  ok ($Math::PlanePath::SierpinskiArrowhead::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::SierpinskiArrowhead->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::SierpinskiArrowhead->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::SierpinskiArrowhead->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::SierpinskiArrowhead->new;
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
  my $path = Math::PlanePath::SierpinskiArrowhead->new;
  ok ($path->n_start, 0, 'n_start()');
  ok ($path->x_negative, 1, 'x_negative()');
  ok ($path->y_negative, 0, 'y_negative()');
}

#------------------------------------------------------------------------------
# xy_to_n() distinct n and all n

{
  my $path = Math::PlanePath::SierpinskiArrowhead->new;
  my $bad = 0;
  my @seen;
  my $xlo = -16;
  my $xhi = 16;
  my $ylo = 0;
  my $yhi = 16;
  my $count = 0;
  my ($nlo, $nhi) = $path->rect_to_n_range($xlo,$ylo, $xhi,$yhi);

 OUTER: for (my $x = $xlo; $x <= $xhi; $x++) {
    for (my $y = $ylo; $y <= $yhi; $y++) {
      my $n = $path->xy_to_n ($x,$y);
      if (! defined $n) {
        next;
      }
      if ($seen[$n]) {
        MyTestHelpers::diag ("x=$x,y=$y n=$n seen before at $seen[$n]");
        last if $bad++ > 10;
      }
      my ($rx,$ry) = $path->n_to_xy ($n);
      if ($rx != $x || $ry != $y) {
        MyTestHelpers::diag ("x=$x,y=$y n=$n goes back to rx=$rx ry=$ry");
        last OUTER if $bad++ > 10;
      }
      if ($n < $nlo) {
        MyTestHelpers::diag ("x=$x,y=$y n=$n below nlo=$nlo");
        last OUTER if $bad++ > 10;
      }
      if ($n > $nhi) {
        MyTestHelpers::diag ("x=$x,y=$y n=$n above nhi=$nhi");
        last OUTER if $bad++ > 10;
      }
      $seen[$n] = "$x,$y";
      $count++;
    }
  }
  foreach my $n (0 .. $#seen) {
    if (! defined $seen[$n]) {
      MyTestHelpers::diag ("n=$n not seen");
      last if $bad++ > 10;
    }
  }
  ok ($bad, 0, "xy_to_n() coverage, $count points");
}

exit 0;
