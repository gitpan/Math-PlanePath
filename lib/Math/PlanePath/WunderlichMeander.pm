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


package Math::PlanePath::WunderlichMeander;
use 5.004;
use strict;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 92;
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


#------------------------------------------------------------------------------

# tables generated by tools/wunderlich-meander-table.pl
#
my @next_state = (18,18, 0,  0, 0, 9, 27,27, 0,    # 0
                  27,27, 9,  9, 9, 0, 18,18, 9,    # 9
                   0, 0,18, 18,18,27,  9, 9,18,    # 18
                   9, 9,27, 27,27,18,  0, 0,27);   # 27
my @digit_to_x = (0,1,2, 2,2,1, 1,0,0,    # 0
                  2,1,0, 0,0,1, 1,2,2,    # 9
                  0,0,0, 1,2,2, 1,1,2,    # 18
                  2,2,2, 1,0,0, 1,1,0);   # 27
my @digit_to_y = (0,0,0, 1,2,2, 1,1,2,    # 0
                  2,2,2, 1,0,0, 1,1,0,    # 9
                  0,1,2, 2,2,1, 1,0,0,    # 18
                  2,1,0, 0,0,1, 1,2,2);   # 27
my @xy_to_digit = (0,7,8, 1,6,5, 2,3,4,    # 0
                   4,3,2, 5,6,1, 8,7,0,    # 9
                   0,1,2, 7,6,3, 8,5,4,    # 18
                   4,5,8, 3,6,7, 2,1,0);   # 27
my @min_digit = (0,0,0,1,2,1,    # 0
                 0,0,0,1,2,1,
                 0,0,0,1,2,1,
                 7,5,3,3,3,5,
                 8,5,4,4,4,5,
                 7,6,3,3,3,6,
                 4,4,4,5,8,5,    # 36
                 3,3,3,5,7,5,
                 2,1,0,0,0,1,
                 2,1,0,0,0,1,
                 2,1,0,0,0,1,
                 3,3,3,6,7,6,
                 0,0,0,7,8,7,    # 72
                 0,0,0,5,5,6,
                 0,0,0,3,4,3,
                 1,1,1,3,4,3,
                 2,2,2,3,4,3,
                 1,1,1,5,5,6,
                 4,3,2,2,2,3,    # 108
                 4,3,1,1,1,3,
                 4,3,0,0,0,3,
                 5,5,0,0,0,6,
                 8,7,0,0,0,7,
                 5,5,1,1,1,6);
my @max_digit = (0,1,2,2,2,1,    # 0
                 7,7,7,6,3,6,
                 8,8,8,6,4,6,
                 8,8,8,6,4,6,
                 8,8,8,5,4,5,
                 7,7,7,6,3,6,
                 4,5,8,8,8,5,    # 36
                 4,6,8,8,8,6,
                 4,6,8,8,8,6,
                 3,6,7,7,7,6,
                 2,2,2,1,0,1,
                 3,6,7,7,7,6,
                 0,7,8,8,8,7,    # 72
                 1,7,8,8,8,7,
                 2,7,8,8,8,7,
                 2,6,6,6,5,6,
                 2,3,4,4,4,3,
                 1,6,6,6,5,6,
                 4,4,4,3,2,3,    # 108
                 5,6,6,6,2,6,
                 8,8,8,7,2,7,
                 8,8,8,7,1,7,
                 8,8,8,7,0,7,
                 5,6,6,6,1,6);

