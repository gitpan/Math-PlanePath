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


package Math::PlanePath::HeptSpiralSkewed;
use 5.004;
use strict;
use List::Util qw(min max);

use vars '$VERSION', '@ISA';
$VERSION = 40;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Smart::Comments '####';


# base lower left diagonal
#   d = [  2,  3, 4 ]
#   n = [  9, 23, 44 ]
#
#   n = (7/2*$d**2 + -7/2*$d + 2)
#     = (3.5*$d - 2.5)*$d + 1
#   d = 1/2 + sqrt(2/7 * $n + -9/28)
#     = 0.5 + sqrt(49*2/7 * $n - 49*9/28)/7
#     = 0.5 + sqrt(14 * $n - 15.75)/7
#
# initial remainder relative to rightwards horizontal y=0
#   d = [ 1,  2,  3,  4 ]
#   n = [ 2, 10, 25, 47 ]
#   n = (7/2*$d**2 + -5/2*$d + 1)
#     = (3.5*$d - 2.5)*$d + 1
#
sub n_to_xy {
  my ($self, $n) = @_;
  #### HeptSpiralSkewed n_to_xy: $n
  if ($n < 1) { return; }
  if ($n < 2) { return ($n-1,0); }

  my $d = int (0.5 + sqrt(14 * $n - 15.75)/7);
  #### d frac: (0.5 + sqrt(14 * $n - 15.75)/7)
  #### $d

  # from -$d up to 6*$d-1, inclusive
  $n -= (3.5*$d - 2.5)*$d + 1;
  #### remainder: $n

  if ($n <= 2*$d) {
    if ($n <= $d) {
      #### right slope and vertical
      return ($d - max($n,0),
              $n);
    } else {
      #### top horizontal of length d
      return ($d - $n,
              $d);
    }
  } else {
    # here $n==2*$d is the top left corner
    if ($n <= 4*$d) {
      #### left vertical
      return (-$d,
              3*$d - $n);
    } else {
      #### bottom horizontal
      return ($n - 5*$d,
              -$d);
    }
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = _round_nearest ($x);
  $y = _round_nearest ($y);

  if ($x >= 0 && $y >= 0) {
    ### slope
    # relative to the y=0 base same as above
    #   d = [ 1,  2,  3,  4 ]
    #   n = [ 2, 10, 25, 47 ]
    #   n = (7/2*$d**2 + -5/2*$d + 1)
    #     = (3.5*$d - 2.5)*$d + 1
    #
    my $d = $x + $y;
    return (3.5*$d - 2.5)*$d + 1 + $y;
  }

  my $d = max(abs($x),abs($y));
  my $n = (3.5*$d - 2.5)*$d + 1;
  if ($y == $d) {
    ### top horizontal
    return $n+$d - $x;
  }
  if ($y == -$d) {
    ### bottom horizontal
    return $n + 5*$d + $x;
  }
  if ($x == $d) {
    ### right vertical
    return $n + $y;
  }
  # ($x == - $d)
  ### left vertical
  return $n + 3*$d - $y;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);
  my $d = 0;
  foreach my $x ($x1, $x2) {
    foreach my $y ($y1, $y2) {
      $d = max ($d,
                1 + ($x > 0 && $y > 0
                     ? $x+$y                    # slope
                     : max(abs($x),abs($y))));  # square corners
    }
  }
  # ENHANCE-ME: find actual minimum if rect doesn't cover 0,0
  return (1,
          (3.5*$d - 2.5)*$d + 1);
}

1;
__END__

=for stopwords HeptSpiralSkewed PlanePath Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::HeptSpiralSkewed -- integer points around a skewed seven sided spiral

=head1 SYNOPSIS

 use Math::PlanePath::HeptSpiralSkewed;
 my $path = Math::PlanePath::HeptSpiralSkewed->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes a seven-sided spiral by cutting one corner of a square

    34-33-32-31                 3
     |         \
    35 14-13-12 30              2
     |  |      \  \
    36 15  4--3 11 29           1
     |  |  |   \  \  \
    47 16  5  1--2 10 28   <- y=0
     |  |  |        |  |
    38 17  6--7--8- 9 27       -1
     |  |              |
    39 18-22-23-24-25-26       -2
     |
    40-41-42-43-44-...

              ^
    -3 -2 -1 x=0 1  2  3

The path is as if around a heptagon, with the left and bottom here as two
sides of the heptagon straightened out, and the flat top here skewed across
to fit a square grid.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::HeptSpiralSkewed-E<gt>new ()>

Create and return a new heptagon spiral object.

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

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SquareSpiral>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

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
