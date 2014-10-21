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




# math-image --path=SierpinskiCurveStair --lines --scale=10
#
# math-image --path=SierpinskiCurveStair,diagonal_length=1 --all --output=numbers_dash --offset=-10,-7 --size=78x30



package Math::PlanePath::SierpinskiCurveStair;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 75;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;

# x,y negatives by number of arms
my @x_negative = (undef,  0,0, 1,1, 1,1, 1,1);
my @y_negative = (undef,  0,0, 0,0, 1,1, 1,1);
sub x_negative {
  my ($self) = @_;
  return $x_negative[$self->arms_count];
}
sub y_negative {
  my ($self) = @_;
  return $y_negative[$self->arms_count];
}

sub arms_count {
  my ($self) = @_;
  return $self->{'arms'};
}

use constant parameter_info_array =>
  [
   { name        => 'diagonal_length',
     type        => 'integer',
     minimum     => 1,
     default     => 1,
     width       => 1,
     description => 'Length of the diagonal in the base pattern.',
   },
   { name      => 'arms',
     share_key => 'arms_8',
     type      => 'integer',
     minimum   => 1,
     maximum   => 8,
     default   => 1,
     width     => 1,
   },
  ];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);

  $self->{'diagonal_length'} ||= 1;

  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 8) { $arms = 8; }
  $self->{'arms'} = $arms;

  return $self;
}

#                        20--21
#                         |   |
#                    18--19  22--23
#                     |           |
#                16--17          24--25
#                 |                   |
#                15--14          27--26
#                     |           |
#         4---5      13--12  29--28      36--37
#         |   |           |   |           |   |
#     2---3   6---7  10--11  30--31  34--35  38--39  42--43
#     |           |   |           |   |           |   |
# 0---1           8---9          32--33          40--41

# len=5
# N=0 to 9 is 10
# next N=0 to 41 is 42=4*10+2
# next is 4*42+2=166
# points(level) = 4*points(level-1)+2
#
# or side 5 points
# points(level) = 4*points(level-1)+1
#               = 4*(4*points(level-2)+1)+1
#               = 16*points(level-2) + 4 + 1
#               = 64*points(level-3) + 16 + 4 + 1
#               = 5 * 4^level + 1+...+4^(level-1)
#               = 5 * 4^level + (4^level - 1) / 3
#               = (15 * 4^level + 4^level - 1) / 3
#               = (16 * 4^level - 1) / 3
#               = (4^(level+2) - 1) / 3
# level=0 (16*1-1)/3=5
# level=1 (16*4-1)/3=21
# level=2 (16*16-1)/3=85
#
# n = (16 * 4^level - 1) / 3
# 3n+1 = 16 * 4^level
# 4^level = (3n+1)/16
# level = log4 ( (3n+1)/16)
#       = log4(3n+1) - 2
# N=21 log4(64)-2=3-2=1
#
# nlen=4^(level+2)
# n = (nlen-1)/3
# next_n = (nlen/4-1)/3
#        = (nlen-4)/3 /4
#        = ((nlen-1)/3 -1) /4
#
# len=2,6,14
# len(k)=2*len(k-1) + 2
#       = 2^k + 2*(2^(k-1)-1)
#       = 2^k + 2^k - 2
#       = 2*(2^k - 1)
# k=1 len=2*(2-1) = 2
# k=2 len=2*(4-1) = 6
# k=3 len=2*(8-1) = 14

