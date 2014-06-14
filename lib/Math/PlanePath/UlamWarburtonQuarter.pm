# Copyright 2011, 2012, 2013, 2014 Kevin Ryde

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


# A147610 - 3^(ones(n-1) - 1)
# A048883 - 3^(ones n)



package Math::PlanePath::UlamWarburtonQuarter;
use 5.004;
use strict;
use List::Util 'sum';

use vars '$VERSION', '@ISA';
$VERSION = 116;
use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_divrem_mutate = \&Math::PlanePath::_divrem_mutate;

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'round_down_pow',
  'bit_split_lowtohigh',
  'digit_split_lowtohigh',
  'digit_join_lowtohigh';

# uncomment this to run the ### lines
# use Smart::Comments;


use constant parameter_info_array =>
  [ Math::PlanePath::Base::Generic::parameter_info_nstart1() ];

use constant class_x_negative => 0;
use constant class_y_negative => 0;
use constant tree_num_children_list => (0, 1, 3);

# Minimum dir=0 at N=13 dX=2,dY=0.
# Maximum dir seems dX=13,dY=-9 at N=149 going top-left part to new bottom
# right diagonal.
use constant dir_maximum_dxdy => (13,-9);

#------------------------------------------------------------------------------
sub new {
  my $self = shift->SUPER::new(@_);
  if (! defined $self->{'n_start'}) {
    $self->{'n_start'} = $self->default_n_start;
  }
  return $self;
}

# 7   7   7   7
#   6       6
# 7   5   5   7
#       4
# 3   3   5   7
#   2       6
# 1   3   7   7
#
# 1+1+3=5
# 5+1+3*5=21
# 1+3 = 4
# 1+3+3+9 = 16
#
#       0
# 1  0 +1
# 2  1 +1       <- 1
# 3  2 +3
# 4  5 +1       <- 1 + 4 = 5
# 5  6 +3
# 6  9 +3
# 7  12 +9
# 8  21         <- 1 + 4 + 16 = 21

# 1+3 = 4  power 2
# 1+3+3+9 = 16    power 3
# 1+3+3+9+3+9+9+27 = 64    power 4
#
# (1+4+16+...+4^(l-1)) = (4^l-1)/3
#    l=1 total=(4-1)/3 = 1
#    l=2 total=(16-1)/3 = 5
#    l=3 total=(64-1)/3=63/3 = 21
#
# n = 1 + (4^l-1)/3
# n-1 = (4^l-1)/3
# 3n-3 = (4^l-1)
# 3n-2 = 4^l
#
# 3^0+3^1+3^1+3^2 = 1+3+3+9=16
# x+3x+3x+9x = 16x = 256
#
#               22
# 20  19  18  17
#   12      11
# 21   9   8  16
#        6
#  5   4   7  15
#    2      10
#  1   3  13  14
#

