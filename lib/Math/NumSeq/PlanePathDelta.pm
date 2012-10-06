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


# maybe:
#
# dRadius, dRSquared,
# dTRadius, dTRSquared   of the radii
# dTheta360
# 'Dir360','TDir360',
#
# dAbsDiff change in abs(X-Y)
#    (Xnext-Ynext) - (X-Y)
#      = (Xnext-X) - (Ynext-Y)
#      = dX-dY
#    (Xnext-Ynext) - (Y-X)        # if X-Y negative
#      = Xnext+X - Ynext-Y
# dSumAbs change in abs(X)+abs(Y)  taxi dist

# matching Dir4,TDir6
# dDist dDSquared
# dTDist dTDSquared
# Dist DSquared
# TDist TDSquared


package Math::NumSeq::PlanePathDelta;
use 5.004;
use strict;
use Carp;
use List::Util 'max';

use vars '$VERSION','@ISA';
$VERSION = 90;
use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');

use Math::NumSeq::PlanePathCoord;
*_planepath_name_to_object = \&Math::NumSeq::PlanePathCoord::_planepath_name_to_object;

# uncomment this to run the ### lines
#use Smart::Comments;


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
                   'dSum','dDiffXY','dDiffYX',
                   'Dir4','TDir6',
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

  $self->{'delta_func'}
    = $self->can("_delta_func_$self->{'delta_type'}")
      || croak "Unrecognised delta_type: ",$self->{'delta_type'};

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
#   ### NumSeq-PlanePath next(): $self->{'i'}
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
  ### NumSeq-PlanePath ith(): $i

  my $planepath_object = $self->{'planepath_object'};
  if (my ($dx, $dy) = $planepath_object->n_to_dxdy ($i)) {
    return &{$self->{'delta_func'}}($dx,$dy);
  } else {
    return undef;
  }
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
use constant _PI => 4 * atan2(1,1);  # similar to Math::Complex

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
  ### atan2: atan2($dy,$dx)
  ### atan2 degrees: atan2($dy,$dx) * (180 / _PI)
  my $degrees = atan2($dy,$dx) * (180 / _PI);
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

sub values_min {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'};
  my $func;
  return (($func = $planepath_object->can("_NumSeq_Delta_$self->{'delta_type'}_min"))
          ? $planepath_object->$func()
          : undef);
}
sub values_max {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'};
  my $func;
  return (($func = $planepath_object->can("_NumSeq_Delta_$self->{'delta_type'}_max"))
          ? $planepath_object->$func()
          : undef);
}

{ package Math::PlanePath;

  use constant _NumSeq_Delta_dX_min => undef;
  use constant _NumSeq_Delta_dX_max => undef;
  use constant _NumSeq_Delta_dY_min => undef;
  use constant _NumSeq_Delta_dY_max => undef;
  use constant _NumSeq_Delta_dSum_min => undef;
  use constant _NumSeq_Delta_dSum_max => undef;
  use constant _NumSeq_Delta_dDiffXY_min => undef;
  use constant _NumSeq_Delta_dDiffXY_max => undef;
  use constant _NumSeq_Delta_dX_integer => 1;  # usually
  use constant _NumSeq_Delta_dY_integer => 1;

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
    my $dx = $self->_NumSeq_Delta_AbsdX_min;
    my $dy = $self->_NumSeq_Delta_AbsdY_min;
    return _max (1, $dx*$dx + $dy*$dy);
  }
  sub _NumSeq_Delta_TDSquared_min {
    my ($self) = @_;
    my $dx = $self->_NumSeq_Delta_AbsdX_min;
    my $dy = $self->_NumSeq_Delta_AbsdY_min;
    return _max (1, $dx*$dx + 3*$dy*$dy);
  }

  # Default Dist max from AbsdX,AbsdY max, if maximums exist.
  # Subclass must overridde if those maximums don't occur together.
  sub _NumSeq_Delta_DSquared_max {
    my ($self) = @_;
    if (defined (my $dx = $self->_NumSeq_Delta_AbsdX_max)
        && defined (my $dy = $self->_NumSeq_Delta_AbsdY_max)) {
      return ($dx*$dx + $dy*$dy);
    } else {
    return undef;
  }
  }
  sub _NumSeq_Delta_TDSquared_max {
    my ($self) = @_;
    if (defined (my $dx = $self->_NumSeq_Delta_AbsdX_max)
        && defined (my $dy = $self->_NumSeq_Delta_AbsdY_max)) {
      return ($dx*$dx + 3*$dy*$dy);
    } else {
      return undef;
    }
  }

  # default AbsdX,AbsdY from dX,dY min/max
  use constant _NumSeq_Delta_AbsdX_min => 0;
  use constant _NumSeq_Delta_AbsdY_min => 0;
  sub _NumSeq_Delta_AbsdX_max {
    my ($self) = @_;
    if (defined (my $dx_min = $self->_NumSeq_Delta_dX_min)
        && defined (my $dx_max = $self->_NumSeq_Delta_dX_max)) {
      return _max(abs($dx_min),abs($dx_max));
    } else {
      return undef;
    }
  }
  sub _NumSeq_Delta_AbsdY_max {
    my ($self) = @_;
    if (defined (my $dy_min = $self->_NumSeq_Delta_dY_min)
        && defined (my $dy_max = $self->_NumSeq_Delta_dY_max)) {
      return _max(abs($dy_min),abs($dy_max));
    } else {
      return undef;
    }
  }
  sub _NumSeq_Delta_AbsdX_integer { $_[0]->_NumSeq_Delta_dX_integer }
  sub _NumSeq_Delta_AbsdY_integer { $_[0]->_NumSeq_Delta_dY_integer }

  sub _NumSeq_Delta_dSum_integer {
    my ($self) = @_;
    ### _NumSeq_Delta_dSum_integer() ...
    return ($self->_NumSeq_Delta_dX_integer
            && $self->_NumSeq_Delta_dY_integer);
  }
  *_NumSeq_Delta_dDiffXY_integer = \&_NumSeq_Delta_dSum_integer;
  *_NumSeq_Delta_dDiffYX_integer = \&_NumSeq_Delta_dSum_integer;
  *_NumSeq_Delta_DSquared_integer = \&_NumSeq_Delta_dSum_integer;
  *_NumSeq_Delta_TDSquared_integer = \&_NumSeq_Delta_dSum_integer;

  use constant _NumSeq_Delta_Dir4_min => 0;
  use constant _NumSeq_Delta_Dir4_max => 3;

  use constant _NumSeq_Delta_TDir6_min => 0;
  use constant _NumSeq_Delta_TDir6_max => 5;

  use constant _NumSeq_Delta_Dir360_min => 0;
  use constant _NumSeq_Delta_Dir360_max => 360;
}