# len(k)-2=2*len(k-1)
# (len(k)-2)/2=len(k-1)
# len(k-1) = (len(k)-2)/2
#          = len(k)/2-1
#
# ---------
# with P=2*L+1 points per side
# points(level) = 64*points(level-3) + 16 + 4 + 1
#               = P*4^level + 1+...+4^(level-1)
#               = P*4^level + (4^level - 1) / 3
#               = (3P*4^level + 4^level - 1) / 3
#               = ((3P+1)*4^level - 1) / 3
#               = ((3*(2L+1)+1)*4^level - 1) / 3
#               = ((6L+3+1)*4^level - 1) / 3
#               = ((6L+4)*4^level - 1) / 3
# n = ((6L+4)*4^level - 1) / 3
# 3n+1 = (6L+4)*4^level
#
# len(k) = 2*len(k-1) + 2
#        = 2*len(k-2) + 2 + 4
#        = 2*len(k-3) + 2 + 4 + 8
#        = 2^(k-1)*L + 2^k - 2
#        = (L+2)*2^(k-1) - 2
# L=2 k=3 len=(2+2)*2^2-2=14
#
# ----------
# Nlevel = ((6L+4)*4^level - 1) / 3 - 1
#        = ((6L+4)*4^level - 4) / 3
# Xlevel = (L+2)*2^level - 2 + 1
#        = (L+2)*2^level - 1
#
# fill = Nlevel / (Xlevel*(Xlevel-1)/2)
#      = (((6L+4)*4^level - 1) / 3 - 1) / (((L+2)*2^level - 1)*((L+2)*2^level - 2))
#     -> (((6L+4)*4^level) / 3) / ((L+2)*2^level)^2
#      = ((6L+4)*4^level) / ((L+2)^2*4^level) *2/3
#      = ((6L+4)) / ((L+2)^2) * 2/3
#      = 2*(3L+2) / ((L+2)^2) * 2/3
#      = 4/3 * (3L+2)/(L+2)^2
#      = (12L+8) / (3*L^2+12L+12)
# L=1 (12+8)/(3+12+12) = 20/27


