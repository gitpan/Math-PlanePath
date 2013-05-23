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


#------------------------------------------------------------------------------
# U-W in half plane
#
# A183060 total
# A183061 added
#
#        8
#       878
#      8 6 8
#     8765678
#    8 8 4 8 8
#   878 434 878
#  8 6 4 2 4 6 8
# 876543212345678

#------------------------------------------------------------------------------
# U-W in first quadrant, incl X,Y axes
#
# A151922 total num first-quadrant cells
# A079314  added
#
# 0  1, 3, 5,   9, 11, 15, 19,   29, 31, 35, 39, 49, 53, 63, 73,  101,103,107,
# 1, 2, 2, 4,   2,  4,  4, 10,   2,  4,  4,  10, 4,  10, 10, 28,    2,  4,
# 0  1  2  3    4   5   6   7    8   9  10   11  12  13  14  15    16  17
#
# 0, 1, 5, 9,  21, 25, 37, 49,  85, 89,101,113, 149,161,197,233,  341,
# 1, 4, 4, 12,  4, 12, 12, 36,   4, 12, 12, 36,  12, 36, 36,108,    4, 12, 12,

#------------------------------------------------------------------------------
# cf
# Ulam/Warburton with cells turning off too
# A079315 cells OFF -> ON
# A079317 cells ON at stage n
# A079316 cells ON at stage n, in first quadrant
# A151921 net gain ON cells


#------------------------------------------------------------------------------

package Math::PlanePath::UlamWarburton;
use 5.004;
use strict;
use Carp;
use List::Util 'sum';

use vars '$VERSION', '@ISA';
$VERSION = 104;
use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_divrem = \&Math::PlanePath::_divrem;
*_divrem_mutate = \&Math::PlanePath::_divrem_mutate;

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'round_down_pow',
  'digit_split_lowtohigh';

use Math::PlanePath::UlamWarburtonQuarter;

# uncomment this to run the ### lines
# use Smart::Comments;


use constant parameter_info_array =>
  [
   { name            => 'parts',
     share_key       => 'parts_ulamwarburton',
     display         => 'Parts',
     type            => 'enum',
     default         => '4',
     choices         => ['4','2','1',
                        ],
     description     => 'Which parts of the plane to fill.',
   },
   Math::PlanePath::Base::Generic::parameter_info_nstart1(),
  ];

use constant absdx_minimum => 1;

my %x_negative = (4         => 1,
                  2         => 1,
                  1         => 0,
                 );
sub x_negative {
  my ($self) = @_;
  return $x_negative{$self->{'parts'}};
}

sub y_negative {
  my ($self) = @_;
  return $self->{'parts'} eq '4';
}

{
  my %dir_maximum_dxdy = (4         => [1,-1], # N=4  South-East
                          2         => [1,-1], # N=44 South-East
                          1         => [2,-1], # N=3  ESE
                         );
  sub dir_maximum_dxdy {
    my ($self) = @_;
    return @{$dir_maximum_dxdy{$self->{'parts'}}};
  }
}

sub tree_num_children_maximum {
  my ($self) = @_;
  return ($self->{'parts'} eq '4' ? 4 : 3);
}

