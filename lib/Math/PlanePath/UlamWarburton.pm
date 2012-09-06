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


# math-image --path=UlamWarburton --all --output=numbers --size=80x50
#
# A147610 - 3^(ones(n-1) - 1)
# A048883 - 3^(ones n)

# A160117 peninsula and bridges
# A160118 similar but all 8 directions around single-touching peninsula
# A160415   first diffs
# A160796 with initial single 1
# A160797   first diffs
# A188343


package Math::PlanePath::UlamWarburton;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 88;
use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_divrem = \&Math::PlanePath::_divrem;
*_divrem_mutate = \&Math::PlanePath::_divrem_mutate;

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'round_down_pow';

# uncomment this to run the ### lines
#use Smart::Comments;


# 1+3+3+9=16
#
# 0 +1
# 1 +4        <- 0
# 5 +4        <- 1
# 9 +12
# 21 +4     <- 5 + 4+12 = 21 = 5 + 4*(1+3)
# 25 +12
# 37 +12
# 49 +36
# 85 +4     <- 21 + 4+12+12+36  = 21 + 4*(1+3+3+9)
# 89 +12      <- 8   +64
# 101 +12
# 113 +36
# 149
# 161
# 197
# 233
# 341
# 345         <- 16  +256
# 357
# 369

# 1+3 = 4  power 2
# 1+3+3+9 = 16    power 3
# 1+3+3+9+3+9+9+27 = 64    power 4
#
# 4*(1+4+...+4^(l-1)) = 4*(4^l-1)/3
#    l=1 total=4*(4-1)/3 = 4
#    l=2 total=4*(16-1)/3=4*5 = 20
#    l=3 total=4*(64-1)/3=4*63/3 = 4*21 = 84
#
# n = 2 + 4*(4^l-1)/3
# (n-2) = 4*(4^l-1)/3
# 3*(n-2) = 4*(4^l-1)
# 3n-6 = 4^(l+1)-4
# 3n-2 = 4^(l+1)
#
# 3^0+3^1+3^1+3^2 = 1+3+3+9=16
# x+3x+3x+9x = 16x = 256
# 4 quads is 4*16=64
#
# 1+1+3 = 5
# 1+1+3 +1+1+3 +3+3+9 = 25

# 1+4 = 5
# 1+4+4+12 = 21 = 1 + 4*(1+1+3)
# 2  +1
# 3  +3
# 6  +1
# 7  +1
# 10 +3
# 13


