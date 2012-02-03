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



# math-image --path=CellularRule --all --scale=10
#
# math-image --path=CellularRule --all --output=numbers --size=80x50


package Math::PlanePath::CellularRule;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 67;

use Math::PlanePath 54; # v.54 for _max()
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::CellularRule54 54; # v.54 for _rect_for_V()
*_rect_for_V = \&Math::PlanePath::CellularRule54::_rect_for_V;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant class_y_negative => 0;
use constant n_frac_discontinuity => .5;

use constant parameter_info_array =>
  [ { name      => 'rule',
      type      => 'integer',
      default   => 30,
      minimum   => 0,
      maximum   => 255,
      width     => 3,
      type_hint => 'cellular_rule',
      description => 'Rule number 0 to 255 encoding what triplets 111 to 000 become in the next row.',
    },
  ];

# rule=1 000->1 goes negative if 001->0 to keep left empty
# so rule&3 == 1
#
# any 001->1, rule&2 goes left initially
#
#
#
sub x_negative {
  my ($self) = @_;
  return (($self->{'rule'} & 2)
          || ($self->{'rule'} & 3) == 1);
}

# cf 60 is right half Sierpinski
#    129 is inverse Sierpinski, except for initial N=1 cell
#    119 etc alternate rows PyramidRows step=4 with 2*Y
#    50 PyramidRows with 2*N
#
my @rule_to_class;
{
  my $store = sub {
    my ($rule, $aref) = @_;
    if ($rule_to_class[$rule] && $rule_to_class[$rule] != $aref) {
      die "Oops, already have rule_to_class[] $rule";
    }
    $rule_to_class[$rule] = $aref;
  };

  $store->(54, [ 'Math::PlanePath::CellularRule54' ]);
  $store->(57, [ 'Math::PlanePath::CellularRule57' ]);
  $store->(99, [ 'Math::PlanePath::CellularRule57', mirror => 1 ]);
  $store->(190, [ 'Math::PlanePath::CellularRule190' ]);
  $store->(246, [ 'Math::PlanePath::CellularRule190', mirror => 1 ]);

  {
    # *******
    # ******
    # *****
    # ****
    # ***
    # **
    # *
    #     111 -> 1   solid
    #     110 -> 1   to right
    #     101        any, doesn't occur
    #     100 -> 1   initial
    #     011 -> 1   vertical
    #     010 -> 1   initial
    #     001 -> 0   not to left
    #     000 -> 0
    my $solid_half = [ 'Math::PlanePath::PyramidRows', step => 1 ];
    $store->(220, $solid_half);
    $store->(252, $solid_half);
  }
  {
    # * * * * * * * *
    #  *   *   *   *
    #   * *     * *
    #    *       *
    #     * * * *
    #      *   *
    #       * *
    #        *
    # 18,26,82,90,146,154,210,218
    # 111      any, doesn't occur
    # 110      any, doesn't occur
    # 101 -> 0
    # 100 -> 1 initial
    # 011      any, doesn't occur
    # 010 -> 0 initial
    # 001 -> 1 initial
    # 000 -> 0 for outsides
    #
    my $sierpinski_triangle = [ 'Math::PlanePath::SierpinskiTriangle',
                                n_start => 1 ];
    foreach my $i (0 .. 255) {
      $store->(($i&0xC8)|0x12, $sierpinski_triangle);
    }
  }
  {
    # left negative line, 2,10,...
    # 111      any, doesn't occur
    # 110      any, doesn't occur
    # 101      any, doesn't occur
    # 100 -> 0 initial
    # 011      any, doesn't occur
    # 010 -> 0 initial
    # 001 -> 1 initial towards left
    # 000 -> 0 for outsides
    #
    my $left_line = [ 'Math::PlanePath::CellularRule::Line',
                      sign => -1 ];
    foreach my $i (0 .. 255) {
      $store->(($i&0xE8)|0x02, $left_line);
    }
  }
  {
    # right positive line, 16,...
    # 111      any, doesn't occur
    # 110      any, doesn't occur
    # 101      any, doesn't occur
    # 100 -> 1 initial
    # 011      any, doesn't occur
    # 010 -> 0 initial
    # 001 -> 0 initial towards left
    # 000 -> 0 for outsides
    #
    my $right_line = [ 'Math::PlanePath::CellularRule::Line',
                       sign => 1 ];
    foreach my $i (0 .. 255) {
      $store->(($i&0xE8)|0x10, $right_line);
    }
  }
  {
    # central vertical line 4,...
    # 111      any
    # 110      any
    # 101      any
    # 100 -> 0
    # 011      any
    # 010 -> 1 initial cell
    # 001 -> 0
    # 000 -> 0
    my $centre_line = [ 'Math::PlanePath::CellularRule::Line',
                        sign => 0 ];
    foreach my $i (0 .. 255) {
      $store->(($i&0xE8)|0x04, $centre_line);
    }
  }
  {
    # solid every second cell, 50,58,114,122,178,186,242,250
    # http://mathworld.wolfram.com/Rule250.html
    # 111      any, doesn't occur
    # 110      any, doesn't occur
    # 101 -> 1 middle
    # 100 -> 1 initial
    # 011      any, doesn't occur
    # 010 -> 0 initial
    # 001 -> 1 initial
    # 000 -> 0 outsides
    my $odd_solid = [ 'Math::PlanePath::CellularRule::OddSolid' ];
    foreach my $i (0 .. 255) {
      $store->(($i&0xC8)|0x32, $odd_solid);
    }
  }
  {
    # solid left half 0xCE=206,0xEE=238
    # 111 -> 1 middle
    # 110 -> 1 vertical
    # 101      any, doesn't occur
    # 100 -> 0 initial
    # 011 -> 1 left
    # 010 -> 1 initial
    # 001 -> 1 initial
    # 000 -> 0 outsides
    my $left_solid = [ 'Math::PlanePath::CellularRule::LeftSolid' ];
    foreach my $i (0 .. 255) {
      $store->(($i&0x20)|0xCE, $left_solid);
    }
  }
}

