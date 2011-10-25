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


# math-image --path=DragonRounded --lines --scale=10
# math-image --path=DragonRounded,arms=4 --all --output=numbers_dash --size=132x60
#


package Math::PlanePath::DragonRounded;
use 5.004;
use strict;
use List::Util qw(max);

use vars '$VERSION', '@ISA';
$VERSION = 50;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;
*_floor = \&Math::PlanePath::_floor;

use Math::PlanePath::SierpinskiArrowhead;
*_round_up_pow2 = \&Math::PlanePath::SierpinskiArrowhead::_round_up_pow2;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant n_start => 0;
sub arms_count {
  my ($self) = @_;
  return $self->{'arms'} || 1;
}

use constant parameter_info_array => [ { name      => 'arms',
                                         share_key => 'arms_4',
                                         type      => 'integer',
                                         minimum   => 1,
                                         maximum   => 4,
                                         default   => 1,
                                         width     => 1,
                                         description => 'Arms',
                                       } ];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 4) { $arms = 4; }
  $self->{'arms'} = $arms;
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### DragonRounded n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n, $n); }

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;
    $n = $int; # BigFloat int() gives BigInt, use that
  }
  ### $frac

  my $zero = ($n * 0);  # inherit bignum 0

  my $arms = $self->{'arms'};
  my $rot = $n % $arms;
  $n = int($n/$arms);

  my $x_offset = ($n % 2);
  $n = int($n/2);

  # ENHANCE-ME: sx,sy just from len=3*2**level
  my @digits;
  my @sx;
  my @sy;
  {
    my $sx = $zero + 3;
    my $sy = $zero;
    while ($n) {
      push @digits, ($n % 2);
      push @sx, $sx;
      push @sy, $sy;
      $n = int($n/2);

      # (sx,sy) + rot+90(sx,sy)
      ($sx,$sy) = ($sx - $sy,
                   $sy + $sx);
    }
  }

  ### @digits
  my $rev = 0;
  my $x = $zero;
  my $y = $zero;
  my $above_low_zero = 0;

  for (my $i = $#digits; $i >= 0; $i--) {     # high to low
    my $digit = $digits[$i];
    my $sx = $sx[$i];
    my $sy = $sy[$i];
    ### at: "$x,$y  $digit   side $sx,$sy"
    ### $rot

    if ($rot & 2) {
      ($sx,$sy) = (-$sx,-$sy);
    }
    if ($rot & 1) {
      ($sx,$sy) = (-$sy,$sx);
    }
    ### rotated side: "$sx,$sy"

    if ($rev) {
      if ($digit) {
        $x += -$sy;
        $y += $sx;
        ### rev add to: "$x,$y next is still rev"
      } else {
        $above_low_zero = $digits[$i+1];
        $rot ++;
        $rev = 0;
        ### rev rot, next is no rev ...
      }
    } else {
      if ($digit) {
        $rot ++;
        $x += $sx;
        $y += $sy;
        $rev = 1;
        ### plain add to: "$x,$y next is rev"
      } else {
        $above_low_zero = $digits[$i+1];
      }
    }
  }

  # Digit above the low zero is the direction of the next turn, 0 for left,
  # 1 for right, and that determines the y_offset to apply to go across
  # towards the next edge.  When original input $n is odd, which means
  # $x_offset 0 at this point, there's no y_offset as going along the edge
  # not across the vertex.
  #
  my $y_offset = ($x_offset ? ($above_low_zero ? -$frac : $frac)
                  : 0);
  $x_offset = $frac + 1 + $x_offset;

  ### final: "$x,$y  rot=$rot  above_low_zero=$above_low_zero   offset=$x_offset,$y_offset"
  if ($rot & 2) {
    ($x_offset,$y_offset) = (-$x_offset,-$y_offset);  # rotate 180
  }
  if ($rot & 1) {
    ($x_offset,$y_offset) = (-$y_offset,$x_offset);  # rotate +90
  }
  $x = $x_offset + $x;
  $y = $y_offset + $y;
  ### rotated offset: "$x_offset,$y_offset   return $x,$y"
  return ($x,$y);
}

# point N>=2^18 have radius >= 2^17 or a bit less
# N = 2^level
#     r >= 2^(level-1)
#     h >= 4^(level-1)
#     level-1 <= log4(h)
#     level-1 <= 2*log2(h)
#     level <= 2*log2(h) + 1

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### DragonRounded xy_to_n(): "$x, $y"

  $x = _round_nearest($x);
  $y = _round_nearest($y);

  {
    my $yrem = $y % 3;
    if ($x % 3) {
      # horizontal
      if ($yrem) {
        return undef;
      }
    } else {
      # vertical
      unless ($yrem) {
        return undef;
      }
    }
  }

  my $arms = $self->{'arms'};

  # n=0 not covered by @digits starting from 1 ...
  # {
  #   my $ax = $x;
  #   my $ay = $y;
  #   foreach my $arm (0 .. $arms-1) {
  #     if ($ax == 1 && $ay == 0) {
  #       return $arm;
  #     }
  #     ($ax,$ay) = ($ay, -$ax);  # rotate -90
  #   }
  # }

  my ($pow,$exp) = _round_up_pow2(max(abs($x/3),abs($y/3)));
  my $level_limit = 2*$exp + 5;
  if (_is_infinite($level_limit)) {
    return $level_limit;
  }

  my @hypot = (10);
  for (my $top = 0; $top < $level_limit; $top++) {
    ### $top
    push @hypot, ($top % 4 ? 2 : 3) * $hypot[$top];  # little faster than 2^lev

  ARM: foreach my $arm (0 .. $arms-1) {
      my @digits = (((0) x $top), 1);
      my $i = $top;
      for (;;) {
        my $n = 0;
        foreach my $digit (reverse @digits) { # high to low
          $n = 2*$n + $digit;
        }
        $n = $arms*($n-1) + $arm;   # n-1 to include N=0
        ### consider: "arm=$arm i=$i  digits=".join(',',reverse @digits)."  is n=$n"

        my ($nx,$ny) = $self->n_to_xy($n);
        ### xy_to_n at: "nxy=$nx,$ny  cf hypot ".$hypot[$i]

        if ($i == 0 && $x == $nx && $y == $ny) {
          ### found ...
          return $n;
        }

        if ($i == 0 || ($x-$nx)**2 + ($y-$ny)**2 > $hypot[$i]) {
          ### too far away: "$nx,$ny target $x,$y    ".(($x-$nx)**2 + ($y-$ny)**2).' vs '.$hypot[$i]

          while (++$digits[$i] > 1) {
            $digits[$i] = 0;
            if (++$i >= $top) {
              ### backtrack past top ...
              next ARM;
            }
            ### backtrack up ...
          }

        } else {
          ### descend ...
          ### assert: $i > 0
          $i--;
          $digits[$i] = 0;
        }
      }
    }
  }
  ### not found below level limit
  return undef;
}

