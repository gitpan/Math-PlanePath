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


package Math::PlanePath::Diagonals;
use 5.004;
use strict;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 91;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use Math::PlanePath::Base::Generic
  'round_nearest';

# uncomment this to run the ### lines
#use Smart::Comments;

use constant class_x_negative => 0;
use constant class_y_negative => 0;
use constant n_frac_discontinuity => .5;

use constant parameter_info_array =>
  [ { name        => 'direction',
      share_key   => 'direction_ud',
      display     => 'Direction',
      type        => 'enum',
      default     => 'down',
      choices     => ['down','up'],
      choices_display => ['Down','Up'],
      description => 'Number points downwards or upwards along the diagonals.',
    },
    Math::PlanePath::Base::Generic::_parameter_info_nstart1(),
  ];

sub dx_maximum {
  my ($self) = @_;
  return ($self->{'direction'} eq 'down'
          ? 1       # down at most +1 across
          : undef); # up jumps back across unlimited at top
}
sub dy_minimum {
  my ($self) = @_;
  return ($self->{'direction'} eq 'down'
          ? -1      # down at most -1
          : undef); # up jumps down unlimited at top
}

#------------------------------------------------------------------------------

sub new {
  my $self = shift->SUPER::new(@_);
  if (! defined $self->{'n_start'}) {
    $self->{'n_start'} = $self->default_n_start;
  }
  $self->{'direction'} ||= 'down';

  # secret undocumented options
  $self->{'x_start'} ||= 0;
  $self->{'y_start'} ||= 0;
  return $self;
}

# start each diagonal at 0.5 earlier
#
#     s = [   0,   1,   2,   3,    4 ]
#     n = [ 0.5, 1.5, 3.5, 6.5, 10.5 ]
#               +1   +2   +3   +4
#                  1    1    1
#
#     n = 0.5*$s*$s + 0.5*$s + 0.5
#     s = 1/2 * (-1 + sqrt(4*2n + 1 - 4))
#     s = -1/2 + sqrt(2n - 3/4)
#       = [ -1 + sqrt(8n - 3) ] / 2
#
#     remainder n - (0.5*$s*$s + 0.5*$s + 0.5)
#     is dist from x=-0.5 and y=$s+0.5
#     work the 0.5 in so
#         n - (0.5*$s*$s + 0.5*$s + 0.5) - 0.5
#       = n - (0.5*$s*$s + 0.5*$s + 1)
#       = n - 0.5*$s*($s+1) + 1
#
# starting on the integers vertical at X=0
#
#     s = [   0,  1, 2, 3,  4 ]
#     n = [   1,  2, 4, 7, 11 ]
#
#     N = (1/2 d^2 + 1/2 d + 1)
#       = ((1/2*$d + 1/2)*$d + 1)
#       = (d+1)*d/2 + 1     one past triangular
#     d = -1/2 + sqrt(2 * $n -7/4)
#       = [-1 + sqrt(8*$n - 7)] / 2
#
sub n_to_xy {
  my ($self, $n) = @_;
  ### Diagonals n_to_xy(): "$n   ".(ref $n || '')

  # adjust to N=1 at origin X=0,Y=0
  $n = $n - $self->{'n_start'} + 1;

  my $int = int($n);  # BigFloat int() gives BigInt, use that
  $n -= $int;         # frac, preserving any BigFloat

  if (2*$n >= 1) {  # if $frac >= 0.5
    $n -= 1;
    $int += 1;
  }
  ### $int
  ### $n
  return if $int < 1;

  ### sqrt of: (8*$int - 7).''
  my $d = int((sqrt(8*$int-7) - 1) / 2);

  $int -= $d*($d+1)/2 + 1;

  ### d: "$d"
  ### sub: ($d*($d+1)/2 + 1).''
  ### remainder: "$int"

  my $x = $n + $int;
  my $y = -$n - $int + $d;  # $n first so BigFloat not BigInt from $d
  if ($self->{'direction'} eq 'up') {
    ($x,$y) = ($y,$x);
  }
  return ($x + $self->{'x_start'},
          $y + $self->{'y_start'});
}

# round y on an 0.5 downwards so that x=-0.5,y=0.5 gives n=1 which is the
# inverse of n_to_xy() ... or is that inconsistent with other classes doing
# floor() always?
#
# d(d+1)/2+1
#   = (d^2 + d + 2) / 2
#
sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### xy_to_n(): $x, $y
  $x = $x - $self->{'x_start'};   # "-" operator to provoke warning if x==undef
  $y = $y - $self->{'y_start'};
  if ($self->{'direction'} eq 'up') {
    ($x,$y) = ($y,$x);
  }
  $x = round_nearest ($x);
  $y = round_nearest (- $y);
  ### rounded
  ### $x
  ### $y
  if ($x < 0 || $y > 0) {
    return undef;  # outside
  }

  my $d = $x - $y;
  ### $d
  return $d*($d+1)/2 + $x + $self->{'n_start'};
}

# bottom-left to top-right, used by DiagonalsAlternating too
# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }
  if ($x2 < $self->{'x_start'} || $y2 < $self->{'y_start'}) {
    return (1, 0); # rect all negative, no N
  }

  $x1 = max ($x1, $self->{'x_start'});
  $y1 = max ($y1, $self->{'y_start'});

  # exact range bottom left to top right
  return ($self->xy_to_n ($x1,$y1),
          $self->xy_to_n ($x2,$y2));
}

1;
__END__

=for stopwords PlanePath Ryde Math-PlanePath DiagonalsOctant OEIS

