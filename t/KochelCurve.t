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
BEGIN { plan tests => 132 }

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Smart::Comments;

require Math::PlanePath::KochelCurve;
my $path = Math::PlanePath::KochelCurve->new;


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
  my $want_version = 59;
  ok ($Math::PlanePath::KochelCurve::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::KochelCurve->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::KochelCurve->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::KochelCurve->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

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
  ok ($path->n_start, 0, 'n_start()');
  ok ($path->x_negative, 0, 'x_negative() instance method');
  ok ($path->y_negative, 0, 'y_negative() instance method');

  my @pnames = map {$_->{'name'}} $path->parameter_info_list;
  ok (join(',',@pnames), '', 'parameter_info_list() keys');
}


#------------------------------------------------------------------------------
# random fracs

{
  my $path = Math::PlanePath::KochelCurve->new;
  for (1 .. 20) {
    my $bits = int(rand(20));         # 0 to 20, inclusive
    my $n = int(rand(2**$bits)) + 1;  # 1 to 2^bits, inclusive

    my ($x1,$y1) = $path->n_to_xy ($n);
    my ($x2,$y2) = $path->n_to_xy ($n+1);

    foreach my $frac (0.25, 0.5, 0.75) {
      my $want_xf = $x1 + ($x2-$x1)*$frac;
      my $want_yf = $y1 + ($y2-$y1)*$frac;

      my $nf = $n + $frac;
      my ($got_xf,$got_yf) = $path->n_to_xy ($nf);

      ok ($got_xf, $want_xf, "n_to_xy($n) frac $frac, x");
      ok ($got_yf, $want_yf, "n_to_xy($n) frac $frac, y");
    }
  }
}

#------------------------------------------------------------------------------
# many fracs

{
  my $path = Math::PlanePath::KochelCurve->new;
  my ($x,$y) = $path->n_to_xy (0);
  my $bad = 0;
  my $pow = 5;
  for my $n (0 .. 4**$pow+5) {
    my ($x2,$y2) = $path->n_to_xy ($n+1);

    my $frac = 0.25;
    my $want_xf = $x + ($x2-$x)*$frac;
    my $want_yf = $y + ($y2-$y)*$frac;

    my $nf = $n + $frac;
    my ($got_xf,$got_yf) = $path->n_to_xy ($nf);

    if ($got_xf != $want_xf || $got_yf != $want_yf) {
      MyTestHelpers::diag ("wrong at n=$n  got $got_xf,$got_yf want $want_xf,$want_yf");
      if ($bad++ > 10) { last; }
    }
    ($x,$y) = ($x2,$y2);
  }
  ok ($bad, 0);
}



exit 0
;
