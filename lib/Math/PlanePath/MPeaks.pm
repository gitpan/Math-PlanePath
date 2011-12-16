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


package Math::PlanePath::MPeaks;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 60;
use Math::PlanePath 54; # v.54 for _max()
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant y_negative => 0;

# starting each left side at 0.5 before
# [ 1,2,3 ],
# [ 1-0.5, 6-0.5, 17-0.5 ]
# N = (3 d^2 - 4 d + 3/2)
#   = (3*$d**2 - 4*$d + 3/2)
#   = ((3*$d - 4)*$d + 3/2)
# d = 2/3 + sqrt(1/3 * $n + -1/18)
#   = (2 + 3*sqrt(1/3 * $n - 1/18))/3
#   = (2 + sqrt(3 * $n - 1/2))/3
#   = (4 + 2*sqrt(3 * $n - 1/2))/6
#   = (4 + sqrt(12*$n - 2))/6
# at n=1/2 d=(4+sqrt(12/2-2))/6 = (4+sqrt(4))/6  = 1
#
# base at Y=0
# [ 1, 6, 17 ]
# N = (3 d^2 - 4 d + 2)
#   = (3*$d**2 - 4*$d + 2)
#   = ((3*$d - 4)*$d + 2)
#
# centre
# [ 3,11,25 ]
# N = (3 d^2 - d + 1)
#   = (3*$d**2 - $d + 1)
#   = ((3*$d - 1)*$d + 1)
#
sub n_to_xy {
  my ($self, $n) = @_;
  ### MPeaks n_to_xy(): $n

  # $n<0.5 no good for Math::BigInt circa Perl 5.12, compare in integers
  return if 2*$n < 1;

  my $d = int( (sqrt(int(12*$n)-2) + 4) / 6 );
  $n -= ((3*$d - 1)*$d + 1);   # to $n==0 at centre
  ### $d
  ### remainder: $n

  if ($n >= $d) {
    ### right vertical ...
    # N-d is top of right peak
    # N-(3d-1) = N-3d+1 is right Y=0
    # Y=-(N-2d+1)= -N+3d-1
    return ($d,
            -$n + 3*$d - 1);
  }
  if ($n <= (my $neg_d = -$d)) {
    ### left vertical ...
    # N+(3d-1) is left Y=0
    # Y=N+3d-1
    return ($neg_d,
            $n + 3*$d - 1);
  }
  ### centre diagonals ...
  return ($n,
          abs($n) + $d-1);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### MPeaks xy_to_n(): $x, $y

  $y = _round_nearest ($y);
  if ($y < 0) {
    return undef;
  }
  $x = _round_nearest ($x);

  {
    my $two_x;
    if (($two_x=2*$x) > $y) {
      ### right vertical ...
      # right end [ 5,16,33 ]
      # N = (3 x^2 + 2 x)
      return (3*$x+2)*$x - $y;
    }
    if ($two_x < -$y) {
      ### left vertical ...
      # Nleftend = (3 d^2 - 4 d + 2)
      #          = (3x+4)x + 2
      return (3*$x+4)*$x + 2 + $y;
    }
  }

  ### centre diagonals ...
  # d=Y+abs(x) with d=0 first (not d=1 as above),  N=(3 d^2 + 5 d + 3)
  my $d = $y - abs($x);
  ### $d
  return (3*$d+5)*$d + 3 + $x;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);

  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); } # swap to y1<=y2
  if ($y2 < 0) {
    return (1, 0); # rect all negative, no N
  }
  if ($y1 < 0) { $y1 = 0; }

  # ENHANCE-ME: this is a big over-estimate
  my $d = _max ($y2+1,
                abs($x1),
                abs($x2));

  # Nrightend = 3d^2 + 2d
  return (1,
          (3*$d+2)*$d);
}

# my @n;
# if ($y1 <= 2*$x2) {
#   # right vertical
#   push @n, (3*$x2+2)*$x2 - $y1;
# }
# if (($x1 > 0) != ($x2 > 0)) {
#   # centre vertical
#   return (3*$y2+5)*$y2 + 3;
# }


1;
__END__

=for stopwords Ryde Math-PlanePath ie HexSpiral

=head1 NAME

Math::PlanePath::MPeaks -- points in expanding M shape

=head1 SYNOPSIS

 use Math::PlanePath::MPeaks;
 my $path = Math::PlanePath::MPeaks->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path puts points in layers of an "M" shape

         41                              49         7
         40  42                      48  50         6
         39  22  43              47  28  51         5
         38  21  23  44      46  27  29  52         4
         37  20   9  24  45  26  13  30  53         3
         36  19   8  10  25  12  14  31  54         2
         35  18   7   2  11   4  15  32  55         1
         34  17   6   1   3   5  16  33  56     <- Y=0

                          ^
         -4  -3  -2  -1  X=0  1   2   3   4

N=1 to N=5 is the first "M" shape, then N=6 to N=16 on top of that, etc.
The centre goes half way down.  Reckoning the N=1 to N=5 as layer d=1 then

    Xleft = -d
    Xright = d
    Ypeak = 2*d - 1
    Ycentre = d - 1

Each "M" is 6 points longer than the preceding.  The verticals are 2 longer
each, and the centre diagonals 1 longer each.  This step 6 is similar to the
HexSpiral.

The octagonal numbers 1,8,21,40,65,etc k*(3k-2) are a straight line of slope
2 going up to the left.  The octagonal numbers of the second kind
5,16,33,56,etc k*(3k+2) are along the X axis to the right.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MPeaks-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n < 0.5> the return is an empty list, it being considered there are
no negative points.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are each
rounded to the nearest integer which has the effect of treating points as a
squares of side 1, so the half-plane y>=-0.5 is entirely covered.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PyramidSides>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011 Kevin Ryde

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
# compile-command: "math-image --path=MPeaks --lines --scale=20"
# End:
#
# math-image --path=MPeaks --all --output=numbers
