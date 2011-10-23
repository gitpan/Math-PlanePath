# Copyright 2011 Kevin Ryde

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


package Math::PlanePath::SierpinskiCurve;
use 5.004;
use strict;
use List::Util qw(min max);

use vars '$VERSION', '@ISA';
$VERSION = 49;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

# uncomment this to run the ### lines
#use Devel::Comments;


use constant n_start => 0;

my @x_negative = (undef,  0,0, 1,1, 1,1, 1,1);
my @y_negative = (undef,  0,0, 0,0, 1,1, 1,1);
sub x_negative {
  my ($self) = @_;
  return $x_negative[$self->{'arms'}];
}
sub y_negative {
  my ($self) = @_;
  return $y_negative[$self->{'arms'}];
}
sub arms_count {
  my ($self) = @_;
  return $self->{'arms'};
}

use constant parameter_info_array =>
  [
   { name      => 'arms',
     share_key => 'arms_8',
     type      => 'integer',
     minimum   => 1,
     maximum   => 8,
     default   => 1,
     width     => 1,
   },

   { name      => 'straight_spacing',
     type      => 'integer',
     minimum   => 1,
     default   => 1,
     width     => 1,
   },
   { name      => 'diagonal_spacing',
     type      => 'integer',
     minimum   => 1,
     default   => 1,
     width     => 1,
   },
  ];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 8) { $arms = 8; }
  $self->{'arms'} = $arms;
  $self->{'straight_spacing'} ||= 1;
  $self->{'diagonal_spacing'} ||= 1;
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### SierpinskiCurve n_to_xy(): $n

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
    # if ($frac) {
    #   my ($x1,$y1) = $self->n_to_xy($int);
    #   my ($x2,$y2) = $self->n_to_xy($int+$arms);
    #
    #   my $dx = $x2-$x1;
    #   my $dy = $y2-$y1;
    #   return ($frac*$dx + $x1, $frac*$dy + $y1);
    # }
    $n = $int; # BigFloat int() gives BigInt, use that
  }
  ### $frac

  # {
  #   my $int = int($n);
  #   $frac = $n - $int;
  #   $n = $int;       # int(BigFloat) gives BigInt, use that
  # }

  my $arm;
  {
    $arm = ($n % $arms);
    $n = int($n/$arms);
  }

  my $s = $self->{'straight_spacing'};
  my $d = $self->{'diagonal_spacing'};
  my $base = 2*$d+$s;
  my $x = my $y = ($n * 0);  # inherit big 0
  my $len = $x + $base;      # inherit big

  while ($n) {
    my $digit = $n % 4;      # low to high
    $n = int($n/4);
    ### at: "$x,$y"
    ### $digit

    if ($digit == 0) {
      $x = $frac + $x;
      $y = $frac + $y;
      $frac = 0;

    } elsif ($digit == 1) {
      ($x,$y) = ($frac - $y + $len-$d-$s,   # rotate +90
                 $x + $d);
      $frac = 0;

    } elsif ($digit == 2) {
      # rotate -90
      ($x,$y) = ($frac + $y  + $len-$d,
                 -$frac - $x + $len-$d-$s);
      $frac = 0;

    } else { # digit==3
      $x += $len;
    }
    $len *= 2;
  }

  # n=0 or n=33..33
  $x = $frac + $x;
  $y = $frac + $y;

  $x += 1;
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

  # use POSIX 'floor';
  # $x += floor($x/3);
  # $y += floor($y/3);

  # $x += floor(($x-1)/3) + floor(($x-2)/3);
  # $y += floor(($y-1)/3) + floor(($y-2)/3);


  ### final: "$x,$y"
  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### SierpinskiCurve xy_to_n(): "$x, $y"

  $x = _round_nearest($x);
  $y = _round_nearest($y);

  # my @xy_mod_off_curve = ([1,0,1],
  #                         [0,1,0],
  #                         [1,0,1]);
  #
  #  1  1  1  1
  #  1  0  1  1
  #  0  1  0  1
  #  1  0  1  1
  #
  #  1  1  0  1
  #  0  1  1  0
  #  1  1  1  1
  #  1  0  1  1
  #
  #
  #
  #
  # unless ((($x%3) + ($y%3)) % 2) {
  #   ### x,y not on 3x3 block usage ...
  #   return undef;
  # }

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

  my $s = $self->{'straight_spacing'};
  my $d = $self->{'diagonal_spacing'};
  my $base = (2*$d+$s);
  my ($len,$level) = _round_down_pow (($x+$y)/$base || 1,  2);
  ### $level
  ### $len
  if (_is_infinite($level)) {
    return $level;
  }

  # Xtop = 3*2^(level-1)-1
  #
  $len *= 2*$base;
  ### initial len: $len

  my $n = 0;
  foreach (0 .. $level) {
    $n *= 4;
    ### at: "loop=$_ len=$len   x=$x,y=$y  n=$n"
    ### assert: $x >= 0
    ### assert: $y >= 0

    my $len_sub_d = $len - $d;
    if ($x < $len_sub_d) {
      ### digit 0 or 1...
      if ($x+$y+$s < $len) {
        ### digit 0 ...
      } else {
        ### digit 1 ...
        ($x,$y) = ($y-$d, $len-$s-$d-$x);   # shift then rotate -90
        $n += 1;
      }
    } else {
      $x -= $len_sub_d;
      ### digit 2 or 3 to: "x=$x y=$y"
      if ($x < $y) {   # before diagonal
        ### digit 2...
        ($x,$y) = ($len-$d-$s-$y, $x);     # shift y-len then rotate +90
        $n += 2;
      } else {
        #### digit 3...
        $x -= $d;
        $n += 3;
      }
      if ($x < 0) {
        return undef;
      }
    }
    $len /= 2;
  }

  ### end at: "x=$x,y=$y   n=$n"
  ### assert: $x >= 0
  ### assert: $y >= 0

  $n *= 4;
  if ($y == 0 && $x == 0) {
    ### final digit 0 ...
  } elsif ($x == $d && $y == $d) {
    ### final digit 1 ...
    $n += 1;
  } elsif ($x == $d+$s && $y == $d) {
    ### final digit 2 ...
    $n += 2;
  } elsif ($x == $base && $y == 0) {
    ### final digit 3 ...
    $n += 3;
  } else {
    return undef;
  }

  return $n*$arms + $arm;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### SierpinskiCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"

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
              || ($arms == 7 && $x1 > 2-$y2))))) {
    ### rect outside octants ...
    return (1,0);
  }

  my $max = ($x2 + $y2);
  if ($arms >= 3) {
    _max ($max, -1-$x1 + $y2);

    if ($arms >= 5) {
      _max ($max, -1-$x1 - $y1-1);

      if ($arms >= 7) {
        _max ($max, $x2 - $y1-1);
      }
    }
  }
  ### $max

  if (_is_infinite($max)) {
    return (0, $max);
  }

  # base=2d+s
  # level begins at
  #   base*(2^level-1)-s = X+Y     ... maybe
  #   base*2^level = X+base
  #   2^level = (X+base)/base
  #   level = log2((X+base)/base)
  # then
  #   Nlevel = 4^level-1

  my $base = 2 * $self->{'diagonal_spacing'} + $self->{'straight_spacing'};
  my ($power) = _round_down_pow ($max / $base || 1,
                                 2);
  return (0, 4*$power*$power * $arms - 1);
}

