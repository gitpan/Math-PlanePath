# Copyright 2011, 2012, 2013, 2014 Kevin Ryde

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



# points singles A052548 2^n + 2
# points doubles A000918 2^n - 2
# points triples A028243 3^(n-1) - 2*2^(n-1) + 1     cf A[k] = 2*3^(k-1) - 2*2^(k-1)

# T(3*N)   = (w+1)*T(N)                dir(N)=w^(2*count1digits)
# T(3*N+1) = (w+1)*T(N) + 1*dir(N)
# T(3*N+2) = (w+1)*T(N) + w*dir(N)

# T(0*3^k + N)  =             T(N)
# T(1*3^k + N)  = 2^k   + w^2*T(N)    # rotate and offset
# T(2*3^k + N)  = w*2^k +     T(N)    # offset only



package Math::PlanePath::TerdragonCurve;
use 5.004;
use strict;
use List::Util 'first';
use List::Util 'min'; # 'max'
*max = \&Math::PlanePath::_max;

use Math::PlanePath;
*_divrem_mutate = \&Math::PlanePath::_divrem_mutate;

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest',
  'xy_is_even';
use Math::PlanePath::Base::Digits
  'digit_split_lowtohigh',
  'digit_join_lowtohigh';

use vars '$VERSION', '@ISA';
$VERSION = 116;
@ISA = ('Math::PlanePath');

use Math::PlanePath::TerdragonMidpoint;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;
use constant parameter_info_array =>
  [ { name      => 'arms',
      share_key => 'arms_6',
      display   => 'Arms',
      type      => 'integer',
      minimum   => 1,
      maximum   => 6,
      default   => 1,
      width     => 1,
      description => 'Arms',
    } ];

{
  my @x_negative_at_n = (undef, 13, 5, 5, 6, 7, 8);
  sub x_negative_at_n {
    my ($self) = @_;
    return $x_negative_at_n[$self->{'arms'}];
  }
}
{
  my @y_negative_at_n = (undef, 159, 75, 20, 11, 9, 10);
  sub y_negative_at_n {
    my ($self) = @_;
    return $y_negative_at_n[$self->{'arms'}];
  }
}
sub dx_minimum {
  my ($self) = @_;
  return ($self->{'arms'} == 1 ? -1 : -2);
}
use constant dx_maximum => 2;
use constant dy_minimum => -1;
use constant dy_maximum => 1;

sub _UNDOCUMENTED__dxdy_list {
  my ($self) = @_;
  return ($self->{'arms'} == 1
          ? Math::PlanePath::_UNDOCUMENTED__dxdy_list_three()
          : Math::PlanePath::_UNDOCUMENTED__dxdy_list_six());
}
{
  my @_UNDOCUMENTED__dxdy_list_at_n = (undef, 4, 9, 13, 7, 8, 5);
  sub _UNDOCUMENTED__dxdy_list_at_n {
    my ($self) = @_;
    return $_UNDOCUMENTED__dxdy_list_at_n[$self->{'arms'}];
  }
}
use constant absdx_minimum => 1;
use constant dsumxy_minimum => -2; # diagonals
use constant dsumxy_maximum => 2;
use constant ddiffxy_minimum => -2;
use constant ddiffxy_maximum => 2;

# arms=1 curve goes at 0,120,240 degrees
# arms=2 second +60 to 60,180,300 degrees
# so when arms==1 dir maximum is 240 degrees
sub dir_maximum_dxdy {
  my ($self) = @_;
  return ($self->{'arms'} == 1
          ? (-1,-1)    # 0,2,4 only           South-West
          : ( 1,-1));  # rotated to 1,3,5 too South-East
}

#------------------------------------------------------------------------------

sub new {
  my $self = shift->SUPER::new(@_);
  $self->{'arms'} = max(1, min(6, $self->{'arms'} || 1));
  return $self;
}

my @dir6_to_si = (1,0,0, -1,0,0);
my @dir6_to_sj = (0,1,0, 0,-1,0);
my @dir6_to_sk = (0,0,1, 0,0,-1);

sub n_to_xy {
  my ($self, $n) = @_;
  ### TerdragonCurve n_to_xy(): $n

  if ($n < 0) { return; }
  if (is_infinite($n)) { return ($n, $n); }

  my $zero = ($n * 0);  # inherit bignum 0

  my $i = 0;
  my $j = 0;
  my $k = 0;
  my $si = $zero;
  my $sj = $zero;
  my $sk = $zero;

  # initial rotation from arm number
  {
    my $int = int($n);
    my $frac = $n - $int;  # inherit possible BigFloat
    $n = $int;             # BigFloat int() gives BigInt, use that

    my $rot = _divrem_mutate ($n, $self->{'arms'});

    my $s = $zero + 1;  # inherit bignum 1
    if ($rot >= 3) {
      $s = -$s;         # rotate 180
      $frac = -$frac;
      $rot -= 3;
    }
    if ($rot == 0)    { $i = $frac; $si = $s; } # rotate 0
    elsif ($rot == 1) { $j = $frac; $sj = $s; } # rotate +60
    else              { $k = $frac; $sk = $s; } # rotate +120
  }

  foreach my $digit (digit_split_lowtohigh($n,3)) {
    ### at: "$i,$j,$k   side $si,$sj,$sk"
    ### $digit

    if ($digit == 1) {
      ($i,$j,$k) = ($si-$j, $sj-$k, $sk+$i);  # rotate +120 and add
    } elsif ($digit == 2) {
      $i -= $sk;   # add rotated +60
      $j += $si;
      $k += $sj;
    }

    # add rotated +60
    ($si,$sj,$sk) = ($si - $sk,
                     $sj + $si,
                     $sk + $sj);
  }

  ### final: "$i,$j,$k   side $si,$sj,$sk"
  ### is: (2*$i + $j - $k).",".($j+$k)

  return (2*$i + $j - $k, $j+$k);
}


# all even points when arms==6
sub xy_is_visited {
  my ($self, $x, $y) = @_;
  if ($self->{'arms'} == 6) {
    return xy_is_even($self,$x,$y);
  } else {
    return defined($self->xy_to_n($x,$y));
  }
}

# maximum extent -- no, not quite right
#
#          .----*
#           \
#       *----.
#
# Two triangle heights, so
#     rnext = 2 * r * sqrt(3)/2
#           = r * sqrt(3)
#     rsquared_next = 3 * rsquared
# Initial X=2,Y=0 is rsquared=4
# then X=3,Y=1 is 3*3+3*1*1 = 9+3 = 12 = 4*3
# then X=3,Y=3 is 3*3+3*3*3 = 9+3 = 36 = 4*3^2
#
my @try_dx = (2, 1, -1, -2, -1,  1);
my @try_dy = (0, 1,  1, 0,  -1, -1);

sub xy_to_n {
  return scalar((shift->xy_to_n_list(@_))[0]);
}
sub xy_to_n_list {
  my ($self, $x, $y) = @_;
  ### TerdragonCurve xy_to_n_list(): "$x, $y"

  $x = round_nearest($x);
  $y = round_nearest($y);

  if (is_infinite($x)) {
    return $x;  # infinity
  }
  if (is_infinite($y)) {
    return $y;  # infinity
  }

  my @n_list;
  my $xm = 2*$x;  # doubled out
  my $ym = 2*$y;
  foreach my $i (0 .. $#try_dx) {
    my $t = $self->Math::PlanePath::TerdragonMidpoint::xy_to_n
      ($xm+$try_dx[$i], $ym+$try_dy[$i]);

    ### try: ($xm+$try_dx[$i]).",".($ym+$try_dy[$i])
    ### $t

    next unless defined $t;

    # function call here to get our n_to_xy(), not the overridden method
    # when in TerdragonRounded or other subclass
    my ($tx,$ty) = n_to_xy($self,$t)
      or next;

    if ($tx == $x && $ty == $y) {
      ### found: $t
      if (@n_list && $t < $n_list[0]) {
        unshift @n_list, $t;
      } elsif (@n_list && $t < $n_list[-1]) {
        splice @n_list, -1,0, $t;
      } else {
        push @n_list, $t;
      }
      if (@n_list == 3) {
        return @n_list;
      }
    }
  }
  return @n_list;
}

