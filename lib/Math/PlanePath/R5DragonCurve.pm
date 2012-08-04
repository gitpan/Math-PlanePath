# Copyright 2012 Kevin Ryde

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



# math-image --path=R5DragonCurve --lines --scale=20
#
# math-image --path=R5DragonCurve --all --output=numbers
#
# cf A176405 R7 turns
#    A176416 R7B turns

package Math::PlanePath::R5DragonCurve;
use 5.004;
use strict;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 84;
use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_divrem_mutate = \&Math::PlanePath::_divrem_mutate;

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'digit_split_lowtohigh';

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;
use constant parameter_info_array =>
  [ { name        => 'arms',
      share_key   => 'arms_4',
      type        => 'integer',
      minimum     => 1,
      maximum     => 4,
      default     => 1,
      width       => 1,
      description => 'Arms',
    } ];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);

  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 6) { $arms = 6; }
  $self->{'arms'} = $arms;

  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### R5dragonCurve n_to_xy(): $n

  if ($n < 0) { return; }
  if (is_infinite($n)) { return ($n, $n); }

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;  # inherit possible BigFloat
    $n = $int;          # BigFloat int() gives BigInt, use that
  }

  my $zero = ($frac * 0);  # inherit bignum 0
  my $one = $zero + 1;  # inherit bignum 1

  my $x = 0;
  my $y = 0;
  my $sx = $zero;
  my $sy = $zero;

  # initial rotation from arm number
  {
    my $rot = _divrem_mutate ($n, $self->{'arms'});
    if ($rot == 0)    { $x = $frac, $sx = $one; }
    elsif ($rot == 1) { $y = $frac, $sy = $one; }
    elsif ($rot == 2) { $x = -$frac, $sx = -$one; }
    else              { $y = -$frac, $sy = -$one; } # rot==3
  }

  foreach my $digit (digit_split_lowtohigh($n,5)) {

    ### at: "$x,$y   side $sx,$sy"
    ### $digit

    if ($digit == 1) {
      ($x,$y) = ($sx-$y, $sy+$x); # rotate +90 and offset
    } elsif ($digit == 2) {
      $x = $sx-$sy - $x;  # rotate 180 and offset diag
      $y = $sy+$sx - $y;
    } elsif ($digit == 3) {
      ($x,$y) = (-$sy - $y, $sx + $x); # rotate +90 and offset vert
    } elsif ($digit == 4) {
      $x -= 2*$sy;  # offset vert 2*
      $y += 2*$sx;
    }

    # add 2*(rot+90), which is multiply by (2i+1)
    ($sx,$sy) = ($sx - 2*$sy,
                 $sy + 2*$sx);
  }

  ### final: "$x,$y   side $sx,$sy"

  return ($x, $y);
}


sub xy_to_n {
  return scalar((shift->xy_to_n_list(@_))[0]);
}
sub xy_to_n_list {
  my ($self, $x, $y) = @_;
  ### R5DragonCurve xy_to_n(): "$x, $y"

  $x = round_nearest($x);
  $y = round_nearest($y);

  if (is_infinite($x)) {
    return $x;  # infinity
  }
  if (is_infinite($y)) {
    return $y;  # infinity
  }

  if ($x == 0 && $y == 0) {
    return (0 .. $self->arms_count - 1);
  }

  require Math::PlanePath::R5DragonMidpoint;

  my @n_list;
  my $xm = $x+$y;  # rotate -45 and mul sqrt(2)
  my $ym = $y-$x;
  foreach my $dx (0,-1) {
    foreach my $dy (0,1) {
      my $t = $self->Math::PlanePath::R5DragonMidpoint::xy_to_n
        ($xm+$dx, $ym+$dy);

      ### try: ($xm+$dx).",".($ym+$dy)
      ### $t
      next unless defined $t;

      my ($tx,$ty) = $self->n_to_xy($t)
        or next;

      if ($tx == $x && $ty == $y) {
        ### found: $t
        if (@n_list && $t < $n_list[0]) {
          unshift @n_list, $t;
        } else {
          push @n_list, $t;
        }
        if (@n_list == 2) {
          return @n_list;
        }
      }
    }
  }
  return @n_list;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### R5DragonCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"
  my $xmax = int(max(abs($x1),abs($x2))) + 1;
  my $ymax = int(max(abs($y1),abs($y2))) + 1;
  return (0,
          ($xmax*$xmax + $ymax*$ymax)
          * 10
          * $self->{'arms'});
}

1;
__END__

=for stopwords eg Ryde Dragon Math-PlanePath Nlevel et al vertices doublings OEIS Online terdragon ie morphism R5DragonMidpoint radix

=head1 NAME

Math::PlanePath::R5DragonCurve -- radix 5 dragon curve

=head1 SYNOPSIS

 use Math::PlanePath::R5DragonCurve;
 my $path = Math::PlanePath::R5DragonCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is the R5 dragon curve,

             31-----30     27-----26                                  5
              |      |      |      |
             32---29/33--28/24----25                                  4
                     |      |
             35---34/38--39/23----22     11-----10      7------6      3
                     |             |      |      |      |      |
             36---37/41--20/40--21/17--16/12---13/9----8/4-----5      2
                     |      |      |      |      |      |
    --50     47---42/46--19/43----18     15-----14      3------2      1
       |      |      |      |                                  |
    49/53--48/64  45/65--44/68    69                    0------1  <-Y=0

       ^      ^      ^      ^      ^      ^      ^      ^      ^
      -7     -6     -5     -4     -3     -2     -1     X=0     1

