#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

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


use 5.010;
use strict;
use warnings;
use POSIX ();
use List::Util 'min', 'max';

# uncomment this to run the ### lines
#use Smart::Comments;

{
  # average diff step 4*sqrt(2)
  require Image::Base::Text;
  my $prev = 0;
  my $diff_total = 0;
  my $diff_count = 0;
  foreach my $r (1 .. 500) {
    my $w = 2*$r+1;
    my $image = Image::Base::Text->new (-width => $w,
                                        -height => $w);
    $image->ellipse (0,0, $w-1,$w-1, 'x');
    my $str = $image->save_string;
    my $count = ($str =~ tr/x/x/);
    my $diff = $count - $prev;
    printf "%2d %3d  %2d\n", $r, $count, $diff;
    $prev = $count;
    $diff_total += $diff;
    $diff_count++;
  }
  print "diff average ",$diff_total/$diff_count,"\n";
  exit 0;
}


my $width = 79;
my $height = 23;

my @rows;
my @x;
my @y;
foreach my $r (0 .. 39) {
  my $rr = $r * $r;
  # E(x,y) = x^2*r^2 + y^2*r^2 - r^2*r^2
  #
  # Initially,
  #     d1 = E(x-1/2,y+1)
  #        = (x-1/2)^2*r^2 + (y+1)^2*r^2 - r^2*r^2
  # which for x=r,y=0 is
  #        = r^2 - r^2*r + r^2/4
  #        = (r + 5/4) * r^2
  #
  my $x = $r;
  my $y = 0;
  my $d = ($x-.5)**2 * $rr + ($y+1)**2 * $rr - $rr*$rr;
  my $count = 0;
  while ($x >= $y) {
    ### at: "$x,$y"
    ### assert: $d == ($x-.5)**2 * $rr + ($y+1)**2 * $rr - $rr*$rr

    push @x, $x;
    push @y, $y;
    $rows[$y]->[$x] = ($r%10);
    $count++;

    if( $d < 0 ) {
      $d += $rr * (2*$y + 3);
      ++$y;
    }
    else {
      $d += $rr * (2*$y - 2*$x + 5);
      ++$y;
      --$x;
    }
  }
  my $c = int (2*3.14159*$r/8 + .5);
  printf "%2d %2d %2d  %s\n", $r, $count, $c, ($count!=$c ? "**" : "");
}

foreach my $row (reverse @rows) {
  if ($row) {
    foreach my $char (@$row) {
      print ' ', $char // ' ';
    }
  }
  print "\n";
}
