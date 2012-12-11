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
plan tests => 2;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

# uncomment this to run the ### lines
#use Devel::Comments '###';

use Math::PlanePath::UlamWarburton;
my $path = Math::PlanePath::UlamWarburton->new;


#------------------------------------------------------------------------------

# my @grid;
# my $offset = 30;
# my @n_start;
# 
# my $prev = 0;
# $grid[0+$offset][0+$offset] = 0;
# foreach my $n (1 .. 300) {
#   my ($x,$y) = $path->n_to_xy($n);
#   my $l = $grid[$x+$offset-1][$y+$offset]
#     ||  $grid[$x+$offset+1][$y+$offset]
#       || $grid[$x+$offset][$y+$offset-1]
#         ||  $grid[$x+$offset][$y+$offset+1]
#           || 0;
#   if ($l != $prev) {
#     push @n_start, $n;
#     $prev = $l;
#   }
#   $grid[$x+$offset][$y+$offset] = $l+1;
# }
# ### @n_start
# my @n_end = map {$_-1} @n_start;
# ### @n_end
# 
# my @levelcells = (1, map {$n_start[$_]-$n_start[$_-1]} 1 .. $#n_start);
# ### @levelcells

# foreach my $y (reverse -$offset .. $offset) {
#   foreach my $x (-$offset .. $offset) {
#     my $c = $grid[$x+$offset][$y+$offset];
#     if (! defined $c) { $c = ' '; }
#     print $c;
#   }
#   print "\n";
# }


#------------------------------------------------------------------------------
# A147582 - count new cells in each level

MyOEIS::compare_values
  (anum => 'A147582',
   func => sub {
     my ($count) = @_;
     my @got;
     my $prev = $path->tree_depth_to_n(0);
     for (my $depth = 1; @got < $count; $depth++) {
       my $n = $path->tree_depth_to_n($depth);
       push @got, $n - $prev;
       $prev = $n;
     }
     return \@got;
   });

#------------------------------------------------------------------------------

exit 0;
