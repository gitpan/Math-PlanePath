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


# A160410 cellular corner grows 3
#   A130665 4*3^onescount
# http://www.polprimos.com/imagenespub/polca023.jpg
#
# A160414 same starting from one cell
# http://www.polprimos.com/imagenespub/polca025.jpg

#          18 17
# 14 13 12 11 16
# 15  6  5 10
#  3  2  4  9
#  0  1  7  8


package Math::PlanePath::LCornerReplicate;
use 5.004;
use strict;
#use List::Util 'max','min';
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 91;
use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_divrem = \&Math::PlanePath::_divrem;
*_divrem_mutate = \&Math::PlanePath::_divrem_mutate;

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'round_down_pow',
  'bit_split_lowtohigh',
  'digit_split_lowtohigh',
  'digit_join_lowtohigh';

use Math::PlanePath::UlamWarburtonQuarter;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant n_start => 0;
use constant class_x_negative => 0;
use constant class_y_negative => 0;

# state=0   state=4   state=8   state=12
# 3 2       2 1       1 0       0 3
# 0 1       3 0       2 3       1 2

my @next_state = (0,12,0,4, 4,0,4,8, 8,4,8,12, 12,8,12,0);
my @digit_to_x = (0,1,1,0, 1,1,0,0, 1,0,0,1, 0,0,1,1);
my @digit_to_y = (0,0,1,1, 0,1,1,0, 1,1,0,0, 1,0,0,1);
my @yx_to_digit = (0,1,3,2, 3,0,2,1, 2,3,1,0, 1,2,0,3);
my @min_digit = (0,0,1,0, 0,1,3,2, 2,undef,undef,undef,
                 3,0,0,2, 0,0,2,1, 1,undef,undef,undef,
                 2,2,3,1, 0,0,1,0, 0,undef,undef,undef,
                 1,1,2,0, 0,2,0,0, 3);
my @max_digit = (0,1,1,3, 3,2,3,3, 2,undef,undef,undef,
                 3,3,0,3, 3,1,2,2, 1,undef,undef,undef,
                 2,3,3,2, 3,3,1,1, 0,undef,undef,undef,
                 1,2,2,1, 3,3,0,3, 3);

