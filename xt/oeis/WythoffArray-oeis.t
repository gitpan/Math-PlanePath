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
plan tests => 46;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::WythoffArray;

# uncomment this to run the ### lines
#use Smart::Comments '###';

sub BIGINT {
  require Math::NumSeq::PlanePathN;
  return Math::NumSeq::PlanePathN::_bigint();
}


#------------------------------------------------------------------------------
# A188436 -- [3r]-[nr]-[3r-nr], where r=(1+sqrt(5))/2 and []=floor.
# positions of right turns

MyOEIS::compare_values
  (anum => 'A188436',
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath => 'WythoffArray',
                                                 turn_type => 'Right');
     my @got = (0,0,0,0,0);
     while (@got < $count) {
       my ($i,$value) = $seq->next;
       push @got, $value;
     }
     return \@got;
   });

use constant PHI => (1 + sqrt(5)) / 2;
use POSIX 'floor';
sub A188436_func {
  my ($n) = @_;
  floor(3*PHI) - floor($n*PHI)-floor(3*PHI-$n*PHI);
}

{
  require Math::NumSeq::PlanePathTurn;
  my $seq = Math::NumSeq::PlanePathTurn->new (planepath => 'WythoffArray',
                                              turn_type => 'Right');
  my $bad = 0;
  foreach (1 .. 50000) {
    my ($i,$seq_value) = $seq->next;
    my $func_value = A188436_func($i+4);
    if ($func_value != $seq_value) {
      print "$i  seq=$seq_value func=$func_value\n";
      last if $bad++ > 20;
    }
  }
  ok (0, $bad);
}
# [3r]-[(n+4)r]-[3r-(n+4)r]
# = [3r]-[(n+4)r]-[3r-nr-4r]
# = [3r]-[nr+4r]-[-r-nr]
# some of Y axis  4,12,17,25,33,38,46
  

#------------------------------------------------------------------------------
# A000045 -- N on X axis, Fibonacci numbers

