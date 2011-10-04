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


# math-image --path=QuadricIslands --lines --scale=10
# math-image --path=QuadricIslands --all --output=numbers_dash --size=132x50

# area approaches sqrt(48)/10


package Math::PlanePath::QuadricIslands;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX qw(floor ceil);
use Math::PlanePath::QuadricCurve;

use vars '$VERSION', '@ISA';
$VERSION = 47;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

# uncomment this to run the ### lines
#use Devel::Comments;


# N=1 to 4      4 of, level=0
# N=5 to 36    12 of, level=1
# N=37 to ..   48 of, level=3
#
# each loop = 4*8^level
#
#     n_base = 1 + 4*8^0 + 4*8^1 + ... + 4*8^(level-1)
#            = 1 + 4*[ 8^0 + 8^1 + ... + 8^(level-1) ]
#            = 1 + 4*[ (8^level - 1)/7 ]
#            = 1 + 4*(8^level - 1)/7
#            = (4*8^level - 4 + 7)/7
#            = (4*8^level + 3)/7
#
#     n >= (4*8^level + 3)/7
#     7*n = 4*8^level + 3
#     (7*n - 3)/4 = 8^level
#
#    nbase(k+1)-nbase(k)
#       = (4*8^(k+1)+3  - (4*8^k+3)) / 7
#       = (4*8*8^k - 4*8^k) / 7
#       = (4*8-4) * 8^k / 7
#       = 28 * 8^k / 7
#       = 4 * 8^k
#
#    nbase(0) = (4*8^0 + 3)/7 = (4+3)/7 = 1
#    nbase(1) = (4*8^1 + 3)/7 = (4*8+3)/7 = (32+3)/7 = 35/7 = 5
#    nbase(2) = (4*8^2 + 3)/7 = (4*64+3)/7 = (256+3)/7 = 259/7 = 37
#
### loop 1: 4* 8**1
### loop 2: 4* 8**2
### loop 3: 4* 8**3

# sub _level_to_base {
#   my ($level) = @_;
#   return (4*8**$level + 3) / 7;
# }
# ### level_to_base(1): _level_to_base(1)
# ### level_to_base(2): _level_to_base(2)
# ### level_to_base(3): _level_to_base(3)

sub n_to_xy {
  my ($self, $n) = @_;
  ### QuadricIslands n_to_xy(): $n
  if ($n < 1) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  my ($base,$level) = _round_down_pow ((7*$n - 3)/4, 8);
  $base = (4*$base + 3)/7;  # (4 * 8**$level + 3)/7

  ### $level
  ### $base
  ### next base would be: (4 * 8**($level+1) + 3)/7

  my $rem = $n - $base;
  ### $rem

  ### assert: $n >= $base
  ### assert: $n < 8**($level+1)
  ### assert: $rem>=0
  ### assert: $rem < 4 * 8 ** $level

  my $sidelen = 8**$level;
  my $side = int($rem / $sidelen);
  ### $sidelen
  ### $side
  ### $rem
  $rem -= $side*$sidelen;
  ### assert: $side >= 0 && $side < 4
  my ($x, $y) = Math::PlanePath::QuadricCurve::n_to_xy ($self, $rem);

  my $pos = 4**$level / 2;
  ### side calc: "$x,$y   for pos $pos"

  if ($side < 1) {
    ### horizontal rightwards
    return ($x - $pos,
            $y - $pos);
  } elsif ($side < 2) {
    ### right vertical upwards
    return ($pos - $y,     # rotate +90, offset
            $x - $pos);
  } elsif ($side < 3) {
    ### horizontal leftwards
    return ($pos - $x,     # rotate 180, offset
            $pos - $y)
  } else {
    ### left vertical downwards
    return ($y - $pos,     # rotate -90, offset
            $pos - $x);
  }
}

my @inner_to_n = (1,2,4,3);

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### QuadricIslands xy_to_n(): "$x, $y"

  if (abs($x) <= .75 && abs($y) <= .75) {
    return $inner_to_n[($x >= 0) + 2*($y >= 0)];
  }
  $x = _round_nearest($x);
  $y = _round_nearest($y);

  my $high;
  if ($x >= $y + ($y>0)) {
    # +($y>0) to exclude the downward bump of the top side
    ### below leading diagonal ...
    if ($x < -$y) {
      ### bottom quarter ...
      $high = 0;
    } else {
      ### right quarter ...
      $high = 1;
      ($x,$y) = ($y, -$x);   # rotate -90
    }
  } else {
    ### above leading diagonal
    if ($y > -$x) {
      ### top quarter ...
      $high = 2;
      $x = -$x;   # rotate 180
      $y = -$y;
    } else {
      ### right quarter ...
      $high = 3;
      ($x,$y) = (-$y, $x);   # rotate +90
    }
  }
  ### rotate to: "$x,$y   high=$high"

  # ymax = (10*4^(l-1)-1)/3
  # ymax < (10*4^(l-1)-1)/3+1
  # (10*4^(l-1)-1)/3+1 > ymax
  # (10*4^(l-1)-1)/3 > ymax-1
  # 10*4^(l-1)-1 > 3*(ymax-1)
  # 10*4^(l-1) > 3*(ymax-1)+1
  # 10*4^(l-1) > 3*(ymax-1)+1
  # 10*4^(l-1) > 3*ymax-3+1
  # 10*4^(l-1) > 3*ymax-2
  # 4^(l-1) > (3*ymax-2)/10
  #
  # (2*4^(l-1) + 1)/3 = ymin
  # 2*4^(l-1) + 1 = 3*y
  # 2*4^(l-1) = 3*y-1
  # 4^(l-1) = (3*y-1)/2
  #
  # ypos = 4^l/2 = 2*4^(l-1)


  # z = -2*y+x
  # (2*4**($level-1) + 1)/3 = z
  # 2*4**($level-1) + 1 = 3*z
  # 2*4**($level-1) = 3*z - 1
  # 4**($level-1) = (3*z - 1)/2
  #               = (3*(-2y+x)-1)/2
  #               = (-6y+3x - 1)/2
  #               = -3*y + (3x-1)/2

  # 2*4**($level-1) = -2*y-x
  # 4**($level-1) = -y-x/2
  # 4**$level = -4y-2x
  #
  # line slope y/x = 1/2 as an index
  my $z = -$y-$x/2;
  my ($len,$level) = _round_down_pow ($z, 4);
  ### $z
  ### amin: 2*4**($level-1)
  ### $level
  ### $len
  if (_is_infinite($level)) {
    return $level;
  }

  $len *= 2;
  $x += $len;
  $y += $len;
  ### shift to: "$x,$y"
  my $n = Math::PlanePath::QuadricCurve::xy_to_n($self, $x, $y);

  # Nmin = (4*8^l+3)/7
  # Nmin+high = (4*8^l+3)/7 + h*8^l
  #           = (4*8^l + 3 + 7h*8^l)/7 +
  #           = ((4+7h)*8^l + 3)/7
  #
  ### plain curve on: ($x+2*$len).",".($y+2*$len)."  give n=".(defined $n && $n)
  ### $high
  ### high: (8**$level)*$high
  ### base: (4 * 8**($level+1) + 3)/7
  ### base with high: ((4+7*$high) * 8**($level+1) + 3)/7

  if (defined $n) {
    return ((4+7*$high) * 8**($level+1) + 3)/7 + $n;
  } else {
    return undef;
  }
}

