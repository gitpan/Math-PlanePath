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


package Math::PlanePath::DekkingCurve;
use 5.004;
use strict;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 97;
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

use constant dx_minimum => -1;
use constant dx_maximum => 1;
use constant dy_minimum => -1;
use constant dy_maximum => 1;


#------------------------------------------------------------------------------

use Math::PlanePath::DekkingCentres;
use vars '@_next_state','@_digit_to_x','@_digit_to_y','@_yx_to_digit';
BEGIN {
  *_next_state = \@Math::PlanePath::DekkingCentres::_next_state;
  *_digit_to_x = \@Math::PlanePath::DekkingCentres::_digit_to_x;
  *_digit_to_y = \@Math::PlanePath::DekkingCentres::_digit_to_y;
  *_yx_to_digit = \@Math::PlanePath::DekkingCentres::_yx_to_digit;
}

# tables generated by tools/dekking-curve-table.pl
#
my @edge_dx = (0,0,0,1,1, 0,0,1,1,0, 0,0,0,1,0, 0,0,1,0,1, 0,1,0,1,1,
               1,1,1,1,1, 1,1,1,0,1, 1,1,0,1,0, 0,0,1,0,0, 0,1,1,0,0,
               1,1,1,0,0, 1,1,0,0,1, 1,1,1,0,1, 1,1,0,1,0, 1,0,1,0,0,
               0,0,0,0,0, 0,0,0,1,0, 0,0,1,0,1, 1,1,0,1,1, 1,0,0,1,1,
               1,1,1,1,1, 1,0,0,0,0, 1,1,1,1,1, 0,0,0,0,1, 1,0,0,1,1,
               1,1,1,0,0, 1,1,1,1,1, 0,0,0,1,1, 0,0,1,0,1, 0,1,0,1,1,
               0,0,0,0,0, 0,1,1,1,1, 0,0,0,0,0, 1,1,1,1,0, 0,1,1,0,0,
               0,0,0,1,1, 0,0,0,0,0, 1,1,1,0,0, 1,1,0,1,0, 1,0,1,0,0);
my @edge_dy = (0,0,0,0,0, 0,0,0,1,0, 0,0,1,0,1, 1,1,0,1,1, 1,0,0,1,1,
               0,0,0,1,1, 0,0,1,1,0, 0,0,0,1,0, 0,0,1,0,1, 0,1,0,1,1,
               1,1,1,1,1, 1,1,1,0,1, 1,1,0,1,0, 0,0,1,0,0, 0,1,1,0,0,
               1,1,1,0,0, 1,1,0,0,1, 1,1,1,0,1, 1,1,0,1,0, 1,0,1,0,0,
               0,0,0,1,1, 0,0,0,0,0, 1,1,1,0,0, 1,1,0,1,0, 1,0,1,0,0,
               1,1,1,1,1, 1,0,0,0,0, 1,1,1,1,1, 0,0,0,0,1, 1,0,0,1,1,
               1,1,1,0,0, 1,1,1,1,1, 0,0,0,1,1, 0,0,1,0,1, 0,1,0,1,1,
               0,0,0,0,0, 0,1,1,1,1, 0,0,0,0,0, 1,1,1,1,0, 0,1,1,0,0);

