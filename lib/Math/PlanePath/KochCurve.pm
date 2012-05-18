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


# math-image --path=KochCurve --lines --scale=10
# math-image --path=KochCurve --all --scale=10

# continuous but nowhere differentiable
#
# Sur une courbe continue sans tangente, obtenue par une construction
# géométrique élémentaire
#
# Cesàro, "Remarques sur la courbe de von Koch." Atti della
# R. Accad. della Scienze fisiche e matem. Napoli 12, No. 15, 1-12,
# 1905. Reprinted as §228 in Opere scelte, a cura dell'Unione matematica
# italiana e col contributo del Consiglio nazionale delle ricerche, Vol. 2:
# Geometria, analisi, fisica matematica. Rome: Edizioni Cremonese,
# pp. 464-479, 1964.
#
# Thue-Morse count 1s mod 2 is net direction
# Toeplitz first diffs is turn sequence +1 or -1


package Math::PlanePath::KochCurve;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 74;

use Math::PlanePath 54; # v.54 for _max()
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;
*_digit_split_lowtohigh = \&Math::PlanePath::_digit_split_lowtohigh;


use constant n_start => 0;
use constant class_x_negative => 0;
use constant class_y_negative => 0;

sub n_to_xy {
  my ($self, $n) = @_;
  ### KochCurve n_to_xy(): $n

  # secret negatives to -.5
  if (2*$n < -1) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  my $x;
  my $y;
  {
    my $int = int($n);
    $x = 2 * ($n - $int);  # usually positive, but n=-0.5 gives x=-0.5
    $y = $x * 0;           # inherit possible bigrat 0
    $n = $int;             # BigFloat int() gives BigInt, use that
  }

  my $len = $y+1;  # inherit bignum 1
  foreach my $digit (_digit_split_lowtohigh($n,4)) {
    ### at: "$x,$y  digit=$digit"

    if ($digit == 0) {

    } elsif ($digit == 1) {
      ($x,$y) = (($x-3*$y)/2 + 2*$len,     # rotate +60
                 ($x+$y)/2);

    } elsif ($digit == 2) {
      ($x,$y) = (($x+3*$y)/2 + 3*$len,    # rotate -60
                 ($y-$x)/2   + $len);

    } else {
      ### assert: $digit==3
      $x += 4*$len;
    }
    $len *= 3;
  }

  ### final: "$x,$y"
  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### KochPeaks xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($y < 0 || $x < 0 || (($x ^ $y) & 1)) {
    ### neg y or parity different ...
    return undef;
  }
  my ($len,$level) = _round_down_pow(($x/2)||1, 3);
  ### $level
  ### $len
  if (_is_infinite($level)) {
    return $level;
  }

  my $n = 0;
  foreach (0 .. $level) {
    $n *= 4;
    ### at: "level=$level len=$len   x=$x,y=$y  n=$n"
    if ($x < 3*$len) {
      if ($x < 2*$len) {
        ### digit 0 ...
      } else {
        ### digit 1 ...
        $x -= 2*$len;
        ($x,$y) = (($x+3*$y)/2,   # rotate -60
                   ($y-$x)/2);
        $n += 1;
      }
    } else {
      $x -= 4*$len;
      ### digit 2 or 3 to: "x=$x"
      if ($x < $y) {   # before diagonal
        ### digit 2...
        $x += $len;
        $y -= $len;
        ($x,$y) = (($x-3*$y)/2,     # rotate +60
                   ($x+$y)/2);
        $n += 2;
      } else {
        #### digit 3...
        $n += 3;
      }
    }
    $len /= 3;
  }
  ### end at: "x=$x,y=$y   n=$n"
  if ($x != 0 || $y != 0) {
    return undef;
  }
  return $n;
}