sub n_to_xy {
  my ($self, $n) = @_;
  ### UlamWarburton n_to_xy(): $n

  if ($n < 1) { return; }
  if (is_infinite($n)) { return ($n,$n); }
  if ($n == 1) { return (0,0); }

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

  my ($power, $exp) = round_down_pow (3*$n-2, 4);
  $exp -= 1;
  $power /= 4;

  ### $power
  ### $exp
  ### pow base: 2 + 4*(4**$exp - 1)/3

  $n -= ($power - 1)/3 * 4 + 2;
  ### n less pow base: $n

  my @levelbits = (2**$exp);
  $power = 3**$exp;

  # find the cumulative levelpoints total <= $n, being the start of the
  # level containing $n
  #
  my $factor = 4;
  while (--$exp >= 0) {
    $power /= 3;
    my $sub = 4**$exp * $factor;
    ### $sub
    # $power*$factor;
    my $rem = $n - $sub;

    ### $n
    ### $power
    ### $factor
    ### consider subtract: $sub
    ### $rem

    if ($rem >= 0) {
      $n = $rem;
      push @levelbits, 2**$exp;
      $factor *= 3;
    }
  }

  ### @levelbits
  ### remaining n: $n
  ### assert: $n >= 0
  ### assert: $n < $factor

  $factor /= 4;
  (my $quad, $n) = _divrem ($n, $factor);

  ### mod: $factor
  ### $quad
  ### n within quad: $n
  ### assert: $quad >= 0
  ### assert: $quad <= 3

  my $x = 0;
  my $y = 0;
  while (@levelbits) {
    my $digit = _divrem_mutate ($n, 3);
    ### levelbits: $levelbits[-1]
    ### $digit

    $x += pop @levelbits;
    if (@levelbits) {
      if ($digit == 0) {
        ($x,$y) = ($y,-$x);   # rotate -90
      } elsif ($digit == 2) {
        ($x,$y) = (-$y,$x);   # rotate +90
      }
    }
    ### rotate to: "$x,$y"
    ### bit to x: "$x,$y"
  }

  ### xy no quad: "$x,$y"
  if ($quad & 2) {
    $x = -$x;
    $y = -$y;
  }
  if ($quad & 1) {
    ($x,$y) = (-$y,$x); # rotate +90
  }

  ### final: "$x,$y"
  return $x,$y;
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### UlamWarburton xy_to_n(): "$x, $y"

  $x = round_nearest ($x);
  $y = round_nearest ($y);
  if ($x == 0 && $y == 0) {
    return 1;
  }

  my $quad;
  if ($y > $x) {
    ### quad above leading diagonal ...
    if ($y > -$x) {
      ### quad above opposite diagonal, top quarter ...
      $quad = 1;
      ($x,$y) = ($y,-$x);  # rotate -90
    } else  {
      ### quad below opposite diagonal, left quarter ...
      $quad = 2;
      $x = -$x;  # rotate -180
      $y = -$y;
    }
  } else {
    ### quad below leading diagonal ...
    if ($y > -$x) {
      ### quad above opposite diagonal, right quarter ...
      $quad = 0;
    } else {
      ### quad below opposite diagonal, bottom quarter ...
      $quad = 3;
      ($x,$y) = (-$y,$x);  # rotate +90
    }
  }
  ### $quad
  ### quad rotated xy: "$x,$y"
  ### assert: $x >= $y
  ### assert: $x >= -$y

  my ($len, $exp) = round_down_pow ($x + abs($y), 2);
  if (is_infinite($exp)) { return ($exp); }


  my $level =
    my $ndigits =
      my $n = ($x * 0 * $y);  # inherit bignum 0

  while ($exp-- >= 0) {
    ### at: "$x,$y  n=$n len=$len"

    my $abs_y = abs($y);
    if ($x && $x == $abs_y) {
      return undef;
    }

    # right quarter diamond
    ### assert: $x >= 0
    ### assert: $x >= abs($y)
    ### assert: $x+abs($y) < 2*$len || $x==abs($y)

    if ($x + $abs_y >= $len) {
      # one of the three quarter diamonds away from the origin
      $x -= $len;
      ### shift to: "$x,$y"

      $level += $len;
      if ($x || $y) {
        $n *= 3;
        $ndigits++;

        if ($y < -$x) {
          ### bottom, digit 0 ...
          ($x,$y) = (-$y,$x);  # rotate +90

        } elsif ($y > $x) {
          ### top, digit 2 ...
          ($x,$y) = ($y,-$x);  # rotate -90
          $n += 2;
        } else {
          ### right, digit 1 ...
          $n += 1;
        }
      }
    }

    $len /= 2;
  }

  ### $n
  ### $level
  ### level n: _n_start($level)
  ### $ndigits
  ### npower: 3**$ndigits
  ### $quad
  ### quad powered: $quad*3**$ndigits
  ### xy_to_n: $n + ($zero+3)**$ndigits*$quad + _n_start($level)

  return $n + $quad*3**$ndigits + _n_start($level);
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### UlamWarburton rect_to_n_range(): "$x1,$y1  $x2,$y2"

  my ($dlo, $dhi)
    = _rect_to_diamond_range (round_nearest($x1), round_nearest($y1),
                              round_nearest($x2), round_nearest($y2));
  ### $dlo
  ### $dhi

  if ($dlo) {
    ($dlo) = round_down_pow ($dlo,2);
  }
  ($dhi) = round_down_pow ($dhi,2);

  ### rounded to pow2: "$dlo  ".(2*$dhi)

  return (_n_start($dlo), _n_start(2*$dhi));
}

#     x1       |       x2
#     +--------|-------+ y2          xzero true, yzero false
#     |        |       |             diamond min is y1
#     +--------|-------+ y1
#              |
#    ----------O-------------
#
#     |   x1        x2
#     |    +--------+ y2          xzero false, yzero true
#     |    |        |             diamond min is x1
#    -O--------------------
#     |    |        |
#     |    +--------+ y1
#     |
#
sub _rect_to_diamond_range {
  my ($x1,$y1, $x2,$y2) = @_;

  my $xzero = ($x1 < 0) != ($x2 < 0);  # x range covers x=0
  my $yzero = ($y1 < 0) != ($y2 < 0);  # y range covers y=0

  $x1 = abs($x1);
  $y1 = abs($y1);
  $x2 = abs($x2);
  $y2 = abs($y2);

  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1) }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1) }

  return (($yzero ? 0 : $y1) + ($xzero ? 0 : $x1),
          $x2+$y2);
}

sub _n_start {
  my ($level) = @_;
  ### _n_start: $level

  my ($power, $exp) = round_down_pow ($level, 2);
  if (is_infinite($power)) {
    return $power;
  }
  my $n = 2 + 4*($power*$power - 1)/3  - ($level==0);

  ### $power
  ### $exp
  ### $n

  $level -= $power;
  my $factor = 4;
  while ($exp--) {
    $power /= 2;
    if ($level >= $power) {
      $level -= $power;
      $n += $power*$power*$factor;
      ### add: $power*$factor
      $factor *= 3;
    }
  }
  ### n_level: $n
  return $n;
}
### assert: _n_start(1) == 2
### assert: _n_start(2) == 6
### assert: _n_start(3) == 10
### assert: _n_start(4) == 22
### assert: _n_start(5) == 26
### assert: _n_start(6) == 38
### assert: _n_start(7) == 50
### assert: _n_start(8) == 86