# minimum  -- no, not quite right
#
#                *----------*
#                 \
#                  \   *
#               *   \
#                    \
#          *----------*
#
# width = side/2
# minimum = side*sqrt(3)/2 - width
#         = side*(sqrt(3)/2 - 1)
#
# minimum 4/9 * 2.9^level roughly
# h = 4/9 * 2.9^level
# 2.9^level = h*9/4
# level = log(h*9/4)/log(2.9)
# 3^level = 3^(log(h*9/4)/log(2.9))
#         = h*9/4, but big bigger for log
#
# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### TerdragonCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"
  my $xmax = int(max(abs($x1),abs($x2)));
  my $ymax = int(max(abs($y1),abs($y2)));
  return (0,
          ($xmax*$xmax + 3*$ymax*$ymax + 1)
          * 2
          * $self->{'arms'});
}

my @dir6_to_dx   = (2, 1,-1,-2, -1, 1);
my @dir6_to_dy   = (0, 1, 1, 0, -1,-1);
my @digit_to_nextturn = (2,-2);
sub n_to_dxdy {
  my ($self, $n) = @_;
  ### n_to_dxdy(): $n

  if ($n < 0) {
    return;  # first direction at N=0
  }
  if (is_infinite($n)) {
    return ($n,$n);
  }

  my $int = int($n);  # integer part
  $n -= $int;         # fraction part

  # initial direction from arm
  my $dir6 = _divrem_mutate ($int, $self->{'arms'});

  my @ndigits = digit_split_lowtohigh($int,3);
  $dir6 += 2 * scalar(grep {$_==1} @ndigits);  # count 1s for total turn
  $dir6 %= 6;
  my $dx = $dir6_to_dx[$dir6];
  my $dy = $dir6_to_dy[$dir6];

  if ($n) {
    # fraction part

    # find lowest non-2 digit, or zero if all 2s or no digits at all
    $dir6 += $digit_to_nextturn[ first {$_!=2} @ndigits, 0];
    $dir6 %= 6;
    $dx += $n*($dir6_to_dx[$dir6] - $dx);
    $dy += $n*($dir6_to_dy[$dir6] - $dy);
  }
  return ($dx, $dy);
}


#-----------------------------------------------------------------------------
# eg. arms=5 0 .. 5*3^k    by 5s
#            1 .. 5*3^k+1  by 5s
#            4 .. 5*3^k+4  by 5s
#
sub _UNDOCUMENTED_level_to_n_range {
  my ($self, $level) = @_;
  return (0,
          3**$level * $self->{'arms'} + ($self->{'arms'}-1));
}

#-----------------------------------------------------------------------------
# right boundary N

# mixed radix binary, ternary
# no 11, 12, 20
# 11 -> 21, including low digit
# run of 11111 becomes 22221
# low to high 1 or 0 <- 0   cannot 20 can 10 00
#             2 or 0 <- 1   cannot 11 can 21 01
#             2 or 0 <- 2   cannot 12 can 02 22
sub _UNDOCUMENTED__right_boundary_i_to_n {
  my ($self, $i) = @_;
  my @digits = _digit_split_mix23_lowtohigh($i);
  for (my $i = $#digits; $i >= 1; $i--) {   # high to low
    if ($digits[$i] == 1 && $digits[$i-1] != 0) {
      $digits[$i] = 2;
    }
  }
  return digit_join_lowtohigh(\@digits, 3, $i*0);

  # {
  #   for (my $i = 0; $i < $#digits; $i++) {   # low to high
  #     if ($digits[$i+1] == 1 && ($digits[$i] == 1 || $digits[$i] == 2)) {
  #       $digits[$i+1] = 2;
  #     }
  #   }
  #   return digit_join_lowtohigh(\@digits,3);
  # }
}

# Return a list of digits, low to high, which is a mixed radix
# representation low digit ternary and the rest binary.
sub _digit_split_mix23_lowtohigh {
  my ($n) = @_;
  my $low = _divrem_mutate($n,3);
  return ($low, digit_split_lowtohigh($n,2));
}

{
  my @_UNDOCUMENTED__n_segment_is_right_boundary;
  $_UNDOCUMENTED__n_segment_is_right_boundary[1][1] = 1;  # disallowed
  $_UNDOCUMENTED__n_segment_is_right_boundary[1][2] = 1;  # combinations
  $_UNDOCUMENTED__n_segment_is_right_boundary[2][0] = 1;

  sub _UNDOCUMENTED__n_segment_is_right_boundary {
    my ($self, $n) = @_;
    if (is_infinite($n)) { return 0; }
    unless ($n >= 0) { return 0; }
    $n = int($n);

    my $prev = _divrem_mutate($n,3);
    while ($n) {
      my $digit = _divrem_mutate($n,3);
      if ($_UNDOCUMENTED__n_segment_is_right_boundary[$digit][$prev]) {
        return 0;
      }
      $prev = $digit;
    }
    return 1;
  }
}

#-----------------------------------------------------------------------------
# left boundary N

# mixed 0,1, 2, 10, 11, 12, 100, 101, 102, 110, 111, 112, 1000, 1001, 1002, 1010, 1011, 1012, 1100, 1101, 1102,
# vals  0,1,12,120,121,122,1200,1201,1212,1220,1221,1222,12000,12001,12012,12120,12121,12122,12200,12201,12212,
{
  my @_UNDOCUMENTED__left_boundary_i_to_n = ([0,2],  # 0
                                             [0,2],  # 1
                                             [1,2]); # 2
  sub _UNDOCUMENTED__left_boundary_i_to_n {
    my ($self, $i) = @_;
    my @digits = (Math::PlanePath::TerdragonCurve::_digit_split_mix23_lowtohigh($i),
                  0);
    my $prev = $digits[0];
    foreach my $i (1 .. $#digits) {
      $prev = $digits[$i] = $_UNDOCUMENTED__left_boundary_i_to_n[$prev][$digits[$i]];
    }
    return digit_join_lowtohigh(\@digits, 3, $i*0);

    # if ($digits[$i-1] == 0) {       # 0or2 <- 0
    #   if ($digits[$i]) { $digits[$i] = 2; }
    # } elsif ($digits[$i-1] == 1) {  # 0or2 <- 1
    #   if ($digits[$i]) { $digits[$i] = 2; }
    # } else {                        # 1or2 <- 2
    #   if ($digits[$i]) { $digits[$i] = 2; }
    #   else { $digits[$i] = 1; }
    # }

    # for (my $i = 1; $i <= $#digits; $i++) {   # low to high
    #   if ($digits[$i] == 0 && $digits[$i-1] == 2) {
    #     $digits[$i] = 1;     # 02 -> 12
    #   } elsif ($digits[$i] == 1 && $digits[$i-1] == 2) {
    #     $digits[$i] = 2;     # 12 -> 22
    #   } elsif ($digits[$i] == 1 && $digits[$i-1] == 0) {
    #     $digits[$i] = 2;     # 10 -> 20
    #   } elsif ($digits[$i] == 1 && $digits[$i-1] == 1) {
    #     $digits[$i] = 2;     # 11 -> 21
    #   }
    # }
  }
}

{
  my @_UNDOCUMENTED__n_segment_is_left_boundary;
  $_UNDOCUMENTED__n_segment_is_left_boundary[0][2] = 1;  # disallowed
  $_UNDOCUMENTED__n_segment_is_left_boundary[1][0] = 1;  # combinations
  $_UNDOCUMENTED__n_segment_is_left_boundary[1][1] = 1;

  sub _UNDOCUMENTED__n_segment_is_left_boundary {
    my ($self, $n) = @_;
    if (is_infinite($n)) { return 0; }
    unless ($n >= 0) { return 0; }
    $n = int($n);

    my $prev = _divrem_mutate($n,3);
    while ($n) {
      my $digit = _divrem_mutate($n,3);
      if ($_UNDOCUMENTED__n_segment_is_left_boundary[$digit][$prev]) {
        return 0;
      }
      $prev = $digit;
    }
    return ($prev <= 1);  # high digit 1, and also $n==0
  }

  # sub left_boundary_n_pred {
  #   my ($n) = @_;
  #   my $n3 = '0' . Math::BaseCnv::cnv($n,10,3);
  #   return ($n3 =~ /02|10|11/ ? 0 : 1);
  # }
}

1;
__END__


# old n_to_xy()
#
# # initial rotation from arm number
# my $arms = $self->{'arms'};
# my $rot = $n % $arms;
# $n = int($n/$arms);

