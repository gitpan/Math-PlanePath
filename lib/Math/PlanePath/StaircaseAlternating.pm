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



# math-image --path=StaircaseAlternating --all --output=numbers_dash --size=70x30
# math-image --path=StaircaseAlternating,end_type=square --all --output=numbers_dash --size=70x30

package Math::PlanePath::StaircaseAlternating;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 87;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use Math::PlanePath::Base::Generic
  'round_nearest';

# uncomment this to run the ### lines
#use Smart::Comments;


use constant class_x_negative => 0;
use constant class_y_negative => 0;

my %n_frac_discontinuity = (jump => .5);
sub n_frac_discontinuity {
  my ($self) = @_;
  return $n_frac_discontinuity{$self->{'end_type'}};
}

sub new {
  my $self = shift->SUPER::new(@_);
  $self->{'end_type'} ||= 'jump';
  return $self;
}


# --16
#    |
#   17--18
#        |
# --15  19--20
#    |       |
#   14--13  21--22
#        |       |
#  --2  12--11  23--24  34--33
#    |       |       |       |
#    3-- 4  10-- 9  25--26  32--31
#        |       |       |       |
#  --1   5-- 6   8-- 7  27--28  30--29

# 17
#  |\
# 16 18
#  |  |
# 15 19-20
#  |     |
# 14-13 21-22
#     |     |
#  3 12-11 23-24 34-33
#  |\    |     |     |
#  2  4 10--9 25-26 32-31
#  |  |      \   |       \
#  1  5--6--7--8 27-28-29-30

#  .
#
# 42-43
#  |  |
# 41 44-45
#  |     |
# 40-39 46-47
#     |     |
#  . 38-37 48-
#        |
# 14-15 35-36
#  |  |     |
# 13 16-17 34-33
#  |     |     |
# 12-11 18-19 32-31
#     |     |     |
#  . 10--9 20-21 30-29
#        |     |     |
#  2--3  8--7 22-23 28-27
#  |  |     |    |      |
#  1  4--5--6  . 24-25-26  .
#
# start from integer vertical
# d = [ 2,  3,  4, 5 ]
# N = [ 5, 13, 25, 41 ]
# N = (2 d^2 - 2 d + 1)
#   = ((2*$d - 2)*$d + 1)
# d = 1/2 + sqrt(1/2 * $n + -1/4)
#   = (1 + sqrt(2*$n - 1)) / 2
#

sub n_to_xy {
  my ($self, $n) = @_;
  #### StaircaseAlternating n_to_xy: $n

  my $d;
  if ($self->{'end_type'} eq 'square') {
    if ($n < 1) { return; }

    $d = int ((1 + sqrt(int(2*$n-1))) / 2);
    $n -= (2*$d - 2)*$d;
    ### $d
    ### remainder n: $n

    if ($n < 2) {
      if ($d % 2) {
        return (0, $n+2*$d-3);
      } else {
        return ($n+2*$d-3, 0);
      }
    }

  } else {
    if (2*$n < 1) { return; }

    $d = int ((1 + sqrt(int(8*$n-3))) / 4);
    $n -= (2*$d - 1)*$d;
    ### rem: $n
  }

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

  $x = round_nearest ($x);
  $y = round_nearest ($y);
  if ($x < 0 || $y < 0) {
    return undef;
  }

  my $jump = ($self->{'end_type'} ne 'square');
  unless ($jump) {
    # square omitted endpoints
    if ($x == 0) {
      if (($y % 4) == 2) {
        return undef;
      }
    } elsif ($y == 0 && ($x % 4) == 0) {
      return undef;
    }
  }

  my $d = int(($x + $y + 1) / 2);
  return ((2*$d + $jump) * $d + 1
          + ($d % 2
             ? $x - $y
             : $y - $x));
}

# 12--11  18--19      14--13  21--22
#      |       |           |       |
#  .  10-- 9  20       2  12--11  23
#          |           |       |
#  2-- 3   8-- 7       3-- 4  10-- 9
#  |   |       |           |       |
#  1   4-- 5-- 6       1   5-- 6   8
#
my @yx_to_min_dx = (0, 0, 0, -1,
                    0, 0, 1, 0,
                    0, 1, 0, 0,
                    1, 0, 0, 0);
my @yx_to_min_dy = (0, 1, 0, 0,
                    -1, 0, 0, 0,
                    0, 0, 0, 1,
                    0, 0, 1, 0);

