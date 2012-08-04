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


# math-image --path=Toothpick --all --output=numbers --size=80x50
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

package Math::PlanePath::Toothpick;
use 5.004;
use strict;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 84;
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
  $self->{'h'} = 1;
  $self->{'endpoints'} = [ '0,0' ];
  $self->{'xy_to_n'} = { '0,0' => 1 };
  $self->{'n_to_x'} = [ undef, 0 ];
  $self->{'n_to_y'} = [ undef, 0 ];
  return $self;
}

sub _extend {
  my ($self) = @_;
  ### _extend(): $self
  my $endpoints = $self->{'endpoints'};
  my $h = $self->{'h'};
  my @extend;
  foreach (@$endpoints) {
    my ($x,$y) = split /,/;
    if ($h) {
      push @extend,
        ($x+1).",$y",
          ($x-1).",$y";
    } else {
      push @extend,
        "$x,".($y+1),
          "$x,".($y-1);
    }
  }
  my %extend;
  foreach (@extend) {
    $extend{$_}++;
  }
  @$endpoints = ();
  my $n_to_x = $self->{'n_to_x'};
  my $n_to_y = $self->{'n_to_y'};
  my $xy_to_n = $self->{'xy_to_n'};
  foreach (@extend) {
    if ($extend{$_}==1 && ! exists $xy_to_n->{$_}) {
      push @$endpoints, $_;
      my ($x,$y) = split /,/;
      push @$n_to_x, $x;
      push @$n_to_y, $y;
      $xy_to_n->{$_} = $#$n_to_x;
    }
  }
  $self->{'h'} = ! $h;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### Toothpick n_to_xy(): $n

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
  ### Toothpick xy_to_n(): "$x, $y"

  $x = round_nearest ($x);
  $y = round_nearest ($y);

  my $n_hi = 4*(1 + $x*$x + $y*$y);
  while ($#{$self->{'n_to_x'}} < $n_hi) {
    _extend($self);
  }
  return $self->{'xy_to_n'}->{"$x,$y"};
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### Toothpick rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = round_nearest ($x1);
  $y1 = round_nearest ($y1);
  $x2 = round_nearest ($x2);
  $y2 = round_nearest ($y2);

  return (1,
          4*(1 + max(abs($x1),abs($x2))**2
             + max(abs($y1),abs($y2))**2));
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

Math::PlanePath::Toothpick -- growth of a 2-D cellular automaton

=head1 SYNOPSIS

 use Math::PlanePath::Toothpick;
 my $path = Math::PlanePath::Toothpick->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress ...>

This is the "toothpick" pattern ...

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::Toothpick-E<gt>new ()>

Create and return a new path object.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::UlamWarburtonQuarter>

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
