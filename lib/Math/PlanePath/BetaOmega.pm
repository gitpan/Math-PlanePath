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


# http://www.upb.de/pc2/papers/files/pdfps399main.toappear.ps   # gone
# http://wwwcs.upb.de/pc2/papers/files/399.ps   # gone  
#
# copy ?
# http://www.cs.uleth.ca/~wismath/cccg/papers/27l.ps


package Math::PlanePath::BetaOmega;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 52;
use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;


use constant n_start => 0;
use constant x_negative => 0;

sub n_to_xy {
  my ($self, $n) = @_;
  ### BetaOmega n_to_xy(): $n
  ### hex: sprintf "%#X", $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  {
    # ENHANCE-ME: determine dx/dy direction from N bits, not full
    # calculation of N+1
    my $int = int($n);
    if ($n != $int) {
      my $frac = $n - $int;  # inherit possible BigFloat/BigRat
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int;
  }

  my @digits;
  my $len = $n*0 + 1;
  my $state = 4;
  my $x = 0;
  my $y = 0;
  while ($n) {
    push @digits, $n % 4;
    $n = int($n/4);
    $len *= 2;
    $state ^= 4;
    $y = ($len - $y);
    ### $y
  }
  ### digits: scalar(@digits)
  ### $len
  ### initial y: $y
  if (@digits & 1) {
    $y = ($len - $y);
    ### invert y: $y
  }
  $y = -$y;
  if ($n) { return; }

  # while ($n) {
  #   push @digits, $n % 4;
  #   $n = int($n/4);
  #   $len *= 2;
  #   $state ^= 4;
  # }

#  if ($n > 256) { return; }

  my $transpose = ($#digits & 1);
  my $rot = -$transpose;
  my $rev = 0;
  my $omega = 0;

  while (@digits) {
    $len /= 2;
    my $digit = pop @digits;
    # ### $state
    ### $digit
    ### $rot
    ### $transpose
    ### $rev

    if ($rev) {
      $digit = 3-$digit;
    }

    my $xo = 0;
    my $yo = 0;
    my $new_transpose = $transpose;
    my $new_rot = $rot;
    if ($omega) {
      $omega = 0;
      if ($digit == 0) {
        $new_transpose = $transpose ^ 1;
        if ($transpose) {
          $new_rot = $rot + 1;
        } else {
          $new_rot = $rot - 1;
        }
      } elsif ($digit == 1) {
        $yo = 1;
        if ($transpose) {
          $new_rot = $rot - 1;
        } else {
          $new_rot = $rot + 1;
        }
      } elsif ($digit == 2) {
        $xo = 1;
        $yo = 1;
        $new_transpose = $transpose ^ 1;
        $rev ^= 1;
      } elsif ($digit == 3) {
        $xo = 1;
        $new_rot = $rot + 2;
        $rev ^= 1;
      }

    } else {
      if ($digit == 0) {
        $new_transpose = $transpose ^ 1;
        if ($transpose) {
          $new_rot = $rot + 1;
        } else {
          $new_rot = $rot - 1;
        }
      } elsif ($digit == 1) {
        $yo = 1;
        if ($transpose) {
          $new_rot = $rot - 1;
        } else {
          $new_rot = $rot + 1;
        }
      } elsif ($digit == 2) {
        $xo = 1;
        $yo = 1;
        $new_transpose = $transpose ^ 1;
        $rev ^= 1;
      } elsif ($digit == 3) {
        $xo = 1;
        if ($transpose) {
          $new_rot = $rot + 1;
        } else {
          $new_rot = $rot - 1;
        }
        $omega = 1;
      }
    }
    ### base: "$xo, $yo"

    if ($transpose) {
      ($xo,$yo) = ($yo,$xo);
    }
    ### transp to: "$xo, $yo"

    if ($rot & 2) {
      $xo ^= 1;
      $yo ^= 1;
    }
    if ($rot & 1) {
      ($xo,$yo) = ($yo^1,$xo);
    }
    ### rot to: "$xo, $yo"

    if ($xo) { $x += $len; }
    if ($yo) { $y += $len; }
    ### apply: ($xo*$len).', '.($yo*$len)

    $transpose = $new_transpose;
    $rot = $new_rot;

    # $state += $digit;
    # $x += $len * $state_x[$state];
    # $y += $len * $state_y[$state];
    # $state = $next_state[$state];
  }

  ### final: "$x,$y"
  return ($x, $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### BetaOmega xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($x < 0) {
    return undef;
  }
  if (_is_infinite($x)) {
    return $x;
  }
  if (_is_infinite($y)) {
    return abs($y);
  }

  my $n = ($x * 0 * $y);

  my ($len, $level) = _round_down_pow (($x > 4*$y ? $x : 4*$y),
                                       2);
  $len *= 8;
  $level += 3;
  $len *= $len;
  $level *= 2;
  # $len = 64;
  # $level = 6;

  ### $len
  ### $level

  my $transpose = 0;
  my $rot = 0;
  if ($level & 1) {
    my $offset = ($len - 2) / 3;
    ### half offset: $offset
    $y += $offset;
  } else {
    my $offset = (2*$len - 2) / 3;
    ### $offset
    $y += $offset;
    $transpose = 1;
    $rot = -1;
  }
  ### offset y to: "$x, $y"
  ### assert: $y >= 0

  my $rev = 0;
  my $omega = 0;

  while (--$level >= 0) {
    $len /= 2;

    ### at: "$x,$y  len=$len"
    ### $transpose
    ### $rot
    ### $rev
    ### $omega

    ### assert: $x < 2*$len
    ### assert: $y < 2*$len

    my $xo;
    if ($x >= $len) {
      $xo = 1;
      $x -= $len;
    } else {
      $xo = 0;
    }
    my $yo;
    if ($y >= $len) {
      $yo = 1;
      $y -= $len;
    } else {
      $yo = 0;
    }
    ### start: "$xo, $yo"

    if ($rot & 2) {
      $xo ^= 1;
      $yo ^= 1;
    }
    if ($rot & 1) {
      ($xo,$yo) = ($yo,$xo^1);
    }
    ### rot to: "$xo, $yo"

    if ($transpose) {
      ($xo,$yo) = ($yo,$xo);
      ### transp to: "$xo, $yo"
    }

    my $new_rev = $rev;
    my $new_omega = 0;
    my $digit;
    if ($xo) {
      if ($yo) {
        $digit = 2;
        $new_rev ^= 1;
        $transpose ^= 1;

      } else {
        $digit = 3;
        if ($omega) {
          $new_rev ^= 1;;
          $rot += 2;

        } else {
          $new_omega = 1;
          if ($transpose) {
            $rot++;
          } else {
            $rot--;
          }
        }
      }

    } else {
      if ($yo) {
        $digit = 1;
        if ($transpose) {
          $rot--;
        } else {
          $rot++;
        }

      } else {
        $digit = 0;
        if ($transpose) {
          $rot++;
        } else {
          $rot--;
        }
        $transpose ^= 1;
      }
    }
    ### $digit

    if ($rev) {
      $digit = 3-$digit;
      ### digit reversed: $digit
    }
    $omega = $new_omega;
    $rev = $new_rev;
    $n = 4*$n + $digit;
  }

  ### assert: $x == 0
  ### assert: $y == 0

  return $n;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### BetaOmega rect_to_n_range(): "$x1,$y1, $x2,$y2"

  $x1 = _round_nearest ($x1);
  $x2 = _round_nearest ($x2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;

  if ($x2 < 0) {
    return (1, 0);
  }

  $y1 = _round_nearest ($y1);
  $y2 = _round_nearest ($y2);
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  $y1 = -6*$y1 - 2;
  $y2 = 12*$y2 - 8;
  ### tripled y: "$y1, $y2"

  my ($ylen, $ylevel) = _round_down_pow (($y1 > $y2 ? $y1 : $y2),
                                         4);
  if (_is_infinite($ylen)) {
    return (0, $ylevel);
  }
  $ylen *= $ylen;
  ### $ylevel
  ### $ylen

  my ($xlen, $xlevel) = _round_down_pow ($x2, 4);
  if (_is_infinite($xlevel)) {
    return (0, $xlevel);
  }
  $xlen *= 4;
  $xlen *= $xlen;
  ### $xlevel
  ### $xlen

  return (0,
          ($xlen > $ylen ? $xlen : $ylen) - 1);
}

1;
__END__

# #             1--2
# # state=0     |  |    beta
# #           --0  3
# #                |
# #
# #                |   
# #           --0  3
# # state=4     |  |    beta
# #             1--2
# #
# #                |
# #             1--0
# # state=8     |        beta
# #             2--3--
# #
# #             |
# #             3--2
# # state=12       |    beta
# #           --0--1
# #              
# #             |
# #             3--2
# # state=16       |    omega
# #             0--1
# #             |
# #
# #             2--3--
# # state=20    |        beta
# #             1--0
# #                |
# #
# #             |
# #             3  0--
# # state=24    |  |     beta
# #             2--1
# #
# #             1--2
# # state=28    |  |     beta
# #             0  3--
# #             |  
# #
# #             1--2
# # state=32    |  |    omega
# #           --0  3--
# #
# #           --0--1
# # state=36       |    beta
# #             3--2
# #             |
# #
# 
# 
# 
# #
# #             2--1
# # state=16    |  |    beta
# #             3  0--
# #             |
# #
# 
# #                |
# #             1--0
# # state=36    |       omega
# #             2--3
# #                |
# #
# #           --3  0--
# # state=44    |  |    omega
# #             2--1
# #
# my @next_state = (4, 20, 36, 34,     # 0
#                   0,  8, 12, 16,    # 4
#                   12, 8,  8, 32,      # 8
#                   8,12,12,32,    # 12
#                   20,16,16,32,   # 16
#                   16,24,28,32,   # 20
#                   28,36,16,32,   # 24
#                   24,16,16,32,   # 28
#                   20,24,36,0,   # 32
#                   0,0,0,0,   # 36
#                  );
# #           --0--1
# # state=36       |    beta
# #             3--2
# #             |
# my @state_x = (0,0,1,1,   # 0
#                0,0,1,1,   # 4
#                1,0,0,1,   # 8
#                0,1,1,0,   # 12
#                0,1,1,0,   # 16
#                1,0,0,1,   # 20
#                1,1,0,0,   # 24
#                0,0,1,1,   # 28
#                0,0,1,1,   # 32
#                0,1,1,0,   # 36
# 
#                0,1,1,0,   # 16
#                0,1,1,0,   # 16
#                0,1,1,0,   # 16
#                0,1,1,0,   # 16
#                0,1,1,0,   # 16
#                0,1,1,0,   # 16
#               );
# my @state_y = (0, 1, 1, 0,   # 0
#                0,-1,-1, 0,   # 4
#                1,1,0,0,   # 8
#                0,0,1,1,   # 12
#                0,0,1,1,   # 16
#                -1,-1,0,0,   # 20
#                1,0,0,1,    # 24
#                0,1,1,0,    # 28
#                0,1,1,0,    # 32
#                0,0,-1,-1,   # 36
# 
#                0, 0, -1, -1,   # 36
#                0, 0, -1, -1,   # 16
#                0, 0, -1, -1,   # 16
#                0, 0, -1, -1,   # 16
#                0, 0, -1, -1,   # 16
#                0, 0, -1, -1,   # 16
#                0, 0, -1, -1,   # 16
#                0, 0, -1, -1,   # 16
#                0, 0, -1, -1,   # 16
#                0, 0, -1, -1,   # 16
#               );
# 
#     # $state += $digit;
#     # $x += $len * $state_x[$state];
#     # $y += $len * $state_y[$state];
#     # $state = $next_state[$state];
# 
# my @digit_x = (0,0,1,1);
# my @digit_y = (0,1,1,0);


=for stopwords HilbertCurve eg Ryde OEIS ZOrderCurve ie bignums prepending BetaOmega Math-PlanePath

=head1 NAME

Math::PlanePath::BetaOmega -- 2x2 half-plane traversal

=head1 SYNOPSIS

 use Math::PlanePath::BetaOmega;
 my $path = Math::PlanePath::BetaOmega->new;
 my ($x, $y) = $path->n_to_xy (123);


=head1 DESCRIPTION

This is an integer version of the Beta-Omega curve by Jens-Michael Wierum.
It makes a 2x2 self-similar traversal of a half plane (XE<gt>=0),
                                        
      5   25--26  29--30  33--34  37--38
           |   |   |   |   |   |   |   |
      4   24  27--28  31--32  35--36  39
           |                           |
      3   23  20--19--18  45--44--43  40
           |   |       |   |       |   |
      2   22--21  16--17  46--47  42--41
                   |           |        
      1    1-- 2  15--14  49--48  53--54
           |   |       |   |       |   |
    Y=0->  0   3  12--13  50--51--52  55
               |   |                   |
     -1    5-- 4  11--10  61--60--59  56
           |           |   |       |   |
     -2    6-- 7-- 8-- 9  62--63  58--57
                               |        
     -3                       ...

         X=0   1   2   3   4   5   6   7 

Each level extends in (2^level)x(2^level) blocks alternately above or below.
The initial N=0 to N=3 extends up from Y=0 and exits the block downwards as
N=4 and extends downwards through to exit upwards at N=15.  Then N=16
extends upwards through to N=63 which exits downwards, etc.

The curve is named for the two base shapes

         Beta                     Omega

           *---*                  *---*
           |   |                  |   |
         --*   *                --*   *--
               |

The beta comprises three betas and an omega, the omega comprises four betas,
in each case suitably rotated, transposed or reversed, so expanding to.

      *---*---*---*            *---*---*---*
      |           |            |           |
      *---*   *---*            *---*   *---*
          |   |                    |   |    
    --*   *   *---*          --*   *   *   *--
      |   |       |            |   |   |   |
      *---*   *---*            *---*   *---*
              |

The curve is expressed in terms of repeated ever-smaller substitutions,
which has the effect of making the start a beta going alternately up or
down.  For this integer version of the path the start direction is fixed as
a beta going upwards and the higher levels alternately up and down from that
orientation.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::BetaOmega-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::HilbertCurve>

Jens-Michael Wierum "Definition of a New Circular Space-Filling Curve:
Beta-Omega-Indexing", Technical Report TR-001-02, Paderborn Center for
Parallel Computing, March 2002.

Jens-Michael Wierum, "Logarithmic Path-Length in Space-Filling Curves", 14th
Canadian Conference on Computational Geometry (CCCG'02), 2002.

    http://www.cccg.ca/proceedings/2002/
    http://www.cccg.ca/proceedings/2002/27.ps     [shorter]
    http://www.cccg.ca/proceedings/2002/27l.ps    [longer]

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

    #                                                |
    #   5   25--26  29--30  33--34  37--38 249-250 255-254 233-232-231-230 
    #        |   |   |   |   |   |   |   |   |   |       |   |           | 
    #   4   24  27--28  31--32  35--36  39 248 251-252-253 234-235 228-229 
    #        |                           |   |                   |   |     
    #   3   23  20--19--18  45--44--43  40 247 244-243 240-239 236 227-226 
    #        |   |       |   |       |   |   |   |   |   |   |   |       | 
    #   2   22--21  16--17  46--47  42--41 246-245 242-241 238-237 224-225 
    #                |           |                                   |     
    #   1    1-- 2  15--14  49--48  53--54 201-202 205-206 209-210 223-222 
    #        |   |       |   |       |   |   |   |   |   |   |   |       | 
    # Y=0->  0   3  12--13  50--51--52  55 200 203-204 207-208 211 220-221 
    #            |   |                   |   |                   |   |     
    #  -1    5-- 4  11--10  61--60--59  56 199 196-195-194 213-212 219-218 
    #        |           |   |       |   |   |   |       |   |           | 
    #  -2    6-- 7-- 8-- 9  62--63  58--57 198-197 192-193 214-215-216-217 
    #                            |                   |                     
    #  -3   89--88--87--86  65--64  69--70 185-186 191-190 169-168-167-166 
    #        |           |   |       |   |   |   |       |   |           | 
    #  -4   90--91  84--85  66--67--68  71 184 187-188-189 170-171 164-165 
    #            |   |                   |   |                   |   |     
    #  -5   93--92  83  80--79  76--75  72 183 180-179 176-175 172 163-162 
    #        |       |   |   |   |   |   |   |   |   |   |   |   |       | 
    #  -6   94--95  82--81  78--77  74--73 182-181 178-177 174-173 160-161 
    #            |                                                   |     
    #  -7   97--96 109-110 113-114 125-126 129-130 141-142 145-146 159-158 
    #        |       |   |   |   |   |   |   |   |   |   |   |   |       | 
    #  -8   98--99 108 111-112 115 124 127-128 131 140 143-144 147 156-157 
    #            |   |           |   |           |   |           |   |     
    #  -9  101-100 107-106 117-116 123-122 133-132 139-138 149-148 155-154 
    #        |           |   |           |   |           |   |           | 
    # -10  102-103-104-105 118-119-120-121 134-135-136-137 150-151-152-153 
    # 
    #       ^    
    #      X=0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15




# Local variables:
# compile-command: "math-image --path=BetaOmega --lines --scale=20"
# End:
#
# math-image --path=BetaOmega --all --output=numbers_dash
