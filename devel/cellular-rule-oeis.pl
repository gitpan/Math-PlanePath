#!/usr/bin/perl -w

# Copyright 2012 Kevin Ryde

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
use HTML::Entities::Interpolate;
use List::Util;
use URI::Escape;
use Tie::IxHash;
use Math::BigInt;
use Math::PlanePath::CellularRule;

# uncomment this to run the ### lines
#use Smart::Comments;


open OUT, ">/tmp/find.html" or die;
print OUT <<HERE or die;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>start</title>
</head>
<body>
HERE

{
  # 0/1 cells
  my %done;
  tie %done, 'Tie::IxHash';
  foreach my $rule (0 .. 255) {
    my $path = Math::PlanePath::CellularRule->new(rule=>$rule);

    my @values;
  Y01: foreach my $y (0 .. 10) {
      foreach my $x (-$y .. $y) {
        if (defined ($path->xy_to_n($x,$y))) {
          push @values, 1;
        } else {
          push @values, 0;
        }
        last Y01 if (@values > 30);
      }
    }
    my $values = join(',',@values);
    $done{$values} .= ",$rule";
  }
  foreach my $values (keys %done) {
    my $name = $done{$values};
    $name =~ s/^,//;
    my $values_escaped = URI::Escape::uri_escape($values);

    print OUT "<br>\n0/1 rule=$name\n" or die;

    print OUT <<HERE or die;
<a href="http://oeis.org/search?q=signed:$values_escaped&sort=&language=english&go=Search">$values</a>
HERE
  }
  print OUT "</p>\n" or die;
}

{
  # bignum rows
  my %done;
  tie %done, 'Tie::IxHash';
  foreach my $rule (0 .. 255) {
    my $path = Math::PlanePath::CellularRule->new(rule=>$rule);

    my @values;
  Y01: foreach my $y (0 .. 10) {
      my $n = Math::BigInt->new(0);
      foreach my $x (-$y .. $y) {
        $n *= 2;
        if (defined ($path->xy_to_n($x,$y))) {
          $n++;
        }
        push @values, $n;
        last Y01 if (@values > 30);
      }
    }
    my $values = join(',',@values);
    $done{$values} .= ",$rule";
  }
  foreach my $values (keys %done) {
    my $name = $done{$values};
    $name =~ s/^,//;
    my $values_escaped = URI::Escape::uri_escape($values);

    print OUT "<br>\n0/1 rule=$name\n" or die;

    print OUT <<HERE or die;
<a href="http://oeis.org/search?q=signed:$values_escaped&sort=&language=english&go=Search">$values</a>
HERE
  }
  print OUT "</p>\n" or die;
}

  print OUT <<HERE or die;
</body>
</html>
HERE
close OUT or die;

exit 0;

