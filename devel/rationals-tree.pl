#!/usr/bin/perl -w

# Copyright 2011, 2012, 2013 Kevin Ryde

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


use 5.010;
use strict;
use POSIX ();
use List::Util 'sum';
use Math::PlanePath::Base::Digits
  'round_down_pow',
  'digit_split_lowtohigh',
  'digit_join_lowtohigh';
use Math::PlanePath::RationalsTree;

# uncomment this to run the ### lines
use Smart::Comments;



{
  # Pythagorean N in binary
  my $tree_type_aref = Math::PlanePath::RationalsTree->parameter_info_hash->{'tree_type'}->{'choices'};
  foreach my $tree_type (@$tree_type_aref) {
    print "$tree_type\n";
    my $path = Math::PlanePath::RationalsTree->new(tree_type => $tree_type);
    for (my $n = 2; $n < 70; $n += 1) {
      my ($x,$y) = $path->n_to_xy($n);
      next unless xy_is_pythagorean($x,$y);
      # next unless (($x^$y)&1) == 0;  # odd/odd
      # next unless (($x^$y)&1) == 1;  # odd/even or even/odd
      # next unless ($x%2==1 && $y%2==0);
      printf "%7b\n", $n;
    }
    print "\n";
  }
  exit 0;

  sub xy_is_pythagorean {
    my ($x,$y) = @_;
    return ($x>$y && ($x%2)!=($y%2));
  }
}
{
  # Pythagorean N search
  my $tree_type_aref = Math::PlanePath::RationalsTree->parameter_info_hash->{'tree_type'}->{'choices'};
  foreach my $offset (0 .. 3, -3 .. -1) {
    print "offset=$offset\n";
    foreach my $tree_type (@$tree_type_aref) {
      my $path = Math::PlanePath::RationalsTree->new(tree_type => $tree_type);
      my $str = '';
      for (my $n = 2; length($str) < 60; $n += 1) {
        my ($x,$y) = $path->n_to_xy($n);

        # next unless xy_is_pythagorean($x,$y);
        # next unless (($x^$y)&1) == 0;  # odd/odd
        # next unless (($x^$y)&1) == 1;  # odd/even or even/odd
        next unless ($x%2==1 && $y%2==0);
        $str .= ($n+$offset).",";
      }
      print "$tree_type  $str\n";
      if (system("grep -e '$str' ~/OEIS/stripped") == 0) {
        print "matched\n";
      }
      print "\n";
    }
  }
  exit 0;

  sub xy_is_pythagorean {
    my ($x,$y) = @_;
    return ($x>$y && ($x%2)!=($y%2));
  }
}
{
  # parity search
  my $tree_type_aref = Math::PlanePath::RationalsTree->parameter_info_hash->{'tree_type'}->{'choices'};
  foreach my $mult (1,2) {
    foreach my $add (0, ($mult==2 ? -1 : ())) {
      foreach my $neg (0, 1) {
        print "$mult*N+$add neg=$neg\n";

        foreach my $tree_type (@$tree_type_aref) {
          my $path = Math::PlanePath::RationalsTree->new(tree_type => $tree_type);
          my $str = '';
          # for (my $n = 1030; $n < 1080; $n += 1) {
          for (my $n = 2; $n < 50; $n += 1) {
            my ($x,$y) = $path->n_to_xy($n);
            my $value = ($x ^ $y) & 1;
            $value *= $mult;
            $value += $add;
            if ($neg) { $value = -$value; }
            $str .= "$value,";
          }
          print "$tree_type  $str\n";
          system "grep -e '$str' ~/OEIS/stripped";
          print "\n";
        }
      }
    }
  }
  exit 0;
}
{
  require Math::PlanePath::RationalsTree;
  # SB 11xxxx and 0 or 2 mod 3
  # CS 3,5 mod 6
  # L 0,4 mod 6
  # groups 1,1,3,5,11,21,43,85,171,341,683,1365,2731
  # A001045 Jacobsthal a(n-1)+2*a(n-2)
  # 3*a(n)+(-1)^n = 2^n
  # Inverse: floor(log_2(a(n))=n-2 for n>=2

  # D. E. Knuth, Art of Computer Programming, Vol. 3, Sect.
  # 5.3.1, Eq. 13.   On GCD
  # Arises in study of sorting by merge insertions and in
  # analysis of a method for computing GCDs - see Knuth
  # reference.

  my $tree_type_aref = Math::PlanePath::RationalsTree->parameter_info_hash->{'tree_type'}->{'choices'};
  foreach my $tree_type (@$tree_type_aref) {
    print "$tree_type\n";
    my $path = Math::PlanePath::RationalsTree->new (tree_type => $tree_type);
    my $count = 0;
    my $group = 0;
    my $prev_high_bit = 0b10;
    foreach my $n ($path->n_start .. 50000) {
      my ($x,$y) = $path->n_to_xy($n);
      next unless $x>$y && ($x%2)!=($y%2); # P>Q not both odd

      if (high_bit($n) != $prev_high_bit) {
        print "group $group\n";
        $prev_high_bit = high_bit($n);
        $group = 0;
      }
      $group++;

      #      printf "%7b,   # %d\n", $n, sans_high_bit(sans_high_bit($n))%3;
      last if $count++ > 9000;
    }
    print "\n";
  }
  exit 0;
}

