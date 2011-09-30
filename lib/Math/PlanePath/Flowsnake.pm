# Copyright 2010, 2011 Kevin Ryde

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


# math-image --path=Flowsnake --lines --scale=10
# math-image --path=Flowsnake,arms=3 --all --output=numbers_dash
#
# Martin Gardner, In which "monster" curves force redefinition of the word
# "curve", Scientific American 235 (December issue), 1976, 124-133.
#
# http://80386.nl/pub/gosper-level21.png
#
# http://www.mathcurve.com/fractals/gosper/gosper.shtml
#


package Math::PlanePath::Flowsnake;
use 5.004;
use strict;
use List::Util 'max';
use POSIX 'ceil';

use vars '$VERSION', '@ISA';
$VERSION = 45;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::SacksSpiral;

use constant n_start => 0;
sub arms_count {
  my ($self) = @_;
  return $self->{'arms'} || 1;
}

use constant parameter_info_array => [ { name      => 'arms',
                                         share_key => 'arms_3',
                                         type      => 'integer',
                                         minimum   => 1,
                                         maximum   => 3,
                                         default   => 1,
                                         width     => 1,
                                       } ];


#         *
#        / \
#       /   \
#      *-----*
#
# (b/2)^2 + h^2 = s
# (1/2)^2 + h^2 = 1
# h^2 = 1 - 1/4
# h = sqrt(3)/2 = 0.866
#

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 3) { $arms = 3; }
  $self->{'arms'} = $arms;
  return $self;
}


# my @L = (1,1,2,-1,-2,0,-1);
# my @R = (0,1,1,0,0,0,1);

# Triplet h,i,j coordinates are redundant, just the h,i is enough, though
# two instead of three requires some additions in the rotation calculations,
# instead of just swaps and negates.
#
#     j     i
#     ^     ^
#      \   /
#       \ /
#        *-----> h

#       4-->5-->6
#       ^       ^
#        \       \
#         3-->2
#            /
#           v
#       0-->1

#             6<---
#             ^
#            /
#       0   5<--4
#        \       \
#         v       v
#         1<--2<--3

#            0   1  2  3  4  5  6
my @pos_h = (0,  1, 1, 0, 0, 0, 1,
             0,  0, 1, 2, 2, 1, 1);
my @pos_i = (0,  0, 1, 1, 1, 2, 2,
             0,  0, 0, 0, 0, 0, 1);
my @pos_j = (0,  0, 0, 0, 1, 0, 0,
             0, -1,-1,-1, 0, 0, 0);
my @rev   = (0,  7, 7, 0, 0, 0, 7,
             7,  0, 0, 0, 7, 7, 0);
my @dir   = (0,  1, 3, 2, 0, 0, 5,
             5,  0, 0, 2, 3, 1, 0);


my @rot_h = (1, 0, 0, -1, 0, 0);
my @rot_i = (0, 1, 0,  0,-1, 0);
my @rot_j = (0, 0, 1,  0, 0,-1);