# level width extends
#    side = 4^level
#    ypos = 4^l / 2
#    width = 1 + 4 + ... + 4^(l-1)
#          = (4^l - 1)/3
#    ymin = ypos(l) - 4^(l-1) - width(l-1)
#         = 4^l / 2  - 4^(l-1) - (4^(l-1) - 1)/3
#         = 4^(l-1) * (2 - 1 - 1/3) + 1/3
#         = (2*4^(l-1) + 1) / 3
#
#    (2*4^(l-1) + 1) / 3 = z
#    2*4^(l-1) + 1 = 3*z
#    2*4^(l-1) = 3*z-1
#    4^(l-1) = (3*z-1)/2
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### QuadricIslands rect_to_n_range(): "$x1,$y1  $x2,$y2"

  # $x1 = _round_nearest ($x1);
  # $y1 = _round_nearest ($y1);
  # $x2 = _round_nearest ($x2);
  # $y2 = _round_nearest ($y2);

  my $m = max(1,
              abs($x1), abs($x2),
              abs($y1), abs($y2));
  my $level = ceil (log((3*$m+5)/2) / log(4));
  ### $level
  return (1, 4 * 8**($level+1) - 1);
}

1;
__END__

=for stopwords eg Ryde ie Math-PlanePath quadric QuadricCurve

=head1 NAME

Math::PlanePath::QuadricIslands -- quadric curve rings

=head1 SYNOPSIS

 use Math::PlanePath::QuadricIslands;
 my $path = Math::PlanePath::QuadricIslands->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is concentric islands made from four sides of the QuadricCurve,

                                  27--26                     3               
                                   |   |                                     
                              29--28  25  22--21             2               
                               |       |   |   |                             
                              30--31  24--23  20--19         1
                                   | 4--3          | 
                          34--33--32    | 16--17--18     <- Y=0
                           |         1--2  |         
                          35--36   7---8  15--14            -1
                                   |   |       | 
                               5---6   9  12--13            -2
                                       |   |     
                          55--56      10--11                -3
                           |   |               
      ...             53--54  57  60--61                    -4
                       |       |   |   |       
                      52--51  58--59  62--63                -5
                           |               |                      
                  48--49--50      66--65--64                -6    
                   |               |                              
          39--40  47--46          67--68                    -7
           |   |       |               |                
      37--38  41  44--45              69                    -8
               |   |                   |              
              42--43                  70--71                -9
                                           |                                 
                                  74--73--72               -10
                                   |                       
                                  75--76  79--80      ...  -11               
                                       |   |   |       |                     
                                      77--78  81  84--85   -12               
                                               |   |                         
                                              82--83       -13               

                                       ^
      -8  -7  -6  -5  -4  -3  -2  -1  X=0  1   2   3   4

The initial figure is the square N=1,2,3,4 then for the next level each
straight side expands to 4x longer and a zigzag like N=5 through N=13,

                                *---*
                                |   |
      *---*     becomes     *---*   *   *---*
                                    |   |
                                    *---*

=head2 Level Ranges

Counting the innermost square as level 0, each ring is

    length = 4 * 8^level     many points
    Nstart = 1 + length[0] + ... + length[level-1]
           = (4*8^level + 3)/7
    Xstart = - 4^level / 2
    Ystart = - 4^level / 2

For example the lower partial ring shown above is level 2 starting
N=(4*8^2+3)/7=37 and X=-(4^2)/2=-8,Y=-8.

The innermost square N=1,2,3,4 is on 0.5 coordinates, for example N=1 at
X=-0.5,Y=-0.5.  This is centred on the origin and consistent with the
(4^level)/2.  Points from N=5 onwards are have integer X,Y.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::QuadricIslands-E<gt>new ()>

Create and return a new path object.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::QuadricCurve>,
L<Math::PlanePath::KochSnowflakes>,
L<Math::PlanePath::GosperIslands>

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