{
  # X,Y list by levels
  require Math::PlanePath::RationalsTree;
  my $tree_type_aref = Math::PlanePath::RationalsTree->parameter_info_hash->{'tree_type'}->{'choices'};
  foreach my $tree_type (@$tree_type_aref) {
    print "$tree_type\n";
    my $path = Math::PlanePath::RationalsTree->new
      (
       # tree_type => 'HCS',
       tree_type => $tree_type,
       # tree_type => 'CW',
       # tree_type => 'SB',
      );

    my $non_monotonic = '';
    foreach my $level (0 .. 6) {
      my $nstart = 2**$level;
      my $nend = 2**($level+1)-1;
      my $prev_x = 1;
      my $prev_y = 0;
      print "$nstart  ";
      foreach my $n ($nstart .. $nend) {
        if ($n != $nstart) { print " "; }
        my ($x,$y) = $path->n_to_xy($n);
        next unless $x>$y && ($x%2)!=($y%2); # P>Q not both odd

        print "$x/$y";
        unless (frac_lt($prev_y,$prev_x, $y,$x)) {
          $non_monotonic ||= "at $y/$x";
        }
        $prev_x = $x;
        $prev_y = $y;
      }
      print "\n";
      # print " non-monotonic $non_monotonic\n";
    }
  }
  exit 0;
}
{
  # turn list with levels, or parity with levels

  require Math::NumSeq::PlanePathTurn;
  my $path = Math::PlanePath::RationalsTree->new(tree_type => 'SB');
  my $seq = Math::NumSeq::PlanePathTurn->new (planepath_object => $path,
                                              turn_type => 'Right');
  for (my $n = $seq->i_start; $n <= 16384; $n+=1) {
    # next if $n % 2;
    if (is_pow2($n)) {
      printf "\n%5d ", $n;
    }

    # my $turn = $seq->ith($n);
    my ($x,$y) = $path->n_to_xy($n);
    # my $turn = ($x ^ $y) & 1;
    my $turn = ($x&1) + 2*($y&1);

    # if ($n % 8 == 0) { print " "; }
    print "$turn";
  }
  print "\n";
  exit 0;
}

{
  # HCS turn left,right
  require Math::NumSeq::PlanePathTurn;
  require Math::BaseCnv;
  require Math::PlanePath::GrayCode;
  my $path = Math::PlanePath::RationalsTree->new(tree_type => 'HCS');
  my $seq = Math::NumSeq::PlanePathTurn->new (planepath_object => $path,
                                              turn_type => 'Right');
  foreach my $n ($path->n_start+1 .. 255) {
    # if (($n & 3) == 1 || ($n & 3) == 2) {
    #   next;
    # }
    my $turn = $seq->ith($n); # -1); # int(($n-1)/2));
    # print "$turn,"; next;
    my $n2 = Math::BaseCnv::cnv($n,10,2);
    if (is_pow2($n)) { print "\n"; }
    my ($x,$y) = $path->n_to_xy($n);
    my $parity = hcs_turn_right($n) ? 1 : 0;
    my $diff = ($parity == $turn ? '' : '  ***');
    printf "%2s %5s %2s,%-2s  %d %s%s\n",
      $n, $n2, $x,$y,  $turn, $parity, $diff;
  }

  # X/(X+Y), (X+Y)/Y high to low both shear only so no change
  # SB Right when floor((N+1)/2 is odd or power 2^k.
  # Right at first and last of row, otherwise LRRL repeat.
  sub Zsb_turn_right {     # bad
    my ($n) = @_;
    $n += ($n&1);
    return (($n & 2) == 1 || ($n & ($n-1)) == 0);
  }
  sub Ysb_turn_right {     # good
    my ($n) = @_;
    if ($n == 3) { return 0; }
    $n = ($n+1) >> 1;
    return (($n & 1) || is_pow2($n));
  }
  # N is 1or2 mod 4, or N=1111or10000 is N or N+1 is pow2
  sub sb_turn_right {     # good
    my ($n) = @_;
    if ($n == 3) {
      return 0;
    }
    if (($n & 3) == 1 || ($n & 3) == 2) {
      return 1;
    }
    return is_pow2($n) || is_pow2($n+1);
  }
  sub XXsb_turn {     # good
    my ($n) = @_;
    ### sb_turn(): "$n  binary ".sprintf('%b',$n)
    my $bit = high_bit($n);
    ### high: "bit=".sprintf('%b',$bit)
    $n -= $bit;
    for ($bit >>= 1; $bit > 2; $bit >>= 1) {
      ### at: "n=".sprintf('%b',$n)." bit=".sprintf('%b',$bit)
      if ($n & $bit) {
        $n -= $bit;
        $n ^= ($bit-1);
      }
      if ($n == $bit-1) {
        return 0;
      }
    }
    return 1;
  }

  sub hcs_turn_right {  # good
    my ($n) = @_;
    return count_1_bits($n+1) & 1;
  }
  sub count_1_bits {
    my ($n) = @_;
    my $count = 0;
    while ($n) {
      $count += ($n & 1);
      $n >>= 1;
    }
    return $count;
  }

  # Y/(X+Y) and (X+Y)/X high to low
  # so transpose on every new bit inserted
  sub bird_turn_right {  # good
    my ($n) = @_;
    if ($n == 2) { return 1; }
    $n++;
    $n >>= 1;
    if ($n == high_bit($n)) {
      return 0;   # first and last of row always 0
    }
    my $ret = bit_length($n) & 1;   # rows alternately 1s and 0s
    if (($n & 3) == 0) {            # but 0mod8 and 7mod8 flip by low 0s
      my $c = count_low_0_bits($n);
      $ret ^= ($c & 1) ^ 1;
    }
    return $ret;
  }
  sub bit_length {
    my ($n) = @_;
    my $len = 0;
    while ($n) {
      $n >>= 1;
      $len++;
    }
    return $len;
  }
  sub count_low_0_bits {
    my ($n) = @_;
    if ($n == 0) { return 0; }
    my $count = 0;
    until ($n % 2) {
      $count++;
      $n /= 2;
    }
    return $count;
  }

  # 0 1 2 3 4 5 6 7 8 9 A B C D E F
  # 1,1,0,1,0,1,0,0,1,1,0,0,1,1,0,0
  #
  sub ayt_turn_right {   # wrong
    my ($n) = @_;
    if (($n & 3) == 1 || ($n & 3) == 2) {
      return 1;
    }
    my $bit = high_bit($n);
    if (bit_length($n) & 1) {
      return ($n == $bit+$bit/2 || $n == $bit+$bit/2-1 ? 1 : 0);
    } else {
      return ($n == $bit || $n == 2*$bit-1 ? 0 : 1);
    }
  }

  sub drib_turn_right {   # wrong
    my ($n) = @_;
    if (($n & 3) == 1 || ($n & 3) == 2) {
      return 1;
    }
    my $bit = high_bit($n);
    if (bit_length($n) & 1) {
      return ($n == $bit+$bit/2 || $n == $bit+$bit/2-1 ? 1 : 0);
    } else {
      return ($n == $bit || $n == 2*$bit-1 ? 0 : 1);
    }
  }

  #            C 3,5 R
  #     A 1,4                                P->A X/X+Y shear North
  #     P 1,3         B 4,3 L                P->B X+Y/Y shear East
  #            Q 3,2         D 5,2           Q->C X/X+Y shear North
  #                                          Q->D X+Y/Y shear East
  #      X=1    X=3    X=4    X=5
  sub cw_turn_right {    # wrong
    my ($n) = @_;
    my $bit = high_bit($n);
    $n -= $bit;
    while ($bit > 2) {
      if ($n & $bit) {
        $n -= $bit;
        $n ^= ($bit-1);
      }
      if ($n == 1 || $n == 2) {
        return 0;
      }
      $bit >>= 1;
    }
    return 1;
    return 0;
  }

  sub to_gray {
    my ($n) = @_;
    my $digits = [ digit_split_lowtohigh($n,2) ];
    Math::PlanePath::GrayCode::_digits_to_gray_reflected($digits,2);
    return digit_join_lowtohigh($digits,2);
  }
  sub from_gray {
    my ($n) = @_;
    my $digits = [ digit_split_lowtohigh($n,2) ];
    Math::PlanePath::GrayCode::_digits_from_gray_reflected($digits,2);
    return digit_join_lowtohigh($digits,2);
  }
  sub sans_high_bit {
    my ($n) = @_;
    return $n ^ high_bit($n);
  }
  sub high_bit {
    my ($n) = @_;
    my $bit = 1;
    while ($bit <= $n) {
      $bit <<= 1;
    }
    return $bit >> 1;
  }

  exit 0;
}
{
  # HCS vs Bird
  require Math::NumSeq::PlanePathTurn;
  my $hcs  = Math::PlanePath::RationalsTree->new(tree_type => 'HCS');
  my $bird = Math::PlanePath::RationalsTree->new(tree_type => 'Bird');
  my $n = 0b1000000010000000000;
  my ($x,$y) = $hcs->n_to_xy($n);
  my $nb = $bird->xy_to_n($x,$y);
  printf "%10b\n", $n;
  printf "%10b\n", $nb;
  exit 0;
}

