# Copyright 2012, 2013, 2014 Kevin Ryde

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


# boundary B[k] = 4*3^k - 2
# dB[k] = B[k+1] - B[k]
#       = 4*3*3^k - 2 - (4*3^k - 2)
#       = (4*3 - 4)*3^k
#       = 8*3^k
# 5*B[k] - B[k+1]
#   = 5*(4*3^k - 2) - (4*3^(k+1) - 2)
#   = 5*4*3^k - 10 - 3*4*3^k + 2
#   = 8*3^k - 8     in 4 joins
# 2*3^k-2 in each join

#  new touching points
#   = 8*3^k      in four joins
# 2*3^k in each join



package Math::PlanePath::R5DragonCurve;
use 5.004;
use strict;
use List::Util 'first','sum';
use List::Util 'min'; # 'max'
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 116;
use Math::PlanePath;
use Math::PlanePath::Base::NSEW;
@ISA = ('Math::PlanePath::Base::NSEW',
        'Math::PlanePath');

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'digit_split_lowtohigh';
*_divrem_mutate = \&Math::PlanePath::_divrem_mutate;

# uncomment this to run the ### lines
# use Smart::Comments;


use constant n_start => 0;
use constant parameter_info_array =>
  [ { name        => 'arms',
      share_key   => 'arms_4',
      display     => 'Arms',
      type        => 'integer',
      minimum     => 1,
      maximum     => 4,
      default     => 1,
      width       => 1,
      description => 'Arms',
    } ];

{
  my @x_negative_at_n = (undef, 9,5,5,6);
  sub x_negative_at_n {
    my ($self) = @_;
    return $x_negative_at_n[$self->{'arms'}];
  }
}
{
  my @y_negative_at_n = (undef, 54,19,8,7);
  sub y_negative_at_n {
    my ($self) = @_;
    return $y_negative_at_n[$self->{'arms'}];
  }
}

#------------------------------------------------------------------------------

sub new {
  my $self = shift->SUPER::new(@_);
  $self->{'arms'} = max(1, min(4, $self->{'arms'} || 1));
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### R5dragonCurve n_to_xy(): $n

  if ($n < 0) { return; }
  if (is_infinite($n)) { return ($n, $n); }

  my $int = int($n);
  $n -= $int;    # fraction part

  my $zero = ($n * 0);    # inherit bignum 0
  my $one = $zero + 1;    # inherit bignum 1

  my $x = 0;
  my $y = 0;
  my $sx = $zero;
  my $sy = $zero;

  # initial rotation from arm number
  {
    my $rot = _divrem_mutate ($int, $self->{'arms'});
    if ($rot == 0)    { $x = $n;  $sx = $one;  }
    elsif ($rot == 1) { $y = $n;  $sy = $one;  }
    elsif ($rot == 2) { $x = -$n; $sx = -$one; }
    else              { $y = -$n; $sy = -$one; } # rot==3
  }

  foreach my $digit (digit_split_lowtohigh($int,5)) {

    ### at: "$x,$y   side $sx,$sy"
    ### $digit

    if ($digit == 1) {
      ($x,$y) = ($sx-$y, $sy+$x); # rotate +90 and offset
    } elsif ($digit == 2) {
      $x = $sx-$sy - $x;  # rotate 180 and offset diag
      $y = $sy+$sx - $y;
    } elsif ($digit == 3) {
      ($x,$y) = (-$sy - $y, $sx + $x); # rotate +90 and offset vert
    } elsif ($digit == 4) {
      $x -= 2*$sy;  # offset vert 2*
      $y += 2*$sx;
    }

    # add 2*(rot+90), which is multiply by (2i+1)
    ($sx,$sy) = ($sx - 2*$sy,
                 $sy + 2*$sx);
  }

  ### final: "$x,$y   side $sx,$sy"

  return ($x, $y);
}

my @digit_to_dir = (0,1,2,1,0);
my @dir4_to_dx = (1,0,-1,0);
my @dir4_to_dy = (0,1,0,-1);
my @digit_to_nextturn = (1,1,-1,-1);

sub n_to_dxdy {
  my ($self, $n) = @_;
  ### R5dragonCurve n_to_dxdy(): $n

  if ($n < 0) { return; }

  my $int = int($n);
  $n -= $int;    # fraction part

  if (is_infinite($int)) { return ($int, $int); }

  # direction from arm number
  my $dir = _divrem_mutate ($int, $self->{'arms'});

  # plus direction from digits
  my @ndigits = digit_split_lowtohigh($int,5);
  $dir = sum($dir, map {$digit_to_dir[$_]} @ndigits) & 3;

  ### direction: $dir
  my $dx = $dir4_to_dx[$dir];
  my $dy = $dir4_to_dy[$dir];

  # fractional $n incorporated using next turn
  if ($n) {
    # lowest non-4 digit, or 0 if all 4s (implicit 0 above high digit)
    $dir += $digit_to_nextturn[ first {$_!=4} @ndigits, 0 ];
    $dir &= 3;
    ### next direction: $dir
    $dx += $n*($dir4_to_dx[$dir] - $dx);
    $dy += $n*($dir4_to_dy[$dir] - $dy);
  }
  return ($dx, $dy);
}

