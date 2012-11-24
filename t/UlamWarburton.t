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
plan tests => 788;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Devel::Comments;

require Math::PlanePath::UlamWarburton;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 93;
  ok ($Math::PlanePath::UlamWarburton::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::UlamWarburton->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::UlamWarburton->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::UlamWarburton->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::UlamWarburton->new;
  ok ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      1,
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      1,
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# tree_depth_to_n()

{
  my $path = Math::PlanePath::UlamWarburton->new;
  my @data = ([ 0,  1 ],
              [ 1,  2 ],
              [ 2,  6 ],
              [ 3, 10 ],
              [ 4, 22 ],
              [ 5, 26 ],
              [ 6, 38 ],
              [ 7, 50 ],
              [ 8, 86 ],
              [ 9, 90 ],
             );
  foreach my $elem (@data) {
    my ($depth, $want_n) = @$elem;
    my $got_n = $path->tree_depth_to_n ($depth);
    ok ($got_n, $want_n, "tree_depth_to_n() depth=$depth");
  }
}

#------------------------------------------------------------------------------
# tree_n_parent()
{
  my @data = ([ 1, undef ],

              [ 2,  1 ],
              [ 3,  1 ],
              [ 4,  1 ],
              [ 5,  1 ],

              [ 6,  2 ],
              [ 7,  3 ],
              [ 8,  4 ],
              [ 9,  5 ],

              [ 10,  6 ],
              [ 11,  6 ],
              [ 12,  6 ],
              [ 13,  7 ],
              [ 14,  7 ],
              [ 15,  7 ],
             );
  my $path = Math::PlanePath::UlamWarburton->new;
  foreach my $elem (@data) {
    my ($n, $want_n_parent) = @$elem;
    my $got_n_parent = $path->tree_n_parent ($n);
    ok ($got_n_parent, $want_n_parent);
  }
}

#------------------------------------------------------------------------------
# tree_n_children()
{
  my @data = ([ 1, '2,3,4,5' ],

              [ 2,  '6' ],
              [ 3,  '7' ],
              [ 4,  '8' ],
              [ 5,  '9' ],

              [ 6,  '10,11,12' ],
              [ 7,  '13,14,15' ],
              [ 8,  '16,17,18' ],
              [ 9,  '19,20,21' ],
             );
  my $path = Math::PlanePath::UlamWarburton->new;
  foreach my $elem (@data) {
    my ($n, $want_n_children) = @$elem;
    my $got_n_children = join(',',$path->tree_n_children($n));
    ok ($got_n_children, $want_n_children, "tree_n_children($n)");
  }
}

#------------------------------------------------------------------------------
# n_start, x_negative, y_negative

{
  my $path = Math::PlanePath::UlamWarburton->new;
  ok ($path->n_start, 1, 'n_start()');
  ok ($path->x_negative, 1, 'x_negative()');
  ok ($path->y_negative, 1, 'y_negative()');
}


#------------------------------------------------------------------------------
# random points

{
  my $path = Math::PlanePath::UlamWarburton->new;
  for (1 .. 50) {
    my $bits = int(rand(20));         # 0 to 20, inclusive
    my $n = int(rand(2**$bits)) + 1;  # 1 to 2^bits, inclusive

    my ($x,$y) = $path->n_to_xy ($n);
    my $rev_n = $path->xy_to_n ($x,$y);
    if (! defined $rev_n) { $rev_n = 'undef'; }
    ok ($rev_n, $n, "xy_to_n($x,$y) reverse to expect n=$n, got $rev_n");

    my ($n_lo, $n_hi) = $path->rect_to_n_range ($x,$y, $x,$y);
    ok ($n_lo <= $n, 1, "rect_to_n_range() reverse n=$n cf got n_lo=$n_lo");
    ok ($n_hi >= $n, 1, "rect_to_n_range() reverse n=$n cf got n_hi=$n_hi");
  }
}


#------------------------------------------------------------------------------
# x,y coverage

{
  my $path = Math::PlanePath::UlamWarburton->new;
  foreach my $x (-10 .. 10) {
    foreach my $y (-10 .. 10) {
      my $n = $path->xy_to_n ($x,$y);
      next if ! defined $n;
      my ($nx,$ny) = $path->n_to_xy ($n);

      ok ($nx, $x, "xy_to_n($x,$y)=$n then n_to_xy() reverse");
      ok ($ny, $y, "xy_to_n($x,$y)=$n then n_to_xy() reverse");
    }
  }
}

exit 0;
