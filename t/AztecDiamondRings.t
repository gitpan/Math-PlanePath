#!/usr/bin/perl -w

# Copyright 2011, 2012 Kevin Ryde

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
BEGIN { plan tests => 215; }

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

require Math::PlanePath::AztecDiamondRings;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 73;
  ok ($Math::PlanePath::AztecDiamondRings::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::AztecDiamondRings->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::AztecDiamondRings->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::AztecDiamondRings->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::AztecDiamondRings->new;
  ok ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      1,
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      1,
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# rect_to_n_range()

{
  my $path = Math::PlanePath::AztecDiamondRings->new;
  foreach my $elem
    (
     [1,-2,  1,2,   5,27], # X=1,  Y=-2..2 being 23,12,5,14,27
     [-1,-2, -1,2,  2,16], # X=-1, Y=-2..2 being 10,3,2,7,16

     [-2,1,  2,1,   6,26], # Y=1,  X=-2..2 being 17,7,6,14,26
     [-2,-1, 2,-1,  3,24], # Y=-1, X=-2..2 being 9,3,4,12,24
     [-2,-1, 1,-1,  3,12], # Y=-1, X=-2..1 being 9,3,4,12

     [0,-2,  -2,-2, 10,20],   # Y=-2, X=-2 to 0 being 20,10,11
    ) {
    my ($x1,$y1,$x2,$y2, $want_lo, $want_hi) = @$elem;
    my ($got_lo, $got_hi) = $path->rect_to_n_range ($x1,$y1, $x2,$y2);
    ok ($got_lo, $want_lo, "lo on $x1,$y1 $x2,$y2");
    ok ($got_hi, $want_hi, "hi on $x1,$y1 $x2,$y2");
  }
}

#------------------------------------------------------------------------------
# n_start, x_negative, y_negative

{
  my $path = Math::PlanePath::AztecDiamondRings->new;
  ok ($path->n_start, 1, 'n_start()');
  ok ($path->x_negative, 1, 'x_negative()');
  ok ($path->y_negative, 1, 'y_negative()');
  ok ($path->class_x_negative, 1, 'class_x_negative() instance method');
  ok ($path->class_y_negative, 1, 'class_y_negative() instance method');
}
{
  my @pnames = map {$_->{'name'}}
    Math::PlanePath::AztecDiamondRings->parameter_info_list;
  ok (join(',',@pnames), '');
}

#------------------------------------------------------------------------------
# first few points

{
  my @data = (
              [ 1,    0,0 ],
              [ 2,   -1,0 ],
              [ 3,   -1,-1 ],
              [ 4,    0,-1 ],

              [ 5,    1,0 ],
              [ 6,    0,1 ],
              [ 7,   -1,1 ],
              [ 8,   -2,0 ],

              [ 1.25,   -.25, 0 ],
              [ 1.75,   -.75, 0 ],
              [ 2.25,   -1, -.25 ],
              [ 3.25,   -.75, -1 ],
              [ 4.25,   0, -.75 ],

              [ 12.25,   1, -.75 ],
              [ 24.25,   2, -.75 ],

             );
  foreach my $elem (@data) {
    my ($n, $x, $y) = @$elem;
    my $path = Math::PlanePath::AztecDiamondRings->new;
    {
      # n_to_xy()
      my ($got_x, $got_y) = $path->n_to_xy ($n);
      if ($got_x == 0) { $got_x = 0 }  # avoid "-0"
      if ($got_y == 0) { $got_y = 0 }
      ok ($got_x, $x, "n_to_xy() x at n=$n");
      ok ($got_y, $y, "n_to_xy() y at n=$n");
    }
    if ($n==int($n)) {
      # xy_to_n()
      my $got_n = $path->xy_to_n ($x, $y);
      ok ($got_n, $n, "xy_to_n() n at x=$x,y=$y");
    }

    if ($n == int($n)) {
      {
        my ($got_nlo, $got_nhi) = $path->rect_to_n_range (0,0, $x,$y);
        ok ($got_nlo <= $n, 1, "rect_to_n_range(0,0,$x,$y) for n=$n, got_nlo=$got_nlo");
        ok ($got_nhi >= $n, 1, "rect_to_n_range(0,0,$x,$y) for n=$n, got_nhi=$got_nhi");
      }
      {
        $n = int($n);
        my ($got_nlo, $got_nhi) = $path->rect_to_n_range ($x,$y, $x,$y);
        ok ($got_nlo <= $n, 1, "rect_to_n_range($x,$y,$x,$y) for n=$n, got_nlo=$got_nlo");
        ok ($got_nhi >= $n, 1, "rect_to_n_range($x,$y,$x,$y) for n=$n, got_nhi=$got_nhi");
      }
    }
  }
}


#------------------------------------------------------------------------------
# random fracs

{
  my $path = Math::PlanePath::AztecDiamondRings->new;
  for (1 .. 20) {
    my $bits = int(rand(20));         # 0 to 20, inclusive
    my $n = int(rand(2**$bits)) + 1;  # 1 to 2^bits, inclusive

    my ($x1,$y1) = $path->n_to_xy ($n);
    my ($x2,$y2) = $path->n_to_xy ($n+1);

    foreach my $frac (0.25, 0.5, 0.75) {
      my $want_xf = $x1 + ($x2-$x1)*$frac;
      my $want_yf = $y1 + ($y2-$y1)*$frac;

      # the end of the ring goes towards the start of the current ring, not
      # the next
      if ($y1 == -1 && $x1 >= 0) {
        $want_xf = $x1;
      }

      my $nf = $n + $frac;
      my ($got_xf,$got_yf) = $path->n_to_xy ($nf);

      ok ($got_xf, $want_xf, "n_to_xy($n) frac $frac, x");
      ok ($got_yf, $want_yf, "n_to_xy($n) frac $frac, y");
    }
  }
}

exit 0;
