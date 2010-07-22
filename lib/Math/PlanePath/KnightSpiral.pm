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
use POSIX 'floor';

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 5;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments '###';

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

  my $d = int (.25 * (7 + sqrt($n - 1)));
  my $d1 = $d-1;
  my $outer = 2*$d1;
  my $inner = $outer - 1;
  my $p = 2*$d1;
  my $p1 = $p - 1;

  # use Smart::Comments;

  #### s frac: .25 * (7 + sqrt($n - 1))
  #### $d
  #### $d1
  #### $inner
  #### $outer
  #### $p
  #### $p1

  $n -= $d*(16*$d - 56) + 50;
  #### remainder: $n

  # one
  #
  if ($n < $p1) {
    #### right upwards, eg 2
    return ($outer - _odd($n),
            -$inner + 2*$n);
  }
  $n -= $p1;

  if ($n < $p1) {
    #### top leftwards, eg 3
    return ($inner - 2*$n,
            $inner + _odd($n));
  }
  $n -= $p1;

  if ($n < $p) {
    #### left downwards
    return (-$inner - _odd($n),
            $outer - 2*$n);
  }
  $n -= $p;

  if ($n < $p1) {
    #### bottom rightwards: $n
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
    #### top leftwards
    return ($outer - 2*$n,
            $inner + _odd($n));
  }
  $n -= $p;

  if ($n < $p1) {
    #### left downwards
    return (-$outer + _odd($n),
            $inner - 2*$n);
  }
  $n -= $p1;

  if ($n < $p1) {
    #### bottom rightwards: $n
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
    #### top leftwards, eg 14
    return ($inner - 2*$n,
            $outer - _odd($n));
  }
  $n -= $p1;

  if ($n < $p1) {
    #### left downwards, eg 15
    return (-$inner - _odd($n),
            $inner - 2*$n);
  }
  $n -= $p1;

  if ($n < $p1) {
    #### bottom rightwards, eg 16
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
    #### top leftwards, eg 19
    return ($outer - 2*$n,
            $outer - _odd($n));
  }
  $n -= $p;

  if ($n < $p) {
    #### left downwards, eg 21
    return (-$outer + _odd($n),
            $outer - 2*$n);
  }
  $n -= $p;

  if ($n < $p) {
    #### bottom rightwards, eg 23
    return (-$outer + 2*$n,
            -$outer + _odd($n));
  }
  $n -= $p;

  #### step outwards, eg 25
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
  $x = floor ($x + 0.5);
  $y = floor ($y + 0.5);
  if ($x == 0 && $y == 0) { return 1; }

  my $r = max(abs($x),abs($y));
  my $d = int (($r+1)/2);  # ring number, counting $x=1,2 as $d==1
  $r -= (~$r & 1);  # next lower odd number
  ### $d
  ### $r

  if ($y >= $r) {
    ### top horizontal
    my $xodd = ($x & 1);
    $x = ($x - $xodd) / 2;
    ### $xodd
    ### $x

    # x odd
    # [3,30,89,180,303]         (16*$d**2 + -21*$d + 8)
    # [14,57,132,239,378,549]   (16*$d**2 + -5*$d + 3)
    # 
    # [9,44,111,210,341,504]    (16*$d**2 + -13*$d + 6)
    # [20,71,154,269,416]       (16*$d**2 + 3*$d + 1)

    my $n = 16*$d*$d - $x;
    if (($x ^ $y ^ $d) & 1) {
      if ($xodd) {
        return $n -5*$d + 3;
      } else {
        return $n -13*$d + 6;
      }
    } else {
      if ($xodd) {
        return $n -21*$d + 8;
      } else {
        return $n + 3*$d + 1;
      }
    }
  }

  # the lower left outer corner 25,81,169,etc belongs on the bottom
  # horizontal, it's not an extension downwards from the right vertical
  # (positions N=18,66,146,etc), hence $x!=-$y
  #
  if ($x >= $r && $x != -$y) {
    ### right vertical
    my $yodd = ($y & 1);
    $y = ($y - $yodd) / 2;
    ### $yodd
    ### $y

    # y odd
    # [3, 28,85, 174,295, 448,633]  (16*$d**2 + -23*$d + 10)
    # [8,41, 106,203, 332,493]      (16*$d**2 + -15*$d + 7)
    #
    # y even
    # [13,54,127,232,369,538]      (16*$d**2 + -7*$d + 4)
    # [18,67,148,261,406,583,792]  (16*$d**2 + $d + 1)
    #
    my $n = 16*$d*$d + $y;
    if (($x ^ $y ^ $d) & 1) {
      if ($yodd) {
        return $n -15*$d + 7;
      } else {
        return $n -7*$d + 4;
      }
    } else {
      if ($yodd) {
        return $n -23*$d + 10;
      } else {
        return $n + $d + 1;
      }
    }
  }

  if ($y <= -$r) {
    ### bottom horizontal
    my $xodd = ($x & 1);
    $x = ($x - $xodd) / 2;
    ### $xodd
    ### $x

    # x odd
    # [7,38,101,196,323]         (16*$d**2 + -17*$d + 8)
    # [12,51,122,225,360,527]    (16*$d**2 + -9*$d + 5)
    #
    # x even
    # [17,64,143,254,397,572]    (16*$d**2 + -1*$d + 2)
    # [24,79,166,285,436]        (16*$d**2 + 7*$d + 1)

    my $n = 16*$d*$d + $x;
    if (($x ^ $y ^ $d) & 1) {
      if ($xodd) {
        return $n -9*$d + 5;
      } else {
        return $n -1*$d + 2;
      }
    } else {
      if ($xodd) {
        return $n -17*$d + 8;
      } else {
        return $n + 7*$d + 1;
      }
    }
  }

  if ($x <= -$r) {
    ### left vertical
    my $yodd = ($y & 1);
    $y = ($y - $yodd) / 2;
    ### $yodd
    ### $y

    # y odd
    # [10,47,116,217,350,515]  (16*$d**2 + -11*$d + 5)
    # [15,60,137,246,387]      (16*$d**2 + -3*$d + 2)
    #
    # y even
    # [5,34,95,188,313]    (16*$d**2 + -19*$d + 8)
    # [22,75,160,277,426]  (16*$d**2 + 5*$d + 1)
    #
    my $n = 16*$d*$d - $y;
    if (($x ^ $y ^ $d) & 1) {
      if ($yodd) {
        return $n -11*$d + 5;
      } else {
        return $n -19*$d + 8;
      }
    } else {
      if ($yodd) {
        return $n -3*$d + 2;
      } else {
        return $n + 5*$d + 1;
      }
    }
  }
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  my $x = max(abs($x1),abs($x2));
  my $y = max(abs($y1),abs($y2));
  $x = floor($x+0.5);
  $y = floor($y+0.5);

  my $d = max(abs($x),abs($y));
  $d += ($d & 1);  # next even number if not already even
  ### $x
  ### $y
  ### $d
  ### is: $d*$d

  $d = 2*$d+1;  # width of whole square
  # ENHANCE-ME: find actual minimum if rect doesn't cover 0,0
  return (1,
          1 + $d*$d);
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
        21   4   9  14  19                 2
                              
        10  15  20   3   8      28         1
                              
         5  22   1  18  13            <- y=0
                              
        16  11  24   7   2  27             1
                              
        23   6  17  12  25                 2
      
                                26

                 ^
        -2  -1  x=0  1   2   3

Each step is a chess knight's move 1 across and 2 along, or vice versa.  The
pattern makes 4 cycles on a 2-wide path around a square before stepping
outwards to do the same again to a now bigger square.  The above sample
shows the first 4-cycle around the central 1 then stepping out at 26 and
beginning to go around the outside of the now 5x5 square.

An attractive traced out picture of the path can be seen at the following
page (quarter way down under "Open Knight's Tour"),

    http://www.borderschess.org/KTart.htm

See the C<math-image> program to draw the path lines too.  Or
F<examples/knights-sloane.pl> expressing the knight's tour by the numbering
of the SquareSpiral (Sloane's sequence A068608).

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::KnightSpiral-E<gt>new ()>

Create and return a new square spiral object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> on the path.

For C<$n < 1> the return is an empty list, it being considered the path
starts at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
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