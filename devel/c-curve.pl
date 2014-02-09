#!/usr/bin/perl -w

# Copyright 2011, 2012, 2013, 2014 Kevin Ryde

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
use List::Util 'min','max';
use Math::PlanePath::CCurve;
use List::Pairwise;
use lib 'xt';
use Math::PlanePath::Base::Digits
  'digit_join_lowtohigh';

# uncomment this to run the ### lines
# use Smart::Comments;


{
  # right outer boundary

=pod

=head2 Right Boundary

The boundary on the right of the curve, which is the outside of the "C",
from N=0 to N=2^k is

    right[k] = /  7*2^h - 2k - 6     if k even
               \ 10*2^h - 2k - 6     if k odd
                     where h = floor(k/2)
             = 1, 2, 4, 8, 14, 24, 38, 60, 90, 136, 198, 292, 418, ...

The length doubles until right[4]=14 which is N=0 to N=16 shown above.  At
that level points N=7,8,9 have closed off some of the curve and so the
boundary is shorter.


The right boundary comprises runs of straight lines and zig-zags.  The
straight lines all point "forward" which is anti-clockwise.  They expand on
the right of each segment to become zigzags.

                                  *     *     *
                           =>    / ^   / ^   / ^
                                v   \ v   \ v   \
     D<----C<----B<----A       D     C     B     A
     |                 ^      /                   ^
     v                 |     v                     \

The zigzags are likewise all segments pointing "forward" which is
anti-clockwise.  They expand to close off the V shape and become straight
lines.

        *     *     *           *<----*<----*<----*
       / ^   / ^   / ^     =>   |     |     |     |
      v   \ v   \ v   \         |     |     |     |
     D     C     B     A        D     C     B     A
    /                   ^
   v                     \


                               *     *
                              / ^   / ^       S -> Zr + Zl
                             v   \ v   \
      <----A<----  expands        A

                                   ^
                                    \         Zr -> S
                                     *
           ^                        / ^
           |                       /   \
           A<----  expands        A 


           A<---                    /^
           |                       /  \       Zl -> S + Zl
           v       expands        A    \
                                 /
                                V
                               *
                                \             Zr+Zl -> 2S + Zl
                                 v                   


Let S[k] be the number of straight lines and Z[k] the number of zig-zags
from N=0 to N=2^k.  The zigzags are counted as a "V" notch inwards.  Then

    Z[k] = 2*S[k-1] + k
    S[k] =   Z[k-1]

    S[k] = 2*S[k-2] + k-1
    S[0] = 0
    S[1] = 0

    Z[k] = 2*Z[k-2] + k
    Z[0] = 0
    Z[1] = 1

    right[k] = S[k] + Z[k] + 1
               = 2*S[k-2] + k-1 + 2*Z[k-2] + k + 1
               = 2*(S[k-2] + Z[k-2] + 1) - 2 + k-1 + k + 1
               = 2*right[k-2] + 2k-2

    right[2] =  2 + 2*(1) = 4
    right[4] =  6 + 2*(2 + 2*(1)) = 14
    right[6] = 10 + 2*(6 + 2*(2 + 2*(1))) = 38

even
right[k] = 2k-2 + 2*right[k-2]
         = 2k-2 + 2*(2k-4) + 2^2*(2k-6) + ... + 2^h*2 + 2^(h+1)

                  i=k/2-1
         = 2^h + sum        (2k-2 - 4i)*2^i
                  i=0

                                       i=h-1
         = 2^h + (2k-2)*(2^h-1) - 4 * sum    i*2^i
                                       i=0
         = 2^h + (2k-2)*2^h - (2k-2)
         = (2k-1)*2^h - 2k + 2

2^1 + 2*2^2 + 3*2^3 + ... + t*2^t
  = 2^(t+1)-1 + 2*(2^t-1) + 4*(2^(t-1)-1) + ... + 1*2^t
  = t*2^(t+1) - (1 + 2 + ... + 2^(t-1)t)
  = (t-1)*2^(t+1)+2
2+2*4+3*8+4*16+5*32 = 258  t=5
2+2*4+3*8+4*16+5*32+6*64 = 642  t=6

         = (2k-1)*2^h - 2k + 2 - 4*( (h-1-1)*2^(h-1+1) + 2 )
         = (2k-1)*2^h - 2k + 2 - 4*( (h-2)*2^h + 2 )
         = (2k-1)*2^h - 2k + 2 - 4*(h-2)*2^h - 8
         = (4h-1 - 4*(h-2)*2^h - 2k + 2 - 8
         = (4h-1 - 4h + 8)*2^h - 2k - 6
         = 7*2^h - 4h - 6

odd
h = (k-1)/2   k=2h+1
right[k] = 2k-2 + 2*right[k-2]
         = 2k-2 + 2*(2k-4) + 2^2*(2k-6) + ... + 2^(h-1)*4   + 2^h*2
stop at k=3 is 2k-2=4
2k-2 - 4i = 4
4i = 2k-6
4i = 2(2h+1)-6
   = 4h+2-6 = 4h-4
i=h-1

                    i=h-1
         = 2^h*2 + sum     (2k-2 - 4i)*2^i
                    i=0

                                         i=h-1
         = 2*2^h + (2k-2)*(2^h-1) - 4 * sum    i*2^i
                                         i=0

         = 2*2^h + (2k-2)*(2^h-1) - 4*(h-2)*2^h - 8
         = (2 + 2k-2 - 4*(h-2))*2^h - (2k-2) - 8
         = (2 + 2k-2 - 4h + 8))*2^h - (2k-2) - 8
         = (2 + 4h+2-2 - 4h + 8)*2^h - (2k-2) - 8
         = (2  + 8)*2^h - (4h+2-2) - 8
         = 10*2^h - 4h - 8

j = (k+1)/2 = h+1   h = j-1
right[k] = 10*2^(j-1) - 4(j-1) - 8
         = 5*2^j) - 4j+4 - 8
         = 5*2^j - 4j - 4
