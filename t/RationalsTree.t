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
BEGIN { plan tests => 398 }

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }

# uncomment this to run the ### lines
#use Smart::Comments;

require Math::PlanePath::RationalsTree;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 43;
  ok ($Math::PlanePath::RationalsTree::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::RationalsTree->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::RationalsTree->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::RationalsTree->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::RationalsTree->new;
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
  my $path = Math::PlanePath::RationalsTree->new;
  ok ($path->n_start, 1, 'n_start()');
  ok ($path->x_negative, 0, 'x_negative()');
  ok ($path->y_negative, 0, 'y_negative()');
}

#------------------------------------------------------------------------------
# n_to_xy(),  xy_to_n()

foreach my $topelem ([ 'SB',
                       [ 1, 1,1 ],

                       [ 2, 1,2 ],
                       [ 3, 2,1 ],

                       [ 4, 1,3 ],
                       [ 5, 2,3 ],
                       [ 6, 3,2 ],
                       [ 7, 3,1 ],

                       [ 8, 1,4 ],
                       [ 9, 2,5 ],
                       [ 10, 3,5 ],
                       [ 11, 3,4 ],
                       [ 12, 4,3 ],
                       [ 13, 5,3 ],
                       [ 14, 5,2 ],
                       [ 15, 4,1 ],

                       [ 16, 1,5 ],
                       [ 17, 2,7 ],
                       [ 18, 3,8 ],
                       [ 19, 3,7 ],
                       [ 20, 4,7 ],
                       [ 21, 5,8 ],
                       [ 22, 5,7 ],
                       [ 23, 4,5 ],
                       [ 24, 5,4 ],
                       [ 25, 7,5 ],
                       [ 26, 8,5 ],
                       [ 27, 7,4 ],
                       [ 28, 7,3 ],
                       [ 29, 8,3 ],
                       [ 30, 7,2 ],
                       [ 31, 5,1 ],
                     ],
                     [ 'CW',
                       [ 1, 1,1 ],

                       [ 2, 1,2 ],
                       [ 3, 2,1 ],

                       [ 4, 1,3 ],
                       [ 5, 3,2 ],
                       [ 6, 2,3 ],
                       [ 7, 3,1 ],

                       [ 8, 1,4 ],
                       [ 9, 4,3 ],
                       [ 10, 3,5 ],
                       [ 11, 5,2 ],
                       [ 12, 2,5 ],
                       [ 13, 5,3 ],
                       [ 14, 3,4 ],
                       [ 15, 4,1 ],
                     ],

                     [ 'Bird',
                       [ 1, 1,1 ],

                       [ 2, 1,2 ],
                       [ 3, 2,1 ],

                       [ 4, 2,3 ],
                       [ 5, 1,3 ],
                       [ 6, 3,1 ],
                       [ 7, 3,2 ],

                       [ 8, 3,5 ],
                       [ 9, 3,4 ],
                       [ 10, 1,4 ],
                       [ 11, 2,5 ],
                       [ 12, 5,2 ],
                       [ 13, 4,1 ],
                       [ 14, 4,3 ],
                       [ 15, 5,3 ],

                       [ 16, 5,8 ],
                       [ 17, 4,7 ],
                       [ 18, 4,5 ],
                       [ 19, 5,7 ],
                       [ 20, 2,7 ],
                       [ 21, 1,5 ],
                       [ 22, 3,7 ],
                       [ 23, 3,8 ],
                       [ 24, 8,3 ],
                       [ 25, 7,3 ],
                       [ 26, 5,1 ],
                       [ 27, 7,2 ],
                       [ 28, 7,5 ],
                       [ 29, 5,4 ],
                       [ 30, 7,4 ],
                       [ 31, 8,5 ],
                     ],
                    ) {
  my ($tree_type, @elems) = @$topelem;
  my $path = Math::PlanePath::RationalsTree->new (tree_type => $tree_type);

  foreach my $elem (@elems) {
    my ($n, $want_x, $want_y) = @$elem;
    my ($got_x, $got_y) = $path->n_to_xy ($n);
    ok ($got_x, $want_x, "x at n=$n");
    ok ($got_y, $want_y, "y at n=$n");
  }

  foreach my $elem (@elems) {
    my ($want_n, $x, $y) = @$elem;
    my $got_n = $path->xy_to_n ($x, $y);
    ok ($got_n, $want_n, "n at x=$x,y=$y");
  }

  foreach my $elem (@elems) {
    my ($n, $x, $y) = @$elem;
    my ($got_nlo, $got_nhi) = $path->rect_to_n_range (0,0, $x,$y);
    ok ($got_nlo <= $n, 1, "rect_to_n_range() nlo=$got_nlo at n=$n,x=$x,y=$y");
    ok ($got_nhi >= $n, 1, "rect_to_n_range() nhi=$got_nhi at n=$n,x=$x,y=$y");
  }
}


#------------------------------------------------------------------------------
# xy_to_n() distinct n

foreach my $options ([tree_type => 'SB'],
                     [tree_type => 'CW'],
                     [tree_type => 'AYT'],
                    ) {
  my $path = Math::PlanePath::RationalsTree->new (@$options);
  my $bad = 0;
  my %seen;
  my $xlo = -2;
  my $xhi = 25;
  my $ylo = -2;
  my $yhi = 20;
  my ($nlo, $nhi) = $path->rect_to_n_range($xlo,$ylo, $xhi,$yhi);
  my $count = 0;
 OUTER: for (my $x = $xlo; $x <= $xhi; $x++) {
    for (my $y = $ylo; $y <= $yhi; $y++) {
      my $n = $path->xy_to_n ($x,$y);
      next if ! defined $n;  # sparse

      # avoid overflow when N becomes big
      if ($n >= 2**32) {
        MyTestHelpers::diag ("x=$x,y=$y n=$n, oops, meant to keep below 2^32");
        last if $bad++ > 10;
        next;
      }

      if ($seen{$n}) {
        MyTestHelpers::diag ("x=$x,y=$y n=$n seen before at $seen{$n}");
        last if $bad++ > 10;
      }
      if ($n < $nlo) {
        MyTestHelpers::diag ("x=$x,y=$y n=$n below nlo=$nlo");
        last OUTER if $bad++ > 10;
      }
      if ($n > $nhi) {
        MyTestHelpers::diag ("x=$x,y=$y n=$n above nhi=$nhi");
        last OUTER if $bad++ > 10;
      }
      $seen{$n} = "$x,$y";
      $count++;
    }
  }
  ok ($bad, 0, "xy_to_n() coverage and distinct, $count points");
}

exit 0;
