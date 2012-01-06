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


package Math::PlanePath::AztecDiamondRings;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 63;
use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;

# d = [ 1, 2, 3, 4 ]
# n = [ 1,5,13,25 ]
# N = (2 d^2 - 2 d + 1)
#   = (2*$d**2 - 2*$d + 1)
#   = ((2*$d - 2)*$d + 1)
# d = 1/2 + sqrt(1/2 * $n + -1/4)
#
sub n_to_xy {
  my ($self, $n) = @_;
  #### n_to_xy: $n
  if ($n < 1) { return; }

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;
    $n = $int;       # BigFloat int() gives BigInt, use that
    ### assert: $frac >= 0
    ### assert: $frac < 1
  }

  my $d = int( (1 + sqrt(2*$n-1))/2 );
  #### $d
  #### d frac: (1 + sqrt(2*$n-1))/2
  #### base: ((2*$d - 2)*$d + 1)
  #### base with offset: (2*$d*$d + 1)

  # and base+2d = (2 d^2 - 2d + 1) + 2d
  #             = 2*d*d + 1
  $n -= (2*$d*$d + 1);
  ### rem from left: $n

  if ($n < 0) {
    my $x = -$d-$n-1;
    if ($n != -1) {
      $x = -$frac + $x;
    }
    if ($n < -$d) {
      # top-right
      my $y = $n+2*$d;
      if ($n != -$d-1) {
        $y = $frac + $y;
      }
      return ($x, $y);
    } else {
      # top-left
      return ($x, -$frac-1-$n);
    }
  } else {
    my $x = $n-$d;
    if ($n != 2*$d-1) {
      $x = $frac + $x;
    }
    if ($n < $d) {
      # bottom-left
      my $y = -1-$n;
      if ($n != $d-1) {
        $y = -$frac + $y;
      }
      return ($x, $y);
    } else {
      # bottom-right
      return ($x, $frac-2*$d+$n);
    }
  }


  my $y = $d - abs($n);  # y=+$d at the top, down to y=-$d
  my $x = abs($y) - $d;  # 0 to $d on the right
  #### uncapped y: $y
  #### abs x: $x

  return (($n >= 0 ? $x : -$x),  # negate if on the right
          max ($y, -$d));        # cap for horiz at 5 to 6, 13 to 14 etc
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### AztecDiamondRings xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  my $s = abs($x) + abs($y);

  if ($y >= 0) {
    if ($x >= 0) {
      my $d = $x + $y;
      return (2*$d + 2)*$d + 1 + $y;
    } else {
      my $d = $y - $x;
      return (2*$d - 1)*$d - $x;
    }
  } else {
    if ($x < 0) {
      my $d = -$x - $y;
      return (2*$d - 4)*$d + 2 - $y;
    } else {
      my $d = $x - $y;
      return (2*$d + 2)*$d + 1 + $y;
    }
  }
}

# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### AztecDiamondRings rect_to_n_range(): "$x1,$y1, $x2,$y2"

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  my ($max_x, $max_y);
  {
    my $max_d = 0;
    if ($x2 >= 0 && $y2 >= 0) {
      # top right
      my $d = $x2+$y2;
      if ($d >= $max_d) {
        $max_x = $x2;
        $max_y = $y2;
        $max_d = $d;
      }
    }
    if ($x1 < 0 && $y2 >= 0) {
      # top left
      my $d = $y2-$x1-1;
      if ($d >= $max_d) {
        $max_x = $x1;
        $max_y = $y2;
        $max_d = $d;
      }
    }
    if ($x1 < 0 && $y1 < 0) {
      # bottom left
      my $d = -$y1-$x1-2;
      if ($d >= $max_d) {
        $max_x = $x1;
        $max_y = $y1;
        $max_d = $d;
      }
    }
    if ($x2 >= 0 && $y1 < 0) {
      # bottom right
      my $d = $x2-$y1-1;
      if ($d >= $max_d) {
        $max_x = $x2;
        $max_y = $y1;
        $max_d = $d;
      }
    }
  }

  my ($min_x, $min_y);
  if (($x1 < 0) != ($x2 < 0)) {
    # X=0 covered
    $min_x = 0;

    if (($y1 < 0) != ($y2 < 0)) {
      ### Y=0 covered too, so origin is minimum ...
      $min_y = 0;

    } else {
      ### Y=0 not covered, y1,y2 both neg or both pos ...
      #
      #     x1       |       x2
      #     +--------|-------+ y2
      #     |        |       |
      #     +--------|-------+ y1
      #              |
      #    ----------O-------------
      #              |
      #     x1       |       x2
      #     +--------|-------+ y2
      #     |        |       |
      #     +--------|-------+ y1
      #              |
      #
      if ($y2 < 0) {
        $min_y = $y2;
        if ($x1 < 0) {
          $min_x = -1;  # X=-1,X=0 flat section, X=-1 smaller
        }
      } else {
        $min_y = $y1;
      }
    }

  } else {
    # X origin not covered, x1 negative, x2 positive

    if (($y1 < 0) != ($y2 < 0)) {
      ### Y origin covered, y1 negative, y2 positive ...
      #
      #   x1        x2     |   x1        x2
      #    +--------+ y2   |    +--------+ y2
      #    |        |      |    |        |
      #  ------------------O--------------------
      #    |        |      |    |        |
      #    +--------+ y1   |    +--------+ y1
      #                    |
      #
      $min_y = 0;
      if ($x2 < 0) {
        $min_x = $x2;
      } else {
        $min_x = $x1;
      }

    } else {
      # X,Y neither origin covered

      # bottom right
      my $min_d;

      if ($x1 >= 0 && $y2 < 0) {
        my $d = $x1-$y2-1;
        if (! defined $min_d || $d <= $min_d) {
          $min_x = $x1;
          $min_y = $y2;
          $min_d = $d;
        }
      }
      if ($x2 < 0 && $y2 < 0) {
        # bottom left
        my $d = -$y2-$x2-2;
        if (! defined $min_d || $d <= $min_d) {
          $min_x = $x2;
          $min_y = $y2;
          $min_d = $d;
        }
      }
      if ($x2 < 0 && $y1 >= 0) {
        # top left
        my $d = $y1-$x2-1;
        if (! defined $min_d || $d <= $min_d) {
          $min_x = $x2;
          $min_y = $y1;
          $min_d = $d;
        }
      }
      if ($x1 >= 0 && $y1 >= 0) {
        # top right
        my $d = $x1+$y1;
        if (! defined $min_d || $d <= $min_d) {
          $min_x = $x1;
          $min_y = $y1;
          $min_d = $d;
        }
      }
    }
  }

  ### min at: "$min_x, $min_y"
  ### max at: "$max_x, $max_y"
  return ($self->xy_to_n($min_x,$min_y),
          $self->xy_to_n($max_x,$max_y));
}

1;
__END__

=for stopwords SquareSpiral eg AztecDiamondRings Ryde Math-PlanePath DiamondSpiral

=head1 NAME

Math::PlanePath::AztecDiamondRings -- rings around an Aztec diamond shape

=head1 SYNOPSIS

 use Math::PlanePath::AztecDiamondRings;
 my $path = Math::PlanePath::AztecDiamondRings->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes rings around an Aztec diamond shape,

                           67  66                             5
                       68  46  45  65                         4
                   69  47  29  28  44  64                     3
               70  48  30  16  15  27  43  63                 2
           71  49  31  17   7   6  14  26  42  62             1
       72  50  32  18   8   2   1   5  13  25  41  61     <- Y=0
       73  51  33  19   9   3   4  12  24  40  60  84        -1
           74  52  34  20  10  11  23  39  59  83            -2
               75  53  35  21  22  38  58  82                -3
                   76  54  36  37  57  81                    -4
                       77  55  56  80                        -5
                           78  79                            -6

                                ^
       -6  -5  -4  -3  -2  -1  X=0  1   2   3   4   5

This is very similar to the DiamondSpiral, but has all four corners
flattened to 2 vertical or horizontal, instead of just one in the
DiamondSpiral.  This is only a small change to the alignment of numbers in
the sides, but is more symmetric.

The hexagonal numbers 1,6,15,28,45,66,etc, k*(2k-1), are the vertical at X=0
going upwards.  The hexagonal numbers of the "second kind" 3,10,21,36,55,78,
etc k*(2k+1), are the vertical at X=-1 going downwards.  Combining those two
is the triangular numbers 3,6,10,15,21,etc, k*(k+1)/2, alternately on one
line and the other.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::AztecDiamondRings-E<gt>new ()>

Create and return a new Aztec diamond spiral object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

For C<$n < 1> the return is an empty list, it being considered the path
starts at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each
point in the path as a square of side 1, so the entire plane is covered.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

The returned range is exact, meaning C<$n_lo> and C<$n_hi> are the smallest
and biggest in the rectangle.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DiamondSpiral>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011 Kevin Ryde

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
# compile-command: "math-image --path=AztecDiamondRings --lines"
# End:
#
# math-image --path=AztecDiamondRings --all --output=numbers --size=60x14
