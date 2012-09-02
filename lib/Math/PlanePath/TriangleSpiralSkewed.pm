# Copyright 2010, 2011, 2012 Kevin Ryde

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


package Math::PlanePath::TriangleSpiralSkewed;
use 5.004;
use strict;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 87;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use Math::PlanePath::Base::Generic
  'round_nearest';

# uncomment this to run the ### lines
#use Smart::Comments;


sub new {
  my $self = shift->SUPER::new (@_);
  if (! defined $self->{'n_start'}) {
    $self->{'n_start'} = $self->default_n_start;
  }
  return $self;
}

# base at bottom right corner
#   r = [ 1,  2,  3 ]
#   n = [ 2,  11, 29 ]
#   $d = 1/2 + sqrt(2/9 * $n + -7/36)
#      = ( 3 + 6*sqrt(8/36 * $n + -7/36) ) / 6
#      = ( 3 + sqrt(8 * $n + -7) ) / 6
#      = (3 + sqrt(8*$n - 7)) / 6
#
#   $n = (9/2*$d**2 + -9/2*$d + 2)
#
# top corner is further 3*$d-1 along, so
#   rem = $n - (9/2*$d**2 + -9/2*$d + 2) - (3*$d - 1)
#       = $n - (9/2*$d**2 + -3/2*$d + 1)
#       = $n - (9/2*$d + -3/2)*$d + 1
#       = $n - (9*$d - 3)*$d/2 + 1
#   so go rem-2*$r rightwards from x=-2*$r, is x = rem - 4*$r
#
sub n_to_xy {
  my ($self, $n) = @_;
  #### TriangleSpiralSkewed n_to_xy: $n

  $n = $n - $self->{'n_start'};  # starting $n==0, warn if $n==undef
  if ($n < 0) { return; }

  my $d = int ((3 + sqrt(8*$n + 1)) / 6);
  #### $d

  $n -= (9*$d - 3)*$d/2;
  #### remainder: $n

  if ($n <= 3*$d) {
    ### right slope and left vertical
    my $x = - ($d + $n);
    return (max($x,-$d),
            2*$d - abs($n));
  } else {
    ### bottom horizontal
    return ($n - 4*$d,
            -$d);
  }
}

# vertical x=0
#   [ 1,  2,  3 ]
#   [ 3, 14, 34 ]
#   n = (9/2*$d**2 + -5/2*$d + 1)
#     = 4.5*$d*$d - 2.5*$d + 1
#
# positive y, x=0 centres
#   [ 1,  2,  3 ]
#   [ 3, 13, 31 ]
#   n = (4*$d*$d + -2*$d + 1)
#
sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = round_nearest ($x);
  $y = round_nearest ($y);
  ### xy_to_n(): "$x,$y"

  if ($y < 0 && $y <= $x && $x <= -2*$y) {
    ### bottom horizontal

    # negative y, vertical at x=0
    #   [ -1, -2, -3, -4 ]
    #   [  8, 24, 49, 83 ]
    #   n = (9/2*$d**2 + -5/2*$d + 1)
    #
    return (9*$y - 5)*$y/2 + $x + $self->{'n_start'};
  }
  if ($x < 0 && $x <= $y && $y <= 2*-$x) {
    ### left vertical

    # negative x, horizontal at y=0
    #   [ -1, -2, -3, -4 ]
    #   [  6, 20, 43, 75 ]
    #   n = (9/2*$d**2 + -1/2*$d + 1)
    #
    return (9*$x - 1)*$x/2 - $y + $self->{'n_start'};
  }

  my $d = $x + $y;
  ### right slope
  ### $d

  # positive y, vertical at x=0
  #   [ 1,  2,  3,  4 ]
  #   [ 3, 14, 34, 63 ]
  #   n = (9/2*$d**2 + -5/2*$d + 1)
  #
  return (9*$d - 5)*$d/2 - $x + $self->{'n_start'};
}