# level 21  n=1048576 .. 2097152
#   min 1052677 0b100000001000000000101   at -1026,1  factor 1.99610706057474
#   n=2^20 min r^2=2^20 plus a bit
#   maybe ...
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### DragonRounded rect_to_n_range(): "$x1,$y1  $x2,$y2  arms=$self->{'arms'}"

  $x1 = abs($x1);
  $x2 = abs($x2);
  $y1 = abs($y1);
  $y2 = abs($y2);
  my $xmax = int(($x1 > $x2 ? $x1 : $x2) / 3);
  my $ymax = int(($y1 > $y2 ? $y1 : $y2) / 3);
  return (0,
          ($xmax*$xmax + $ymax*$ymax + 1) * $self->{'arms'} * 16);

  # use Math::PlanePath::SacksSpiral;
  # my ($r_lo, $r_hi) = Math::PlanePath::SacksSpiral::_rect_to_radius_range
  #   ($x1/3,$y1/3, $x2/3,$y2/3);
  # my $level_hi = ceil (log($r_hi+.1) * (3 * 1/log(2))) + 1;
  # return (1, (2**$level_hi + 2));
}

1;
__END__

=for stopwords eg Ryde Dragon Math-PlanePath Nlevel Heighway Harter et al vertices multi-arm

=head1 NAME

Math::PlanePath::DragonRounded -- dragon curve with rounded corners

=head1 SYNOPSIS

 use Math::PlanePath::DragonRounded;
 my $path = Math::PlanePath::DragonRounded->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is a version of the dragon curve by Heighway, Harter, et al, done with
two points per edge and skipping vertices so as to make rounded-off corners,

                          17-16              9--8                 6
                         /     \           /     \
                       18       15       10        7              5
                        |        |        |        |
                       19       14       11        6              4
                         \        \     /           \
                          20-21    13-12              5--4        3
                               \                          \
                                22                          3     2
                                 |                          |
                                23                          2     1
                               /                          /
        33-32             25-24                    .  0--1       Y=0
       /     \           /
     34       31       26                                        -1
      |        |        |
     35       30       27                                        -2
       \        \     /
        36-37    29-28    44-45                                  -3
             \           /     \
              38       43       46                               -4
               |        |        |
              39       42       47                               -5
                \     /        /
                 40-41    49-48                                  -6
                         /
                       50                                        -7
                        |
                       ...


      ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^
    -15-14-13-12-11-10 -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3 ...

The two points on an edge have one of X or Y a multiple of 3, and the other
Y or X at 1 mod 3 or 2 mod 3.  For example the N=19 and N=20 are on the X=-9
edge (a multiple of 3), and at Y=4 and Y=5 (1 and 2 mod 3).

The "rounding" of the corners ensures that for example N=13 and N=21 don't
touch as they approach X=-6,Y=3.  The curve never crosses itself.

=head2 Arms

The dragon curve fills a quarter of the plane and four copies mesh together
rotated by 90, 180 and 270 degrees.  The C<arms> parameter can choose 1 to 4
curve arms, successively advancing.  For example C<arms =E<gt> 4> gives


                36-32             59-...          6
               /     \           /
    ...      40       28       55                 5
     |        |        |        |
    56       44       24       51                 4
      \     /           \        \
       52-48    13--9    20-16    47-43           3
               /     \        \        \
             17        5       12       39        2
              |        |        |        |
             21        1        8       35        1
            /                 /        /
       29-25     6--2     0--4    27-31       <- Y=0
      /        /                 /
    33       10        3       23                -1
     |        |        |        |
    37       14        7       19                -2
      \        \        \     /
       41-45    18-22    11-15    50-54          -3
            \        \           /     \
             49       26       46       58       -4
              |        |        |        |
             53       30       42       ...      -5
            /           \     /
      ...-57             34-38                   -6



     ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^
    -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6

With 4 arms all 3x3 blocks are visited, using 4 out of 9 points in each.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::DragonRounded-E<gt>new ()>

=item C<$path = Math::PlanePath::DragonRounded-E<gt>new (arms =E<gt> $aa)>

Create and return a new path object.

The optional C<arms> parameter makes a multi-arm curve.  The default is 1
for just one arm.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DragonCurve>,
L<Math::PlanePath::DragonMidpoint>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011 Kevin Ryde

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
