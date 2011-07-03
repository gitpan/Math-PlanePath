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
plan tests => 87;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Devel::Comments;

require Math::PlanePath::KochCurve;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 33;
  ok ($Math::PlanePath::KochCurve::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::KochCurve->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::KochCurve->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::KochCurve->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::KochCurve->new;
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
  my $path = Math::PlanePath::KochCurve->new;
  ok ($path->n_start, 0, 'n_start()');
  ok (! $path->x_negative, 1, 'x_negative()');
  ok (! $path->y_negative, 1, 'y_negative()');
}

#------------------------------------------------------------------------------
# _round_down_pow3()

foreach my $elem ([ 1, 1,0 ],
                  [ 2, 1,0 ],
                  [ 3, 3,1 ],
                  [ 4, 3,1 ],
                  [ 5, 3,1 ],

                  [ 8, 3,1 ],
                  [ 9, 9,2 ],
                  [ 10, 9,2 ],

                  [ 26, 9,2 ],
                  [ 27, 27,3 ],
                  [ 28, 27,3 ],
                 ) {
  my ($n, $want_pow, $want_exp) = @$elem;
  my ($got_pow, $got_exp)
    = Math::PlanePath::KochCurve::_round_down_pow3($n);
  ok ($got_pow, $want_pow);
  ok ($got_exp, $want_exp);
}

{
  my $bad = 0;
  foreach my $i (2 .. 200) {
    my $p = 3**$i;
    if ($p+1 <= $p
        || $p-1 >= $p
        || ($p % 3) != 0
        || (($p+1) % 3) != 1
        || (($p-1) % 3) != 2) {
      MyTestHelpers::diag ("_round_down_pow3() tests stop for round-off at i=$i");
      last;
    }

    {
      my $n = $p-1;
      my $want_pow = $p/3;
      my $want_exp = $i-1;
      my ($got_pow, $got_exp)
        = Math::PlanePath::KochCurve::_round_down_pow3($n);
      if ($got_pow != $want_pow
          || $got_exp != $want_exp) {
        MyTestHelpers::diag ("_round_down_pow3($n) i=$i prev got $got_pow,$want_pow want $got_exp,$want_exp");
        $bad++;
      }
    }
    {
      my $n = $p;
      my $want_pow = $p;
      my $want_exp = $i;
      my ($got_pow, $got_exp)
        = Math::PlanePath::KochCurve::_round_down_pow3($n);
      if ($got_pow != $want_pow
          || $got_exp != $want_exp) {
        MyTestHelpers::diag ("_round_down_pow3($n) i=$i exact got $got_pow,$want_pow want $got_exp,$want_exp");
        $bad++;
      }
    }
    {
      my $n = $p+1;
      my $want_pow = $p;
      my $want_exp = $i;
      my ($got_pow, $got_exp)
        = Math::PlanePath::KochCurve::_round_down_pow3($n);
      if ($got_pow != $want_pow
          || $got_exp != $want_exp) {
        MyTestHelpers::diag ("_round_down_pow3($n) i=$i post $got_pow,$want_pow want $got_exp,$want_exp");
        $bad++;
      }
    }
  }
  ok ($bad,0);
}


#------------------------------------------------------------------------------
# first few points

{
  my @data = ([ 0.5, 1,0 ],
              [ 3.5, 5,0 ],
              

              [ 0, 0,0 ],
              [ 1, 2,0 ],
              [ 2, 3,1 ],
              [ 3, 4,0 ],

              [ 4, 6,0 ],
              [ 5, 7,1 ],
              [ 6, 6,2 ],
              [ 7, 8,2 ],

              [ 8, 9,3 ],
             );
  my $path = Math::PlanePath::KochCurve->new;
  foreach my $elem (@data) {
    my ($n, $want_x, $want_y) = @$elem;
    my ($got_x, $got_y) = $path->n_to_xy ($n);
    ok ($got_x, $want_x, "x at n=$n");
    ok ($got_y, $want_y, "y at n=$n");
  }

  foreach my $elem (@data) {
    my ($want_n, $x, $y) = @$elem;
    next unless $want_n==int($want_n);
    my $got_n = $path->xy_to_n ($x, $y);
    ok ($got_n, $want_n, "n at x=$x,y=$y");
  }

  foreach my $elem (@data) {
    my ($n, $x, $y) = @$elem;
    my ($got_nlo, $got_nhi) = $path->rect_to_n_range (0,0, $x,$y);
    ok ($got_nlo <= $n, 1, "rect_to_n_range() nlo=$got_nlo at n=$n,x=$x,y=$y");
    ok ($got_nhi >= $n, 1, "rect_to_n_range() nhi=$got_nhi at n=$n,x=$x,y=$y");
  }
}


#------------------------------------------------------------------------------
# xy_to_n() distinct n

{
  my $path = Math::PlanePath::KochCurve->new;
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

exit 0;