sub n_to_xy {
  my ($self, $n) = @_;
  ### SierpinskiCurveStair n_to_xy(): $n

  if ($n < 0) {
    return;
  }
  if (_is_infinite($n)) {
    return ($n,$n);
  }

  my $arms = $self->{'arms'};
  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;  # inherit possible BigFloat
    if ($frac) {
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+$arms);

      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int; # BigFloat int() gives BigInt, use that
  }
  ### $frac

  my $arm;
  {
    $arm = ($n % $arms);
    $n = int($n/$arms);
  }

  my $zero = ($n * 0);  # inherit bignum 0

  my $diagonal_length = $self->{'diagonal_length'};
  my $diagonal_div = 6*$diagonal_length + 4;

  my ($nlen,$level) = _round_down_pow ((3*$n+1)/$diagonal_div, 4);
  ### $nlen
  ### $level
  if (_is_infinite($level)) {
    return $level;
  }

  my $x = $zero;
  my $y = $zero;
  my $dx = 1;
  my $dy = 0;

  # (L+2)*2^(level-1) - 2
  my $len = ($diagonal_length+2)*2**$level - 2;
  $nlen = ($diagonal_div*$nlen-1)/3;

  while ($level-- >= 0) {
    ### at: "n=$n xy=$x,$y  nlen=$nlen len=$len"

    if ($n < 2*$nlen+1) {
      if ($n < $nlen) {
        ### part 0 ...
      } else {
        ### part 1 ...
        $x += ($len+1)*$dx - $len*$dy;
        $y += ($len+1)*$dy + $len*$dx;
        ($dx,$dy) = ($dy,-$dx); # rotate -90
        $n -= $nlen;
      }
    } else {
      $n -= 2*$nlen+1;
      if ($n < $nlen) {
        ### part 2 ...
        $x += (2*$len+2)*$dx - $dy;
        $y += (2*$len+2)*$dy + $dx;
        ($dx,$dy) = (-$dy,$dx); # rotate +90
      } else {
        ### part 3 ...
        $x += ($len+2)*$dx - ($len+2)*$dy;
        $y += ($len+2)*$dy + ($len+2)*$dx;
        $n -= $nlen;
      }
    }

    $nlen = ($nlen-1)/4;
    $len = $len/2-1;
  }

  my $lowdigit_x = int(($n+1)/2);
  if ($n == 2*$diagonal_length+1) { $lowdigit_x -= 2; }
  my $lowdigit_y = int($n/2);

  ### final: "n=$n  xy=$x,$y  dxdy=$dx,$dy"
  ### $lowdigit_x
  ### $lowdigit_y

  $x += $lowdigit_x*$dx - $lowdigit_y*$dy + 1;  # +1 start at x=1,y=0
  $y += $lowdigit_x*$dy + $lowdigit_y*$dx;

  if ($arm & 1) {
    ($x,$y) = ($y,$x);   # mirror 45
  }
  if ($arm & 2) {
    ($x,$y) = (-1-$y,$x);   # rotate +90
  }
  if ($arm & 4) {
    $x = -1-$x;   # rotate 180
    $y = -1-$y;
  }

  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### SierpinskiCurveStair xy_to_n(): "$x, $y"

  $x = _round_nearest($x);
  $y = _round_nearest($y);

  my $arm = 0;
  if ($y < 0) {
    $arm = 4;
    $x = -1-$x;  # rotate -180
    $y = -1-$y;
  }
  if ($x < 0) {
    $arm += 2;
    ($x,$y) = ($y, -1-$x);  # rotate -90
  }
  if ($y > $x) {       # second octant
    $arm++;
    ($x,$y) = ($y,$x); # mirror 45
  }

  my $arms = $self->{'arms'};
  if ($arm >= $arms) {
    return undef;
  }

  $x -= 1;
  if ($x < 0 || $x < $y) {
    return undef;
  }
  ### x adjust to zero: "$x,$y"
  ### assert: $x >= 0
  ### assert: $y >= 0

  # len=2*(2^level - 1)
  # len/2+1 = 2^level
  # 2^level = len/2+1
  # 2^(level+1) = len+2

  # len=(L+2)*2^(level-1) - 2
  # (len+2)/(L+2) = 2^(level-1)

  my $diagonal_length = $self->{'diagonal_length'};
  my ($len,$level) = _round_down_pow (($x+1)/($diagonal_length+2), 2);
  ### $level
  ### $len
  if (_is_infinite($level)) {
    return $level;
  }

  my $n = 0;
  my $nlen = ((6*$diagonal_length+4)*$len*$len-1)/3;
  $len *= ($self->{'diagonal_length'}+2);
  ### $len
  ### $nlen

  my $n_last_1;
  foreach (0 .. $level) {
    ### at: "loop=$_   x=$x,y=$y  n=$n nlen=$nlen   len=$len diag cmp ".(2*$len-2)
    ### assert: $x >= 0
    ### assert: $y >= 0

    if ($x+$y <= 2*$len-2) {
      ### part 0 or 1...
      if ($x < $len-1) {
        ### part 0 ...
        $n_last_1 = 0;
      } else {
        ### part 1 ...
        ($x,$y) = ($len-2-$y, $x-($len-1));   # shift then rotate +90
        $n += $nlen;
        $n_last_1 = 1;
      }
    } else {
      $n += 2*$nlen + 1;  # +1 for middle point
      ### part 2 or 3 ...
      if ($y < $len) {
        ### part 2...
        ($x,$y) = ($y-1, 2*$len-2-$x);     # shift y-1 then rotate -90
        $n_last_1 = 0;
      } else {
        #### digit 3...
        $x -= $len;
        $y -= $len;
        $n += $nlen;
      }
      if ($x < 0) {
        return undef;
      }
    }
    $len /= 2;
    $nlen = ($nlen-1)/4;
  }

  ### end at: "x=$x,y=$y   n=$n  last2=$n_last_1"
  ### assert: $x >= 0
  ### assert: $y >= 0

  if ($x == $y || $x == $y+1) {
    $n += $x+$y;
  } elsif ($n_last_1 && $x == $diagonal_length-1 && $y == $diagonal_length) {
    # in between diagonals
    $n += 2*$diagonal_length+1;
  } else {
    return undef;
  }

  return $n*$arms + $arm;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### SierpinskiCurveStair rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = _round_nearest ($x1);
  $x2 = _round_nearest ($x2);
  $y1 = _round_nearest ($y1);
  $y2 = _round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  #            x2
  # y2 +-------+      *
  #    |       |    *
  # y1 +-------+  *
  #             *
  #           *
  #         *
  #       ------------------
  #
  #
  #               *
  #   x1    *  x2 *
  #    +-----*-+y2*
  #    |      *|  *
  #    |       *  *
  #    |       |* *
  #    |       | **
  #    +-------+y1*
  #   ----------------
  #
  my $arms = $self->{'arms'};
  if (($arms <= 4
       ? ($y2 < 0  # y2 negative, nothing ...
          || ($arms == 1 && $x2 <= $y1)
          || ($arms == 2 && $x2 < 0)
          || ($arms == 3 && $x2 < -$y2))

       # arms >= 5
       : ($y2 < 0
          && (($arms == 5 && $x1 >= $y2)
              || ($arms == 6 && $x1 >= 0)
              || ($arms == 7 && $x1 > 3-$y2))))) {
    ### rect outside octants, for arms: $arms
    ### $x1
    ### $y2
    return (1,0);
  }

  my $max = $x2;   # arms 1,8 using X, starting at X=1
  if ($arms >= 2) {
    # arms 2,3 upper using Y, starting at Y=1
    _apply_max ($max, $y2);

    if ($arms >= 4) {
      # arms 4,5 right using X, starting at X=-2
      _apply_max ($max, -1-$x1);

      if ($arms >= 6) {
        # arms 6,7 down using Y, starting at Y=-2
        _apply_max ($max, -1-$y1);
      }
    }
  }
  ### $max


  # points(level) = (4^(level+2) - 1) / 3
  # Nlast(level) = (4^(level+2) - 1) / 3 - 1
  #              = (4^(level+2) - 4) / 3
  # then + arms-1 for last of arms
  # Nhi = Nlast(level) * arms + arms-1
  #     = (Nlast(level + 1)) * arms - 1
  #     = ((4^(level+2) - 4) / 3 + 1) * arms - 1
  #     = ((4^(level+2) - 1) / 3) * arms - 1
  # my ($len, $level) = _round_down_pow ($max, 2);

  # len(level) = = (L+2)*2^(level-1) - 2
  # points(level) = ((3*P+1)*4^level - 1) / 3
  #
  my ($pow,$level) = _round_down_pow ($max/($self->{'diagonal_length'}+2),
                                      2);
  return (0,
          ((6*$self->{'diagonal_length'}+4)*4*$pow*$pow - 1) / 3
          * $arms - 1);
}

