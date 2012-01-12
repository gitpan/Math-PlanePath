#!/usr/bin/perl -w

# Copyright 2012 Kevin Ryde

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


# Usage: perl cellular-rules.pl
#
# This program printing the patterns from the CellularRule paths as "*"s.
# Rules which generate the same output are listed together rather than
# repeating the output.
#
# Points are plotted by looping $n until its $y is beyond the desired number
# of rows.  @rows is an array of strings of length 2*size+1 spaces each
# which are then set to "*"s at the plotted points.
#
# Another way to plot it would be to loop over $x,$y for the desired
# rectangle and look at $n=$path->xy_to_n($x,$y) to see which cells have
# defined($n).  Characters could be appended or "join(map{})"ed to make an
# output $str in that case.  Though going by $n should be fastest for sparse
# patterns (though CellularRule is not blindingly quick either way).
#
# See Cellular::Automata::Wolfram for the same but with many more options
# and a graphics file output.
#

use 5.004;
use strict;
use Math::PlanePath::CellularRule;

my $size = 15;

my %seen;
my $count = 0;
my $mirror_count = 0;
my $finite_count = 0;

my @strs;
my @rules_list;
my @mirror_of;

foreach my $rule (0 .. 255) {
  my $path = Math::PlanePath::CellularRule->new (rule => $rule);

  my @rows = (' ' x (2*$size+1)) x ($size+1);
  for (my $n = $path->n_start; ; $n++) {
    my ($x,$y) = $path->n_to_xy($n)
      or last; # some patterns are only finitely many N values
    last if $y > $size; # stop at $size+1 many rows

    substr($rows[$y], $x+$size, 1) = '*';
  }
  @rows = reverse @rows;  # print going up the page

  my $str = join("\n",@rows);
  my $seen_rule = $seen{$str};
  if (defined $seen_rule) {
    $rules_list[$seen_rule] .= ",$rule";
    next;
  }

  my $mirror_str = join("\n", map {scalar(reverse)} @rows);
  my $mirror_rule = $seen{$mirror_str};
  if (defined $mirror_rule) {
    $mirror_of[$rule] = " (mirror image of rule $mirror_rule)";
    $mirror_count++;
  }

  $strs[$rule] = $str;
  $rules_list[$rule] = $rule;
  $seen{$str} = $rule;
  $count++;

  if ($rows[0] =~ /^ *$/) {
    $finite_count++;
  }
}

foreach my $rule (0 .. 255) {
  my $str = $strs[$rule] || next;

  print "rule=$rules_list[$rule]", $mirror_of[$rule]||'', "\n";
  print "\n$strs[$rule]\n\n";
}

my $unmirrored_count = $count - $mirror_count;

print "Total $count different rule patterns\n";
print "$mirror_count are mirror images of another\n";
print "$finite_count stop after a few cells\n";
exit 0;
