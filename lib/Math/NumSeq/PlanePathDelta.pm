# Copyright 2011, 2012, 2013 Kevin Ryde

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


# maybe:
#
# dRadius, dRSquared,
# dTRadius, dTRSquared   of the radii
# dTheta360
# 'Dir360','TDir360',

# matching Dir4,TDir6
# dLength
# dDist dDSquared
# dTDist dTDSquared
# Dist DSquared
# TDist TDSquared
# StepDist StepSquared
# StepTDist StepTSquared
# StepRadius
# StepRSquared


package Math::NumSeq::PlanePathDelta;
use 5.004;
use strict;
use Carp;
use List::Util 'max';

use vars '$VERSION','@ISA';
$VERSION = 104;
use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');

use Math::NumSeq::PlanePathCoord;
*_planepath_name_to_object = \&Math::NumSeq::PlanePathCoord::_planepath_name_to_object;

# uncomment this to run the ### lines
# use Smart::Comments;


use constant 1.02; # various underscore constants below
use constant characteristic_smaller => 1;

sub description {
  my ($self) = @_;
  if (ref $self) {
    return "Coordinate change $self->{'delta_type'} on path $self->{'planepath'}";
  } else {
    # class method
    return 'Coordinate changes from a PlanePath';
  }
}

use constant::defer parameter_info_array =>
  sub {
    [ Math::NumSeq::PlanePathCoord::_parameter_info_planepath(),
      {
       name    => 'delta_type',
       display => 'Delta Type',
       type    => 'enum',
       default => 'dX',
       choices => ['dX','dY',
                   'AbsdX','AbsdY',
                   'dSum','dSumAbs',
                   'dDiffXY','dDiffYX','dAbsDiff',
                   'Dir4','TDir6',

                   # 'dRSquared',
                   # 'Dist','DSquared',
                   # 'TDist','TDSquared',
                  ],
       description => 'Coordinate change or direction to take from the path.',
      },
    ];
  };

#------------------------------------------------------------------------------

sub oeis_anum {
  my ($self) = @_;
  ### PlanePathCoord oeis_anum() ...

  my $planepath_object = $self->{'planepath_object'};
  my $delta_type = $self->{'delta_type'};

  {
    my $key = Math::NumSeq::PlanePathCoord::_planepath_oeis_anum_key($self->{'planepath_object'});
    my $i_start = $self->i_start;
    if ($i_start != $self->default_i_start) {
      ### $i_start
      ### cf n_start: $planepath_object->n_start
      $key .= ",i_start=$i_start";
    }

    ### planepath: ref $planepath_object
    ### $key
    ### whole table: $planepath_object->_NumSeq_Delta_oeis_anum
    ### key href: $planepath_object->_NumSeq_Delta_oeis_anum->{$key}

    if (my $anum = $planepath_object->_NumSeq_Delta_oeis_anum->{$key}->{$delta_type}) {
      return $anum;
    }
  }
  return undef;
}

#------------------------------------------------------------------------------

sub new {
  ### NumSeq-PlanePathDelta new(): @_
  my $self = shift->SUPER::new(@_);

  $self->{'planepath_object'}
    ||= _planepath_name_to_object($self->{'planepath'});
  {
    my $delta_type = $self->{'delta_type'};
    ($self->{'delta_func'} = $self->can("_delta_func_$delta_type"))
      or ($self->{'n_func'} = $self->can("_n_func_$delta_type"))
        or croak "Unrecognised delta_type: ",$delta_type;
  }
  $self->rewind;
  return $self;
}

sub default_i_start {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'}
    # nasty hack allow no 'planepath_object' when SUPER::new() calls rewind()
    || return 0;
  return $planepath_object->n_start;
}
sub i_start {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'} || return 0;
  return $planepath_object->n_start;
}

# Old code keeping a previous X,Y to take a delta from.
#
# sub rewind {
#   my ($self) = @_;
#
#   my $planepath_object = $self->{'planepath_object'} || return;
#   $self->{'i'} = $self->i_start;
#   undef $self->{'x'};
#   $self->{'arms_count'} = $planepath_object->arms_count;
# }
# sub next {
#   my ($self) = @_;
#   ### NumSeq-PlanePathDelta next(): $self->{'i'}
#   ### n_next: $self->{'n_next'}
#
#   my $planepath_object = $self->{'planepath_object'};
#   my $i = $self->{'i'}++;
#   my $x = $self->{'x'};
#   my $y;
#   if (defined $x) {
#     $y = $self->{'y'};
#   } else {
#     ($x, $y) = $planepath_object->n_to_xy ($i)
#       or return;
#   }
#
#   my $arms = $self->{'arms_count'};
#   my ($next_x, $next_y) = $planepath_object->n_to_xy($i + $arms)
#     or return;
#   my $value = &{$self->{'delta_func'}}($x,$y, $next_x,$next_y);
#
#   if ($arms == 1) {
#     $self->{'x'} = $next_x;
#     $self->{'y'} = $next_y;
#   }
#   return ($i, $value);
# }

sub ith {
  my ($self, $i) = @_;
  ### NumSeq-PlanePathDelta ith(): $i

  my $planepath_object = $self->{'planepath_object'};
  if (my $func = $self->{'n_func'}) {
    return &$func($planepath_object,$i);
  }
  if (my ($dx, $dy) = $planepath_object->n_to_dxdy($i)) {
    return &{$self->{'delta_func'}}($dx,$dy);
  }
  return undef;
}

sub _delta_func_dX {
  my ($dx,$dy) = @_;
  return $dx;
}
sub _delta_func_dY {
  my ($dx,$dy) = @_;
  return $dy;
}
sub _delta_func_AbsdX {
  my ($dx,$dy) = @_;
  return abs($dx);
}
sub _delta_func_AbsdY {
  my ($dx,$dy) = @_;
  return abs($dy);
}
sub _delta_func_dSum {
  my ($dx,$dy) = @_;
  return $dx+$dy;
}
sub _delta_func_dDiffXY {
  my ($dx,$dy) = @_;
  return $dx-$dy;
}
sub _delta_func_dDiffYX {
  my ($dx,$dy) = @_;
  return $dy-$dx;
}

# (abs(x2)+abs(y2)) - (abs(x1)+abs(y1))
#   = abs(x2)-abs(x1) + abs(y2)-+abs(y1)
#   = dAbsX + dAbsY
sub _n_func_dSumAbs {
  my ($path, $n) = @_;
  ### _n_func_dSumAbs(): $n
  my ($x1,$y1) = $path->n_to_xy($n)
    or return undef;
  my ($x2,$y2) = $path->n_to_xy($n + $path->arms_count)
    or return undef;
  ### coords: "x1=$x1 y1=$y1    x2=$x2 y2=$y2"
  ### result: (abs($x2)+abs($y2)) - (abs($x1)+abs($y1))
  return (abs($x2)+abs($y2)) - (abs($x1)+abs($y1));
}
# abs(x2-y2) - abs(x1-y1)
sub _n_func_dAbsDiff {
  my ($path, $n) = @_;
  my ($x1,$y1) = $path->n_to_xy($n)
    or return undef;
  my ($x2,$y2) = $path->n_to_xy($n + $path->arms_count)
    or return undef;
  return abs($x2-$y2) - abs($x1-$y1);
}
sub _n_func_dRSquared {
  my ($path, $n) = @_;
  # dRSquared = (x2^2+y2^2) - (x1^2+y1^2)
  if (defined (my $r1 = $path->n_to_rsquared($n))) {
    if (defined (my $r2 = $path->n_to_rsquared($n + $path->arms_count))) {
      return ($r2 - $r1);
    }
  }
  return undef;
}

sub _delta_func_Dist {
  return sqrt(_delta_func_DSquared(@_));
}
sub _delta_func_DSquared {
  my ($dx,$dy) = @_;
  return $dx*$dx + $dy*$dy;
}
sub _delta_func_TDist {
  return sqrt(_delta_func_TDSquared(@_));
}
sub _delta_func_TDSquared {
  my ($dx,$dy) = @_;
  return $dx*$dx + 3*$dy*$dy;
}

sub _delta_func_Dir4 {
  my ($dx,$dy) = @_;
  ### _delta_func_Dir4(): "$dx,$dy"
  return _delta_func_Dir360($dx,$dy) / 90;
}
sub _delta_func_TDir6 {
  my ($dx,$dy) = @_;
  ### _delta_func_TDir6(): "$dx,$dy"
  return _delta_func_TDir360($dx,$dy) / 60;
}
sub _delta_func_Dir8 {
  my ($dx,$dy) = @_;
  return _delta_func_Dir360($dx,$dy) / 45;
}

use constant 1.02; # for leading underscore
use constant _PI => 2*atan2(1,0);

sub _delta_func_Dir360 {
  my ($dx,$dy) = @_;
  ### _delta_func_Dir360(): "$dx,$dy"

  if ($dy == 0) {
    return ($dx >= 0 ? 0 : 180);
  }
  if ($dx == 0) {
    return ($dy > 0 ? 90 : 270);
  }
  if ($dx > 0) {
    if ($dx == $dy) { return 45; }
    if ($dx == -$dy) { return 315; }
  } else {
    if ($dx == $dy) { return 225; }
    if ($dx == -$dy) { return 135; }
  }

  # don't atan2() in bigints
  if (ref $dx && $dx->isa('Math::BigInt')) {
    $dx = $dx->numify;
  }
  if (ref $dy && $dy->isa('Math::BigInt')) {
    $dy = $dy->numify;
  }

  # Crib: atan2() returns -PI <= a <= PI, and perlfunc says atan2(0,0) is
  # "not well defined", though glibc gives 0
  #
  my $degrees = atan2($dy,$dx) * (180 / _PI);
  ### atan2: atan2($dy,$dx)
  ### $degrees
  return ($degrees < 0 ? $degrees + 360 : $degrees);
}

sub _delta_func_TDir360 {
  my ($dx,$dy) = @_;
  ### _delta_func_TDir360(): "$dx,$dy"

  if ($dy == 0) {
    return ($dx >= 0 ? 0 : 180);
  }
  if ($dx == 0) {
    return ($dy > 0 ? 90 : 270);
  }
  if ($dx > 0) {
    if ($dx == 3*$dy) { return 30; }
    if ($dx == $dy) { return 60; }
    if ($dx == -$dy) { return 300; }
    if ($dx == -3*$dy) { return 330; }
  } else {
    if ($dx == -$dy) { return 120; }
    if ($dx == -3*$dy) { return 150; }
    if ($dx == 3*$dy) { return 210; }
    if ($dx == $dy) { return 240; }
  }

  # Crib: atan2() returns -PI <= a <= PI, and is supposedly "not well
  # defined", though glibc gives 0
  #
  my $degrees = atan2($dy*sqrt(3), $dx) * (180 / _PI);
  return ($degrees < 0 ? $degrees + 360 : $degrees);
}

#------------------------------------------------------------------------------

sub characteristic_integer {
  my ($self) = @_;
  ### PlanePathDelta characteristic_integer() ...
  ### func: "_NumSeq_Delta_$self->{'delta_type'}_integer"
  my $planepath_object = $self->{'planepath_object'};
  if (my $func = $planepath_object->can("_NumSeq_Delta_$self->{'delta_type'}_integer")) {
    return $planepath_object->$func();
  }
  return undef;
}

sub characteristic_increasing {
  my ($self) = @_;
  ### PlanePathDelta characteristic_increasing() ...
  my $planepath_object = $self->{'planepath_object'};
  my $func;
  return
    (($func = ($planepath_object->can("_NumSeq_Delta_$self->{'delta_type'}_increasing")
               || ($self->{'delta_type'} eq 'DSquared'
                   && $planepath_object->can("_NumSeq_Delta_Dist_increasing"))
               || ($self->{'delta_type'} eq 'TDSquared'
                   && $planepath_object->can("_NumSeq_Delta_TDist_increasing"))))
     ? $planepath_object->$func()
     : undef); # unknown
}

sub characteristic_non_decreasing {
  my ($self) = @_;
  ### PlanePathDelta characteristic_non_decreasing() ...
  my $planepath_object = $self->{'planepath_object'};
  my $func;
  return
    (($func = ($planepath_object->can("_NumSeq_Delta_$self->{'delta_type'}_non_decreasing")
               || ($self->{'delta_type'} eq 'DSquared'
                   && $planepath_object->can("_NumSeq_Delta_Dist_non_decreasing"))
               || ($self->{'delta_type'} eq 'TDSquared'
                   && $planepath_object->can("_NumSeq_Delta_TDist_non_decreasing"))))
     ? $planepath_object->$func()
     : $self->characteristic_increasing); # increasing means non_decreasing too
}

sub _dir360_to_tdir6 {
  my ($a) = @_;
  if ($a % 90 == 0) {
    # 0,90,180,270 -> 0, 1.5, 3, 4.5
    return $a / 60;
  }
  if ($a % 45 == 0) {
    # 45, 135, 225, 315 -> 1, 2, 4, 5
    return ($a+45)/90 + ($a < 180 ? 0 : 1);
  }
  if ($a == 30)  { return 0.75; }
  if ($a == 150) { return 2.25; }
  if ($a == 210) { return 3.75; }
  if ($a == 330) { return 5.25; }

  $a *= _PI/180; # degrees to radians
  my $tdir6 = atan2(sin($a)*sqrt(3), cos($a))
    * (3/_PI);  # radians to 6
  return ($tdir6 < 0 ? $tdir6 + 6 : $tdir6);
}

sub _dxdy_to_dir4 {
  my ($dx,$dy) = @_;
  ### _dxdy_to_dir4(): "$dx,$dy"

  if ($dy == 0) {
    return ($dx == 0 ? 4 : $dx > 0 ? 0 : 2);
  }
  if ($dx == 0) {
    return ($dy > 0 ? 1 : 3);
  }
  if ($dx > 0) {
    if ($dx == $dy) { return 0.5; }
    if ($dx == -$dy) { return 3.5; }
  } else {
    if ($dx == $dy) { return 2.5; }
    if ($dx == -$dy) { return 1.5; }
  }

  # don't atan2() in bigints
  if (ref $dx && $dx->isa('Math::BigInt')) {
    $dx = $dx->numify;
  }
  if (ref $dy && $dy->isa('Math::BigInt')) {
    $dy = $dy->numify;
  }

  # Crib: atan2() returns -PI <= a <= PI, and perlfunc says atan2(0,0) is
  # "not well defined", though glibc gives 0
  #
  ### atan2: atan2($dy,$dx)
  my $dir4 = atan2($dy,$dx) * (2 / _PI);
  ### $dir4
  return ($dir4 < 0 ? $dir4 + 4 : $dir4);
}

{
  my %values_min = (dX    => 'dx_minimum',
                    dY    => 'dy_minimum',
                    AbsdX => 'absdx_minimum',
                    AbsdY => 'absdy_minimum',
                    # Dir4  => 'dir4_minimum',
                   );
  sub values_min {
    my ($self) = @_;
    my $planepath_object = $self->{'planepath_object'};
    if (my $method = ($values_min{$self->{'delta_type'}}
                      || $planepath_object->can("_NumSeq_Delta_$self->{'delta_type'}_min"))) {
      return $planepath_object->$method();
    }
    return undef;
  }
}
{
  my %values_max = (dX => 'dx_maximum',
                    dY => 'dy_maximum',
                    AbsdX => 'absdx_maximum',
                    AbsdY => 'absdy_maximum',
                    # Dir4  => 'dir4_maximum',
                   );
  sub values_max {
    my ($self) = @_;
    my $planepath_object = $self->{'planepath_object'};
    if (my $method = ($values_max{$self->{'delta_type'}}
                      || $planepath_object->can("_NumSeq_Delta_$self->{'delta_type'}_max"))) {
      return $planepath_object->$method();
    }
    return undef;
  }
}

