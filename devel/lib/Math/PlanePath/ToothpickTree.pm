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


# math-image --path=ToothpickTree --all --output=numbers --size=80x50
#
# A139250 total cells
#    a(2^k) = A007583(k) = (2^(2n+1) + 1)/3
#    a(2^k-1) = A000969(2^k-2), A000969=floor (2*n+3)*(n+1)/3
# A139251 cells added
#   0, 1, 2,
#   4,  4,
#   4, 8, 12, 8,
#   4, 8, 12, 12, 16, 28, 32, 16,
#   4, 8, 12, 12, 16, 28, 32, 20, 16, 28, 36, 40, 60, 88, 80, 32,
#   4, 8, 12, 12, 16, 28, 32, 20, 16, 28, 36, 40, 60, 88, 80, 36, 16, 28, 36, 40, 60, 88, 84, 56, 60, 92, 112, 140, 208, 256, 192, 64,
#   4, 8, 12, 12, 16, 28, 32, 20, 16, 28

# A152968 (cells added)/2
# A152978 (cells added)/4
# A139252 total segments
# A139253 primes
# A147614 grid points if length 2
# A139560 new segments added
# A160570 triangle, row sums are toothpick cumulative
# A152980 diffs
# A153000 total in first quad
# A153006 in one quad ?
# A153007 triangular-toothpick
# A151567 toothpick seq
# A160552 A160762 A151548 A078008 A151575 A147614 toothpick
# A160164 I tooth A187220 gull
#
# cf A160808 count cells falling on Fibonacci spiral
#    A161330 E-toothpick snowflake

package Math::PlanePath::ToothpickTree;
use 5.004;
use strict;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 86;
use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_divrem_mutate = \&Math::PlanePath::_divrem_mutate;

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'round_down_pow';

# uncomment this to run the ### lines
#use Smart::Comments;


sub new {
  my $self = shift->SUPER::new(@_);
  $self->{'horiz'} = 0;
  $self->{'endpoints_x'} = [ 0 ];
  $self->{'endpoints_y'} = [ 0 ];
  $self->{'endpoints_dir'} = [ 2 ];
  $self->{'xy_to_n'} = { '0,0' => 1 };
  $self->{'n_to_x'} = [ undef, 0 ];
  $self->{'n_to_y'} = [ undef, 0 ];
  $self->{'level'} = 0;
  return $self;
}

my @dir_to_dx = (1,0,-1,0);
my @dir_to_dy = (0,1,0,-1);

sub _extend {
  my ($self) = @_;
  ### _extend(): $self
  my $xy_to_n = $self->{'xy_to_n'};
  my $endpoints_x = $self->{'endpoints_x'};
  my $endpoints_y = $self->{'endpoints_y'};
  my $endpoints_dir = $self->{'endpoints_dir'};
  my @extend_x;
  my @extend_y;
  my @extend_dir;
  my %extend;
  foreach my $i (0 .. $#$endpoints_x) {
    my $x = $endpoints_x->[$i];
    my $y = $endpoints_y->[$i];
    my $dir = ($endpoints_dir->[$i] - 1) & 3;  # -90
    foreach (-1, 1) {
      my $x = $x + $dir_to_dx[$dir];
      my $y = $y + $dir_to_dy[$dir];
      my $key = "$x,$y";
      unless ($xy_to_n->{$key}) {
        $extend{$key}++;
        push @extend_x, $x;
        push @extend_y, $y;
        push @extend_dir, $dir;
      }
      $dir ^= 2;  # +180
    }
  }
  @$endpoints_x = ();
  @$endpoints_y = ();
  @$endpoints_dir = ();
  foreach my $i (0 .. $#extend_x) {
    my $x = $extend_x[$i];
    my $y = $extend_y[$i];
    my $key = "$x,$y";
    next if $extend{$key} > 1;
    push @$endpoints_x, $x;
    push @$endpoints_y, $y;
    push @$endpoints_dir, $extend_dir[$i];
  }
  my $n_to_x = $self->{'n_to_x'};
  my $n_to_y = $self->{'n_to_y'};
  foreach my $i (0 .. $#$endpoints_x) {
    my $x = $endpoints_x->[$i];
    my $y = $endpoints_y->[$i];
    push @$n_to_x, $x;
    push @$n_to_y, $y;
    $xy_to_n->{"$x,$y"} = $#$n_to_x;
  }
  $self->{'level'}++;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### ToothpickTree n_to_xy(): $n

  if ($n < 1) { return; }
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

  while ($#{$self->{'n_to_x'}} < $n) {
    _extend($self);
  }
  ### $self

  ### x: $self->{'n_to_x'}->[$n]
  ### y: $self->{'n_to_y'}->[$n]
  return ($self->{'n_to_x'}->[$n],
          $self->{'n_to_y'}->[$n]);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### ToothpickTree xy_to_n(): "$x, $y"

  $x = round_nearest ($x);
  $y = round_nearest ($y);

  my ($len,$level) = round_down_pow (max(abs($x), abs($y)-1),
                                     2);
  $len *= 4;
  if (is_infinite($len)) {
    return ($len,$len);
  }
  while ($self->{'level'} <= $len) {
    _extend($self);
  }
  return $self->{'xy_to_n'}->{"$x,$y"};
}

