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


package Math::PlanePath::Rows;
use 5.004;
use strict;
use warnings;
use List::Util qw(min max);
use POSIX 'floor';

use vars '$VERSION', '@ISA';
$VERSION = 2;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant x_negative => 0;
use constant y_negative => 0;


sub n_to_xy {
  my ($self, $n) = @_;
  ### x: $n % $self->{'width'}
  ### y: int ($n / $self->{'width'})
  $n--;

  # row y=0 starts at n=-0.5 with x=-0.5
  #
  # subtract back from $n instead of POSIX::fmod() because the latter rounds
  # towards 0 instead of -infinity (with a view to allowing negatives maybe,
  # perhaps)
  #
  my $y = floor (($n + 0.5) / $self->{'width'});
  return ($n - $y * $self->{'width'},
          $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;

  $x = floor ($x + 0.5);
  if ($x < 0 || $x >= $self->{'width'}) {
    return undef;  # outside the column
  }

  $y = floor ($y + 0.5);
  return $x + $y * $self->{'width'} + 1;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  my $y = POSIX::floor (max($y1,$y2) + 0.5);
  return (1,
          ($y+1) * $self->{'width'});
}

1;
__END__

=for stopwords Math-PlanePath Ryde

=head1 NAME

Math::PlanePath::Rows -- points in fixed-width rows

=head1 SYNOPSIS

 use Math::PlanePath::Rows;
 my $path = Math::PlanePath::Rows->new (width => 20);
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path is rows of a given fixed width.  For example width 7 is

                                  width=7
                                    ^
    ...                             |
      3  |  22 ...
      2  |  15  16  17  18  19  20  21
      1  |   8   9  10  11  12  13  14
    y=0  |   1   2   3   4   5   6   7
          -------------------------------
           x=0   1   2   3   4   5   6

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::Rows-E<gt>new (width =E<gt> $w)>

Create and return a new path object.  A C<width> parameter must be supplied.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> in the path.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x>,C<$y>.

C<$x> and C<$y> are rounded to the nearest integers, which has the effect of
treating each point in the path as a square of side 1, so a column -0.5 <= x
< width+0.5 and y>=-0.5 is covered.

=back

=head1 SEE ALSO

L<Math::PlanePath>, L<Math::PlanePath::Columns>

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
