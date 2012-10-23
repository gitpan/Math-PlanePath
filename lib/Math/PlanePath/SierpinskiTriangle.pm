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
# rule 126 extra cell to the inward side of each
# math-image --path=CellularRule,rule=60 --all --text
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
#
# cf A080263
#    A067771  vertices of sierpinski graph, joins up replications
#             so 1 less each giving 3*(3^k-1)/2
#




package Math::PlanePath::SierpinskiTriangle;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 91;
use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_divrem_mutate = \&Math::PlanePath::_divrem_mutate;

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'round_down_pow',
  'bit_split_lowtohigh',
  'digit_join_lowtohigh';

# uncomment this to run the ### lines
#use Smart::Comments;

use constant parameter_info_array =>
  [ { name      => 'align',
      share_key => 'align_trld',
      display   => 'Align',
      type      => 'enum',
      default   => 'triangular',
      choices   => ['triangular', 'right', 'left','diagonal'],
      choices_display => ['Triangular', 'Right', 'Left','Diagonal'],
    },
    Math::PlanePath::Base::Generic::_parameter_info_nstart1(),
  ];

my %x_negative = (triangular => 1,
                  left       => 1,
                  right      => 0,
                  diagonal   => 0);
sub x_negative {
  my ($self) = @_;
  return $x_negative{$self->{'align'}};
}
use constant class_y_negative => 0;
use constant default_n_start => 0;
use constant n_frac_discontinuity => .5;

sub dy_minimum {
  my ($self) = @_;
  return ($self->{'align'} eq 'diagonal' ? undef : 0);
}
sub dy_maximum {
  my ($self) = @_;
  return ($self->{'align'} eq 'diagonal' ? undef : 1);
}

#------------------------------------------------------------------------------
sub new {
  my $self = shift->SUPER::new(@_);
  if (! defined $self->{'n_start'}) {
    $self->{'n_start'} = $self->default_n_start;
  }
  $self->{'align'} ||= 'triangular';
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### SierpinskiTriangle n_to_xy(): $n

  # written as $n-n_start() rather than "-=" so as to provoke an
  # uninitialized value warning if $n==undef
  $n = $n - $self->{'n_start'};   # N=0 basis

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
  ### $n
  ### $frac

  if ($n < 0) {
    return;
  }
  if ($n == 0 || is_infinite($n)) {
    return ($n,$n);
  }

  my ($depthbits, $ndepth) = _n0_to_depthbits($n);
  ### $depthbits
  ### $ndepth

  my @nbits = bit_split_lowtohigh($n-$ndepth); # offset into row

  # Where there's a 0-bit in the depth remains a 0-bit.
  # Where there's a 1-bit in the depth takes a bit from Noffset.
  # Small Noffset has less bits than the depth 1s, hence "|| 0".
  #
  my @xbits = map {$_ && (shift @nbits || 0)} @$depthbits;
  ### @xbits

  my $zero = $n * 0;
  my $x = digit_join_lowtohigh (\@xbits,    2, $zero);
  my $y = digit_join_lowtohigh ($depthbits, 2, $zero);

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
  ### adjusted xy: "$x,$y"

  return _right_xy_to_n ($self, $x, $y);
}