{ package Math::PlanePath;
  use constant _NumSeq_Delta_oeis_anum => {};

  #------------
  # dX,dY
  use constant _NumSeq_Delta_dX_integer => 1;  # usually
  use constant _NumSeq_Delta_dY_integer => 1;

  #------------
  # AbsdX,AbsdY
  sub _NumSeq_Delta_AbsdX_integer { $_[0]->_NumSeq_Delta_dX_integer }
  sub _NumSeq_Delta_AbsdY_integer { $_[0]->_NumSeq_Delta_dY_integer }

  #------------
  # dSum
  use constant _NumSeq_Delta_dSum_min => undef;
  use constant _NumSeq_Delta_dSum_max => undef;
  sub _NumSeq_Delta_dSum_integer {
    my ($self) = @_;
    ### _NumSeq_Delta_dSum_integer() ...
    return ($self->_NumSeq_Delta_dX_integer
            && $self->_NumSeq_Delta_dY_integer);
  }

  #------------
  # dSumAbs
  sub _NumSeq_Delta_dSumAbs_min {
    my ($self) = @_;
    if (! $self->x_negative && ! $self->y_negative) {
      return $self->_NumSeq_Delta_dSum_min;
    }
    return undef;
  }
  sub _NumSeq_Delta_dSumAbs_max {
    my ($self) = @_;
    if (! $self->x_negative && ! $self->y_negative) {
      return $self->_NumSeq_Delta_dSum_max;
    }
    return undef;
  }
  *_NumSeq_Delta_dSumAbs_integer = \&_NumSeq_Delta_dSum_integer;

  #------------
  # dDiffXY
  use constant _NumSeq_Delta_dDiffXY_min => undef;
  use constant _NumSeq_Delta_dDiffXY_max => undef;

  sub _NumSeq_Delta_dDiffYX_min {
    my ($self) = @_;
    if (defined (my $m = $self->_NumSeq_Delta_dDiffXY_max)) {
      return - $m;
    } else {
      return undef;
    }
  }
  sub _NumSeq_Delta_dDiffYX_max {
    my ($self) = @_;
    if (defined (my $m = $self->_NumSeq_Delta_dDiffXY_min)) {
      return - $m;
    } else {
      return undef;
    }
  }

  *_NumSeq_Delta_dDiffXY_integer = \&_NumSeq_Delta_dSum_integer;
  sub _NumSeq_Delta_dDiffYX_integer {
    return $_[0]->_NumSeq_Delta_dDiffXY_integer;
  }
  *_NumSeq_Delta_dAbsDiff_integer = \&_NumSeq_Delta_dDiffYX_integer;

  #------------
  # Dir4
  sub _NumSeq_Delta_Dir4_min {
    my ($self) = @_;
    return Math::NumSeq::PlanePathDelta::_dxdy_to_dir4
      ($self->dir_minimum_dxdy);
  }
  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return Math::NumSeq::PlanePathDelta::_dxdy_to_dir4
      ($self->dir_maximum_dxdy);
  }
  sub _NumSeq_Dir4_max_is_supremum {
    my ($self) = @_;
    return ($self->_NumSeq_Delta_Dir4_max == 4);
  }
  use constant _NumSeq_Dir4_min_is_infimum => 0;

  #------------
  # TDir6
  sub _NumSeq_Delta_TDir6_min {
    my ($self) = @_;
    return Math::NumSeq::PlanePathDelta::_dir360_to_tdir6
      ($self->_NumSeq_Delta_Dir4_min * 90);
  }
  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    return Math::NumSeq::PlanePathDelta::_dir360_to_tdir6
      ($self->_NumSeq_Delta_Dir4_max * 90);
  }
  sub _NumSeq_TDir6_max_is_supremum {
    return $_[0]->_NumSeq_Dir4_max_is_supremum;
  }
  sub _NumSeq_TDir6_min_is_infimum {
    return $_[0]->_NumSeq_Dir4_min_is_infimum;
  }

  #------------
  sub _NumSeq_Delta_Dist_min {
    my ($self) = @_;
    sqrt($self->_NumSeq_Delta_DSquared_min);
  }
  sub _NumSeq_Delta_Dist_max {
    my ($self) = @_;
    my $max;
    return (defined ($max = $self->_NumSeq_Delta_DSquared_max)
            ? sqrt($max)
            : undef);
  }

  sub _NumSeq_Delta_TDist_min {
    my ($self) = @_;
    sqrt($self->_NumSeq_Delta_TDSquared_min);
  }
  sub _NumSeq_Delta_TDist_max {
    my ($self) = @_;
    my $max;
    return (defined ($max = $self->_NumSeq_Delta_TDSquared_max)
            ? sqrt($max)
            : undef);
  }

  # Default Dist min from AbsdX,AbsdY min.
  # Subclass must overridde if those minimums don't occur together.
  sub _NumSeq_Delta_DSquared_min {
    my ($self) = @_;
    my $dx = $self->absdx_minimum;
    my $dy = $self->absdy_minimum;
    return _max (1, $dx*$dx + $dy*$dy);
  }
  sub _NumSeq_Delta_TDSquared_min {
    my ($self) = @_;
    my $dx = $self->absdx_minimum;
    my $dy = $self->absdy_minimum;
    return _max (1, $dx*$dx + 3*$dy*$dy);
  }

  # Default Dist max from AbsdX,AbsdY max, if maximums exist.
  # Subclass must overridde if those maximums don't occur together.
  sub _NumSeq_Delta_DSquared_max {
    my ($self) = @_;
    if (defined (my $dx = $self->absdx_maximum)
        && defined (my $dy = $self->absdy_maximum)) {
      return ($dx*$dx + $dy*$dy);
    } else {
      return undef;
    }
  }
  sub _NumSeq_Delta_TDSquared_max {
    my ($self) = @_;
    if (defined (my $dx = $self->absdx_maximum)
        && defined (my $dy = $self->absdy_maximum)) {
      return ($dx*$dx + 3*$dy*$dy);
    } else {
      return undef;
    }
  }

  *_NumSeq_Delta_DSquared_integer = \&_NumSeq_Delta_dSum_integer;
  *_NumSeq_Delta_TDSquared_integer = \&_NumSeq_Delta_dSum_integer;

  use constant _NumSeq_Delta_Dir360_min => 0;
  use constant _NumSeq_Delta_Dir360_max => 360;
}


