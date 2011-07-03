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


# http://www.cut-the-knot.org/Curriculum/Geometry/PeanoComplete.shtml
#     Java applet, directions in 9 sub-parts
#

package Math::PlanePath::PeanoCurve;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX qw(floor ceil);

use vars '$VERSION', '@ISA';
$VERSION = 33;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;

use constant n_start => 0;
use constant x_negative => 0;
use constant y_negative => 0;

sub n_to_xy {
  my ($self, $n) = @_;
  ### PeanoCurve n_to_xy(): $n
  if ($n < 0            # negative
      || _is_infinite($n)) {
    return;
  }

  if (int($n) != $n) {
    my ($x1,$y1) = $self->n_to_xy(floor($n));
    my ($x2,$y2) = $self->n_to_xy(ceil($n));
    return (($x1+$x2)/2, ($y1+$y2)/2);
  }

  my $x = 0;
  my $y = 0;
  my $comp = 0;
  my $power = 1;
  for (;;) {
    ### $n
    ### $power
    {
      my $digit = $n % 3;
      if ($digit & 1) {
        $y = $comp - $y;
      }
      $x += $power * $digit;
    }
    $n = int($n/3) || last;
    $comp = (3*$comp + 2);
    {
      my $digit = $n % 3;
      if ($digit & 1) {
        $x = $comp - $x;
      }
      $y += $power * $digit;
    }
    $n = int($n/3) || last;
    $power *= 3;
  }
  return ($x, $y);


  # my (@n);
  # while ($n) {
  #   push @n, $n % 3; $n = int($n/3);
  #   push @n, $n % 3; $n = int($n/3);
  # }
  #
  # my $x = 0;
  # my $y = 0;
  # my $xk = 0;
  # my $yk = 0;
  # while (@n) {
  #   {
  #     my $digit = pop @n;
  #     $xk ^= $digit;
  #     $y = 3*$y + ($yk & 1 ? 2-$digit : $digit);
  #   }
  #   {
  #     my $digit = pop @n;
  #     $yk ^= $digit;
  #     $x = 3*$x + ($xk & 1 ? 2-$digit : $digit);
  #   }
  # }
  #
  # ### is: "$x,$y"
  # return ($x, $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### PeanoCurve xy_to_n(): "$x, $y"

  $x = floor($x + 0.5);
  $y = floor($y + 0.5);
  if ($x < 0 || $y < 0) {
    return undef;
  }

  if (_is_infinite($x) || _is_infinite($y)) {
    return undef;
  }

  my $power = 1;
  my $comp = 0;
  my $xn = my $yn = ($x & 0); # inherit
  while ($x || $y) {
    {
      my $digit = $x % 3;
      if ($digit & 1) {
        $yn = $comp - $yn;
      }
      $xn += $power * $digit;
      $x = int($x/3);
    }
    $comp = (3*$comp + 2);
    {
      my $digit = $y % 3;
      if ($digit & 1) {
        $xn = $comp - $xn;
      }
      $yn += $power * $digit;
      $y = int($y/3);
    }
    $power *= 3;
  }

  my $n = ($x & 0); # inherit
  $power = 1;
  while ($xn || $yn) {
    $n += ($xn % 3) * $power;
    $power *= 3;
    $n += ($yn % 3) * $power;
    $power *= 3;
    $xn = int($xn/3);
    $yn = int($yn/3);
  }
  return $n;




  # my $pos = 0;
  # my @x;
  # my @y;
  # while ($x || $y) {
  #   push @x, $x % 3; $x = int($x/3);
  #   push @y, $y % 3; $y = int($y/3);
  # }
  # 
  # my $i = 0;
  # my $xk = 0;
  # my $yk = 0;
  # while (@x) {
  #   {
  #     my $digit = pop @y;
  #     $xk ^= $digit;
  #     if ($yk & 1) {
  #       $digit = 2 - $digit;
  #     }
  #     $n = ($n * 3) + $digit;
  #   }
  #   {
  #     my $digit = pop @x;
  #     $yk ^= $digit;
  #     if ($xk & 1) {
  #       $digit = 2 - $digit;
  #     }
  #     $n = ($n * 3) + $digit;
  #   }
  # }
  # 
  # return $n;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = floor($x1 + 0.5);
  $y1 = floor($y1 + 0.5);
  $x2 = floor($x2 + 0.5);
  $y2 = floor($y2 + 0.5);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### rect_to_n_range(): "$x1,$y1 to $x2,$y2"

  if ($x2 < 0 || $y2 < 0) {
    return (1, 0);
  }


  my $power = 1;
  {
    my $max = max($x2,$y2);
    if ($max-1 == $max) {
      return (0,$max);  # infinity
    }
    until ($power > $max) {
      $power *= 3;
    }
  }

  my $n_power = $power * $power;
  my $max_x = 0;
  my $max_y = 0;
  my $max_n = 0;
  my $max_xk = 0;
  my $max_yk = 0;

  my $min_x = 0;
  my $min_y = 0;
  my $min_n = 0;
  my $min_xk = 0;
  my $min_yk = 0;

  # l<=c<h doesn't overlap c1<=c<=c2 if
  #     l>c2 or h-1<c1
  #     l>c2 or h<=c1
  # so does overlap if
  #     l<=c2 and h>c1
  #
  my $overlap = sub {
    my ($c,$ck,$digit, $c1,$c2) = @_;
    if ($ck & 1) {
      $digit = 2 - $digit;
    }
    ### overlap consider: "inv@{[$ck&1]}digit=$digit ".($c+$digit*$power)."<=c<".($c+($digit+1)*$power)." cf $c1 to $c2 incl"
    return ($c + $digit*$power <= $c2
            && $c + ($digit+1)*$power > $c1);
  };

  while ($power > 1) {
    $power = int($power/3);
    $n_power = int($n_power/3);

    ### $power
    ### $n_power
    ### $max_n
    ### $min_n
    {
      my $digit = (&$overlap   ($max_y,$max_yk,2, $y1,$y2) ? 2
                   : &$overlap ($max_y,$max_yk,1, $y1,$y2) ? 1
                   : 0);
      $max_n += $n_power * $digit;
      if ($max_yk&1) { $digit = 2 - $digit; }
      $max_y += $power * $digit;
      $max_xk ^= $digit;
      ### max y digit: $digit
      ### $max_y
      ### $max_n
    }
    {
      my $digit = (&$overlap   ($min_y,$min_yk,0, $y1,$y2) ? 0
                   : &$overlap ($min_y,$min_yk,1, $y1,$y2) ? 1
                   : 2);
      $min_n += $n_power * $digit;
      if ($min_yk&1) { $digit = 2 - $digit; }
      $min_y += $power * $digit;
      $min_xk ^= $digit;
      ### min y digit: $digit
      ### $min_y
      ### $min_n
    }

    $n_power = int($n_power/3);
    {
      my $digit = (&$overlap   ($max_x,$max_xk,2, $x1,$x2) ? 2
                   : &$overlap ($max_x,$max_xk,1, $x1,$x2) ? 1
                   : 0);
      $max_n += $n_power * $digit;
      if ($max_xk&1) { $digit = 2 - $digit; }
      $max_x += $power * $digit;
      $max_yk ^= $digit;
      ### max x digit: $digit
      ### $max_x
      ### $max_n
    }
    {
      my $digit = (&$overlap   ($min_x,$min_xk,0, $x1,$x2) ? 0
                   : &$overlap ($min_x,$min_xk,1, $x1,$x2) ? 1
                   : 2);
      $min_n += $n_power * $digit;
      if ($min_xk&1) { $digit = 2 - $digit; }
      $min_x += $power * $digit;
      $min_yk ^= $digit;
      ### min x digit: $digit
      ### $min_x
      ### $min_n
    }
  }
  ### is: "$min_n at $min_x,$min_y  to  $max_n at $max_x,$max_y"
  return ($min_n, $max_n);
}

