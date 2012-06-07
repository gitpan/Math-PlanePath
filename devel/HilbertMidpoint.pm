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





     # <a href="gallery.html#hilbert-midpoint" title="HilbertMidpoint">
     #    <img src="hilbert-midpoint-small.png" width=32 height=32 align=middle
     #         alt="HilbM"></a>

# <a name="hilbert-midpoint">, HilbertMidpoint
# </a>
# <img src="hilbert-midpoint-big.png" width=190 height=190
#      alt="HilbertMidpoint sample">
# <a href="http://search.cpan.org/perldoc?Math::PlanePath::HilbertMidpoint">
# HilbertMidpoint</a> and

     # 'Math::PlanePath::HilbertMidpoint'      => 58, # new in v.58


# Local variables:
# compile-command: "math-image --path=HilbertMidpoint --lines --scale=40"
# End:
#
# math-image --path=HilbertMidpoint --all --output=numbers_dash



package Math::PlanePath::HilbertMidpoint;
use 5.004;
use strict;

use Math::PlanePath;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::HilbertCurve;

use vars '$VERSION', '@ISA';
$VERSION = 77;
@ISA = ('Math::PlanePath');


# uncomment this to run the ### lines
#use Devel::Comments;


use constant n_start => 0;
use constant class_x_negative => 0;
use constant class_y_negative => 0;

sub n_to_xy {
  my ($self, $n) = @_;
  ### HilbertMidpoint n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n, $n); }

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

  my ($x1,$y1) = $self->Math::PlanePath::HilbertCurve::n_to_xy($n);
  my ($x2,$y2) = $self->Math::PlanePath::HilbertCurve::n_to_xy($n+1);

  return ($x1 + $x2,
          $y1 + $y2);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### HilbertMidpoint xy_to_n(): "$x, $y"

  $x = _round_nearest($x);
  $y = _round_nearest($y);

  foreach my $dx (1, -1) {
    my $try_x = int(($x + $dx)/2);
    foreach my $dy (1, -1) {
      my $try_y = int(($y + $dy)/2);
      if (defined (my $n = $self->Math::PlanePath::HilbertCurve::xy_to_n($try_x,$try_y))) {
        if (my ($nx,$ny) = $self->n_to_xy($n)) {
          if ($nx == $x && $ny == $y) {
            return $n;
          }
        }
      }
    }
  }
  return undef;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### HilbertMidpoint rect_to_n_range(): "$x1,$y1  $x2,$y2"

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  return Math::PlanePath::HilbertCurve->rect_to_n_range
    (int($x1/2), int($y1/2),
     int(($x2+1)/2), int(($y2+1)/2));
}

1;
__END__

=for stopwords eg Ryde Math-PlanePath HilbertCurve HilbertMidpoint

=head1 NAME

Math::PlanePath::HilbertMidpoint -- Hilbert curve midpoints

=head1 SYNOPSIS

 use Math::PlanePath::HilbertMidpoint;
 my $path = Math::PlanePath::HilbertMidpoint->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is the midpoints of each segment of the HilbertCurve.

       |   \
    14 |    62          48----47          43----42
       |      \        /        \        /        \
    13 |       61    49          46    44          41
       |      /        \           \  /           /
    12 |    60          50          45          40
       |   /              \                    /
    11 | 59                51                39
       |  |                 |                  \
    10 |  |       55        |       33          38
       |  |      /  \       |      /  \           \
     9 | 58    56    54    52    32    34          37
       |   \  /        \  /       |      \        /
     8 |    57          53        |       35----36
       |                          |
     7 |                         31
       |                          |
     6 |     5           9        |       27----26
       |   /  \        /  \       |      /        \
     5 |  4     6     8    10    30    28          25
       |  |      \  /       |      \  /           /
     4 |  |        7        |       29          24
       |  |                 |                  /
     3 |  3                11                23
       |   \              /                    \
     2 |     2          12          17          22
       |      \        /           /  \           \
     1 |        1    13          16    18          21
       |      /        \        /        \        /
    Y=0|     0          14----15          19----20
       +----------------------------------------------
         X=0 1  2  3  4  5  6  7  8  9 10 11 12 13 14

The X,Y coordinates are kept as integers by doubling the segment lengths,

    *---5---*       *---9---*
    |       |       |       |
    4       6       8      10
    |       |       |       |
    *       *---7---*       *
    |                       |
    3                      11
    |                       |
    *---2---*       *--12---*
            |       |
            1      13
            |       |
    *---0---*       *--14---*--15--

The effect is to visit 1 of every 4 points in the first quadrant.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::HilbertMidpoint-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::HilbertCurve>,
L<Math::PlanePath::DragonMidpoint>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011, 2012 Kevin Ryde

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
