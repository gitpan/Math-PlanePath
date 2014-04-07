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


# math-image --path=DragonCurve --lines --scale=20
# math-image --path=DragonCurve --all --scale=10
# math-image --path=DragonCurve --output=numbers_dash
#
# Harter first to show copies of the dragon fit together ...
#
# cf A088431 run lengths of dragon turns
#    A007400 cont frac 1/2^1 + 1/2^2 + 1/2^4 + 1/2^8 + ... 1/2^(2^n)
#            = 0.8164215090218931...
#    2,4,6 values
#    a(0)=0,
#    a(1)=1,
#    a(2)=4,
#    a(8n) = a(8n+3) = 2,
#    a(8n+4) = a(8n+7) = a(16n+5) = a(16n+14) = 4,
#    a(16n+6) = a(16n+13) = 6,
#    a(8n+1) = a(4n+1),
#    a(8n+2) = a(4n+2)
#
#    A060833 not adding to 2^k+2,
#            superset of positions of left turns ...
#
#    A166242 double or half according to dragon turn

#
# connection points
#   N = 26 = 11010
#     = 27 = 11011
#   N = 51 = 110011 = (3*16^k-1)/15 -> 1/5
#     = 52 = 110100
#   N = 101 = 1100101
#     = 102 = 1100110 = 2*(3*16^k-1)/15 -> 2/5
#   N


# Martin Gardner, "The Dragon Curve and Other Problems (Mathematical
# Games)", Scientific American, March 1967 (addenda from readers April and
# July).
#
# Reprinted in "Mathematical Magic Show", 1978.

# Chandler Davis and Donald Knuth,
# "Number Representations and Dragon Curves - I", C. Davis & D. E. Knuth,
# Journal Recreational Math., volume 3, number 2 (April 1970), pages 66-81.
# 16 pages
#
# Chandler Davis and Donald Knuth,
# "Number Representations and Dragon Curves - II", C. Davis & D. E. Knuth,
# Journal Recreational Math., volume 3, number 3 (July 1970), pages 133-149.
# 17 pages
#
# Revised in "Selected Papers on Fun and Games", 2010, pages 571-603 with
# addendum pages 603-614.
# http://trove.nla.gov.au/version/50039930
# 32+12=44 pages

# Sze-Man Ngai and Nhu Nguyen, "The Heighway Dragon Revisited", Discrete and
# Computational Geometry, May 2003 volume 29, issue 4, pages 603-623
# http://www.math.nmsu.edu/~nnguyen/23paper.ps

package Math::PlanePath::DragonCurve;
use 5.004;
use strict;
use List::Util 'min'; # 'max'
*max = \&Math::PlanePath::_max;

use vars '$VERSION', '@ISA';
$VERSION = 115;
use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_divrem_mutate = \&Math::PlanePath::_divrem_mutate;

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'round_down_pow',
  'bit_split_lowtohigh',
  'digit_split_lowtohigh';
use Math::PlanePath::DragonMidpoint;

# uncomment this to run the ### lines
# use Smart::Comments;



use constant n_start => 0;

use constant parameter_info_array => [ { name      => 'arms',
                                         share_key => 'arms_4',
                                         display   => 'Arms',
                                         type      => 'integer',
                                         minimum   => 1,
                                         maximum   => 4,
                                         default   => 1,
                                         width     => 1,
                                         description => 'Arms',
                                       } ];

{
  my @_UNDOCUMENTED__x_negative_at_n = (undef, 5,5,5,6);
  sub _UNDOCUMENTED__x_negative_at_n {
    my ($self) = @_;
    return $_UNDOCUMENTED__x_negative_at_n[$self->{'arms'}];
  }
}
{
  my @_UNDOCUMENTED__y_negative_at_n = (undef, 14,11,8,7);
  sub _UNDOCUMENTED__y_negative_at_n {
    my ($self) = @_;
    return $_UNDOCUMENTED__y_negative_at_n[$self->{'arms'}];
  }
}
use constant dx_minimum => -1;
use constant dx_maximum => 1;
use constant dy_minimum => -1;
use constant dy_maximum => 1;

*_UNDOCUMENTED__dxdy_list = \&Math::PlanePath::_UNDOCUMENTED__dxdy_list_four;
{
  my @_UNDOCUMENTED__dxdy_list_at_n = (undef, 5, 5, 5, 3);
  sub _UNDOCUMENTED__dxdy_list_at_n {
    my ($self) = @_;
    return $_UNDOCUMENTED__dxdy_list_at_n[$self->{'arms'}];
  }
}
use constant dsumxy_minimum => -1; # straight only
use constant dsumxy_maximum => 1;
use constant ddiffxy_minimum => -1;
use constant ddiffxy_maximum => 1;
use constant dir_maximum_dxdy => (0,-1); # South


#------------------------------------------------------------------------------

sub new {
  my $self = shift->SUPER::new(@_);
  $self->{'arms'} = max(1, min(4, $self->{'arms'} || 1));
  return $self;
}

{
  # sub state_string {
  #   my ($state) = @_;
  #   my $digit = $state & 3;  $state >>= 2;
  #   my $rot = $state & 3;  $state >>= 2;
  #   my $rev = $state & 1;  $state >>= 1;
  #   return "rot=$rot rev=$rev (digit=$digit)";
  # }

  # generated by tools/dragon-curve-table.pl
  # next_state length 32
  my @next_state = (12,16, 4,16,  0,20, 8,20,  4,24,12,24,  8,28, 0,28,
                    0,20, 0,28,  4,24, 4,16,  8,28, 8,20, 12,16,12,24);
  my @digit_to_x = ( 0, 0, 1, 1,  0, 1, 1, 0,  0, 0,-1,-1,  0,-1,-1, 0,
                     0, 1, 1, 2,  0, 0,-1,-1,  0,-1,-1,-2,  0, 0, 1, 1);
  my @digit_to_y = ( 0,-1,-1, 0,  0, 0, 1, 1,  0, 1, 1, 0,  0, 0,-1,-1,
                     0, 0, 1, 1,  0, 1, 1, 2,  0, 0,-1,-1,  0,-1,-1,-2);
  my @digit_to_dxdy = ( 1, 0,undef,undef,  0, 1,undef,undef, -1, 0,undef,undef,  0,-1,undef,undef,
                        1, 0,undef,undef,  0, 1,undef,undef, -1, 0,undef,undef,  0,-1);

  sub n_to_xy {
    my ($self, $n) = @_;
    ### DragonCurve n_to_xy(): $n

    if ($n < 0) { return; }
    if (is_infinite($n)) { return ($n, $n); }

    my $int = int($n);      # integer part
    $n -= $int;             # $n = fraction part
    my $zero = ($int * 0);  # inherit bignum 0

    my $arm = _divrem_mutate ($int, $self->{'arms'});
    my @digits = digit_split_lowtohigh($int,4);
    ### @digits

    # initial state from rotation by arm and number of digits
    my $state = ((scalar(@digits) + $arm) & 3) << 2;

    my $len = (2+$zero) ** $#digits;
    my $x = $zero;
    my $y = $zero;
    foreach my $digit (reverse @digits) {  # high to low
      ### at: "x=$x,y=$y  len=$len digit=$digit state=$state"
      # ### state is: state_string($state)

      $state += $digit;
      $x += $len * $digit_to_x[$state];
      $y += $len * $digit_to_y[$state];
      $state = $next_state[$state];
      $len /= 2;
    }

    ### final: "x=$x y=$y  state=$state"
    # ### state is: state_string($state)
    ### final: "frac dx=$digit_to_dxdy[$state], dy=$digit_to_dxdy[$state+1]"

    return ($n * $digit_to_dxdy[$state] + $x,
            $n * $digit_to_dxdy[$state+1] + $y);
  }
}


{
  # generated by tools/dragon-curve-dxdy.pl
  # next_state length 32
  my @next_state = ( 0, 6,20, 2,  4,10,24, 6,  8,14,28,10, 12, 2,16,14,
                     0,22,20,18,  4,26,24,22,  8,30,28,26, 12,18,16,30);
  my @state_to_dxdy = ( 1, 0,-1, 1,  0, 1,-1,-1, -1, 0, 1,-1,  0,-1, 1, 1,
                        1, 0,-1,-1,  0, 1, 1,-1, -1, 0, 1, 1,  0,-1,-1, 1);

  sub n_to_dxdy {
    my ($self, $n) = @_;
    ### n_to_dxdy(): $n

    my $int = int($n);
    $n -= $int;  # $n fraction part
    ### $int
    ### $n

    my $state = 4 * _divrem_mutate ($int, $self->{'arms'});
    ### arm as initial state: $state

    foreach my $bit (reverse bit_split_lowtohigh($int)) {  # high to low
      $state = $next_state[$state + $bit];
    }
    $state &= 0x1C;  # mask out "prevbit" from state, leaving state==0 mod 4

    ### final state: $state
    ### dx: $state_to_dxdy[$state]
    ### dy: $state_to_dxdy[$state+1],
    ### frac dx: $state_to_dxdy[$state+2],
    ### frac dy: $state_to_dxdy[$state+3],

    return ($state_to_dxdy[$state]   + $n * $state_to_dxdy[$state+2],
            $state_to_dxdy[$state+1] + $n * $state_to_dxdy[$state+3]);
  }
}

# point N=2^(2k) at XorY=+/-2^k  radius 2^k
#       N=2^(2k-1) at X=Y=+/-2^(k-1) radius sqrt(2)*2^(k-1)
# radius = sqrt(2^level)
# R(l)-R(l-1) = sqrt(2^level) - sqrt(2^(level-1))
#             = sqrt(2^level) * (1 - 1/sqrt(2))
# about 0.29289
#
my @try_dx = (0,0,-1,-1);
my @try_dy = (0,1,1,0);

