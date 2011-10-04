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


# cf
#
# http://www.cut-the-knot.org/Curriculum/Geometry/PeanoComplete.shtml
#     Java applet, directions in 9 sub-parts
#
# math-image --path=PeanoCurve,radix=5 --all --output=numbers
# math-image --path=PeanoCurve,radix=5 --lines
#
# T = 0.a1 a2 ...
# X = 0.b1 b2 ...
# Y = 0.c1 c2 ...
#
# b1=a1
# c1 = a2 comp(a1)
# b2 = a3 comp(a2)
# c2 = a4 comp(a1+a3)
#
# bn = a[2n-1] comp a2+a4+...+a[2n-2]
# cn = a[2n] comp a1+a3+...+a[2n-1]
#


package Math::PlanePath::PeanoCurve;
use 5.004;
use strict;
use List::Util qw(min max);

use vars '$VERSION', '@ISA';
$VERSION = 47;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;
use constant x_negative => 0;
use constant y_negative => 0;

use constant parameter_info_array =>
  [ { name      => 'radix',
      share_key => 'radix_3',
      type      => 'integer',
      minimum   => 2,
      default   => 3,
      width     => 3,
    } ];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  if (! $self->{'radix'} || $self->{'radix'} < 2) {
    $self->{'radix'} = 3;
  }
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### PeanoCurve n_to_xy(): $n
  if ($n < 0) {            # negative
    return;
  }
  if (_is_infinite($n)) {
    return ($n,$n);
  }

  {
    # ENHANCE-ME: for odd radix the ends join and the direction can be had
    # without a full N+1 calculation
    my $int = int($n);
    ### $int
    ### $n
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

  # low to high
  my $x = my $y = $n & 0;  # inherit BigInt 0
  my $power = $x + 1;      # inherit BigInt 1
  my $radix = $self->{'radix'};
  for (;;) {
    ### $n
    ### $power
    {
      my $digit = $n % $radix;
      if ($digit & 1) {
        $y = $power-1 - $y;   # 99..99 - Y
      }
      $x += $power * $digit;
    }
    $n = int($n/$radix) || last;
    {
      my $digit = $n % $radix;
      $y += $power * $digit;
      $power *= $radix;

      if ($digit & 1) {
        $x = $power-1 - $x;
      }
    }
    $n = int($n/$radix) || last;
  }
  return ($x, $y);


  # # high to low
  # my $radix = $self->{'radix'};
  # my $radix_minus_1 = $radix - 1;
  # my (@n);
  # while ($n) {
  #   push @n, $n % $radix; $n = int($n/$radix);
  #   push @n, $n % $radix; $n = int($n/$radix);
  # }
  # my $x = 0;
  # my $y = 0;
  # my $xk = 0;
  # my $yk = 0;
  # while (@n) {
  #   {
  #     my $digit = pop @n;
  #     $xk ^= $digit;
  #     $y *= $radix;
  #     $y += ($yk & 1 ? $radix_minus_1-$digit : $digit);
  #   }
  #   {
  #     my $digit = pop @n;
  #     $yk ^= $digit;
  #     $x *= $radix;
  #     $x += ($xk & 1 ? $radix_minus_1-$digit : $digit);
  #   }
  # }
  # ### is: "$x,$y"
  # return ($x, $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### PeanoCurve xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($x < 0 || $y < 0
      || _is_infinite($x)
      || _is_infinite($y)) {
    return undef;
  }

  # my $radix = $self->{'radix'};
  # my $power = 1;
  # my $xn = my $yn = ($x & 0); # inherit
  # while ($x || $y) {
  #   {
  #     my $digit = $x % $radix;
  #     $x = int($x/$radix);
  #     if ($digit & 1) {
  #       $yn = $power-1 - $yn;
  #     }
  #     $xn += $power * $digit;
  #   }
  #   {
  #     my $digit = $y % $radix;
  #     $y = int($y/$radix);
  #     $yn += $power * $digit;
  #     $power *= $radix;
  #     if ($digit & 1) {
  #       $xn = $power-1 - $xn;
  #     }
  #   }
  # }
  #
  # my $n = ($x & 0); # inherit
  # $power = 1;
  # while ($xn || $yn) {
  #   $n += ($xn % $radix) * $power;
  #   $power *= $radix;
  #   $n += ($yn % $radix) * $power;
  #   $power *= $radix;
  #   $xn = int($xn/$radix);
  #   $yn = int($yn/$radix);
  # }
  # return $n;


  my $radix = $self->{'radix'};
  my $radix_minus_1 = $radix - 1;
  my @x;
  my @y;
  while ($x || $y) {
    push @x, $x % $radix; $x = int($x/$radix);
    push @y, $y % $radix; $y = int($y/$radix);
  }

  my $xk = 0;
  my $yk = 0;
  my $n = 0;
  while (@x) {
    {
      my $digit = pop @y;
      if ($yk & 1) {
        $digit = $radix_minus_1 - $digit;
      }
      $n = ($n * $radix) + $digit;
      $xk ^= $digit;
    }
    {
      my $digit = pop @x;
      if ($xk & 1) {
        $digit = $radix_minus_1 - $digit;
      }
      $n = ($n * $radix) + $digit;
      $yk ^= $digit;
    }
  }
  return $n;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### rect_to_n_range(): "$x1,$y1 to $x2,$y2"

  if ($x2 < 0 || $y2 < 0) {
    return (1, 0);
  }

  my $radix = $self->{'radix'};
  my $power = 1;
  {
    my $max = max($x2,$y2);
    if ($max-1 == $max) {
      return (0,$max);  # infinity
    }
    until ($power > $max) {
      $power *= $radix;
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
  my $radix_minus_1 = $radix - 1;
  my $overlap = sub {
    my ($c,$ck,$digit, $c1,$c2) = @_;
    if ($ck & 1) {
      $digit = $radix_minus_1 - $digit;
    }
    ### overlap consider: "inv@{[$ck&1]}digit=$digit ".($c+$digit*$power)."<=c<".($c+($digit+1)*$power)." cf $c1 to $c2 incl"
    return ($c + $digit*$power <= $c2
            && $c + ($digit+1)*$power > $c1);
  };

  while ($power > 1) {
    $power = int($power/$radix);
    $n_power = int($n_power/$radix);

    ### $power
    ### $n_power
    ### $max_n
    ### $min_n
    {
      my $digit;
      for ($digit = $radix_minus_1; $digit > 0; $digit--) {
        last if &$overlap ($max_y,$max_yk,$digit, $y1,$y2);
      }
      $max_n += $n_power * $digit;
      $max_xk ^= $digit;
      if ($max_yk&1) { $digit = $radix_minus_1 - $digit; }
      $max_y += $power * $digit;
      ### max y digit (complemented): $digit
      ### $max_y
      ### $max_n
    }
    {
      my $digit;
      for ($digit = 0; $digit < $radix_minus_1; $digit++) {
        last if &$overlap ($min_y,$min_yk,$digit, $y1,$y2);
      }
      $min_n += $n_power * $digit;
      $min_xk ^= $digit;
      if ($min_yk&1) { $digit = $radix_minus_1 - $digit; }
      $min_y += $power * $digit;
      ### min y digit (complemented): $digit
      ### $min_y
      ### $min_n
    }

    $n_power = int($n_power/$radix);
    {
      my $digit;
      for ($digit = $radix_minus_1; $digit > 0; $digit--) {
        last if &$overlap ($max_x,$max_xk,$digit, $x1,$x2);
      }
      $max_n += $n_power * $digit;
      $max_yk ^= $digit;
      if ($max_xk&1) { $digit = $radix_minus_1 - $digit; }
      $max_x += $power * $digit;
      ### max x digit (complemented): $digit
      ### $max_x
      ### $max_n
    }
    {
      my $digit;
      for ($digit = 0; $digit < $radix_minus_1; $digit++) {
        last if &$overlap ($min_x,$min_xk,$digit, $x1,$x2);
      }
      $min_n += $n_power * $digit;
      $min_yk ^= $digit;
      if ($min_xk&1) { $digit = $radix_minus_1 - $digit; }
      $min_x += $power * $digit;
      ### min x digit (complemented): $digit
      ### $min_x
      ### $min_n
    }
  }
  ### is: "$min_n at $min_x,$min_y  to  $max_n at $max_x,$max_y"
  return ($min_n, $max_n);
}

1;
__END__

=for stopwords Guiseppe Peano Peano's there'll HilbertCurve eg Sur une courbe qui remplit toute aire Mathematische Annalen Ryde OEIS trit-twiddling ZOrderCurve ie bignums prepending trit PeanoCurve Math-PlanePath versa Online

=head1 NAME

Math::PlanePath::PeanoCurve -- 3x3 self-similar quadrant traversal

=head1 SYNOPSIS

 use Math::PlanePath::PeanoCurve;
 my $path = Math::PlanePath::PeanoCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

 # or another radix digits ...
 my $path5 = Math::PlanePath::PeanoCurve->new (radix => 5);

=head1 DESCRIPTION

This path is an integer version of the curve described by Guiseppe Peano in
1890 for filling a unit square.  It traverses a quadrant of the plane one
step at a time in a self-similar 3x3 pattern,

       8    60--61--62--63--64--65  78--79--80--...
             |                   |   |
       7    59--58--57  68--67--66  77--76--75
                     |   |                   |
       6    54--55--56  69--70--71--72--73--74
             |
       5    53--52--51  38--37--36--35--34--33
                     |   |                   |
       4    48--49--50  39--40--41  30--31--32
             |                   |   |
       3    47--46--45--44--43--42  29--28--27
                                             |
       2     6---7---8---9--10--11  24--25--26
             |                   |   |
       1     5---4---3  14--13--12  23--22--21
                     |   |                   |
      Y=0    0---1---2  15--16--17--18--19--20

           X=0   1   2   3   4   5   6   7   8   9 ...

The start is an S shape of the nine points 0 to 8, and then nine of those
groups are put together in the same S configuration.  The sub-parts are
flipped horizontally and/or vertically to make the starts and ends adjacent,
so 8 is next to 9, 17 next to 18, etc,

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

Within a power-of-3 square, 3x3, 9x9, 27x27, 81x81 etc (3^k)x(3^k), at the
origin, all the N values 0 to 3^(2*k)-1 are within the square.  The top
right corner 8, 80, 728, etc is the 3^(2*k)-1 maximum in each.

Because each step is by 1, the distance along the curve between two X,Y
points is the difference in their N values (as given by C<xy_to_n()>).

=head2 Radix

The radix parameter can do the calculation in a base other than 3, using the
same kind of direction reversals.  For example radix 5 gives 5x5 groups,

      4  |  20--21--22--23--24--25--26--27--28--29
         |   |                                   |
      3  |  19--18--17--16--15  34--33--32--31--30
         |                   |   |
      2  |  10--11--12--13--14  35--36--37--38--39
         |   |                                   |
      1  |   9-- 8-- 7-- 6-- 5  44--43--42--41--40
         |                   |   |
     Y=0 |   0-- 1-- 2-- 3-- 4  45--46--47--48--49--50-...
         |
         +----------------------------------------------
           X=0   1   2   3   4   5   6   7   8   9  10

If the radix is even then the ends of each group don't join up.  For example
in radix 4 N=15 isn't next to N=16, nor N=31 to N=32, etc.

         |
      3  |  15--14--13--12  16--17--18--19
         |               |               |
      2  |   8-- 9--10--11  23--22--21--20
         |   |               |
      1  |   7-- 6-- 5-- 4  24--25--26--27
         |               |               |
     Y=0 |   0-- 1-- 2-- 3  31--30--29--28  32--33-...
         |
         +------------------------------------------
           X=0   1   2   4   5   6   7   8   9  10

Even sizes can be made to join using other patterns, but this module is just
Peano's digit construction.  For 2x2 groupings see HilbertCurve (which is
essentially the only way to join up in 2x2).  For bigger groupings there's
various ways.

