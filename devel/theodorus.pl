#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use POSIX 'floor', 'fmod';
use Math::Trig 'pi', 'atan';
use Math::BigFloat try => 'GMP';
use Math::Libm 'hypot';

use Smart::Comments;


{
  require Math::Polynomial;

  my @n;
  my @theta;
  my $total = 0;
  foreach my $n (1 .. 50) {
    my $total += atan(1/sqrt($n));
    push @n, $n;
    push @theta, $total;
  }

  my $p = Math::Polynomial->new;
  $p = $p->interpolate(\@n, \@theta);

  foreach my $i (0 .. $p->degree) {
    print "$i  ",$p->coeff($i),"\n";
  }
  # $p->string_config({ fold_sign => 1,
  #                     variable  => 'n' });
  # print "theta = $p\n";
  exit 0;
}

{
  my $c2 = 2.15778;
  my $t1 = 1.8600250;
  my $t2 = 0.43916457;
  my $z32 = 2.6123753486;
  my $tn1 = 2*$t1 - 2*$t2 - $z32;
  my $n = 1;
  my $x = 1;
  my $y = 0;

  while ($n < 10000) {
    my $r = sqrt($n); # before increment
    ($x, $y) = ($x - $y/$r, $y + $x/$r);
    $n++;

    $r = sqrt($n); # after increment

    my $theta = atan2($y,$x);
    if ($theta < 0) { $theta += 2*pi(); }
    my $root;
    $root = 2*sqrt($n) - $c2;
    # $root += .01/$r;

    # $root = -atan(sqrt($n)) + $n*atan(1/sqrt($n)) + sqrt($n);
    # $root = atan(1/sqrt($n)) - pi()/2 + $n*atan(1/sqrt($n)) + sqrt($n);
    $root = 2*sqrt($n)
      + 1/sqrt($n)
        - $c2
#           - 1/($n*sqrt($n))/3
#             + 1/($n*$n*sqrt($n))/5
#               - 1/($n*$n*sqrt($n))/7
#                 + 1/($n*$n*$n*sqrt($n))/9
                  ;
    #     $root = -pi()/4 + Arctan($r);
    #     foreach my $k (2 .. 1000000) {
    #       $root += atan(1/sqrt($k)) - atan(1/sqrt($k + $r*$r - 1));
    #       # $root += atan( ($r*$r - 1) / ( ($k + $r*$r)*sqrt($k) + ($k+1)*sqrt($k+$r*$r-1)));
    #     }

    # $root = -pi()/2 + Arctan($r) + $t1 *$r*$r/2 + ($tn1 - $t1)*$r**2/8;

    $root = fmod ($root, 2*pi());
    my $d = $root - $theta;
    $d = fmod ($d + pi(), 2*pi()) - pi();

    # printf  "%10.6f %10.6f %23.20f\n", $theta, $root, $d;
    printf  "%23.20f\n", $d;
  }
  exit 0;
}

{
  my $t1 = 0;
  foreach my $k (1 .. 100) {
    $t1 += 1 / (sqrt($k) * ($k+1));
  printf  "%10.6f\n", $t1;
  }
  exit 0;
}

sub Arctan {
  my ($r) = @_;
  return pi()/2 - atan(1/$r);
}

{
  Math::BigFloat->accuracy(200);
  my $bx = Math::BigFloat->new(1);
  my $by = Math::BigFloat->new(0);
  my $x = 1;
  my $y = 0;
  my $n = 1;

  my @n = ($n);
  my @x = ($x);
  my @y = ($y);
  my $count = 0;

  my $prev_n = 0;
      my $prev_d = 0;
  my @dd;

  while ($n++ < 10000000) {
    my $r = hypot($x,$y);
    my $py = $y;
    ($x, $y) = ($x - $y/$r, $y + $x/$r);

    if ($py < 0 && $y >= 0) {
      my $d = $n-$prev_n;
      my $dd = $d-$prev_d;
      push @dd, $dd;
      printf  "%5d +%4d +%3d %7.3f %10.6f %10.6f\n",
        $n,
          $d,
            $dd,
          # (sqrt($n)-1.07)/pi(),
          sqrt($n),
            $x, $y;
      $prev_n = $n;
      $prev_d = $d;
      if (++$count >= 10) {
        push @n, $n;
        push @x, $x;
        push @y, $y;
        $count = 0;
      }
    }
  }

  print "average dd ", List::Util::sum(@dd)/scalar(@dd),"\n";

#   require Data::Dumper;
#   print Data::Dumper->new([\@n],['n'])->Indent(1)->Dump;
#   print Data::Dumper->new([\@x],['x'])->Indent(1)->Dump;
#   print Data::Dumper->new([\@y],['y'])->Indent(1)->Dump;

  #   require Math::Polynomial;
  #   my $p = Math::Polynomial->new(0);
  #   $p = $p->interpolate([ 1 .. @nc ], \@nc);
  #   $p->string_config({ fold_sign => 1,
  #                       variable  => 'd' });
  #   print "N = $p\n";

  exit 0;
}

{
  Math::BigFloat->accuracy(200);
  my $bx = Math::BigFloat->new(1);
  my $by = Math::BigFloat->new(0);
  my $x = 1;
  my $y = 0;
  my $n = 1;

  while ($n++ < 10000) {
    my $r = hypot($x,$y);
    ($x, $y) = ($x - $y/$r, $y + $x/$r);

    my $br = sqrt($bx*$bx + $by*$by);
    ($bx, $by) = ($bx - $by/$br, $by + $bx/$br);

  }
  my $ex = "$bx" + 0;
  my $ey = "$by" + 0;
  printf  "%10.6f %10.6f %23.20f\n", $ex, $x, $ex - $x;
  exit 0;
}