{ package Math::PlanePath::SquareSpiral;
  use constant _NumSeq_Delta_dSum_min => -1; # NSEW straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1; # NSEW straight only
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;

  use constant _NumSeq_Delta_oeis_anum =>
    { 'wider=0,n_start=1' =>
      { AbsdY   => 'A079813',   # k 0s then k 1s plus initial 1 is abs(dY)
        # OEIS-Catalogue: A079813 planepath=SquareSpiral delta_type=AbsdY
      },
    };
}
{ package Math::PlanePath::GreekKeySpiral;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dSumAbs_min => -1;
  use constant _NumSeq_Delta_dSumAbs_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::PyramidSpiral;
  use constant _NumSeq_Delta_AbsdX_non_decreasing => 1; # constant absdx=1
  use constant _NumSeq_Delta_dSum_min => -2; # SW diagonal
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -2;  # NW diagonal
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;

  use constant _NumSeq_Delta_DSquared_max => 2;
  use constant _NumSeq_Delta_TDir6_integer => 1;
}
{ package Math::PlanePath::TriangleSpiral;
  use constant _NumSeq_Delta_dSum_min => -2; # SW diagonal
  use constant _NumSeq_Delta_dSum_max => 2;  # dX=+2 horiz
  use constant _NumSeq_Delta_dDiffXY_min => -2;  # NW diagonal
  use constant _NumSeq_Delta_dDiffXY_max => 2;   # dX=+2 horiz
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;

  use constant _NumSeq_Delta_TDir6_integer => 1;

  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_DSquared_max => 4;
  use constant _NumSeq_Delta_TDSquared_min => 4;  # triangular
  use constant _NumSeq_Delta_TDSquared_max => 4;  # triangular
  use constant _NumSeq_Delta_TDist_non_decreasing => 1;  # triangular
}
{ package Math::PlanePath::TriangleSpiralSkewed;
  {
    my %_NumSeq_Delta_dSum_min = (left  => -1,  # diagonal only NW across
                                  right => -2,  # SW
                                  up    => -1,  # S
                                  down  => -1); # W
    sub _NumSeq_Delta_dSum_min {
      my ($self) = @_;
      return $_NumSeq_Delta_dSum_min{$self->{'skew'}};
    }
  }
  {
    my %_NumSeq_Delta_dSum_max = (left  => 1,  # E
                                  right => 1,  # N
                                  up    => 2,  # NE
                                  down  => 1); # N
    sub _NumSeq_Delta_dSum_max {
      my ($self) = @_;
      return $_NumSeq_Delta_dSum_max{$self->{'skew'}};
    }
  }

  use constant _NumSeq_Delta_dSumAbs_min => -2;
  use constant _NumSeq_Delta_dSumAbs_max => 2;

  {
    my %_NumSeq_Delta_dDiffXY_min = (left  => -2,  # North-West
                                     right => -1,  # N
                                     up    => -1,  # W
                                     down  => -1); # W
    sub _NumSeq_Delta_dDiffXY_min {
      my ($self) = @_;
      return $_NumSeq_Delta_dDiffXY_min{$self->{'skew'}};
    }
  }
  {
    my %_NumSeq_Delta_dDiffXY_max = (left  => 1,  # S
                                     right => 1,  # S
                                     up    => 1,  # S
                                     down  => 2); # South-East
    sub _NumSeq_Delta_dDiffXY_max {
      my ($self) = @_;
      return $_NumSeq_Delta_dDiffXY_max{$self->{'skew'}};
    }
  }

  {
    my %_NumSeq_Delta_dAbsDiff_min = (left  => -2,  # North-West
                                      right => -1,  # N
                                      up    => -1,  # W
                                      down  => -2); # North-West
    sub _NumSeq_Delta_dAbsDiff_min {
      my ($self) = @_;
      return $_NumSeq_Delta_dAbsDiff_min{$self->{'skew'}};
    }
  }
  {
    my %_NumSeq_Delta_dAbsDiff_max = (left  => 2,  # South-East
                                      right => 1,  # S
                                      up    => 1,  # S
                                      down  => 2); # South-East
    sub _NumSeq_Delta_dAbsDiff_max {
      my ($self) = @_;
      return $_NumSeq_Delta_dAbsDiff_max{$self->{'skew'}};
    }
  }

  use constant _NumSeq_Delta_DSquared_max => 2;

  # A204435 f(i,j)=((i+j  )^2 mod 3), antidiagonals
  # A204437 f(i,j)=((i+j+1)^2 mod 3), antidiagonals
  # A204439 f(i,j)=((i+j+2)^2 mod 3), antidiagonals
  # gives 0s at every third antidiagonal
  use constant _NumSeq_Delta_oeis_anum =>
    { 'skew=left,n_start=1' =>
      { AbsdX => 'A204439',
        AbsdY => 'A204437',
        # OEIS-Catalogue: A204439 planepath=TriangleSpiralSkewed,skew=left delta_type=AbsdX
        # OEIS-Catalogue: A204437 planepath=TriangleSpiralSkewed,skew=left delta_type=AbsdY
      },
      'skew=right,n_start=1' =>
      { AbsdX => 'A204435',
        AbsdY => 'A204437',
        # OEIS-Catalogue: A204435 planepath=TriangleSpiralSkewed,skew=right delta_type=AbsdX
        # OEIS-Other:     A204437 planepath=TriangleSpiralSkewed,skew=right delta_type=AbsdY
      },
      'skew=up,n_start=1' =>
      { AbsdX => 'A204439',
        AbsdY => 'A204435',
        # OEIS-Other: A204439 planepath=TriangleSpiralSkewed,skew=up delta_type=AbsdX
        # OEIS-Other: A204435 planepath=TriangleSpiralSkewed,skew=up delta_type=AbsdY
      },
      'skew=down,n_start=1' =>
      { AbsdX => 'A204435',
        AbsdY => 'A204439',
        # OEIS-Other: A204435 planepath=TriangleSpiralSkewed,skew=down delta_type=AbsdX
        # OEIS-Other: A204439 planepath=TriangleSpiralSkewed,skew=down delta_type=AbsdY
      },
    };
}
{ package Math::PlanePath::DiamondSpiral;
  use constant _NumSeq_Delta_AbsdX_non_decreasing => 1; # constant absdx=1
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;
  use constant _NumSeq_Delta_DSquared_max => 2;
  use constant _NumSeq_Delta_TDir6_integer => 1;

  use constant _NumSeq_Delta_oeis_anum =>
    { 'n_start=1' =>
      { AbsdX => 'A000012', # all 1s, starting OFFSET=1
        # OEIS-Other: A000012 planepath=DiamondSpiral delta_type=AbsdX
      },
      'n_start=0' =>
      { dSumAbs => 'A003982',  # characteristic of A001844 Y_neg axis
        # OEIS-Other: A003982 planepath=DiamondSpiral,n_start=0 delta_type=dSumAbs
      },
    };
}
{ package Math::PlanePath::AztecDiamondRings;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  # use constant _NumSeq_Delta_dSumAbs_min => -2; # diagonals
  # use constant _NumSeq_Delta_dSumAbs_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;

  use constant _NumSeq_Delta_oeis_anum =>
    { 'n_start=0' =>
      { AbsdY => 'A023532', # 0 at n=k*(k+3)/2, 1 otherwise
        # OEIS-Catalogue: A023532 planepath=AztecDiamondRings,n_start=0 delta_type=AbsdY
      },
    };
}
{ package Math::PlanePath::PentSpiral;
  use constant _NumSeq_Delta_dSum_min => -3; # SW -2,-1
  use constant _NumSeq_Delta_dSum_max => 2;  # dX=+2 and NE diag
  use constant _NumSeq_Delta_dDiffXY_min => -3; # NW dX=-2,dY=+1
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_dAbsDiff_min => -3;
  use constant _NumSeq_Delta_dAbsDiff_max => 3;

  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_DSquared_max => 5;
}
{ package Math::PlanePath::PentSpiralSkewed;
  use constant _NumSeq_Delta_dSum_min => -2; # SW diagonal
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -2; # NW diagonal
  use constant _NumSeq_Delta_dDiffXY_max => 2;  # SE diagonal
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;
  use constant _NumSeq_Delta_DSquared_max => 2;
}
{ package Math::PlanePath::HexSpiral;
  use constant _NumSeq_Delta_dSum_min => -2; # SW diagonal
  use constant _NumSeq_Delta_dSum_max => 2;  # dX=+2 and diagonal
  use constant _NumSeq_Delta_dDiffXY_min => -2; # NW diagonal
  use constant _NumSeq_Delta_dDiffXY_max => 2;  # SE diagonal
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;

  use constant _NumSeq_Delta_TDir6_integer => 1;

  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_DSquared_max => 4;
  use constant _NumSeq_Delta_TDist_non_decreasing => 1;  # triangular
  use constant _NumSeq_Delta_TDSquared_max => 4;  # triangular
}
{ package Math::PlanePath::HexSpiralSkewed;
  use constant _NumSeq_Delta_dSum_min => -1; # W,S straight
  use constant _NumSeq_Delta_dSum_max => 1;  # N,E straight
  use constant _NumSeq_Delta_dDiffXY_min => -2; # NW diagonal
  use constant _NumSeq_Delta_dDiffXY_max => 2;  # SE diagonal
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;
  use constant _NumSeq_Delta_DSquared_max => 2;
}
{ package Math::PlanePath::HeptSpiralSkewed;
  use constant _NumSeq_Delta_dSum_min => -1; # W,S straight
  use constant _NumSeq_Delta_dSum_max => 1;  # N,E straight
  use constant _NumSeq_Delta_dDiffXY_min => -2; # NW diagonal
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;
  use constant _NumSeq_Delta_DSquared_max => 2;
}
{ package Math::PlanePath::OctagramSpiral;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_DSquared_max => 2;
}
{ package Math::PlanePath::AnvilSpiral;
  use constant _NumSeq_Delta_AbsdX_non_decreasing => 1; # constant
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;
  use constant _NumSeq_Delta_DSquared_max => 2;
  use constant _NumSeq_Delta_TDir6_integer => 1;

  use constant _NumSeq_Delta_oeis_anum =>
    { 'wider=0,n_start=0' =>
     { AbsdX     => 'A000012',  # all 1s, OFFSET=0
       # OEIS-Other: A000012 planepath=AnvilSpiral,n_start=0 delta_type=AbsdX
     },
    };
}
{ package Math::PlanePath::KnightSpiral;
  use constant _NumSeq_Delta_dSum_min => -3; # -2,-1
  use constant _NumSeq_Delta_dSum_max => 3;  # +2,+1
  use constant _NumSeq_Delta_dSumAbs_min => -3;
  use constant _NumSeq_Delta_dSumAbs_max => 3;
  use constant _NumSeq_Delta_dDiffXY_min => -3;
  use constant _NumSeq_Delta_dDiffXY_max => 3;
  use constant _NumSeq_Delta_dAbsDiff_min => -3;
  use constant _NumSeq_Delta_dAbsDiff_max => 3;

  use constant _NumSeq_Delta_DSquared_min => 2*2+1*1; # dX=1,dY=2
  use constant _NumSeq_Delta_DSquared_max => 2*2+1*1;
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_min => 2*2 + 3*1*1; # dX=2,dY=1
  use constant _NumSeq_Delta_TDSquared_max => 1*1 + 3*2*2; # dX=1,dY=2
}
{ package Math::PlanePath::CretanLabyrinth;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;
  use constant _NumSeq_Delta_DSquared_max => 1;
  use constant _NumSeq_Delta_Dir4_integer => 1;
}
{ package Math::PlanePath::SquareArms;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dSumAbs_min => -1;
  use constant _NumSeq_Delta_dSumAbs_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;
  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;  # vertical
}
{ package Math::PlanePath::DiamondArms;  # diag always
  use constant _NumSeq_Delta_AbsdX_non_decreasing => 1; # constant absdx=1
  use constant _NumSeq_Delta_AbsdY_non_decreasing => 1; # constant absdy=1
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;

  use constant _NumSeq_Delta_TDir6_integer => 1;

  use constant _NumSeq_Delta_DSquared_min => 2;   # diagonal always
  use constant _NumSeq_Delta_DSquared_max => 2;
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;

  use constant _NumSeq_Delta_TDSquared_min => 4;   # diagonal always
  use constant _NumSeq_Delta_TDSquared_max => 4;
  use constant _NumSeq_Delta_TDist_non_decreasing => 1;
}
{ package Math::PlanePath::HexArms;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dSumAbs_min => -2;
  use constant _NumSeq_Delta_dSumAbs_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;
  use constant _NumSeq_Delta_TDir6_integer => 1;

  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_DSquared_max => 4;

  use constant _NumSeq_Delta_TDSquared_max => 4;  # triangular
  use constant _NumSeq_Delta_TDist_non_decreasing => 1;  # triangular
}
{ package Math::PlanePath::SacksSpiral;
  use constant _NumSeq_Delta_dX_integer => 0;
  use constant _NumSeq_Delta_dY_integer => 0;
  use constant _NumSeq_Delta_dSumAbs_min => - 2*atan2(1,0);  # -pi
  use constant _NumSeq_Delta_dSumAbs_max =>   2*atan2(1,0);  # +pi
  use constant _NumSeq_AbsdX_min_is_infimum => 1;
  use constant _NumSeq_Delta_Dist_increasing => 1; # each step bigger
}
{ package Math::PlanePath::VogelFloret;
  use constant _NumSeq_Delta_dX_integer => 0;
  use constant _NumSeq_Delta_dY_integer => 0;
  use constant _NumSeq_AbsdX_min_is_infimum => 1;
  use constant _NumSeq_AbsdY_min_is_infimum => 1;

  use constant _NumSeq_Dir4_min_is_infimum => 1;
  use constant _NumSeq_Dir4_max_is_supremum => 1;
}
{ package Math::PlanePath::TheodorusSpiral;
  use constant _NumSeq_Delta_dX_integer => 0;
  use constant _NumSeq_Delta_dY_integer => 0;
  use constant _NumSeq_dX_min_is_infimum => 1;
  use constant _NumSeq_dY_min_is_infimum => 1;

  use constant _NumSeq_Delta_dSum_min => -sqrt(2); # supremum diagonal
  use constant _NumSeq_Delta_dSum_max => sqrt(2);
  use constant _NumSeq_dSum_min_is_infimum => 1;
  use constant _NumSeq_dSum_max_is_supremum => 1;

  use constant _NumSeq_Delta_dSumAbs_min => -1; # supremum vert/horiz
  use constant _NumSeq_Delta_dSumAbs_max => 1;
  use constant _NumSeq_dSumAbs_min_is_infimum => 1;

  use constant _NumSeq_Delta_dDiffXY_min => -sqrt(2); # supremum diagonal
  use constant _NumSeq_Delta_dDiffXY_max => sqrt(2);
  use constant _NumSeq_dDiffXY_min_is_infimum => 1;
  use constant _NumSeq_dDiffXY_max_is_supremum => 1;

  use constant _NumSeq_Delta_dAbsDiff_min => -sqrt(2); # supremum diagonal
  use constant _NumSeq_Delta_dAbsDiff_max => sqrt(2);
  use constant _NumSeq_dAbsDiff_min_is_infimum => 1;
  use constant _NumSeq_dAbsDiff_max_is_supremum => 1;

  use constant _NumSeq_Delta_DSquared_max => 1; # constant 1
  use constant _NumSeq_Delta_Dist_non_decreasing => 1; # constant 1
  use constant _NumSeq_Delta_TDSquared_max => 3; # vertical
}
{ package Math::PlanePath::ArchimedeanChords;
  use constant _NumSeq_Delta_dX_integer => 0;
  use constant _NumSeq_Delta_dY_integer => 0;
  use constant _NumSeq_dX_min_is_infimum => 1;

  use constant _NumSeq_AbsdX_min_is_infimum => 1;
  use constant _NumSeq_dY_min_is_infimum => 1;
  use constant _NumSeq_dY_max_is_supremum => 1;

  use constant _NumSeq_Delta_dSum_min => -sqrt(2); # supremum when diagonal
  use constant _NumSeq_Delta_dSum_max => sqrt(2);
  use constant _NumSeq_dSum_min_is_infimum => 1;

  use constant _NumSeq_Delta_dSumAbs_min => -1;
  use constant _NumSeq_Delta_dSumAbs_max => 1;
  use constant _NumSeq_dSumAbs_min_is_infimum => 1;

  use constant _NumSeq_Delta_dDiffXY_min => -sqrt(2); # supremum when diagonal
  use constant _NumSeq_Delta_dDiffXY_max => sqrt(2);
  use constant _NumSeq_dDiffXY_min_is_infimum => 1;

  use constant _NumSeq_Delta_dAbsDiff_min => -sqrt(2); # supremum when diagonal
  use constant _NumSeq_Delta_dAbsDiff_max => sqrt(2);
  use constant _NumSeq_dAbsDiff_min_is_infimum => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;  # supremum
  use constant _NumSeq_TDSquared_max_is_supremum => 1;

  use constant _NumSeq_Dir4_max_is_supremum => 1;
}
{ package Math::PlanePath::MultipleRings;

  #---------
  # dX
  sub _NumSeq_dX_min_is_infimum {
    my ($self) = @_;
    if ($self->{'step'} == 0) {
      return 0;    # horizontal only, exact
    }
    return 1;  # infimum
  }
  sub _NumSeq_dX_max_is_supremum {
    my ($self) = @_;
    return ($self->{'step'} <= 6
            ? 0
            : 1); # supremum
  }
  sub _NumSeq_Delta_dX_non_decreasing {
    my ($self) = @_;
    return ($self->{'step'} == 0);  # constant dX=1,dY=0
  }
  *_NumSeq_Delta_dX_integer             = \&_NumSeq_Delta_dX_non_decreasing;

  #---------
  # dY
  *_NumSeq_dY_max_is_supremum      = \&_NumSeq_dX_min_is_infimum;
  *_NumSeq_dY_min_is_infimum       = \&_NumSeq_dX_min_is_infimum;
  *_NumSeq_Delta_dY_non_decreasing      = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_dY_integer             = \&_NumSeq_Delta_dX_non_decreasing;

  #---------
  # AbsdX
  sub _NumSeq_AbsdX_min_is_infimum {
    my ($self) = @_;
    if ($self->{'step'} == 1) {
      return 0; # horizontal only
    }
    if ($self->{'step'} % 2 == 1) {
      return 0; # any odd num sides has left vertical dX=0 exactly
    }
    return $self->_NumSeq_dX_min_is_infimum;
  }
  *_NumSeq_Delta_AbsdX_non_decreasing   = \&_NumSeq_Delta_dX_non_decreasing;

  #---------
  # AbsdY
  sub _NumSeq_Delta_AbsdY_non_decreasing {
    my ($self) = @_;
    if ($self->{'ring_shape'} eq 'polygon' && $self->{'step'} == 4) {
      return 1;   # abs(dY) constant
    }
    return $self->_NumSeq_Delta_dY_non_decreasing;
  }

  #---------
  # dSum
  sub _NumSeq_Delta_dSum_min {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 1    # horizontal only
            : -1); # infimum
  }
  use constant _NumSeq_Delta_dSum_max => 1;
  *_NumSeq_dSum_max_is_supremum    = \&_NumSeq_dX_min_is_infimum;
  *_NumSeq_dSum_min_is_infimum     = \&_NumSeq_dX_min_is_infimum;
  *_NumSeq_Delta_dSum_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;

  #---------
  # dDiffXY
  # FIXME: for step=1 is there a supremum at 9 or thereabouts?
  # and for other step<6 too?
  # 2*dXmax * sqrt(2) ?
  sub _NumSeq_Delta_dDiffXY_min {
    my ($self) = @_;
    return ($self->{'step'} == 0  ? 1     # horizontal only
            : $self->{'step'} <= 6 ? $self->dx_minimum * sqrt(2)
            : -1); # infimum
  }
  sub _NumSeq_Delta_dDiffXY_max {
    my ($self) = @_;
    return ($self->{'step'} == 0   ? 1     # horizontal only
            : $self->{'step'} <= 6 ? $self->dx_maximum * sqrt(2)
            : 1); # supremum
  }
  *_NumSeq_dDiffXY_min_is_infimum  = \&_NumSeq_dX_min_is_infimum;
  *_NumSeq_dDiffXY_max_is_supremum = \&_NumSeq_dX_min_is_infimum;
  *_NumSeq_Delta_dDiffXY_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;

  #---------
  # dDiffYX
  *_NumSeq_Delta_dDiffYX_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;

  #---------
  # dSumAbs
  *_NumSeq_Delta_dSumAbs_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;

  #---------
  # dAbsDiff
  *_NumSeq_Delta_dAbsDiff_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;

  #---------
  # DSquared
  sub _NumSeq_Delta_DSquared_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 1    # horizontal only

            : $self->{'step'} <= 6
            ? ((8*atan2(1,1)) / $self->{'step'}) ** 2

            # step > 6, between rings
            : ((0.5/_PI()) * $self->{'step'}) ** 2);
  }

  *_NumSeq_Delta_Dist_non_decreasing    = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_TDist_non_decreasing   = \&_NumSeq_Delta_dX_non_decreasing;

  #-----------
  # Dir4,TDir6
  *_NumSeq_Delta_Dir4_non_decreasing    = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_TDir6_non_decreasing   = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_Dir4_integer           = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_TDir6_integer          = \&_NumSeq_Delta_dX_non_decreasing;

  use constant _NumSeq_Delta_oeis_anum =>
    {
     # MultipleRings step=0 is trivial X=N,Y=0
     'step=0,ring_shape=circle' =>
     { dX     => 'A000012',  # all 1s
       dY     => 'A000004',  # all-zeros
       Dir4   => 'A000004',  # all zeros, East
       TDir6  => 'A000004',  # all zeros, East
       # OEIS-Other: A000012 planepath=MultipleRings,step=0 delta_type=dX
       # OEIS-Other: A000004 planepath=MultipleRings,step=0 delta_type=dY
       # OEIS-Other: A000004 planepath=MultipleRings,step=0 delta_type=Dir4
       # OEIS-Other: A000004 planepath=MultipleRings,step=0 delta_type=TDir6
     },
    };
}
{ package Math::PlanePath::PixelRings;  # NSEW+diag
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 3;  # dx=2,dy=1 at jump N=5 to N=6
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;
  use constant _NumSeq_Delta_DSquared_max => 5; # dx=2,dy=1 at jump N=5 to N=6
}
{ package Math::PlanePath::FilledRings;  # NSEW+diag
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;
  use constant _NumSeq_Delta_DSquared_max => 2;
}
{ package Math::PlanePath::Hypot;
  # approaches horizontal
  use constant _NumSeq_Dir4_max_is_supremum => 1;


  sub _NumSeq_Delta_DSquared_min {
    my ($self) = @_;
    return ($self->{'points'} eq 'all'
            ? 1    # dX=1,dY=0
            : 2);   # dX=1,dY=1
  }
  sub _NumSeq_Delta_TDSquared_min {
    my ($self) = @_;
    return ($self->{'points'} eq 'all'
            ? 1    # dX=1,dY=0
            : 4);   # dX=1,dY=1
  }
}
{ package Math::PlanePath::HypotOctant;
  sub _NumSeq_Delta_DSquared_min {
    my ($self) = @_;
    return ($self->{'points'} eq 'all'
            ? 1    # dX=1,dY=0
            : 2);   # dX=1,dY=1
  }
  sub _NumSeq_Delta_TDSquared_min {
    my ($self) = @_;
    return ($self->{'points'} eq 'all'
            ? 1    # dX=1,dY=0
            : 4);   # dX=1,dY=1
  }
}
{ package Math::PlanePath::TriangularHypot;
  # approaches horizontal
  use constant _NumSeq_Dir4_max_is_supremum => 1;

  sub _NumSeq_Delta_DSquared_min {
    my ($self) = @_;
    return ($self->{'points'} eq 'all'
            ? 1    # dX=1,dY=0
            : 2);   # dX=1,dY=1
  }
  sub _NumSeq_Delta_TDSquared_min {
    my ($self) = @_;
    return ($self->{'points'} eq 'all'
            ? 1    # dX=1,dY=0
            : 4);   # dX=1,dY=1
  }
}
{ package Math::PlanePath::PythagoreanTree;
  {
    my %Dir4_min_is_infimum = ('BC,UAD' => 1,
                               'SM,UAD' => 1,
                               'SC,UAD' => 1,
                               'MC,UAD' => 1,

                               'AB,FB' => 1,
                               'AC,FB' => 1,
                               'BC,FB' => 1,
                               'PQ,FB' => 1,
                               'SM,FB' => 1,
                               'SC,FB' => 1,
                               'MC,FB' => 1,
                              );
    sub _NumSeq_Dir4_min_is_infimum {
      my ($self) = @_;
      return $Dir4_min_is_infimum{"$self->{'coordinates'},$self->{'tree_type'}"};
    }
  }
  {
    my %Dir4_max_is_supremum = ('BC,UAD' => 1,
                                'SM,UAD' => 1,
                                'SC,UAD' => 1,
                                'MC,UAD' => 1,

                                'AB,FB'  => 1,
                                'AC,FB'  => 1,
                                'PQ,FB'  => 1,
                                'SM,FB' => 1,
                                'SC,FB' => 1,
                                'MC,FB' => 1,
                               );
    sub _NumSeq_Dir4_max_is_supremum {
      my ($self) = @_;
      return $Dir4_max_is_supremum{"$self->{'coordinates'},$self->{'tree_type'}"};
    }
  }
}
{ package Math::PlanePath::RationalsTree;
  {
    my %Dir4_min_is_infimum = (Drib => 1);
    sub _NumSeq_Dir4_min_is_infimum {
      my ($self) = @_;
      return $Dir4_min_is_infimum{$self->{'tree_type'}};
    }
  }
  {
    my %Dir4_max_is_supremum = (CW   => 1,
                                AYT  => 1,
                                Drib => 1,
                                L    => 1);
    sub _NumSeq_Dir4_max_is_supremum {
      my ($self) = @_;
      return $Dir4_max_is_supremum{$self->{'tree_type'}};
    }
  }

  use constant _NumSeq_Delta_oeis_anum =>
    { 'tree_type=L' =>
      { dY => 'A070990',  # Stern diatomic differences OFFSET=0
        # OEIS-Catalogue: A070990 planepath=RationalsTree,tree_type=L delta_type=dY
      },

      # 'tree_type=CW' =>
      # {
      #  # dY => 'A070990', # Stern diatomic first diffs, except it starts i=0
      #  # where RationalsTree N=1.  dX is same, but has extra leading 0.
      # },
    };
}
{ package Math::PlanePath::FractionsTree;
  use constant _NumSeq_Dir4_max_is_supremum => 1;
}
{ package Math::PlanePath::ChanTree;
  sub _NumSeq_Dir4_min_is_infimum {
    my ($self) = @_;
    return ($self->{'k'} == 2 || ($self->{'k'} & 1) == 0
            ? 0    # k=2 or k odd
            : 1);  # k even
  }

  use constant _NumSeq_Dir4_max_is_supremum => 1;
}
{ package Math::PlanePath::DiagonalRationals;
  use constant _NumSeq_Delta_dSum_min => 0;
  use constant _NumSeq_Delta_dSum_max => 1;  # to next diagonal stripe
  use constant _NumSeq_TDSquared_min => 3;
}
{ package Math::PlanePath::FactorRationals;
  use constant _NumSeq_Dir4_min_is_infimum => 1;
  use constant _NumSeq_Dir4_max_is_supremum => 1;
}
{ package Math::PlanePath::CfracDigits;

  # radix=1 N=1       has dir4=0
  # radix=2 N=5628    has dir4=0 dx=9,dy=0
  # radix=3 N=1189140 has dir4=0 dx=1,dy=0
  # radix=4 N=169405  has dir4=0 dx=2,dy=0
  # always eventually 0 ?
  sub _NumSeq_Dir4_min_is_infimum {
    my ($self) = @_;
    return ($self->{'radix'} > 4);
  }
  use constant _NumSeq_Dir4_max_is_supremum => 1;
}
{ package Math::PlanePath::GcdRationals;
  sub _NumSeq_Delta_TDSquared_min {
    my ($self) = @_;
    return ($self->{'pairs_order'} eq 'diagonals_down'
            ? 3   # at N=1 vert
            : 1); # at N=4 horiz
  }
}
# { package Math::PlanePath::CfracDigits;
# }
{ package Math::PlanePath::PeanoCurve;

  *_NumSeq_Delta_dSum_min = \&dx_minimum;
  *_NumSeq_Delta_dSum_max = \&dx_maximum;

  *_NumSeq_Delta_dDiffXY_min = \&dx_minimum;
  *_NumSeq_Delta_dDiffXY_max = \&dx_maximum;

  *_NumSeq_Delta_dAbsDiff_min = \&dx_minimum;
  *_NumSeq_Delta_dAbsDiff_max = \&dx_maximum;

  *_NumSeq_Delta_DSquared_max = \&dx_maximum;
  sub _NumSeq_Delta_Dist_non_decreasing {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? 1     # odd
            : 0);   # even, jumps about
  }
  sub _NumSeq_Delta_TDSquared_max {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? 3         # odd, vertical
            : undef);   # even, unlimited
  }

  sub _NumSeq_Delta_Dir4_integer {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? 1      # odd, continuous path
            : 0);    # even, jumps
  }

  sub _NumSeq_Dir4_max_is_supremum {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? 0      # odd
            : 1);    # even, supremum
  }

  # use constant _NumSeq_Delta_oeis_anum =>
  #   { 'radix=3' =>
  #     {
  #      # Not quite, extra initial 0
  #      # AbsdX => 'A014578', # 1 - count low 0-digits, mod 2
  #      #  # OEIS-Catalogue: A014578 planepath=PeanoCurve delta_type=AbsdX
  #
  #      #  # Not quite, OFFSET n=1 cf N=0
  #      #  # # A163534 is 0=east,1=south,2=west,3=north treated as down page,
  #      #  # # which corrsponds to 1=north (incr Y), 3=south (decr Y) for
  #      #  # # directions of the PeanoCurve planepath here
  #      #  # Dir4 => 'A163534',
  #      #  # # OEIS-Catalogue: A163534 planepath=PeanoCurve delta_type=Dir4
  #      #
  #      #  # delta a(n)-a(n-1), so initial dx=0 at i=0 ...
  #      #  # dX => 'A163532',
  #      #  # # OEIS-Catalogue: A163532 planepath=PeanoCurve delta_type=dX
  #      #  # dY => 'A163533',
  #      #  # # OEIS-Catalogue: A163533 planepath=PeanoCurve delta_type=dY
  #     },
  #   };
}
{ package Math::PlanePath::WunderlichSerpentine;
  # same as PeanoCurve

  sub _NumSeq_Delta_dSum_min { return $_[0]->dx_minimum; }
  sub _NumSeq_Delta_dSum_max { return $_[0]->dx_maximum; }

  *_NumSeq_Delta_dDiffXY_min = \&_NumSeq_Delta_dSum_min;
  *_NumSeq_Delta_dDiffXY_max = \&_NumSeq_Delta_dSum_max;
  *_NumSeq_Delta_dAbsDiff_min = \&_NumSeq_Delta_dSum_min;
  *_NumSeq_Delta_dAbsDiff_max = \&_NumSeq_Delta_dSum_max;

  # radix=2 0101 is straight NSEW parts, other evens are diagonal
  sub _NumSeq_Delta_Dir4_integer {
    my ($self) = @_;
    return (($self->{'radix'} % 2)
            || join('',@{$self->{'serpentine_array'}}) eq '0101'
            ? 1      # odd, continuous path
            : 0);    # even, jumps
  }
  sub _NumSeq_Dir4_max_is_supremum {
    my ($self) = @_;
    return (($self->{'radix'} % 2)
            || join('',@{$self->{'serpentine_array'}}) eq '0101'
            ? 0      # odd, South
            : 1);    # even, supremum
  }

  *_NumSeq_Delta_DSquared_max = \&Math::PlanePath::PeanoCurve::_NumSeq_Delta_DSquared_max;
  *_NumSeq_Delta_Dist_non_decreasing = \&Math::PlanePath::PeanoCurve::_NumSeq_Delta_Dist_non_decreasing;
  *_NumSeq_Delta_TDSquared_max = \&Math::PlanePath::PeanoCurve::_NumSeq_Delta_TDSquared_max;
}
{ package Math::PlanePath::HilbertCurve;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;

  # 'Math::PlanePath::HilbertCurve' =>
  # {
  #  # Not quite, OFFSET=1 at origin, cf path N=0
  #  # # A163540 is 0=east,1=south,2=west,3=north for drawing down the page,
  #  # # which corresponds to 1=north,3=south per the HilbertCurve planepath
  #  # Dir4 => 'A163540',
  #  # # OEIS-Catalogue: A163540 planepath=HilbertCurve delta_type=Dir4
  #
  # Not quite, # delta path(n)-path(n-1) starting i=0 with path(-1)=0 for
  # first value 0
  # # dX => 'A163538',
  #  # # OEIS-Catalogue: A163538 planepath=HilbertCurve delta_type=dX
  #  # dY => 'A163539',
  #  # # OEIS-Catalogue: A163539 planepath=HilbertCurve delta_type=dY
  #  #
  #  # cf A163541    absolute direction, transpose X,Y
  #  # would be N=0,E=1,S=2,W=3
  # },
}
{ package Math::PlanePath::HilbertSpiral;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
# { package Math::PlanePath::HilbertMidpoints;
#   use constant _NumSeq_Delta_DSquared_min => 2;
#   use constant _NumSeq_Delta_DSquared_max => 4;
# }
{ package Math::PlanePath::ZOrderCurve;
  use constant _NumSeq_Delta_dSum_max => 1; # forward straight only
}
{ package Math::PlanePath::GrayCode;
  # FIXME: some combinations are always NSEW ...
  # use constant _NumSeq_Delta_Dir4_integer => 1;
  sub _NumSeq_Delta_dSum_min {
    my ($self) = @_;
    return $self->dx_minimum;
  }
  sub _NumSeq_Delta_dSum_max {
    my ($self) = @_;
    return $self->dx_maximum;
  }

  *_NumSeq_Delta_dSumAbs_min = \&_NumSeq_Delta_dSum_min;
  *_NumSeq_Delta_dSumAbs_max = \&_NumSeq_Delta_dSum_max;

  *_NumSeq_Delta_dDiffXY_min = \&_NumSeq_Delta_dSum_min;
  *_NumSeq_Delta_dDiffXY_max = \&_NumSeq_Delta_dSum_max;

  *_NumSeq_Delta_dAbsDiff_min = \&_NumSeq_Delta_dSum_min;
  *_NumSeq_Delta_dAbsDiff_max = \&_NumSeq_Delta_dSum_max;

  {
    my %Dir4_integer = (reflected => { TsF => 1,
                                       FsT => 1,
                                       Ts  => 1,
                                       Fs  => 1,
                                     },
                        modular => { TsF => 1,
                                     Ts  => 1,
                                   },
                       );
    sub _NumSeq_Delta_Dir4_integer {
      my ($self) = @_;
      my $gray_type = ($self->{'radix'} == 2
                       ? 'reflected'
                       : $self->{'gray_type'});
      return $Dir4_integer{$gray_type}->{$self->{'apply_type'}};
    }
  }

  sub _NumSeq_Delta_Dist_non_decreasing {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            && $self->{'gray_type'} eq 'reflected'
            && ($self->{'apply_type'} eq 'TsF'
                || $self->{'apply_type'} eq 'FsT')
            ? 1    # PeanoCurve style NSEW only
            : 0);
  }
}
{ package Math::PlanePath::ImaginaryBase;
  # Dir4 radix=2 goes south-east at
  #  N=2^3-1=7
  #  N=2^7-1=127
  #  N=2^11-1=2047
  #  N=2^15-1=32767
  # dx=0x555555
  # dy=-0xAAAAAB
  # approaches dx=1,dy=-2
  #
  # radix=3
  # dy=dx+1 approches SE
  #
  # radix=4 dx/dy=1.5
  # radix=5 dx/dy=2
  # dx/dy=(radix-1)/2

  use constant _NumSeq_Dir4_max_is_supremum => 1;
}
{ package Math::PlanePath::ImaginaryHalf;
  {
    my %_NumSeq_Dir4_min_is_infimum = (XYX => 0,
                                       XXY => 0,
                                       YXX => 1,  # dX=big,dY=1
                                       XnYX => 1,  # dX=big,dY=1
                                       XnXY => 0,  # dX=1,dY=0 at N=1
                                       YXnX =>  1,  # dX=big,dY=1
                                      );
    sub _NumSeq_Dir4_min_is_infimum {
      my ($self) = @_;
      return $_NumSeq_Dir4_min_is_infimum{$self->{'digit_order'}};
    }
  }

  use constant _NumSeq_Dir4_max_is_supremum => 1;
}
{ package Math::PlanePath::CubicBase;
  use constant _NumSeq_Delta_DSquared_min => 4; # at X=0 to X=2
  # direction supremum maybe at
  #   dx=-0b 1001001001001001... = - (8^k-1)/7
  #   dy=-0b11011011011011011... = - (3*8^k-1)/7
  # which is
  #   dx=-1, dy=-3
  use constant _NumSeq_Dir4_max_is_supremum => 1;

  use constant _NumSeq_Delta_TDSquared_min => 4;  # at N=0 dX=2,dY=1
}
# { package Math::PlanePath::Flowsnake;
#   # inherit from FlowsnakeCentres
# }
{ package Math::PlanePath::FlowsnakeCentres;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;

  use constant _NumSeq_Delta_TDir6_integer => 1;

  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_DSquared_max => 4;
  use constant _NumSeq_Delta_TDist_non_decreasing => 1;  # triangular
  use constant _NumSeq_Delta_TDSquared_max => 4;             # triangular
}
{ package Math::PlanePath::GosperReplicate;
  # maximum angle N=34 dX=3,dY=-1, it seems
}
{ package Math::PlanePath::GosperIslands;
  use constant _NumSeq_Delta_DSquared_min => 2;
}
{ package Math::PlanePath::GosperSide;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dSumAbs_min => -2; # diagonals
  use constant _NumSeq_Delta_dSumAbs_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;
  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_DSquared_max => 4;
  use constant _NumSeq_Delta_TDir6_integer => 1;

  # use constant _NumSeq_Delta_oeis_anum =>
  # 'Math::PlanePath::GosperSide' =>
  # 'Math::PlanePath::TerdragonCurve' =>
  # A062756 is total turn starting OFFSET=0, count of ternary 1 digits.
  # Dir6 would be total%6, or 2*(total%3) for Terdragon, suspect such a
  # modulo version not in OEIS.
}
{ package Math::PlanePath::KochCurve;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;
  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_DSquared_max => 4;
  use constant _NumSeq_Delta_TDir6_integer => 1;

  use constant _NumSeq_Delta_oeis_anum =>
    { '' =>
      { AbsdY => 'A011655', # 0,1,1 repeating
        # OEIS-Catalogue: A011655 planepath=KochCurve delta_type=AbsdY
      },
    };
}
{ package Math::PlanePath::KochPeaks;
  use constant _NumSeq_Delta_dSum_max => 2; # diagonal NE
  use constant _NumSeq_Delta_dDiffXY_max => 2; # diagonal NW
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_TDir6_integer => 1;
}
{ package Math::PlanePath::KochSnowflakes;
  use constant _NumSeq_Delta_dX_integer => 1;
  use constant _NumSeq_Delta_dY_integer => 0; # initial Y=+2/3
  use constant _NumSeq_Delta_DSquared_min => 2; # step diag or 2straight
}
{ package Math::PlanePath::KochSquareflakes;
  use constant _NumSeq_Delta_dX_integer => 0; # initial non-integers
  use constant _NumSeq_Delta_dY_integer => 0;
  use constant _NumSeq_Delta_dSum_max => 2; # diagonal NE
  use constant _NumSeq_Delta_dSum_integer => 1;
  use constant _NumSeq_Delta_dSumAbs_integer => 1;
  use constant _NumSeq_Delta_dDiffXY_max => 2; # diagonal NW
  use constant _NumSeq_Delta_dDiffXY_integer => 1;
  use constant _NumSeq_Delta_dAbsDiff_integer => 1;
}