sub xy_to_n {
  return scalar((shift->xy_to_n_list(@_))[0]);
}
sub xy_to_n_list {
  my ($self, $x, $y) = @_;
  ### R5DragonCurve xy_to_n(): "$x, $y"

  $x = round_nearest($x);
  $y = round_nearest($y);

  if (is_infinite($x)) {
    return $x;  # infinity
  }
  if (is_infinite($y)) {
    return $y;  # infinity
  }

  if ($x == 0 && $y == 0) {
    return (0 .. $self->arms_count - 1);
  }

  require Math::PlanePath::R5DragonMidpoint;

  my @n_list;
  my $xm = $x+$y;  # rotate -45 and mul sqrt(2)
  my $ym = $y-$x;
  foreach my $dx (0,-1) {
    foreach my $dy (0,1) {
      my $t = $self->Math::PlanePath::R5DragonMidpoint::xy_to_n
        ($xm+$dx, $ym+$dy);

      ### try: ($xm+$dx).",".($ym+$dy)
      ### $t
      next unless defined $t;

      my ($tx,$ty) = $self->n_to_xy($t)
        or next;

      if ($tx == $x && $ty == $y) {
        ### found: $t
        if (@n_list && $t < $n_list[0]) {
          unshift @n_list, $t;
        } else {
          push @n_list, $t;
        }
        if (@n_list == 2) {
          return @n_list;
        }
      }
    }
  }
  return @n_list;
}

#------------------------------------------------------------------------------

# whole plane covered when arms==4
sub xy_is_visited {
  my ($self, $x, $y) = @_;
  return ($self->{'arms'} == 4
          || defined($self->xy_to_n($x,$y)));
}

#------------------------------------------------------------------------------

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### R5DragonCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"
  my $xmax = int(max(abs($x1),abs($x2))) + 1;
  my $ymax = int(max(abs($y1),abs($y2))) + 1;
  return (0,
          ($xmax*$xmax + $ymax*$ymax)
          * 10
          * $self->{'arms'});
}

#------------------------------------------------------------------------------
{
  # This is a search for disallowed digit pairs going from low to high.
  # $state encodes the preceding digit, lower significance, or $state=1
  # initial no low digits yet.  The initial no low digits skips low digit=1
  # and then begins the allowing/disallowing on the first non-1 digit.
  #
  # The digits are found by repeated _divrem_mutate() in the expectation
  # that with 8 out of 20 digit pairs disallowed, after stripping low 1s, we
  # should be able to usually answer "no" in less work than a full
  # digit_split_lowtohigh(), especially since currently that code for base 5
  # is only repeated divrems anyway.
  #
  my @table 
    = (undef,                              #    prev  allowed pairs
       [     2,     1,     3,     4, 5 ],  # 1  none 
       [     2,     2,     3           ],  # 2   0       00, 20
       [     2,     3, undef, undef, 5 ],  # 3   2       02,    42
       [     2,     4, undef, undef, 5 ],  # 4   3       03,    43
       [     2,     5, undef, undef, 5 ],  # 5   4       04,    44
      );

  sub _UNDOCUMENTED__n_segment_is_right_boundary {
    my ($self, $n) = @_;
    if (is_infinite($n)) { return 0; }
    unless ($n >= 0) { return 0; }
    $n = int($n);

    my $state = 1;
    while ($n) {
      my $digit = _divrem_mutate($n,5);  # low to high
      $state = $table[$state][$digit] || return 0;
    }
    return 1;
  }
}

{
  my @table
    #       0     1     2  3  4 digit
    = (undef,
       [    4,    3,    2, 1, 1 ],  # 1 L -> ZYXLL
       [undef,undef,undef, 2, 1 ],  # 2 X -> ___XL
       [undef,undef,undef, 3    ],  # 3 Y -> ___Y_
       [    4,    3,    2, 4    ],  # 4 Z -> ZYXX_
      );
  sub _UNDOCUMENTED__n_segment_is_left_boundary {
    my ($self, $n) = @_;
    if (is_infinite($n)) { return 0; }
    unless ($n >= 0) { return 0; }
    $n = int($n);

    my $state = 4;
    foreach my $digit (reverse digit_split_lowtohigh($n,5)) { # high to low
      $state = $table[$state][$digit] || return 0;
    }
    return 1;
  }
}


#-----------------------------------------------------------------------------
# level_to_n_range()

sub _UNDOCUMENTED_level_to_n_range {
  my ($self, $level) = @_;
  return (0,
          5**$level * $self->{'arms'} + ($self->{'arms'}-1));
}

1;
__END__

=for stopwords eg Ryde Dragon Math-PlanePath Nlevel et al vertices doublings OEIS Online terdragon ie morphism R5DragonMidpoint radix Jorg Arndt Arndt's fxtbook PlanePath min xy TerdragonCurve arctan gt lt undef diff abs dX dY characterization

=head1 NAME

Math::PlanePath::R5DragonCurve -- radix 5 dragon curve

=head1 SYNOPSIS

 use Math::PlanePath::R5DragonCurve;
 my $path = Math::PlanePath::R5DragonCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

X<Arndt, Jorg>This is the R5 dragon curve by Jorg Arndt,

             31-----30     27-----26                                  5
              |      |      |      |
             32---29/33--28/24----25                                  4
                     |      |
             35---34/38--39/23----22     11-----10      7------6      3
              |      |             |      |      |      |      |
             36---37/41--20/40--21/17--16/12---13/9----8/4-----5      2
                     |      |      |      |      |      |
    --50     47---42/46--19/43----18     15-----14      3------2      1
       |      |      |      |                                  |
    49/53--48/64  45/65--44/68    69                    0------1  <-Y=0

       ^      ^      ^      ^      ^      ^      ^      ^      ^
      -7     -6     -5     -4     -3     -2     -1     X=0     1

The base figure is an "S" shape

    4----5
    |
    3----2
         |
    0----1