# my @digits;
# my (@si, @sj, @sk);  # vectors
# {
#   my $si = $zero + 1; # inherit bignum 1
#   my $sj = $zero;     # inherit bignum 0
#   my $sk = $zero;     # inherit bignum 0
#
#   for (;;) {
#     push @digits, ($n % 3);
#     push @si, $si;
#     push @sj, $sj;
#     push @sk, $sk;
#     ### push: "digit $digits[-1]   $si,$sj,$sk"
#
#     $n = int($n/3) || last;
#
#     # straight + rot120 + straight
#     ($si,$sj,$sk) = (2*$si - $sj,
#                      2*$sj - $sk,
#                      2*$sk + $si);
#   }
# }
# ### @digits
#
# my $i = $zero;
# my $j = $zero;
# my $k = $zero;
# while (defined (my $digit = pop @digits)) {  # digits high to low
#   my $si = pop @si;
#   my $sj = pop @sj;
#   my $sk = pop @sk;
#   ### at: "$i,$j,$k  $digit   side $si,$sj,$sk"
#   ### $rot
#
#   $rot %= 6;
#   if ($rot == 1)    { ($si,$sj,$sk) = (-$sk,$si,$sj); }
#   elsif ($rot == 2) { ($si,$sj,$sk) = (-$sj,-$sk,$si); }
#   elsif ($rot == 3) { ($si,$sj,$sk) = (-$si,-$sj,-$sk); }
#   elsif ($rot == 4) { ($si,$sj,$sk) = ($sk,-$si,-$sj); }
#   elsif ($rot == 5) { ($si,$sj,$sk) = ($sj,$sk,-$si); }
#
#   if ($digit) {
#     $i += $si;  # digit=1 or digit=2
#     $j += $sj;
#     $k += $sk;
#     if ($digit == 2) {
#       $i -= $sj;  # digit=2, straight+rot120
#       $j -= $sk;
#       $k += $si;
#     } else {
#       $rot += 2;  # digit=1
#     }
#   }
# }
#
# $rot %= 6;
# $i = $frac * $dir6_to_si[$rot] + $i;
# $j = $frac * $dir6_to_sj[$rot] + $j;
# $k = $frac * $dir6_to_sk[$rot] + $k;
#
# ### final: "$i,$j,$k"
# return (2*$i + $j - $k, $j+$k);


=for stopwords eg Ryde Dragon Math-PlanePath Nlevel Knuth et al vertices doublings OEIS Online terdragon ie morphism si,sj,sk dX,dY Pari

=head1 NAME

Math::PlanePath::TerdragonCurve -- triangular dragon curve

=head1 SYNOPSIS

 use Math::PlanePath::TerdragonCurve;
 my $path = Math::PlanePath::TerdragonCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

X<Davis>X<Knuth, Donald>This is the terdragon curve by Davis and Knuth,

              \         /       \
           --- 26,29,32 ---------- 27                          6
              /         \
      \      /           \
   -- 24,33,42 ---------- 22,25                                5
      /      \           /     \
              \         /       \
           --- 20,23,44 -------- 12,21            10           4
              /        \        /      \        /     \
      \      /          \      /        \      /       \
        18,45 --------- 13,16,19 ------ 8,11,14 -------- 9     3
             \          /       \      /       \
              \        /         \    /         \
                  17              6,15 --------- 4,7           2
                                       \        /    \
                                        \      /      \
                                          2,5 ---------- 3     1
                                              \
                                               \
                                    0 ----------- 1         <-Y=0

          ^        ^        ^       ^      ^      ^      ^
         -3       -2       -1      X=0     1      2      3

Points are a triangular grid using every second integer X,Y as per
L<Math::PlanePath/Triangular Lattice>.

The base figure is an "S" shape

       2-----3
        \
         \
    0-----1

which then repeats in self-similar style, so N=3 to N=6 is a copy rotated
+120 degrees, which is the angle of the N=1 to N=2 edge,

    6      4          base figure repeats
     \   / \          as N=3 to N=6,
      \/    \         rotated +120 degrees
      5 2----3
        \
         \
    0-----1

Then N=6 to N=9 is a plain horizontal, which is the angle of N=2 to N=3,

          8-----9       base figure repeats
           \            as N=6 to N=9,
            \           no rotation
       6----7,4
        \   / \
         \ /   \
         5,2----3
           \
            \
       0-----1

Notice X=1,Y=1 is visited twice as N=2 and N=5.  Similarly X=2,Y=2 as N=4
and N=7.  Each point can repeat up to 3 times.  "Inner" points are 3 times
and on the edges up to 2 times.  The first tripled point is X=1,Y=3 which as
shown above is N=8, N=11 and N=14.

The curve never crosses itself.  The vertices touch as triangular corners
and no edges repeat.

The curve turns are the same as the C<GosperSide>, but here the turns are by
120 degrees each whereas C<GosperSide> is 60 degrees each.  The extra angle
here tightens up the shape.

=head2 Spiralling

The first step N=1 is to the right along the X axis and the path then slowly
spirals anti-clockwise and progressively fatter.  The end of each
replication is

    Nlevel = 3^level

That point is at level*30 degrees around (as reckoned with Y*sqrt(3) for a
triangular grid).

    Nlevel      X, Y     Angle (degrees)
    ------    -------    -----
       1        1, 0        0
       3        3, 1       30
       9        3, 3       60
      27        0, 6       90
      81       -9, 9      120
     243      -27, 9      150
     729      -54, 0      180

The following is points N=0 to N=3^6=729 going half-circle around to 180
degrees.  The N=0 origin is marked "0" and the N=729 end is marked "E".

=cut

# the following generated by
#   math-image --path=TerdragonCurve --expression='i<=729?i:0' --text --size=132x40

=pod

                               * *               * *
                            * * * *           * * * *
                           * * * *           * * * *
                            * * * * *   * *   * * * * *   * *
                         * * * * * * * * * * * * * * * * * * *
                        * * * * * * * * * * * * * * * * * * *
                         * * * * * * * * * * * * * * * * * * * *
                            * * * * * * * * * * * * * * * * * * *
                           * * * * * * * * * * * *   * *   * * *
                      * *   * * * * * * * * * * * *           * *
     * E           * * * * * * * * * * * * * * * *           0 *
    * *           * * * * * * * * * * * *   * *
     * * *   * *   * * * * * * * * * * * *
    * * * * * * * * * * * * * * * * * * *
     * * * * * * * * * * * * * * * * * * * *
        * * * * * * * * * * * * * * * * * * *
       * * * * * * * * * * * * * * * * * * *
        * *   * * * * *   * *   * * * * *
                 * * * *           * * * *
                * * * *           * * * *
                 * *               * *

=head2 Tiling

The little "S" shapes of the base figure N=0 to N=3 can be thought of as a
rhombus

       2-----3
      .     .
     .     .
    0-----1

The "S" shapes of each 3 points make a tiling of the plane with those rhombi

        \     \ /     /   \     \ /     /
         *-----*-----*     *-----*-----*
        /     / \     \   /     / \     \
     \ /     /   \     \ /     /   \     \ /
    --*-----*     *-----*-----*     *-----*--
     / \     \   /     / \     \   /     / \
        \     \ /     /   \     \ /     /
         *-----*-----*     *-----*-----*
        /     / \     \   /     / \     \
     \ /     /   \     \ /     /   \     \ /
    --*-----*     *-----o-----*     *-----*--
     / \     \   /     / \     \   /     / \
        \     \ /     /   \     \ /     /
         *-----*-----*     *-----*-----*
        /     / \     \   /     / \     \

Which is an ancient pattern,

=over

L<http://tilingsearch.org/HTML/data23/C07A.html>

=back

=head2 Arms

The curve fills a sixth of the plane and six copies rotated by 60, 120, 180,
240 and 300 degrees mesh together perfectly.  The C<arms> parameter can
choose 1 to 6 such curve arms successively advancing.

For example C<arms =E<gt> 6> begins as follows.  N=0,6,12,18,etc is the
first arm (the same shape as the plain curve above), then N=1,7,13,19 the
second, N=2,8,14,20 the third, etc.

                  \         /             \           /
                   \       /               \         /
                --- 8/13/31 ---------------- 7/12/30 ---
                  /        \               /         \
     \           /          \             /           \          /
      \         /            \           /             \        /
    --- 9/14/32 ------------- 0/1/2/3/4/5 -------------- 6/17/35 ---
      /         \            /           \             /        \
     /           \          /             \           /          \
                  \        /               \         /
               --- 10/15/33 ---------------- 11/16/34 ---
                  /        \               /         \
                 /          \             /           \

With six arms every X,Y point is visited three times, except the origin 0,0
where all six begin.  Every edge between points is traversed once.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::TerdragonCurve-E<gt>new ()>

=item C<$path = Math::PlanePath::TerdragonCurve-E<gt>new (arms =E<gt> 6)>

Create and return a new path object.

The optional C<arms> parameter can make 1 to 6 copies of the curve, each arm
successively advancing.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  If there's nothing at
C<$x,$y> then return C<undef>.

The curve can visit an C<$x,$y> up to three times.  C<xy_to_n()> returns the
smallest of the these N values.