# level extends to x= 2*3^level
#                  level = log3(x/2)
#
# ENHANCE-ME:
# look for min/max by digits high to low
# chop search when segment of a given level+rotation outside rect
# rot=0,180 is box Ymax=len Xmax=6*len
# rot=60,120 is square to endpoint X=Y=3*len, triangle upper or lower
#
# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### KochCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = _round_nearest ($x1);
  $x2 = _round_nearest ($x2);
  $y1 = _round_nearest ($y1);
  $y2 = _round_nearest ($y2);
  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }

  if ($x2 < 0 || $y2 < 0
      || 3*$y1 > $x2 ) {   # above line Y=X/3
    return (1,0);
  }

  #        \
  #          \
  #       *    \
  #      / \     \
  # o-+-*   *-+-e  \
  # 0     3     6
  #
  # 3*Y+X/2 - (Y!=0)
  #
  #                  /
  #             *-+-*
  #              \
  #       *       *
  #      / \     /
  # o-+-*   *-+-* 
  # 0     3     6   X/2
  #
  my ($len, $level) = _round_down_pow ($x2/2, 3);
  return _rect_to_n_range_rot ($len, $level, 0, $x1,$y1, $x2,$y2);



  # (undef, my $level) = _round_down_pow ($x2/2, 3);
  # ### $level
  # return (0, 4**($level+1)-1);
}


my @rot_to_dx = (2,1,-1,-2,-1,1);
my @rot_to_dy = (0,1,1,0,-1,-1);
my @max_digit_to_rot = (1, -2, 1, 0);
my @min_digit_to_rot = (0, 1, -2, 1);
my @max_digit_to_offset = (-1, -1, -1, 2);
my @min_digit_to_offset = (1, 1, 1, 1);