which then repeats in self-similar style, so N=5 to N=10 is a copy rotated
+90 degrees, as per the direction of the N=1 to N=2 segment.

    10    7----6
     |    |    |  <- repeat rotated +90
     9---8,4---5
          |
          3----2
               |
          0----1

This replication is similar to the C<TerdragonCurve> in that there's no
reversals or mirroring.  Each replication is the plain base curve.

The shape of N=0,5,10,15,20,25 repeats the initial N=0 to N=5,

           25                          4
          /
         /           10__              3
        /           /    ----___
      20__         /            5      2
          ----__  /            /
                15            /        1
                            /
                           0       <-Y=0

       ^    ^    ^    ^    ^    ^
      -4   -3   -2   -1   X=0   1


The curve never crosses itself.  The vertices touch at corners like N=4 and
N=8 above, but no edges repeat.

=head2 Spiralling

The first step N=1 is to the right along the X axis and the path then slowly
spirals anti-clockwise and progressively fatter.  The end of each
replication is

    Nlevel = 5^level

Each such point is at arctan(2/1)=63.43 degrees further around from the
previous,

    Nlevel     X,Y     angle (degrees)
    ------    -----    -----
      1        1,0         0
      5        2,1        63.4
     25       -3,4      2*63.4 = 126.8
    125      -11,-2     3*63.4 = 190.3

=head2 Arms

The curve fills a quarter of the plane and four copies mesh together
perfectly rotated by 90, 180 and 270 degrees.  The C<arms> parameter can
choose 1 to 4 such curve arms successively advancing.

C<arms =E<gt> 4> begins as follows.  N=0,4,8,12,16,etc is the first arm (the
same shape as the plain curve above), then N=1,5,9,13,17 the second,
N=2,6,10,14 the third, etc.

    arms => 4
                    16/32---20/63
                      |
    21/60    9/56----5/12----8/59
      |       |       |       |
    17/33--- 6/13--0/1/2/3---4/15---19/35
              |       |       |       |
            10/57----7/14---11/58   23/62
                      |
            22/61---18/34

With four arms every X,Y point is visited twice, except the origin 0,0 where
all four begin.  Every edge between the points is traversed once.

=head2 Tiling

The little "S" shapes of the N=0to5 base shape tile the plane with 2x1
bricks and 1x1 holes in the following pattern,

    +--+-----|  |--+--+-----|  |--+--+---
    |  |     |  |  |  |     |  |  |  |
    |  |-----+-----|  |-----+-----|  |---
    |  |  |  |     |  |  |  |     |  |  |
    +-----|  |-----+-----|  |-----+-----+
    |     |  |  |  |     |  |  |  |     |
    +-----+-----|  |-----+-----|  |-----+
    |  |  |     |  |  |  |     |  |  |  |
    ---|  |-----+-----|  |-----+-----|  |
       |  |  |  |     |  |  |  |     |  |
    ---+-----|  |-----o-----|  |-----+---
    |  |     |  |  |  |     |  |  |  |
    |  |-----+-----|  |-----+-----|  |---
    |  |  |  |     |  |  |  |     |  |  |
    +-----|  |-----+-----|  |-----+-----+
    |     |  |  |  |     |  |  |  |     |
    +-----+-----|  |-----+-----|  |-----+
    |  |  |     |  |  |  |     |  |  |  |
    ---|  |-----+-----|  |-----+-----|  |
       |  |  |  |     |  |  |  |     |  |
    ---+--+--|  |-----+--+--|  |-----+--+

This is the curve with each segment N=2mod5 to N=3mod5 omitted.  A 2x1 block
has 6 edges but the "S" traverses just 4 of them.  The way the blocks mesh
meshes together mean the other 2 edges are traversed by another brick,
possibly a brick on another arm of the curve.

This tiling is also for example

=over

L<http://tilingsearch.org/HTML/data182/AL04.html>

Or with enlarged square part,
L<http://tilingsearch.org/HTML/data149/L3010.html>

=back

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::R5DragonCurve-E<gt>new ()>

=item C<$path = Math::PlanePath::R5DragonCurve-E<gt>new (arms =E<gt> 4)>

Create and return a new path object.

The optional C<arms> parameter can make 1 to 4 copies of the curve, each arm
successively advancing.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional C<$n> gives an X,Y position along a straight line between the
integer positions.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  If there's nothing at
C<$x,$y> then return C<undef>.

The curve can visit an C<$x,$y> twice.  In the current code the smallest of
the these N values is returned.  Is that the best way?

=item C<@n_list = $path-E<gt>xy_to_n_list ($x,$y)>

Return a list of N point numbers for coordinates C<$x,$y>.  There can be
none, one or two N's for a given C<$x,$y>.

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 FORMULAS

=head2 Turn

X<Arndt, Jorg>X<fxtbook>At each point N the curve always turns 90 degrees
either to the left or right, it never goes straight ahead.  As per the code
in Jorg Arndt's fxtbook, if N is written in base 5 then the lowest non-zero
digit gives the turn

    lowest non-0 digit     turn
    ------------------     ----
            1              left
            2              left
            3              right
            4              right

At a point N=digit*5^level for digit=1,2,3,4 the turn follows the shape at
that digit, so two lefts then two rights,

    4*5^k----5^(k+1)
     |
     |
    2*5^k----2*5^k
              |
              |
     0------1*5^k

The first and last unit segments in each level are the same direction, so at
those endpoints it's the next level up which gives the turn.

=head2 Next Turn