sub _right_xy_to_n {
  my ($self, $x, $y) = @_;
  ### _right_xy_to_n() ...

  unless ($x >= 0 && $x <= $y && $y >= 0) {
    ### outside horizontal row range ...
    return undef;
  }
  if (is_infinite($y)) {
    return $y;
  }

  my $zero = ($y * 0);
  my $n = $zero;          # inherit bignum 0
  my $npower = $zero+1;   # inherit bignum 1

  my @xbits = bit_split_lowtohigh($x);
  my @depthbits = bit_split_lowtohigh($y);

  my @nbits;  # N offset into row
  foreach my $i (0 .. $#depthbits) {      # x,y bits low to high
    if ($depthbits[$i]) {
      $n = 2*$n + $npower;
      push @nbits, $xbits[$i] || 0;   # low to high
    } else {
      if ($xbits[$i]) {
        return undef;
      }
    }
    $npower *= 3;
  }

  ### n at left end of y row: $n
  ### n offset for x: @nbits
  ### total: $n + digit_join_lowtohigh(\@nbits,2,$zero) + $self->{'n_start'}

  return $n + digit_join_lowtohigh(\@nbits,2,$zero) + $self->{'n_start'};
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### SierpinskiTriangle rect_to_n_range(): "$x1,$y1, $x2,$y2"

  $y1 = round_nearest ($y1);
  $y2 = round_nearest ($y2);
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1) }

  $x1 = round_nearest ($x1);
  $x2 = round_nearest ($x2);
  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1) }

  if ($self->{'align'} eq 'diagonal') {
    $y2 += $x2;
    $y1 += $x1;
  }
  if ($y2 < 0) {
    return (1, 0);
  }
  if ($y1 < 0) {
    $y1 = 0;
  }
  return (_right_xy_to_n($self,0,$y1),
          _right_xy_to_n($self,$y2,$y2));


  # use Math::PlanePath::CellularRule54;
  # *_rect_for_V = \&Math::PlanePath::CellularRule54::_rect_for_V;
  #
  # if ($self->{'align'} eq 'diagonal') {
  #   if ($x2 < 0 || $y2 < 0) {
  #     return (1,0);
  #   }
  #   if ($x1 < 0) { $x1 *= 0; }
  #   if ($y1 < 0) { $y1 *= 0; }
  #
  #   return ($self->xy_to_n(0, $x1+$y1),
  #           $self->xy_to_n($x2+$y2, 0));
  # }
  #
  # ($x1,$y1, $x2,$y2) = _rect_for_V ($x1,$y1, $x2,$y2)
  #   or return (1,0); # rect outside pyramid
  #
  # return ($self->xy_to_n($self->{'align'} eq 'right' ? 0 : -$y1,
  #                        $y1),
  #         $self->xy_to_n($self->{'align'} eq 'left' ? 0 : $y2,
  #                        $y2));
}

sub tree_n_num_children {
  my ($self, $n) = @_;

  $n = $n - $self->{'n_start'};   # N=0 basis
  if ($n < 0) {
    return undef;
  }
  my ($depthbits, $ndepth) = _n0_to_depthbits($n);
  $n -= $ndepth;  # Noffset into row

  unless (shift @$depthbits) {  # low bit
    # Depth even (or zero), two children under every point.
    return 2;
  }

  # Depth odd, single child under some or all points.
  # When depth==1mod4 it's all points, when depth has more than one
  # trailing 1-bit then it's only some points.
  #
  my $repbit = _divrem_mutate($n,2);
  while (shift @$depthbits) {  # low to high
    if (_divrem_mutate($n,2) != $repbit) {
      return 0;
    }
  }
  return 1;
}
sub tree_n_children {
  my ($self, $n) = @_;

  $n = $n - $self->{'n_start'};   # N=0 basis
  if ($n < 0) {
    return;
  }
  my ($depthbits, $ndepth, $nwidth) = _n0_to_depthbits($n);
  $n -= $ndepth;  # Noffset into row

  if (shift @$depthbits) {
    # Depth odd, single child under some or all points.
    # When depth==1mod4 it's all points, when depth has more than one
    # trailing 1-bit then it's only some points.
    while (shift @$depthbits) {  # depth==3mod4 or more low 1s
      my $repbit = _divrem_mutate($n,2);
      if (($n % 2) != $repbit) {
        return;
      }
    }
    return $n + $ndepth+$nwidth + $self->{'n_start'};

  } else {
    # Depth even (or zero), two children under every point.
    $n = 2*$n + $ndepth+$nwidth + $self->{'n_start'};
    return ($n,$n+1);
  }
}
sub tree_n_parent {
  my ($self, $n) = @_;

  my ($x,$y) = $self->n_to_xy($n)
    or return undef;

  if ($self->{'align'} eq 'diagonal') {
    my $n_parent = $self->xy_to_n($x-1, $y);
    if (defined $n_parent) {
      return $n_parent;
    } else {
      return $self->xy_to_n($x,$y-1);
    }
  }

  $y -= 1;
  my $n_parent = $self->xy_to_n($x-($self->{'align'} ne 'left'), $y);
  if (defined $n_parent) {
    return $n_parent;
  }
  return $self->xy_to_n($x+($self->{'align'} ne 'right'),$y);
}