sub _max {
  ### _max(): "$_[0] cf $_[1]"
  unless ($_[0] > $_[1]) {
    $_[0] = $_[1];
  }
}

sub _round_up_pow2 {
  my ($x) = @_;
  ### _round_up_pow2(): $x
  if ($x < 1) {
    return (1,0);
  }
  # Math::BigInt and Math::BigRat overloaded log() return NaN, use integer
  # based blog()
  my $exp = (ref $x && ($x->isa('Math::BigInt') || $x->isa('Math::BigRat'))
             ? $x->copy->blog(2)
             : int(log($x)/log(2)));
  my $pow = 2 ** $exp;
  ### $exp
  ### $pow
  if ($pow < $x) {
    return (2*$pow, $exp+1)
  } else {
    return ($pow, $exp);
  }
}


1;
__END__

=for stopwords eg Ryde Sierpinski Sierpinski's Math-PlanePath Nlevel

=head1 NAME

Math::PlanePath::SierpinskiCurve -- Sierpinski curve

=head1 SYNOPSIS

 use Math::PlanePath::SierpinskiCurve;
 my $path = Math::PlanePath::SierpinskiCurve->new (arms => 2);
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is an integer version of the self-similar curve by Waclaw Sierpinski
traversing the plane by right triangles.  The default is a single arm of the
curve in an eighth of the plane.


    10  |                                  31-32                 
        |                                 /     \
     9  |                               30       33              
        |                                |        |
     8  |                               29       34              
        |                                 \     /
     7  |                         25-26    28 35    37-38        
        |                        /     \  /     \  /     \
     6  |                      24       27       36       39     
        |                       |                          |
     5  |                      23       20       43       40     
        |                        \     /  \     /  \     /
     4  |                 7--8    22-21    19 44    42-41    55-...
        |               /     \           /     \           /
     3  |              6        9       18       45       54     
        |              |        |        |        |        |
     2  |              5       10       17       46       53     
        |               \     /           \     /           \
     1  |        1--2     4 11    13-14    16 47    49-50    52  
        |      /     \  /     \  /     \  /     \  /     \  /
    Y=0 |  .  0        3       12       15       48       51    
        |
        +-----------------------------------------------------------
           ^
          X=0 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16

