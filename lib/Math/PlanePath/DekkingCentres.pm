# Copyright 2011, 2012, 2013 Kevin Ryde

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


package Math::PlanePath::DekkingCentres;
use 5.004;
use strict;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 112;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'round_down_pow',
  'digit_split_lowtohigh',
  'digit_join_lowtohigh';

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;
use constant class_x_negative => 0;
use constant class_y_negative => 0;
*xy_is_visited = \&Math::PlanePath::Base::Generic::xy_is_visited_quad1;

use constant dx_minimum => -1;
use constant dx_maximum => 1;
use constant dy_minimum => -1;
use constant dy_maximum => 1;
use constant dsumxy_minimum => -2; # diagonals
use constant dsumxy_maximum => 2;
use constant ddiffxy_minimum => -2;
use constant ddiffxy_maximum => 2;
use constant dir_maximum_dxdy => (1,-1); # South-East


#------------------------------------------------------------------------------

# tables generated by tools/dekking-curve-table.pl
# state length 200 in each of 4 tables
use vars '@_next_state','@_digit_to_x','@_digit_to_y','@_yx_to_digit';
@_next_state = (  0,  0,175,100, 25,  # 0
                  0,175,100, 50,175,
                  0,  0,150, 25,150,
                  75, 75,100, 75,125,
                  150, 25,  0,125,125,
                  25, 25,100,125, 50,  # 25
                  25,100,125, 75,100,
                  25, 25,175, 50,175,
                  0,  0,125,  0,150,
                  175, 50, 25,150,150,
                  50, 50,125,150, 75,  # 50
                  50,125,150,  0,125,
                  50, 50,100, 75,100,
                  25, 25,150, 25,175,
                  100, 75, 50,175,175,
                  75, 75,150,175,  0,  # 75
                  75,150,175, 25,150,
                  75, 75,125,  0,125,
                  50, 50,175, 50,100,
                  125,  0, 75,100,100,
                  25, 25,100,125, 50,  # 100
                  25,175,  0,175,175,
                  50,125, 50,100,100,
                  75,150,  0, 75,100,
                  125,  0, 75,100,100,
                  50, 50,125,150, 75,  # 125
                  50,100, 25,100,100,
                  75,150, 75,125,125,
                  0,175, 25,  0,125,
                  150, 25,  0,125,125,
                  75, 75,150,175,  0,  # 150
                  75,125, 50,125,125,
                  0,175,  0,150,150,
                  25,100, 50, 25,150,
                  175, 50, 25,150,150,
                  0,  0,175,100, 25,  # 175
                  0,150, 75,150,150,
                  25,100, 25,175,175,
                  50,125, 75, 50,175,
                  100, 75, 50,175,175);
@_digit_to_x = (0,1,2,1,0, 1,2,1,0,0, 0,1,2,2,3, 4,4,3,3,2, 3,3,4,4,4,
                4,4,4,3,3, 2,2,1,2,1, 0,0,1,0,0, 0,1,1,2,3, 4,3,2,3,4,
                4,3,2,3,4, 3,2,3,4,4, 4,3,2,2,1, 0,0,1,1,2, 1,1,0,0,0,
                0,0,0,1,1, 2,2,3,2,3, 4,4,3,4,4, 4,3,3,2,1, 0,1,2,1,0,
                4,4,4,3,3, 2,3,3,4,4, 3,2,2,1,0, 0,0,1,2,1, 0,1,2,1,0,
                4,3,2,3,4, 3,2,1,1,0, 0,0,1,0,0, 1,2,1,2,2, 3,3,4,4,4,
                0,0,0,1,1, 2,1,1,0,0, 1,2,2,3,4, 4,4,3,2,3, 4,3,2,3,4,
                0,1,2,1,0, 1,2,3,3,4, 4,4,3,4,4, 3,2,3,2,2, 1,1,0,0,0);
