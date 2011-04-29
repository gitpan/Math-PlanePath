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


package Math::PlanePath::ZOrderCurve;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX qw(floor ceil);

use vars '$VERSION', '@ISA';
$VERSION = 23;

use Math::PlanePath;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant n_start => 0;
use constant x_negative => 0;
use constant y_negative => 0;

sub n_to_xy {
  my ($self, $n) = @_;
  ### ZOrderCurve n_to_xy(): $n
  if ($n < 0
      || $n-1 == $n) {  # infinity
    return;
  }

  if (int($n) != $n) {
    my ($x1,$y1) = $self->n_to_xy(floor($n));
    my ($x2,$y2) = $self->n_to_xy(ceil($n));
    return (($x1+$x2)/2, ($y1+$y2)/2);
  }

  my $x = my $y = ($n&0); # inherit
  my $bit = $x|1;  # inherit
  while ($n) {
    ### $x
    ### $y
    ### $n
    ### $bit
    if ($n & 1) {
      $x += $bit;
    }
    if ($n & 2) {
      $y += $bit;
    }
    $n >>= 2;
    $bit <<= 1;
  }

  ### is: "$x,$y"
  return ($x, $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### ZOrderCurve xy_to_n(): "$x, $y"

  $x = floor($x + 0.5);
  $y = floor($y + 0.5);
  if ($x < 0 || $y < 0) {
    return undef;
  }
  my $xmod = 2 + ($self->{'wider'} || 0);

  my $n = ($x & 0); # inherit
  my $nbit = 1;
  while ($x || $y) {
    if ($x & 1) {
      $n |= $nbit;
    }
    $x >>= 1;
    $nbit <<= 1;

    if ($y & 1) {
      $n |= $nbit;
    }
    $y >>= 1;
    $nbit <<= 1;
  }
  return $n;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }
  if ($y2 < 0 || $x2 < 0) {
    return (1, 0); # rect all negative, no N
  }

  # monotonic increasing in $x and $y directions
  return ($self->xy_to_n (max(0,min($x1,$x2)), max(0,min($y1,$y2))),
          $self->xy_to_n (max($x1,$x2), max($y1,$y2)));
}

1;
__END__

  # if (my $xmod = $self->{'wider'}) {
  # 
  #   $xmod += 2;
  #   ### $xmod
  # 
  #   my $xbit = 1;
  #   my $ybit = 1;
  #   while ($n) {
  #     ### $x
  #     ### $y
  #     ### $n
  #     ### $xbit
  #     ### $ybit
  #     $x += ($n % $xmod) * $xbit;
  #     $n = floor ($n / $xmod);
  #     $xbit *= $xmod;
  # 
  #     if ($n & 1) {
  #       $y += $ybit;
  #     }
  #     $n >>= 1;
  #     $ybit <<= 1;
  #   }
  # } else {

  # my $xmod = 2 + ($self->{'wider'} || 0);
  # 
  # my $n = 0;
  # my $npos = 1;
  # while ($x || $y) {
  #   if ($y & 1) {
  #     $n += $npos;
  #   }
  #   $y >>= 1;
  #   $npos <<= 1;
  # 
  # $n += ($x % $xmod) * $npos;
  #   $x = int ($x / $xmod);
  #   $npos *= $xmod;

=for stopwords Ryde Math-PlanePath Karatsuba undrawn

=head1 NAME

Math::PlanePath::ZOrderCurve -- 2x2 self-similar Z shape quadrant traversal

=head1 SYNOPSIS

 use Math::PlanePath::ZOrderCurve;
 my $path = Math::PlanePath::ZOrderCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path puts points in a self-similar Z pattern described by G.M. Morton,

      7  |   42  43  46  47  58  59  62  63
      6  |   40  41  44  45  56  57  60  61
      5  |   34  35  38  39  50  51  54  55
      4  |   32  33  36  37  48  49  52  53
      3  |   10  11  14  15  26  27  30  31
      2  |    8   9  12  13  24  25  28  29
      1  |    2   3   6   7  18  19  22  23
     y=0 |    0   1   4   5  16  17  20  21  64  ...
         +--------------------------------
          x=0   1   2   3   4   5   6   7

The first four points make a "Z" shape if written with Y going downwards
(inverted if drawn upwards as above),

     0---1       y=0
        /
      /
     2---3       y=1

Then groups of those are arranged as a further Z, etc, doubling in size each
time.

     0   1      4   5       y=0
     2   3 ---  6   7       y=1
             /
            /
           /
     8   9 --- 12  13       y=2
    10  11     14  15       y=3

Within an power of 2 square 2x2, 4x4, 8x8, 16x16 etc (2^k)x(2^k), all the N
values 0 to 2^(2*k)-1 are within the square.  The top right corner 3, 15,
63, 255 etc of each is the 2^(2*k)-1 maximum.

=head2 Power of 2 Values

Plotting N values related to powers of 2 can come out as interesting
patterns.  For example displaying the N's which have no digit 3 in their
base 4 representation gives

    * 
    * * 
    *   * 
    * * * * 
    *       * 
    * *     * * 
    *   *   *   * 
    * * * * * * * * 
    *               * 
    * *             * * 
    *   *           *   * 
    * * * *         * * * * 
    *       *       *       * 
    * *     * *     * *     * * 
    *   *   *   *   *   *   *   * 
    * * * * * * * * * * * * * * * * 

The 0,1,2 and not 3 makes a little 2x2 "L" at the bottom left, then
repeating at 4x4 with again the whole "3" position undrawn, and so on.  The
blanks are a visual representation of the multiplications saved by recursive
use of the Karatsuba multiplication algorithm.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::ZOrderCurve-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.  The lines don't overlap, but the lines between bit
squares soon become rather long and probably of very limited use.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x,$y>.  Each integer N is
considered the centre of a unit square and an C<$x,$y> within that square
returns N.

=back

=head1 FORMULAS

=head2 N to X,Y

The coordinate calculation is simple.  The bits of X and Y are simply every
second bit of N.  So if N = binary 101010 then X=000 and Y=111 in binary,
which is the N=42 shown above at X=0,Y=7.

=head2 N Range

Within each row the N values increase as X increases, and conversely within
each column N increases with increasing Y.  So for a given rectangle the
smallest N is at the lower left corner (smallest X and smallest Y), and the
biggest N is at the upper right (biggest X and biggest Y).

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::HilbertCurve>,
L<Math::PlanePath::PeanoCurve>

C<http://www.jjj.de/fxt/#fxtbook> (section 1.31.2)

L<Algorithm::QuadTree>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Math-PlanePath is Copyright 2010, 2011 Kevin Ryde

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
