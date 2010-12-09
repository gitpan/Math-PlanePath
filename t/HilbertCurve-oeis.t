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

use 5.004;
use strict;
use warnings;
use Test::More tests => 4;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

use Math::PlanePath::HilbertCurve;
use Math::PlanePath::Diagonals;
use Math::PlanePath::ZOrderCurve;
use POSIX ();

# uncomment this to run the ### lines
#use Smart::Comments '###';


use constant DBL_INT_MAX => (POSIX::FLT_RADIX() ** POSIX::DBL_MANT_DIG());
use constant MY_MAX => (POSIX::FLT_RADIX() ** (POSIX::DBL_MANT_DIG()-5));

sub read_bfile {
  my ($filename) = @_;
  $filename or return undef;
  require File::Spec;
  $filename = File::Spec->catfile (File::Spec->updir, 'oeis', $filename);
  open FH, "<$filename" or return undef;
  my @array;
  while (defined (my $line = <FH>)) {
    chomp $line;
    next if $line =~ /^\s*$/;   # ignore blank lines
    my ($i, $n) = split /\s+/, $line;
    if (! (defined $n && $n =~ /^[0-9]+$/)) {
      die "oops, bad line in $filename: '$line'";
    }
    if ($n > MY_MAX) {
      ### read_bfile stop bigger than float: $n
      last;
    }
    push @array, $n;
  }
  close FH or die;
  diag "$filename has ",scalar(@array)," values";
  return \@array;
}


#------------------------------------------------------------------------------

my $hilbert  = Math::PlanePath::HilbertCurve->new;
my $diagonal = Math::PlanePath::Diagonals->new;
my $zorder   = Math::PlanePath::ZOrderCurve->new;

SKIP: {
  my $b55 = read_bfile('b163355.txt')
    || skip 'b163355.txt not available', 1;

  my @got;
  foreach my $n (0 .. $#$b55) {
    my ($x, $y) = $zorder->n_to_xy ($n);
    push @got, $hilbert->xy_to_n ($x, $y);
  }
  is_deeply (\@got, $b55);
}

SKIP: {
  my $b57 = read_bfile('b163357.txt')
    || skip 'b163357.txt not available', 1;

  my @got;
  foreach my $n (1 .. @$b57) {
    my ($y, $x) = $diagonal->n_to_xy ($n);     # transposed, same side
    push @got, $hilbert->xy_to_n ($x, $y);
  }
  is_deeply (\@got, $b57);
}

SKIP: {
  my $b59 = read_bfile('b163359.txt')
    || skip 'b163359.txt not available', 1;

  my @got;
  foreach my $n (1 .. @$b59) {
    my ($x, $y) = $diagonal->n_to_xy ($n);     # plain, opposite sides
    push @got, $hilbert->xy_to_n ($x, $y);
  }
  is_deeply (\@got, $b59);
}

SKIP: {
  my $b61 = read_bfile('b163361.txt')
    || skip 'b163361.txt not available', 1;

  my @got;
  foreach my $n (1 .. @$b61) {
    my ($y, $x) = $diagonal->n_to_xy ($n);     # transposed, same side
    push @got, $hilbert->xy_to_n ($x, $y) + 1; # 1-based Hilbert
  }
  is_deeply (\@got, $b61);
}

exit 0;