{ package Math::PlanePath::SquareSpiral;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;

  use constant _NumSeq_Delta_oeis_anum =>
    { 'wider=0,n_start=1' =>
      { AbsdY => 'A079813',   # k 0s then k 1s plus initial 1 is abs(dY)
        # OEIS-Catalogue: A079813 planepath=SquareSpiral delta_type=AbsdY
      },
    };
}
{ package Math::PlanePath::GreekKeySpiral;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::PyramidSpiral;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_AbsdX_non_decreasing => 1; # constant absdx=1
  use constant _NumSeq_Delta_dSum_min => -2; # SW diagonal
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -2;  # NW diagonal
  use constant _NumSeq_Delta_dDiffXY_max => 1;

  use constant _NumSeq_Delta_DSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 2.5; # at most SW diagonal
  use constant _NumSeq_Delta_TDir6_max => 4;  # at most SW diagonal
  use constant _NumSeq_Delta_TDir6_integer => 1;
}
{ package Math::PlanePath::TriangleSpiral;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_dSum_min => -2; # SW diagonal
  use constant _NumSeq_Delta_dSum_max => 2;  # dX=+2 horiz
  use constant _NumSeq_Delta_dDiffXY_min => -2;  # NW diagonal
  use constant _NumSeq_Delta_dDiffXY_max => 2;   # dX=+2 horiz

  use constant _NumSeq_Delta_Dir4_max => 2.5; # at most SW diagonal
  use constant _NumSeq_Delta_TDir6_max => 4;  # at most SW diagonal
  use constant _NumSeq_Delta_TDir6_integer => 1;

  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_DSquared_max => 4;
  use constant _NumSeq_Delta_TDSquared_min => 4;  # triangular
  use constant _NumSeq_Delta_TDSquared_max => 4;  # triangular
  use constant _NumSeq_Delta_TDist_non_decreasing => 1;  # triangular
}
{ package Math::PlanePath::TriangleSpiralSkewed;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # diagonal only acrossways
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -2;  # NW diagonal
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5;  # at most S vertical
  use constant _NumSeq_Delta_DSquared_max => 2;
}
{ package Math::PlanePath::DiamondSpiral;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_AbsdX_non_decreasing => 1; # constant absdx=1
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_DSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
  use constant _NumSeq_Delta_TDir6_integer => 1;

  use constant _NumSeq_Delta_oeis_anum =>
    { 'n_start=1' =>
      { AbsdX => 'A000012', # all 1s, starting OFFSET=1
        # OEIS-Other: A000012 planepath=DiamondSpiral delta_type=AbsdX
      },
    };
}
{ package Math::PlanePath::AztecDiamondRings;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::PentSpiral;
  use constant _NumSeq_Delta_dX_min => -2;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_dSum_min => -3; # SW -2,-1
  use constant _NumSeq_Delta_dSum_max => 2;  # dX=+2 and NE diag
  use constant _NumSeq_Delta_dDiffXY_min => -3; # NW dX=-2,dY=+1
  use constant _NumSeq_Delta_dDiffXY_max => 2;

  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal

  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_DSquared_max => 5;
}
{ package Math::PlanePath::PentSpiralSkewed;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -2; # SW diagonal
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -2; # NW diagonal
  use constant _NumSeq_Delta_dDiffXY_max => 2;  # SE diagonal
  use constant _NumSeq_Delta_DSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5;  # SE diagonal
}
{ package Math::PlanePath::HexSpiral;
  use constant _NumSeq_Delta_dX_min => -2;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_dSum_min => -2; # SW diagonal
  use constant _NumSeq_Delta_dSum_max => 2;  # dX=+2 and diagonal
  use constant _NumSeq_Delta_dDiffXY_min => -2; # NW diagonal
  use constant _NumSeq_Delta_dDiffXY_max => 2;  # SE diagonal

  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
  use constant _NumSeq_Delta_TDir6_integer => 1;

  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_DSquared_max => 4;
  use constant _NumSeq_Delta_TDist_non_decreasing => 1;  # triangular
  use constant _NumSeq_Delta_TDSquared_max => 4;  # triangular
}
{ package Math::PlanePath::HexSpiralSkewed;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # W,S straight
  use constant _NumSeq_Delta_dSum_max => 1;  # N,E straight
  use constant _NumSeq_Delta_dDiffXY_min => -2; # NW diagonal
  use constant _NumSeq_Delta_dDiffXY_max => 2;  # SE diagonal
  use constant _NumSeq_Delta_DSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::HeptSpiralSkewed;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # W,S straight
  use constant _NumSeq_Delta_dSum_max => 1;  # N,E straight
  use constant _NumSeq_Delta_dDiffXY_min => -2; # NW diagonal
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_DSquared_max => 2;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # S vertical at most
}
{ package Math::PlanePath::OctagramSpiral;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_DSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::AnvilSpiral;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_AbsdX_non_decreasing => 1; # constant
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_DSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
  use constant _NumSeq_Delta_TDir6_integer => 1;
}
{ package Math::PlanePath::KnightSpiral;
  use constant _NumSeq_Delta_dX_min => -2;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -2;
  use constant _NumSeq_Delta_dY_max => 2;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_AbsdY_min => 1;
  use constant _NumSeq_Delta_dSum_min => -3; # -2,-1
  use constant _NumSeq_Delta_dSum_max => 3;  # +2,+1
  use constant _NumSeq_Delta_dDiffXY_min => -3;
  use constant _NumSeq_Delta_dDiffXY_max => 3;

  # X=2,Y=1 angle
  use constant _NumSeq_Delta_Dir4_min =>
    Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (2,1);
  use constant _NumSeq_Delta_Dir4_max =>
    Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (2,-1);
  use constant _NumSeq_Delta_TDir6_min =>
    Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (2,1);
  use constant _NumSeq_Delta_TDir6_max =>
    Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (2,-1);

  use constant _NumSeq_Delta_DSquared_min => 2*2+1*1; # dX=1,dY=2
  use constant _NumSeq_Delta_DSquared_max => 2*2+1*1;
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_min => 2*2 + 3*1*1; # dX=2,dY=1
  use constant _NumSeq_Delta_TDSquared_max => 1*1 + 3*2*2; # dX=1,dY=2
}
{ package Math::PlanePath::CretanLabyrinth;
  use constant _NumSeq_Delta_dX_min => -1;  # NSEW
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_DSquared_max => 1;
  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
{ package Math::PlanePath::SquareArms;
  use constant _NumSeq_Delta_dX_min => -1;  # NSEW
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal

  use constant _NumSeq_Delta_DSquared_max => 1;
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;  # vertical
}
{ package Math::PlanePath::DiamondArms;  # diag always
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_AbsdX_non_decreasing => 1; # constant absdx=1
  use constant _NumSeq_Delta_AbsdY_min => 1;
  use constant _NumSeq_Delta_AbsdY_non_decreasing => 1; # constant absdy=1
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;

  use constant _NumSeq_Delta_Dir4_min => 0.5;  # diagonal
  use constant _NumSeq_Delta_Dir4_max => 3.5;  # diagonal
  use constant _NumSeq_Delta_TDir6_min => 1;  # diagonal
  use constant _NumSeq_Delta_TDir6_integer => 1;

  use constant _NumSeq_Delta_DSquared_min => 2;   # diagonal always
  use constant _NumSeq_Delta_DSquared_max => 2;
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;

  use constant _NumSeq_Delta_TDSquared_min => 4;   # diagonal always
  use constant _NumSeq_Delta_TDSquared_max => 4;
  use constant _NumSeq_Delta_TDist_non_decreasing => 1;
}
{ package Math::PlanePath::HexArms;
  use constant _NumSeq_Delta_dX_min => -2;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;

  use constant _NumSeq_Delta_Dir4_max => 3.5;  # diagonal
  use constant _NumSeq_Delta_TDir6_integer => 1;

  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_DSquared_max => 4;

  use constant _NumSeq_Delta_TDSquared_max => 4;  # triangular
  use constant _NumSeq_Delta_TDist_non_decreasing => 1;  # triangular
}
{ package Math::PlanePath::SacksSpiral;
  use constant _NumSeq_Delta_dX_integer => 0;
  use constant _NumSeq_Delta_dY_integer => 0;
  use constant _NumSeq_AbsdX_min_is_infimum => 1;
  use constant _NumSeq_Delta_Dir4_max  => 4;  # supremum
  use constant _NumSeq_Delta_TDir6_max => 6;  # supremum
  use constant _NumSeq_Delta_Dist_increasing => 1; # each step bigger
}
{ package Math::PlanePath::VogelFloret;
  use constant _NumSeq_Delta_dX_integer => 0;
  use constant _NumSeq_Delta_dY_integer => 0;
  use constant _NumSeq_Delta_AbsdX_min => 0;
  use constant _NumSeq_AbsdX_min_is_infimum => 1;

  use constant _NumSeq_Delta_AbsdY_min => 0;
  use constant _NumSeq_AbsdY_min_is_infimum => 1;

  use constant _NumSeq_Delta_Dir4_max => 4;  # supremum
  use constant _NumSeq_Delta_TDir6_max => 6;  # supremum
  use constant _NumSeq_Dir4_min_is_infimum => 1;
  use constant _NumSeq_TDir6_min_is_infimum => 1;
  use constant _NumSeq_Dir4_max_is_supremum => 1;
  use constant _NumSeq_TDir6_max_is_supremum => 1;
}
{ package Math::PlanePath::TheodorusSpiral;
  use constant _NumSeq_Delta_dX_integer => 0;
  use constant _NumSeq_Delta_dY_integer => 0;
  use constant _NumSeq_Delta_dX_min => -1; # supremum when straight
  use constant _NumSeq_Delta_dX_max => 1;  # at N=0
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;  # at N=1
  use constant _NumSeq_dX_min_is_infimum => 1;
  use constant _NumSeq_dY_min_is_infimum => 1;

  use constant _NumSeq_Delta_AbsdX_min => 0;

  use constant _NumSeq_Delta_dSum_min => -sqrt(2); # supremum diagonal
  use constant _NumSeq_Delta_dSum_max => sqrt(2);
  use constant _NumSeq_dSum_min_is_infimum => 1;
  use constant _NumSeq_dSum_max_is_supremum => 1;

  use constant _NumSeq_Delta_dDiffXY_min => -sqrt(2); # supremum diagonal
  use constant _NumSeq_Delta_dDiffXY_max => sqrt(2);
  use constant _NumSeq_dDiffXY_min_is_infimum => 1;
  use constant _NumSeq_dDiffXY_max_is_supremum => 1;

  use constant _NumSeq_Delta_Dir4_max  => 4;  # supremum
  use constant _NumSeq_Delta_TDir6_max => 6;  # supremum

  use constant _NumSeq_Delta_DSquared_max => 1; # constant 1
  use constant _NumSeq_Delta_Dist_non_decreasing => 1; # constant 1
  use constant _NumSeq_Delta_TDSquared_max => 3; # vertical
}
{ package Math::PlanePath::ArchimedeanChords;
  use constant _NumSeq_Delta_dX_integer => 0;
  use constant _NumSeq_Delta_dY_integer => 0;
  use constant _NumSeq_Delta_dX_min => -1; # infimum when straight
  use constant _NumSeq_Delta_dX_max => 1;  # at N=0
  use constant _NumSeq_dX_min_is_infimum => 1;

  use constant _NumSeq_Delta_AbsdX_min => 0;
  use constant _NumSeq_AbsdX_min_is_infimum => 1;

  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_dY_min_is_infimum => 1;
  use constant _NumSeq_dY_max_is_supremum => 1;

  use constant _NumSeq_Delta_dSum_min => -sqrt(2); # supremum when diagonal
  use constant _NumSeq_Delta_dSum_max => sqrt(2);
  use constant _NumSeq_dSum_min_is_infimum => 1;

  use constant _NumSeq_Delta_dDiffXY_min => -sqrt(2); # supremum when diagonal
  use constant _NumSeq_Delta_dDiffXY_max => sqrt(2);
  use constant _NumSeq_dDiffXY_min_is_infimum => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;  # supremum
  use constant _NumSeq_TDSquared_max_is_supremum => 1;

  use constant _NumSeq_Delta_Dir4_max  => 4;  # supremum
  use constant _NumSeq_Delta_TDir6_max => 6;  # supremum
  use constant _NumSeq_Dir4_max_is_supremum => 1;
  use constant _NumSeq_TDir6_max_is_supremum => 1;
}
{ package Math::PlanePath::MultipleRings;

  # step <= 6
  # R=base_r+d
  # theta = 2*$n * $pi / ($d * $step)
  #       = 2pi/(d*step)
  # dX -> R*sin(theta)
  #    -> R*theta
  #     = (base_r+d)*2pi/(d*step)
  #    -> 2pi/step
  #
  # step=5 across first ring
  # N=6 at X=base_r+2, Y=0
  # N=5 at R=base_r+1 theta = 2pi/5
  #   X=(base_r+1)*cos(theta)
  #   dX = base_r+2 - (base_r+1)*cos(theta)
  #
  # step=6 across first ring
  # base_r = 0.5/sin(_PI/6) - 1
  #        = 0.5/0.5 - 1
  #        = 0
  # N=7 at X=base_r+2, Y=0
  # N=6 at R=base_r+1 theta = 2pi/6
  #   X=(base_r+1)*cos(theta)
  #   dX = base_r+2 - (base_r+1)*cos(theta)
  #      = base_r+2 - (base_r+1)*0.5
  #      = 1.5*base_r + 1.5
  #      = 1.5
  #
  # step > 6
  # R = 0.5 / sin($pi / ($d*$step))
  # diff = 0.5 / sin($pi / ($d*$step)) - 0.5 / sin($pi / (($d-1)*$step))
  #     -> 0.5 / ($pi / ($d*$step)) - 0.5 / ($pi / (($d-1)*$step))
  #      = 0.5 * ($d*$step) / $pi - 0.5 * (($d-1)*$step) / $pi
  #      = step*0.5/pi * ($d - ($d-1))
  #      = step*0.5/pi
  # and extra from N=step to N=step+1
  #     * (1-cos(2pi/step))

  sub _NumSeq_Delta_dX_min {
    my ($self) = @_;
    if ($self->{'step'} == 0) {
      return 1;   # horizontal only
    }

    if ($self->{'step'} >= 6) {
      return -1; # supremum, unless polygon and step even
    }
    if ($self->{'ring_shape'} eq 'polygon'
        && $self->{'step'} >= 3) {
      # step=3,4,5
      return (-2*_PI()) / $self->{'step'};  # FIXME
    } else {
      return (-2*_PI()) / $self->{'step'};
    }
  }
  sub _NumSeq_dX_min_is_supremum {
    my ($self) = @_;
    return ($self->{'ring_shape'} eq 'polygon'
            && $self->{'step'} % 2 == 0
            ? 0   # exactly horizontal
            : 1); # supremum
  }

  sub _NumSeq_Delta_dX_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 1   # horizontal only

            : $self->{'step'} == 5
            ? $self->{'base_r'}+2 - ($self->{'base_r'}+1)*cos(2*_PI()/5)

            : $self->{'step'} == 6
            ? 1.5

            : $self->{'step'} <= 6
            ? (2*_PI()) / $self->{'step'}

            # step > 6, between rings
            : (0.5/_PI()) * $self->{'step'}
            * (2-cos(2*_PI()/$self->{'step'})));
  }
  sub _NumSeq_dX_max_is_supremum {
    my ($self) = @_;
    return ($self->{'step'} <= 6
            ? 0
            : 1); # supremum
  }

  sub _NumSeq_Delta_dY_min {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 0    # horizontal only

            : $self->{'step'} <= 6
            ? (-8*atan2(1,1)) / $self->{'step'}

            : -1); # supremum
  }
  sub _NumSeq_Delta_dY_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 0    # horizontal only

            : $self->{'step'} <= 6
            ? (8*atan2(1,1)) / $self->{'step'}

            : 1); # supremum
  }

  sub _NumSeq_Delta_AbsdX_min {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 1    # horizontal only
            : abs($self->_NumSeq_Delta_dX_min));
  }

  sub _NumSeq_Delta_dSum_min {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 1    # horizontal only
            : -1); # infimum
  }
  use constant _NumSeq_Delta_dSum_max => 1;
  sub _NumSeq_Delta_dDiffXY_min {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 1    # horizontal only
            : -1); # infimum
  }
  use constant _NumSeq_Delta_dDiffXY_max => 1;

  sub _NumSeq_dX_min_is_infimum {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 0    # horizontal only
            : 1);  # infimum
  }
  *_NumSeq_AbsdX_min_is_infimum    = \&_NumSeq_dX_min_is_infimum;
  *_NumSeq_dSum_max_is_supremum    = \&_NumSeq_dX_min_is_infimum;
  *_NumSeq_dDiffXY_min_is_infimum  = \&_NumSeq_dX_min_is_infimum;
  *_NumSeq_dDiffXY_max_is_supremum = \&_NumSeq_dX_min_is_infimum;
  *_NumSeq_dSum_min_is_infimum     = \&_NumSeq_dX_min_is_infimum;
  *_NumSeq_dY_max_is_supremum      = \&_NumSeq_dX_min_is_infimum;
  *_NumSeq_dY_min_is_infimum       = \&_NumSeq_dX_min_is_infimum;

  sub _NumSeq_Delta_DSquared_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 1    # horizontal only

            : $self->{'step'} <= 6
            ? ((8*atan2(1,1)) / $self->{'step'}) ** 2

            # step > 6, between rings
            : ((0.5/_PI()) * $self->{'step'}) ** 2);
  }

  sub _NumSeq_Delta_Dir4_min {
    my ($self) = @_;
    if ($self->{'ring_shape'} eq 'polygon' && $self->{'step'} >= 3) {
      # first ring to X axis of next ring, at i=step
      return Math::NumSeq::PlanePathDelta::_delta_func_Dir4
        ($self->n_to_xy($self->{'step'}));
    }
    if ($self->{'step'} == 0) {
      return 0;   # horizontal only
    }
    return 0; # infimum, full circle
  }

  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
           ? 0   # horizontal only
           : 4); # supremum, full circle
  }

  sub _NumSeq_Delta_TDir6_min {
    my ($self) = @_;
    if ($self->{'ring_shape'} eq 'polygon' && $self->{'step'} >= 3) {
      # first ring to X axis of next ring, at i=step
      return Math::NumSeq::PlanePathDelta::_delta_func_TDir6
        ($self->n_to_xy($self->{'step'}));
    }
    if ($self->{'step'} == 0) {
      return 0;   # horizontal only
    }
    return 0; # infimum, full circle
  }

  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
           ? 0   # horizontal only
           : 6); # supremum, full circle
  }

  sub _NumSeq_Delta_dX_non_decreasing {
    my ($self) = @_;
    return ($self->{'step'} == 0);  # constant dX=1,dY=0
  }
  *_NumSeq_Delta_dY_non_decreasing      = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_AbsdX_non_decreasing   = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_AbsdY_non_decreasing   = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_dSum_non_decreasing    = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_dDiffXY_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_dDiffYX_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_Dist_non_decreasing    = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_TDist_non_decreasing   = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_Dir4_non_decreasing    = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_TDir6_non_decreasing   = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_dX_integer             = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_dY_integer             = \&_NumSeq_Delta_dX_non_decreasing;
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
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 2;  # jump N=5 to N=6
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 3;  # dx=2,dy=1 at jump N=5 to N=6
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_DSquared_max => 5; # dx=2,dy=1 at jump N=5 to N=6
  use constant _NumSeq_Delta_Dir4_max => 3.5; # diagonal
}
{ package Math::PlanePath::FilledRings;  # NSEW+diag
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_DSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # diagonal
}
{ package Math::PlanePath::Hypot;
  # approaches horizontal
  use constant _NumSeq_Delta_Dir4_max => 4;  # supremum, almost full way
  use constant _NumSeq_Delta_TDir6_max => 6; # supremum, almost full way
  use constant _NumSeq_Dir4_max_is_supremum => 1;
  use constant _NumSeq_TDir6_max_is_supremum => 1;


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
  sub _NumSeq_Delta_AbsdY_min {
    my ($self) = @_;
    return ($self->{'points'} eq 'all'
            ? 0
            : 1);  # never same Y
  }

  sub _NumSeq_Delta_Dir4_min {
    my ($self) = @_;
    return ($self->{'points'} eq 'all'
            ? 0      # all i=1 to X=1,Y=0
            : 0.5);  # odd,even always at least NE
  }
  sub _NumSeq_Delta_TDir6_min {
    my ($self) = @_;
    return ($self->{'points'} eq 'all'
            ? 0    # all i=1 to X=1,Y=0
            : 1);  # odd,even always at least NE
  }

  # max direction SE diagonal as anything else is at most tangent to the
  # eighth of a circle
  use constant _NumSeq_Delta_Dir4_max => 3.5;

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
  use constant _NumSeq_Delta_Dir4_max => 4;
  use constant _NumSeq_Delta_TDir6_max => 6;
  use constant _NumSeq_Dir4_max_is_supremum => 1;
  use constant _NumSeq_TDir6_max_is_supremum => 1;

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
    my %AbsdX_min = ('AB,UAD' => 2,
                     'AB,FB'  => 2,
                     'PQ,UAD' => 0,
                     'PQ,FB'  => 0,
                    );
    sub _NumSeq_Delta_AbsdX_min {
      my ($self) = @_;
      return $AbsdX_min{"$self->{'coordinates'},$self->{'tree_type'}"} || 0;
    }
  }
  {
    my %AbsdY_min = ('AB,UAD' => 4,
                     'AB,FB'  => 4,
                     'PQ,UAD' => 0,
                     'PQ,FB'  => 1,
                    );
    sub _NumSeq_Delta_AbsdY_min {
      my ($self) = @_;
      return $AbsdY_min{"$self->{'coordinates'},$self->{'tree_type'}"} || 0;
    }
  }
  {
    # AB apparent minimum dX=16,dY=8
    my %Dir4_min = ('AB,UAD' => Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (16,8),
                   );
    my %TDir6_min = (
                     'AB,UAD' => Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (16,8),
                    );
    my %Dir4_is_infimum = ('AB,FB' => 1,
                           'PQ,FB' => 1);
    sub _NumSeq_Delta_Dir4_min {
      my ($self) = @_;
      return $Dir4_min{"$self->{'coordinates'},$self->{'tree_type'}"} || 0;
    }
    sub _NumSeq_Delta_TDir6_min {
      my ($self) = @_;
      return $TDir6_min{"$self->{'coordinates'},$self->{'tree_type'}"} || 0;
    }
    sub _NumSeq_Dir4_min_is_infimum {
      my ($self) = @_;
      return $Dir4_is_infimum{"$self->{'coordinates'},$self->{'tree_type'}"};
    }
    *_NumSeq_TDir6_min_is_infimum = \&_NumSeq_Dir4_min_is_infimum;
  }
  {
    # AB apparent minimum dX=-6,dY=-12
    # PQ apparent maximum dX=-1,dY=-1
    my %Dir4_max = ('AB,UAD' => Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (-6,-12),
                    'PQ,UAD' => 2.5,
                    'AB,FB'  => 4,
                    'PQ,FB'  => 4,
                   );
    my %TDir6_max = ('AB,UAD' => Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (-6,-12),
                     'PQ,UAD' => 4,
                     'AB,FB'  => 6,
                     'PQ,FB'  => 6,
                    );
    my %Dir4_is_supremum = ('AB,FB' => 1,
                            'PQ,FB' => 1);
    sub _NumSeq_Delta_Dir4_max {
      my ($self) = @_;
      return $Dir4_max{"$self->{'coordinates'},$self->{'tree_type'}"} || 3;
    }
    sub _NumSeq_Delta_TDir6_max {
      my ($self) = @_;
      return $TDir6_max{"$self->{'coordinates'},$self->{'tree_type'}"} || 4.5;
    }
    sub _NumSeq_Dir4_max_is_supremum {
      my ($self) = @_;
      return $Dir4_is_supremum{"$self->{'coordinates'},$self->{'tree_type'}"};
    }
    *_NumSeq_TDir6_max_is_supremum = \&_NumSeq_Dir4_max_is_supremum;
  }
}
{ package Math::PlanePath::RationalsTree;
  use constant _NumSeq_Delta_AbsdX_min => 0;
  {
    my %AbsdY_min = (SB   => 0,
                     CW   => 1,
                     AYT  => 0,
                     Bird => 0,
                     Drib => 0,
                     L    => 1);
    sub _NumSeq_Delta_AbsdY_min {
      my ($self) = @_;
      return $AbsdY_min{$self->{'tree_type'}} || 0;
    }
  }
  {
    # Drib apparent minimum dX=k dY=2*k+1 approaches dX=1,dY=2
    my %Dir4_min
      = (CW   => 1,
         Drib => Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (1,2),
         L    => 0.5, # N=0 dX=1,dY=1

        );
    sub _NumSeq_Delta_Dir4_min {
      my ($self) = @_;
      return $Dir4_min{$self->{'tree_type'}} || 0;
    }
  }
  {
    my %TDir6_min
      = (CW => 1.5,
         Drib => Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (1,2),
         L    => 1, # N=0 dX=1,dY=1
        );
    sub _NumSeq_Delta_TDir6_min {
      my ($self) = @_;
      return $TDir6_min{$self->{'tree_type'}} || 0;
    }
  }
  {
    my %Dir4_is_infimum = (Drib => 1);
    sub _NumSeq_Dir4_min_is_infimum {
      my ($self) = @_;
      return $Dir4_is_infimum{$self->{'tree_type'}};
    }
    *_NumSeq_TDir6_min_is_infimum = \&_NumSeq_Dir4_min_is_infimum;
  }
  {
    my %Dir4_max
      = (SB   => 3.5,
         Bird => 3.5,
         CW   => 4,
         AYT  => 4,
         Drib => 4,
         L    => 4, # at 2^k-1 dX=k+1,dY=-1 so approach Dir=4
         CS   => Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (2,-1),
        );
    sub _NumSeq_Delta_Dir4_max {
      my ($self) = @_;
      return $Dir4_max{$self->{'tree_type'}} || 3;
    }
  }
  {
    my %TDir6_max
      = (SB   => 5,
         Bird => 5,
         CW   => 6,
         AYT  => 6,
         Drib => 6,
         L    => 6,
         CS   => Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (2,-1),
        );
    sub _NumSeq_Delta_TDir6_max {
      my ($self) = @_;
      return $TDir6_max{$self->{'tree_type'}} || 4.5;
    }
  }
  {
    my %Dir4_is_supremum = (CW   => 1,
                            AYT  => 1,
                            Drib => 1,
                            L    => 1);
    sub _NumSeq_Dir4_max_is_supremum {
      my ($self) = @_;
      return $Dir4_is_supremum{$self->{'tree_type'}};
    }
    *_NumSeq_TDir6_max_is_supremum = \&_NumSeq_Dir4_max_is_supremum;
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
  use constant _NumSeq_Delta_Dir4_max =>
    Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (-2,-(sqrt(5)+1)); # phi
  use constant _NumSeq_Dir4_max_is_supremum => 1;
  use constant _NumSeq_Delta_TDir6_max =>
    Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (-2,-(sqrt(5)+1)); # phi
  use constant _NumSeq_TDir6_max_is_supremum => 1;
}
{ package Math::PlanePath::ChanTree;
  sub _NumSeq_Delta_AbsdX_min {
    my ($self) = @_;
    return ($self->{'k'} & 1
            ? 1    # k odd
            : 0);  # k even, dX=0 across middle
  }
  sub _NumSeq_Delta_AbsdY_min {
    my ($self) = @_;
    return ($self->{'k'} == 2 || ($self->{'k'} & 1)
            ? 1    # k=2 or k odd
            : 0);  # k even, dX=0 across middle
  }

  sub _NumSeq_Delta_Dir4_min {
    my ($self) = @_;
    return ($self->{'k'} == 2
            ? 1    # k=2, per CW above
            : 0);  # other
  }
  sub _NumSeq_Delta_TDir6_min {
    my ($self) = @_;
    return ($self->{'k'} == 2
            ? 1.5  # k=2, per CW above
            : 0);  # other
  }
  sub _NumSeq_Dir4_min_is_infimum {
    my ($self) = @_;
    return ($self->{'k'} == 2 || ($self->{'k'} & 1) == 0
            ? 0    # k=2 or k odd
            : 1);  # k even
  }
  *_NumSeq_TDir6_min_is_infimum = \&_NumSeq_Dir4_min_is_infimum;

  use constant _NumSeq_Delta_Dir4_max => 4;
  use constant _NumSeq_Delta_TDir6_max => 6;
  use constant _NumSeq_Dir4_max_is_supremum => 1;
  use constant _NumSeq_TDir6_max_is_supremum => 1;
}
{ package Math::PlanePath::DiagonalRationals;
  use constant _NumSeq_Delta_AbsdY_min => 1;
  use constant _NumSeq_Delta_dSum_min => 0;
  use constant _NumSeq_Delta_dSum_max => 1;  # to next diagonal stripe
  use constant _NumSeq_Delta_Dir4_min => 1;    # vertical
  use constant _NumSeq_Delta_Dir4_max => 3.5;  # SE diagonal
  use constant _NumSeq_Delta_TDir6_min => 1.5; # vertical
  use constant _NumSeq_TDSquared_min => 3;
}
{ package Math::PlanePath::FactorRationals;
  # Dir probably approaches 0
  # N=642735 to 642735 Dir4=0.05644  dX=45 dY=4
  use constant _NumSeq_Dir4_min_is_infimum => 1;
  use constant _NumSeq_TDir6_min_is_infimum => 1;

  use constant _NumSeq_Delta_AbsdY_min => 1;

  use constant _NumSeq_Delta_Dir4_max => 4;
  use constant _NumSeq_Delta_TDir6_max => 6;
  use constant _NumSeq_Dir4_max_is_supremum => 1;
  use constant _NumSeq_TDir6_max_is_supremum => 1;
}
{ package Math::PlanePath::CfracDigits;
  # FIXME: believe approaches 0, slowly
  sub _NumSeq_Dir4_min_is_infimum {
    my ($self) = @_;
    return ($self->{'radix'} == 1 ? 0  # radix=1 has 0 at N=1
            : 1);                      # other radix approaches 0
  }
  *_NumSeq_TDir6_min_is_infimum = \&_NumSeq_Dir4_min_is_infimum;

  # ENHANCE-ME: suspect this is right, but check N+1 always changes Y
  sub _NumSeq_Delta_AbsdY_min {
    my ($self) = @_;
    return ($self->{'radix'} < 3 ? 0
            : 1);                    
  }

  # FIXME: believe approaches 360 degrees, eventually
  use constant _NumSeq_Delta_Dir4_max => 4;
  use constant _NumSeq_Delta_TDir6_max => 6;
  use constant _NumSeq_Dir4_max_is_supremum => 1;
  use constant _NumSeq_TDir6_max_is_supremum => 1;
}
{ package Math::PlanePath::GcdRationals;
  {
    my %Dir4_min
      = (rows           => 0,  # N=4 to N=5 horiz
         rows_reverse   => 0,  # N=1 to N=2 horiz
         diagonals_down => 1,  # N=1 to N=2 vertical, nothing less
         diagonals_up   => 0,  # N=4 to N=5 horiz
        );
    my %TDir6_min
      = (rows           => 0,   # N=4 to N=5 horiz
         rows_reverse   => 0,   # N=1 to N=2 horiz
         diagonals_down => 1.5, # N=1 to N=2 vertical, nothing less
         diagonals_up   => 0,   # N=4 to N=5 horiz
        );
    sub _NumSeq_Delta_Dir4_min {
      my ($self) = @_;
      return ($Dir4_min{$self->{'pairs_order'}});
    }
    sub _NumSeq_Delta_TDir6_min {
      my ($self) = @_;
      return ($TDir6_min{$self->{'pairs_order'}});
    }
  }
  {
    my %Dir4_max
      = (rows => 3.5,     # N=2 to N=3 SE diagonal
         rows_reverse =>  # N=3 to N=4 dX=2,dY=-1
         Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (2,-1),
         diagonals_down => 3.5, # N=5 to N=6 SE diagonal
         diagonals_up =>  # N=9 to N=10 dX=2,dY=-1
         Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (2,-1),
        );
    my %TDir6_max
      = (rows => 5,       # N=2 to N=3 SE diagonal
         rows_reverse =>  # N=3 to N=4 dX=2,dY=-1
         Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (2,-1),
         diagonals_down =>  5, # N=5 to N=6 SE diagonal
         diagonals_up =>  # N=9 to N=10 dX=2,dY=-1
         Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (2,-1),
        );
    sub _NumSeq_Delta_Dir4_max {
      my ($self) = @_;
      return ($Dir4_max{$self->{'pairs_order'}});
    }
    sub _NumSeq_Delta_TDir6_max {
      my ($self) = @_;
      return ($TDir6_max{$self->{'pairs_order'}});
    }
  }
  sub _NumSeq_Delta_TDSquared_min {
    my ($self) = @_;
    return ($self->{'pairs_order'} eq 'diagonals_down'
            ? 3   # at N=1 vert
            : 1); # at N=4 horiz
  }
  sub _NumSeq_Delta_AbsdY_min {
    my ($self) = @_;
    return ($self->{'pairs_order'} eq 'diagonals_down'
            ? 1
            : 0);
  }
}
{ package Math::PlanePath::CfracDigits;
  # radix=1 N=3    dX=1,dY=1
  # radix=2 N=2307 dX=20,dY=1
  # radix=3 N=1108 dX=34,dY=6
  # radix=4 N=1905 dX=18,dY=2
  # radix=5 N=1338 dX=28,dY=1
  # sub _NumSeq_Delta_Dir4_min {
  #   my ($self) = @_;
  #   return ($self->{'radix'} % 2
  #           ? 3      # odd, South
  #           : 4);    # even, supremum
  # }

  # radix=1 N=4    dX=1,dY=-1 for dir4=3.5
  # radix=2 N=4413 dX=9,dY=-1
  # radix=3 N=9492 dX=3,dY=-1
  # sub _NumSeq_Delta_Dir4_max {
  #   my ($self) = @_;
  #   return ($self->{'radix'} % 2
  #           ? 3      # odd, South
  #           : 4);    # even, supremum
  # }
}
{ package Math::PlanePath::PeanoCurve;
  use constant _NumSeq_Delta_AbsdX_min => 0;

  sub _NumSeq_Delta_dX_min {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? -1      # odd
            : undef); # even, unlimited
  }
  *_NumSeq_Delta_dY_min = \&_NumSeq_Delta_dX_min;
  *_NumSeq_Delta_dSum_min = \&_NumSeq_Delta_dX_min;
  *_NumSeq_Delta_dDiffXY_min = \&_NumSeq_Delta_dX_min;

  sub _NumSeq_Delta_dX_max {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? 1         # odd
            : undef);   # even, unlimited
  }
  *_NumSeq_Delta_dY_max = \&_NumSeq_Delta_dX_max;
  *_NumSeq_Delta_dSum_max = \&_NumSeq_Delta_dX_max;
  *_NumSeq_Delta_dDiffXY_max = \&_NumSeq_Delta_dX_max;

  *_NumSeq_Delta_DSquared_max = \&_NumSeq_Delta_dX_max;
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

  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? 3      # odd, South
            : 4);    # even, supremum
  }
  sub _NumSeq_Delta_Dir4_integer {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? 1      # odd, continuous path
            : 0);    # even, jumps
  }

  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? 4.5   # odd, south
            : 6);   # even, supremum
  }

  sub _NumSeq_Dir4_max_is_supremum {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? 0      # odd
            : 1);    # even, supremum
  }
  *_NumSeq_TDir6_max_is_supremum = \&_NumSeq_Dir4_max_is_supremum;

  # 'Math::PlanePath::PeanoCurve,radix=3' =>
  # {
  #  # Not quite, OFFSET n=1 cf N=0
  #  # # A163534 is 0=east,1=south,2=west,3=north treated as down the page,
  #  # # which corrsponds to 1=north (incr Y), 3=south (decr Y) for
  #  # # directions of the PeanoCurve planepath here
  #  # Dir4 => 'A163534',
  #  # # OEIS-Catalogue: A163534 planepath=PeanoCurve delta_type=Dir4
  #
  #  # delta a(n)-a(n-1), so initial dx=0 at i=0 ...
  #  # dX => 'A163532',
  #  # # OEIS-Catalogue: A163532 planepath=PeanoCurve delta_type=dX
  #  # dY => 'A163533',
  #  # # OEIS-Catalogue: A163533 planepath=PeanoCurve delta_type=dY
  # },
}
{ package Math::PlanePath::WunderlichSerpentine;
  # same as PeanoCurve

  use constant _NumSeq_Delta_AbsdX_min => 0;
  *_NumSeq_Delta_dX_min = \&Math::PlanePath::PeanoCurve::_NumSeq_Delta_dX_min;
  *_NumSeq_Delta_dY_min = \&_NumSeq_Delta_dX_min;
  *_NumSeq_Delta_dSum_min = \&_NumSeq_Delta_dX_min;
  *_NumSeq_Delta_dDiffXY_min = \&_NumSeq_Delta_dX_min;

  *_NumSeq_Delta_dX_max = \&Math::PlanePath::PeanoCurve::_NumSeq_Delta_dX_max;
  *_NumSeq_Delta_dY_max = \&_NumSeq_Delta_dX_max;
  *_NumSeq_Delta_dSum_max = \&_NumSeq_Delta_dX_max;
  *_NumSeq_Delta_dDiffXY_max = \&_NumSeq_Delta_dX_max;

  # radix=2 0101 is straight NSEW parts, other evens are diagonal
  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return (($self->{'radix'} % 2)
            || join('',@{$self->{'serpentine_array'}}) eq '0101'
            ? 3      # odd, South
            : 4);    # even, supremum
  }
  sub _NumSeq_Delta_Dir4_integer {
    my ($self) = @_;
    return (($self->{'radix'} % 2)
            || join('',@{$self->{'serpentine_array'}}) eq '0101'
            ? 1      # odd, continuous path
            : 0);    # even, jumps
  }
  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    return (($self->{'radix'} % 2)
            || join('',@{$self->{'serpentine_array'}}) eq '0101'
            ? 4.5     # odd, South
            : 6);     # even, supremum
  }
  sub _NumSeq_Dir4_max_is_supremum {
    my ($self) = @_;
    return (($self->{'radix'} % 2)
            || join('',@{$self->{'serpentine_array'}}) eq '0101'
            ? 0      # odd, South
            : 1);    # even, supremum
  }
  *_NumSeq_TDir6_max_is_supremum = \&_NumSeq_Dir4_max_is_supremum;

  *_NumSeq_Delta_DSquared_max = \&Math::PlanePath::PeanoCurve::_NumSeq_Delta_DSquared_max;
  *_NumSeq_Delta_Dist_non_decreasing = \&Math::PlanePath::PeanoCurve::_NumSeq_Delta_Dist_non_decreasing;
  *_NumSeq_Delta_TDSquared_max = \&Math::PlanePath::PeanoCurve::_NumSeq_Delta_TDSquared_max;
}
{ package Math::PlanePath::HilbertCurve;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;

  # 'Math::PlanePath::HilbertCurve' =>
  # {
  #  # Not quite, OFFSET=1 at origin, cf path instead N=0
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
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
# { package Math::PlanePath::HilbertMidpoints;
#   use constant _NumSeq_Delta_dX_min => -2;
#   use constant _NumSeq_Delta_dX_max => 2;
#   use constant _NumSeq_Delta_dY_min => -2;
#   use constant _NumSeq_Delta_dY_max => 2;
#   use constant _NumSeq_Delta_DSquared_min => 2;
#   use constant _NumSeq_Delta_DSquared_max => 4;
# }
{ package Math::PlanePath::ZOrderCurve;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_dSum_max => 1; # forward straight only

  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return Math::NumSeq::PlanePathDelta::_delta_func_Dir4
      (1, 1 - $self->{'radix'});  # SE diagonal
  }
  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    return Math::NumSeq::PlanePathDelta::_delta_func_TDir6
      (1, 1 - $self->{'radix'});  # SE diagonal
  }
}
{ package Math::PlanePath::GrayCode;
  sub _NumSeq_Delta_AbsdX_min {
  }

  my %sup = (
             # # radix==2 always "reflected"
             # # TsF => 0,
             # # FsT => 0,
             # # Ts => 0,
             # # Fs => 0,
             # sT => 1,
             # sF => 1,

             reflected => {
                           # TsF => 0,
                           # FsT => 0,
                           # Ts  => 0,
                           # Fs  => 0,
                           sT    => 1,
                           sF    => 1,
                          },
             modular   => {
                           # TsF => 0,
                           # Ts  => 0,
                           Fs    => 1,
                           FsT   => 1,
                           sT    => 1,
                           sF    => 1,
                          },
            );
  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return ($self->_NumSeq_Dir4_max_is_supremum
            ? 4      # supremum
            : 3);    # South
  }
  # use constant _NumSeq_Delta_Dir4_integer => 1; # FIXME: some of ...

  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    return ($self->_NumSeq_Dir4_max_is_supremum
            ? 6      # supremum
            : 4.5);    # South
  }

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
  sub _NumSeq_Dir4_max_is_supremum {
    my ($self) = @_;
    my $gray_type = ($self->{'radix'} == 2
                     ? 'reflected'
                     : $self->{'gray_type'});
    return $sup{$gray_type}->{$self->{'apply_type'}};
  }
  *_NumSeq_TDir6_max_is_supremum = \&_NumSeq_Dir4_max_is_supremum;

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

  use constant _NumSeq_Delta_AbsdX_min => 1;
  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return Math::NumSeq::PlanePathDelta::_delta_func_Dir4
      ($self->{'radix'}-1,-2);
  }
  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    return Math::NumSeq::PlanePathDelta::_delta_func_TDir6
      ($self->{'radix'}-1,-2);
  }
  use constant _NumSeq_Dir4_max_is_supremum => 1;
  use constant _NumSeq_TDir6_max_is_supremum => 1;
}
{ package Math::PlanePath::ImaginaryHalf;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_Dir4_max => 4; # supremum
  use constant _NumSeq_Delta_TDir6_max => 6; # supremum
  use constant _NumSeq_Dir4_max_is_supremum => 1;
  use constant _NumSeq_TDir6_max_is_supremum => 1;
}
{ package Math::PlanePath::CubicBase;
  use constant _NumSeq_Delta_AbsdX_min => 2;
  use constant _NumSeq_Delta_DSquared_min => 4; # at X=0 to X=2
  # direction supremum maybe at
  #   dx=-0b 1001001001001001... = - (8^k-1)/7
  #   dy=-0b11011011011011011... = - (3*8^k-1)/7
  # which is
  #   dx=-1, dy=-3
  use constant _NumSeq_Delta_Dir4_max =>
    Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (-1,-3);   # supremum
  use constant _NumSeq_Delta_TDir6_max =>
    Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (-1,-3);   # supremum
  use constant _NumSeq_Dir4_max_is_supremum => 1;
  use constant _NumSeq_TDir6_max_is_supremum => 1;

  use constant _NumSeq_Delta_TDSquared_min => 4;  # at N=0 dX=2,dY=1
}
# { package Math::PlanePath::Flowsnake;
#   # inherit from FlowsnakeCentres
# }
{ package Math::PlanePath::FlowsnakeCentres;
  use constant _NumSeq_Delta_dX_min => -2;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;

  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
  use constant _NumSeq_Delta_TDir6_integer => 1;

  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_DSquared_max => 4;

  use constant _NumSeq_Delta_TDist_non_decreasing => 1;  # triangular
  use constant _NumSeq_Delta_TDSquared_max => 4;             # triangular
}
{ package Math::PlanePath::GosperReplicate;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  # maximum angle N=34 dX=3,dY=-1, it seems
  use constant _NumSeq_Delta_Dir4_max =>
    Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (3,-1);
  use constant _NumSeq_Delta_TDir6_max =>
    Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (3,-1);
}
{ package Math::PlanePath::GosperIslands;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::GosperSide;
  use constant _NumSeq_Delta_dX_min => -2;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_DSquared_max => 4;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
  use constant _NumSeq_Delta_TDir6_integer => 1;

  # use constant _NumSeq_Delta_oeis_anum =>
  # 'Math::PlanePath::GosperSide' =>
  # 'Math::PlanePath::TerdragonCurve' =>
  # A062756 is total turn starting OFFSET=0, count of ternary 1 digits.
  # Dir6 would be total%6, or 2*(total%3) for Terdragon, suspect such a
  # modulo version not in OEIS.
}
{ package Math::PlanePath::KochCurve;
  use constant _NumSeq_Delta_dX_min => -2;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_AbsdX_min => 1; # never vertical
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_DSquared_max => 4;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
  use constant _NumSeq_Delta_TDir6_integer => 1;
}
{ package Math::PlanePath::KochPeaks;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_dSum_max => 2; # diagonal NE
  use constant _NumSeq_Delta_dDiffXY_max => 2; # diagonal NW
  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
  use constant _NumSeq_Delta_TDir6_integer => 1;
}
{ package Math::PlanePath::KochSnowflakes;
  use constant _NumSeq_Delta_dX_integer => 1;
  use constant _NumSeq_Delta_dY_integer => 0; # initial Y=+2/3
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_DSquared_min => 2; # step diag or 2straight
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::KochSquareflakes;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dX_integer => 0; # initial non-integers
  use constant _NumSeq_Delta_dY_integer => 0;
  use constant _NumSeq_Delta_dSum_max => 2; # diagonal NE
  use constant _NumSeq_Delta_dSum_integer => 1;
  use constant _NumSeq_Delta_dDiffXY_max => 2; # diagonal NW
  use constant _NumSeq_Delta_dDiffXY_integer => 1;
  use constant _NumSeq_Delta_dDiffYX_integer => 1;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}