# ENHANCE-ME: step by the bits, not by X,Y
sub tree_n_children {
  my ($self, $n) = @_;
  ### UlamWarburton tree_n_children(): $n

  if ($n < 1) {
    return;
  }
  my ($x,$y) = $self->n_to_xy($n);
  my @ret;
  my $dx = 1;
  my $dy = 0;
  foreach (1 .. 4) {
    if (defined (my $n_child = $self->xy_to_n($x+$dx,$y+$dy))) {
      if ($n_child > $n) {
        push @ret, $n_child;
      }
    }
    ($dx,$dy) = (-$dy,$dx); # rotate +90
  }
  return sort {$a<=>$b} @ret;
}
sub tree_n_parent {
  my ($self, $n) = @_;
  ### UlamWarburton tree_n_parent(): $n

  if ($n <= 1) {
    return undef;
  }
  my ($x,$y) = $self->n_to_xy($n);
  my $dx = 1;
  my $dy = 0;
  foreach (1 .. 4) {
    if (defined (my $n_parent = $self->xy_to_n($x+$dx,$y+$dy))) {
      if ($n_parent < $n) {
        return $n_parent;
      }
    }
    ($dx,$dy) = (-$dy,$dx); # rotate +90
  }
  return undef;
}
# sub tree_n_children {
#   my ($self, $n) = @_;
#   my ($power, $exp) = _round_down_pow (3*$n-2, 4);
#   $exp -= 1;
#   $power /= 4;
#
#   ### $power
#   ### $exp
#   ### pow base: 2 + 4*(4**$exp - 1)/3
#
#   $n -= ($power - 1)/3 * 4 + 2;
#   ### n less pow base: $n
#
#   my @levelbits = (2**$exp);
#   $power = 3**$exp;
#
#   # find the cumulative levelpoints total <= $n, being the start of the
#   # level containing $n
#   #
#   my $factor = 4;
#   while (--$exp >= 0) {
#     $power /= 3;
#     my $sub = 4**$exp * $factor;
#     ### $sub
#     # $power*$factor;
#     my $rem = $n - $sub;
#
#     ### $n
#     ### $power
#     ### $factor
#     ### consider subtract: $sub
#     ### $rem
#
#     if ($rem >= 0) {
#       $n = $rem;
#       push @levelbits, 2**$exp;
#       $factor *= 3;
#     }
#   }
#
#   $n += $factor;
#   if (1) {
#     return ($n,$n+1,$n+2);
#   } else {
#     return $n,$n+1,$n+2;
#   }
# }


1;
__END__

=for stopwords eg Ryde Math-PlanePath Ulam Warburton Nstart OEIS ie

=head1 NAME

Math::PlanePath::UlamWarburton -- growth of a 2-D cellular automaton

=head1 SYNOPSIS

 use Math::PlanePath::UlamWarburton;
 my $path = Math::PlanePath::UlamWarburton->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

X<Ulam, Stanislaw>X<Warburton>This is the pattern of a cellular automaton
studied by Ulam and Warburton, numbering cells by growth level and
anti-clockwise within their level.

                               94                                  9
                            95 87 93                               8
                               63                                  7
                            64 42 62                               6
                         65    30    61                            5
                      66 43 31 23 29 41 60                         4
                   69    67    14    59    57                      3
                70 44 68    15  7 13    58 40 56                   2
       96    71    32    16     3    12    28    55    92          1
    97 88 72 45 33 24 17  8  4  1  2  6 11 22 27 39 54 86 91   <- Y=0
       98    73    34    18     5    10    26    53    90         -1
                74 46 76    19  9 21    50 38 52       ...        -2
                   75    77    20    85    51                     -3
                      78 47 35 25 37 49 84                        -4
                         79    36    83                           -5
                            80 48 82                              -6
                               81                                 -7
                            99 89 101                             -8
                              100                                 -9

                               ^
    -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7  8  9

The rule is that a given cell grows up, down, left and right, but only if
the new cell has no neighbours (up, down, left or right).  So the initial
cell "a" is N=1,

                a                  initial level 0 cell

The next level "b" cells are numbered N=2 to N=5 anti-clockwise from the
right,

                b   
             b  a  b               level 1 
                b    

Likewise the next level "c" cells N=6 to N=9.  The "b" cells only grow
outwards as 4 "c"s since the other positions would have neighbours in the
existing "b"s.

                c      
                b        
          c  b  a  b  c            level 2  
                b        
                c        

