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


package Math::PlanePath::Columns;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 55;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_floor = \&Math::PlanePath::_floor;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant x_negative => 0;
use constant y_negative => 0;

sub new {
  my $self = shift->SUPER::new (@_);
  if (! exists $self->{'height'}) {
    $self->{'height'} = 1;
  }
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;

  # no division by zero, and negatives not meaningful for now
  my $height;
  if (($height = $self->{'height'}) <= 0) {
    ### no points for height<=0
    return;
  }

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;   # inherit possible BigFloat
    if (2*$frac >= 1) {  # $frac >= 0.5
      $frac -= 1;
      $n = $int; # n-1, BigFloat int() gives BigInt, use that
    } else {
      $n = $int-1;
    }
  }

  # column x=0 starts at n=0.5 with y=-0.5
  #
  # subtract back from $n instead of using POSIX::fmod() because fmod rounds
  # towards 0 instead of -infinity (in preparation for negative n one day
  # maybe, perhaps)
  #
  my $x = _floor ($n / $height);
  return ($x,
          $frac + $n - $x*$height);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;

  $y = _round_nearest ($y);
  if ($y < 0 || $y >= $self->{'height'}) {
    return undef;  # outside the oblong
  }
  $x = _round_nearest ($x);
  return $x * $self->{'height'} + $y + 1;
}

# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  my $height = $self->{'height'};

  $y1 = _round_nearest ($y1);
  $y2 = _round_nearest ($y2);
  if ($y2 < $y1) { ($y1,$y2) = ($y2,$y1) } # swap to y1<y2
  ### assert: $y1<=$y2

  if ($height<=0 || $y1 >= $height || $y2 < 0) {
    ### completely outside 0 to height-1, or height<=0
    return (1,0);
  }

  $x1 = _round_nearest ($x1);
  $x2 = _round_nearest ($x2);
  if ($x2 < $x1) { ($x1,$x2) = ($x2,$x1) } # swap to x1<x2
  ### assert: $x1<=$x2

  if ($y1 < 0) { $y1 &= 0; }                          # preserve bigint
  if ($y2 >= $height) { $y2 = ($y2 * 0) + $height-1; }  # preserve bigint

  # exact range bottom left to top right
  return ($x1*$height + $y1 + 1,
          $x2*$height + $y2 + 1);
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

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::Columns-E<gt>new (height =E<gt> $h)>

Create and return a new path object.  A C<height> parameter must be supplied.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> in the path.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.

C<$x> and C<$y> are rounded to the nearest integers, which has the effect of
treating each point in the path as a square of side 1, so a rectangle $x >=
-0.5 and -0.5 <= y < height+0.5 is covered.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

The returned range is exact, meaning C<$n_lo> and C<$n_hi> are the smallest
and biggest in the rectangle.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::Rows>,
L<Math::PlanePath::CoprimeColumns>

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
