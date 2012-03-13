#!/usr/bin/perl -w

# Copyright 2012 Kevin Ryde

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

use constant 1.02 PI => 4 * atan2(1,1);  # similar to Math::Complex

# uncomment this to run the ### lines
#use Smart::Comments;


{
  # max Dir4

  my $radix = 4;

  require Math::BaseCnv;

  print 4-atan2(2,1)/atan2(1,1)/2,"\n";

  require Math::NumSeq::PlanePathDelta;
  my $seq = Math::NumSeq::PlanePathDelta->new (planepath => "PeanoCurve,radix=$radix",
                                               delta_type => 'Dir4');
  my $dx_seq = Math::NumSeq::PlanePathDelta->new (planepath => "PeanoCurve,radix=$radix",
                                                  delta_type => 'dX');
  my $dy_seq = Math::NumSeq::PlanePathDelta->new (planepath => "PeanoCurve,radix=$radix",
                                                  delta_type => 'dY');
  my $max = 0;
  for (1 .. 10000000) {
    my ($i, $value) = $seq->next;

  # foreach my $k (1 .. 1000000) {
  #   my $i = $radix ** (4*$k+3) - 1;
  #   my $value = $seq->ith($i);

    if ($value > $max
        # || $i == 0b100011111
       ) {
      my $dx = $dx_seq->ith($i);
      my $dy = $dy_seq->ith($i);
      my $ri = Math::BaseCnv::cnv($i,10,$radix);
      my $rdx = Math::BaseCnv::cnv($dx,10,$radix);
      my $rdy = Math::BaseCnv::cnv($dy,10,$radix);
      my $f = $dy ? $dx/$dy : -1;
      printf "%d %s %.5f  %s %s   %.3f\n", $i, $ri, $value, $rdx,$rdy, $f;
      $max = $value;
    }
  }

  exit 0;
}