@_digit_to_y = (0,0,0,1,1, 2,2,3,2,3, 4,4,3,4,4, 4,3,3,2,1, 0,1,2,1,0,
                0,1,2,1,0, 1,2,1,0,0, 0,1,2,2,3, 4,4,3,3,2, 3,3,4,4,4,
                4,4,4,3,3, 2,2,1,2,1, 0,0,1,0,0, 0,1,1,2,3, 4,3,2,3,4,
                4,3,2,3,4, 3,2,3,4,4, 4,3,2,2,1, 0,0,1,1,2, 1,1,0,0,0,
                0,1,2,1,0, 1,2,3,3,4, 4,4,3,4,4, 3,2,3,2,2, 1,1,0,0,0,
                4,4,4,3,3, 2,3,3,4,4, 3,2,2,1,0, 0,0,1,2,1, 0,1,2,1,0,
                4,3,2,3,4, 3,2,1,1,0, 0,0,1,0,0, 1,2,1,2,2, 3,3,4,4,4,
                0,0,0,1,1, 2,1,1,0,0, 1,2,2,3,4, 4,4,3,2,3, 4,3,2,3,4);
@_yx_to_digit = (0, 1, 2,20,24,  # 0
                 4, 3,19,21,23,
                 8, 5, 6,18,22,
                 9, 7,12,17,16,
                 10,11,13,14,15,
                 10, 9, 8, 4, 0,  # 25
                 11, 7, 5, 3, 1,
                 13,12, 6,19, 2,
                 14,17,18,21,20,
                 15,16,22,23,24,
                 15,14,13,11,10,  # 50
                 16,17,12, 7, 9,
                 22,18, 6, 5, 8,
                 23,21,19, 3, 4,
                 24,20, 2, 1, 0,
                 24,23,22,16,15,  # 75
                 20,21,18,17,14,
                 2,19, 6,12,13,
                 1, 3, 5, 7,11,
                 0, 4, 8, 9,10,
                 24,23,22, 4, 0,  # 100
                 20,21, 5, 3, 1,
                 16,19,18, 6, 2,
                 15,17,12, 7, 8,
                 14,13,11,10, 9,
                 14,15,16,20,24,  # 125
                 13,17,19,21,23,
                 11,12,18, 5,22,
                 10, 7, 6, 3, 4,
                 9, 8, 2, 1, 0,
                 9,10,11,13,14,  # 150
                 8, 7,12,17,15,
                 2, 6,18,19,16,
                 1, 3, 5,21,20,
                 0, 4,22,23,24,
                 0, 1, 2, 8, 9,  # 175
                 4, 3, 6, 7,10,
                 22, 5,18,12,11,
                 23,21,19,17,13,
                 24,20,16,15,14);