=cut

  my $R_formula = sub {
    my ($k) = @_;
    if ($k & 1) {
      my $h = ($k-1)/2;
      my $j = ($k+1)/2;
      return 10*2**$h - 2*$k - 6;  # yes
      return 5*2**$j - 4*$j - 4;  # yes
      return 10*2**$h - 4*$h - 8;  # yes
      return 2*2**$h + (2*$k-2)*(2**$h-1) - 4*($h-2)*2**$h - 8;  # yes

      {
        my $r = 0;
        foreach my $i (1 .. $h-1) {      # yes
          $r += $i * 2**$i;
        }
        return 2*2**$h + (2*$k-2)*(2**$h-1)  - 4*$r;
      }
      {
        my $r = 0;
        foreach my $i (0 .. $h-1) {
          $r += (2*$k-2 - 4*$i) * 2**$i;
        }
        return 2*2**$h + $r
      }
      {
        my $r = 0;
        my $pow = 1;
        while ($k >= 3) {
          ### t: 2*$k-2
          $r += (2*$k-2) * $pow;
          $pow *= 2;
          $k -= 2;
        }
        return $r + 2*$pow;
      }
    } else {
      my $h = $k/2;

      {
        return 7*2**$h - 2*$k - 6;  # yes
        return 7*2**$h - 4*$h - 6;  # yes
        return (2*$k-1) * 2**$h - 2*$k + 2 - 4*(($h-1-1)*2**($h-1+1) + 2);
      }
      {
        # right[k] = 2k-2 + 2*right[k-2]      termwise, yes
        my $r = 0;
        foreach my $i (0 .. $h-1) {
          $r += $i*2**$i;
        }
        return (2*$k-1) * 2**$h - 2*$k + 2 - 4*$r;
      }
      {
        # right[k] = 2k-2 + 2*right[k-2]      termwise, yes
        my $r = 0;
        my $pow = 1;
        while ($k > 0) {
          $r += (2*$k-2) * $pow;
          $pow *= 2;
          $k -= 2;
        }
        return $r + $pow;
      }
      return ($h-2) *2**$h;
    }
  };

  my ($S_recurrence, $Z_recurrence, $R_recurrence);
  $S_recurrence = sub {
    my ($k) = @_;
    if ($k == 0) { return 0; }
    if ($k == 1) { return 0; }
    return 2*$S_recurrence->($k-2) + $k-1;  # yes
    return $Z_recurrence->($k-1);           # yes
  };
  $Z_recurrence = sub {
    my ($k) = @_;
    if ($k == 0) { return 0; }
    if ($k == 1) { return 1; }
    return 2*$Z_recurrence->($k-2) + $k; # yes
    return 2*$S_recurrence->($k-1) + $k; # yes
  };
  $R_recurrence = sub {
    my ($k) = @_;
    if ($k == 0) { return 1; }
    if ($k == 1) { return 2; }
    return 2*$R_recurrence->($k-2) + 2*$k-2;
  };

  for (my $k = 0; $k < 15; $k++) {
    print $R_formula->($k),", ";
  }
  print "\n";

  require MyOEIS;
  my $path = Math::PlanePath::CCurve->new;
  foreach my $k (0 .. 17) {
    my $n_end = 2**$k;
    my $p = MyOEIS::path_boundary_length($path, $n_end, side => 'right');
    # my $b = $B->($k);
    my $srec = $S_recurrence->($k);
    my $zrec = $Z_recurrence->($k);
    my $rszrec = $srec + $zrec + 1;
    my $rrec = $R_recurrence->($k);
    # my $t = $T->($k);
    # my $u = $U->($k);
    # my $u2 = $U2->($k);
    # my $u_lr = $U_from_LsubR->($k);
    # my $v = $V->($k);
    my ($s, $z) = path_S_and_Z($path, $n_end);
    my $r = $s + $z + 1;
    my $rformula = $R_formula->($k);
    my $drformula = $r - $rformula;
    # next unless $k & 1;
    print "$k $p  $s $z $r   $srec $zrec $rszrec $rrec $rformula  small by=$drformula\n";
  }
  exit 0;

  sub path_S_and_Z {
    my ($path, $n_end) = @_;
    ### path_S_and_Z(): $n_end
    my $s = 0;
    my $z = 0;
    my $x = 1;
    my $y = 0;
    my ($dx,$dy) = (1,0);
    my ($target_x,$target_y) = $path->n_to_xy($n_end);
    until ($x == $target_x && $y == $target_y) {
      ### at: "$x, $y  $dx,$dy"
      ($dx,$dy) = ($dy,-$dx); # rotate -90
      if (path_xy_is_visited_within ($path, $x+$dx,$y+$dy, $n_end)) {
        $z++;
      } else {
        ($dx,$dy) = (-$dy,$dx); # rotate +90
        if (path_xy_is_visited_within ($path, $x+$dx,$y+$dy, $n_end)) {
          $s++;
        } else {
          ($dx,$dy) = (-$dy,$dx); # rotate +90
          $z++;
          path_xy_is_visited_within ($path, $x+$dx,$y+$dy, $n_end) or die;
        }
      }
      $x += $dx;
      $y += $dy;
    }
    return ($s, $z);
  }
  sub path_xy_is_visited_within {
    my ($path, $x,$y, $n_end) = @_;
    my @n_list = $path->xy_to_n_list($x,$y);
    foreach my $n (@n_list) {
      if ($n <= $n_end) {
        return 1;
      }
    }
    return 0;
  }
}
{
  # X,Y extents at 4^k
  my $path = Math::PlanePath::CCurve->new;
  my $x_min = 0;
  my $y_min = 0;
  my $x_max = 0;
  my $y_max = 0;
  my $target = 2;
  my @w_max;
  my @w_min;
  my @h_max;
  my @h_min;
  my $rot = 3;
  foreach my $n (0 .. 2**16) {
    my ($x,$y) = $path->n_to_xy ($n);
    $x_min = min($x+$y,$x_min);
    $x_max = max($x+$y,$x_max);
    $y_min = min($y-$x,$y_min);
    $y_max = max($y-$x,$y_max);

    if ($n == $target) {
      my $w_min = $x_min;
      my $w_max = $x_max;
      my $h_min = $y_min;
      my $h_max = $y_max;
      foreach (1 .. $rot) {
        ($w_max,$w_min, $h_max,$h_min) = ($h_max,$h_min,  -$w_min,-$w_max);
      }
      push @w_min, $w_min;
      push @h_min, $h_min;
      push @w_max, $w_max;
      push @h_max, $y_max;

      if (1) {
        printf "xy=%9b,%9b  w -%9b to %9b   h -%9b to %9b\n",
          abs($x),abs($y), abs($w_min),$w_max, abs($h_min),$h_max;
      }
      print "xy=$x,$y  w $w_min to $w_max   h $h_min to $h_max\n";
      # print "xy=$x,$y  x $x_min to $x_max   y $y_min to $y_max\n\n";
      $target *= 4;
      $rot++;
    }
  }

  require MyOEIS;
  # print MyOEIS->grep_for_values(array => \@w_min, name => "w_min");
  # print MyOEIS->grep_for_values(array => \@h_min);
  # print MyOEIS->grep_for_values(array => \@w_max);
  shift @h_max;
  shift @h_max;
  print MyOEIS->grep_for_values(array => \@h_max, name => "h_max");
  exit 0;
}