{ package Math::PlanePath::QuadricCurve;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dSumAbs_min => -1;
  use constant _NumSeq_Delta_dSumAbs_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;
  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::QuadricIslands;
  use constant _NumSeq_Delta_dX_integer => 0; # initial 0.5s
  use constant _NumSeq_Delta_dY_integer => 0;

  # minimum unbounded jumping to next ring
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dSum_integer => 1;  # 0.5+0.5 integer

  # maximum unbounded jumping to next ring
  use constant _NumSeq_Delta_dSumAbs_min => -1;     # at N=5
  use constant _NumSeq_Delta_dSumAbs_integer => 1;  # 0.5+0.5 integer

  # dDiffXY=+1 or -1
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dDiffXY_integer => 1;

  # dAbsDiff=+1 or -1
  # jump to next ring is along leading diagonal so dAbsDiff bounded
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_integer => 1;  # 0.5-0.5 integer
}

{ package Math::PlanePath::SierpinskiCurve;
  use List::Util;

  sub _NumSeq_Delta_dSum_min {
    my ($self) = @_;
    return - List::Util::max ($self->{'straight_spacing'},
                              2*$self->{'diagonal_spacing'});
  }
  sub _NumSeq_Delta_dSum_max {
    my ($self) = @_;
    return List::Util::max ($self->{'straight_spacing'},
                            2*$self->{'diagonal_spacing'});
  }
  *_NumSeq_Delta_dSumAbs_min = \&_NumSeq_Delta_dSum_min;
  *_NumSeq_Delta_dSumAbs_max = \&_NumSeq_Delta_dSum_max;
  *_NumSeq_Delta_dDiffXY_min = \&_NumSeq_Delta_dSum_min;
  *_NumSeq_Delta_dDiffXY_max = \&_NumSeq_Delta_dSum_max;
  *_NumSeq_Delta_dAbsDiff_min = \&_NumSeq_Delta_dSum_min;
  *_NumSeq_Delta_dAbsDiff_max = \&_NumSeq_Delta_dSum_max;

  sub _NumSeq_Delta_Dir4_integer {
    my ($self) = @_;
    return ($self->{'diagonal_spacing'} == 0);
  }

  sub _NumSeq_Delta_DSquared_min {
    my ($self) = @_;
    return List::Util::min ($self->{'straight_spacing'} ** 2,
                            2 * $self->{'diagonal_spacing'} ** 2);
  }
  sub _NumSeq_Delta_DSquared_max {
    my ($self) = @_;
    return List::Util::max ($self->{'straight_spacing'} ** 2,
                            2 * $self->{'diagonal_spacing'} ** 2);
  }
  sub _NumSeq_Delta_TDSquared_min {
    my ($self) = @_;
    return List::Util::min($self->{'straight_spacing'},
                           2 * $self->{'diagonal_spacing'}) ** 2;
  }
  sub _NumSeq_Delta_TDSquared_max {
    my ($self) = @_;
    return List::Util::max(3 * $self->{'straight_spacing'} ** 2, # vertical
                           4 * $self->{'diagonal_spacing'} ** 2);
  }

  # use constant _NumSeq_Delta_oeis_anum =>
  # 'arms=1,straight_spacing=1,diagonal_spacing=1' =>
  # {
  #  # # Not quite, A127254 has extra initial 1
  #  # AbsdY => 'A127254',  # 0 at 2*position of "odious" odd number 1-bits
  #  # # OEIS-Catalogue: A127254 planepath=SierpinskiCurve delta_type=AbsdY
  # },
}
{ package Math::PlanePath::SierpinskiCurveStair;
  use constant _NumSeq_Delta_dSum_min => -1; # NSEW only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dSumAbs_min => -1;
  use constant _NumSeq_Delta_dSumAbs_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;
  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;

  use constant _NumSeq_Delta_oeis_anum =>
    { 'arms=1' =>
      { AbsdX => 'A059841',  # 1,0 repeating
        AbsdY => 'A000035',  # 0,1 repeating

        # OEIS-Other: A059841 planepath=SierpinskiCurveStair delta_type=AbsdX
        # OEIS-Other: A000035 planepath=SierpinskiCurveStair delta_type=AbsdY
        #
        # OEIS-Other: A059841 planepath=SierpinskiCurveStair,diagonal_length=2 delta_type=AbsdX
        # OEIS-Other: A059841 planepath=SierpinskiCurveStair,diagonal_length=3 delta_type=AbsdX
        # OEIS-Other: A000035 planepath=SierpinskiCurveStair,diagonal_length=2 delta_type=AbsdY
        # OEIS-Other: A000035 planepath=SierpinskiCurveStair,diagonal_length=3 delta_type=AbsdY
      },
    };
}
{ package Math::PlanePath::SierpinskiTriangle;
  use constant _NumSeq_Delta_DSquared_min => 2;

  sub _NumSeq_Delta_dSum_min {
    my ($self) = @_;
    return ($self->{'align'} eq 'diagonal'
           ? 0         # X+Y constant along diagonals
           : undef);
  }
  sub _NumSeq_Delta_dSum_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'diagonal'
           ? 1         # X+Y increase by 1 to next diagonal
           : undef);
  }
  *_NumSeq_Delta_dSumAbs_min = \&_NumSeq_Delta_dSum_min;
  *_NumSeq_Delta_dSumAbs_max = \&_NumSeq_Delta_dSum_max;

  sub _NumSeq_Dir4_max_is_supremum {
    my ($self) = @_;
    return ($self->{'align'} ne 'diagonal');
  }
}
{ package Math::PlanePath::SierpinskiArrowhead;
  {
    my %_NumSeq_Delta_dSum_min = (triangular => -2,
                                  left       => -1,
                                  right      => -2,
                                  diagonal   => -1,
                                 );
    sub _NumSeq_Delta_dSum_min {
      my ($self) = @_;
      return $_NumSeq_Delta_dSum_min{$self->{'align'}};
    }
  }
  {
    my %_NumSeq_Delta_dSum_max = (triangular => 2,
                                  left       => 1,
                                  right      => 2,
                                  diagonal   => 1,
                                 );
    sub _NumSeq_Delta_dSum_max {
      my ($self) = @_;
      return $_NumSeq_Delta_dSum_max{$self->{'align'}};
    }
  }

  {
    my %_NumSeq_Delta_dSumAbs_min = (triangular => -2,
                                     left       => -2,
                                     right      => -2,
                                     diagonal   => -1,
                                    );
    sub _NumSeq_Delta_dSumAbs_min {
      my ($self) = @_;
      return $_NumSeq_Delta_dSumAbs_min{$self->{'align'}};
    }
  }
  {
    my %_NumSeq_Delta_dSumAbs_max = (triangular => 2,
                                     left       => 2,
                                     right      => 2,
                                     diagonal   => 1,
                                    );
    sub _NumSeq_Delta_dSumAbs_max {
      my ($self) = @_;
      return $_NumSeq_Delta_dSumAbs_max{$self->{'align'}};
    }
  }

  sub _NumSeq_Delta_dDiffXY_min {
    my ($self) = @_;
    return ($self->{'align'} eq 'right' ? -1 : -2);
  }
  sub _NumSeq_Delta_dDiffXY_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'right' ? 1 : 2);
  }

  *_NumSeq_Delta_dAbsDiff_min = \&_NumSeq_Delta_dDiffXY_min;
  *_NumSeq_Delta_dAbsDiff_max = \&_NumSeq_Delta_dDiffXY_max;

  sub _NumSeq_Delta_TDir6_integer {
    my ($self) = @_;
    return ($self->{'align'} eq 'triangular' ? 1 : 0);
  }

  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_DSquared_max => 4;
  use constant _NumSeq_Delta_TDist_non_decreasing => 1;  # triangular
  use constant _NumSeq_Delta_TDSquared_max => 4;             # triangular
}
{ package Math::PlanePath::SierpinskiArrowheadCentres;
  *_NumSeq_Delta_dSum_min
    = \&Math::PlanePath::SierpinskiArrowhead::_NumSeq_Delta_dSum_min;
  *_NumSeq_Delta_dSum_max
    = \&Math::PlanePath::SierpinskiArrowhead::_NumSeq_Delta_dSum_max;
  *_NumSeq_Delta_dSumAbs_min
    = \&Math::PlanePath::SierpinskiArrowhead::_NumSeq_Delta_dSumAbs_min;
  *_NumSeq_Delta_dSumAbs_max
    = \&Math::PlanePath::SierpinskiArrowhead::_NumSeq_Delta_dSumAbs_max;

  sub _NumSeq_Delta_dDiffXY_min {
    my ($self) = @_;
    return ($self->{'align'} eq 'right' ? -1 : -2);
  }
  sub _NumSeq_Delta_dDiffXY_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'right' ? 1 : 2);
  }

  *_NumSeq_Delta_dAbsDiff_min = \&_NumSeq_Delta_dDiffXY_min;
  *_NumSeq_Delta_dAbsDiff_max = \&_NumSeq_Delta_dDiffXY_max;

  sub _NumSeq_Delta_dDSquared_min {
    my ($self) = @_;
    return ($self->{'align'} eq 'triangular' ? 2 : 1);
  }
  sub _NumSeq_Delta_dDSquared_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'triangular' ? 4 : 2);
  }
  sub _NumSeq_Delta_TDir6_integer {
    my ($self) = @_;
    return ($self->{'align'} eq 'triangular' ? 1 : 0);
  }
}