#------------------------------------------------------------------------------
sub new {
  my $self = shift->SUPER::new(@_);
  if (! defined $self->{'n_start'}) {
    $self->{'n_start'} = $self->default_n_start;
  }
  my $parts = ($self->{'parts'} ||= '4');
  if (! exists $x_negative{$parts}) {
    croak "Unrecognised parts option: ", $parts;
  }
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### UlamWarburton n_to_xy(): "$n  parts=$self->{'parts'}"

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

  $n = $n - $self->{'n_start'};  # N=0 basis
  if ($n == 0) { return (0,0); }

  my $parts = $self->{'parts'};
  my ($depthsum, $factor, $nrem) = _n0_to_depthsum_factor_rem($n, $parts)
    or return $n;  # N=nan or +inf
  ### depthsum: join(',',@$depthsum)
  ### $factor
  ### n rem within row: $nrem

  $factor /= $parts;
  if ($parts ne '4') {
    $nrem += ($factor-1)/2;
  }
  (my $quad, $nrem) = _divrem ($nrem, $factor);

  ### factor modulus: $factor
  ### $quad
  ### n rem within quad: $nrem
  ### assert: $quad >= 0
  ### assert: $quad <= 3

  my $dhigh = shift @$depthsum;  # highest term
  my @ndigits = digit_split_lowtohigh($nrem,3);
  ### $dhigh
  ### ndigits low to high: join(',',@ndigits)

  my $x = 0;
  my $y = 0;
  foreach my $depthterm (reverse @$depthsum) { # depth terms low to high
    my $ndigit = shift @ndigits;              # N digits low to high
    ### $depthterm
    ### $ndigit

    $x += $depthterm;
    ### bit to x: "$x,$y"

    if ($ndigit) {
      if ($ndigit == 2) {
        ($x,$y) = (-$y,$x);   # rotate +90
      }
    } else {
      # $ndigit==0 (or undef when @ndigits shorter than @$depthsum)
      ($x,$y) = ($y,-$x);   # rotate -90
    }
    ### rotate to: "$x,$y"
  }
  $x += $dhigh;

  ### xy before quad: "$x,$y"
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
# no Smart::Comments;

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### UlamWarburton xy_to_n(): "$x, $y"

  $x = round_nearest ($x);
  $y = round_nearest ($y);
  if ($x == 0 && $y == 0) {
    return $self->{'n_start'};
  }

  my $parts = $self->{'parts'};
  if ($parts ne '4'
      && ($y < 0
          || ($parts eq '1' && $x < 0))) {
    return undef;
  }

  my $quad;
  if ($y > $x) {
    ### quad above leading diagonal ...
    #        /
    # above /
    #      /
    if ($y > -$x) {
      ### quad above opposite diagonal, top quarter ...
      #  top
      # \  /
      #  \/
      $quad = 1;
      ($x,$y) = ($y,-$x);  # rotate -90
    } else  {
      ### quad below opposite diagonal, left quarter ...
      #      \
      # left  \
      #       /
      #      /
      $quad = 2;
      $x = -$x;  # rotate -180
      $y = -$y;
    }
  } else {
    ### quad below leading diagonal ...
    #   /
    #  / below
    # /
    if ($y > -$x) {
      ### quad above opposite diagonal, right quarter ...
      #   /
      #  / right
      #  \
      #   \
      $quad = 0;
    } else {
      ### quad below opposite diagonal, bottom quarter ...
      #  /\
      # /  \
      # bottom
      $quad = 3;
      ($x,$y) = (-$y,$x);  # rotate +90
    }
  }
  ### $quad
  ### quad rotated xy: "$x,$y"
  ### assert: ! ($y > $x)
  ### assert: ! ($y < -$x)

  my ($len, $exp) = round_down_pow ($x + abs($y), 2);
  if (is_infinite($exp)) { return ($exp); }


  my $depth =
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

      $depth += $len;
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
  ### $depth
  ### $ndigits
  ### npower: 3**$ndigits
  ### $quad
  ### quad powered: $quad*3**$ndigits

  my $npower = 3**$ndigits;
  if ($parts ne '4') {
     $n -= ($npower-1)/2;
  }

  return $n + $quad*$npower + $self->tree_depth_to_n($depth);
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

  return ($self->tree_depth_to_n($dlo),
          $self->tree_depth_to_n(2*$dhi) - 1);
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

# ENHANCE-ME: step by the bits, not by X,Y
# ENHANCE-ME: tree_n_to_depth() by probe
sub tree_n_children {
  my ($self, $n) = @_;
  ### UlamWarburton tree_n_children(): $n

  if ($n < $self->{'n_start'}) {
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
    ($dx,$dy) = (-$dy,$dx);  # rotate +90
  }
  return sort {$a<=>$b} @ret;
}
sub tree_n_parent {
  my ($self, $n) = @_;
  ### UlamWarburton tree_n_parent(): $n

  if ($n <= $self->{'n_start'}) {
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
#   my @$depthsum = (2**$exp);
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
#       push @$depthsum, 2**$exp;
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

# Converting quarter ...
# (N-start)*4+1+start = 4*N-4*start+1+start
#                     = 4*N-3*start+1
#
sub tree_depth_to_n {
  my ($self, $depth) = @_;
  if ($depth == 0) {
    return $self->{'n_start'};
  }
  my $n = $self->Math::PlanePath::UlamWarburtonQuarter::tree_depth_to_n($depth-1);
  if (! defined $n) {
    return undef;
  }
  my $parts = $self->{'parts'};
  if ($parts eq '2') {
    return 2*$n - $self->{'n_start'} + $depth;
  }
  if ($parts eq '1') {
    return $n + $depth;
  }
  if ($parts eq 'octant' || $parts eq 'octant_up') {
    return ($n + $depth + 1) / 2;
  }
  ### assert: $parts eq '4'
  return 4*$n - 3*$self->{'n_start'} + 1;
}

sub tree_n_to_depth {
  my ($self, $n) = @_;

  $n = $n - $self->{'n_start'};  # N=0 basis
  if ($n < 0) {
    return undef;
  }
  $n = int($n);
  if ($n == 0) {
    return 0;
  }
  my ($depthsum) = _n0_to_depthsum_factor_rem($n, $self->{'parts'})
    or return $n;  # N=nan or +inf
  return sum(@$depthsum);
}


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


# parts=1
#   1+4+...+4^(l-1) + 2^l
#     = (4^l-1)/3 + 2^l
#     = (4^l-1 + 3*2^l)/3
#     = (2^l*(2^l + 3) - 1)/3
#   l=1 total= 3
#   l=2 total= 9
#   l=3 total= 29
#   l=4 total= 101
#
#   N = (4^l-1)/3 + 2^l
#   3*(N-2^l)+1 = 4^l
#   12*(N-2^l)+1 = 4 * 4^l
#
# parts=2
#   N = 2*(4^l-1)/3 + 2^l
#   3/2*(N-2^l)+1 = 4^l
#   6*(N-2^l)+1 = 4 * 4^l
#
# parts=4
#   N = (4^l-1)/3
#   3*N+1 = 4 * 4^l

# use Smart::Comments;

# Return ($aref, $factor, $remaining_n).
# sum(@$aref) = depth starting depth=1
#
sub _n0_to_depthsum_factor_rem {
  my ($n, $parts) = @_;
  ### _n0_to_depthsum_factor_rem(): "$n  parts=$parts"

  if ($n == 0) {
    return ([], $parts, 0);
  }

  my $n3 = 3*$n+1;
  my $ndepth = 0;
  my $power = $n3;
  my $exp;
  if ($parts eq '4') {
    $power /= 4;
  } elsif ($parts eq '2') {
    $power /= 2;
    $ndepth = -1;
  }
  ($power, $exp) = round_down_pow ($power, 4);
  ### $n3
  ### $power
  ### $exp
  if (is_infinite($exp)) {
    return;
  }

  # ### pow base: ($power - 1)/3 * $factor + 1 + ($parts ne '4' && $exp)
  # $n -= ($power - 1)/3 * $factor + 1;
  # if ($parts ne '4') { $n -= $exp; }
  # ### n less pow base: $n

  my $factor = $parts;
  my $twopow = 2**$exp;
  my @depthsum;

  for (;
       $exp-- >= 0;
       $power /= 4, $twopow /= 2) {
    ### at: "power=$power twopow=$twopow factor=$factor n3=$n3 ndepth=$ndepth depthsum=".join(',',@depthsum)

    my $nmore = $power * $factor;
    if ($parts ne '4') { $nmore += 3*$twopow; }
    my $ncmp = $ndepth + $nmore;
    ### $nmore
    ### $ncmp

    if ($n3 >= $ncmp) {
      ### go to ncmp, remainder: $n3-$ncmp
      $factor *= 3;
      $ndepth = $ncmp;
      push @depthsum, $twopow;
    }
  }

  if ($parts eq '2') {
    $n3 += 1;
  }

  ### assert: ($n3 - $ndepth)%3 == 0
  $n = ($n3 - $ndepth) / 3;
  $factor /= 3;

  ### $ndepth
  ### @depthsum
  ### remaining n: $n
  ### assert: $n >= 0
  ### assert: $n < $factor + ($parts ne '4')

  return \@depthsum, $factor, $n;
}

sub tree_n_to_height {
  my ($self, $n) = @_;
  ### tree_n_to_height(): $n

  $n = int($n - $self->{'n_start'});  # N=0 basis
  if ($n < 0) {
    return undef;
  }
  my ($depthsum, $factor, $nrem) = _n0_to_depthsum_factor_rem($n, $self->{'parts'})
    or return $n;  # N=nan or +inf
  ### $depthsum
  ### $factor
  ### $nrem

  my $parts = $self->{'parts'};
  $factor /= $parts;
  if ($parts ne '4') {
    $nrem += ($factor-1)/2;
  }
  (my $quad, $nrem) = _divrem ($nrem, $factor);

  my $sub = pop @$depthsum;
  while (_divrem_mutate($nrem,3) == 1) {  # low "1" ternary digits of Nrem
    $sub += pop @$depthsum;
  }
  if (@$depthsum) {
    return $depthsum->[-1] - 1 - $sub;
  } else {
    return undef;  # N all 1-digits, on central infinite spine
  }
}

1;
__END__

=for stopwords eg Ryde Math-PlanePath Ulam Warburton Ndepth OEIS ie

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

=cut

# math-image --path=UlamWarburton --expression='i<100?i:0' --output=numbers
# and add N=100,N=101 manually

=pod

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
4*3^1=12 cells N=10 to N=21 because 3=0b11 has two 1-bits in binary.  The N
start and end for a level is the cumulative total of those before it,

    Ndepth(level) = 1 + (levelcells(0) + ... + levelcells(level-1))

    Nend(level) = levelcells(0) + ... + levelcells(level)

For example level 3 ends at N=(1+4+4)=9.

    level    Ndepth   levelcells     Nend
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

For a power-of-2 level the Ndepth is

    Ndepth(2^a) = 2 + 4*(4^a-1)/3

For example level=4=2^2 starts at N=2+4*(4^2-1)/3=22, or level=8=2^3 starts
N=2+4*(4^3-1)/3=86.

Further bits in the level value contribute powers-of-4 with a tripling for
each bit above.  So if the level number has bits a,b,c,d,etc in descending
order,

    level = 2^a + 2^b + 2^c + 2^d ...       a>b>c>d...
    Ndepth = 2 + 4*(-1
                    +       4^a
                    +   3 * 4^b
                    + 3^2 * 4^c
                    + 3^3 * 4^d + ... ) / 3

For example level=6 = 2^2+2^1 is Ndepth = 2 + (1+4*(4^2-1)/3) + 4^(1+1) =
38.  Or level=7 = 2^2+2^1+2^0 is Ndepth = 1 + (1+4*(4^2-1)/3) + 4^(1+1) +
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

=head2 Half Plane

Option C<parts =E<gt> '2'> confines the pattern to the upper half plane
C<YE<gt>=0>,

=cut

# math-image --path=UlamWarburton,parts=2 --expression='i<32?i:0' --output=numbers --size=99x16

=pod

    parts => "2"

                      28                           6
                      21                           5
                29 22 16 20 27                     4
                      11                           3
          30       12  6 10       26               2
          23    13     3     9    19               1
    31 24 17 14  7  4  1  2  5  8 15 18 25     <- Y=0
    --------------------------------------
    -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6

Points are still numbered anti-clockwise around so X axis N=1,2,5,8,15,etc
is the first of each level and X negative axis N=1,4,7,14,etc is the last.

Within a row a line from point N to N+1 is always a 45-degree angle.  This
is true of each 3 direct children, but also across groups of children by
symmetry.  For this parts=2 the lines from the last of one row to the first
of the next are horizontal, making an attractive pattern of diagonals and
then across to the next row horizontally.  For parts=4 or parts=1 the last
to first lines are at various different slopes and so upsets the pattern.

=head2 One Quadrant

Option C<parts =E<gt> '1'> confines the pattern to the first quadrant,

=cut

# math-image --path=UlamWarburton,parts=1 --expression='i<20?i:0' --output=numbers --size=99x16

=pod

    parts => "1"

    14  |  73
    13  |  63
    12  |  53 62 72
    11  |  49
    10  |  39 48       71
     9  |  35    47    61
     8  |  31 34 38 46 52 60 70
     7  |  29    45    59
     6  |  19 28       69          67
     5  |  15    27                57
     4  |  11 14 18 26       68 58 51 56 66
     3  |   9    25    23          43
     2  |   5  8    24 17 22    44 37 42       65
     1  |   3     7    13    21    33    41    55
    Y=0 |   1  2  4  6 10 12 16 20 30 32 36 40 50 54 64
        +-----------------------------------------------
          X=0  1  2  3  4  5  6  7  8  9 10 11 12 13 14

X axis N=1,2,4,6,10,etc is the first of each depth level and Y axis
N=1,3,5,9,11,etc is the last.

In this arrangement horizontal arms have even N and vertical arms have
odd N.  For example the vertical at X=8 N=30,33,37,etc has N odd and when it
turns to horizontal at N=42 or N=56 it becomes N even.  The children of N=66
are not shown but the verticals from there are N=79 below and N=81 above and
so are odd again.

This odd/even pattern is true of N=2 horizontal and N=3 vertical and
thereafter is true due to each row having an even number of points and the
self-similar replications in the pattern,

    |\          replication
    | \            block 0 to 1 and 3
    |3 \           and block 0 block 2 less sides
    |----
    |\ 2|\
    | \ | \
    |0 \|1 \
    ---------

Block 0 is the base and is replicated as block 1 and in reverse as block 3.
Block 2 is a further copy of block 0, but the two halves of block 0 rotated
inward 90 degrees, so the X axis of block 0 becomes the vertical of block 2,
and the Y axis of block 0 the horizontal of block 2.  Those axis parts are
dropped since they're already covered by block 1 and 3 and dropping them
flips the odd/even parity to match the vertical/horizontal flip due to the
90-degree rotation.

=head2 N Start

The default is to number points starting N=1 as shown above.  An optional
C<n_start> can give a different start, in the same pattern.  For example to
start at 0,

=cut

# math-image --path=UlamWarburton,n_start=0 --expression='i<38?i:0' --output=numbers

=pod

    n_start => 0

                   29                       5
                30 22 28                    4
                   13                       3
                14  6 12                    2
       31    15     2    11    27           1
    32 23 16  7  3  0  1  5 10 21 26    <- Y=0
       33    17     4     9    25          -1
                18  8 20       37          -2
                   19                      -3
                34 24 36                   -4
                   35                      -5

                    ^
    -5 -4 -3 -2 -1 X=0 1  2  3  4  5

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::UlamWarburton-E<gt>new ()>

=item C<$path = Math::PlanePath::UlamWarburton-E<gt>new (parts =E<gt> $str, n_start =E<gt> $n)>

Create and return a new path object.  The C<parts> option (a string) can be

    "4"     the default
    "2"
    "1"

=back

=head2 Tree Methods

=over

=item C<@n_children = $path-E<gt>tree_n_children($n)>

Return the children of C<$n>, or an empty list if C<$n> has no children
(including when C<$n E<lt> 1>, ie. before the start of the path).

The children are the cells turned on adjacent to C<$n> at the next level.
The way points are numbered means that when there's multiple children
they're consecutive N values, for example at N=6 the children are 10,11,12.

=item C<$num = $path-E<gt>tree_n_num_children($n)>

Return the number of children of C<$n>, or return C<undef> if
C<$nE<lt>n_start()> (ie. before the start of the path).

    parts        possible num children
    -----        ---------------------
      4          0,    3, 4
      2          0, 2, 3
      1          0, 2, 3

parts=4 has 4 children at the origin N=0 and thereafter either 0 or 3.
parts=2 or parts=1 can have 2 children on the boundaries where what would be
a 3rd child is chopped off.

=item C<$n_parent = $path-E<gt>tree_n_parent($n)>

Return the parent node of C<$n>, or C<undef> if C<$n E<lt>= 1> (the start of
the path).

=back

=head1 OEIS

This cellular automaton is in Sloane's Online Encyclopedia of Integer
Sequences as

    http://oeis.org/A147582    (etc)

    parts=4
      A147562   total cells to depth, being tree_depth_to_n() n_start=0
      A147582   added cells at depth

    parts=2
      A183060   total cells to depth=n in half plane
      A183061   added cells at depth=n

    parts=1
      A151922   total cells to depth=n in quadrant
      A079314   added cells at depth=n

The A147582 new cells sequence starts from n=1, so takes the innermost N=1
single cell as level n=1, then N=2,3,4,5 as level n=2 with 5 cells, etc.
This makes the formula a binary 1-bits count on n-1 rather than on N the way
levelcells() above is expressed.

The 1-bits-count power 3^(count 1-bits in level) part of the levelcells() is
also separately in A048883, and as n-1 in A147610.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::UlamWarburtonQuarter>,
L<Math::PlanePath::LCornerTree>,
L<Math::PlanePath::CellularRule>

L<Math::PlanePath::SierpinskiTriangle> (a similar binary 1s-count related
level calculation)

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011, 2012, 2013 Kevin Ryde

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
