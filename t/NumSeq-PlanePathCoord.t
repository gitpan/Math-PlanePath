#!/usr/bin/perl -w

# Copyright 2010, 2011, 2012 Kevin Ryde

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

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $test_count = (tests => 21)[1];
plan tests => $test_count;

if (! eval { require Math::NumSeq; 1 }) {
  MyTestHelpers::diag ('skip due to Math::NumSeq not available -- ',$@);
  foreach (1 .. $test_count) {
    skip ('due to no Math::NumSeq', 1, 1);
  }
  exit 0;
}

require Math::NumSeq::PlanePathCoord;

{
  package MyPlanePath;
  use vars '@ISA';
  @ISA = ('Math::PlanePath');
  sub n_to_xy {
    my ($self, $n) = @_;
    return ($self->{'x'},$self->{'y'});
  }
}

#------------------------------------------------------------------------------
# _coordinate_func_BitAnd()
# _coordinate_func_BitOr()
# _coordinate_func_BitXor()

{
  my $path = MyPlanePath->new;
  my $seq = Math::NumSeq::PlanePathCoord->new (planepath_object => $path);

  $path->{'x'} = 0;
  $path->{'y'} = 0;
  ok (Math::NumSeq::PlanePathCoord::_coordinate_func_BitAnd($seq,0), 0);
  ok (Math::NumSeq::PlanePathCoord::_coordinate_func_BitOr($seq,0), 0);
  ok (Math::NumSeq::PlanePathCoord::_coordinate_func_BitXor($seq,0), 0);

  $path->{'x'} = 7;
  $path->{'y'} = 9;
  ok (Math::NumSeq::PlanePathCoord::_coordinate_func_BitAnd($seq,0), 1);
  ok (Math::NumSeq::PlanePathCoord::_coordinate_func_BitOr($seq,0),  15);
  ok (Math::NumSeq::PlanePathCoord::_coordinate_func_BitXor($seq,0), 14);

  $path->{'x'} = 7.0 / 16.0;
  $path->{'y'} = 9.0 / 16.0;
  ok (Math::NumSeq::PlanePathCoord::_coordinate_func_BitAnd($seq,0),1.0 /16.0);
  ok (Math::NumSeq::PlanePathCoord::_coordinate_func_BitOr($seq,0), 15.0/16.0);
  ok (Math::NumSeq::PlanePathCoord::_coordinate_func_BitXor($seq,0),14.0/16.0);

  $path->{'x'} = 7.0 / 4.0;
  $path->{'y'} = 9.0 / 4.0;
  ok (Math::NumSeq::PlanePathCoord::_coordinate_func_BitAnd($seq,0),1.0 /4.0);
  ok (Math::NumSeq::PlanePathCoord::_coordinate_func_BitOr($seq,0), 15.0/4.0);
  ok (Math::NumSeq::PlanePathCoord::_coordinate_func_BitXor($seq,0),14.0/4.0);

  $path->{'x'} = -1.0 / 16.0;
  $path->{'y'} = -1.0 / 16.0;
  ok (Math::NumSeq::PlanePathCoord::_coordinate_func_BitAnd($seq,0),-1.0/16.0);
  ok (Math::NumSeq::PlanePathCoord::_coordinate_func_BitOr($seq,0), -1.0/16.0);
  ok (Math::NumSeq::PlanePathCoord::_coordinate_func_BitXor($seq,0),0);

  $path->{'x'} = -1.0 / 16.0; # ...111.1111
  $path->{'y'} = 15.0 / 16.0; #      0.1111
  ok (Math::NumSeq::PlanePathCoord::_coordinate_func_BitAnd($seq,0),15.0/16.0);
  ok (Math::NumSeq::PlanePathCoord::_coordinate_func_BitOr($seq,0), -1.0/16.0);
  ok (Math::NumSeq::PlanePathCoord::_coordinate_func_BitXor($seq,0),-1);

  $path->{'x'} = -1.0 / 16.0; # ...111.1111
  $path->{'y'} =  2.0 / 16.0; #      0.0010
  ok (Math::NumSeq::PlanePathCoord::_coordinate_func_BitAnd($seq,0), 2.0/16.0);
  ok (Math::NumSeq::PlanePathCoord::_coordinate_func_BitOr($seq,0), -1.0/16.0);
  ok (Math::NumSeq::PlanePathCoord::_coordinate_func_BitXor($seq,0),-3.0/16.0);
}

#------------------------------------------------------------------------------
exit 0;