# T(level) = 4 * T(level-1) + 2
# T(level) = 2 * (4^level - 1) / 3
# total = T(level) + 2
# N = (4^level - 1)*2/3
# 4^level - 1 = 3*N/2
# 4^level = 3*N/2 + 1
#
# len=2^level
# total = (len*len-1)*2/3 + 2

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### ToothpickTree rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = round_nearest ($x1);
  $y1 = round_nearest ($y1);
  $x2 = round_nearest ($x2);
  $y2 = round_nearest ($y2);

  my ($len,$level) = round_down_pow (max(abs($x1),  abs($x2),
                                         abs($y1)-1,abs($y2)-1),
                                     2);
  ### $level
  ### $len
  if (is_infinite($level)) {
    return $level;
  }

  $len *= 4;
  return (1, ($len*$len-1)*2/3+2);
}

# ENHANCE-ME: calculate by the bits of n, not by X,Y
sub tree_n_children {
  my ($self, $n) = @_;

  my ($x,$y) = $self->n_to_xy($n)
    or return undef;
  my ($n1,$n2);
  if (($x + $y) % 2) {
    # vertical to children
    $n1 = $self->xy_to_n($x,$y-1);
    $n2 = $self->xy_to_n($x,$y+1);
  } else  {
    # horizontal to children
    $n1 = $self->xy_to_n($x-1,$y);
    $n2 = $self->xy_to_n($x+1,$y);
  }
  return ((defined $n1 && $n1 > $n ? $n1 : ()),
          (defined $n2 && $n2 > $n ? $n2 : ()));
}
sub tree_n_parent {
  my ($self, $n) = @_;
  if ($n == 1) {
    return undef;
  }
  my ($x,$y) = $self->n_to_xy($n)
    or return undef;
  if (($x + $y) % 2) {
    # horizontal to parent
    return min ($self->xy_to_n($x-1,$y) || $n,
                $self->xy_to_n($x+1,$y) || $n);
  } else {
    # vertical to parent
    return min ($self->xy_to_n($x,$y-1) || $n,
                $self->xy_to_n($x,$y+1) || $n);
  }
}

1;
__END__

=for stopwords eg Ryde Math-PlanePath Ulam Warburton Nstart Nend

=head1 NAME

Math::PlanePath::ToothpickTree -- toothpick sequence

=head1 SYNOPSIS

 use Math::PlanePath::ToothpickTree;
 my $path = Math::PlanePath::ToothpickTree->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress ...>

This is the "toothpick" sequence expanding through the plane by
non-overlapping line segments (toothpicks).

=cut

# math-image --path=ToothpickTree --output=numbers --all --size=65x11

=pod

    --50--                          --49--           5
       |                               |
      45--39--  --38--  --37--  --36--44             4
       |   |       |       |       |   |
    --51- 28--18--27      26--17--25 -48--           3
           |   |               |   |
              13---9--- ---8--12                     2
           |   |   |       |   |   |
          29--19-  5---2---4 -16--24                 1
           |       |   |   |       |
                       1                        <- Y=0
           |       |   |   |       |
          30--20-  6---3---7 -23--35                -1
           |   |   |       |   |   |
              14--10--- --11--15                    -2
           |   |               |   |
    --52- 31--21--32      33--22--34 -55--          -3
       |   |       |       |       |   |
      46--40--  --41--  --42--  --43--47            -4
       |                               |
    --53--                          --54--          -5
                       ^
      -4   -3 -2  -1  X=0  1   2   3   4

Each X,Y point is the centre of a toothpick.  The toothpick is vertical on
"even" points X+Y==0 mod 2, or horizontal on "odd" points X+Y==1 mod 2.

Points are numbered around by growth of toothpick ends, and anti-clockwise
around when there's a new point at both ends of an existing point.

                                                   ---9--- ---8---
                                  |       |           |       |
                ---2---           5---2---4           5---2---4
    |              |              |   |   |           |   |   |
    1      ->      1       ->         1        ->         1      
    |              |              |   |   |           |   |   |
                ---3---           6---3---7           6---3---7
                                  |       |           |       |
                                                   --10--- --11---

The start is N=1 and points N=2 and N=3 are added to the two ends of that
toothpick.  Then a points N=4,5,6,7 at those four ends.

For points N=4,5,6,7 a new toothpick is only added at each far ends, not the
"inner" positions X=1,Y=0 and X=-1,Y=0.  This is because those points are
the ends of two toothpicks.  X=1,Y=0 is the end of toothpicks N=4 and N=7,
and conversely X=-1,Y=0 the ends of N=5,N=6.  The rule is that when two ends
meet like that nothing is added at that point.

The stair-step diagonal N=2,4,8,12,17,25,36,44,49 etc, and similar in the
other quadrants, extends indefinitely and the parts in between are filled in
a self-similar style.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::ToothpickTree-E<gt>new ()>

Create and return a new path object.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::UlamWarburton>

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
