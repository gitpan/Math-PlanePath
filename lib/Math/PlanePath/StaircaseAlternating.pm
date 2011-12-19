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


package Math::PlanePath::StaircaseAlternating;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 61;
use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_round_nearest = \&Math::PlanePath::_round_nearest;


use constant x_negative => 0;
use constant y_negative => 0;

sub n_to_xy {
  my ($self, $n) = @_;
  #### StaircaseAlternating n_to_xy: $n

  if (2*$n < 1) { return; }

  my $d = int ((1 + sqrt(int(8*$n-3))) / 4);
  $n -= (2*$d - 1)*$d;
  ### rem: $n

  my $int = int($n);
  my $frac = $n - $int;
  my $r = int($int/2);

  my ($x,$y);
  if ($int % 2) {
    ### down ...
    $x = $r;
    $y = -$frac + 2*$d - $r;
  } else {
    ### across ...
    $x = $frac + $r-1;
    $y = 2*$d - $r;
  }

  if ($d % 2) {
    return ($x,$y);
  } else {
    return ($y,$x);
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### StaircaseAlternating xy_to_n(): "$x,$y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($x < 0 || $y < 0) {
    return undef;
  }

  my $d = int(($x + $y + 1) / 2);
  if ($d % 2) {
    return (2*$d + 1)*$d + 1 - $y + $x;
  } else {
    return (2*$d + 1)*$d + 1 + $y - $x;
  }
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### StaircaseAlternating rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);
  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }  # x2 > x1
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }  # y2 > y1

  if ($x2 < 0 || $y2 < 0) {
    return (1, 0);   # nothing in first quadrant
  }

  $x2 += $y2 + 2;
  return (1,
          $x2*($x2+1)/2);
}

1;
__END__

=for stopwords SquareSpiral eg StaircaseAlternating PlanePath Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::StaircaseAlternating -- stair-step diagonals up and down

=head1 SYNOPSIS

 use Math::PlanePath::StaircaseAlternating;
 my $path = Math::PlanePath::StaircaseAlternating->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes a staircase pattern up from Y axis down to the X and then
back up again.

    10       46
              |
     9       47--48
                  |
     8       45  49--50
              |       |
     7       44--43  51--52
                  |       |
     6       16  42--41  53--54
              |       |       |
     5       17--18  40--39  55--...
                  |       |
     4       15  19--20  38--37
              |       |       |
     3       14--13  21--22  36--35
                  |       |       |
     2        2  12--11  23--24  34--33
              |       |       |       |
     1        3-- 4  10-- 9  25--26  32--31
                  |       |       |       |
    Y=0 ->    1   5-- 6   8-- 7  27--28  30--29

              ^
             X=0  1   2   3   4   5   6   7   8

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::StaircaseAlternating-E<gt>new ()>

Create and return a new staircase path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::Staircase>,
L<Math::PlanePath::DiagonalsAlternating>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011 Kevin Ryde

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
# compile-command: "math-image --path=StaircaseAlternating --lines --scale=20"
# End:
#
# math-image --path=StaircaseAlternating --all --output=numbers_dash --size=70x30
