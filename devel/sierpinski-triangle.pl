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
use Math::PlanePath::SierpinskiTriangle;

use Math::PlanePath;
*_divrem_mutate = \&Math::PlanePath::_divrem_mutate;

use Math::PlanePath::Base::Digits
  'digit_split_lowtohigh',
  'digit_join_lowtohigh';

# uncomment this to run the ### lines
use Smart::Comments;


{
  # number of children
  my $path = Math::PlanePath::SierpinskiTriangle->new;
  for (my $n = $path->n_start+1; $n < 40; $n++) {
    my @n_children = $path->tree_n_children($n);
    my $num_children = scalar(@n_children);
    print "$num_children,";
  }
  print "\n";
  exit 0;
}

{
  # number of children in replicate style

  my $levels = 5;
  my $height = 2**$levels;
  
  sub replicate_n_to_xy {
    my ($n) = @_;
    my $zero = $n * 0;
    my @xpos_bits;
    my @xneg_bits;
    my @y_bits;
    foreach my $ndigit (digit_split_lowtohigh($n,3)) {
      if ($ndigit == 0) {
        push @xpos_bits, 0;
        push @xneg_bits, 0;
        push @y_bits, 0;
      } elsif ($ndigit == 1) {
        push @xpos_bits, 0;
        push @xneg_bits, 1;
        push @y_bits, 1;
      } else {
        push @xpos_bits, 1;
        push @xneg_bits, 0;
        push @y_bits, 1;
      }
    }

    return (digit_join_lowtohigh(\@xpos_bits, 2, $zero)
            - digit_join_lowtohigh(\@xneg_bits, 2, $zero),

            digit_join_lowtohigh(\@y_bits, 2, $zero));
  }

  # xxx0    = 2    low digit 0 then num children = 2
  # xxx0111 = 1  \ low digit != 0 then all low non-zeros must be same
  # xxx0222 = 1  /
  # other   = 0    otherwise num children = 0
  
  sub replicate_tree_n_num_children {
    my ($n) = @_;
    $n = int($n);
    my $low_digit = _divrem_mutate($n,3);
    if ($low_digit == 0) {
      return 2;
    }
    while (my $digit = _divrem_mutate($n,3)) {
      if ($digit != $low_digit) {
        return 0;
      }
    }
    return 1;
  }

  my $path = Math::PlanePath::SierpinskiTriangle->new;
  my %grid;
  for (my $n = 0; $n < 3**$levels; $n++) {
    my ($x,$y) = replicate_n_to_xy($n);
    my $path_num_children = path_xy_num_children($path,$x,$y);
    my $repl_num_children = replicate_tree_n_num_children($n);
    if ($path_num_children != $repl_num_children) {
      print "$x,$y  $path_num_children $repl_num_children\n";
      exit 1;
    }
    $grid{$x}{$y} = $repl_num_children;
  }

  foreach my $y (0 .. $height) {
    foreach my $x (-$height .. $y) {
      print $grid{$x}{$y} // ' ';
    }
    print "\n";
  }
  exit 0;

  sub path_xy_num_children {
    my ($path, $x,$y) = @_;
    my $n = $path->xy_to_n($x,$y);
    return (defined $n
            ? $path->tree_n_num_children($n)
            : undef);
  }
}


{
  my $path = Math::PlanePath::SierpinskiTriangle->new;
  foreach my $y (0 .. 10) {
    foreach my $x (-$y .. $y) {
      if ($path->xy_to_n($x,$y)) {
        print "1,";
      } else {
        print "0,";
      }
    }
  }
  print "\n";
  exit 0;
}