{ package Math::PlanePath::DragonCurve;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dSumAbs_min => -1;
  use constant _NumSeq_Delta_dSumAbs_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;

  use constant _NumSeq_Delta_oeis_anum =>
    {
     do {
       my $href =
         { AbsdX => 'A059841', # 1,0 repeating
           AbsdY => 'A000035', # 0,1 repeating
         };
       ('arms=1' => $href,
        'arms=3' => $href,
       );
       # OEIS-Other: A059841 planepath=DragonCurve delta_type=AbsdX
       # OEIS-Other: A000035 planepath=DragonCurve delta_type=AbsdY
       # OEIS-Other: A059841 planepath=DragonCurve,arms=3 delta_type=AbsdX
       # OEIS-Other: A000035 planepath=DragonCurve,arms=3 delta_type=AbsdY
     },
     # 'arms=2' => $href,# 0,1,1,0
     'arms=4' =>
     { AbsdY => 'A165211', # 0,1,0,1, 1,0,1,0, repeating
       # OEIS-Other: A165211 planepath=DragonCurve,arms=4 delta_type=AbsdY
     },
    };
}
{ package Math::PlanePath::DragonRounded;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dSumAbs_min => -2;
  use constant _NumSeq_Delta_dSumAbs_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;
  use constant _NumSeq_Delta_DSquared_max => 2;

  use constant _NumSeq_Delta_oeis_anum =>
    { 'arms=1' =>
      { AbsdX => 'A152822', # 1,1,0,1 repeating
        AbsdY => 'A166486', # 0,1,1,1 repeating
        # OEIS-Catalogue: A166486 planepath=DragonRounded delta_type=AbsdY
        # OEIS-Catalogue: A152822 planepath=DragonRounded delta_type=AbsdX
      },
    };
}
{ package Math::PlanePath::DragonMidpoint;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dSumAbs_min => -1;
  use constant _NumSeq_Delta_dSumAbs_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;
  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;

  # use constant _NumSeq_Delta_oeis_anum =>
  # '' =>
  # {
  #  # Not quite, has n=N+2 and extra initial 0 at n=1
  #  # AbsdY => 'A073089',
  # },
}
{ package Math::PlanePath::R5DragonCurve;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dSumAbs_min => -1;
  use constant _NumSeq_Delta_dSumAbs_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;

  use constant _NumSeq_Delta_oeis_anum =>
    { do {
      my $href =
        { AbsdX => 'A059841', # 1,0 repeating
          AbsdY => 'A000035', # 0,1 repeating
        };
      ('arms=1' => $href,
       'arms=3' => $href,
      );
      # OEIS-Other: A059841 planepath=R5DragonCurve delta_type=AbsdX
      # OEIS-Other: A000035 planepath=R5DragonCurve delta_type=AbsdY
      # OEIS-Other: A059841 planepath=R5DragonCurve,arms=3 delta_type=AbsdX
      # OEIS-Other: A000035 planepath=R5DragonCurve,arms=3 delta_type=AbsdY
    },
      'arms=4' =>
      { AbsdY => 'A165211', # 0,1,0,1, 1,0,1,0, repeating
        # OEIS-Other: A165211 planepath=R5DragonCurve,arms=4 delta_type=AbsdY
      },
    };
}
{ package Math::PlanePath::R5DragonMidpoint;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dSumAbs_min => -1;
  use constant _NumSeq_Delta_dSumAbs_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::CCurve;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dSumAbs_min => -1;
  use constant _NumSeq_Delta_dSumAbs_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;
  use constant _NumSeq_Delta_Dir4_integer => 1; # NSEW

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;

  use constant _NumSeq_Delta_oeis_anum =>
    { '' =>
      { AbsdX => 'A010059', # 0,1 repeating
        AbsdY => 'A010060', # 1-bit count mod 2, DigitSumModulo Thue-Morse
        Dir4  => 'A179868', # 1-bit count mod 4, DigitSumModulo
        # OEIS-Catalogue: A010059 planepath=CCurve delta_type=AbsdX
        # OEIS-Other:     A010060 planepath=CCurve delta_type=AbsdY
        # OEIS-Other:     A179868 planepath=CCurve delta_type=Dir4
      },
    };
}
{ package Math::PlanePath::AlternatePaper;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dSumAbs_min => -1;
  use constant _NumSeq_Delta_dSumAbs_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;

  use constant _NumSeq_Delta_oeis_anum =>
    { 'arms=1' =>
      { AbsdY    => 'A000035', # 0,1 repeating
        dSum     => 'A020985', # GRS
        dSumAbs  => 'A020985', # GRS
        # OEIS-Other: A000035 planepath=AlternatePaper delta_type=AbsdY
        # OEIS-Other: A020985 planepath=AlternatePaper delta_type=dSum
        # OEIS-Other: A020985 planepath=AlternatePaper delta_type=dSumAbs

        # dX_every_second_point_skipping_zeros => 'A020985', # GRS
        #  # ie. Math::NumSeq::GolayRudinShapiro
      },

      'arms=4' =>
      { dSum  => 'A020985', # GRS
        # OEIS-Other: A020985 planepath=AlternatePaper,arms=4 delta_type=dSum
      },
    };
}
{ package Math::PlanePath::AlternatePaperMidpoint;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dSumAbs_min => -1;
  use constant _NumSeq_Delta_dSumAbs_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::TerdragonCurve;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dSumAbs_min => -2;
  use constant _NumSeq_Delta_dSumAbs_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;

  use constant _NumSeq_Delta_TDir6_integer => 1;

  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_DSquared_max => 4;
  use constant _NumSeq_Delta_TDist_non_decreasing => 1;  # triangular
  use constant _NumSeq_Delta_TDSquared_max => 4;  # triangular
}
{ package Math::PlanePath::TerdragonRounded;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dSumAbs_min => -2;
  use constant _NumSeq_Delta_dSumAbs_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;
  use constant _NumSeq_Delta_TDir6_integer => 1;

  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_DSquared_max => 4;
  use constant _NumSeq_Delta_TDist_non_decreasing => 1;  # triangular
  use constant _NumSeq_Delta_TDSquared_max => 4;             # triangular
}
{ package Math::PlanePath::TerdragonMidpoint;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dSumAbs_min => -2;
  use constant _NumSeq_Delta_dSumAbs_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;

  use constant _NumSeq_Delta_TDir6_integer => 1;

  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_DSquared_max => 4;
  use constant _NumSeq_Delta_TDist_non_decreasing => 1;  # triangular
  use constant _NumSeq_Delta_TDSquared_max => 4;             # triangular
}
{ package Math::PlanePath::ComplexPlus;
  use constant _NumSeq_Dir4_max_is_supremum => 1;
}
{ package Math::PlanePath::ComplexMinus;
  use constant _NumSeq_Dir4_max_is_supremum => 1;
}
{ package Math::PlanePath::ComplexRevolving;
  use constant _NumSeq_Dir4_max_is_supremum => 1;
}
{ package Math::PlanePath::Rows;
  sub _NumSeq_Delta_dX_non_decreasing {
    my ($self) = @_;
    return ($self->{'width'} <= 1
           ? 1  # single column only, dX=0 always
           : 0);
  }
  sub _NumSeq_Delta_AbsdX_non_decreasing {
    my ($self) = @_;
    return ($self->{'width'} <= 2); # 1 or 2 is constant 0 or 1
  }

  sub _NumSeq_Delta_dSum_min {
    my ($self) = @_;
    return 2 - $self->{'width'}; # dX=-(width-1) dY=+1
  }
  use constant _NumSeq_Delta_dSum_max => 1;

  sub _NumSeq_Delta_dDiffXY_min {
    my ($self) = @_;
    # dX=-(width-1) dY=+1 dDiffXY=-width+1-1=-width
    return - $self->{'width'};
  }
  sub _NumSeq_Delta_dDiffXY_max {
    my ($self) = @_;
    return ($self->{'width'} == 1
            ? -1  # constant dY=-1
            : 1); # straight E
  }

  # abs(X-Y) move towards and then away from X=Y diagonal by +1 and -1 in row,
  # then at row end to Y axis goes
  #    from X=width-1, Y=k      AbsDiff = abs(k-(width-1))
  #    to   X=0,       Y=k+1    AbsDiff = k+1
  #    dAbsDiff = k+1 - abs(k-(width-1))
  #    when k>=width-1  dAbsDiff = k+1 - (k-(width-1))
  #                              = k+1 - k + (width-1)
  #                              = 1 + width-1
  #                              = width
  #    when k<=width-1  dAbsDiff = k+1 - ((width-1)-k)
  #                              = k+1 - (width-1) + k
  #                              = 2k+1 - width + 1
  #                              = 2k+2 - width
  #      at k=0       dAbsDiff = 2-width
  #      at k=width-1 dAbsDiff = 2*(width-1)+2 - width
  #                            = 2*width - 2 + 2 - width
  #                            = width
  #    minimum = 2-width or -1
  #    maximum = width
  #
  sub _NumSeq_Delta_dAbsDiff_min {
    my ($self) = @_;
    if ($self->{'width'} == 1) { return 1; } # constant dAbsDiff=1
    return List::Util::min(-1, 2 - $self->{'width'});
  }
  sub _NumSeq_Delta_dAbsDiff_max {
    my ($self) = @_;
    return $self->{'width'};
  }

  *_NumSeq_Delta_dY_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_AbsdY_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_dSum_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_Dir4_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_TDir6_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_Dist_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_TDist_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_dDiffXY_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_dDiffYX_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_dAbsDiff_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_dSumAbs_non_decreasing # width=1 is dSumAbs=constant
    = \&_NumSeq_Delta_dX_non_decreasing;

  *_NumSeq_Delta_Dir4_integer = \&_NumSeq_Delta_dX_non_decreasing;
  sub _NumSeq_Delta_TDir6_integer {
    my ($self) = @_;
    return ($self->{'width'} == 2); # E and NW
  }

  use constant _NumSeq_Delta_oeis_anum =>
    { 'n_start=1,width=1' =>
      { dX   => 'A000004', # all zeros, X=0 always
        dY   => 'A000012', # all 1s
        Dir4 => 'A000012', # all 1s, North
        # OEIS-Other: A000004 planepath=Rows,width=1 delta_type=dX
        # OEIS-Other: A000012 planepath=Rows,width=1 delta_type=dY
        # OEIS-Other: A000012 planepath=Rows,width=1 delta_type=Dir4
      },
      'n_start=0,width=2' =>
      { dX    => 'A033999', # 1,-1 repeating, OFFSET=0
        TDir6 => 'A010673', # 0,2 repeating, OFFSET=0
        # catalogued here pending perhaps simpler implementation elsewhere
        # OEIS-Catalogue: A033999 planepath=Rows,width=2,n_start=0 delta_type=dX
        # OEIS-Catalogue: A010673 planepath=Rows,width=2,n_start=0 delta_type=TDir6
      },
      'n_start=1,width=3' =>
      { dX   => 'A061347', # 1,1,-2 repeating OFFSET=1
        # OEIS-Catalogue: A061347 planepath=Rows,width=3 delta_type=dX
      },
      'n_start=0,width=3' =>
      { dSum    => 'A131561', # 1,1,-1 repeating
        dSumAbs => 'A131561', # same
        # OEIS-Catalogue: A131561 planepath=Rows,width=3,n_start=0 delta_type=dSum
        # OEIS-Other:     A131561 planepath=Rows,width=3,n_start=0 delta_type=dSumAbs

      # dY   => 'A022003', # 0,0,1 repeating, decimal of 1/999
      # # OEIS-Other: A022003 planepath=Rows,width=3 delta_type=dY
      },
      'n_start=1,width=4' =>
      { dY   => 'A011765', # 0,0,0,1 repeating, starting OFFSET=1
        # OEIS-Other: A011765 planepath=Rows,width=4 delta_type=dY
      },
      # OFFSET
      # 'n_start=1,width=6' =>
      # { dY   => 'A172051', # 0,0,0,0,0,1 repeating decimal 1/999999
      #   # OEIS-Other: A172051 planepath=Rows,width=6 delta_type=dY
      # },
    };
}