sub n_to_xy {
  my ($self, $n) = @_;
  ### DekkingCurve n_to_xy(): $n

  if ($n < 0) { return; }
  if (is_infinite($n)) { return ($n,$n); }

  my $int = int($n);
  $n -= $int;

  my @digits = digit_split_lowtohigh($int,25);
  my $state = my $dirstate = 0;
  my @x;
  my @y;
  foreach my $i (reverse 0 .. $#digits) {
    $state += $digits[$i];

    ### $state
    ### digit_to_x: $digit_to_x[$state]
    ### digit_to_y: $digit_to_y[$state]
    ### next_state: $next_state[$state]

    if ($digits[$i] != 24) {   # lowest non-24 digit
      $dirstate = $state;
    }
    $x[$i] = $_digit_to_x[$state];
    $y[$i] = $_digit_to_y[$state];
    $state = $_next_state[$state];
  }

  my $zero = $int * 0;
  return ($n * ($_digit_to_x[$dirstate+1] - $_digit_to_x[$dirstate])
          + digit_join_lowtohigh(\@x, 5, $zero),

          $n * ($_digit_to_y[$dirstate+1] - $_digit_to_y[$dirstate])
          + digit_join_lowtohigh(\@y, 5, $zero));
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### DekkingCurve xy_to_n(): "$x, $y"

  $x = round_nearest ($x);
  $y = round_nearest ($y);
  if ($x < 0 || $y < 0) {
    return undef;
  }
  if (is_infinite($x)) {
    return $x;
  }
  if (is_infinite($y)) {
    return $y;
  }

  my @x = digit_split_lowtohigh($x,5);
  my @y = digit_split_lowtohigh($y,5);
  ### @x
  ### @y

  my $state = 0;
  my @n;

  foreach my $i (reverse 0 .. max($#x,$#y)) {
    my $digit = $n[$i] = $_yx_to_digit[$state + 5*($y[$i]||0) + ($x[$i]||0)];
    $state = $_next_state[$state+$digit];
  }

  return digit_join_lowtohigh(\@n, 25, $x*0*$y); # preserve bignum
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### DekkingCurve rect_to_n_range(): "$x1,$y1, $x2,$y2"

  $x1 = round_nearest ($x1);
  $x2 = round_nearest ($x2);
  $y1 = round_nearest ($y1);
  $y2 = round_nearest ($y2);

  $x2 = max($x1,$x2);
  $y2 = max($y1,$y2);

  if ($x2 < 0 || $y2 < 0) {
    ### rectangle all negative, no N values ...
    return (1, 0);
  }

  my ($pow, $level) = round_down_pow (max($x2,$y2), 5);
  ### $pow
  ### $level
  return (0, 25*$pow*$pow-1);
}

1;
__END__

=for stopwords eg Ryde ie Math-PlanePath Dekking

=head1 NAME

Math::PlanePath::DekkingCentres -- 5x5 self-similar

=head1 SYNOPSIS

 use Math::PlanePath::DekkingCentres;
 my $path = Math::PlanePath::DekkingCentres->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is a variation of a 5x5 self-similar curve by F. M. Dekking.  This form
visits the "centres" of the 5x5 self-similar blocks.  The result is diagonal
steps, but replications wholly within 5x5 areas.

=cut

# math-image --path=DekkingCentres --all --output=numbers_dash --size=75x26

=pod

                              ...
        |                     /
      9 |  115-116 122-123-124  89--88  86--85--84
        |    |   |    \          |    \  |       |
      8 |  114 117-118 121-120  90  92  87  82--83
        |    |        \   /      |/   \      |
      7 |  113-112 106 119 102  91  94--93  81  77
        |     /   /  |    /  |    /       /   /  |
      6 |  111 107 105 103 101  95--96  80  78  76
        |    |    \   \  |   |        \   \  |   |
      5 |  110-109-108 104 100--99--98--97  79  75
        |                                         \
      4 |   10--11  13--14--15  35--36  38--39--40  74  70  66--65--64
        |    |    \  |       |   |    \  |       |   |   |\   \      |
      3 |    9   7  12  17--16  34  32  37  42--41  73  71  69  67  63
        |    |/   \      |       |/   \      |       |/      |/   /
      2 |    8   5-- 6  18  22  33  30--31  43  47  72  55  68  62--61
        |      /      /   /  |    /       /   /  |    /   \          |
      1 |    4-- 3  19  21  23  29--28  44  46  48  54--53  56--57  60
        |         \   \  |   |        \   \  |   |        \      |   |
    Y=0 |    0-- 1-- 2  20  24--25--26--27  45  49--50--51--52  58--59
        +---------------------------------------------------------------
           X=0   1   2   3   4   5   6   7   8   9  10  11  12  13  14

The base pattern is the N=0 to N=24 section.  It repeats with rotations or
reversals which make the ends join.  For example N=75 to N=99 is the base
pattern in reverse.  Or N=50 to N=74 is reverse and also rotate by -90.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> the behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::DekkingCentres-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DekkingCurve>,
L<Math::PlanePath::CincoCurve>,
L<Math::PlanePath::PeanoCurve>

=head1 HOME PAGE

L<http://user42.tuxfamily.org/math-planepath/index.html>

=head1 LICENSE

Copyright 2011, 2012, 2013 Kevin Ryde

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