{
  # Minkowski question mark
  #
  # cf = [0,a1,a2,...] range 0to1
  #             (-1)^(k-1)
  # ? = sum  -----------
  #      k    2^(a1+...+ak-1)
  # (-1)^(1-1)/2^a1 = 1/2^a1 = 0.000..001 binary

  # + (-1)^(1-2)/2^(a1+a2) = -1/2^(a1+a2)
  #   = 0.0001 - 0.000000001
  #   = 0.000011111
  #
  # 0to1 cf = [0,a0,a1,...]
  # ? = 2*(1 - 2^-a0 + 2^-(a0+a1) - 2^-(a0+a1+a2) + ...)
  #
  # ? =
  #
  # ?(1/k^n) = 1/2^(k^n-1)
  # ?(0) = 0
  # ?(1/3) = 1/4
  require Math::BaseCnv;
  require Math::BigRat;
  my $path = Math::PlanePath::RationalsTree->new (tree_type => 'SB');

  # ?(1/3)=1/4  ?(1/2)=1/2  ?(2/3)=3/4
  foreach my $xy ('1/3', '1/2', '2/3') {
    my ($x,$y) = split m{/}, $xy;
    try ($x,$y);
  }

  foreach my $n ($path->n_start .. 64) {
    my ($x,$y) = $path->n_to_xy($n);
    try ($x,$y);
  }

  foreach my $xy ('1/3', '1/2', '2/3') {
    my ($x,$y) = split m{/}, $xy;
    try ($x,$y);
  }

  sub try {
    my ($x,$y) = @_;
    require Math::ContinuedFraction;
    my $cfrac = Math::ContinuedFraction->from_ratio($x,$y);
    my $cfrac_str = $cfrac->to_ascii;
    my $n = $path->xy_to_n($x,$y);
    my $nbits = Math::BaseCnv::cnv($n,10,2);
    my $mp = minkowski_by_path($x,$y);
    my $mc = minkowski_by_cfrac($x,$y);
    my $mpstr = to_binary($mp);
    my $mcstr = to_binary($mc);
    print "$x/$y  $nbits  p=$mp c=$mc   $cfrac_str\n";
  }

  # pow=2^level <= N
  # ? = (2*(N-pow) + 1) / pow
  #   = (2N - 2pow + 1) / pow
  #   = (2N+1)/pow - 2pow/pow
  #   = (2N+1)/pow - 2
  #   = 2*((N+1/2)/pow - 1)
  sub minkowski_by_path {
    my ($x,$y) = @_;
    my $n = $path->xy_to_n($x,$y);
    my ($pow,$exp) = round_down_pow($n,2);
    return Math::BigRat->new(2*$n+1) / $pow - 2;
    return Math::BigRat->new(2*($n-$pow) + 1) / $pow;

    return (2*($n-$pow) + 1) / $pow;
    return (2*$pow-1 - $n) / $pow;
    return $n / (2*$pow);
  }

  # q0, q1, ...
  #               1          1           1
  # ? = 2 * (1 - --- * (1 - ---- * (1 - ---- * (... 
  #             2^q0        2^q1        2^q2
  #
  sub minkowski_by_cfrac {
    my ($x,$y) = @_;
    require Math::ContinuedFraction;
    my $cfrac = Math::ContinuedFraction->from_ratio($x,$y);
    my $aref = $cfrac->to_array;  # first to last
    ### $aref
    my $ret = 1;
    foreach my $q (reverse @$aref) {
      $ret = 1 - 1/Math::BigRat->new(2)**$q * $ret;
    }
    return 2*$ret;
  }

  # q0, q1, ...
  #                (-1)^k
  # ? = sum -------------------
  #      k  2^(q0+q1+...qk - 1)
  sub minkowski_by_cfrac_cumul {
    my ($x,$y) = @_;
    require Math::ContinuedFraction;
    my $cfrac = Math::ContinuedFraction->from_ratio($x,$y);
    my $aref = $cfrac->to_array;
    ### $aref
    my $ret = 1;
    my $sign = Math::BigRat->new(1);
    my $pos = 0;
    foreach my $q (@$aref) {
      $sign = -$sign;
      $pos += $q;
      $ret += $sign / (Math::BigInt->new(2) ** $pos);
    }
    return 2*$ret;
  }

  # pow=2^level <= N
  # F = (2*(N-pow) + 1) / pow / 2
  #   = ((N-pow) + 1/2) / pow
  sub F_by_path {
    my ($x,$y) = @_;
    my $n = $path->xy_to_n($x,$y);
    my ($pow,$exp) = round_down_pow($n,2);
    return Math::BigRat->new(2*$n+1) / $pow - 2;
    return Math::BigRat->new(2*($n-$pow) + 1) / $pow;
  }
  # q0, q1, ...
  #
  #                (-1)^k
  # F = sum -------------------
  #      k  2^(q0+q1+...qk)
  sub F_by_cfrac {
    my ($x,$y) = @_;
    require Math::ContinuedFraction;
    my $cfrac = Math::ContinuedFraction->from_ratio($x,$y);
    my $aref = $cfrac->to_array;
    ### $aref
    my $ret = 1;
    my $sign = Math::BigRat->new(1);
    my $pos = 0;
    foreach my $q (@$aref) {
      $sign = -$sign;
      $pos += $q;
      $ret += $sign / (Math::BigInt->new(2) ** $pos);
    }
    return $ret;
  }

  sub to_binary {
    my ($n) = @_;
    my $str = sprintf '%b', int($n);
    $n -= int($n);
    if ($n) {
      $str .= '.';
      while ($n) {
        $n *= 2;
        if ($n >= 1) {
          $n -= 1;
          $str .= '1';
        } else {
          $str .= '0';
        }
      }
    }
    return $str;
  }
  exit 0;
}