{ package Math::PlanePath::QuadricCurve;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::QuadricIslands;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dX_integer => 0; # initial 0.5s
  use constant _NumSeq_Delta_dY_integer => 0;

  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dSum_integer => 1;

  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_dDiffXY_integer => 1;
  use constant _NumSeq_Delta_dDiffYX_integer => 1;

  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}

{ package Math::PlanePath::SierpinskiCurve;
  use List::Util;
  sub _NumSeq_Delta_dX_max {
    my ($self) = @_;
    return List::Util::max ($self->{'straight_spacing'},
                                  $self->{'diagonal_spacing'});
  }
  *_NumSeq_Delta_dY_max = \&_NumSeq_Delta_dX_max;

  sub _NumSeq_Delta_dX_min {
    my ($self) = @_;
    return - List::Util::max ($self->{'straight_spacing'},
                              $self->{'diagonal_spacing'});
  }
  *_NumSeq_Delta_dY_min = \&_NumSeq_Delta_dX_min;

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
  *_NumSeq_Delta_dDiffXY_min = \&_NumSeq_Delta_dSum_min;
  *_NumSeq_Delta_dDiffXY_max = \&_NumSeq_Delta_dSum_max;

  sub _NumSeq_Delta_Dir4_integer {
    my ($self) = @_;
    return ($self->{'diagonal_spacing'} == 0);
  }
  use constant _NumSeq_Delta_Dir4_max => 3.5; # diagonal

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
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal

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
  sub _NumSeq_Delta_dY_min {
    my ($self) = @_;
    return ($self->{'align'} eq 'diagonal' ? undef : 0);
  }
  sub _NumSeq_Delta_dY_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'diagonal' ? undef : 1);
  }

  {
    my %AbsdX_min = (triangular => 1,
                     left       => 1,
                     right      => 0,  # at N=0
                     diagonal   => 0); # at N=0
    sub _NumSeq_Delta_AbsdX_min {
      my ($self) = @_;
      return $AbsdX_min{$self->{'align'}};
    }
  }
  {
    my %AbsdY_min = (triangular => 0,  # rows
                     left       => 0,  # rows
                     right      => 0,  # rows
                     diagonal   => 1); # diagonal always moves
    sub _NumSeq_Delta_AbsdY_min {
      my ($self) = @_;
      return $AbsdY_min{$self->{'align'}};
    }
  }

  use constant _NumSeq_Delta_DSquared_min => 2;

  sub _NumSeq_Delta_Dir4_min {
    my ($self) = @_;
    return ($self->{'align'} eq 'diagonal' ? 1 # vertical
            : 0); # horizontal
  }
  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'diagonal' ? 3.5 # SW diagonal
            : 2);  # supremum, west and 1 up
  }

  sub _NumSeq_Delta_TDir6_min {
    my ($self) = @_;
    return ($self->{'align'} eq 'diagonal' ? 1.5 # vertical
            : 0); # horizontal
  }
  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'diagonal' ? 5 # SW diagonal
            : 3);  # supremum, west and 1 up
  }
  sub _NumSeq_Dir4_max_is_supremum {
    my ($self) = @_;
    return ($self->{'align'} ne 'diagonal');
  }
  *_NumSeq_TDir6_max_is_supremum = \&_NumSeq_Dir4_max_is_supremum;
}
{ package Math::PlanePath::SierpinskiArrowhead;
  sub _NumSeq_Delta_dX_min {
    my ($self) = @_;
    return ($self->{'align'} eq 'triangular' ? -2 : -1);
  }
  sub _NumSeq_Delta_dX_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'triangular' ? 2 : 1);
  }
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  sub _NumSeq_Delta_AbsdX_min {
    my ($self) = @_;
    return ($self->{'align'} eq 'triangular' ? 1 : 0);
  }
  sub _NumSeq_Delta_AbsdX_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'triangular' ? 2 : 1);
  }
  sub _NumSeq_Delta_dSum_min {
    my ($self) = @_;
    return ($self->{'align'} eq 'triangular' || $self->{'align'} eq 'right'
            ? -2  # diagonal
            : -1);
  }
  sub _NumSeq_Delta_dSum_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'triangular' || $self->{'align'} eq 'right'
            ? 2  # diagonal
            : 1);
  }
  sub _NumSeq_Delta_dDiffXY_min {
    my ($self) = @_;
    return ($self->{'align'} eq 'right' ? -1 : -2);
  }
  sub _NumSeq_Delta_dDiffXY_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'right' ? 1 : 2);
  }
  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'right' ? 3
            : 3.5); # SE diagonal
  }
  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'right' ? 4.5
            : 5); # SE diagonal
  }
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
  sub _NumSeq_Delta_dX_min {
    my ($self) = @_;
    return ($self->{'align'} eq 'triangular' ? -2 : -1);
  }
  sub _NumSeq_Delta_dX_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'triangular' ? 2 : 1);
  }
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  sub _NumSeq_Delta_AbsdX_min {
    my ($self) = @_;
    return ($self->{'align'} eq 'triangular' ? 1 : 0);
  }
  sub _NumSeq_Delta_AbsdX_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'triangular' ? 2 : 1);
  }
  sub _NumSeq_Delta_dSum_min {
    my ($self) = @_;
    return ($self->{'align'} eq 'triangular' || $self->{'align'} eq 'right'
            ? -2
            : -1);
  }
  sub _NumSeq_Delta_dSum_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'triangular' || $self->{'align'} eq 'right'
            ? 2
            : 1);
  }
  sub _NumSeq_Delta_dDiffXY_min {
    my ($self) = @_;
    return ($self->{'align'} eq 'right' ? -1 : -2);
  }
  sub _NumSeq_Delta_dDiffXY_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'right' ? 1 : 2);
  }
  sub _NumSeq_Delta_dDSquared_min {
    my ($self) = @_;
    return ($self->{'align'} eq 'triangular' ? 2 : 1);
  }
  sub _NumSeq_Delta_dDSquared_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'triangular' ? 4 : 2);
  }
  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'right' ? 3
            : 3.5); # SE diagonal
  }
  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'right' ? 4.5
            : 5); # SE diagonal
  }
  sub _NumSeq_Delta_TDir6_integer {
    my ($self) = @_;
    return ($self->{'align'} eq 'triangular' ? 1 : 0);
  }
}

