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


# PowerPart has mostly square-free for X/Y > 1/2, then wedge of mostly
# multiple of 4, then mostly multiple of 16, then wedge of higher powers
# of 2.  Similar in AYT.



package Math::PlanePath::FractionsTree;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 67;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant class_x_negative => 0;
use constant class_y_negative => 0;

use constant parameter_info_array =>
  [
   { name       => 'tree_type',
     share_key  => 'tree_type_fractions',
     type       => 'enum',
     default    => 'Kepler',
     choices    => ['Kepler'],
   },
  ];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new (@_);
  $self->{'tree_type'} ||= 'Kepler';
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### FractionsTree n_to_xy(): "$n"

  if ($n < 1) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  # FIXME: what to do for fractional $n?
  {
    my $int = int($n);
    if ($n != $int) {
      ### frac ...
      my $frac = $n - $int;  # inherit possible BigFloat/BigRat
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      ### x1,y1: "$x1, $y1"
      ### x2,y2: "$x2, $y2"
      ### dx,dy: "$dx, $dy"
      ### result: ($frac*$dx + $x1).', '.($frac*$dy + $y1)
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int;
  }

  my $zero = ($n * 0);  # inherit bignum 0
  my $one = $zero + 1;  # inherit bignum 1

  # my $tree_type = $self->{'tree_type'};
  # if ($tree_type eq 'Kepler')

  {
    ### Kepler tree ...

    #       X/Y
    #     /     \
    # X/(X+Y)  Y/(X+Y)
    #
    # (1 0) (x) = ( x )     (a b) (1 0) = (a+b b)   digit 0
    # (1 1) (y)   (x+y)     (c d) (1 1)   (c+d d)
    #
    # (0 1) (x) = ( y )     (a b) (0 1) = (b a+b)   digit 1
    # (1 1) (y)   (x+y)     (c d) (1 1)   (d c+d)

    my $a = $one;     # initial  (1 0)
    my $b = $zero;    #          (0 1)
    my $c = $zero;
    my $d = $one;
    while ($n > 1) {
      ### digit: ($n % 2).''
      ### at: "($a $b)"
      ### at: "($c $d)"
      if ($n % 2) {      # low to high
        ($a,$b) = ($b, $a+$b);
        ($c,$d) = ($d, $c+$d);
      } else {
        $a += $b;
        $c += $d;
      }
      $n = int($n/2);
    }
    ### final: "($a $b)"
    ### final: "($c $d)"

    # (a b) (1) = (a+b)
    # (c d) (2)   (c+d)
    return ($a+2*$b, $c+2*$d);
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  ### FractionsTree xy_to_n(): "$x,$y   $self->{'tree_type'}"

  if (_is_infinite($x)) { return $x; }
  if (_is_infinite($y)) { return $y; }
  if ($x < 1 || $y < 2 || $x >= $y) {
    return undef;
  }

  my $zero = $x * 0 * $y;   # inherit bignum 0
  my $one = ($zero + 1);    # inherit bignum 1

  #       X/Y
  #     /     \
  # X/(X+Y)  Y/(X+Y)
  #
  # (x,y) <- (x, y-x)  digit 0
  # (x,y) <- (y-x, x)  digit 1
  #
  my $n = $zero;
  my $power = $one;   # bits generated low to high
  for (;;) {
    ### at: "$x,$y n=$n"
    if ($y <= 2) {
      if ($x == 1 && $y == 2) {
        return $n + $power;  # plus high bit
      } else {
        return undef;
      }
    }
    ($y -= $x) || return undef;  # common factor
    if ($x > $y) {
      ($x,$y) = ($y,$x);
      $n += $power;
    }
    $power *= 2;
  }
}


# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### rect_to_n_range()

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### $x2
  ### $y2


  #   |    /
  #   |   / x1
  #   |  /  +-----y2
  #   | /   |
  #   |/    +-----
  #
  if ($x2 < 1 || $y2 < 2 || $x1 >= $y2) {
    ### no values, rect outside upper octant ...
    return (1,0);
  }

  my $zero = ($x1 * 0 * $y1 * $x2 * $y2);  # inherit bignum
  ### $zero

  if ($x2 >= $y2) { $x2 = $y2-1; }
  if ($x1 < 1) { $x1 = 1; }
  if ($y1 < 2) { $y1 = 2; }

  # big x2, small y1
  # big y2, small x1
  # my $level = _bingcd_max ($y2,$x1);
  ### $level

  my $level = $y2;
  return (1, ($zero+2) ** $level);
}

sub _bingcd_max {
  my ($x,$y) = @_;
  ### _bingcd_max(): "$x,$y"

  if ($x < $y) { ($x,$y) = ($y,$x) }

  ### div: int($x/$y)
  ### bingcd: int($x/$y) + $y

  return int($x/$y) + $y + 1;
}

