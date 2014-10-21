#!/usr/bin/perl -w

# Copyright 2012, 2013 Kevin Ryde

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
plan tests => 33;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::Base::Digits 'digit_split_lowtohigh';
use Math::PlanePath::GrayCode;
use Math::PlanePath::Diagonals;
use Math::PlanePath::Base::Digits
  'digit_join_lowtohigh';

# uncomment this to run the ### lines
#use Smart::Comments '###';


#------------------------------------------------------------------------------
# A003188 -- Gray code radix=2 is ZOrder X,Y -> Gray TsF
#                           and Gray FsT X,Y -> ZOrder
MyOEIS::compare_values
  (anum => 'A003188',
   func => sub {
     my ($count) = @_;
     require Math::PlanePath::ZOrderCurve;
     my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'TsF');
     my $zorder_path = Math::PlanePath::ZOrderCurve->new;
     my @got;
     for (my $n = $zorder_path->n_start; @got < $count; $n++) {
       my ($x, $y) = $zorder_path->n_to_xy ($n);
       my $n = $gray_path->xy_to_n ($x, $y);
       push @got, $n;
     }
     return \@got;
   });

MyOEIS::compare_values
  (anum => 'A003188',
   func => sub {
     my ($count) = @_;
     require Math::PlanePath::ZOrderCurve;
     my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'FsT');
     my $zorder_path = Math::PlanePath::ZOrderCurve->new;
     my @got;
     for (my $n = $gray_path->n_start; @got < $count; $n++) {
       my ($x, $y) = $gray_path->n_to_xy ($n);
       my $n = $zorder_path->xy_to_n ($x, $y);
       push @got, $n;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A006068 -- ungray, inverse Gray TsT X,Y -> ZOrder N
#                          and ZOrder X,Y -> Gray FsF
MyOEIS::compare_values
  (anum => 'A006068',
   func => sub {
     my ($count) = @_;
     require Math::PlanePath::ZOrderCurve;
     my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'TsF');
     my $zorder_path = Math::PlanePath::ZOrderCurve->new;
     my @got;
     for (my $n = $gray_path->n_start; @got < $count; $n++) {
       my ($x, $y) = $gray_path->n_to_xy ($n);
       my $n = $zorder_path->xy_to_n ($x, $y);
       push @got, $n;
     }
     return \@got;
   });

# A006068 -- ungray, ZOrder X,Y -> Gray FsT N
MyOEIS::compare_values
  (anum => 'A006068',
   func => sub {
     my ($count) = @_;
     require Math::PlanePath::ZOrderCurve;
     my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'FsT');
     my $zorder_path = Math::PlanePath::ZOrderCurve->new;
     my @got;
     for (my $n = $zorder_path->n_start; @got < $count; $n++) {
       my ($x, $y) = $zorder_path->n_to_xy ($n);
       my $n = $gray_path->xy_to_n ($x, $y);
       push @got, $n;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A064707 -- permutation radix=2 TsF -> FsT
#   inverse square of A003188 Gray code

# A064706 -- permutation radix=2 FsT -> TsF
#   square of A003188 Gray code ZOrder->TsF

# not same as A100281,A100282

MyOEIS::compare_values
  (anum => q{A064707},
   func => sub {
     my ($count) = @_;
     my $TsF_path = Math::PlanePath::GrayCode->new (apply_type => 'TsF');
     my $FsT_path = Math::PlanePath::GrayCode->new (apply_type => 'FsT');
     my @got;
     for (my $n = $TsF_path->n_start; @got < $count; $n++) {
       my ($x, $y) = $TsF_path->n_to_xy ($n);
       my $n = $FsT_path->xy_to_n ($x, $y);
       push @got, $n;
     }
     return \@got;
   });

MyOEIS::compare_values
  (anum => q{A064706},
   func => sub {
     my ($count) = @_;
     my $TsF_path = Math::PlanePath::GrayCode->new (apply_type => 'TsF');
     my $FsT_path = Math::PlanePath::GrayCode->new (apply_type => 'FsT');
     my @got;
     for (my $n = $FsT_path->n_start; @got < $count; $n++) {
       my ($x, $y) = $FsT_path->n_to_xy ($n);
       my $n = $TsF_path->xy_to_n ($x, $y);
       push @got, $n;
     }
     return \@got;
   });

# {
#   my $seq = Math::NumSeq::OEIS->new(anum=>'A099896');
#   sub A100281_by_twice {
#     my ($i) = @_;
#     $i = $seq->ith($i);
#     if (defined $i) { $i = $seq->ith($i); }
#     return $i;
#   }
# }
# sub A100281_by_func {
#   my ($i) = @_;
#   $i = ($i ^ ($i>>1) ^ ($i>>2));
#   $i = ($i ^ ($i>>1) ^ ($i>>2));
#   return $i;
# }


#------------------------------------------------------------------------------
# A099896 -- permutation Peano radix=2 -> Gray sF, from N=1 onwards
#  n XOR [n/2] XOR [n/4]
#  1, 3, 2, 7, 6, 4, 5, 14, 15, 13, 12, 9, 8, 10, 11, 28, 29, 31, 30, 27,
# to_gray = n xor n/2

# PeanoCurve radix=2
#
#        54--55  49--48  43--42  44--45  64--65  71--70  93--92  90--91 493-492
#         |       |           |       |       |       |   |       |       |
#        53--52  50--51  40--41  47--46  67--66  68--69  94--95  89--88 494-495
#
#        56--57  63--62  37--36  34--35  78--79  73--72  83--82  84--85 483-482
#             |       |   |       |       |       |           |       |       |
#        59--58  60--61  38--39  33--32  77--76  74--75  80--81  87--86 480-481
#
#        13--12  10--11  16--17  23--22 123-122 124-125 102-103  97--96 470-471
#         |       |           |       |       |       |   |       |       |
#        14--15   9-- 8  19--18  20--21 120-121 127-126 101-100  98--99 469-468
#
#         3-- 2   4-- 5  30--31  25--24 117-116 114-115 104-105 111-110 472-473
#             |       |   |       |       |       |           |       |       |
#         0-- 1   7-- 6  29--28  26--27 118-119 113-112 107-106 108-109 475-474

# apply_type => "sF"
#
#  7  |  32--33  37--36  52--53  49--48
#     |    /       \       /       \
#  6  |  34--35  39--38  54--55  51--50
#     |
#  5  |  42--43  47--46  62--63  59--58
#     |    \       /       \       /
#  4  |  40--41  45--44  60--61  57--56
#     |
#  3  |   8-- 9  13--12  28--29  25--24
#     |    /       \       /       \
#  2  |  10--11  15--14  30--31  27--26
#     |
#  1  |   2-- 3   7-- 6  22--23  19--18
#     |    \       /       \       /
# Y=0 |   0-- 1   5-- 4  20--21  17--16
#     |
#     +---------------------------------
#       X=0   1   2   3   4   5   6   7

MyOEIS::compare_values
  (anum => 'A099896',
   func => sub {
     my ($count) = @_;
     require Math::PlanePath::PeanoCurve;
     my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'sF');
     my $peano_path = Math::PlanePath::PeanoCurve->new (radix => 2);
     my @got;
     for (my $n = 1; @got < $count; $n++) {
       my ($x, $y) = $peano_path->n_to_xy ($n);
       my $n = $gray_path->xy_to_n ($x, $y);
       push @got, $n;
     }
     return \@got;
   });

# A100280 -- inverse
MyOEIS::compare_values
  (anum => 'A100280',
   func => sub {
     my ($count) = @_;
     require Math::PlanePath::PeanoCurve;
     my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'sF');
     my $peano_path = Math::PlanePath::PeanoCurve->new (radix => 2);
     my @got;
     for (my $n = $gray_path->n_start; @got < $count; $n++) {
       my ($x, $y) = $gray_path->n_to_xy ($n);
       my $n = $peano_path->xy_to_n ($x, $y);
       push @got, $n;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A003159 -- (N+1)/2 of positions of Left turns

MyOEIS::compare_values
  (anum => 'A003159',
   func => sub {
     my ($count) = @_;
     my @got;
     my $path = Math::PlanePath::GrayCode->new;

     for (my $n = 2; @got < $count; $n += 2) {
       if (path_n_turn($path,$n) == 1) {
         push @got, $n/2;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A036554 -- (N+1)/2 of positions of Left turns

MyOEIS::compare_values
  (anum => 'A036554',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::GrayCode->new;
     my @got;
     for (my $n = 2; @got < $count; $n += 2) {
       if (path_n_turn($path,$n) == 0) {
         push @got, $n/2;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A039963 -- Left turns

MyOEIS::compare_values
  (anum => 'A039963',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::GrayCode->new;
     my @got;
     for (my $n = $path->n_start + 1; @got < $count; $n++) {
       push @got, path_n_turn($path,$n);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A035263 -- Left turns undoubled, skip N even

MyOEIS::compare_values
  (anum => 'A035263',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::GrayCode->new;
     my @got;
     for (my $n = $path->n_start + 1; @got < $count; $n += 2) {
       push @got, path_n_turn($path,$n);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A065882 -- low base4 non-zero digit

MyOEIS::compare_values
  (anum => 'A065882',
   fixup => sub {
     my ($bvalues) = @_;
     foreach (@$bvalues) { $_ %= 2; }
   },
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::GrayCode->new;
     my @got;
     for (my $n = $path->n_start + 1; @got < $count; $n += 2) {
       push @got, path_n_turn($path,$n);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A007913 -- Left turns from square free part of N, skip N even

MyOEIS::compare_values
  (anum => q{A007913},  # not xreffed in GrayCode.pm
   fixup => sub {
     my ($bvalues) = @_;
     foreach (@$bvalues) { $_ %= 2; }
   },
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::GrayCode->new;
     my @got;
     for (my $n = $path->n_start + 1; @got < $count; $n += 2) {
       push @got, path_n_turn($path,$n);
     }
     return \@got;
   });

# return 1 for left, 0 for right
sub path_n_turn {
  my ($path, $n) = @_;
  my $prev_dir = path_n_dir ($path, $n-1);
  my $dir = path_n_dir ($path, $n);
  my $turn = ($dir - $prev_dir) % 4;
  if ($turn == 1) { return 1; }
  if ($turn == 2) { return 0; }
  die "Oops, unrecognised turn";
}
# return 0,1,2,3
sub path_n_dir {
  my ($path, $n) = @_;
  my ($dx,$dy) = $path->n_to_dxdy($n) or die "Oops, no point at ",$n;
  return dxdy_to_dir ($dx, $dy);
}
# return 0,1,2,3, with Y reckoned increasing upwards
sub dxdy_to_dir {
  my ($dx, $dy) = @_;
  if ($dx > 0) { return 0; }  # east
  if ($dx < 0) { return 2; }  # west
  if ($dy > 0) { return 1; }  # north
  if ($dy < 0) { return 3; }  # south
}


#------------------------------------------------------------------------------
# A163233 -- permutation diagonals sF

MyOEIS::compare_values
  (anum => 'A163233',
   func => sub {
     my ($count) = @_;
     my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'sF');
     my $diagonal_path = Math::PlanePath::Diagonals->new (direction => 'up');
     my @got;
     for (my $n = $diagonal_path->n_start; @got < $count; $n++) {
       my ($x, $y) = $diagonal_path->n_to_xy ($n);
       my $n = $gray_path->xy_to_n ($x, $y);
       push @got, $n;
     }
     return \@got;
   });

# A163234 -- diagonals sF inverse
MyOEIS::compare_values
  (anum => 'A163234',
   func => sub {
     my ($count) = @_;
     my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'sF');
     my $diagonal_path = Math::PlanePath::Diagonals->new (direction => 'up',
                                                          n_start => 0);
     my @got;
     for (my $n = $gray_path->n_start; @got < $count; $n++) {
       my ($x, $y) = $gray_path->n_to_xy ($n);
       my $n = $diagonal_path->xy_to_n ($x, $y);
       push @got, $n;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A163235 -- diagonals sF, opposite side start

MyOEIS::compare_values
  (anum => 'A163235',
   func => sub {
     my ($count) = @_;
     my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'sF');
     my $diagonal_path = Math::PlanePath::Diagonals->new (direction => 'down');
     my @got;
     for (my $n = $diagonal_path->n_start; @got < $count; $n++) {
       my ($x, $y) = $diagonal_path->n_to_xy ($n);
       my $n = $gray_path->xy_to_n ($x, $y);
       push @got, $n;
     }
     return \@got;
   });

# A163236 -- diagonals sF inverse, opposite side start
MyOEIS::compare_values
  (anum => 'A163236',
   func => sub {
     my ($count) = @_;
     my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'sF');
     my $diagonal_path = Math::PlanePath::Diagonals->new (direction => 'down');
     my @got;
     for (my $n = $gray_path->n_start; @got < $count; $n++) {
       my ($x, $y) = $gray_path->n_to_xy ($n);
       my $n = $diagonal_path->xy_to_n ($x, $y);
       push @got, $n + $gray_path->n_start - $diagonal_path->n_start;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A163237 -- diagonals sF, same side start, flip base-4 digits 2,3

sub flip_base4_23 {
  my ($n) = @_;
  my @digits = digit_split_lowtohigh($n,4);
  foreach my $digit (@digits) {
    if ($digit == 2) { $digit = 3; }
    elsif ($digit == 3) { $digit = 2; }
  }
  return digit_join_lowtohigh(\@digits,4);
}


MyOEIS::compare_values
  (anum => 'A163237',
   func => sub {
     my ($count) = @_;
     my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'sF');
     my $diagonal_path = Math::PlanePath::Diagonals->new (direction => 'up');
     my @got;
     for (my $n = $diagonal_path->n_start; @got < $count; $n++) {
       my ($x, $y) = $diagonal_path->n_to_xy ($n);
       my $n = $gray_path->xy_to_n ($x, $y);
       $n = flip_base4_23($n);
       push @got, $n;
     }
     return \@got;
   });

# A163238 -- inverse
MyOEIS::compare_values
  (anum => 'A163238',
   func => sub {
     my ($count) = @_;
     my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'sF');
     my $diagonal_path = Math::PlanePath::Diagonals->new (direction => 'up');
     my @got;
     for (my $n = $gray_path->n_start; @got < $count; $n++) {
       my $n = flip_base4_23($n);
       my ($x, $y) = $gray_path->n_to_xy ($n);
       $n = $diagonal_path->xy_to_n ($x, $y);
       push @got, $n + $gray_path->n_start - $diagonal_path->n_start;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A163239 -- diagonals sF, opposite side start, flip base-4 digits 2,3

MyOEIS::compare_values
  (anum => 'A163239',
   func => sub {
     my ($count) = @_;
     my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'sF');
     my $diagonal_path = Math::PlanePath::Diagonals->new (direction => 'down');
     my @got;
     for (my $n = $diagonal_path->n_start; @got < $count; $n++) {
       my ($x, $y) = $diagonal_path->n_to_xy ($n);
       my $n = $gray_path->xy_to_n ($x, $y);
       $n = flip_base4_23($n);
       push @got, $n;
     }
     return \@got;
   });

# A163240 -- inverse
MyOEIS::compare_values
  (anum => 'A163240',
   func => sub {
     my ($count) = @_;
     my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'sF');
     my $diagonal_path = Math::PlanePath::Diagonals->new (direction => 'down');
     my @got;
     for (my $n = $gray_path->n_start; @got < $count; $n++) {
       my $n = flip_base4_23($n);
       my ($x, $y) = $gray_path->n_to_xy ($n);
       $n = $diagonal_path->xy_to_n ($x, $y);
       push @got, $n + $gray_path->n_start - $diagonal_path->n_start;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A163242 -- sF diagonal sums

MyOEIS::compare_values
  (anum => 'A163242',
   func => sub {
     my ($count) = @_;
     my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'sF');
     my @got;
     for (my $y = 0; @got < $count; $y++) {
       my $sum = 0;
       foreach my $i (0 .. $y) {
         $sum += $gray_path->xy_to_n ($i, $y-$i);
       }
       push @got, $sum;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A163478 -- sF diagonal sums, divided by 3

MyOEIS::compare_values
  (anum => 'A163478',
   func => sub {
     my ($count) = @_;
     my $gray_path = Math::PlanePath::GrayCode->new (apply_type => 'sF');
     my @got;
     for (my $y = 0; @got < $count; $y++) {
       my $sum = 0;
       foreach my $i (0 .. $y) {
         $sum += $gray_path->xy_to_n ($i, $y-$i);
       }
       push @got, $sum / 3;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A003188 - binary gray reflected
# modular and reflected same in binary

MyOEIS::compare_values
  (anum => 'A003188',
   func => sub {
     my ($count) = @_;
     my $radix = 2;
     my @got;
     for (my $n = 0; @got < $count; $n++) {
       my $digits = [ digit_split_lowtohigh($n,$radix) ];
       Math::PlanePath::GrayCode::_digits_to_gray_reflected($digits,$radix);
       push @got, digit_join_lowtohigh($digits,$radix);
     }
     return \@got;
   });

MyOEIS::compare_values
  (anum => 'A003188',
   func => sub {
     my ($count) = @_;
     my $radix = 2;
     my @got;
     for (my $n = 0; @got < $count; $n++) {
       my $digits = [ digit_split_lowtohigh($n,$radix) ];
       Math::PlanePath::GrayCode::_digits_to_gray_modular($digits,$radix);
       push @got, digit_join_lowtohigh($digits,$radix);
     }
     return \@got;
   });

# A014550 - binary gray reflected, in binary
MyOEIS::compare_values
  (anum => 'A014550',
   func => sub {
     my ($count) = @_;
     my $radix = 2;
     my @got;
     for (my $n = 0; @got < $count; $n++) {
       my $digits = [ digit_split_lowtohigh($n,$radix) ];
       Math::PlanePath::GrayCode::_digits_to_gray_reflected($digits,$radix);
       push @got, digit_join_lowtohigh($digits,10);
     }
     return \@got;
   });

MyOEIS::compare_values
  (anum => 'A014550',
   func => sub {
     my ($count) = @_;
     my $radix = 2;
     my @got;
     for (my $n = 0; @got < $count; $n++) {
       my $digits = [ digit_split_lowtohigh($n,$radix) ];
       Math::PlanePath::GrayCode::_digits_to_gray_modular($digits,$radix);
       push @got, digit_join_lowtohigh($digits,10);
     }
     return \@got;
   });

# A006068 - binary gray reflected inverse
MyOEIS::compare_values
  (anum => 'A006068',
   func => sub {
     my ($count) = @_;
     my $radix = 2;
     my @got;
     for (my $n = 0; @got < $count; $n++) {
       my $digits = [ digit_split_lowtohigh($n,$radix) ];
       Math::PlanePath::GrayCode::_digits_from_gray_reflected($digits,$radix);
       push @got, digit_join_lowtohigh($digits,$radix);
     }
     return \@got;
   });

MyOEIS::compare_values
  (anum => 'A006068',
   func => sub {
     my ($count) = @_;
     my $radix = 2;
     my @got;
     for (my $n = 0; @got < $count; $n++) {
       my $digits = [ digit_split_lowtohigh($n,$radix) ];
       Math::PlanePath::GrayCode::_digits_from_gray_modular($digits,$radix);
       push @got, digit_join_lowtohigh($digits,$radix);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A105530 - ternary gray modular

MyOEIS::compare_values
  (anum => 'A105530',
   func => sub {
     my ($count) = @_;
     my $radix = 3;
     my @got;
     for (my $n = 0; @got < $count; $n++) {
       my $digits = [ digit_split_lowtohigh($n,$radix) ];
       Math::PlanePath::GrayCode::_digits_to_gray_modular($digits,$radix);
       push @got, digit_join_lowtohigh($digits,$radix);
     }
     return \@got;
   });

# A105529 - ternary gray modular inverse
MyOEIS::compare_values
  (anum => 'A105529',
   func => sub {
     my ($count) = @_;
     my $radix = 3;
     my @got;
     for (my $n = 0; @got < $count; $n++) {
       my $digits = [ digit_split_lowtohigh($n,$radix) ];
       Math::PlanePath::GrayCode::_digits_from_gray_modular($digits,$radix);
       push @got, digit_join_lowtohigh($digits,$radix);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A128173 - ternary gray reflected
# odd radix to and from are the same

MyOEIS::compare_values
  (anum => 'A128173',
   func => sub {
     my ($count) = @_;
     my $radix = 3;
     my @got;
     for (my $n = 0; @got < $count; $n++) {
       my $digits = [ digit_split_lowtohigh($n,$radix) ];
       Math::PlanePath::GrayCode::_digits_to_gray_reflected($digits,$radix);
       push @got, digit_join_lowtohigh($digits,$radix);
     }
     return \@got;
   });

MyOEIS::compare_values
  (anum => 'A128173',
   func => sub {
     my ($count) = @_;
     my $radix = 3;
     my @got;
     for (my $n = 0; @got < $count; $n++) {
       my $digits = [ digit_split_lowtohigh($n,$radix) ];
       Math::PlanePath::GrayCode::_digits_from_gray_reflected($digits,$radix);
       push @got, digit_join_lowtohigh($digits,$radix);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A003100 - decimal gray reflected

MyOEIS::compare_values
  (anum => 'A003100',
   func => sub {
     my ($count) = @_;
     my $radix = 10;
     my @got;
     for (my $n = 0; @got < $count; $n++) {
       my $digits = [ digit_split_lowtohigh($n,$radix) ];
       Math::PlanePath::GrayCode::_digits_to_gray_reflected($digits,$radix);
       push @got, digit_join_lowtohigh($digits,$radix);
     }
     return \@got;
   });

# A174025 - decimal gray reflected inverse
MyOEIS::compare_values
  (anum => 'A174025',
   func => sub {
     my ($count) = @_;
     my $radix = 10;
     my @got;
     for (my $n = 0; @got < $count; $n++) {
       my $digits = [ digit_split_lowtohigh($n,$radix) ];
       Math::PlanePath::GrayCode::_digits_from_gray_reflected($digits,$radix);
       push @got, digit_join_lowtohigh($digits,$radix);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A098488 - decimal gray modular

MyOEIS::compare_values
  (anum => 'A098488',
   func => sub {
     my ($count) = @_;
     my $radix = 10;
     my @got;
     for (my $n = 0; @got < $count; $n++) {
       my $digits = [ digit_split_lowtohigh($n,$radix) ];
       Math::PlanePath::GrayCode::_digits_to_gray_modular($digits,$radix);
       push @got, digit_join_lowtohigh($digits,$radix);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
exit 0;
