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
plan tests => 218;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }

use lib 'xt';
use MyOEIS;

# uncomment this to run the ### lines
# use Smart::Comments;

use Memoize;
use Math::PlanePath::R5DragonCurve;
my $path = Math::PlanePath::R5DragonCurve->new;



#------------------------------------------------------------------------------
# Area

sub A_recurrence {
  my ($k) = @_;
  if ($k <= 0) { return 0; }
  if ($k == 1) { return 0; }
  if ($k == 2) { return 4; }
  if ($k == 3) { return 36; }
  return (9*A_recurrence($k-1)
          - 23*A_recurrence($k-2)
          + 15*A_recurrence($k-3));
}
BEGIN { memoize('A_recurrence') }

{
  # A[k] = (2*5^k - B[k])/4

  foreach my $k (0 .. 8) {
    my $b = B_from_path($path,$k);
    ### $b
    my $got = (2*5**$k - $b)/4;
    my $want = A_from_path($path,$k);
    ok ($got,$want);
  }
}
{
  # A[k] recurrence

  foreach my $k (0 .. 8) {
    my $n_limit = 5**$k;
    my $got = A_recurrence($k);
    my $want = A_from_path($path,$k);
    ok ($got,$want, "k=$k");
  }
}
{
  # A[k] = (5^k - 2*3^k + 1)/2

  foreach my $k (0 .. 8) {
    my $got = (5**$k - 2*3**$k + 1)/2;
    my $want = A_from_path($path,$k);
    ok ($got,$want);
  }
}


#------------------------------------------------------------------------------
# R

{
  # R[k] = B[k]/2
  my $sum = 1;
  foreach my $k (0 .. 8) {
    my $b = B_from_path($path,$k);
    my $r = R_from_path($path,$k);
    ok ($r,$b/2);
  }
}
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
  # R[k+1] = 2*R[k] + U[k]

  foreach my $k (1 .. 8) {
    my $r0 = R_from_path($path,$k);
    my $r1 = R_from_path($path,$k+1);
    my $u = R_from_path($path,$k);
    ok (2*$r0+$u, $r1);
  }
}

#------------------------------------------------------------------------------
# boundary lengths

sub B_from_path {
  my ($path, $k) = @_;
  my $n_limit = 5**$k;
  my $points = MyOEIS::path_boundary_points($path, $n_limit);
  return scalar(@$points);
}
BEGIN { memoize('B_from_path') }

sub L_from_path {
  my ($path, $k) = @_;
  my $n_limit = 5**$k;
  my $points = MyOEIS::path_boundary_points($path, $n_limit, side => 'left');
  return scalar(@$points) - 1;
}
BEGIN { memoize('L_from_path') }

sub R_from_path {
  my ($path, $k) = @_;
  my $n_limit = 5**$k;
  my $points = MyOEIS::path_boundary_points($path, $n_limit, side => 'right');
  return scalar(@$points) - 1;
}
BEGIN { memoize('R_from_path') }

sub U_from_path {
  my ($path, $k) = @_;
  my $n_limit = 5**$k;
  my ($x,$y) = $path->n_to_xy(3*$n_limit);
  my ($to_x,$to_y) = $path->n_to_xy(0);
  my $points = MyOEIS::path_boundary_points_ft($path, 5*$n_limit,
                                               $x,$y, $to_x,$to_y,
                                               dir => 1);
  return scalar(@$points) - 1;
}
BEGIN { memoize('U_from_path') }

sub A_from_path {
  my ($path, $k) = @_;
  return MyOEIS::path_enclosed_area($path, 5**$k);
}
BEGIN { memoize('A_from_path') }

#------------------------------------------------------------------------------
# B

{
  # POD samples
  my @want = (2, 10, 34, 106, 322, 970, 2914);
  foreach my $k (0 .. $#want) {
    my $got = B_from_path($path,$k);
    my $want = $want[$k];
    ok ($got,$want);
  }
}
{
  # B[k] = 4*R[k] + 2*U[k]

  foreach my $k (0 .. 10) {
    my $r = R_from_path($path,$k);
    my $u = U_from_path($path,$k);
    my $b = B_from_path($path,$k+1);
    ok ($4*$r+2*$u,$b);
  }
}
{
  # B[k+2] = 4*B[k+1] - 3*B[k]

  foreach my $k (0 .. 10) {
    my $b0 = B_from_path($path,$k);
    my $b1 = B_from_path($path,$k+1);
    my $got = 4*$b1 - 3*$b0;
    my $want = B_from_path($path,$k+2);
    ok ($got,$want);
  }
}
{
  # B[k] = 4*3^k - 2

  foreach my $k (0 .. 10) {
    my $want = b_from_path($path,$k);
    my $got = 4*3**$k - 2;
    ok ($got,$want);
  }
}

# #------------------------------------------------------------------------------
# # U
# 
# {
#   # POD samples
#   my @want = (3, 6, 8, 12, 20, 32, 52, 88, 148, 248, 420, 712, 1204, 2040);
#   foreach my $k (0 .. $#want) {
#     my $got = U_from_path($path,$k);
#     my $want = $want[$k];
#     ok ($got,$want);
#   }
# }
# {
#   # U[k+1] = U[k] + V[k]
# 
#   foreach my $k (0 .. 10) {
#     my $u = U_from_path($path,$k);
#     my $v = V_from_path($path,$k);
#     my $got = $u + $v;
#     my $want = U_from_path($path,$k+1);
#     ok ($got,$want);
#   }
# }
# {
#   # U[k+1] = U[k] + L[k]      k>=1
#   foreach my $k (1 .. 10) {
#     my $u = U_from_path($path,$k);
#     my $l = L_from_path($path,$k);
#     my $got = $u + $l;
#     my $want = U_from_path($path,$k+1);
#     ok ($got,$want);
#   }
# }
# {
#   # U[k+4] = 2*U[k+3] - U[k+2] + 2*U[k+1] - 2*U[k]    for k >= 1
# 
#   foreach my $k (1 .. 10) {
#     my $u0 = U_from_path($path,$k);
#     my $u1 = U_from_path($path,$k+1);
#     my $u2 = U_from_path($path,$k+2);
#     my $u3 = U_from_path($path,$k+3);
#     my $got = 2*$u3 - $u2 + 2*$u1 - 2*$u0;
#     my $want = U_from_path($path,$k+4);
#     ok ($got,$want);
#   }
# }
# {
#   # U[k] = L[k+2] - R[k]
#   foreach my $k (0 .. 10) {
#     my $l = L_from_path($path,$k+2);
#     my $r = R_from_path($path,$k);
#     my $got = $l - $r;
#     my $want = U_from_path($path,$k);
#     ok ($got,$want);
#   }
# }

#------------------------------------------------------------------------------
exit 0;