# set $_[0] to the max of $_[0] and $_[1]
sub _apply_max {
  ### _apply_max(): "$_[0] cf $_[1]"
  unless ($_[0] > $_[1]) {
    $_[0] = $_[1];
  }
}

1;
__END__


   #                                          84-85
   #                                           |  |
   #                                       82-83 ...
   #                                        |
   #                                    80-81
   #                                     |
   #                                    79-78
   #                                        |
   #                              68-69    77-76
   #                               |  |        |
   #                           66-67 70-71 74-75
   #                            |        |  |
   #                        64-65       72-73
   #                         |
   #                        63-62       55-54
   #                            |        |  |
   #                  20-21    61-60 57-56 53-52
   #                   |  |        |  |        |
   #               18-19 22-23    59-58    50-51
   #                |        |              |
   #            16-17       24-25       48-49
   #             |              |        |
   #            15-14       27-26       47-46
   #                |        |              |
   #       4--5    13-12 29-28    36-37    45-44
   #       |  |        |  |        |  |        |
   #    2--3  6--7 10-11 30-31 34-35 38-39 42-43
   #    |        |  |        |  |        |  |
   # 0--1        8--9       32-33       40-41


     #               ..--90       89--..                      7
     #                    |        |
     #                   82-74 73-81                          6
     #                       |  |
     #                   58-66 65-57                          5
     #                    |        |
     #                42-50       49-41                       4
     #                 |              |
     #                34-26       25-33                       3
     #                    |        |
     # ...      43-35    18-10  9-17    32-40       ..        2
     #  |        |  |        |  |        |  |        |
     # 91-83 59-51 27-19     2  1    16-24 48-56 80-88        1
     #     |  |        |              |        |  |
     #    75-67       11--3     .  0--8       64-72      <- Y=0
     # 
     #    76-68       12--4        7-15       71-79          -1
     #     |  |        |              |        |  |
     # 92-84 60-52 28-20     5  6    23-31 55-63 87-95       -2
     #  |        |  |        |  |        |  |        |
     # ..       44-36    21-13 14-22    39-47       ..       -3
     #                    |        |
     #                37-29       30-38                      -4
     #                 |              |
     #                45-53       54-46                      -5
     #                    |        |
     #                   61-69 70-62                         -6
     #                       |  |
     #                   85-77 78-86                         -7
     #                    |        |
     #               ..--93       94--..                     -8
     # 
     #                          ^
     # -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7