The turn at N+1 can be calculated in a similar way but from the lowest non-4
digit.

    lowest non-4 digit     turn
    ------------------     ----
            0              left
            1              left
            2              right
            3              right

This works simply because in N=...z444 becomes N+1=...(z+1)000 and so the
turn at N+1 is given by digit z+1.

=head2 Total Turn

The direction at N, ie. the total cumulative turn, is given by the direction
of each digit when N is written in base 5,

    digit       direction
      0             0
      1             1
      2             2
      3             1
      4             0

    direction = (sum direction for each digit) * 90 degrees

For example N=13 in base 5 is "23" so digit=2 direction=2 plus digit=3
direction=1 gives direction=(2+1)*90 = 270 degrees, ie. south.

Because there's no reversals etc in the replications there's no state to
maintain when considering the digits, just a plain sum of direction for each
digit.

=head2 Boundary Length

The length of the boundary of the curve points N=0 to N=5^k inclusive is

    B[k] = 4*3^k - 2
         = 2, 10, 34, 106, 322, 970, 2914, ...

=for Test-Pari-DEFINE  Bsamples = [2, 10, 34, 106, 322, 970, 2914]

=for Test-Pari-DEFINE  B(k) = 4*3^k - 2

=for Test-Pari  vector(length(Bsamples), k, B(k-1)) == Bsamples

=for Test-Pari-DEFINE  R(k) = B(k)/2

=cut

# generating function
# 4/(1-3*x) - 2/(1-x) =  (2 + 2*x)/((1-3*x) * (1-x))

# singles = boundary/2 + 1
#         = (4*3^k - 2)/2 + 1
#         = 2*3^k

=pod

The boundary follows the curve edges around from the origin until returning
there.  So the single line segment N=0 to N=1 is boundary length 2, or the
"S" shape of N=0 to N=5 is length 10.

                          4---5
    boundary              |        boundary
     B[0]=2               3---2    B[1]=10
                              |
    0---1                 0---1

The first "S" shape is 5x the previous length but thereafter the way the
curve touches itself makes the boundary shorter (growing just over 3x as can
be seen from the power 3^k in B).

The boundary formula can be calculated from the way the curve meets when it
replicates.  Consider the level N=0 to N=5^k and take its boundary length in
two parts as a short side R and an inner curving part U.

        R          R[k] = side boundary
      4---5        U[k] = inner curve boundary
    R | U
      3---2        initial R[0] = 1
        U | R              U[0] = 3
      0---1
        R

The curve is shown here as plain lines but becomes fatter and wiggly at
higher replications.  Points 1 and 2 are on the right side boundary, and
similarly 3 and 4 on the left side boundary, so in this breakdown the points
where U and R parts meet are on the boundary.  The total is

    B[k+1] = 4*R[k] + 2*U[k]

The curve is symmetric on its left and right sides so R is half the total
boundary of the preceding level,

    R[k] = B[k] / 2

Combining these two equations gives

    2*R[k+1] = 4*R[k] + 2*U[k]
      R[k+1] = 2*R[k] +   U[k]

When the curve replicates to the next level N=5^k the boundary length
becomes,

        R
      *---5
    R | U       R       R           R[k+1] = 2*R[k] +   U[k]
      *---*   *---2   *---*         U[k+1] =   R[k] + 2*U[k]
        U | U |   | U |   | R
      4---*---*---*---*---1         # eg. 0 to 1 on the right for R[k+1]
    R |   | U |   | U | U           #     0 to 3 on the left for U[k+1]
      *---*   3---*   *---*
        R       R       U | R
                      0---*
                        R

The expansion for R[k+1] is the same as obtained above from symmetry of the
total.  Then U from 0 to 3 gives a second recurrence.  Eliminate U by
substituting the former into the latter,

    U[k] = R[k+1] - 2*R[k]                       # from R[k+1] formula

    R[k+2]-2*R[k+1] = 2*(R[k+1]-2*R[k]) + R[k]   # from U[k+1] formula
    R[k+2] = 4*R[k+1] - 3*R[k]

Then from R[k]=B[k-1]/2 this recurrence for R becomes the same recurrence
for the total B,

    B[k+1] = 4*B[k] - 3*B[k-1]

The characteristic equation of this recurrence is

    x^2 - 4*x + 3 = (x-3)*(x-1)     roots 3, 1

So the closed form is an a*3^k+b*1^k, being 4*3^k - 2.  That formula can
also be verified by induction from the initial B[0]=2, B[1]=10.

=cut

# x^2 - 4*x + 3 = (x-3)*(x-1)

# boundary = 2,10,34,106,322,970,2914
#          = A079004
#        a(n) = 3*a(n-1) + 4
#        a(n) = 4*3^n - 2
#      diff = 8, 24,72,216,648,1944,5832    = 8*3^n = A005051

# R[k] = B[k-1] / 2
# B[k] = 2*U[k] + 4*R[k]
# U[k+1] = 2*U[k] +   R[k]
# R[k+1] =   U[k] + 2*R[k]
# B[k+1] = 2*(2*U[k] + R[k]) + 4*(U[k] + 2*R[k])
#        = 8*U[k] + 10*R[k]
#
# U[1] = 3
# R[1] = 1
# B[1] = 4+2*3 = 10
#
# U[2] = 2*3+1 = 7
# R[2] = 3+2*1 = 5
# B[2] = 4*5+2*7 = 34
#
# U[k] = R[k+1] - 2*R[k]
# B[k] = 2*(R[k+1] - 2*R[k]) + 4*R[k]
#      = 2*R[k+1]
#
# U[k+1] = 2*U[k] + R[k]
# R[k+2] - 2*R[k+1] = 2*(R[k+1] - 2*R[k]) + R[k]
# R[k+2] = 2*R[k+1] + 2*R[k+1] - 4*R[k] + R[k]
# R[k+2] = 4*R[k+1] - 3*R[k]
# B[k+2] = 4*B[k+1] - 3*B[k]    from B[k-1] = 2 * R[k]
#
# 4*(4*3^(k+1) - 2) - 3*(4*3^k - 2)
#   = 4*4*3^(k+1) - 8 - 3*4*3^k + 6
#   = 4*4*3^(k+1) - 4*3^(k+1) - 2
#   = 3*4*3^(k+1) - 2
#   = 4*3^(k+2) - 2