=head2 Unit Square

Peano's original form was for filling a unit square by mapping a number T in
the range 0E<lt>TE<lt>1 to a pair of X,Y coordinates 0E<lt>XE<lt>1 and
0E<lt>YE<lt>1.  The curve is continuous and every X,Y is reached, so it
fills the unit square.  A unit cube or higher dimension can be filled
similarly by developing three or more coordinates X,Y,Z, etc.  Georg Cantor
had shown a line is equivalent to a surface, Peano's mapping is a continuous
way to do that.

The code here might be pressed into service for a fractional T to X,Y by
multiplying up by a power of 9 to desired precision then dividing X and Y
back by the same power of 3 (perhaps swapping X,Y for which one should be
the first ternary digit).  Note that if T is a binary floating point then a
power of 3 division will round off in general as 1/3 is not exactly
representable.  See HilbertCurve or ZOrderCurve for binary mappings.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::PeanoCurve-E<gt>new ()>

=item C<$path = Math::PlanePath::PeanoCurve-E<gt>new (radix =E<gt> $r)>

Create and return a new path object.

The optional C<radix> parameter gives the base for digit splitting.  The
default is ternary, C<radix =E<gt> 3>.

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

Peano's calculation is based on putting base-3 digits of N alternately to X
or Y.  From the high end of N a digit is appended to Y then the next
appended to X.  Beginning at an even digit position in N makes the last
digit go to X so the first N=0,1,2 goes along the X axis.

