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

use 5.010;
use strict;
use warnings;
use List::MoreUtils;
use POSIX 'floor';
use Math::Libm 'M_PI', 'hypot';
use List::Util 'min', 'max';
use Math::PlanePath::DragonCurve;
use Math::PlanePath::Base::Digits
  'round_down_pow';
use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::KochCurve;
*_digit_join_hightolow = \&Math::PlanePath::KochCurve::_digit_join_hightolow;

use lib 'xt';


# uncomment this to run the ### lines
#use Smart::Comments;


{
  # X,Y recursion
  my $w = 8;
  my $path = Math::PlanePath::DragonCurve->new;
  foreach my $offset (0 .. $w-1) {
    my $n = $path->n_start + $offset;
    foreach (1 .. 10) {
      my ($x,$y) = $path->n_to_xy($n);
      print "$x ";
      $n += $w;
    }
    print "\n";
  }
  exit 0;
}

{
  # Midpoint tiling, text lines

  require Math::PlanePath::DragonMidpoint;
  require Image::Base::Text;
  my $scale = 1;
  my $arms = 4;
  my $path = Math::PlanePath::DragonMidpoint->new (arms => $arms);

  my $width = 64;
  my $height = 32;
  my $xoffset = $width/2;
  my $yoffset = $height/2;
  my $image = Image::Base::Text->new (-width => $width,
                                      -height => $height);
  my ($nlo,$nhi) = $path->rect_to_n_range(-$xoffset,-$yoffset,
                                          $xoffset,$yoffset);
  $nhi = 16384;
  print "nhi $nhi\n";
  for (my $n = 0; $n <= $nhi; $n++) {
    # next if int($n/$arms) % 2;
    next unless int($n/$arms) % 2;
    my ($x1,$y1) = $path->n_to_xy($n);
    my ($x2,$y2) = $path->n_to_xy($n+$arms);
    my $colour = ($x1 == $x2 ? '|' : '-');
    $x1 *= $scale;
    $x2 *= $scale;
    $y1 *= $scale;
    $y2 *= $scale;
    $x1 += $xoffset;
    $x2 += $xoffset;
    $y1 += $yoffset;
    $y2 += $yoffset;
    $image->line($x1,$y1,$x2,$y2,$colour);
  }
  $image->save('/dev/stdout');
  exit 0;
}

{
  # Midpoint tiling, text grid

  require Math::PlanePath::DragonMidpoint;
  require Image::Base::Text;
  my $scale = 2;
  my $arms = 4;
  my $path = Math::PlanePath::DragonMidpoint->new (arms => $arms);

  my $width = 64;
  my $height = 32;
  my $xoffset = $width/2 - 9;
  my $yoffset = $height/2 - 10;
  my $image = Image::Base::Text->new (-width => $width,
                                      -height => $height);
  my ($nlo,$nhi) = $path->rect_to_n_range(-$xoffset,-$yoffset,
                                          $xoffset,$yoffset);
  $nhi = 16384;
  print "nhi $nhi\n";
  for (my $n = 0; $n <= $nhi; $n++) {
    # next if int($n/$arms) % 2;
    next unless int($n/$arms) % 2;
    my ($x1,$y1) = $path->n_to_xy($n);
    my ($x2,$y2) = $path->n_to_xy($n+$arms);
    $y1 = -$y1;
    $y2 = -$y2;
    my $colour = ($x1 == $x2 ? '|' : '-');
    ($x1,$x2) = (min($x1,$x2),max($x1,$x2));
    ($y1,$y2) = (min($y1,$y2),max($y1,$y2));
    $x1 *= $scale;
    $x2 *= $scale;
    $y1 *= $scale;
    $y2 *= $scale;

    $x1 -= $scale/2;
    $x2 += $scale/2;
    $y1 -= $scale/2;
    $y2 += $scale/2;

    $x1 += $xoffset;
    $x2 += $xoffset;
    $y1 += $yoffset;
    $y2 += $yoffset;

    ### rect: $x1,$y1,$x2,$y2
    $image->rectangle($x1,$y1,$x2,$y2,'*');
  }
  $image->save('/dev/stdout');
  exit 0;
}

{
  # Midpoint tiling, PNG

  require Math::PlanePath::DragonMidpoint;
  require Image::Base::Text;
  require Image::Base::PNGwriter;

  my $scale = 4;
  my $arms = 1;
  my $path = Math::PlanePath::DragonMidpoint->new (arms => $arms);

  # my $width = 78;
  # my $height = 48;
  # my $xoffset = $width/2;
  # my $yoffset = $height/2;
  # my $image = Image::Base::Text->new (-width => $width,
  #                                     -height => $height);

  my $width = 1000;
  my $height = 800;
  my $xoffset = $width/2;
  my $yoffset = $height/2;
  my $image = Image::Base::PNGwriter->new (-width => $width,
                                           -height => $height);
  my $colour = '#00FF00';
  my ($nlo,$nhi) = $path->rect_to_n_range(-$xoffset,-$yoffset,
                                          $xoffset,$yoffset);
  $nhi = 16384*2;
  print "nhi $nhi\n";
  for (my $n = 0; $n <= $nhi; $n++) {
    # next if int($n/$arms) % 2;
     next unless int($n/$arms) % 2;
    my ($x1,$y1) = $path->n_to_xy($n);
    my ($x2,$y2) = $path->n_to_xy($n+$arms);
    $x1 *= $scale;
    $y1 *= $scale;
    $x2 *= $scale;
    $y2 *= $scale;
    $x1 += $xoffset;
    $x2 += $xoffset;
    $y1 += $yoffset;
    $y2 += $yoffset;
    $image->line($x1,$y1,$x2,$y2,$colour);
  }
  # $image->save('/dev/stdout');
  $image->save('/tmp/x.png');
  system('xzgv /tmp/x.png');
  exit 0;
}
{
  # drawing with Language::Logo

  require Language::Logo;
  require Math::NumSeq::PlanePathTurn;
  my $seq = Math::NumSeq::PlanePathTurn->new(planepath=>'DragonCurve',
                                             turn_type => 'Right');

  my $lo = Logo->new(update => 20);
  $lo->command("pendown");
  foreach my $n (0 .. 256) {
    my ($i,$value) = $seq->next;
    my $turn_angle = ($value ? 90 : -90);
    $lo->command("forward 10; right $turn_angle");
  }
  $lo->disconnect("Finished...");
  exit 0;
}

{
  require Math::NumSeq::PlanePathTurn;
  my $seq = Math::NumSeq::PlanePathTurn->new(planepath=>'DragonCurve',
                                             turn_type => 'Right');
  foreach my $n (0 .. 16) {
    my $dn = dseq($n);
    my $turn = $seq->ith($n) // 'undef';
    print "$n  $turn $dn\n";
  }
  exit 0;

  # Knuth vol 2 answer to 4.5.3 question 41, page 607
  sub dseq {
    my ($n) = @_;
    for (;;) {
      if ($n == 0) {
        return 1;
      }
      if (($n % 2) == 0) {
        $n >>= 1;
        next;
      }
      if (($n % 4) == 1) {
        return 0;   # bit above lowest 1-bit
      }
      if (($n % 4) == 3) {
        return 1;   # bit above lowest 1-bit
      }
    }
  }

}