1;
__END__

=for stopwords Guiseppe Peano Peano's there'll HilbertCurve eg Sur une courbe qui remplit toute aire Mathematische Annalen Ryde OEIS trit-twiddling ZOrderCurve ie bignums prepending trit PeanoCurve Math-PlanePath

=head1 NAME

Math::PlanePath::PeanoCurve -- 3x3 self-similar quadrant traversal

=head1 SYNOPSIS

 use Math::PlanePath::PeanoCurve;
 my $path = Math::PlanePath::PeanoCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path is an integer version of the curve described by Guiseppe Peano in
1890 for filling a unit square.  It traverses a quadrant of the plane one
step at a time in a self-similar 3x3 pattern,

      y=8   60--61--62--63--64--65  78--79--80--...
             |                   |   |
      y=7   59--58--57  68--67--66  77--76--75
                     |   |                   |
      y=6   54--55--56  69--70--71--72--73--74
             |
      y=5   53--52--51  38--37--36--35--34--33
                     |   |                   |
      y=4   48--49--50  39--40--41  30--31--32
             |                   |   |
      y=3   47--46--45--44--43--42  29--28--27
                                             |
      y=2    6---7---8---9--10--11  24--25--26
             |                   |   |
      y=1    5---4---3  14--13--12  23--22--21
                     |   |                   |
      y=0    0---1---2  15--16--17--18--19--20

           x=0   1   2   3   4   5   6   7   8   9 ...