{ package Math::PlanePath::Columns;
  sub _NumSeq_Delta_AbsdY_non_decreasing {
    my ($self) = @_;
    return ($self->{'height'} <= 2); # 1 or 2 is constant
  }

  sub _NumSeq_Delta_dSum_min {
    my ($self) = @_;
    return 2 - $self->{'height'}; # dX=+1 dY=-(height-1)
  }
  use constant _NumSeq_Delta_dSum_max => 1;

  sub _NumSeq_Delta_dDiffXY_min {
    my ($self) = @_;
    return ($self->{'height'} == 1
            ? 1    # constant dX=1,dY=0
            : -1); # straight N
  }
  sub _NumSeq_Delta_dDiffXY_max {
    my ($self) = @_;
    return $self->{'height'}; # dX=+1 dY=-(height-1)
  }

  # same as Rows dAbsDiff
  sub _NumSeq_Delta_dAbsDiff_min {
    my ($self) = @_;
    if ($self->{'height'} == 1) { return 1; } # constant dAbsDiff=1
    return List::Util::min(-1, 2 - $self->{'height'});
  }
  sub _NumSeq_Delta_dAbsDiff_max {
    my ($self) = @_;
    return $self->{'height'};
  }

  sub _NumSeq_Delta_TDSquared_min {
    my ($self) = @_;
    return ($self->{'height'} == 1
            ? 1    # horizontal
            : 3);  # vertical
  }

  sub _NumSeq_Delta_dX_non_decreasing {
    my ($self) = @_;
    return ($self->{'height'} == 1); # constant when column only
  }
  *_NumSeq_Delta_dY_non_decreasing      = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_AbsdX_non_decreasing   = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_dSum_non_decreasing    = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_dDiffXY_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_dDiffYX_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_dAbsDiff_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_dSumAbs_non_decreasing # height=1 is dSumAbs=constant
    = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_Dir4_non_decreasing    = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_TDir6_non_decreasing   = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_Dist_non_decreasing    = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_TDist_non_decreasing   = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_Dir4_integer           = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_TDir6_integer          = \&_NumSeq_Delta_dX_non_decreasing;

  use constant _NumSeq_Delta_oeis_anum =>
    { 'n_start=1,height=1' =>
      { dX     => 'A000012', # all 1s
        dY     => 'A000004', # all zeros, Y=0 always
        Dir4   => 'A000004', # all zeros, East
        TDir6  => 'A000004', # all zeros, East
        # OEIS-Other: A000012 planepath=Columns,height=1 delta_type=dX
        # OEIS-Other: A000004 planepath=Columns,height=1 delta_type=dY
        # OEIS-Other: A000004 planepath=Columns,height=1 delta_type=Dir4
        # OEIS-Other: A000004 planepath=Columns,height=1 delta_type=TDir6
      },
      'n_start=0,height=2' =>
      { dY      => 'A033999', # 1,-1 repeating
        dSum    => 'A059841', # 1,0 repeating, 1-n mod 2
        dSumAbs => 'A059841', # same
        # OEIS-Other: A033999 planepath=Columns,height=2,n_start=0 delta_type=dY
        # OEIS-Other: A059841 planepath=Columns,height=2,n_start=0 delta_type=dSum
        # OEIS-Other: A059841 planepath=Columns,height=2,n_start=0 delta_type=dSumAbs
      },
      'n_start=0,height=3' =>
      { dSum    => 'A131561', # 1,1,-1 repeating
        dSumAbs => 'A131561', # same
        # OEIS-Other: A131561 planepath=Columns,height=3,n_start=0 delta_type=dSum
        # OEIS-Other: A131561 planepath=Columns,height=3,n_start=0 delta_type=dSumAbs
      },
      'n_start=1,height=3' =>
      { dY   => 'A061347', # 1,1,-2 repeating
        # OEIS-Other: A061347 planepath=Columns,height=3 delta_type=dY

        # dX   => 'A022003', # 0,0,1 repeating from frac 1/999
        # # OEIS-Other: A022003 planepath=Columns,height=3 delta_type=dX
      },
      'n_start=1,height=4' =>
      { dX   => 'A011765', # 0,0,0,1 repeating, starting OFFSET=1
        # OEIS-Other: A011765 planepath=Columns,height=4 delta_type=dX
      },
      # OFFSET
      # 'n_start=1,height=6' =>
      # { dX   => 'A172051', # 0,0,0,1 repeating, starting n=0
      #   # OEIS-Other: A172051 planepath=Columns,height=6 delta_type=dX
      # },
    };
}

