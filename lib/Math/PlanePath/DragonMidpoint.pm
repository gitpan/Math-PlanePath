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


# math-image --path=DragonMidpoint --lines --scale=20
# math-image --path=DragonMidpoint --all --output=numbers_dash


package Math::PlanePath::DragonMidpoint;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 57;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::SierpinskiArrowhead;
*_round_up_pow2 = \&Math::PlanePath::SierpinskiArrowhead::_round_up_pow2;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;
sub arms_count {
  my ($self) = @_;
  return $self->{'arms'} || 1;
}

use constant parameter_info_array => [ { name      => 'arms',
                                         share_key => 'arms_4',
                                         type      => 'integer',
                                         minimum   => 1,
                                         maximum   => 4,
                                         default   => 1,
                                         width     => 1,
                                         description => 'Arms',
                                       } ];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 4) { $arms = 4; }
  $self->{'arms'} = $arms;
  return $self;
}

# sub n_to_xy {
#   my ($self, $n) = @_;
#   ### DragonMidpoint n_to_xy(): $n
#
#   if ($n < 0) { return; }
#   if (_is_infinite($n)) { return ($n, $n); }
#
#   {
#     my $int = int($n);
#     if ($n != $int) {
#       my ($x1,$y1) = $self->n_to_xy($int);
#       my ($x2,$y2) = $self->n_to_xy($int+1);
#       my $frac = $n - $int;  # inherit possible BigFloat
#       my $dx = $x2-$x1;
#       my $dy = $y2-$y1;
#       return ($frac*$dx + $x1, $frac*$dy + $y1);
#     }
#     $n = $int; # BigFloat int() gives BigInt, use that
#   }
#
#   my ($x1,$y1) = Math::PlanePath::DragonCurve->n_to_xy($n);
#   my ($x2,$y2) = Math::PlanePath::DragonCurve->n_to_xy($n+1);
#
#   my $dx = $x2-$x1;
#   my $dy = $y2-$y1;
#   return ($x1+$y1 + ($dx+$dy-1)/2,
#           $y1-$x1 + ($dy-$dx+1)/2);
# }

