#!/usr/bin/perl -w

# Copyright 2011, 2012 Kevin Ryde

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
use Math::PlanePath::SierpinskiTriangle;

# uncomment this to run the ### lines
#use Smart::Comments '###';


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


#------------------------------------------------------------------------------
# A106344 - by dX=-3,dY=+1 slopes upwards
# cf A106346 its matrix inverse, or something
#
# 1
# 0, 1
# 0, 1, 1,
# 0, 0, 0, 1,
# 0, 0, 1, 1, 1,
# 0, 0, 0, 1, 0, 1,
# 0, 0, 0, 1, 0, 1, 1,
# 0, 0, 0, 0, 0, 0, 0, 1,
# 0, 0, 0, 0, 1, 0, 1, 1, 1,
# 0, 0, 0, 0, 0, 1, 0, 1, 0, 1,
# 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1,
# 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1,
# 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1,
# 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1

# 19  20  21  22  23  24  25  26   
#   15      16      17      18     
#     11  12          13  14   .    
#        9              10   .      
#          5   6   7   8   .        
#            3   .   4   .          
#              1   2    .   .        
#                0    .   .   .

# path(x,y) = binomial(y,(x+y)/2)
# T(n,k)=binomial(k,n-k)
# y=k
# (x+y)/2=n-k
# x+k=2n-2k
# x=2n-3k
{
  my $anum = 'A106344';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  {
    # align="left" is dX=1,dY=1 diagonals
    my $diff;
    if ($bvalues) {
      my $path = Math::PlanePath::SierpinskiTriangle->new (align => 'left');
      my @got;
      my $xstart = 0;
      my $x = 0;
      my $y = 0;
      while (@got < @$bvalues) {
        my $n = $path->xy_to_n($x,$y);
        push @got, (defined $n ? 1 : 0);

        $x += 1;
        $y += 1;
        if ($x > 0) {
          $xstart--;
          $x = $xstart;
          $y = 0;
        }
      }
      $diff = diff_nums(\@got, $bvalues);
      if ($diff) {
        MyTestHelpers::diag ("bvalues: ",join('',@{$bvalues}[0..60]));
        MyTestHelpers::diag ("got:     ",join('',@got[0..60]));
      }
    }
    skip (! $bvalues,
          $diff,
          undef,
          "$anum by path");
  }
  {
    # align="right" is dX=2,dY=1 slopes, chess knight moves
    my $diff;
    if ($bvalues) {
      my $path = Math::PlanePath::SierpinskiTriangle->new (align => 'right');
      my @got;
      my $xstart = 0;
      my $x = 0;
      my $y = 0;
      while (@got < @$bvalues) {
        my $n = $path->xy_to_n($x,$y);
        push @got, (defined $n ? 1 : 0);

        $x += 2;
        $y += 1;
        if ($x > $y) {
          $xstart--;
          $x = $xstart;
          $y = 0;
        }
      }
      $diff = diff_nums(\@got, $bvalues);
      if ($diff) {
        MyTestHelpers::diag ("bvalues: ",join('',@{$bvalues}[0..60]));
        MyTestHelpers::diag ("got:     ",join('',@got[0..60]));
      }
    }
    skip (! $bvalues,
          $diff,
          undef,
          "$anum by path");
  }
  {
    my $diff;
    if ($bvalues) {
      my $path = Math::PlanePath::SierpinskiTriangle->new;
      my @got;
      my $xstart = 0;
      my $x = 0;
      my $y = 0;
      while (@got < @$bvalues) {
        my $n = $path->xy_to_n($x,$y);
        push @got, (defined $n ? 1 : 0);

        $x += 3;
        $y += 1;
        if ($x > $y) {
          $xstart -= 2;
          $x = $xstart;
          $y = 0;
        }
      }
      $diff = diff_nums(\@got, $bvalues);
      if ($diff) {
        MyTestHelpers::diag ("bvalues: ",join('',@{$bvalues}[0..60]));
        MyTestHelpers::diag ("got:     ",join('',@got[0..60]));
      }
    }
    skip (! $bvalues,
          $diff,
          undef,
          "$anum by path");
  }
  {
    my $diff;
    if ($bvalues) {
      my $path = Math::PlanePath::SierpinskiTriangle->new;
      my @got;
    OUTER: for (my $n = 0; ; $n++) {
        for (my $k = 0; $k <= $n; $k++) {
          my $n = $path->xy_to_n(2*$n-3*$k,$k);
          push @got, (defined $n ? 1 : 0);
          if (@got >= @$bvalues) {
            last OUTER;
          }
        }
      }
      $diff = diff_nums(\@got, $bvalues);
      if ($diff) {
        MyTestHelpers::diag ("bvalues: ",join('',@{$bvalues}[0..60]));
        MyTestHelpers::diag ("got:     ",join('',@got[0..60]));
      }
    }
    skip (! $bvalues,
          $diff,
          undef,
          "$anum by path");
  }
  {
    my $diff;
    if ($bvalues) {
      my $path = Math::PlanePath::SierpinskiTriangle->new;
      my @got;
      require Math::BigInt;
    OUTER: for (my $n = 0; ; $n++) {
        for (my $k = 0; $k <= $n; $k++) {

          # my $b = Math::BigInt->new($k);
          # $b->bnok($n-$k);   # binomial(k,k-n)
          # $b->bmod(2);
          # push @got, $b;

          push @got, binomial_mod2 ($k, $n-$k);
          if (@got >= @$bvalues) {
            last OUTER;
          }
        }
      }
      $diff = diff_nums(\@got, $bvalues);
      if ($diff) {
        MyTestHelpers::diag ("bvalues: ",join('',@{$bvalues}[0..60]));
        MyTestHelpers::diag ("got:     ",join('',@got[0..60]));
      }
    }
    skip (! $bvalues,
          $diff,
          undef,
          "$anum by bnok()");
  }
}

