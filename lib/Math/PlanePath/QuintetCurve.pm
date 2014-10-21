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


# math-image --path=QuintetCurve --lines --scale=10
# math-image --path=QuintetCurve --all --output=numbers_dash


package Math::PlanePath::QuintetCurve;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 93;

# inherit: new(), rect_to_n_range(), arms_count(), n_start(),
#          parameter_info_array(), xy_is_visited()
use Math::PlanePath::QuintetCentres;
@ISA = ('Math::PlanePath::QuintetCentres');

use Math::PlanePath;
*_divrem_mutate = \&Math::PlanePath::_divrem_mutate;

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'digit_split_lowtohigh';

# uncomment this to run the ### lines
#use Smart::Comments;


my @rot_to_dx = (1,0,-1,0);
my @rot_to_dy = (0,1,0,-1);
my @digit_reverse = (0,1,0,0,1,0);

sub n_to_xy {
  my ($self, $n) = @_;
  ### QuintetCurve n_to_xy(): $n

  if ($n < 0) {
    return;
  }
  if (is_infinite($n)) {
    return ($n,$n);
  }

  my $arms = $self->{'arms'};
  my $int = int($n);
  $n -= $int;  # fraction part

  my $rot = _divrem_mutate ($int,$arms);
  if ($rot) { $int += 1; }

  my @digits = digit_split_lowtohigh($int,5);
  my @sx;
  my @sy;
  {
    my $sy = 0 * $int; # inherit bignum 0
    my $sx = 1 + $sy;  # inherit bignum 1
    foreach (@digits) {
      push @sx, $sx;
      push @sy, $sy;

      # 2*(sx,sy) + rot+90(sx,sy)
      ($sx,$sy) = (2*$sx - $sy,
                   2*$sy + $sx);
    }
    # ### @digits
    # my $rev = 0;
    # for (my $i = $#digits; $i >= 0; $i--) {  # high to low
    #   ### digit: $digits[$i]
    #   if ($rev) {
    #     ### reverse: "$digits[$i] to ".(5 - $digits[$i])
    #     $digits[$i] = (5 - $digits[$i]) % 5;
    #   }
    #   #      $rev ^= $digit_reverse[$digits[$i]];
    #   ### now rev: $rev
  }
  #    ### reversed n: @digits


  my $x = 0;
  my $y = 0;
  my $rev = 0;

  while (defined (my $digit = pop @digits)) {  # high to low
    my $sx = pop @sx;
    my $sy = pop @sy;
    ### at: "$x,$y  digit $digit   side $sx,$sy"

    if ($rot & 2) {
      ($sx,$sy) = (-$sx,-$sy);
    }
    if ($rot & 1) {
      ($sx,$sy) = (-$sy,$sx);
    }

    if ($rev) {
      if ($digit == 0) {
        $rev = 0;
        $rot++;

      } elsif ($digit == 1) {
        $x -= $sy;
        $y += $sx;
        $rot++;

      } elsif ($digit == 2) {
        $x += -2*$sy;
        $y += 2*$sx;

      } elsif ($digit == 3) {
        $x += $sx - 2*$sy;    # add 2*rot-90(side) + side
        $y += $sy + 2*$sx;
        $rot--;
        $rev = 0;

      } else {  # $digit == 4
        $x += $sx - $sy;    # add rot-90(side) + side
        $y += $sy + $sx;
      }

    } else {
      # normal

      if ($digit == 0) {

      } elsif ($digit == 1) {
        $x += $sx;
        $y += $sy;
        $rot--;
        $rev = 1;

      } elsif ($digit == 2) {
        $x += $sx + $sy;    # add side + rot-90(side)
        $y += $sy - $sx;

      } elsif ($digit == 3) {
        $x += 2*$sx + $sy;
        $y += 2*$sy - $sx;
        $rot++;

      } else {  # $digit == 4
        $x += 2*$sx;
        $y += 2*$sy;
        $rot++;
        $rev = 1;
      }
    }

    # lowest non-zero digit determines the direction
    if ($digit != 0) {
      ### frac_dir at non-zero: $rot
    }
  }

  ### final: "$x,$y"
  ### $rot
  $rot &= 3;
  return ($n * $rot_to_dx[$rot] + $x,
          $n * $rot_to_dy[$rot] + $y);
}

#                  up  upl left
my @attempt_x = (0, 0, -1, -1);
my @attempt_y = (0, 1,  1, 0);
sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### QuintetCurve xy_to_n(): "$x, $y"

  $x = round_nearest($x);
  $y = round_nearest($y);

  my ($n, $cx, $cy);
  foreach my $i (0, 1, 2, 3) {
    if (defined ($n = $self->SUPER::xy_to_n($x + $attempt_x[$i],
                                            $y + $attempt_y[$i]))
        && (($cx,$cy) = $self->n_to_xy($n))
        && $x == $cx
        && $y == $cy) {
      return $n;
    }
  }
  return undef;
}

1;
__END__

=for stopwords eg Ryde Mandelbrot Math-PlanePath Nlevel QuintetCurve QuintetCentres

=head1 NAME

Math::PlanePath::QuintetCurve -- self-similar "plus" shaped curve

