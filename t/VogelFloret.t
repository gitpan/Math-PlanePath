#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

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
use Test::More tests => 21;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

require Math::PlanePath::VogelFloret;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 17;
  is ($Math::PlanePath::VogelFloret::VERSION, $want_version,
      'VERSION variable');
  is (Math::PlanePath::VogelFloret->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::VogelFloret->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::VogelFloret->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  my $path = Math::PlanePath::VogelFloret->new;
  is ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# x_negative, y_negative

{
  my $path = Math::PlanePath::VogelFloret->new;
  ok ($path->x_negative, 'x_negative() instance method');
  ok ($path->y_negative, 'y_negative() instance method');
}

#------------------------------------------------------------------------------
# parameters

{
  my $pp = Math::PlanePath::VogelFloret->new;
  cmp_ok ($pp->{'rotation_factor'}, '>=', 0);
  cmp_ok ($pp->{'radius_factor'}, '>=', 0);

  my $ps2 = Math::PlanePath::VogelFloret->new (rotation_type => 'sqrt2');
  cmp_ok ($ps2->{'rotation_factor'}, '>=', 0);
  cmp_ok ($ps2->{'radius_factor'}, '>=', 0);

  isnt ($pp->{'rotation_factor'}, $ps2->{'rotation_factor'});

  {
    my $path = Math::PlanePath::VogelFloret->new (rotation_factor => 0.5);
    cmp_ok ($path->{'rotation_factor'}, '=', 0.5);
    cmp_ok ($path->{'radius_factor'}, '>=', 1.0);
  }
  {
    my $path = Math::PlanePath::VogelFloret->new (rotation_type => 'sqrt2',
                                                  radius_factor => 2.0);
    is ($path->{'rotation_factor'}, $ps2->{'rotation_factor'});
    cmp_ok ($path->{'radius_factor'}, '>=', 2.0);
  }
}

#------------------------------------------------------------------------------
# rect_to_n_range()

{
  my $path = Math::PlanePath::VogelFloret->new;
  my ($n_lo, $n_hi) = $path->rect_to_n_range (-100,-100, 100,100);
  is ($n_lo, 1);
  cmp_ok ($n_hi, '>', 1);
  cmp_ok ($n_hi, '<', 10*100*100);
}

exit 0;