sub n_to_xy {
  my ($self, $n) = @_;
  ### UlamWarburtonQuarter n_to_xy(): $n

  if ($n < $self->{'n_start'}) { return; }
  if (is_infinite($n)) { return ($n,$n); }

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

  $n = $n - $self->{'n_start'} + 1;  # N=1 basis
  if ($n == 1) { return (0,0); }

  my ($depthsum, $nrem) = _n1_to_depthsum_and_rem($n)
    or return ($n,$n); # N==nan or N==+inf

  my @ndigits = digit_split_lowtohigh($nrem,3);
  my $dhigh = shift(@$depthsum) - 1;  # highest term
  my $x = 0;
  my $y = 0;
  foreach my $depthsum (reverse @$depthsum) { # depth terms low to high
    my $ndigit = shift @ndigits;              # N digits low to high
    ### $depthsum
    ### $ndigit

    $x += $depthsum;
    $y += $depthsum;
    ### depthsum to xy: "$x,$y"

    if ($ndigit) {
      if ($ndigit == 2) {
        ($x,$y) = (-$y,$x);   # rotate +90
      }
    } else {
      # digit==0 (or undef when run out of @ndigits)
      ($x,$y) = ($y,-$x);   # rotate -90
    }
    ### rotate to: "$x,$y"
  }

  ### final: "$x,$y"
  return ($dhigh + $x, $dhigh + $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### UlamWarburtonQuarter xy_to_n(): "$x, $y"

  $x = round_nearest ($x);
  $y = round_nearest ($y);
  if ($x < 0 || $y < 0) {
    return undef;
  }
  if ($x == 0 && $y == 0) {
    return $self->{'n_start'};
  }
  $x += 1;  # pushed away by 1 ...
  $y += 1;

  my ($len, $exp) = round_down_pow ($x + $y, 2);
  if (is_infinite($exp)) { return $exp; }

  my $level
    = my $n
      = ($x * 0 * $y);  # inherit bignum 0

  while ($exp-- >= 0) {
    ### at: "$x,$y  n=$n len=$len"

    # first quadrant square
    ### assert: $x >= 0
    ### assert: $y >= 0
    # ### assert: $x < 2*$len
    # ### assert: $y < 2*$len

    if ($x >= $len || $y >= $len) {
      # one of three quarters away from origin
      #     +---+---+
      #     | 2 | 1 |
      #     +---+---+
      #     |   | 0 |
      #     +---+---+

      $x -= $len;
      $y -= $len;
      ### shift to: "$x,$y"

      if ($x) {
        unless ($y) {
          return undef;  # x==0, y!=0, nothing
        }
      } else {
        if ($y) {
          return undef;  # x!=0, y-=0, nothing
        }
      }

      $level += $len;
      if ($x || $y) {
        $n *= 3;
        if ($y < 0) {
          ### bottom right, digit 0 ...
          ($x,$y) = (-$y,$x);  # rotate +90
        } elsif ($x >= 0) {
          ### top right, digit 1 ...
          $n += 1;
        } else {
          ### top left, digit 2 ...
          ($x,$y) = ($y,-$x);  # rotate -90
          $n += 2;
        }
      }
    }

    $len /= 2;
  }

  ### $n
  ### $level

  return $n + $self->tree_depth_to_n($level-1);
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### UlamWarburtonQuarter rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = round_nearest ($x1);
  $y1 = round_nearest ($y1);
  $x2 = round_nearest ($x2);
  $y2 = round_nearest ($y2);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  if ($x2 < 0 || $y2 < 0) {
    return (1, 0);  # all outside first quadrant
  }

  if ($x1 < 0) { $x1 *= 0; }
  if ($y1 < 0) { $y1 *= 0; }

  # level numbers
  my $dlo = ($x1 > $y1 ? $x1 : $y1)+1;
  my $dhi = ($x2 > $y2 ? $x2 : $y2);
  ### $dlo
  ### $dhi

  # round down to level=2^k numbers
  if ($dlo) {
    ($dlo) = round_down_pow ($dlo,2);
  }
  ($dhi) = round_down_pow ($dhi,2);

  ### rounded to pow2: "$dlo  ".(2*$dhi)

  return ($self->tree_depth_to_n($dlo-1),
          $self->tree_depth_to_n(2*$dhi-1));
}

#------------------------------------------------------------------------------
use constant tree_num_roots => 1;

# ENHANCE-ME: step by the bits, not by X,Y
sub tree_n_children {
  my ($self, $n) = @_;
  if ($n < $self->{'n_start'}) {
    return;
  }
  my ($x,$y) = $self->n_to_xy($n);
  my @ret;
  my $dx = 1;
  my $dy = 1;
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
  if ($n <= $self->{'n_start'}) {
    return undef;
  }
  my ($x,$y) = $self->n_to_xy($n);
  my $dx = 1;
  my $dy = 1;
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

# level = depth+1 = 2^a + 2^b + 2^c + 2^d ...       a>b>c>d...
# Ndepth = 1 + (-1
#               +       4^a
#               +   3 * 4^b
#               + 3^2 * 4^c
#               + 3^3 * 4^d + ...) / 3
sub tree_depth_to_n {
  my ($self, $depth) = @_;
  ### tree_depth_to_n(): $depth
  if (is_infinite($depth)) {
    return $depth;
  }
  unless ($depth >= 0) {
    return undef;
  }
  my $n = $depth*0;        # inherit bignum 0
  my $pow3 = 1 + $n;       # inherit bignum 1
  foreach my $bit (reverse bit_split_lowtohigh($depth+1)) {  # high to low
    $n *= 4;
    if ($bit) {
      $n += $pow3;
      $pow3 *= 3;
    }
  }
  return ($n-1)/3 + $self->{'n_start'};
}

sub tree_n_to_depth {
  my ($self, $n) = @_;

  $n = int($n - $self->{'n_start'} + 1);  # N=1 basis
  if ($n < 1) {
    return undef;
  }
  (my $depthsum, $n) = _n1_to_depthsum_and_rem($n)
    or return $n;  # N==nan or N==+infinity
  return sum(-1, @$depthsum);
}

# Return ($aref, $remaining_n).
# sum(@$aref) = depth starting depth=1
#
sub _n1_to_depthsum_and_rem {
  my ($n) = @_;
  ### _n1_to_depthsum_and_rem(): $n

  my ($power, $exp) = round_down_pow (3*$n-2, 4);
  if (is_infinite($exp)) {
    return;
  }

  ### $power
  ### $exp
  ### pow base: ($power - 1)/3 + 1

  $n -= ($power - 1)/3 + 1;
  ### n less pow base: $n

  my @depthsum = (2**$exp);

  # find the cumulative levelpoints total <= $n, being the start of the
  # level containing $n
  #
  my $factor = 1;
  while (--$exp >= 0) {
    $power /= 4;
    my $sub = $power * $factor;
    ### $sub
    my $rem = $n - $sub;

    ### $n
    ### $power
    ### $factor
    ### consider subtract: $sub
    ### $rem

    if ($rem >= 0) {
      $n = $rem;
      push @depthsum, 2**$exp;
      $factor *= 3;
    }
  }

  ### _n1_to_depthsum_and_rem() result ...
  ### @depthsum
  ### remaining n: $n
  ### assert: $n >= 0
  ### assert: $n < $factor

  return \@depthsum, $n;
}


# at 0,2 turn and new height limit
# at 1 keep existing depth limit
# N=30 rem=1 = 0,1 depth=11=8+2+1=1011 width=9
# 
sub tree_n_to_subheight {
  my ($self, $n) = @_;
  ### tree_n_to_subheight(): $n

  $n = int($n - $self->{'n_start'} + 1);  # N=1 basis
  if ($n < 1) {
    return undef;
  }
  my ($depthsum, $nrem) = _n1_to_depthsum_and_rem($n)
    or return $n;  # N==nan or N==+infinity
  ### $depthsum
  ### $nrem

  my $sub = pop @$depthsum;
  while (@$depthsum && _divrem_mutate($nrem,3) == 1) {
    $sub += pop @$depthsum;
  }
  if (@$depthsum) {
    return $depthsum->[-1] - 1 - $sub;
  } else {
    return undef; # $nrem all 1-digits
  }
}

1;
__END__

=for stopwords eg Ryde Math-PlanePath Ulam Warburton Ndepth Nend ie OEIS

=head1 NAME

Math::PlanePath::UlamWarburtonQuarter -- growth of a 2-D cellular automaton

=head1 SYNOPSIS

 use Math::PlanePath::UlamWarburtonQuarter;
 my $path = Math::PlanePath::UlamWarburtonQuarter->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

X<Ulam, Stanislaw>X<Warburton>This is the pattern of a cellular automaton
studied by Ulam and Warburton, confined to a quarter of the plane and
oriented diagonally.  Cells are numbered by growth level and anti-clockwise
within the level.

=cut

# math-image --path=UlamWarburtonQuarter --all --output=numbers --size=70x15

=pod

    14 |  81    80    79    78    75    74    73    72
    13 |     57          56          55          54
    12 |  82    48    47    77    76    46    45    71
    11 |           40                      39
    10 |  83    49    36    35    34    33    44    70
     9 |     58          28          27          53
     8 |  84    85    37    25    24    32    68    69
     7 |                       22
     6 |  20    19    18    17    23    31    67    66
     5 |     12          11          26          52
     4 |  21     9     8    16    29    30    43    65
     3 |            6                      38
     2 |   5     4     7    15    59    41    42    64
     1 |      2          10          50          51
    Y=0|   1     3    13    14    60    61    62    63
       +----------------------------------------------
         X=0  1  2  3  4  5  6  7  8  9 10 11 12 13 14

The rule is a given cell grows diagonally NE, NW, SE and SW, but only if the
new cell has no neighbours and is within the first quadrant.  So the initial
cell "a" is N=1,


    |
    | a                    initial cell, depth=0
    +----

It's confined to the first quadrant so can only grow NE as "b",

    |   b
    | a                    "b" depth=1
    +------

Then the next level "c" cells can go in three directions SE, NE, NW.  These
cells are numbered anti-clockwise around from the SE as N=3,N=4,N=5.

    | c   c
    |   b
    | a   c                "c" depth=2
    +---------

The "d" cell is then only a single on the leading diagonal, since the other
diagonals all already have neighbours (the existing "c" cells).

    |       d
    | c   c                depth=3
    |   b
    | a   c
    +---------

    |     e   e
    |       d
    | c   c   e            depth=4
    |   b
    | a   c
    +-----------

    |   f       f
    |     e   e
    |       d
    | c   c   e            depth=5
    |   b       f
    | a   c
    +-------------

    | g   g   g   g
    |   f       f
    | g   e   e   g
    |       d
    | c   c   e   g        depth=6
    |   b       f
    | a   c   g   g
    +-------------

In general each level always grows by 1 along the X=Y leading diagonal, and
travels into the sides with a self-similar diamond shaped pattern filling 6
of 16 cells any 4x4 square block.

=head2 Level Ranges

Counting level 1 as the N=1 at the origin, level 2 as the next N=2, etc, the
number of new cells added in a growth level is

    levelcells(level) = 3^((count 1 bits in level) - 1)

So level 1 has 3^(1-1)=1 cell, as does level 2 N=2.  Then level 3 has
3^(2-1)=3 cells N=3,N=4,N=5 because 3=0b11 has two 1 bits in binary.  The N
start and end for a level is the cumulative total of those before it,

    Ndepth(level) = 1 + (levelcells(0) + ... + levelcells(level-1))

    Nend(level) = levelcells(0) + ... + levelcells(level)

For example level 3 ends at N=(1+1+3)=5.

    level    Ndepth   levelcells     Nend
      1          1         1           1
      2          2         1           2
      3          3         3           5
      4          6         1           6
      5          7         3           9
      6         10         3          12
      7         13         9          21
      8         22         1          22
      9         23         3          25

For a power-of-2 level the Ndepth sum is

    Ndepth(2^a) = 1 + (4^a-1)/3

For example level=4=2^2 starts at N=1+(4^2-1)/3=6, or level=8=2^3 starts
N=1+(4^3-1)/3=22.

Further bits in the level value contribute powers-of-4 with a tripling for
each bit above.  So if the level number has bits a,b,c,d,etc in descending
order,

    level = 2^a + 2^b + 2^c + 2^d ...       a>b>c>d...
    Ndepth = 1 + (-1
                  +       4^a
                  +   3 * 4^b
                  + 3^2 * 4^c
                  + 3^3 * 4^d + ...) / 3

For example level=6 = 2^2+2^1 is Ndepth = 1+(4^2-1)/3 + 4^1 = 10.  Or
level=7 = 2^2+2^1+2^0 is Ndepth = 1+(4^2-1)/3 + 4^1 + 3*4^0 = 13.

=head2 Self-Similar Replication

The square shape growth up to a level 2^ repeats three times.  For example,

    |  d   d   c   c
    |    d       c
    |  d   d   c   c
    |        *
    |  a   a   b   b
    |    a       b
    |  a   a   b   b
    +--------------------

The 3x3 square "a" repeats, pointing SE, NE and NW as "b", "c" and "d".
This resulting 7x7 square then likewise repeats.  The points in the path
here are numbered by growth level rather than by this sort of replication,
but the replication helps to see the structure of the pattern.

=head2 N Start

The default is to number points starting N=1 as shown above.  An optional
C<n_start> can give a different start, in the same pattern.  For example to
start at 0,

=cut

# math-image --path=UlamWarburtonQuarter,n_start=0 --expression='i<22?i:0' --output=numbers

=pod

    n_start => 0

     7 |                      21
     6 | 19    18    17    16   
     5 |    11          10      
     4 | 20     8     7    15   
     3 |           5            
     2 |  4     3     6    14   
     1 |     1           9      
    Y=0|  0     2    12    13   
       +-------------------------
        X=0  1  2  3  4  5  6  7 

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::UlamWarburtonQuarter-E<gt>new ()>

=item C<$path = Math::PlanePath::UlamWarburtonQuarter-E<gt>new (n_start =E<gt> $n)>

Create and return a new path object.

=back

=head2 Tree Methods

=over

=item C<@n_children = $path-E<gt>tree_n_children($n)>

Return the children of C<$n>, or an empty list if C<$n> has no children
(including when C<$n E<lt> 1>, ie. before the start of the path).

The children are the cells turned on adjacent to C<$n> at the next level.
This can be 0, 1 or 3 points.  The way points are numbered means that when
there's multiple children they're consecutive N values, for example at N=12
the children 19,20,21.

=item C<$num = $path-E<gt>tree_n_num_children($n)>

Return the number of children of C<$n>, or return C<undef> if C<$nE<lt>1>
(ie. before the start of the path).

=item C<$n_parent = $path-E<gt>tree_n_parent($n)>

Return the parent node of C<$n>, or C<undef> if C<$n E<lt>= 1> (the start of
the path).

=back

=head1 OEIS

Entries in Sloane's Online Encyclopedia of Integer Sequences related to this
path includes

=over

L<http://oeis.org/A151920> (etc)

=back

    A147610     num cells in level, being 3^count1bits(depth)

    n_start=1 (the default)
      A151920   total cells to depth, being cumulative 3^(count 1-bits)
                  tree_depth_to_n_end()

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::UlamWarburton>,
L<Math::PlanePath::LCornerTree>,
L<Math::PlanePath::CellularRule>

L<Math::PlanePath::SierpinskiTriangle> (a similar binary ones-count related
level calculation)

=head1 HOME PAGE

L<http://user42.tuxfamily.org/math-planepath/index.html>

=head1 LICENSE

Copyright 2011, 2012, 2013, 2014 Kevin Ryde

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
