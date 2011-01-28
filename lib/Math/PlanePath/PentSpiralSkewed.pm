# Copyright 2010, 2011 Kevin Ryde

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


package Math::PlanePath::PentSpiralSkewed;
use 5.004;
use strict;
use warnings;
use List::Util qw(min max);
use POSIX 'floor';

use vars '$VERSION', '@ISA';
$VERSION = 19;

use Math::PlanePath;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;


# start at diagonal to bottom right
#   d = [ 1, 2,  3 ]
#   n = [ 2, 7, 17 ]
#
#   n = (5/2*$d**2 + -5/2*$d + 2)
#   d = 1/2 + sqrt(2/5 * $n + -11/20)
#     =  .5 + sqrt((8*$n-11)/20)
#
#   remainder from base $n - (5/2*$d**2 + -5/2*$d + 2)
#   then step to vertical x=0 is (2*$d-1) so
#   rem = $n - (5/2*$d**2 + -5/2*$d + 2) - (2*$d-1)
#       = $n - (5/2*$d**2 - 1/2*$d + 1)
#       = $n - (2.5*$d*$d - 0.5*$d + 1)
#
sub n_to_xy {
  my ($self, $n) = @_;
  #### n_to_xy: $n
  if ($n < 1) { return; }
  if ($n < 2) { return ($n-1,0); }

  my $d = int (.5 + sqrt((8*$n-11)/20));
  #### d frac: .5 + sqrt((8*$n-11)/20)
  #### $d
  #### remainder from base: $n - (5/2*$d**2 + -5/2*$d + 2)
  #### remainder from vertical: $n - (2.5*$d*$d - 0.5*$d + 1)
  $n -= (2.5*$d*$d - 0.5*$d + 1);

  if ($n < $d) {
    #### upper diagonals and right vertical
    return (min(-$n, $d),
            $d - abs($n));
  } else {
    #### lower left and bottom horizontal
    return (-2*$d + $n,
            max ($d-$n, -$d));
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;

  $x = floor ($x + 0.5);
  $y = floor ($y + 0.5);

  if ($x > 0 && $y < 0) {
    # vertical downwards at x=0
    #   d = [ 1, 2, 3 ]
    #   n = [ 5, 14, 28 ]
    #   n = (5/2*$d**2 + 3/2*$d + 1)
    # so
    my $d = max($x-1, -$y);
    ### lower right square part
    ### $d
    return ((5/2*$d**2 + 3/2*$d + 1)
            + $x
            + ($x > $d ? $y+$d : 0));
  }

  # vertical at x=0
  #   d = [ 1, 2, 3 ]
  #   n = [ 3, 10, 22 ]
  #   n = (5/2*$d**2 + -1/2*$d + 1)
  #
  my $d = abs($x)+abs($y);
  return ((5/2*$d**2 + -1/2*$d + 1)
          - $x
          + ($y < 0 ? 2*($d+$x) : 0));
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### PentSpiralSkewed xy_to_n_range(): $x1,$y1, $x2,$y2

  my $d = 0;
  foreach my $x ($x1, $x2) {
    $x = floor(0.5 + $x);
    foreach my $y ($y1, $y2) {
      $y = floor(0.5 + $y);

      my $this_d = 1 + ($x > 0 && $y < 0
                        ? max($x,-$y)
                        : abs($x)+abs($y));
      ### $x
      ### $y
      ### $this_d
      $d = max($d, $this_d);
    }
  }
  ### $d
  return (1,
          2.5*$d*($d-1) + 2);
}

1;
__END__

=for stopwords PentSpiral SquareSpiral DiamondSpiral PlanePath Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::PentSpiralSkewed -- integer points in a pentagonal shape

=head1 SYNOPSIS

 use Math::PlanePath::PentSpiralSkewed;
 my $path = Math::PlanePath::PentSpiralSkewed->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes a pentagonal (five-sided) spiral with points skewed so as to
fit a square grid and fully cover the plane.

          10 ...             2
         /  \  \
       11  3  9 20           1
      /  /  \  \  \
    12  4  1--2  8 19    <- y=0
      \  \       |  | 
       13  5--6--7 18       -1
         \          |    
          14-15-16-17       -2
               
     ^  ^  ^  ^  ^  ^ 
    -2 -1 x=0 1  2  3 ...

The pattern is similar to the SquareSpiral but cuts three corners which
makes each cycle is faster.  Each cycle is just 5 steps longer than the
previous (where it's 8 for a SquareSpiral).

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::PentSpiral-E<gt>new ()>

Create and return a new PentSpiral spiral object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> on the path.

For C<$n < 1> the return is an empty list, it being considered the path
starts at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each
point in the path as a square of side 1.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SquareSpiral>,
L<Math::PlanePath::DiamondSpiral>,
L<Math::PlanePath::HexSpiralSkewed>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Math-PlanePath is Copyright 2010, 2011 Kevin Ryde

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