### rule_to_class count: do { my @k = grep {defined} @rule_to_class; scalar(@k) }
### rule_to_class: [ map {defined($_) && join(',',@$_)} @rule_to_class ]

# ### zap %rule_to_class for testing ...
# %rule_to_class = ();


sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);

  my $rule = $self->{'rule'};
  if (! defined $rule) {
    $rule = $self->{'rule'} =  parameter_info_array()->[0]->{'default'};
  }

  if (my $aref = $rule_to_class[$rule]) {
    ($class, my @args) = @$aref;
    ### $class
    ### @args
    $class->can('new')
      or eval "require $class; 1"
        or die;
    return $class->new(@args);
  }

  $self->{'rows'} = [ "\001" ];
  $self->{'row_end_n'} = [1];
  $self->{'left'} = 0;
  $self->{'right'} = 0;
  $self->{'rule_table'} = [ map { ($rule >> $_) & 1 } 0 .. 7 ];
  ### rule_table: $self->{'rule_table'}

  return $self;
}

#
# Y=2   L 0 1 2 3 4 R     right=2*Y+2
# Y=1     L 0 1 2 R
# Y=0       L 0 R

sub _extend {
  my ($self) = @_;
  ### _extend()

  my $rule_table = $self->{'rule_table'};
  my $rows = $self->{'rows'};
  my $row = $rows->[-1];
  my $newrow = '';
  my $rownum = $#$rows;
  my $count = 0;
  my $bits = $self->{'left'} * 7;
  $self->{'left'} = $rule_table->[$bits];

  ### $row
  ### $rownum

  foreach my $i (0 .. 2*$rownum) {
    $bits = (($bits<<1) + vec($row,$i,1)) & 7;

    ### $i
    ### $bits
    ### new: $rule_table->[$bits]
    $count +=
      (vec($newrow,$i,1) = $rule_table->[$bits]);
  }

  my $rbit = $self->{'right'};
  $self->{'right'} = $rule_table->[7*$rbit];
  ### $rbit
  ### new right: $self->{'right'}

  # right, second last
  $bits = (($bits<<1) + $rbit) & 7;
  $count +=
    (vec($newrow,2*$rownum+1,1) = $rule_table->[$bits]);
  ### $bits
  ### new second last: $rule_table->[$bits]

  # right end
  $bits = (($bits<<1) + $rbit) & 7;
  $count +=
    (vec($newrow,2*$rownum+2,1) = $rule_table->[$bits]);
  ### $bits
  ### new right end: $rule_table->[$bits]

  ### $count
  ### $newrow
  push @$rows, $newrow;

  my $row_end_n = $self->{'row_end_n'};
  push @$row_end_n, $row_end_n->[-1] + $count;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### CellularRule n_to_xy(): $n

  my $int = int($n);
  $n -= $int;   # now fraction part
  if (2*$n >= 1) {
    $n -= 1;
    $int += 1;
  }
  # -0.5 <= $n < 0.5 fractional part
  ### assert: 2*$n >= -1
  ### assert: 2*$n < 1

  if ($int < 1) {
    return;
  }
  if (_is_infinite($int)) { return ($int,$int); }

  my $row_end_n = $self->{'row_end_n'};
  my $y = 0;
  for (;;) {
    if (scalar(@$row_end_n) >= 3
        && $row_end_n->[-1] == $row_end_n->[-2]
        && $row_end_n->[-2] == $row_end_n->[-3]) {
      ### no more cells in three rows means rest is blank ...
      return;
    }
    if ($y > $#$row_end_n) {
      _extend($self);
    }
    if ($int <= $row_end_n->[$y]) {
      last;
    }
    $y++;
  }

  ### $y
  ### row_end_n: $row_end_n->[$y]
  ### remainder: $int - $row_end_n->[$y]

  $int -= $row_end_n->[$y];
  my $row = $self->{'rows'}->[$y];
  my $x = 2*$y+1;   # for first vec 2*Y
  ### $row

  for ($x = 2*$y+1; $x >= 0; $x--) {
    if (vec($row,$x,1)) {
      ### step bit: "x=$x"
      if (++$int > 0) {
        last;
      }
    }
  }

  ### result: ($n + $x - $y).",$y"

  return ($n + $x - $y,
          $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### CellularRule xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);

  if (_is_infinite($x)) { return $x; }
  if (_is_infinite($y)) { return $y; }

  if ($y < 0 || ! ($x <= $y && ($x+=$y) >= 0)) {
    return undef;
  }

  my $row_end_n = $self->{'row_end_n'};
  while ($y > $#$row_end_n) {
    if (scalar(@$row_end_n) >= 3
        && $row_end_n->[-1] == $row_end_n->[-2]
        && $row_end_n->[-2] == $row_end_n->[-3]) {
      ### no more cells in three rows means rest is blank ...
      return undef;
    }
    _extend($self);
  }

  my $row = $self->{'rows'}->[$y];
  if (! vec($row,$x,1)) {
    return undef;
  }
  my $n = $row_end_n->[$y];
  foreach my $i ($x+1 .. 2*$y) {
    $n -= vec($row,++$x,1);
  }
  return $n;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### CellularRule rect_to_n_range(): "$x1,$y1  $x2,$y2"

  ($x1,$y1, $x2,$y2) = _rect_for_V ($x1,$y1, $x2,$y2)
    or return (1,0);  # rect outside pyramid

  if (_is_infinite($y1)) { return (1, $y1); }  # for nan
  if (_is_infinite($y2)) { return (1, $y2); }  # for nan or inf

  my $row_end_n = $self->{'row_end_n'};
  while ($#$row_end_n < $y2) {
    if (scalar(@$row_end_n) >= 3
        && $row_end_n->[-1] == $row_end_n->[-2]
        && $row_end_n->[-2] == $row_end_n->[-3]) {
      ### rect_to_n_range() no more cells in three rows means rest is blank ...
      last;
    }
    _extend($self);
  }

  $y1 -= 1; # to be 1 past end of prev row
  if ($y1 > $#$row_end_n) { $y1 = $#$row_end_n; }

  if ($y2 > $#$row_end_n) { $y2 = $#$row_end_n; }
  ### y range: "$y1 to $y2"

  return ($y1 < 0 ? 1 : $row_end_n->[$y1]+1,
          $row_end_n->[$y2]);
}

{
  package Math::PlanePath::CellularRule::Line;
  use vars '$VERSION', '@ISA';
  $VERSION = 67;
  @ISA = ('Math::PlanePath::CellularRule');
  *_is_infinite = \&Math::PlanePath::_is_infinite;
  *_round_nearest = \&Math::PlanePath::_round_nearest;

  use constant class_y_negative => 0;
  sub x_negative {
    my ($self) = @_;
    return $self->{'sign'} < 0;
  }

  sub n_to_xy {
    my ($self, $n) = @_;
    ### CellularRule-Line n_to_xy(): $n

    my $int = int($n);
    $n -= $int;   # now fraction part
    if (2*$n >= 1) {
      $n -= 1;
      $int += 1;
    }
    # -0.5 <= $n < 0.5 fractional part
    ### assert: 2*$n >= -1
    ### assert: 2*$n < 1

    $int -= 1;
    ### int zero-based: $int
    if ($int < 0) {
      return;
    }
    if (_is_infinite($int)) { return ($int,$int); }

    return ($n + $int*$self->{'sign'}, $int);
  }

  sub xy_to_n {
    my ($self, $x, $y) = @_;
    ### CellularRule-Line xy_to_n(): "$x,$y"

    $x = _round_nearest ($x);
    $y = _round_nearest ($y);
    if (_is_infinite($y)) { return $y; }

    if ($y >= 0 && $x == $y*$self->{'sign'}) {
      return $y+1;
    } else {
      return undef;
    }
  }

  # not exact
  sub rect_to_n_range {
    my ($self, $x1,$y1, $x2,$y2) = @_;

    $x1 = _round_nearest ($x1);
    $y1 = _round_nearest ($y1);
    $x2 = _round_nearest ($x2);
    $y2 = _round_nearest ($y2);
    if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); } # swap to y1<=y2

    if ($y2 < 0) {
      return (1, 0);
    }
    if (_is_infinite($y1)) { return (1, $y1+1); }
    if (_is_infinite($y2)) { return (1, $y2+1); }
    return ($y1+1, $y2+1);
  }
}

{
  package Math::PlanePath::CellularRule::OddSolid;
  use vars '$VERSION', '@ISA';
  $VERSION = 67;
  use Math::PlanePath::PyramidRows;
  @ISA = ('Math::PlanePath::PyramidRows');
  *_is_infinite = \&Math::PlanePath::_is_infinite;
  *_floor = \&Math::PlanePath::_floor;
  *_round_nearest = \&Math::PlanePath::_round_nearest;

  use constant n_start => 1;
  use constant x_negative => 1; # not the PyramidRows from step

  sub new {
    my ($class) = @_;
    return $class->SUPER::new(step=>1);
  }
  sub n_to_xy {
    my ($self, $n) = @_;
    ### CellularRule-OddSolid n_to_xy(): $n
    my ($x,$y) = $self->SUPER::n_to_xy($n)
      or return;
    ### pyramid: "$x, $y"
    return ($x+_round_nearest($x) - $y, $y);
  }
  sub xy_to_n {
    my ($self, $x, $y) = @_;
    ### CellularRule-OddSolid xy_to_n(): "$x,$y"
    $x = _round_nearest ($x);
    $y = _round_nearest ($y);
    if (($x+$y)%2) {
      return undef;
    }
    return $self->SUPER::xy_to_n(($x+$y)/2, $y);
  }
  # not exact
  sub rect_to_n_range {
    my ($self, $x1,$y1, $x2,$y2) = @_;

    $y1 = _round_nearest ($y1);
    $y2 = _round_nearest ($y2);
    if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); } # swap to y1<=y2
    return $self->SUPER::rect_to_n_range(0,$y1,0,$y2+1);
  }
}

