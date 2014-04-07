#!/usr/bin/perl -w

# Copyright 2011, 2012, 2014 Kevin Ryde

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

# uncomment this to run the ### lines
use Smart::Comments;

{
  # require Math::PlanePath::SierpinskiTriangle;
  # my $path = Math::PlanePath::SierpinskiTriangle->new;

  require Math::PlanePath::ToothpickTree;
  my $path = Math::PlanePath::ToothpickTree->new;

  my $depth = 5;
  my $n_lo = $path->n_start;
  my $n_hi = $path->tree_depth_to_n_end($depth);

  require Graph::Easy;
  my $graph = Graph::Easy->new();
  foreach my $n ($n_lo .. $n_hi) {
    foreach my $c ($path->tree_n_children($n)) {
      $graph->add_edge($n,$c);
    }
  }
  print "$graph\n";
  print $graph->as_ascii;
  print $graph->as_graphviz();
  exit 0;
}

{
  require Graph;
  my $depth = 4;

  my $path = Math::PlanePath::SierpinskiTriangle->new;
  my $n_lo = $path->n_start;
  my $n_hi = $path->tree_depth_to_n_end($depth);
  my $graph = Graph->new (vertices => [ $n_lo .. $n_hi ],
                          edges => [ map { my $n = $_;
                                           map { [ $n, $_ ] }
                                             $path->tree_n_children($n)
                                           }
                                     $n_lo .. $n_hi ]);
  print "$graph\n";
  ### cyclic: $graph->is_cyclic
  ### acyclic: $graph->is_acyclic
  ### all_successors: $graph->all_successors($n_lo)
  ### neighbours: $graph->neighbours($n_lo)
  ### interior_vertices: $graph->interior_vertices
  ### exterior_vertices: $graph->exterior_vertices

  print "in_degree: ",join(',',map{$graph->in_degree($_)}$n_lo..$n_hi),"\n";
  print "out_degree:   ",join(',',map{$graph->out_degree($_)}$n_lo..$n_hi),"\n";
  print "num_children: ",join(',',map{$path->tree_n_num_children($_)}$n_lo..$n_hi),"\n";
  exit 0;
}
