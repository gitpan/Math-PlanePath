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
plan tests => 32;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Smart::Comments;

require Math::PlanePath::ToothpickTree;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 92;
  ok ($Math::PlanePath::ToothpickTree::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::ToothpickTree->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::ToothpickTree->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::ToothpickTree->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::ToothpickTree->new;
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
  my @groups = ([ { parts => 1 },
                  [  0,  0 ],   # + 1
                  [  1,  1 ],   # + 3
                  [  2,  2 ],   # + 3
                  [  3,  3 ],   # + 9
                  [  4,  5 ],  # + 3
                  [  5,  8 ],  # + 9
                  [  6,  10 ],  # + 9
                  [  7,  11 ],  # + 27
                  [  8,  13 ],  #
                  [  9,  16 ],  #
                  [ 10,  19 ],  #
                  [ 11,  23 ],  #
                  [ 12,  30 ],  #
                  [ 13,  38 ],  #
                  [ 14,  42 ],  #
                  [ 15,  43 ],  #
                  [ 16,  45 ],  #
                ],
                # [ { parts => 4 },
                #   [ 0,  0 ],   # + 4*1
                #   [ 1,  4 ],   # + 4*3
                #   [ 2,  16 ],  # + 4*3
                #   [ 3,  28 ],  # + 4*9
                #   [ 4,  64 ],  # + 4*3
                #   [ 5,  76 ],
                #   [ 6, 112 ],
                #   [ 7, 148 ],
                #   [ 8, 256 ],
                # ],
               );
  foreach my $group (@groups) {
    my ($options, @data) = @$group;
    my $path = Math::PlanePath::ToothpickTree->new (%$options);
    foreach my $elem (@data) {
      my ($depth, $want_n) = @$elem;
      my $got_n = $path->tree_depth_to_n ($depth);
      ok ($got_n, $want_n, "tree_depth_to_n() depth=$depth ".join(',',%$options));
    }
  }
}


exit 0;

#------------------------------------------------------------------------------
# tree_n_to_depth()

{
  my @groups = ([ { parts => 1 },
                  [ 0,  0 ],
                  [ 1,  1 ],
                  [ 2,  2 ],
                  [ 3,  3 ],
                  [ 4,  3 ],
                  [ 5,  4 ],
                  [ 6,  4 ],
                  [ 7,  4 ],
                  [ 8,  5 ],
                  [ 9,  5 ],
                  [ 10, 6 ],
                  [ 11, 7 ],
                  [ 12, 7 ],
                  [ 13, 8 ],
                ],
                [ { parts => 2 },
                  [ 0,  0 ],
                  [ 1,  1 ],
                  [ 2,  1 ],
                  [ 3,  2 ],
                  [ 4,  2 ],
                  [ 5,  3 ],
                  [ 6,  3 ],
                  [ 7,  4 ],
                  [ 8,  4 ],
                  [ 9,  4 ],
                  [ 10, 4 ],
                  [ 11, 5 ],
                ],
                [ { parts => 4 },
                  [ 0,  0 ],
                  [ 1,  1 ],
                  [ 2,  1 ],
                  [ 3,  2 ],
                  [ 4,  2 ],
                  [ 5,  2 ],
                  [ 6,  2 ],
                  [ 7,  3 ],
                  [ 8,  3 ],
                  [ 9,  3 ],
                  [ 10, 3 ],
                  [ 11, 4 ],
                ],
               );
  foreach my $group (@groups) {
    my ($options, @data) = @$group;
    my $path = Math::PlanePath::ToothpickTree->new (%$options);
    foreach my $elem (@data) {
      my ($depth, $want_n) = @$elem;
      my $got_n = $path->tree_n_to_depth ($depth);
      ok ($got_n, $want_n, "tree_n_to_depth() n=$depth ".join(',',%$options));
    }
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
  my $path = Math::PlanePath::ToothpickTree->new;
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
  my $path = Math::PlanePath::ToothpickTree->new;
  foreach my $elem (@data) {
    my ($n, $want_n_children) = @$elem;
    my $got_n_children = join(',',$path->tree_n_children($n));
    ok ($got_n_children, $want_n_children, "tree_n_children($n)");
  }
}

#------------------------------------------------------------------------------
# n_start, x_negative, y_negative

{
  my $path = Math::PlanePath::ToothpickTree->new;
  ok ($path->n_start, 1, 'n_start()');
  ok ($path->x_negative, 1, 'x_negative()');
  ok ($path->y_negative, 1, 'y_negative()');
}

