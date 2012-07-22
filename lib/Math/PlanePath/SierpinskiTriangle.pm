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


# Maybe:
#
# rule 22 includes the midpoint between adjacent leaf points.
# math-image --path=CellularRule,rule=22 --all --text
#
# rule 60 right hand octant
# rule 102 left hand octant
# math-image --path=CellularRule,rule=60 --all
# math-image --path=CellularRule,rule=102 --all
# align=left
# align=right
# align=centre_spread
#
# rule 126 extra cell to the inward side of each
# math-image --path=CellularRule,rule=60 --all --text
# extra_cell=inward
# extra_cell=midleaf
#
# cf rule 150 double ups, something base 2 instead
# math-image --path=CellularRule,rule=150 --all
#
# cf rule 182 filled gaps
# math-image --path=CellularRule,rule=182 --all

# math-image --path=SierpinskiTriangle --all --scale=5
# math-image --path=SierpinskiTriangle --all --output=numbers
# math-image --path=SierpinskiTriangle --all --text --size=80

# Number of cells in a row:
#    numerator of (2^k)/k!
#    2^(number of 1 bits in y)
#
# A080263


package Math::PlanePath::SierpinskiTriangle;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 82;
use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_divrem_mutate = \&Math::PlanePath::_divrem_mutate;

use Math::PlanePath::ZOrderCurve;
*_digit_join_lowtohigh = \&Math::PlanePath::ZOrderCurve::_digit_join_lowtohigh;

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'round_down_pow',
  'digit_split_lowtohigh';

use Math::PlanePath::CellularRule54;
*_rect_for_V = \&Math::PlanePath::CellularRule54::_rect_for_V;

# uncomment this to run the ### lines
#use Smart::Comments;

# Not quite ready.
# use constant parameter_info_array =>
#   [
#    {
#     name      => 'align',
#     type      => 'enum',
#     share_key => 'align_trl',
#     default   => 'triangular',
#     choices   => ['triangular', 'right', 'left','diagonal'],
#    },
#   ];

use constant class_y_negative => 0;
sub n_start {
  my ($self) = @_;
  return $self->{'n_start'};
}
sub x_negative {
  my ($self) = @_;
  return ($self->{'align'} ne 'right');
}

