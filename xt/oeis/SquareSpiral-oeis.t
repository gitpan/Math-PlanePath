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
plan tests => 42;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use List::Util 'min', 'max';
use Math::PlanePath::SquareSpiral;

# uncomment this to run the ### lines
# use Smart::Comments '###';


my $path = Math::PlanePath::SquareSpiral->new;

sub numeq_array {
  my ($a1, $a2) = @_;
  if (! ref $a1 || ! ref $a2) {
    return 0;
  }
  my $i = 0;
  while ($i < @$a1 && $i < @$a2) {
    if ($a1->[$i] ne $a2->[$i]) {
      return 0;
    }
    $i++;
  }
  return (@$a1 == @$a2);
}
sub diff_nums {
  my ($gotaref, $wantaref) = @_;
  for (my $i = 0; $i < @$gotaref; $i++) {
    if ($i > @$wantaref) {
      return "want ends prematurely pos=$i";
    }
    my $got = $gotaref->[$i];
    my $want = $wantaref->[$i];
    if (! defined $got && ! defined $want) {
      next;
    }
    if (! defined $got || ! defined $want) {
      return "different pos=$i got=".(defined $got ? $got : '[undef]')
        ." want=".(defined $want ? $want : '[undef]');
    }
    $got =~ /^[0-9.-]+$/
      or return "not a number pos=$i got='$got'";
    $want =~ /^[0-9.-]+$/
      or return "not a number pos=$i want='$want'";
    if ($got != $want) {
      return "different pos=$i numbers got=$got want=$want";
    }
  }
  return undef;
}

# return 1,2,3,4
sub path_n_dir4_1 {
  my ($path, $n) = @_;
  my ($x,$y) = $path->n_to_xy($n);
  my ($next_x,$next_y) = $path->n_to_xy($n+1);
  return dxdy_to_dir4_1 ($next_x - $x,
                         $next_y - $y);
}
# return 1,2,3,4, with Y reckoned increasing upwards
sub dxdy_to_dir4_1 {
  my ($dx, $dy) = @_;
  if ($dx > 0) { return 1; }  # east
  if ($dx < 0) { return 3; }  # west
  if ($dy > 0) { return 2; }  # north
  if ($dy < 0) { return 4; }  # south
}


#------------------------------------------------------------------------------
# A059428 -- Prime[N] for N=corner

MyOEIS::compare_values
  (anum => q{A059428},
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath_object => $path,
                                                 turn_type => 'LSR');
     my @got = (2);
     while (@got < $count) {
       my ($i,$value) = $seq->next;
       if ($value) {
         push @got, MyOEIS::ith_prime($i); # i=2 as first turn giving prime=3
       }
     }
     return \@got;
   });

# #------------------------------------------------------------------------------
# # A048851 -- x^2+y^2 of prime N
# # WRONG
# {
#   my $anum = q{A048851};
#   my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
#   my $diff;
#   if ($bvalues) {
#     require Math::Prime::XS;
#     my @got;
#     for (my $n = $path->n_start; @got < $count; $n++) {
#       next unless Math::Prime::XS::is_prime($n);
#       push @got, $path->n_to_rsquared($n);
#     }
#     $diff = diff_nums(\@got, $bvalues);
#     if ($diff) {
#       MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..45]));
#       MyTestHelpers::diag ("got:     ",join(',',@got[0..45]));
#     }
#
#   }
#   skip (! $bvalues,
#         $diff, undef,
#         "$anum");
# }

#------------------------------------------------------------------------------
# A123663 -- count total shared edges