{
  package Math::PlanePath::CellularRule::LeftSolid;
  use vars '$VERSION', '@ISA';
  $VERSION = 67;
  use Math::PlanePath::PyramidRows;
  @ISA = ('Math::PlanePath::PyramidRows');
  *_is_infinite = \&Math::PlanePath::_is_infinite;
  *_round_nearest = \&Math::PlanePath::_round_nearest;

  use constant x_negative => 1; # not the PyramidRows from step

  sub new {
    my ($class) = @_;
    return $class->SUPER::new(step=>1);
  }
  sub n_to_xy {
    my ($self, $n) = @_;
    ### CellularRule-LeftSolid n_to_xy(): $n

    my ($x,$y) = $self->SUPER::n_to_xy($n)
      or return;
    return ($x-$y, $y);
  }
  sub xy_to_n {
    my ($self, $x, $y) = @_;
    ### CellularRule-LeftSolid xy_to_n(): "$x,$y"
    ### super: "at ".($x-$y).",$y"
    return $self->SUPER::xy_to_n ($x+_round_nearest($y), $y);
  }
  # not exact
  sub rect_to_n_range {
    my ($self, $x1,$y1, $x2,$y2) = @_;
    $y1 = _round_nearest ($y1);
    $y2 = _round_nearest ($y2);
    if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); } # swap to y1<=y2
    return $self->SUPER::rect_to_n_range(0,$y1,0,$y2+1);
  }
}