The tiling it represents is

                    /
                   /|\
                  / | \
                 /  |  \
                /  7| 8 \
               / \  |  / \
              /   \ | /   \
             /  6  \|/  9  \
            /-------|-------\
           /|\  5  /|\ 10  /|\
          / | \   / | \   / | \
         /  |  \ /  |  \ /  |  \
        /  1| 2 X 4 |11 X 13|14 \
       / \  |  / \  |  / \  |  / \ ...
      /   \ | /   \ | /   \ | /   \
     /  0  \|/  3  \|/  12 \|/  15 \
    ----------------------------------

The points are on a square grid with integer X,Y.  4 points are used in each
3x3 block.  In general a point is used if

    X%3==1 or Y%3==1 but not both

    which means
    ((X%3)+(Y%3)) % 2 == 1

=head2 Level Ranges

Counting the N=0 to N=3 as level=1, N=0 to N=15 as level 2, etc, the end of
each level, back at the X axis, is

    Nlevel = 4^level - 1
    Xlevel = 3*2^level - 2
    Ylevel = 0

For example level=2 is Nend = 2^(2*2)-1 = 15 at X=3*2^2-2 = 10.

The top of each level is half way along,

    Ntop = (4^level)/2 - 1
    Xtop = 3*2^(level-1) - 1
    Ytop = 3*2^(level-1) - 2

For example level=3 is Ntop = 2^(2*3-1)-1 = 31 at X=3*2^(3-1)-1 = 11 and
Y=3*2^(3-1)-2 = 10.

The factor of 3 arises essentially from the three steps which make up the
N=0,1,2,3 section.  The Xlevel width grows as

    Xlevel(1) = 3
    Xlevel(level+1) = 2*Xwidth(level) + 3

which dividing out the factor of 3 is 2*w+1, given 2^k-1 (in binary a left
shift and bring in a new 1 bit, giving 2^k-1).

=head2 Arms