{
  # A108356 partial sums
  # A108357 AYT 2N left or 2N+1 right within a row but not across it
  # (1+x^2+x^4)/(1-x^8) repeat of 10101000
  # 8 7 6 5 4 3 2 1 0-1-2-3-4-5
  # 0,0,0,0,1,0,1,0,1,0,0,0,0,0
  #        -1 0 0 0 0 0 0 0 1     -1
  require Math::Polynomial;
  Math::Polynomial->string_config({ ascending => 1 });
  my $num = Math::Polynomial->new(1,0,1,0,1);
  my $den = Math::Polynomial->new(1,0,0,0,0,0,0,0,-1);

  {
    my %seen;
    my $when = 1;
    for (;;) {
      $num <<= 1;
      my $q = $num / $den;
      $num %= $den;
      print "$q      $num\n";
      if (my $prev = $seen{$num}) {
        print "at $when repeat of $prev\n";
        last;
      }
      $seen{$num} = $when++;
    }
    exit 0;
  }
  {
    $num <<= 270;
    $num /= $den;
    $num = -$num;
    print $num,"\n";
    while ($num) {
      print $num->coeff(0);
      $num >>= 1;
    }
    print "\n";
    exit 0;

    # 1010001010100010101000101010001010100010101000101010001010100010101
    #       101010001010100010101000101010001010100010101000101010001010100010101000
  }
}
{
  # turn search
  require Math::NumSeq::PlanePathTurn;
  my $tree_type_aref = Math::PlanePath::RationalsTree->parameter_info_hash->{'tree_type'}->{'choices'};
  foreach my $mult (1,2) {
    foreach my $add (0, ($mult==2 ? 1 : ())) {
      foreach my $turn_type ('Left','Right','LSR') {
        foreach my $neg (0, ($turn_type eq 'LSR' ? 1 : ())) {
          print "$mult*N+$add  $turn_type  neg=$neg\n";
          foreach my $tree_type (@$tree_type_aref) {
            my $path = Math::PlanePath::RationalsTree->new(tree_type => $tree_type);
            my $seq = Math::NumSeq::PlanePathTurn->new (planepath_object => $path,
                                                        turn_type => $turn_type);
            my $str = '';
            # foreach my $n (1030 .. 1080) {
            foreach my $n (2 .. 50) {
              my $value = $seq->ith($mult*$n+$add);
              if ($neg) { $value = -$value; }
              $str .= "$value,";
            }
            print "$tree_type  $str\n";
            system "grep -e '$str' ~/OEIS/stripped";
            print "\n";
          }
        }
      }
    }
  }
  exit 0;
}


{
  # X,Y list CW

  # 1,1,3, 5,11,21,43
  # 1,2,5,10,21,42,85
  # P = X+Y Q=X      X=Q Y=P-Q
  #
  #              X,Y                                   X+Y,X
  #           /        \                            /         \
  #    X,(X+Y)           (X+Y),Y             2X+Y,X             X+2Y,X+Y
  #   /     \            /      \           /      \            /          \
  # X,(2X+Y) 2X+Y,X+Y X+Y,X+2Y X+2Y,Y  3X+Y,2X+Y 3X+2Y,2X+Y 2X+3Y,X+Y X+3Y,X+2Y
  #
  #              1,1
  #    1,2                 2,1
  # 1,3  3,2            2,3    3,1
  # 1/4  4/3  3/5 5/2  2/5 5/3  3/4 4/1
  #
  # X+Y,X                                         2,1 T
  #                        3,1                                          3,2*U
  #           4,1*D                   5,3                   5,2*A                    4,3*UU
  #       5,1      7,4*DU     8,3*UA        7,5      7,2*UD        8,5*AU        7,3         5,4*UUU
  #
  #  6,1*DD 9,5 11,4* 10,7* 11,3 13,8* 12,5*AA 9,7 9,2*AD 12,7* 13,5 11,8*   10,3* 11,7  9,4*DA 6,5*
  #
  # X+Y,Y                                         2,1 T
  #                        3,2*U                                         3,1
  #           4,3*UU                  5,2                   5,3*A                    4,1*D
  #       5,4*UUU  7,3*DU     8,5*UA        7,2      7,5*UD        8,3*AU        7,4         5,1*UUU
  #
  #  6,5*DD 9,4 11,4* 10,7* 11,3 13,8* 12,5*AA 9,7 9,2*AD 12,7* 13,8 11,3*   10,7* 11,4* 9,5*DA 6,1*

  require Math::PlanePath::RationalsTree;
  require Math::PlanePath::PythagoreanTree;
  my $pythag = Math::PlanePath::PythagoreanTree->new (coordinates=>'PQ');
  my $path = Math::PlanePath::RationalsTree->new(tree_type => 'CW');
  my $oe_total = 0;
  foreach my $depth (0 .. 6) {
    my $oe = 0;
    foreach my $n ($path->tree_depth_to_n($depth) ..
                   $path->tree_depth_to_n_end($depth)) {
      my ($x,$y) = $path->n_to_xy($n);
      my $flag = '';
      ($x,$y) = ($x+$y, $y);
      if ($x%2 != $y%2) {
        $flag = ($x%2?'odd':'even').','.($y%2?'odd':'even');
        $oe += $flag ? 1 : 0;
      }
      my $octant = '';
      if ($y < $x) {
        $octant = 'octant';
      }
      my $pn = $pythag->xy_to_n($x,$y);
      if ($pn) {
        $pn = n_to_pythagstr($pn);
      }
      printf "N=%2d %2d / %2d   %10s %10s %s\n", $n, $x,$y,
        $flag, $octant, $pn||'';
      $n++;
    }
    $oe_total += $oe;
    print "$oe   $oe_total\n";
  }

  sub n_to_pythagstr {
    my ($n) = @_;
    if ($n < 1) { return undef; }
    my ($pow, $exp) = round_down_pow (2*$n-1, 3);
    $n -= ($pow+1)/2;  # offset into row
    my @digits = digit_split_lowtohigh($n,3);
    push @digits, (0) x ($exp - scalar(@digits));  # high pad to $exp many
    return '1+'.join('',reverse @digits);
  }

    exit 0;
  }

