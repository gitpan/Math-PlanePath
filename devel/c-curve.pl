#!/usr/bin/perl -w

# Copyright 2011, 2012, 2013 Kevin Ryde

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

# uncomment this to run the ### lines
# use Smart::Comments;

{
  # A047838     1, 3, 7, 11, 17, 23, 31, 39, 49, 59, 71, 83, 97, 111, 127, 143,
  # A080827  1, 3, 5, 9, 13, 19, 25, 33, 41, 51, 61, 73, 85, 99, 113, 129,

  require Image::Base::Text;
  my $width = 60;
  my $height = 30;
  my $w2 = int(($width+1)/2);
  my $h2 = int($height/2);
  my $image = Image::Base::Text->new (-width => $width,
                                      -height => $height);
  my $x = $w2;
  my $y = $h2;
  my $dx = 1;
  my $dy = 0;
  foreach my $i (2 .. 102) {
    $image->xy($x,$y,'*');
    if ($dx) {
      $x += $dx;
      $image->xy($x,$y,'-');
      $x += $dx;
      $image->xy($x,$y,'-');
      $x += $dx;
    } else {
      $y += $dy;
      $image->xy($x,$y,'|');
      $y += $dy;
    }
    my $value = A080827_pred($i);
    if (! $value) {
      if ($i & 1) {
        ($dx,$dy) = ($dy,-$dx);
      } else {
        ($dx,$dy) = (-$dy,$dx);
      }
    }
  }
  $image->save('/dev/stdout');
  exit 0;
}

{
  # drawing turn sequence Language::Logo

  require Language::Logo;
  require Math::NumSeq::OEIS;

  # A003982=0,1 characteristic of A001844=2n(n+1)+1
  # constant A190406
  # my $seq = Math::NumSeq::OEIS->new (anum => 'A003982');
  # each leg 4 longer
  # 1, 0, 0, 0,
  # 1, 0, 0, 0, 0, 0, 0, 0,
  # 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  # 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  # 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  # 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  # 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

  # my $seq = Math::NumSeq::OEIS->new (anum => 'A080827');

  require Math::NumSeq::Squares;
  my $square = Math::NumSeq::Squares->new;

  my @value = (1, 0,
               1, 0, 0, 0,
               1, 0, 0, 0, 0, 0,
               1, 0, 0, 0, 0, 0, 0, 0,
               1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
               1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
               1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
              );

  # A010052 charact of squares
  # 1,
  # 1, 0, 0,
  # 1, 0, 0, 0, 0,
  # 1, 0, 0, 0, 0, 0, 0,
  # 1, 0, 0, 0, 0, 0, 0, 0, 0,
  # 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  # 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

  # A047838
  @value = (1, 0,
            1, 0, 0, 0,
            1, 0, 0, 0,
            1, 0, 0, 0, 0, 0,
            1, 0, 0, 0, 0, 0,
            1, 0, 0, 0, 0, 0, 0, 0,
            1, 0, 0, 0, 0, 0, 0, 0,
            1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
           );

  for (my $i = 0; $i <= $#value; $i++) {
    if ($value[$i]) { print $i+1,","; }
  }
  print "\n";
  #  exit 0;

  my $lo = Logo->new(update => 20, port=>8222+time()%100);
  $lo->command("pendown");
  $lo->command("seth 0");
  foreach my $n (1 .. 2560) {
    # my ($i, $value) = $seq->next or last;

    # 2n(n+1)+1
    # my $i = $n+1;
    # my $value = $square->pred(2*$n+1);

    # my $i = $n+1;
    # my $value = $value[$i-1] // last;

    # i = floor(n^2/2)-1.
    # i+1 = floor(n^2/2)
    # 2i+2 = n^2
    my $i = $n+1;
    my $value = A080827_pred($i);

    $lo->command("forward 10");
    if (! $value) {
      if ($i & 1) {
        $lo->command("left 90");
      } else {
        $lo->command("right 90");
      }
    }
  }
  $lo->disconnect("Finished...");
  exit 0;
}

BEGIN {
  require Math::NumSeq::OEIS;
  # my $seq = Math::NumSeq::OEIS->new (anum => 'A080827');
  my $seq = Math::NumSeq::OEIS->new (anum => 'A047838');
  my %values;
  while (my($i,$value) = $seq->next) {
    $values{$value} = 1;
  }
  sub A080827_pred {
    my ($value) = @_;
    return $values{$value};
    # return $seq->pred($value);
  }
}
{
  # drawing with Language::Logo

  require Language::Logo;
  require Math::NumSeq::PlanePathTurn;
  my $seq = Math::NumSeq::PlanePathTurn->new(planepath=>'DragonCurve',
                                             turn_type => 'Right');
  require Math::NumSeq::Fibbinary;
  my $fibbinary = Math::NumSeq::Fibbinary->new;

  my $lo = Logo->new(update => 20, port=>8222);
  $lo->command("pendown");
  foreach my $n (1 .. 2560) {
    # my $b = $n;
      $b = $fibbinary->ith($b);

    # my $turn4 = count_low_0_bits($b) - 1;
    # my $turn360 = $turn4 * 90;
    # $lo->command("forward 3; right $turn360");

    my $dir4 = count_1_bits($b) - 1;
    my $dir360 = $dir4 * 90;
    $lo->command("forward 3; seth $dir360");
  }
  $lo->disconnect("Finished...");
  exit 0;

  sub count_1_bits {
    my ($n) = @_;
    my $count = 0;
    while ($n) {
      $count += ($n & 1);
      $n >>= 1;
    }
    return $count;
  }
  sub count_low_0_bits {
    my ($n) = @_;
    if ($n == 0) { die; }
    my $count = 0;
    until ($n % 2) {
      $count++;
      $n /= 2;
    }
    return $count;
  }
}
{
  # repeat points
  require Math::PlanePath::CCurve;
  my $path = Math::PlanePath::CCurve->new;
  my %seen;
  my @first;
  foreach my $n (0 .. 2**16 - 1) {
    my ($x, $y) = $path->n_to_xy ($n);
    my $xy = "$x,$y";
    my $count = ++$seen{$xy};
    $first[$count] ||= $xy;
  }

  ### @first
  foreach my $xy (@first) {
    $xy or next;
    my ($x,$y) = split /,/, $xy;
    my @n_list = $path->xy_to_n_list($x,$y);
    print "$xy  N=",join(', ',@n_list),"\n";
  }

  my @count;
  while (my ($key,$visits) = each %seen) {
    $count[$visits]++;
    if ($visits > 4) {
      print "$key    $visits\n";
    }
  }
  ### @count


  exit 0;
}

{
  # _rect_to_level()
  require Math::PlanePath::CCurve;
  foreach my $x (0 .. 16) {
    my ($len,$level) = Math::PlanePath::CCurve::_rect_to_level(0,0,$x,0);
    $len = $len*$len-1;
    print "$x  $len $level\n";
  }
  foreach my $x (0 .. 16) {
    my ($len,$level) = Math::PlanePath::CCurve::_rect_to_level(0,0,0,$x);
    $len = $len*$len-1;
    print "$x  $len $level\n";
  }
  foreach my $x (0 .. 16) {
    my ($len,$level) = Math::PlanePath::CCurve::_rect_to_level(0,0,-$x,0);
    $len = $len*$len-1;
    print "$x  $len $level\n";
  }
  foreach my $x (0 .. 16) {
    my ($len,$level) = Math::PlanePath::CCurve::_rect_to_level(0,0,0,-$x);
    $len = $len*$len-1;
    print "$x  $len $level\n";
  }
  exit 0;
}