MyOEIS::compare_values
  (anum => q{A123663},
   func => sub {
     my ($count) = @_;
     my @got;
     my $edges = 0;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x,$y) = $path->n_to_xy ($n);
       foreach my $sn ($path->xy_to_n($x+1,$y),
                       $path->xy_to_n($x-1,$y),
                       $path->xy_to_n($x,$y+1),
                       $path->xy_to_n($x,$y-1)) {
         if ($sn < $n) {
           $edges++;
         }
       }
       push @got, $edges;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A136626 -- count surrounding primes

{
  my $anum = q{A136626};
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  $bvalues->[31] = 3;  # DODGY-DATA: 3 primes 13,31,59 surrounding 32
  if ($bvalues) {
    require Math::Prime::XS;
    my @got;
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x,$y) = $path->n_to_xy ($n);
      push @got, ((!! Math::Prime::XS::is_prime   ($path->xy_to_n($x+1,$y)))
                  + (!! Math::Prime::XS::is_prime ($path->xy_to_n($x-1,$y)))
                  + (!! Math::Prime::XS::is_prime ($path->xy_to_n($x,$y+1)))
                  + (!! Math::Prime::XS::is_prime ($path->xy_to_n($x,$y-1)))
                  + (!! Math::Prime::XS::is_prime ($path->xy_to_n($x+1,$y+1)))
                  + (!! Math::Prime::XS::is_prime ($path->xy_to_n($x-1,$y-1)))
                  + (!! Math::Prime::XS::is_prime ($path->xy_to_n($x-1,$y+1)))
                  + (!! Math::Prime::XS::is_prime ($path->xy_to_n($x+1,$y-1)))
                 );
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..45]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..45]));
    }

  }
  skip (! $bvalues,
        $diff, undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A141481 -- values as sum of eight surrounding

MyOEIS::compare_values
  (anum => q{A141481},
   func => sub {
     my ($count) = @_;
     require Math::BigInt;
     my $path = Math::PlanePath::SquareSpiral->new (n_start => 0);
     my @got = (1);
     for (my $n = $path->n_start + 1; @got < $count; $n++) {
       my ($x,$y) = $path->n_to_xy ($n);
       my $sum = Math::BigInt->new(0);
       foreach my $sn ($path->xy_to_n($x+1,$y),
                       $path->xy_to_n($x-1,$y),
                       $path->xy_to_n($x,$y+1),
                       $path->xy_to_n($x,$y-1),
                       $path->xy_to_n($x+1,$y+1),
                       $path->xy_to_n($x-1,$y-1),
                       $path->xy_to_n($x-1,$y+1),
                       $path->xy_to_n($x+1,$y-1)) {
         if ($sn < $n) {
           $sum += $got[$sn]; # @got is 0-based
         }
       }
       push @got, $sum;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A156859 Y axis positive and negative

MyOEIS::compare_values
  (anum => 'A156859',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::SquareSpiral->new (n_start => 0);
     my @got = (0);
     for (my $y = 1; @got < $count; $y++) {
       push @got, $path->xy_to_n(0, $y);
       last unless @got < $count;
       push @got, $path->xy_to_n(0, -$y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A172294 -- jewels, composite surrounded by 4 primes, starting N=0

MyOEIS::compare_values
  (anum => 'A172294',
   func => sub {
     my ($count) = @_;
     my @got;
     my $path = Math::PlanePath::SquareSpiral->new (n_start => 0);
     require Math::Prime::XS;
     for (my $n = $path->n_start; @got < $count; $n++) {
       next if Math::Prime::XS::is_prime($n);
       my ($x,$y) = $path->n_to_xy ($n);
       if (Math::Prime::XS::is_prime    ($path->xy_to_n($x+1,$y))
           && Math::Prime::XS::is_prime ($path->xy_to_n($x-1,$y))
           && Math::Prime::XS::is_prime ($path->xy_to_n($x,$y+1))
           && Math::Prime::XS::is_prime ($path->xy_to_n($x,$y-1))
          ) {
         push @got, $n;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A115258 -- isolated primes

MyOEIS::compare_values
  (anum => 'A115258',
   func => sub {
     my ($count) = @_;
     my @got;
     require Math::Prime::XS;
     for (my $n = $path->n_start; @got < $count; $n++) {
       next unless Math::Prime::XS::is_prime($n);
       my ($x,$y) = $path->n_to_xy ($n);
       if (! Math::Prime::XS::is_prime    ($path->xy_to_n($x+1,$y))
           && ! Math::Prime::XS::is_prime ($path->xy_to_n($x-1,$y))
           && ! Math::Prime::XS::is_prime ($path->xy_to_n($x,$y+1))
           && ! Math::Prime::XS::is_prime ($path->xy_to_n($x,$y-1))
           && ! Math::Prime::XS::is_prime ($path->xy_to_n($x+1,$y+1))
           && ! Math::Prime::XS::is_prime ($path->xy_to_n($x-1,$y-1))
           && ! Math::Prime::XS::is_prime ($path->xy_to_n($x-1,$y+1))
           && ! Math::Prime::XS::is_prime ($path->xy_to_n($x+1,$y-1))
          ) {
         push @got, $n;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A214177 -- sum of 4 neighbours

MyOEIS::compare_values
  (anum => 'A214177',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x,$y) = $path->n_to_xy ($n);
       push @got, ($path->xy_to_n($x+1,$y)
                   + $path->xy_to_n($x-1,$y)
                   + $path->xy_to_n($x,$y+1)
                   + $path->xy_to_n($x,$y-1)
                  );
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A214176 -- sum of 8 neighbours

MyOEIS::compare_values
  (anum => 'A214176',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x,$y) = $path->n_to_xy ($n);
       push @got, ($path->xy_to_n($x+1,$y)
                   + $path->xy_to_n($x-1,$y)
                   + $path->xy_to_n($x,$y+1)
                   + $path->xy_to_n($x,$y-1)
                   + $path->xy_to_n($x+1,$y+1)
                   + $path->xy_to_n($x-1,$y-1)
                   + $path->xy_to_n($x-1,$y+1)
                   + $path->xy_to_n($x+1,$y-1)
                  );
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A214664 -- X coord of prime N

MyOEIS::compare_values
  (anum => 'A214664',
   func => sub {
     my ($count) = @_;
     my @got;
     require Math::Prime::XS;
     for (my $n = $path->n_start; @got < $count; $n++) {
       next unless Math::Prime::XS::is_prime($n);
       my ($x,$y) = $path->n_to_xy ($n);
       push @got, $x;
     }
     return \@got;
   });

# A214665 -- Y coord of prime N
MyOEIS::compare_values
  (anum => 'A214665',
   func => sub {
     my ($count) = @_;
     my @got;
     require Math::Prime::XS;
     for (my $n = $path->n_start; @got < $count; $n++) {
       next unless Math::Prime::XS::is_prime($n);
       my ($x,$y) = $path->n_to_xy ($n);
       push @got, $y;
     }
     return \@got;
   });

# A214666 -- X coord of prime N, first to west
MyOEIS::compare_values
  (anum => 'A214666',
   func => sub {
     my ($count) = @_;
     my @got;
     require Math::Prime::XS;
     for (my $n = $path->n_start; @got < $count; $n++) {
       next unless Math::Prime::XS::is_prime($n);
       my ($x,$y) = $path->n_to_xy ($n);
       push @got, -$x;
     }
     return \@got;
   });

# A214667 -- Y coord of prime N, first to west
MyOEIS::compare_values
  (anum => 'A214667',
   func => sub {
     my ($count) = @_;
     my @got;
     require Math::Prime::XS;
     for (my $n = $path->n_start; @got < $count; $n++) {
       next unless Math::Prime::XS::is_prime($n);
       my ($x,$y) = $path->n_to_xy ($n);
       push @got, -$y;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A143856 -- N values ENE slope=2

MyOEIS::compare_values
  (anum => 'A143856',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $i = 0; @got < $count; $i++) {
       push @got, $path->xy_to_n (2*$i, $i);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A143861 -- N values NNE slope=2

MyOEIS::compare_values
  (anum => 'A143861',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $i = 0; @got < $count; $i++) {
       push @got, $path->xy_to_n ($i, 2*$i);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A063826 -- direction 1,2,3,4 = E,N,W,S

{
  my $anum = 'A063826';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      push @got, path_n_dir4_1($path,$n);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A062410 -- a(n) is sum of existing numbers in row of a(n-1)

{
  my $anum = 'A062410';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum,
                                                      max_value => 'unlimited');
  my @got;
  if ($bvalues) {
    require Math::BigInt;
    my %plotted;
    $plotted{0,0} = Math::BigInt->new(1);
    my $xmin = 0;
    my $ymin = 0;
    my $xmax = 0;
    my $ymax = 0;
    push @got, 1;

    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      my ($prev_x, $prev_y) = $path->n_to_xy ($n-1);
      my ($x, $y) = $path->n_to_xy ($n);
      my $total = 0;
      if ($y == $prev_y) {
        ### column: "$ymin .. $ymax at x=$prev_x"
        foreach my $y ($ymin .. $ymax) {
          $total += $plotted{$prev_x,$y} || 0;
        }
      } else {
        ### row: "$xmin .. $xmax at y=$prev_y"
        foreach my $x ($xmin .. $xmax) {
          $total += $plotted{$x,$prev_y} || 0;
        }
      }
      ### total: "$total"

      $plotted{$x,$y} = $total;
      $xmin = min($xmin,$x);
      $xmax = max($xmax,$x);
      $ymin = min($ymin,$y);
      $ymax = max($ymax,$y);
      push @got, $total;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- sum of rows");
}

#------------------------------------------------------------------------------
# A141481 -- plot sum of existing eight surrounding values entered

{
  my $anum = q{A141481};  # not in POD
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum,
                                                      max_value => 'unlimited');
  my @got;
  if ($bvalues) {
    require Math::BigInt;
    my %plotted;
    $plotted{0,0} = Math::BigInt->new(1);
    push @got, 1;

    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      my $value = (
                   ($plotted{$x+1,$y+1} || 0)
                   + ($plotted{$x+1,$y} || 0)
                   + ($plotted{$x+1,$y-1} || 0)

                   + ($plotted{$x-1,$y-1} || 0)
                   + ($plotted{$x-1,$y} || 0)
                   + ($plotted{$x-1,$y+1} || 0)

                   + ($plotted{$x,$y-1} || 0)
                   + ($plotted{$x,$y+1} || 0)
                  );
      $plotted{$x,$y} = $value;
      push @got, $value;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- sum of eight surrounding");
}

#------------------------------------------------------------------------------
# A033638 -- N positions of the turns

{
  my $anum = 'A033638';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum, max_value => 1_000_000);
  my @got;
  if ($bvalues) {
    push @got, 1, 1;
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      my ($prev_x, $prev_y) = $path->n_to_xy ($n-1);
      my ($x, $y) = $path->n_to_xy ($n);
      my ($next_x, $next_y) = $path->n_to_xy ($n+1);

      if ($x - $prev_x != $next_x - $x
          || $y - $prev_y != $next_y - $y) {
        # not straight ahead
        push @got, $n;
      }
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- N positions of turns");
}

#------------------------------------------------------------------------------
# A172979 -- N positions of the turns which are also primes

{
  my $anum = 'A172979';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::Prime::XS }) {
    $skip = "Math::Prime::XS not available";
    MyTestHelpers::diag ("Math::Prime::XS not available -- $@");

  } else {
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      my ($prev_x, $prev_y) = $path->n_to_xy ($n-1);
      my ($x, $y) = $path->n_to_xy ($n);
      my ($next_x, $next_y) = $path->n_to_xy ($n+1);

      if ($x - $prev_x != $next_x - $x
          || $y - $prev_y != $next_y - $y) {
        # not straight ahead

        if (Math::Prime::XS::is_prime($n)) {
          push @got, $n;
        }
      }
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- N positions of turns which are primes too");
}

#------------------------------------------------------------------------------
# A020703 -- permutation read clockwise, ie. transpose Y,X
{
  my $anum = 'A020703';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $path->xy_to_n ($y, $x);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- permutation clockwise");
}

#------------------------------------------------------------------------------
# A121496 -- run lengths of consecutive N in A068225 N at X+1,Y

{
  my $anum = 'A121496';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $count = 0;
    my $prev_right_n = A068225(1) - 1;  # make first value look like a run
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my $right_n = A068225($n);
      if ($right_n == $prev_right_n + 1) {
        $count++;
      } else {
        push @got, $count;
        $count = 1;
      }
      $prev_right_n = $right_n;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- run lengths of consecutive N at X+1,Y");
}


#------------------------------------------------------------------------------
# A054551 -- plot Nth prime at each N, values are those primes on X axis

{
  my $anum = 'A054551';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::Prime::XS }) {
    $skip = "Math::Prime::XS not available";
    MyTestHelpers::diag ("Math::Prime::XS not available -- $@");

  } else {
    my $hi = $bvalues->[-1];
    my @primes = (0,  # skip N=0
                  Math::Prime::XS::sieve_primes($hi));
    for (my $x = 0; @got < @$bvalues; $x++) {
      my $n = $path->xy_to_n($x,0);
      last if $n > $#primes;
      push @got, $primes[$n];
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- primes X axis");
}

#------------------------------------------------------------------------------
# A054553 -- plot Nth prime at each N, values are those primes on X=Y diagonal

{
  my $anum = 'A054553';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::Prime::XS }) {
    $skip = "Math::Prime::XS not available";
    MyTestHelpers::diag ("Math::Prime::XS not available -- $@");

  } else {
    my $hi = $bvalues->[-1];
    my @primes = (0,  # skip N=0
                  Math::Prime::XS::sieve_primes($hi));
    for (my $x = 0; @got < @$bvalues; $x++) {
      my $n = $path->xy_to_n($x,$x);
      last if $n > $#primes;
      push @got, $primes[$n];
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- primes X=Y diagonal");
}

#------------------------------------------------------------------------------
# A054555 -- plot Nth prime at each N, values are those primes on Y axis

{
  my $anum = 'A054555';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::Prime::XS }) {
    $skip = "Math::Prime::XS not available";
    MyTestHelpers::diag ("Math::Prime::XS not available -- $@");

  } else {
    my $hi = $bvalues->[-1];
    my @primes = (0,  # skip N=0
                  Math::Prime::XS::sieve_primes($hi));
    for (my $y = 0; @got < @$bvalues; $y++) {
      my $n = $path->xy_to_n(0,$y);
      last if $n > $#primes;
      push @got, $primes[$n];
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- primes Y axis");
}

#------------------------------------------------------------------------------
# A053999 -- plot Nth prime at each N, values are those primes on South-East

{
  my $anum = 'A053999';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::Prime::XS }) {
    $skip = "Math::Prime::XS not available";
    MyTestHelpers::diag ("Math::Prime::XS not available -- $@");

  } else {
    my $hi = $bvalues->[-1];
    my @primes = (0,  # skip N=0
                  Math::Prime::XS::sieve_primes($hi));
    for (my $x = 0; @got < @$bvalues; $x++) {
      my $n = $path->xy_to_n($x,-$x);
      last if $n > $#primes;
      push @got, $primes[$n];
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- primes Y axis");
}

#------------------------------------------------------------------------------
# A054564 -- plot Nth prime at each N, values are those primes on North-West

{
  my $anum = 'A054564';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::Prime::XS }) {
    $skip = "Math::Prime::XS not available";
    MyTestHelpers::diag ("Math::Prime::XS not available -- $@");

  } else {
    my $hi = $bvalues->[-1];
    my @primes = (0,  # skip N=0
                  Math::Prime::XS::sieve_primes($hi));
    for (my $x = 0; @got < @$bvalues; $x--) {
      my $n = $path->xy_to_n($x,-$x);
      last if $n > $#primes;
      push @got, $primes[$n];
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- primes Y axis");
}

#------------------------------------------------------------------------------
# A054566 -- plot Nth prime at each N, values are those primes on negative X

{
  my $anum = 'A054566';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::Prime::XS }) {
    $skip = "Math::Prime::XS not available";
    MyTestHelpers::diag ("Math::Prime::XS not available -- $@");

  } else {
    my $hi = $bvalues->[-1];
    my @primes = (0,  # skip N=0
                  Math::Prime::XS::sieve_primes($hi));
    for (my $x = 0; @got < @$bvalues; $x--) {
      my $n = $path->xy_to_n($x,0);
      last if $n > $#primes;
      push @got, $primes[$n];
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- primes Y axis");
}

#------------------------------------------------------------------------------
# A137928 -- N values on diagonal X=1-Y positive and negative
{
  my $anum = 'A137928';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $y = 0; @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n(1-$y,$y);
      last unless @got < @$bvalues;
      if ($y != 0) {
        push @got, $path->xy_to_n(1-(-$y),-$y);
      }
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X=Y+1 diagonal, positive and negative");
}

#------------------------------------------------------------------------------
# A002061 -- central polygonal numbers, N values on diagonal X=Y pos and neg
{
  my $anum = 'A002061';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $y = 0; @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n($y,$y);
      last unless @got < @$bvalues;
      push @got, $path->xy_to_n(-$y,-$y);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X=Y+1 diagonal, positive and negative");
}

#------------------------------------------------------------------------------
# A016814 -- N values (4n+1)^2 on SE diagonal every second square
{
  my $anum = 'A016814';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $i = 0; @got < @$bvalues; $i+=2) {
      push @got, $path->xy_to_n($i,-$i);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X=Y diagonal");
}

#------------------------------------------------------------------------------
# A033952 -- AllDigits on negative Y axis

{
  my $anum = 'A033952';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::NumSeq::AllDigits }) {
    $skip = "Math::NumSeq::AllDigits not available";
    MyTestHelpers::diag ("Math::NumSeq::AllDigits not available -- $@");

  } else {
    my $seq = Math::NumSeq::AllDigits->new;
    for (my $y = 0; @got < @$bvalues; $y--) {
      my $n = $path->xy_to_n (0, $y);
      push @got, $seq->ith($n);
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- AllDigits negative Y axis");
}

#------------------------------------------------------------------------------
# A033953 -- AllDigits starting 0, on negative Y axis

{
  my $anum = 'A033953';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::NumSeq::AllDigits }) {
    $skip = "Math::NumSeq::AllDigits not available";
    MyTestHelpers::diag ("Math::NumSeq::AllDigits not available -- $@");

  } else {
    my $seq = Math::NumSeq::AllDigits->new;
    for (my $y = 0; @got < @$bvalues; $y--) {
      my $n = $path->xy_to_n (0, $y);
      push @got, $seq->ith($n-1);
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- AllDigits starting 0, negative Y axis");
}

#------------------------------------------------------------------------------
# A033988 -- AllDigits starting 0, on negative X axis

{
  my $anum = 'A033988';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::NumSeq::AllDigits }) {
    $skip = "Math::NumSeq::AllDigits not available";
    MyTestHelpers::diag ("Math::NumSeq::AllDigits not available -- $@");

  } else {
    my $seq = Math::NumSeq::AllDigits->new;
    for (my $x = 0; @got < @$bvalues; $x--) {
      my $n = $path->xy_to_n ($x, 0);
      push @got, $seq->ith($n-1);
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- AllDigits starting 0, negative X axis");
}

#------------------------------------------------------------------------------
# A033989 -- AllDigits starting 0, on positive Y axis

{
  my $anum = 'A033989';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::NumSeq::AllDigits }) {
    $skip = "Math::NumSeq::AllDigits not available";
    MyTestHelpers::diag ("Math::NumSeq::AllDigits not available -- $@");

  } else {
    my $seq = Math::NumSeq::AllDigits->new;
    for (my $y = 0; @got < @$bvalues; $y++) {
      my $n = $path->xy_to_n (0, $y);
      push @got, $seq->ith($n-1);
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- AllDigits starting 0, negative X axis");
}

#------------------------------------------------------------------------------
# A033990 -- AllDigits starting 0, on positive X axis

{
  my $anum = 'A033990';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::NumSeq::AllDigits }) {
    $skip = "Math::NumSeq::AllDigits not available";
    MyTestHelpers::diag ("Math::NumSeq::AllDigits not available -- $@");

  } else {
    my $seq = Math::NumSeq::AllDigits->new;
    for (my $x = 0; @got < @$bvalues; $x++) {
      my $n = $path->xy_to_n ($x, 0);
      push @got, $seq->ith($n-1);
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- AllDigits starting 0, negative X axis");
}

#------------------------------------------------------------------------------
# A054556 -- N values on Y axis
{
  my $anum = 'A054556';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $y = 0; @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n(0,$y);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- Y axis");
}

#------------------------------------------------------------------------------
# A054567 -- N values on negative X axis
{
  my $anum = 'A054567';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $x = 0; @got < @$bvalues; $x++) {
      my $n = $path->xy_to_n (-$x, 0);
      push @got, $n;
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X axis");
}

#------------------------------------------------------------------------------
# A054554 -- N values on X=Y diagonal
{
  my $anum = 'A054554';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $i = 0; @got < @$bvalues; $i++) {
      push @got, $path->xy_to_n($i,$i);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X=Y diagonal");
}

#------------------------------------------------------------------------------
# A054569 -- N values on negative X=Y diagonal, but OFFSET=1
{
  my $anum = 'A054569';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $i = 0; @got < @$bvalues; $i++) {
      push @got, $path->xy_to_n(-$i,-$i);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X=Y diagonal");
}

#------------------------------------------------------------------------------
# A068225 -- permutation N at X+1,Y
{
  my $anum = 'A068225';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      push @got, A068225($n);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- permutation N at X+1,Y");
}

# starting n=1
sub A068225 {
  my ($n) = @_;
  my ($x, $y) = $path->n_to_xy ($n);
  return $path->xy_to_n ($x+1,$y);
}

#------------------------------------------------------------------------------
# A068226 -- permutation N at X-1,Y
{
  my $anum = 'A068226';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $path->xy_to_n ($x-1,$y);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- permutation N at X-1,Y");
}

#------------------------------------------------------------------------------
exit 0;