# my $b = Math::BigInt->new($k);
# $b->bnok($n-$k);   # binomial(k,k-n)
# $b->bmod(2);
sub binomial_mod2 {
  my ($n, $k) = @_;
  return Math::BigInt->new($n)->bnok($k)->bmod(2)->numify;
}


#------------------------------------------------------------------------------
# A106345 - 
# k=0..floor(n/2) of binomial(k, n-2k)
#
# path(x,y) = binomial(y,(x+y)/2)
# T(n,k)=binomial(k,n-2k)
# y=k
# (x+y)/2=n-2k
# x+k=2n-4k
# x=2n-5k

{
  my $anum = 'A106345';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum,
                                                      # touch slow, shorten
                                                      max_count => 1000);
  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::SierpinskiTriangle->new;
    my @got;
    for (my $xstart = 0; @got < @$bvalues; $xstart -= 2) {
      my $x = $xstart;
      my $y = 0;
      my $total = 0;
      while ($x <= $y) {
        my $n = $path->xy_to_n($x,$y);
        if (defined $n) {
          $total++;
        }
        $x += 5;
        $y += 1;
      }
      push @got, $total;
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..10]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..10]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum by path");
}

#------------------------------------------------------------------------------
# A002487 - stern diatomic count along of dX=3,dY=1 slopes

{
  my $anum = 'A002487';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum,
                                                      # touch slow, shorten
                                                      max_count => 1000);
  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::SierpinskiTriangle->new;
    my @got = (0);
    for (my $xstart = 0; @got < @$bvalues; $xstart -= 2) {
      my $x = $xstart;
      my $y = 0;
      my $total = 0;
      while ($x <= $y) {
        my $n = $path->xy_to_n($x,$y);
        if (defined $n) {
          $total++;
        }
        $x += 3;
        $y += 1;
      }
      push @got, $total;
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..10]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..10]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum by path");
}


#------------------------------------------------------------------------------
# A001316 - Gould's sequence number of 1s in each row
{
  my $anum = 'A001316';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::SierpinskiTriangle->new;
    my @got;
    my $prev_y = 0;
    my $count = 0;
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x,$y) = $path->n_to_xy($n);
      if ($y == $prev_y) {
        $count++;
      } else {
        push @got, $count;
        $prev_y = $y;
        $count = 1;
      }
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A047999 - 1/0 by rows, without the skipped (x^y)&1==1 points of triangular
# lattice
{
  my $anum = 'A047999';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  {
    my $diff;
    if ($bvalues) {
      my $path = Math::PlanePath::SierpinskiTriangle->new;
      my @got;
      my $x = 0;
      my $y = 0;
      foreach my $n (1 .. @$bvalues) {
        push @got, (defined($path->xy_to_n($x,$y)) ? 1 : 0);
        $x += 2;
        if ($x > $y) {
          $y++;
          $x = -$y;
        }
      }
    }
    skip (! $bvalues,
          $diff,
          undef,
          "$anum");
  }
  {
    my $diff;
    if ($bvalues) {
      my $path = Math::PlanePath::SierpinskiTriangle->new (align => "right");
      my @got;
      my $x = 0;
      my $y = 0;
      foreach my $n (1 .. @$bvalues) {
        push @got, (defined($path->xy_to_n($x,$y)) ? 1 : 0);
        $x++;
        if ($x > $y) {
          $y++;
          $x = 0;
        }
      }
    }
    skip (! $bvalues,
          $diff,
          undef,
          "$anum");
  }
}


#------------------------------------------------------------------------------
# A075438 - 1/0 by rows of "right", including blank 0s in left of pyramid
{
  my $anum = 'A075438';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  {
    my $diff;
    if ($bvalues) {
      my $path = Math::PlanePath::SierpinskiTriangle->new (align => 'right');
      my @got;
      my $x = 0;
      my $y = 0;
      foreach my $n (1 .. @$bvalues) {
        push @got, (defined($path->xy_to_n($x,$y)) ? 1 : 0);
        $x++;
        if ($x > $y) {
          $y++;
          $x = -$y;
        }
      }
    }
    skip (! $bvalues,
          $diff,
          undef,
          "$anum");
  }
}

#------------------------------------------------------------------------------
# A001317 - rows as binary bignums, without the skipped (x^y)&1==1 points of
# triangular lattice
{
  my $anum = 'A001317';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::SierpinskiTriangle->new;
    my @got;
    require Math::BigInt;
    my $y = 0;
    foreach my $n (1 .. @$bvalues) {
      my $b = 0;
      foreach my $i (0 .. $y) {
        my $x = $y-2*$i;
        if (defined ($path->xy_to_n($x,$y))) {
          $b += Math::BigInt->new(2) ** $i;
        }
      }
      push @got, "$b";
      $y++;
    }
    ### @got
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------

exit 0;
