# Copyright 2011, 2012 Kevin Ryde

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


# math-image --path=AlternatePaperMidpoint,arms=8 --all --output=numbers_dash
# math-image --path=AlternatePaperMidpoint --lines --scale=20


package Math::PlanePath::AlternatePaperMidpoint;
use 5.004;
use strict;
#use List::Util 'max';
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 83;
use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_divrem_mutate = \&Math::PlanePath::_divrem_mutate;

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'round_down_pow',
  'digit_split_lowtohigh';
use Math::PlanePath::AlternatePaper;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;

sub x_negative {
  my ($self) = @_;
  return ($self->{'arms'} >= 3);
}
sub y_negative {
  my ($self) = @_;
  return ($self->{'arms'} >= 5);
}

use constant parameter_info_array => [ { name      => 'arms',
                                         share_key => 'arms_8',
                                         type      => 'integer',
                                         minimum   => 1,
                                         maximum   => 8,
                                         default   => 1,
                                         width     => 1,
                                         description => 'Arms',
                                       } ];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);

  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 8) { $arms = 8; }
  $self->{'arms'} = $arms;

  return $self;
}

sub Xn_to_xy {
  my ($self, $n) = @_;
  ### AlternatePaperMidpoint n_to_xy(): $n

  if ($n < 0) { return; }
  if (is_infinite($n)) { return ($n, $n); }

  {
    my $int = int($n);
    if ($n != $int) {
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+$self->{'arms'});
      my $frac = $n - $int;  # inherit possible BigFloat
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int; # BigFloat int() gives BigInt, use that
  }

  my ($x1,$y1) = $self->Math::PlanePath::AlternatePaper::n_to_xy($n);
  my ($x2,$y2) = $self->Math::PlanePath::AlternatePaper::n_to_xy($n+1);

  my $dx = $x2-$x1;
  my $dy = $y2-$y1;
  return ($x1+$y1 + ($dx+$dy-1)/2,
          $x1-$y1 - ($dy-$dx+1)/2);
}



#    +-----------+      states
#    |\         /|
#    | \   4   / |
#    |  \     /  |
#    |   \   /   |
#    |    \ /    |
#    | 8   *  12 |
#    |    / \    |
#    |   /   \   |
#    |  /     \  |
#    | /   0   \ |
#    |/         \|
#    +-----------+
#
#           +           state=0 digits
#          /|\
#         / | \
#        /  |  \
#       /\ 1|3 /\
#      /  \ | /  \
#     /  0 \|/  2 \
#    +------+------+

my @next_state = (0, 12, 0,  8,   # forward
                  4,  8, 4, 12,   # forward NW
                  4,  8, 0,  8,   # reverse
                  0, 12, 4, 12,   # reverse NE
                 );
my @digit_to_x = (0,0,1,1,
                  1,1,0,0,
                  0,0,0,0,
                  1,1,1,1,
                 );
my @digit_to_y = (0,0,0,0,
                  1,1,1,1,
                  0,0,1,1,
                  1,1,0,0,
                 );