The optional C<arms> parameter can draw multiple curves, each advancing
successively.  For example C<arms =E<gt> 2>,

                                  ...
                                   |
       33       39       57       63         11
      /  \     /  \     /  \     /
    31    35-37    41 55    59-61    62-..   10
      \           /     \           /
       29       43       53       60          9
        |        |        |        |
       27       45       51       58          8
      /           \     /           \
    25    21-19    47-49    50-52    56       7
      \  /     \           /     \  /
       23       17       48       54          6
                 |        |
        9       15       46       40          5
      /  \     /           \     /  \
     7    11-13    14-16    44-42    38       4
      \           /     \           /
        5       12       18       36          3
        |        |        |        |
        3       10       20       34          2
      /           \     /           \
     1     2--4     8 22    26-28    32       1
         /     \  /     \  /     \  /
        0        6       24       30      <- Y=0

     ^
    X=0 1  2  3  4  5  6  7  8  9 10 11

The N=0 point is at X=1,Y=0 (in all arms forms) so that the second arm is
within the first quadrant.

Anywhere between 1 and 8 arms can be done this way.  C<arms=E<gt>8> is as
follows.

           ...                       ...           6
            |                          |
           58       34       33       57           5
             \     /  \     /  \     /
    ...-59    50-42    26 25    41-49    56-...    4
          \           /     \           /
           51       18       17       48           3
            |        |        |        |
           43       10        9       40           2
          /           \     /           \
        35    19-11     2  1     8-16    32        1
          \  /     \           /     \  /
           27        3     .  0       24       <- Y=0

           28        4        7       31          -1
          /  \     /           \     /  \
        36    20-12     5  6    15-23    39       -2
          \           /     \           /
           44       13       14       47          -3
            |        |        |        |
           52       21       22       55          -4
          /           \     /           \
    ...-60    53-45    29 30    46-54    63-...   -5
             /     \  /     \  /     \
           61       37       38       62          -6
            |                          |
           ...                       ...          -7

                           ^
     -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6

The middle "." is the origin X=0,Y=0.  It'd be more symmetrical to make the
origin the middle of the eight arms, at X=-0.5,Y=-0.5 in the above, but that
would give fractional X,Y values.  Apply an offset as X+0.5,Y+0.5 if
desired.

=head2 Spacing