{
  # count 0-bits below high 1
  # 1 2 3 4 5 6 7 8
  # 0,1,0,2,1,0,0,3,2,1,1,0,0,0,0,4,3,2,2,1,1,1,1,0,0,0,0,0,0,0,0,5,
  
  #             1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24
  # SB int(x/y) 1,0,2,0,0,1,3,0,0,0, 0, 1, 1, 2, 4,  0, 0, 0, 0, 0, 0, 0, 0, 1
  # count 

  # count high 1-bits, is +1 except at n=2^k
  #           0,1,1,2,1,1,2,3,1,1,1, 1, 2, 2, 3, 4,  1, 1, 1, 1, 1, 1, 1, 1, 2,

  foreach my $n (1 .. 32) {
    my $k = $n;
    while (! is_pow2($k)) {
      $k >>= 1;
    }
    my ($pow,$exp) = round_down_pow($k,2);
    print "$exp,";
  }
  print "\n";
  exit 0;

  sub is_pow2 {
    my ($n) = @_;
    while ($n > 1) {
      if ($n & 1) {
        return 0;
      }
      $n >>= 1;
    }
    return ($n == 1);
  }
}

{
  # X,Y list  cf pythag odd,even
  require Math::PlanePath::RationalsTree;
  foreach my $path
    (Math::PlanePath::RationalsTree->new(tree_type => 'SB'),
     Math::PlanePath::RationalsTree->new(tree_type => 'CW'),
     Math::PlanePath::RationalsTree->new(tree_type => 'HCS'),
     Math::PlanePath::RationalsTree->new(tree_type => 'AYT'),
     Math::PlanePath::RationalsTree->new(tree_type => 'Drib'),
     Math::PlanePath::RationalsTree->new(tree_type => 'Bird')) {
    print "tree_type $path->{'tree_type'}\n";
    foreach my $depth (0 .. 5) {
      foreach my $n ($path->tree_depth_to_n($depth) ..
                     $path->tree_depth_to_n_end($depth)) {
        my ($x,$y) = $path->n_to_xy($n);
        my $flag = '';
        if ($x%2 != $y%2) {
          $flag = ($x%2?'odd':'even').','.($y%2?'odd':'even');
        }
        my $octant = '';
        if ($y < $x) {
          $octant = 'octant';
        }
        printf "N=%2d %2d / %2d   %10s %10s\n", $n, $x,$y, $flag, $octant;
        $n++;
      }
      print "\n";
    }
  }
  exit 0;
}
{
  # HCS runs
  my $path = Math::PlanePath::RationalsTree->new (tree_type => 'HCS');
  my ($x,$y) = $path->n_to_xy(0b10000001001001000);
  #                             \-----/\-/\-/\--/
  #                                7    3  3  4
  #  is [6, 3, 3, 5]

  ($x,$y) = $path->n_to_xy(0b11000001);
  #                          |\----/|
  #                          1   6  1
  #  is [0, 6, 2]

  require Math::ContinuedFraction;
  my $cfrac = Math::ContinuedFraction->from_ratio($x,$y);
  my $cfrac_str = $cfrac->to_ascii;
  say $cfrac_str;
  exit 0;
}

{
  # A072726 numerator of rationals >= 1 with continued fractions even terms
  # A072727 denominator

  # A072728 numerator of rationals >= 1 with continued fraction terms 1,2 only
  # A072729 denominator

  require Math::NumSeq::OEIS;
  require Math::PlanePath::RationalsTree;
  my $num = Math::NumSeq::OEIS->new (anum => 'A072726');
  my $den = Math::NumSeq::OEIS->new (anum => 'A072727');
  my $tree_types = Math::PlanePath::RationalsTree->parameter_info_hash->{'tree_type'}->{'choices'};
  my @paths = map { Math::PlanePath::RationalsTree->new (tree_type => $_) }
    @$tree_types;
  print "    ",join('   ',@$tree_types),"\n";

  foreach (1 .. 120) {
    (undef, my $x) = $num->next;
    (undef, my $y) = $den->next;
    print "$x/$y";
    foreach my $path (@paths) {
      print "  ";
      my $n = $path->xy_to_n($x,$y);
      if (! defined $n) {
        print "undef";
        next;
      }
      printf '%b', $n;
    }
    print "\n";
  }
  exit 0;
}