1;
__END__


# For reference the specifics currently are
# 
#     54                              CellularRule54
#     190,246                         CellularRule190
#     18,26,82,90,146,154,210,218     SierpinskiTriangle
#                                     (offset to start N=1)
#     151,159,183,191,215,223,247,    PyramidRows step=2
#     254,222,255                       solid block
#     220,252                         PyramidRows step=1 half
#     4,12,36,44,68,76,100,108,132,   Rows width=1
#     140,164,172,196,204,228,236     single-cell column



=for stopwords PyramidRows Ryde Math-PlanePath PlanePath ie Xmax-Xmin CellularRule SierpinskiTriangle superclass eg CellularRule CellularRule54 CellularRule190

=head1 NAME

Math::PlanePath::CellularRule -- cellular automaton points of binary rule

=head1 SYNOPSIS

 use Math::PlanePath::CellularRule;
 my $path = Math::PlanePath::CellularRule->new (rule => 30);
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is the patterns of Stephen Wolfram's bit-rule based cellular automatons

    http://mathworld.wolfram.com/ElementaryCellularAutomaton.html

Points are numbered left to right in rows so for example C<rule =E<gt> 30>
is

    51 52    53 54 55 56    57 58       59          60 61 62       9
       44 45       46          47 48 49                50          8
          32 33    34 35 36 37       38 39 40 41 42 43             7
             27 28       29             30       31                6
                18 19    20 21 22 23    24 25 26                   5
                   14 15       16          17                      4
                       8  9    10 11 12 13                         3
                          5  6        7                            2
                             2  3  4                               1
                                1                              <- Y=0

    -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7  8  9