{
  # X,Y to N by dividing
  #
  #   *--*
  #      |
  #   *  *             0,1   1,1
  #      |
  #   *==*      -1,0   0,0   1,0
  #      |
  #   *  *             0,-1  1,-1
  #      |
  #   *--*
  #
  my $path = Math::PlanePath::CCurve->new;
  my @dir4_to_dx = (1,0,-1,0);
  my @dir4_to_dy = (0,1,0,-1);
  my @dir4_to_ds = ( 1, 1, -1, -1); # ds = dx+dy
  my @dir4_to_dd = (-1, 1,  1, -1); # ds = dy-dx

  my $n_at = 1727;
  my ($x,$y) = $path->n_to_xy ($n_at);
  print "n=$n_at   $x,$y\n";

  my @n_list;
  my $n_list_str = '';
  foreach my $anti (0) {
    foreach my $dir (0, 1, 2, 3) {
      print "dir=$dir  anti=$anti\n";
      my $dx = $dir4_to_dx[$dir];
      my $dy = $dir4_to_dy[$dir];
      my $arm = 0;

      my ($x,$y) = ($x,$y);
      my $s = $x + $y;
      my $d = $y - $x;
      my $ds = $dir4_to_ds[$dir];
      my $dd = $dir4_to_dd[$dir];
      my @nbits;
      for (;;) {
        my $nbits = join('',reverse @nbits);
        print "$x,$y  bit=",$s%2,"   $nbits\n";

        if ($s >= -1 && $s <= 1 && $d >= -1 && $d <= 1) {
          # five final positions
          #      .   0,1   .       ds,dd
          #           |
          #    -1,0--0,0--1,0
          #           |
          #      .   0,-1  .
          #
          if ($s == $ds && $d == $dd) {
            push @nbits, 1;
            $s -= $ds;
            $d -= $dd;
          }
          if ($s==0 && $d==0) {
            my $n = digit_join_lowtohigh(\@nbits, 2, 0);
            my $nbits = join('',reverse @nbits);
            print "n=$nbits = $n\n";
            push @n_list, $n;
            $n_list_str .= "${n}[dir=$dir,anti=$anti], ";
            last;
          }

          $arm += dxdy_to_dir4($x,$y);
          print "not found, arm=$arm\n";
          last;
        }

        my $bit = $s % 2;
        push @nbits, $bit;
        if ($bit) {
          # if (($x == 0 && ($y == 1 || $y == -1))
          #     || ($y == 0 && ($x == 1 || $x == -1))) {
          #   if ($x != $dx || $y != $dy) {
          $x -= $dx;
          $y -= $dy;
          # $s -= ($dx + $dy);
          # $d -= ($dy - $dx);
          $s -= $ds;
          $d -= $dd;
          ($dx,$dy) = ($dy,-$dx); # rotate -90
          ($ds,$dd) = ($dd,-$ds); # rotate -90
          $arm++;
        }

        # undo expand on right, normal curl anti-clockwise:
        # divide i+1 = mul (i-1)/(i^2 - 1^2)
        #            = mul (i-1)/-2
        # is (i*y + x) * (i-1)/-2
        #  x = (-x - y)/-2  = (x + y)/2
        #  y = (-y + x)/-2  = (y - x)/2
        #
        # undo expand on left, curl clockwise:
        # divide 1-i = mul (1+i)/(1 - i^2)
        #            = mul (1+i)/2
        # is (i*y + x) * (i+1)/2
        #  x = (x - y)/2
        #  y = (y + x)/2
        #
        ### assert: (($x+$y)%2)==0
        ($x,$y) = ($anti ? ($d/-2, $s/2)     : ($s/2, $d/2));

        ($s,$d) = (($s + $d)/2, ($d - $s)/2);

        last if @nbits > 20;
      }
      print "\n";
    }
  }
  print "$n_list_str\n";
  print join(', ', @n_list),"\n";
  @n_list = sort {$a<=>$b} @n_list;
  print join(', ', @n_list),"\n";
  foreach my $n (@n_list) {
    my $count = count_1_bits($n) % 4;
    printf "%b  %d\n", $n, $count;
  }
  exit 0;

  sub dxdy_to_dir4 {
    my ($dx, $dy) = @_;
    if ($dx > 0) { return 0; }  # east
    if ($dx < 0) { return 2; }  # west
    if ($dy > 0) { return 1; }  # north
    if ($dy < 0) { return 3; }  # south
  }

  # S=X+Y   S = S
  # D=Y-X   Y = (S+D)/2
  #
  # S=X+Y
  # X=S-Y
  #
  # newX,newY = (X+Y)/2, (Y-X)/2
  #           = (S-Y+Y)/2, (Y-(S-Y))/2
  #           = S/2, (Y-S+Y)/2
  #           = S/2, (2Y-S)/2
  # newS = S/2 + (2Y-S)/2
  #      = Y
  # newY = (2Y-S)/2
}

