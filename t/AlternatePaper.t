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
BEGIN { plan tests => 164 }

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Devel::Comments;

require Math::PlanePath::AlternatePaper;

my $path = Math::PlanePath::AlternatePaper->new;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 70;
  ok ($Math::PlanePath::AlternatePaper::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::AlternatePaper->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::AlternatePaper->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::AlternatePaper->VERSION($check_version); 1 },
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
  ok ($path->class_x_negative, 0, 'class_x_negative()');
  ok ($path->class_y_negative, 0, 'class_y_negative()');
}
{
  my @pnames = map {$_->{'name'}}
    Math::PlanePath::AlternatePaper->parameter_info_list;
  ok (join(',',@pnames), '');
}


#------------------------------------------------------------------------------
# turn sequence claimed in the pod

{
  # with Y reckoned increasing upwards
  sub dxdy_to_dir {
    my ($dx, $dy) = @_;
    if ($dx > 0) { return 0; }  # east
    if ($dx < 0) { return 2; }  # west
    if ($dy > 0) { return 1; }  # north
    if ($dy < 0) { return 3; }  # south
  }

  sub path_n_dir {
    my ($path, $n) = @_;
    my ($x,$y) = $path->n_to_xy($n);
    my ($next_x,$next_y) = $path->n_to_xy($n+1);
    return dxdy_to_dir ($next_x - $x,
                        $next_y - $y);
  }

  # return 1 for left, 0 for right
  sub path_n_turn {
    my ($path, $n) = @_;
    my $prev_dir = path_n_dir ($path, $n-1);
    my $dir = path_n_dir ($path, $n);
    my $turn = ($dir - $prev_dir) % 4;
    if ($turn == 1) { return 1; } # left
    if ($turn == 3) { return 0; } # right
    die "Oops, unrecognised turn";
  }

  # return 1 for left, 0 for right
  sub calc_n_turn {
    my ($n) = @_;
    die if $n == 0;

    my $pos = 0;
    while (($n % 2) == 0) {
      $n = int($n/2); # skip low 0s
      $pos++;
    }
    $n = int($n/2);   # skip lowest 1
    $pos++;
    return ($n % 2) ^ ($pos % 2);  # next bit and its pos are the turn
  }

  # return 1 for left, 0 for right
  sub calc_n_next_turn {
    my ($n) = @_;
    die if $n == 0;

    my $pos = 0;
    while (($n % 2) == 1) {
      $n = int($n/2); # skip low 1s
      $pos++;
    }
    $n = int($n/2);   # skip lowest 0
    $pos++;
    return ($n % 2) ^ ($pos % 2);  # next bit and its pos are the turn
  }

  my $bad = 0;
  foreach my $n ($path->n_start + 1 .. 500) {
    {
      my $path_turn = path_n_turn ($path, $n);
      my $calc_turn = calc_n_turn ($n);
      if ($path_turn != $calc_turn) {
        MyTestHelpers::diag ("turn n=$n  path $path_turn calc $calc_turn");
        last if $bad++ > 10;
      }
    }
    {
      my $path_turn = path_n_turn ($path, $n+1);
      my $calc_turn = calc_n_next_turn ($n);
      if ($path_turn != $calc_turn) {
        MyTestHelpers::diag ("next turn n=$n  path $path_turn calc $calc_turn");
        last if $bad++ > 10;
      }
    }
  }
  ok ($bad, 0, "turn sequence");
}

#------------------------------------------------------------------------------
# random rect_to_n_range()

{
  for (1 .. 5) {
    my $bits = int(rand(25));     # 0 to 25, inclusive
    my $n = int(rand(2**$bits));  # 0 to 2^bits, inclusive

    my ($x,$y) = $path->n_to_xy ($n);

    my $rev_n = $path->xy_to_n ($x,$y);
    ok (defined $rev_n, 1,
        "xy_to_n($x,$y) reverse n, got undef");

    my ($n_lo, $n_hi) = $path->rect_to_n_range ($x,$y, $x,$y);
    ok ($n_lo <= $n, 1,
        "rect_to_n_range() n=$n at xy=$x,$y cf got n_lo=$n_lo");
    ok ($n_hi >= $n, 1,
        "rect_to_n_range() n=$n at xy=$x,$y cf got n_hi=$n_hi");
  }
}


#------------------------------------------------------------------------------
# xy_to_n_list()

{
  my @data = (
              [ 0,1, [] ],
              [ -1,0, [] ],
              [ -1,-1, [] ],
              [ 1,-1, [] ],

              [ 0,0, [0] ],
              [ 1,0, [1] ],
              [ 1,1, [2] ],

              [ 2,1, [3,7] ],
              [ 2,0, [4] ],
              [ 3,0, [5] ],
              [ 3,1, [6,14] ],
              # 2,1  7
              [ 2,2, [8] ],
              [ 3,2, [9,13] ],

              [ 3,3, [10] ],

              [ 4,3, [11,31] ],
              [ 4,2, [12,28] ],
              # 3,2  13
              # 3,1  14
              [ 4,1, [15,27] ],
              [ 4,0, [16] ],
              [ 5,0, [17] ],
              [ 5,1, [18,26] ],
              [ 6,1, [19,23] ],
              [ 6,0, [20] ],
              [ 7,0, [21] ],
              [ 7,1, [22,62] ],

              [ 4,4, [32] ],

              [ 8,0, [64] ],
              [ 9,0, [65] ],

             );
  foreach my $elem (@data) {
    my ($x,$y, $want_n_aref) = @$elem;
    my $want_n_str = join(',', @$want_n_aref);
    {
      my @got_n_list = $path->xy_to_n_list($x,$y);
      ok (scalar(@got_n_list), scalar(@$want_n_aref),
         "xy=$x,$y");
      my $got_n_str = join(',', @got_n_list);
      ok ($got_n_str, $want_n_str);
    }
    {
      my $got_n = $path->xy_to_n($x,$y);
      ok ($got_n, $want_n_aref->[0]);
    }
    {
      my @got_n = $path->xy_to_n($x,$y);
      ok (scalar(@got_n), 1);
      ok ($got_n[0], $want_n_aref->[0]);
    }
  }
}


exit 0;