# n_hi exact, n_lo not
# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = round_nearest ($x1);
  $y1 = round_nearest ($y1);
  $x2 = round_nearest ($x2);
  $y2 = round_nearest ($y2);

  return ($self->{'n_start'},
          max ($self->xy_to_n ($x1,$y1),
               $self->xy_to_n ($x1,$y2),
               $self->xy_to_n ($x2,$y1),
               $self->xy_to_n ($x2,$y2)));
}
# my $d = 0;
# foreach my $x ($x1, $x2) {
#   foreach my $y ($y1, $y2) {
#     $d = max ($d,
#               1 + ($y < 0 && $y <= $x && $x <= -2*$y
#                    ? -$y                          # bottom horizontal
#                    : $x < 0 && $x <= $y && $y <= 2*-$x
#                    ? -$x              # left vertical
#                    : abs($x) + $y));  # right slope
#   }
# }
#         (9*$d - 9)*$d + 1 + $self->{'n_start'});

1;
__END__

=for stopwords TriangleSpiral TriangleSpiralSkewed PlanePath Ryde Math-PlanePath polygonals hendecagonal hendecagonals OEIS

=head1 NAME

Math::PlanePath::TriangleSpiralSkewed -- integer points drawn around a skewed equilateral triangle

=head1 SYNOPSIS

 use Math::PlanePath::TriangleSpiralSkewed;
 my $path = Math::PlanePath::TriangleSpiralSkewed->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes an spiral shaped as an equilateral triangle (each side the
same length), but skewed to the left to fit on a square grid,

=cut

# math-image --path=TriangleSpiralSkewed --expression='i<=31?i:0' --output=numbers_dash

=pod

    16                              4
     |\
    17 15                           3
     |   \
    18  4 14                        2
     |  |\  \
    19  5  3 13                     1
     |  |   \  \
    20  6  1--2 12 ...         <- Y=0
     |  |         \  \
    21  7--8--9-10-11 30           -1
     |                  \
    22-23-24-25-26-27-28-29        -2

           ^
    -2 -1 X=0 1  2  3  4  5

The properties are the same as the spread-out TriangleSpiral.  The triangle
numbers fall on straight lines as the do in the TriangleSpiral but the skew
means the top corner goes up at an angle to the vertical and the left and
right downwards are different angles plotted (but are symmetric by N count).

=head2 N Start

The default is to number points starting N=1 as shown above.  An optional
C<n_start> can give a different start, with the same shape etc.  For example
to start at 0,

=cut

# math-image --path=TriangleSpiralSkewed,n_start=0 --expression='i<=31?i:0' --output=numbers_dash

=pod

    15        n_start => 0
     |\
    16 14
     |   \
    17  3 13 ...
     |  |\  \  \
    18  4  2 12 31
     |  |   \  \  \
    19  5  0--1 11 30
     |  |         \  \
    20  6--7--8--9-10 29
     |                  \
    21-22-23-24-25-26-27-28

With this adjustment for example the X axis N=0,1,11,30,etc is (9k-7)*k/2,
the hendecagonal numbers (11-polygonals).  And N=0,8,25,etc is the
hendecagonals of the second kind, (9k-7)*k/2 for k negative.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::TriangleSpiralSkewed-E<gt>new ()>

=item C<$path = Math::PlanePath::TriangleSpiralSkewed-E<gt>new (n_start =E<gt> $n)>

Create and return a new skewed triangle spiral object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n < 1> the return is an empty list, it being considered the path
starts at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each N
in the path as centred in a square of side 1, so the entire plane is
covered.

=back

=head1 OEIS

Entries in Sloane's Online Encyclopedia of Integer Sequences related to this
path include

    http://oeis.org/A117625  (etc)

    n_start=1 (default)
      A010054     turn 1=left,0=straight, extra initial 1

      A117625     N on X axis
      A064226     N on Y axis, but without initial value=1
      A006137     N on X negative
      A064225     N on Y negative
      A081589     N on X=Y leading diagonal
      A038764     N on X=Y negative South-West diagonal
      A081267     N on X=-Y negative South-East diagonal
      A060544     N on ESE slope dX=2,dY=-1
      A081272     N on SSE slope dX=1,dY=-2

    n_start=0
      A051682     N on X axis (11-gonal numbers)
      A081268     N on X=1 vertical (next to Y axis)
      A062728     N on South-East diagonal (11-gonal second kind)
      A081266     N on X=Y negative South-West diagonal
      A081270     N on X=1-Y North-West diagonal, starting N=3


A081271


=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::TriangleSpiral>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2010, 2011, 2012 Kevin Ryde

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
