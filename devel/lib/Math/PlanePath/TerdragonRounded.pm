# mostly working


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


# math-image --path=TerdragonRounded --all --output=numbers
# math-image --path=TerdragonRounded,radix=5 --lines
#


package Math::PlanePath::TerdragonRounded;
use 5.004;
use strict;
use List::Util 'max';

use vars '$VERSION', '@ISA';
$VERSION = 74;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;
*_digit_split_lowtohigh = \&Math::PlanePath::_digit_split_lowtohigh;

use Math::PlanePath::TerdragonCurve;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;

*parameter_info_array   # arms
  = \&Math::PlanePath::TerdragonCurve::parameter_info_array;
*arms_count = \&Math::PlanePath::TerdragonCurve::arms_count;
*new = \&Math::PlanePath::TerdragonCurve::new;

sub n_to_xy {
  my ($self, $n) = @_;
  ### TerdragonRounded n_to_xy(): $n

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

  my $arms_count = $self->{'arms'};
  my $arm = $n % $arms_count;
  $n = int($n/$arms_count);

  my $pair = $n % 2;
  $n = int($n/2);

  my ($x, $y) = $self->Math::PlanePath::TerdragonCurve::n_to_xy
    ((9*$n + ($pair ? 4 : 2)) * $arms_count + $arm);

  ### is: (($x+3*$y)/2).", ".(($y-$x)/2)

  return (($x+3*$y)/2, ($y-$x)/2);  # rotate -60
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### TerdragonRounded xy_to_n(): "$x, $y"

  if (($x+$y) % 2) {
    return undef;
  }

  ($x,$y) = (($x-3*$y)/2,   # rotate +60
             ($x+$y)/2);
  ### rot: "$x,$y"

  my @n_list = $self->Math::PlanePath::TerdragonCurve::xy_to_n_list ($x, $y);
  ### @n_list

  my $arms_count = $self->{'arms'};
  foreach my $n (@n_list) {
    my $arm = $n % $arms_count;
    $n = int($n/$arms_count);

    if (($n % 9) == 2) {
      return (2*int(($n-2)/9))*$arms_count + $arm;
    }
    if (($n % 9) == 4) {
      return (2*int(($n-4)/9) + 1)*$arms_count + $arm;
    }
  }
  return undef;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  # my $xmax = int(_max(abs($x1),abs($x2))) + 1;
  # my $ymax = int(_max(abs($y1),abs($y2))) + 1;
  # return (0,
  #         ($xmax*$xmax + 3*$ymax*$ymax)
  #         * 1
  #         * $self->{'arms'});

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  # FIXME: How much wider ?
  # Might matter when TerdragonCurve becomes exact.
  $x1 = int (($x1-5)/3);
  $y1 = int (($y1-5)/3);
  $x2 = int (($x2+5)/3);
  $y2 = int (($y2+5)/3);
  
  my ($n_lo, $n_hi) = $self->Math::PlanePath::TerdragonCurve::rect_to_n_range
    ($x1,$y1, $x2,$y2);
  if ($n_hi >= $n_hi) {
    $n_lo *= 2;
    $n_hi = 2*$n_hi + 1;
  }
  return ($n_lo, $n_hi);
}

1;
__END__

=for stopwords Guiseppe Terdragon Terdragon's eg Sur une courbe qui remplit toute aire Mathematische Annalen Ryde OEIS ZOrderCurve ie TerdragonCurve Math-PlanePath versa Online Radix radix HilbertCurve

=head1 NAME

Math::PlanePath::TerdragonRounded -- 3x3 self-similar quadrant traversal

=head1 SYNOPSIS

 use Math::PlanePath::TerdragonRounded;
 my $path = Math::PlanePath::TerdragonRounded->new;
 my ($x, $y) = $path->n_to_xy (123);

 # or another radix digits ...
 my $path5 = Math::PlanePath::TerdragonRounded->new (radix => 5);

=head1 DESCRIPTION

This is a version of the TerdragonCurve with rounded-off corners,

=cut

# math-image --path=TerdragonRounded --all --output=numbers_dash --size=132x70

=pod

    ...         44----43                                   14
      \        /        \
       46----45          42                                13
                        /
                40----41                                   12
               /
             39          24----23          20----19        11
               \        /        \        /        \
                38    25          22----21          18     10
               /        \                          /
       36----37          26----27          16----17         9
      /                          \        /
    35          32----31          28    15                  8
      \        /        \        /        \
       34----33          30----29          14               7
                                          /
                                  12----13                  6
                                 /
                               11           8-----7         5
                                 \        /        \
                                  10-----9           6      4
                                                   /
                                            4-----5         3
                                          /
                                         3                  2
                                          \
                                            2               1
                                          /
                             .     0-----1             <- Y=0

     ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^
    -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6

=head2 Arms

Multiple copies of the curve can be selected, each advancing successively.
Like the main TerdragonCurve the plain rounded curve is 1/6 of the plane and
6 arms rotated by 60, 120, 180, 240 and 300 degrees mesh together perfectly.

C<arms =E<gt> 6> begins as follows.  N=0,6,12,18,etc is the first arm (like
the plain curve above), then N=1,7,13,19 the second copy rotated 60 degrees,
N=2,8,14,20 the third rotated 120, etc.

=cut

# math-image --path=TerdragonRounded,arms=6 --all --output=numbers_dash --size=80x30

=pod

    arms=>6              43----37          72--...
                        /        \        /
               ...    49          31    66          48----42
               /        \        /        \        /        \
             73          55    25          60----54          36
               \        /        \                          /
                67----61          19----13          24----30
                                          \        /
       38----32          14-----8           7    18          71---...
      /        \        /        \        /        \        /
    44          26----20           2     1          12    65
      \                                            /        \
       50----56           9     3     .     0-----6          59----53
               \        /                                            \
    ...         62    15           4     5          23----29          47
      \        /        \        /        \        /        \        /
       74----68          21    10          11----17          35----41
                        /        \
                33----27          16----22          64----70
               /                          \        /        \
             39          57----63          28    58          76
               \        /        \        /        \        /
                45----51          69    34          52    ...
                                 /        \        /
                          ...--75          40----46

     ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^
    -11-10-9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7  8  9 10 11

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::TerdragonRounded-E<gt>new ()>

=item C<$path = Math::PlanePath::TerdragonRounded-E<gt>new (arms =E<gt> $count)>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::TerdragonCurve>,
L<Math::PlanePath::DragonRounded>

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
