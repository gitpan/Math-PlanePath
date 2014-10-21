#!/usr/bin/perl -w

# Copyright 2011, 2012, 2013 Kevin Ryde

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
plan tests => 14;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();

use MyOEIS;
use Math::PlanePath::SierpinskiCurve;
use Math::NumSeq::PlanePathDelta;
use Math::NumSeq::PlanePathTurn;

# uncomment this to run the ### lines
#use Smart::Comments '###';


#------------------------------------------------------------------------------
# A081706 - N-1 positions of left turns

MyOEIS::compare_values
  (anum => 'A081706',
   func => sub {
     my ($count) = @_;
     my $seq = Math::NumSeq::PlanePathTurn->new
       (planepath => 'SierpinskiCurve',
        turn_type => 'Left');
     my @got;
     for (my $n = $seq->i_start; @got < $count; $n++) {
       my ($i,$value) = $seq->next;
       if ($value) {  # if a left turn
         push @got, $i-1;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A039963 - turn 1=right,0=left
# R,R L,L R,R

MyOEIS::compare_values
  (anum => 'A039963',
   func => sub {
     my ($count) = @_;
     my $seq = Math::NumSeq::PlanePathTurn->new
       (planepath => 'SierpinskiCurve',
        turn_type => 'Right');
     my @got;
     for (my $n = $seq->i_start; @got < $count; $n++) {
       push @got, $seq->ith($n);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A127254 - abs(dY) extra initial 1

MyOEIS::compare_values
  (anum => 'A127254',
   func => sub {
     my ($count) = @_;
     my $seq = Math::NumSeq::PlanePathDelta->new
       (planepath => 'SierpinskiCurve',
        delta_type => 'AbsdY');
     my @got = (1);
     while (@got < $count) {
       my ($i,$value) = $seq->next;
       push @got, $value;
     }
     return \@got;
   });

#------------------------------------------------------------------------------

exit 0;
