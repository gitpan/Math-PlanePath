#!/usr/bin/perl -w

# Copyright 2014 Kevin Ryde

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
use List::Util 'min','max';
use Test;
plan tests => 637;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }

use lib 'xt';
use MyOEIS;

# uncomment this to run the ### lines
#use Smart::Comments;

use Math::PlanePath::DragonCurve;
use Memoize;

sub B_from_path {
  my ($path, $k) = @_;
  my $n_limit = 2**$k;
  my $points = MyOEIS::path_boundary_points($path, $n_limit);
  return scalar(@$points);
}
memoize('B_from_path');

sub L_from_path {
  my ($path, $k) = @_;
  my $n_limit = 2**$k;
  my $points = MyOEIS::path_boundary_points($path, $n_limit, side => 'left');
  return scalar(@$points) - 1;
}
memoize('L_from_path');

sub R_from_path {
  my ($path, $k) = @_;
  my $n_limit = 2**$k;
  my $points = MyOEIS::path_boundary_points($path, $n_limit, side => 'right');
  return scalar(@$points) - 1;
}
memoize('R_from_path');

sub T_from_path {
  my ($path, $k) = @_;
  # 2 to 4
  my $n_limit = 2**$k;
  my ($x,$y) = $path->n_to_xy(2*$n_limit);
  my ($to_x,$to_y) = $path->n_to_xy(4*$n_limit);
  my $points = MyOEIS::path_boundary_points_ft($path, 4*$n_limit,
                                               $x,$y, $to_x,$to_y,
                                               dir => 2);
  return scalar(@$points) - 1;
}
memoize('T_from_path');

sub U_from_path {
  my ($path, $k) = @_;
  my $n_limit = 2**$k;
  my ($x,$y) = $path->n_to_xy(3*$n_limit);
  my ($to_x,$to_y) = $path->n_to_xy(0);
  my $points = MyOEIS::path_boundary_points_ft($path, 4*$n_limit,
                                               $x,$y, $to_x,$to_y,
                                               dir => 1);
  return scalar(@$points) - 1;
}
memoize('U_from_path');

sub V_from_path {
  my ($path, $k) = @_;
  my $n_limit = 2**$k;
  my ($x,$y) = $path->n_to_xy(6*$n_limit);
  my ($to_x,$to_y) = $path->n_to_xy(3*$n_limit);
  my $points = MyOEIS::path_boundary_points_ft($path, 8*$n_limit,
                                               $x,$y, $to_x,$to_y,
                                               dir => 0);
  return scalar(@$points) - 1;
}
memoize('V_from_path');

sub A_from_path {
  my ($path, $k) = @_;
  return MyOEIS::path_enclosed_area($path, 2**$k);
}
memoize('A_from_path');

my $path = Math::PlanePath::DragonCurve->new;

#------------------------------------------------------------------------------
# Area

{
  # A[k] = 2^k - B[k]/2

  foreach my $k (0 .. 10) {
    my $n_limit = 2**$k;
    my $b = B_from_path($path,$k);
    my $got = 2**($k-1) - $b/4;
    my $want = A_from_path($path,$k);
    ok ($got,$want);
  }
}

#------------------------------------------------------------------------------
# subst eliminating U

{
  # L[k+3]-R[k+1] = L[k+2]-R[k] + L[k]     k >= 1

  foreach my $k (1 .. 10) {
    my $lhs = L_from_path($path,$k+3) - R_from_path($path,$k+1);
    my $rhs = (L_from_path($path,$k+2) - R_from_path($path,$k)
               + L_from_path($path,$k));
    ok ($lhs,$rhs);
  }
}

#------------------------------------------------------------------------------
# B

{
  # POD samples
  my @want = (2, 4, 8, 16, 28, 48, 84, 144, 244, 416, 708, 1200, 2036);
  foreach my $k (0 .. $#want) {
    my $got = B_from_path($path,$k);
    my $want = $want[$k];
    ok ($got,$want);
  }
}
{
  # B[k+4] = 2*B[k+3] - B[k+2] + 2*B[k+1] - 2*B[k]    for k >= 0

  foreach my $k (0 .. 10) {
    my $b0 = B_from_path($path,$k);
    my $b1 = B_from_path($path,$k+1);
    my $b2 = B_from_path($path,$k+2);
    my $b3 = B_from_path($path,$k+3);
    my $got = 2*$b3 - $b2 + 2*$b1 - 2*$b0;
    my $want = B_from_path($path,$k+4);
    ok ($got,$want);
  }
}
{
  # B[k] = L[k] + R[k]

  foreach my $k (0 .. 10) {
    my $l = L_from_path($path,$k);
    my $r = R_from_path($path,$k);
    my $got = $l + $r;
    my $want = B_from_path($path,$k);
    ok ($got,$want);
  }
}