1;
__END__

=for stopwords eg Ryde OEIS ie Math-PlanePath coprime RationalsTree Harmonices Mundi octant onwards Aiton

=head1 NAME

Math::PlanePath::FractionsTree -- fractions by tree

=head1 SYNOPSIS

 use Math::PlanePath::FractionsTree;
 my $path = Math::PlanePath::FractionsTree->new (tree_type => 'Kepler');
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path enumerates fractions X/Y in the range 0 E<lt> X/Y E<lt> 1 and in
reduced form, ie. X and Y having no common factor.

Fractions are traversed by rows of a binary tree which effectively
represents a coprime pair X,Y by the steps of the binary greatest common
divisor algorithm which would prove X,Y coprime.  The steps left or right
are encoded/decoded as an N value.

=head2 Kepler Tree

The only tree currently is by Johannes Kepler, though in principle some bit
reversal etc variations such as in RationalsTree would be possible.

    N=1                             1/2
                              ------   ------
    N=2 to N=3             1/3               2/3
                          /    \            /   \
    N=4 to N=7         1/4      3/4      2/5      3/5
                       | |      | |      | |      | |
    N=8 to N=15     1/5  4/5  3/7 4/7  2/7 5/7  3/8 5/8

A node descends as

          X/Y
        /     \
    X/(X+Y)  Y/(X+Y)

Kepler described the tree as starting at 1, ie. 1/1, which descends to two
identical 1/2 and 1/2.  For the code here a single copy starting from 1/2 is
used.

Plotting the N values by X,Y is as follows.  Since it's only fractions
X/YE<lt>1, ie. XE<lt>Y, all points are above the X=Y diagonal.  The unused
X,Y positions are where X and Y have a common factor.  For example X=2,Y=6
have common factor 2 so is never reached.
             
    12  |    1024                  26        27                1025
    11  |     512   48   28   22   34   35   23   29   49  513     
    10  |     256        20                  21       257          
     9  |     128   24        18   19        25  129               
     8  |      64        14        15        65                    
     7  |      32   12   10   11   13   33                         
     6  |      16                  17                              
     5  |       8    6    7    9                                   
     4  |       4         5                                        
     3  |       2    3                                             
     2  |       1                                                  
     1  |
    Y=0 |   
         ----------------------------------------------------------
          X=0   1    2    3    4    5    6    7    8    9   10   11

The X=1 vertical is the fractions 1/Y at the left end of each tree row,
which is

    Nstart=2^level

The diagonal X=Y-1, fraction K/(K+1), is the second in each row, at
N=Nstart+1.  That's the maximum X/Y in each level.

The N values in the upper octant, ie. above the line Y=2*X, are even and
those below that line are odd.  This arises since XE<lt>Y so the left leg
X/(X+Y) E<lt> 1/2 and the right leg Y/(X+Y) E<gt> 1/2.  The left is an even
N and the right an odd N.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over

=item C<$path = Math::PlanePath::FractionsTree-E<gt>new ()>

Create and return a new path object.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

Return a range of N values which occur in a rectangle with corners at
C<$x1>,C<$y1> and C<$x2>,C<$y2>.  The range is inclusive.

For reference, C<$n_hi> can be quite large because within each row there's
only one new 1/Y fraction.  So if X=1 is included then roughly C<$n_hi =
2**max(x,y)>.

=back

=head1 OEIS

The trees are in Sloane's Online Encyclopedia of Integer Sequences in the
following forms

    http://oeis.org/A002487   (etc)

    A020651  - Kepler numerators (RationalsTree AYT denominators)
    A086592  - Kepler denominators
    A086593  - Kepler denominators every second value, and sum X+Y
    A020650  - difference Y-X (RationalsTree AYT numerators)

The tree descends as X/(X+Y) and Y/(X+Y) so the denominators are in pairs of
two X+Y each time, after the initial 1/2.  A086593 is every second value,
starting at 2, eliminating the duplication.  This is also the sum X+Y (from
value 3 onwards), as can be seen by thinking of writing a node as the X+Y
which would be the denominators it descends to.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::RationalsTree>,
L<Math::PlanePath::CoprimeColumns>,
L<Math::PlanePath::PythagoreanTree>

L<Math::NumSeq::SternDiatomic>

Johannes Kepler, "Harmonices Mundi" Book III.  Excerpt of translation by
Aiton, Duncan and Field at

    http://ndirty.cute.fi/~karttu/Kepler/a086592.htm

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
# compile-command: "math-image --path=FractionsTree --all --scale=10"
# End:
#
# math-image --path=FractionsTree --all --output=numbers