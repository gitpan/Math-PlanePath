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


# math-image --path=SierpinskiArrowheadSkewed --lines --scale=10
# math-image --path=SierpinskiArrowheadSkewed --output=numbers


package Math::PlanePath::SierpinskiArrowheadSkewed;
use 5.004;
use strict;
use POSIX qw(floor);

use vars '$VERSION', '@ISA';
$VERSION = 67;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use Math::PlanePath::Base::Generic
  'round_nearest';
use Math::PlanePath::SierpinskiArrowhead;

# uncomment this to run the ### lines
#use Devel::Comments;


use constant n_start => 0;
use constant class_x_negative => 0;
use constant class_y_negative => 0;

sub n_to_xy {
  my ($self, $n) = @_;
  ### SierpinskiArrowheadSkewed n_to_xy(): $n
  my ($x, $y) = Math::PlanePath::SierpinskiArrowhead->n_to_xy($n)
    or return;
  return (($y+$x)/2, ($y-$x)/2);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = round_nearest ($x);
  $y = round_nearest ($y);
  return Math::PlanePath::SierpinskiArrowhead->xy_to_n
    ($y-$x, $y+$x);
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1) }
  $y2 = round_nearest ($y2);
  if ($y2 < 0) {
    return (1,0);
  }

  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1) }
  $x2 = round_nearest ($x2);
  if ($x2 < 0) {
    return (1,0);
  }
  my $h = $x2+$y2;
  return Math::PlanePath::SierpinskiArrowhead->rect_to_n_range
    (-$h,0, $h,$h);
}

1;
__END__

=for stopwords eg Ryde Sierpinski

=head1 NAME

Math::PlanePath::SierpinskiArrowheadSkewed -- self-similar triangular path traversal

=head1 SYNOPSIS

 use Math::PlanePath::SierpinskiArrowheadSkewed;
 my $path = Math::PlanePath::SierpinskiArrowheadSkewed->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<Old ...>

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::SierpinskiArrowheadSkewed-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::KochCurve>

=cut