=for stopwords eg Ryde Waclaw Sierpinski Sierpinski's Math-PlanePath Nlevel CornerReplicate Nend Ntop Xlevel SierpinskiCurve

=head1 NAME

Math::PlanePath::SierpinskiCurveStair -- Sierpinski curve with stair-step diagonals

=head1 SYNOPSIS

 use Math::PlanePath::SierpinskiCurveStair;
 my $path = Math::PlanePath::SierpinskiCurveStair->new (arms => 2);
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is a variation on the SierpinskiCurve with stair-step diagonal parts.

    10  |                                  52-53
        |                                   |  |
     9  |                               50-51 54-55
        |                                |        |
     8  |                               49-48 57-56
        |                                   |  |
     7  |                         42-43 46-47 58-59 62-63
        |                          |  |  |        |  |  |
     6  |                      40-41 44-45       60-61 64-65
        |                       |                          |
     5  |                      39-38 35-34       71-70 67-66
        |                          |  |  |        |  |  |
     4  |                12-13    37-36 33-32 73-72 69-68    92-93
        |                 |  |              |  |              |  |
     3  |             10-11 14-15       30-31 74-75       90-91 94-95
        |              |        |        |        |        |        |
     2  |              9--8 17-16       29-28 77-76       89-88 97-96
        |                 |  |              |  |              |  |
     1  |        2--3  6--7 18-19 22-23 26-27 78-79 82-83 86-87 98-99
        |        |  |  |        |  |  |  |        |  |  |  |        |
    Y=0 |     0--1  4--5       20-21 24-25       80-81 84-85       ...
        |
        +-------------------------------------------------------------
           ^
          X=0 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19

The tiling is the same as the SierpinskiCurve, but each diagonal is a stair
step horizontal and vertical.  The correspondence is

    SierpinskiCurve        SierpinskiCurveStair

                7--                   12--
              /                        |
             6                     10-11
             |                      |
             5                      9--8
              \                        |
       1--2     4             2--3  6--7
     /     \  /               |  |  |
    0        3             0--1  4--5

So the SierpinskiCurve N=0 to N=1 diagonal corresponds to N=0 to N=2 here,
and N=2 to N=3 corresponds to N=3 to N=5.  The join section N=3 to N=4 gets
an extra point at N=6 here, and later similar N=19, etc.

=head2 Diagonal Length

The C<diagonal_length> option can make longer diagonals, still in stair-step
style.  For example C<diagonal_length =E<gt> 4>,

    10  |                                 36-37
        |                                  |  |
     9  |                              34-35 38-39
        |                               |        |
     8  |                           32-33       40-41
        |                            |              |
     7  |                        30-31             42-43
        |                         |                    |
     6  |                     28-29                   44-45
        |                      |                          |
     5  |                     27-26                   47-46
        |                         |                    |
     4  |                8--9    25-24             49-48    ...
        |                |  |        |              |        |
     3  |             6--7 10-11    23-22       51-50    62-63
        |             |        |        |        |        |
     2  |          4--5       12-13    21-20 53-52    60-61
        |          |              |        |  |        |
     1  |       2--3             14-15 18-19 54-55 58-59
        |       |                    |  |        |  |
    Y=0 |    0--1                   16-17       56-57
        |
        +------------------------------------------------------
          ^
         X=0 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17