sub n_to_xy {
  my ($self, $n) = @_;
  ### WunderlichMeander n_to_xy(): $n

  if ($n < 0) { return; }
  if (is_infinite($n)) { return ($n,$n); }

  {
    # ENHANCE-ME: determine dx/dy direction from last state, not full
    # calculation of N+1
    my $int = int($n);
    if ($n != $int) {
      my $frac = $n - $int;  # inherit possible BigFloat/BigRat
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int;
  }

  my @digits = digit_split_lowtohigh($n,9);
  my $len = ($n*0 + 3) ** scalar(@digits);   # inherit bignum 3

  ### digits: join(', ',@digits)."   count ".scalar(@digits)
  ### $len

  my $state = ($#digits & 1 ? 18 : 0);
  my $x = 0;
  my $y = 0;

  while (@digits) {
    $len /= 3;
    $state += pop @digits;  # high to low

    ### $len
    ### $state
    ### digit_to_x: $digit_to_x[$state]
    ### digit_to_y: $digit_to_y[$state]
    ### next_state: $next_state[$state]

    $x += $len * $digit_to_x[$state];
    $y += $len * $digit_to_y[$state];
    $state = $next_state[$state];
  }

  ### final: "$x,$y"
  return ($x, $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### WunderlichMeander xy_to_n(): "$x, $y"

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

  my @xdigits = digit_split_lowtohigh ($x, 3);
  my @ydigits = digit_split_lowtohigh ($y, 3);
  my $level = max($#xdigits,$#ydigits);
  my $state = ($level & 1 ? 18 : 0);
  my @ndigits;
  foreach my $i (reverse 0 .. $level) {  # high to low
    my $ndigit = $xy_to_digit[$state
                              + 3*($xdigits[$i]||0)
                              + ($ydigits[$i]||0)];
    $ndigits[$i] = $ndigit;
    $state = $next_state[$state+$ndigit];
  }

  return digit_join_lowtohigh (\@ndigits, 9,
                               $x * 0 * $y); # bignum zero
}

# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### WunderlichMeander rect_to_n_range(): "$x1,$y1, $x2,$y2"

  $x1 = round_nearest ($x1);
  $x2 = round_nearest ($x2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;

  $y1 = round_nearest ($y1);
  $y2 = round_nearest ($y2);
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  if ($x2 < 0 || $y2 < 0) {
    return (1, 0);
  }

  my ($len, $level) = round_down_pow (max($x2,$y2), 3);
  ### $len
  ### $level
  if (is_infinite($level)) {
    return (0, $level);
  }

  my $n_min = my $n_max
    = my $x_min = my $y_min
      = my $x_max = my $y_max
        = ($x1 * 0 * $x2 * $y1 * $y2); # inherit bignum 0

  my $min_state
    = my $max_state
      = ($level & 1 ? 18 : 0);

  # x__  0
  # xx_  1
  # xxx  2
  # _xx  3
  # __x  4
  # _x_  5
  #
  while ($level >= 0) {
    my $l2 = 2*$len;
    {
      my $x_cmp1 = $x_min + $len;
      my $y_cmp1 = $y_min + $len;
      my $x_cmp2 = $x_min + $l2;
      my $y_cmp2 = $y_min + $l2;
      my $digit = $min_digit[4*$min_state  # 4*9=36 apart
                             + ($x1 >= $x_cmp2 ? 4
                                : $x1 >= $x_cmp1 ? ($x2 < $x_cmp2 ? 5 : 3)
                                : ($x2 < $x_cmp1 ? 0
                                   : $x2 < $x_cmp2 ? 1 : 2))
                             + ($y1 >= $y_cmp2 ? 6*4
                                : $y1 >= $y_cmp1 ? ($y2 < $y_cmp2 ? 6*5 : 6*3)
                                : ($y2 < $y_cmp1 ? 6*0
                                   : $y2 < $y_cmp2 ? 6*1 : 6*2))];

      # my $key = 4*$min_state  # 4*9=36 apart
      #   + ($x1 >= $x_cmp2 ? 4
      #      : $x1 >= $x_cmp1 ? ($x2 < $x_cmp2 ? 5 : 3)
      #      : ($x2 < $x_cmp1 ? 0
      #         : $x2 < $x_cmp2 ? 1 : 2))
      #     + ($y1 >= $y_cmp2 ? 6*4
      #        : $y1 >= $y_cmp1 ? ($y2 < $y_cmp2 ? 6*5 : 6*3)
      #        : ($y2 < $y_cmp1 ? 6*0
      #           : $y2 < $y_cmp2 ? 6*1 : 6*2));
      # ### $min_state
      # ### $len
      # ### $l2
      # ### $key
      # ### $x_cmp1
      # ### $x_cmp2
      # ### $digit


      $n_min = 9*$n_min + $digit;
      $min_state += $digit;
      $x_min += $len * $digit_to_x[$min_state];
      $y_min += $len * $digit_to_y[$min_state];
      $min_state = $next_state[$min_state];
    }
    {
      my $x_cmp1 = $x_max + $len;
      my $y_cmp1 = $y_max + $len;
      my $x_cmp2 = $x_max + $l2;
      my $y_cmp2 = $y_max + $l2;
      my $digit = $max_digit[4*$max_state  # 4*9=36 apart
                             + ($x1 >= $x_cmp2 ? 4
                                : $x1 >= $x_cmp1 ? ($x2 < $x_cmp2 ? 5 : 3)
                                : ($x2 < $x_cmp1 ? 0
                                   : $x2 < $x_cmp2 ? 1 : 2))
                             + ($y1 >= $y_cmp2 ? 6*4
                                : $y1 >= $y_cmp1 ? ($y2 < $y_cmp2 ? 6*5 : 6*3)
                                : ($y2 < $y_cmp1 ? 6*0
                                   : $y2 < $y_cmp2 ? 6*1 : 6*2))];

      # my $key = 4*$max_state  # 4*9=36 apart
      #   + ($x1 >= $x_cmp2 ? 4
      #      : $x1 >= $x_cmp1 ? ($x2 < $x_cmp2 ? 5 : 3)
      #      : ($x2 < $x_cmp1 ? 0
      #         : $x2 < $x_cmp2 ? 1 : 2))
      #     + ($y1 >= $y_cmp2 ? 4
      #        : $y1 >= $y_cmp1 ? ($y2 < $y_cmp2 ? 5 : 3)
      #        : ($y2 < $y_cmp1 ? 0
      #           : $y2 < $y_cmp2 ? 1 : 2));
      # ### $max_state
      # ### $len
      # ### $l2
      # ### $x_key
      # ### $key
      # ### $x_max
      # ### $y_max
      # ### $x_cmp1
      # ### $x_cmp2
      # ### $y_cmp1
      # ### $y_cmp2
      # ### $digit
      # ### max digit: $max_digit[$key]

      $n_max = 9*$n_max + $digit;
      $max_state += $digit;
      $x_max += $len * $digit_to_x[$max_state];
      $y_max += $len * $digit_to_y[$max_state];
      $max_state = $next_state[$max_state];
    }

    $len = int($len/3);
    $level--;
  }
  return ($n_min, $n_max);
}

1;
__END__

=for stopwords eg Ryde ie WunderlichMeander Math-PlanePath Wunderlich PeanoCurve Wunderlich's Uber Peano-Kurven Elemente der Mathematik PlanePath

=head1 NAME

Math::PlanePath::WunderlichMeander -- 3x3 self-similar "R" shape

=head1 SYNOPSIS

 use Math::PlanePath::WunderlichMeander;
 my $path = Math::PlanePath::WunderlichMeander->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

X<Wunderlich, Walter>This is an integer version of the 3x3 self-similar
meander by Walter Wunderlich,

      8     20--21--22  29--30--31  38--39--40
             |       |   |       |   |       |
      7     19  24--23  28  33--32  37  42--41
             |   |       |   |       |   |
      6     18  25--26--27  34--35--36  43--44
             |                               |
      5     17  14--13  56--55--54--53--52  45
             |   |   |   |               |   |
      4     16--15  12  57  60--61  50--51  46
                     |   |   |   |   |       |
      3      9--10--11  58--59  62  49--48--47
             |                   |
      2      8   5-- 4  65--64--63  74--75--76
             |   |   |   |           |       |
      1      7-- 6   3  66  69--70  73  78--77
                     |   |   |   |   |   |
    Y=0->    0-- 1-- 2  67--68  71--72  79--80-...

            X=0  1   2   3   4   5   6   7   8

The base pattern is the N=0 to N=8 section.  It works as a traversal of a
3x3 square going from one corner along one side.  The base figure goes
upwards and it's then used rotated by 180 degrees and/or transposed to go in
other directions,

    +----------------+----------------+---------------+
    | ^              |              * | ^             |
    | |              |  rotate 180  | | |   base      |
    | |     8        |       5      | | |     4       |
    | |   base       |              | | |             |
    | *              |              v | *             |
    +----------------+----------------+---------------+
    | <------------* | <------------* | ^             |
    |                |                | |             |
    |       7        |       6        | |     3       |
    |   rotate 180   |   rotate 180   | |   base      |
    |  + transpose   |  + transpose   | *             |
    +----------------+----------------+---------------+
    |                |                | ^             |
    |                |                | |             |
    |       0        |       1        | |     2       |
    |   transpose    |   transpose    | |   base      |
    | *----------->  | *------------> | *             |
    +----------------+----------------+---------------+

The base 0 to 8 goes upwards, so the across sub-parts are an X,Y transpose.
The transpose in the 0 part means the higher levels go alternately up or
across.  So N=0 to N=8 goes up, then the next level N=0,9,18,.,72 goes
right, then N=81,162,..,648 up again, etc.

Wunderlich's conception is successive lower levels of detail as a
space-filling curve and the transposing in that case applies to ever smaller
parts.  But for the integer version here the start direction is fixed and
the successively higher levels alternate.  The first move N=0 to N=1 is
rightwards per the "Schema" shown in Wunderlich's paper (and which is
similar to the PeanoCurve and various other PlanePath curves).

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::WunderlichMeander-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

The returned range is exact, meaning C<$n_lo> and C<$n_hi> are the smallest
and biggest in the rectangle.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PeanoCurve>

Walter Wunderlich "Uber Peano-Kurven", Elemente der Mathematik, 28(1):1-10,
1973.

    http://sodwana.uni-ak.ac.at/geom/mitarbeiter/wallner/wunderlich/
    http://sodwana.uni-ak.ac.at/geom/mitarbeiter/wallner/wunderlich/pdf/125.pdf
    (scanned copy, in German)

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


# Local variables:
# compile-command: "math-image --path=WunderlichMeander --lines --scale=20"
# End:
#
# math-image --path=WunderlichMeander --all --output=numbers_dash