=item C<@n_list = $path-E<gt>xy_to_n_list ($x,$y)>

Return a list of N point numbers for coordinates C<$x,$y>.  There can be
none, one, two or three N's for a given C<$x,$y>.

=back

=head2 Descriptive Methods

=over

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=item C<$dx = $path-E<gt>dx_minimum()>

=item C<$dx = $path-E<gt>dx_maximum()>

=item C<$dy = $path-E<gt>dy_minimum()>

=item C<$dy = $path-E<gt>dy_maximum()>

The dX,dY values on the first arm take three possible combinations, being
120 degree angles.

    dX,dY   for arms=1
    -----
     2, 0        dX minimum = -1, maximum = +2
    -1, 1        dY minimum = -1, maximum = +1
     1,-1

For 2 or more arms the second arm is rotated by 60 degrees so giving the
following additional combinations, for a total six.  This changes the dX
minimum.

    dX,dY   for arms=2 or more
    -----
    -2, 0        dX minimum = -2, maximum = +2
     1, 1        dY minimum = -1, maximum = +1
    -1,-1

=back

=head1 FORMULAS

=head2 N to X,Y

There's no reversals or reflections in the curve so C<n_to_xy()> can take
the digits of N either low to high or high to low and apply what is
effectively powers of the N=3 position.  The current code goes low to high
using i,j,k coordinates as described in L<Math::PlanePath/Triangular
Calculations>.

    si = 1    # position of endpoint N=3^level
    sj = 0    #    where level=number of digits processed
    sk = 0

    i = 0     # position of N for digits so far processed
    j = 0
    k = 0

    loop base 3 digits of N low to high
       if digit == 0
          i,j,k no change
       if digit == 1
          (i,j,k) = (si-j, sj-k, sk+i)  # rotate +120, add si,sj,sk
       if digit == 2
          i -= sk      # add (si,sj,sk) rotated +60
          j += si
          k += sj

       (si,sj,sk) = (si - sk,      # add rotated +60
                     sj + si,
                     sk + sj)

The digit handling is a combination of rotate and offset,

    digit==1                   digit 2
    rotate and offset          offset at si,sj,sk rotated

         ^                          2------>
          \
           \                          \
    *---  --1                  *--   --*

The calculation can also be thought of in term of w=1/2+I*sqrt(3)/2, a
complex number sixth root of unity.  i is the real part, j in the w
direction (60 degrees), and k in the w^2 direction (120 degrees).  si,sj,sk
increase as if multiplied by w+1.

=head2 Turn

At each point N the curve always turns 120 degrees either to the left or
right, it never goes straight ahead.  If N is written in ternary then the
lowest non-zero digit gives the turn

   ternary lowest
   non-zero digit     turn
   --------------     -----
         1            left
         2            right

At N=3^level or N=2*3^level the turn follows the shape at that 1 or 2 point.
The first and last unit step in each level are in the same direction, so the
next level shape gives the turn.

       2*3^k-------3*3^k
          \
           \
    0-------1*3^k

=head2 Next Turn

The next turn, ie. the turn at position N+1, can be calculated from the
ternary digits of N similarly.  The lowest non-2 digit gives the turn.

   ternary lowest
     non-2 digit       turn
   --------------      -----
          0            left
          1            right

If N is all 2s then the lowest non-2 is taken to be a 0 above the high end.
For example N=8 is 22 ternary so considered 022 for lowest non-2 digit=0 and
turn left after the segment at N=8, ie. at point N=9 turn left.

This rule works for the same reason as the plain turn above.  The next turn
of N is the plain turn of N+1 and adding +1 turns trailing 2s into trailing
0s and increments the 0 or 1 digit above them to be 1 or 2.

=head2 Total Turn

The direction at N, ie. the total cumulative turn, is given by the number of
1 digits when N is written in ternary,

    direction = (count 1s in ternary N) * 120 degrees

For example N=12 is ternary 110 which has two 1s so the cumulative turn at
that point is 2*120=240 degrees, ie. the segment N=16 to N=17 is at angle
240.

The segments for digit 0 or 2 are in the "current" direction unchanged.  The
segment for digit 1 is rotated +120 degrees.

=head2 X,Y to N

The current code applies C<TerdragonMidpoint> C<xy_to_n()> to calculate six
candidate N from the six edges around a point.  Those N values which convert
back to the target X,Y by C<n_to_xy()> are the results for
C<xy_to_n_list()>.

The six edges are three going towards the point and three going away.  The
midpoint calculation gives N-1 for the towards and N for the away.  Is there
a good way to tell which edge will be the smaller?  Or just which 3 edges
lead away?  It would be directions 0,2,4 for the even arms and 1,3,5 for the
odd ones, but identifying the boundaries of those arms to know which is
which is difficult.

=head2 X,Y Visited

When arms=6 all "even" points of the plane are visited.  As per the
triangular representation of X,Y this means

    X+Y mod 2 == 0        "even" points

=head2 Boundary Length

The length of the boundary of the terdragon on points N=0 to N=3^k
inclusive, taking each line segment as length 1, is

    boundary B[k] = / 2      if k=0     (N=0 to N=1)
                    \ 3*2^k  if k>=1    (N=0 to N=3^k)
    = 2, 6, 12, 24, 48, 96, ...

=for Test-Pari-DEFINE  Bsamples=[2, 6, 12, 24, 48, 96]

=for Test-Pari-DEFINE  B(k)=if(k==0, 2, 3*2^k)

=for Test-Pari vector(length(Bsamples), k, B(k-1)) == Bsamples

The boundary follows the curve edges around from the origin until returning
there.  So the single line segment N=0 to N=1 is boundary length 2, or the
"S" shape of N=0 to N=3 is length 6.

                           2------3
    B[0] = 2                \
                             \       B[1] = 6
    0-----1            0------1

The B[1] first "S" is 3x the length of the preceding but thereafter the
curve touches itself and so the boundary grows by only 2x per level.

The boundary formula can be calculated from the way the curve meets when it
replicates.  Consider the level N=0 to N=3^k and take its boundary length in
two parts as a short side R on the right and the V shaped indentation on the
left.  These are shown as plain lines here but are wiggly as the curve
becomes bigger and fatter.

             R         R[k] = right side boundary length
          2-----3      V[k] = left side boundary length
           \ V       initial
         V  \          R[0] = 1
       0-----1         V[0] = 2
          R          B[k+1] = 2*R[k] + 2*V[k]
                       B[1] = 6

By symmetry the two sides of the terdragon are the same length, so the total
boundary is twice the right side,

    boundary[k] = 2*R[k+1]

When the curve is tripled out to the next level N=3^k the boundary length
does not triple because the sides marked "===" in the following diagram
enclose lengths 2*R and 2*V which would have been boundary, leaving only 4*R
and 4*V.

             R          for k >= 0
          *-----3       R[k+1] = R[k] + V[k]    # per 0 to 1
           \ V          V[k+1] = R[k] + V[k]    # per 0 to 2
          V \
       2=====@
        \   / \ R
      R  \ /   \        initial B[0] = 2
          @=====1               B[1] = 6
           \ V
          V \
       0-----*
         R

The two recurrences for R and V are the same, so R[k]=V[k] for k>=1 and
hence

    R[k+1] = 2*R[k]       k >= 1

    B[k] = 2*B[k-1]       k >= 2
         = 3*2^k          from initial boundary[1] = 6

The separate R and V parts are

    R[k] = / 1          if k=0
           \ 3*2^(k-1)  if k>=1
    = 1, 3, 6, 12, 24, 48, ...

    V[k] = / 2          if k=0
           \ 3*2^(k-1)  if k>=1
    = 2, 3, 6, 12, 24, 48, ...

=for Test-Pari-DEFINE  Rsamples=[1, 3, 6, 12, 24, 48]

=for Test-Pari-DEFINE  R(k)=if(k==0, 1, 3*2^(k-1))

=for Test-Pari vector(length(Rsamples), k, R(k-1)) == Rsamples

=for Test-Pari-DEFINE  Vsamples=[2, 3, 6, 12, 24, 48]

=for Test-Pari-DEFINE  V(k)=if(k==0, 2, 3*2^(k-1))

=for Test-Pari vector(length(Vsamples), k, V(k-1)) == Vsamples

=head2 Multi-Arm Boundary

The boundary length of two curve arms each to N=3^k is

    Ba2[k] = 2*R[k] + V[k]
           = / 4           if k=0
             \ 9*2^(k-1)   if k>=1
    = 4, 9, 18, 36, 72, 144, 288, 576, 1152, ...

          2
         ^
      R /  V       Ba2 = 2*R + V
       /
      0----->1
         R