sub n_to_xy {
  my ($self, $n) = @_;
  ### DekkingCurve n_to_xy(): $n

  if ($n < 0) { return; }
  if (is_infinite($n)) { return ($n,$n); }

  my $int = int($n);
  $n -= $int;

  my @digits = digit_split_lowtohigh($int,25);
  my $state = 0;
  my @x;
  my @y;
  foreach my $i (reverse 0 .. $#digits) {
    $state += $digits[$i];
    $x[$i] = $_digit_to_x[$state];
    $y[$i] = $_digit_to_y[$state];
    $state = $_next_state[$state];
  }

  ### @x
  ### @y
  ### $state
  ### dx: $_digit_to_x[$state+24] - $_digit_to_x[$state]
  ### dy: $_digit_to_y[$state+24] - $_digit_to_y[$state]

  my $zero = $int * 0;
  return ($n * (($_digit_to_x[$state+24] - $_digit_to_x[$state])/4)
          + digit_join_lowtohigh(\@x, 5, $zero)
          + $edge_dx[$state],

          $n * (($_digit_to_y[$state+24] - $_digit_to_y[$state])/4)
          + digit_join_lowtohigh(\@y, 5, $zero)
          + $edge_dy[$state]);
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

  foreach my $xoffset (0,-1) {
    foreach my $yoffset (0,-1) {

      my @x = digit_split_lowtohigh($x+$xoffset,5);
      my @y = digit_split_lowtohigh($y+$yoffset,5);
      my $state = 0;
      my @n;
      foreach my $i (reverse 0 .. max($#x,$#y)) {
        my $digit = $n[$i] = $_yx_to_digit[$state + 5*($y[$i]||0) + ($x[$i]||0)];
        $state = $_next_state[$state+$digit];
      }
      my $n = digit_join_lowtohigh(\@n, 25, $x*0*$y);
      my ($nx,$ny) = $self->n_to_xy($n);
      if ($nx == $x && $ny == $y) {
        return $n;
      }
    }
  }
  return undef;
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

  my ($pow) = round_down_pow (max($x2,$y2)+1, 5);
  ### $pow
  ### $level
  return (0, 25*$pow*$pow-1);
}

1;
__END__

=for stopwords eg Ryde ie DekkingCurve Math-PlanePath Dekking

=head1 NAME

Math::PlanePath::DekkingCurve -- 5x5 self-similar edge curve

=head1 SYNOPSIS

 use Math::PlanePath::DekkingCurve;
 my $path = Math::PlanePath::DekkingCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is an integer version of a 5x5 self-similar curve by Dekking,

=cut

# math-image --path=DekkingCurve --all --output=numbers_dash --size=78x30

=pod

     10 |             123-124-125-...      86--85
        |               |                   |   |
      9 | 115-116-117 122-121  90--89--88--87  84
        |   |       |       |   |               |
      8 | 114-113 118-119-120  91--92--93  82--83
        |       |                       |   |         
      7 |     112 107-106 103-102  95--94  81  78--77 
        |       |   |   |   |   |   |       |   |   | 
      6 |     111 108 105-104 101  96--97  80--79  76 
        |       |   |           |       |           | 
      5 |     110-109  14--15 100--99--98  39--40  75          66--65
        |               |   |               |   |   |           |   |
      4 |  10--11--12--13  16  35--36--37--38  41  74  71--70  67  64
        |   |               |   |               |   |   |   |   |   |
      3 |   9---8---7  18--17  34--33--32  43--42  73--72  69--68  63
        |           |   |               |   |                       |
      2 |       5---6  19  22--23  30--31  44  47--48  55--56--57  62--61 
        |       |       |   |   |   |       |   |   |   |       |       | 
      1 |       4---3  20--21  24  29--28  45--46  49  54--53  58--59--60 
        |           |           |       |           |       |             
    Y=0 |   0---1---2          25--26--27          50--51--52             
        +----------------------------------------------------------------
          X=0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15

The base pattern is the N=0 to N=25 section.  It then repeats with rotations
or reversals which make the ends join.  For example N=75 to N=100 is the
base pattern in reverse, ie. from N=25 down to N=0.  Or N=50 to N=75 is
reverse and also rotate by -90.

The curve segments are edges of squares in a 5x5 arrangement.

     +- - -+- - -+- - 14----15  ---+
     |     |     |     |  v  |>    |
        ^     ^       <|     |      
    10----11----12----13- - 16   --+
     |              v        |>    |
     |>       ^           ^  |      
     9-----8-----7 -- 18----17   --+
        v  |     |     |>          |
     |        ^  |>    |        ^   
     +- -  5-----6 -  19    22----23
           |          <|     |    <|
     |    <|  ^        |    <|     |
     +- -  4-----3    20----21 -- 24
                 |       v        <|
        ^     ^  |>    |     |     |
     0-----1-----2  -- + -- -+-   25

The little notch marks show which square each edge represents.  This is the
side the curve expands into at the next level.  For example N=1 to N=2 has
its notch on the left so the next level N=25 to N=50 expands on the left.

An expansion on the left is a repeat of the base shape, possibly rotated 90,
180 or 270 degrees.  An expansion on the right is the base shape in reverse,
as for example N=2 to N=3 on the right becomes N=50 to N=75 traversing to
the right at the next level.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::DekkingCurve-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DekkingCentres>,
L<Math::PlanePath::PeanoCurve>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

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
