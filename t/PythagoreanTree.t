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
plan tests => 301;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Smart::Comments;

require Math::PlanePath::PythagoreanTree;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 90;
  ok ($Math::PlanePath::PythagoreanTree::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::PythagoreanTree->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::PythagoreanTree->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::PythagoreanTree->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::PythagoreanTree->new;
  ok ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      1,
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      1,
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# ab_to_pq()
{
  require Math::PlanePath::CoprimeColumns;
  require Math::PlanePath::GcdRationals;

  my $bad = 0;
  foreach my $a (-2 .. 50) {
    foreach my $b (-2 .. 50) {
      my ($p,$q) = Math::PlanePath::PythagoreanTree::_ab_to_pq($a,$b);

      if (defined $p || defined $q) {
        unless ($p > $q) {
          MyTestHelpers::diag ("bad, a=$a,b=$b gives p=$p,q=$q not p>q");
          $bad++;
        }
        unless ($q >= 1) {
          MyTestHelpers::diag ("bad, a=$a,b=$b gives p=$p,q=$q not q>=1");
          $bad++;
        }
        # unless (Math::PlanePath::CoprimeColumns::_coprime($p,$q)) {
        #   my $gcd = Math::PlanePath::GcdRationals::_gcd($p,$q);
        #   MyTestHelpers::diag ("bad, a=$a,b=$b gives p=$p,q=$q not coprime, gcd=$gcd");
        #   $bad++;
        # }
      }

      if (ab_is_primitive_triple($a,$b)) {
        unless (defined $p && defined $q) {
          MyTestHelpers::diag ("bad, a=$a,b=$b doesn't give p,q");
          $bad++;
        }
      } else {
        # Some non-primitive pass _ab_to_pq(), some do not.
        # if (defined $p || defined $q) {
        #   my $gcd = Math::PlanePath::GcdRationals::_gcd($p,$q);
        #   MyTestHelpers::diag ("bad, a=$a,b=$b not primitive triple but gives p=$p,q=$q (with gcd=$gcd)");
        #   $bad++;
        # }
      }
    }
  }
  ok ($bad, 0);

  sub ab_is_primitive_triple {
    my ($a,$b) = @_;
    if ($a < 3 || $b < 3) {
      return 0;
    }
    unless ($a & 1 && !($b & 1)) {
      return 0;
    }
    my $csquared = $a*$a + $b*$b;
    my $c = int(sqrt($csquared));
    if ($c*$c != $csquared) {
      return 0;
    }
    return Math::PlanePath::CoprimeColumns::_coprime($a,$b);
  }
}

#------------------------------------------------------------------------------
# n_start, x_negative, y_negative

{
  my $path = Math::PlanePath::PythagoreanTree->new;
  ok ($path->n_start, 1, 'n_start()');
  ok ($path->x_negative, 0, 'x_negative()');
  ok ($path->y_negative, 0, 'y_negative()');
}
{
  my @pnames = map {$_->{'name'}}
    Math::PlanePath::PythagoreanTree->parameter_info_list;
  ok (join(',',@pnames), 'tree_type,coordinates');
}

#------------------------------------------------------------------------------
# tree_n_parent()
{
  my @data = ([ 1, undef ],

              [ 2,  1 ],
              [ 3,  1 ],
              [ 4,  1 ],

              [ 5,  2 ],
              [ 6,  2 ],
              [ 7,  2 ],
              [ 8,  3 ],
              [ 9,  3 ],
              [ 10,  3 ],
              [ 11,  4 ],
              [ 12,  4 ],
              [ 13,  4 ],
             );
  my $path = Math::PlanePath::PythagoreanTree->new;
  foreach my $elem (@data) {
    my ($n, $want_n_parent) = @$elem;
    my $got_n_parent = $path->tree_n_parent ($n);
    ok ($got_n_parent, $want_n_parent);
  }
}

#------------------------------------------------------------------------------
# tree_n_children()
{
  my @data = ([ 1, '2,3,4' ],

              [ 2,  '5,6,7' ],
              [ 3,  '8,9,10' ],
              [ 4,  '11,12,13' ],

              [ 5,  '14,15,16' ],
              [ 6,  '17,18,19' ],
              [ 7,  '20,21,22' ],
             );
  my $path = Math::PlanePath::PythagoreanTree->new;
  foreach my $elem (@data) {
    my ($n, $want_n_children) = @$elem;
    my $got_n_children = join(',',$path->tree_n_children($n));
    ok ($got_n_children, $want_n_children, "tree_n_children($n)");
  }
}

#------------------------------------------------------------------------------
# n_to_xy(),  xy_to_n()

# tree_type=UAD, coordinates=AB
{
  my @data = ([ 1, 3,4 ],

              [ 2,  5,12 ],
              [ 3,  21,20 ],
              [ 4,  15,8 ],

              [ 5,  7,24 ],
              [ 6,  55,48 ],
              [ 7,  45,28 ],
              [ 8,  39,80 ],
              [ 9,  119,120 ],
              [ 10,  77,36 ],
              [ 11,  33,56 ],
              [ 12,  65,72 ],
              [ 13,  35,12 ],

              [ undef, 27,36 ],
              [ undef, 45,108 ],
              [ undef, 63,216 ],
              [ undef, 75,100 ],
              [ undef, 81,360 ],
             );
  my $path = Math::PlanePath::PythagoreanTree->new;
  foreach my $elem (@data) {
    my ($n, $want_x, $want_y) = @$elem;
    next unless defined $n;
    my ($got_x, $got_y) = $path->n_to_xy ($n);
    ok ($got_x, $want_x, "x at n=$n");
    ok ($got_y, $want_y, "y at n=$n");
  }

  foreach my $elem (@data) {
    my ($want_n, $x, $y) = @$elem;
    my $got_n = $path->xy_to_n ($x, $y);
    ok ($got_n, $want_n, "n at x=$x,y=$y");
  }

  foreach my $elem (@data) {
    my ($n, $x, $y) = @$elem;
    next unless defined $n;
    my ($got_nlo, $got_nhi) = $path->rect_to_n_range (0,0, $x,$y);
    ok ($got_nlo <= $n, 1, "rect_to_n_range() nlo=$got_nlo at n=$n,x=$x,y=$y");
    ok ($got_nhi >= $n, 1, "rect_to_n_range() nhi=$got_nhi at n=$n,x=$x,y=$y");
  }
}

# tree_type=UAD, coordinates=PQ
{
  my @data = ([ 1,  2,1 ],

              [ 2,  3,2 ],
              [ 3,  5,2 ],
              [ 4,  4,1 ],

              [ 5,  4,3 ],
              [ 6,  8,3 ],
              [ 7,  7,2 ],
              [ 8,  8,5 ],
              [ 9,  12,5 ],
              [ 10,  9,2 ],
              [ 11,  7,4 ],
              [ 12,  9,4 ],
              [ 13,  6,1 ],
             );
  my $path = Math::PlanePath::PythagoreanTree->new
    (coordinates => 'PQ');
  foreach my $elem (@data) {
    my ($n, $want_x, $want_y) = @$elem;
    my ($got_x, $got_y) = $path->n_to_xy ($n);
    ok ($got_x, $want_x, "x at n=$n");
    ok ($got_y, $want_y, "y at n=$n");
  }

  foreach my $elem (@data) {
    my ($want_n, $x, $y) = @$elem;
    my $got_n = $path->xy_to_n ($x, $y);
    ok ($got_n, $want_n, "n at x=$x,y=$y");
  }

  foreach my $elem (@data) {
    my ($n, $x, $y) = @$elem;
    my ($got_nlo, $got_nhi) = $path->rect_to_n_range (0,0, $x,$y);
    ok ($got_nlo <= $n, 1, "rect_to_n_range() nlo=$got_nlo at n=$n,x=$x,y=$y");
    ok ($got_nhi >= $n, 1, "rect_to_n_range() nhi=$got_nhi at n=$n,x=$x,y=$y");
  }
}

# tree_type=FB, coordinates=AB
{
  my @data = ([ 1, 3,4 ],

              [ 2,  5,12 ],
              [ 3,  15,8 ],
              [ 4,  7,24 ],

              [ 5,  9,40 ],
              [ 6,  35,12 ],
              [ 7,  11,60 ],
              [ 8,  21,20 ],
              [ 9,  55,48 ],
              [ 10,  39,80 ],
              [ 11,  13,84 ],
              [ 12,  63,16 ],
              [ 13,  15,112 ],
             );
  my $path = Math::PlanePath::PythagoreanTree->new
    (tree_type => 'FB');
  foreach my $elem (@data) {
    my ($n, $want_x, $want_y) = @$elem;
    my ($got_x, $got_y) = $path->n_to_xy ($n);
    ok ($got_x, $want_x, "x at n=$n");
    ok ($got_y, $want_y, "y at n=$n");
  }

  foreach my $elem (@data) {
    my ($want_n, $x, $y) = @$elem;
    my $got_n = $path->xy_to_n ($x, $y);
    ok ($got_n, $want_n, "n at x=$x,y=$y");
  }

  foreach my $elem (@data) {
    my ($n, $x, $y) = @$elem;
    my ($got_nlo, $got_nhi) = $path->rect_to_n_range (0,0, $x,$y);
    ok ($got_nlo <= $n, 1, "rect_to_n_range() nlo=$got_nlo at n=$n,x=$x,y=$y");
    ok ($got_nhi >= $n, 1, "rect_to_n_range() nhi=$got_nhi at n=$n,x=$x,y=$y");
  }
}

# tree_type=FB, coordinates=PQ
{
  my @data = ([ 1,  2,1 ],

              [ 2,  3,2 ],  # K1
              [ 3,  4,1 ],  # K2
              [ 4,  4,3 ],  # K3

              [ 5,  5,4 ],
              [ 6,  6,1 ],
              [ 7,  6,5 ],
              [ 8,  5,2 ],
              [ 9,  8,3 ],
              [ 10,  8,5 ],
              [ 11,  7,6 ],
              [ 12,  8,1 ],
              [ 13,  8,7 ],
             );
  my $path = Math::PlanePath::PythagoreanTree->new
    (tree_type => 'FB',
     coordinates => 'PQ');
  foreach my $elem (@data) {
    my ($n, $want_x, $want_y) = @$elem;
    my ($got_x, $got_y) = $path->n_to_xy ($n);
    ok ($got_x, $want_x, "x at n=$n");
    ok ($got_y, $want_y, "y at n=$n");
  }

  foreach my $elem (@data) {
    my ($want_n, $x, $y) = @$elem;
    my $got_n = $path->xy_to_n ($x, $y);
    ok ($got_n, $want_n, "n at x=$x,y=$y");
  }

  foreach my $elem (@data) {
    my ($n, $x, $y) = @$elem;
    my ($got_nlo, $got_nhi) = $path->rect_to_n_range (0,0, $x,$y);
    ok ($got_nlo <= $n, 1, "rect_to_n_range() nlo=$got_nlo at n=$n,x=$x,y=$y");
    ok ($got_nhi >= $n, 1, "rect_to_n_range() nhi=$got_nhi at n=$n,x=$x,y=$y");
  }
}


#------------------------------------------------------------------------------
# xy_to_n() distinct n

foreach my $options ([tree_type => 'UAD', coordinates => 'AB'],
                     [tree_type => 'UAD', coordinates => 'PQ'],
                     [tree_type => 'FB', coordinates => 'AB'],
                     [tree_type => 'FB', coordinates => 'PQ']) {
  my $path = Math::PlanePath::PythagoreanTree->new (@$options);
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