{ package Math::PlanePath::Diagonals;
  use constant _NumSeq_Delta_dSum_min => 0; # advancing diagonals
  use constant _NumSeq_Delta_dSum_max => 1;

  sub _NumSeq_Delta_dDiffXY_min {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down'
            ? undef  # "down" jumps back unlimited at bottom
            : -2);   # NW diagonal
  }
  sub _NumSeq_Delta_dDiffXY_max {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down'
            ? 2       # SE diagonal
            : undef); # "up" jumps down unlimited at top
  }

  # step 2 along opp diagonal, except end of row jumping back up goes
  #
  #           | T             step = 2*(F-Xstart)+1
  #           | \     X=Y     F = Ystart
  #           | |\   /        eg. Xstart=20 Ystart=10
  #           | | \ /         step = 2*(10-20)+1 = -19
  #           | +--F    
  #           |   /
  #           |  /
  #           | /
  #           |/
  #           +--------
  sub _NumSeq_Delta_dAbsDiff_min {
    my ($self) = @_;
    return List::Util::min (-2, # towards X=Y diagonal
                            ($self->{'direction'} eq 'down' ? 2 : -2)
                            * ($self->{'y_start'} - $self->{'x_start'}) + 1);
  }
  sub _NumSeq_Delta_dAbsDiff_max {
    my ($self) = @_;
    return List::Util::max (2,  # away from X=Y diagonal
                            ($self->{'direction'} eq 'down' ? 2 : -2)
                            * ($self->{'y_start'} - $self->{'x_start'}) + 1);

  }

  sub _NumSeq_Delta_TDSquared_min {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down'
            ? 3      # N=1 dX=0,dY=1 vertical
            : 1);    # N=1 dX=0,dY=1 horizontal
  }

  use constant _NumSeq_Delta_oeis_anum =>
    { 'direction=down,n_start=1,x_start=0,y_start=0' =>
      { dY    => 'A127949',
        # OEIS-Catalogue: A127949 planepath=Diagonals delta_type=dY
      },
      'direction=up,n_start=1,x_start=0,y_start=0' =>
      { dX    => 'A127949',
        # OEIS-Other: A127949 planepath=Diagonals,direction=up delta_type=dX
      },

      'direction=down,n_start=0,x_start=0,y_start=0' =>
      { AbsdY   => 'A051340',
        dSum    => 'A023531', # characteristic "1" at triangulars
        dSumAbs => 'A023531', # same
        # OEIS-Catalogue: A051340 planepath=Diagonals,n_start=0 delta_type=AbsdY
        # OEIS-Other:     A023531 planepath=Diagonals,n_start=0 delta_type=dSum
        # OEIS-Other:     A023531 planepath=Diagonals,n_start=0 delta_type=dSumAbs
      },
      'direction=up,n_start=0,x_start=0,y_start=0' =>
      { AbsdX => 'A051340',
        dSum    => 'A023531', # characteristic "1" at triangulars
        dSumAbs => 'A023531', # same
        # OEIS-Other: A051340 planepath=Diagonals,direction=up,n_start=0 delta_type=AbsdX
        # OEIS-Other: A023531 planepath=Diagonals,direction=up,n_start=0 delta_type=dSum
        # OEIS-Other: A023531 planepath=Diagonals,direction=up,n_start=0 delta_type=dSumAbs

        # Almost AbsdY=>'A051340' too, but path starts initial 0,1,1 whereas
        # A051340 starts 1,1,2
      },
    };
}
{ package Math::PlanePath::DiagonalsAlternating;
  use constant _NumSeq_Delta_dSum_min => 0; # advancing diagonals
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -2; # NW diagonal
  use constant _NumSeq_Delta_dDiffXY_max => 2;  # SE diagonal
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;
  use constant _NumSeq_Delta_DSquared_max => 2;

  use constant _NumSeq_Delta_oeis_anum =>
    { 'n_start=0' =>
      { dSum    => 'A023531', # characteristic "1" at triangulars
        dSumAbs => 'A023531', # same
        # OEIS-Other: A023531 planepath=DiagonalsAlternating,n_start=0 delta_type=dSum
        # OEIS-Other: A023531 planepath=DiagonalsAlternating,n_start=0 delta_type=dSumAbs
      },
    };
}
{ package Math::PlanePath::DiagonalsOctant;
  use constant _NumSeq_Delta_dSum_min => 0; # advancing diagonals
  use constant _NumSeq_Delta_dSum_max => 1;

  sub _NumSeq_Delta_dDiffXY_min {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down'
            ? undef  # "down" jumps back unlimited at bottom
            : -2);   # NW diagonal
  }
  sub _NumSeq_Delta_dDiffXY_max {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down'
            ? 2       # SE diagonal
            : undef); # "up" jumps down unlimited at top
  }

  sub _NumSeq_Delta_dAbsDiff_min {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down'
            ? -2      # "down"
            : undef); # "up"
  }
  sub _NumSeq_Delta_dAbsDiff_max {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down'
            ? undef   # "down"
            : 2);     # "up"
  }

  sub _NumSeq_Delta_TDSquared_min {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down'
            ? 3      # N=1 dX=0,dY=1 vertical
            : 1);    # N=1 dX=0,dY=1 horizontal
  }
}
{ package Math::PlanePath::MPeaks;
  use constant _NumSeq_Delta_dSum_max => 2; # NE diagonal
  use constant _NumSeq_Delta_dDiffXY_max => 2; # SE diagonal
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;
  use constant _NumSeq_Delta_TDSquared_min => 3; # vertical
}
{ package Math::PlanePath::Staircase;
  use constant _NumSeq_Delta_dSum_min => -1; # straight S
  use constant _NumSeq_Delta_dSum_max => 2;  # next row
  use constant _NumSeq_Delta_dDiffXY_max => 1; # straight S,E
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;
}
{ package Math::PlanePath::StaircaseAlternating;
  use constant _NumSeq_Delta_dSum_min => -1; # straight S
  *_NumSeq_Delta_dSum_max = \&dx_maximum;

  {
    my %dDiffXY_max = (jump   => -2,
                       square => -1);
    sub _NumSeq_Delta_dDiffXY_min {
      my ($self) = @_;
      return $dDiffXY_max{$self->{'end_type'}};
    }
  }
  *_NumSeq_Delta_dDiffXY_max = \&dx_maximum;

  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  {
    my %_NumSeq_Delta_dAbsDiff_max = (jump   => 2,  # at endpoint
                                      square => 1); # always NSEW
    sub _NumSeq_Delta_dAbsDiff_max {
      my ($self) = @_;
      return $_NumSeq_Delta_dAbsDiff_max{$self->{'end_type'}};
    }
  }
  {
    my %DSquared_max = (jump   => 4,
                        square => 1);
    sub _NumSeq_Delta_DSquared_max {
      my ($self) = @_;
      return $DSquared_max{$self->{'end_type'}};
    }
  }
  {
    my %Dist_non_decreasing = (jump   => 0,
                               square => 1); # NSEW always
    sub _NumSeq_Delta_Dist_non_decreasing {
      my ($self) = @_;
      return $Dist_non_decreasing{$self->{'end_type'}};
    }
  }
  {
    my %TDSquared_max = (jump   => 12,
                         square => 3);
    sub _NumSeq_Delta_TDSquared_max {
      my ($self) = @_;
      return $TDSquared_max{$self->{'end_type'}};
    }
  }

  use constant _NumSeq_Delta_Dir4_integer => 1;
}
{ package Math::PlanePath::Corner;
  use List::Util;
  # dSum minimum either south dX=0,dy=-1 for dSum=-1
  # or end gnomon up to start of next gnomon is
  #    X=wider+k,Y=0 to X=0,Y=k+1
  #    dsum = 0-(wider+k) + (k+1)-0
  #         = -wider-k + k + 1
  #         = 1-wider
  sub _NumSeq_Delta_dSum_min {
    my ($self) = @_;
    return List::Util::min(-1, 1-$self->{'wider'});
  }
  use constant _NumSeq_Delta_dSum_max => 1;  # next row
  use constant _NumSeq_Delta_dDiffXY_max => 1;  # straight S,E

  # X=k+wider, Y=0 has abs(X-Y)=k+wider
  # X=0, Y=k+1     has abs(X-Y)=k+1
  # dAbsDiff = (k+1)-(k+wider)
  #          = 1-wider
  # and also dAbsDiff=-1 when going towards X=Y diagonal
  sub _NumSeq_Delta_dAbsDiff_min {
    my ($self) = @_;
    return List::Util::min(-1, 1-$self->{'wider'});
  }
  use constant _NumSeq_Delta_dAbsDiff_max => 1;

  *_NumSeq_Delta_dSumAbs_min = \&_NumSeq_Delta_dSum_min;
  use constant _NumSeq_Delta_dSumAbs_max => 1;  # next row

  # use constant _NumSeq_Delta_oeis_anum =>
  #   { 'wider=0,n_start=0' =>
  #     { dSumAbs => 'A000012',   # all ones, OFFSET=0
  #       # OEIS-Other: A000012 planepath=Corner delta_type=dSumAbs
  #     },
  #   };
}
{ package Math::PlanePath::PyramidRows;
  # within row X increasing dSum=1
  # end row decrease by big
  sub _NumSeq_Delta_dSum_min {
    my ($self) = @_;
    return ($self->{'step'} == 0 ? 1 : undef);
  }
  use constant _NumSeq_Delta_dSum_max => 1;
  sub _NumSeq_Delta_dSum_non_decreasing {
    my ($self) = @_;
    return ($self->{'step'} == 0); # constant when column only
  }

  # align=right
  #   X>=0 so SumAbs=Sum
  #   within row X increasing dSum=1
  #   end row decrease by big
  #   minimum = undef
  #   maximum = 1
  #
  # align=left
  #   within dSumAbs=-1 towards Y axis then dSumAbs=1 away
  #   end row X=0,Y=k              SumAbs=k
  #        to X=-step*(k+1),Y=k+1  SumAbs=step*(k+1) + (k+1)
  #   dSumAbs = step*(k+1) + (k+1) - k
  #           = step*k + step + k + 1 - k
  #           = step*(k+1) + 1    big positive
  #   minimum = -1
  #   maximum = undef
  #
  # align=centre, step=even
  #   within dSumAbs=-1 towards Y axis then dSumAbs=1 away
  #   end row X=k*step/2, Y=k        SumAbs=k*step/2 + k
  #        to X=-step/2*(k+1),Y=k+1  SumAbs=step/2*(k+1) + k+1
  #   dSumAbs = step/2*(k+1) + k+1 - (k*step/2 + k)
  #           = step/2*(k+1) + k+1 - k*step/2 - k
  #           = step/2*(k+1) +1 - k*step/2
  #           = step/2 +1
  #   minimum = -1
  #   maximum = step/2 +1
  #
  # align=centre, step=odd
  #   f=floor(step/2) c=ceil(step/2)=f+1
  #   within dSumAbs=-1 towards Y axis then dSumAbs=1 away
  #   end row X=k*c, Y=k         SumAbs=k*c + k
  #        to X=-f*(k+1),Y=k+1  SumAbs=f*(k+1) + k+1
  #   dSumAbs = f*(k+1) + k+1 - (k*c + k)
  #           = f*(k+1) + k+1 - k*(f+1) - k
  #           = f*k +f + k+1 - k*f - k - k
  #           = f + 1 - k
  #           = (step+1)/2 - k
  #   minimum = big negative
  #   maximum = floor(step/2) + 1   when k=0 first end row
  #
  sub _NumSeq_Delta_dSumAbs_min {
    my ($self) = @_;
    if ($self->{'step'} == 0) {
      return 1;         # step=0 constant dSumAbs=1
    }
    if ($self->{'align'} eq 'left'
        || ($self->{'align'} eq 'centre' && $self->{'step'} % 2 == 0)) {
      return -1;     # towards Y axis
    }
    return undef;  # big negatives
  }
  sub _NumSeq_Delta_dSumAbs_max {
    my ($self) = @_;
    if ($self->{'step'} == 0
        || $self->{'align'} eq 'right') {
      return 1;    
    }
    if ($self->{'align'} eq 'centre') {
      return int($self->{'step'}/2) + 1;
    }
    return undef;
  }

  sub _NumSeq_Delta_dDiffXY_min {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? -1      # constant N dY=1
            : undef);
  }
  sub _NumSeq_Delta_dDiffXY_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? -1      # constant N dY=1
            : 1);
  }

  # abs(X-Y) move towards and then away from X=Y diagonal by +1 and -1 in row
  #
  # align=left
  #    towards X=Y diagonal so dAbsDiff=-1
  #    from X=0,Y=k               AbsDiff = k
  #    to   X=-(k+1)*step,Y=k+1   AbsDiff = k+1 - (-(k+1)*step)
  #    dAbsDiff = k+1 - (-(k+1)*step) - k
  #             = step*(k+1) + 1      big positive
  #
  # align=right
  #    step<=1 only towards X=Y diagonal dAbsDiff=-1
  #    step>=2 away from  X=Y diagonal   dAbsDiff=+1
  #    from X=k*step,Y=k   AbsDiff = k*step - k
  #    to   X=0,Y=k+1      AbsDiff = k+1
  #    dAbsDiff = k+1 - (k*step - k)
  #             = -(step-2)*k + 1
  #    step=1 dAbsDiff = k+1       big positive
  #    step=2 dAbsDiff = 1
  #    step=3 dAbsDiff = -k + 1    big negative
  # 
  sub _NumSeq_Delta_dAbsDiff_min {
    my ($self) = @_;
    if ($self->{'step'} == 0) {      # constant N dY=1
      return 1;
    }
    if ($self->{'align'} eq 'right' && $self->{'step'} >= 3) {
      return undef;  # big negative
    }
    return -1;
  }
  sub _NumSeq_Delta_dAbsDiff_max {
    my ($self) = @_;
    if ($self->{'step'} == 0) {      # constant N dY=1
      return 1;
    }
    if ($self->{'align'} eq 'right' && $self->{'step'} >= 2) {
      return 1;
    }
    return undef;
  }
  *_NumSeq_Delta_dAbsDiff_non_decreasing = \&_NumSeq_Delta_dSum_non_decreasing;

  *_NumSeq_Delta_AbsdX_non_decreasing = \&_NumSeq_Delta_dSum_non_decreasing;
  *_NumSeq_Delta_AbsdY_non_decreasing = \&_NumSeq_Delta_dSum_non_decreasing;
  *_NumSeq_Delta_dDiffXY_non_decreasing = \&_NumSeq_Delta_dSum_non_decreasing;
  *_NumSeq_Delta_dDiffYX_non_decreasing = \&_NumSeq_Delta_dSum_non_decreasing;
  *_NumSeq_Delta_dSumAbs_non_decreasing = \&_NumSeq_Delta_dSum_non_decreasing;

  sub _NumSeq_Delta_DSquared_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 1    # X=0 vertical only
            : undef);
  }

  sub _NumSeq_Dir4_max_is_supremum {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 0    # north only, exact
            : 1);  # supremum, west and 1 up
  }
  sub _NumSeq_Delta_Dir4_integer {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 1    # North only, integer
            : 0);  # otherwise fraction
  }

  sub _NumSeq_Delta_dX_non_decreasing {
    my ($self) = @_;
    return ($self->{'step'} == 0);  # step=0 is dX=0,dY=1 always
  }
  *_NumSeq_Delta_dY_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_Dir4_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_TDir6_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_Dist_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_TDist_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;

  use constant _NumSeq_Delta_oeis_anum =>
    {
     # PyramidRows step=0 is trivial X=0,Y=N
     do {
       my $href = { dX    => 'A000004',  # all zeros, X=0 always
                    dY    => 'A000012',  # all 1s
                    Dir4  => 'A000012',  # all 1s, North
                  };
       ('step=0,align=centre,n_start=1' => $href,
        'step=0,align=right,n_start=1'  => $href,
        'step=0,align=left,n_start=1'   => $href,
       );

       # OEIS-Other: A000004 planepath=PyramidRows,step=0 delta_type=dX
       # OEIS-Other: A000012 planepath=PyramidRows,step=0 delta_type=dY
       # OEIS-Other: A000012 planepath=PyramidRows,step=0 delta_type=Dir4
     },

     # PyramidRows step=1
     do {   # n_start=1
       my $href = { dDiffYX  => 'A127949',
                    dAbsDiff => 'A127949',  # Y>=X so same as dDiffYX
                  };
       ('step=1,align=centre,n_start=1' => $href,
        'step=1,align=right,n_start=1'  => $href,
       );
       # OEIS-Other: A127949 planepath=PyramidRows,step=1 delta_type=dDiffYX
       # OEIS-Other: A127949 planepath=PyramidRows,step=1 delta_type=dAbsDiff
       # OEIS-Other: A127949 planepath=PyramidRows,step=1,align=right delta_type=dDiffYX
       # OEIS-Other: A127949 planepath=PyramidRows,step=1,align=right delta_type=dAbsDiff
     },
     do {   # n_start=0
       my $href =
         { dY      => 'A023531',  # 1,0,1,0,0,1,etc, 1 if n==k(k+3)/2
           AbsdY   => 'A023531',  # abs(dy) same

           # Not quite, A167407 has an extra initial 0
           # dDiffXY => 'A167407',
         };
       ('step=1,align=centre,n_start=0' => $href,
        'step=1,align=right,n_start=0'  => $href,
       );
       # OEIS-Catalogue: A023531 planepath=PyramidRows,step=1,n_start=0 delta_type=dY
       # OEIS-Other:     A023531 planepath=PyramidRows,step=1,n_start=0 delta_type=AbsdY

       # OEIS-Other: A023531 planepath=PyramidRows,step=1,align=right,n_start=0 delta_type=dY
       # OEIS-Other: A023531 planepath=PyramidRows,step=1,align=right,n_start=0 delta_type=AbsdY
     },
     'step=1,align=left,n_start=0' =>
     { dY      => 'A023531',  # 1,0,1,0,0,1,etc, 1 if n==k(k+3)/2
       AbsdY   => 'A023531',  # abs(dy) same
       # OEIS-Other: A023531 planepath=PyramidRows,step=1,align=left,n_start=0 delta_type=dY
       # OEIS-Other: A023531 planepath=PyramidRows,step=1,align=left,n_start=0 delta_type=AbsdY
     },

     # 'step=2,align=centre,n_start=0' =>
     # {
     #  # Not quite, extra initial 0
     #  # dDiffXY      => 'A010052',
     # },
    };
}
{ package Math::PlanePath::PyramidSides;
  use constant _NumSeq_Delta_dSum_max => 2; # NE diagonal
  use constant _NumSeq_Delta_dSumAbs_min => 0; # unchanged on diagonal
  use constant _NumSeq_Delta_dSumAbs_max => 1; # step to next diagonal
  use constant _NumSeq_Delta_dDiffXY_max => 2; # SE diagonal
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;
  use constant _NumSeq_Delta_TDir6_integer => 1;

  use constant _NumSeq_Delta_oeis_anum =>
    { 'n_start=1' =>
      { AbsdY => 'A049240', # 0=square,1=non-square
        # OEIS-Catalogue: A049240 planepath=PyramidSides delta_type=AbsdY

        # Not quite, extra initial 1 in A010052
        # dSumAbs => 'A010052', 1 at n=square
      },
    };
}
{ package Math::PlanePath::CellularRule;
  sub _NumSeq_Delta_dSum_min {
    my ($self) = @_;
    return (($self->{'rule'} & 0x5F) == 0x54  # right line 2, const dSum=+1
            ? 1
            : undef);
  }
  sub _NumSeq_Delta_dSum_max {
    my ($self) = @_;
    return (($self->{'rule'} & 0x5F) == 0x54  # right line 2
            ? 1                               #   is constant dSum=+1
            : undef);
  }
  sub _NumSeq_Delta_dSum_non_decreasing {
    my ($self) = @_;
    return (($self->{'rule'} & 0x5F) == 0x54  # right line 2
            ? 1                               #   is constant dSum=+1
            : undef);
  }
  sub _NumSeq_Delta_dSumAbs_non_decreasing {
    my ($self) = @_;
    return (($self->{'rule'} & 0x5F) == 0x54  # right line 2
            ? 1                               #  is constant dSumAbs=1
            : undef);
  }

  sub _NumSeq_Delta_dAbsDiff_min {
    my ($self) = @_;
    return (($self->{'rule'} & 0x5F) == 0x54  # right line 2
            ? -1

            : ($self->{'rule'} & 0x5F) == 0x0E  # left line 2
            ? -1

            : ($self->{'rule'} & 0xDF) == 3  # rule=3,35
            ? -3

            : $self->{'rule'} == 5
            ? -2

            : $self->{'rule'} == 7
            ? -1

            : $self->{'rule'} == 9
            ? -2

            : ($self->{'rule'} & 0xDF) == 11  # rule=11,43
            ? -1

            : $self->{'rule'} == 13
            ? -2

            : $self->{'rule'} == 15
            ? -1

            : ($self->{'rule'} & 0xDF) == 17  # rule=17,49
            ? -3

            : $self->{'rule'} == 19
            ? -2

            : $self->{'rule'} == 21
            ? -1

            : ($self->{'rule'} & 0x97) == 23 # rule=23,31,55,63,87,95,119,127
            ? -1

            : $self->{'rule'} == 27
            ? -2

            : $self->{'rule'} == 29
            ? -2

            : undef);
  }
  sub _NumSeq_Delta_dAbsDiff_max {
    my ($self) = @_;
    return (($self->{'rule'} & 0x5F) == 0x54  # right line 2
            ? 1 

            : ($self->{'rule'} & 0x5F) == 0x0E  # left line 2
            ? 3

            : undef);
  }

  sub _NumSeq_Dir4_max_is_supremum {
    my ($self) = @_;
    return (($self->{'rule'} & 0x5F) == 0x54  # right line 2
            || ($self->{'rule'} & 0x5F) == 0x0E  # left line 2
            ? 0
            : 1);  # supremum
  }
  sub _NumSeq_Delta_Dir4_integer {
    my ($self) = @_;
    return (($self->{'rule'} & 0x5F) == 0x54  # right line 2
            ? 1    # N,E only
            : 0);  # various diagonals
  }

  sub _NumSeq_Delta_dY_non_decreasing {
    my ($self) = @_;
    return (($self->{'rule'} & 0x17) == 0        # single cell only
            ? 1
            : 0);
  }

  use constant _NumSeq_Delta_oeis_anum =>
    { do {  # 14,46,142,174   left line 2
      my $href
        = { dSum => 'A062157', # 0 then 1,-1 repeating
            # OEIS-Catalogue: A062157 planepath=CellularRule,rule=14 delta_type=dSum
          };
      ('rule=14'  => $href,
       'rule=46'  => $href,
       'rule=142' => $href,
       'rule=174' => $href)
    },
    };
}
{ package Math::PlanePath::CellularRule::OneTwo;
  use constant _NumSeq_Dir4_max_is_supremum => 0;

  sub _NumSeq_Delta_dSum_min {
    my ($self) = @_;
    return ($self->{'sign'} < 0
            ? -1   # left, ENE
            : 1);  # right, N, going as a stairstep so always increase
  }
  sub _NumSeq_Delta_dSum_max {
    my ($self) = @_;
    return ($self->{'sign'} < 0
            ? 1   # left, East
            : 2); # right, NE diagonal
  }
  use constant _NumSeq_Delta_dSum_non_decreasing => 0;

  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  sub _NumSeq_Delta_dAbsDiff_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'left' ? 3 : 1);
  }

  use constant _NumSeq_Delta_oeis_anum =>
    { 'align=right,n_start=0' =>
      { dSumAbs => 'A177702', # 1,1,2 repeating, OFFSET=0
        # OEIS-Catalogue: A177702 planepath=CellularRule,rule=20,n_start=0 delta_type=dSumAbs
      },
      'align=left,n_start=0' =>
      { AbsdX   => 'A177702', # 1,1,2 repeating, OFFSET=0
        dSum    => 'A102283', # 0,1,-1 repeating, OFFSET=0
        dSumAbs => 'A131756', # 2,-1,3 repeating, OFFSET=0
        # OEIS-Other: A177702 planepath=CellularRule,rule=6,n_start=0 delta_type=AbsdX
        # OEIS-Catalogue: A102283 planepath=CellularRule,rule=6,n_start=0 delta_type=dSum
        # OEIS-Catalogue: A131756 planepath=CellularRule,rule=6,n_start=0 delta_type=dSumAbs
      },
    };
}
{ package Math::PlanePath::CellularRule::Line;
  # constant left   => 2
  #          centre => 1
  #          right  => 0
  sub _NumSeq_Delta_dAbsDiff_min {
    my ($self) = @_;
    return 1-$self->{'sign'}
  }
  *_NumSeq_Delta_dAbsDiff_max = \&_NumSeq_Delta_dAbsDiff_min;

  sub _NumSeq_Delta_DSquared_min {
    my ($path) = @_;
    return abs($path->{'sign'}) + 1;
  }
  *_NumSeq_Delta_DSquared_max = \&_NumSeq_Delta_DSquared_min;

  use constant _NumSeq_Dir4_max_is_supremum => 0;
  use constant _NumSeq_TDir6_max_is_supremum => 0;

  sub _NumSeq_Delta_Dir4_integer {
    my ($self) = @_;
    return ($self->{'sign'} == 0
            ? 1    # vertical Dir4=1
            : 0);  # left,right Dir4=0.5 or 1.5
  }
  sub _NumSeq_Delta_TDir6_integer {
    my ($self) = @_;
    return ($self->{'sign'} == 0
            ? 0    # vertical TDir6=1.5
            : 1);  # left,right Tdir6=1 or 2
  }

  use constant _NumSeq_Delta_dX_non_decreasing => 1; # constant
  use constant _NumSeq_Delta_dY_non_decreasing => 1; # constant
  use constant _NumSeq_Delta_AbsdX_non_decreasing => 1; # constant
  use constant _NumSeq_Delta_AbsdY_non_decreasing => 1; # constant
  use constant _NumSeq_Delta_dSum_non_decreasing => 1; # constant
  use constant _NumSeq_Delta_dSumAbs_non_decreasing => 1; # constant
  use constant _NumSeq_Delta_dDiffXY_non_decreasing => 1; # constant
  use constant _NumSeq_Delta_dDiffYX_non_decreasing => 1; # constant
  use constant _NumSeq_Delta_dAbsDiff_non_decreasing => 1; # constant
  use constant _NumSeq_Delta_Dir4_non_decreasing => 1; # constant
  use constant _NumSeq_Delta_TDir6_non_decreasing => 1; # constant
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDist_non_decreasing => 1;
}
{ package Math::PlanePath::CellularRule::OddSolid;
  use constant _NumSeq_Delta_dSum_max => 2; # straight E dX=+2
  use constant _NumSeq_Delta_dDiffXY_max => 2; # straight E dX=+2
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Dir4_max_is_supremum => 1;
}
{ package Math::PlanePath::CellularRule54;
  use constant _NumSeq_Delta_dSum_max => 4; # straight E dX=+4
  use constant _NumSeq_Delta_dDiffXY_max => 4; # straight E dX=+4
  use constant _NumSeq_Dir4_max_is_supremum => 1;
}
{ package Math::PlanePath::CellularRule57;
  use constant _NumSeq_Delta_dSum_max => 3; # straight E dX=+3
  use constant _NumSeq_Delta_dAbsDiff_min => -3;
  use constant _NumSeq_Delta_dDiffXY_max => 3; # straight E dX=+3
  use constant _NumSeq_Dir4_max_is_supremum => 1;
}
{ package Math::PlanePath::CellularRule190;
  use constant _NumSeq_Delta_dSum_max => 2; # straight E dX=+2
  use constant _NumSeq_Delta_dSumAbs_min => -2; # towards Y axis dX=+2
  use constant _NumSeq_Delta_dSumAbs_max => 2;  # away Y axis dX=+2
  use constant _NumSeq_Delta_dDiffXY_max => 2; # straight E dX=+2
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Dir4_max_is_supremum => 1;
}
{ package Math::PlanePath::UlamWarburton;
  # minimum dir=0 at N=1
  use constant _NumSeq_Delta_DSquared_min => 2;  # diagonal
  use constant _NumSeq_Delta_TDSquared_min => 4;  # diagonal

  # always diagonal slope=+/-1 within depth level.  parts=2 is horizontal
  # between levels, but parts=1 or parts=4 are other slopes between levels.
  sub _NumSeq_Delta_TDir6_integer {
    my ($self) = @_;
    return ($self->{'parts'} eq '2');
  }
}
# { package Math::PlanePath::UlamWarburtonQuarter;
# }
# { package Math::PlanePath::CoprimeColumns;
# }
# { package Math::PlanePath::DivisibleColumns;
# }
# { package Math::PlanePath::File;
#   # FIXME: analyze points for dx/dy min/max etc
# }
{ package Math::PlanePath::QuintetCurve;  # NSEW
  # inherit QuintetCentres, except

  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;
  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::QuintetCentres;  # NSEW+diag
  use constant _NumSeq_Delta_DSquared_max => 2;
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;
}
{ package Math::PlanePath::QuintetReplicate;
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;

  # N=1874 Dir4=3.65596
  # N=9374 Dir4=3.96738, etc
  # Dir4 supremum at 244...44 base 5
  use constant _NumSeq_Dir4_max_is_supremum => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;
}
{ package Math::PlanePath::AR2W2Curve;     # NSEW+diag
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;
  use constant _NumSeq_Delta_DSquared_max => 2;
}
{ package Math::PlanePath::KochelCurve;     # NSEW
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::BetaOmega;    # NSEW
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::DekkingCurve;    # NSEW
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::DekkingCentres;   # NSEW+diag
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_dAbsDiff_min => -2;
  use constant _NumSeq_Delta_dAbsDiff_max => 2;
  use constant _NumSeq_Delta_DSquared_max => 2;
}
{ package Math::PlanePath::CincoCurve;    # NSEW
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::WunderlichMeander;    # NSEW
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::HIndexing;   # NSEW
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::DigitGroups;
  use constant _NumSeq_Dir4_max_is_supremum => 1; # almost full way
}
# { package Math::PlanePath::CornerReplicate;
# }
# { package Math::PlanePath::SquareReplicate;
# }
{ package Math::PlanePath::FibonacciWordFractal;  # NSEW
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dAbsDiff_min => -1;
  use constant _NumSeq_Delta_dAbsDiff_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;

  use constant _NumSeq_Delta_oeis_anum =>
    { '' =>
      { AbsdX => 'A171587', # diagonal variant
        # OEIS-Catalogue: A171587 planepath=FibonacciWordFractal delta_type=AbsdX
      },
    };
}
{ package Math::PlanePath::LTiling;
  use constant _NumSeq_Dir4_max_is_supremum => 1; # almost full way
  sub _NumSeq_Delta_DSquared_min {
    my ($self) = @_;
    return ($self->{'L_fill'} eq 'middle'
            ? 5    # N=2 dX=2,dY=1
            : 1);
  }
  sub _NumSeq_Delta_TDSquared_min {
    my ($self) = @_;
    return ($self->{'L_fill'} eq 'middle'
            ? 7    # N=2 dX=2,dY=1
            : 1);
  }
}
{ package Math::PlanePath::WythoffArray;
  use constant _NumSeq_Delta_TDSquared_min => 1;
}
{ package Math::PlanePath::PowerArray;

  # at N=1to2 either dX=1,dY=0 if radix=2 or dX=0,dY=1 if radix>2
  sub _NumSeq_Delta_TDSquared_min {
    my ($self) = @_;
    return ($self->{'radix'} == 2
            ? 1    # dX=1,dY=0
            : 3);  # dX=0,dY=1
  }

  use constant _NumSeq_Delta_oeis_anum =>
    { 'radix=2' =>
      {
       # Not quite, OFFSET=0
       # AbsdX => 'A050603', # add1c(n,2)
       # # OEIS-Catalogue: A050603 planepath=PowerArray,radix=2 delta_type=AbsdX

       #  # # Not quite, starts OFFSET=0 (even though A001511 starts OFFSET=1)
       #  # # vs n_start=1 here
       #  # dX => 'A094267', # first diffs of count low 0s
       #  #  # OEIS-Catalogue: A094267 planepath=PowerArray,radix=2
       #
       #  # # Not quite, starts OFFSET=0 values 0,1,-1,2 as diffs of A025480
       #  # # 0,0,1,0,2, vs n_start=1 here doesn't include 0
       #  # dY => 'A108715', # first diffs of odd part of n
       #  # # OEIS-Catalogue: A108715 planepath=PowerArray,radix=2 delta_type=dY
      },
    };
}

