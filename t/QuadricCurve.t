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
plan tests => 12;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Devel::Comments;

require Math::PlanePath::QuadricCurve;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 59;
  ok ($Math::PlanePath::QuadricCurve::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::QuadricCurve->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::QuadricCurve->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::QuadricCurve->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::QuadricCurve->new;
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
  my $path = Math::PlanePath::QuadricCurve->new;
  ok ($path->n_start, 0, 'n_start()');
  ok ($path->x_negative, 0, 'x_negative()');
  ok ($path->y_negative, 1, 'y_negative()');
}

#------------------------------------------------------------------------------
# xy_to_n() distinct n

{
  my $path = Math::PlanePath::QuadricCurve->new;
  my $bad = 0;
  my %seen;
  my $xlo = -5;
  my $xhi = 100;
  my $ylo = -5;
  my $yhi = 100;
  my ($nlo, $nhi) = $path->rect_to_n_range($xlo,$ylo, $xhi,$yhi);
  my $count = 0;
 OUTER: for (my $x = $xlo; $x <= $xhi; $x++) {
    for (my $y = $ylo; $y <= $yhi; $y++) {
      next if ($x ^ $y) & 1;
      my $n = $path->xy_to_n ($x,$y);
      next if ! defined $n;  # sparse

      if ($seen{$n}) {
        MyTestHelpers::diag ("x=$x,y=$y n=$n seen before at $seen{$n}");
        last if $bad++ > 10;
      }
      if ($n < $nlo) {
        MyTestHelpers::diag ("x=$x,y=$y n=$n below nlo=$nlo");
        last OUTER if $bad++ > 10;
      }
      if ($n > $nhi) {
        MyTestHelpers::diag ("x=$x,y=$y n=$n above nhi=$nhi");
        last OUTER if $bad++ > 10;
      }
      $seen{$n} = "$x,$y";
      $count++;
    }
  }
  ok ($bad, 0, "xy_to_n() coverage and distinct, $count points");
}

#------------------------------------------------------------------------------
# turn sequence

{
  sub n_to_turn {
    my ($n) = @_;
    for (;;) {
      if ($n == 0) { die "oops n=0"; }
      my $mod = $n % 8;
      if ($mod == 1) { return 1; }
      if ($mod == 2) { return -1; }
      if ($mod == 3) { return -1; }
      if ($mod == 4) { return 0; }
      if ($mod == 5) { return 1; }
      if ($mod == 6) { return 1; }
      if ($mod == 7) { return -1; }
      $n = int($n/8);
    }
  }

  sub dxdy_to_dir {
    my ($dx,$dy) = @_;
    if ($dy == 0) {
      if ($dx == 1) { return 0; }
      if ($dx == -1) { return 2; }
    }
    if ($dy == 1) {
      if ($dx == 0) { return 1; }
    }
    if ($dy == -1) {
      if ($dx == 0) { return 3; }
    }
    die "unrecognised $dx,$dy";
  }

  my $path = Math::PlanePath::QuadricCurve->new;
  my $n = $path->n_start;
  my $bad = 0;

  my ($prev_x, $prev_y) = $path->n_to_xy($n++);

  my ($x, $y) = $path->n_to_xy($n++);
  my $dx = $x - $prev_x;
  my $dy = $y - $prev_y;
  my $prev_dir = dxdy_to_dir($dx,$dy);

  while ($n < 1000) {
    $prev_x = $x;
    $prev_y = $y;

    ($x,$y) = $path->n_to_xy($n);
    $dx = $x - $prev_x;
    $dy = $y - $prev_y;
    my $dir = dxdy_to_dir($dx,$dy);

    my $got_turn = ($dir - $prev_dir) % 4;
    my $want_turn = n_to_turn($n-1) % 4;

    if ($got_turn != $want_turn) {
      MyTestHelpers::diag ("n=$n turn got=$got_turn want=$want_turn");
      MyTestHelpers::diag ("  dir=$dir prev_dir=$prev_dir");
      last if $bad++ > 10;
    }

    $n++;
    $prev_dir = $dir;
  }
  ok ($bad, 0, "turn sequence");
}

exit 0;
