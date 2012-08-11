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


package Math::PlanePath::PentSpiral;
use 5.004;
use strict;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 85;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use Math::PlanePath::Base::Generic
  'round_nearest';

# uncomment this to run the ### lines
#use Smart::Comments;


# start at diagonal to bottom right
#   d = [ 1, 2,  3 ]
#   n = [ 2, 7, 17 ]
#
#   n = (5/2*$d**2 + -5/2*$d + 2)
#   d = 1/2 + sqrt(2/5 * $n + -11/20)
#     = 1/2 + sqrt((8*$n-11)/20)
#     = (1 + sqrt((8*$n-11)/5)) / 2
#     = (5 + sqrt(5*(8*$n-11))) / 10
#     = (5 + sqrt(40*$n-55)) / 10
#
#   remainder from base $n - (5/2*$d**2 + -5/2*$d + 2)
#   then step to vertical x=0 is (2*$d-1) so
#   rem = $n - (5/2*$d**2 + -5/2*$d + 2) - (2*$d-1)
#       = $n - (5/2*$d**2 - 1/2*$d + 1)
#       = $n - (2.5*$d*$d - 0.5*$d + 1)
#       = $n - (5*$d*$d - $d + 1)/2
#       = $n - ((5*$d - 1)*$d+ 1)/2
#
sub n_to_xy {
  my ($self, $n) = @_;
  #### n_to_xy: $n
  if ($n < 1) { return; }
  if ($n < 2) { return ($n-1,0); }

  my $d = int( (sqrt(40*$n-55)+5) / 10 );
  #### d frac: .5 + sqrt((8*$n-11)/20)
  #### d frac: (sqrt(40*$n-55)+5) / 10
  #### $d

  #### remainder from base: $n - (5/2*$d**2 + -5/2*$d + 2)
  #### remainder from vertical: $n - (2.5*$d*$d - 0.5*$d + 1)
  ### assert: (((5*$d - 5)*$d + 4) % 2) == 0
  ### assert: (((5*$d - 1)*$d + 2) % 2) == 0
  #
  $n -= (5*$d - 1)*$d/2 + 1;

  if ($n < $d) {
    #### upper diagonals and right vertical
    my $nd = $n + $d;
    return (-2*$n + ($nd < 0 ? 3*$nd : 0),
            - abs($n) + $d );
  } else {
    #### lower left, and bottom horizontal ...
    $n -= 2*$d;
    #### relative to bottom left corner: "$n"
    if ($n <= 0) {
      ### lower left ...
      return ($n - $d,
              -$n - $d);
    } else {
      ### bottom horizontal: 2*$n - $d
      return (2*$n - $d,
              -$d);
    }
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;

  $x = round_nearest ($x);
  $y = round_nearest ($y);

  # nothing on odd squares
  # when y>=0 any odd x is not covered
  # when y<0 the uncovered alternates, x even on y=-1, x odd on y=-2, x even
  # y=-3 etc
  if (($x%2) ^ ($y < 0 ? $y%2 : 0)) {
    return undef;
  }

  if ($y >= 0) {
    ### top left and right slopes
    # vertical at x=0
    #   d = [ 1, 2, 3 ]
    #   n = [ 3, 10, 22 ]
    #   n = (5/2*$d**2 + -1/2*$d + 1)
    #
    ### assert: ($x%2)==0
    $x /= 2;
    my $d = abs($x) + $y;
    return (5*$d - 1)*$d/2 + 1 - $x;
  }

  if ($x < $y) {
    ### lower left slope
    # horizontal leftwards at y=0
    #   d = [ 1,  2,  3 ]
    #   n = [ 4, 12, 25 ]
    #   n = (5/2*$d**2 + 1/2*$d + 1)
    #     = (2.5*$d + 0.5)*$d + 1
    my $d = -($x+$y)/2;
    return (5*$d + 1)*$d/2 + 1 - $y;
  }

  if ($x > -$y) {
    ### lower right slope
    # horizontal rightwards at y=0
    #   d = [ 1, 2, 3, ]
    #   n = [ 2, 8, 19,]
    #   n = (5/2*$d**2 + -3/2*$d + 1)
    #     = (2.5*$d - 1.5)*$d + 1
    my $d = ($x-$y)/2;
    return (5*$d - 3)*$d/2 + 1 + $y;
  }

  ### bottom horizontal
  # vertical downwards at x=0 is
  #   y = [  -1, -2,   -3 ]
  #   n = [ 5.5, 15, 29.5 ]
  #   n = (5/2*$y**2 + -2*$y + 1)
  #     = (2.5*$y - 2)*$y + 1
  # so
  #   N = (2.5*$y - 2)*$y + 1  +  $x/2
  #     = ((5*$y - 4)*$y + $x)/2 + 1
  #
  return ((5*$y-4)*$y + $x)/2 + 1;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### PentSpiral rect_to_n_range(): $x1,$y1, $x2,$y2

  my $d = 0;
  foreach my $x ($x1, $x2) {
    $x = round_nearest ($x);
    foreach my $y ($y1, $y2) {
      $y = round_nearest ($y);

      my $this_d = 1 + ($y >= 0     ? abs($x) + $y
                        : $x < $y   ? -($x+$y)/2
                        : $x > -$y  ? ($x-$y)/2
                        : -$y);
      ### $x
      ### $y
      ### $this_d
      $d = max($d, $this_d);
    }
  }
  ### $d
  return (1,
          5*$d*($d-1)/2 + 2);
}

1;
__END__

=for stopwords PentSpiral PentSpiralSkewed PlanePath Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::PentSpiral -- integer points in a pentagonal shape

=head1 SYNOPSIS

 use Math::PlanePath::PentSpiral;
 my $path = Math::PlanePath::PentSpiral->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes a pentagonal (five-sided) spiral with points spread out to
fit on a square grid.

                      22                              3
                           
                23    10    21                        2
                                 
          24    11     3     9    20                  1
                                       
    25    12     4     1     2     8    19       <- y=0
                                        
       26    13     5     6     7    18    ...       -1
                                           
          27    14    15    16    17    33           -2
                                        
             28    29    30    31    32              -2


     ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  
    -6 -5 -4 -3 -2 -1 x=0 1  2  3  4  5  6  7

Each horizontal gap is 2, so for instance n=1 is at x=0,y=0 then n=2 is at
x=2,y=0.  The lower diagonals are 1 across and 1 down, so n=17 is at
x=4,y=-2 and n=18 is x=5,y=-1.  But the upper angles go 2 across and 1 up,
so n=20 is x=4,y=1 then n=21 is x=2,y=2.

The effect is to make the sides equal length, except for a kink at the lower
right corner.  Only every second square in the plane is used.  In the top
half (y>=0) those squares line up, in the lower half (y<0) they're offset on
alternate rows.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::PentSpiral-E<gt>new ()>

Create and return a new pentagon spiral object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n < 1> the return is an empty list, it being considered the path
starts at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each
point in the path as a square of side 1.

=back

=head1 OEIS

Entries in Sloane's Online Encyclopedia of Integer Sequences related to this
path include

    http://oeis.org/A140066  (etc)

    A140066    N on Y axis
    A134238    N on South-West diagonal

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PentSpiralSkewed>,
L<Math::PlanePath::HexSpiral>

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