#------------------------------------------------------------------------------
# R

{
  # POD samples
  my @want = (1, 2, 4, 8, 16, 28, 48, 84, 144, 244, 416, 708, 1200, 2036);
  foreach my $k (0 .. $#want) {
    my $got = R_from_path($path,$k);
    my $want = $want[$k];
    ok ($got,$want);
  }
}
{
  # R[k+4] = 2*R[k+3] - R[k+2] + 2*R[k+1] - 2*R[k]    for k >= 1

  foreach my $k (1 .. 10) {
    my $r0 = R_from_path($path,$k);
    my $r1 = R_from_path($path,$k+1);
    my $r2 = R_from_path($path,$k+2);
    my $r3 = R_from_path($path,$k+3);
    my $got = 2*$r3 - $r2 + 2*$r1 - 2*$r0;
    my $want = R_from_path($path,$k+4);
    ok ($got,$want);
  }
}
{
  # R[k+1] = L[k] + R[k]

  foreach my $k (0 .. 10) {
    my $l = L_from_path($path,$k);
    my $r = R_from_path($path,$k);
    my $got = $l + $r;
    my $want = R_from_path($path,$k+1);
    ok ($got,$want);
  }
}

#------------------------------------------------------------------------------
# L

{
  # POD samples
  my @want = (1, 2, 4, 8, 12, 20, 36, 60, 100, 172, 292, 492, 836, 1420);
  foreach my $k (0 .. $#want) {
    my $got = L_from_path($path,$k);
    my $want = $want[$k];
    ok ($got,$want);
  }
}
{
  # L[k+1] = T[k]

  foreach my $k (0 .. 10) {
    my $l = L_from_path($path,$k+1);
    my $t = T_from_path($path,$k);
    ok ($l,$t);
  }
}

#------------------------------------------------------------------------------
# T

{
  # T[k+1] = U[k] + R[k]

  foreach my $k (0 .. 10) {
    my $r = R_from_path($path,$k);
    my $u = U_from_path($path,$k);
    my $got = $r + $u;
    my $want = T_from_path($path,$k+1);
    ok ($got,$want, "k=$k");
  }
}

#------------------------------------------------------------------------------
# U

{
  # POD samples
  my @want = (3, 6, 8, 12, 20, 32, 52, 88, 148, 248, 420, 712, 1204, 2040);
  foreach my $k (0 .. $#want) {
    my $got = U_from_path($path,$k);
    my $want = $want[$k];
    ok ($got,$want);
  }
}
{
  # U[k+1] = U[k] + V[k]

  foreach my $k (0 .. 10) {
    my $u = U_from_path($path,$k);
    my $v = V_from_path($path,$k);
    my $got = $u + $v;
    my $want = U_from_path($path,$k+1);
    ok ($got,$want);
  }
}
{
  # U[k+1] = U[k] + L[k]      k>=1
  foreach my $k (1 .. 10) {
    my $u = U_from_path($path,$k);
    my $l = L_from_path($path,$k);
    my $got = $u + $l;
    my $want = U_from_path($path,$k+1);
    ok ($got,$want);
  }
}
{
  # U[k+4] = 2*U[k+3] - U[k+2] + 2*U[k+1] - 2*U[k]    for k >= 1

  foreach my $k (1 .. 10) {
    my $u0 = U_from_path($path,$k);
    my $u1 = U_from_path($path,$k+1);
    my $u2 = U_from_path($path,$k+2);
    my $u3 = U_from_path($path,$k+3);
    my $got = 2*$u3 - $u2 + 2*$u1 - 2*$u0;
    my $want = U_from_path($path,$k+4);
    ok ($got,$want);
  }
}
{
  # U[k] = L[k+2] - R[k]
  foreach my $k (0 .. 10) {
    my $l = L_from_path($path,$k+2);
    my $r = R_from_path($path,$k);
    my $got = $l - $r;
    my $want = U_from_path($path,$k);
    ok ($got,$want);
  }
}

#------------------------------------------------------------------------------
# V

{
  # V[k+1] = T[k]

  foreach my $k (0 .. 10) {
    my $v = V_from_path($path,$k+1);
    my $t = T_from_path($path,$k);
    ok ($v,$t);
  }
}


#------------------------------------------------------------------------------
exit 0;