At each stage a "complement" state is maintained for X and for Y.  When
complemented the digit is reversed to S<2 - digit>, so 0,1,2 becomes 2,1,0.
This reverses the direction so points like N=12,13,14 shown above go to the
left, or groups like 9,10,11 then 12,13,14 then 15,16,17 go downwards.

The complement is calculated by adding the digits from N which went to the
other one of X or Y.  So the X complement is the sum of digits which have
gone to Y so far, and conversely the Y complement is the sum of digits put
to X.  If the complement sum is odd then the reversal is done.  An XOR can
be used instead of a sum, accumulating odd/even-ness the same way as a sum.

When forming the complement it's the original digits from N which are used,
before applying any complementing for putting them to X or Y.  If the radix
is odd, like the default 3, then the complement doesn't change it mod 2 so
either before or after is fine, but if the radix is even then it's not the
same.

It also works to take the base-3 digits of N from low to high, generating
low to high digits in X and Y.  When an odd digit is put to X then the low
digits of Y so far must be complemented as S<22..22 - Y> (the 22..22 value
being all 2s in base 3, ie. 3^k-1).  Conversely if an odd digit is put to Y
then X must be complemented.  With this approach the high digit position in
N doesn't have to be found, but instead peel off digits of N from the low
end.  But the subtract to complement is then more work if using bignums.