# 2*R[k] - U[k] = 3*R[k-1]
# U[k] = 2*R[k] - 3*R[k-1]
# R[k] = 2*R[k-1] + 2*R[k-1] - 3*R[k-2]
#      = 4*R[k-1] - 3*R[k-2]
#
# 2*U[k] - R[k] = 3*U[k-1]
# R[k] = 2*U[k] - 3*U[k-1]
# U[k] = 2*U[k-1] + 2*U[k-1] - 3*U[k-2]
#      = 4*U[k-1] - 3*U[k-2]
#
# B[k] = 4*R[k] + 2*U[k]
#      = 4*(4*R[k-1] - 3*R[k-2]) + 2*(4*U[k-1] - 3*U[k-2])
#      = 4*4*R[k-1] - 4*3*R[k-2] + 2*4*U[k-1] - 2*3*U[k-2]
#      = 4*4*R[k-1] + 2*4*U[k-1] - 4*3*R[k-2] - 2*3*U[k-2]
#      = 4*(4*R[k-1] + 2*U[k-1]) - 3*(4*R[k-2] + 2*U[k-2])
# B[k] = 4*B[k-1] - 3*B[k-2]
# starting B[0] = 2, B[1] = 10
# 4*10 - 3*2 = 34
# 4*34 - 3*10 = 106
# 4*106 - 3*34 = 322
#
# B[k] = 4*B[k-1] - 3*B[k-2]
#      = 4*(4*B[k-2] - 3*B[k-3]) - 3*B[k-2]
#      = (4*4 - 3)*B[k-2] - 3*B[k-3]
#      = (4*4 - 3)*(4*B[k-3] - 3*B[k-4]) - 3*B[k-3]
#      = ((4*4 - 3)*4 - 3)*B[k-3] - (4*4 - 3)*3*B[k-4]
#
# B[k] - B[k-1] = (4*B[k-1] - 3*B[k-2]) - (4*B[k-2] - 3*B[k-3])
#               = 4*B[k-1] - 3*B[k-2] - 4*B[k-2] + 3*B[k-3]
#               = 4*B[k-1] - 7*B[k-2] + 3*B[k-3]
# B[k] - B[k-1] = (4*B[k-1] - 3*B[k-2]) - 3*B[k-2]
#               = 4*B[k-1] - 6*B[k-2]

=head2 U Boundary

The U length above can be calculated from the R[k+1]=2*R[k]+U[k] formula
above,

    U[k] = 2*3^k + 1
         = 3, 7, 19, 55, 163, 487, 1459, 4375, 13123, 39367, ...

=for Test-Pari-DEFINE  Usamples = [3, 7, 19, 55, 163, 487, 1459, 4375, 13123, 39367]

=for Test-Pari-DEFINE  U(k) = 2*3^k + 1

=for Test-Pari  vector(length(Usamples), k, U(k-1)) == Usamples

=for Test-Pari  vector(20, k, U(k-1)) == vector(20, k, R(k-1+1)-2*R(k-1))

=cut

# Pari: (U(k)=2*3^k+1); for(k=0,10,print1(U(k),", "))
# R[0]=1
# R[1]=5
# U[0]=R[1]-2*R[0]
#
# R[k+1] = 2*R[k] +   U[k]
# U[k] = R[k+1] - 2*R[k]
#      = (4*3^k - 2)/2 - (4*3^(k-1) - 2)
#      = 2*3^k - 1 - 4*3^(k-1) + 2
#      = 6*3^(k-1) - 4*3^(k-1) + 1
#      = 2*3^(k-1) + 1
#
# BU[k] = U[k] + 3*R[k]
#       = 2*3^k + 1  + 3*(4*3^k - 2)/2
#       = 2*3^k + 1  + 3/2*4*3^k - 3/2*2
#       = 2*3^k + 1  + 6*3^k - 3
#       = 8*3^k - 2

=pod

=for Test-Pari-DEFINE  BU(k) = 8*3^k - 2

=for Test-Pari BU(0) == 6

=head2 Area

The area enclosed by the curve from N=0 to N=5^k inclusive is

    A[k] = (5^k - 2*3^k + 1)/2
         = 0, 0, 4, 36, 232, 1320, 7084, 36876, 188752, ...

    A[k] = 9*A[k-1] - 23*A[k-2] + 15*A[k-3]

                                        4
    generating function  x^2 * -------------------
                               (1-5x)*(1-3x)*(1-x)

                            1/2      1      1/2
                         = ----- - ------ + ---
                           1-5*x   1-3*x    1-x


=for Test-Pari-DEFINE  Asamples = [0, 0, 4, 36, 232, 1320, 7084, 36876, 188752]

=for Test-Pari-DEFINE  A(k) = (5^k - 2*3^k + 1)/2

=for Test-Pari  vector(length(Asamples), k, A(k-1)) == Asamples