sub _rect_to_n_range_rot {
  my ($initial_len, $level_max, $initial_rot, $x1,$y1, $x2,$y2) = @_;
  ### KochCurve _rect_to_n_range_rot(): "$x1,$y1  $x2,$y2  len=$initial_len level=$level_max rot=$initial_rot"

  my ($rot, $len, $x, $y);
  my $overlap = sub {
    my ($x, $y) = @_;
    ### overlap: "$x,$y len=$len rot=$rot"

    if ($len == 1) {
      return ($x >= $x1 && $x <= $x2
              && $y >= $y1 && $y <= $y2);
    }
    my $len = $len / 3;

    if ($rot < 3) {
      if ($rot == 0) {
        #       *
        #      / \
        # o-+-*   *-+-.
        return ($y <= $y2               # bottom before end
                && $y+$len >= $y1
                && $x <= $x2
                && $x+6*$len > $x1);    # right before end, exclusive
      } elsif ($rot == 1) {
        #       .
        #      /
        # *-+-*
        #  \
        #   *  +-----
        #  /   |x1,y2
        # o
        return ($x <= $x2              # left before end
                && $y+3*$len > $y1     # top after start, exclusive
                && $y-$x <= $y2-$x1);  # diag before corner
      } else {
        # .    |x1,y1
        #  \   +-----
        #   *
        #  /
        # *-+-*
        #      \
        #       o
        return ($y <= $y2              # bottom before end
                && $x-3*$len <=$x2     # left before end
                && $y+$x >= $y1+$x1);  # diag after corner
      }
    } else {
      if ($rot == 3) {
        # .-+-*   *-+-o
        #      \ /
        #       *
        return ($y >= $y1              # top after start
                && $y-$len <= $y2      # bottom before end
                && $x >= $x1           # right after start
                && $x-6*$len < $x2);   # left before end, exclusive
      } elsif ($rot == 4) {
        # x2,y1|    o
        # -----+   /
        #         *
        #          \
        #       *-+-*
        #      /
        #     .
        return ($x >= $x1              # right after start
                && $y-3*$len < $y2     # bottom before end, exclusive
                && $y-$x >= $y1-$x2);  # diag after corner
      } else {
        #    o
        #     \
        #      *-+-*
        #         /
        #        *
        # -----+  \
        # x2,y2|   .
        return ($y >= $y1              # top after start
                && $x+3*$len >= $x1    # right after start
                && $y+$x <= $y2+$x2);  # diag before corner
      }
    }
  };

  my @lens = ($initial_len);
  my $n_hi;
  my $zero;
  $rot = $initial_rot;
  $len = $initial_len;
  $x = 0;
  $y = 0;
  my @digits = (4);

  for (;;) {
    my $digit = --$digits[-1];
    ### max at: "digits=".join(',',@digits)."  xy=$x,$y   len=$len"

    if ($digit < 0) {
      pop @digits;
      if (! @digits) {
        ### nothing found to level_max ...
        return (1, 0);
      }
      ### end of digits, backtrack ...
      $len = $lens[$#digits];
      next;
    }

    my $offset = $max_digit_to_offset[$digit];
    $rot = ($rot - $max_digit_to_rot[$digit]) % 6;
    $x += $rot_to_dx[$rot] * $offset * $len;
    $y += $rot_to_dy[$rot] * $offset * $len;

    ### $offset
    ### $rot

    if (&$overlap ($x, $y, $len)) {
      if ($#digits >= $level_max) {
        ### yes overlap, found n_hi ...
        ### digits: join(',',@digits)
        ### n_hi: _digit_join_htol (\@digits, 4, 0)
        $zero = 0*$x1*$x2*$y1*$y2;
        $n_hi = _digit_join_htol (\@digits, 4, $zero);
        last;
      }
      ### yes overlap, descend ...
      push @digits, 4;
      $len = ($lens[$#digits] ||= $len/3);
    } else {
      ### no overlap, next digit ...
    }
  }

  $rot = $initial_rot;
  $x = 0;
  $y = 0;
  $len = $initial_len;
  @digits = (-1);

  for (;;) {
    my $digit = ++$digits[-1];
    ### min at: "digits=".join(',',@digits)."  xy=$x,$y   len=$len"

    if ($digit > 3) {
      pop @digits;
      if (! @digits) {
        ### oops, n_lo not found to level_max ...
        return (1, 0);
      }
      ### end of digits, backtrack ...
      $len = $lens[$#digits];
      next;
    }

    ### $digit
    ### rot increment: $min_digit_to_rot[$digit]
    $rot = ($rot + $min_digit_to_rot[$digit]) % 6;

    if (&$overlap ($x, $y, $len)) {
      if ($#digits >= $level_max) {
        ### yes overlap, found n_lo ...
        ### digits: join(',',@digits)
        ### n_lo: _digit_join_htol (\@digits, 4, $zero)
        return (_digit_join_htol (\@digits, 4, $zero),
                $n_hi);
      }
      ### yes overlap, descend ...
      push @digits, -1;
      $len = ($lens[$#digits] ||= $len/3);

    } else {
      ### no overlap, next digit ...
      ### offset: $min_digit_to_offset[$digit]

      my $offset = $min_digit_to_offset[$digit];
      $x += $rot_to_dx[$rot] * $offset * $len;
      $y += $rot_to_dy[$rot] * $offset * $len;
    }
  }
}

# $aref->[0] high digit
sub _digit_join_htol {
  my ($aref, $radix, $zero) = @_;
  my $n = $zero;
  foreach my $digit (@$aref) {
    $n *= $radix;
    $n += $digit;
  }
  return $n;
}



# integer only, not documented

my @digit_to_dir = (0, 1, -1, 0);
sub _n_to_TDir6 {
  my ($self, $n) = @_;
  my $digits = _digit_split_lowtohigharef($n,4) || return undef;
  my $dir = 0;
  foreach my $digit (@$digits) {
    $dir += $digit_to_dir[$digit];
  }
  return ($dir % 6);
}

my @dir_to_dx = (2, 1, -1, -2, -1, 1);
my @dir_to_dy = (0, 1, 1, 0, -1, -1, 0);
sub _n_to_dxdy {
  my ($self, $n) = @_;
  my $dir = $self->_n_to_TDir6($n);
  return ($dir_to_dx[$dir], $dir_to_dy[$dir]);
}

my @digit_to_Turn6 = (undef,
                      1,  # +60 degrees
                      -2, # -120 degrees
                      1); # +60 degrees
sub _n_to_Turn6 {
  my ($self, $n) = @_;
  if (_is_infinite($n)) {
    return undef;
  }
  while ($n) {
    if (my $digit = ($n % 4)) {
      return $digit_to_Turn6[$digit];
    }
    $n = int($n/4);
  }
}
sub _n_to_LSR {
  my ($self, $n) = @_;
  my $turn6 = $self->_n_to_Turn6($n) || return undef;
  return ($turn6 > 0 ? 1 : -1);
}
sub _n_to_Left {
  my ($self, $n) = @_;
  my $turn6 = $self->_n_to_Turn6($n) || return undef;
  return ($turn6 > 0 ? 1 : 0);
}
sub _n_to_Right {
  my ($self, $n) = @_;
  my $turn6 = $self->_n_to_Turn6($n) || return undef;
  return ($turn6 < 0 ? 1 : 0);
}

sub _digit_split_lowtohigharef {
  my ($n, $radix) = @_;
  ### _digit_split(): $n
  my @ret;
  unless (_is_infinite($n)) {
    while ($n) {
      push @ret, $n % $radix;
      $n = int($n/$radix);
    }
  }
  return \@ret;   # array[0] low digit
}



#------------------------------------------------------------------------------
# generic, shared

# Return ($pow, $exp) with $pow = $base**$exp <= $n,
# the next power of $base at or below $n.
#
# (ENHANCE-ME: Occasionally the $pow value is not wanted,
# eg. SierpinskiArrowhead, though that tends to be approximation code rather
# than exact range calculations etc.)
#
sub _round_down_pow {
  my ($n, $base) = @_;
  ### _round_down_pow(): "$n base $base"

  # only for integer bases
  ### assert: $base == int($base)

  if ($n < $base) {
    return (1, 0);
  }

  # Math::BigInt and Math::BigRat overloaded log() return NaN, use integer
  # based blog()
  if (ref $n) {
    if ($n->isa('Math::BigRat')) {
      $n = int($n);
    }
    if ($n->isa('Math::BigInt')) {
      ### use blog() ...
      my $exp = $n->copy->blog($base);
      ### exp: "$exp"
      return (Math::BigInt->new(1)->blsft($exp,$base),
              $exp);
    }
  }

  my $exp = int(log($n)/log($base));
  my $pow = $base**$exp;
  ### n:   ref($n)."  $n"
  ### exp: ref($exp)."  $exp"
  ### pow: ref($pow)."  $pow"

  # check how $pow actually falls against $n, not sure should trust float
  # rounding in log()/log($base)
  # Crib: $n as first arg in case $n==BigFloat and $pow==BigInt
  if ($n < $pow) {
    ### hmm, int(log) too big, decrease...
    $exp -= 1;
    $pow = $base**$exp;
  } elsif ($n >= $base*$pow) {
    ### hmm, int(log) too small, increase...
    $exp += 1;
    $pow *= $base;
  }
  return ($pow, $exp);
}

1;
__END__

=for stopwords eg Ryde Helge von Koch Math-PlanePath Nlevel differentiable ie OEIS

=head1 NAME

Math::PlanePath::KochCurve -- horizontal Koch curve

=head1 SYNOPSIS

 use Math::PlanePath::KochCurve;
 my $path = Math::PlanePath::KochCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

X<Koch, Helge von>
This is an integer version of the self-similar curve by Helge von Koch going
along the X axis and making triangular excursions upwards.

                               8                                   3
                             /  \
                      6---- 7     9----10                18-...    2
                       \              /                    \
             2           5          11          14          17     1
           /  \        /              \        /  \        /
     0----1     3---- 4                12----13    15----16    <- Y=0
     ^
    X=0   2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19

The replicating shape is the initial N=0 to N=4,

            *
           / \
      *---*   *---*

which is rotated and repeated 3 times in the same pattern to give sections
N=4 to N=8, N=8 to N=12, and N=12 to N=16.  Then that N=0 to N=16 is itself
replicated three times at the angles of the base pattern, and so on
infinitely.

The X,Y coordinates are arranged on a square grid using every second point,
per L<Math::PlanePath/Triangular Lattice>.  The result is flattened
triangular segments with diagonals at a 45 degree angle.

=head2 Level Ranges

Each replication adds 3 copies of the existing points and is thus 4 times
bigger, so if N=0 to N=4 is reckoned as level 1 then a given replication
level goes from

    Nstart = 0
    Nlevel = 4^level   (inclusive)

Each replication is 3 times the width.  The initial N=0 to N=4 figure is 6
wide and in general a level runs from

    Xstart = 0
    Xlevel = 2*3^level   (at N=Nlevel)

The highest Y is 3 times greater at each level similarly.  The peak is at
the midpoint of each level,

    Npeak = (4^level)/2
    Ypeak = 3^level
    Xpeak = 3^level

It can be seen that the N=6 point backtracks horizontally to the same X as
the start of its section N=4 to N=8.  This happens in the further
replications too and is the maximum extent of the backtracking.

The Nlevel is multiplied by 4 to get the end of the next higher level.  The
same 4*N can be applied to all points N=0 to N=Nlevel to get the same shape
but a factor of 3 bigger X,Y coordinates.  The in-between points 4*N+1,
4*N+2 and 4*N+3 are then new finer structure in the higher level.

=head2 Fractal

Koch conceived the curve as having a fixed length and infinitely fine
structure, making it continuous everywhere but differentiable nowhere.  The
code here can be pressed into use for that sort of construction for a given
level of granularity by scaling

    X/3^level
    Y/3^level

which makes it a fixed 2 wide by 1 high.  Or for unit-side equilateral
triangles then apply further factors 1/2 and sqrt(3)/2, as noted in
L<Math::PlanePath/Triangular Lattice>.

    (X/2) / 3^level
    (Y*sqrt(3)/2) / 3^level

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::KochCurve-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

The returned range is exact, meaning C<$n_lo> and C<$n_hi> are the smallest
and biggest in the rectangle.

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 FORMULAS

=head2 Turn Sequence

The sequence of turns made by the curve is straightforward.  The curve
always turns either +60 degrees or -120 degrees, it never goes straight
ahead.  In the base 4 representation of N the lowest non-zero digit gives
the turn

   low digit       turn
   ---------   ------------
      1         +60 degrees (left)
      2        -120 degrees (right)
      3         +60 degrees (left)

For example N=8 is 20 base 4, so lowest nonzero "2" means turn -120 degrees
for the next segment.

When the least significant digit is non-zero it determines the turn, making
the base N=0 to N=4 shape.  When the low digit is zero then the next level
up is in control, eg. N=0,4,8,12,16, making a turn where the base shape
repeats.

=head2 Net Direction

The cumulative turn at a given N can be found by counting digits 1 and 2 in
base 4.

    direction = 60 * ((count of 1 digits in base 4)
                      - (count of 2 digits in base 4))  degrees

For example N=11 is 23 in base 4, so 60*(0-1) = -60 degrees.

In this formula the count of 1s and 2s can go past 360 degrees, representing
a spiralling around which occurs at progressively higher replication levels.
The direction can be taken mod 360 degrees, or the count mod 6, for a
direction 0 to 5 or as desired.

=head1 OEIS

The Koch curve is in Sloane's Online Encyclopedia of Integer Sequences in
various forms,

    http://oeis.org/A035263  (etc)

    A035263 -- turn 1=left,0=right, by morphism
    A096268 -- turn 0=left,1=right, by morphism
    A029883 -- turn +/-1=left,0=right, Thue-Morse first differences
    A089045 -- turn +/-1=left,0=right, by +/- something

    A003159 -- N positions of left turns, ending even number 0 bits
    A036554 -- N positions of right turns, ending odd number 0 bits

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PeanoCurve>,
L<Math::PlanePath::HilbertCurve>,
L<Math::PlanePath::KochPeaks>,
L<Math::PlanePath::KochSnowflakes>

L<Math::Fractal::Curve>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011, 2012 Kevin Ryde

Math-PlanePath is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

Math-PlanePath is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-PlanePath.  If not, see <http://www.gnu.org/licenses/>.

=cut