MyOEIS::compare_values
  (anum => 'A000045',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::WythoffArray->new;
     my @got = (0,1); # initial skipped
     for (my $x = BIGINT()->new(0); @got < $count; $x++) {
       push @got, $path->xy_to_n ($x, 0);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A005248 -- every second N on Y=1 row, every second Lucas number

MyOEIS::compare_values
  (anum => q{A005248},
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::WythoffArray->new;
     my @got = (2,3); # initial skipped
     for (my $x = BIGINT()->new(1); @got < $count; $x+=2) {
       push @got, $path->xy_to_n ($x, 1);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# N on columns
# per list in A035513

foreach my $elem ([ 'A035337', 2 ],
                  [ 'A035338', 3 ],
                  [ 'A035339', 4 ],
                  [ 'A035340', 5 ],
                 ) {
  my ($anum, $x, %options) = @$elem;

  MyOEIS::compare_values
      (anum => $anum,
       func => sub {
         my ($count) = @_;
         my $path = Math::PlanePath::WythoffArray->new;
         my @got = @{$options{'extra_initial'}||[]};
         for (my $y = BIGINT()->new(0); @got < $count; $y++) {
           push @got, $path->xy_to_n ($x, $y);
         }
         return \@got;
       });
}

#------------------------------------------------------------------------------
# N on rows
# per list in A035513

foreach my $elem ([ 'A006355', 2, extra_initial=>[1,0,2,2,4] ],
                  [ 'A022086', 3, extra_initial=>[0,3,3,6] ],
                  [ 'A022087', 4, extra_initial=>[0,4,4,8] ],
                  [ 'A000285', 5, extra_initial=>[1,4,5,9] ],
                  [ 'A022095', 6, extra_initial=>[1,5,6,11] ],

                  # sum of Fibonacci and Lucas numbers
                  [ 'A013655', 7, extra_initial=>[3,2,5,7,12] ],

                  [ 'A022112', 8, extra_initial=>[2,6,8,14] ],
                  [ 'A022113', 9, extra_initial=>[2,7,9,16] ],
                  [ 'A022120', 10, extra_initial=>[3,7,10,17] ],
                  [ 'A022121', 11, extra_initial=>[3,8,11,19] ],
                  [ 'A022379', 12, extra_initial=>[3,9,12,21] ],
                  [ 'A022130', 13, extra_initial=>[4,9,13,22] ],
                  [ 'A022382', 14, extra_initial=>[4,10,14,24] ],
                  [ 'A022088', 15, extra_initial=>[0,5,5,10,15,25] ],
                  [ 'A022136', 16, extra_initial=>[5,11,16,27] ],
                  [ 'A022137', 17, extra_initial=>[5,12,17,29] ],
                  [ 'A022089', 18, extra_initial=>[0,6,6,12,18,30] ],
                  [ 'A022388', 19, extra_initial=>[6,13,19,32] ],
                  [ 'A022096', 20, extra_initial=>[1,6,7,13,20,33] ],
                  [ 'A022090', 21, extra_initial=>[0,7,7,14,21,35] ],
                  [ 'A022389', 22, extra_initial=>[7,15,22,37] ],
                  [ 'A022097', 23, extra_initial=>[1,7,8,15,23,38] ],
                  [ 'A022091', 24, extra_initial=>[0,8,8,16,24,40] ],
                  [ 'A022390', 25, extra_initial=>[8,17,25,42] ],
                  [ 'A022098', 26, extra_initial=>[1,8,9,17,26,43], ],
                  [ 'A022092', 27, extra_initial=>[0,9,9,18,27,45], ],
                 ) {
  my ($anum, $y, %options) = @$elem;

  MyOEIS::compare_values
      (anum => $anum,
       func => sub {
         my ($count) = @_;
         my $path = Math::PlanePath::WythoffArray->new;
         my @got = @{$options{'extra_initial'}||[]};
         for (my $x = BIGINT()->new(0); @got < $count; $x++) {
           push @got, $path->xy_to_n ($x, $y);
         }
         return \@got;
       });
}

#------------------------------------------------------------------------------
# A064274 -- inverse perm of by diagonals up from X axis

MyOEIS::compare_values
  (anum => 'A064274',
   func => sub {
     my ($count) = @_;
     require Math::PlanePath::Diagonals;
     my $diagonals  = Math::PlanePath::Diagonals->new (direction => 'up');
     my $wythoff = Math::PlanePath::WythoffArray->new;
     my @got = (0);  # extra 0
     for (my $n = $diagonals->n_start; @got < $count; $n++) {
       my ($x, $y) = $wythoff->n_to_xy ($n);
       $x = BIGINT()->new($x);
       $y = BIGINT()->new($y);
       push @got, $diagonals->xy_to_n($x,$y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A035612 -- X coord, starting 1

MyOEIS::compare_values
  (anum => 'A035612',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::WythoffArray->new;
     my @got;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, $x+1;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A035614 -- X coord, starting 0

MyOEIS::compare_values
  (anum => 'A035614',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::WythoffArray->new;
     my @got;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, $x;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A003603 -- Y+1 coord

MyOEIS::compare_values
  (anum => 'A003603',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::WythoffArray->new;
     my @got;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, $y+1;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A139764 -- lowest Zeckendorf term fibonacci value,
#   is N on X axis for the column containing n

MyOEIS::compare_values
  (anum => 'A139764',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::WythoffArray->new;
     my @got;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, $path->xy_to_n($x,0);   # down to axis
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A003849 -- Fibonacci word

MyOEIS::compare_values
  (anum => 'A003849',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::WythoffArray->new;
     my @got = (0);
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x,$y) = $path->n_to_xy($n);
       push @got, ($x == 0 ? 1 : 0);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A000201 -- N+1 for N not on Y axis, spectrum of phi

MyOEIS::compare_values
  (anum => 'A000201',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::WythoffArray->new;
     my @got = (1);
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x,$y) = $path->n_to_xy($n);
       if ($x != 0) {
         push @got, $n+1;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A022342 -- N not on Y axis, even Zeckendorfs

MyOEIS::compare_values
  (anum => 'A022342',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::WythoffArray->new;
     my @got = (0);
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x,$y) = $path->n_to_xy($n);
       if ($x != 0) {
         push @got, $n;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A001950 -- N+1 of the N's on Y axis, spectrum

MyOEIS::compare_values
  (anum => 'A001950',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::WythoffArray->new;
     my @got;
     for (my $y = 0; @got < $count; $y++) {
       my $n = $path->xy_to_n(0,$y);
       push @got, $n+1;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A083412 -- by diagonals, down from Y axis

MyOEIS::compare_values
  (anum => 'A083412',
   func => sub {
     my ($count) = @_;
     require Math::PlanePath::Diagonals;
     my $diagonals  = Math::PlanePath::Diagonals->new (direction => 'down');
     my $wythoff = Math::PlanePath::WythoffArray->new;
     my @got;
     for (my $n = $diagonals->n_start; @got < $count; $n++) {
       my ($x, $y) = $diagonals->n_to_xy ($n);
       push @got, $wythoff->xy_to_n($x,$y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A035513 -- by diagonals, up from X axis

MyOEIS::compare_values
  (anum => 'A035513',
   func => sub {
     my ($count) = @_;
     require Math::PlanePath::Diagonals;
     my $diagonals  = Math::PlanePath::Diagonals->new (direction => 'up');
     my $wythoff = Math::PlanePath::WythoffArray->new;
     my @got;
     for (my $n = $diagonals->n_start; @got < $count; $n++) {
       my ($x, $y) = $diagonals->n_to_xy ($n);
       $x = BIGINT()->new($x);
       $y = BIGINT()->new($y);
       push @got, $wythoff->xy_to_n($x,$y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A000204 -- N on Y=1 row, Lucas numbers
# cf A000032 starting 2,1

MyOEIS::compare_values
  (anum => 'A000204',
   max_count => 150,
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::WythoffArray->new;
     my @got = (1, 3); # initial skipped
     for (my $x = BIGINT()->new(0); @got < $count; $x++) {
       push @got, $path->xy_to_n ($x, 1);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A035336 -- N in X=1 column (and A066097 is a duplicate)

MyOEIS::compare_values
  (anum => 'A035336',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::WythoffArray->new;
     my @got;
     for (my $y = 0; @got < $count; $y++) {
       push @got, $path->xy_to_n (1, $y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A003622 -- N on Y axis, but OFFSET=1

MyOEIS::compare_values
  (anum => 'A003622',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::WythoffArray->new;
     my @got;
     for (my $y = 0; @got < $count; $y++) {
       push @got, $path->xy_to_n (0, $y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A020941 -- N on X=Y diagonal, but OFFSET=1

MyOEIS::compare_values
  (anum => 'A020941',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::WythoffArray->new;
     my @got;
     for (my $i = 0; @got < $count; $i++) {
       push @got, $path->xy_to_n ($i,$i);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
exit 0;