sub n_to_xy {
  my ($self, $n) = @_;
  ### Flowsnake n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;  # inherit possible BigFloat
    $n = $int;          # BigFloat int() gives BigInt, use that
  }
  ### $frac
  ### n int: $n

  my $arms = $self->{'arms'};
  my $rot = 2 * ($n % $arms);
  $n = int(($n+$arms-1) / $arms);
  ### $arms
  ### $rot
  ### arms inc: $arms-1
  ### n inc: ($n+$arms-1)
  ### n div arm: $n

  # ENHANCE-ME: The s[] vectors here are constants and could be kept up to
  # the level used thusfar
  my (@digits, @sh, @si, @sj);
  {
    my $sh = 1;
    my $si = 0;
    my $sj = 0;
    while ($n) {
      push @digits, $n % 7;
      $n = int($n/7);
      push @sh, $sh;
      push @si, $si;
      push @sj, $sj;
      ($sh, $si, $sj) = (2*$sh - $sj,
                         2*$si + $sh,
                         2*$sj + $si);
    }
    ### @digits
  }

  my $h = my $i = my $j = 0;
  my $rev = 0;
  while (@digits) {
    my $digit = pop @digits;  # high to low
    my $sh = pop @sh;
    my $si = pop @si;
    my $sj = pop @sj;
    my $o = $rev + $digit;

    ### $digit
    ### step: "$sh, $si, $sj  sx=".($sh*2 + $si - $sj)." sy=".($si+$sj)
    ### $rot
    ### $rev
    ### $o

    if ($rot == 0)    { ($sh,$si,$sj) = ($sh,$si,$sj); }
    elsif ($rot == 1) { ($sh,$si,$sj) = (-$sj,$sh,$si); }
    elsif ($rot == 2) { ($sh,$si,$sj) = (-$si,-$sj,$sh); }
    elsif ($rot == 3) { ($sh,$si,$sj) = (-$sh,-$si,-$sj); }
    elsif ($rot == 4) { ($sh,$si,$sj) = ($sj,-$sh,-$si); }
    elsif ($rot == 5) { ($sh,$si,$sj) = ($si,$sj,-$sh); }

    $h += $sh * $pos_h[$o]  - $sj * $pos_i[$o]  - $si * $pos_j[$o];
    $i += $si * $pos_h[$o]  + $sh * $pos_i[$o]  - $sj * $pos_j[$o];
    $j += $sj * $pos_h[$o]  + $si * $pos_i[$o]  + $sh * $pos_j[$o];

    $rev ^= $rev[$o];
    $rot = ($rot + $dir[$o]) % 6;
    ### rotated step: "$sh, $si, $sj"
    ### pos: "$pos_h[$o], $pos_i[$o], $pos_j[$o]"
    ### to: "$h, $i, $j  x=".($h*2 + $i - $j)." y=".($i+$j)
  }

  # fraction in final rotation direction
  if ($frac) {
    ### apply: "frac=$frac  rot=$rot"
    $h += $rot_h[$rot] * $frac;
    $i += $rot_i[$rot] * $frac;
    $j += $rot_j[$rot] * $frac;
  }

  ### ret: "$h, $i, $j  x=".($h*2 + $i - $j)." y=".($i+$j)
  return ($h*2 + $i - $j,
          $i+$j);
}


#       4-->5-->6
#       ^       ^
#        \       \
#         3-->2
#            /
#           v
#       0-->1
#
# longest to 6 is x=4,y=2 is 4*4+3*2*2 = 28
#
#             6<---
#             ^
#            /
#       0   5<--4
#        \       \
#         v       v
#         1<--2<--3
#
# longest to 3 is x=5,y=1 is 5*5+3*1*1 = 28
#
# side len 1 len sqrt(7)
# total sqrt(7)^k + ... + 1
#     = (b^(k+1) - 1) / (b - 1)
#     < b^(k+1) / (b - 1)
# squared 7^(k+1) / (7 - 2*sqrt(7) + 1)
#     = 7^k * 7/(7-2*sqrt(7)+1)
#     = 7^k * 2.584
#
# minimum = b^k - upper(k-1)
#         = b^k - b^k / (b - 1)
#         = b^k * (1 - 1/(b-1))
#         = b^k * (b-1 - 1)/(b-1)
#         = b^k * (b-2)/(b-1)
#         = b^k * 0.392
#
# sqrt((x/2)^2 + (y*sqrt(3)/2)^2)
#    = sqrt(x^2/4 + y^2*3/4)
#    = sqrt(x^2 + 3*y^2)/2