{
  # L-tree OFFSET=0 for 0/1
  #                  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14
  # A174981(n)   num 0, 1, 1, 2, 3, 1, 2, 3, 5, 2, 5, 3, 4, 1, 3,
  # A002487(n+2) den 1, 2, 1, 3, 2, 3, 1, 4, 3, 5, 2, 5, 3, 4, 1,
  # A174980 den, stern variant
  my $path = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
  foreach my $n (0 .. 15) {
    my ($x,$y) = $path->n_to_xy($n);
    $x //= 'undef';
    $y //= 'undef';
    my $ln = cw_to_l($n);
    print "$n  $x,$y   $ln\n";
  }

  sub cw_to_l {
    my ($n) = @_;
    $n++;
    my ($pow,$exp) = round_down_pow($n,2);
    $n ^= $pow-1;
    # $n--;
    # $n |= $pow;
    return $n-1;
  }
  exit 0;
}


{
  # permutations in N row
  my $choices = Math::PlanePath::RationalsTree->parameter_info_hash
    ->{'tree_type'}->{'choices'};
  my %seen;
  foreach my $from_type (@$choices) {
    my $from_path = Math::PlanePath::RationalsTree->new (tree_type => $from_type);

    foreach my $to_type (@$choices) {
      next if $from_type eq $to_type;
      my $to_path = Math::PlanePath::RationalsTree->new (tree_type => $to_type);
      {
        my $str = '';
        foreach my $from_n (2 .. 25) {
          my ($x,$y) = $from_path->n_to_xy($from_n);
          my $to_n = $to_path->xy_to_n($x,$y);
          $str .= "$to_n,";
        }
        next if $seen{$str}++;
        print "$from_type->$to_type  http://oeis.org/search?q=$str\n";
      }
      {
        my $str = '';
        foreach my $from_n (2 .. 25) {
          my ($x,$y) = $from_path->n_to_xy($from_n);
          my $to_n = $to_path->xy_to_n($x,$y);
          $to_n ^= $from_n;
          # $str .= "$to_n,";
          $str .= sprintf '%d,', $to_n;
        }
        next if $seen{$str}++;
        print "$from_type->$to_type XOR  http://oeis.org/search?q=$str\n";
      }
    }
    print "\n";
  }
  exit 0;
}



{
  # 49/22
  # ### nbits apply CW: [
  # ###                   '0',
  # ###                   '1',
  # ###                   '1',
  # ###                   '0',
  # ###                   '0',
  # ###                   '0',
  # ###                   '0',
  # ###                   '1',
  # ###                   '1'
  # ###                 ]

  # HCS
  # 49/22
  # 27/22  X
  # 5/22   X
  # 5/17   Y
  # 5/12   Y
  # 5/7    Y
  # 5/2    Y
  # 3/2    X
  # 1/2    X
  # 1/1    Y


  # 1      .       = 1
  # 10     .0.     = 2
  # 100    .0.0.   = 3
  # 1000   .0.0.0. = 4

  # 1 00 1000 10 1
  #   \/ \--/ \/ ^
  #   2    4  2  2

  # 0,
  # 1,       .   1
  #
  # 1/2      .0. = .. = 2 -> 2 = 1/2
  # 2        .1. = 1,1 -> 0,2 = 0 + 1/(0+1/2) = 2
  #
  # 3/2      .0.0. = ... = 3 = 0 + 1/3
  # 1/3      .0.1. = ..1. = 2,1 -> 1,2 = 0+1/(1+1/2) = 2/3
  # 2/3      .1.0. = .1.. = 1,2 -> 0,3 = 0+1/(0+1/3) = 3
  # 3        .1.1. = 1,1,1 -> 0,1,2 = 0+1/(0+1/(1+1/2)) = 3/2
  #
  # 100 .. 111             SB  1/3 2/3 3/2 3/1
  # 5/2 4/3 5/3 1/4 2/5 3/4 3/5  4    1000 .. 1111     SB 1/4 .. 4/1

  # CW: 224 11100000  3/16  [0, 5, 3]
  # HCS: 194   3.0000, 16.0000   194  1_4096  0.000,1.000(1.0000) c=388,389
  # 194 = binary 11000010
  #              0 5   3
  # 1.1.0.0.0.0.1.0. = .1.....1.. = 1,5,2 -> 0,5,3 = 0+1/(5+1/3) = 3/16
  #
  # AYT
  # 836  49.0000, 22.0000   836  1_268435456
  # 1001000101 = 581
  # 1101000100 = 836
  #  |\/\--/\/
  #  22  4  2

  my $x = 1;
  my $y = 1;
  foreach my $nbit (0,0, 1,0,0,0, 1,0, 1) {
    $y += $x;
    if (! $nbit) {
      ($x,$y) = ($y,$x);
    }
  }
  # foreach my $nbit (reverse 0,0, 1,0,0,0, 1,0, 1) {
  #   # foreach my $nbit (reverse 0,0,0,0) {
  #   $x += $y;
  #   if ($nbit) {
  #     ($x,$y) = ($y,$x);
  #   }
  # }
  print "$x,$y\n";
  require Math::ContinuedFraction;
  my $cfrac = Math::ContinuedFraction->from_ratio($x,$y);
  my $cfrac_str = $cfrac->to_ascii;
  print "$cfrac_str\n";
  exit 0;
}

{
  # AYT vs continued fraction
  require Math::ContinuedFraction;
  require Math::BaseCnv;
  my $ayt = Math::PlanePath::RationalsTree->new (tree_type => 'CW');

  my $level = 10;
  foreach my $n (1 .. 2**$level) {
    my ($x,$y) = $ayt->n_to_xy($n);
    my $cfrac = Math::ContinuedFraction->from_ratio($x,$y);
    my $cfrac_str = $cfrac->to_ascii;
    my $nbits = Math::BaseCnv::cnv($n,10,2);
    printf "%3d %7s %2d/%-2d  %s\n", $n, $nbits, $x,$y, $cfrac_str;
  }
  exit 0;
}

{
  require Math::ContinuedFraction;
  my $cfrac = Math::ContinuedFraction->from_ratio(29,42);
  my $cfrac_str = $cfrac->to_ascii;
  print "$cfrac_str\n";
  exit 0;
}


