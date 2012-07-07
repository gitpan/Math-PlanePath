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
use Math::Libm 'M_PI', 'hypot';
use Math::PlanePath;;
*_divrem_destructive = \&Math::PlanePath::_divrem_destructive;

# uncomment this to run the ### lines
#use Smart::Comments;


{
  # turn sequence -- working for integers

  require Math::PlanePath::Flowsnake;
  require Math::NumSeq::PlanePathTurn;
  require Math::NumSeq::PlanePathDelta;

  # 0  straight
  # 1  +60 rev
  # 2  180 rev
  # 3  +240
  # 4  straight
  # 5  straight
  # 6  -60 rev

  # 4---- 5---- 6
  #  \           \
  #    3---- 2    7
  #        /
  # 0---- 1
  # turn(N) = tdir6(N)-tdir6(N-1)
  # N-1 changes low 0s to low 6s
  # N   = aaad000
  # N-1 = aaac666
  # low 0s no change to direction
  # low 6s state 7
  # N=14=20[7] dir[2]=3,dirrev[0]=5 total 3+5=2mod6
  # N-1=13=16[7] dir[1]=1,dirrev[6]=0 total 1+0=1  diff 2-1=1
  # dir[2]-dir[1]=2
  # dirrev[0] since digit=2 goes to rev
  # N=23=32[7]

  my @turn6 = (0,1,2,5,4,0,5,
               0,1,0,2,1,4,5,
               0,1,1,5,5,1,5,
               0,1,5,1,1,5,5,
              );
  my @digit_to_state = (0,7,7,0,0,0,7);
  sub n_to_turn6 {
    my ($self, $n) = @_;
    unless ($n >= 1) {
      return undef;
    }

    my $lowdigit = _divrem_destructive($n,7);
    ### $lowdigit

    # skip low 0s
    unless ($lowdigit) {
      while ($n) {
        last if ($lowdigit = _divrem_destructive($n,7));
      }
      # flag that some zeros were skipped
      $lowdigit += 14;
      ### $lowdigit
    }

    # forward/reverse state from lowest non-3
    for (;;) {
      my $digit = _divrem_destructive($n,7);
      if ($digit != 3) {
        $lowdigit += $digit_to_state[$digit];
        last;
      }
    }

    ### lookup: $lowdigit
    return $turn6[$lowdigit];
  }
  my @next_state = (0,7,7,0,0,0,7,
                    0,7,7,7,0,0,7);
  my @tdir6 = (0,1,3,2,0,0,5,
               5,0,0,2,3,1,0);
  sub n_to_tdir6 {
    my ($self, $n) = @_;
    unless ($n >= 0) {
      return undef;
    }
    my $state = 0;
    my $tdir6 = 0;
    foreach my $digit (reverse Math::PlanePath::_digit_split_lowtohigh($n,7)) {
      $state += $digit;
      $tdir6 += $tdir6[$state];
      $state = $next_state[$state];
    }
    return $tdir6 % 6;
  }
  sub _digit_lowest {
    my ($n, $radix) = @_;
    my $digit;
    for (;;) {
      last if ($digit = ($n % 7));
      $n /= 7;
      last unless $n;
    }
    # if ($digit < 1_000_000) {
    #   $digit = "$digit";
    # }
    return $digit;
  }

  {
    my $class = 'Math::PlanePath::Flowsnake';
    my $path = $class->new;
    my $seq = Math::NumSeq::PlanePathDelta->new (planepath=>'Flowsnake',
                                                 delta_type => 'TDir6');
    for (my $n = 1; $n < 7**3; $n+=1) {
      my $value = ($seq->ith($n) - $seq->ith($n-1)) % 6;
      my $turn = n_to_turn6($path,$n);
      my $diff = ($value != $turn ? '   ***' : '');
      print "$n  $value $turn$diff\n";
    }
    exit 0;
  }
  {
    my $class = 'Math::PlanePath::Flowsnake';
    my $path = $class->new;
    my $seq = Math::NumSeq::PlanePathDelta->new (planepath=>'Flowsnake',
                                                 delta_type => 'TDir6');
    for (my $n = 0; $n < 7**3; $n+=1) {
      my $value = $seq->ith($n);
      my $tdir6 = n_to_tdir6($path,$n);
      my $diff = ($value != $tdir6 ? '   ***' : '');
      print "$n  $value $tdir6$diff\n";
    }
    exit 0;
  }
}
{
  require Math::BaseCnv;
  require Math::PlanePath::Flowsnake;
  require Math::PlanePath::FlowsnakeCentres;
  my $f = Math::PlanePath::Flowsnake->new (arms => 2);
  my $c = Math::PlanePath::FlowsnakeCentres->new (arms => 2);
  my $width = 5;
  my %saw;
  foreach my $n (0 .. 7**($width-1)) {
    my ($x,$y) = $f->n_to_xy($n);

    my $cn = $c->xy_to_n($x,$y) // -1;

    my $cr = $c->xy_to_n($x+2, $y) // -1;
    my $ch = $c->xy_to_n($x+1,$y+1) // -1;
    my $cw = $c->xy_to_n($x-1,$y+1) // -1;
    my $cl = $c->xy_to_n($x-2,$y) // -1;       # <------
    my $cu = $c->xy_to_n($x-1,$y-1) // -1;     # <------3
    my $cz = $c->xy_to_n($x+1,$y-1) // -1;

    if ($n == $cn) { $saw{'n'} = 0; }
    if ($n == $cr) { $saw{'r'} = 1; }
    if ($n == $ch) { $saw{'h'} = 2; }
    if ($n == $cw) { $saw{'w'} = 3; }
    if ($n == $cl) { $saw{'l'} = 4; }
    if ($n == $cu) { $saw{'u'} = 5; }
    if ($n == $cz) { $saw{'z'} = 6; }

    unless (($n == $cn)
            || ($n == $cr)
            || ($n == $ch)
            || ($n == $cw)
            || ($n == $cl)
            || ($n == $cu)
            || ($n == $cz)) {
      die "no match $n: $cn,$cr,$ch,$cw,$cl,$cu,$cz";
    }
  }
  my $saw = join(',', sort {$saw{$a}<=>$saw{$b}} keys %saw);
  print "$saw\n";
  exit 0;
}
{
  require Math::PlanePath::Flowsnake;
  require Math::PlanePath::FlowsnakeCentres;
  say Math::PlanePath::Flowsnake->isa('Math::PlanePath::FlowsnakeCentres');
  say Math::PlanePath::FlowsnakeCentres->isa('Math::PlanePath::Flowsnake');
  say Math::PlanePath::Flowsnake->can('xy_to_n');
  say Math::PlanePath::FlowsnakeCentres->can('xy_to_n');
  exit 0;
}