sub tree_n_to_depth {
  my ($self, $n) = @_;
  ### SierpinskiTriangle n_to_depth(): $n
  $n = $n - $self->{'n_start'};
  if ($n < 0) {
    return undef;
  }
  if (is_infinite($n)) {
    return $n;
  }
  my ($depthbits) = _n0_to_depthbits($n);
  return digit_join_lowtohigh ($depthbits, 2, $n*0);
}
sub tree_depth_to_n {
  my ($self, $depth) = @_;
  return ($depth >= 0 ? _right_xy_to_n($self,0,$depth) : undef);
}

sub _n0_to_depthbits {
  my ($n) = @_;

  if ($n == 0) {
    return ([], 0, 1);
  }

  my ($nwidth, $bitpos) = round_down_pow ($n, 3);
  ### $nwidth
  ### $bitpos

  my @depthbits;
  my $ndepth = 0;
  for (;;) {
    ### at: "n=$n nwidth=$nwidth bitpos=$bitpos depthbits=".join(',',map{$_||0}@depthbits)
    if ($n >= $ndepth + $nwidth) {
      $depthbits[$bitpos] = 1;
      $ndepth += $nwidth;
      $nwidth *= 2;
    } else {
      $depthbits[$bitpos] = 0;
    }
    $bitpos--;
    last unless $bitpos >= 0;
    $nwidth /= 3;
  }

  # Nwidth = 2**count1bits(depth)
  ### @depthbits
  ### assert: $nwidth == (1 << scalar(grep{$_}@depthbits))

  return (\@depthbits, $ndepth, $nwidth);
}

1;
__END__

=for stopwords eg Ryde Sierpinski Nlevel ie Ymin Ymax SierpinskiArrowheadCentres OEIS Online rowpoints Nleft Math-PlanePath Gould's Nend bitand CellularRule Noffset

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
"." position X=0,Y=1 is skipped

    1  .  2
       0

This is replicated twice in the next row pair, as N=3 to N=8.  Then the
resulting four-row shape is replicated twice again in the next four-row
group as N=9 to N=26, etc.

See the SierpinskiArrowheadCentres path to traverse by a connected path,
rather than rows jumping across gaps.

=head2 Row Ranges

