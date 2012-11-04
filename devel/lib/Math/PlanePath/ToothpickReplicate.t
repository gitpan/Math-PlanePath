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
plan tests => 215;;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

require Math::PlanePath::ToothpickReplicate;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 92;
  ok ($Math::PlanePath::ToothpickReplicate::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::ToothpickReplicate->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::ToothpickReplicate->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::ToothpickReplicate->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::ToothpickReplicate->new;
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
  my $path = Math::PlanePath::ToothpickReplicate->new;
  ok ($path->n_start, 1, 'n_start()');
  ok ($path->x_negative, 1, 'x_negative()');
  ok ($path->y_negative, 1, 'y_negative()');
  ok ($path->class_x_negative, 1, 'class_x_negative() instance method');
  ok ($path->class_y_negative, 1, 'class_y_negative() instance method');
}
{
  my @pnames = map {$_->{'name'}}
    Math::PlanePath::ToothpickReplicate->parameter_info_list;
  ok (join(',',@pnames), 'parts');
}

#------------------------------------------------------------------------------
# first few points

{
  my @data = ([ [ parts => '3/4' ],

                [ 1,    0,0 ],
                [ 2,    0,1 ],

                [ 3,    0,-1 ], # quad 3
                [ 4,    1,-1 ],

                [ 5,    1,1 ], # quad 1
                [ 6,    1,2 ],

                [ 7,   -1,1 ], # quad 2
                [ 8,   -1,2 ],

                # [ 6,    2,2 ], # A
                # [ 7,    2,3 ], # B
                #
                # [ 8,    2,1 ], # 1
                # [ 9,    3,1 ],
                # [ 10,   3,3 ], # 2
                # [ 11,   3,4 ],
                # [ 12,   1,3 ], # 3
                # [ 13,   1,4 ],
                #
                # [ 11,   4,4 ], # A
                # [ 12,   4,5 ], # B
                #
                # # part 1
                # [ 13,   4,3 ], # 0
                # [ 14,   5,3 ],
                # [ 15,   5,2 ], # A
                # [ 16,   6,2 ], # B
                # [ 17,   4,2 ], # 1
                # [ 18,   4,1 ],
                # [ 19,   6,1 ], # 2
                # [ 20,   7,1 ],
                # [ 21,   6,3 ], # 3
                # [ 22,   7,3 ],
                #
                # # part 2
                # [ 23,   5,5 ], # 0
                # [ 24,   5,6 ], # 0
                #
                # # part 3
                # [ 33,   3,5 ], # 0
                # [ 34,   3,6 ], # 0
                # [ 35,   2,6 ], # A
                # [ 36,   2,7 ], # B
                # [ 37,   2,5 ], # 1
                # [ 38,   1,5 ],
                # [ 39,   1,7 ], # 2
                # [ 40,   1,8 ],
                # [ 41,   3,7 ], # 3
                # [ 42,   3,8 ],
              ],

[ [ parts => 'all' ],

                [ 1,    0,0 ],
                [ 2,    0,1 ],
                [ 3,    0,-1 ],

                [ 4,    1,1 ], # quad 0
                [ 5,    1,2 ],

                [ 6,   -1,1 ], # quad 1
                [ 7,   -1,2 ],

                [ 8,   -1,-1 ], # quad 2
                [ 9,   -1,-2 ],

                [ 10,  1,-1 ], # quad 3
                [ 11,  1,-2 ],

                # [ 6,    2,2 ], # A
                # [ 7,    2,3 ], # B
                #
                # [ 8,    2,1 ], # 1
                # [ 9,    3,1 ],
                # [ 10,   3,3 ], # 2
                # [ 11,   3,4 ],
                # [ 12,   1,3 ], # 3
                # [ 13,   1,4 ],
                #
                # [ 11,   4,4 ], # A
                # [ 12,   4,5 ], # B
                #
                # # part 1
                # [ 13,   4,3 ], # 0
                # [ 14,   5,3 ],
                # [ 15,   5,2 ], # A
                # [ 16,   6,2 ], # B
                # [ 17,   4,2 ], # 1
                # [ 18,   4,1 ],
                # [ 19,   6,1 ], # 2
                # [ 20,   7,1 ],
                # [ 21,   6,3 ], # 3
                # [ 22,   7,3 ],
                #
                # # part 2
                # [ 23,   5,5 ], # 0
                # [ 24,   5,6 ], # 0
                #
                # # part 3
                # [ 33,   3,5 ], # 0
                # [ 34,   3,6 ], # 0
                # [ 35,   2,6 ], # A
                # [ 36,   2,7 ], # B
                # [ 37,   2,5 ], # 1
                # [ 38,   1,5 ],
                # [ 39,   1,7 ], # 2
                # [ 40,   1,8 ],
                # [ 41,   3,7 ], # 3
                # [ 42,   3,8 ],
              ],

              [ [ parts => 'quarter' ],
                [ 1,    1,1 ],
                [ 2,    1,2 ],
                [ 3,    2,2 ], # A
                [ 4,    2,3 ], # B

                [ 5,    2,1 ], # 1
                [ 6,    3,1 ],
                [ 7,    3,3 ], # 2
                [ 8,    3,4 ],
                [ 9,    1,3 ], # 3
                [ 10,   1,4 ],

                [ 11,   4,4 ], # A
                [ 12,   4,5 ], # B

                # part 1
                [ 13,   4,3 ], # 0
                [ 14,   5,3 ],
                [ 15,   5,2 ], # A
                [ 16,   6,2 ], # B
                [ 17,   4,2 ], # 1
                [ 18,   4,1 ],
                [ 19,   6,1 ], # 2
                [ 20,   7,1 ],
                [ 21,   6,3 ], # 3
                [ 22,   7,3 ],

                # part 2
                [ 23,   5,5 ], # 0
                [ 24,   5,6 ], # 0

                # part 3
                [ 33,   3,5 ], # 0
                [ 34,   3,6 ], # 0
                [ 35,   2,6 ], # A
                [ 36,   2,7 ], # B
                [ 37,   2,5 ], # 1
                [ 38,   1,5 ],
                [ 39,   1,7 ], # 2
                [ 40,   1,8 ],
                [ 41,   3,7 ], # 3
                [ 42,   3,8 ],
              ],
             );
  foreach my $elem (@data) {
    my ($options, @points) = @$elem;
    my $path = Math::PlanePath::ToothpickReplicate->new (@$options);
    foreach my $point (@points) {
      my ($n, $x, $y) = @$point;
      {
        # n_to_xy()
        my ($got_x, $got_y) = $path->n_to_xy ($n);
        if ($got_x == 0) { $got_x = 0 }  # avoid "-0"
        if ($got_y == 0) { $got_y = 0 }
        ok ($got_x, $x, "n_to_xy() x at n=$n");
        ok ($got_y, $y, "n_to_xy() y at n=$n");
      }
      # if ($n==int($n)) {
      #   # xy_to_n()
      #   my $got_n = $path->xy_to_n ($x, $y);
      #   ok ($got_n, $n, "xy_to_n() n at x=$x,y=$y");
      # }

      if ($n == int($n)) {
        {
          my ($got_nlo, $got_nhi) = $path->rect_to_n_range (0,0, $x,$y);
          ok ($got_nlo <= $n, 1, "rect_to_n_range(0,0,$x,$y) for n=$n, got_nlo=$got_nlo");
          ok ($got_nhi >= $n, 1, "rect_to_n_range(0,0,$x,$y) for n=$n, got_nhi=$got_nhi");
        }
        {
          $n = int($n);
          my ($got_nlo, $got_nhi) = $path->rect_to_n_range ($x,$y, $x,$y);
          ok ($got_nlo <= $n, 1, "rect_to_n_range($x,$y,$x,$y) for n=$n, got_nlo=$got_nlo");
          ok ($got_nhi >= $n, 1, "rect_to_n_range($x,$y,$x,$y) for n=$n, got_nhi=$got_nhi");
        }
      }
    }
  }
}


# #------------------------------------------------------------------------------
# # N on leading diagonal
# 
# {
#   my $path = Math::PlanePath::ToothpickReplicate->new;
#   foreach my $i (1 .. 32) {
#     my $n = $path->xy_to_n($i,$i);
#     printf "%b %d %b %b\n", $i, $n,$n, 3*$n;
#   }
# }
# exit 0;


exit 0;