sub xy_to_n {
  return scalar((shift->xy_to_n_list(@_))[0]);
}
sub xy_to_n_list {
  my ($self, $x, $y) = @_;
  ### DragonCurve xy_to_n(): "$x, $y"

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

  my @n_list;
  my $xm = $x+$y;  # rotate -45 and mul sqrt(2)
  my $ym = $y-$x;
  foreach my $dx (0,-1) {
    foreach my $dy (0,1) {
      my $t = $self->Math::PlanePath::DragonMidpoint::xy_to_n
        ($xm+$dx, $ym+$dy);
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

sub xy_is_visited {
  my ($self, $x, $y) = @_;

  my $arms_count = $self->{'arms'};
  if ($arms_count == 4) {
    # yes, whole plane visited
    return 1;
  }

  my $xm = $x+$y;
  my $ym = $y-$x;
  {
    my $arm = Math::PlanePath::DragonMidpoint::_xy_to_arm($xm,$ym);
    if ($arm < $arms_count) {
      # yes, segment $xm,$ym is on the desired arms
      return 1;
    }
    if ($arm == 2 && $arms_count == 1) {
      # no, segment $xm,$ym is on arm 2, which means its opposite is only on
      # arm 1,2,3 not arm 0 so arms_count==1 cannot be visited
      return 0;
    }
  }
  return (Math::PlanePath::DragonMidpoint::_xy_to_arm($xm-1,$ym+1)
          < $arms_count);
}


#------------------------------------------------------------------------------

# f = (1 - 1/sqrt(2) = .292
# 1/f = 3.41
# N = 2^level
# Rend = sqrt(2)^level
# Rmin = Rend / 2  maybe
# Rmin^2 = (2^level)/4
# N = 4 * Rmin^2
#
# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### DragonCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"
  my $xmax = int(max(abs($x1),abs($x2)));
  my $ymax = int(max(abs($y1),abs($y2)));
  return (0,
          $self->{'arms'} * ($xmax*$xmax + $ymax*$ymax + 1) * 7);
}

# Not quite right yet ...
#
# sub rect_to_n_range {
#   my ($self, $x1,$y1, $x2,$y2) = @_;
#   ### DragonCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"
#
#
#    my ($length, $level_limit) = round_down_pow
#      ((max(abs($x1),abs($x2))**2 + max(abs($y1),abs($y2))**2 + 1) * 7,
#       2);
#    $level_limit += 2;
#    ### $level_limit
#
#    if (is_infinite($level_limit)) {
#      return ($level_limit,$level_limit);
#    }
#
#    $x1 = round_nearest ($x1);
#    $y1 = round_nearest ($y1);
#    $x2 = round_nearest ($x2);
#    $y2 = round_nearest ($y2);
#    ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
#    ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
#    ### sorted range: "$x1,$y1  $x2,$y2"
#
#
#    my @xend = (0, 1);
#    my @yend = (0, 0);
#    my @xmin = (0, 0);
#    my @xmax = (0, 1);
#    my @ymin = (0, 0);
#    my @ymax = (0, 0);
#    my @sidemax = (0, 1);
#    my $extend = sub {
#      my ($i) = @_;
#      ### extend(): $i
#      while ($i >= $#xend) {
#        ### extend from: $#xend
#        my $xend = $xend[-1];
#        my $yend = $yend[-1];
#        ($xend,$yend) = ($xend-$yend,  # rotate +45
#                         $xend+$yend);
#        push @xend, $xend;
#        push @yend, $yend;
#        my $xmax = $xmax[-1];
#        my $xmin = $xmin[-1];
#        my $ymax = $ymax[-1];
#        my $ymin = $ymin[-1];
#        ### assert: $xmax >= $xmin
#        ### assert: $ymax >= $ymin
#
#        #    ### at: "end=$xend,$yend   $xmin..$xmax  $ymin..$ymax"
#        push @xmax, max($xmax, $xend + $ymax);
#        push @xmin, min($xmin, $xend + $ymin);
#
#        push @ymax, max($ymax, $yend - $xmin);
#        push @ymin, min($ymin, $yend - $xmax);
#
#        push @sidemax, max ($xmax[-1], -$xmin[-1],
#                             $ymax[-1], -$ymin[-1],
#                             abs($xend),
#                             abs($yend));
#      }
#      ### @sidemax
#    };
#
#    my $rect_dist = sub {
#      my ($x,$y) = @_;
#      my $xd = ($x < $x1 ? $x1 - $x
#                : $x > $x2 ? $x - $x2
#                : 0);
#      my $yd = ($y < $y1 ? $y1 - $y
#                : $y > $y2 ? $y - $y2
#                : 0);
#      return max($xd,$yd);
#    };
#
#    my $arms = $self->{'arms'};
#    ### $arms
#    my $n_lo;
#    {
#      my $top = 0;
#      for (;;) {
#      ARM_LO: foreach my $arm (0 .. $arms-1) {
#          my $i = 0;
#          my @digits;
#          if ($top > 0) {
#            @digits = ((0)x($top-1), 1);
#          } else {
#            @digits = (0);
#          }
#
#          for (;;) {
#            my $n = 0;
#            foreach my $digit (reverse @digits) { # high to low
#              $n = 2*$n + $digit;
#            }
#            $n = $n*$arms + $arm;
#            my ($nx,$ny) = $self->n_to_xy($n);
#            my $nh = &$rect_dist ($nx,$ny);
#
#            ### lo consider: "i=$i  digits=".join(',',reverse @digits)."  is n=$n xy=$nx,$ny nh=$nh"
#
#            if ($i == 0 && $nh == 0) {
#              ### lo found inside: $n
#              if (! defined $n_lo || $n < $n_lo) {
#                $n_lo = $n;
#              }
#              next ARM_LO;
#            }
#
#            if ($i == 0 || $nh > $sidemax[$i+2]) {
#              ### too far away: "nxy=$nx,$ny   nh=$nh vs ".$sidemax[$i+2]." at i=$i"
#
#              while (++$digits[$i] > 1) {
#                $digits[$i] = 0;
#                if (++$i <= $top) {
#                  ### backtrack up ...
#                } else {
#                  ### not found within this top and arm, next arm ...
#                  next ARM_LO;
#                }
#              }
#            } else {
#              ### lo descend ...
#              ### assert: $i > 0
#              $i--;
#              $digits[$i] = 0;
#            }
#          }
#        }
#
#        # if an $n_lo was found on any arm within this $top then done
#        if (defined $n_lo) {
#          last;
#        }
#
#        ### lo extend top ...
#        if (++$top > $level_limit) {
#          ### nothing below level limit ...
#          return (1,0);
#        }
#        &$extend($top+3);
#      }
#    }
#
#    my $n_hi = 0;
#   ARM_HI: foreach my $arm (reverse 0 .. $arms-1) {
#      &$extend($level_limit+2);
#      my @digits = ((1) x $level_limit);
#      my $i = $#digits;
#      for (;;) {
#        my $n = 0;
#        foreach my $digit (reverse @digits) { # high to low
#          $n = 2*$n + $digit;
#        }
#
#        $n = $n*$arms + $arm;
#        my ($nx,$ny) = $self->n_to_xy($n);
#        my $nh = &$rect_dist ($nx,$ny);
#
#        ### hi consider: "arm=$arm  i=$i  digits=".join(',',reverse @digits)."  is n=$n xy=$nx,$ny nh=$nh"
#
#        if ($i == 0 && $nh == 0) {
#          ### hi found inside: $n
#          if ($n > $n_hi) {
#            $n_hi = $n;
#            next ARM_HI;
#          }
#        }
#
#        if ($i == 0 || $nh > $sidemax[$i+2]) {
#          ### too far away: "$nx,$ny   nh=$nh vs ".$sidemax[$i+2]." at i=$i"
#
#          while (--$digits[$i] < 0) {
#            $digits[$i] = 1;
#            if (++$i < $level_limit) {
#              ### hi backtrack up ...
#            } else {
#              ### hi nothing within level limit for this arm ...
#              next ARM_HI;
#            }
#          }
#
#        } else {
#          ### hi descend
#          ### assert: $i > 0
#          $i--;
#          $digits[$i] = 1;
#        }
#      }
#    }
#
#    if ($n_hi == 0) {
#      ### oops, lo found but hi not found
#      $n_hi = $n_lo;
#    }
#
#    return ($n_lo, $n_hi);
# }


#------------------------------------------------------------------------------

{
  my @_UNDOCUMENTED_level_to_left_line_boundary = (1,2,4);
  sub _UNDOCUMENTED_level_to_left_line_boundary {
    my ($self, $level) = @_;
    if ($level < 0) { return undef; }
    if ($level <= 2) { return $_UNDOCUMENTED_level_to_left_line_boundary[$level]; }
    if (is_infinite($level)) { return $level; }

    my $l0 = 2;
    my $l1 = 4;
    my $l2 = 8;
    foreach (4 .. $level) {
      ($l2,$l1,$l0) = ($l2 + 2*$l0, $l2, $l1);
    }
    return $l2;
  }
}

{
  my @level_to_right_line_boundary = (1,2,4,8,undef);
  sub _UNDOCUMENTED_level_to_right_line_boundary {
    my ($self, $level) = @_;
    if ($level < 0) { return undef; }
    if ($level <= 3) { return $level_to_right_line_boundary[$level]; }
    if (is_infinite($level)) { return $level; }

    my $r0 =  2;
    my $r1 =  4;
    my $r2 =  8;
    my $r3 = 16;
    foreach (5 .. $level) {
      ($r3,$r2,$r1,$r0) = (2*$r3 - $r2 + 2*$r1 - 2*$r0,  $r3, $r2, $r1);
    }
    return $r3;
  }
}
sub _UNDOCUMENTED_level_to_line_boundary {
  my ($self, $level) = @_;
  if ($level < 0) { return undef; }
  return $self->_UNDOCUMENTED_level_to_right_line_boundary($level+1);
}

sub _UNDOCUMENTED_level_to_u_left_line_boundary {
  my ($self, $level) = @_;
  if ($level < 0) { return undef; }
  return ($level == 0 ? 3
          : $self->_UNDOCUMENTED_level_to_right_line_boundary($level) + 4);
}
sub _UNDOCUMENTED_level_to_u_right_line_boundary {
  my ($self, $level) = @_;
  if ($level < 0) { return undef; }
  return ($self->_UNDOCUMENTED_level_to_right_line_boundary($level)
          + $self->_UNDOCUMENTED_level_to_right_line_boundary($level+1));
}
sub _UNDOCUMENTED_level_to_u_line_boundary {
  my ($self, $level) = @_;
  if ($level < 0) { return undef; }
  return ($self->_UNDOCUMENTED_level_to_u_left_line_boundary($level)
          + $self->_UNDOCUMENTED_level_to_u_right_line_boundary($level));
}

sub _UNDOCUMENTED_level_to_enclosed_area {
  my ($self, $level) = @_;
  # A[k] = 2^(k-1) - B[k]/4
  if ($level < 0) { return undef; }
  if ($level == 0) { return 0; } # avoid 2**(-1)
  return 2**($level-1) - $self->_UNDOCUMENTED_level_to_line_boundary($level) / 4;
}
*_UNDOCUMENTED_level_to_doubled_points = \&_UNDOCUMENTED_level_to_enclosed_area;

{
  my @_UNDOCUMENTED_level_to_single_points = (2,3,5);
  sub _UNDOCUMENTED_level_to_single_points {
    my ($self, $level) = @_;
    if ($level < 0) { return undef; }
    if ($level <= 2) { return $_UNDOCUMENTED_level_to_single_points[$level]; }
    if (is_infinite($level)) { return $level; }

    my $l0 = 3;
    my $l1 = 5;
    my $l2 = 9;
    foreach (4 .. $level) {
      ($l2,$l1,$l0) = ($l2 + 2*$l0, $l2, $l1);
    }
    return $l2;
  }
}

{
  my @_UNDOCUMENTED_level_to_enclosed_area_join = (0,0,0,1);
  sub _UNDOCUMENTED_level_to_enclosed_area_join {
    my ($self, $level) = @_;
    if ($level < 0) { return undef; }
    if ($level <= 3) { return $_UNDOCUMENTED_level_to_enclosed_area_join[$level]; }
    if (is_infinite($level)) { return $level; }

    my ($j0,$j1,$j2,$j3) = @_UNDOCUMENTED_level_to_enclosed_area_join;
    $j3 += $level*0;
    foreach (4 .. $level) {
      ($j3,$j2,$j1,$j0) = (2*$j3 - $j2 + 2*$j1 - 2*$j0,  $j3, $j2, $j1);
    }
    return $j3;
  }
}

#------------------------------------------------------------------------------
# points visited

{
  my @_UNDOCUMENTED_level_to_visited = (2, 3, 5, 9, 16);
  sub _UNDOCUMENTED_level_to_visited {
    my ($self, $level) = @_;

    if ($level < 0) { return undef; }
    if ($level <= $#_UNDOCUMENTED_level_to_visited) { return $_UNDOCUMENTED_level_to_visited[$level]; }
    if (is_infinite($level)) { return $level; }

    my ($p0,$p1,$p2,$p3,$p4) = @_UNDOCUMENTED_level_to_visited;
    foreach (5 .. $level) {
      ($p4,$p3,$p2,$p1,$p0) = (4*$p4 - 5*$p3 + 4*$p2 - 6*$p1 + 4*$p0,  $p4, $p3, $p2, $p1);
    }
    return $p4;
  }
}

1;
__END__


#------------------------------------------------------------------------------

# n_to_xy() old code based on i+1 multiply up.
#
# my @dir4_to_dx = (1,0,-1,0);
# my @dir4_to_dy = (0,1,0,-1);
#
# sub n_to_xy {
#   my ($self, $n) = @_;
#   ### DragonCurve n_to_xy(): $n
#
#   if ($n < 0) { return; }
#   if (is_infinite($n)) { return ($n, $n); }
#
#   my $int = int($n);   # integer part
#   $n -= $int;          # fraction part
#   my $zero = ($int * 0);  # inherit bignum 0
#
#   # arm as initial rotation
#   my $rot = _divrem_mutate ($int, $self->{'arms'});
#
#   my @digits = bit_split_lowtohigh($int);
#   ### @digits
#
#   my @sx;
#   my @sy;
#   {
#     my $sy = $zero;     # inherit BigInt 0
#     my $sx = $zero + 1; # inherit BigInt 1
#     ### $sx
#     ### $sy
#
#     foreach (@digits) {
#       push @sx, $sx;
#       push @sy, $sy;
#       # (sx,sy) + rot+90(sx,sy), is multiply (i+1)
#       ($sx,$sy) = ($sx - $sy,
#                    $sy + $sx);
#     }
#   }
#
#   my $rev = 0;
#   my $x = $zero;
#   my $y = $zero;
#   while (defined (my $digit = pop @digits)) {  # high to low
#     my $sx = pop @sx;
#     my $sy = pop @sy;
#     ### at: "$x,$y  $digit   side $sx,$sy"
#     ### $rot
#
#     if ($rot & 2) {
#       ($sx,$sy) = (-$sx,-$sy);
#     }
#     if ($rot & 1) {
#       ($sx,$sy) = (-$sy,$sx);
#     }
#
#     if ($rev) {
#       if ($digit) {
#         $x -= $sy;
#         $y += $sx;
#         ### rev add to: "$x,$y next is still rev"
#       } else {
#         $rot ++;
#         $rev = 0;
#       }
#     } else {
#       if ($digit) {
#         $rot ++;
#         $x += $sx;
#         $y += $sy;
#         $rev = 1;
#         ### add to: "$x,$y next is rev"
#       }
#     }
#   }
#
#   $rot &= 3;
#   $x = $n * $dir4_to_dx[$rot] + $x;
#   $y = $n * $dir4_to_dy[$rot] + $y;
#
#   ### final: "$x,$y"
#   return ($x,$y);
# }

# n_to_dxdy() by separate direction and frac next turn.
#
# my @dir4_to_dx = (1,0,-1,0);
# my @dir4_to_dy = (0,1,0,-1);
#
# sub n_to_dxdy {
#   my ($self, $n) = @_;
#   ### n_to_dxdy(): $n
#
#   my $int = int($n);
#   $n -= $int;  # $n fraction part
#   ### $int
#   ### $n
#
#   my $dir = _divrem_mutate ($int, $self->{'arms'});
#   ### arm as initial dir: $dir
#
#   my @digits = bit_split_lowtohigh($int);
#   ### @digits
#
#   my $prev = 0;
#   foreach my $digit (reverse @digits) {
#     $dir += ($digit != $prev);
#     $prev = $digit;
#   }
#   $dir &= 3;
#   my $dx = $dir4_to_dx[$dir];
#   my $dy = $dir4_to_dy[$dir];
#   ### $dx
#   ### $dy
#
#   if ($n) {
#     ### apply fraction part: $n
#
#     # maybe:
#     # +/- $n as dx or dy
#     # +/- (1-$n) as other dy or dx
#
#     # strip any low 1-bits, and the 0-bit above them
#     while (shift @digits) { }
#
#     $dir += ($digits[0] ? -1 : 1); # bit above lowest 0-bit, 1=right,0=left
#     $dir &= 3;
#     $dx += $n*($dir4_to_dx[$dir] - $dx);
#     $dy += $n*($dir4_to_dy[$dir] - $dy);
#
#     # my $sign = ($digits[0] ? 1 : -1); # bit above lowest 0-bit
#     # ($dx,$dy) = ($dx - $n*($dx - $sign*$dy),
#     #              $dy - $n*($dy + $sign*$dx));
#
#     # my ($next_dx, $next_dy);
#     # if ($digits[0]) {   # bit above lowest 0-bit
#     #   # right
#     #   $next_dx = $dy;
#     #   $next_dy = -$dx;
#     # } else {
#     #   # left
#     #   $next_dx = -$dy;
#     #   $next_dy = $dx;
#     # }
#     # ### $next_dx
#     # ### $next_dy
#     #
#     # $dx += $n*($next_dx - $dx);
#     # $dy += $n*($next_dy - $dy);
#   }
#
#   ### result: "$dx, $dy"
#   return ($dx,$dy);
# }

#------------------------------------------------------------------------------

=for stopwords eg Ryde Dragon Math-PlanePath Heighway Harter et al vertices doublings OEIS Online Jorg Arndt fxtbook versa Nlevel Nlevel-1 Xlevel,Ylevel lengthways Lmax Lmin Wmin Wmax Ns Shallit Kmosek Seminumerical dX,dY bitwise lookup dx dy ie Xmid,Ymid

=head1 NAME

Math::PlanePath::DragonCurve -- dragon curve

=head1 SYNOPSIS

 use Math::PlanePath::DragonCurve;
 my $path = Math::PlanePath::DragonCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is the dragon or paper folding curve by Heighway, Harter, et al.

=cut

# math-image --path=DragonCurve --all --output=numbers_dash --size=70x30

=pod

                 9----8    5---4               2
                 |    |    |   |
                10--11,7---6   3---2           1
                      |            |
      17---16   13---12        0---1       <- Y=0
       |    |    |
      18-19,15-14,22-23                       -1
            |    |    |
           20--21,25-24                       -2
                 |
                26---27                       -3
                      |
         --32   29---28                       -4
            |    |
           31---30                            -5

       ^    ^    ^    ^    ^   ^   ^
      -5   -4   -3   -2   -1  X=0  1 ...

The curve visits "inside" X,Y points twice.  The first of these is X=-2,Y=1
which is N=7 and also N=11.  The segments N=6,7,8 and N=10,11,12 have
touched, but the path doesn't cross itself.  The doubled vertices are all
like this, touching but not crossing and no edges repeating.

=head2 Arms

The curve fills a quarter of the plane and four copies mesh together
perfectly when rotated by 90, 180 and 270 degrees.  The C<arms> parameter
can choose 1 to 4 curve arms successively advancing.

For example arms=4 begins as follows, with N=0,4,8,12,etc being the first
arm, N=1,5,9,13 the second, N=2,6,10,14 the third and N=3,7,11,15 the
fourth.

    arms => 4

            20 ------ 16
                       |
             9 ------5/12 -----  8       23
             |         |         |        |
    17 --- 13/6 --- 0/1/2/3 --- 4/15 --- 19
     |       |         |         |
    21      10 ----- 14/7 ----- 11
                       |
                      18 ------ 22

With four arms every X,Y point is visited twice (except the origin 0,0 where
all four begin) and every edge between the points is traversed once.

=head2 Level Angle

The first step N=1 is to the right along the X axis and the path then slowly
spirals anti-clockwise and progressively fatter.  The end of each
replication is N=2^level which is at level*45 degrees around,

    N       X,Y     angle   radial dist
   ----    -----    -----   -----------
     1      1,0        0         1
     2      1,1       45       sqrt(2)
     4      0,2       90       sqrt(4)=2
     8     -2,2      135       sqrt(8)
    16     -4,0      180       sqrt(16)=4
    32     -4,-4     225       sqrt(32)
   ...

Here's points N=0 to N=2^9=512.  "0" is the origin and "+" is N=512.  Notice
it's spiralled around full-circle to angle 45 degrees up again, like the
initial N=2.

                                    * *     * *
                                  * * *   * * *
                                  * * * * * * * * *
                                  * * * * * * * * *
                            * *   * * * *       * *
                          * * *   * * * *     + * *
                          * * * * * *         * *
                          * * * * * * *
                          * * * * * * * *
                              * * * * * *
                              * * * *
                                  * * * * * * *
                            * *   * * * * * * * *
                          * * *   * * * * * * * *
                          * * * * * * * * * *
                          * * * * * * * * * * * * * * *
                          * * * * * * * * * * * * * * * *
                              * * * * * * * * * * * * * *
                              * * * * * * * * * * * *
        * * * *                   * * * * * * * * * * *
        * * * * *           * *   * * * *       * * * * *
    * * * *   0 *         * * *   * * * *   * * * * * * *
    * * * *               * * * * * *       * * * * *
      * * *               * * * * * * *       * * * *
        * * * *     * *   * * * * * * * *
    * * * * * *   * * *   * * * * * * * *
    * * * * * * * * * * * * * * * * *
      * * * * * * * * * * * * * * * * *
                * * * * *       * * * * *
            * * * * * * *   * * * * * * *
            * * * * *       * * * * *
              * * * *         * * * *

At a power of two Nlevel=2^level for N=2 or higher, the curve always goes
upward from Nlevel-1 to Nlevel, and then goes to the left for Nlevel+1.  For
example at N=16 the curve goes up N=15 to N=16, then left for N=16 to N=17.
Likewise at N=32, etc.  The spiral curls around ever further but the
self-similar twist back means the Nlevel endpoint is always at this same
up/left orientation.  See L</Total Turn> below for the net direction in
general.

=head2 Level Ranges

The X,Y extents of the path through to Nlevel=2^level can be expressed as a
"length" in the direction of the Xlevel,Ylevel endpoint and a "width"
across.

    level even, so endpoint is a straight line
    k = level/2

       +--+      <- Lmax
       |  |
       |  E      <- Lend = 2^k at Nlevel=2^level
       |
       +-----+
             |
          O  |   <- Lstart=0
          |  |
          +--+   <- Lmin

       ^     ^
    Wmin     Wmax

    Lmax = (7*2^k - 4)/6 if k even
           (7*2^k - 2)/6 if k odd

    Lmin = - (2^k - 1)/3 if k even
           - (2^k - 2)/3 if k odd

    Wmax = (2*2^k - 2) / 3 if k even
           (2*2^k - 1) / 3 if k odd

    Wmin = Lmin

For example level=2 is to Nlevel=2^2=4 and k=level/2=1 is odd so it measures
as follows,

    4      <- Lmax = (7*2^1 - 2)/6 = 2
    |
    3--2
       |
    0--1   <- Lmin = -(2^1 - 2)/3 = 0

    ^  ^Wmax = (2*2^1 - 1)/3 = 1
    |
    Wmin = Lmin = 0

Or level=4 is to Nlevel=2^4=16 and k=4/2=2 is even.  It measures as follows.
The lengthways "L" measures are in the direction of the N=16 endpoint and
the "W" measures are across.

          9----8    5---4        <- Wmax = (2*2^2 - 2)/3 = 2
          |    |    |   |
         10--11,7---6   3---2
               |            |
    16   13---12        0---1
     |    |
    15---14                      <- Wmin = -(2^2 - 1)/3 = -1

     ^                      ^Lmin = Wmin = -1
     |
     Lmax = (7*2^2 - 4)/6 = 4

The formulas are all integer values, but the fractions 7/6, 1/3 and 2/3 show
the limits as the level increases.  If scaled so that length Lend=2^k is
reckoned as 1 unit then Lmax extends 1/6 past the end, Lmin and Wmin extend
1/3, and Wmax extends across 2/3.

    +--------+ --
    | -      | 1/6   total length
    || |     |          = 1/6+1+1/3 = 3/2
    || E     | --
    ||       |
    ||       |
    | \      |  1
    |  \     |
    |   --\  |
    |      \ |
    |       ||
    |  O    || --
    |  |    ||
    |  |    || 1/3
    |   ---- |
    +--------+ --
    1/3|  2/3

    total width = 1/3+2/3 = 1

=head2 Paper Folding

The path is called a paper folding curve because it can be generated by
thinking of a long strip of paper folded in half repeatedly and then
unfolded so each crease is a 90 degree angle.  The effect is that the curve
repeats in successive doublings turned by 90 degrees and reversed.

The first segment unfolds, pivoting at the "1",

                                          2
                                     ->   |
                     unfold         /     |
                      ===>         |      |
                                          |
    0-------1                     0-------1

Then the same again with that L shape, pivoting at the "2", then after that
pivoting at the "4", and so on.

                                 4
                                 |
                                 |
                                 |
                                 3--------2
           2                              |
           |        unfold          ^     |
           |         ===>            \_   |
           |                              |
    0------1                     0--------1

It can be shown that this unfolding doesn't overlap itself but the corners
may touch, such as at the X=-2,Y=1 etc noted above.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::DragonCurve-E<gt>new ()>

=item C<$path = Math::PlanePath::DragonCurve-E<gt>new (arms =E<gt> $int)>

Create and return a new path object.

The optional C<arms> parameter can make 1 to 4 copies of the curve, each arm
successively advancing.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  If there's nothing at
C<$x,$y> then return C<undef>.

The curve visits an C<$x,$y> twice for various points (all the "inside"
points).  The smaller of the two N values is returned.

=item C<@n_list = $path-E<gt>xy_to_n_list ($x,$y)>

Return a list of N point numbers for coordinates C<$x,$y>.

The origin 0,0 has C<arms_count()> many N since it's the starting point for
each arm.  Other points have up to two Ns for a given C<$x,$y>.  If arms=4
then every C<$x,$y> has exactly two Ns.

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 FORMULAS

=head2 X,Y to N

The current code uses the C<DragonMidpoint> C<xy_to_n()> by rotating -45
degrees and offsetting to the midpoints of the four edges around the target
X,Y.  The C<DragonMidpoint> algorithm then gives four candidate N values and
those which convert back to the desired X,Y in the C<DragonCurve>
C<n_to_xy()> are the results for C<xy_to_n_list()>.

    Xmid,Ymid = X+Y, Y-X    # rotate -45 degrees
    for dx = 0 or -1
      for dy = 0 or 1
        N candidate = DragonMidpoint xy_to_n(Xmid+dx,Ymid+dy)

Since there's at most two C<DragonCurve> Ns at a given X,Y the loop can stop
when two Ns are found.

Only the "leaving" edges will convert back to the target N, so only two of
the four edges actually need to be considered.  Is there a way to identify
them?  For arm 1 and 3 the leaving edges are up,down on odd points (meaning
sum X+Y odd) and right,left for even points (meaning sum X+Y even).  But for
arm 2 and 4 it's the other way around.  Without an easy way to determine the
arm this doesn't seem to help.

=head2 X,Y is Visited

Whether a given X,Y is visited by the curve can be determined from one or
two segments (rather then up to four for X,Y to N).

            |             S midpoint Xmid = X+Y
            |                        Ymid = Y-X
    *---T--X,Y--S---*
            |             T midpoint Xmid-1
            |                        Ymid+1

Segment S is to the East of X,Y.  The arm it falls on can be determined as
per L<Math::PlanePath::DragonMidpoint/X,Y to N>.  Numbering arm(S) = 0,1,2,3
then

                                     X,Y Visited
                                     -----------
    if arms_count()==4                  yes     # whole plane
    if arm(S) < arms_count()            yes
    if arm(S)==2 and arms_count()==1    no
    if arm(T) < arms_count()            yes

This works because when two arms touch they approach and leave by a right
angle, without crossing.  So two opposite segments S and T identify the two
possible arms coming to the X,Y point.

           |
           |
            \
      ----   ----
          \
           |
           |

An arm only touches its immediate neighbour, ie. arm-1 or arm+1 mod 4.  This
means if arm(S)==2 then arm(T) can only be 1,2,3, not 0.  So if
C<arms_count()> is 1 then arm(T) cannot be on the curve and no need to run
its segment check.

The only exception to the right-angle touching rule is at the origin X,Y =
0,0.  In that case Xmid,Ymid = 0,0 is on the first arm and X,Y is correctly
determined to be on the curve.  If S was not to the East but some other
direction away from X,Y then this wouldn't be so.

=head2 Turn

At each point the curve always turns either left or right, it never goes
straight ahead.  The bit above the lowest 1-bit in N gives the turn
direction.

    N = 0b...z10000   (possibly no trailing 0s)

    z bit    Turn
    -----    ----
      0      left
      1      right

For example N=12 is binary 0b1100, the lowest 1 bit is 0b_1__ and the bit
above that is a 1, which means turn to the right.  Or N=18 is binary
0b10010, the lowest 1 is 0b___1_ and the bit above that is 0, so turn left
there.

This z bit can be picked out with some bit twiddling

    $mask = $n & -$n;          # lowest 1 bit, 000100..00
    $z = $n & ($mask << 1);    # the bit above it
    $turn = ($z == 0 ? 'left' : 'right');

This sequence is in Knuth volume 2 "Seminumerical Algorithms" answer to
section 4.5.3 question 41 and is called the "dragon sequence".  It's
expressed there recursively as

    d(0) = 1       # unused, since first turn at N=1
    d(2N) = d(N)   # shift down looking for low 1-bit
    d(4N+1) = 0    # bit above lowest 1-bit is 0
    d(4N+3) = 1    # bit above lowest 1-bit is 1

=head2 Next Turn

The bits also give the turn after next by looking at the bit above the
lowest 0-bit.  This works because 011..11 + 1 = 100..00 so the bit above the
lowest 0 becomes the bit above the lowest 1.

    N = 0b...w01111    (possibly no trailing 1s)

    w bit    Next Turn
    ----     ---------
      0       left
      1       right

For example at N=12=0b1100 the lowest 0 is the least significant bit 0b___0,
and above that is a 0 too, so at N=13 the turn is to the left.  Or for
N=18=0b10010 the lowest 0 is again the least significant bit, but above it
is a 1, so at N=19 the turn is to the right.

This too can be found with some bit twiddling, as for example

    $mask = $n ^ ($n+1);      # low one and below 000111..11
    $w = $n & ($mask + 1);    # the bit above there
    $turn = ($w == 0 ? 'left' : 'right');

=head2 Total Turn

The total turn is the count of 0E<lt>-E<gt>1 transitions in the runs of bits
of N, which is the same as how many bit pairs of N (including overlaps) are
different so "01" or "10".

This can be seen from the segment replacements resulting from bits of N,

    N bits from high to low, start in "plain" state

    plain state
     0 bit -> no change
     1 bit -> count left, and go to reversed state

    reversed state
     0 bit -> count left, and go to plain state
     1 bit -> no change

The 0 or 1 counts are from the different side a segment expands on in plain
or reversed state.  Segment A to B expands to an "L" shape bend which is on
the right in plain state, but on the left in reversed state.

      plain state             reverse state

      A = = = = B                    +
       \       ^              0bit  / \
        \     /               turn /   \ 1bit
    0bit \   / 1bit           left/     \
          \ /  turn              /       v
           +   left             A = = = = B

In both cases a rotate of +45 degrees keeps the very first segment of the
whole curve in a fixed direction (along the X axis), which means the
south-east slope shown is no-change.  This is the 0 of plain or the 1 of
reversed.  And the north-east slope which is the other new edge is a turn
towards the left.

It can be seen the "state" above is simply the previous bit, so the effect
for the bits of N is to count a left turn at each transition from 0-E<gt>1
or 1-E<gt>0.  Initial "plain" state means the infinite zero bits at the high
end of N are included.  For example N=9 is 0b1001 so three left turns for
curve direction south to N=10 (as can be seen in the diagram above).

     1 00 1   N=9
    ^ ^  ^
    +-+--+---three transitions,
             so three left turns for direction south

The transitions can also be viewed as a count of how many runs of contiguous
0s or 1s, up to the highest 1-bit.

    1 00 1   three blocks of 0s and 1s

X<Arndt, Jorg>X<fxtbook>This can be calculated by some bit twiddling with a
shift and xor to turn transitions into 1-bits which can then be counted, as
per Jorg Arndt (fxtbook section 1.31.3.1 "The Dragon Curve").

    total turn = count_1_bits ($n ^ ($n >> 1))

The reversing structure of the curve shows up in the total turn at each
point.  The total turns for a block of 2^N is followed by its own reversal
plus 1.  For example,

                    ------->
    N=0 to N=7    0, 1, 2, 1, 2, 3, 2, 1

    N=15 to N=8   1, 2, 3, 2, 3, 4, 3, 2    each is +1
                               <-------

=head2 N to dX,dY

C<n_to_dxdy()> is the "total turn" per above, or for fractional N then an
offset according to the "next turn" above.  If using the bit twiddling
operators described then the two can be calculated separately.

The current C<n_to_dxdy()> code tries to support floating point or other
number types without bitwise XOR etc by processing bits high to low with a
state table which combines the calculations for total turn and next turn.
The state encodes

    total turn       0 to 3
    next turn        0 or 1
    previous bit     0 or 1  (the bit above the current bit)

The "next turn" remembers the bit above lowest 0 seen so far (or 0
initially).  The "total turn" counts 0-E<gt>1 or 1-E<gt>0 transitions.  The
"previous bit" shows when there's a transition, or what bit is above when a
0 is seen.  It also works not to have this previous bit in the state but
instead pick out two bits each time.

At the end of bit processing any "previous bit" in state is no longer needed
and can be masked out to lookup the final four dx, dy, next dx, next dy.

=head2 Boundary Parts

Boundary lengths can be obtained by taking the curve in five types of
section,

                  R                           initial values
      8       5 <--- 4                    k    L  R  T  U  V
      |       ^      |                   ---  -- -- -- -- --
   R  |   U   |   V  |  T                 0    1  1  2  3  3
      v       |      v                    1    2  2  4  6
      7 <---- 6      3 <--- 2             2    4  4     8
          L                 |             3    8  8    12
                        U   |  L          4      16    20
                            v
                     0 ---> 1
                        R

L and R are the left and right sides of the curve.  The other parts T, U and
V are because the points measured must be on the boundary.  The way the
curve touches itself within the "U" part means only 0 and 3 are on the left
boundary and so a measurement must be made between those only.  Similarly T
and V.

The arrowheads drawn show the direction of the curve sub-sections for
replication.  Sections U and V have different directions and are not the
same.  If rotated to upright then U has endpoint positions odd,even whereas
V is even,odd (where odd or even is reckoned by N position along the curve
and which is also odd or even of the sum X+Y).

    even odd  even odd      odd even          U=even,odd
      8   5     0   3        3   6            V=odd,even
      | U |     | U |        | V |
      7---6     1---2        4---5

Right-angle boundary points remain boundary points as the curve expands.  In
the following picture curves ja and jb meet at point j.  When they replicate
as ac and bd respectively the width and height of those is at most 2/3 of
the length and so too small to touch j.

                    c
                    |
                    |
    a------j        a------j        ab and cd don't touch j
           |               |
           |               |
           b        d------b

The same applies if j is on the left boundary.  The ac,bd parts are always
too small to reach back and touch or surround j.  So in the picture above
the boundary points 0 to 8 remain boundary points when the curve doubles to
the next replication level.

The curve expands from 8 sections to 16 sections in the following pattern.
(Drawn here turned 45-degrees to stay horizontal and vertical.)

                        R              R
                    * <--- 4       * <--- 2
                    ^      |       ^      |
                  L |      |   U   |   V  |  T
                    |      v       |      v
                    5 ---> * <---- 3      * <--- 1
                           ^                     |
                        V  |  T              U   |  L
                           |                     v
            8       * <--- 6              0 ---> *
            |       ^                        R
          R |   U   |  T
            v       |
            * <---  7
                L

=cut

# A single segment expands as follows to give recurrences for L and R.
# R[k+1]=R[k]+L[k] is the "unfolding" described above.  Upon unfolding the
# left side L[k] adds to the right for the next level.
#
#                               1           L[k+1] = T[k]
#                               |           R[k+1] = R[k] + L[k]
#                            T  | L
#        L                      v           initial R[0] = 1
#     0 ---> 1           0 ---> *                   L[0] = 1
#        R                  R
#
# T expands to a U and an R.
#
#                           2
#                           |
#                         R |
#                           v
#             2             * <--- 1        T[k+1] = U[k] + R[k]
#             |                    |
#          T  |                 U  |        initial
#             v                    v        T[0] = 2
#      0 ---> 1             0 ---> *
#
# U expands to a U and a V.
#
#                      * <--- 2
#                      ^      |
#                      |  V   |
#                      |      v
#      3 <--- 2        3      * <--- 1      U[k+1] = U[k] + V[k]
#             |                      |
#          U  |                   U  |      initial
#             v                      v      U[0] = 3
#      0 ---> 1               0 ---> *
#
# V expands to a T because the curve touches itself and so closes off the "U"
# shape.  The effect is that the V values are V[0]=3 thereafter the T values
# V[1]=T[0], V[2]=T[1], etc.
#
#                             5 <--- *
#                             |      |
#                             |      |
#                             v      v
#      6 <--- 5        6 ---> * ---> 4      V[k+1] = T[k]
#             |               ^
#          V  |            T  |             initial V[0]=3
#             v               |
#      3 ---> 4               3

=pod

It can be seen R -> R+L, L -> T, T -> U+R, U -> U+V, and V->T.  For V (3 to
6) the curve touches itself and so closes off some boundary leaving just T.
The effect is that the V values are V[0]=3 and thereafter the T values,
V[1]=T[0], V[2]=T[1], etc.

These expansions can be written as recurrences

    R[k+1] = R[k] + L[k]           for k >= 0
    L[k+1] = T[k]
    T[k+1] = R[k] + U[k]
    U[k+1] = U[k] + V[k]
    V[k+1] = T[k]

Some matrix manipulation can isolate each in terms of others, or as a
recurrence in itself.  But it's easy enough to take the equations directly.

=head2 Left Boundary

The left boundary length L is given by a recurrence

    L[k+3] = L[k+2] + 2*L[k]       for k >= 1
    starting L[0] = 1
             L[1] = 2
             L[2] = 4
             L[3] = 8
    1, 2, 4, 8, 12, 20, 36, 60, 100, 172, 292, 492, 836, 1420, ...

                          (1 + x)*(1 + 2*x^2)
    generating function   -------------------
                             1 - x - 2*x^3

=for Test-Pari-DEFINE gL(x)=(1 + x)*(1 + 2*x^2) / (1 - x - 2*x^3)

=for Test-Pari-DEFINE gLplus1(x) = (gL(x)-1)/x    /* L[k+1] stripping first term */

=for Test-Pari Vec(gL(x) - O(x^14)) == [1, 2, 4, 8, 12, 20, 36, 60, 100, 172, 292, 492, 836, 1420]

=for Test-Pari k=0; 4 + 2*1 != 8    /* not k=0 recurrence */

=for Test-Pari k=1; 8 + 2*2 == 12

=for Test-Pari (x^4 - 2*x^3 + x^2 - 2*x + 2) / (x^3 - x^2 - 2) == x-1

=cut

# Left
# g(x) - (x*g(x) + 2*x^3*g(x)) = 1 + (2-1)*x + (4-2)*x^2 + (8-6)*x^3
# g(x) = (1 + (2-1)*x + (4-2)*x^2 + (8-6)*x^3) / (1 - x - 2*x^3)
# g(x) = (1 + x + 2*x^2 + 2*x^3) / (1 - x - 2*x^3)
# g(x) = (1 + x)*(1+2*x^2) / (1 - x - 2*x^3)
# g(x) = 1 + (1 + x + 2*x^2 + 2*x^3 - 1 + x + 2*x^3) / (1 - x - 2*x^3)
# g(x) = 1 + (2*x + 2*x^2 + 4*x^3) / (1 - x - 2*x^3)
# g(x) = 1 + 2*x * (1 + x + 2*x^2) / (1 - x - 2*x^3)
# g(x) = 1 + 2*x + 2*x * (1 + x + 2*x^2 - 1 + x + 2*x^3) / (1 - x - 2*x^3)
# g(x) = 1 + 2*x + 4*x^2 * (1 + x + x^2) / (1 - x - 2*x^3)
# g(x) = 1 + 2*x + 4*x^2 + 4*x^2 * (1 + x + x^2 - 1 + x + 2*x^3) / (1 - x - 2*x^3)
# g(x) = 1 + 2*x + 4*x^2 + 4*x^2 * (2*x + x^2 + 2*x^3) / (1 - x - 2*x^3)
# g(x) = 1 + 2*x + 4*x^2 + 4*x^3 * (2 + x + 2*x^2) / (1 - x - 2*x^3)

=pod

This is obtained from the equations above by first noticing L[k+1]=T[k] and
V[k+1]=T[k] so L[k]=V[k] for kE<gt>=1, then substitute T[k+1]=R[k]+U[k] to
eliminate T, leaving

    R[k+1] = R[k] + L[k]
    U[k+1] = U[k] + L[k]                     for k >= 1
    L[k+1] = R[k-1] + U[k-1]
           = R[k-2]+L[k-2] + U[k-2]+L[k-2]   for k >= 3
           = R[k-2]+U[k-2]  + 2*L[k-2]
    L[k+1] = L[k-1] + 2*L[k-2]               for k >= 3

which is the recurrence for L above.  The generating function follows from
the initial values.

The way T[k]=L[k+1] is simply that two inward pointing sub-curves is the
same as the left side.  T is reckoned as two segments, so this is L[k+1].

                  2
                  |
    T[k]=L[k+1]   |
                  v
           0 ---> 1

The recurrence can be seen directly in the expansion as follows.  The
expanded 0 to 3 plus 7 to 8 are the same as the original 0 to 8.  In the
middle is inserted two extra L[k+1].

              * <--- 4       * <--- 2
              ^      |       ^      |
              |      |       |   V  |
              |      v       |      v
              5 ---> * <---- 3      * <--- 1
                     ^                     |
                     |  L[k+1]         U   |
                     |                     v
      8       * <--- 6              0 ---> *
      |       ^
    R |       |  L[k+1]
      v       |
      * <---  7          extra two L[k+1] on left side
          L              so L[k+4] = L[k+3] + 2*L[k+1]

The fact that L[k]=V[k] (for kE<gt>=1) is not quite obvious from the
geometry of their definition, only from the way they expand.  L[0]=1 and
V[0]=3 differ but thereafter they are the same.

=head2 Right Boundary

The right-side boundary length is given by a recurrence

    R[k+4] = 2*R[k+3] - R[k+2] + 2*R[k+1] - 2*R[k]     k >= 1
    starting R[0] =  1
             R[1] =  2
             R[2] =  4
             R[3] =  8
             R[4] = 16
    = 1, 2, 4, 8, 16, 28, 48, 84, 144, 244, 416, 708, 1200, 2036, ...

                            1 + x^2 + 2*x^4
    generating function  ---------------------
                         (1 - x - 2*x^3)*(1-x)

The recurrence is only for kE<gt>=1 as noted.  At k=0 it would give R[4]=14
but that's incorrect, N=0 to N=2^4 has right side boundary R[4]=16.

=for Test-Pari-DEFINE gR(x)=(1 + x^2 + 2*x^4) / ((1 - x - 2*x^3) * (1-x))

=for Test-Pari-DEFINE gRplus1(x)=(gR(x)-1)/x  /* stripping first term so R[k+1] */

=for Test-Pari gR(x) == 1 + x*((4+2*x+4*x^2)/(1-x-2*x^3) - 2/(1-x))

=for Test-Pari gR(x) == 1 + 2*x*((2+x+2*x^2)/(1-x-2*x^3) - 1/(1-x))

=for Test-Pari Vec(gR(x) - O(x^14)) == [1, 2, 4, 8, 16, 28, 48, 84, 144, 244, 416, 708, 1200, 2036]

=for Test-Pari k=0; 2*8 - 4 + 2*2 - 2*1 != 16  /* not k=0 recurrence */

=for Test-Pari k=1; 2*16 - 8 + 2*4 - 2*2 == 28  /* yes */

=cut

#  R[k+4]-R[k+3]-R[k+1] = R[k+3]-R[k+2]-R[k] + R[k+1]-R[k]
#
# r(x) = 1 + x*g(x)
# r(x) = (2*x + 2*x^3 + (1 - x - 2*x^3)*(1-x)) / ((1 - x - 2*x^3)*(1-x))
# r(x) = (1 + x^2 + 2*x^4) / ((1 - x - 2*x^3)*(1-x))
#      = 1 + x * (2 + 2*x^2) / ((1 - x - 2*x^3)*(1-x))
# partial fractions
# r(x) = (A+Bx+Cx^2)/(1 - x - 2*x^3) + D/(1-x)
#  num = (A+Bx+Cx^2)*(1-x) + D*(1 - x - 2*x^3)
#      = (A +D) + (B-A -D)*x + (C-B)*x^2 + (-C -2D)*x^3
# matsolve([1,0,0,1; -1,1,0,-1; 0,-1,1,0; 0,0,-1,-2], [2;0;2;0])
#
# r(x) = 1 + x*(4 + 2*x + 4*x^2)/(1 - x - 2*x^3)

=pod

The recurrence can be had from the three equations above.  The second gives
U[k-1]=L[k+1]-R[k-1].  Substitute that into the third to eliminate U,

    R[k+1] = R[k] + L[k]
    L[k+3]-R[k+1] = L[k+2]-R[k] + L[k]     for k >= 1

Then the first equation is L[k]=R[k+1]-R[k] and substitute that to
eliminate L.  The result is the fourth-order recurrence for R above.  The
generating function follows from it in the usual way.

=head2 Right Boundary by Summation

The right boundary is a cumulative left boundary, as per R[k+1]=R[k]+L[k]
above.  Substituting repeatedly gives

                                                      i=k-1
    R[k] = L[k-1] + L[k-2] + ... + L[0] + R[0] = 1 + sum  L[i]
     for k>=0                                         i=0
     empty sum if k=0

The usual ways to sum a linear recurrence give the same fourth-order as
above.  The generating function follows from the summation too by
multiplying x/(1-x) in the usual way to sum to term k-1, then add 1/(1-x)
for +1.

             x           1
    gR(x) = ---*gL(x) + ---
            1-x         1-x

=for Test-Pari gR(x) ==  x*(1/(1-x) * gL(x)) + 1/(1-x)

The summation arises from the repeated curve unfoldings.  Each unfold copies
the left side to the right side.  So when level 0 unfolds it puts an L[0]
onto the right.  Then level 1 expands and copies L[1] onto the right, and so
on up to L[k].  This doesn't say anything about the nature of L though.

              L[k-2]
           *----------*             section endpoints on
   L[k-1] /            \            45-degree angles as
         /              ...         per "Level Angle" above
        /                *
       *                 | L[0]
       |              *--*
  L[k] |              R[0]
       |
       *

=head2 Total Boundary

The total boundary is a left and a right,

    B[k] = L[k] + R[k]
         = R[k+1]       for k>=0
         = 2, 4, 8, 16, 28, 48, 84, 144, 244, 416, 708, 1200, ...

                               2 + 2*x^2
    generating function   ---------------------
                          (1 - x - 2*x^3)*(1-x)

                              / 2 + x + 2*x^2     1  \
                          = 2*| -------------- - --- |
                              \ 1 - x - 2*x^3    1-x /

B[k]=R[k+1] is from the R[k+1]=R[k]+L[k] above, representing one more
unfolding.  The first term is dropped from the generating function of R and
that simplifies the numerator.

=for Test-Pari-DEFINE gB(x)=(2 + 2*x^2) / ((1 - x - 2*x^3) * (1-x))

=for Test-Pari gB(x) == gRplus1(x)

=for Test-Pari gB(x) == 2*((2 + x + 2*x^2)/(1-x-2*x^3) - 1/(1-x))

=for Test-Pari Vec(gB(x) - O(x^13)) == [2, 4, 8, 16, 28, 48, 84, 144, 244, 416, 708, 1200, 2036]

=for Test-Pari k=0; 2*16 - 8 + 2*4 - 2*2 == 28

All the boundary lengths start by doubling with N=2^k but when the curve
begins to touch itself the boundary is then less than double.  For B this
happens at B[4]=28 onwards.

The characteristic equation of the recurrence for B and for R is

    x^4 - 2*x^3 + x^2 - 2*x + 2 = (x^3 - x^2 - 2) * (x-1)

=for Test-Pari x^4 - 2*x^3 + x^2 - 2*x + 2 == (x^3 - x^2 - 2) * (x-1)

The real root of the cubic can be had from the usual formula as a cube root
of a square root.  The root is approximately equal to 1.69562 and this shows
how B grows,

    B[k] = approx 3.6 * 1.69562^k

=cut

# characteristic equation x^3 - x^2 - 2 = 0
# real root D^(1/3) + (1/9)*D^(-1/3) + 1/3 = 1.6956207695598620
# where D=28/27 + (1/9)*sqrt(29*3) = 28/27 + sqrt(29/27)
# per Chang and Zhang

# polroots(x^4 - 2*x^3 + x^2 - 2*x + 2)
# x^3 + px + q = 0
# x = cbrt(q/2 + sqrt(p^3/27 + q^2/4)) + cbrt(q/2 - sqrt(p^3/27 + q^2/4))
#
# change of variable x=y+1/3; x^3 - x^2 - 2
# y^3 - 1/3*y - 56/27 = 0
# p = -1/3; q=-56/27
# y = (-28/27 + sqrt(29/27))^(1/3) + (-28/27 - sqrt(29/27))^(1/3)
# x = 1/3 + ...

=pod

=head2 U Boundary

U from the boundary parts above is

    U[k] = /  3          for k=0
           \  R[k] + 4   for k>=1
         = 3, 6, 8, 12, 20, 32, 52, 88, 148, 248, 420, 712, 1204, ...

                          3 - x^2 - 4*x^3 - 2*x^4
    generating function   -----------------------
                           (1 - x - 2*x^3)*(1-x)

=for Test-Pari-DEFINE gU(x)=(3 - x^2 - 4*x^3 - 2*x^4) / ((1 - x - 2*x^3)*(1-x))

=for Test-Pari-DEFINE gUplus1(x)=(gU(x)-3)/x  /* skipping first term */

=for Test-Pari-DEFINE gOnes(x)=1/(1-x) /* 1,1,1,1,1,1,etc */

=for Test-Pari gUplus1(x) == gRplus1(x) + 4*gOnes(x)  /* skipping first term each */

=for Test-Pari Vec(gU(x) - O(x^14)) == [3, 6, 8, 12, 20, 32, 52, 88, 148, 248, 420, 712, 1204, 2040]

=for Test-Pari k=0; 2*12 - 8 + 2*6 - 2*3 != 20    /* not k=0 recurrence */

=for Test-Pari k=1; 2*20 - 12 + 2*8 - 2*6 == 32

U is a summation of L as per the equation U[k+1]=U[k]+L[k] for k>=1.

                                                      i=k
    U[k+1] = L[k] + L[k-1] + ... + L[1] + U[1] = 6 + sum  L[i]
     for k>=1                                         i=1

So U is the same summation as R except for different fixed term U[1]=6
whereas R[1]=2, hence U[k]=R[k]+4, except not at U[0] as the summation does
not apply there.  It's also possible to do the substitutions made for R in
L</Right Boundary> to get U directly from the three equations.

U can also be obtained by considering the left side of a 2-level expansion,
giving U as an L,R difference.  This is also in the substitution formulas
above.

                                        4      4
    L[k+2] = U[k] + R[k]                |      |
                                        |    R |
    so                           L[k+2] |      v
                                        |      3 <--- 2
    U[k] = L[k+2] - R[k]                |             |
                                        |          U  |
                                        v             v
                                        0      0 ---> 1

=cut

# R[k+1] = R[k] + L[k]
# L[k+1] = R[k-1] + U[k-1]        R[k-1] = L[k+1]-U[k-1]
# U[k+1] = U[k] + L[k]            L[k] = U[k+1]-U[k]
#
# L[k+3]-U[k+1] = L[k+2]-U[k] + L[k]
# U[k+4]-U[k+3] -U[k+1] = U[k+3]-U[k+2] -U[k] + U[k+1]-U[k]
# U[k+4] = U[k+3] U[k+1] + U[k+3]-U[k+2] -U[k] + U[k+1]-U[k]
# U[k+4] = 2*U[k+3] - U[k+2] + 2*U[k+1] - 2*U[k]
#
# R[k+4] = 2*R[k+3] - R[k+2] + 2*R[k+1] - 2*R[k]

=pod

=head2 U Total Boundary

The U shape is a kind of one-and-a-half dragon, as if a dragon curve plus a
further half dragon.  The U[k] quantity is its left side.  The right side
and total can be calculated too.

       3 <---- 2
               |     U shape 1+1/2 dragon
               v
       0 ----> 1

The right side of this is

    RU[k] = R[k] + R[k+1]
          = 3, 6, 12, 24, 44, 76, 132, 228, 388, 660, 1124, ...

                          3 + 3*x^2 + 2*x^4
    generating function  --------------------
                         (1 - x - 2*x^3)*(1-x)

=for Test-Pari-DEFINE gRU(x)=(3 + 3*x^2 + 2*x^4) / ((1 - x - 2*x^3)*(1-x))

=for Test-Pari gRU(x) == gR(x)+gRplus1(x)

=for Test-Pari Vec(gRU(x) - O(x^11)) == [3, 6, 12, 24, 44, 76, 132, 228, 388, 660, 1124]

And the total is

    BU[k] = U[k] + RU[k]
          = /  6                     for k=0
            \  2*R[k] + R[k+1] + 4   for k>=1
          = 6, 12, 20, 36, 64, 108, 184, 316, 536, 908, 1544, ...

                          2*(3 + x^2 - 2*x^3)
    generating function  ---------------------
                         (1 - x - 2*x^3)*(1-x)

=for Test-Pari-DEFINE gBU(x)=2*(3 + x^2 - 2*x^3) / ((1 - x - 2*x^3)*(1-x))

=for Test-Pari gBU(x) == gU(x)+gRU(x)

=for Test-Pari Vec(gBU(x) - O(x^11)) == [6, 12, 20, 36, 64, 108, 184, 316, 536, 908, 1544]

=head2 Area from Boundary

The area enclosed by the dragon curve from 0 to N is related to the boundary by

    A[N] = N/2 - B[N]/4

At all times the curve has all "inside" line segments traversed exactly once
so that each unit area has all four sides traversed.  If there was ever an
area enclosed bigger than a single unit then the curve would have to cross
itself to traverse the inner lines to produce the "all inside segments
traversed" pattern of the replications and expansions.

Imagine each line segment as a diamond shape made from a right triangle of
area 1/4 on each of the two sides.

      *
     / \         2 triangles
    0---1        one each side of line segment
     \ /         each triangle area 1/4
      *

If a line segment is on the curve boundary then its outside triangle should
not count towards the area enclosed, so subtract 1 for each unit boundary
length.  If a segment is both a left and right boundary, such as the initial
N=0 to N=1 then it counts 2 to B[N] which makes its area 0 which is as
desired.  So

    triangles = 2*N - B[N]

The triangles are area 1/4 each so

    A[N] = triangles*1/4 = N/2 - B[N]/4

=cut

# four segments to make unit square, but internal segs count twice
# NonBoundary = N-B
# A = (N + N-B)/4 = N/2-B/4
# but what of isolated boundary segs not part of a unit square ???

=pod

=head2 Area

The area enclosed by the dragon curve N=0 to N=2^k can thus be calculated
from the boundary recurrence B[k] as

    A[k] = 2^(k-1) - B[k]/4
         = 0, 0, 0, 0, 1, 4, 11, 28, 67, 152, 335, 724, 1539, ...

    A[k+5] = 4*A[k+4] - 5*A[k+3] + 4*A[k+2] - 6*A[k+1] + 4*A[k]
    starting A[0]=A[1]=A[2]=A[3]=0
             A[4]=1
                                    x^4
    generating function  -----------------------------
                         (1 - x - 2*x^3)*(1-x)*(1-2*x)

=for Test-Pari-DEFINE gA(x)=x^4 / ((1 - x - 2*x^3)*(1-x)*(1-2*x))

=for Test-Pari-DEFINE gAplus1(x)=gA(x)/x     /* A[k+1] skipping first term */

=for Test-Pari Vec(gA(x) - O(x^13)) == [1, 4, 11, 28, 67, 152, 335, 724, 1539]
/* no leading zeros from Vec() */

=for Test-Pari-DEFINE gTwoPow(x)=1/(1-2*x) /* 1,2,4,8,16,32,etc */

=for Test-Pari gA(x) == gTwoPow(x)/2 - gB(x)/4

=cut

# area
# b(x) = (2 + 2*x^2) / ((1 - x - 2*x^3)*(1-x))
# p(x) = 1/2 / (1-2*x)    for 2^(n-1)
# g(x) = p(x) - b(x)/4
# g(x) = 1/2 / (1-2*x) - 1/4 * (2 + 2*x^2) / ((1 - x - 2*x^3)*(1-x))
# g(x) = x^4 / ((1 - x - 2*x^3)*(1-x)*(1-2*x))

=pod

=cut

# B[k] = 2*2^k - 4*A[k]
# B[k+4] = 2*B[k+3] - B[k+2] + 2*B[k+1] - 2*B[k]    for k >= 0
# 2*16*2^k - 4*A[k+4] = 2*(2*8*2^k - 4*A[k+3]) - (2*4*2^k - 4*A[k+2]) + 2*(2*2*2^k - 4*A[k+1]) - 2*(2*2^k - 4*A[k])
#   32*2^k - 4*A[k+4] =     32*2^k - 8*A[k+3]  -    8*2^k + 4*A[k+2]  +      8*2^k - 8*A[k+1]  - 4*2^k + 4*A[k]
#            4*A[k+4] =            + 8*A[k+3]             - 4*A[k+2]               + 8*A[k+1]  + 4*2^k - 4*A[k]
#              A[k+4] =              2*A[k+3]             -   A[k+2]               + 2*A[k+1]  - A[k] + 2^k

=pod

The recurrence form is the usual way to work a power into an existing linear
recurrence.  Or it can be obtained from the generating function which uses
1/(1-2x) to get 2^k to subtract from.  The characteristic equation has a new
factor (x-2) for 2 as a new root, and generating function denominator (1-2x)
similarly.

    x^5 - 4*x^4 + 5*x^3 - 4*x^2 + 6*x^1 - 4
    = (x^3 - x^2 - 2) * (x-1) * (x-2)

=for Test-Pari x^5 - 4*x^4 + 5*x^3 - 4*x^2 + 6*x^1 - 4 == (x^3 - x^2 - 2) * (x-1) * (x-2)

=head2 Join Area

When the dragon curve doubles out from N=2^k to N=2^(k+1) the two copies
enclose the same area each, plus where they meet encloses a further join
area.  This can be calculated as a difference

     JA[k] = A[k+1] - 2*A[k]      join area when N=2^k doubles

Using the A[k] area formula above gives JA[k] with the same recurrence as
the boundary formula but different initial values.  In the generating
function the 1-2*x term in A[k] is eliminated.

     JA[k+4] = 2*JA[k+3] - JA[k+2] + 2*JA[k+1] - 2*JA[k]   k >= 0
     starting J[0] = 0
              J[1] = 0
              J[2] = 0
              J[3] = 1
     1, 2, 3, 6, 11, 18, 31, 54, 91, 154, 263, 446, 755, 1282, 2175, ...

                                  x^3
    generating function  ---------------------
                         (1 - x - 2*x^3)*(1-x)

=for Test-Pari-DEFINE gJA(x)=x^3 / ((1 - x - 2*x^3)*(1-x))

=for Test-Pari gJA(x) == gA(x)/x - 2*gA(x)         /* A[k+1] - 2*A[k] */

=for Test-Pari Vec(gJA(x) - O(x^18)) == [1, 2, 3, 6, 11, 18, 31, 54, 91, 154, 263, 446, 755, 1282, 2175]
/* no leading zeros from Vec() */

The B[k]=R[k+1] and difference L[k]=R[k+1]-R[k] from L</Boundary Length>
above also give

     JA[k] = (R[k+1] - L[k+1])/4

=for Test-Pari gJA(x) == gB(x)/2 - (gB(x)-2)/x/4   /* B[k]/2 - B[k+1]/4 */

=for Test-Pari gJA(x) == (gRplus1(x) - gLplus1(x))/4

The geometric interpretation of this difference form is that if the two
copies of the curve did not touch at all then their boundary would be
2*(R[k]+L[k]) = 2*R[k+1].  But the doubled-out boundary is in fact only
R[k+1]+L[k+1] so the shortfall is

    2*R[k+1] - (R[k+1]+L[k+1]) = R[k+1] - L[k+1]

Then each unit area of join has 4 sides worth of boundary, hence divide by 4
to JA[k] = (R[k+1]-L[k+1])/4.

=cut

# JoinArea = A[k+1] - 2*A[k]
#          = 2^(k+1-1) - B[k+1]/4 - 2*(2^(k-1) - B[k]/4)
#          = 2^k - B[k+1]/4 - (2^k - B[k]/2)
#          = B[k]/2 - B[k+1]/4
#          = (2*B[k] - B[k+1])/4
#          = (B[k] - (B[k+1] - B[k]))/4
#          = (R[k+1] - (R[k+2] - R[k+1]))/4
#          = (R[k+1] - L[k+1])/4
#
# JA[k] = (2*B[k] - B[k+1])/4
#       = 2*(2*B[k-1] - B[k-2] + 2*B[k-3] - 2*B[k-4])
#         - (2*B[k-0] - B[k-1] + 2*B[k-2] - 2*B[k-3])  / 4

=pod

=head2 Double Points from Area

The number of double-visited points is the same as the area enclosed for
any N.

    Doubled[N] = Area[N]          points 0 to N inclusive

When a new line segment goes to an otherwise unvisited point it does not
enclose new area and does not newly double a point.

When a line segment does touch an existing point it creates a new doubled
point and encloses a new unit square area.  As per L</Area by Boundary>
above the curve only ever closes a single unit square at a time, never a
bigger area.

=head2 Single Points from Boundary

The number of single-visited points for any N is given by

    Single[N] = Boundary[N]/2 + 1

The single start point N=0 is Single[N]=1 and Boundary[N]=0.  Thereafter
when a new line segment goes to an otherwise unvisited point it creates 1
new single and 2 new boundary, maintaining the relation.

When a line segment does touch an existing point that point must be a
single.  It cannot be a double since no point is visited three times.  So a
single point becomes a new double, so single count -1.  The following
picture shows how the boundary is a net -2, maintaining the relation above.

     S <---*   new segment enclose 3 boundary
     |     |               create 1 new boundary
     |     |               net -2 boundary
     *-----*   single point S becomes double, so singles -1

All points are either singles or doubles and the total is

    N+1 = Single[N] + 2*Double[N]         points 0 to N inclusive

So the singles can also be obtained from Double[N]=Area[N] and
Area[N]=N/2-B[N]/4 above.

    Single[N] = N+1 - 2*Double[N]
              = N+1 - 2*Area[N]
              = N+1 - 2*(N/2 - B[N]/4)
              = 1 + B[N]/2

=head2 Single Points

The singles for N=0 to N=2^k inclusive from the boundary is

    S[k] = 2^k + 1 - 2*(2^(k-1) - B[k]/4)
         = 1 + B[k]/2
    = 2, 3, 5, 9, 15, 25, 43, 73, 123, 209, 355, 601, 1019, 1729, ...

    S[k+3] = S[k+2] + 2*S[k]   for k >= 0
    starting S[0] = 2
             S[1] = 3
             S[2] = 5
                          2 + x + 2*x^2
    generating function   -------------
                          1 - x - 2*x^3

=for Test-Pari k=0; 2*2 + 5 == 9

=for Test-Pari k=1; 2*3 + 9 == 15

=for Test-Pari-DEFINE gS(x)=(2 + x + 2*x^2)/(1 - x - 2*x^3)

=for Test-Pari gS(x) == gOnes(x)+gB(x)/2

=for Test-Pari Vec(gS(x) - O(x^14)) == [2, 3, 5, 9, 15, 25, 43, 73, 123, 209, 355, 601, 1019, 1729]

This is the same recurrence as left boundary L[k] but with different initial
values.  S[0] through S[4] inclusive are S[k]=2^k+1 since for kE<lt>=4 all
points are singles.  But for k>=5 some points double so there are fewer
singles.

For the generating function the B[k]/2+1 cancels out the 2* and -1/(1-x) in
the generating function of B (as per L</Total Boundary> above) leaving just
the 1-x-2*x^3 denominator.

=head2 Total Points

The total number of distinct points visited by the curve from 0 to N inclusive is

      P[N] = Single[N] + Doubled[N]
           = N+1 - Doubled[N]
           = N+1 - A[N]

For points N=0 to N=2^k inclusive the recurrence for A gives

      P[k] = 2^(k-1) + 1 + B[k]/4
           = 4*P[k-1] - 5*P[k-2] + 4*P[k-3] - 6*P[k-4] + 4*P[k-5]   k>=5
      starting P[0] =  2
               P[1] =  3
               P[2] =  5
               P[3] =  9
               P[4] = 16
      = 2, 3, 5, 9, 16, 29, 54, 101, 190, 361, 690, 1325, 2558, 4961, ...

                           2 - 5*x + 3*x^2 - 4*x^3 + 5*x^4
      generating function  -------------------------------
                            (1 - x - 2*x^3)*(1-x)*(1-2*x)

=for Test-Pari (1 - x - 2*x^3)*(1-x)*(1-2*x) == 1 - (4*x - 5*x^2 + 4*x^3 - 6*x^4 + 4*x^5)

=for Test-Pari-DEFINE gP(x)=(2 - 5*x + 3*x^2 - 4*x^3 + 5*x^4)/((1 - x - 2*x^3)*(1-x)*(1-2*x))

=for Test-Pari-DEFINE gPplus1(x) = (gP(x)-2)/x    /* P[k+1] strip first term */

=for Test-Pari gP(x) == gS(x) + gA(x)

=for Test-Pari gP(x) == gTwoPow(x)/2 + gOnes(x) + gB(x)/4

=for Test-Pari gP(x) == gTwoPow(x)+gOnes(x) - gA(x)

=for Test-Pari Vec(gP(x) - O(x^15)) == [2, 3, 5, 9, 16, 29, 54, 101, 190, 361, 690, 1325, 2558, 4961, 9658]

=for Test-Pari k=5; 4*16 - 5*9 + 4*5 - 6*3 + 4*2 == 29

=for Test-Pari k=6; 4*29 - 5*16 + 4*9 - 6*5 + 4*3 == 54

=cut

# Visit[k] = Double[k] + Single[k]
# Visit[k] = Double[k] + 2^k+1 - 2*Double[k]
# Visit[k] = 2^k+1 - Double[k]
# Visit[k] = 2^k+1 - Area[k]
# Visit[k] = 2^k+1 - (2^(k-1) - B[k]/4)
# Visit[k] = 2^(k-1) + 1 + B[k]/4
#
# points visited
#  Visit[k+1] = 2*Visit[k] - JoinPoints[k]
#             = 2*V[k] + (- JP[k])
#             = 2*V[k] + 2*(2*V[k-1]-JP[k-1]) - (2*V[k-2]-JP[k-2]) + 2*(2*V[k-3]-JP[k-3]) - 2*(2*V[k-4]-JP[k-4])
#                   - 2*(   2*V[k-1]          -    V[k-2]          +    2*V[k-3]          -    2*V[k-4])
#             = 2*V[k] + 2*V[k]               - V[k-1]             + 2*V[k-2]             - 2*V[k-3]
#                         - 4*V[k-1]           + 2*V[k-2]             - 4*V[k-3]             + 4*V[k-4])
#      V[k+1] = 4*V[k] - 5*V[k-1] + 4*V[k-2] - 6*V[k-3] + 4*V[k-4]
#      same recurrence as area, diff start values
#
# (x^5 - 4*x^4 + 5*x^3 - 4*x^2 + 6*x - 4)
#   = (x-1)*(x-2)*(x^3 - x^2 - 2)

=pod

This is the same recurrence as the area but with different starting values.

=head2 Join Points

When the curve doubles the two copies have a certain number of join points
in common.  This is given by

    JP[k] = JA[k] + 1
          = 2*JP[k-1] - JP[k-2] + 2*JP[k-3] - 2*JP[k-4]   k>=0
    starting JP[0] = 1
             JP[1] = 1
             JP[2] = 1
             JP[3] = 2
    = 1, 1, 1, 2, 3, 4, 7, 12, 19, 32, 55, 92, 155, 264, 447, ...

                             1 - x - x^3
    generating function  ---------------------
                         (1 - x - 2*x^3)*(1-x)

=for Test-Pari-DEFINE gJP(x)=(1 - x - x^3) / ((1 - x - 2*x^3)*(1-x))

=for Test-Pari gJP(x) == gJA(x) + gOnes(x)

=for Test-Pari Vec(gJP(x) - O(x^15)) == [1, 1, 1, 2, 3, 4, 7, 12, 19, 32, 55, 92, 155, 264, 447]

=cut

# JP[k] = JA[k] + 1
#       = 2*JA[k-1] - JA[k-2] + 2*JA[k-3] - 2*JA[k-4]   + 1
#       = 2*(JA[k-1]+1) - (JA[k-2]+1) + 2*(JA[k-3]+1) - 2*(JA[k-4]+1)  +1-2+1-2+2
# JP[k] = 2*JP[k-1] - JP[k-2] + 2*JP[k-3]- 2*JP[k-4]
#
# gJP(x) = x^3 / ((1 - x - 2*x^3)*(1-x))  +  1/(1-x)
#        = (x^3 + 1 - x - 2*x^3) / ((1 - x - 2*x^3)*(1-x))
#        = (1 - x - x^3) / ((1 - x - 2*x^3)*(1-x))

=pod

The initial values are 1 because the copies meet at their endpoints only.
For example N=0to2 becomes N=0to4 and the point N=2 is the single join point
between the copies.

When a unit area of join is created, two points P and Q from the first and
second copy touch.  As in the following picture P and Q might be either two
right angles meeting, or a little U closed off.  In both cases the join
takes 2 points from each of the two curve copies.

        |                                |
         \    second            first   /
    --- P -----*                  *----- P ---
       \       |                  |       /
        |      |                  |      | second
        |       \                 |       \
        *----- Q ---              *----- Q ---
    first     \                         \
               |                         |

The first join point is N=2^k itself, and thereafter each join area square
adds 1 more join point.  So the total join points is

    JP[k] = JA[k] + 1

Substituting the recurrence for JA and noticing the recurrence coefficients
add up to -1 so cancelling out the +1 means JP is the same boundary
recurrence as in B but with yet further different initial values.

The join points are pairs of singles in the previous level which have now
become doubles, plus the N=2^k endpoint itself.  So JP[k] can be had from
the newly formed doubles

    JP[k] = 1 + Doubles[k+1] - 2*Doubles[k]

which with Doubles[N]=Area[N] is the same as from JA[k].

=for Test-Pari gJP(x) == gOnes(x) + gAplus1(x) - 2*gA(x)

The join points can also be had from the total points.  If two copies of the
curve did not touch at all then the total visited points would double.  The
actual total visited is less and the shortfall is the join points.

    JP[k] = 2*P[k] - P[k+1]       # total points shortfall on doubling

=for Test-Pari gJP(x) == 2*gP(x) - gPplus1(x)

=head2 Twin Dragons

Two dragons placed head to tail mesh perfectly.  The second dragon is
rotated 180 degrees and the two left sides match.

             9----8    5---4
             |    |    |   |
            10--11,7---6   3---2
                  |            |
       16   13---12        0---1
        |    |
       15---14        14--15
                       |   |      ^   second copy
    1---0         12--13  16      |   rotated 180
    |              |              |   left sides mesh
    2---3     6---7,11-10             N=0 and N=16
        |     |    |    |             head to tail
        4-----5    8----9

The meshing can be starting from an initial 1x1 square.

                          1
                         ^ ^
                        /   \           twin dragon
                      2      0,4        square N=0 to N=2
    1<---0 2           \     /          each expanding
    ^      |            v   v           to N=0 to N=4
    |      |             3 3
    |      v            ^   ^
    2 0--->1           /     \
                     4,0      2
                        \   /
                         v v
                          1

The arrows show the directions the subsequent expansion on the right.  The
directions are per the odd/even point pattern and as the expansions above
the enclosed square remains enclosed and all interior segments traversed
precisely once, which means a perfect meshing.

=head2 Other Formulas

X<Chang, Angel>X<Zhang, Tianrong>A boundary calculation for the curve as a
fractal of infinite descent can be found in

=over

Angel Chang and Tianrong Zhang, "The Fractal Geometry of the Boundary of
Dragon Curves", Journal of Recreational Mathematics, volume 30, number 1,
1999-2000, pages 9-22.
L<http://www.coiraweb.com/poignance/math/Fractals/Dragon/Bound.html>
L<http://stanford.edu/~angelx/pubs/dragonbound.pdf>

=back

=head1 OEIS

The Dragon curve is in Sloane's Online Encyclopedia of Integer Sequences in
many forms (and see C<DragonMidpoint> for its forms too),

=over

L<http://oeis.org/A014577> (etc)

=back

    A038189   turn, 0=left,1=right, bit above lowest 1, extra 0
    A089013    same as A038189, but initial extra 1
    A082410   turn, 1=left,0=right, reversing complement, extra 0
    A099545   turn, 1=left,3=right, as [odd part n] mod 4
               so turn by 90 degrees * 1 or 3
    A034947   turn, 1=left,-1=right, Jacobi (-1/n)
    A112347   turn, 1=left,-1=right, Kronecker (-1/n), extra 0
    A121238   turn, 1=left,-1=right, -1^(n + some partitions) extra 1
    A014577   next turn, 0=left,1=right
    A014707   next turn, 1=left,0=right
    A014709   next turn, 2=left,1=right
    A014710   next turn, 1=left,2=right

    A005811   total turn
    A088748   total turn + 1
    A164910   cumulative [total turn + 1]
    A166242   2^(total turn), by double/halving

    A088431   turn sequence run lengths
    A007400     2*runlength

    A091072   N positions of the left turns, being odd part form 4K+1
    A003460   turns N=1 to N=2^n-1 packed as bits 1=left,0=right
                low to high, then written in octal
    A126937   points numbered like SquareSpiral (start N=0 and flip Y)

    A146559   X at N=2^k, for k>=1, being Re((i+1)^k)
    A009545   Y at N=2^k, for k>=1, being Im((i+1)^k)

    A227036   boundary length N=0 to N=2^k
                also right boundary length to N=2^(k+1)
    A203175   left boundary length N=0 to N=2^k
                also differences of total boundary

    A003230   area enclosed N=0 to N=2^k, for k=4 up
               same as double points
    A003478   area increment, for k=4 up

    A003479   join area between N=2^k replications
    A077949   join area increments

    A003476   single points N=0 to N=2^k inclusive
                and initial 1 for N=0 to N=0
    A164395   single points N=0 to N=2^k-1 inclusive, for k=4 up

The numerous turn sequences differ only in having left or right represented
as 0, 1, -1, etc, and possibly "extra" initial 0 or 1 at n=0 arising from
the definitions and the first turn being at n=N=1.  The "next turn" forms
begin at n=0 for turn at N=1 and so are the turn at N=n+1.

The run lengths A088431 and A007400 are from a continued fraction expansion
of an infinite sum

        1   1   1     1      1              1
    1 + - + - + -- + --- + ----- + ... + ------- + ...
        2   4   16   256   65536         2^(2^k)

X<Shallit, Jeffrey>X<Kmosek>Jeffrey Shallit and independently M. Kmosek show
how continued fraction terms which are repeated in reverse give rise to this
sort of power sum,

=over

Jeffrey Shallit, "Simple Continued Fractions for Some Irrational Numbers",
Journal of Number Theory, volume 11, 1979, pages 209-217.
L<http://www.cs.uwaterloo.ca/~shallit/papers.html>
L<http://www.cs.uwaterloo.ca/~shallit/Papers/scf.ps>

(And which appears in Knuth "Art of Computer Programming", volume 2, section
4.5.3 exercise 41.)

=cut

# M. Kmosek, "Rozwiniecie niektorych liczb niewymiernych na ulamki lancuchowe", Master's
# thesis, Uniwersytet Warszawski, 1979.  -- is that right?

=pod

=back

The A126937 C<SquareSpiral> numbering has the dragon curve and square
spiralling with their Y axes in opposite directions, as shown in its
F<a126937.pdf>.  So the dragon curve turns up towards positive Y but the
square spiral is numbered down towards negative Y (or vice versa).
C<PlanePath> code for this starting at C<$i=0> would be

      my $dragon = Math::PlanePath::DragonCurve->new;
      my $square = Math::PlanePath::SquareSpiral->new (n_start => 0);
      my ($x, $y) = $dragon->n_to_xy ($i);
      my $A126937_of_i = $square->xy_to_n ($x, -$y);

For reference, "dragon-like" A059125 is similar to the turn sequence
A014707, but differs in having the "middle" values for each replication come
from successive values of the sequence itself, or something like that.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DragonRounded>,
L<Math::PlanePath::DragonMidpoint>,
L<Math::PlanePath::R5DragonCurve>,
L<Math::PlanePath::TerdragonCurve>

L<Math::PlanePath::ComplexMinus>,
L<Math::PlanePath::ComplexPlus>,
L<Math::PlanePath::CCurve>,
L<Math::PlanePath::AlternatePaper>

L<http://rosettacode.org/wiki/Dragon_curve>

=for comment http://wiki.tcl.tk/10745 recursive curves

=head1 HOME PAGE

L<http://user42.tuxfamily.org/math-planepath/index.html>

=head1 LICENSE

Copyright 2011, 2012, 2013, 2014 Kevin Ryde

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