sub n_to_xy {
  my ($self, $n) = @_;
  ### DragonMidpoint n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n, $n); }

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;  # inherit possible BigFloat
    $n = $int;          # BigFloat int() gives BigInt, use that
  }

  my $zero = ($n * 0);  # inherit bignum 0

  my $arms = $self->{'arms'};
  my $rot = $n % $arms;
  $n = int($n/$arms);

  # ENHANCE-ME: sx,sy just from len,len
  my @digits;
  my @sx;
  my @sy;
  {
    my $sx = $zero + 1;
    my $sy = -$sx;
    while ($n) {
      push @digits, ($n % 2);
      push @sx, $sx;
      push @sy, $sy;
      $n = int($n/2);

      # (sx,sy) + rot+90(sx,sy)
      ($sx,$sy) = ($sx - $sy,
                   $sy + $sx);
    }
  }

  ### @digits
  my $rev = 0;
  my $x = $zero;
  my $y = $zero;
  my $above_low_zero = 0;

  for (my $i = $#digits; $i >= 0; $i--) {     # high to low
    my $digit = $digits[$i];
    my $sx = $sx[$i];
    my $sy = $sy[$i];
    ### at: "$x,$y  $digit   side $sx,$sy"
    ### $rot

    if ($rot & 2) {
      $sx = -$sx;
      $sy = -$sy;
    }
    if ($rot & 1) {
      ($sx,$sy) = (-$sy,$sx);
    }
    ### rotated side: "$sx,$sy"

    if ($rev) {
      if ($digit) {
        $x += -$sy;
        $y += $sx;
        ### rev add to: "$x,$y next is still rev"
      } else {
        $above_low_zero = $digits[$i+1];
        $rot ++;
        $rev = 0;
        ### rev rot, next is no rev ...
      }
    } else {
      if ($digit) {
        $rot ++;
        $x += $sx;
        $y += $sy;
        $rev = 1;
        ### plain add to: "$x,$y next is rev"
      } else {
        $above_low_zero = $digits[$i+1];
      }
    }
  }

  # Digit above the low zero is the direction of the next turn, 0 for left,
  # 1 for right.
  #
  ### final: "$x,$y  rot=$rot  above_low_zero=".($above_low_zero||0)

  if ($rot & 2) {
    $frac = -$frac;  # rotate 180
    $x -= 1;
  }
  if (($rot+1) & 2) {
    # rot 1 or 2
    $y += 1;
  }
  if (!($rot & 1) && $above_low_zero) {
    $frac = -$frac;
  }
  $above_low_zero ^= ($rot & 1);
  if ($above_low_zero) {
    $y = $frac + $y;
  } else {
    $x = $frac + $x;
  }

  ### rotated offset: "$x_offset,$y_offset   return $x,$y"
  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### DragonMidpoint xy_to_n(): "$x, $y"

  $x = _round_nearest($x);
  $y = _round_nearest($y);

  my ($pow,$exp) = _round_up_pow2(_max(abs($x),abs($y)));
  my $level_limit = 2*$exp + 5;
  if (_is_infinite($level_limit)) {
    return $level_limit;  # infinity
  }

  my $arms = $self->{'arms'};
  my @hypot = (5);
  for (my $top = 0; $top < $level_limit; $top++) {
    push @hypot, ($top % 4 ? 2 : 3) * $hypot[$top];  # little faster than 2^lev

    # start from digits=1 but subtract 1 so that n=0,1,...,$arms-1 are tried
    # too
  ARM: foreach my $arm (-$arms .. 0) {
      my @digits = (((0) x $top), 1);
      my $i = $top;
      for (;;) {
        my $n = 0;
        foreach my $digit (reverse @digits) { # high to low
          $n = 2*$n + $digit;
        }
        $n = $arms*$n + $arm;
        ### consider: "arm=$arm i=$i  digits=".join(',',reverse @digits)."  is n=$n"

        my ($nx,$ny) = $self->n_to_xy($n);
        ### at: "n $nx,$ny  cf hypot ".$hypot[$i]

        if ($i == 0 && $x == $nx && $y == $ny) {
          ### found
          return $n;
        }

        if ($i == 0 || ($x-$nx)**2 + ($y-$ny)**2 > $hypot[$i]) {
          ### too far away: "$nx,$ny target $x,$y    ".(($x-$nx)**2 + ($y-$ny)**2).' vs '.$hypot[$i]

          while (++$digits[$i] > 1) {
            $digits[$i] = 0;
            if (++$i >= $top) {
              ### backtrack past top ...
              next ARM;
            }
            ### backtrack up
          }

        } else {
          ### descend
          ### assert: $i > 0
          $i--;
          $digits[$i] = 0;
        }
      }
    }
  }
  ### not found below level limit
  return undef;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### DragonMidpoint rect_to_n_range(): "$x1,$y1  $x2,$y2  arms=$self->{'arms'}"
  $x1 = abs($x1);
  $x2 = abs($x2);
  $y1 = abs($y1);
  $y2 = abs($y2);
  my $xmax = int(_max($x1,$x2));
  my $ymax = int(_max($y1,$y2));
  return (0,
          ($xmax*$xmax + $ymax*$ymax + 1) * $self->{'arms'} * 5);
}

# sub rect_to_n_range {
#   my ($self, $x1,$y1, $x2,$y2) = @_;
#   ### DragonMidpoint rect_to_n_range(): "$x1,$y1  $x2,$y2"
#
#   return Math::PlanePath::DragonCurve->rect_to_n_range
#     (sqrt(2)*$x1, sqrt(2)*$y1, sqrt(2)*$x2, sqrt(2)*$y2);
# }

1;
__END__

=for stopwords eg Ryde Dragon Math-PlanePath Nlevel Heighway Harter et al DragonCurve DragonMidpoint

=head1 NAME

Math::PlanePath::DragonMidpoint -- dragon curve midpoints

=head1 SYNOPSIS

 use Math::PlanePath::DragonMidpoint;
 my $path = Math::PlanePath::DragonMidpoint->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is an integer version of the dragon or paper folding curve by Heighway,