=head1 SYNOPSIS

 use Math::PlanePath::QuintetCurve;
 my $path = Math::PlanePath::QuintetCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path is traces out a spiralling self-similar "+" shape,

            125--...                 93--92                      11
              |                       |   |
        123-124                      94  91--90--89--88          10
          |                           |               |
        122-121-120 103-102          95  82--83  86--87           9
                  |   |   |           |   |   |   |
        115-116 119 104 101-100--99  96  81  84--85               8
          |   |   |   |           |   |   |
    113-114 117-118 105  32--33  98--97  80--79--78               7
      |               |   |   |                   |
    112-111-110-109 106  31  34--35--36--37  76--77               6
                  |   |   |               |   |
                108-107  30  43--42  39--38  75                   5
                          |   |   |   |       |
                 25--26  29  44  41--40  73--74                   4
                  |   |   |   |           |
             23--24  27--28  45--46--47  72--71--70--69--68       3
              |                       |                   |
             22--21--20--19--18  49--48  55--56--57  66--67       2
                              |   |       |       |   |
              5---6---7  16--17  50--51  54  59--58  65           1
              |       |   |           |   |   |       |
      0---1   4   9---8  15          52--53  60--61  64       <- Y=0
          |   |   |       |                       |   |
          2---3  10--11  14                      62--63          -1
                      |   |
                     12--13                                      -2

      ^
     X=0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 ...


The base figure is the initial N=0 to N=4.

              5
              |
              |
      0---1   4      base figure
          |   |
          |   |
          2---3

It corresponds to a traversal of the following "+" shape,

         .... 5
         .    |
         .   <|
              |
    0----1 .. 4 ....
      v  |    |    .
    .    |>   |>   .
    .    |    |    .
    .... 2----3 ....
         . v  .
         .    .
         .    .
         . .. .

The "v" and ">" notches are the side the figure is directed at the higher
replications.  The 0, 2 and 3 parts are the right hand side of the line and
are a plain repetition of the base figure.  The 1 and 4 parts are to the
left and are a reversal.  The first such reversal is seen above as N=5 to
N=10.
        .....
        .   .

    5---6---7 ...
    .   .   |   .
    .       |   .   reversed figure
    ... 9---8 ...
        |   .
        |   .
       10 ...

In the base figure it can be seen the N=5 endpoint is rotated up around from
the N=0 to N=1 direction.  This makes successive higher levels slowly spiral
around.

    N = 5^level
    angle = level * atan(1/2)
          = level * 26.56 degrees
    radius = sqrt(5) ^ level

In the sample shown above N=125 is level=3 and has spiralled around to angle
3*26.56=79.7 degrees.  The next level goes into the second quadrant with X
negative.  A full circle around the plane is around level 14.

=head2 Arms

The optional C<arms =E<gt> $a> parameter can give 1 to 4 copies of the
curve, each advancing successively.  For example C<arms=E<gt>4> is as
follows.  N=4*k points are the plain curve, and N=4*k+1, N=4*k+2 and N=4*k+3
are rotated copies of it.

                    69--65                      ...
                     |   |                       |
    ..-117-113-109  73  61--57--53--49         120
                 |   |               |           |
           101-105  77  25--29  41--45 100-104 116
             |       |   |   |   |       |   |   |
            97--93  81  21  33--37  92--96 108-112
                 |   |   |           |
        50--46  89--85  17--13-- 9  88--84--80--76--72
         |   |                   |                   |
        54  42--38  10-- 6   1-- 5  20--24--28  64--68
         |       |   |   |           |       |   |
        58  30--34  14   2   0-- 4  16  36--32  60
         |   |       |           |   |   |       |
    66--62  26--22--18   7-- 3   8--12  40--44  56
     |                   |                   |   |
    70--74--78--82--86  11--15--19  87--91  48--52
                     |           |   |   |
       110-106  94--90  39--35  23  83  95--99
         |   |   |       |   |   |   |       |
       114 102--98  47--43  31--27  79 107-103
         |           |               |   |
       118          51--55--59--63  75 111-115-119-..
         |                       |   |
        ...                     67--71

The curve is essentially an ever expanding "+" shape with one corner at the
origin.  Four such shapes can be packed as follows,

                +---+
                |   |
        +---+---    +---+
        |   |     A     |
    +---+   +---+   +---+
    |     B     |   |   |
    +---+   +---O---+   +---+
        |   |   |     D     |
        +---+   +---+   +---+
        |     C     |   |
        +---+   +---+---+ 
            |   |
            +---+

At higher replication levels the sides are wiggly and spiralling and the
centres of each rotated around, but they sides are symmetric and mesh
together perfectly to fill the plane.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::QuintetCurve-E<gt>new ()>

=item C<$path = Math::PlanePath::QuintetCurve-E<gt>new (arms =E<gt> $a)>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

In the current code the returned range is exact, meaning C<$n_lo> and
C<$n_hi> are the smallest and biggest in the rectangle, but don't rely on
that yet since finding the exact range is a touch on the slow side.  (The
advantage of which though is that it helps avoid very big ranges from a
simple over-estimate.)

=back

=head1 FORMULAS

=head2 X,Y to N

The current approach uses the QuintetCentres C<xy_to_n()>.  Because the
tiling in QuintetCurve and QuintetCentres is the same, the X,Y coordinates
for a given N are no more than 1 away in the grid.

The way the two lowest shapes are arranged in fact means that for a
QuintetCurve N at X,Y then the same N on the QuintetCentres is at one of
three locations

    X, Y          same
    X, Y+1        up
    X-1, Y+1      up and left
    X-1, Y        left

This is so even when the "arms" multiple paths are in use (the same arms in
both coordinates).

Is there an easy way to know which of the four offsets is right?  The
current approach is to give each to QuintetCentres to make an N, put that N
back through C<n_to_xy()> to see if it's the target C<$n>.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::QuintetCentres>,
L<Math::PlanePath::QuintetReplicate>,
L<Math::PlanePath::Flowsnake>

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