=for Test-Pari-DEFINE  Arec(k) = if(k<3,Asamples[k+1], 9*Arec(k-1) - 23*Arec(k-2) + 15*Arec(k-3))

=for Test-Pari  vector(length(Asamples), k, Arec(k-1)) == Asamples

=for Test-Pari-DEFINE  gA(x) =  (1/2)/(1-5*x) - 1/(1-3*x) + (1/2)/(1-x)

=for Test-Pari gA(x) == 4*x^2 / (1 - 9*x + 23*x^2 - 15*x^3)

=for Test-Pari gA(x) == 4*x^2 / ( (1 - 5*x)*(1-3*x)*(1-x) )

=for Test-Pari Vec(gA(x) - O(x^9)) == vecextract(Asamples,"3..")  /* no leading zeros from Vec() */

=cut

# perl -e '$,=", "; print map{(5**$_ - 2*3**$_ + 1)/2} 0 .. 8'
# Pari: (A(k)=(5^k - 2*3^k + 1)/2); for(k=0,18,print1(A(k),", "))

=pod

This can be calculated from the boundary.  The R5 curve encloses unit
squares in the same way as as the dragon curve per
L<Math::PlanePath::DragonCurve/Area from Boundary>, so 2*N = 4*A[N] + B[N],
giving

    2*5^k = 4*A[k] + 4*3^k - 2
    A[k] = (5^k - 2*3^k + 1)/2

The 5^k term can be worked into the B recurrence in the usual way to give
the A[k] recurrence 9,-23,15 above, and which can be verified by induction
from the initial A[0]=0, A[1]=0, A[2]=4.  The characteristic equation is

    x^3 - 9*x^2 + 23*x - 15 = (x-1)*(x-3)*(x-5)

The roots 3 and 5 become the power terms in the explicit formula, and 1 is
the constant.

Another form per Henry Bottomley in OEIS A007798 (which is area/2) is

    A[k+2] = 8*A[k+1] - 15*A[k] + 4

=for Test-Pari-DEFINE  ArecTwo(k) = if(k<2,Asamples[k+1], 8*ArecTwo(k-1) - 15*ArecTwo(k-2) + 4)

=for Test-Pari  vector(length(Asamples), k, ArecTwo(k-1)) == Asamples

=head2 Area by Replication

The area can also be calculated explicitly by replications in a similar way
to the boundary.  Consider the level N=0 to N=5^k and take its area in two
parts as a short side RA to the right and an inner curving part UA

       RA          RA[k] = side area
      4---5        RA[k] = inner curve area
   RA | UA
      3---2        initial RA[0]=0,RA[1]=0  UA[0]=0,UA[1]=0
       UA | RA
      0---1        A[k] = 4*RA[k] + 2*UA[k]
       RA

As per above, point 1 is on the right boundary of the curve.  Area RA is the
region between the 0--1 line and the right boundary of the curve around from
0 to 1.  This boundary in fact dips back to the left side of this 0--1 line.
When that happens it's reckoned as a negative area.  A similar negative area
happens to UA.

             ___   <-- negative area when other side of the line
            /   \
      0----/-----1
       \  /          line 0 to 1
        --           curve right boundary

The total area is the six parts

    A[k] = 4*RA[k] + 2*UA[k]

The curve is symmetric on its left and right sides so RA itself is half the
total area of the preceding level,

    RA[k] = A[k-1] / 2

Which gives

    RA[k+1] = 2*RA[k] + UA[k]

When the curve replicates to the next level N=5^k the pattern of new U and R
is the same as the boundary above, except the four newly enclosed squares
are of interest for the area.

        R
      *---5                         square edge length sqrt(5)^(k-2)
    R | U       R       R           square area = 5^(k-2)
      *---*   *---2   *---*
        U | U |   | U |   | R
      4---*---*---*---*---1
    R |   | U |   | U | U
      *---*   3---*   *---*
        R       R       U | R
                      0---*
                        R

The size of the squares grows by the sqrt(5) replication factor.  The
25-point replication shown is edge length 1.  Hence square=5^(k-2).

The line 0 to 1 passes through 3/4 of a square,

         ..... 1
         .    /      line dividing each square
         .   | .     into two parts 1/4 and 3/4
         .   / .
         *..|..*
         .  /  .
         . |   .
          /    .
         0 .....

The area for RA[k+1] is that to the right of the line 0--1.  This is first
+3/4 of a square with a further two RA on its outside, then -3/4 of a square
with a UA pushing out (reducing that negative).

    RA[k+1] = 3/4*square + 2*RA[k] - 3/4*square + UA[k]
           = 2*RA[k] + UA[k]

This is the same recurrence as obtained above from the symmetry RA[k] =
A[k-1]/2.

The area for UA[k+1] is that on left of the U shaped line 0-1-2-3,

    UA[k+1] = -3/4*square + UA[k] + 3/4*square
             + 2*square + UA[k] + RA[k]
    UA[k+1] = RA[k] + 2*UA[k] + 2*5^(k-2}           # square = 5^(k-2)

Notice for RA that the first 3/4 square has the left side of that square
dipping in.  For RA it's counted as a full +3/4 being the right side of the
centre line.  Then in UA on the left it's -3/4 which gives a net area of
just what's between the left and right curve boundaries.

=cut

# U[0] = 0    R[0] = 0
# U[1] = 0    R[1] = 0
#
# R[2] = 2*0 +   0 = 0
# U[2] =   0 + 2*0 + 2*5^0 = 2
# area[2] = 2*U+4*R = 4
#
# R[3] = 2*0 +   2 = 2
# U[3] =   0 + 2*2 + 2*5^1 = 14
# area[2] = 2*14+4*2 = 36