The start is an S shape of the nine points 0 to 8, and then nine of those
groups are put together in the same configuration.  The sub-parts are
flipped horizontally and/or vertically to make the starts and ends adjacent,
so that 8 is next to 9, 17 next to 18, etc,

    60,61,62 --- 63,64,65     78,79,80
    59,58,57     68,67,55     77,76,75
    54,55,56     69,70,71 --- 72,73,74
     |  
     |  
    53,52,51     38,37,36 --- 35,34,33
    48,49,50     39,40,41     30,31,32
    47,46,45 --- 44,43,42     29,28,27
                                     |
                                     |
     6,7,8  ----  9,10,11     24,25,26
     3,4,5       12,13,14     23,22,21
     0,1,2       15,16,17 --- 18,19,20

The process repeats, tripling in size each time.

Within a power-of-3 square 3x3, 9x9, 27x27, 81x81 etc (3^k)x(3^k) at the
origin, all the N values 0 to 3^(2*k)-1 are within the square.  The top
right corner 8, 80, 728, etc is the 3^(2*k)-1 maximum in each.

Because each step is by 1, the distance along the curve between two X,Y
points is the difference in their N values (as given by C<xy_to_n>).

=head2 Unit Square

Peano's original form was for filling a unit square by mapping a number T in
the range 0E<lt>TE<lt>1 to a pair of X,Y coordinates 0E<lt>XE<lt>1 and
0E<lt>YE<lt>1.  The curve is continuous and every X,Y is reached, so it
fills the unit square.  A unit cube can be filled too by developing three
coordinates X,Y,Z similarly.  Georg Cantor had shown a line is equivalent to
a surface, Peano's mapping is a continuous way to do that.

The code here could be pressed into service for a fractional T to X,Y by
multiplying up by a power of 9 to desired precision then dividing X,Y back
by the same power of 3 (perhaps swapping X,Y for which one should be the
first ternary digit).  If T is a binary floating point then a power of 3
division will round off in general since 1/3 is not exactly representable in
binary.  See HilbertCurve or ZOrderCurve for binary based mappings.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::PeanoCurve-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.  Integer positions are always just 1 apart either
horizontally or vertically, so the effect is that the fraction part appears
either added to or subtracted from X or Y.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x,$y>.  Each integer N is
considered the centre of a unit square and an C<$x,$y> within that square
returns N.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

Return a range of N values which occur in a rectangle with corners at
C<$x1>,C<$y1> and C<$x2>,C<$y2>.  If the X,Y values are not integers then
the curve is treated as unit squares centred on each integer point and
squares which are partly covered by the given rectangle are included.

The returned range is exact, meaning C<$n_lo> is the smallest in the
rectangle and C<$n_hi> is the biggest.  Of course not all the N's in that
range are necessarily in the rectangle.

=back

=head1 FORMULAS

=head2 N to X,Y

Peano's calculation is based on putting base-3 digits of N alternately
between X and Y.  Starting from the high end of N a digit is appended to Y
then the next appended to X.  Starting at an even digit position in N makes
the last digit go to X so that the first N=0,1,2 steps go along the X axis.

At each stage a "complement" state is maintained for X and Y.  When
complemented the digit is reversed to S<2 - digit>, so 0,1,2 becomes 2,1,0.
This reverses the direction so points like N=12,13,14 shown above go to the
left, or groups like 9,10,11 then 12,13,14 then 15,16,17 go downwards.

The complement is calculated by adding the N digits which went to the other
of X or Y.  The X complement is the sum of digits which have been appended
to Y so far, and conversely the Y complement is the sum of digits applied
to X.  If the complement sum is odd then the reversal is done.  The reversal
itself doesn't change the odd/even so it doesn't matter if the digit is
taken before or after reversing.  An XOR can be used instead of a sum,
accumulating odd/even the same way.

