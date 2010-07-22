# Copyright 2010 Kevin Ryde

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


package Math::PlanePath::Columns;
use 5.004;
use strict;
use warnings;
use List::Util qw(min max);
use POSIX 'floor';

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 5;
@ISA = ('Math::PlanePath');

use constant x_negative => 0;
use constant y_negative => 0;

sub n_to_xy {
  my ($self, $n) = @_;

  # column x=0 starts at n=0.5 with y=-0.5
  #
  # subtract back from $n instead of using POSIX::fmod() because fmod rounds
  # towards 0 instead of -infinity (in preparation for negative n one day
  # maybe, perhaps)
  #
  $n--;
  my $x = floor (($n + 0.5) / $self->{'height'});
  return ($x,
          $n - $x * $self->{'height'});
}

sub xy_to_n {
  my ($self, $x, $y) = @_;

  $y = floor ($y + 0.5);
  if ($y < 0 || $y >= $self->{'height'}) {
    return undef;  # outside the oblong
  }
  $x = floor ($x + 0.5);
  return $x * $self->{'height'} + $y + 1;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  my $x = floor (max($x1,$x2) + 0.5);
  return (1,
          ($x+1) * $self->{'height'});
}

1;
__END__

=for stopwords pronic SacksSpiral PyramidSides PlanePath Math-PlanePath Ryde

=head1 NAME

Math::PlanePath::Columns -- points in fixed-height columns

=head1 SYNOPSIS

 use Math::PlanePath::Columns;
 my $path = Math::PlanePath::Columns->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path is columns of a given fixed height.  For example height 5 would be

         |
      4  |   5  10  15  20    --->   height==5
      3  |   4   9  14  19
      2  |   3   8  13  18
      1  |   2   7  12  17  ...
    y=0  |   1   6  11  16  21 
          ----------------------
           x=0   1   2   3   4  ...

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::Columns-E<gt>new (height =E<gt> $h)>

Create and return a new path object.  A C<height> parameter must be supplied.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> in the path.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.

C<$x> and C<$y> are rounded to the nearest integers, which has the effect of
treating each point in the path as a square of side 1, so a rectangle $x >=
-0.5 and -0.5 <= y < height+0.5 is covered.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::Rows>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Math-PlanePath is Copyright 2010 Kevin Ryde

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