The "d" cells are then N=10 to N=21, numbered following the previous level
"c" cell order and then anti-clockwise around each.

                d
             d  c  d      
          d     b     d   
       d  c  b  a  b  c  d         level 3  
          d     b     d   
             d  c  d  
                d

There's only 4 "e" cells since among the "d"s only the X,Y axes won't have
existing neighbours (the "b"s and "d"s).

                e                
                d
             d  c  d     
          d     b     d   
    e  d  c  b  a  b  c  d  e      level 4
          d     b     d   
             d  c  d  
                d
                e

In general each level always grows by 1 along the X and Y axes and travels
into the quarter planes between with a sort of diamond shaped tree pattern
which fills 11 cells of each 4x4 square block.

=head2 Level Ranges

Counting level 0 as the N=1 at the origin and level 1 as the next N=2,3,4,5
generation, the number of new cells added in a growth level is

    levelcells(0) = 1
      then
    levelcells(level) = 4 * 3^((count 1 bits in level) - 1)

So level 1 has 4*3^0=4 cells, as does level 2 N=6,7,8,9.  Then level 3 has
4*3^1=12 cells N=10 to N=21 because 3=0b11 has two 1 bits in binary.  The N
start and end for a level is the cumulative total of those before it,

    Nstart(level) = 1 + (levelcells(0) + ... + levelcells(level-1))

    Nend(level) = levelcells(0) + ... + levelcells(level)

For example level 3 ends at N=(1+4+4)=9.

    level    Nstart   levelcells     Nend    
      0          1         1           1   
      1          2         4           5   
      2          6         4           9
      3         10        12          21   
      4         22         4          25   
      5         26        12          37   
      6         38        12          49   
      7         50        36          85   
      8         86         4          89   
      9         90        12         101   

For a power-of-2 level the Nstart is

    Nstart(2^a) = 2 + 4*(4^a-1)/3

For example level=4=2^2 starts at N=2+4*(4^2-1)/3=22, or level=8=2^3 starts
N=2+4*(4^3-1)/3=86.

Further bits in the level value contribute powers-of-4 with a tripling for
each bit above.  So if the level number has bits a,b,c,d,etc in descending
order,

    level = 2^a + 2^b + 2^c + 2^d ...       a>b>c>d...
    Nstart = 2 + 4*(4^a-1)/3
               +       4^(b+1)
               +   3 * 4^(c+1)
               + 3^2 * 4^(d+1) + ...

For example level=6 = 2^2+2^1 is Nstart = 1 + (1+4*(4^2-1)/3) + 4^(1+1) =
38.  Or level=7 = 2^2+2^1+2^0 is Nstart = 1 + (1+4*(4^2-1)/3) + 4^(1+1) +
3*4^(0+1) = 50.

=head2 Self-Similar Replication

The diamond shape growth up to a level 2^a repeats three times.  For example
an "a" part going to the right,

          d
        d d d
      a   d   c
    a a a * c c c ...
      a   b   c
        b b b 
          b

The 2x2 diamond shaped "a" repeats pointing up, down and right as "b", "c"
and "d".  This resulting 4x4 diamond then likewise repeats up, down and
right.  The points in the path here are numbered by growth level rather than
in this sort of replication, but the replication helps to see the structure
of the pattern.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::UlamWarburton-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 1 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head2 Tree Methods

=over

=item C<@n_children = $path-E<gt>tree_n_children($n)>

Return the children of C<$n>, or an empty list if C<$n> has no children
(including when C<$n E<lt> 1>, ie. before the start of the path).

The children are the cells turned on adjacent to C<$n> at the next level.
This can be none, one or three points; or four at the initial N=1.  The way
points are numbered means that when there's multiple children they're
consecutive N values, for example at N=6 the children are 10,11,12.

=item C<$num = $path-E<gt>tree_n_num_children($n)>

Return the number of children of C<$n>, or 0 if C<$n> has no children.

=item C<$n_parent = $path-E<gt>tree_n_parent($n)>

Return the parent node of C<$n>, or C<undef> if C<$n E<lt>= 1> (the start of
the path).

=back

=head1 OEIS

This cellular automaton is in Sloane's Online Encyclopedia of Integer
Sequences as

    http://oeis.org/A147582    (etc)

    A147562 - cumulative total cells to level n, being Nend(level)
    A147582 - number of new cells in level n

The A147582 new cells sequence starts from n=1, so takes the innermost N=1
single cell as level n=1, then N=2,3,4,5 as level n=2 with 5 cells, etc.
This makes the formula a binary 1-bits count on n-1 rather than on N the way
levelcells() above is expressed.

The 1bits-count power 3^(count 1 bits in level) part of the levelcells() is
also separately in A048883, and as n-1 in A147610.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::CellularRule>

L<Math::PlanePath::SierpinskiTriangle> (a similar binary ones-count related
level calculation)

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011, 2012 Kevin Ryde

This file is part of Math-PlanePath.

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
