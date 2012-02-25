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

package Math::PlanePath::DiagonalsAlternating;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 71;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant class_x_negative => 0;
use constant class_y_negative => 0;

# d= [ 1,2,3 ]
# N= [ 1,6,15 ]
# N = (2 d^2 - d)
#   = (2*$d**2 - $d)
#   = ((2*$d - 1)*$d)
# d = 1/4 + sqrt(1/2 * $n + 1/16)
#   = (1 + sqrt(8*$n + 1)) / 4
#
# relative to midpoint
# d= [ 1,2,3 ]
# N= [ 3,10,21 ]
# N = ((2*$d + 1)*$d)
#
sub n_to_xy {
  my ($self, $n) = @_;
  ### DiagonalsAlternating n_to_xy(): "$n   ".(ref $n || '')

  if ($n < 1) {
    return;
  }
  my $int = int($n);  # BigFloat int() gives BigInt, use that
  $n -= $int;         # frac, preserving any BigFloat

  my $d = int((sqrt(8*$int+7) + 1) / 4);
  $int -= ((2*$d + 1)*$d);

  ### $d
  ### remainder: "$int"

  if ($int >= 0) {
    ### positive, upwards ...
    if ($int == 0) {
      ### horizontal X axis ...
      return ($n + 2*$d-1,
              0);
    } else {
      $n += $int;
      return (-$n + 2*$d + 1,
              $n - 1);
    }
  } else {
    ### negative remainder, downwards ...
    if ($int == -2*$d) {
      ### vertical Y axis ...
      return (0,
              $n + 2*$d - 2);
    } else {
      $n += $int;
      return ($n + 2*$d - 1,
              -$n);
    }
  }
  return ($n + $int,
          -$n - $int + $d);   # $n first so BigFloat not BigInt from $d
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### xy_to_n(): $x, $y

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($x < 0 || $y < 0) {
    return undef;  # outside first quadrant
  }

  my $d = $x + $y;

  # odd, downwards ...
  # d= [ 1,3,5 ]
  # N= [ 2,7,16 ]
  # N = ((1/2*$d + 1/2)*$d + 1)
  #
  # even, upwards
  # d= [ 0,2,4 ]
  # N= [ 1,4,11 ]
  # N = ((1/2*$d + 1/2)*$d + 1)
  #   = ($d + 1)*$d/2 + 1

  my $n = ($d + 1)*$d/2 + 1;
  if ($d % 2) {
    return $n + $x;
  } else {
    return $n + $y;
  }
}

# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }
  if ($y2 < 0 || $x2 < 0) {
    return (1, 0); # rect all negative, no N
  }

  my $zero = ($x1 * 0 * $y1 * $x2 * $y2);  # inherit bignum 0

  if ($x1 < 0) { $x1 = 0; }
  if ($y1 < 0) { $y1 = 0; }

  # exact range bottom left to top right
  return ($self->xy_to_n ($zero+$x1,$y1),
          $self->xy_to_n ($zero+$x2,$y2));
}

1;
__END__

=for stopwords PlanePath Ryde Math-PlanePath hexagonals

=head1 NAME

Math::PlanePath::DiagonalsAlternating -- points in diagonal stripes of alternating directions

=head1 SYNOPSIS

 use Math::PlanePath::DiagonalsAlternating;
 my $path = Math::PlanePath::DiagonalsAlternating->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path follows successive diagonals going from the Y axis down to the X
axis and then back again,

      7  |  29 
      6  |  28  30
      5  |  16  27  31
      4  |  15  17  26  ...
      3  |   7  14  18  25 
      2  |   6   8  13  19  24 
      1  |   2   5   9  12  20  23
    Y=0  |   1   3   4  10  11  21  22
         +----------------------------
           X=0   1   2   3   4   5   6

The triangular numbers 1,3,6,10,etc, k*(k+1)/2, fall alternately on the X
axis and Y axis.  So 1,6,15,28,etc on the Y axis, and 3,10,21,36,etc on the
X axis.  Those on the Y axis are the hexagonal numbers j*(2j-1) and those on
the X axis are the hexagonals of the second kind j*(2j+1).

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::DiagonalsAlternating-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n E<lt> 1> the return is an empty list, it being considered the path
begins at 1.

=back

=head1 FORMULAS

=head2 Rectangle to N Range

Within each row increasing X is increasing N, and in each column increasing
Y is increasing N.  So in a rectangle the lower left corner is the minimum N
and the upper right is the maximum N.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::Diagonals>

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


# Local variables:
# compile-command: "math-image --path=DiagonalsAlternating --lines --scale=20"
# End:
#
# math-image --path=DiagonalsAlternating --all --output=numbers_dash