=pod

UA is eliminated by substituting the RA[k+1] recurrence into the UA[k+1]

    UA[k] = RA[k+1] - 2*RA[k]      # from the RA[k+1] formula

    RA[k+2]-2*RA[k+1] = 2*(RA[k+1]-2*RA[k]) + RA[k] + 2*5^(k-1)
    RA[k+2] = 4*RA[k+1] - 3*RA[k] + 2*5^(k-1)

Then from RA[k] = A[k-1]/2 the total area is as follows,

    A[k+2] = 4*A[k+1] - 3*A[k] + 4*5^k      # k>=2

This is the same as boundary calculation above but an extra 4*5^(k-2) which
are the 4 squares fully enclosed when the curve replicates.

=cut

# A[0] = 0
# A[1] = 0
# A[2] = 4*0 - 3*0 + 4*5^0 = 4
# A[3] = 4*4 - 3*0 + 4*5^1 = 36
# A[4] = 4*36 - 3*4 + 4*5^2 = 232

=pod

=head2 Single Points

The count of single-visited points N=0 to N=5^k inclusive is obtained from
the boundary in the same way as L<Math::PlanePath::DragonCurve/Single Points
from Boundary>,

    S[k] = B[k]/2 + 1
         = (4*3^k - 2)/2 + 1
         = 2*3^k
    = 2, 6, 18, 54, 162, 486, 1458, 4374, 13122, 39366, 118098, ...

=for Test-Pari-DEFINE Ssamples = [2, 6, 18, 54, 162, 486, 1458, 4374, 13122, 39366, 118098]

=for Test-Pari-DEFINE S(k) = 2*3^k

=for Test-Pari vector(length(Ssamples), k, S(k-1)) == Ssamples

=for Test-Pari-DEFINE SfromB(k) = B(k)/2 + 1

=for Test-Pari vector(length(Ssamples), k, SfromB(k-1)) == Ssamples

=cut

# Pari: for(k=0,18,print1(2*3^k,", "))

=pod

The double-visited points are the same as the area (also as per the dragon
curve) and the total singles and doubles is 5^k+1

    Singles[k] + 2*Doubles[k] = 2*3^k + 2*(5^k - 2*3^k + 1)/2
                              = 5^k + 1
    being points N=0 to N=5^k inclusive

=head2 Right Boundary Segment N

The curve segment numbers which are on the right boundary are

    RN = N, in ascending order, which in base 5 with 1s deleted
         does not have any of the following eight digit pairs
               22, 23, 24,
           30, 32, 33, 34,
           40

    = decimal 0,1,2,3,4,  5, 6, 7, 8, 9, 10,11, 16, 21,22,23,24, 25,...
    = base5   0,1,2,3,4, 10,11,12,13,14, 20,21, 31, 41,42,43,44, 100,...

This characterization is obtained by considering the boundary in four parts

    4-------5
    |    E          E[k] = 4...
    | D             D[k] = 3...
    |    C          C[k] = 2...
    3-------2       R[k] = 0...
            |
            | R
            |
    0-------1
        R

The values in each part R[k] etc has k many base-5 digits.  The two R parts
are the same, since points 0, 1 and 2 are all on the right boundary.  C is
those points starting digit 2 which are on the boundary.  Point 3 is not on
the boundary so there are fewer segments in C than in R.

The curve expands as follows

    *-----5                              R -> 0R, 1R, 2C, 3D, 4E
    |   E                                C -> 0R, 1C
    |D                                   D ->     1D
    |   C          R           R         E ->     1E, 2C, 3D, 4E
    *-----*     *-----2     *-----*
          |E   C|     |E   C|     |
          |     |     |     |     | R
          /  D  \     \  D  /     |
    4----/ /---\ \---\ \---/ /----1
    |     /     \     \     /   E
    |     |     |     |     | D
    |     |     |     |     |   C
    *-----*     3-----*     *-----*
                                  | R
                                  |
                            0-----*
                               R

2 to 3 is section C and it expands to an R and a C.  The further parts of C
are not on the boundary.  So in section type C a digit 0 leads to an R and a
digit 1 leads to a C, each of the preceding expansion level.

The boundary N values are then determined by starting from state R and
making transitions to state R, C, D or E according to the digits from high
to low per the expansions shown.

It can be seen that a digit 1 always leaves the state unchanged.  So any
digit 1s in N can be ignored.  With that done the digit determines the
state, since the transitions are always 0-E<gt>R, 2-E<gt>C, 3-E<gt>D and
4-E<gt>E.  The disallowed state transitions therefore become disallowed
digit pairs.

Since the D part only leads to another D part it can be seen that once a
digit 3 is seen the only permitted digit below there is 1.  There can be
zero or more such 1s.  The N=3 segment is zero 1s, then N=16 = base-5 "31"
has a single 1 below, etc.  The "3" giving D state can be reached from
either R or E, but once there that state is D always.

For computer calculation it works equally well to consider digits high to
low or low to high.  A state variable can maintain the preceding digit and
suitable table entries can leave the state unchanged to skip 1 digits.  For
high to low the initial state is equivalent to a 0 digit.  That can be
thought of as a 0 above the highest of N.  For low to high a special initial
state "no digit seen yet" is required.  That state skips low 1 digits until
a non-1 is reached.

=head2 Right Boundary Segment N Lengths

