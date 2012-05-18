# Copyright 2012 Kevin Ryde

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


# math-image --path=CubicBase --all --output=numbers --size=60x20

#

package Math::PlanePath::CubicBase;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 74;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant n_start => 0;

use constant parameter_info_array =>
  [{ name      => 'radix',
     share_key => 'radix_2',
     type      => 'integer',
     minimum   => 2,
     default   => 2,
     width     => 3,
   },
   { name      => 'skewed',
     type      => 'boolean',
     default   => 0,
   }
];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $radix = $self->{'radix'};
  if (! defined $radix || $radix <= 2) { $radix = 2; }
  $self->{'radix'} = $radix;
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### CubicBase n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  # is this sort of midpoint worthwhile? not documented yet
  {
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
    $n = $int;       # BigFloat int() gives BigInt, use that
  }

  my $x = 0;
  my $y = 0;
  my $dx = 2;
  my $dy = 0;
  my $radix = $self->{'radix'};
  my $rot = 0;

  while ($n) {
    ### at: "$x,$y"
    ### digit: ($n % $radix)

    my $digit = $n % $radix;
    $n = int($n/$radix);

    $x += $digit * $dx;
    $y += $digit * $dy;

    ($dx,$dy) = (($dx+3*$dy)/-2, ($dx-$dy)/2);  # rotate +120
    if (++$rot >= 2) {
      $rot = 0;
      $dx *= $radix;
      $dy *= $radix;
    }
  }

  if ($self->{'skewed'}) {
    $x = ($x + $y) / 2;
  }

  ### final: "$x,$y"
  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### CubicBase xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if (_is_infinite($x)) { return ($x); }
  if (_is_infinite($y)) { return ($y); }

  if ($self->{'skewed'}) {
    $x = 2*$x - $y;
  } else {
    if (($x + $y) % 2) {
      # nothing on odd squares, only A2 even squares
      return undef;
    }
  }

  my $radix = $self->{'radix'};
  my $radix_2 = 2*$radix;

  my $n = ($x * 0 * $y);  # inherit bignum 0
  my $power = $n + 1;     # inherit bignum 1
  my $rot = 0;

  while ($x || $y) {
    ### at: "x=$x y=$y"
    ### assert: (($x + $y) % 2) == 0

    my $digit = ($x + $y) % $radix_2;
    $n += $digit/2 * $power;    # digits low to high
    ### $digit

    $x -= $digit;
    ### subtract to: "x=$x y=$y"

    ($x,$y) = ((3*$y - $x)/2, ($x+$y)/-2);  # rotate -120
    ### rotate to: "x=$x y=$y"

    if (++$rot >= 2) {
      $rot = 0;
      ### assert: ($x % $radix) == 0
      ### assert: ($y % $radix) == 0
      $x /= $radix;
      $y /= $radix;
    }

    $power *= $radix;
  }
  return $n;
}

# for i-1 need level=6 to cover 8 points surrounding 0,0
# for i-2 and higher level=3 is enough

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### CubicBase rect_to_n_range(): "$x1,$y1  $x2,$y2"

  my $xm = _max(abs($x1),abs($x2));
  my $ym = _max(abs($y1),abs($y2));

  return (0,
          int ($xm*$xm + $ym*$ym) * $self->{'radix'} * 8);
}

1;
__END__

=for stopwords eg Ryde Math-PlanePath ZOrderCurve Radix ie

=head1 NAME

Math::PlanePath::CubicBase -- replications in three directions

=head1 SYNOPSIS

 use Math::PlanePath::CubicBase;
 my $path = Math::PlanePath::CubicBase->new (radix => 4);
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is a pattern arising from complex numbers expressed in a base w*cbrt(2)
or other w*sqrt(r) base, where w=-1/2+i*sqrt(3)/2, the cube root of unity at
+120 degrees.

=cut

# these numbers generated with
#   math-image --path=CubicBase --expression='i<64?i:0' --output=numbers --size=132x20