sub n_to_xy {
  my ($self, $n) = @_;
  ### LCornerReplicate n_to_xy(): $n

  if ($n < 0) { return; }
  if (is_infinite($n)) { return ($n,$n); }
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

  my @ndigits = digit_split_lowtohigh($n,4);

  my $state = 0;
  my (@xbits, @ybits);
  foreach my $i (reverse 0 .. $#ndigits) {    # digits high to low
    $state += $ndigits[$i];
    $xbits[$i] = $digit_to_x[$state];
    $ybits[$i] = $digit_to_y[$state];
    $state = $next_state[$state];
  }

  my $zero = ($n * 0); # inherit bigint 0
  return (digit_join_lowtohigh (\@xbits, 2, $zero),
          digit_join_lowtohigh (\@ybits, 2, $zero));
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### LCornerReplicate xy_to_n(): "$x, $y"

  $x = round_nearest ($x);
  if (is_infinite($x)) { return $x; }
  $y = round_nearest ($y);
  if (is_infinite($y)) { return $y; }

  if ($x < 0 || $y < 0) {
    return undef;
  }

  my @xbits = bit_split_lowtohigh($x);
  my @ybits = bit_split_lowtohigh($y);

  my @ndigits;
  my $state = 0;
  foreach my $i (reverse 0 .. max($#xbits,$#ybits)) {   # high to low
    my $ndigit = $yx_to_digit[$state + 2*($ybits[$i]||0) + ($xbits[$i]||0)];
    $ndigits[$i] = $ndigit;
    $state = $next_state[$state+$ndigit];
  }

  return digit_join_lowtohigh(\@ndigits, 4,
                              $x * 0 * $y); # inherit bignum 0
}

# 3  2  4
# 0  1  5  6
#
# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### LCornerReplicate rect_to_n_range() ...

  $x1 = round_nearest ($x1);
  $y1 = round_nearest ($y1);
  $x2 = round_nearest ($x2);
  $y2 = round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### rect: "x=$x1..$x2  y=$y1..$y2"

  if ($x2 < 0 || $y2 < 0) {
    ### rectangle outside first quadrant ...
    return (1, 0);
  }

  my $zero = ($x1 * 0 * $x2 * $y1 * $y2); # inherit bignum 0
  my $x_min = $zero;
  my $y_min = $zero;
  my $x_max = $zero;
  my $y_max = $zero;

  my ($len, $level) = round_down_pow(max($x2,$y2), 2);
  ### $len
  ### $level
  if (is_infinite($level)) {
    return (0, $level);
  }

  my $min_state = 0;
  my $max_state = 0;
  my (@n_min_digits, @n_max_digits);

  for ( ; $level >= 0; $level--,$len/=2) {
    ### iterate: "level=$level len=$len"
    ### assert: $len == 2 ** $level
    {
      ### at: "min_state=$min_state  x_min=$x_min,y_min=$y_min"
      my $x_cmp = $x_min + $len;
      my $y_cmp = $y_min + $len;
      my $c = ($x1 >= $x_cmp ? 2 : $x2 >= $x_cmp ? 1 : 0)
        + ($y1 >= $y_cmp ? 6 : $y2 >= $y_cmp ? 3 : 0);
      ### $c
      my $digit = $min_digit[3*$min_state
                             + ($x1 >= $x_cmp ? 2 : $x2 >= $x_cmp ? 1 : 0)
                             + ($y1 >= $y_cmp ? 6 : $y2 >= $y_cmp ? 3 : 0)];
      $n_min_digits[$level] = $digit;

      ### cmp: "x_cmp=$x_cmp y_cmp=$y_cmp gives digit=$digit"

      $min_state += $digit;
      if ($digit_to_x[$min_state]) { $x_min += $len; }
      if ($digit_to_y[$min_state]) { $y_min += $len; }
      $min_state = $next_state[$min_state];
    }
    {
      my $x_cmp = $x_max + $len;
      my $y_cmp = $y_max + $len;
      my $digit = $max_digit[3*$max_state
                             + ($x1 >= $x_cmp ? 2 : $x2 >= $x_cmp ? 1 : 0)
                             + ($y1 >= $y_cmp ? 6 : $y2 >= $y_cmp ? 3 : 0)];
      $n_max_digits[$level] = $digit;

      $max_state += $digit;
      if ($digit_to_x[$max_state]) { $x_max += $len; }
      if ($digit_to_y[$max_state]) { $y_max += $len; }
      $max_state = $next_state[$max_state];
    }
  }
  ### end: "x_min=$x_min,y_min=$y_min  min_state=$min_state"
  ### @n_min_digits

  return (digit_join_lowtohigh (\@n_min_digits, 4, $zero),
          digit_join_lowtohigh (\@n_max_digits, 4, $zero));
}
  
1;
__END__

=for stopwords eg Ryde Math-PlanePath Ulam Warburton Nstart OEIS ie

=head1 NAME

Math::PlanePath::LCornerReplicate -- self-similar growth at exposed corners

=head1 SYNOPSIS

 use Math::PlanePath::LCornerReplicate;
 my $path = Math::PlanePath::LCornerReplicate->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is a self-similar "L" shaped corners,

=cut

# math-image --path=LCornerReplicate --all --output=numbers --size=50x9

     7  |   58  57  55  54  46  45  43  42  64 
     6  |   59  56  52  53  47  44  40  41  ...
     5  |   61  60  50  49  35  34  36  39  
     4  |   62  63  51  48  32  33  37  38  
     3  |   14  13  11  10  16  19  31  30  
     2  |   15  12   8   9  17  18  28  29  
     1  |    3   2   4   7  21  20  24  27  
    Y=0 |    0   1   5   6  22  23  25  26  
        +-------------------------------------
          X=0   1   2   3   4   5   6   7   8

The base pattern is the initial N=0,1,2,3 and then when replicating the 1
and 3 sub-parts are rotated -90 and +90 degrees,

    +----------------+
    |     3 |  2     |
    |  ^    |    ^   |
    |   \   |   /    |
    |    \  |  /     |
    | +90   |        |
    |-------+--------|
    |       |    -90 |
    |    ^  |  \     |
    |   /   |   \    |
    |  /    |    v   |
    | /  0  |  1     |
    +----------------+

Groups of 3 points such as N=13,14,15 make little L-shaped parts, except at
the middle single points where a replication begins such as N=4,8,12.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::LCornerReplicate-E<gt>new ()>

Create and return a new path object.

=back

=head1 OEIS

Entreis in Sloane's Online Encyclopedia of Integer Sequences related to this
path include

    http://oeis.org/A062880    (etc)

    A062880    N values on diagonal X=Y (digits 0,2 in base 4)

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::LCornerTree>,
L<Math::PlanePath::UlamWarburtonRule>

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