# sqrt(x^2 + 3*y^2)/2 > b^k * (b-2)/(b-1)
# sqrt(x^2 + 3*y^2) > b^k * 2*(b-2)/(b-1)
# x^2 + 3*y^2 > 7^k * (2*(b-2)/(b-1))^2
# x^2 + 3*y^2 > 7^k * (2*(b-2)/(b-1))^2
# (x^2 + 3*y^2) / (2*(b-2)/(b-1))^2 > 7^k
# 7^k < (x^2 + 3*y^2) / (2*(b-2)/(b-1))^2
# k < log7 ((x^2 + 3*y^2) / (2*(b-2)/(b-1))^2)
# k < log7 ((x^2 + 3*y^2) * 1.62
# k < log((x^2 + 3*y^2) * 1.62/log(7)
# k < log((x^2 + 3*y^2) * 0.8345

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### Flowsnake xy_to_n(): "$x, $y"

  $x = _round_nearest($x);
  $y = _round_nearest($y);
  if (($x + $y) % 2) { return undef; }

  my $level_limit = log($x*$x + 3*$y*$y + 1) * 0.835 * 2;
  if (_is_infinite($level_limit)) { return $level_limit; }

  # hypot 5*5+3*1*1 = 28
  #       11*11+3*5*5 = 196 is *7
  #
  my $arms = $self->{'arms'};
  my @sx = (2);
  my @sy = (0);
  my @hypot = (6);
  my $top = 0;

  for (;;) {
  ARM: foreach my $arm (0 .. $arms-1) {
      my $i = 0;
      my @digits = (0);
      for (;;) {
        my $n = 0;
        foreach my $digit (reverse @digits) { # high to low
          $n = 7*$n + $digit;
        }
        $n = $n*$arms + $arm;
        ### consider: "i=$i  digits=".join(',',reverse @digits)."  is n=$n"

        my ($nx,$ny) = $self->n_to_xy($n);
        if ($i == 0 && $x == $nx && $y == $ny) {
          ### found
          return $n;
        }

        if ($i == 0
            || ($x - $nx) ** 2 + 3 * ($y - $ny) ** 2 > $hypot[$i]) {
          ### too far away: "$nx,$ny target $x,$y    ".(($x - $nx) ** 2 + 3 * ($y - $ny) ** 2).' vs '.$hypot[$i]

          while (++$digits[$i] > 6) {
            $digits[$i] = 0;
            if (++$i <= $top) {
              ### backtrack up ...
            } else {
              ### not found within this arm and top ...
              next ARM;
            }
          }

        } else {
          ### descend
          ### assert: $i > 0
          $i--;
          $digits[$i] = 0;
        }
      }
    }

    if (++$top > $level_limit) {
      ### oops, not found below level limit
      return;
    }
    $sx[$top] = (5 * $sx[$top-1] - 3 * $sy[$top-1]) / 2;
    $sy[$top] = ($sx[$top-1] + 5 * $sy[$top-1]) / 2;
    $hypot[$top] = 7 * $hypot[$top-1];
  }
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### Flowsnake rect_to_n_range(): "$x1,$y1  $x2,$y2"

  my ($r_lo, $r_hi) = Math::PlanePath::SacksSpiral::_rect_to_radius_range
    ($x1,$y1*sqrt(3), $x2,$y2*sqrt(3));
  $r_hi *= 2;
  my $level_plus_1 = ceil( log(max(1,$r_hi/4)) / log(sqrt(7)) ) + 2;
  # return (0, 7**$level_plus_1);


  my $level_limit = $level_plus_1;
  ### $level_limit
  if (_is_infinite($level_limit)) { return ($level_limit,$level_limit); }

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### sorted range: "$x1,$y1  $x2,$y2"

  my $rect_dist = sub {
    my ($x,$y) = @_;
    my $xd = ($x < $x1 ? $x1 - $x
              : $x > $x2 ? $x - $x2
              : 0);
    my $yd = ($y < $y1 ? $y1 - $y
              : $y > $y2 ? $y - $y2
              : 0);
    return ($xd*$xd + 3*$yd*$yd);
  };

  my $arms = $self->{'arms'};
  ### $arms
  my $n_lo;
  {
    my @hypot = (6);
    my $top = 0;
    for (;;) {
    ARM_LO: foreach my $arm (0 .. $arms-1) {
        my $i = 0;
        my @digits;
        if ($top > 0) {
          @digits = ((0)x($top-1), 1);
        } else {
          @digits = (0);
        }

        for (;;) {
          my $n = 0;
          foreach my $digit (reverse @digits) { # high to low
            $n = 7*$n + $digit;
          }
          $n = $n*$arms + $arm;
          ### lo consider: "i=$i  digits=".join(',',reverse @digits)."  is n=$n"

          my ($nx,$ny) = $self->n_to_xy($n);
          my $nh = &$rect_dist ($nx,$ny);
          if ($i == 0 && $nh == 0) {
            ### lo found inside: $n
            if (! defined $n_lo || $n < $n_lo) {
              $n_lo = $n;
            }
            next ARM_LO;
          }

          if ($i == 0 || $nh > $hypot[$i]) {
            ### too far away: "nxy=$nx,$ny   nh=$nh vs ".$hypot[$i]

            while (++$digits[$i] > 6) {
              $digits[$i] = 0;
              if (++$i <= $top) {
                ### backtrack up ...
              } else {
                ### not found within this top and arm, next arm ...
                next ARM_LO;
              }
            }
          } else {
            ### lo descend ...
            ### assert: $i > 0
            $i--;
            $digits[$i] = 0;
          }
        }
      }

      # if an $n_lo was found on any arm within this $top then done
      if (defined $n_lo) {
        last;
      }

      ### lo extend top ...
      if (++$top > $level_limit) {
        ### nothing below level limit ...
        return (1,0);
      }
      $hypot[$top] = 7 * $hypot[$top-1];
    }
  }

  my $n_hi = 0;
 ARM_HI: foreach my $arm (reverse 0 .. $arms-1) {
    my @digits = ((6) x $level_limit);
    my $i = $#digits;
    for (;;) {
      my $n = 0;
      foreach my $digit (reverse @digits) { # high to low
        $n = 7*$n + $digit;
      }
      $n = $n*$arms + $arm;
      ### hi consider: "arm=$arm  i=$i  digits=".join(',',reverse @digits)."  is n=$n"

      my ($nx,$ny) = $self->n_to_xy($n);
      my $nh = &$rect_dist ($nx,$ny);
      if ($i == 0 && $nh == 0) {
        ### hi found inside: $n
        if ($n > $n_hi) {
          $n_hi = $n;
          next ARM_HI;
        }
      }

      if ($i == 0 || $nh > (6 * 7**$i)) {
        ### too far away: "$nx,$ny   nh=$nh vs ".(6 * 7**$i)

        while (--$digits[$i] < 0) {
          $digits[$i] = 6;
          if (++$i < $level_limit) {
            ### hi backtrack up ...
          } else {
            ### hi nothing within level limit for this arm ...
            next ARM_HI;
          }
        }

      } else {
        ### hi descend
        ### assert: $i > 0
        $i--;
        $digits[$i] = 6;
      }
    }
  }

  if ($n_hi == 0) {
    ### oops, lo found but hi not found
    $n_hi = $n_lo;
  }

  return ($n_lo, $n_hi);
}