It also works to take the base-3 digits of N from low to high, prepending
digits to X and Y successively.  When an odd digit, ie. a 1, is put onto X
then the digits of Y so far must be complemented as 22..22 - Y, the 22..22
value being all 2s in base 3.  Conversely if a digit 1 is added to Y then X
must be complemented.  With this approach the high digits of N don't have to
be found, but instead digits of N peeled off the low end.  But the subtract
to do the complement is more work if using bignums.

=head2 X,Y to N

The X,Y to N calculation can be done by an inverse of either method above,
in both cases putting digits alternately from X and Y onto N, with
complement as necessary.  For the low to high approach it's not easy to
complement just the X digits in the N constructed so far, but it works to
build and complement the X and Y digits separately then at the end
interleave to make the final N.  Complementing is the equivalent of an XOR
in binary.  On a ternary machine some trit-twiddling could no doubt do it.

In the current code C<n_to_xy> and C<xy_to_n> both go low to high as that
seems a bit easier than finding the high ternary digits of the inputs.

=head2 N Range

An easy over-estimate of the maximum N in a region can be had by going to
the next bigger (3^k)x(3^k) square enclosing the region.  This means the
biggest X or Y rounded up to the next power of 3 (perhaps using C<log> if
you trust its accuracy), so

    find k with 3^k > max(X,Y)
    N_max = 3^(2k) - 1

An exact N range can be found by following the high to low N to X,Y
procedure.  Start at the 3^(2k) ternary digit position in N which is bigger
than the desired region and choose a digit 0,1,2 for X, the biggest which
overlaps some of the region.  Or if there's an X complement then the
smallest digit is the biggest N, again which overlaps the region.  Then the
same for a digit of Y, etc.

Biggest and smallest N must be calculated separately as they track down
different N digits and different X,Y complement states.  The N range for any
shape can be done this way, not just a rectangle the way C<rect_to_n_range>
does, since it only depends only on asking when a one-third sub-part of X or
Y overlaps the target area.

=head1 OEIS

This path is in Sloane's OEIS in several forms,

    http://oeis.org/A163528  (etc)

    A163528    X coordinate
    A163529    Y coordinate
    A163530    coordinate sum X+Y
    A163531    square of distance from origin X^2+Y^2
    A163532    X change -1,0,1
    A163533    Y change -1,0,1
    A163534    absolute direction of each step (up,down,left,right)
    A163535    absolute direction, transpose X,Y
    A163536    relative direction (ahead,left,right)
    A163537    relative direction, transpose X,Y
    A163342    diagonal sums
    A163343    central diagonal 0,4,8,44,40,36,etc
    A163344    central diagonal divided by 4
    A163479    diagonal sums divided by 6
    A163480    row at Y=0
    A163481    column at X=0

And taking the squares of the plane in the Diagonals sequence, each value of
the following sequences is the N of the Peano curve at those positions.

    A163334    numbering by diagonals, from same axis as first step
    A163336    numbering by diagonals, from opposite axis
    A163338    A163334 + 1, Peano starting from N=1
    A163340    A163336 + 1, Peano starting from N=1

C<Math::PlanePath::Diagonals> numbers from the Y axis down, which is the
opposite axis to the Peano curve first step along the X axis, so a plain
Diagonals -> PeanoCurve is the "opposite axis" form A163336.

These sequences are permutations of the integers since all X,Y positions of
the first quadrant are reached eventually.  The inverses are as follows.
They can be thought of taking X,Y positions in the Peano curve order and
then asking what N the Diagonals would put there.

    A163335    inverse of A163334
    A163337    inverse of A163336
    A163339    inverse of A163338
    A163341    inverse of A163340

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::HilbertCurve>,
L<Math::PlanePath::ZOrderCurve>,
L<Math::PlanePath::KochCurve>

Guiseppe Peano, "Sur une courbe, qui remplit toute une aire plane",
Mathematische Annalen, volume 36, number 1, 1890, p157-160

    http://www.springerlink.com/content/w232301n53960133/
    DOI 10.1007/BF01199438

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

   +--+
   |  |
+--+--+--+
   |  |
   +--+

         +
         |
      +--+--+
      |  |  |
   +--+--+--+--+
   |  |  |  |  |
+--+--+--+--+--+--+
   |  |  |  |  |
   +--+--+--+--+      
      |  |  |
      +--+--+
         |
         +   
