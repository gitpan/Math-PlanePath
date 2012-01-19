#!/usr/bin/perl -w

# Copyright 2011, 2012 Kevin Ryde

# This file is part of Math-PlanePath.
#
# Math-PlanePath is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
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
plan tests => 156;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Smart::Comments;

require Math::PlanePath::GcdRationals;
my $path = Math::PlanePath::GcdRationals->new;
my $n_start = $path->n_start;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 65;
  ok ($Math::PlanePath::GcdRationals::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::GcdRationals->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::GcdRationals->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::GcdRationals->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

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
  ok ($n_start, 1, 'n_start()');
  ok ($path->x_negative, 0, 'x_negative()');
  ok ($path->y_negative, 0, 'y_negative()');
}
{
  my @pnames = map {$_->{'name'}}
    Math::PlanePath::GcdRationals->parameter_info_list;
  ok (join(',',@pnames), '');
}


#------------------------------------------------------------------------------
# Y=1 horizontal triangular numbers

{
  foreach my $k (1 .. 15) {
    my $n = $path->xy_to_n ($k, 1); 
    ok ($n, ($k+1)*$k/2);

    my ($x,$y) = $path->n_to_xy($n);
    ok ($x, $k);
    ok ($y, 1);
  }
}

#------------------------------------------------------------------------------
# rect_to_n_range() various

{
  my @data = ([ 7,7, 8,8,   35,93 ],   # 35,93
              [ 19,2, 19,4, 200,217 ], # 200,217,205
              [ 5,3, 5,7,   19,30 ],   # 19,30,20,26
             );
  foreach my $elem (@data) {
    my ($x1,$y1, $x2,$y2, $want_nlo, $want_nhi) = @$elem;
    my ($got_nlo, $got_nhi) = $path->rect_to_n_range ($x1,$y1, $x2,$y2);
    ok ($got_nlo <= $want_nlo,
        1,
        "got_nlo=$got_nlo  want_nlo=$want_nlo");
    ok ($got_nhi >= $want_nhi,
        1,
        "got_nhi=$got_nhi  want_nhi=$want_nhi");
  }
}

# exact ones
{
  my @data = ([ 3,7, 3,8,   24,31 ],
              [ 7,8, 7,13,  35,85 ],
              [ 1,1, 1,1,   1,1 ],
              [ 1,1, 1,2,   1,2 ],
              [ 1,1, 2,1,   1,3 ],
              [ 1,1, 8,1,   1,36 ],
              [ 6,1, 8,1,   21,36 ],
             );
  foreach my $elem (@data) {
    my ($x1,$y1, $x2,$y2, $want_nlo, $want_nhi) = @$elem;
    my ($got_nlo, $got_nhi) = $path->rect_to_n_range ($x1,$y1, $x2,$y2);
    ok ($got_nlo == $want_nlo,
        1,
        "got_nlo=$got_nlo  want_nlo=$want_nlo");
    ok ($got_nhi == $want_nhi,
        1,
        "got_nhi=$got_nhi  want_nhi=$want_nhi");
  }
}


#------------------------------------------------------------------------------
# rect_to_n_range() random

{
  foreach (1 .. 40) {
    my $x1 = int(rand() * 40) + 1;
    my $x2 = $x1 + int(rand() * 4);
    my $y1 = int(rand() * 40) + 1;
    my $y2 = $y1 + int(rand() * 10);

    my $nlo = 0;
    my $nhi = 0;
    my $nlo_y = 'none';
    my $nhi_y = 'none';

    foreach my $x ($x1 .. $x2) {
      foreach my $y ($y1 .. $y2) {
        my $n = $path->xy_to_n($x,$y);
        next if ! defined $n;

        if (! defined $nlo || $n < $nlo) {
          $nlo = $n;
          $nlo_y = $y;
        }
        if (! defined $nhi || $n > $nhi) {
          $nhi = $n;
          $nhi_y = $y;
        }
      }
    }

    my ($got_nlo,$got_nhi) = $path->rect_to_n_range($x1,$y1, $x2,$y2);

    ok (! $nlo || $got_nlo <= $nlo,
        1,
        "x=$x1..$x2 y=$y1..$y2 nlo=$nlo (at y=$nlo_y) but got_nlo=$got_nlo");
    ok (! $nhi || $got_nhi >= $nhi,
        1,
        "x=$x1..$x2 y=$y1..$y2 nhi=$nhi (at y=$nhi_y) but got_nhi=$got_nhi");
  }
}

exit 0;