=for Test-Pari-DEFINE  Ba2samples = [4, 9, 18, 36, 72, 144, 288, 576, 1152]

=for Test-Pari-DEFINE  Ba2_by_RV(k) = 2*R(k) + V(k)

=for Test-Pari vector(length(Ba2samples), k, Ba2_by_RV(k-1)) == Ba2samples

=for Test-Pari-DEFINE  Ba2(k) = if(k==0, 4, 9*2^(k-1))

=for Test-Pari vector(length(Ba2samples), k, Ba2(k-1)) == Ba2samples

=cut

# Ba2 = / 2*1 + 2
#       \ 2*3*2^(k-1) + 3*2^(k-1)
# Ba2 = / 4
#       \ 9*2^(k-1)
# Pari: (Ba2(k) = if(k==0, 4, 9*2^(k-1))); for(k=0,8,print1(Ba2(k),", "))

=pod

The boundary between endpoints 1 and 2 is the same as V above.  The curve
direction 0 to 1 is the other way around, but that doesn't matter since the
curve is identical forward and backward.

The boundary length of three through five arms has a further V in each.

    Ba3[k] = 2*R[k] + 2*V[k]
           = 6*2^k
    = 6, 12, 24, 48, 96, 192, 384, 768, 1536, ...

    Ba4[k] = 2*R[k] + 3*V[k]
           = / 8            if k=0
             \ 15*2^(k-1)   if k>=1
    = 8, 15, 30, 60, 120, 240, 480, 960, 1920,

    Ba5[k] = 2*R[k] + 4*V[k]
           = / 10           if k=0
             \ 9*2^k        if k>=1
    = 10, 18, 36, 72, 144, 288, 576, 1152, 2304,

    3       2             3       2            3       2
     ^  V  ^               ^  V  ^              ^  V  ^
    R \   /  V           V  \   /  V          V  \   /  V
       \ /                   \ /                  \ /
        0----->1       4<-----0----->1      4<-----0----->1
           R              R      R             V  /    R
                                                 / R
    Ba3 = 2*R + 2*V    Ba4 = 2*R + 3*V          v
                                               5

                                             Ba5 = 2*R + 4*V

=for Test-Pari-DEFINE  Ba3samples = [6, 12, 24, 48, 96, 192, 384, 768, 1536]

=for Test-Pari-DEFINE  Ba4samples = [8, 15, 30, 60, 120, 240, 480, 960, 1920]

=for Test-Pari-DEFINE  Ba5samples = [10, 18, 36, 72, 144, 288, 576, 1152, 2304]

=for Test-Pari-DEFINE  Ba3(k) = 6*2^k

=for Test-Pari-DEFINE  Ba4(k) = if(k==0, 8, 15*2^(k-1))

=for Test-Pari-DEFINE  Ba5(k) = if(k==0, 10, 9*2^k)

=for Test-Pari vector(length(Ba3samples), k, Ba3(k-1)) == Ba3samples

=for Test-Pari vector(length(Ba4samples), k, Ba4(k-1)) == Ba4samples

=for Test-Pari vector(length(Ba5samples), k, Ba5(k-1)) == Ba5samples

=for Test-Pari-DEFINE  Ba3_by_RV(k) = 2*R(k) + 2*V(k)

=for Test-Pari-DEFINE  Ba4_by_RV(k) = 2*R(k) + 3*V(k)

=for Test-Pari-DEFINE  Ba5_by_RV(k) = 2*R(k) + 4*V(k)

=for Test-Pari vector(length(Ba3samples), k, Ba3_by_RV(k-1)) == Ba3samples

=for Test-Pari vector(length(Ba4samples), k, Ba4_by_RV(k-1)) == Ba4samples

=for Test-Pari vector(length(Ba5samples), k, Ba5_by_RV(k-1)) == Ba5samples

=cut

# Ba3 = / 2*1 + 2*2
#       \ 2*3*2^(k-1) + 2*3*2^(k-1)
# Ba3 = / 6
#       \ 6*2^k
#     = 6*2^k
#
# Ba4 = / 2*1 + 3*2
#       \ 2*3*2^(k-1) + 3*3*2^(k-1)
# Ba4 = / 8
#       \ 15*2^(k-1)
#
# Ba5 = / 2*1 + 4*2
#       \ 2*3*2^(k-1) + 4*3*2^(k-1)
# Ba5 = / 10
#       \ 9*2^k
#
# Pari: (Ba3(k) = 6*2^k);                   for(k=0,8,print1(Ba3(k),", "))
# Pari: (Ba4(k) = if(k==0, 8, 15*2^(k-1))); for(k=0,8,print1(Ba4(k),", "))
# Pari: (Ba5(k) = if(k==0, 10, 9*2^k));     for(k=0,8,print1(Ba5(k),", "))

=pod

Six arms is six V,

    Ba6[k] = 6*V[k]
           = / 12       if k=0
             \ 9*2^k    if k>=1
    = 12, 18, 36, 72, 144, 288, 576, 1152, 2304, ...

       3       2
        ^  V  ^
      V  \   /  V      
          \ /             Ba6 = 6*V
    4<-----0----->1
       V  / \  V
         /   \
        v  V  v
       5       6

=for Test-Pari-DEFINE  Ba6samples = [12, 18, 36, 72, 144, 288, 576, 1152, 2304]

=for Test-Pari-DEFINE  Ba6(k) = if(k==0, 12, 9*2^k)

=for Test-Pari vector(length(Ba6samples), k, Ba6(k-1)) == Ba6samples

=for Test-Pari-DEFINE  Ba6_by_V(k) = 6*V(k)

=for Test-Pari vector(length(Ba6samples), k, Ba6_by_V(k-1)) == Ba6samples

=cut

# Pari: (Ba6(k) = if(k==0, 12, 9*2^k)); for(k=0,8,print1(Ba6(k),", "))

=pod

Notice Ba6[k] = Ba5[k] for kE<gt>=1.  That arises since R[k]=V[k] for
kE<gt>=1.  The two Rs in 5 arms have become two Vs in 6 arms.

=head2 Area from Boundary

The area enclosed by the terdragon curve from 0 to N inclusive is related to
the boundary by

    2*N = 3*A[N] + B[N]

where A[N] counts unit equilateral triangles.  Imagine each line segment as
having a little triangle on each side, with each of those triangles being
1/3 of the unit area.

          *      equilateral unit area
         /|\     divided into 3 triangles
        / | \
       /  |  \
      /  _*_  \                _*_         2 triangles
     /_--   --_\            _--   --_      one each side of line segment
    *-----------*         *-----------*    total triangles=2*N
                            -__   __-      each triangle area 1/3
                               -*-

If a line segment is on the curve boundary then its outside triangle should
not count towards the area enclosed, so subtract 1 for each unit boundary
length.  If a segment is both a left and right boundary, such as the initial
N=0 to N=1 then it counts 2 to B[N] which makes its area 0 which is as
desired.  So

    area triangles = total triangles - B[N]
       3*A[N]      =      2*N        - B[N]

Another way is to consider how a new line segment changes the total boundary and area

    <------*       line segment not enclose triangle
          /          boundary +2
                     area     unchanged

    *  <----*      line segment enclose triangle
     \     /         boundary -2 + 1 = -1
      \   /          area     + 1
       \ /
        *

So the boundary increases by 2 for each N, but decreases by 3 if there's a
new enclosed area triangle, giving the relation

    B = 2*N - 3*A

At all times the curve has all "inside" line segments traversed exactly once
so that each unit area has all three sides traversed once each.  If there
was ever an area enclosed bigger than a single unit equilateral triangle
then the curve would have to cross itself to traverse the inner lines to
produce the "all inside segments traversed" pattern of the replications and
expansions.

=head2 Area

The area enclosed by the curve from N=0 to N=3^k inclusive is

    A[k] = / 0                      if k=0
           \ 2*(3^(k-1) - 2^(k-1))  if k >=1
         = 0, 0, 2, 10, 38, 130, 422, 1330, 4118, ...

=for Test-Pari-DEFINE  Asamples=[0, 0, 2, 10, 38, 130, 422, 1330, 4118]

=for Test-Pari-DEFINE  A(k)=if(k==0, 0, 2*(3^(k-1) - 2^(k-1)))

=for Test-Pari vector(length(Asamples), k, A(k-1)) == Asamples

=for Test-Pari vector(20, k, 2*3^(k -1)) == vector(20, k, 3*A(k -1) + B(k -1))

=cut

