#!/usr/bin/perl -w

# Copyright 2011, 2012, 2013, 2014 Kevin Ryde

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
plan tests => 12;

use lib 't','xt';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }
use MyOEIS;

use Math::PlanePath::R5DragonCurve;

# uncomment this to run the ### lines
#use Smart::Comments '###';

my $path = Math::PlanePath::R5DragonCurve->new;

#------------------------------------------------------------------------------
# A198859 boundary, one side only, N=0 to 25^k, even levels
foreach my $side ('right', 'left') {
  MyOEIS::compare_values
      (anum => 'A198859',
       max_value => 50_000,
       func => sub {
         my ($count) = @_;
         my @got;
         for (my $k = 0; @got < $count; $k++) {
           push @got, MyOEIS::path_boundary_length($path, 25**$k,
                                                   side => $side);
         }
         return \@got;
       });
}

# A198963 boundary, one side only, N=0 to 5*25^k, odd levels
foreach my $side ('right', 'left') {
  MyOEIS::compare_values
      (anum => 'A198963',
       max_value => 50_000,
       func => sub {
         my ($count) = @_;
         my @got;
         for (my $k = 0; @got < $count; $k++) {
           push @got, MyOEIS::path_boundary_length($path, 5*25**$k,
                                                   side => $side);
         }
         return \@got;
       });
}

# A048473 right or left side boundary for points N <= 5^k
# which is 1/2 of whole boundary
foreach my $side ('right', 'left') {
  MyOEIS::compare_values
      (anum => 'A048473',
       max_value => 50_000,
       func => sub {
         my ($count) = @_;
         my @got;
         for (my $k = 0; @got < $count; $k++) {
           push @got, MyOEIS::path_boundary_length($path, 5**$k,
                                                   side => $side);
         }
         return \@got;
       });
}

#------------------------------------------------------------------------------
# A079004 boundary length for points N <= 5^k

MyOEIS::compare_values
  (anum => 'A079004',
   max_value => 50_000,
   func => sub {
     my ($count) = @_;
     my @got = (7,10);
     for (my $k = 1; @got < $count; $k++) {
       push @got, MyOEIS::path_boundary_length($path, 5**$k);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A005058 1/2 * enclosed area to N <= 5^k, first differences
# A005059 1/4 * enclosed area to N <= 5^k, first differences
MyOEIS::compare_values
  (anum => 'A005059',
   max_value => 50_000,
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $k = 0; @got < $count; $k++) {
       push @got, (MyOEIS::path_enclosed_area($path, 5**($k+1))
                   - MyOEIS::path_enclosed_area($path, 5**$k)) / 4;
     }
     return \@got;
   });
MyOEIS::compare_values
  (anum => 'A005058',
   max_value => 50_000,
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $k = 0; @got < $count; $k++) {
       push @got, (MyOEIS::path_enclosed_area($path, 5**($k+1))
                   - MyOEIS::path_enclosed_area($path, 5**$k)) / 2;
     }
     return \@got;
   });

# A007798 1/2 * enclosed area to N <= 5^k
# A016209 1/4 * enclosed area to N <= 5^k
MyOEIS::compare_values
  (anum => 'A007798',
   max_value => 100_000,
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $k = 1; @got < $count; $k++) {
       push @got, MyOEIS::path_enclosed_area($path, 5**$k) / 2;
     }
     return \@got;
   });
MyOEIS::compare_values
  (anum => 'A016209',
   max_value => 100_000,
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $k = 2; @got < $count; $k++) {
       push @got, MyOEIS::path_enclosed_area($path, 5**$k) / 4;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A175337 -- turn 0=left,1=right

MyOEIS::compare_values
  (anum => 'A175337',
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath => 'R5DragonCurve',
                                                 turn_type => 'Right');
     my @got;
     while (@got < $count) {
       my ($i,$value) = $seq->next;
       push @got, $value;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
exit 0;