The number of points in each row is always a power of 2.  The power is the
count of 1-bits in Y.  For example Y=13 is binary 1101 which has three
1-bits so in row Y=13 there are 2^3=8 points.  (This count is sometimes
called Gould's sequence.)

    rowpoints(Y) = 2^(count of 1 bits in Y)

Because the first point is N=0, the N at the left of each row is the
cumulative count of preceding points,

    Ndepth(Y) = rowpoints(0) + ... + rowpoints(Y-1)

Since the powers of 2 are always even except for 2^0=1 in row Y=0, this
Ndepth(Y) total is always odd.  The self-similar nature of the triangle means
the same is true of the sub-triangles, for example N=31,35,41,47,etc on the
left of the triangle at X=8,Y=8.  This means in particular the primes fall
predominately on the left side of the triangles and sub-triangles.

=head2 Replication Sizes

Counting the N=0,1,2 part as level 1, each replication level goes from

    Nstart = 0
    Nlevel = 3^level - 1     inclusive

For example level 2 is from N=0 to N=3^2-1=9.  Each level doubles in size,

               0  <= Y <= 2^level - 1
    - 2^level + 1 <= X <= 2^level - 1

=head2 Align Parameter

The optional C<align> parameter controls how points are arranged relative to
the Y axis.  The default shown above is "triangular".

C<align=E<gt>"right"> means points to the right of the axis, packed next to
each other and so using an eighth of the plane.

=cut

# math-image --path=SierpinskiTriangle,align=right --all --output=numbers

=pod

    align => "right"

    19 20 21 22 23 24 25 26       7
    15    16    17    18          6
    11 12       13 14             5
     9          10                4
     5  6  7  8                   3
     3     4                      2
     1  2                         1
     0                        <- Y=0

    X=0 1  2  3  4  5  6  7

C<align=E<gt>"left"> is similar but to the left of the Y axis, ie. into
negative X.  The rows are still numbered starting from the left (so it's a
shift across, not a negate of X).

=cut

# math-image --path=SierpinskiTriangle,align=left --all --output=numbers

=pod

    align => "left"

    19 20 21 22 23 24 25 26        7
       15    16    17    18        6
          11 12       13 14        5
              9          10        4
                 5  6  7  8        3
                    3     4        2
                       1  2        1
                          0    <- Y=0

    -7 -6 -5 -4 -3 -2 -1 X=0

"diagonal" put rows on diagonals down from the Y axis to the X axis.  This
uses the whole of the first quadrant, with gaps according to the pattern.

=cut

# math-image --expression='i<=80?i:0' --path=SierpinskiTriangle,align=diagonal --output=numbers

=pod

    align => "diagonal"

     15 | 65       ...
     14 | 57 66
     13 | 49    67
     12 | 45 50 58 68
     11 | 37          69
     10 | 33 38       59 70
      9 | 29    39    51    71
      8 | 27 30 34 40 46 52 60 72
      7 | 19                      73
      6 | 15 20                   61 74
      5 | 11    21                53    75
      4 |  9 12 16 22             47 54 62 76
      3 |  5          23          41          77       ...
      2 |  3  6       17 24       35 42       63 78
      1 |  1     7    13    25    31    43    55    79
    Y=0 |  0  2  4  8 10 14 18 26 28 32 36 44 48 56 64 80
        +-------------------------------------------------
         X=0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15

These diagonals visit all points X,Y where X and Y written in binary don't
have any 1-bits in the same bit positions, ie. where S<X bitand Y> == 0.
For example X=13,Y=3 is not visited because 13=0b1011 and 6=0b0110 both have
bit 0b0010 set.

This bit rule is an easy way to test for visited or not visited cells of the
pattern.  It can be calculated by this diagonal X,Y but then plotted X,X+Y
for the "right" align or X-Y,X+Y for "triangular", as desired.

=head2 Cellular Automaton

The triangle arises in Stephen Wolfram's CellularRule style 1-D cellular
automaton (per L<Math::PlanePath::CellularRule>).

    align           rule
    -----           ----
    "triangular"    18,26,82,90,146,154,210,218
    "right"         60
    "left"          102

    http://mathworld.wolfram.com/Rule90.html
    http://mathworld.wolfram.com/Rule60.html
    http://mathworld.wolfram.com/Rule102.html

=cut

# rule 60 right hand octant
# rule 102 left hand octant
# math-image --path=CellularRule,rule=60 --all
# math-image --path=CellularRule,rule=102 --all

=pod

In each row the rule 18 etc pattern turns a cell "on" in the next row if one
but not both its diagonal predecessors are "on".  This is a mod 2 sum giving
Pascal's triangle mod 2.

Some other cellular rules make variations on the triangle.  Rule 22 is
"triangular" but filling the gap between leaf points such as N=5 and N=6.
Or rule 126 adds an extra point on the inward side of each visited.  And
rule 182 fills in the big gaps leaving just a single-cell empty border
delimiting them.

=head2 N Start

The default is to number points starting N=0 as shown above.  An optional
C<n_start> parameter can give a different start, with the same shape.  For
example starting at 1 (which is the numbering of CellularRule rule=60),

=cut

# math-image --path=SierpinskiTriangle,n_start=1 --expression='i<=27?i:0' --output=numbers

=pod

    n_start => 1

    20    21    22    23    24    25    26    27
       16          17          18          19
          12    13                14    15
             10                      11
                 6     7     8     9
                    4           5
                       2     3
                          1

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::SierpinskiTriangle-E<gt>new ()>

=item C<$path = Math::PlanePath::SierpinskiTriangle-E<gt>new (align =E<gt> $str, n_start =E<gt> $n)>

Create and return a new path object.  C<align> is a string, one of the
following as described above.

    "triangular"   the default
    "right"
    "left"
    "diagonal"

=back

=head2 Descriptive Methods

=over

=item C<$n = $path-E<gt>n_start()>

Return the first N in the path.  This is 0 by default, or the given
C<n_start> parameter.

=back

=head2 Tree Methods

=over

=item C<@n_children = $path-E<gt>tree_n_children($n)>

Return the children of C<$n>, or an empty list if C<$n E<lt> n_start>
(ie. before the start of the path).

The children are the points diagonally up left and right on the next row.
There can be 0, 1 or 2 such points.  At even depth there's 2, on depth=1mod4
there's 1.  On other depths there's some 0s and some 1s (see L</N to Number
of Children>) below).