{ package Math::PlanePath::DragonCurve;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal

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
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_DSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::DragonMidpoint;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;
  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal

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
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal

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
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::CCurve;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;

  use constant _NumSeq_Delta_oeis_anum =>
    { '' =>
      { AbsdX => 'A010059', # 0,1 repeating
        AbsdY => 'A010060', # 1-bit count mod 2, Thue-Morse
        Dir4  => 'A179868', # 1-bit count mod 4
        # OEIS-Catalogue: A010059 planepath=CCurve delta_type=AbsdX
        # OEIS-Other:     A010060 planepath=CCurve delta_type=AbsdY
        # OEIS-Catalogue: A179868 planepath=CCurve delta_type=Dir4
      },
    };
}
{ package Math::PlanePath::AlternatePaper;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;

  use constant _NumSeq_Delta_oeis_anum =>
    { 'arms=1' =>
      { AbsdY => 'A000035', # 0,1 repeating
        dSum  => 'A020985', # GRS
        # OEIS-Other: A000035 planepath=AlternatePaper delta_type=AbsdY
        # OEIS-Other: A020985 planepath=AlternatePaper delta_type=dSum

        # dX_every_second_point_skipping_zeros => 'A020985', # GRS
        #  # ie. Math::NumSeq::GolayRudinShapiro
      },
    };
}
{ package Math::PlanePath::AlternatePaperMidpoint;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::TerdragonCurve;
  use constant _NumSeq_Delta_dX_min => -2;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;

  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
  use constant _NumSeq_Delta_TDir6_integer => 1;
  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? 4    # 0,2,4 only
            : 5);  # rotated to 1,3,5 too
  }

  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_DSquared_max => 4;
  use constant _NumSeq_Delta_TDist_non_decreasing => 1;  # triangular
  use constant _NumSeq_Delta_TDSquared_max => 4;  # triangular
}
{ package Math::PlanePath::TerdragonRounded;
  use constant _NumSeq_Delta_dX_min => -2;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
  use constant _NumSeq_Delta_TDir6_integer => 1;

  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_DSquared_max => 4;
  use constant _NumSeq_Delta_TDist_non_decreasing => 1;  # triangular
  use constant _NumSeq_Delta_TDSquared_max => 4;             # triangular
}
{ package Math::PlanePath::TerdragonMidpoint;
  use constant _NumSeq_Delta_dX_min => -2;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;

  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
  use constant _NumSeq_Delta_TDir6_integer => 1;
  sub _NumSeq_Delta_TDir6_min {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? 1    # 1,3,5 only
            : 0);  # rotated to 0,2,4 too
  }

  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_DSquared_max => 4;
  use constant _NumSeq_Delta_TDist_non_decreasing => 1;  # triangular
  use constant _NumSeq_Delta_TDSquared_max => 4;             # triangular
}
{ package Math::PlanePath::ComplexPlus;

  sub _NumSeq_Delta_AbsdX_min {
    my ($self) = @_;
    return ($self->{'realpart'} == 1
            ? 0   # i+1 N=1 dX=0,dY=1
            : 1); # i+r otherwise always diff
  }
  use constant _NumSeq_Delta_Dir4_max => 4;  # supremum, almost full way
  use constant _NumSeq_Delta_TDir6_max => 6; # supremum, almost full way
  use constant _NumSeq_Dir4_max_is_supremum => 1;
  use constant _NumSeq_TDir6_max_is_supremum => 1;
}
{ package Math::PlanePath::ComplexMinus;
  use List::Util;

  sub _NumSeq_Delta_AbsdX_min {
    my ($self) = @_;
    return ($self->{'realpart'} == 1
            ? 0   # i-1 N=3 dX=0,dY=-3
            : 1); # i-r otherwise always diff
  }

  # realpart=1
  # dx=1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0 = (6*16^k-2)/15
  # dy=1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,1 = ((9*16^5-1)/15-1)/2+1
  # approaches dx=6/15=12/30, dy=9/15/2=9/30

  my @Dir4_max = (undef,
                  Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (12,-9),
                  4);  # FIXME: smaller ?
  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return $Dir4_max[List::Util::min($self->{'realpart'}, $#Dir4_max)];
  }
  use constant _NumSeq_Dir4_max_is_supremum => 1;

  my @TDir6_max = (undef,
                   Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (12,-9),
                   6);  # FIXME: smaller ?
  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    return $TDir6_max[List::Util::min($self->{'realpart'}, $#TDir6_max)];
  }
  use constant _NumSeq_TDir6_max_is_supremum => 1;
}
{ package Math::PlanePath::ComplexRevolving;
  use constant _NumSeq_Delta_Dir4_max => 4;  # supremum, almost full way
  use constant _NumSeq_Delta_TDir6_max => 6; # supremum, almost full way
  use constant _NumSeq_Dir4_max_is_supremum => 1;
  use constant _NumSeq_TDir6_max_is_supremum => 1;
}
{ package Math::PlanePath::Rows;
  sub _NumSeq_Delta_dX_min {
    my ($self) = @_;
    return - ($self->{'width'}-1);
  }
  sub _NumSeq_Delta_dX_max {
    my ($self) = @_;
    return ($self->{'width'} <= 1
            ? 0   # single column only
            : 1);
  }

  sub _NumSeq_Delta_dY_min {
    my ($self) = @_;
    return ($self->{'width'} <= 1
            ? 1   # single column only
            : 0);
  }
  use constant _NumSeq_Delta_dY_max => 1;

  sub _NumSeq_Delta_AbsdX_min {
    my ($self) = @_;
    return ($self->{'width'} <= 1 ? 0 : 1);
  }
  sub _NumSeq_Delta_AbsdX_non_decreasing {
    my ($self) = @_;
    return ($self->{'width'} <= 2); # 1 or 2 is constant 0 or 1
  }
  sub _NumSeq_Delta_AbsdY_min {
    my ($self) = @_;
    return ($self->{'width'} <= 1
            ? 1   # single column only
            : 0);
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

  sub _NumSeq_Delta_Dir4_min {
    my ($self) = @_;
    return ($self->{'width'} == 1
            ? 1   # north only
            : 0); # E to NW
  }
  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return Math::NumSeq::PlanePathDelta::_delta_func_Dir4
      ($self->_NumSeq_Delta_dX_min, 1);
  }

  sub _NumSeq_Delta_TDir6_min {
    my ($self) = @_;
    return ($self->{'width'} == 1
            ? 1.5   # north only
            : 0); # E to NW
  }
  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    return Math::NumSeq::PlanePathDelta::_delta_func_TDir6
      ($self->_NumSeq_Delta_dX_min, 1);
  }

  sub _NumSeq_Delta_dX_non_decreasing {
    my ($self) = @_;
    return ($self->{'width'} <= 1
           ? 1  # single column only, dX=0 always
           : 0);
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
      # 'n_start=0,width=3' =>
      # { dY   => 'A022003', # 0,0,1 repeating, decimal of 1/999
      #   # OEIS-Other: A022003 planepath=Rows,width=3 delta_type=dY
      # },
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
  sub _NumSeq_Delta_dX_min {
    my ($self) = @_;
    return ($self->{'height'} <= 1
            ? 1   # single row only
            : 0);
  }
  use constant _NumSeq_Delta_dX_max => 1;

  sub _NumSeq_Delta_dY_min {
    my ($self) = @_;
    return - ($self->{'height'}-1);
  }
  sub _NumSeq_Delta_dY_max {
    my ($self) = @_;
    return ($self->{'height'} <= 1
            ? 0   # single row only
            : 1);
  }

  sub _NumSeq_Delta_AbsdX_min {
    my ($self) = @_;
    return ($self->{'height'} <= 1
            ? 1   # single row only
            : 0);
  }
  sub _NumSeq_Delta_AbsdY_min {
    my ($self) = @_;
    return ($self->{'height'} <= 1 ? 0 : 1);
  }
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

  sub _NumSeq_Delta_Dir4_min {
    my ($self) = @_;
    return ($self->{'height'} == 1
            ? 0   # east only
            : 1); # N to SE
  }
  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return Math::NumSeq::PlanePathDelta::_delta_func_Dir4
      (1, $self->_NumSeq_Delta_dY_min);
  }

  sub _NumSeq_Delta_TDir6_min {
    my ($self) = @_;
    return ($self->{'height'} == 1
            ? 0     # E only
            : 1.5); # N to SE
  }
  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    return Math::NumSeq::PlanePathDelta::_delta_func_TDir6
      (1, $self->_NumSeq_Delta_dY_min);
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
      { dY   => 'A033999', # 1,-1 repeating
        # OEIS-Other: A033999 planepath=Columns,height=2,n_start=0 delta_type=dY
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
  sub _NumSeq_Delta_dX_max {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down'
            ? 1       # down at most +1 across
            : undef); # up jumps back across unlimited at top
  }
  sub _NumSeq_Delta_dY_min {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down'
            ? -1      # down at most -1
            : undef); # up jumps down unlimited at top
  }

  sub _NumSeq_Delta_AbsdX_min {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down'
            ? 0   # N=1 dX=0,dY=1
            : 1); # otherwise always changes
  }
  sub _NumSeq_Delta_AbsdY_min {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down'
            ? 1   # otherwise always changes
            : 0); # N=1 dX=1,dY=0
  }

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

  sub _NumSeq_Delta_Dir4_min {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down'
            ? 1   # down, vertical or more
            : 0); # up, horiz at N=1
  }
  sub _NumSeq_Delta_TDir6_min {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down'
            ? 1.5  # down, vertical or more
            : 0);  # up, horiz at N=1
  }

  my %Dir4_max
    = (down => 3.5,  # down, SE diagonal
       up => Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (2,-1));
  my %TDir6_max
    = (down => 5,   # down, SE diagonal
       up => Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (2,-1));
  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return $Dir4_max{$self->{'direction'}};
  }
  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    return $TDir6_max{$self->{'direction'}};
  }

  sub _NumSeq_Delta_TDSquared_min {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down'
            ? 3      # N=1 dX=0,dY=1 vertical
            : 1);    # N=1 dX=0,dY=1 horizontal
  }

  use constant _NumSeq_Delta_oeis_anum =>
    { 'direction=down,n_start=1,x_start=0,y_start=0' =>
      { dY => 'A127949',
        # OEIS-Catalogue: A127949 planepath=Diagonals delta_type=dY
      },
      'direction=up,n_start=1,x_start=0,y_start=0' =>
      { dX => 'A127949',
        # OEIS-Other: A127949 planepath=Diagonals,direction=up delta_type=dX
      },
      'direction=down,n_start=0,x_start=0,y_start=0' =>
      { dSum => 'A023531', # characteristic "1" at triangulars
        # OEIS-Other: A023531 planepath=Diagonals,n_start=0 delta_type=dSum
      },
      'direction=up,n_start=0,x_start=0,y_start=0' =>
      { dSum => 'A023531', # characteristic "1" at triangulars
        # OEIS-Other: A023531 planepath=Diagonals,direction=up,n_start=0 delta_type=dSum
      },
    };
}
{ package Math::PlanePath::DiagonalsAlternating;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => 0; # advancing diagonals
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -2; # NW diagonal
  use constant _NumSeq_Delta_dDiffXY_max => 2;  # SE diagonal
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
  use constant _NumSeq_Delta_DSquared_max => 2;

  use constant _NumSeq_Delta_oeis_anum =>
    { 'n_start=0' =>
      { dSum => 'A023531', # characteristic "1" at triangulars
        # OEIS-Other: A023531 planepath=DiagonalsAlternating,n_start=0 delta_type=dSum
      },
    };
}
{ package Math::PlanePath::DiagonalsOctant;
  sub _NumSeq_Delta_dX_min {
    my ($self) = @_;
    return ($self->{'direction'} eq 'up' ? -1 : undef);
  }
  sub _NumSeq_Delta_dX_max {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down' ? 1 : undef);
  }

  sub _NumSeq_Delta_dY_min {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down' ? -1 : undef);
  }
  sub _NumSeq_Delta_dY_max {
    my ($self) = @_;
    return ($self->{'direction'} eq 'up' ? 1 : undef);
  }

  use constant _NumSeq_Delta_AbsdX_min => 0; # N=1 dX=0,dY=1
  sub _NumSeq_Delta_AbsdY_min {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down'
            ? 1   # 'down' always changes
            : 0); # 'up' N=2 dX=1,dY=0
  }

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

  sub _NumSeq_Delta_Dir4_min {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down'
            ? 1   # vertical N=1to2
            : 0); # horizontal N=2to3
  }
  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down'
            ? 3.5 # SE diagonal
            # N=6 to N=7
            : Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (2,-1));
  }

  sub _NumSeq_Delta_TDir6_min {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down'
            ? 1.5 # vertical N=1to2
            : 0); # horizontal N=2to3
  }
  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    return ($self->{'direction'} eq 'down'
            ? 5 # SE diagonal
            # N=6 to N=7
            : Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (2,-1));
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
  use constant _NumSeq_Delta_Dir4_min => 0.5; # NE diagonal
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
  use constant _NumSeq_Delta_TDir6_min => 1; # NE diagonal
  use constant _NumSeq_Delta_TDSquared_min => 3; # vertical
}
{ package Math::PlanePath::Staircase;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight S
  use constant _NumSeq_Delta_dSum_max => 2;  # next row
  use constant _NumSeq_Delta_dDiffXY_max => 1; # straight S,E
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
{ package Math::PlanePath::StaircaseAlternating;
  use constant _NumSeq_Delta_AbsdX_min => 0;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dY_min => -1;
  {
    my %dX_max = (jump   => 2,
                  square => 1);
    sub _NumSeq_Delta_dX_max {
      my ($self) = @_;
      return $dX_max{$self->{'end_type'}};
    }
  }
  *_NumSeq_Delta_dY_max = \&_NumSeq_Delta_dX_max;

  use constant _NumSeq_Delta_dSum_min => -1; # straight S
  *_NumSeq_Delta_dSum_max = \&_NumSeq_Delta_dX_max;

  {
    my %dDiffXY_max = (jump   => -2,
                  square => -1);
    sub _NumSeq_Delta_dDiffXY_min {
      my ($self) = @_;
      return $dDiffXY_max{$self->{'end_type'}};
    }
  }
  *_NumSeq_Delta_dDiffXY_max = \&_NumSeq_Delta_dX_max;

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
  use constant _NumSeq_Delta_TDir6_max => 4.5; # vertical
}
{ package Math::PlanePath::Corner;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight S
  use constant _NumSeq_Delta_dSum_max => 1;  # next row
  use constant _NumSeq_Delta_dDiffXY_max => 1;  # straight S,E
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
{ package Math::PlanePath::PyramidRows;

  sub _NumSeq_Delta_dX_min {
    my ($self) = @_;
    return ($self->{'step'} == 0 ? 0 : undef);
  }
  sub _NumSeq_Delta_dX_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 0    # vertical only
            : 1);  # East
  }

  sub _NumSeq_Delta_dY_min {
    my ($self) = @_;
    return ($self->{'step'} == 0 ? 1 : 0);
  }
  use constant _NumSeq_Delta_dY_max => 1;

  sub _NumSeq_Delta_AbsdX_min {
    my ($self) = @_;
    return ($self->{'step'} == 0
            || $self->{'align'} eq 'right' # dX=0 at N=1
            || ($self->{'step'} == 1 && $self->{'align'} eq 'centre')
            ? 0 : 1);
  }
  sub _NumSeq_Delta_AbsdY_min {
    my ($self) = @_;
    return ($self->{'step'} == 0 ? 1 : 0);
  }

  sub _NumSeq_Delta_dSum_min {
    my ($self) = @_;
    return ($self->{'step'} == 0 ? 1 : undef);
  }
  use constant _NumSeq_Delta_dSum_max => 1;
  sub _NumSeq_Delta_dSum_non_decreasing {
    my ($self) = @_;
    return ($self->{'step'} == 0); # constant when column only
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
  *_NumSeq_Delta_AbsdX_non_decreasing = \&_NumSeq_Delta_dSum_non_decreasing;
  *_NumSeq_Delta_AbsdY_non_decreasing = \&_NumSeq_Delta_dSum_non_decreasing;
  *_NumSeq_Delta_dDiffXY_non_decreasing = \&_NumSeq_Delta_dSum_non_decreasing;
  *_NumSeq_Delta_dDiffYX_non_decreasing = \&_NumSeq_Delta_dSum_non_decreasing;

  sub _NumSeq_Delta_DSquared_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 1    # X=0 vertical only
            : undef);
  }

  # if step==0 then always north, otherwise E to NW
  sub _NumSeq_Delta_Dir4_min {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 1    # north only
            : 0);  # east
  }
  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 1    # north only
            : 2);  # supremum, west and 1 up
  }
  sub _NumSeq_Dir4_max_is_supremum {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 0    # north only
            : 1);  # supremum, west and 1 up
  }
  *_NumSeq_Delta_Dir4_integer = \&_NumSeq_Delta_Dir4_min; # when North only

  # if step==0 then always north, otherwise E to NW
  sub _NumSeq_Delta_TDir6_min {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 1.5  # north only
            : 0);  # east
  }
  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 1.5  # north only
            : 3);  # supremum, west and up 1
  }
  sub _NumSeq_TDir6_max_is_supremum {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 0    # north only
            : 1);  # supremum, west and 1 up
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
       my $href =
         { dDiffYX => 'A127949',
         };
       ('step=1,align=centre,n_start=1' => $href,
        'step=1,align=right,n_start=1'  => $href,
       );
       # OEIS-Other: A127949 planepath=PyramidRows,step=1 delta_type=dDiffYX
       # OEIS-Other: A127949 planepath=PyramidRows,step=1,align=right delta_type=dDiffYX
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
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_max => 2; # NE diagonal
  use constant _NumSeq_Delta_dDiffXY_max => 2; # SE diagonal
  use constant _NumSeq_Delta_Dir4_min => 0.5;  # NE diagonal
  use constant _NumSeq_Delta_Dir4_max => 3.5;  # SE diagonal
  use constant _NumSeq_Delta_TDir6_min => 1;   # NE diagonal
  use constant _NumSeq_Delta_TDir6_integer => 1;
}
{ package Math::PlanePath::CellularRule;

  # left 2 cell line 14,46,142,174
  # 111 -> any, doesn't occur
  # 110 -> 0
  # 101 -> any, doesn't occur
  # 100 -> 0
  # 011 -> 1
  # 010 -> 1
  # 001 -> 1
  # 000 -> 0
  # so (rule & 0x5F) == 0x0E
  #
  # left 1,2 cell line 6,38,134,166
  # 111 -> any, doesn't occur
  # 110 -> 0
  # 101 -> any, doesn't occur
  # 100 -> 0
  # 011 -> 0
  # 010 -> 1
  # 001 -> 1
  # 000 -> 0
  # so (rule & 0x5F) == 0x06
  #

  sub _NumSeq_Delta_dX_min {
    my ($self) = @_;
    return (($self->{'rule'} & 0x17) == 0        # single cell only
            || ($self->{'rule'} & 0x5F) == 0x14  # right line 1,2
            || ($self->{'rule'} & 0x5F) == 0x54  # right line 2
            ? 0

            : (($self->{'rule'} & 0x5F) == 0x0E     # left line 2
               || ($self->{'rule'} & 0x5F) == 0x06) # left line 1,2
            ? -2

            : undef);
  }
  sub _NumSeq_Delta_dX_max {
    my ($self) = @_;
    return (($self->{'rule'} & 0x17) == 0        # single cell only
            || ($self->{'rule'} & 0x5F) == 0x14  # right line 1,2
            || ($self->{'rule'} & 0x5F) == 0x54  # right line 2
            ? 1
            : undef);
  }

  sub _NumSeq_Delta_AbsdX_min {
    my ($self) = @_;
    return (($self->{'rule'} & 0x17) == 0        # single cell only
            || ($self->{'rule'} & 0x5F) == 0x14  # right line 1,2
            || ($self->{'rule'} & 0x5F) == 0x54  # right line 2
            || ($self->{'rule'} & 0xDF) == 1     # 1,33 alternate rows
            || $self->{'rule'} == 5              # alternate rows
            || $self->{'rule'} == 9
            || $self->{'rule'} == 13
            || $self->{'rule'} == 21
            || $self->{'rule'} == 27
            || $self->{'rule'} == 28
            || $self->{'rule'} == 29
            || $self->{'rule'} == 37
            || $self->{'rule'} == 41
            || $self->{'rule'} == 45
            || $self->{'rule'} == 53
            || $self->{'rule'} == 61
            || $self->{'rule'} == 67
            || $self->{'rule'} == 69
            || $self->{'rule'} == 71
            || $self->{'rule'} == 75
            || $self->{'rule'} == 79
            || $self->{'rule'} == 81
            || $self->{'rule'} == 85
            || $self->{'rule'} == 92
            || $self->{'rule'} == 93
            || $self->{'rule'} == 101
            || $self->{'rule'} == 103
            || $self->{'rule'} == 107
            || $self->{'rule'} == 109
            || $self->{'rule'} == 111
            || $self->{'rule'} == 113
            || $self->{'rule'} == 117
            || $self->{'rule'} == 124
            || $self->{'rule'} == 125
            || $self->{'rule'} == 129
            || $self->{'rule'} == 133
            || $self->{'rule'} == 137
            || $self->{'rule'} == 141
            || $self->{'rule'} == 149
            || $self->{'rule'} == 156
            || $self->{'rule'} == 157
            || $self->{'rule'} == 161
            || $self->{'rule'} == 169
            || $self->{'rule'} == 173
            || $self->{'rule'} == 181
            || $self->{'rule'} == 188
            || $self->{'rule'} == 189
            || $self->{'rule'} == 197
            || $self->{'rule'} == 205
            || $self->{'rule'} == 213
            || $self->{'rule'} == 221
            || $self->{'rule'} == 229
            || $self->{'rule'} == 237
            || $self->{'rule'} == 245
            || $self->{'rule'} == 253
            ? 0
            : 1);
  }

  sub _NumSeq_Delta_dSum_min {
    my ($self) = @_;
    return (($self->{'rule'} & 0x5F) == 0x54  # right line 2, const dSum=+1
            || ($self->{'rule'} & 0x5F) == 0x14  # right line 1,2
            ? 1
            : undef);
  }
  sub _NumSeq_Delta_dSum_max {
    my ($self) = @_;
    return (($self->{'rule'} & 0x5F) == 0x54  # right line 2
            ? 1                               #   is constant dSum=+1
            : ($self->{'rule'} & 0x5F) == 0x14  # right line 1,2
            ? 2  # diagonal NE
            : undef);
  }
  sub _NumSeq_Delta_dSum_non_decreasing {
    my ($self) = @_;
    return (($self->{'rule'} & 0x5F) == 0x54  # right line 2
            ? 1                               #   is constant dSum=+1
            : undef);
  }

  {
    my $dir4_max_left2
      = Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (-2,1);
    sub _NumSeq_Delta_Dir4_max {
      my ($self) = @_;
      return (($self->{'rule'} & 0x5F) == 0x14     # right line 1,2
              || ($self->{'rule'} & 0x5F) == 0x54  # right line 2
              ? 1    # north

              : (($self->{'rule'} & 0x5F) == 0x0E     # left line 2
                 || ($self->{'rule'} & 0x5F) == 0x06) # left line 1,2
              ? $dir4_max_left2

              : 2);  # supremum, west and 1 up
    }
    sub _NumSeq_Dir4_max_is_supremum {
      my ($self) = @_;
      return (($self->{'rule'} & 0x5F) == 0x14     # right line 1,2
              || ($self->{'rule'} & 0x5F) == 0x54  # right line 2
              || ($self->{'rule'} & 0x5F) == 0x0E  # left line 2
              || ($self->{'rule'} & 0x5F) == 0x06  # left line 1,2
              ? 0
              : 1);  # supremum
    }
  }
  {
    my $tdir6_max_left2
      = Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (-2,1);
    sub _NumSeq_Delta_TDir6_max {
      my ($self) = @_;
      return (($self->{'rule'} & 0x5F) == 0x14     # right line 1,2
              || ($self->{'rule'} & 0x5F) == 0x54  # right line 2
              ? 1.5    # north

              : (($self->{'rule'} & 0x5F) == 0x0E     # left line 2
                 || ($self->{'rule'} & 0x5F) == 0x06) # left line 1,2
              ? $tdir6_max_left2

              : 3);  # supremum, west and 1 up
    }
    *_NumSeq_TDir6_max_is_supremum = \&_NumSeq_Dir4_max_is_supremum;
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
}
{ package Math::PlanePath::CellularRule::Line;
  sub _NumSeq_Delta_dX_min {
    my ($path) = @_;
    return $path->{'sign'};
  }
  *_NumSeq_Delta_dX_max = \&_NumSeq_Delta_dX_min;

  use constant _NumSeq_Delta_dY_min => 1;
  use constant _NumSeq_Delta_dY_max => 1;

  sub _NumSeq_Delta_AbsdX_min {
    my ($path) = @_;
    return ($path->{'sign'} ? 1 : 0);
  }
  use constant _NumSeq_Delta_AbsdY_min => 1; # constant

  sub _NumSeq_Delta_DSquared_min {
    my ($path) = @_;
    return abs($path->{'sign'}) + 1;
  }
  *_NumSeq_Delta_DSquared_max = \&_NumSeq_Delta_DSquared_min;

  sub _NumSeq_Delta_Dir4_min {
    my ($path) = @_;
    # 1  -> 0.5 right
    # 0  -> 1 vertical
    # -1 -> 1.5 left
    return 1 - $path->{'sign'}/2;
  }
  *_NumSeq_Delta_Dir4_max = \&_NumSeq_Delta_Dir4_min;
  use constant _NumSeq_Dir4_max_is_supremum => 0;

  sub _NumSeq_Delta_TDir6_min {
    my ($path) = @_;
    # 1  -> 1 right
    # 0  -> 1.5 vertical
    # -1 -> 2 left
    return (3 - $path->{'sign'})/2;
  }
  *_NumSeq_Delta_TDir6_max = \&_NumSeq_Delta_TDir6_min;
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
  use constant _NumSeq_Delta_dDiffXY_non_decreasing => 1; # constant
  use constant _NumSeq_Delta_dDiffYX_non_decreasing => 1; # constant
  use constant _NumSeq_Delta_Dir4_non_decreasing => 1; # constant
  use constant _NumSeq_Delta_TDir6_non_decreasing => 1; # constant
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDist_non_decreasing => 1;
}
{ package Math::PlanePath::CellularRule::OddSolid;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => 0;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_dSum_max => 2; # straight E dX=+2
  use constant _NumSeq_Delta_dDiffXY_max => 2; # straight E dX=+2
  use constant _NumSeq_Delta_DSquared_min => 2;
  use constant _NumSeq_Delta_Dir4_max => 2; # west and up
  use constant _NumSeq_Delta_TDir6_max => 3; # west and up
}
{ package Math::PlanePath::CellularRule54;
  use constant _NumSeq_Delta_dX_max => 4;
  use constant _NumSeq_Delta_dY_min => 0;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_dSum_max => 4; # straight E dX=+4
  use constant _NumSeq_Delta_dDiffXY_max => 4; # straight E dX=+4

  use constant _NumSeq_Delta_Dir4_max => 2;  # supremum, west and 1 up
  use constant _NumSeq_Delta_TDir6_max => 3; # supremum, west and 1 up
  use constant _NumSeq_Dir4_max_is_supremum => 1;
  use constant _NumSeq_TDir6_max_is_supremum => 1;
}
{ package Math::PlanePath::CellularRule57;
  use constant _NumSeq_Delta_dX_max => 3;
  use constant _NumSeq_Delta_dY_min => 0;
  use constant _NumSeq_Delta_dY_max => 1;
  sub _NumSeq_Delta_AbsdX_min {
    my ($self) = @_;
    return ($self->{'mirror'} ? 0 : 1);
  }
  use constant _NumSeq_Delta_dSum_max => 3; # straight E dX=+3
  use constant _NumSeq_Delta_dDiffXY_max => 3; # straight E dX=+3

  use constant _NumSeq_Delta_Dir4_max => 2;  # supremum, west and 1 up
  use constant _NumSeq_Delta_TDir6_max => 3; # supremum, west and 1 up
  use constant _NumSeq_Dir4_max_is_supremum => 1;
  use constant _NumSeq_TDir6_max_is_supremum => 1;
}
{ package Math::PlanePath::CellularRule190;
  use constant _NumSeq_Delta_dX_max => 2; # across gap
  use constant _NumSeq_Delta_dY_min => 0;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_dSum_max => 2; # straight E dX=+2
  use constant _NumSeq_Delta_dDiffXY_max => 2; # straight E dX=+2

  use constant _NumSeq_Delta_Dir4_max => 2;  # supremum, west and 1 up
  use constant _NumSeq_Delta_TDir6_max => 3; # supremum, west and 1 up
  use constant _NumSeq_Dir4_max_is_supremum => 1;
  use constant _NumSeq_TDir6_max_is_supremum => 1;
}
{ package Math::PlanePath::UlamWarburton;
  # minimum dir=0 at N=1
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
  use constant _NumSeq_Delta_DSquared_min => 2;  # diagonal
  use constant _NumSeq_Delta_TDSquared_min => 4;  # diagonal
}
{ package Math::PlanePath::UlamWarburtonQuarter;
  # minimum dir=0 at N=13 dX=2,dY=0
  # maximum dir seems dX=13,dY=-9 at N=149 going top-left part to new bottom
  # right diagonal
  use constant _NumSeq_Delta_Dir4_max =>
    Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (13,-9);
  use constant _NumSeq_Delta_TDir6_max =>
    Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (13,-9);
}
{ package Math::PlanePath::CoprimeColumns;
  use constant _NumSeq_Delta_dX_min => 0;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # at most SE diagonal
}
{ package Math::PlanePath::DivisibleColumns;
  use constant _NumSeq_Delta_dX_min => 0;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # at most SE diagonal
}
# { package Math::PlanePath::File;
#   # FIXME: analyze points for dx/dy min/max etc
# }
{ package Math::PlanePath::QuintetCurve;  # NSEW
  # inherit QuintetCentres, except

  use constant _NumSeq_Delta_Dir4_max => 3; # vertical
  use constant _NumSeq_Delta_TDir6_max => 4.5; # vertical
  use constant _NumSeq_Delta_Dir4_integer => 1;

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::QuintetCentres;  # NSEW+diag
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_AbsdX_min => 0;
  use constant _NumSeq_Delta_DSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::QuintetReplicate;
  # N=1874 Dir4=3.65596
  # N=9374 Dir4=3.96738, etc
  # Dir4 supremum at 244...44 base 5
  use constant _NumSeq_Delta_DSquared_max => 1;
  use constant _NumSeq_Delta_Dir4_max => 4;
  use constant _NumSeq_Delta_TDir6_max => 6;
  use constant _NumSeq_Dir4_max_is_supremum => 1;
  use constant _NumSeq_TDir6_max_is_supremum => 1;
}
{ package Math::PlanePath::AR2W2Curve;     # NSEW+diag
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_DSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::KochelCurve;     # NSEW
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::BetaOmega;    # NSEW
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::DekkingCurve;    # NSEW
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::DekkingCentres;   # NSEW+diag
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -2; # diagonals
  use constant _NumSeq_Delta_dSum_max => 2;
  use constant _NumSeq_Delta_dDiffXY_min => -2;
  use constant _NumSeq_Delta_dDiffXY_max => 2;
  use constant _NumSeq_Delta_DSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::CincoCurve;    # NSEW
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::WunderlichMeander;    # NSEW
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::HIndexing;   # NSEW
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::DigitGroups;
  use constant _NumSeq_Delta_AbsdX_min => 1;
  use constant _NumSeq_Delta_Dir4_max => 4;  # supremum, almost full way
  use constant _NumSeq_Delta_TDir6_max => 6; # supremum, almost full way
  use constant _NumSeq_Dir4_max_is_supremum => 1;
  use constant _NumSeq_TDir6_max_is_supremum => 1;
}
{ package Math::PlanePath::CornerReplicate;
  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (2,-1);  # SE
  }
  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    return Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (2,-1);  # SE
  }
}
{ package Math::PlanePath::SquareReplicate;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # S vertical at most
}
{ package Math::PlanePath::FibonacciWordFractal;  # NSEW
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_dSum_min => -1; # straight only
  use constant _NumSeq_Delta_dSum_max => 1;
  use constant _NumSeq_Delta_dDiffXY_min => -1;
  use constant _NumSeq_Delta_dDiffXY_max => 1;

  use constant _NumSeq_Delta_Dir4_integer => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal

  use constant _NumSeq_Delta_DSquared_max => 1;  # NSEW only
  use constant _NumSeq_Delta_Dist_non_decreasing => 1;
  use constant _NumSeq_Delta_TDSquared_max => 3;
}
{ package Math::PlanePath::LTiling;
  use constant _NumSeq_Delta_Dir4_max => 4;  # supremum, almost full way
  use constant _NumSeq_Delta_TDir6_max => 6; # supremum, almost full way
  use constant _NumSeq_Dir4_max_is_supremum => 1;
  use constant _NumSeq_TDir6_max_is_supremum => 1;
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
  use constant _NumSeq_Delta_AbsdX_min => 1; # never same X
  use constant _NumSeq_Delta_Dir4_max =>  # N=4 to N=5 dX=3,dY=-1
    Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (3,-1);
  use constant _NumSeq_Delta_TDir6_max =>
    Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (3,-1);
  use constant _NumSeq_Delta_TDSquared_min => 1;
}
{ package Math::PlanePath::PowerArray;
  sub _NumSeq_Delta_AbsdX_min {
    my ($self) = @_;
    return ($self->{'radix'} == 2
            ? 1
            : 0); # at N=1 dX=0,dY=1
  }
  sub _NumSeq_Delta_AbsdY_min {
    my ($self) = @_;
    return ($self->{'radix'} == 2
            ? 0   # at N=1 dX=1,dY=0
            : 1); # always different Y
  }
  sub _NumSeq_Delta_Dir4_min {
    my ($self) = @_;
    return ($self->{'radix'} == 2 ? 0 : 1);
  }
  sub _NumSeq_Delta_TDir6_min {
    my ($self) = @_;
    return ($self->{'radix'} == 2 ? 0 : 1.5);
  }

  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    my $pos = $self->{'radix'};
    if ($pos == 2) { $pos = 4 }
    return Math::NumSeq::PlanePathDelta::_delta_func_Dir4
      ($self->n_to_dxdy($pos-1));
  }
  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    my $pos = $self->{'radix'};
    if ($pos == 2) { $pos = 4 }
    return Math::NumSeq::PlanePathDelta::_delta_func_TDir6
      ($self->n_to_dxdy($pos-1));
  }

  # at N=1to2 either dX=1,dY=0 if radix=2 or dX=0,dY=1 if radix>2
  sub _NumSeq_Delta_TDSquared_min {
    my ($self) = @_;
    return ($self->{'radix'} == 2
            ? 1    # dX=1,dY=0
            : 3);  # dX=0,dY=1
  }

  # use constant _NumSeq_Delta_oeis_anum =>
  # 'radix=2' =>
  # {
  #  # # Not quite, starts OFFSET=0 (even though A001511 starts OFFSET=1)
  #  # # vs n_start=1 here
  #  # dX => 'A094267', # first diffs of count low 0s
  #  #  # OEIS-Catalogue: A094267 planepath=PowerArray,radix=2
  #
  #  # # Not quite, starts OFFSET=0 values 0,1,-1,2 as diffs of A025480
  #  # # 0,0,1,0,2, vs n_start=1 here doesn't include 0
  #  # dY => 'A108715', # first diffs of odd part of n
  #  # # OEIS-Catalogue: A108715 planepath=PowerArray,radix=2 delta_type=dY
  # },
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


