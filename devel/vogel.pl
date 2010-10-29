#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

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

use strict;
use warnings;
use POSIX 'fmod';
use Math::Libm 'M_PI', 'hypot';
use Math::Trig 'pi';
use POSIX;

use Smart::Comments;

use constant PHI => (1 + sqrt(5)) / 2;


sub cont {
  my $ret = pop;
  while (@_) {
    $ret = (pop @_) + 1/$ret;
  }
  return $ret;
}
### phi: cont(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1)

{
  # use constant ROTATION => M_PI-3;
  # use constant ROTATION => PHI;
  #use constant ROTATION => sqrt(37);
  use constant ROTATION => cont(1 .. 20);
  
  my $margin = 0.999;
  # use constant K => 6;
  # use constant ROTATION => (K + sqrt(4+K*K)) / 2;
  print "ROTATION ",ROTATION,"\n";
  my @n;
  my @r;
  my @x;
  my @y;
  my $prev_d = 5;
  my $min_d = 5;
  my $min_n1 = 0;
  my $min_n2 = 0;
  my $min_x2 = 0;
  my $min_y2 = 0;
  for (my $n = 1; $n < 100_000_000; $n++) {
    my $r = sqrt($n);
    my $theta = $n * ROTATION() * 2*pi();  # radians
    my $x = $r * cos($theta);
    my $y = $r * sin($theta);

    foreach my $i (0 .. $#n) {
      my $d = hypot ($x-$x[$i], $y-$y[$i]);
      if ($d < $min_d) {
        $min_d = $d;
        $min_n1 = $n[$i];
        $min_n2 = $n;
        $min_x2 = $x;
        $min_y2 = $y;
        if ($min_d / $prev_d < $margin) {
          $prev_d = $min_d;
          print "$min_n1 $min_n2   $min_d ", 1/$min_d, "\n";
          print "  x=$min_x2 y=$min_y2\n";
        }
      }
    }

    push @n, $n;
    push @r, $r;
    push @x, $x;
    push @y, $y;

    if ((my $r_lo = sqrt($n) - 1.2 * $min_d) > 0) {
      while (@n > 1) {
        if ($r[0] >= $r_lo) {
          last;
        }
        shift @r;
        shift @n;
        shift @x;
        shift @y;
      }
    }
  }
  print "$min_n1 $min_n2   $min_d ", 1/$min_d, "\n";
  print "  x=$min_x2 y=$min_y2\n";
  exit 0;
}


{
  my $x = 3;
  foreach (1 .. 100) {
    $x = 1 / (1 + $x);
  }
}

# {
#   # 609 631   0.624053229799566 1.60242740883046
#   # 2 7   1.47062247517163 0.679984167849259
# 
#   use constant ROTATION => M_PI-3;
#   my @x;
#   my @y;
#   foreach my $n (1 .. 20000) {
#     my $r = sqrt($n);
#     # my $theta = 2 * $n;  # radians
#     my $theta = $n * ROTATION() * 2*pi();  # radians
#     push @x, $r * cos($theta);
#     push @y, $r * sin($theta);
#   }
#   # ### @x
#   my $min_d = 999;
#   my $min_i = 0;
#   my $min_j = 0;
#   my $min_xi = 0;
#   my $min_yi = 0;
#   foreach my $i (0 .. $#x-1) {
#     my $xi = $x[$i];
#     my $yi = $y[$i];
#     foreach my $j ($i+1 .. $#x) {
#       my $d = hypot ($xi-$x[$j], $yi-$y[$j]);
#       if ($d < $min_d) {
#         $min_d = $d;
#         $min_i = $i;
#         $min_j = $j;
#         $min_xi = $xi;
#         $min_yi = $yi;
#       }
#     }
#   }
#   print "$min_i $min_j   $min_d ", 1/$min_d, "\n";
#   print "  x=$min_xi y=$min_yi\n";
#   exit 0;
# }

# {
#   require Math::PlanePath::VogelFloret;
#   use constant FACTOR => do {
#     my @c = map {
#       my $n = $_;
#       my $r = sqrt($n);
#       my $revs = $n / (PHI * PHI);
#       my $theta = $revs * 2*M_PI();
#       ### $n
#       ### $r
#       ### $revs
#       ### $theta
#       ($r*cos($theta), $r*sin($theta))
#     } 1, 4;
#     ### @c
#     ### hypot: hypot ($c[0]-$c[2], $c[1]-$c[3])
#     1 / hypot ($c[0]-$c[2], $c[1]-$c[3])
#   };
#   ### FACTOR: FACTOR()
# 
#   print "FACTOR ", FACTOR(), "\n";
#   # print "FACTOR ", Math::PlanePath::VogelFloret::FACTOR(), "\n";
#   exit 0;
# }

{
  foreach my $i (0 .. 20) {
    my $f = PHI**$i/sqrt(5);
    my $rem = fmod($f,PHI);
    printf "%11.5f  %6.5f\n", $f, $rem;
  }
  exit 0;
}

{
  foreach my $n (18239,19459,25271,28465,31282,35552,43249,74592,88622,
                 101898,107155,116682) {
    my $theta = $n / (PHI * PHI);  # 1==full circle
    printf "%6d  %.2f\n", $n, $theta;
  }
  exit 0;
}

foreach my $i (2 .. 5000) {
  my $rem = fmod ($i, PHI*PHI);
  if ($rem > 0.5) {
    $rem = $rem - 1;
  }
  if (abs($rem) < 0.02) {
    printf "%4d  %6.3f  %s\n", $i,$rem,factorize($i);
  }
}


sub factorize {
  my ($n) = @_;
  my @factors;
  foreach my $f (2 .. int(sqrt($n)+1)) {
    if (($n % $f) == 0) {
      push @factors, $f;
      $n /= $f;
      while (($n % $f) == 0) {
        $n /= $f;
      }
    }
  }
  return join ('*',@factors);
}
exit 0;

#     pi    => { rotation_factor => M_PI() - 3,
#                rfactor    => 2,
#                # ever closer ?
#                # 298252 298365   0.146295611059244 6.83547505464836
#                #   x=-142.771526420416 y=527.239311170539
#              },
# # BEGIN {
# #   foreach my $info (rotation_types()) {
# #     my $rot = $info->{'rotation_factor'};
# #     my $n1 = $info->{'closest_Ns'}->[0];
# #     my $r1 = sqrt($n1);
# #     my $t1 = $n1 * $rot * 2*M_PI();
# #     my $x1 = cos ($t1);
# #     my $y1 = sin ($t1);
# # 
# #     my $r2 = sqrt($n2);
# #     my $t2 = $n2 * $rot * 2*M_PI();
# #     my $x2 = cos ($t2);
# #     my $y2 = sin ($t2);
# # 
# #     $info->{'rfactor'} = 1 / hypot ($x1-$x2, $y1-$y2);
# #   }
# # }