{
  require Math::BaseCnv;
  require Math::PlanePath::Flowsnake;
  require Math::PlanePath::FlowsnakeCentres;
  my $c = Math::PlanePath::Flowsnake->new;
  my $f = Math::PlanePath::FlowsnakeCentres->new;
  my $width = 5;
  my %saw;
  foreach my $n (0 .. 7**($width-1)) {
    my $n7 = sprintf '%*s', $width, Math::BaseCnv::cnv($n,10,7);
    my ($x,$y) = $f->n_to_xy($n);

    my $cn = $c->xy_to_n($x,$y) || -1;
    my $cn7 = sprintf '%*s', $width, Math::BaseCnv::cnv($cn,10,7);

    my $rx = $x + 1;
    my $ry = $y + 1;
    my $cr = $c->xy_to_n($rx,$ry) || -1;
    my $cr7 = sprintf '%*s', $width, Math::BaseCnv::cnv($cr,10,7);

    my $hx = $x + 1;
    my $hy = $y + 1;
    my $ch = $c->xy_to_n($hx,$hy) || -1;
    my $ch7 = sprintf '%*s', $width, Math::BaseCnv::cnv($ch,10,7);

    my $wx = $x - 1;
    my $wy = $y + 1;
    my $cw = $c->xy_to_n($wx,$wy) || -1;
    my $cw7 = sprintf '%*s', $width, Math::BaseCnv::cnv($cw,10,7);

    my $lx = $x - 2;
    my $ly = $y;
    my $cl = $c->xy_to_n($lx,$ly) || -1;
    my $cl7 = sprintf '%*s', $width, Math::BaseCnv::cnv($cl,10,7);

    my $ux = $x - 1;
    my $uy = $y - 1;
    my $cu = $c->xy_to_n($ux,$uy) || -1;
    my $cu7 = sprintf '%*s', $width, Math::BaseCnv::cnv($cu,10,7);

    my $zx = $x + 1;
    my $zy = $y - 1;
    my $cz = $c->xy_to_n($zx,$zy) || -1;
    my $cz7 = sprintf '%*s', $width, Math::BaseCnv::cnv($cz,10,7);

    if ($n == $cn) { $saw{'n'} = 0; }
    if ($n == $cr) { $saw{'r'} = 1; }
    if ($n == $ch) { $saw{'h'} = 2; }
    if ($n == $cw) { $saw{'w'} = 3; }
    if ($n == $cl) { $saw{'l'} = 4; }
    if ($n == $cu) { $saw{'u'} = 5; }
    if ($n == $cz) { $saw{'z'} = 6; }
    my $bad = ($n == $cn
               || $n == $cr
               || $n == $ch
               || $n == $cw
               || $n == $cl
               || $n == $cu
               || $n == $cz
               ? ''
               : '  ******');

    # print "$n7 $cn7 $ch7 $cw7 $cu7   $bad\n";
  }
  my $saw = join(',', sort {$saw{$a}<=>$saw{$b}} keys %saw);
  print "$saw\n";
  exit 0;
}