=for stopwords Ryde dX dY dX+dY dX-dY dSum dDiffXY DiffXY dDiffYX TDir6 Math-NumSeq Math-PlanePath NumSeq SquareSpiral PlanePath

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

    "dX"       change in X coordinate
    "dY"       change in Y coordinate
    "AbsdX"    abs(dX)
    "AbsdY"    abs(dY)
    "dSum"     change in X+Y, equals dX+dY
    "dDiffXY"  change in X-Y, equals dX-dY
    "dDiffYX"  change in Y-X, equals dY-dX
    "Dir4"     direction 0=East, 1=North, 2=West, 3=South
    "TDir6"    triangular 0=E, 1=NE, 2=NW, 3=W, 4=SW, 5=SE

In each case the value at i is per C<$path-E<gt>n_to_dxdy($i)>, being the
change from N=i to N=i+1, or from N=i to N=i+arms for paths with multiple
"arms" (thus following a particular arm).  i values start from the usual
C<$path-E<gt>n_start()>.

"dSum" is the change in X+Y and is also simply dX+dY since

    dSum = (Xnext+Ynext) - (X+Y)
         = (Xnext-X) + (Ynext-Y)
         = dX + dY

The sum X+Y counts anti-diagonals, as described in
L<Math::NumSeq::PlanePathCoord>.  dSum is therefore a move between diagonals
or 0 if a step stays within the same diagonal.

