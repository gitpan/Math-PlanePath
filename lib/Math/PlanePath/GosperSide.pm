# Copyright 2011, 2012 Kevin Ryde

# This file is part of Math-PlanePath.
#
# Math-PlanePath is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-PlanePath is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-PlanePath.  If not, see <http://www.gnu.org/licenses/>.


# arms begin at 0,0 or at 1 in ?


# math-image --path=GosperSide --lines --scale=10
# math-image --path=GosperSide --output=numbers


package Math::PlanePath::GosperSide;
use 5.004;
use strict;
use List::Util qw(max);
use POSIX qw(ceil);
use Math::PlanePath::GosperIslands;
use Math::PlanePath::SacksSpiral;

use vars '$VERSION', '@ISA', '@_xend','@_yend';
$VERSION = 93;
use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_divrem_mutate = \&Math::PlanePath::_divrem_mutate;

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'digit_split_lowtohigh';

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;

# secret experimental as yet ...
#
# use constant parameter_info_array => [ { name      => 'arms',
#                                          share_key => 'arms_6',
#                                          type      => 'integer',
#                                          minimum   => 1,
#                                          maximum   => 6,
#                                          default   => 1,
#                                          width     => 1,
#                                          description => 'Arms',
#                                        } ];

use constant dx_minimum => -2;
use constant dx_maximum => 2;
use constant dy_minimum => -1;
use constant dy_maximum => 1;

#------------------------------------------------------------------------------

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 6) { $arms = 6; }
  $self->{'arms'} = $arms;
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### GosperSide n_to_xy(): $n
  if ($n < 0) {
    return;
  }
  if (is_infinite($n)) {
    return ($n,$n);
  }

  my $x;
  my $y = my $yend = ($n * 0);  # inherit bignum 0
  my $xend = $y + 2;            # inherit bignum 2
  {
    my $int = int($n);
    $x = 2 * ($n - $int);
    $n = $int;
  }


  if ((my $arms = $self->{'arms'}) > 1) {
    my $rot = _divrem_mutate ($n, $arms);
    if ($rot >= 3) {
      $rot -= 3;
      $x = -$x;    # rotate 180, knowing y=0,yend=0
      $xend = -2;
    }
    if ($rot == 1) {
      $x = $y = $x/2;   # rotate +60, knowing y=0,yend=0
      $xend = $yend = $xend/2;
    } elsif ($rot == 2) {
      $y = $x/2;   # rotate +120, knowing y=0,yend=0
      $x = -$y;
      $yend = $xend/2;
      $xend = -$yend;
    }
  }

  foreach my $digit (digit_split_lowtohigh($n,3)) {
    my $xend_offset = 3*($xend-$yend)/2;   # end and end +60
    my $yend_offset = ($xend+3*$yend)/2;

    ### at: "$x,$y"
    ### $digit
    ### $xend
    ### $yend
    ### $xend_offset
    ### $yend_offset

    if ($digit == 1) {
      ($x,$y) = (($x-3*$y)/2  + $xend,   # rotate +60
                 ($x+$y)/2    + $yend);
    } elsif ($digit == 2) {
      $x += $xend_offset;   # offset and offset +60
      $y += $yend_offset;
    }
    $xend += $xend_offset;   # offset and offset +60
    $yend += $yend_offset;
  }

  ### final: "$x,$y"
  return ($x, $y);
}

# level = (log(hypot) + log(2*.99)) * 1/log(sqrt(7))
#       = (log(hypot^2)/2 + log(2*.99)) * 1/log(sqrt(7))
#       = (log(hypot^2) + 2*log(2*.99)) * 1/(2*log(sqrt(7)))
#
sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = round_nearest ($x);
  $y = round_nearest ($y);
  ### GosperSide xy_to_n(): "$x, $y"

  if (($x ^ $y) & 1) {
    return undef;
  }

  my $h2 = $x*$x + $y*$y*3 + 1;
  my $level = max (0,
                   ceil ((log($h2) + 2*log(2*.99)) * (1/2*log(sqrt(7)))));
  if (is_infinite($level)) {
    return $level;
  }
  return Math::PlanePath::GosperIslands::_xy_to_n_in_level($x,$y,$level);
}


# Points beyond N=3^level only go a small distance back before that N
# hypotenuse.
#     hypot = .99 * 2 * sqrt(7)^level
#     sqrt(7)^level = hypot / (2*.99)
#     sqrt(7)^level = hypot / (2*.99)
#     level = log(hypot / (2*.99)) / log(sqrt(7))
#           = (log(hypot) + log(2*.99)) * 1/log(sqrt(7))
#
# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  $y1 *= sqrt(3);
  $y2 *= sqrt(3);
  my ($r_lo, $r_hi) = Math::PlanePath::SacksSpiral::_rect_to_radius_range
    ($x1,$y1, $x2,$y2);
  my $level = max (0,
                   ceil ((log($r_hi+.1) + log(2*.99)) * (1/log(sqrt(7)))));
  return (0,
          $self->{'arms'} * 3 ** $level - 1);
}

1;
__END__

=for stopwords eg Ryde GosperIslands Math-PlanePath Gosper TerdragonCurve

=head1 NAME

Math::PlanePath::GosperSide -- one side of the Gosper island

=head1 SYNOPSIS

 use Math::PlanePath::GosperSide;
 my $path = Math::PlanePath::GosperSide->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

X<Gosper, William>This path is a single side of the Gosper island, in
integers (L<Math::PlanePath/Triangular Lattice>).

                                        20-...        14
                                       /
                               18----19               13
                              /
                            17                        12
                              \
                               16                     11
                              /
                            15                        10
                              \
                               14----13                9
                                       \
                                        12             8
                                       /
                                     11                7
                                       \
                                        10             6
                                       /
                                8---- 9                5
                              /
                       6---- 7                         4
                     /
                    5                                  3
                     \
                       4                               2
                     /
              2---- 3                                  1
            /
     0---- 1                                       <- Y=0

     ^
    X=0 1  2  3  4  5  6  7  8  9 10 11 12 13 ...

The path slowly spirals around counter clockwise, with a lot of wiggling in
between.  The N=3^level point is at

   N = 3^level
   angle = level * atan(sqrt(3)/5)
         = level * 19.106 degrees
   radius = sqrt(7) ^ level

A full revolution for example takes roughly level=19 which is about
N=1,162,000,000.

Both ends of such levels are in fact sub-spirals, like an "S" shape.

The path is both the sides and the radial spokes of the GosperIslands path,
as described in L<Math::PlanePath::GosperIslands/Side and Radial Lines>.
Each N=3^level point is the start of a GosperIslands ring.

The path is the same as the TerdragonCurve except the turns here are by 60
degrees each, whereas TerdragonCurve is by 120 degrees.  See
L<Math::PlanePath::TerdragonCurve> for the turn sequence and total direction
formulas etc.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::GosperSide-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional C<$n> gives a point on the straight line between integer N.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::GosperIslands>,
L<Math::PlanePath::TerdragonCurve>,
L<Math::PlanePath::KochCurve>

L<Math::Fractal::Curve>

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