{
  # lengths of frac or bits

  require Math::PlanePath::DiagonalRationals;
  require Math::PlanePath::CoprimeColumns;
  require Math::PlanePath::PythagoreanTree;

  foreach my $path (Math::PlanePath::DiagonalRationals->new,
                    Math::PlanePath::CoprimeColumns->new,
                    Math::PlanePath::PythagoreanTree->new(coordinates=>'PQ'),
                   ) {
    print join(',', map{cfrac_length($path->n_to_xy($_))} 2 .. 32),"\n";
    print join(',', map{bits_length ($path->n_to_xy($_))} 2 .. 32),"\n";
    print "\n";
  }
  exit 0;

  sub bits_length {
    my ($x,$y) = @_;
    return sum(0, Math::PlanePath::RationalsTree::_xy_to_quotients($x,$y));
  }
  sub cfrac_length {
    my ($x,$y) = @_;
    my @quotients = Math::PlanePath::RationalsTree::_xy_to_quotients($x,$y);
    return scalar(@quotients);
  }
}




{
  # 167/3
  require Math::BigInt;
  my $path = Math::PlanePath::RationalsTree->new;
  my $x = Math::BigInt->new(167);
  my $y = Math::BigInt->new(3);
  my $n = $path->xy_to_n($x,$y);
  print $n,"\n";
  my $binstr = $n->as_bin;
  $binstr =~ s/0b//;
  print $binstr,"\n";
  print length($binstr),"\n";
  exit 0;
}


{
  my $cw = Math::PlanePath::RationalsTree->new(tree_type => 'CW');
  my $ayt = Math::PlanePath::RationalsTree->new (tree_type => 'AYT');

  my $level = 6;
  foreach my $cn (2**$level .. 2**($level+1)-1) {
    my ($cx,$cy) = $cw->n_to_xy($cn);
    my $an = $ayt->xy_to_n($cx,$cy);
    my ($z,$c) = cw_to_ayt($cn);
    my ($t,$u) = ayt_to_cw($an);
    printf "%5s  %b %b   %b(%b)%s    %b(%b)%s\n",
      "$cx/$cy", $cn, $an,
        $z, $c, ($z == $an ? " eq" : ""),
          $t, $u, ($t == $cn ? " eq" : "");
  }
  exit 0;

  sub cw_to_ayt {
    my ($c) = @_;
    my $z = 0;
    my $flip = 0;
    for (my $bit = 1; $bit <= (1 << ($level-1)); $bit <<= 1) {  # low to high
      if ($flip) { $c ^= $bit; }
      if ($c & $bit) {

      } else {
        $z |= $bit;
        $flip ^= 1;
      }
    }
    $z += (1 << $level);
    $c &= (1 << $level) - 1;
    return $z,0;
  }

  sub ayt_to_cw {
    my ($a) = @_;
    $a &= (1 << $level) - 1;
    my $t = 0;
    my $flip = 0;
    for (my $bit = (1 << ($level-1)); $bit > 0; $bit >>= 1) {   # high to low
      if ($a & $bit) {
        $a ^= $bit;
        $t |= $bit;
        $flip ^= 1;
      } else {
      }
      if ($flip) { $t ^= $bit; }
    }
    if (!$flip) { $t = ~$t; }
    $t &= (1 << $level) - 1;    # mask to level
    $t += (1 << $level);        # high 1-bit
    return ($t,$a);
  }
}
{
  require Math::ContinuedFraction;
  {
    my $cf = Math::ContinuedFraction->new([0,10,2,1,8]);
    print $cf->to_ascii,"\n";
    print $cf->brconvergent(4),"\n";
  }
  {
    my $cf = Math::ContinuedFraction->from_ratio(26,269);
    print $cf->to_ascii,"\n";
  }
  exit 0;
}
{
  my $n = 12590;
  my $radix = 3;
  while ($n) {
    my $digit = $n % $radix;
    if ($digit == 0) {
      $digit = $radix;
    }
    $n -= $digit;
    ($n % $radix) == 0 or die;
    $n /= $radix;
    print "$digit";
  }
  print "\n";
  exit 0;
}
{
  my $n = 12590;
  my $radix = 3;
  my @digits = digit_split_lowtohigh($n,$radix);
  my $borrow = 0;
  foreach my $i (0 .. $#digits) {
    $digits[$i] -= $borrow;
    if ($digits[$i] <= 0) {
      $digits[$i] += $radix;
      $borrow = 1;
    } else {
      $borrow = 0;
    }
  }
  $borrow == 0 or die;
  print reverse(@digits),"\n";
  exit 0;
}
{
  my $n = 0;
  my @digits = (1,2,1,3,1,3,3,2,2);
  my $power = 1;
  foreach my $digit (@digits) {
    $power *= 3;
    $n += $power * $digit;
  }
  print $n;
  exit 0;
}

{
  require Math::ContinuedFraction;
  my $sb = Math::PlanePath::RationalsTree->new(tree_type => 'SB');
  for (my $n = $sb->n_start; $n < 3000; $n++) {
    my ($x,$y) = $sb->n_to_xy ($n);
    next if $x > $y;
    my $cf = Math::ContinuedFraction->from_ratio($x,$y);
    my $cfstr = $cf->to_ascii;
    my $cfaref = $cf->to_array;
    my $cflen = scalar(@$cfaref);
    my $nhex = sprintf '0x%X', $n;
    print "$nhex $n  $x/$y  $cflen  $cfstr\n";
  }
  exit 0;
}



