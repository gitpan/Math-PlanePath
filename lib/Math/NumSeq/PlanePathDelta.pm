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

package Math::NumSeq::PlanePathDelta;
use 5.004;
use strict;
use Carp;
use List::Util 'max';

use vars '$VERSION','@ISA';
$VERSION = 72;
use Math::NumSeq;
@ISA = ('Math::NumSeq');

use Math::NumSeq::PlanePathCoord;
*_planepath_oeis_key = \&Math::NumSeq::PlanePathCoord::_planepath_oeis_key;
*_planepath_name_to_object = \&Math::NumSeq::PlanePathCoord::_planepath_name_to_object;

use Math::PlanePath; # for _min(), _max()

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
    return Math::NumSeq::__('Coordinate changes from a PlanePath');
  }
}

use constant::defer parameter_info_array =>
  sub {
    [ Math::NumSeq::PlanePathCoord::_parameter_info_planepath(),
      {
       name    => 'delta_type',
       display => Math::NumSeq::__('Delta Type'),
       type    => 'enum',
       default => 'dX',
       choices => ['dX','dY',
                   'Dir4','TDir6',

                   # 'Dist','DistSquared',
                   # 'Dir360','TDir360',
                  ],
       # description => Math::NumSeq::__(''),
      },
    ];
  };

# SquareSpiral dX maybe A118175 signed version of Rule 220 in binary ??
#              dY maybe A079813 signed version of n 0s then n 1s

# DragonMidpoint abs(dY) is A073089, but it has n=N+2 and extra initial 0 at
# n=1
#
# ComplesMinus i-1 dX with zeros removed is Golay-Rudin-Shapiro A020985 

my %oeis_anum
  = (
     # 'Math::PlanePath::HilbertCurve' =>
     # {
     #  # OFFSET n=1 cf N=0
     #  # # A163540 is 0=east,1=south,2=west,3=north for drawing down the page,
     #  # # which corresponds to 1=north,3=south per the HilbertCurve planepath
     #  # Dir4 => 'A163540',
     #  # # OEIS-Catalogue: A163540 planepath=HilbertCurve delta_type=Dir4
     # 
     #  # delta path(n)-path(n-1) starting i=0 with path(-1)=0 for first value 0
     #  # dX => 'A163538',
     #  # # OEIS-Catalogue: A163538 planepath=HilbertCurve delta_type=dX
     #  # dY => 'A163539',
     #  # # OEIS-Catalogue: A163539 planepath=HilbertCurve delta_type=dY
     #  #
     #  # cf A163541    absolute direction, transpose X,Y
     #  # would be N=0,E=1,S=2,W=3
     # },

     # 'Math::PlanePath::PeanoCurve,radix=3' =>
     # {
     #  # OFFSET n=1 cf N=0
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

     # 'Math::PlanePath::RationalsTree,tree_type=CW' =>
     # {
     #  # dY => 'A070990', # Stern diatomic first diffs, except it starts i=0
     #  # where RationalsTree N=1.  dX is same, but has extra leading 0.
     # },

     # PyramidRows step=0 is trivial X=0,Y=N
     'Math::PlanePath::PyramidRows,step=0' =>
     { dX    => 'A000004',  # all zeros, X=0 always
       dY    => 'A000012',  # all ones
       Dir4  => 'A000012',  # all ones, North
       # OEIS-Other: A000004 planepath=PyramidRows,step=0 delta_type=dX
       # OEIS-Other: A000012 planepath=PyramidRows,step=0 delta_type=dY
       # OEIS-Other: A000012 planepath=PyramidRows,step=0 delta_type=Dir4
     },

     # # PyramidRows step=1
     # 'Math::PlanePath::PyramidRows,step=1' =>
     # {
     #  # not quite, PyramidRows starts N=1 but A023531 starts n=0
     #  # dY    => 'A023531',  # 1,0,1,0,0,1,etc, 1 if n==k(k+3)/2
     # },

     # PyramidRows step=2 dY is A010052, 1 if n=k^2, except it starts n=0
     # where PyramidRows starts i=1

     # MultipleRings step=0 is trivial X=N,Y=0
     'Math::PlanePath::MultipleRings,step=0' =>
     { dX     => 'A000012',  # all ones
       dY     => 'A000004',  # all-zeros
       Dir4   => 'A000004',  # all zeros, East
       TDir6  => 'A000004',  # all zeros, East
       # OEIS-Other: A000012 planepath=MultipleRings,step=0 delta_type=dX
       # OEIS-Other: A000004 planepath=MultipleRings,step=0 delta_type=dY
       # OEIS-Other: A000004 planepath=MultipleRings,step=0 delta_type=Dir4
       # OEIS-Other: A000004 planepath=MultipleRings,step=0 delta_type=TDir6
     },

     'Math::PlanePath::Rows,width=1' =>
     { dX   => 'A000004', # all zeros, X=0 always
       dY   => 'A000012', # all ones
       Dir4 => 'A000012', # all ones, North
       # OEIS-Other: A000004 planepath=Rows,width=1 delta_type=dX
       # OEIS-Other: A000012 planepath=Rows,width=1 delta_type=dY
       # OEIS-Other: A000012 planepath=Rows,width=1 delta_type=Dir4
     },
     'Math::PlanePath::Columns,height=1' =>
     { dX     => 'A000012', # all ones
       dY     => 'A000004', # all zeros, Y=0 always
       Dir4   => 'A000004', # all zeros, East
       TDir6  => 'A000004', # all zeros, East
       # OEIS-Other: A000012 planepath=Columns,height=1 delta_type=dX
       # OEIS-Other: A000004 planepath=Columns,height=1 delta_type=dY
       # OEIS-Other: A000004 planepath=Columns,height=1 delta_type=Dir4
       # OEIS-Other: A000004 planepath=Columns,height=1 delta_type=TDir6
     },

     # OFFSET
     # 'Math::PlanePath::Rows,width=2' =>
     # { dX    => 'A033999', # 1,-1 repeating
     #   TDir6 => 'A010673', # 0,2 repeating
     #   # OEIS-Other: A033999 planepath=Rows,width=2 delta_type=dX
     #   # OEIS-Other: A010673 planepath=Rows,width=2 delta_type=TDir6
     # },
     # 'Math::PlanePath::Columns,height=2' =>
     # { dY   => 'A033999', # 1,-1 repeating
     #   # OEIS-Other: A033999 planepath=Columns,height=2 delta_type=dY
     # },

     # OFFSET
     # 'Math::PlanePath::Rows,width=3' =>
     # { dX   => 'A061347', # 1,1,-2 repeating
     #   dY   => 'A022003', # 0,0,1 repeating
     #   # OEIS-Other: A061347 planepath=Rows,width=3 delta_type=dX
     #   # OEIS-Other: A022003 planepath=Rows,width=3 delta_type=dY
     # },
     # 'Math::PlanePath::Columns,height=3' =>
     # { dX   => 'A022003', # 0,0,1 repeating
     #   dY   => 'A061347', # 1,1,-2 repeating
     #   # OEIS-Other: A022003 planepath=Columns,height=3 delta_type=dX
     #   # OEIS-Other: A061347 planepath=Columns,height=3 delta_type=dY
     # },

     'Math::PlanePath::Rows,width=4' =>
     { dY   => 'A011765', # 0,0,0,1 repeating, starting n=1
       # OEIS-Other: A011765 planepath=Rows,width=4 delta_type=dY
     },
     'Math::PlanePath::Columns,height=4' =>
     { dX   => 'A011765', # 0,0,0,1 repeating, starting n=1
       # OEIS-Other: A011765 planepath=Columns,height=4 delta_type=dX
     },

     # OFFSET
     # 'Math::PlanePath::Rows,width=6' =>
     # { dY   => 'A172051', # 0,0,0,1 repeating, starting n=0
     #   # OEIS-Other: A172051 planepath=Rows,width=6 delta_type=dY
     # },
     # 'Math::PlanePath::Columns,height=6' =>
     # { dX   => 'A172051', # 0,0,0,1 repeating, starting n=0
     #   # OEIS-Other: A172051 planepath=Columns,height=6 delta_type=dX
     # },
    );