sub new {
  my $self = shift->SUPER::new(@_);
  $self->{'n_start'} ||= 0;
  $self->{'align'} ||= 'triangular';
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### SierpinskiTriangle n_to_xy(): $n

  # written as $n-n_start() rather than "-=" so as to provoke an
  # uninitialized value warning if $n==undef
  $n = $n - $self->{'n_start'};

  # this frac behaviour slightly unspecified yet
  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;
    if ($frac >= 0.5) {
      $frac -= 1;
      $int += 1;
    } elsif ($frac < -0.5) {
      $frac += 1;
      $int -= 1;
    }
    $n = $int;
  }

  if ($n < 0) {
    return;
  }
  if ($n == 0 || is_infinite($n)) {
    return ($n,$n);
  }

  my ($power, $level) = round_down_pow ($n, 3);
  ### $power
  ### $level

  my $y = 2**$level;
  my @ybits = ($y);
  $n -= $power;
  my $factor = 2;

  # find the cumulative rowpoints total <= $n, being the left of the row
  # containing $n
  #
  while (--$level >= 0) {
    $power /= 3;
    my $rem = $n - $power*$factor;

    ### $n
    ### $power
    ### $factor
    ### consider: $power*$factor
    ### $rem

    if ($rem >= 0) {
      $n = $rem;
      my $ybit = 2**$level;
      $y += $ybit;
      push @ybits, $ybit;
      $factor *= 2;
    }
  }
  ### remaining n: $n
  ### assert: $n >= 0
  ### assert: $n < $factor

  # now $n is offset into the row
  #
  my $x = 0;
  foreach my $digit (digit_split_lowtohigh($n,2)) {
    my $ybit = pop @ybits;
    if ($digit) {
      $x += $ybit;
    }
  }

  ### final: "$x,$y"
  if ($self->{'align'} eq 'right') {
    return ($x, $y);
  } elsif ($self->{'align'} eq 'left') {
    return ($x-$y, $y);
  } elsif ($self->{'align'} eq 'diagonal') {
    return ($x, $y-$x);
  } else { # triangular
    return (-$y+2*$x, $y);
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### SierpinskiTriangle xy_to_n(): "$x, $y"

  $y = round_nearest ($y);
  $x = round_nearest($x);

  if ($self->{'align'} eq 'diagonal') {
    $y += $x;
  } elsif ($self->{'align'} eq 'left') {
    $x += $y;
  } elsif ($self->{'align'} eq 'triangular') {
    $x += $y;
    if (_divrem_mutate ($x, 2)) {
      # if odd point
      return undef;
    }
  }

  if (is_infinite($y)) {
    return ($y);
  }
  if ($y < 0) {
    return undef;
  }

  if ($x < 0 || $x > $y) {
    # if outside horiz range
    ### not odd point in pyramid, no point ...
    return undef;
  }
  ### adjusted x: $x

  my $zero = ($y * 0);
  my $n = $zero;          # inherit bignum 0
  my $npower = $zero+1;   # inherit bignum 1

  my @x = digit_split_lowtohigh($x,2);
  my @y = digit_split_lowtohigh($y,2);

  my @nx;
  foreach my $i (0 .. $#y) {
    if ($y[$i]) {
      $n = 2*$n + $npower;
      push @nx, $x[$i] || 0;   # low to high
    } else {
      if ($x[$i]) {
        return undef;
      }
    }
    $npower *= 3;
  }

  ### n at left end of y row: $n
  ### n offset for x: @nx

  return $n + _digit_join_lowtohigh(\@nx,2,$zero) + $self->{'n_start'};
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### SierpinskiTriangle rect_to_n_range(): "$x1,$y1, $x2,$y2"

  if ($self->{'align'} eq 'diagonal') {
    $y1 = round_nearest ($y1);
    $y2 = round_nearest ($y2);
    if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1) }

    $x1 = round_nearest ($x1);
    $x2 = round_nearest ($x2);
    if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1) }

    if ($x2 < 0 || $y2 < 0) {
      return (1,0);
    }
    if ($x1 < 0) { $x1 *= 0; }
    if ($y1 < 0) { $y1 *= 0; }

    return ($self->xy_to_n(0, $x1+$y1),
            $self->xy_to_n($x2+$y2, 0));
  }

  ($x1,$y1, $x2,$y2) = _rect_for_V ($x1,$y1, $x2,$y2)
    or return (1,0); # rect outside pyramid

  return ($self->xy_to_n($self->{'align'} eq 'right' ? 0 : -$y1,
                         $y1),
          $self->xy_to_n($self->{'align'} eq 'left' ? 0 : $y2,
                         $y2));
}

# ENHANCE-ME: calculate by the bits of n, not by X,Y
sub tree_n_children {
  my ($self, $n) = @_;
  if ($n < 0) {
    return;
  }
  my ($x,$y) = $self->n_to_xy($n);
  $y += 1;
  my $n1 = $self->xy_to_n($x - ($self->{'align'} ne 'right'), $y);
  my $n2 = $self->xy_to_n($x + ($self->{'align'} ne 'left'),$y);
  return ((defined $n1 ? ($n1) : ()),
          (defined $n2 ? ($n2) : ()));
}
sub tree_n_parent {
  my ($self, $n) = @_;
  if ($n < 1) {
    return undef;
  }
  my ($x,$y) = $self->n_to_xy($n);
  $y -= 1;
  if (defined (my $n = $self->xy_to_n($x-($self->{'align'} ne 'left'), $y))) {
    return $n;
  }
  return $self->xy_to_n($x+($self->{'align'} ne 'right'),$y);
}

1;
__END__

=for stopwords eg Ryde Sierpinski Nlevel ie Ymin Ymax SierpinskiArrowheadCentres OEIS Online rowpoints Nleft Math-PlanePath Gould's Nright

=head1 NAME

Math::PlanePath::SierpinskiTriangle -- self-similar triangular path traversal

=head1 SYNOPSIS

 use Math::PlanePath::SierpinskiTriangle;
 my $path = Math::PlanePath::SierpinskiTriangle->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

X<Sierpinski, Waclaw>This is an integer version of the Sierpinski triangle
with cells numbered horizontally across each row.

    65  66  67  68  69  70  71  72  73  74  75  76  77  78  79  80   15
      57      58      59      60      61      62      63      64     14
        49  50          51  52          53  54          55  56       13
          45              46              47              48         12
            37  38  39  40                  41  42  43  44           11
              33      34                      35      36             10
                29  30                          31  32                9
                  27                              28                  8
                    19  20  21  22  23  24  25  26                    7
                      15      16      17      18                      6
                        11  12          13  14                        5
                           9              10                          4
                             5   6   7   8                            3
                               3       4                              2
                                 1   2                                1
                                   0                             <- Y=0

         X= ... -9-8-7-6-5-4-3-2-1 0 1 2 3 4 5 6 7 8 9 ...