{
  my $sb = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
  my $bird = Math::PlanePath::RationalsTree->new(tree_type => 'Bird');

  my $level = 5;
  foreach my $an (2**$level .. 2**($level+1)-1) {
    my ($ax,$ay) = $sb->n_to_xy($an);
    my $bn = $bird->xy_to_n($ax,$ay);
    my ($z,$c) = sb_to_bird($an);
    my ($t,$u) = bird_to_sb($bn);
    printf "%5s  %b %b   %b(%b)%s    %b(%b)%s\n",
      "$ax/$ay", $an, $bn,
      $z, $c, ($z == $bn ? " eq" : ""),
      $t, $u, ($t == $an ? " eq" : "");
  }
  exit 0;

  sub sb_to_bird {
    my ($n) = @_;
    for (my $bit = (1 << ($level-1)); $bit > 0; $bit >>= 1) {   # high to low
      $bit >>= 1;
      $n ^= $bit;
    }
    return $n,0;
  }
  sub bird_to_sb {
    my ($n) = @_;
    for (my $bit = (1 << ($level-1)); $bit > 0; $bit >>= 1) {   # high to low
      $bit >>= 1;
      $n ^= $bit;
    }
    return $n,0;
  }

  sub ayt_to_bird {
    my ($a) = @_;
    ### bird_to_ayt(): sprintf "%b", $a
    my $z = 0;
    my $flip = 1;
    $a = _reverse($a);
    for (my $bit = 1; $bit <= (1 << ($level-1)); $bit <<= 1) {  # low to high
      ### a bit: ($a & $bit)
      ### $flip
      if ($a & $bit) {
        if (! $flip) {
          $z |= $bit;
        }
      } else {
        $flip ^= 1;
        if ($flip) {
          $z |= $bit;
        }
      }
      ### z now: sprintf "%b", $z
      ### flip now: $flip
    }
    $z += (1 << $level);
    $a &= (1 << $level) - 1;
    return $z,0;
  }

  no Devel::Comments;

  sub bird_to_ayt {
    my ($b) = @_;
    $b = _reverse($b);
    $b &= (1 << $level) - 1;
    my $t = 0;
    my $flip = 1;
    for (my $bit = (1 << ($level-1)); $bit > 0; $bit >>= 1) {   # high to low
      if ($b & $bit) {
        if ($flip) {
          $t |= $bit;
        }
        $flip ^= 1;
      } else {
        if (! $flip) {
          $t |= $bit;
        }
      }
      # if ($flip) { $t ^= $bit; }
    }
    if (!$flip) { $t = ~$t; }
    $t &= (1 << $level) - 1;
    $t += (1 << $level);
    return ($t,0); # $b);
  }

  sub _reverse {
    my ($n) = @_;
    my $rev = 1;
    while ($n > 1) {
      $rev = 2*$rev + ($n % 2);
      $n = int($n/2);
    }
    return $rev;
  }
}


{
  # diatomic 0,1,1,2,1,3,2,3, 1,4,3,5,2,5,3,4, 1,5,4,7,3,8,5,7,2,7,5,8,3,7,4,5,1,6,5,9,4,11,7,10,3,11,8,13,5,12,7,9,2,9,7,12,5,13,8,11,3,10,7,11,4,9,5,6,1,7,6,11,5,14,9,13,4,15,11,18,7,17,
  my $ayt = Math::PlanePath::RationalsTree->new(tree_type => 'AYT');

  foreach my $level (0 .. 3) {
    foreach my $n (2**$level .. 2**($level+1)-1) {
      my ($x,$y) = $ayt->n_to_xy($n);
      print "$x,";
    }
  }
  print "\n";

  my $prev_y = 1;
  foreach my $level (0 .. 5) {
    foreach my $n (reverse 2**$level .. 2**($level+1)-1) {
      my ($x,$y) = $ayt->n_to_xy($n);
      print "$n  $x $y\n";
      if ($x != $prev_y) {
        print "diff\n";
      }
      $prev_y = $y;
    }
  }
  exit 0;
}

{
  require Math::PlanePath::RationalsTree;
  my $path = Math::PlanePath::RationalsTree->new;
  $, = ' ';
  say $path->xy_to_n (9,8);
  say $path->xy_to_n (2,3);
  say $path->rect_to_n_range (9,8, 2,3);

  exit 0;
}

{
  require Math::PlanePath::RationalsTree;
  my $path = Math::PlanePath::RationalsTree->new;
  require Math::BigInt;
  # my ($n_lo,$n_hi) = $path->xy_to_n (1000,0, 1500,200);
  my $n = $path->xy_to_n (Math::BigInt->new(1000),1);
  ### $n
  ### n: "$n"

  require Math::NumSeq::All;
  my $seq = Math::NumSeq::All->new;
  my $pred = $seq->pred($n);
  ### $pred

  exit 0;
}

{
  require Math::PlanePath::RationalsTree;
  my $cw = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
  my $drib = Math::PlanePath::RationalsTree->new(tree_type => 'Drib');

  my $level = 5;
  foreach my $an (2**$level .. 2**($level+1)-1) {
    my ($ax,$ay) = $cw->n_to_xy($an);
    my $bn = $drib->xy_to_n($ax,$ay);
    my ($z,$c) = cw_to_drib($an);
    my ($t,$u) = drib_to_cw($bn);
    printf "%5s  %b %b   %b(%b)%s    %b(%b)%s\n",
      "$ax/$ay", $an, $bn,
      $z, $c, ($z == $bn ? " eq" : ""),
      $t, $u, ($t == $an ? " eq" : "");
  }
  exit 0;

  sub cw_to_drib {
    my ($n) = @_;
    for (my $bit = 2; $bit <= (1 << ($level-1)); $bit <<= 2) {  # low to high
      $n ^= $bit;
    }
    return $n,0;
  }
  sub drib_to_cw {
    my ($n) = @_;
    for (my $bit = 2; $bit <= (1 << ($level-1)); $bit <<= 2) {  # low to high
      $n ^= $bit;
    }
    return $n,0;
  }
}





{
  require Math::PlanePath::RationalsTree;
  my $path = Math::PlanePath::RationalsTree->new
    (
     tree_type => 'AYT',
     tree_type => 'CW',
     tree_type => 'SB',
    );

  foreach my $y (reverse 1 .. 10) {
    foreach my $x (1 .. 10) {
      my $n = $path->xy_to_n($x,$y);
      if (! defined $n) { $n = '' }
      printf (" %4s", $n);
    }
    print "\n";
  }
  exit 0;
}

{
  require Math::PlanePath::RationalsTree;
  my $path = Math::PlanePath::RationalsTree->new
    (
     tree_type => 'AYT',
     tree_type => 'CW',
     tree_type => 'SB',
    );

  foreach my $y (2 .. 10) {
    my $prev = 0;
    foreach my $x (1 .. 100) {
      my $n = $path->xy_to_n($x,$y) || next;
      if ($n < $prev) {
        print "not monotonic at X=$x,Y=$y n=$n prev=$prev\n";
      }
      $prev = $n;
    }
  }
  exit 0;
}
sub frac_lt {
  my ($p1,$q1, $p2,$q2) = @_;
  return ($p1*$q2 < $p2*$q1);
}
