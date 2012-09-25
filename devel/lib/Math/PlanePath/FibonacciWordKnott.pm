# Copyright 2011, 2012 Kevin Ryde

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


# http://alexis.monnerot-dumaine.neuf.fr/articles/fibonacci%20fractal.pdf
# [gone]
#
# math-image --path=FibonacciWordKnott --output=numbers_dash


package Math::PlanePath::FibonacciWordKnott;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 89;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;
use constant class_x_negative => 0;
use constant class_y_negative => 0;

my @rot_to_sx = (0,-1,0,1);
my @rot_to_sy = (1,0,-1,0);

sub n_to_xy {
  my ($self, $n) = @_;
  ### FibonacciWordKnott n_to_xy(): $n

  if ($n < 0) { return; }
  if (is_infinite($n)) { return ($n, $n); }

  # my $frac;
  # {
  #   my $int = int($n);
  #   $frac = $n - $int;  # inherit possible BigFloat
  #   $n = $int;          # BigFloat int() gives BigInt, use that
  # }
  {
    my $int = int($n);
    ### $int
    ### $n
    if ($n != $int) {
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $frac = $n - $int;  # inherit possible BigFloat
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int;       # BigFloat int() gives BigInt, use that
  }

  my $zero = ($n * 0);  # inherit bignum 0
  my $one = $zero + 1;  # inherit bignum 0

  my @f = ($one, 2+$zero);
  my @xend = ($zero, $zero, $one);     # F3 N=2 X=1,Y=1
  my @yend = ($zero, $one, $one);
  my $level = 2;
  while ($f[-1] < $n) {
    push @f, $f[-1] + $f[-2];

    my ($x,$y);
    if (($level % 6) == 1) {
      $x = $yend[-2];     # -90
      $y = - $xend[-2];
    } elsif (($level % 6) == 2) {
      $x = $xend[-2];     # T -90
      $y = - $yend[-2];
    } elsif (($level % 6) == 3) {
      $x = $yend[-2];     # T
      $y = $xend[-2];

    } elsif (($level % 6) == 4) {
      $x = - $yend[-2];      # +90
      $y = $xend[-2];
    } elsif (($level % 6) == 5) {
      $x = - $xend[-2];     # T +90
      $y = $yend[-2];
    } elsif (($level % 6) == 0) {
      $x = $yend[-2];     # T
      $y = $xend[-2];
    }

    push @xend, $xend[-1] + $x;
    push @yend, $yend[-1] + $y;
    ### push xy: "levelmod=".($level%6)." add $x,$y for $xend[-1],$yend[-1]  for f=$f[-1]"
    $level++;
  }

  my $x = $zero;
  my $y = $zero;
  my $rot = 0;
  my $transpose = 0;

  while (@xend > 1) {
    ### at: "$x,$y  rot=$rot transpose=$transpose level=$level   n=$n consider f=$f[-1]"
    my $xo = pop @xend;
    my $yo = pop @yend;

    if ($n >= $f[-1]) {
      $n -= $f[-1];
      ### offset: "$xo, $yo  for ".($level % 6)

      if ($transpose) {
        ($xo,$yo) = ($yo,$xo);
      }
      if ($rot & 2) {
        $xo = -$xo;
        $yo = -$yo;
      }
      if ($rot & 1) {
        ($xo,$yo) = (-$yo,$xo);
      }
      ### apply rot to offset: "$xo, $yo"

      $x += $xo;
      $y += $yo;

      if (($level % 6) == 1) {         # F8 N=21 etc
        # -90
        if ($transpose) {
          $rot++;
        } else {
          $rot--;   # -90
        }

      } elsif (($level % 6) == 2) {    # F3 N=2 etc
        # T -90
        if ($transpose) {
          $rot++;
        } else {
          $rot--;   # -90
        }
        $transpose ^= 3;
      } elsif (($level % 6) == 3) {    # F4 N=3 etc
        $transpose ^= 3;  # T

      } elsif (($level % 6) == 4) {    # F5 N=5 etc
        # +90
        if ($transpose) {
          $rot--;
        } else {
          $rot++;   # +90
        }
      } elsif (($level % 6) == 5) {    # F6 N=8 etc
        # T +90
        if ($transpose) {
          $rot--;
        } else {
          $rot++;   # +90
        }
        $transpose ^= 3;
      } else {  # (($level % 6) == 0)  # F7 N=13 etc
        $transpose ^= 3;  # T
      }
    }
    pop @f;
    $level--;
  }

  # mod 6 twist ?
  # ### final rot: "$rot  transpose=$transpose gives ".(($rot^$transpose)&3)
  # $rot = ($rot ^ $transpose) & 3;
  # $x = $frac * $rot_to_sx[$rot] + $x;
  # $y = $frac * $rot_to_sy[$rot] + $y;

  ### final with frac: "$x,$y"
  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### FibonacciWordKnott xy_to_n(): "$x, $y"

  $x = round_nearest($x);
  if (is_infinite($x)) {
    return $x;
  }

  $y = round_nearest($y);
  if (is_infinite($y)) {
    return $y;
  }

  my $zero = ($x * 0 * $y);  # inherit bignum 0
  my $one = $zero + 1;       # inherit bignum 0

  my @f = ($one, $zero+2);
  my @xend = ($zero, $one);  # F3 N=2 X=1,Y=1
  my @yend = ($one, $one);
  my $level = 3;

  for (;;) {
    my ($xo,$yo);
    if (($level % 6) == 2) {
      $xo = $yend[-2];     # T
      $yo = $xend[-2];
    } elsif (($level % 6) == 3) {
      $xo = $yend[-2];      # -90
      $yo = - $xend[-2];
    } elsif (($level % 6) == 4) {
      $xo = $xend[-2];     # T -90
      $yo = - $yend[-2];

    } elsif (($level % 6) == 5) {
      ### T
      $xo = $yend[-2];     # T
      $yo = $xend[-2];
    } elsif (($level % 6) == 0) {
      $xo = - $yend[-2];     # +90
      $yo = $xend[-2];
    } elsif (($level % 6) == 1) {
      $xo = - $xend[-2];     # T +90
      $yo = $yend[-2];
    }

    $xo += $xend[-1];
    $yo += $yend[-1];
    last if ($xo > $x && $yo > $y);

    push @f, $f[-1] + $f[-2];
    push @xend, $xo;
    push @yend, $yo;
    $level++;
    ### new: "level=$level  $xend[-1],$yend[-1]  for N=$f[-1]"
  }

  my $n = 0;
  while ($level >= 2) {
    ### at: "$x,$y  n=$n level=$level consider $xend[-1],$yend[-1] for $f[-1]"

    if (($level+3) % 6 < 3) {
      ### 3,4,5 X ...
      if ($x >= $xend[-1]) {
        $n += $f[-1];
        $x -= $xend[-1];
        $y -= $yend[-1];
        ### shift to: "$x,$y  levelmod ".($level % 6)

        if (($level % 6) == 3) {          # F3 N=2 etc
          ($x,$y) = (-$y,$x);  # +90
        } elsif (($level % 6) == 4) {     # F4 N=3 etc
          $y = -$y;            # +90 T
        } elsif (($level % 6) == 5) {     # F5 N=5 etc
          ($x,$y) = ($y,$x);   # T
        }
        ### rot to: "$x,$y"
        if ($x < 0 || $y < 0) {
          return undef;
        }
      }
    } else {
      ### 0,1,2 Y ...
      if ($y >= $yend[-1]) {
        $n += $f[-1];
        $x -= $xend[-1];
        $y -= $yend[-1];
        ### shift to: "$x,$y  levelmod ".($level % 6)

        if (($level % 6) == 0) {          # F6 N=8 etc
          ($x,$y) = ($y,-$x);  # -90
        } elsif (($level % 6) == 1) {     # F7 N=13 etc
          $x = -$x;            # -90 T
        } elsif (($level % 6) == 2) {     # F8 N=21 etc, incl F2 N=1
          ($x,$y) = ($y,$x);   # T
        }
        ### rot to: "$x,$y"
        if ($x < 0 || $y < 0) {
          return undef;
        }
      }
    }

    pop @f;
    pop @xend;
    pop @yend;
    $level--;
  }

  if ($x != 0 || $y != 0) {
    return undef;
  }
  return $n;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### FibonacciWordKnott rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = round_nearest ($x1);
  $y1 = round_nearest ($y1);
  $x2 = round_nearest ($x2);
  $y2 = round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### rect_to_n_range(): "$x1,$y1 to $x2,$y2"

  if ($x2 < 0 || $y2 < 0) {
    return (1, 0);
  }
  foreach ($x1,$x2,$y1,$y2) {
    if (is_infinite($_)) { return (0, $_); }
  }

  my $zero = ($x1 * 0 * $y1 * $x2 * $y2);  # inherit bignum 0
  my $one = $zero + 1;                     # inherit bignum 0

  my $f0 = 1;
  my $f1 = 2;
  my $xend0 = $zero;
  my $xend1 = $one;
  my $yend0 = $one;
  my $yend1 = $one;
  my $level = 3;

  for (;;) {
    my ($xo,$yo);
    if (($level % 6) == 3) {         # at F3 N=2 etc
      $xo = $yend0;     # -90
      $yo = - $xend0;
    } elsif (($level % 6) == 4) {    # at F4 N=3 etc
      $xo = $xend0;     # T -90
      $yo = - $yend0;

    } elsif (($level % 6) == 5) {    # at F5 N=5 etc
      $xo = $yend0;     # T
      $yo = $xend0;
    } elsif (($level % 6) == 0) {    # at F6 N=8 etc
      $xo = - $yend0;   # +90
      $yo = $xend0;
    } elsif (($level % 6) == 1) {    # at F7 N=13 etc
      $xo = - $xend0;   # T +90
      $yo = $yend0;
    } else {   #  if (($level % 6) == 2) {    # at F8 N=21 etc
      $xo = $yend0;     # T
      $yo = $xend0;
    }

    ($f1,$f0) = ($f1+$f0,$f1);
    ($xend1,$xend0) = ($xend1+$xo,$xend1);
    ($yend1,$yend0) = ($yend1+$yo,$yend1);
    $level++;

    ### consider: "f1=$f1  xy end $xend1,$yend1"
    if ($xend1 > $x2 && $yend1 > $y2) {
      return (0, $f1 - 1);
    }
  }
}

1;
__END__