# perl -e '$,=", "; print map{2*(3**($_-1)-2**($_-1))} 1 .. 8'
# Pari: for(n=1,8,print1(2*(3^(n-1)-2^(n-1)),", "))

=pod

This is per 2*N=3*A+B and the boundary formula above.

    2*3^k = 3*A[k] + 3*2^k        k >= 1

=head2 Area by Replication

The area can also be calculated directly from the replication.

       *-----D
        \              A[k] = 2 * A[k-1]     # AB and CD
         \                  + 2 * 3^(k-2)    # centre triangles
    C-----f                 - 2 * A[k-2]/2   # Cf, Be insides
     \   / \                + 2 * A[k-2]/2   # Ce, Bf outsides
      \ /   \
       e-----B              = 2*A[k-1] + 2*3^(k-2)
        \
         \             sum to
    A-----*            A[k] = 2*(3^(k-1) - 2^(k-1))

=cut

# A[0] to N=1   0
# A[1] to N=2   0
# A[2] to N=9   k=2; 2*0 + 2*3^(k-2) == 2
# A[2] to N=27  k=3; 2*2 + 2*3^(k-2) == 10
# A[2] to N=81  k=4; 2*10 + 2*3^(k-2) == 38

=pod

The area enclosed by the end two copies A-B and C-D are each the area of the
preceding level.

The middle two triangles enclose area 2*3^k.  But they duplicate the area on
the underside of the C-f copy of the curve and the upper side of the B-e
copy.  The terdragon is symmetric on the two sides of the line between its
endpoints so the part on the upper side is half the curve, so subtract
2*A[k-2]/2.

Then there are 2 similar half curve A[k-2]/2 areas on the outer sides of the
B-f and C-e segments to be added.  The extra and overlapped insides and
outsides cancel out.

=cut

# A[k] = 2^1*3^(k-1) + 2^2*3^(k-2) + ... + 2^k*3^0
#      = 2* (3^k - 2^k)/(3-2)
#
#            *
#           / \       area = base^2
#   *      *---*
#  / \    / \ / \
# *---*  *---*---*
#
#       *-----D
#        \
#         \
#    *-----*                  R[3] = -1+1+1 = 1
#     \   / \                 V[3] = -1+1-1+1+1+1 = 4
#      \ /   \                A[3] = 2R+2V = 10
#       *-----*     *
#        \   / \   / \
#         \ /   \ /   \
#    C-----*-----*-----B
#     \   / \   / \
#      \ /   \ /   \
#       *     *-----*
#              \   / \
#               \ /   \
#                *-----*
#                 \
#                  \
#             A-----*
#
#  2*(3^k - 2^k) / 3^k -> 2

# This is as if in the area of the A-B and C-D end parts above became
# negligible and only the centre two triangles mattered.

=pod

=head2 Area as Rhombus

The area of the curve approaches the area of a rhombus made of two large
equilateral triangles between the endpoints.

       *-----N         N=3^(k+1)
      . \   .          side length = sqrt(3)^k
     .   \ .           rhombus area = 2 * side^2 = 2*3^k
    O-----*            (area measured in unit triangles)

    terdragon    2*(3^k - 2^k)
    --------- =  ------------- -> 1 as k->infinity
     rhombus         2*3^k

If the terdragon is reckoned as a fractal with unit length between its
endpoints and infinitely smaller wiggles then this ratio is exact, ie. the
area of the fractal terdragon is the same as the area of the rhombus.

=cut

# Rhombus area
#
# +---*------*
# |  /      /|  H=S*sqrt(3)/2
# | /      / |
# |/      /  |         rhombus area = 2 * side^2 = 2*3^k
# O------*---+
#    S
# H^2+(S/2)^2 = 3/4*S^2 + 1/4*S^2 = S^2
# Rect = (S+S/2)*H = 3/2**sqrt(3)/2*S^2 = 3/4*sqrt(3)*S
# Rhombus = 2/3 * Rect = 1/2*sqrt(3)*S

=pod

=head2 Join Area

When the terdragon curve triples out from N=3^k to N=3^(k+1) the three
copies enclose the same area each, plus where they meet encloses a further
join area.

       _____
      /    /
     /____/
    _____  <-- join area JA[k]
    \    \
     \____\
       _____  <-- join area JA[k]
      /    /
     /____/

The curve is symmetric so the two join areas are the same, just rotated 180
degrees.  The join area can be calculated as a difference A[k+1] versus
three A[k].

     JA[k] = (A[k+1] - 3*A[k])/2      join area when N=3^k triples
           = / 0       if k = 0
             \ 2^k     if k >= 1
     = 0, 2, 4, 8, 16, 32, 64, ...

=for Test-Pari-DEFINE  JAsamples = [0, 2, 4, 8, 16, 32, 64]

=for Test-Pari-DEFINE  JA(k)=if(k==0,0, 2^k)

=for Test-Pari vector(length(JAsamples), k, JA(k-1)) == JAsamples

=for Test-Pari-DEFINE  A(k)=if(k==0, 0, 2*(3^(k-1) - 2^(k-1)))

=for Test-Pari-DEFINE  JA_from_A(k)=A(k+1)-3*A(k)

=for Test-Pari vector(length(JAsamples), k, JA_from_A(k-1)) == JAsamples

=for Test-Pari vector(20, k, JA_from_A(k-1)) == vector(20, k, JA_from_A(k-1))

=cut

# JA[k] = A[k+1] - 3*A[k]
#       = 2*3^k - 2*2^k - 3*2*3^(k-1) + 3*2*2^(k-1)
#       = 2*3^k - 2*2^k - 2*3^k + 3*2^k
#       = 2^k

=pod

=head2 Join Boundary

When two copies of the curve meet there is a certain boundary length on each
side of the two copies.  These lengths are V[k] and R[k], and hence equal
for kE<gt>=2.

    2-----
     \    \       boundary 1 to j = / 0         if k=0
      \____\                        \ V[k-1]    if k>=1
       j____1
      /    /      boundary 1 to j = / 0         if k=0
     /    /                         \ R[k-1]    if k>=1
    0-----

For example two k=1 levels meet as follows.  N=2 to N=3 is the boundary of
the first copy, which is R[0]=1.  N=3,4,5 is the boundary of the second,
which is V[1]=2.

    6     4
     \  /  \     V[0] = 2       k=1 join
      5,2---3
        \        R[0] = 1
    0----1

The triangular area 2-3-4-5 expand on its two sides as R and V boundaries
described above.

      *
     / \             A-*-B second curve   V[k]
    / V \
   A     B

      R              A-B first curve      R[k]
   A-----B

Outside that triangular area there is no further join.  The 1--2 is the
first curve and 5--6 is the second and two curves in the same direction like
that don't touch except at their endpoint 2 and 5.

This can be seen from the curve extents, or also from the join area
calculated above.  Each join area has 3 sides of boundary and it can be seen
that the total of those is equal to the R and V boundaries inside the
triangle.

    3*JA[k] = R[k] + V[k]       k >= 1

=for Test-Pari vector(20, k, 3*JA(k)) == vector(20, k, R(k) + V(k))

=head2 Right Boundary Turn Sequence

The right side boundary of the terdragon at each point either turns by +120
degrees (left), -120 degrees (right), or goes straight ahead.  Numbering the
boundary starting from i=1 at N=1 the turn sequence is

    Rt(i) = / if i == 2 mod 3 then  turn -120   (right)
            | otherwise
            | let b = bit above lowest 1-bit of i-floor(i/3)
            | if b = 0 then         turn +120   (left)
            \ if b = 1 then         turn 0      (straight ahead)

    = 1, -1, 1, 0, -1, 1, 1, -1, 0, 0, -1, 1, 1, -1, 1, 0, -1, 0, ...
      starting i=1, multiple of 120 degrees

Every third turn is -1.  i-floor(i/3) counts positions with those turns
removed.  Bit above lowest 1-bit on that remaining position is the same as
the dragon curve turn sequence (the full dragon curve, not just its
boundary).  So the terdragon boundary turns are the dragon turns with -1
inserted as every third turn starting from position i=2.

The following diagram illustrates the initial boundary turns.  Boundary
positions 5 and 8 are at the same point since that point is visited twice by
the boundary.

       Rt(8)=-1
       |
    *  v  7  Rt(7)=1
     \   / \
      \8/   \                       right boundary
       *-----6  Rt(6)=1             turn sequence
        \5  Rt(5)=-1
         \
          4  Rt(4)=0
           \
            \
       *-----3   Rt(3)=1
        \2  Rt(2)=-1
         \
    *-----1  Rt(1)=1