1;
__END__

=for stopwords eg Ryde flowsnake Gosper ie Fukuda Shimizu Nakamura Math-PlanePath

=head1 NAME

Math::PlanePath::Flowsnake -- self-similar path through hexagons

=head1 SYNOPSIS

 use Math::PlanePath::Flowsnake;
 my $path = Math::PlanePath::Flowsnake->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path is an integer version of the flowsnake curve by William Gosper,

                         39----40----41                        8
                           \           \
          32----33----34    38----37    42                     7
            \           \        /     /
             31----30    35----36    43    47----48            6
                  /                    \     \     \
          28----29    17----16----15    44    46    49...      5
         /              \           \     \  /
       27    23----22    18----19    14    45                  4
         \     \     \        /     /
          26    24    21----20    13    11----10               3
            \  /                    \  /     /
             25     4---- 5---- 6    12     9                  2
                     \           \         /
                       3---- 2     7---- 8                     1
                           /
                    0---- 1                                  y=0

     x=-4 -3 -2 -1  0  1  2  3  4  5  6  7  8  9 10 11

The points are spread out on every second X coordinate to make little
triangles with integer coordinates, per L<Math::PlanePath/Triangular
Lattice>.

The basic pattern is the seven points 0 to 6,

    4---- 5---- 6
     \           \
       3---- 2
           /
    0---- 1