sub n_to_xy {
  my ($self, $n) = @_;
  ### AlternatePaperMidpoint n_to_xy(): $n

  if ($n < 0) { return; }
  if (is_infinite($n)) { return ($n, $n); }

  {
    my $int = int($n);
    if ($n != $int) {
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+$self->{'arms'});
      my $frac = $n - $int;  # inherit possible BigFloat
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int; # BigFloat int() gives BigInt, use that
  }

  my $zero = ($n * 0);  # inherit bignum 0

  # arm as initial rotation
  my $arm = _divrem_mutate ($n, $self->{'arms'});

  ### $arm
  ### $n

  my @digits = digit_split_lowtohigh($n,4);
  my $len = (2 + $zero) ** (scalar($#digits) + 1);

  my $state = 0;
  my $x = $zero;
  my $y = $zero;

  foreach my $digit (reverse @digits) { # high to low
    $state += $digit;
    $x += $len * $digit_to_x[$state];
    $y += $len * $digit_to_y[$state];
    $state = $next_state[$state];
    $len /= 2;
  }

  ### final: "xy=$x,$y state=$state"

  $x += $digit_to_x[$state];      # state=4,12 increment
  $y += $digit_to_y[$state + 3];  # state=4,8 increment

  if ($arm & 1) {
    ($x,$y) = ($y+1,$x+1);
  }
  if ($arm & 2) {
    ($x,$y) = (-$y,$x+1);
  }
  if ($arm & 4) {
    $x = -1 - $x;
    $y = 1 - $y;
  }

  # ### rotated return: "$x,$y"
  return ($x,$y);
}


#          43-35 42-50-58 57-49-41
#           |  |  |              |
# 91-99    51 27 34-26-18 17-25-33
#  |        |  |        |  |
# 83-75-67-59 19-11--3 10  9 32-40
#                       |  |  |  |
# 84-76-68-60 20-12--4  2  1 24 48    96-88
#  |        |  |              |  |        |
# 92       52 28  5  6  0--8-16 56-64-72-80
#           |  |  |  |
#          44-36 13 14  7-15-23 63-71-79-87
#                 |  |        |  |        |
#          37-29-21 22-30-38 31 55       95
#           |              |  |  |
#          45-53-61 62-54-46 39-47
#                 |  |
#                69 70

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### AlternatePaperMidpoint xy_to_n(): "$x, $y"

  $x = round_nearest($x);
  $y = round_nearest($y);

  if (is_infinite($x)) {
    return $x;  # infinity
  }
  if (is_infinite($y)) {
    return $y;  # infinity
  }

  # arm in various octants, rotate/transpose to first
  my $arm;
  if ($y >= ($x>=0?0:2)) {   # Y>=0 when X positive, Y>=2 when X negative
    $arm = 0;
  } else {
    # lower arms 4,5,6,7 ...
    $arm = 4;
    $x = -1 - $x;   # rotate 180, offset
    $y = 1 - $y;
  }
  if ($x < ($y>0?1:0)) {
    ### second quad arms 2,3 ...
    ($x,$y) = ($y-1,-$x);  # rotate -90, offset
    $arm += 2;
  }
  if ($y > $x-($x%2)) {
    ### above diagonal, arm 1 ...
    ($x,$y) = ($y-1,$x-1);   # offset and transpose
    $arm++;
  }
  ### assert: $x >= 0
  ### assert: $y >= 0
  ### assert: $y <= $x - ($x%2)

  if ($arm >= $self->{'arms'}) {
    return undef;
  }

  my ($len, $level) = round_down_pow ($x, 2);
  if (is_infinite($level)) {
    return ($level);
  }

  #           +           state=0 digits
  #          /|\
  #         / | \
  #        /  |  \
  #       /\ 1|3 /\
  #      /  \ | /  \
  #     /  0 \|/  2 \
  #    +------+------+

  #           +           state=0 digits
  #          /|\
  #         / | \
  #        /  |  \
  #       /\ 2|0 /\
  #      /  \ | /  \
  #     /  3 \|/  1 \
  #    +------+------+

  #                                   |           |
  #                         64-65-66 71-72-73-74 95
  #                          |                    |
  #                         63             98-97-96
  #                          |              |
  #                   20-21 62             99
  #                    |  |  |
  #                   19 22 61-60-59
  #                    |  |        |
  #             16-17-18 23 56-57-58
  #              |        |  |
  #             15 26-25-24 55 50-49-48-47
  #              |  |        |  |        |
  #        4--5 14 27-28-29 54 51 36-37 46
  #        |  |  |        |  |  |  |  |  |
  #        3  6 13-12-11 30 53-52 35 38 45-44-43
  #        |  |        |  |        |  |        |
  #  0--1--2  7--8--9-10 31-32-33-34 39-40-41-42
  #
  #  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16

  my $n = ($x * 0 * $y); # inherit bignum 0
  my $rev = 0;

  $len *= 2;
  while ($level-- >= 0) {
    ### at: "xy=$x,$y  rev=$rev  len=$len  n=".sprintf('%#x',$n)

    ### assert: $x >= 0
    ### assert: $y >= 0
    ### assert: $y <= $x - ($x%2)
    ### assert: $x+$y+($x%2) < 2*$len

    my $digit;
    if ($x < $len) {
      ### diagonal: $x+$y+($x%2), $len
      if ($x+$y+($x%2) < $len) {
        ### part 0 ...
        $digit = 0;
      } else {
        ### part 1 ...
        ($x,$y) = ($y,$len-1-$x); # shift, rotate -90
        $rev ^= 3;
        $digit = 2;  # becoming digit=1 with reverse
      }
    } else {
      $x -= $len;
      ### 2,3 ycmp: $y, $x-($x%2)
      if ($y <= $x-($x%2)) {
        ### part 2 ...
        $digit = 2;
      } else {
        ### part 3 ...
        ($x,$y) = ($len-1-$y,$x); # shift, rotate +90
        $rev ^= 3;
        $digit = 0;  # becoming digit=3 with reverse
      }
    }
    ### $digit

    $digit ^= $rev;   # $digit = 3-$digit if reverse
    ### reversed digit: $digit

    $n *= 4;
    $n += $digit;
    $len /= 2;
  }
  ### final: "xy=$x,$y rev=$rev"

  ### assert: $x == 0
  ### assert: $y == 0

  return $n*$self->{'arms'} + $arm;
}


# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### AlternatePaperMidpoint rect_to_n_range(): "$x1,$y1  $x2,$y2  arms=$self->{'arms'}"

  $x1 = round_nearest($x1);
  $x2 = round_nearest($x2);
  $y1 = round_nearest($y1);
  $y2 = round_nearest($y2);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  my $arms = $self->{'arms'};
  if (($arms == 1 && $y1 > $x2)       # x2,y1 bottom right corner
      || ($arms <= 2 && $x2 < 0)
      || ($arms <= 4 && $y2 < 0)) {
    ### outside ...
    return (1,0);
  }

  my ($len, $level) = round_down_pow (max ($x2,
                                           ($arms >= 2 ? $y2-1 : ()),
                                           ($arms >= 4 ? -1-$x1 : ()),
                                           ($arms >= 6 ? -$y1 : ())),
                                      2);
  return (0, 2*$arms*$len*$len-1);
}