=head2 X,Y to N

The X,Y to N calculation can be done by an inverse of either the high to low
or low to high methods above, in both cases putting digits alternately from
X and Y onto N, with complement as necessary.

For the low to high approach it's not easy to complement just the X digits
in the N constructed so far, but it works to build and complement the X and
Y digits separately then at the end interleave to make the final N.
Complementing is the ternary equivalent of an XOR in binary.  On a ternary
machine some trit-twiddling could no doubt do it.

For the low to high with even radix the complementing is also tricky since
changing the accumulated X affects the digits of Y below that, and vice
versa.  What's the rule?  Is it alternate digits which end up complemented?
In any case the current C<xy_to_n()> code goes high to low which is easier,
but means breaking the X,Y inputs into arrays of digits.

=head2 Rectangle to N Range

An easy over-estimate of the maximum N in a region can be had by going to
the next bigger (3^k)x(3^k) square enclosing the region.  This means the
biggest X or Y rounded up to the next power of 3 (perhaps using C<log()> if
you trust its accuracy), so

    find k with 3^k > max(X,Y)
    N_hi = 3^(2k) - 1

An exact N range can be found by following the "high to low" N to X,Y
procedure above.  Start with the easy over-estimate to find a 3^(2k) ternary
digit position in N bigger than the desired region, then choose a digit
0,1,2 for X, the biggest which overlaps some of the region.  Or if there's
an X complement then the smallest digit is the biggest N, again one which
overlaps the region.  Then likewise for a digit of Y, etc.

Biggest and smallest N must maintain separate complement states as they
track down different N digits, but a single loop can be used since there's
them same "2k" many digits of N to consider for both.

The N range of any shape can be done this way, not just a rectangle like
C<rect_to_n_range()>, since the procedure only depends on asking whether a
one-third sub-part of X or Y overlaps the target region or not.

=head1 OEIS

This path is in Sloane's Online Encyclopedia of Integer Sequences in several
forms,

    http://oeis.org/A163528  (etc)

    A163528    X coordinate
    A163529    Y coordinate
    A163530    coordinate sum X+Y
    A163531    square of distance from origin X^2+Y^2
    A163532    X change -1,0,1
    A163533    Y change -1,0,1
    A163534    absolute direction of each step (up,down,left,right)
    A163535    absolute direction, swapped X,Y
    A163536    relative direction (ahead, left, or right)
    A163537    relative direction, swapped X,Y
    A163342    diagonal sums
    A163343    central diagonal 0,4,8,44,40,36,etc
    A163344    central diagonal divided by 4
    A163479    diagonal sums divided by 6
    A163480    row at Y=0
    A163481    column at X=0

And taking X,Y points by the Diagonals sequence, then the value of the
following sequences is the N of the Peano curve at those positions.

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