The optional C<diagonal_spacing> and C<straight_spacing> can increase the
space between points diagonally or vertically/horizontally.  The default for
each is 1.

    $path = Math::PlanePath::SierpinskiCurve->new
               (straight_spacing => 2,
               (diagonal_spacing => 1)

The effect is only to spread the points.  In the level formulas above the
"3" factor becomes 2*d+s, effectively being the N=0 to N=3 section being
d+s+d.

    d = diagonal_spacing
    s = straight_spacing

    Xlevel = (2d+s)*(2^level - 1)  + 1

    Xtop = (2d+s)*2^(level-1) - d - s + 1
    Ytop = (2d+s)*2^(level-1) - d - s

=head2 Closed Curve

Sierpinki's original conception was a closed curve filling a unit square by
ever greater self-similar detail,

    /\_/\ /\_/\ /\_/\ /\_/\
    \   / \   / \   / \   /
     | |   | |   | |   | |
    / _ \_/ _ \ / _ \_/ _ \
    \/ \   / \/ \/ \   / \/
       |  |         | |
    /\_/ _ \_/\ /\_/ _ \_/\
    \   / \   / \   / \   /
     | |   | |   | |   | |
    / _ \ / _ \_/ _ \ / _ \
    \/ \/ \/ \   / \/ \/ \/
              | |
    /\_/\ /\_/ _ \_/\ /\_/\
    \   / \   / \   / \   /
     | |   | |   | |   | |
    / _ \_/ _ \ / _ \_/ _ \
    \/ \   / \/ \/ \   / \/
       |  |         | |
    /\_/ _ \_/\ /\_/ _ \_/\
    \   / \   / \   / \   /
     | |   | |   | |   | |
    / _ \ / _ \ / _ \ / _ \
    \/ \/ \/ \/ \/ \/ \/ \/

The code here might be pressed into use for this by drawing a mirror image
of the curve (N=0 through Nlevel above).  Or using the C<arms=E<gt>2> form
(N=0 to N=4^level, inclusive), and joining up the ends.

The curve is usually conceived as scaling down by quarters.  This can be had
with C<straight_spacing =E<gt> 2>, and then an offset to X+1,Y+1 to centre
in a 4*2^level square

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::SierpinskiCurve-E<gt>new ()>

=item C<$path = Math::PlanePath::SierpinskiCurve-E<gt>new (arms =E<gt> 8)>

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
L<Math::PlanePath::SierpinskiArrowhead>,
L<Math::PlanePath::KochCurve>

=cut




   #                                              63-64            14
   #                                               |  |
   #                                              62 65            13
   #                                             /     \
   #                                        60-61       66-67      12
   #                                         |              |
   #                                        59-58       69-68      11
   #                                             \     /
   #                                  51-52       57 70            10
   #                                   |  |        |  |
   #                                  50 53       56 71       ...   9
   #                                 /     \     /     \     /
   #                            48-49       54-55       72-73       8
   #                             |
   #                            47-46       41-40                   7
   #                                 \     /     \
   #                      15-16       45 42       39                6
   #                       |  |        |  |        |
   #                      14 17       44-43       38                5
   #                     /     \                 /
   #                12-13       18-19       36-37                   4
   #                 |              |        |
   #                11-10       21-20       35-34                   3
   #                     \     /                 \
   #           3--4        9 22       27-28       33                2
   #           |  |        |  |        |  |        |
   #           2  5        8 23       26 29       32                1
   #         /     \     /     \     /     \     /
   #     0--1        6--7       24-25       30-31                 Y=0
   #
   #  ^
   # X=0 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 ...

    #                                                                 127-128
    #                                                                /       \
    #                                                              126      ...
    #                                                                |
    #                                                              125
    #                                                                 \
    #                                                        121-122  124
    #                                                        /     \  /
    #                                                     120      123
    #                                                       |
    #                                                     119      116
    #                                                        \     /  \
    #                                               103-104  118-117  115
    #                                               /     \           /
    #                                             102     105      114
    #                                              |       |         |
    #                                             101     106      113
    #                                               \     /           \
    #                                       97-98   100 107  109-110  112
    #                                      /     \  /     \  /     \  /
    #                                    96       99      108      111
    #                                     |
    #                                    95       92       83       80
    #                                      \     /  \     /  \     /  \
    #                              31-32    94-93    91 84    82-81    79
    #                             /     \           /     \           /
    #                           30       33       90       85       78
    #                            |        |        |        |        |
    #                           29       34       89       86       77
    #                             \     /           \     /           \
    #                     25-26    28 35    37-38    88-87    73-74    76
    #                    /     \  /     \  /     \           /     \  /
    #                  24       27       36       39       72       75
    #                   |                          |        |
    #                  23       20       43       40       71       68
    #                    \     /  \     /  \     /           \     /  \
    #             7--8    22-21    19 44    42-41    55-56    70-69    67
    #           /     \           /     \           /     \           /
    #          6        9       18       45       54       57       66
    #          |        |        |        |        |        |        |
    #          5       10       17       46       53       58       65
    #           \     /           \     /           \     /           \
    #    1--2     4 11    13-14    16 47    49-50    52 59    61-62    64
    #  /     \  /     \  /     \  /     \  /     \  /     \  /     \  /
    # 0        3       12       15       48       51       60       63

# The factor of 3 arises because there's a gap between each level, increasing
# it by a fixed extra each time,
# 
#     length(level) = 2*length(level-1) + 2
#                   = 2^level + (2^level + 2^(level-1) + ... + 2)
#                   = 2^level + (2^(level+1)-1 - 1)
#                   = 3*2^level - 2



# Local variables:
# compile-command: "math-image --path=SierpinskiCurve --lines --scale=10"
# End:
#
# math-image --path=SierpinskiCurve --all --output=numbers_dash