sub oeis_anum {
  my ($self) = @_;
  ### PlanePathCoord oeis_anum() ...

  my $planepath_object = $self->{'planepath_object'};
  my $delta_type = $self->{'delta_type'};

  my $key = _planepath_oeis_key($planepath_object);
  ### $key

  {
    my $i_start = $self->i_start;
    if ($i_start != $planepath_object->n_start) {
      $key .= ",i_start=$i_start";
    }
    ### $i_start
    ### n_start: $planepath_object->n_start
  }
  ### $key

  return $oeis_anum{$key}->{$delta_type};
}

sub new {
  my $class = shift;
  ### NumSeq-PlanePathDelta new(): @_
  my $self = $class->SUPER::new(@_);

  my $planepath_object = ($self->{'planepath_object'}
                          ||= _planepath_name_to_object($self->{'planepath'}));
  ### $planepath_object

  $self->{'delta_func'}
    = $self->can("_delta_func_$self->{'delta_type'}")
      || croak "Unrecognised delta_type: ",$self->{'delta_type'};

  $self->rewind;
  return $self;
}

sub i_start {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'} || return 0;
  return $planepath_object->n_start;
}
sub rewind {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'} || return;

  $self->{'i'} = $self->i_start;
  undef $self->{'x'};
  $self->{'arms_count'} = $planepath_object->arms_count;
}

sub next {
  my ($self) = @_;
  ### NumSeq-PlanePath next(): $self->{'i'}
  ### n_next: $self->{'n_next'}

  my $planepath_object = $self->{'planepath_object'};
  my $i = $self->{'i'}++;
  my $x = $self->{'x'};
  my $y;
  if (defined $x) {
    $y = $self->{'y'};
  } else {
    ($x, $y) = $planepath_object->n_to_xy ($i)
      or return;
  }

  my $arms = $self->{'arms_count'};
  my ($next_x, $next_y) = $planepath_object->n_to_xy($i + $arms)
    or return;
  my $value = &{$self->{'delta_func'}}($x,$y, $next_x,$next_y);

  if ($arms == 1) {
    $self->{'x'} = $next_x;
    $self->{'y'} = $next_y;
  }
  return ($i, $value);
}