=pod

                       18    19    26    27                      5
                          16    17    24    25                   4
                 22    23    30    31                            3
                    20    21    28    29                         2
           50    51    58    59     2     3    10    11          1
              48    49    56    57     0     1     8     9   <- Y=0
     54    55    62    63     6     7    14    15               -1
        52    53    60    61     4     5    12    13            -2
                       34    35    42    43                     -3
                          32    33    40    41                  -4
                 38    39    46    47                           -5
                    36    37    44    45                        -6

                                       ^
    -11-10 -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6

The points are on a triangular grid by using every second integer X,Y, as
per L<Math::PlanePath/Triangular Lattice>.  All points on that triangular
grid are visited.

The pattern can be seen by dividing into blocks of 2^k points,

                      -----------------------
                      \ 18    19    26    27 \
                       \                       \
                        \  16    17    24    25 \
               ----------              ----------
                \ 22    23    30    31 \
                  \                      \
                   \ 20    21    28    29  \
          --------- ------------ +----------- -----------
          \ 50    51    58    59  \  2     3  \ 10    11 \
            \                      +-----------+           \
             \ 48    49    56    57  \  0     1  \  8     9 \
    ----------              --------- +-----------  ---------+
    \ 54    55    62    63  \  6     7  \ 14    15  \
     \                        \          \            \
       \ 52    53    60    61  \  4     5 \  12    13  \
        --------------          +---------- ------------
                      \ 34    35    42    43 \
                       \                       \
                        \  32    33    40    41 \
                ---------+            -----------
                \ 38    39    46    47 \
                 \                       \
                   \ 36    37    44    45 \
                    -----------------------

N=0 is the origin, then N=1 to the right.  Those two are repeated at +120
degrees up as N=2 and N=3.  Then that skew 2x2 repeated at 240 degrees
around as N=4 to N=7.  The bow-tie shaped block of 8 is repeated around
again to 0 degrees as N=8 to N=16.  Then the skewed 4x4 block at +120 as
N=16 to N=31, and the resulting 32 point block repeated as N=32 to N=64 at
+240 degrees.  Each replication is 1/3 of the circle around at 0, 120 and
240 degrees.  The relative layout within a replication is unchanged.

This is similar to the ImaginaryBase, but where it repeats in 4 directions
based on i=squareroot(-1), here it's in 3 directions based on w=cuberoot(1).

=head2 Radix

The C<radix> parameter controls the "r" used to break N into X,Y.  For
example C<radix =E<gt> 4> gives 4x4 blocks, with r-1 copies of the preceding
level at each stage.

=cut

# these numbers generated by
#   math-image --path=CubicBase,radix=4 --expression='i<64?i:0' --output=numbers --size=150x30

=pod

       3                                 12    13    14    15
       2                                     8     9    10    11
       1                                        4     5     6     7
     Y=0 ->                                        0     1     2     3
      -1                     28    29    30    31
      -2                        24    25    26    27
      -3                           20    21    22    23
      -4                              16    17    18    19
      -5         44    45    46    47
      ...           40    41    42    43
                       36    37    38    39
                          32    33    34    35
     60    61    62    63
        56    57    58    59
           52    53    54    55
              48    49    50    51

                                                   ^
    -15-14-13-12-11-10 -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6

Notice the parts always replicate successively away from the origin, so the
block N=16 to N=31 is near the origin at X=-4, then N=32 at X=-8, N=48 at
X=-12, and N=64 at X=-16 (not shown).

In this layout the replications still mesh together perfectly and all points
on that triangular grid are visited.

=head2 Axis Values

In the default radix=2, the N=0,1,8,9,etc on the positive X axis are those
integers with zeros at two of every three bits starting from zeros in the
second and third least significant bit.

    X axis Ns = binary ..._00_00_00_     with _ either 0 or 1
    in octal, digits 0,1 only

For a radix other than binary the pattern is the same.  Each "_" is any
digit of the given radix, and each 0 must be 0.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::CubicBase-E<gt>new ()>

=item C<$path = Math::PlanePath::CubicBase-E<gt>new (radix =E<gt> $r)>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::ImaginaryBase>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2012 Kevin Ryde

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
