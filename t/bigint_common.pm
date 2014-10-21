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

package bigint_common;
use 5.004;
use strict;
use Test;

# uncomment this to run the ### lines
#use Smart::Comments '###';

use lib 't';
use MyTestHelpers;

sub isa_bigint {
  my ($x) = @_;
  if (ref $x && $x->isa('Math::BigInt')) {
    return 1;
  } else {
    return 0;
  }
}
sub isa_bigfloat {
  my ($x) = @_;
  if (ref $x && $x->isa('Math::BigFloat')) {
    return 1;
  } else {
    return 0;
  }
}
  
sub bigint_checks {
  my ($bigclass) = @_;

  eval "require $bigclass" or die;
  MyTestHelpers::diag ("$bigclass version ",
                       $bigclass->VERSION);


  #----------------------------------------------------------------------------
  # _digit_split_lowtohigh()

  {
    require Math::PlanePath;
    my $zero = $bigclass->new(0);
    my $thirteen = $bigclass->new(13);
    ok (join(',',Math::PlanePath::_digit_split_lowtohigh($zero,2)), '');
    ok (join(',',Math::PlanePath::_digit_split_lowtohigh($zero,3)), '');
    ok (join(',',Math::PlanePath::_digit_split_lowtohigh($zero,4)), '');
    ok (join(',',Math::PlanePath::_digit_split_lowtohigh($zero,8)), '');
    ok (join(',',Math::PlanePath::_digit_split_lowtohigh($zero,10)), '');
    ok (join(',',Math::PlanePath::_digit_split_lowtohigh($zero,16)), '');

    ok (join(',',Math::PlanePath::_digit_split_lowtohigh($thirteen,2)), '1,0,1,1');
    ok (join(',',Math::PlanePath::_digit_split_lowtohigh($thirteen,3)), '1,1,1');
    ok (join(',',Math::PlanePath::_digit_split_lowtohigh($thirteen,4)), '1,3');
    ok (join(',',Math::PlanePath::_digit_split_lowtohigh($thirteen,8)), '5,1');
    ok (join(',',Math::PlanePath::_digit_split_lowtohigh($thirteen,10)), '3,1');
    ok (join(',',Math::PlanePath::_digit_split_lowtohigh($thirteen,16)), '13');

    ok (join(',',Math::PlanePath::_digit_split_lowtohigh($bigclass->new(4),4)), '0,1');
    ok (join(',',Math::PlanePath::_digit_split_lowtohigh($bigclass->new(8),4)), '0,2');

    if ($bigclass->isa('Math::BigInt')) {
      foreach my $radix (2,3,4,5,6,7,8,9,10,11,16,256) {
        my @digits = Math::PlanePath::_digit_split_lowtohigh($thirteen,7);
        foreach my $digit (@digits) {
          ok (! ref $digit, 1,
              '_digit_split_lowtohigh() return plain digits, not bigints');
        }
      }
    }

    ok ($thirteen, 13, 'thirteen unchanged');
    ok ($zero, 0, 'zero unchanged');
  }

  #----------------------------------------------------------------------------
  # _divrem()

  {
    require Math::PlanePath;
    my $n = $bigclass->new(123);
    my ($q,$r) = Math::PlanePath::_divrem($n,5);
    ok ("$n", 123);
    ok ("$q", 24);
    ok ("$r", 3);
    if ($bigclass->isa('Math::BigInt')) {
      ok (ref $r, '');
    }
  }

  #----------------------------------------------------------------------------
  # _divrem_destructive()

  {
    require Math::PlanePath;
    my $n = $bigclass->new(123);
    my $r = Math::PlanePath::_divrem_destructive($n,5);
    ok ("$n", 24);
    ok ("$r", 3);
    if ($bigclass->isa('Math::BigInt')) {
      ok (ref $r, '');
    }
  }

  #---------------------------------------------------------------------------
  # VogelFloret

  {
    require Math::PlanePath::VogelFloret;
    {
      my $path = Math::PlanePath::VogelFloret->new (radius_factor => 1);
      my $n = $bigclass->new(23);
      my $rsquared = $path->n_to_rsquared($n);
      ok ($rsquared == 23, 1);
      ok (ref $rsquared && $rsquared->isa($bigclass), 1);
    }
    if ($bigclass->isa('Math::BigInt')) {
      my $path = Math::PlanePath::VogelFloret->new (radius_factor => 1.5);
      my $n = $bigclass->new(40);
      my $rsquared = $path->n_to_rsquared($n);
      ok ($rsquared == 90, 1);
      ok (isa_bigfloat($rsquared), 1,
          'non-integer radius_factor promote bigint->bigfloat');
    }
  }

  #----------------------------------------------------------------------------
  # MultipleRings

  {
    require Math::PlanePath::MultipleRings;
    my $path = Math::PlanePath::MultipleRings->new (step => 6);

    {
      my $n = $bigclass->new(23);
      my ($got_x,$got_y) = $path->n_to_xy($n);
      ok (isa_bigfloat($got_x), 1);
      ok ($got_x > 0 && $got_x < 1,
          1,
          "MultipleRings n_to_xy($n) got_x $got_x");
      ok ($got_y > 2.5 && $got_y < 3.1,
          1,
          "MultipleRings n_to_xy($n) got_y $got_y");
    }
  }

  #----------------------------------------------------------------------------
  # GcdRationals

  {
    require Math::PlanePath::GcdRationals;
    my $path = Math::PlanePath::GcdRationals->new;
    {
      foreach my $n ($path->n_start .. 20) {
        my ($x,$y) = $path->n_to_xy($n);
        $x = $bigclass->new($x);
        $y = $bigclass->new($y);
        my $rev_n = $path->xy_to_n ($x,$y);
        ok($rev_n,$n);
      }
    }
    {
      my $x = $bigclass->new(7);
      my $y = 1;
      my $n = 28; # 7*8/2
      my $got_n = $path->xy_to_n($x,$y);
      ok ($got_n, $n);
      my ($got_x,$got_y) = $path->n_to_xy($n);
      ok ($got_x, $x);
      ok ($got_y, $y);
    }
    {
      my $x = $bigclass->new(2) ** 128 - 1;
      my $y = 1;
      my $n = $x*($x+1)/2;
      my $got_n = $path->xy_to_n($x,$y);
      ok ($got_n, $n);
      my ($got_x,$got_y) = $path->n_to_xy($n);
      ok ($got_x, $x);
      ok ($got_y, $y);
    }
    {
      my $x = $bigclass->new(30);
      my $y = $bigclass->new(105);
      my $gcd = Math::PlanePath::GcdRationals::_gcd($x,$y);
      ok ($gcd, 15);
      ok ($x, 30);
      ok ($y, 105);
    }
  }


  #--------------------------------------------------------------------------
  # CoprimeColumns

  require Math::PlanePath::CoprimeColumns;
  {
    my $path = Math::PlanePath::CoprimeColumns->new;
    {
      my $n = $bigclass->new(-1);
      my ($got_x,$got_y) = $path->n_to_xy($n);
      ok ($got_x, undef);
      ok ($got_y, undef);
    }
    {
      my $n = $bigclass->new(-99);
      my ($got_x,$got_y) = $path->n_to_xy($n);
      ok ($got_x, undef);
      ok ($got_y, undef);
    }
    {
      my $n = $bigclass->new(0);
      my ($got_x,$got_y) = $path->n_to_xy($n);
      ok ($got_x, 1);
      ok ($got_y, 1);
    }
  }

  #--------------------------------------------------------------------------
  # Corner

  require Math::PlanePath::Corner;
  {
    my $path = Math::PlanePath::Corner->new;
    {
      my $y = $bigclass->new(2) ** 128 - 1;
      {
        my $n = $y*($y+1) + 1;  # on the diagonal

        my ($got_x,$got_y) = $path->n_to_xy($n);
        ok ($got_x, $y);
        ok ($got_y, $y);

        my $got_n = $path->xy_to_n($y,$y);
        ok ($got_n, $n);
      }
      {
        my $n = $y*$y+1;  # left X=1 vertical

        my ($got_x,$got_y) = $path->n_to_xy($n);
        ok ($got_x, 0);
        ok ($got_y, $y);

        my $got_n = $path->xy_to_n(0,$y);
        ok ($got_n, $n);
      }
    }
    {
      my $n = $bigclass->new(0);
      my ($got_x,$got_y) = $path->n_to_xy($n);
      ok ($got_x, undef);
      ok ($got_y, undef);
    }
  }

  #--------------------------------------------------------------------------
  # Diagonals

  {
    require Math::PlanePath::Diagonals;
    my $path = Math::PlanePath::Diagonals->new;
    {
      my $x = $bigclass->new(2) ** 128 - 1;
      my $n = ($x+1)*($x+2)/2;  # triangular numbers on Y=0 horizontal

      my ($got_x,$got_y) = $path->n_to_xy($n);
      ok ($got_x, $x);
      ok ($got_y, 0);

      my $got_n = $path->xy_to_n($x,0);
      ok ($got_n, $n);
    }
    {
      my $x = $bigclass->new(2) ** 128 - 1;
      my $n = ($x+1)*($x+2)/2;  # Y=0 horizontal

      my ($got_x,$got_y) = $path->n_to_xy($n);
      ok ($got_x, $x);
      ok ($got_y, 0);

      my $got_n = $path->xy_to_n($x,0);
      ok ($got_n, $n);
    }
    {
      my $y = $bigclass->new(2) ** 128 - 1;
      my $n = $y*($y+1)/2 + 1;  # X=0 vertical

      my ($got_x,$got_y) = $path->n_to_xy($n);
      ok ($got_x, 0);
      ok ($got_y, $y);

      my $got_n = $path->xy_to_n(0,$y);
      ok ($got_n, $n);
    }
    {
      my $n = $bigclass->new(-1);
      my ($got_x,$got_y) = $path->n_to_xy($n);
      ok ($got_x, undef);
      ok ($got_y, undef);
    }
  }

  #--------------------------------------------------------------------------
  # PeanoCurve

  require Math::PlanePath::PeanoCurve;
  {
    my $path = Math::PlanePath::PeanoCurve->new;

    {
      my $n = $bigclass->new(9) ** 128 + 2;
      my $want_x = $bigclass->new(3) ** 128 + 2;
      my $want_y = $bigclass->new(3) ** 128 - 1;

      my ($got_x,$got_y) = $path->n_to_xy($n);
      ok ($got_x, $want_x);
      ok ($got_y, $want_y);
    }

    # 2020202...
    # {
    #   my $x = $bigclass->new(3) ** 128 + 1;
    #   my $y = 2;
    #   my $want_n = $bigclass->new(9) ** 127 * 15;
    #   my $got_n = $path->xy_to_n($x,$y);
    #   ok ($got_n, $want_n);
    # }
    # {
    #   my $x = 2;
    #   my $y = $bigclass->new(3) ** 128 + 1;
    #   my $want_n = $bigclass->new(9) ** 128 + 6;
    #   my $got_n = $path->xy_to_n($x,$y);
    #   ok ($got_n, $want_n);
    # }
  }

  #--------------------------------------------------------------------------
  # ZOrderCurve

  require Math::PlanePath::ZOrderCurve;
  {
    my $path = Math::PlanePath::ZOrderCurve->new;

    {
      my $n = $bigclass->new(4) ** 128 + 9;
      my $want_x = $bigclass->new(2) ** 128 + 1;
      my $want_y = 2;
      my ($got_x,$got_y) = $path->n_to_xy($n);
      ok ($got_x, $want_x);
      ok ($got_y, $want_y);
    }
    {
      my $x = $bigclass->new(2) ** 128 + 1;
      my $y = 2;
      my $want_n = $bigclass->new(4) ** 128 + 9;
      my $got_n = $path->xy_to_n($x,$y);
      ok ($got_n, $want_n);
    }
    {
      my $x = 2;
      my $y = $bigclass->new(2) ** 128 + 1;
      my $want_n = $bigclass->new(4) ** 128 * 2 + 6;
      my $got_n = $path->xy_to_n($x,$y);
      ok ($got_n, $want_n);
    }
  }

  #--------------------------------------------------------------------------
  # KochCurve

  require Math::PlanePath::KochCurve;
  {
    my $orig = $bigclass->new(3) ** 128 + 2;
    my $n    = $bigclass->new(3) ** 128 + 2;
    my ($pow,$exp) = Math::PlanePath::KochCurve::_round_down_pow($n,3);

    ok ($n, $orig);
    ok ($pow, $bigclass->new(3) ** 128);
    ok ($exp, 128);
  }
  {
    my $orig = $bigclass->new(3) ** 128;
    my $n    = $bigclass->new(3) ** 128;
    my ($pow,$exp) = Math::PlanePath::KochCurve::_round_down_pow($n,3);

    ok ($n, $orig);
    ok ($pow, $bigclass->new(3) ** 128);
    ok ($exp, 128);
  }

  #--------------------------------------------------------------------------
  # RationalsTree

  require Math::PlanePath::RationalsTree;
  {
    my $path = Math::PlanePath::RationalsTree->new (tree_type => 'CW');

    my $n = $bigclass->new(2) ** 256 - 1;
    my $want_x = 256;
    my $want_y = 1;

    my ($got_x,$got_y) = $path->n_to_xy($n);
    ok ($got_x, $want_x);
    ok ($got_y, $want_y);
  }

  {
    my $path = Math::PlanePath::RationalsTree->new (tree_type => 'SB');

    my $n = $bigclass->new(2) ** 256 - 1;
    my $want_x = 256;
    my $want_y = 1;

    my ($got_x,$got_y) = $path->n_to_xy($n);
    ok ($got_x, $want_x);
    ok ($got_y, $want_y);
  }

  {
    my $path = Math::PlanePath::RationalsTree->new (tree_type => 'AYT');

    # cf 2^256 - 1 gives fibonacci F[k]/F[k+1]
    my $n = $bigclass->new(2) ** 256 + 1;
    my $want_x = 1;
    my $want_y = 257;

    my ($got_x,$got_y) = $path->n_to_xy($n);
    ok ($got_x, $want_x);
    ok ($got_y, $want_y);
  }

  #--------------------------------------------------------------------------
  # SacksSpiral

  require Math::PlanePath::SacksSpiral;
  {
    my $path = Math::PlanePath::SacksSpiral->new;
    my $x = 0;
    my $y = $bigclass->new(2) ** 128;
    my ($nlo, $nhi) = $path->rect_to_n_range($x,$y, 0,0);
    ok (!! ref $nhi, 1,
        'SacksSpiral rect_to_n_range() nhi bignum');
  }
}

1;