=head1 NAME

Math::PlanePath::Diagonals -- points in diagonal stripes

=head1 SYNOPSIS

 use Math::PlanePath::Diagonals;
 my $path = Math::PlanePath::Diagonals->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path follows successive diagonals going from the Y axis down to the X
axis.

      6  |  22
      5  |  16  23
      4  |  11  17  24
      3  |   7  12  18  ...
      2  |   4   8  13  19
      1  |   2   5   9  14  20
    Y=0  |   1   3   6  10  15  21
         +-------------------------
           X=0   1   2   3   4   5

N=1,3,6,10,etc on the X axis is the triangular numbers.  N=1,2,4,7,11,etc on
the Y axis is the triangular plus 1, the next point visited after the X
axis.

=head2 Direction

Option C<direction =E<gt> 'up'> reverses the order within each diagonal to
count upward from the X axis.

=cut

# math-image --path=Diagonals,direction=up  --all --output=numbers

=pod

    direction => "up"

      5  |  21
      4  |  15  20
      3  |  10  14  19 ...
      2  |   6   9  13  18  24
      1  |   3   5   8  12  17  23
    Y=0  |   1   2   4   7  11  16  22
         +-----------------------------
           X=0   1   2   3   4   5   6

This is merely a transpose changing X,Y to Y,X, but it's the same as in
DiagonalsOctant and can be handy to control the direction when combining
Diagonals with some other path or calculation.

=head2 N Start

The default is to number points starting N=1 as shown above.  An optional
C<n_start> can give a different start, in the same diagonals sequence.  For
example to start at 0,

=cut

# math-image --path=Diagonals,n_start=0 --all --output=numbers --size=35x5
# math-image --path=Diagonals,n_start=0,direction=up --all --output=numbers --size=35x5

=pod

    n_start => 0                 n_start=>0, direction=>"up"

      4  |  10                        |  14
      3  |   6 11                     |   9 13
      2  |   3  7 12                  |   5  8 12
      1  |   1  4  8 13               |   2  4  7 11
    Y=0  |   0  2  5  9 14            |   0  1  3  6 10
         +-----------------           +-----------------
           X=0  1  2  3  4              X=0  1  2  3  4

=head2 X,Y Start

Options C<x_start =E<gt> $x> and C<x_start =E<gt> $y> give a starting
position for the diagonals.  For example to start at X=1,Y=1

      7  |   22               x_start => 1,
      6  |   16 23            y_start => 1
      5  |   11 17 24         
      4  |    7 12 18 ...     
      3  |    4  8 13 19      
      2  |    2  5  9 14 20   
      1  |    1  3  6 10 15 21
    Y=0  | 
         +------------------
         X=0  1  2  3  4  5

The effect is merely to add a fixed offset to all X,Y values taken and
returned, but it can be handy to have the path do that to step through
non-negatives or similar.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::Diagonals-E<gt>new ()>

=item C<$path = Math::PlanePath::Diagonals-E<gt>new (direction =E<gt> $str, n_start =E<gt> $integer)>

Create and return a new path object.  The C<direction> option (a string) can
be

    direction => "down"       the default
    direction => "up"         number upwards from the X axis

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n E<lt> 0.5> the return is an empty list, it being considered the
path begins at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each
point C<$n> as a square of side 1, so the quadrant x>=-0.5, y>=-0.5 is
entirely covered.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

The returned range is exact, meaning C<$n_lo> and C<$n_hi> are the smallest
and biggest in the rectangle.

=back

=head1 FORMULAS

=head2 X,Y to N

The sum d=X+Y numbers each diagonal from d=0 upwards, corresponding to the Y
coordinate where the diagonal starts (or X if direction=up).

    d=2
        \
    d=1  \
        \ \
    d=0  \ \
        \ \ \

N is then given by

    d = X+Y
    N = d*(d+1)/2 + X + Nstart

The d*(d+1)/2 shows how the triangular numbers fall on the Y axis when X=0
and Nstart=0.  For the default Nstart=1 it's 1 more than the triangulars, as
noted above.

=head2 Rectangle to N Range

Within each row increasing X is increasing N, and in each column increasing
Y is increasing N.  So in a rectangle the lower left corner is the minimum N
and the upper right is the maximum N.

    |            \     \ N max
    |       \ ----------+
    |        |     \    |\
    |        |\     \   |
    |       \| \     \  |
    |        +----------
    |  N min  \  \     \
    +-------------------------

=head1 OEIS

Entries in Sloane's Online Encyclopedia of Integer Sequences related to this
path include

    http://oeis.org/A023531  (etc)

    direction=down
      A002262    X coordinate, runs 0 to k
      A025581  	 Y coordinate, runs k to 0
      A003056  	 X+Y coordinate sum, k repeated k+1 times
      A114327  	 Y-X coordinate diff
      A049581    abs(X-Y) coordinate diff
      A004247    X*Y coordinate product
      A048147    X^2+Y^2

      A127949    dY, change in Y coordinate

      A000124    N on Y axis
      A001844    N on X=Y diagonal

    direction=down, n_start=0
      A023531    dSum = dX+dY, being 1 at N=triangular+1 (and 0)
      A129184    turn 1=left,0=right

    direction=up
      Likewise but swapping X,Y.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DiagonalsAlternating>,
L<Math::PlanePath::DiagonalsOctant>,
L<Math::PlanePath::Corner>,
L<Math::PlanePath::Rows>,
L<Math::PlanePath::Columns>

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