The number of values in the C, D and E sections after k expansions is

    C[k] = 3^k - k  = 1, 2,  7, 24, 77, 238, 723, 2180, 6553, ...
    D[k] = 1
    E[k] = 3^k + k  = 1, 4, 11, 30, 85, 248, 735, 2194, 6569, ...

=cut

# R[k+1] = 2*R[k] + C[k] + D[k] +   E[k]
# C[k+1] =   R[k] + C[k]
# D[k+1] =                 D[k]
# E[k+1] =          C[k] + D[k] + 2*E[k]
# U = C+D+E
# R[k] = 2*3^k - 1
# C[k+1] = R[k] + R[k-1] + ... + R[0] + C[0]
#        = 2*(3^(k+1) - 1)/(3-1) - (k+1) + 1
#        = (3^(k+1) - (k+1)
# C[k] = 3^k - k
# D[k] = 1 always
# 2*3^(k+1) - 1 = 2*(2*3^k - 1) + 3^k - k + 1 + E[k]
# E[k] = 2*3^(k+1) - 1 - 2*(2*3^k - 1) - 3^k + k - 1
#      = 2*3^(k+1) - 4*3^k + 2 - 3^k + k - 2
#      = 6*3^k - 4*3^k - 3^k + k
#      = 3^k + k
# C+D+E = 2*3^k + 1
# as per U[k] = 2*3^k + 1
# Pari: (C(k) = 3^k - k); for(k=0,8,print1(C(k),", "))
# Pari: (E(k) = 3^k + k); for(k=0,8,print1(E(k),", "))

=for Test-Pari-DEFINE  C_samples = [ 1, 2, 7, 24, 77, 238, 723, 2180, 6553 ]

=for Test-Pari-DEFINE  E_samples = [ 1, 4, 11, 30, 85, 248, 735, 2194, 6569 ]

=for Test-Pari-DEFINE  C(k) = 3^k - k 

=for Test-Pari-DEFINE  D(k) = 1

=for Test-Pari-DEFINE  E(k) = 3^k + k    /* 1, 4, 11, 30, 85, 248, 735, 2194, 6569 */

=for Test-Pari  vector(length(C_samples), k, C(k-1)) == C_samples

=for Test-Pari  vector(length(E_samples), k, E(k-1)) == E_samples

=for Test-Pari  vector(20, k, R(k+1)) == vector(20, k, 2*R(k) + C(k) + D(k) + E(k))

=for Test-Pari  vector(20, k, C(k+1)) == vector(20, k, R(k) + C(k))

=for Test-Pari  vector(20, k, D(k+1)) == vector(20, k, D(k))

=for Test-Pari  vector(20, k, E(k+1)) == vector(20, k, C(k) + D(k) + 2*E(k))

These are obtained from the relations

    R[k+1] = 2*R[k] + C[k] + D[k] +   E[k]         
    C[k+1] =   R[k] + C[k]
    D[k+1] =                 D[k] 
    E[k+1] =          C[k] + D[k] + 2*E[k]

    initial R[0]=C[0]=D[0]=E[0] = 1

Since D[k+1]=D[k] and initial D[0]=1 it is simply D[k]=1 always.
C[k+1]=R[k]+C[k] makes it a cumulative R[k], so

    C[k] = R[k-1] + R[k-2] + ... + R[0] + C[0]
                k-1
         = 1 + sum 2*3^k - 1
                i=0
         = 1 + 2*(3^k-1)/(3-1) - k
         = 3^k - k

Then substituting R, C and D into the first equation gives E

    E[k] = R[k+1] - 2*R[k] - C[k] - D[k]
         = 2*3^(k+1) - 1 - 2*(2*3^k - 1) - (3^k - k) - 1
         = 3^k + k

The total C,D,E is the U boundary length,

    C[k] + D[k] + E[k] = 2*3^k + 1 = U[k]

=head1 OEIS

The R5 dragon is in Sloane's Online Encyclopedia of Integer Sequences as,

=over

L<http://oeis.org/A175337> (etc)

=back

    A175337    next turn 0=left,1=right
                 (n=0 is the turn at N=1)

    A079004    boundary length N=0 to 5^k, skip initial 7,10
                 being 4*3^k - 2

    A048473    boundary/2 (one side), N=0 to 5^k
                 being half whole, 2*3^n - 1
    A198859    boundary/2 (one side), N=0 to 25^k
                 being even levels, 2*9^n - 1
    A198963    boundary/2 (one side), N=0 to 5*25^k
                 being odd levels, 6*9^n - 1

    A007798    1/2 * area enclosed N=0 to 5^k
    A016209    1/4 * area enclosed N=0 to 5^k

    A005058    1/2 * new area N=5^k to N=5^(k+1)
                 being area increments, 5^n - 3^n
    A005059    1/4 * new area N=5^k to N=5^(k+1)
                 being area increments, (5^n - 3^n)/2

    A008776    count single-visited points N=0 to 5^k
                 being 2*3^k

    A024024    C[k] boundary lengths, 3^k-k
    A104743    E[k] boundary lengths, 3^k+k

    arms=1 and arms=3
      A059841    abs(dX), being simply 1,0 repeating
      A000035    abs(dY), being simply 0,1 repeating

    arms=4
      A165211    abs(dY), being 0,1,0,1,1,0,1,0 repeating

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DragonCurve>,
L<Math::PlanePath::TerdragonCurve>

=head1 HOME PAGE

L<http://user42.tuxfamily.org/math-planepath/index.html>

=head1 LICENSE

Copyright 2012, 2013, 2014 Kevin Ryde

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
