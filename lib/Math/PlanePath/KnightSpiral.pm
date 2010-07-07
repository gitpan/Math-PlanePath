# Copyright 2010 Kevin Ryde

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


package Math::PlanePath::KnightSpiral;
use 5.004;
use strict;
use warnings;
use List::Util qw(max);
use POSIX ();

use vars '$VERSION', '@ISA';
$VERSION = 2;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

sub _odd {
  my ($n) = @_;
  return abs (POSIX::fmod($n+1,2) - 1);
}

sub n_to_xy {
  my ($self, $n) = @_;
  #### KnightSpiral n_to_xy: $n
  if ($n < 1) { return; }
  if ($n < 2) {
    $n--;
    return (2*$n, -$n);
  }

  my $s = int (.25 * (7 + sqrt($n - 1)));
  my $s1 = $s-1;
  my $outer = 2*$s1;
  my $inner = $outer - 1;
  my $p = 2*$s1;
  my $p1 = $p - 1;

  # use Smart::Comments;

  ### s frac: .25 * (7 + sqrt($n - 1))
  ### $s
  ### $s1
  ### $inner
  ### $outer
  ### $p
  ### $p1

  $n -= $s*(16*$s - 56) + 50;
  #### remainder: $n

  # one
  #
  if ($n < $p1) {
    ### right upwards, eg 2
    return ($outer - _odd($n),
            -$inner + 2*$n);
  }
  $n -= $p1;

  if ($n < $p1) {
    ### top leftwards, eg 3
    return ($inner - 2*$n,
            $inner + _odd($n));
  }
  $n -= $p1;

  if ($n < $p) {
    ### left downwards
    return (-$inner - _odd($n),
            $outer - 2*$n);
  }
  $n -= $p;

  if ($n < $p1) {
    ### bottom rightwards: $n
    return (-$inner + 2*$n,
            -$outer + _odd($n));
  }
  $n -= $p1;



  # two
  #
  if ($n < $p1) {
    # right upwards
    return ($inner + _odd($n),
            -$inner + 2*$n);
  }
  $n -= $p1;

  if ($n < $p) {
    ### top leftwards
    return ($outer - 2*$n,
            $inner + _odd($n));
  }
  $n -= $p;

  if ($n < $p1) {
    ### left downwards
    return (-$outer + _odd($n),
            $inner - 2*$n);
  }
  $n -= $p1;

  if ($n < $p1) {
    ### bottom rightwards: $n
    return (-$inner + 2*$n,
            -$inner - _odd($n));
  }
  $n -= $p1;



  # three
  #
  if ($n < $p) {
    # right upwards, eg 12
    return ($inner + _odd($n),
            -$outer + 2*$n);
  }
  $n -= $p;

  if ($n < $p1) {
    ### top leftwards, eg 14
    return ($inner - 2*$n,
            $outer - _odd($n));
  }
  $n -= $p1;

  if ($n < $p1) {
    ### left downwards, eg 15
    return (-$inner - _odd($n),
            $inner - 2*$n);
  }
  $n -= $p1;

  if ($n < $p1) {
    ### bottom rightwards, eg 16
    return (-$outer + 2*$n,
            -$inner - _odd($n));
  }
  $n -= $p1;


  # four
  #
  if ($n < $p) {
    # right upwards, eg 17 special cross
    return ($outer - _odd($n) - 2*($n == 0),
            -$outer + 2*$n);
  }
  $n -= $p;

  if ($n < $p) {
    ### top leftwards, eg 19
    return ($outer - 2*$n,
            $outer - _odd($n));
  }
  $n -= $p;

  if ($n < $p) {
    ### left downwards, eg 21
    return (-$outer + _odd($n),
            $outer - 2*$n);
  }
  $n -= $p;

  if ($n < $p) {
    ### bottom rightwards, eg 23
    return (-$outer + 2*$n,
            -$outer + _odd($n));
  }
  $n -= $p;

  ### step outwards, eg 25
    return ($outer + 2*$n,
            -$outer - _odd($n));
}


