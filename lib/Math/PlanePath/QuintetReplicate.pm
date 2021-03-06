# Copyright 2011, 2012, 2013, 2014 Kevin Ryde

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


# math-image --path=QuintetReplicate --lines --scale=10
# math-image --path=QuintetReplicate --output=numbers --all
# math-image --path=QuintetReplicate --expression='5**i'

package Math::PlanePath::QuintetReplicate;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 117;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'digit_split_lowtohigh',
  'digit_join_lowtohigh';

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;
use constant xy_is_visited => 1;
use constant x_negative_at_n => 3;
use constant y_negative_at_n => 4;

#     10        7
#         2  8  5  6
#      3  0  1  9
#         4

# my @digit_to_xbx = (0,1,0,-1,0);
# my @digit_to_xby = (0,0,-1,0,1);
# my @digit_to_y = (0,0,1,0,-1);
# my @digit_to_yby = (0,0,1,0,-1);
#     $x += $bx * $digit_to_xbx[$digit] + $by * $digit_to_xby[$digit];
#     $y += $bx * $digit_to_ybx[$digit] + $by * $digit_to_yby[$digit];

sub n_to_xy {
  my ($self, $n) = @_;
  ### QuintetReplicate n_to_xy(): $n

  if ($n < 0) {
    return;
  }
  if (is_infinite($n)) {
    return ($n,$n);
  }

  # any value in long frac lines like this?
  {
    my $int = int($n);
    if ($n != $int) {
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $frac = $n - $int;  # inherit possible BigFloat
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int; # BigFloat int() gives BigInt, use that
  }

  my $x = my $y = my $by = ($n * 0); # inherit bignum 0
  my $bx = $x+1; # inherit bignum 1

  foreach my $digit (digit_split_lowtohigh($n,5)) {
    ### $digit
    ### $bx
    ### $by

    if ($digit == 1) {
      $x += $bx;
      $y += $by;
    } elsif ($digit == 2) {
      $x -= $by;  # i*(bx+i*by) = rotate +90
      $y += $bx;
    } elsif ($digit == 3) {
      $x -= $bx;  # -1*(bx+i*by) = rotate 180
      $y -= $by;
    } elsif ($digit == 4) {
      $x += $by;  # -i*(bx+i*by) = rotate -90
      $y -= $bx;
    }

    # power (bx,by) = (bx + i*by)*(i+2)
    #
    ($bx,$by) = (2*$bx-$by, 2*$by+$bx);
  }

  return ($x, $y);
}

# digit   modulus 2Y+X mod 5
#   2        2
# 3 0 1    1 0 4
#   4        3
#
my @modulus_to_x = (0,-1,0,0,1);
my @modulus_to_y = (0,0,1,-1,0);
my @modulus_to_digit = (0,3,2,4,1);

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### QuintetReplicate xy_to_n(): "$x, $y"

  $x = round_nearest ($x);
  $y = round_nearest ($y);

  foreach my $overflow (2*$x + 2*$y, 2*$x - 2*$y) {
    if (is_infinite($overflow)) { return $overflow; }
  }

  my $zero = ($x * 0 * $y);  # inherit bignum 0
  my @n; # digits low to high

  while ($x || $y) {
    ### at: "$x,$y"

    my $m = (2*$y - $x) % 5;
    ### $m
    ### digit: $modulus_to_digit[$m]

    push @n, $modulus_to_digit[$m];

    $x -= $modulus_to_x[$m];
    $y -= $modulus_to_y[$m];
    ### modulus shift to: "$x,$y"

    # div i+2,
    # = (i*y + x) * (i-2)/-5
    # = (-y -2*y*i + x*i -2*x) / -5
    # = (y + 2*y*i - x*i + 2*x) / 5
    # = (2x+y + (2*y-x)i) / 5
    #
    # ### assert: ((2*$x + $y) % 5) == 0
    # ### assert: ((2*$y - $x) % 5) == 0

    ($x,$y) = ((2*$x + $y) / 5,
               (2*$y - $x) / 5);
  }
  return digit_join_lowtohigh (\@n, 5, $zero);
}