sub ith {
  my ($self, $i) = @_;
  ### NumSeq-PlanePath ith(): $i

  my $planepath_object = $self->{'planepath_object'};
  my ($x, $y) = $planepath_object->n_to_xy ($i)
    or return undef;
  my ($next_x, $next_y) = $planepath_object->n_to_xy ($i + $self->{'arms_count'})
    or return undef;
  return &{$self->{'delta_func'}}($x,$y, $next_x,$next_y);
}

sub _delta_func_dX {
  my ($x,$y, $next_x,$next_y) = @_;
  ### _delta_func_dX() ...
  return $next_x - $x;
}
sub _delta_func_dY {
  my ($x,$y, $next_x,$next_y) = @_;
  ### _delta_func_dY() ...
  return $next_y - $y;
}
sub _delta_func_Dist {
  return sqrt(_delta_func_DistSquared(@_));
}
sub _delta_func_DistSquared {
  my ($x,$y, $next_x,$next_y) = @_;
  $x -= $next_x;
  $y -= $next_y;
  return $x*$x + $y*$y;
}

sub _delta_func_Dir4 {
  my ($x,$y, $next_x,$next_y) = @_;
  ### _delta_func_Dir4(): "$x,$y,  $next_x,$next_y"

  return _delta_func_Dir360($x,$y, $next_x,$next_y) / 90;
}
sub _delta_func_TDir6 {
  my ($x,$y, $next_x,$next_y) = @_;
  ### _delta_func_TDir6(): "$x,$y,  $next_x,$next_y"

  return _delta_func_TDir360($x,$y, $next_x,$next_y) / 60;
}
sub _delta_func_Dir8 {
  my ($x,$y, $next_x,$next_y) = @_;
  return _delta_func_Dir360($x,$y, $next_x,$next_y) / 45;
}

use constant 1.02; # for leading underscore
use constant _PI => 4 * atan2(1,1);  # similar to Math::Complex

sub _delta_func_Dir360 {
  my ($x,$y, $next_x,$next_y) = @_;
  ### _delta_func_Dir360(): "$x,$y,  $next_x,$next_y"

  my $dx = $next_x - $x;
  my $dy = $next_y - $y;
  ### dxdy: "$dx $dy"

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

  # Crib: atan2() returns -PI <= a <= PI, and perlfunc says atan2(0,0) is
  # "not well defined", though glibc gives 0
  #
  ### atan2: atan2($dy,$dx)
  ### atan2 degrees: atan2($dy,$dx) * (180 / _PI)
  my $degrees = atan2($dy,$dx) * (180 / _PI);
  return ($degrees < 0 ? $degrees + 360 : $degrees);
}