{
  # rect range exact

  my @rot_to_dx = (1,0,-1,0);
  my @rot_to_dy = (0,1,0,-1);
  my @digit_to_rev = (0,5,0,5,undef,
                      5,0,5,0);
  my @min_digit_to_rot = (-1,1,1,-1,0,
                          0,1,-1,-1,1);

  sub rect_to_n_range {
    my ($self, $x1,$y1, $x2,$y2) = @_;
    ### DragonCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"

    my $xmax = int(max(abs($x1),abs($x2)));
    my $ymax = int(max(abs($y1),abs($y2)));
    my ($level_power, $level_max)
      = round_down_pow (($xmax*$xmax + $ymax*$ymax + 1) * 7,
                        2);
    ### $level_power
    ### $level_max
    if (is_infinite($level_max)) {
      return (0, $level_max);
    }

    my $zero = $x1 * 0 * $y1 * $x2 * $y2;
    my $initial_len = 2**$level_max;
    ### $initial_len

    my ($len, $rot, $x, $y);
    my $overlap = sub {
      my $extent = ($len == 1 ? 0 : 2*$len);
      ### overlap consider: "xy=$x,$y extent=$extent"
      return ($x + $extent >= $x1
              && $x - $extent <= $x2
              && $y + $extent >= $y1
              && $y - $extent <= $y2);
    };


    my $find_min = sub {
      my ($initial_rev, $extra_rot) = @_;
      ### find_min() ...
      ### $initial_rev
      ### $extra_rot

      $rot = $level_max + 1 + $extra_rot;
      $len = $initial_len;
      if ($initial_rev) {
        $rot += 2;
        $x = 2*$len * $rot_to_dx[($rot+2)&3];
        $y = 2*$len * $rot_to_dy[($rot+2)&3];
      } else {
        $x = $zero;
        $y = $zero;
      }
      my @digits = (-1);  # high to low
      my $rev = $initial_rev;

      for (;;) {
        my $digit = ++$digits[-1];
        ### min at: "digits=".join(',',@digits)."  xy=$x,$y   len=$len  rot=".($rot&3)." rev=$rev"

        unless ($initial_rev) {
          my $nlo = _digit_join_hightolow ([@digits,(0)x($level_max-$#digits)], 4, $zero);
          my ($nx,$ny) = $self->n_to_xy($nlo);
          my ($nextx,$nexty) = $self->n_to_xy($nlo + $len*$len);
          ### nlo: "nlo=$nlo xy=$nx,$ny  next xy=$nextx,$nexty"
          ### assert: $x == $nx
          ### assert: $y == $ny
          # ### assert: $nextx == $nx + ($rot_to_dx[$rot&3] * $len)
          # ### assert: $nexty == $ny + ($rot_to_dy[$rot&3] * $len)
        }

        $rot += $min_digit_to_rot[$digit+$rev];
        ### $digit
        ### rot increment: $min_digit_to_rot[$digit+$rev]." to $rot"

        if ($digit > 3) {
          pop @digits;
          if (! @digits) {
            ### not found to level_max ...

            if ($x1 <= 0 && $x2 >= 0 && $y1 <= 0 && $y2 >= 0) {
              ### origin covered: 4**($level_max+1)
              return 4**$level_max;
            } else {
              return;
            }
          }
          $rev = (@digits < 2 ? $initial_rev
                  : $digits[-2]&1 ? 5 : 0);
          ### past digit=3, backtrack ...
          $len *= 2;
          next;
        }

        if (&$overlap()) {
          if ($#digits >= $level_max) {
            ### yes overlap, found n_lo ...
            last;
          }
          ### yes overlap, descend ...
          ### apply rev: "digit=$digit rev=$rev   xor=$digit_to_rev[$digit+$rev]"
          push @digits, -1;
          $rev = ($digit & 1 ? 5 : 0);
          $len /= 2;

          # {
          #   my $state = 0;
          #   foreach (@digits) { if ($_&1) { $state ^= 5 } }
          #   ### assert: $rev == $state
          # }

        } else {
          ### no overlap, next digit ...
          $rot &= 3;
          $x += $rot_to_dx[$rot] * $len;
          $y += $rot_to_dy[$rot] * $len;
        }
      }
      ### digits: join(',',@digits)
      ### found n_lo: _digit_join_hightolow (\@digits, 4, $zero)
      return _digit_join_hightolow (\@digits, 4, $zero);
    };

    my $arms = $self->{'arms'};
    my @n_lo;
    foreach my $arm (0 .. $arms-1) {
      if (defined (my $n = &$find_min(0,$arm))) {
        push @n_lo, $n*$arms + $arm;
      }
    }
    if (! @n_lo) {
      return (1,0);  # rectangle not visited by curve
    }

    my $n_top = 4 * $level_power * $level_power;
    ### $n_top
    my @n_hi;
    foreach my $arm (0 .. $arms-1) {
      if (defined (my $n = &$find_min(5,$arm))) {
        push @n_hi, ($n_top-$n)*$arms + $arm;
      }
    }

    return (min(@n_lo), max(@n_hi));
  }

  my $path = Math::PlanePath::DragonCurve->new (arms => 4);
  foreach my $n (4 .. 1000) {
    my ($x,$y) = $path->n_to_xy($n);
    my @n_list = $path->xy_to_n_list($x,$y);
    my $want_lo = min(@n_list);
    my $want_hi = max(@n_list);
    my ($lo,$hi) = rect_to_n_range ($path, $x,$y, $x,$y);
    print "n=$n  lo=$lo wantlo=$want_lo  hi=$hi wanthi=$want_hi\n";

    if ($lo != $want_lo) {
      die "n=$n  lo=$lo wantlo=$want_lo";
    }
    if ($hi != $want_hi) {
      die "n=$n  hi=$hi wanthi=$want_hi";
    }
  }
  exit 0;
}


{
  # level to ymax, xmin
  my $path = Math::PlanePath::DragonCurve->new;
  my $target = 4;
  my $xmin = 0;
  my $ymax = 0;
  for (my $n = 0; $n < 2**28; $n++) {
    my ($x,$y) = $path->n_to_xy($n);
    $xmin = min($x,$xmin);
    $ymax = max($y,$ymax);
    if ($n == $target) {
      printf "%7d %14b %14b\n", $n, -$xmin, $ymax;
      $target *= 2;
    }
  }
  exit 0;
}

{
  # upwards
  #                  9----8    5---4
  #                  |    |    |   |
  #                 10--11,7---6   3---2
  #                       |            |
  #            16   13---12        0---1
  #             |    |
  #            15---14
  #
  #
  #
  #                       8----->  4
  #                       |        ^
  #                       |        |
  #            16----->   v        |
  #
  #
  #
  # 2*(4^2-1)/3 = 10 0b1010
  # 4*(4^2-1)/3 = 20 0b10100
  #
  # (2^3+1)/3
  # (2^4-1)/3
  # (2^5-2)/3 = 10
  # (2^6-4)/3 = 20
  # (2^7-2)/3 = 42 = 101010
  # (2^8-4)/3 = 84 = 1010100
  #
  # # new xmax = xmax or ymax
  # # new xmin = ymin-4
  # # new ymax = ymax or -ymin or 2-xmin
  # # new ymin = ymin or -ymax or -xmax
  #
  #                  16
  #                   |
  #                   |
  #                   v
  #       xmin seg 2  <---8
  #                       |
  #                       |
  #                       v
  #                   --->4   xmax seg0
  #
  #               ymin seg 0
  #
  # new xmax = len + -xmin
  #          = len + -ymin
  # new xmin = - xmax
  # new ymax = 2len + (-ymin)   only candidate
  # new ymin = -(ymax-len)
  #
  # xmax,xmin alternate
  # ymax-len,ymin alternate

  my $xmin = 0;
  my $xmax = 0;
  my $ymin = 0;
  my $ymax = 0;
  my $len = 1;
  my $exp = 8;
  print "level xmin    xmax       xsize      |   ymin   ymax   ysize\n";
  for (0 .. $exp) {
    printf "%2d %-10s %-10s = %-10s | %-10s %-10s = %-10s\n",
      $_,
        to_bin($xmin),to_bin($xmax),  to_bin(-$xmin+$xmax),
            to_bin($ymin),to_bin($ymax),  to_bin(-$ymin+$ymax);

    my @xmax_candidates = ($ymax,      # seg 0 across
                           $len-$xmin, # seg 1 side    <---
                           $len-$ymin, # seg 2 before  <---
                          );
    my $xmax_seg = max_index(@xmax_candidates);
    my $xmax_candstr = join(',',@xmax_candidates);

    my @xmin_candidates = ($ymin,         # seg 0 before
                           -($ymax-$len), # seg 2 across
                           -$xmax,        # seg 3 side  <---
                          );
    my $xmin_seg = min_index(@xmin_candidates);
    my $xmin_candstr = join(',',@xmin_candidates);

    my @ymin_candidates = (-$xmax,          # seg 0 side  <---
                           -($ymax-$len));  # seg 1 extend
    my $ymin_seg = min_index(@ymin_candidates);
    my $ymin_candstr = join(',',@ymin_candidates);
    print "$_  xmax ${xmax_seg}of$xmax_candstr xmin ${xmin_seg}of$xmin_candstr ymin ${ymin_seg}of$ymin_candstr\n";

    ($xmax,$xmin, $ymax,$ymin)
      = (
         # xmax
         max ($ymax,      # seg 0 across
              $len-$xmin, # seg 1 side
              $len-$ymin, # seg 2 before
             ),

         # xmin
         min ($ymin,       # seg 0 before
              $len-$ymax,  # seg 2 across
              -$xmax,      # seg 3 side
             ),

         # ymax
         2*$len-$ymin,    # seg 3 before

         # ymin
         min(-$xmax,           # seg 0 side
             -($ymax-$len)));  # seg 1 extend

    ### assert: $xmin <= 0
    ### assert: $ymin <= 0
    ### assert: $xmax >= 0
    ### assert: $ymax >= 0

    $len *= 2;
  }
  print 3*$xmin/$len+.001," / 3\n";
  print 6*$xmax/$len+.001," / 6\n";
  print 3*$ymin/$len+.001," / 3\n";
  print 3*$ymax/$len+.001," / 3\n";
  exit 0;

  sub min_index {
    my $min_value = $_[0];
    my $ret = 0;
    foreach my $i (1 .. $#_) {
      my $next = $_[$i];
      if ($next == $min_value) {
        $ret .= ",$i";
      } elsif ($next < $min_value) {
        $ret = $i;
        $min_value = $next;
      }
    }
    return $ret;
  }
  sub max_index {
    ### max_index(): @_
    my $max_value = $_[0];
    my $ret = 0;
    foreach my $i (1 .. $#_) {
      my $next = $_[$i];
      ### $next
      if ($next == $max_value) {
        ### append ...
        $ret .= ",$i";
      } elsif ($next > $max_value) {
        ### new max ...
        $ret = $i;
        $max_value = $next;
      }
    }
    return $ret;
  }
}

{
  # A088431 and A007400 continued fraction
  require Math::ContinuedFraction;
  require Math::NumSeq::PlanePathTurn;
  require Math::NumSeq::GolayRudinShapiro;
  require Math::NumSeq::OEIS;

  my @runlengths = (0,1);
  # my $seq = Math::NumSeq::PlanePathTurn->new(planepath=>'DragonCurve');
  my $seq = Math::NumSeq::GolayRudinShapiro->new;
  # my $seq = Math::NumSeq::OEIS->new (anum => 'A203531');

  my (undef, $prev) = $seq->next;
  my $count = 1;
  while (@runlengths < 50) {
    my (undef, $turn) = $seq->next;
    if ($turn != $prev) {
      push @runlengths, $count * 2;
      $count = 0;
      $prev = $turn;
    }
    $count++;
  }

  # @runlengths = (0, 1, 4, 2, 4, 4, 6, 4, 2, 4, 6, 2, 4, 6, 4, 4, 2, 4, 6, 2, 4, 4, 6, 4,
  #                2, 6, 4, 2, 4, 6, 4, 4, 2, 4, 6, 2, 4, 4, 6, 4, 2, 4, 6, 2, 4, 6, 4, 4,
  #                2, 6, 4, 2, 4, 4, 6, 4, 2, 6, 4, 2, 4, 6, 4, 4, 2, 4, 6, 2, 4, 4, 6, 4,
  #                2, 4, 6, 2, 4, 6, 4, 4, 2, 4, 6, 2, 4, 4, 6, 4, 2, 6, 4, 2, 4, 6, 4, 4,
  #               );

  my $cf = Math::ContinuedFraction->new(\@runlengths);
  my $cfstr = $cf->to_ascii;
  print "cf $cfstr\n";

  foreach my $i (1 .. $#runlengths) {
    my ($num, $den) = $cf->convergent($i);
    my $numstr = $num->as_bin;
    $numstr =~ s/^0b//;
    my $denstr = $den->as_bin;
    $denstr =~ s/^0b//;
    # printf "%3d %-40.70s\n", $i, $numstr;
    # printf "    %-40.70s\n", $denstr;

    my $approx = ($num << 256) / $den;
    my $bits = $approx->as_bin;
    $bits =~ s/^0b//;
    print "approx:   $bits\n";
  }

  my ($num, $den) = $cf->convergent($#runlengths);
  my $approx = $num->numify / $den->numify;
  print "$approx\n";

  $num *= Math::BigInt->new(2) ** 70;
  $num /= $den;
  my $bits = $num->as_bin;
  $bits =~ s/^0b//;
  print "d:   $bits\n";

  exit 0;
}



  # n_to_xy ...

  # {
  #   # low to high
  #   my $rev = 0;
  #   my @rev;
  #   foreach my $digit (reverse @digits) {
  #     push @rev, $rev;
  #     $rev ^= $digit;
  #   }
  #   ### @digits
  #   my $x = 0;
  #   my $y = 0;
  #   my $dy = $rot & 1;
  #   my $dx = ! $dy;
  #   if ($rot & 2) {
  #     $dx = -$dx;
  #     $dy = -$dy;
  #   }
  #   $rev = 0;
  #   foreach my $digit (@digits) {
  #     ### at: "$x,$y  dxdy=$dx,$dy"
  #     my $rev = shift @rev;
  #     if ($digit) {
  #       if ($rev) {
  #         ($x,$y) = (-$y,$x); # rotate +90
  #       } else {
  #         ($x,$y) = ($y,-$x); # rotate -90
  #       }
  #       $x += $dx;
  #       $y += $dy;
  #       $rev = $digit;
  #     }
  #     # multiply i+1, ie. (dx,dy) = (dx + i*dy)*(i+1)
  #     ($dx,$dy) = ($dx-$dy, $dx+$dy);
  #   }
  #   ### final: "$x,$y  dxdy=$dx,$dy"
  #   return ($x,$y);
  # }


{
  # inner rectangle touching

  #                          |               |
  #                    751-750         735-734         431-
  #
  #
  #
  #                                                382-383
  #                                                      |
  #                                            380-385-384
  #                                                  |
  #                                            379-386-387
  #                                                      |
  #                                            376-377-388
  #                                                  |
  #                                            375-374 371-
  #
  #                                                    368
  #
  #                                                    367-
  #
  #          9-- 8   5-- 4
  #          |       |
  #         10--11-- 6   3-- 2                     190-191
  #              |                                       |
  # 17--16  13--12       0-- 1                 188-193-192
  #  |       |                                       |
  # 18--19- 22--23                             187-194-195
  #      |       |                                       |
  #     20- 25--24                             184-185-196
  #          |                                       |
  #         26--27  46--47          94--95     183-182-179-
  #              |       |               |               |
  # 33--32  29- 44- 49--48      92- 97--96     108-113-176
  #  |       |       |               |               |
  # 34--35- 38- 43- 50--51  54- 91- 98--99 102-107-114-175-
  #      |       |       |       |       |       |       |
  #     36--37  40--41  52- 57- 88--89-100-101 104-105 116
  #                          |       |
  #                         58- 87--86- 83--82
  #                              |       |
  #                 65--64  61- 76--77  80--81     129-128
  #                  |       |                       |
  #                 66--67- 70- 75--74             130-131-134
  #                      |       |                       |
  #                     68--69  72--73                 132


  require Math::PlanePath::DragonCurve;
  my $path = Math::PlanePath::DragonCurve->new;

  foreach my $k (0 .. 5) {
    my $level = 2*$k;
    my $Nlevel = 2**$level;
    print "k=$k level=$level  Nlevel=$Nlevel\n";

    # my $c1x = 2**$k - calc_Wmax($k);  # <--
    # my $c1y = 2**$k + calc_Wmin($k);  # <--
    # my $c2x = 2**($k+1) - calc_Wmax($k+1);
    # my $c2y = 2**($k+1) + calc_Wmin($k+1);
    # my $c3x = 2**($k+2) - calc_Wmax($k+2);   # <--
    # my $c3y = 2**($k+2) + calc_Wmin($k+2);   # <--

    my $c1x = calc_Wouter($k);  # <--
    my $c1y = calc_Louter($k);  # <--
    my $c2x = calc_Wouter($k+1);
    my $c2y = calc_Louter($k+1);
    my $c3x = calc_Wouter($k+2);   # <--
    my $c3y = calc_Louter($k+2);   # <--

    my $step_c2x = 2*$c1x - !($k&1);
    unless ($step_c2x == $c2x) {
      warn "step X $step_c2x != $c2x";
    }
    my $step_c2y = 2*$c1y - ($k&1);
    unless ($step_c2y == $c2y) {
      warn "step Y $step_c2y != $c2y";
    }

    my $step_c3x = 4 * $c1x - 2 + ($k&1);
    unless ($step_c3x == $c3x) {
      warn "step X $step_c3x != $c3x";
    }
    my $step_c3y = 4 * $c1y - 1 - ($k & 1);
    unless ($step_c3y == $c3y) {
      warn "step Y $step_c3y != $c3y";
    }

    unless ($c1y == $c2x) {
      warn "diff $c1y $c2x";
    }
    unless ($c2y == $c3x) {
      warn "diff $c2y $c3x";
    }

    my $xmax = $c1x;
    my $ymax = $c1y;

    my $xmin = -$c3x;
    my $ymin = -$c3y;

    print "  C1 x=$xmax,y=$ymax  C2 x=$c2x,y=$c2y C3 x=$c3x,y=$c3y\n";

    print "  out x=$xmin..$xmax  y=$ymin..$ymax\n";
    foreach (1 .. $k) {
      print "    rotate\n";
      ($xmax,       # rotate +90
       $ymax,
       $xmin,
       $ymin) = (-$ymin,
                 $xmax,
                 -$ymax,
                 $xmin);
    }
    print "  out x=$xmin..$xmax  y=$ymin..$ymax\n";

    my $in_xmax = $xmax - 1;
    my $in_xmin = $xmin + 1;
    my $in_ymax = $ymax - 1;
    my $in_ymin = $ymin + 1;
    print "  in x=$in_xmin..$in_xmax  y=$in_ymin..$in_ymax\n";

    # inner edges, Nlevel or higher is bad
    foreach my $y ($in_ymax, $in_ymin) {
      foreach my $x ($in_xmin .. $in_xmax) {
        foreach my $n ($path->xy_to_n_list ($x, $y)) {
          if ($n >= $Nlevel) {
            print "$n  $x,$y  horiz ***\n";
          }
        }
      }
    }
    # inner edges, Nlevel or higher is bad
    foreach my $x ($in_xmax, $in_xmin) {
      foreach my $y ($in_ymin .. $in_ymax) {
        foreach my $n ($path->xy_to_n_list ($x, $y)) {
          if ($n >= $Nlevel) {
            print "$n  $x,$y  vert ***\n";
          }
        }
      }
    }


    # outer edges, Nlevel or higher touched
    my $touch = 0;
    foreach my $y ($ymax, $ymin) {
      foreach my $x ($xmin .. $xmax) {
        foreach my $n ($path->xy_to_n_list ($x, $y)) {
          if ($n >= $Nlevel) {
            $touch++;
          }
        }
      }
    }
    # inner edges, Nlevel or higher is bad
    foreach my $x ($xmax, $xmin) {
      foreach my $y ($ymin .. $ymax) {
        foreach my $n ($path->xy_to_n_list ($x, $y)) {
          if ($n >= $Nlevel) {
            $touch++;
          }
        }
      }
    }
    my $diff_touch = ($touch == 0 ? '  ***' : '');
    print "  touch $touch$diff_touch\n";
  }

  exit 0;

  sub calc_Louter {
    my ($k) = @_;
    # Louter = 2^k - abs(Lmin)
    #        = 2^k - (2^k - 1 - (k&1))/3
    #        = (3*2^k - (2^k - 1 - (k&1)))/3
    #        = (3*2^k - 2^k + 1 + (k&1))/3
    #        = (2*2^k + 1 + (k&1))/3
    return (2*2**$k + 1 + ($k&1)) / 3;

    # return 2**$k + calc_Lmin($k);
  }
  sub calc_Wouter {
    my ($k) = @_;
    # Wouter = 2^k - Wmax
    #        = 2^k - (2*2^k - 2 + (k&1)) / 3
    #        = (3*2^k - (2*2^k - 2 + (k&1))) / 3
    #        = (3*2^k - 2*2^k + 2 - (k&1)) / 3
    #        = (2^k + 2 - (k&1)) / 3
    return (2**$k + 2 - ($k&1)) / 3;

    # return 2**$k - calc_Wmax($k);
  }



  sub calc_Lmax {
    my ($k) = @_;
    #     Lmax = (7*2^k - 4)/6 if k even
    #            (7*2^k - 2)/6 if k odd
    if ($k & 1) {
      return (7*2**$k - 2) / 6;
    } else {
      return (7*2**$k - 4) / 6;
    }
  }
  sub calc_Lmin {
    my ($k) = @_;
    #     Lmin = - (2^k - 1)/3 if k even
    #            - (2^k - 2)/3 if k odd
    #          = - (2^k - 2 - (k&1))/3
    if ($k & 1) {
      return - (2**$k - 2) / 3;
    } else {
      return - (2**$k - 1) / 3;
    }
  }
  sub calc_Wmax {
    my ($k) = @_;
    #     Wmax = (2*2^k - 1) / 3 if k odd
    #            (2*2^k - 2) / 3 if k even
    #          = (2*2^k - 2 + (k&1)) / 3
    if ($k & 1) {
      return (2*2**$k - 1) / 3;
    } else {
      return (2*2**$k - 2) / 3;
    }
  }
  sub calc_Wmin {
    my ($k) = @_;
    return calc_Lmin($k);
  }
}

{
  # inner Wmin/Wmax

  foreach my $k (0 .. 10) {
    my $wmax = calc_Wmax($k);
    my $wmin = calc_Wmin($k);
    my $submax = 2**$k - $wmax;
    my $submin = 2**$k + $wmin;
    printf "%2d %4d %4d   %4d %4d\n",
      $k, abs($wmin), $wmax, $submax, $submin;

    # printf "%2d %8b %8b   %8b %8b\n",
    #   $k, abs($wmin), $wmax, $submax, $submin;
  }
  exit 0;    
}



{
  # width,height extents

  require Math::PlanePath::DragonCurve;
  my $path = Math::PlanePath::DragonCurve->new;

  my @xend = (1);
  my @yend = (0);
  my @xmin = (0);
  my @xmax = (1);
  my @ymin = (0);
  my @ymax = (0);
  extend();
  sub extend {
    my $xend = $xend[-1];
    my $yend = $yend[-1];
    ($xend,$yend) = ($xend-$yend,  # rotate +45
                     $xend+$yend);
    push @xend, $xend;
    push @yend, $yend;
    my $xmax = $xmax[-1];
    my $xmin = $xmin[-1];
    my $ymax = $ymax[-1];
    my $ymin = $ymin[-1];
    ### assert: $xmax >= $xmin
    ### assert: $ymax >= $ymin

    #    ### at: "end=$xend,$yend   $xmin..$xmax  $ymin..$ymax"
    push @xmax, max($xmax, $xend + $ymax);
    push @xmin, min($xmin, $xend + $ymin);

    push @ymax, max($ymax, $yend - $xmin);
    push @ymin, min($ymin, $yend - $xmax);
  }

  my $level = 0;
  my $n_level = 1;
  my $n = 0;
  my $xmin = 0;
  my $xmax = 0;
  my $ymin = 0;
  my $ymax = 0;
  my $prev_r = 1;
  for (;;) {
    my ($x,$y) = $path->n_to_xy($n);
    $xmin = min($xmin,$x);
    $xmax = max($xmax,$x);
    $ymin = min($ymin,$y);
    $ymax = max($ymax,$y);
    if ($n == $n_level) {
      my $width = $xmax - $xmin + 1;
      my $height = $ymax - $ymin + 1;
      my $r = ($width/2)**2 + ($height/2)**2;
      my $rf = $r / $prev_r;
      my $xmin2 = to_bin($xmin);
      my $ymin2 = to_bin($ymin);
      my $xmax2 = to_bin($xmax);
      my $ymax2 = to_bin($ymax);
      my $xrange= sprintf "%9s..%9s", $xmin2, $xmax2;
      my $yrange= sprintf "%9s..%9s", $ymin2, $ymax2;

      printf "%2d n=%-7d %19s   %19s    r=%.2f (%.3f)\n",
        $level, $n, $xrange, $yrange, $r, $rf;

      extend();
      $xrange="$xmin[$level]..$xmax[$level]";
      $yrange="$ymin[$level]..$ymax[$level]";
      # printf "             %9s   %9s\n",
      #   $xrange, $yrange;


      $level++;
      $n_level *= 2;
      $prev_r = $r;
      last if $level > 30;

    }
    $n++;
  }

  exit 0;

  sub to_bin {
    my ($n) = @_;
    return ($n < 0 ? '-' : '') . sprintf('%b', abs($n));
  }
}



{
  # A088431
  require Math::ContinuedFraction;
  require Math::BigInt;
  require Math::BigRat;
  my $half = Math::BigRat->new('1/2');
  my $rat = Math::BigRat->new('1');
  for (my $exp = 1; $exp <= 16; $exp *= 2) {
    $rat += $half ** $exp;
  }
  print "$rat\n";

  my $num = $rat->numerator;
  my $den = $rat->denominator;
  print "num ",$num->as_bin,"\n";
  print "den ",$den->as_bin,"\n";
  my $cf = Math::ContinuedFraction->from_ratio($num,$den);
  my $cfstr = $cf->to_ascii;
  my $cfaref = $cf->to_array;
  my $cflen = scalar(@$cfaref);
  print "$cflen  $cfstr\n";
  $,=',';

  foreach (@$cfaref) { $_ /= 2 }
  print @$cfaref,"\n";
  exit 0;
}

{
  # diagonal

  #
  #                       |---8
  #                       |
  #                       v
  #                       6<--
  #                           |
  #                           |
  #                   0   |---4
  #                   |   |
  #                   |   v
  #                   |-->2
  #
  # new xmax = ymax or -ymin or 2L-xmin
  # new xmin = ymin
  # new ymax = 2L-ymin
  # new ymin = -xmax or -ymax            same

  my $xmax = 1;
  my $xmin = 0;
  my $ymax = 1;
  my $ymin = 0;
  my $len = 1;
  my $exp = 8;
  for (1 .. $exp) {
    printf "%2d %-18s %-18s %-18s %-18s\n",
      $_, to_bin($xmin),to_bin($xmax), to_bin($ymin),to_bin($ymax);
    ($xmax,
     $xmin,
     $ymax,
     $ymin)
      =
        (max($ymax, -$ymin, 2*$len-$xmin),
         min($ymin),
         2*$len-$ymin,
         min(-$xmax,-$ymax));
    ### assert: $xmin <= 0
    ### assert: $ymin <= 0
    ### assert: $xmax >= 0
    ### assert: $ymax >= 0
    $len *= 2;
  }
  print 3*$xmin/$len+.001," / 3\n";
  print 6*$xmax/$len+.001," / 6\n";
  print 3*$ymin/$len+.001," / 3\n";
  print 3*$ymax/$len+.001," / 3\n";
}




{
  # A073089 midpoint vertical/horizontal formula

  require Math::NumSeq::OEIS::File;
  my $A073089 = Math::NumSeq::OEIS::File->new (anum => 'A073089');

  my $A014577 = Math::NumSeq::OEIS::File->new (anum => 'A014577'); # 0=left n=0
  my $A014707 = Math::NumSeq::OEIS::File->new (anum => 'A014707'); # 1=left
  my $A038189 = Math::NumSeq::OEIS::File->new (anum => 'A038189');
  my $A082410 = Math::NumSeq::OEIS::File->new (anum => 'A082410');

  my $A000035 = Math::NumSeq::OEIS::File->new (anum => 'A000035'); # n mod 2

  my $count = 0;
  foreach my $n (0 .. 1000) {
    my $got = $A073089->ith($n) // next;

    # works except for n=1
    # my $turn = $A014707->ith($n-2) // next;
    # my $flip = $A000035->ith($n-2) // next;
    # my $calc = $turn ^ $flip;

    # works
    # my $turn = $A014577->ith($n-2) // next;
    # my $flip = $A000035->ith($n-2) // next;
    # my $calc = $turn ^ $flip ^ 1;

    # so A073089(n) = A082410(n) xor A000035(n) xor 1
    my $turn = $A082410->ith($n) // next;
    my $flip = $A000035->ith($n) // next;
    my $calc = $turn ^ $flip ^ 1;

    if ($got != $calc) {
      print "wrong $n  got=$got calc=$calc\n";
    }
    $count++;
  }
  print "count $count\n";
  exit 0;
}

{
  # doublings
  require Math::PlanePath::DragonCurve;
  require Math::BaseCnv;
  my $path = Math::PlanePath::DragonCurve->new;
  my %seen;
  for (my $n = 0; $n < 2000; $n++) {
    my ($x,$y) = $path->n_to_xy($n);
    my $key = "$x,$y";
    push @{$seen{$key}}, $n;
    if (@{$seen{$key}} == 2) {
      my @v2;
      my $aref = delete $seen{$key};
      my $sum = 0;
      foreach my $v (@$aref) {
        $sum += $v;
        my $v2 = Math::BaseCnv::cnv($v,10,2);
        push @v2, $v2;
        printf "%4s %12s\n", $v, $v2;
      }
      printf "%4s %12b  sum\n", $sum, $sum;

      my $diff = abs($aref->[0]-$aref->[1]);
      printf "%4s %12b  diff\n", $diff, $diff;

      my $lenmatch = 0;
      foreach my $i (1 .. length($v2[0])) {
        my $want = substr ($v2[0], -$i);
        if ($v2[1] =~ /$want$/) {
          next;
        } else {
          $lenmatch = $i-1;
          last;
          last;
        }
      }
      my $zeros = ($v2[0] =~ /(0*)$/ && $1);
      my $lenzeros = length($zeros);
      my $same = ($lenmatch == $lenzeros+2 ? "same" : "diff");
      print "low same $lenmatch zeros $lenzeros   $same\n";

      my $new = $aref->[0];
      my $first_bit = my $bit = 2 * 2**$lenzeros;
      my $change = 0;
      while ($bit <= 2*$aref->[0]) {
        ### $bit
        ### $change
        if ($change) {
          $new ^= $bit;
          $change = ! ($aref->[0] & $bit);
        } else {
          $change = ($aref->[0] & $bit);
        }
        $bit *= 2;
      }
      my $new2 = Math::BaseCnv::cnv($new,10,2);
      if ($new != $aref->[1]) {
        print "flip wrong first $first_bit last $bit to $new $new2\n";
      }
      print "\n";
    }
  }
  exit 0;
}


{
  # DragonMidpoint abs(dY) sequence
  require Math::NumSeq::PlanePathDelta;
  my $seq = Math::NumSeq::PlanePathDelta->new (planepath => 'DragonMidpoint',
                                               delta_type => 'dY');
  foreach (0 .. 64) {
    my ($i,$value) = $seq->next;
    my $p = $i+2;
    # while ($p && ! ($p&1)) {
    #   $p/=2;
    # }
    my $v = calc_n_midpoint_vert($i+1);
    printf "%d %d %7b\n", abs($value), $v, $p;
  }
  exit 0;
}
{
  # DragonMidpoint abs(dY) sequence
  require Math::PlanePath::DragonMidpoint;
  my $path = Math::PlanePath::DragonMidpoint->new;
  foreach my $n (0 .. 64) {
    my ($x,$y) = $path->n_to_xy($n);
    my ($nx,$ny) = $path->n_to_xy($n+1);
    if ($nx == $x) {
      my $p = $n+2;
      # while ($p && ! ($p&1)) {
      #   $p/=2;
      # }
      my $v = calc_n_midpoint_vert($n);
      printf "%d %7b\n", $v, $p;
    }
  }
  exit 0;

  sub calc_n_midpoint_vert {
    my ($n) = @_;
    if ($n < 0) { return 0; }
    my $vert = ($n & 1);
    my $right = calc_n_turn($n);
    return ((($vert && !$right)
             || (!$vert && $right))
            ? 0
            : 1);
  }
  # return 0 for left, 1 for right
  sub calc_n_turn {
    my ($n) = @_;
    my ($mask,$z);
    $mask = $n & -$n;          # lowest 1 bit, 000100..00
    $z = $n & ($mask << 1);    # the bit above it
    my $turn = ($z == 0 ? 0 : 1);
    # printf "%b   %b  %b  %d\n", $n,$mask, $z, $turn;
    return $turn;
  }
}


{
  # xy absolute direction nsew

  require Math::PlanePath::DragonCurve;
  my @array;
  my $arms = 4;
  my $path = Math::PlanePath::DragonCurve->new (arms => $arms);

  my $width = 20;
  my $height = 20;

  my ($n_lo, $n_hi) = $path->rect_to_n_range(0,0,$width+2,$height+2);
  print "n_hi $n_hi\n";
  for my $n (0 .. 20*$n_hi) {
    # next if ($n % 4) == 0;
    # next if ($n % 4) == 1;
    # next if ($n % 4) == 2;
    # next if ($n % 4) == 3;
    my ($x,$y) = $path->n_to_xy($n);
    next if $x < 0 || $y < 0 || $x > $width || $y > $height;

    my ($nx,$ny) = $path->n_to_xy($n+$arms);

    if ($ny == $y+1) {
      $array[$x][$y] .= ($n & 1 ? "n" : "N");
    }
    if ($ny == $y-1) {
      $array[$x][$y] .= ($n & 1 ? "s" : "S");
    }
    # if ($nx == $x+1) {
    #   $array[$x][$y] .= "w";
    # }
    # if ($nx == $x-1) {
    #   $array[$x][$y] .= "e";
    # }
  }
  foreach my $y (reverse 0 .. $height) {
    foreach my $x (0 .. $width) {
      my $v = $array[$x][$y]//'';
      $v = sort_str($v);
      printf "%3s", $v;
    }
    print "\n";
  }

  exit 0;
}

{
  # xy absolute direction
  require Image::Base::Text;
  require Math::PlanePath::DragonCurve;
  my $arms = 1;
  my $path = Math::PlanePath::DragonCurve->new (arms => $arms);

  my $width = 20;
  my $height = 20;
  my $image = Image::Base::Text->new (-width => $width,
                                      -height => $height);

  my ($n_lo, $n_hi) = $path->rect_to_n_range(0,0,$width+2,$height+2);
  print "n_hi $n_hi\n";
  for my $n (0 .. $n_hi) {
    my ($x,$y) = $path->n_to_xy($n);
    next if $x < 0 || $y < 0 || $x >= $width || $y >= $height;

    my ($nx,$ny) = $path->n_to_xy($n+$arms);

    # if ($nx == $x+1) {
    #   $image->xy($x,$y,$n&3);
    # }
    # if ($ny == $y+1) {
    #   $image->xy($x,$y,$n&3);
    # }
    if ($ny == $y+1 || $ny == $y-1) {
      # $image->xy($x,$y,$n&3);
      $image->xy($x,$y,'|');
    }
    if ($nx == $x+1 || $nx == $x-1) {
      # $image->xy($x,$y,$n&3);
      $image->xy($x,$y,'-');
    }
  }
  $image->save('/dev/stdout');

  exit 0;
}


{
  # Rounded and Midpoint equivalence table

  require Math::PlanePath::DragonRounded;
  require Math::PlanePath::DragonMidpoint;

    my @yx_rtom_dx;
    my @yx_rtom_dy;
  foreach my $arms (1 .. 4) {
    ### $arms
    my $rounded = Math::PlanePath::DragonRounded->new (arms => $arms);
    my $midpoint = Math::PlanePath::DragonMidpoint->new (arms => $arms);
    my %seen;
    foreach my $n (0 .. 5000) {
      my ($x,$y) = $rounded->n_to_xy($n) or next;
      my ($mx,$my) = $midpoint->n_to_xy($n);
      my $dx = ($x - floor($x/3)) - $mx;
      my $dy = ($y - floor($y/3)) - $my;

      if (defined $yx_rtom_dx[$y%6][$x%6]
          && $yx_rtom_dx[$y%6][$x%6] != $dx) {
        die "oops";
      }
      if (defined $yx_rtom_dy[$y%6][$x%6]
          && $yx_rtom_dy[$y%6][$x%6] != $dy) {
        die "oops";
      }
      $yx_rtom_dx[$y%6][$x%6] = $dx;
      $yx_rtom_dy[$y%6][$x%6] = $dy;
    }
    print_6x6(\@yx_rtom_dx);
    print_6x6(\@yx_rtom_dy);

    foreach my $n (0 .. 1000) {
      my ($x,$y) = $rounded->n_to_xy($n) or next;

      my $mx = $x-floor($x/3) - $yx_rtom_dx[$y%6][$x%6];
      my $my = $y-floor($y/3) - $yx_rtom_dy[$y%6][$x%6];

      my $m = $midpoint->xy_to_n($mx,$my);

      my $good = (defined $m && $n == $m ? "good" : "bad");

      printf "n=%d xy=%d,%d -> mxy=%d,%d m=%s   %s\n",
        $n, $x,$y,
          $mx,$my, $m//'undef',
            $good;
    }
  }
  exit 0;

  sub print_6x6 {
    my ($aref) = @_;
    foreach my $y (0 .. 5) {
      if ($y == 0) {
        print "[[";
      } else {
        print " [";
      }
      foreach my $x (0 .. 5) {
        my $v = $aref->[$y][$x] // 'undef';
        printf "%5s", $v;
        if ($x != 5) { print ", " }
      }
      if ($y == 5) {
        print "] ]\n";
      } else {
        print "]\n";
      }
    }
  }
}


{
  # Rounded and Midpoint equivalence checks

  require Math::PlanePath::DragonRounded;
  require Math::PlanePath::DragonMidpoint;

  my @yx_rtom_dx;
  my @yx_rtom_dy;
  foreach my $arms (1 .. 4) {
    print "\narms=$arms\n";
    my $rounded = Math::PlanePath::DragonRounded->new (arms => $arms);
    my $midpoint = Math::PlanePath::DragonMidpoint->new (arms => $arms);
    foreach my $y (reverse -10 .. 10) {
      foreach my $x (-7 .. 7) {
        my $d = '';
        my $n = $rounded->xy_to_n($x,$y);
        if (defined $n) {
          my ($mx,$my) = $midpoint->n_to_xy($n);
          my $dx = ($x - floor($x/3)) - $mx;
          my $dy = ($y - floor($y/3)) - $my;
          $d = "$dx,$dy";
        } elsif ($x==0&&$y==0) {
          $d = '+';
        }
        printf "%5s", $d;
      }
      print "\n";
    }
  }

  exit 0;
}

{
  # A059125 "dragon-like"

  require MyOEIS;
  my ($drag_values) = MyOEIS::read_values('A014707');
  my ($like_values) = MyOEIS::read_values('A059125');

  my @diff = map {$drag_values->[$_] == $like_values->[$_] ? '_' : 'x' }
    0 .. 80;

  print @{$drag_values}[0..70],"\n";
  print @{$like_values}[0..70],"\n";
  print @diff[0..70],"\n";
  exit 0;
}

{
  # total turn
  require Math::PlanePath::DragonCurve;

  sub transitions {
    my ($n) = @_;
    my $count = 0;
    while ($n) {
      $count += (($n & 3) == 1 || ($n & 3) == 2);
      $n >>= 1;
    }
    return $count
  }
  sub transitions2 {
    my ($n) = @_;

    my $m = low_ones_mask($n);
    $n ^= $m;  # zap to zeros
    my $count = ($m!=0);

    while ($n) {
      ### assert: ($n&1)==0
      $m = low_zeros_mask($n);
      $n |= $m;  # fill to ones
      $count++;

      $m = low_ones_mask($n);
      $n ^= $m;  # zap to zeros
      $count++;
      last unless $n;
    }
    return $count
  }
  sub transitions3 {
    my ($n) = @_;
    my $count = 0;
    return ones_count($n^($n>>1));
  }
  sub low_zeros_mask {
    my ($n) = @_;
    die if $n == 0;
    return ($n ^ ($n-1)) >> 1;
  }
  ### assert: low_zeros_mask(1)==0
  ### assert: low_zeros_mask(2)==1
  ### assert: low_zeros_mask(3)==0
  ### assert: low_zeros_mask(4)==3
  ### assert: low_zeros_mask(12)==3
  ### assert: low_zeros_mask(10)==1
  sub low_ones_mask {
    my ($n) = @_;
    return ($n ^ ($n+1)) >> 1;
  }
  ### assert: low_ones_mask(1)==1
  ### assert: low_ones_mask(2)==0
  ### assert: low_ones_mask(3)==3
  ### assert: low_ones_mask(5)==1
  sub ones_count {
    my ($n) = @_;
    my $count;
    while ($n) {
      $count += ($n&1);
      $n >>= 1;
    }
    return $count;
  }

  # with Y reckoned increasing upwards
  sub dxdy_to_dir {
    my ($dx, $dy) = @_;
    if ($dx > 0) { return 0; }  # east
    if ($dx < 0) { return 2; }  # west
    if ($dy > 0) { return 1; }  # north
    if ($dy < 0) { return 3; }  # south
  }

  sub path_n_dir {
    my ($path, $n) = @_;
    return dxdy_to_dir ($path->n_to_xy($n+1));
  }

  # return 1 for left, -1 for right
  sub path_n_turn {
    my ($path, $n) = @_;
    my $prev_dir = path_n_dir ($path, $n-1);
    my $dir = path_n_dir ($path, $n);
    my $turn = ($dir - $prev_dir) % 4;
    if ($turn == 1) { return 1; }
    if ($turn == 3) { return -1; }
    die "Oops, unrecognised turn";
  }

  my $path = Math::PlanePath::DragonCurve->new;
  my $total_turn = 0;
  for (my $n = 0; $n < 16; ) {
    my $t = transitions($n);
    my $t2 = transitions2($n);
    my $t3 = transitions3($n);
    my $good = ($t == $t2 && $t2 == $t3 && $t == $total_turn
                ? 'good'
                : '');
    printf "%2d %d  %d,%d,%d   %s\n", $n, $total_turn, $t,$t2,$t3, $good;

    $n++;
    my $turn = path_n_turn($path,$n);
    $total_turn += $turn;
  }
  exit 0;
}


{
  # Curve xy to n by midpoint
  require Math::PlanePath::DragonCurve;
  require Math::PlanePath::DragonMidpoint;
  require Math::BaseCnv;

  foreach my $arms (3) {
    ### $arms
    my $curve = Math::PlanePath::DragonCurve->new (arms => $arms);
    my $midpoint = Math::PlanePath::DragonMidpoint->new (arms => $arms);
    my %seen;
    for (my $n = 0; $n < 50; $n++) {
      my ($x,$y) = $curve->n_to_xy($n);

      my $list = '';
      my $found = '';
    DX: foreach my $dx (-1,0) {
        foreach my $dy (0,1) {
          # my ($x,$y) = ($x-$y,$x+$y); # rotate +45 and mul sqrt(2)
          my ($x,$y) = ($x+$y,$y-$x); # rotate -45 and mul sqrt(2)
          my $m = $midpoint->xy_to_n($x+$dx,$y+$dy) // next;
          $list .= " $m";
          if ($m == $n) {
            $found = "$dx,$dy";
            # last DX;
          }
        }
      }
      printf "n=%d xy=%d,%d got  %s   %s\n",
        $n,$x,$y,
          $found, $list;
      $seen{$found} = 1;
    }
    $,=' ';
    print sort keys %seen,"\n";
  }
  exit 0;

  # (x+iy)*(i+1) = (x-y)+(x+y)i   # +45
  # (x+iy)*(-i+1) = (x+y)+(y-x)i  # -45
}


{
  # x axis absolute direction
  require Math::PlanePath::DragonCurve;
  my $path = Math::PlanePath::DragonCurve->new (arms => 4);

  my $width = 30;
  my ($n_lo, $n_hi) = $path->rect_to_n_range(0,0,$width+2,0);
  my (@enter, @leave);
  print "n_hi $n_hi\n";
  for my $n (0 .. $n_hi) {
    my ($x,$y) = $path->n_to_xy($n);

    if ($y == 0 && $x >= 0) {
      {
        my ($nx,$ny) = $path->n_to_xy($n+4);
        if ($ny > $y) {
          $leave[$x] .= 'u';
        }
        if ($ny < $y) {
          $leave[$x] .= 'd';
        }
        if ($nx > $x) {
          $leave[$x] .= 'r';
        }
        if ($nx < $x) {
          $leave[$x] .= 'l';
        }
      }
      if ($n >= 4) {
        my ($px,$py) = $path->n_to_xy($n-4);
        if ($y > $py) {
          $enter[$x] .= 'u';
        }
        if ($y < $py) {
          $enter[$x] .= 'd';
        }
        if ($x > $px) {
          $enter[$x] .= 'r';
        }
        if ($x < $px) {
          $enter[$x] .= 'l';
        }
      }
    }
  }
  foreach my $x (0 .. $width) {
    print "$x  ",sort_str($enter[$x]),"  ",sort_str($leave[$x]),"\n";
  }

  sub sort_str {
    my ($str) = @_;
    if (! defined $str) {
      return '-';
    }
    return join ('', sort split //, $str);

  }
  exit 0;
}


{
  # Midpoint xy to n
  require Math::PlanePath::DragonMidpoint;
  require Math::BaseCnv;

  my @yx_adj_x = ([0,1,1,0],
                  [1,0,0,1],
                  [1,0,0,1],
                  [0,1,1,0]);
  my @yx_adj_y = ([0,0,1,1],
                  [0,0,1,1],
                  [1,1,0,0],
                  [1,1,0,0]);
  sub xy_to_n {
    my ($self, $x,$y) = @_;

    my $n = ($x * 0 * $y) + 0; # inherit bignum 0
    my $npow = $n + 1;         # inherit bignum 1

    while (($x != 0 && $x != -1) || ($y != 0 && $y != 1)) {

      # my $ax = ((($x+1) ^ ($y+1)) >> 1) & 1;
      # my $ay = (($x^$y) >> 1) & 1;
      # ### assert: $ax == - $yx_adj_x[$y%4]->[$x%4]
      # ### assert: $ay == - $yx_adj_y[$y%4]->[$x%4]

      my $y4 = $y % 4;
      my $x4 = $x % 4;
      my $ax = $yx_adj_x[$y4]->[$x4];
      my $ay = $yx_adj_y[$y4]->[$x4];

      ### at: "$x,$y  n=$n  axy=$ax,$ay  bit=".($ax^$ay)

      if ($ax^$ay) {
        $n += $npow;
      }
      $npow *= 2;

      $x -= $ax;
      $y -= $ay;
      ### assert: ($x+$y)%2 == 0
      ($x,$y) = (($x+$y)/2,   # rotate -45 and divide sqrt(2)
                 ($y-$x)/2);
    }

    ### final: "xy=$x,$y"
    my $arm;
    if ($x == 0) {
      if ($y) {
        $arm = 1;
        ### flip ...
        $n = $npow-1-$n;
      } else { #  $y == 1
        $arm = 0;
      }
    } else { # $x == -1
      if ($y) {
        $arm = 2;
      } else {
        $arm = 3;
        ### flip ...
        $n = $npow-1-$n;
      }
    }
    ### $arm

    my $arms_count = $self->arms_count;
    if ($arm > $arms_count) {
      return undef;
    }
    return $n * $arms_count + $arm;
  }

  foreach my $arms (4,3,1,2) {
    ### $arms

    my $path = Math::PlanePath::DragonMidpoint->new (arms => $arms);
    for (my $n = 0; $n < 50; $n++) {
      my ($x,$y) = $path->n_to_xy($n)
        or next;

      my $rn = xy_to_n($path,$x,$y);

      my $good = '';
      if (defined $rn && $rn == $n) {
        $good .= "good N";
      }

      my $n2 = Math::BaseCnv::cnv($n,10,2);
      my $rn2 = Math::BaseCnv::cnv($rn,10,2);
      printf "n=%d xy=%d,%d got rn=%d    %s\n",
        $n,$x,$y,
          $rn,
            $good;
    }
  }
  exit 0;
}
{
  # xy modulus
  require Math::PlanePath::DragonMidpoint;
  my $path = Math::PlanePath::DragonMidpoint->new;
  my %seen;
  for (my $n = 0; $n < 1024; $n++) {
    my ($x,$y) = $path->n_to_xy($n)
      or next;
    my $k = ($x+$y) & 15;
    # $x &= 3; $y &= 3; $k = "$x,$y";
    $seen{$k} = 1;
  }
  ### %seen
  exit 0;
}

{
  # arm xy modulus
  require Math::PlanePath::DragonMidpoint;
  my $path = Math::PlanePath::DragonMidpoint->new (arms => 4);

  my %seen;
  for (my $n = 0; $n < 1024; $n++) {
    my ($x,$y) = $path->n_to_xy($n)
      or next;
    $x &= 3;
    $y &= 3;
    $seen{$n&3}->{"$x,$y"} = 1;
  }

  ### %seen
  exit 0;
}

{
  # xy to n
  require Math::PlanePath::DragonMidpoint;
  require Math::BaseCnv;

  my @yx_adj_x = ([0,-1,-1,0],
                  [-1,0,0,-1],
                  [-1,0,0,-1],
                  [0,-1,-1,0]);
  my @yx_adj_y = ([0,0,-1,-1],
                  [0,0,-1,-1],
                  [-1,-1,0,0],
                  [-1,-1,0,0]);
  my $path = Math::PlanePath::DragonMidpoint->new (); # (arms => 4);
  for (my $n = 0; $n < 50; $n++) {
    my ($x,$y) = $path->n_to_xy($n)
      or next;

    ($x,$y) = (-$y,$x+1); # rotate +90
    # ($x,$y) = (-$x-1,-$y+1); # rotate 180

    # my $rot = 1;
    # if ($rot & 2) {
    #   $x -= 1;
    # }
    # if (($rot+1) & 2) {
    #   # rot 1 or 2
    #   $y += 1;
    # }

    ### xy: "$n   $x,$y  adj ".$yx_adj_x[$y&3]->[$x&3]." ".$yx_adj_y[$y&3]->[$x&3]

    my $rx = $x;
    my $ry = $y;
    # if (((($x+1)>>1)&1) ^ ((($y-1)&2))) {
    #   $rx--;
    # }
    # if (((($x-1)>>1)&1) ^ ((($y+1)&2))) {
    #   $ry--;
    # }

    my $ax = ((($x+1) ^ ($y+1)) >> 1) & 1;
    my $ay = (($x^$y) >> 1) & 1;
    ### assert: $ax == - $yx_adj_x[$y&3]->[$x&3]
    ### assert: $ay == - $yx_adj_y[$y&3]->[$x&3]

    # $rx += $yx_adj_x[$y&3]->[$x&3];
    # $ry += $yx_adj_y[$y&3]->[$x&3];
    $rx -= $ax;
    $ry -= $ay;

    ($rx,$ry) = (($rx+$ry)/2,
                 ($ry-$rx)/2);
    ### assert: $rx == int($rx)
    ### assert: $ry == int($ry)

    # my $arm = $n & 3;
    # my $nbit = ($path->arms_count == 4 ? ($n>>2)&1 : $n&1);
    # my $bit = $ax ^ $ay ^ ($arm&0) ^ (($arm>>1)&1);

    my $nbit = $n&1;
    my $bit = $ax ^ $ay;

    my $rn = $path->xy_to_n($ry-1,-$rx); # rotate -90
    # my $rn = $path->xy_to_n(-$rx-1,-$ry+1); # rotate 180

    my $good = '';
    if (defined $rn && $rn == int($n/2)) {
      $good .= "good N";
    }
    if ($nbit == $bit) {
      $good .= "  good bit";
    }

    my $n2 = Math::BaseCnv::cnv($n,10,2);
    my $rn2 = Math::BaseCnv::cnv($rn,10,2);
    printf "%d %d (%8s %8s) bit=%d,%d  %d,%d  %s\n",
      $n,$rn, $n2,$rn2,
        $nbit,$bit,
          $x,$y, $good;
  }
  exit 0;
}

{
  require Image::Base::Text;
  my $width = 79;
  my $height = 50;
  my $ox = $width/2;
  my $oy = $height/2;
  my $image = Image::Base::Text->new (-width => $width,
                                      -height => $height);
  require Math::PlanePath::DragonCurve;
  my $path = Math::PlanePath::DragonCurve->new;
  my $store = sub {
    my ($x,$y,$c) = @_;
    # $x *= 2;
    # $y *= 2;
    $x += $ox;
    $y += $oy;
    if ($x >= 0 && $y >= 0 && $x < $width && $y < $height) {
      my $o = $image->xy($x,$y);
      # if (defined $o && $o ne ' ' && $o ne $c) {
      #   $c = '*';
      # }
      $image->xy($x,$y,$c);
    } else {
      die "$x,$y";
    }
  };
  my ($x,$y);
  for my $n (0 .. 2**8) {
    ($x,$y) = $path->n_to_xy($n);

    # # (x+iy)/(i+1) = (x+iy)*(i-1)/2 = (-x-y)/2 + (x-y)/2
    # if (($x+$y) % 2) { $x--; }
    # ($x,$y) = ((-$x-$y)/2,
    #            ($x-$y)/2);
    #
    # # (x+iy)/(i+1) = (x+iy)*(i-1)/2 = (-x-y)/2 + (x-y)/2
    # if (($x+$y) % 2) { $x--; }
    # ($x,$y) = ((-$x-$y)/2,
    #            ($x-$y)/2);

    # ($x,$y) = (-$y,$x); # rotate +90

    $y = -$y;
    $store->($x,$y,'*');
  }
  $store->($x,$y,'+');
  $store->(0,0,'o');
  $image->save('/dev/stdout');
  exit 0;
}

{
  # vs ComplexPlus
  require Math::PlanePath::DragonCurve;
  require Math::PlanePath::ComplexPlus;
  require Math::BaseCnv;
  my $dragon = Math::PlanePath::DragonCurve->new;
  my $complex = Math::PlanePath::ComplexPlus->new;
  for (my $n = 0; $n < 50; $n++) {
    my ($x,$y) = $dragon->n_to_xy($n)
      or next;
    my $cn = $complex->xy_to_n($x,$y);
    my $n2 = Math::BaseCnv::cnv($n,10,2);
    my $cn2 = (defined $cn ? Math::BaseCnv::cnv($cn,10,2) : 'undef');
    printf "%8s %8s  %d,%d\n", $n2, $cn2, $x,$y;
  }
  exit 0;
}




{
  # turn
  require Math::PlanePath::DragonCurve;
  my $path = Math::PlanePath::DragonCurve->new;

   my $n = $path->n_start;
  my ($n0_x, $n0_y) = $path->n_to_xy ($n);
  $n++;
  my ($prev_x, $prev_y) = $path->n_to_xy ($n);
  my ($prev_dx, $prev_dy) = ($prev_x - $n0_x, $prev_y - $n0_y);
  $n++;

  my $pow = 4;
  for ( ; $n < 128; $n++) {
    my ($x, $y) = $path->n_to_xy ($n);
    my $dx = ($x - $prev_x);
    my $dy = ($y - $prev_y);
    my $turn;
    if ($prev_dx) {
      if ($dy == $prev_dx) {
        $turn = 0;  # left
      } else {
        $turn = 1;  # right
      }
    } else {
      if ($dx == $prev_dy) {
        $turn = 1;  # right
      } else {
        $turn = 0;  # left
      }
    }
    ($prev_dx,$prev_dy) = ($dx,$dy);
    ($prev_x,$prev_y) = ($x,$y);

    print "$turn";
    if ($n-1 == $pow) {
      $pow *= 2;
      print "\n";
    }
  }
  print "\n";
  exit 0;
}

{
  # turn
  require Math::PlanePath::DragonCurve;
  my $path = Math::PlanePath::DragonCurve->new;

  my $n = 0;
  my ($n0_x, $n0_y) = $path->n_to_xy ($n);
  $n++;
  my ($prev_x, $prev_y) = $path->n_to_xy ($n);
  my ($prev_dx, $prev_dy) = ($prev_x - $n0_x, $prev_y - $n0_y);
  $n++;

  for ( ; $n < 40; $n++) {
    my ($x, $y) = $path->n_to_xy ($n);
    my $dx = ($x - $prev_x);
    my $dy = ($y - $prev_y);

    my $turn;
    if ($prev_dx) {
      if ($dy == $prev_dx) {
        $turn = 0;  # left
      } else {
        $turn = 1;  # right
      }
    } else {
      if ($dx == $prev_dy) {
        $turn = 1;  # right
      } else {
        $turn = 0;  # left
      }
    }
    ### $n
    ### $prev_dx
    ### $prev_dy
    ### $dx
    ### $dy
    # ### is: "$got[-1]   at idx $#got"

    ($prev_dx,$prev_dy) = ($dx,$dy);
    ($prev_x,$prev_y) = ($x,$y);

    my $zero = bit_above_lowest_zero($n-1);
    my $one  = bit_above_lowest_one($n-1);
    print "$n $turn   $one $zero\n";
    # if ($turn != $bit) {
    #   die "n=$n got $turn bit $bit\n";
    # }
  }
  print "n=$n ok\n";

  sub bit_above_lowest_zero {
    my ($n) = @_;
    for (;;) {
      if (($n % 2) == 0) {
        last;
      }
    $n = int($n/2);
    }
    $n = int($n/2);
    return ($n % 2);
  }
  sub bit_above_lowest_one {
    my ($n) = @_;
    for (;;) {
      if (! $n || ($n % 2) != 0) {
        last;
      }
      $n = int($n/2);
    }
    $n = int($n/2);
    return ($n % 2);
  }

  exit 0;
}

{
  # BigFloat log()
  use Math::BigFloat;
  my $b = Math::BigFloat->new(3)**64;
  my $log = log($b);
  my $log3 = $log/log(3);
  # $b->blog(undef,100);
  print "$b\n$log\n$log3\n";
  exit 0;
}
{
  # BigInt log()
  use Math::BigInt;
  use Math::BigFloat;
  my $b = Math::BigInt->new(1025);
  my $log = log($b);
  $b->blog(undef,100);
  print "$b $log\n";
  exit 0;
}

{
  require Image::Base::Text;
  my $width = 132;
  my $height = 50;
  my $ox = $width/2;
  my $oy = $height/2;
  my $image = Image::Base::Text->new (-width => $width, -height => $height);
  require Math::PlanePath::DragonCurve;
  my $path = Math::PlanePath::DragonCurve->new;
  my $store = sub {
    my ($x,$y,$c) = @_;
    $x *= 2;
    $x += $ox;
    $y += $oy;
    if ($x >= 0 && $y >= 0 && $x < $width && $y < $height) {
      my $o = $image->xy($x,$y);
      # if (defined $o && $o ne ' ' && $o ne $c) {
      #   $c = '*';
      # }
      $image->xy($x,$y,$c);
    } else {
      die "$x,$y";
    }
  };
  my ($x,$y);
  for my $n (0 .. 2**9) {
    ($x,$y) = $path->n_to_xy($n);
    $y = -$y;
    $store->($x,$y,'*');
  }
  $store->($x,$y,'+');
  $store->(0,0,'+');
  $image->save('/dev/stdout');
  exit 0;
}

{
  # Midpoint fracs
  require Math::PlanePath::DragonMidpoint;
  my $path = Math::PlanePath::DragonMidpoint->new;
  for my $n (0 .. 64) {
    my $frac = .125;
    my ($x1,$y1) = $path->n_to_xy($n);
    my ($x2,$y2) = $path->n_to_xy($n+1);
    my ($x,$y) = $path->n_to_xy($n+$frac);
    my $dx = $x2-$x1;
    my $dy = $y2-$y1;
    my $xm = $x1 + $frac*$dx;
    my $ym = $y1 + $frac*$dy;
    my $wrong = '';
    if ($x != $xm) {
      $wrong .= " X";
    }
    if ($y != $ym) {
      $wrong .= " Y";
    }
    print "$n   $dx,$dy    $x, $y  want $xm, $ym     $wrong\n"
  }
  exit 0;
}

{
  # min/max for level
  require Math::PlanePath::DragonRounded;
  my $path = Math::PlanePath::DragonRounded->new;
  my $prev_min = 1;
  my $prev_max = 1;
  for (my $level = 1; $level < 25; $level++) {
    my $n_start = 2**($level-1);
    my $n_end = 2**$level;

    my $min_hypot = 128*$n_end*$n_end;
    my $min_x = 0;
    my $min_y = 0;
    my $min_pos = '';

    my $max_hypot = 0;
    my $max_x = 0;
    my $max_y = 0;
    my $max_pos = '';

    print "level $level  n=$n_start .. $n_end\n";

    foreach my $n ($n_start .. $n_end) {
      my ($x,$y) = $path->n_to_xy($n);
      my $h = $x*$x + $y*$y;

      if ($h < $min_hypot) {
        $min_hypot = $h;
        $min_pos = "$x,$y";
      }
      if ($h > $max_hypot) {
        $max_hypot = $h;
        $max_pos = "$x,$y";
      }
    }
    # print "  min $min_hypot   at $min_x,$min_y\n";
    # print "  max $max_hypot   at $max_x,$max_y\n";
    {
      my $factor = $min_hypot / $prev_min;
      print "  min r^2 $min_hypot 0b".sprintf('%b',$min_hypot)."   at $min_pos  factor $factor\n";
    }
    {
      my $factor = $max_hypot / $prev_max;
      print "  max r^2 $max_hypot 0b".sprintf('%b',$max_hypot)."   at $max_pos  factor $factor\n";
    }
    $prev_min = $min_hypot;
    $prev_max = $max_hypot;
  }
  exit 0;
}

{
  # points N=2^level
  require Math::PlanePath::DragonRounded;
  my $path = Math::PlanePath::DragonRounded->new;
  for my $n (0 .. 50) {
    my ($x,$y) = $path->n_to_xy($n);
    my ($x2,$y2) = $path->n_to_xy($n+1);
    my $dx = $x2 - $x;
    my $dy = $y2 - $y;

    my ($xm,$ym) = $path->n_to_xy($n+.5);

    # my $dir = 0;
    # for (my $bit = 1; ; ) {
    #   $dir += ((($n ^ ($n>>1)) & $bit) != 0);
    #   $bit <<= 1;
    #   last if $bit > $n;
    #   # $dir += 1;
    # }
    # $dir %= 4;
    $x += $dx/2;
    $y += $dy/2;
    print "$n  $x,$y   $xm,$ym\n";
  }
  exit 0;
}

{
  # reverse checking
  require Math::PlanePath::DragonRounded;
  my $path = Math::PlanePath::DragonRounded->new;
  for my $n (1 .. 50000) {
    my ($x,$y) = $path->n_to_xy($n);
    my $rev = $path->xy_to_n($x,$y);
    if (! defined $rev || $rev != $n) {
      if (! defined $rev) { $rev = 'undef'; }
      print "$n  $x,$y   $rev\n";
    }
  }
  exit 0;
}

{
  require Image::Base::Text;
  my $width = 78;
  my $height = 40;
  my $ox = $width/2;
  my $oy = $height/2;
  my $image = Image::Base::Text->new (-width => $width, -height => $height);
  require Math::PlanePath::DragonCurve;
  my $path = Math::PlanePath::DragonCurve->new;
  my $store = sub {
    my ($x,$y,$c) = @_;
    $x *= 2;
    $x += $ox;
    $y += $oy;
    if ($x >= 0 && $y >= 0 && $x < $width && $y < $height) {
      my $o = $image->xy($x,$y);
      if (defined $o && $o ne ' ' && $o ne $c) {
        $c = '.';
      }
      $image->xy($x,$y,$c);
    }
  };
  for my $n (0 .. 16*256) {
    my ($x,$y) = $path->n_to_xy($n);
    $y = -$y;
    {
      $store->($x,$y,'a');
    }
    {
      $store->(-$y,$x,'b');
    }
    {
      $store->(-$x,-$y,'c');
    }
    {
      $store->($y,-$x,'d');
    }
  }
  $image->xy($ox,$oy,'+');
  $image->save('/dev/stdout');
  exit 0;
}

{
  # points N=2^level
  require Math::PlanePath::DragonCurve;
  my $path = Math::PlanePath::DragonCurve->new;
  for my $level (0 .. 50) {
    my $n = 2**$level;
    my ($x,$y) = $path->n_to_xy($n);
    print "$level  $n  $x,$y\n";
  }
  exit 0;
}

{
  # sx,sy
  my $sx = 1;
  my $sy = 0;
  for my $level (0 .. 50) {
    print "$level  $sx,$sy\n";
    ($sx,$sy) = ($sx - $sy,
                 $sy + $sx);
  }
  exit 0;
}
