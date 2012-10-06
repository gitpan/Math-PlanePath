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
# math-image --path=ToothpickTree --all --figure=eobar
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
# A152978 (cells added)/4, is quarter cells added too
# A139253 primes among total cells
#
# A139252 total segments
# A139560 new segments added, end-to-end meetings not counted
# A147614 grid points if length 2,
#           ie. counting endpoints too, without multiplicity
# A139252 count segments to level, end-to-end meetings coalesced
#
# A153006 three-quarter total cells
# A152980 three-quarter cells added
#
# A153000 quarter total cells
# A152978 quarter cells added
#    start half tooth horizontal x=0,y=1 to x=1,y=1
#    first tooth added is x=1,y=1 vertical 
#
# A160570 triangle, row sums are toothpick cumulative
# A153007 triangular-toothpick
# A160552 A160762 A151548 toothpick
#
# cf A160808 count cells Fibonacci spiral
#    A160809 cells added Fibonacci spiral
#
#    A160164 "I"-toothpick A187220 gull
#
#    A151567 another rule toothpicks


package Math::PlanePath::ToothpickTree;
use 5.004;
use strict;
#use List::Util 'max','min';
*max = \&Math::PlanePath::_max;
*min = \&Math::PlanePath::_min;

use vars '$VERSION', '@ISA';
$VERSION = 90;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

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
  $self->{'level_to_n'} = [ 1, 2 ];
  $self->{'level'} = 0;
  return $self;
}


use constant _UNTESTED__tree_level_start => 0;
sub _UNTESTED__tree_level_n_range {
  my ($self, $level) = @_;
  my $level_to_n = $self->{'level_to_n'};
  while ($#$level_to_n <= $level) {
    _extend($self);
  }
  return ($level_to_n->[$level], $level_to_n->[$level+1]-1);
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
  push @{$self->{'level_to_n'}}, $#$n_to_x + 1;
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
  ### tree_n_children(): $n

  my ($x,$y) = $self->n_to_xy($n)
    or return undef;
  my ($n1,$n2);
  if (($x + $y) % 2) {
    # odd, horizontal to children
    $n1 = $self->xy_to_n($x-1,$y);
    $n2 = $self->xy_to_n($x+1,$y);
  } else  {
    # even, vertical to children
    $n1 = $self->xy_to_n($x,$y-1);
    $n2 = $self->xy_to_n($x,$y+1);
  }
  ### $n1
  ### $n2
  if (($n1||0) > ($n2||0)) {
    ($n1,$n2) = ($n2,$n1); # sorted
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

my @tree_n_to_depth = (undef, 0, 1,1, 2,2,2,2);
sub tree_n_to_depth {
  my ($self, $n) = @_;
  if ($n < 0) {
    return undef;
  }
  if ($n < @tree_n_to_depth) {
    return $tree_n_to_depth[$n];
  }
  $n -= 8;

  if (is_infinite($n)) {
    return $n;
  }
  my ($depth,$rem) = _n_to_depth_and_rem($n);
  return $depth;
}

sub _n_to_depth_and_rem {
  my ($n) = @_;

  my $zero = $n*0;
  my @added = ($zero, 1+$zero, 2+$zero, 4+$zero);

  for (my $len = 4; $len <= 16; $len *= 2) {
    ### at: "n=$n len=$len"
    push @added, $len;
    if ($n < $len) {
      return ($len, $n);
    }
    $n -= $len;

    for my $i (1 .. $len-1) {
      my $add = $added[$i+1] + 2*$added[$i];
      push @added, $add;
      if ($n < $add) {
        return ($len+$i, $n);
      }
      $n -= $add;
    }
  }
}


# sub _UNTESTED__n_to_xy {
#   my ($n) = @_;
# 
#   my $zero = $n*0;
#   my @added = ($zero, 1+$zero, 2+$zero, 4+$zero);
# 
#   for (my $len = 4; $len <= 16; $len *= 2) {
#     ### at: "n=$n len=$len"
#     push @added, $len;
#     if ($n < $len) {
#       return ($len, $n);
#     }
#     $n -= $len;
# 
#     for my $i (1 .. $len-1) {
#       my $add = $added[$i+1] + 2*$added[$i];
#       push @added, $add;
#       if ($n < $add) {
#         return ($len+$i, $n);
#       }
#       $n -= $add;
#     }
#   }
# }

1;
__END__


# no good
# cumulative total a(2^k) = (2^(2n+1) + 1)/3 = 3,11,43,171
# N = (2^(2n+1) + 1)/3
# 3N = 2^(2n+1) + 1
# 2^(2n+1) = 3N - 1
# 2^(2n+2) = 6N-2
# len = 4^(n+1) = 6N-2
# cumul = (len/2 + 1)/3
#       = (len+2)/6
# my ($len,$level) = round_down_pow(6*$n-8);
# my @depth_bits;
# while ($level-- >= 0) {
#   my $cumul = ($len+2)/6;
#
#   if ($n >= $cumul) {
#     $n -= $cumul;
#     _divrem_mutate($n,4);
#     my $cumul = ($len/4+2)/6;
#     $n += $cumul;
#     push @depth_bits, 1;
#   } else {
#     push @depth_bits, 0;
#   }
#   $len /= 4;
# }


=for stopwords eg Ryde Math-PlanePath Nstart Nend

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
              13---9--  ---8--12                     2
           |   |   |       |   |   |
          29--19-  5---2---4 -16--24                 1
           |       |   |   |       |
                       1                        <- Y=0
           |       |   |   |       |
          30--20-  6---3---7 -23--35                -1
           |   |   |       |   |   |
              14--10--  --11--15                    -2
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

Points are numbered by each growth level at the endpoints, and
anti-clockwise around when there's a new point at both ends of an existing
toothpick.

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
toothpick.  Then points N=4,5,6,7 are added at those four ends.

For points N=4,5,6,7 a new toothpick is only added at each far ends, not the
"inner" positions X=1,Y=0 and X=-1,Y=0.  This is because those points are
the ends of two toothpicks and would overlap.  X=1,Y=0 is the end of
toothpicks N=4 and N=7, and X=-1,Y=0 the ends of N=5,N=6.  The rule is that
when two ends meet like that nothing is added at that point.  The end of a
toothpick is allowed to touch an existing toothpick.  The first time this
happens is N=16.  Its left end touches N=4.

The stair-step X=Y,X=Y-1 diagonal N=2,4,8,12,17,25,36,44,49 etc and similar
in the other quadrants extend indefinitely.  The quarters to either side of
the diagonals are filled in a self-similar fashion.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::ToothpickTree-E<gt>new ()>

Create and return a new path object.

=back

=head2 Tree Methods

=over

=item C<@n_children = $path-E<gt>tree_n_children($n)>

Return the children of C<$n>, or an empty list if C<$n> has no children
(including when C<$n E<lt> 1>, ie. before the start of the path).

The children are the new toothpicks added at the ends of C<$n> in the next
level.  This can be none, one or two points.  For example N=8 has a single
child 12, N=24 has no children, or N=2 has two children 4,5.  The way points
are numbered means when there's two children they're consecutive N values.

=item C<$num = $path-E<gt>tree_n_num_children($n)>

Return the number of children of C<$n>, or return C<undef> if C<$nE<lt>1>
(ie. before the start of the path).

=item C<$n_parent = $path-E<gt>tree_n_parent($n)>

Return the parent node of C<$n>, or C<undef> if C<$n E<lt>= 1> (the start of
the path).

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