# level   min x^2+y^2 for N >= 5^k
#   0      1   at 1,0
#   1      2   at 1,1  factor 2
#   2      5   at 1,2  factor 2.5
#   3     16   at 0,4  factor 3.2
#   4     65   at -4,7  factor 4.0625
#   5    296   at -14,10  factor 4.55384615384615
#   6   1405   at -37,6  factor 4.74662162162162
#   7   6866   at -79,-25  factor 4.88683274021352
#
# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = abs($x1);
  $x2 = abs($x2);
  $y1 = abs($y1);
  $y2 = abs($y2);
  if ($x1 < $x2) { $x1 = $x2; }
  if ($y1 < $y2) { $y1 = $y2; }
  my $rsquared = $x1*$x1 + $y1*$y1;
  if (is_infinite($rsquared)) {
    return (0, $rsquared);
  }

  my $x = 1;
  my $y = 0;
  for (my $level = 1; ; $level++) {
    # (x+iy)*(2+i)
    ($x,$y) = (2*$x - $y, $x + 2*$y);
    if (abs($x) >= abs($y)) {
      $x -= ($x<=>0);
    } else {
      $y -= ($y<=>0);
    }

    unless ($x*$x + $y*$y <= $rsquared) {
      return (0, 5**$level - 1);
    }
  }
}

#------------------------------------------------------------------------------
# levels

sub level_to_n_range {
  my ($self, $level) = @_;
  return (0, 5**$level - 1);
}
sub n_to_level {
  my ($self, $n) = @_;
  if ($n < 0) { return undef; }
  $n = round_nearest($n);
  my ($pow, $exp) = round_down_pow ($n, 5);
  return $exp;
}

#------------------------------------------------------------------------------
1;
__END__

=for stopwords eg Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::QuintetReplicate -- self-similar "+" tiling

=head1 SYNOPSIS

 use Math::PlanePath::QuintetReplicate;
 my $path = Math::PlanePath::QuintetReplicate->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is a self-similar tiling of the plane with "+" shapes.  It's the same
kind of tiling as the C<QuintetCurve> (and C<QuintetCentres>), but with the
middle square of the "+" shape centred on the origin.

            12                         3

        13  10  11       7             2

            14   2   8   5   6         1

        17   3   0   1   9         <- Y=0

    18  15  16   4  22                -1

        19      23  20  21            -2

                    24                -3

                 ^
    -4 -3 -2 -1 X=0  1  2  3  4

The base pattern is a "+" shape

        +---+
        | 2 |
    +---+---+---+
    | 3 | 0 | 1 |
    +---+---+---+
        | 4 |
        +---+

which is then replicated

         +--+
         |  |
      +--+  +--+  +--+
      |   10   |  |  |
      +--+  +--+--+  +--+
         |  |  |   5    |
      +--+--+  +--+  +--+
      |  |   0    |  |
   +--+  +--+  +--+--+
   |   15   |  |  |
   +--+  +--+--+  +--+
      |  |  |   20   |
      +--+  +--+  +--+
               |  |
               +--+

The effect is to tile the whole plane.  Notice the centres 0,5,10,15,20 are
the same "+" shape but rotated around by an angle atan(1/2)=26.565 degrees,
as noted below.

=head2 Complex Base

This tiling corresponds to expressing a complex integer X+i*Y in base b=2+i

    X+Yi = a[n]*b^n + ... + a[2]*b^2 + a[1]*b + a[0]

where each digit a[i] is

    a[i] digit     N digit
    ----------     -------
        0             0
        1             1
        i             2
       -1             3
       -i             4

The base b=2+i is at an angle atan(1/2) = 26.56 degrees as seen at N=5
above.  Successive powers b^2, b^3, b^4 etc at N=5^level rotate around by
that much each time.

    Npow = 5^level
    angle = level*26.56 degrees
    radius = sqrt(5) ^ level

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::QuintetReplicate-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head2 Level Methods

=over

=item C<($n_lo, $n_hi) = $path-E<gt>level_to_n_range($level)>

Return C<(0, 5**$level - 1)>.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::QuintetCurve>,
L<Math::PlanePath::ComplexMinus>,
L<Math::PlanePath::GosperReplicate>

=head1 HOME PAGE

L<http://user42.tuxfamily.org/math-planepath/index.html>

=head1 LICENSE

Copyright 2011, 2012, 2013, 2014 Kevin Ryde

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