sub _delta_func_TDir360 {
  my ($x,$y, $next_x,$next_y) = @_;
  ### _delta_func_TDir360(): "$x,$y,  $next_x,$next_y"

  my $dx = $next_x - $x;
  my $dy = $next_y - $y;
  ### dxdy: "$dx $dy"

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

sub characteristic_increasing {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'};
  my $func;
  return
    (($func = ($planepath_object->can("_NumSeq_Delta_$self->{'delta_type'}_increasing")
               || ($self->{'delta_type'} eq 'DistSquared'
                   && $planepath_object->can("_NumSeq_Delta_Dist_increasing"))))
     ? $planepath_object->$func()
     : undef); # unknown
}

sub characteristic_non_decreasing {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'};
  my $func;
  return
    (($func = ($planepath_object->can("_NumSeq_Delta_$self->{'delta_type'}_non_decreasing")
               || ($self->{'delta_type'} eq 'DistSquared'
                   && $planepath_object->can("_NumSeq_Delta_Dist_non_decreasing"))))
     ? $planepath_object->$func()
     : undef); # unknown
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

  sub _NumSeq_Delta_Dist_min {
    my ($self) = @_;
    sqrt($self->_NumSeq_Delta_DistSquared_min);
  }
  sub _NumSeq_Delta_Dist_max {
    my ($self) = @_;
    my $max;
    return (defined ($max = $self->_NumSeq_Delta_DistSquared_max)
            ? sqrt($max)
            : undef);
  }

  sub _NumSeq_Delta_DistSquared_min {
    my ($self) = @_;
    my $dx = 0;
    if (defined(my $dx_min = $self->_NumSeq_Delta_dX_min)) {
      if ($dx_min > 0) {
        $dx = $dx_min;
      }
    } elsif (defined(my $dx_max = $self->_NumSeq_Delta_dX_max)) {
      if ($dx_max < 0) {
        $dx = $dx_max;
      }
    }
    my $dy = 0;
    if (defined(my $dy_min = $self->_NumSeq_Delta_dy_min)) {
      if ($dy_min > 0) {
        $dy = $dy_min;
      }
    } elsif (defined(my $dy_max = $self->_NumSeq_Delta_dy_max)) {
      if ($dy_max < 0) {
        $dy = $dy_max;
      }
    }
    return $dx*$dx + $dy*$dy;  # usually 0
  }
  sub _NumSeq_Delta_DistSquared_max {
    my ($self) = @_;
    if (defined (my $dx_min = $self->_NumSeq_Delta_dX_min)
        && defined (my $dx_max = $self->_NumSeq_Delta_dX_max)
        && defined (my $dy_min = $self->_NumSeq_Delta_dy_min)
        && defined (my $dy_max = $self->_NumSeq_Delta_dy_max)) {
      return (max(abs($dx_min),abs($dx_max)) ** 2
              + max(abs($dy_min),abs($dy_max)) ** 2);
    }
    return undef;
  }

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
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
{ package Math::PlanePath::PyramidSpiral;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 2.5; # at most SW diagonal
  use constant _NumSeq_Delta_TDir6_max => 4;  # at most SW diagonal
}
{ package Math::PlanePath::TriangleSpiral;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 2;
  use constant _NumSeq_Delta_DistSquared_max => 4;
  use constant _NumSeq_Delta_Dir4_max => 2.5; # at most SW diagonal
  use constant _NumSeq_Delta_TDir6_max => 4;  # at most SW diagonal
}
{ package Math::PlanePath::TriangleSpiralSkewed;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 2;
  use constant _NumSeq_Delta_TDir6_max => 4.5;  # at most S vertical
}
{ package Math::PlanePath::DiamondSpiral;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::AztecDiamondRings;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::PentSpiral;
  use constant _NumSeq_Delta_dX_min => -2;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 2;
  use constant _NumSeq_Delta_DistSquared_max => 4;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::PentSpiralSkewed;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5;  # SE diagonal
}
{ package Math::PlanePath::HexSpiral;
  use constant _NumSeq_Delta_dX_min => -2;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 2;
  use constant _NumSeq_Delta_DistSquared_max => 4;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::HexSpiralSkewed;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::HeptSpiralSkewed;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 2;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # S vertical at most
}
{ package Math::PlanePath::OctagramSpiral;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::AnvilSpiral;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::KnightSpiral;
  use constant _NumSeq_Delta_dX_min => -2;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -2;
  use constant _NumSeq_Delta_dY_max => 2;
  use constant _NumSeq_Delta_DistSquared_min => 5; # 2*2+1*1=5
  use constant _NumSeq_Delta_DistSquared_max => 5;
  # X=2,Y=1 angle
  use constant _NumSeq_Delta_Dir4_min =>
    Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (0,0, 2,1);
  use constant _NumSeq_Delta_Dir4_max =>
    Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (0,0, 2,-1);
  use constant _NumSeq_Delta_TDir6_min =>
    Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (0,0, 2,1);
  use constant _NumSeq_Delta_TDir6_max =>
    Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (0,0, 2,-1);
}
{ package Math::PlanePath::CretanLabyrinth;
  use constant _NumSeq_Delta_dX_min => -1;  # NSEW
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
{ package Math::PlanePath::SquareArms;
  use constant _NumSeq_Delta_dX_min => -1;  # NSEW
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
{ package Math::PlanePath::DiamondArms;  # diag always
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 2;
  use constant _NumSeq_Delta_DistSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_min => 0.5;  # diagonal
  use constant _NumSeq_Delta_Dir4_max => 3.5;  # diagonal
  use constant _NumSeq_Delta_TDir6_min => 1;  # diagonal
}
{ package Math::PlanePath::HexArms;
  use constant _NumSeq_Delta_dX_min => -2;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 2;
  use constant _NumSeq_Delta_DistSquared_max => 4;
  use constant _NumSeq_Delta_Dir4_max => 3.5;  # diagonal
}
{ package Math::PlanePath::GreekKeySpiral;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
{ package Math::PlanePath::SacksSpiral;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_Dir4_max  => 4;  # supremum
  use constant _NumSeq_Delta_TDir6_max => 6;  # supremum
}
# { package Math::PlanePath::VogelFloret;
# }
{ package Math::PlanePath::TheodorusSpiral;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 1;
  use constant _NumSeq_Delta_Dir4_max  => 4;  # supremum
  use constant _NumSeq_Delta_TDir6_max => 6;  # supremum
}
{ package Math::PlanePath::ArchimedeanChords;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 1;
  use constant _NumSeq_Delta_Dir4_max  => 4;  # supremum
  use constant _NumSeq_Delta_TDir6_max => 6;  # supremum
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
    return ($self->{'step'} == 0
            ? 1   # horizontal only

            : $self->{'step'} <= 6
            ? (-2*_PI()) / $self->{'step'}

            : -1); # supremum
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
            * (2-cos(2*_PI()/$self->{'step'})))
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

  use constant _NumSeq_Delta_DistSquared_min => 1;
  sub _NumSeq_Delta_DistSquared_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 1    # horizontal only

            : $self->{'step'} <= 6
            ? ((8*atan2(1,1)) / $self->{'step'}) ** 2

            # step > 6, between rings
            : ((0.5/_PI()) * $self->{'step'}) ** 2);
  }

  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
           ? 0   # horizontal only
           : 4); # supremum, full circle
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
  *_NumSeq_Delta_dY_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_DistSquared_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_Dir4_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_TDir6_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
}
{ package Math::PlanePath::PixelRings;  # NSEW+diag
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 2;  # jump N=5 to N=6
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # diagonal
}
{ package Math::PlanePath::FilledRings;  # NSEW+diag
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # diagonal
}
{ package Math::PlanePath::Hypot;
  use constant _NumSeq_Delta_Dir4_max => 4;  # supremum, almost full way
  use constant _NumSeq_Delta_TDir6_max => 6; # supremum, almost full way
}
{ package Math::PlanePath::HypotOctant;
  # max direction SE diagonal as anything else is at most tangent to the
  # eighth of a circle
  use constant _NumSeq_Delta_Dir4_max => 3.5;
}
# { package Math::PlanePath::TriangularHypot;
# }
# { package Math::PlanePath::PythagoreanTree;
# }
# { package Math::PlanePath::RationalsTree;
# }
# { package Math::PlanePath::FractionsTree;
# }
{ package Math::PlanePath::DiagonalRationals;
  use constant _NumSeq_Delta_Dir4_min => 1;    # vertical
  use constant _NumSeq_Delta_Dir4_max => 3.5;  # SE diagonal
  use constant _NumSeq_Delta_TDir6_min => 1.5; # vertical
}
# { package Math::PlanePath::FactorRationals;
# }
{ package Math::PlanePath::GcdRationals;
  # N+1 goes SE diagonal and across 1, at most SE N=2 to N=3
  use constant _NumSeq_Delta_Dir4_max => 3.5;  # SE diagonal
}
{ package Math::PlanePath::PeanoCurve;
  sub _NumSeq_Delta_dX_min {
    my ($self) = @_;
    return ($self->{'radix'} % 2 ? -1 : undef);
  }
  sub _NumSeq_Delta_dX_max {
    my ($self) = @_;
    return ($self->{'radix'} % 2 ? 1 : undef);
  }
  sub _NumSeq_Delta_dY_min {
    my ($self) = @_;
    return ($self->{'radix'} % 2 ? -1 : undef);
  }
  sub _NumSeq_Delta_dY_max {
    my ($self) = @_;
    return ($self->{'radix'} % 2 ? 1 : undef);
  }
  sub _NumSeq_Delta_DistSquared_min {
    my ($self) = @_;
    return ($self->{'radix'} % 2 ? 1 : undef);
  }
  sub _NumSeq_Delta_DistSquared_max {
    my ($self) = @_;
    return ($self->{'radix'} % 2 ? 1 : undef);
  }
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
{ package Math::PlanePath::HilbertCurve;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
{ package Math::PlanePath::HilbertSpiral;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
# { package Math::PlanePath::HilbertMidpoints;
#   use constant _NumSeq_Delta_dX_min => -2;
#   use constant _NumSeq_Delta_dX_max => 2;
#   use constant _NumSeq_Delta_dY_min => -2;
#   use constant _NumSeq_Delta_dY_max => 2;
#   use constant _NumSeq_Delta_DistSquared_min => 2;
#   use constant _NumSeq_Delta_DistSquared_max => 4;
# }
{ package Math::PlanePath::ZOrderCurve;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;

  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return Math::NumSeq::PlanePathDelta::_delta_func_Dir4
      (0,0, 1, 1 - $self->{'radix'});  # SE diagonal
  }
  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    return Math::NumSeq::PlanePathDelta::_delta_func_TDir6
      (0,0, 1, 1 - $self->{'radix'});  # SE diagonal
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
  # approaches dx=1,dy=-2  dx/dy=0.5
  # which is 4-atan2(2,1)/atan2(1,1)/2
  #
  # radix=3
  # dy=dx+1 approches SE
  #
  # radix=4 dx/dy=1.5
  # radix=5 dx/dy=2
  # dx/dy=(radix-1)/2

  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return Math::NumSeq::PlanePathDelta::_delta_func_Dir4
      (0,0, $self->{'radix'}-1,-2);
  }
  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    return Math::NumSeq::PlanePathDelta::_delta_func_TDir6
      (0,0, $self->{'radix'}-1,-2);
  }
}
# { package Math::PlanePath::Flowsnake;
#   # inherit from FlowsnakeCentres
# }
{ package Math::PlanePath::FlowsnakeCentres;
  use constant _NumSeq_Delta_dX_min => -2;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 2;
  use constant _NumSeq_Delta_DistSquared_max => 4;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::GosperIslands;
  use constant _NumSeq_Delta_DistSquared_min => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::GosperSide;
  use constant _NumSeq_Delta_dX_min => -2;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 2;
  use constant _NumSeq_Delta_DistSquared_max => 4;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}

{ package Math::PlanePath::KochCurve;
  use constant _NumSeq_Delta_dX_min => -2;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 2;
  use constant _NumSeq_Delta_DistSquared_max => 4;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::KochPeaks;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::KochSnowflakes;
  use constant _NumSeq_Delta_DistSquared_min => 2; # step diag or 2straight
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::KochSquareflakes;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}

{ package Math::PlanePath::QuadricCurve;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
{ package Math::PlanePath::QuadricIslands;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}

{ package Math::PlanePath::SierpinskiCurve;
  sub _NumSeq_Delta_dX_max {
    my ($self) = @_;
    return Math::PlanePath::_max ($self->{'straight_spacing'},
                 $self->{'diagonal_spacing'});
  }
  *_NumSeq_Delta_dY_max = \&_NumSeq_Delta_dX_max;

  sub _NumSeq_Delta_dX_min {
    my ($self) = @_;
    return - Math::PlanePath::_max ($self->{'straight_spacing'},
                   $self->{'diagonal_spacing'});
  }
  *_NumSeq_Delta_dY_min = \&_NumSeq_Delta_dX_min;

  sub _NumSeq_Delta_DistSquared_min {
    my ($self) = @_;
    return Math::PlanePath::_min ($self->{'straight_spacing'} ** 2,
                 $self->{'diagonal_spacing'} ** 2);
  }
  sub _NumSeq_Delta_DistSquared_max {
    my ($self) = @_;
    return Math::PlanePath::_max ($self->{'straight_spacing'} ** 2,
                 $self->{'diagonal_spacing'} ** 2);
  }
  use constant _NumSeq_Delta_Dir4_max => 3.5; # diagonal
}
{ package Math::PlanePath::SierpinskiTriangle;
  use constant _NumSeq_Delta_dY_min => 0;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 2;
  use constant _NumSeq_Delta_Dir4_max => 2;  # supremum, west and 1 up
  use constant _NumSeq_Delta_TDir6_max => 3; # supremum, west and 1 up
}
{ package Math::PlanePath::SierpinskiArrowhead;
  use constant _NumSeq_Delta_dX_min => -2;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 2;
  use constant _NumSeq_Delta_DistSquared_max => 4;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::SierpinskiArrowheadCentres;
  use constant _NumSeq_Delta_dX_min => -2;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 2;
  use constant _NumSeq_Delta_DistSquared_max => 4;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}

{ package Math::PlanePath::DragonCurve;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
{ package Math::PlanePath::DragonRounded;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::DragonMidpoint;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
{ package Math::PlanePath::AlternatePaper;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
{ package Math::PlanePath::TerdragonCurve;
  use constant _NumSeq_Delta_dX_min => -2;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 2;
  use constant _NumSeq_Delta_DistSquared_max => 4;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::TerdragonMidpoint;
  use constant _NumSeq_Delta_dX_min => -2;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 2;
  use constant _NumSeq_Delta_DistSquared_max => 4;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::ComplexPlus;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_Dir4_max => 4;  # supremum, almost full way
  use constant _NumSeq_Delta_TDir6_max => 6; # supremum, almost full way
}
{ package Math::PlanePath::ComplexMinus;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_Dir4_max => 4;  # supremum, almost full way
  use constant _NumSeq_Delta_TDir6_max => 6; # supremum, almost full way
}
{ package Math::PlanePath::ComplexRevolving;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_Dir4_max => 4;  # supremum, almost full way
  use constant _NumSeq_Delta_TDir6_max => 6; # supremum, almost full way
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

  use constant _NumSeq_Delta_DistSquared_min => 1;
  sub _NumSeq_Delta_DistSquared_max {
    my ($self) = @_;
    return 1 + $self->{'width'} ** 2;
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
      (0,0, $self->_NumSeq_Delta_dX_min, 1);
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
      (0,0, $self->_NumSeq_Delta_dX_min, 1);
  }

  sub _NumSeq_Delta_dX_non_decreasing {
    my ($self) = @_;
    return ($self->{'width'} <= 1
           ? 1  # single column only, dX=0 always
           : 0);
  }
  *_NumSeq_Delta_dY_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_Dir4_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_TDir6_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
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

  sub _NumSeq_Delta_Dir4_min {
    my ($self) = @_;
    return ($self->{'height'} == 1
            ? 0   # east only
            : 1); # N to SE
  }
  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return Math::NumSeq::PlanePathDelta::_delta_func_Dir4
      (0,0, 1, $self->_NumSeq_Delta_dY_min);
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
      (0,0, 1, $self->_NumSeq_Delta_dY_min);
  }

  use constant _NumSeq_Delta_DistSquared_min => 1;
  sub _NumSeq_Delta_DistSquared_max {
    my ($self) = @_;
    return 1 + $self->{'height'} ** 2;
  }

  sub _NumSeq_Delta_dX_non_decreasing {
    my ($self) = @_;
    return ($self->{'height'} <= 1);  # Y=0,1,2 when height==1
  }
  *_NumSeq_Delta_dY_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_Dir4_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_TDir6_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
}

{ package Math::PlanePath::Diagonals;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_DistSquared_min => 2;
  use constant _NumSeq_Delta_Dir4_min => 1; # vertical or more
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
  use constant _NumSeq_Delta_TDir6_min => 1.5; # vertical or more
}
{ package Math::PlanePath::DiagonalsAlternating;
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::MPeaks;
  use constant _NumSeq_Delta_Dir4_min => 0.5; # NE diagonal
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
  use constant _NumSeq_Delta_TDir6_min => 1; # NE diagonal
}
{ package Math::PlanePath::Staircase;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
{ package Math::PlanePath::StaircaseAlternating;
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

  use constant _NumSeq_Delta_DistSquared_min => 1;
  {
    my %DistSquared_max = (jump   => 4,
                           square => 1);
    sub _NumSeq_Delta_DistSquared_max {
      my ($self) = @_;
      return $DistSquared_max{$self->{'end_type'}};
    }
  }

  use constant _NumSeq_Delta_TDir6_max => 4.5; # vertical
}
{ package Math::PlanePath::Corner;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
{ package Math::PlanePath::PyramidRows;
  sub _NumSeq_Delta_dY_min {
    my ($self) = @_;
    return ($self->{'step'} == 0 ? 1 : 0);
  }
  use constant _NumSeq_Delta_dY_max => 1;

  use constant _NumSeq_Delta_DistSquared_min => 1;
  sub _NumSeq_Delta_DistSquared_max {
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

  sub _NumSeq_Delta_dX_non_decreasing {
    my ($self) = @_;
    return ($self->{'step'} == 0);  # step=0 is dX=0,dY=1 always
  }
  *_NumSeq_Delta_dY_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_Dir4_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
  *_NumSeq_Delta_TDir6_non_decreasing = \&_NumSeq_Delta_dX_non_decreasing;
}
{ package Math::PlanePath::PyramidSides;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 2;
  use constant _NumSeq_Delta_Dir4_min => 0.5;  # NE diagonal
  use constant _NumSeq_Delta_Dir4_max => 3.5;  # SE diagonal
  use constant _NumSeq_Delta_TDir6_min => 1;   # NE diagonal
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

  use constant _NumSeq_Delta_DistSquared_min => 1;

  {
    my $dir4_max_left2
      = Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (0,0, -2,1);
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
  }
  {
    my $tdir6_max_left2
      = Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (0,0, -2,1);
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

  sub _NumSeq_Delta_DistSquared_min {
    my ($path) = @_;
    return abs($path->{'sign'}) + 1;
  }
  use constant _NumSeq_Delta_DistSquared_max => 1;

  sub _NumSeq_Delta_Dir4_min {
    my ($path) = @_;
    # 1  -> 0.5 right
    # 0  -> 1 vertical
    # -1 -> 1.5 left
    return 1 - $path->{'sign'}/2;
  }
  *_NumSeq_Delta_Dir4_max = \&_NumSeq_Delta_Dir4_min;

  sub _NumSeq_Delta_TDir6_min {
    my ($path) = @_;
    # 1  -> 1 right
    # 0  -> 1.5 vertical
    # -1 -> 2 left
    return (3 - $path->{'sign'})/2;
  }
  *_NumSeq_Delta_TDir6_max = \&_NumSeq_Delta_TDir6_min;

  use constant _NumSeq_Delta_dX_non_decreasing => 1; # constant
  use constant _NumSeq_Delta_dY_non_decreasing => 1; # constant
  use constant _NumSeq_Delta_Dir4_non_decreasing => 1; # constant
  use constant _NumSeq_Delta_TDir6_non_decreasing => 1; # constant
}
{ package Math::PlanePath::CellularRule::OddSolid;
  use constant _NumSeq_Delta_dX_max => 2;
  use constant _NumSeq_Delta_dY_min => 0;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 2;
  use constant _NumSeq_Delta_Dir4_max => 2; # west and up
  use constant _NumSeq_Delta_TDir6_max => 3; # west and up
}
{ package Math::PlanePath::CellularRule::LeftSolid;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => 0;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
}
{ package Math::PlanePath::CellularRule54;
  use constant _NumSeq_Delta_dX_max => 4;
  use constant _NumSeq_Delta_dY_min => 0;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_Dir4_max => 2;  # supremum, west and 1 up
  use constant _NumSeq_Delta_TDir6_max => 3; # supremum, west and 1 up
  use constant _NumSeq_Delta_DistSquared_min => 1;
}
{ package Math::PlanePath::CellularRule57;
  use constant _NumSeq_Delta_dX_max => 3;
  use constant _NumSeq_Delta_dY_min => 0;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_Dir4_max => 2;  # supremum, west and 1 up
  use constant _NumSeq_Delta_TDir6_max => 3; # supremum, west and 1 up
  use constant _NumSeq_Delta_DistSquared_min => 1;
}
{ package Math::PlanePath::CellularRule190;
  use constant _NumSeq_Delta_dX_max => 2; # across gap
  use constant _NumSeq_Delta_dY_min => 0;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_Dir4_max => 2;  # supremum, west and 1 up
  use constant _NumSeq_Delta_TDir6_max => 3; # supremum, west and 1 up
  use constant _NumSeq_Delta_DistSquared_min => 1;
}
{ package Math::PlanePath::UlamWarburton;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
# { package Math::PlanePath::UlamWarburtonQuarter;
# }
{ package Math::PlanePath::CoprimeColumns;
  use constant _NumSeq_Delta_dX_min => 0;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # at most SE diagonal
}
{ package Math::PlanePath::DivisibleColumns;
  use constant _NumSeq_Delta_dX_min => 0;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # at most SE diagonal
}
# { package Math::PlanePath::File;
#   # FIXME: analyze points for dx/dy min/max etc
# }
{ package Math::PlanePath::QuintetCurve;  # NSEW
  # inherit QuintetCentres, except
  use constant _NumSeq_Delta_DistSquared_max => 1;
  use constant _NumSeq_Delta_Dir4_max => 3; # vertical
  use constant _NumSeq_Delta_TDir6_max => 4.5; # vertical
}
{ package Math::PlanePath::QuintetCentres;  # NSEW+diag
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::AR2W2Curve;     # NSEW+diag
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 2;
  use constant _NumSeq_Delta_Dir4_max => 3.5; # SE diagonal
}
{ package Math::PlanePath::KochelCurve;     # NSEW
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
{ package Math::PlanePath::BetaOmega;    # NSEW
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
{ package Math::PlanePath::CincoCurve;    # NSEW
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
{ package Math::PlanePath::WunderlichMeander;    # NSEW
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
{ package Math::PlanePath::HIndexing;   # NSEW
  use constant _NumSeq_Delta_dX_min => -1;
  use constant _NumSeq_Delta_dX_max => 1;
  use constant _NumSeq_Delta_dY_min => -1;
  use constant _NumSeq_Delta_dY_max => 1;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
{ package Math::PlanePath::DigitGroups;
  use constant _NumSeq_Delta_DistSquared_min => 1;
}
{ package Math::PlanePath::CornerReplicate;
  use constant _NumSeq_Delta_DistSquared_min => 1;

  sub _NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return Math::NumSeq::PlanePathDelta::_delta_func_Dir4 (0,0, 2,-1);  # SE
  }
  sub _NumSeq_Delta_TDir6_max {
    my ($self) = @_;
    return Math::NumSeq::PlanePathDelta::_delta_func_TDir6 (0,0, 2,-1);  # SE
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
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_DistSquared_max => 1;
  use constant _NumSeq_Delta_TDir6_max => 4.5; # no SE diagonal
}
{ package Math::PlanePath::LTiling;
  use constant _NumSeq_Delta_DistSquared_min => 1;
  use constant _NumSeq_Delta_Dir4_max => 4;  # supremum, almost full way
  use constant _NumSeq_Delta_TDir6_max => 6; # supremum, almost full way
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
#   } elsif ($delta_type eq 'SqRadius') {
#     # FIXME: only sum of two squares, and for triangular same odd/even
#     return ($value >= 0);
#   }
#
#   return undef;
# }


=for stopwords Ryde TDir6 Math-NumSeq Math-PlanePath NumSeq SquareSpiral

=head1 NAME

Math::NumSeq::PlanePathDelta -- sequence of changes in PlanePath X,Y coordinates

=head1 SYNOPSIS

 use Math::NumSeq::PlanePathDelta;
 my $seq = Math::NumSeq::PlanePathDelta->new (planepath => 'SquareSpiral',
                                              delta_type => 'dX');
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This is a tie-in to present coordinate changes from a C<Math::PlanePath>
module in the form of a NumSeq sequence.

The C<delta_type> choices are

    "dX"       change in X coordinate
    "dY"       change in Y coordinate
    "Dir4"     direction 0=East, 1=North, 2=West, 3=South
    "TDir6"    triangular 0=E, 1=NE, 2=NW, 3=W, 4=SW, 5=SE

In each case the value at i is the change from N=i to N=i+1 on the path, or
N=i to N=i+arms for paths with multiple "arms" (thus following a particular
arm).  i values start from the usual path C<n_start()>.

"Dir4" is a fraction when a delta is in between the cardinal directions.
For example North-West dX=-1,dY=+1 would be 1.5.

"TDir6" direction is in the style of L<Math::PlanePath/Triangular Lattice>.
So dX=1,dY=1 is 60 degrees, dX=-1,dY=1 is 120 degrees, dX=-2,dY=0 is 180
degrees, etc, and fractional values in between those.

=head1 FUNCTIONS

See L<Math::NumSeq/FUNCTIONS> for behaviour common to all sequence classes.

=over 4

=item C<$seq = Math::NumSeq::PlanePathDelta-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.  The options are

    planepath          string, name of a PlanePath module
    planepath_object   PlanePath object
    delta_type         string, as described above

C<planepath> can be just the module part such as "SquareSpiral" or a full
class name "Math::PlanePath::SquareSpiral".

=item C<$value = $seq-E<gt>ith($i)>

Return the change at N=$i in the PlanePath.

=item C<$i = $seq-E<gt>i_start()>

Return the first index C<$i> in the sequence.  This is the position
C<rewind()> returns to.

This is C<$path-E<gt>n_start()> from the PlanePath.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::PlanePathCoord>,
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
