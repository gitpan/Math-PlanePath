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


package Math::PlanePath::Staircase;
use 5.004;
use strict;
use List::Util 'max';
use POSIX 'floor';

use vars '$VERSION', '@ISA';
$VERSION = 21;

use Math::PlanePath;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant x_negative => 0;
use constant y_negative => 0;

# start from 0.5 back
# d = [ 0, 1,  2, 3 ]
# n = [ 1.5, 6.5, 15.5 ]
# n = ((2*$d - 1)*$d + 0.5)
# d = 1/4 + sqrt(1/2 * $n + -3/16)
#
sub n_to_xy {
  my ($self, $n) = @_;
  #### Staircase n_to_xy: $n
  if ($n < .5) { return; }

  my $d = int ((1 + sqrt(8*$n -3)) * .25);
  #### $d
  #### d frac: ((1 + sqrt(8*$n -3)) * .25)
  #### base: ((2*$d - 1)*$d + 0.5)

  $n -= (2*$d - 1)*$d;
  ### rem: $n

  my $i = floor($n);
  my $if = $n - $i;
  my $r = int($i/2);
  if ($i & 1) {
    ### down
    return ($r, 2*$d - $r - $if);
  } else {
    ### across
    return ($r-1+$if, 2*$d - $r);
  }
}

# d = [ 1  2, 3, 4 ]
# N = [ 2, 7, 16, 29 ]
# N = (2 d^2 - d + 1)
# and add 2*$d
# base = 2*d^2 - d + 1 + 2*d
#      = 2*d^2 + d + 1
#      = (2*$d + 1)*$d + 1
#
sub xy_to_n {
  my ($self, $x, $y) = @_;

  $x = floor ($x + 0.5);
  $y = floor ($y + 0.5);
  if ($x < 0 || $y < 0) {
    return undef;
  }
  my $d = int(($x + $y + 1) / 2);
  return (2*$d + 1)*$d + 1 - $y + $x;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### Staircase xy_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = floor ($x1 + 0.5);
  $y1 = floor ($y1 + 0.5);
  $x2 = floor ($x2 + 0.5);
  $y2 = floor ($y2 + 0.5);
  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }
  if ($x2 < 0 || $y2 < 0) {
    return (1, 0);   # nothing in first quadrant
  }

  $x1 = max (0, $x1);
  $y1 = max (0, $y1);
  $x2 = max (0, $x2);
  $y2 = max (0, $y2);
  my $y_min = $y1;

  if ((($x1 ^ $y1) & 1) && $y1 < $y2) {  # y2==y_max
    $y1++;
    ### y1 inc: $y1
  }
  if (! (($x2 ^ $y2) & 1) && $y2 > $y_min) {
    $y2--;
    ### y2 dec: $y2
  }
  return ($self->xy_to_n($x1,$y1), $self->xy_to_n($x2,$y2));
}

1;
__END__

=for stopwords SquareSpiral eg Staircase PlanePath Ryde Math-PlanePath HexSpiralSkewed ascii

=head1 NAME

Math::PlanePath::Staircase -- integer points in a diamond shape

=head1 SYNOPSIS

 use Math::PlanePath::Staircase;
 my $path = Math::PlanePath::Staircase->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes a staircase pattern down from the Y axis to the X,

     8      29
             |
     7      30---31
                  |
     6      16   32---33
             |         |
     5      17---18   34---35
                  |         |
     4       7   19---20   36---37
             |         |         |
     3       8--- 9   21---22   38---39
                  |         |         |
     2       2   10---11   23---24   40...
             |         |         |
     1       3--- 4   12---13   25---26
                  |         |         |
    y=0 ->   1    5--- 6   14---15   27---28

             ^   
            x=0   1    2    3    4    5    6

The 1,6,15,28,etc along the X axis at the end of each run are the hexagonal
numbers k*(2*k-1).  The diagonal 3,10,21,36,etc up from x=0,y=1 is the
second hexagonal numbers k*(2*k+1), formed by extending the hexagonal
numbers to negative k.  The two together are the triangular numbers
k*(k+1)/2.

Legendre's prime generating polynomial 2*k^2+29 bounces around for some low
values then makes a steep diagonal upwards from x=19,y=1, at a slope 3 up
for 1 across, but only 2 of each 3 drawn.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::Staircase-E<gt>new ()>

Create and return a new staircase path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> on the path.

For C<$n < 0.5> the return is an empty list, it being considered the path
begins at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
rounded to the nearest integers, which has the effect of treating each point
C<$n> as a square of side 1, so the quadrant x>=-0.5, y>=-0.5 is covered.

=back

=head1 FORMULAS

=head2 N Range

Within each row increasing X is increasing N, and in each column increasing
Y is increasing pairs of N.  Thus for C<rect_to_n_range> the lower left
corner vertical pair is the minimum N and the upper right vertical pair is
the maximum N.

A given X,Y is the larger of a vertical pair when ((X^Y)&1)==1.  If that
happens at the lower left corner then it's X,Y+1 which is the smaller N, if
Y+1 is in the rectangle.  Conversely at the top right if ((X^Y)&1)==0 then
it's X,Y-1 which is the bigger N, if Y-1 is in the rectangle.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::Diagonals>,
L<Math::PlanePath::Corner>

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