The base figure is an "S" shape

    4----5
    |
    3----2
         |
    0----1

which then repeats in self-similar style, so N=5 to N=10 is a copy rotated
+90 degrees, which is the angle of the N=1 to N=2 edge,

    10    7----6
     |    |    |  <- repeat rotated +90
     9---8,4---5
          |
          3----2
               |
          0----1

The shape of N=0,5,10,15,20,25 repeats the initial N=0 to N=5,

           25                          4
          /
         /           10__              3
        /           /    ----___
      20__         /            5      2
          ----__  /            /
                15            /        1
                            /
                           0       <-Y=0

       ^    ^    ^    ^    ^    ^
      -4   -3   -2   -1   X=0   1


The curve never crosses itself.  The vertices touch as corners like N=4 and
N=8 above, but no edges repeat.

=head2 Spiralling

The first step N=1 is to the right along the X axis and the path then slowly
spirals anti-clockwise and progressively fatter.  The end of each
replication is

    Nlevel = 5^level

That point is at atan(2,1)=63.43 degrees further around for each level,

    Nlevel     X,Y     angle (degrees)
    ------    -----    -----
      1        1,0        0
      5        2,1       63.4
     25       -3,4      126.8
    125      -11,-2     190.3

=head2 Arms

The curve fills a quarter of the plane and four copies mesh together
perfectly rotated by 90, 180 and 270 degrees.  The C<arms> parameter can
choose 1 to 4 such curve arms successively advancing.

C<arms =E<gt> 4> begins as follows.  N=0,4,8,12,16,etc is the first arm (the
same shape as the plain curve above), then N=1,5,9,13,17 the second,
N=2,6,10,14 the third, etc.

    arms => 4
                    16/32---20/63
                      |
    21/60    9/56----5/12----8/59
      |       |       |       |
    17/33--- 6/13--0/1/2/3---4/15---19/35
              |       |       |       |
            10/57----7/14---11/58   23/62
                      |
            22/61---18/34

With four arms every X,Y point is visited twice, except the origin 0,0 where
all four begin.  Every edge between the points is traversed once.

=head2 Tiling

The little "S" shapes of the N=0to5 base shape tile the plane in the
following pattern,

     |     |  |  |  |     |  |  |  |
     +--+--+--+--+  +--+--+--+--+  +-
     |  |  |     |  |  |  |     |  |
    -+--+  +--+--+--+--+  +--+--+--+-
        |  |  |  |     |  |  |  |
    -+--+--+--+  +--+--+--+--+  +--+-
     |  |     |  |  |  |     |  |  |
    -+  +--+--+--+--+  +--+--+--+--+
     |  |  |  |     |  |  |  |     |
    -+--+--+  +--+--o--+--+  +--+--+-
     |     |  |  |  |     |  |  |  |
     +--+--+--+--+  +--+--+--+--+  +-
     |  |  |     |  |  |  |     |  |
    -+--+  +--+--+--+--+  +--+--+--+-
        |  |  |  |     |  |  |  |
    -+--+--+--+  +--+--+--+--+  +--+-
     |  |     |  |  |  |     |  |  |
    -+  +--+--+--+--+  +--+--+--+--+
     |  |  |  |     |  |  |  |     |

This is simply edge N=2mod5 to N=3mod5 omitted from each mod5 block.  In
each 2x1 block the "S" traverses 4 of the 6 edges and the way the curve
meshes together traverses the other 2 edges in another brick, possibly a
brick on another arm of the curve.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::R5DragonCurve-E<gt>new ()>

=item C<$path = Math::PlanePath::R5DragonCurve-E<gt>new (arms =E<gt> 4)>

Create and return a new path object.

The optional C<arms> parameter can make 1 to 4 copies of the curve, each arm
successively advancing.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional C<$n> gives an X,Y position along a straight line between the
integer positions.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  If there's nothing at
C<$x,$y> then return C<undef>.

The curve can visit an C<$x,$y> twice.  In the current code the smallest of
the these N values is returned.  Is that the best way?

=item C<@n_list = $path-E<gt>xy_to_n_list ($x,$y)>

Return a list of N point numbers for coordinates C<$x,$y>.  There can be
none, one or two N's for a given C<$x,$y>.

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 FORMULAS

=head2 Turns

At each point N the curve always turns 90 degrees either to the left or
right, it never goes straight ahead.  If N is written in base 5 then the
lowest non-zero digit gives the turn

    Ndigit      Turn
    ------      ----
      1         left
      2         left
      3         right
      4         right

Essentially at a point N=digit*5^level for digit=1,2,3,4 the turn follows
the shape at that digit.

    4*5^k----5^(k+1)
     |
     |
    2*5^k----2*5^k
              |
              |
     0------1*5^k

The first and last unit steps in each level are in the same direction, so at
those endpoints it's the next level up which the turn.

=cut

# The direction at N, ie. the total cumulative turn, is given by the number of
# 1 digits when N is written in base 5,
#
#     direction = (count 1,2s in base5 N) * 90 degrees
#
# For example N=12 is base5 110 which has two 1s so the cumulative turn at
# that point is 2*90=180 degrees, ie. the segment N=16 to N=17 is at angle
# 180.

=head1 OEIS

The R5 dragon is in Sloane's Online Encyclopedia of Integer Sequences as,

    http://oeis.org/A175337

    A175337 -- turn 0=left,1=right by 90 degrees at N=n

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DragonCurve>,
L<Math::PlanePath::TerdragonCurve>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2012 Kevin Ryde

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