The base figure is the first two rows shape N=0 to N=2.  Notice the middle
"." position (X=0,Y=1) is skipped

     1  .  2
        0  

This is replicated twice in the next row pair, as N=3 to N=8.  Then the
resulting four-row shape is replicated twice again in the next four-row
group as N=9 to N=26, etc.

See the SierpinskiArrowheadCentres path to traverse by a connected path,
rather than rows jumping across gaps.

=head2 Row Ranges

The number of points in each row is always a power of 2 according to the
number of 1-bits in Y.  For example Y=13 is binary 1101 which has three 1
bits so in row Y=13 there are 2^3=8 points.  (This count is Gould's
sequence.)

    rowpoints(Y) = 2^(count of 1 bits in Y)

Because the first point is N=0, the N at the left of each row is the
cumulative count of preceding points,

    Nleft(Y) = rowpoints(0) + ... + rowpoints(Y-1)

Since the powers of 2 are always even except for 2^0=1 in row Y=0, this
Nleft(Y) total is always odd.  The self-similar nature of the triangle means
the same is true of the sub-triangles, for example N=31,35,41,47,etc on the
left of the triangle at X=8,Y=8.  This means in particular the primes fall
predominately on the left side of the triangles and sub-triangles.

=head2 Level Sizes

Counting the N=0,1,2 part as level 1, each level goes from

    Nstart = 0
    Nlevel = 3^level - 1     inclusive

For example level 2 is from N=0 to N=3^2-1=9.  Each level doubles in size,

               0  <= Y <= 2^level - 1
    - 2^level + 1 <= X <= 2^level - 1

=head2 Cellular Automaton

The triangle arises in Stephen Wolfram's "rule 90" cellular automaton.  In
each row a cell turns on if one but not both its diagonal predecessors are
on.  That behaves as a mod 2 sum, giving Pascal's triangle mod 2.

    http://mathworld.wolfram.com/Rule90.html

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::SierpinskiTriangle-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 FORMULAS

=head2 N to X,Y

Within a row the X position is given by choosing to keep or clear the 1-bits
of Y.  For example row Y=5 in binary is 0b101 and the positions of the cells
within that row are k = 0b000, 0b001, 0b100, 0b101, and then spread out
across every second cell as Y-2*k.  The Noffset within the row is thus
applied by using the bits of Noffset to select which of the 1 bits of Y to
keep.

=head2 Rectangle to N Range

Since N increases upwards and to the right, the bottom-left and top-right
corners are the N range for a rectangle if those corners are points on the
triangular path.

An easy range can be had just from the Y range by noting the diagonals X=Y
and X=-Y are always visited, so just take the left of Ymin and right of
Ymax,

    Nmin = N at -Ymin,Ymin
    Nmax = N at Ymax,Ymax

Or for less work but a bigger over-estimate, invert the Nlevel formulas
given in L</Row Ranges> above.

    level = floor(log2(Ymax)) + 1
    Nmax = 3^level - 1

For example Y=11, level=floor(log2(11))+1=4, so Nmax=3^4-1=80, which is the
end of the Y=15 row, ie. rounded up to the top of the Y=8 to Y=15
replication.

=head2 OEIS

The Sierpinski Triangle is in Sloane's Online Encyclopedia of Integer
Sequences in various forms,

    http://oeis.org/A001316    etc

    A001316   number of cells in each row (Gould's sequence)
    A001317   row cells 0 or 1 as binary number
    A047999   0,1 cells by rows (every second point)
    A106344   0,1 cells by upwards diagonals dX=3,dY=1
    A006046   Nleft, cumulative number of cells up to row N
    A074330   Nright, right hand end of each row (starting Y=1)

A001316 is the "rowpoints" Gould's sequence noted above.  A006046 is the
cumulative total of that sequence which is the "Nleft" above, and A074330 is
1 less for "Nright".

The path uses every second point to make a triangular lattice (see
L<Math::PlanePath/Triangular Lattice>).  The 0/1 pattern in A047999 of a row
Y=k is therefore every second point X=-k, X=-k+2, X=-k+4, etc for k+1 many
points through to X=k inclusive.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SierpinskiArrowhead>,
L<Math::PlanePath::SierpinskiArrowheadCentres>

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