{
  require Math::BaseCnv;
  require Math::PlanePath::Flowsnake;
  my $path = Math::PlanePath::Flowsnake->new;

  foreach my $y (reverse -5 .. 40) {
    printf "%3d ", $y;
    foreach my $x (-20 .. 15) {
      my $n = $path->xy_to_n($x,$y);
      if (! defined $n) {
        print "  ";
        next;
      }

      my $nh = $n - ($n%7);
      my ($hx,$hy) = $path->n_to_xy($nh);
      my $pos = '?';
      if ($hy > $y) {
        $pos = 'T';
      } if ($hx > $x) {
        $pos = '.';
      } else {
        $pos = '*';
        $pos = $n%7;
      }

      print "$pos ";
    }
    print "\n";
  }
  exit 0;
}

{
  require Math::BaseCnv;
  require Math::PlanePath::Flowsnake;
  require Math::PlanePath::FlowsnakeCentres;
  my $f = Math::PlanePath::Flowsnake->new;
  my $c = Math::PlanePath::FlowsnakeCentres->new;
  my $width = 5;
  foreach my $n (0 .. 7**($width-1)) {
    my $n7 = sprintf '%*s', $width, Math::BaseCnv::cnv($n,10,7);
    my ($x,$y) = $f->n_to_xy($n);

    my $cn = $c->xy_to_n($x,$y) || 0;
    my $cn7 = sprintf '%*s', $width, Math::BaseCnv::cnv($cn,10,7);

    my $m = ($x + 2*$y) % 7;
    if ($m == 2) {  # 2,0  = 2
      $x -= 2;
    } elsif ($m == 5) {  # 3,1 = 3+2*1 = 5
      $x -= 3;
      $y -= 1;
    } elsif ($m == 3) {  # 1,1 = 1+2 = 3
      $x -= 1;
      $y -= 1;
    } elsif ($m == 4) {  # 0,2 = 0+2*2 = 4
      $y -= 2;
    } elsif ($m == 6) {  # 2,2 = 2+2*2 = 6
      $x -= 2;
      $y -= 2;
    } elsif ($m == 1) {  # 4,2 = 4+2*2 = 8 = 1
      $x -= 4;
      $y -= 2;
    }
    my $mn = $c->xy_to_n($x,$y) || 0;
    my $mn7 = sprintf '%*s', $width, Math::BaseCnv::cnv($mn,10,7);

    my $nh = $n - ($n%7);
    my $mh = $mn - ($mn%7);

    my $diff = ($nh == $mh ? "" : "   **");
    print "$n7 $mn7   $cn7$diff\n";
  }
  exit 0;
}

{
  # xy_to_n
  require Math::PlanePath::Flowsnake;
  require Math::PlanePath::FlowsnakeCentres;
  my $path = Math::PlanePath::FlowsnakeCentres->new;
  my $k = 4000;
  my ($n_lo,$n_hi) = $path->rect_to_n_range(-$k,-$k, $k,$k);
  print "$n_lo, $n_hi\n";
  exit 0;
}

