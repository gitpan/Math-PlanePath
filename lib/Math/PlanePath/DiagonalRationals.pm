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


# cf
# A038566   fractions numerators  by ascending den
# A038567   fractions denominators
# A038568   rationals numerators   X/Y followed by Y/X by ascending Y
# A038569   rationals denominators


# math-image --path=DiagonalRationals --all --scale=10
# math-image --path=DiagonalRationals --output=numbers --all



package Math::PlanePath::DiagonalRationals;
use 5.004;
use strict;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use Math::PlanePath;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;
*_rect_for_first_quadrant = \&Math::PlanePath::_rect_for_first_quadrant;

use vars '$VERSION', '@ISA';
$VERSION = 78;
@ISA = ('Math::PlanePath');

use Math::PlanePath::CoprimeColumns;
use vars '@_x_to_n';
BEGIN {
  *_x_to_n = \@Math::PlanePath::CoprimeColumns::_x_to_n;
  *_extend = \&Math::PlanePath::CoprimeColumns::_extend;
}


# uncomment this to run the ### lines
#use Smart::Comments;


# R = 1 / (1/F - 1)
# F = Ycol/Xcol
# R = 1 / (Xcol/Ycol - 1)
#   = 1 / (Xcol-Ycol)/Ycol
#   = Ycol / (Xcol-Ycol)
#
# R = 1 / (1/F - 1)
#   = 1 / (1-F)/F
#   = F/(1-F)
#
# 1/R = 1/F - 1
# 1/R + 1 = 1/F
# F = 1 / (1/R + 1)
#   = 1 / (1+R)/R
#   = R/(1+R)
#
# F = 1 / (1/R + 1)
# R = Xdiag/Ydiag
# F = 1 / (Ydiag/Xdiag + 1)
#   = 1 / (Ydiag+Xdiag)/Xdiag
#   = Xdiag/(Ydiag+Xdiag)
#   = Ycol/Xcol
# Xcol = Ydiag+Xdiag
# Ycol = Xdiag
#
# R = 1 / (1/F - 1)
#   = 1 / ((1+R)/R - 1)
#   = 1 / ((1+R-R)/R)
#   = 1 / (1/R)
#   = R


use constant class_x_negative => 0;
use constant class_y_negative => 0;
use constant n_frac_discontinuity => .5;

sub n_to_xy {
  my ($self, $n) = @_;
  ### DiagonalRationals n_to_xy(): $n

  if (2*$n-1 < 0) {
    return;
  }
  my ($x,$y) = Math::PlanePath::CoprimeColumns::n_to_xy($self,$n)
    or return;
  return ($y,$x-$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### DiagonalRationals xy_to_n(): "$x,$y"
  my $n = Math::PlanePath::CoprimeColumns::xy_to_n($self,$x+$y,$x);

  # not the N=0 at Xcol=1,Ycol=1 which is Xdiag=1,Ydiag=0
  if (defined $n && $n < 1) {
    return undef;
  } else {
    return $n;
  }
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### DiagonalRationals rect_to_n_range(): "$x1,$y1 $x2,$y2"

  $x1 = _round_nearest($x1);
  $y1 = _round_nearest($y1);
  $x2 = _round_nearest($x2);
  $y2 = _round_nearest($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  if ($x2 < 1 || $y2 < 1) {
    ### outside quadrant ...
    return (1, 0);
  }

  ### rect: "$x1,$y1  $x2,$y2"

  my $d2 = $x2 + $y2 + 1;
  if (_is_infinite($d2)) {
    return (1, $d2);
  }
  while ($#_x_to_n < $d2) {
    _extend();
  }
  my $d1 = max (2, $x1 + $y1);
  ### $d1
  ### $d2

  return ($_x_to_n[$d1],
          $_x_to_n[$d2] - 1);
}

1;
__END__

=for stopwords Ryde coprime coprimes coprimeness totient totients Math-PlanePath Euler's onwards CoprimeColumns DiagonalRationals OEIS

=head1 NAME

Math::PlanePath::DiagonalRationals -- rationals X/Y by diagonals

=head1 SYNOPSIS

 use Math::PlanePath::DiagonalRationals;
 my $path = Math::PlanePath::DiagonalRationals->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path enumerates positive rationals X/Y with no common factor, going in
diagonal order from Y down to X.

    17  |    96...
    16  |    80
    15  |    72 81
    14  |    64    82
    13  |    58 65 73 83 97
    12  |    46          84
    11  |    42 47 59 66 74 85 98
    10  |    32    48          86
     9  |    28 33    49 60    75 87
     8  |    22    34    50    67    88
     7  |    18 23 29 35 43 51    68 76 89 99
     6  |    12          36    52          90
     5  |    10 13 19 24    37 44 53 61    77 91
     4  |     6    14    25    38    54    69    92
     3  |     4  7    15 20    30 39    55 62    78 93
     2  |     2     8    16    26    40    56    70    94
     1  |     1  3  5  9 11 17 21 27 31 41 45 57 63 71 79 95
    Y=0 |
        +---------------------------------------------------
         X=0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16

The order is the same as the Diagonals path, but only those X,Y with no
common factor are numbered.

The N=1,2,4,6,10,etc in the leftmost column (at X=1) is the cumulative
totient,

    phi(i) = count divisors of i

                    i=K
    phicumul(K) =  sum   phi(i)
                    i=1

=head2 Coprime Columns

The diagonals are the same as the columns in CoprimeColumns.  For example
the diagonal N=18 to N=21 from X=0,Y=8 down to X=8,Y=0 is the same as the
CoprimeColumns vertical at X=8.  In general the correspondence is

   Xdiag = Ycol
   Ydiag = Xcol - Ycol

   Xcol = Xdiag + Ydiag
   Ycol = Xdiag

The CoprimeColumns has an extra N=0 at X=1,Y=1 which is not present in
DiagonalRationals.  (It would be Xdiag=1,Ydiag=0 which is 1/0.)

The points numbered or skipped in a column up to X=Y is the same as the
points numbered or skipped on a diagonal, simply because X,Y no common
factor is the same as Y,X+Y no common factor.

Taking the CoprimeColumns as enumerating fractions F = Ycol/Xcol with
S<0 E<lt> F E<lt> 1> the corresponding diagonal rational
S<0 E<lt> R E<lt> infinity> is

           1         F
    R = -------  =  ---
        1/F - 1     1-F

           1         R
    F = -------  =  ---
        1/R + 1     1+R

which is a one-to-one mapping between the fractions S<F E<lt> 1> and all
rationals.

=head1 OEIS

This enumeration of rationals is in Sloane's Online Encyclopedia of Integer
Sequences in the following forms

    http://oeis.org/A020652   (etc)

    A020652  - numerators, X
    A020653  - denominators, Y
    A157806  - difference, abs(X-Y)
    A054431  - by diagonals 1=coprime, 0=not
                 (excluding X=0 row and Y=0 column)

    A054424  - permutation DiagonalRationals -> RationalsTree SB
    A054425  -   padded with 0s at non-coprimes
    A054426  -   inverse SB -> DiagonalRationals

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::DiagonalRationals-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 1 and if C<$n E<lt> 1> then the return is an empty list.

=back

=head1 BUGS

The current implementation is fairly slack and is slow on medium to large N.
A table of cumulative totients is built and retained for the diagonal X+Y
sum used.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::CoprimeColumns>,
L<Math::PlanePath::RationalsTree>,
L<Math::PlanePath::PythagoreanTree>

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