#   157   92  113  134  155   90  111  132  153   88  109  130  151
#   114  135  156   91  112  133  154   89  110  131  152   87  108
#    93  158   73   32   45   58   71   30   43   56   69  150  129
#   136  115   46   59   72   31   44   57   70   29   42  107   86
#   159   94   33   74   21    4    9   14   19   68   55  128  149
#   116  137   60   47   10   15   20    3    8   41   28   85  106
#    95  160|  75   34 |  5   22    1   18   13 | 54   67| 148  127
#   138  117   48   61   16   11   24    7    2   27   40  105   84
#   161   96   35   76   23    6   17   12   25   66   53  126  147
#   118  139   62   49   78   37   64   51   80   39   26   83  104
#    97  162   77   36   63   50   79   38   65   52   81  146  125
#   140  119  164   99  142  121  166  101  144  123  168  103   82
#   163   98  141  120  165  100  143  122  167  102  145  124  169

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = POSIX::floor ($x + 0.5);
  $y = POSIX::floor ($y + 0.5);
  if ($x == 0 && $y == 0) { return 1; }

  my $s = max(abs($x),abs($y));
  $s = int (($s+1)/2);  # ring number, counting first as 1
  # entry to ring $s
  # 2, 26, 82, 170  16*$s^2 + -24*$s + 10
  my $lo = $s*(16*$s - 24) + 10;
  my $hi = ($s+1)*(16*($s+1) - 24) + 10;

  ### $x
  ### $y
  ### $s
  ### $lo
  ### $hi

  foreach my $n ($lo .. $hi) {
    my ($nx,$ny) = $self->n_to_xy($n);
    if ($nx == $x && $ny == $y) {
      return $n;
    }
  }
  return;

  #   if ($x < 0) {
  #     if (abs($x) >= abs($y)) {
  #       my $s = int (($x+1) / 2);
  #       # 21, 73, 157    16*$s^2 + 4*$s + 1
  #       # 10, 46, 114    16*$s^2 + -12*$s + 6
  #       # 15, 59, 135    16*$s^2 + -4*$s + 3
  #
  #       my $base = 16*$s*$s;
  #       if ($x & 1) {
  #         if ($y & 1) {
  #
  #
  #           foreach my $n ($base + 4*$s + 1,
  #                          $base + -20*$s + 8,
  #                          $base + -12*$s + 6,
  #                          $base + -4*$s + 3) {
  #           }
  #         } else {
  #         }
  #       } else {
  #         if ($y & 1) {
  #         } else {
  #           #  5, 75, 95    -20*$s^2 + 120*$s + -85
  #           return ($base + 120*$s + -85
  #                   - $y/2);
  #         }
  #       }
  #     }
  #   }
  #
  #   return;
  #
  #
  #   my $d = max(abs($x),abs($y));
  #   my $n = 4*$d*$d + 1;
  #   if ($y == $d) {     # top
  #     return $n - $d - $x;
  #   }
  #   if ($y == - $d) {   # bottom
  #     return $n + 3*$d + $x;
  #   }
  #   if ($x == $d) {     # right
  #     return $n - 3*$d + $y;
  #   }
  #   # ($x == - $d)    # left
  #   return $n + $d - $y;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  my $x = max(abs($x1),abs($x2));
  my $y = max(abs($y1),abs($y2));
  $x = POSIX::floor($x+0.5);
  $y = POSIX::floor($y+0.5);

  my $s = max(abs($x),abs($y));
  $s += ($s & 1);  # next even number if not already even
  ### $x
  ### $y
  ### $s
  ### is: $s*$s

  $s = 2*$s+1;  # width of whole square
  # ENHANCE-ME: find actual minimum if rect doesn't cover 0,0
  return (1,
          1 + $s*$s);
}

1;
__END__

=for stopwords versa PlanePath Ryde Math-PlanePath SquareSpiral

=head1 NAME

Math::PlanePath::KnightSpiral -- integer points drawn around a square

=head1 SYNOPSIS

 use Math::PlanePath::KnightSpiral;
 my $path = Math::PlanePath::KnightSpiral->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path traverses the plane with an infinite "knight's tour" in the form
of a square spiral.

                            ...
        21   4   9  14  19              2
                              
        10  15  20   3   8      28      1
                              
         5  22   1  18  13         <- y=0
                              
        16  11  24   7   2  27          1
                              
        23   6  17  12  25              2
      
                                26
                 ^
        -2  -1  x=0  1   2   3

Each step is a chess knight's move 1 across and 2 along, or vice versa.  The
pattern makes 4 cycles on a 2-wide path around a square before stepping
outwards to do the same again to a then bigger square.  The above sample
shows the first 4-cycle around the central 1 then stepping out at 26 and
beginning to go around the outside of the now 5x5 square.

A traced out picture of the path can be seen at the following page (quarter
way down under "Open Knight's Tour"),

    http://www.borderschess.org/KTart.htm

The C<math-image> program can draw the path lines too.  And see
F<examples/knights-sloane.pl> expressing the knight's tour by the numbering
of the SquareSpiral (sequence A068608 of Sloane's On-Line Encyclopedia of
Integer Sequences).

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::KnightSpiral-E<gt>new (key=E<gt>value, ...)>

Create and return a new square spiral object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> on the path.

For C<$n < 1> the return is an empty list, it being considered the path
starts at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x>,C<$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each N
in the path as centred in a square of side 1, so the entire plane is
covered.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SquareSpiral>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Math-PlanePath is Copyright 2010 Kevin Ryde

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
