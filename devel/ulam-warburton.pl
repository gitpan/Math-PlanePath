#!/usr/bin/perl -w

# Copyright 2010, 2011, 2012 Kevin Ryde

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
use warnings;

# uncomment this to run the ### lines
#use Smart::Comments;


{
  # number of children
  require Math::PlanePath::UlamWarburton;
  require Math::PlanePath::UlamWarburtonQuarter;
  # my $path = Math::PlanePath::UlamWarburton->new;
  my $path = Math::PlanePath::UlamWarburtonQuarter->new;
  my $prev_depth = 0;
  for (my $n = $path->n_start; ; $n++) {
    my $depth = $path->tree_n_to_depth($n);
    if ($depth != $prev_depth) {
      $prev_depth = $depth;
      print "\n";
      last if $depth > 40;
    }
    my $num_children = $path->tree_n_num_children($n);
    print "$num_children,";
  }
  print "\n";
  exit 0;
}
# turn on u(0) = 1
#         u(1) = 1
#         u(n) = 4 * 3^ones(n-1) - 1
# where ones(x) = number of 1 bits   A000120
#
{
  my @yx;
  sub count_around {
    my ($x,$y) = @_;
    return ((!! $yx[$y+1][$x])
            + (!! $yx[$y][$x+1])
            + ($x > 0 && (!! $yx[$y][$x-1]))
            + ($y > 0 && (!! $yx[$y-1][$x])));
  }
  my (@turn_x,@turn_y);
  sub turn_on {
    my ($x,$y) = @_;
    ### turn_on(): "$x,$y"
    if (! $yx[$y][$x] && count_around($x,$y) == 1) {
      push @turn_x, $x;
      push @turn_y, $y;
    }
  }

  my $print_grid = 1;
  my $cumulative = 1;


  my @lchar = ('a' .. 'z');
  $yx[0][0] = $lchar[0];
  for my $level (1 .. 20) {
    print "\n";

    printf "level %d  %b\n", $level, $level;
    if ($print_grid) {
      foreach my $row (reverse @yx) {
        foreach my $cell (@$row) {
          print ' ', (defined $cell #&& ($cell eq 'p' || $cell eq 'o')
                      ? $cell : ' ');
        }
        print "\n";
      }
      print "\n";
    }

    {
      my $count = 0;
      foreach my $row (reverse @yx) {
        foreach my $cell (@$row) {
          $count += defined $cell;
        }
      }
      print "total $count\n";
    }


    foreach my $y (0 .. $#yx) {
      my $row = $yx[$y];
      foreach my $x (0 .. $#$row) {
        $yx[$y][$x] or next;
        ### cell: $yx[$y][$x]

        turn_on ($x, $y+1);
        turn_on ($x+1, $y);
        if ($x > 0) {
          turn_on ($x-1, $y);
        }
        if ($y > 0) {
          turn_on ($x, $y-1);
        }
      }
    }
    print "extra ",scalar(@turn_x),"\n";

    my %seen_turn;
    for (my $i = 0; $i < @turn_x; ) {
      my $key = "$turn_x[$i],$turn_y[$i]";
      if ($seen_turn{$key}) {
        splice @turn_x,$i,1;
        splice @turn_y,$i,1;
      } else {
        $seen_turn{$key} = 1;
        $i++;
      }
    }

    my $e = 4*(scalar(@turn_x)-2)+4;
    $cumulative += $e;
    print "extra $e  cumulative $cumulative\n";
    ### @turn_x
    ### @turn_y
    while (@turn_x) {
      $yx[pop @turn_y][pop @turn_x] = ($lchar[$level]||'z');
    }
    ### @yx
  }
  exit 0;
}