The turns can be calculated by considering how the curve replicates.  Take
the turn sequence in two parts Rt and Vt.  This is similar to the boundary
length above but for the turns not the length.

       2-----3        Rt[k] turns from 0 to 1
        \ Vt          Vt[k] turns from 1 to 3
         \
    0-----1           initial Rt[0] = empty
      Rt                      Vt[0] = -1 (a single turn)

The endpoints are not included in the two sequence parts, so the turn at "1"
is not in either part.  The curve expands as follows.

       *-----3        Rt[k+1] = Rt[k], 1, Vt[k]
        \             Vt[k+1] = Rt[k], 0, Vt[k]
         \
    2-----b
     \   / \
      \ /   \
       *-----1
        \
         \
    0-----a

Rt from 0 to 1 becomes an Rt from 0 to "a", followed by the turn +1 at "a",
then a Vt from "a" to 1.  This is the same as in the first diagram an
Rt[k+1] from 0 to 3 comprising Rt[k] from 0 to 1 and Vt[k] from 1 to 3.

Vt from 1 to 3 becomes an Rt from 1 to "b", followed by turn 0 at "b"
(straight ahead), then a Vt from "b" to 1.

Points a, 1, b and 3 are on the right boundary and remain so in further
expansions due to the extents of the curve segments.  Point 2 which was the
inside of the preceding Vt does not remain on the right boundary.

The repeated expansion

    R -> R,1,V
    V -> R,0,V

is per the dragon curve (L<Math::PlanePath::DragonCurve/Turn>) and hence bit
above lowest 1-bit.  Repeated expansions always have R and V alternating
since both expand to an R and a V in that order, but with a different value
in between.

    R _ V _ R _ V _ R _ V _ R _ V

At the final lowest level Rt[0]=empty and Vt[0]=-1.  That Vt[0]=-1 gives the
-1 at every third position.

The way the endpoint "3" is always on the right boundary means that the
successive levels extend each other.  So Rt[k+1] starts with Rt[k] and then
has further turns (turn 1 then Vt[k]).

=head2 Right Boundary Segment N

The curve segment numbers which are on the right boundary are

    RN = N in ternary no digit pair 11, 12 or 20,
         in ascending order

    = decimal  0,1,2,  3, 7, 8,   9, 10, 11,  21, 25, 26,   27,  28,...
    = ternary  0,1,2, 10,21,22, 100,101,102, 210,221,222, 1000,1001,...

For example on segments N=0 to N=8 the boundary segments are as follows.

        8-----9        boundary segments
         \
          \              N   ternary
     6----7,4            0       0
      \   / \            1       1
       \ /   \           2       2
       5,2----3          3      10      (no 11, 12, 20)
         \               7      21
          \              8      22
     0-----1

Some of the boundary points are visited twice.  The boundary segment N is
the N which goes along the boundary.  So the segment 7,4 to 8 is N=7.
Segment 7,4 to 5,2 would be N=4 (and is not on the boundary).

The ternary characterization of the values can be found by a breakdown
similar to the boundary length calculation above.  Take the boundary N
numbers in two parts RN[k] and VN[k] at expansion level k.

        2-----3
         \  VN[1] = 1,2        initial RN[1] and VN[1]
          \
     0-----1
    RN[1] = 0

RN[k] and VN[k] are in the range 0 to 3^k-1 and so can be written with k
many ternary digits.  The curve replicates and adds a new ternary digit as
follows.  Points 1, 3 and 7,4 are always on the boundary and so subsections
can be taken between them.

       8------9
        \
         \            VN[k+1] =   3^k + RN[k],  (3 to 4)
    6----7,4                    2*3^k + VN[k]   (7 to 9)
     \   / \
      \ /   \
      5,2----3        RN[k+1] = RN[k],          (0 to 1)
        \                       VN[k]           (1 to 3)
         \
    0-----1

RN[k+1] gains a high digit 0.  The initial RN[1] is 0 and so RN[k] has a
high digit 0.

VN[k+1] gains a high digit 1 or 2.  The initial VN[k] is digit 1 or 2 and so
all VN[k] have high digit 1 or 2.

RN[k+1] is a 0 above 0 from LN[k] or 1 or 2 from VN[k] and so gives digit
pairs 00, 01 and 02.  VN[k+1] is a 1 above 0 from RN[k] or a 2 above 1 or 2
from VN[k] and so gives digit pairs 10, 21 and 22.  All these digit pairs
occur and the remaining 11, 12 and 20 do not occur.

=head2 Right Boundary Segment N Calculation

Each right boundary segment number RN(i) can be calculated by writing its
index i in a mixed radix representation with a ternary low digit and then
binary above.

      binary   binary        binary   ternary
    +--------+--------+    +--------+--------+
    |   1    |  0or1  |....|  0or1  |  0or2  |
    +--------+--------+    +--------+--------+
    high                                   low

Then consider each digit pair and change the binary 1s as follows.  The
result as ternary digits is RN(i).

    1,nonzero  ->  2,nonzero

Digit pairs include overlaps.  So a run of consecutive 1-bits has all except
the lowest changed,

    1,1,1,1    ->  2,2,2,1

Disallowed pairs "11" and "12" are changed to the allowed "21" and "22".
The disallowed "20" doesn't occur since 2 is only created by the change
procedure above and so cannot have 0 below it.  The change of "12" -E<gt>
"22" only occurs at the lowest digit pair when the mixed radix gives 2 as
the low ternary digit.

The reason this works can be seen by considering what next higher digit is
permitted above a given ternary 0,1,2.

     next        ternary
    higher        digit
    1 or 0   <-     0         cannot 20, can 10 00
    2 or 0   <-     1         cannot 11, can 21 01
    2 or 0   <-     2         cannot 12, can 02 22

So starting from a low ternary 0,1,2 there is always just two choices as to
what should be above it.  Those two are counted by a binary digit.  The
digit choice is always 0 or non=0 so when the change is applied to binary in
ascending order the resulting RN(i) ternary is in ascending order.

=head2 Left Boundary Segment N

The curve segment numbers which are on the left boundary are

    LN = N in ternary no digit pair 02, 10 or 11,
         and most significant digit 1,
         in ascending order

    = decimal  0,1, 5,  15, 16, 17,   45,  46,  50,   51,  52,  53,...
    = ternary  0,1,12, 120,121,122, 1200,1201,1212, 1220,1221,1222,...

The characterization can be made in a similar way to the right boundary
segments above.  Take the boundary N numbers in two parts LN and EN.

                 EN[1]=2
                   2-----3         initial LN[1] and EN[1]
     LN[1] = 0,1    \
                     \
                0-----1

LN[k] and EN[k] are in the range 0 to 3^k-1 and so can be written with k
many ternary digits.  The curve replicates and adds a new ternary digit as
follows.  Points 5,2, 6 and 8 are on the boundary of the replication and so
subsections can be taken between them.

    EN[k+1]   8------9
               \             EN[k+1] = 2*3^k + LN[k],   (6 to 8)
                \                      2*3^k + EN[k]    (8 to 9)
           6----7,4
            \   / \          LN[k+1] =         LN[k],   (0 to 2)
             \ /   \                     3^k + EN[k]    (5 to 6)
    LN[k+1]  5,2----3
               \
                \
           0-----1

EN[k+1] gains a high digit 2.  The initial EN[1] is a high digit 2 and so
all EN have high digit 2.

LN[k+1] gains a 0 above the 0 or 1 from LN[k], and gains a 1 above the high
2 of EN[k].  LN[1] is 0,1 and so LN always has high digit 0 or 1 and highest
non-zero digit always 1.

EN[k+1] is a 2 above either 0 or 1 from LN[k] or 2 from EN[k] and so gives
digit pairs 20, 21 and 22.  LN[k+1] is a 0 above 0 or 1 from LN[k] or a 1
above 2 from EN[k] and so gives digit pairs 00, 01 and 12.  All these digit
pairs occur and the remaining 02, 10 and 11 do not occur.

The repeatedly expanded LN[k] values are the left boundary of the full
curve.  If stopping at a finite expansion k then the EN[k] positions are on
the boundary too.  If continuing then EN[k] is enclosed by the next
expansion level.  To include EN[k] for a finite expansion the rule above is
relaxed to allow high digit 2.

    LN[k],EN[k] left boundary of curve after k expansions
    = N with k many ternary digits and no digit pair 02, 10 or 11,
      in ascending order

Disallowing high digit 2 can also be done by considering values to have 0s
above the most significant and so a high 2 is a digit pair "02" which is to
be excluded.

=head2 Left Boundary Segment N Calculation

