# Copyright 2011 Kevin Ryde

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


# math-image --path=DragonMidpointArms --lines --scale=20
# math-image --path=DragonMidpointArms --all --output=numbers_dash


package Math::PlanePath::DragonMidpointArms;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX 'ceil';

use vars '$VERSION', '@ISA';
$VERSION = 1;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::DragonMidpoint;

use constant n_start => 0;

sub n_to_xy {
  my ($self, $n) = @_;
  ### DragonMidpoint n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n, $n); }

  {
    my $int = int($n);
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

  my $rem = ($n % 4);
  $n = int($n/4);

  my ($x,$y) = Math::PlanePath::DragonMidpoint->n_to_xy($n);
  if ($rem & 2) {
    $x = -$x;             # rotate 180
    $y = -$y;
  }
  if ($rem & 1) {
    ($x,$y) = (-$y,$x);   # rotate +90
  }
  if ($rem == 1 || $rem == 2) {
    $y += 1;
  }
  if ($rem == 2 || $rem == 3) {
    $x -= 1;
  }
  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  my $n;
  ($x,$y) = (-$y,$x);
  foreach my $mod (-3, -2, -1, 0) {
    ($x,$y) = ($y,-$x);
    my $m = Math::PlanePath::DragonMidpoint->xy_to_n($x,$y);
    if (defined $m) {
      $m = 4*$m + $mod;
      if (! defined $n || $m < $n) {
        $n = $m;
      }
    }
  }
  return $n;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### DragonMidpoint rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $self->{'arms'} = 4;
  my ($n_lo,$n_hi) = $self->Math::PlanePath::DragonMidpoint::rect_to_n_range($x1,$y1, $x2,$y2);
  if ($n_lo) {
    $n_lo -= 1;
  }
  return (4*$n_lo, 4*$n_hi);
}

1;
__END__

=for stopwords eg Ryde Dragon Math-PlanePath Nlevel

=head1 NAME

Math::PlanePath::DragonMidpointArms -- four dragon curves

=head1 SYNOPSIS

 use Math::PlanePath::DragonMidpointArms;
 my $path = Math::PlanePath::DragonMidpointArms->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is four arms of ...                                    
                                                            
=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::DragonMidpointArms-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::KochCurve>

=cut