{
  # xy_to_n
  require Math::PlanePath::Flowsnake;
  require Math::PlanePath::FlowsnakeCentres;
  my $path = Math::PlanePath::FlowsnakeCentres->new;
  my $y = 0;
  for (my $x = 6; $x >= -5; $x-=2) {
    $x -= ($x^$y)&1;
    my $n = $path->xy_to_n($x,$y);
    print "$x,$y   ",($n//'undef'),"\n";
  }
  exit 0;
}

{
  # modulo
  require Math::PlanePath::Flowsnake;
  my $path = Math::PlanePath::Flowsnake->new;
  for (my $n = 0; $n <= 49; $n++) {
    if (($n % 7) == 0) { print "\n"; }
    my ($x,$y) = $path->n_to_xy($n);
    my $c = $x + 2*$y;
    my $m = $c % 7;
    print "$n  $x,$y  $c  $m\n";
  }
  exit 0;
}
{
  require Math::PlanePath::Flowsnake;
  my $path = Math::PlanePath::Flowsnake->new;
  for (my $n = 0; $n <= 49; $n+=7) {
    my ($x,$y) = $path->n_to_xy($n);
    my ($rx,$ry) = ((3*$y + 5*$x) / 14,
                    (5*$y - $x) / 14);
    print "$n  $x,$y  $rx,$ry\n";
  }
  exit 0;
}
  
{
  # radius
  require Math::PlanePath::Flowsnake;
  my $path = Math::PlanePath::Flowsnake->new;
  my $prev_max = 1;
  for (my $level = 1; $level < 10; $level++) {
    print "level $level\n";

    my ($x2,$y2) = $path->n_to_xy(2 * 7**($level-1));
    my ($x3,$y3) = $path->n_to_xy(3 * 7**($level-1));
    my $cx = ($x2+$x3)/2;
    my $cy = ($y2+$y3)/2;
    my $max_hypot = 0;
    my $max_pos = '';
    foreach my $n (0 .. 7**$level - 1) {
      my ($x,$y) = $path->n_to_xy($n);
      my $h = ($x-$cx)**2 + 3*($y-$cy);
      if ($h > $max_hypot) {
        $max_hypot = $h;
        $max_pos = "$x,$y";
      }
    }
    my $factor = $max_hypot / $prev_max;
    $prev_max = $max_hypot;
    print "  cx=$cx,cy=$cy  max $max_hypot   at $max_pos  factor $factor\n";
  }
  exit 0;
}


{
  require Math::PlanePath::Flowsnake;
  my $path = Math::PlanePath::Flowsnake->new;
  my $prev_max = 1;
  for (my $level = 1; $level < 10; $level++) {
    my $n_start = 0;
    my $n_end = 7**$level - 1;
    my $min_hypot = $n_end;
    my $min_x = 0;
    my $min_y = 0;
    my $max_hypot = 0;
    my $max_pos = '';
    print "level $level\n";
    my ($xend,$yend) = $path->n_to_xy(7**($level-1));
    print "   end $xend,$yend\n";
    $yend *= sqrt(3);
    my $cx = -$yend;  # rotate +90
    my $cy = $xend;
    print "   rot90  $cx, $cy\n";
    # $cx *= sqrt(3/4) * .5;
    # $cy *= sqrt(3/4) * .5;
    $cx *= 1.5;
    $cy *= 1.5;
    print "   scale  $cx, $cy\n";
    $cx += $xend;
    $cy += $yend;
    print "   offset to  $cx, $cy\n";
    $cy /= sqrt(3);
    printf "  centre %.1f, %.1f\n", $cx,$cy;
    foreach my $n ($n_start .. $n_end) {
      my ($x,$y) = $path->n_to_xy($n);
      my $h = ($cx-$x)**2 + 3*($cy-$y)**2;

      if ($h > $max_hypot) {
        $max_hypot = $h;
        $max_pos = "$x,$y";
      }
      # if ($h < $min_hypot) {
      #   $min_hypot = $h;
      #   $min_x = $x;
      #   $min_y = $y;
      # }
    }
    # print "  min $min_hypot   at $min_x,$min_y\n";
    my $factor = $max_hypot / $prev_max;
    print "  max $max_hypot   at $max_pos  factor $factor\n";
    $prev_max = $max_hypot;
  }
  exit 0;
}

{
  # diameter
  require Math::PlanePath::Flowsnake;
  my $path = Math::PlanePath::Flowsnake->new;
  my $prev_max = 1;
  for (my $level = 1; $level < 10; $level++) {
    print "level $level\n";
    my $n_start = 0;
    my $n_end = 7**$level - 1;
    my ($xend,$yend) = $path->n_to_xy($n_end);
    print "   end $xend,$yend\n";
    my @x;
    my @y;
    foreach my $n ($n_start .. $n_end) {
      my ($x,$y) = $path->n_to_xy($n);
      push @x, $x;
      push @y, $y;
    }
    my $max_hypot = 0;
    my $max_pos = '';
    my ($cx,$cy);
    foreach my $i (0 .. $#x-1) {
      foreach my $j (1 .. $#x) {
        my $h = ($x[$i]-$x[$j])**2 + 3*($y[$i]-$y[$j]);
        if ($h > $max_hypot) {
          $max_hypot = $h;
          $max_pos = "$x[$i],$y[$i], $x[$j],$y[$j]";
          $cx = ($x[$i] + $x[$j]) / 2;
          $cy = ($y[$i] + $y[$j]) / 2;
        }
      }
    }
    my $factor = $max_hypot / $prev_max;
    print "  max $max_hypot   at $max_pos  factor $factor\n";
    $prev_max = $max_hypot;
  }

  exit 0;
}

{
  require Math::PlanePath::GosperIslands;
  my $path = Math::PlanePath::GosperIslands->new;
  foreach my $level (0 .. 20) {
    my $n_start = 3**($level+1) - 2;
    my $n_end = 3**($level+2) - 2 - 1;
    my ($prev_x) = $path->n_to_xy($n_start);
    foreach my $n ($n_start .. $n_end) {
      my ($x,$y) = $path->n_to_xy($n);

      # if ($y == 0 && $x > 0) {
      #   print "level $level  x=$x y=$y n=$n\n";
      # }

      if (($prev_x>0) != ($x>0) && $y > 0) {
        print "level $level  x=$x y=$y n=$n\n";
      }
      $prev_x = $x;
    }
    print "\n";
  }
  exit 0;
}



sub hij_to_xy {
  my ($h, $i, $j) = @_;
  return ($h*2 + $i - $j,
          $i+$j);
}

{
  # y<0 at n=8598  x=-79,y=-1
  require Math::PlanePath::Flowsnake;
  my $path = Math::PlanePath::Flowsnake->new;
  for (my $n = 3; ; $n++) {
    my ($x,$y) = $path->n_to_xy($n);
    if ($y == 0) {
      print "zero n=$n  $x,$y\n";
    }
    if ($y < 0) {
      print "yneg n=$n  $x,$y\n";
      exit 0;
    }
    # if ($y < 0 && $x >= 0) {
    #   print "yneg n=$n  $x,$y\n";
    #   exit 0;
    # }
  }
  exit 0;
}

{
  {
    my $sh = 1;
    my $si = 0;
    my $sj = 0;
    my $n = 1;
    foreach my $level (1 .. 20) {
      $n *= 7;
      ($sh, $si, $sj) = (2*$sh - $sj,
                         2*$si + $sh,
                         2*$sj + $si);
      my ($x, $y) = hij_to_xy($sh,$si,$sj);
      $n = sprintf ("%f",$n);
      print "$level $n  $sh,$si,$sj  $x,$y\n";
    }
  }
  exit 0;
}


our $level;

my $n = 0;
my $x = 0;
my $y = 0;

my %seen;
my @row;
my $x_offset = 8;
my $dir = 0;

sub step {
  $dir %= 6;
  print "$n  $x, $y   dir=$dir\n";
  my $key = "$x,$y";
  if (defined $seen{$key}) {
    print "repeat   $x, $y  from $seen{$key}\n";
  }
  $seen{"$x,$y"} = $n;
  if ($y >= 0) {
    $row[$y]->[$x+$x_offset] = $n;
  }

  if ($dir == 0) { $x += 2; }
  elsif ($dir == 1) { $x++, $y++; }
  elsif ($dir == 2) { $x--, $y++; }
  elsif ($dir == 3) { $x -= 2; }
  elsif ($dir == 4) { $x--, $y--; }
  elsif ($dir == 5) { $x++, $y--; }
  else { die; }
  $n++;
}

sub forward {
  if ($level == 1) {
    step ();
    return;
  }
  local $level = $level-1;
  forward(); $dir++;           # 0
  backward(); $dir += 2;       # 1
  backward(); $dir--;          # 2
  forward(); $dir -= 2;           # 3
  forward();                   # 4
  forward();  $dir--;                 # 5
  backward(); $dir++;          # 6
}

sub backward {
  my ($dir) = @_;
  if ($level == 1) {
    step ();
    return;
  }
  print "backward\n";
  local $level = $level-1;

  $dir += 2;
  forward();
  forward();
  $dir--;                 # 5
  forward();
  $dir--;                 # 5
  forward();
  $dir--;                 # 5
  backward();
  $dir--;                 # 5
  backward();
  $dir--;                 # 5
  forward();
  $dir--;                 # 5
}

$level = 3;
forward (2);


foreach my $y (reverse 0 .. $#row) {
  my $aref = $row[$y];
  foreach my $x (0 .. $#$aref) {
    printf ('%*s', 3, (defined $aref->[$x] ? $aref->[$x] : ''));
  }
  print "\n";
}