Each left boundary segment number LN(i) can be calculated by writing its
index i in a mixed radix representation with a ternary low digit and then
binary above, plus an extra high 0 bit.

               binary   binary        binary   ternary
    +--------+--------+--------+    +--------+--------+
    |   0    |    1   |  0or1  |....|  0or1  |  0or2  |
    +--------+--------+--------+    +--------+--------+
    high                                            low

Then take each binary digit from low to high and apply a transformation as
follows.  The "previous digit" in each case includes the transformation of
that digit.

    previous digit   binary transformed
         0               0->0  1->2
         1               0->0  1->2
         2               0->1  1->2

For example i=8 in the mixed radix is 0102 so apply the transformations

     0102
       ^^  previous digit 2, bit 0, transform bit 0->1
     0112
      ^^   previous digit 1, bit 1, transform bit 1->2
     0212
     ^^    previous digit 2, bit 0, transform bit 0->1
     1212

     final 1212 ternary = 50 so segment N=50

=for Test-Pari 2 + 3*(0 + 2*(1)) == 8

=for Test-Pari 2 + 3*(1 + 3*(2 + 3*(1))) == 50

The transformations correspond to the allowed digit pairs.  The digit above
a 0 can only be 0 or 2.  The digit above a 1 can only be 0 or 2.  The digit
above a 2 can only be 1 or 2.  The low digit can be ternary 0,1,2 and from
that starting point there are two choices at each digit, hence the binary
mixed radix.

=cut

# CHECK-ME:
#
# Fixed-width k digits with the disallow rule ...
#
# The extra high 0-bit has the effect of adding a 1-digit if the high is
# otherwise 2.  Those high 2 values are EN[k].  If EN[k] values are to be
# included, as for a finite expansion to level k, then that high 0-bit should
# be omitted.

=pod

=head2 Shortcut Boundary Length

The turns on the right boundary which are to the right -120 degrees are like

    2-----3       turn -120 at "2"
     \
      \
       1

A shortcut can be taken by a unit step directly from 1 to 3, skipping
point 2.  Doing so gives a boundary from N=0 to N=3^k which is

    Rsh[k] =   2^k       shortcut right side
    Bsh[k] = 2*2^k       shortcut whole boundary

=for Test-Pari-DEFINE  Rsh(k) = 2^k

=for Test-Pari-DEFINE  Bsh(k) = 2*2^k

Every third point starting from N=2 is a -120 degree turn and at each of
those 2 boundary lines become 1 shortcut line

    Rsh[k] = R[k] * 2/3            k >= 1
           = 3*2^(k-1) * 2/3
           = 2^k

=for Test-Pari vector(20, k, Rsh(k)) == vector(20, k, R(k)*2/3)

R[k] is a multiple of 3, so no rounding is required for the 2/3 factor.  The
multiple of 3 also means the last turn in Rt[k] is always a -120 (to be
shortcut across).  The left and right sides are symmetric, so Bsh=2*Rsh.

=head2 Shortcut Boundary Turn Sequence

The shortcut boundary turn sequence is the dragon curve turns but by 60
degrees instead of 90 degrees.

    St(i) = / bit above lowest 1-bit of i
            |   if 0 then  turn +60  (left)
            \   if 1 then  turn -60  (right)

    = 1, 1, -1, 1, 1, -1, -1, 1, 1, 1, -1, -1, 1, -1, -1, 1, 1, 1, ...
      starting i=1, multiple of 60 degrees

The shortcut eliminates the -120 degree turns from the right boundary turn
sequence.  The following diagram shows a a -120 at s and preceding turn P
and following turn Q.

            \
       s-----Q
        \
         \                  = 1, 0   (at "*" and "a")
       ---P

The turns at P and Q are either 0 or +120 degrees.  The effect of skipping s
and going straight across from P to Q is that the turn at P is -60 degrees
of whatever its value was, and the same for Q -60 degrees of whatever its
value was.  So the turns 0 and +120 in the right boundary sequence become
-60 or +60.

=head2 Shortcut Area

The area enclosed by the shortcut boundary can be calculated from the plain
curve area plus the extra triangles enclosed by B[k]/3 many shortcuts,

   Ash[k] = A[k] + floor(B[k]/3)
          = / 0          if k=0
            \ 2*3^(k-1)  if k>=1

=for Test-Pari-DEFINE  Ash(k) = if(k==0, 0, 2*3^(k-1))

=for Test-Pari-DEFINE  Ash_from_AB(k) = A(k) + floor(B(k)/3)

=for Test-Pari vector(20, k, Ash(k-1)) == vector(20, k, Ash_from_AB(k-1))

=cut

# Ash[k] = 2*(3^(k-1) - 2^(k-1))  +  3*2^k/3
#        = 2*3^(k-1) - 2*2^(k-1)  +  2*2^(k-1)
#        = 2*3^(k-1)
# Pari: (Ash(k) = 2*3^(k-1)); for(k=0,8,print1(Ash(k),", "))
#
# 3*Ash(k)+Bsh(k) = 3*2*3^(k-1) + 2*2^k
#                 = 2*3^k + 2*2^k
#                 = 2*3^k

=pod

The "floor" is only needed for k=0 single line segment case.  B[0]=2 and by
rounding down 2/3 nothing is added to A[0]=0.  For kE<gt>=1 B[k] is a
multiple of 3.

The shortcut area and boundary continue to satisfy the 2N=3A+B relation
given in L</Area from Boundary> above.  That relation requires each unit
area to have all three of its sides traversed and that is so with the
shortcuts.

    Bshortcuts(k) = floor(B(k)/3)      # extra shortcuts
    Nsh(k) = 3^k + Bshortcuts(k)       # total incl shortcuts

    2*Nsh(k) = 3*Ash(k) + Bsh(k)

=for Test-Pari-DEFINE  Bshortcuts(k) = floor(B(k)/3)

=for Test-Pari-DEFINE  Nsh(k) = 3^k + Bshortcuts(k)

=for Test-Pari vector(20, k, 2*Nsh(k -1)) == vector(20, k, 3*Ash(k -1)+Bsh(k -1))

=head1 OEIS

The terdragon is in Sloane's Online Encyclopedia of Integer Sequences as,

=over

L<http://oeis.org/A080846> (etc)

=back

    A080846   next turn 0=left,1=right, by 120 degrees
                (n=0 is turn at N=1)

    A060236   turn 1=left,2=right, by 120 degrees
                (lowest non-zero ternary digit)
    A137893   turn 1=left,0=right (morphism)
    A189640   turn 0=left,1=right (morphism, extra initial 0)
    A189673   turn 1=left,0=right (morphism, extra initial 0)
    A038502   strip trailing ternary 0s,
                taken mod 3 is turn 1=left,2=right

A189673 and A026179 start with extra initial values arising from their
morphism definition.  That can be skipped to consider the turns starting
with a left turn at N=1.

    A026225   N positions of left turns,
                being (3*i+1)*3^j so lowest non-zero digit is a 1
    A026179   N positions of right turns (except initial 1)
    A060032   bignum turns 1=left,2=right to 3^level

    A062756   total turn, count ternary 1s
    A005823   N positions where total turn == 0, ternary no 1s

    A111286   boundary length, N=0 to N=3^k, skip initial 1
    A003945   boundary/2
    A002023   boundary odd levels N=0 to N=3^(2k+1),
              or even levels one side N=0 to N=3^(2k),
                being 6*4^k
    A164346   boundary even levels N=0 to N=3^(2k),
              or one side, odd levels, N=0 to N=3^(2k+1),
                being 3*4^k
    A042950   V[k] boundary length

    A056182   area enclosed N=0 to N=3^k, being 2*(3^k-2^k)
    A081956     same
    A118004   1/2 area N=0 to N=3^(2k+1), odd levels, 9^n-4^n
    A155559   join area, being 0 then 2^k

    A092236   count East segments N=0 to N=3^k
    A135254   count North-West segments N=0 to N=3^k, extra 0
    A133474   count South-West segments N=0 to N=3^k
    A057083   count segments diff from 3^(k-1)

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::TerdragonRounded>,
L<Math::PlanePath::TerdragonMidpoint>,
L<Math::PlanePath::GosperSide>

L<Math::PlanePath::DragonCurve>,
L<Math::PlanePath::R5DragonCurve>

Larry Riddle's Terdragon page, for boundary and area calculations of the
terdragon as an infinite fractal
L<http://ecademy.agnesscott.edu/~lriddle/ifs/heighway/terdragon.htm>

=head1 HOME PAGE

L<http://user42.tuxfamily.org/math-planepath/index.html>

=head1 LICENSE

Copyright 2011, 2012, 2013, 2014 Kevin Ryde

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