"dDiffXY" is the change in DiffXY = X-Y and is also simply dX-dY since

    dDiffXY = (Xnext-Ynext) - (X-Y)
            = (Xnext-X) - (Ynext-Y)
            = dX - dY

The difference X-Y counts diagonals downwards to the south-east as described
in L<Math::NumSeq::PlanePathCoord>.  dDiffXY is therefore movement between
those diagonals, or 0 if a step stays within the same diagonal.

"dDiffYX" is the negative of dDiffXY.  Whether X-Y or Y-X is desired depends
on which way you want to measure diagonals, or what sign to have for the
changes.  dDiffYX is based on Y-X and so counts diagonals upwards to the
North-West.

"Dir4" direction is a fraction when a delta is in between the cardinal
N,S,E,W directions.  For example dX=-1,dY=+1 going diagonally North-West
would be direction=1.5.

    Dir4 = atan2 (dY, dX)       in range to 0 <= Dir4 < 4

"TDir6" direction is in triangular style per L<Math::PlanePath/Triangular
Lattice>.  So dX=1,dY=1 is 60 degrees, dX=-1,dY=1 is 120 degrees, dX=-2,dY=0
is 180 degrees, etc and fractional values if in between.  It behaves as if
dY was scaled by a factor sqrt(3) to make equilateral triangles,

    TDir6 = atan2(dY*sqrt(3), dX)      in range 0 <= TDir6 < 6

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

Copyright 2011, 2012 Kevin Ryde

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