This repeats at 7-fold increasing scale, with sub-sections rotated according
to the edge direction, and the 1, 2 and 6 sub-sections in mirror image.  The
next level can be seen at the multiple of 7 points N=0,7,14,21,28,35,42,49.

                                  42
                      -----------    ---
                   35                   ---
       -----------                         ---
    28                                        49 ---
      ---
         ----                  14
             ---   -----------  |
                21              |
                               |
                              |
                              |
                        ---- 7
                   -----
              0 ---

Notice this is the same shape as the 0 to 6, but rotated by atan(1/sqrt(7))
= 20.68 degrees anti-clockwise.  Each level rotates further and for example
after about 18 levels it goes all the way around and back to the first
quadrant.

The rotation doesn't mean it fills the plane though.  The shape fattens as
it curls around, but leaves a spiral gap beneath it (see L</Arms> below).

=head2 Tiling

The base pattern corresponds to a tiling by hexagons as follows, with the
"***" lines being the base figure.

                        .     .
                       / \   / \
                      /   \ /   \
                     .     .     .
                     |     |     |
                     |     |     |
                     4*****5*****6
                    /*\   / \   /*\
                   / * \ /   \ / * \
                  .   * .     .   * .
                  |   * |     |    *|
                  |    *|     |    *|
                  .     3*****2     7...
                   \   / \   /*\   /
                    \ /   \ / * \ /
                     .     . *   .
                     |     | *   |
                     |     |*    |
                     0*****1     .
                      \   / \   /
                       \ /   \ /
                        .     .

In the next level the parts corresponding to 1, 2 and 6 are mirrored because
they have their hexagon to the right of the line segment, rather than to the
left.

=head2 Arms

The optional C<arms> parameter can give up to three copies of the flowsnake,
each advancing successively.  For example C<arms=E<gt>3> is as follows.
Notice the N=3*k points are the plain curve, and N=3*k+1 and N=3*k+2 are
rotated copies of it.

                                     51----48----45                 5
                                       \           \
                      ...   69----66    54----57    42              4
                        \     \     \        /     /
       28----25----22    78    72    63----60    39    33----30     3
         \           \     \  /                    \  /     /
          31----34    19    75    12----15----18    36    27        2
               /     /              \           \        /
       40----37    16     4---- 1     9---- 6    21----24           1
      /              \     \              /
    43    55----58    13     7     0---- 3    74----77---...    <- Y=0
      \     \     \     \  /                    \
       46    52    61    10     2     8----11    71----68          -1
         \  /     /              \  /     /           /
          49    64    70----73     5    14    62----65             -2
                  \  /     /           /     /
                   67    76    20----17    59    53----50          -3
                        /     /              \  /     /
                      ...   23    35----38    56    47             -4
                              \     \     \        /
                               26    32    41----44                -5
                                 \  /
                                  29                               -6

                                   ^
       -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7  8  9

Essentially the flowsnake fills an ever expanding hexagon with one corner at
the origin.  In the following picture the plain curve fills "A" and there's
room for two more arms to fill B and C, rotated 120 and 240 degrees
respectively.

            *---*         
           /     \       
      *---*   A   *
     /     \     / 
    *   B   O---*  
     \     /     \ 
      *---*   C   *
           \     /
            *---*

But the sides of these "hexagons" are not straight lines, they're more like
wild wiggly spiralling S shapes, and the endpoints rotate around (by the
angle described above) at each level.  But the opposite sides are symmetric,
so they mesh perfectly and with three arms fill the plane.

=head2 Fractal

The flowsnake can also be thought of as successively subdividing line
segments with suitably scaled copies of the 0 to 7 figure (or its reversal).

The code here could be used for that by taking points N=0 to N=7^level.  The
Y coordinates should be multiplied by sqrt(3) to make proper equilateral
triangles, then a rotation and scaling to have the endpoint come out at
X=1,Y=0 or wherever desired.  With this the path is confined to a finite
fractal boundary.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::Flowsnake-E<gt>new ()>

=item C<$path = Math::PlanePath::Flowsnake-E<gt>new (arms =E<gt> $a)>

Create and return a new flowsnake path object.

The optional C<arms> parameter gives between 1 and 3 copies of the curve
successively advancing.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=back

=head1 FORMULAS

=head2 X,Y to N

The current approach is a slightly crude search for digits of N which will,
or might come out as the target X,Y.

Starting at a high digit bigger than a bounding radius for the X,Y values
are considered for that digit and those below it.  When a digit gives a
prospective X,Y further away than the bounding radius for the digits below
then that digit can be rejected.

The bounding radius calculation is a bit of an over-estimate when ends up
making it examine more points than strictly necessary.  Oh, can the current
code also does a full C<n_to_xy()> for each prospective point, rather than
taking a shortcut by adding-up or stepping through the "side"s represented
by a digit at a given level.

=head2 Rectangle to N Range

The current code calculates an exact C<rect_to_n_range()> by searching for
the highest and lowest N which are in the rectangle.

The curve at a given level is bounded by the Gosper island shape but the
wiggly sides make it difficult to calculate, so a bounding radius
sqrt(7)^level, plus a bit, is used.  The portion of the curve comprising a
given set of high digits of N can be excluded if the N point is more than
that radius away from the rectangle.

When a part of the curve is excluded it prunes a whole branch of the digits
tree.  When the lowest digit is reached then a check for that point being
actually within the rectangle is made.  The radius calculation is a bit
rough, and since it doesn't even take into account the direction of the
curve it's a rather large over-estimate, but it works.

The same sort of search can be applied to non-rectangular shapes,
calculating a radial distance from the shape.  The distance calculation
doesn't have to be exact, it can work on something bounding the shape until
the lowest digit is reached and an individual X,Y is being considered as an
candidate high or low N bound.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::FlowsnakeCentres>,
L<Math::PlanePath::GosperIslands>

L<Math::PlanePath::KochCurve>,
L<Math::PlanePath::HilbertCurve>,
L<Math::PlanePath::PeanoCurve>,
L<Math::PlanePath::ZOrderCurve>

"New Gosper Space Filling Curves" by Fukuda, Shimizu and Nakamura, on
flowsnake variations in bigger hexagons (with wiggly sides too).

    http://kilin.clas.kitasato-u.ac.jp/museum/gosperex/343-024.pdf
      or if down then at archive.org
    http://web.archive.org/web/20070630031400/http://kilin.u-shizuoka-ken.ac.jp/museum/gosperex/343-024.pdf

=head1 LICENSE

Copyright 2010, 2011 Kevin Ryde

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


                        *---E
                       /     \
                  *---*       *---*
                 /     \     /     \
                *       *---*       *
                 \     /     \     /
                  *---*       *---*
                 /     \     /     \
                *       *---*       *
                 \     /     \     /
                  *---*       *---*
                       \     /
                        *---*


                        *     *
                       / \   / \
                      /   \ /   \
                     *     *     *
                     |     |     |
                     |     |     |
                     *     *     *
                    / \   / \   / \
                   /   \ /   \ /   \
                  *     *     *     *
                  |     |     |     |
                  |     |     |     |
                  *     *     *     *
                   \   / \   / \   /
                    \ /   \ /   \ /
                     *     *     *
                     |     |     |
                     |     |     |
                     *     *     *
                      \   / \   /
                       \ /   \ /
                        *     *




       B
      / \   / \  
     /   \ /   \ 
    .  ^  .     .
    |   | |     |
    |    ||     |
    .     O-->  A
     \   / \   / 
      \ / | \ /  
       . |   .   
       | v   |   
       |     |   
       C     .   
        \   / 
         \ /  