my @yx_to_max_dx = (1, 0, 0, 0,
                    0, 0, 0, 1,
                    0, 0, 1, 0,
                    0, 1, 0, 0);
my @yx_to_max_dy = (0, 0, 1, 0,
                    0, 1, 0, 0,
                    1, 0, 0, 0,
                    0, 0, 0, 1);

# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### StaircaseAlternating rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = round_nearest ($x1);
  $y1 = round_nearest ($y1);
  $x2 = round_nearest ($x2);
  $y2 = round_nearest ($y2);
  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }  # x2 > x1
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }  # y2 > y1

  if ($x2 < 0 || $y2 < 0) {
    ### entirely outside first quadrant ...
    return (1, 0);
  }

  # not less than 0,0
  if ($x1 < 0) { $x1 *= 0; }
  if ($y1 < 0) { $y1 *= 0; }

  my $corner_x1 = $x1;
  my $corner_y1 = $y1;
  my $corner_x2 = $x2;
  my $corner_y2 = $y2;
  {
    my $key = 4*($y2 % 4) + ($x2 % 4);
    if ($x2 > $x1 && $yx_to_max_dx[$key]) {
      $corner_x2 -= 1;
    } elsif ($y2 > 0 && $y2 > $y1) {
      $corner_y2 -= $yx_to_max_dy[$key];
    }
  }

  my $square = ($self->{'end_type'} eq 'square');
  if ($square && $x1 == 0 && ($y1 % 4) == 2) {
    ### x1,y1 is an omitted Y axis point ...
    if ($corner_x1 < $x2) {
      $corner_x1 += 1;
    } elsif ($corner_y1 < $y2) {
      $corner_y1 += 1;
    } else {
      ### only this point ...
      return (1, 0);
    }

  } elsif ($square && $y1 == 0 && $x1 > 0 && ($x1 % 4) == 0) {
    if ($corner_y1 < $y2) {
      $corner_y1 += 1;
    } elsif ($corner_x1 < $x2) {
      $corner_x1 += 1;
    } else {
      ### only an omitted X axis point ...
      return (1, 0);
    }

  }
  {
    my $key = 4*($corner_y1 % 4) + ($corner_x1 % 4);
    ### min key: $key
    if ($corner_x1 < $x2 && (my $dx = $yx_to_min_dx[$key])) {
      ### x1 incr ...
      unless ($square && $dx < 0 && $corner_y1 == 0) {
        $corner_x1 += 1;
      }
    } elsif ($corner_y1 < $y2 && (my $dy = $yx_to_min_dy[$key])) {
      ### y1 incr ...
      unless ($square && $dy < 0 && $corner_x1 == 0) {
        $corner_y1 += 1;
      }
    }
  }

  ### corners: "$x1,$y1  $x2,$y2"

  return ($self->xy_to_n($corner_x1,$corner_y1),
          $self->xy_to_n($corner_x2,$corner_y2));
}

# inexact but easier ...
#
# if ($self->{'end_type'} eq 'square') {
#   $x2 += $y2 + 1;
#   $x2 = int($x2/2);
#   return (1,
#           (2*$x2+2)*$x2 + 1);
# } else {
#   $x2 += $y2 + 2;
#   return (1,
#           $x2*($x2+1)/2);
# }

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

=head2 Square Ends

Option C<end_type =E<gt> "square"> changes the path as follows, omitting one
point at each end so as to square up the joins.


     9       42--43
              |   |
     8       41  44--45
              |       |
     7       40--39  46--47
                  |       |
     6        .  38--37  48--49
                      |       |
     5       14--15  36--35  50--...
              |   |       |
     4       13  16--17  34--33
              |       |       |
     3       12--11  18--19  32--31
                  |       |       |
     2        .  10-- 9  20--21  30--29
                      |       |       |
     1        2-- 3   8-- 7  22--23  28--27
              |   |       |       |       |
    Y=0 ->    1   4-- 5-- 6   .  24--25--26

              ^
             X=0  1   2   3   4   5   6   7   8

The effect is to shorten each diagonal by a constant 1 each time.  The
lengths of each diagonal still grow by +4 each time (or by +16 up and back).

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::StaircaseAlternating-E<gt>new ()>

Create and return a new path object.

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

Copyright 2011, 2012 Kevin Ryde

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