The length is reckoned from N=0 to the end of the first side N=8, which is
X=1 to X=5 for length 4 units.

=head2 Arms

The optional C<arms> parameter can give up to eight copies of the curve,
each advancing successively.  For example C<arms =E<gt> 8>,

       98-90 66-58       57-65 89-97            5   
           |  |  |        |  |  |                   
    99    82-74 50-42 41-49 73-81    96         4   
     |              |  |              |             
    91-83       26-34 33-25       80-88         3   
        |        |        |        |                
    67-75       18-10  9-17       72-64         2   
     |              |  |              |             
    59-51 27-19     2  1    16-24 48-56         1   
        |  |  |              |  |  |                
       43-35 11--3     .  0--8 32-40       <- Y=0   
                                                    
       44-36 12--4        7-15 39-47           -1   
        |  |  |              |  |  |                
    60-52 28-20     5  6    23-31 55-63        -2   
     |              |  |              |             
    68-76       21-13 14-22       79-71        -3   
        |        |        |        |                
    92-84       29-37 38-30       87-95        -4   
                    |  |                            
          85-77 53-45 46-54 78-86              -5   
           |  |  |        |  |  |                   
          93 69-61       62-70 94              -6   
                                                    
                       ^
    -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6

The multiplies of 8 (or however many arms) N=0,8,16,etc is the original
curve, and the further mod 8 parts are the copies.

The middle "." shown is the origin X=0,Y=0.  It would be more symmetrical to
have the origin the middle of the eight arms, which would be X=-0.5,Y=-0.5
in the above, but that would give fractional X,Y values.  Apply an offset
X+0.5,Y+0.5 to centre if desired.

=head2 Level Ranges

For C<diagonal_length> = L and reckoning the first diagonal side N=0 to N=2L
as level 0, a level extends out to a triangle

    Nlevel = ((6L+4)*4^level - 4) / 3
    Xlevel = (L+2)*2^level - 1

For example level 2 in the default L=1 goes to N=((6*1+4)*4^2-4)/3=52 and
Xlevel=(1+2)*2^2-1=11.  Or in the L=4 sample above level 1 is
N=((6*4+4)*4^1-4)/3=36 and Xlevel=(4+2)*2^1-1=11.

The power-of-4 in Nlevel is per the plain SierpinskiCurve, with factor 2L+1
for the points making the diagonal stair.  The "/3" arises from the extra
points between replications.  They become a power-of-4 series

    Nextras = 1+4+4^2+...+4^(level-1) = (4^level-1)/3

For example level 1 is Nextras=(4^1-1)/3=1, being point N=6 in the default
L=1.  Or for level 2 Nextras=(4^2-1)/3=5 at N=6 and N=19,26,33,46.

The curve doesn't visit all the points in the eighth of the plane below the
X=Y diagonal.  In general Nlevel+1 many points of the triangular area
Xlevel*(Xlevel-1)/2 are visited, for a filled fraction which approaches a
constant

    FillFrac = Nlevel / (Xlevel*(Xlevel-1)/2)
            -> 4/3 * (3L+2)/(L+2)^2

For example the default L=1 has FillFrac=20/27=0.74.  Or L=2
FillFrac=2/3=0.66.  As the diagonal length increases the fraction decreases
due to the growing holes in the pattern.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::SierpinskiCurveStair-E<gt>new ()>

=item C<$path = Math::PlanePath::SierpinskiCurveStair-E<gt>new (diagonal_length =E<gt> $L, arms =E<gt> $A)>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SierpinskiCurve>

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