{ package Math::PlanePath::ToothpickTree;
  {
    my %_NumSeq_Dir4_max_is_supremum = (3         => 1,
                                        2         => 1,
                                        1         => 1,
                                       );
    sub _NumSeq_Dir4_max_is_supremum {
      my ($self) = @_;
      return $_NumSeq_Dir4_max_is_supremum{$self->{'parts'}};
    }
  }
}
{ package Math::PlanePath::ToothpickReplicate;
  use constant _NumSeq_Dir4_max_is_supremum => 1;
}
# { package Math::PlanePath::ToothpickUpist;
# }
{ package Math::PlanePath::LCornerTree;
  {
    my %_NumSeq_Dir4_max_is_supremum
      = (4       => 0,
         3       => 1,
         2       => 1,
         1       => 1,
         octant  => 0,
        );
    sub _NumSeq_Dir4_max_is_supremum {
      my ($self) = @_;
      return $_NumSeq_Dir4_max_is_supremum{$self->{'parts'}};
    }
  }
}
{ package Math::PlanePath::LCornerReplicate;
  use constant _NumSeq_Dir4_max_is_supremum => 1;
}
{ package Math::PlanePath::OneOfEight;
  {
    my %_NumSeq_Dir4_max_is_supremum
      = (4       => 0,
         1       => 1,
         octant  => 0,
         '3mid'  => 1,
         '3side' => 1,
        );
    sub _NumSeq_Dir4_max_is_supremum {
      my ($self) = @_;
      return $_NumSeq_Dir4_max_is_supremum{$self->{'parts'}};
    }
  }
}

1;
__END__


# sub pred {
#   my ($self, $value) = @_;
#
#   my $planepath_object = $self->{'planepath_object'};
#   my $figure = $planepath_object->figure;
#   if ($figure eq 'square') {
#     if ($value != int($value)) {
#       return 0;
#     }
#   } elsif ($figure eq 'circle') {
#     return 1;
#   }
#
#   my $delta_type = $self->{'delta_type'};
#   if ($delta_type eq 'X') {
#     if ($planepath_object->x_negative) {
#       return 1;
#     } else {
#       return ($value >= 0);
#     }
#   } elsif ($delta_type eq 'Y') {
#     if ($planepath_object->y_negative) {
#       return 1;
#     } else {
#       return ($value >= 0);
#     }
#   } elsif ($delta_type eq 'Sum') {
#     if ($planepath_object->x_negative || $planepath_object->y_negative) {
#       return 1;
#     } else {
#       return ($value >= 0);
#     }
#   }
#
#   return undef;
# }


=for stopwords Ryde dX dY dX+dY dX-dY dSum dDiffXY DiffXY dDiffYX dAbsDiff AbsDiff TDir6 Math-NumSeq Math-PlanePath NumSeq SquareSpiral PlanePath

=head1 NAME

Math::NumSeq::PlanePathDelta -- sequence of changes and directions of PlanePath coordinates

=head1 SYNOPSIS

 use Math::NumSeq::PlanePathDelta;
 my $seq = Math::NumSeq::PlanePathDelta->new
             (planepath => 'SquareSpiral',
              delta_type => 'dX');
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This is a tie-in to present coordinate changes and directions from a
C<Math::PlanePath> module in the form of a NumSeq sequence.

The C<delta_type> choices are

    "dX"        change in X coordinate
    "dY"        change in Y coordinate
    "AbsdX"     abs(dX)
    "AbsdY"     abs(dY)
    "dSum"      change in X+Y, equals dX+dY
    "dSumAbs"   change in abs(X)+abs(Y)
    "dDiffXY"   change in X-Y, equals dX-dY
    "dDiffYX"   change in Y-X, equals dY-dX
    "dAbsDiff"  change in abs(X-Y)
    "Dir4"      direction 0=East, 1=North, 2=West, 3=South
    "TDir6"     triangular 0=E, 1=NE, 2=NW, 3=W, 4=SW, 5=SE

In each case the value at i is per C<$path-E<gt>n_to_dxdy($i)>, being the
change from N=i to N=i+1, or from N=i to N=i+arms for paths with multiple
"arms" (thus following a particular arm).  i values start from the usual
C<$path-E<gt>n_start()>.

=head2 AbsdX,AbsdY

If a path always step NSEW by 1 then AbsdX and AbsdY behave as a boolean
indicating horizontal or vertical step,

    NSEW steps by 1

    AbsdX = 0 vertical            AbsdY = 0 horizontal
            1 horizontal                  1 vertical

If a path includes diagonal steps by 1 then those diagonals are a non-zero
delta, so the indication is then

    NSEW and diagonals steps by 1

    AbsdX = 0 vertical            AbsdY = 0 horizontal
            1 non-vertical                1 non-horizontal
              ie. horiz or diag             ie. vert or diag

=head2 dSum

"dSum" is the change in X+Y and is also simply dX+dY since

    dSum = (Xnext+Ynext) - (X+Y)
         = (Xnext-X) + (Ynext-Y)
         = dX + dY

The sum X+Y counts anti-diagonals, as described in
L<Math::NumSeq::PlanePathCoord>.  dSum is therefore a move between diagonals
or 0 if a step stays within the same diagonal.

               \
                \  ^  dSum > 0      dSum = step dist to North-East
                 \/
                 /\
    dSum < 0    v  \
                    \

=head2 dSumAbs

"dSumAbs" is the change in the abs(X)+abs(Y) sum,

    dSumAbs = (abs(Xnext)+abs(Ynext)) - (abs(X)+abs(Y))

As described in L<Math::NumSeq::PlanePathCoord/SumAbs>, SumAbs is a
"taxi-cab" distance from the origin, or equivalently a step between diamond
rings.

A path such as C<DiamondSpiral> follows the diamond around and has dSumAbs=0
until stepping out to the next diamond with dSumAbs=1.

The path might make a big jump which is only a small change in SumAbs.  For
example C<PyramidRows> (its default step=2) going from the end of one row to
the start of the next has dSumAbs=2.

=head2 dDiffXY and dDiffYX

"dDiffXY" is the change in DiffXY = X-Y and is also simply dX-dY since

    dDiffXY = (Xnext-Ynext) - (X-Y)
            = (Xnext-X) - (Ynext-Y)
            = dX - dY

The difference X-Y counts diagonals downwards to the south-east as described
in L<Math::NumSeq::PlanePathCoord>.  dDiffXY is therefore movement between
those diagonals, or 0 if a step stays within the same diagonal.

    dDiffXY < 0       /
                  ^  /             dDiffXY = step dist to South-East
                   \/
                   /\
                  /  v
                 /      dDiffXY > 0

"dDiffYX" is the negative of dDiffXY.  Whether X-Y or Y-X is desired depends
on which way you want to measure diagonals, or which way around to have the
sign for the changes.  dDiffYX is based on Y-X and so counts diagonals
upwards to the North-West.

=head2 dAbsDiff

"dAbsDiff" is the change in AbsDiff = abs(X-Y).  AbsDiff can be interpreted
geometrically as distance from the leading diagonal, as described in
L<Math::NumSeq::PlanePathCoord/AbsDiff>.  dAbsDiff is therefore movement
closer to or further away from the leading diagonal, measured perpendicular
to it.

                / X=Y line
               /
              /  ^
             /    \
            /      *  dAbsDiff towards or away from X=Y line
          |/        \
        --o--        v
         /|
        /

When an X,Y jumps from one side of the diagonal to the other dAbsDiff is
still the change in distance from the diagonal.  So for example if X,Y is
followed by the mirror point Y,X then dAbsDiff=0.  That sort of thing
happens for example in the C<Diagonals> path when jumping from the end of
one run to the start of the next.  In the C<Diagonals> case it's a move just
1 further away from the X=Y centre line, even though it's a big jump in
overall distance.

=head2 Dir4

"Dir4" is a direction angle scaled so a full circle ranges 0 to 4.  The
cardinal directions N,S,E,W are 0,1,2,3.  Angles in between are a fraction.

    Dir4 = atan2(dY,dX)    in range to 0 <= Dir4 < 4

    1.5   1   0.5
        \ | /
         \|/
    2 ----o---- 0
         /|\
        / | \
    2.5   3   3.5

=head2 TDir6

"TDir6" is a direction in triangular style per L<Math::PlanePath/Triangular
Lattice>.  So dX=1,dY=1 is 60 degrees and then scaled to range 0 to 6
gives 1.

       2  1.5  1
         \ | /        
          \|/         
    3 -----o----- 0
          /|\
         / | \
       4  4.5  5

Angles in between the six cardinal directions are fractions, in particular
North is 1.5 and South is 4.5.

The angle is calculated as if dY was scaled by a factor sqrt(3) to make the
lattice into equilateral triangles.  Or equivalently as a circle stretched
vertcially to become an ellipse.

    TDir6 = atan2(dY*sqrt(3), dX)      in range 0 <= TDir6 < 6

Notice that angles dX=0 or dY=0 on the axes are unchanged by the sqrt(3)
factor.  So TDir4 has ENWS 0, 1.5, 3, 4.5 which is in steps of 1.5.
Verticals North and South normally doesn't occur in the triangular lattice
paths, but TDir6 can be applied to other paths.

The sqrt(3) factor increases angles in the middle of the quadrants, off the
axes.  For example dX=1,dY=1 becomes TDir6=1 whereas a plain angle would be
only 45/360*6=0.75 in the same 0 to 6 range.  The sqrt(3) is a continuous
scaling, so a plain angle and a TDir6 are a one-to-one mapping.  TDir6 grows
a bit faster and then a bit slower than the plain angle as the direction
progresses through the quadrant.

=head1 FUNCTIONS

See L<Math::NumSeq/FUNCTIONS> for behaviour common to all sequence classes.

=over 4

=item C<$seq = Math::NumSeq::PlanePathDelta-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.  The options are

    planepath          string, name of a PlanePath module
    planepath_object   PlanePath object
    delta_type         string, as described above

C<planepath> can be either the module part such as "SquareSpiral" or a
full class name "Math::PlanePath::SquareSpiral".

=item C<$value = $seq-E<gt>ith($i)>

Return the change at N=$i in the PlanePath.

=item C<$i = $seq-E<gt>i_start()>

Return the first index C<$i> in the sequence.  This is the position
C<$seq-E<gt>rewind()> returns to.

This is C<$path-E<gt>n_start()> from the PlanePath.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::PlanePathCoord>,
L<Math::NumSeq::PlanePathTurn>,
L<Math::NumSeq::PlanePathN>

L<Math::PlanePath>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011, 2012, 2013 Kevin Ryde

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