For example N=3 has two children N=5,N=6.  Then in turn N=5 has just one
child N=9.  And N=6 has no children.  The way points are numbered across a
row means that when there's two children they're consecutive N values.

=item C<$num = $path-E<gt>tree_n_num_children($n)>

Return the number of children of C<$n>, or return C<undef> if
C<$nE<lt>n_start> (ie. before the start of the path).

=item C<$n_parent = $path-E<gt>tree_n_parent($n)>

Return the parent node of C<$n>, or C<undef> if C<$n E<lt>= n_start> (the
top of the triangle).

=item C<$depth = $path-E<gt>tree_n_to_depth($n)>

Return the depth of node C<$n>, or C<undef> if there's no point C<$n>.  In
the "triangular", "right" and "left" alignments this is the same as the Y
coordinate from C<n_to_xy()>.  In the "diagonal" alignment it's X+Y.

=item C<$n = $path-E<gt>tree_depth_to_n($depth)>

=item C<$n = $path-E<gt>tree_depth_to_n_end($depth)>

Return the first or last N at tree level C<$depth>.  The start of the tree
is depth=0 at the origin X=0,Y=0.

This is the N at the left end of each row.  So in the default triangular
alignment it's the same as C<xy_to_n(-$depth,$depth)>.

=back

=head1 FORMULAS

=head2 X,Y to N

For calculation it's convenient to turn the X,Y coordinates into the "right"
alignment style, so that Y is the depth and X in the range 0E<lt>=XE<lt>=Y.

The starting position of each row of the triangle is given turning bits of
the depth into powers-of-3.

    Y = depth = 2^a + 2^b + 2^c + 2^d ...       a>b>c>d...

    Ndepth =         3^a      first N at this depth
             +   2 * 3^b
             + 2^2 * 3^c
             + 2^3 * 3^d
             + ...

For example depth=6=2^2+2^1 starts at Ndepth=3^2+2*3^1=15.  The powers-of-3
are the three parts of the triangle replication.  The power-of-2 doubling is
the doubling of the width of the row on replicating.

Then the bits of X at the positions of the 1-bits in the depth become the
Noffset offset into the row.

               a  b  c  d
    depth    = 10010010010     binary
    X        = m00n00p00q0
    Noffset  =        mnpq

    N = Ndepth + Noffset

For example in depth=6 binary 110 then at X=4=100 take the bits of X where
depth has 1s, which is X=10_ so Noffset=10 binary and N=15+2=17, as per the
"right" table above at X=4,Y=6.

If X has any 1-bits which don't coincide with 1-bits in the depth then that
X,Y is not visited.  For example depth=6=0b110 X=3=0b11 is not visited
because the low bit X=..1 but at that position depth=..0 is not a 1-bit.

=head2 N to Depth

The row containing N can be found by the Ndepth formula shown above.  The
"a" term is the highest 3^a E<lt>= N, thus giving a bit 2^a for the depth.
Then the remainder Nrem = N - 3^a see the highest "b" where 2*3^b E<lt>=
Nrem.  And so on until reaching an Nrem which is too small to subtract any
more terms.

