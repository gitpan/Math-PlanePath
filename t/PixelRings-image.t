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

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

use Math::PlanePath::PixelRings;

my $test_count = 2;
plan tests => $test_count;

if (! eval 'use Image::Base 1.09; 1') { # version 1.09 for ellipse fixes
  MyTestHelpers::diag ('Image::Base 1.09 not available -- ',$@);
  foreach (1 .. $test_count) {
    skip ('due to no Image::Base 1.09', 1, 1);
  }
  exit 0;
}

# uncomment this to run the ### lines
#use Smart::Comments;

sub dump_coords {
  my ($href) = @_;
  my $x_min = 0;
  my $y_min = 0;
  foreach my $key (keys %$href) {
    my ($x,$y) = split /,/, $key;
    if ($x < $x_min) { $x_min = $x; }
    if ($y < $y_min) { $y_min = $y; }
  }
  my @rows;
  foreach my $key (keys %$href) {
    my ($x,$y) = split /,/, $key;
    $rows[$y-$y_min]->[$x-$x_min] = '*';
  }
  foreach my $row (reverse @rows) {
    my $str = '';
    if ($row) {
      foreach my $char (@$row) {
        if ($char) {
          $str .= " $char";
        } else {
          $str .= "  ";
        }
      }
    }
    MyTestHelpers::diag ($str);
  }
}

my %image_coords;
my $offset = 100;
{
  package MyImage;
  use vars '@ISA';
  @ISA = ('Image::Base');
  sub new {
    my $class = shift;
    return bless {@_}, $class;
  }
  sub xy {
    my ($self, $x, $y, $colour) = @_;
    $x -= $offset;
    $y -= $offset;
    ### image_coords: "$x,$y"
    $image_coords{"$x,$y"} = 1;
  }
}

my $image = MyImage->new;
my $path = Math::PlanePath::PixelRings->new;

#------------------------------------------------------------------------------
# _cumul_extend()

{
  my $good = 1;
  my $limit = $ENV{'MATH_PLANEPATH_TEST_PIXELCUMUL_LIMIT'} || 200;
  foreach my $r (1 .. $limit) {
    %image_coords = ();
    $image->ellipse (-$r+$offset,-$r+$offset, $r+$offset,$r+$offset, 'white');
    my $image_count = scalar(@{[keys %image_coords]});

    ### no critic (ProtectPrivateSubs, ProtectPrivateVars)
    Math::PlanePath::PixelRings::_cumul_extend();
    my $got = $Math::PlanePath::PixelRings::_cumul[$r+1];
    my $want = $Math::PlanePath::PixelRings::_cumul[$r]+$image_count;
    if ($got != $want) {
      $good = 0;
      MyTestHelpers::diag ("_cumul_extend() r=$r wrong: want=$want got=$got");
    }
  }
  ok ($good, 1, "_cumul_extend() to $limit");
}

#------------------------------------------------------------------------------
# coords

{
  my $n = 1;
  my $good = 1;
  my $limit = $ENV{'MATH_PLANEPATH_TEST_PIXELRINGS_LIMIT'} || 50;
  foreach my $r (0 .. $limit) {
    %image_coords = ();
    $image->ellipse (-$r+$offset,-$r+$offset, $r+$offset,$r+$offset, 'white');
    my $image_count = scalar(@{[keys %image_coords]});

    ### $image_count
    ### from n: $n
    my %path_coords;
    while ($image_count--) {
      my ($x,$y) = $path->n_to_xy($n++);

      # perl 5.6.0 through 5.6.2 ends up giving "-0" when stringizing (as of
      # the code in PixelRings version 19), avoid that so the hash keys
      # compare with "eq" successfully
      $x = "$x";
      $y = "$y";
      if ($x eq '-0') { $x = '0'; }
      if ($y eq '-0') { $y = '0'; }

      ### path_coords: "$x,$y"
      $path_coords{"$x,$y"} = 1;
    }

    ### %image_coords
    ### %path_coords
    if (! eq_hash (\%path_coords, \%image_coords)) {
      MyTestHelpers::diag ("Wrong coords at r=$r");
      MyTestHelpers::diag ("image: ", join(',', sort keys %image_coords));
      MyTestHelpers::diag ("path:  ", join(',', sort keys %path_coords));
      dump_coords (\%image_coords);
      dump_coords (\%path_coords);
      $good = 0;
    }
  }
  ok ($good, 1, 'n_to_xy() compared to image->ellipse()');
}


sub eq_hash {
  my ($x, $y) = @_;
  foreach my $key (keys %$x) {
    if (! exists $y->{$key}) {
      return 0;
    }
  }
  foreach my $key (keys %$y) {
    if (! exists $x->{$key}) {
      return 0;
    }
  }
  return 1;
}

exit 0;