1;
__END__


=for stopwords Math-PlanePath eg Ryde AlternatePaper AlternatePaperMidpoint OEIS

=head1 NAME

Math::PlanePath::AlternatePaperMidpoint -- alternate paper folding midpoints

=head1 SYNOPSIS

 use Math::PlanePath::AlternatePaperMidpoint;
 my $path = Math::PlanePath::AlternatePaperMidpoint->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is the midpoints of each alternate paper folding curve
(L<Math::PlanePath::AlternatePaper>).

     8  |                        64-65-...           
        |                         |                  
     7  |                        63                  
        |                         |       
     6  |                  20-21 62                  
        |                   |  |  |
     5  |                  19 22 61-60-59            
        |                   |  |        |            
     4  |            16-17-18 23 56-57-58            
        |             |        |  |                  
     3  |            15 26-25-24 55 50-49-48-47      
        |             |  |        |  |        |      
     2  |       4--5 14 27-28-29 54 51 36-37 46      
        |       |  |  |        |  |  |  |  |  |      
     1  |       3  6 13-12-11 30 53-52 35 38 45-44-43
        |       |  |        |  |        |  |        |
    Y=0 | 0--1--2  7--8--9-10 31-32-33-34 39-40-41-42
        +----------------------------------------------
        X=0  1  2  3  4  5  6  7  8  9 10 11 12 13 14

The AlternatePaper curve begins as follows and the midpoints are numbered
from 0,

                      | 
                      9 
                      | 
                *--8--*
                |     |
                7     |
                |     |
          *--2--*--6--*
          |     |     |
          1     3     5
          |     |     |
    *--0--*     *--4--*

These midpoints are on fractions X=0.5,Y=0, X=1,Y=0.5, etc.  For this
AlternatePaperMidpoint they're turned 45 degrees and mirrored so the 0,1,2
diagonally up become a straight line along the X axis, and the 2,3,4
segments become a vertical up to the X=Y diagonal for N=4 at X=2,Y=2.

The midpoints are distinct X,Y positions because the alternate paper curve
traverses each edge only once.

The curve is self-similar in 2^level sections due to its unfolding.  This
can be seen in the midpoints as for example the above N=0 to N=16 is the
same shape as N=16 to N=32, but latter rotated +90 degrees and numbered in
reverse.

=head2 Arms

The midpoints fill an eighth of the plane and eight copies can mesh together
perfectly mirrored and rotated by 90, 180 and 270 degrees.  The C<arms>
parameter can choose 1 to 8 curve arms, successively advancing.

For example C<arms =E<gt> 8> begins as follows.  N=0,8,16,24,etc is the
first arm, the same as the plain curve above.  N=1,9,17,25 is the second,
N=2,10,18,26 the third, etc.

                           90-82 81-89                
                            |  |  |  |
                          ... 74 73 ...                      6
                               |  |                           
                              66 65                          5
                               |  |                           
                  43-35 42-50-58 57-49-41                    4
                   |  |  |              |                     
         91-..    51 27 34-26-18 17-25-33                    3
          |        |  |        |  |                           
         83-75-67-59 19-11--3 10  9 32-40                    2
                               |  |  |  |                     
         84-76-68-60 20-12--4  2  1 24 48    ..-88           1
          |        |  |              |  |        |            
         92-..    52 28  5  6  0--8-16 56-64-72-80      <- Y=0
                   |  |  |  |                                 
                  44-36 13 14  7-15-23 63-71-79-87          -1
                         |  |        |  |        |            
                  37-29-21 22-30-38 31 55    ..-95          -2
                   |              |  |  |                     
                  45-53-61 62-54-46 39-47                   -3
                         |  |                                 
                        69 70                               -4
                         |  |                                 
                    ... 77 78 ...                           -5
                      |  |  |  |
                     93-85 86-94                            -6

          ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^
         -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6

With eight arms like this every X,Y point is visited exactly once, because
in the AlternatePaper eight arms there traverse every edge exactly once.

The arm numbering doesn't correspond to the AlternatePaper, due to the
rotate and reflect of the first arm.  It ends up arms 0 and 1 of the
AlternatePaper corresponding to arms 7 and 0 of the midpoints here, those
two being a pair going horizontally corresponding to a pair in the
AlternatePaper going diagonally into a quadrant.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::AlternatePaperMidpoint-E<gt>new ()>

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
L<Math::PlanePath::AlternatePaper>

L<Math::PlanePath::DragonMidpoint>,
L<Math::PlanePath::R5DragonMidpoint>,
L<Math::PlanePath::TerdragonMidpoint>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2012 Kevin Ryde

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