It's convenient to go by bits high to low the prospective depth, deciding at
each bit whether Nrem is big enough that the depth can have a 1-bit there,
or whether it must be a 0-bit.

    a = floor(log3(N))     round down to power-of-3
    pow = 3^a
    Nrem = N - pow

    depth = high 1-bit at bit position "a" (counting from 0)

    factor = 2
    loop bitpos a-1 down to 0
      pow /= 3
      if pow*factor <= Nrem
      then depth 0-bit, factor *= 2
      else depth 1-bit

    factor is 2^count1bits(depth)
    Noffset = Nrem     offset into row
    0 <= Noffset < factor

=head2 N to X,Y

N is turned into depth and Noffset as per above.  X in "right" alignment
style is formed by spreading the bits of Noffset out according to the 1-bits
of the depth.

    depth   = 100110  binary
    Noffset =    abc
    Xright  = a00bc0

For example in depth=5 this spreads out the Noffset bits to give Xright =
000, 001, 100, 101 in binary.

From an X,Y in "right" alignment the other alignments are formed

    alignment   from "right" X,Y
    ---------   ----------------
    triangular     2*X-Y, Y       so -Y <= X < Y
    right          X,     Y       unchanged
    left           X-Y,   Y       so -Y <= X <= 0
    diagonal       X,   Y-X       downwards sloping

=head2 N to Number of Children

The number of children follows a pattern based on the depth.

    depth     number of children
    -----     ------------------

     11    1 0 0 1         1 0 0 1
     10     2   2           2   2
      9      1 1             1 1
      8       2               2
      7        1 0 0 0 0 0 0 1   
      6         2   2   2   2 
      5          1 1     1 1  
      4           2       2   
      3            1 0 0 1   
      2             2   2
      1              1 1
      0               2   

At even depth all points have 2 children.  For example the depth=6 row has
four points all with 2 children each.

At odd depth the number of children is either 1 or 0 according to how the
Noffset into the row matches the trailing 1-bits of the depth.

    depth=...011111 in binary

    Noffset = ...00000   \ num children = 1
            = ...11111   /
            =    other   num children = 0

For example depth=11 is binary 1011 which has low 1-bits "11".  Those bits
of Noffset must be either 00 or 11, so Noffset=..00 or ..11, but not 01 or
10.  Hence the pattern 1,0,0,1,1,0,0,1 reading across the row.

In general when the depth doubles the triangle is replicated twice and the
number of children is carried with it, but not the middle two points.  For
example the triangle of depth=0to3 is replicated twice to make depth=4to7,
but the depth=7 row is not 10011001 of a plain doubling of the depth=3 row,
but instead 10000001 which is the middle two points becoming 0.

=head2 Rectangle to N Range

An easy range can be had just from the Y range by noting the diagonals X=Y
and X=-Y are always visited, so just take the Ndepth of Ymin and Nend of
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
    A001317   rows encoded as numbers with bits 0,1
    A006046   Ndepth, cumulative number of cells up to row N
    A074330   Nend, right hand end of each row (starting Y=1)

A001316 is the "rowpoints" noted above.  A006046 is the cumulative total of
that sequence which is the "Ndepth" above, and A074330 is 1 less for "Nend".

    A047999   0,1 cells by rows
    A106344   0,1 cells by upwards sloping dX=3,dY=1

    align="right"
      A075438   0,1 cells by rows including 0 blanks at left of pyramid

A047999 is every second point in the default triangular lattice, or all
points in align="right" or "left".

    A002487   count points along dX=3,dY=1 slopes
                is the Stern diatomic sequence
    A106345   count points along dX=5,dY=1 slopes

dX=3,dY=1 sloping lines are equivalent to opposite-diagonals dX=-1,dY=1 in
"right" alignment.

    A080263   Dyck encoding of the tree structure
    A080264     same in binary
    A080265     position in list of all balanced binary
    A080268   Dyck encoding breadth-first
    A080269     same in binary
    A080270     position in list of all balanced binary

(See for example L<Math::NumSeq::BalancedBinary/Binary Trees> on encoding
trees as balanced binary.)

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SierpinskiArrowhead>,
L<Math::PlanePath::SierpinskiArrowheadCentres>,
L<Math::PlanePath::CellularRule>

L<Math::NumSeq::SternDiatomic>,
L<Math::NumSeq::BalancedBinary>

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