The automaton starts from a single point N=1 at the origin and grows into
the rows above.  The C<rule> parameter specifies what each set of 3 cells
below will produce in the one cell above.  The rule is encoded as a value 0
to 255 inclusive used as bits,

    cells below     cell above from rule

        1,1,1    ->   bit7
        1,1,0    ->   bit6
        1,0,1    ->   bit5
        ...
        0,0,1    ->   bit1
        0,0,0    ->   bit0

When cells 0,0,0 become 1, ie. bit0 in C<rule> is 1 (an odd number), the
"off" cells either side of the initial N=1 become all "on" infinitely to the
sides.  And if the 1,1,1 bit7 is a 0 (ie. S<rule E<lt> 128>) then they turn
on and off alternately in odd and even rows.  In both cases only the pyramid
portion part -YE<lt>=XE<lt>=Y is considered for the N points, but the
infinite cells to the sides are included in the calculation.

The full set of patterns can be seen at the Math World page above, or can be
printed with the F<examples/cellular-rules.pl> program in the Math-PlanePath
sources.  The patterns range from simple to complex.  For some the N=1 cell
doesn't grow at all, only that single point, eg. rule 0 or rule 8.  Some
grow to mere straight lines such as rule 2 or rule 5.  Others make columns
or patterns with "quadratic" style stepping of 1 or 2 rows, or self-similar
replications such as the Sierpinski triangle.  Some rules even give
complicated non-repeating patterns when there's feedback across from one
half to the other, for example rule 30.

For some rules there's specific code which this class dispatches to, such as
CellularRule54, CellularRule190 or SierpinskiTriangle (which is adjusted to
start at N=1 here).

For rules without specific code the current implementation is not
particularly efficient as it builds and holds onto the bit pattern for all
rows to the highest N or X,Y used.  There's no doubt better ways to iterate
an automaton, but this module offers the patterns in PlanePath style.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::CellularRule-E<gt>new (rule =E<gt> 123)>

Create and return a new path object.  C<rule> should be an integer 0 to 255.
A C<rule> should be given always.  There is a default, but it's secret and
likely to change.

For some of the simple rules there's specific code implementing the pattern
and the return value is an object from that class, not a
C<Math::PlanePath::CellularRule> as such.  Is it undesirable that C<new()>
CellularRule gives an object not C<isa()> CellularRule?  Perhaps it could be
cooked up to be a subclass or superclass, but for now getting the more
efficient specific modules at least run much faster.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are each
rounded to the nearest integer, which has the effect of treating each cell
as a square of side 1.  If C<$x,$y> is outside the pyramid or on a skipped
cell the return is C<undef>.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::CellularRule54>,
L<Math::PlanePath::CellularRule57>,
L<Math::PlanePath::CellularRule190>,
L<Math::PlanePath::SierpinskiTriangle>,
L<Math::PlanePath::PyramidRows>

L<Cellular::Automata::Wolfram>

http://mathworld.wolfram.com/ElementaryCellularAutomaton.html

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