Harter, et al, following the midpoint of each edge of the curve segments.



                    17--16           9---8                    5
                     |   |           |   |
                    18  15          10   7                    4
                     |   |           |   |
                    19  14--13--12--11   6---5---4            3
                     |                           |
                    20--21--22                   3            2
                             |                   |
    33--32          25--24--23                   2            1
     |   |           |                           |
    34  31          26                       0---1        <- Y=0
     |   |           |
    35  30--29--28--27                                       -1
     |
    36--37--38  43--44--45--46                               -2
             |   |           |
            39  42  49--48--47                               -3
             |   |   |
            40--41  50                                       -4
                     |
                    51                                       -5
                     |
                    52--53--54                               -6
                             |
    ..--64          57--56--55                               -7
         |           |
        63          58                                       -8
         |           |
        62--61--60--59                                       -9


     ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^
    -10 -9  -8  -7  -6  -5  -4  -3  -2  -1  X=0  1

The dragon curve itself begins as follows, with the edge midpoints at each
"*",

                --*--       --*--
               |     |     |     |
               *     *     *     *
               |     |     |     |
                --*--+--*--       --*--
                     |                 |
                     *                 *
                     |                 |
                --*--+            --*--
               |
              ...

The midpoints are on fractions X=0.5,Y=0, X=1,Y=0.5, etc.  Those positions
can in fact be had from the DragonCurve module by asking for N=0.5, 1.5,
2.5, etc.  But for this DragonMidpoint curve they're turned clockwise 45
degrees and shrunk by sqrt(2) to be integer X,Y values stepping by 1.

Because the dragon curve only traverses each edge once the midpoints are all
distinct X,Y positions.

=head2 Arms

The midpoints fill a quarter of the plane and four copies mesh together
perfectly when rotated by 90, 180 and 270 degrees.  The C<arms> parameter
can choose 1 to 4 curve arms, successively advancing.

For example C<arms =E<gt> 4> begins as follows, with N=0,4,8,12,etc being
one arm, N=1,5,9,13 the second, N=2,6,10,14 the third and N=3,7,11,15 the
fourth.

                    ...-107-103  83--79--75--71
                              |   |           |
     68--64          36--32  99  87  59--63--67
      |   |           |   |   |   |   |
     72  60          40  28  95--91  55
      |   |           |   |           |
     76  56--52--48--44  24--20--16  51
      |                           |   |
     80--84--88  17--13---9---5  12  47--43--39 ...
              |   |           |   |           |  |
    100--96--92  21   6---2   1   8  27--31--35 106
      |           |   |           |   |          |
    104  33--29--25  10   3   0---4  23  94--98-102
      |   |           |   |           |   |
    ...  37--41--45  14   7--11--15--19  90--86--82
                  |   |                           |
                 49  18--22--26  46--50--54--58  78
                  |           |   |           |   |
                 53  89--93  30  42          62  74
                  |   |   |   |   |           |   |
         65--61--57  85  97  34--38          66--70
          |           |   |
         69--73--77--81 101-105-...

With four arms like this every X,Y point is visited exactly once,
corresponding to the way four copies of the dragon curve traversing each
edge exactly once.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::DragonMidpoint-E<gt>new ()>

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
L<Math::PlanePath::DragonCurve>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011 Kevin Ryde

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





     # ...            36---32             59---63-...        5
     #  |              |    |              |                  
     # 60             40   28             55                 4
     #  |              |    |              |                  
     # 56---52---48---44   24---20---16   51                 3
     #                                |    |                  
     #           17---13----9----5   12   47---43---39       2
     #            |              |    |              |        
     #           21    6--- 2    1    8   27---31---35       1 
     #            |    |              |    |                   
     # 33---29---25   10    3    0--- 4   23             <- Y=0
     #  |              |    |              |                  
     # 37---41---45   14    7---11---15---19                -1
     #            |    |                                      
     #           49   18---22---26   46---50---54---58      -2
     #            |              |    |              |        
     #           53             30   42             62      -3
     #            |              |    |              |        
     # ...--61---57             34---38             ...     -4
     # 
     # 
     # 
     #  ^    ^    ^    ^    ^    ^    ^    ^    ^    ^
     # -5   -4   -3   -2   -1   X=0   1    2    3    4