{
  # arms visits

  my $k = 3;
  my $path = Math::PlanePath::CCurve->new;
  my $n_hi = 256  * 8 ** $k;
  my $len = 2 ** $k;

  my @points;
  my $plot = sub {
    my ($x,$y, $n) = @_;
    ### plot: "$x,$y"

    if ($x == 0 && $y == 0) {
      $points[$x][$y] = '8';
    }
    if ($x >= 0 && $x <= 2*$len
        && $y >= 0 && $y <= 2*$len) {
      # $points[$x][$y] .= sprintf '%d,', $n;
      $points[$x][$y] .= sprintf '*', $n;
    }
  };

  foreach my $n (0 .. $n_hi) {
    my ($x,$y) = $path->n_to_xy ($n);
    foreach (0, 1) {
      foreach (1 .. 4) {
        ($x,$y) = (-$y,$x); # rotate +90
        $plot->($x, $y, $n);
      }
      $y = -$y;
    }
  }

  foreach my $y (reverse 0 .. 2*$len) {
    printf "%2d: ", $y;
    foreach my $x (0 .. 2*$len) {
      printf ' %4s', $points[$x][$y] // '-';
    }
    print "\n";
  }
  printf "    ";
  foreach my $x (0 .. 2*$len) {
    printf ' %4s', $x;
  }
  print "\n";

  exit 0;
}

{
  # quad point visits by tiling

  #     *------*-----*
  #     |            |
  #    N=4^k        N=0
  #
  # 4 inward square, 4 outward square

  my $k = 3;
  my $path = Math::PlanePath::CCurve->new;
  my $len = 2 ** $k;
  my $rot = (2 - $k) % 4;
  ### $rot

  my @points;
  my $plot = sub {
    my ($x,$y, $n) = @_;
    ### plot: "$x,$y"

    if ($x >= 0 && $x <= 2*$len
        && $y >= 0 && $y <= 2*$len) {
      # $points[$x][$y] .= sprintf '%d,', $n;
      $points[$x][$y] .= sprintf '*', $n;
    }
  };

  foreach my $n (0 .. 4**$k-1) {
    my ($x,$y) = $path->n_to_xy ($n);
    ### at: "$x,$y n=$n"
    foreach (1 .. $rot) {
      ($x,$y) = (-$y,$x); # rotate +90
    }
    ### rotate to: "$x,$y"
    $x += $len;
    ### X shift to: "$x,$y"

    foreach my $x_offset (0, $len,  #  -$len,
                         ) {
      foreach my $y_offset (0, $len, #  -$len,
                           ) {

        ### horiz: "$x,$y"
        $plot->($x+$x_offset, $y+$y_offset, $n);
        { my ($x,$y) = (-$x,-$y); # rotate 180
          $x += $len;
          ### rotated: "$x,$y"
          $plot->($x+$x_offset,$y+$y_offset, $n);
        }

        my ($x,$y) = (-$y,$x); # rotate +90
        # ### vert: "$x,$y"
        $plot->($x+$x_offset,$y+$y_offset, $n);
        { my ($x,$y) = (-$x,-$y); # rotate 180
          $y += $len;
          # ### rotated: "$x,$y"
          $plot->($x+$x_offset,$y+$y_offset, $n);
        }
      }
    }
  }

  foreach my $y (reverse 0 .. 2*$len) {
    printf "%2d: ", $y;
    foreach my $x (0 .. 2*$len) {
      printf ' %4s', $points[$x][$y] // '-';
    }
    print "\n";
  }
  exit 0;
}

{
  # repeat points
  my $path = Math::PlanePath::CCurve->new;
  my %seen;
  my @first;
  foreach my $n (0 .. 2**16 - 1) {
    my ($x, $y) = $path->n_to_xy ($n);
    my $xy = "$x,$y";
    my $count = ++$seen{$xy};
    if (! $first[$count]) {
      $first[$count] = $xy;
      printf "count=%d first N=%d %b\n", $count, $n,$n;
    }
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
  # repeat edges
  my $path = Math::PlanePath::CCurve->new;
  my ($prev_x,$prev_y) = $path->n_to_xy (0);
  my %seen;
  foreach my $n (1 .. 2**24 - 1) {
    my ($x, $y) = $path->n_to_xy ($n);
    my $min_x = min($x,$prev_x);
    my $min_y = min($y,$prev_y);
    my $max_x = max($x,$prev_x);
    my $max_y = max($y,$prev_y);
    my $xy = "$min_x,$min_y--$max_x,$max_y";
    my $count = ++$seen{$xy};
    if ($count > 2) {
      printf "count=%d third N=%d %b\n", $count, $n,$n;
    }
    $prev_x = $x;
    $prev_y = $y;
  }
  exit 0;
}
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
