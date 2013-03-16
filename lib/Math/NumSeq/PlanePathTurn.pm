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


# math-image --values=PlanePathTurn
#
# maybe:
# Turn4p   0,1,2,3  and fractional
# Turn4    0,1,2,-1  Turn4mid Turn4n Turn4s
# TTurn6   0,1,2,3, -1,-2,  eg. flowsnake  TTurn6s
# TTurn6p  0,1,2,3,4,5



package Math::NumSeq::PlanePathTurn;
use 5.004;
use strict;
use Carp;

use vars '$VERSION','@ISA';
$VERSION = 100;
use Math::NumSeq;
@ISA = ('Math::NumSeq');

use Math::NumSeq::PlanePathCoord;
use Math::PlanePath;
use Math::PlanePath::Base::Generic
  'is_infinite';

# uncomment this to run the ### lines
# use Smart::Comments;


use constant characteristic_smaller => 1;

sub description {
  my ($self) = @_;
  if (ref $self) {
    return "Turn values $self->{'turn_type'} from path $self->{'planepath'}";
  } else {
    # class method
    return 'Turns from a PlanePath';
  }
}

use constant::defer parameter_info_array =>
  sub {
    return [
            Math::NumSeq::PlanePathCoord::_parameter_info_planepath(),
            {
             name    => 'turn_type',
             display => 'Turn Type',
             type    => 'enum',
             default => 'Left',
             choices => ['Left',
                         'Right',
                         'LSR',
                        ],
             description => 'Left is 1=left, 0=right or straight.
Right is 1=right, 0=left or straight.
LSR is 1=left,0=straight,-1=right.',
            },
           ];
  };

my %characteristic_integer = (Left  => 1,
                              Right => 1,
                              LSR   => 1);
sub characteristic_integer {
  my ($self) = @_;
  return $characteristic_integer{$self->{'turn_type'}};
}

#------------------------------------------------------------------------------

sub oeis_anum {
  my ($self) = @_;
  ### PlanePathTurn oeis_anum() ...

  my $planepath = $self->{'planepath_object'};
  my $key = Math::NumSeq::PlanePathCoord::_planepath_oeis_anum_key($self->{'planepath_object'});

  ### planepath: ref $planepath
  ### $key
  ### whole table: $planepath->_NumSeq_Turn_oeis_anum
  ### key href: $planepath->_NumSeq_Turn_oeis_anum->{$key}

  return $planepath->_NumSeq_Turn_oeis_anum->{$key}->{$self->{'turn_type'}};
}

#------------------------------------------------------------------------------

sub new {
  my $class = shift;
  ### PlanePathTurn new(): @_
  my $self = $class->SUPER::new(@_);
  ### self from SUPER: $self

  $self->{'planepath_object'}
    ||= Math::NumSeq::PlanePathCoord::_planepath_name_to_object($self->{'planepath'});


  ### turn_func: "_turn_func_$self->{'turn_type'}", $self->{'turn_func'}
  $self->{'turn_func'}
    = $self->can('_turn_func_'.$self->{'turn_type'})
      || croak "Unrecognised turn_type: ",$self->{'turn_type'};

  $self->rewind;
  return $self;
}

sub i_start {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'} || return 0;
  return $planepath_object->n_start + $planepath_object->arms_count;
}
sub rewind {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'} || return;

  $self->{'i'} = $self->i_start;
  $self->{'arms'} = $planepath_object->arms_count;
  undef $self->{'x'};
}

sub next {
  my ($self) = @_;
  ### NumSeq-PlanePathTurn next(): "i=$self->{'i'}"

  my $planepath_object = $self->{'planepath_object'};

  my $i = $self->{'i'}++;
  my $arms = $self->{'arms'};

  my $x = $self->{'x'};
  my ($y, $dx,$dy);
  if (defined $x) {
    $y = $self->{'y'};
    $dx = $self->{'dx'};
    $dy = $self->{'dy'};
  } else {
    ($x, $y) = $planepath_object->n_to_xy ($i)
      or do {
        ### nothing in path at n: $i
        return;
      };
    my ($prev_x, $prev_y) = $planepath_object->n_to_xy ($i-$arms)
      or do {
        ### nothing in path at previous n: $i-$arms
        return;
      };
    $dx = $x - $prev_x;
    $dy = $y - $prev_y;
  }

  my ($next_x, $next_y) = $planepath_object->n_to_xy($i+$arms)
    or return;
  my $next_dx = $next_x - $x;
  my $next_dy = $next_y - $y;
  my $value = $self->{'turn_func'}->($dx,$dy, $next_dx,$next_dy);

  if ($arms == 1) {
    $self->{'x'} = $next_x;
    $self->{'y'} = $next_y;
    $self->{'dx'} = $next_dx;
    $self->{'dy'} = $next_dy;
  }
  return ($i, $value);
}

sub ith {
  my ($self, $i) = @_;
  ### PlanePathTurn ith(): $i

  if (is_infinite($i)) {
    return undef;
  }

  my $planepath_object = $self->{'planepath_object'};
  my $arms = $self->{'arms'};
  my ($prev_x, $prev_y) = $planepath_object->n_to_xy ($i - $arms)
    or return undef;
  my ($x, $y) = $planepath_object->n_to_xy ($i)
    or return undef;
  my ($next_x, $next_y) = $planepath_object->n_to_xy ($i + $arms)
    or return undef;

  my $dx = $x - $prev_x;
  my $dy = $y - $prev_y;
  my $next_dx = $next_x - $x;
  my $next_dy = $next_y - $y;
  return $self->{'turn_func'}->($dx,$dy, $next_dx,$next_dy);

  #   return ($i, &{$self->{'turn_func'}}($self, $next_x,$next_y, $x,$y));
}

#            dx1,dy1
#  dx2,dy2  /
#       *  /
#         /
#        /
#       /
#      /
#     O
#
# cmpy = dx2 * dy1/dx1
# left if dy2 > cmpy
#         dy2 > dx2 * dy1/dx1
#         dy2 * dx1 > dx2 * dy1
#
# if dx1=0, dy1 > 0 then left if dx2 < 0
#    dy2 * 0 > dx2 * dy1
#          0 > dx2*dy1     good
#
sub _turn_func_Left {
  my ($dx,$dy, $next_dx,$next_dy) = @_;
  ### _turn_func_Left() ...
  return ($next_dy * $dx > $next_dx * $dy ? 1 : 0);
}
sub _turn_func_Right {
  my ($dx,$dy, $next_dx,$next_dy) = @_;
  ### _turn_func_Right() ...
  return ($next_dy * $dx < $next_dx * $dy ? 1 : 0);
}
sub _turn_func_LSR {
  my ($dx,$dy, $next_dx,$next_dy) = @_;
  ### _turn_func_LSR() ...
  return (($next_dy * $dx <=> $next_dx * $dy) || 0);  # 1,0,-1
}
# sub _turn_func_LR_01 {
#   my ($dx,$dy, $next_dx,$next_dy) = @_;
#   ### _turn_func_LR_01() ...
#   return ($next_dy * $dx >= $next_dx * $dy || 0);
# }

sub pred {
  my ($self, $value) = @_;
  ### PlanePathTurn pred(): $value
  my $planepath_object = $self->{'planepath_object'};

  my $turn_type = $self->{'turn_type'};
  if ($turn_type eq 'Left' || $turn_type eq 'Right') {
    unless ($value == 0 || $value == 1) {
      return 0;
    }
  } else { # ($turn_type eq 'LSR') {
    unless ($value == 1 || $value == 0 || $value == -1) {
      return 0;
    }
  }

  if (defined (my $values_min = $self->values_min)) {
    if ($value < $values_min) {
      return 0;
    }
  }
  if (defined (my $values_max = $self->values_max)) {
    if ($value > $values_max) {
      return 0;
    }
  }
  if (my $func = $planepath_object->can('_NumSeq_Turn_'.$self->{'turn_type'}.'_pred_hash')) {
    my $href = $self->$func();
    unless ($href->{$value}) {
      return 0;
    }
  }

  return 1;
}



#------------------------------------------------------------------------------

sub values_min {
  my ($self) = @_;

  my $method = '_NumSeq_Turn_' . $self->{'turn_type'} . '_min';
  return $self->{'planepath_object'}->can($method)
    ? $self->{'planepath_object'}->$method()
      : undef;
}

sub values_max {
  my ($self) = @_;

  my $method = '_NumSeq_Turn_' . $self->{'turn_type'} . '_max';
  return $self->{'planepath_object'}->can($method)
    ? $self->{'planepath_object'}->$method()
      : undef;
}

sub characteristic_increasing {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'};
  if (my $func = $planepath_object->can("_NumSeq_Turn_$self->{'turn_type'}_increasing")) {
    return $planepath_object->$func();
  }
  return undef; # unknown
}

sub characteristic_non_decreasing {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'};
  if (my $func = $planepath_object->can("_NumSeq_Turn_$self->{'turn_type'}_non_decreasing")) {
    return $planepath_object->$func();
  }
  if (defined (my $values_min = $self->values_min)) {
    if (defined (my $values_max = $self->values_max)) {
      if ($values_min == $values_max) {
        # constant seq is non-decreasing
        return 1;
      }
    }
  }
  # increasing means non_decreasing too
  return $self->characteristic_increasing;
}

# my $all_Left_predhash = { 0=>1, 1=>1 };
# my $all_LSR_predhash = { 0=>1, 1=>1, -1=>1 };
# my $straight_Left_predhash = { 0=>1 };
# my $straight_LSR_predhash = { 0=>1 };

{ package Math::PlanePath;

  use constant 1.02; # for leading underscore
  use constant _NumSeq_Turn_Left_min => 0;
  use constant _NumSeq_Turn_Left_max => 1;
  use constant _NumSeq_Turn_Right_min => 0;
  use constant _NumSeq_Turn_Right_max => 1;
  use constant _NumSeq_Turn_LSR_min => -1;
  use constant _NumSeq_Turn_LSR_max => 1;
  use constant _NumSeq_Turn_oeis_anum => {};
}

{ package Math::PlanePath::SquareSpiral;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
  use constant _NumSeq_Turn_Right_max => 0; # left or straight
  use constant _NumSeq_Turn_Right_non_decreasing => 1;
  # SquareSpiral
  # abs(A167752)==Left,LSR if that really is the quarter-squares
  # abs(A167753)==Left,LSR of wider=1 if that really is the ceil(n+1)^2
}
{ package Math::PlanePath::GreekKeySpiral;
  sub _NumSeq_Turn_LSR_min {
    my ($self) = @_;
    return ($self->{'turns'} == 0 ? 0  # SquareSpiral, left or straight only
            : -1);  # any left,straight,right
  }
  sub _NumSeq_Turn_Right_max {
    my ($self) = @_;
    return ($self->{'turns'} == 0 ? 0  # SquareSpiral, left or straight only
            : 1);
  }
  sub _NumSeq_Turn_Right_non_decreasing {
    my ($self) = @_;
    return ($self->{'turns'} == 0 ? 1 # SquareSpiral, left or straight only
            : 0);
  }
}
{ package Math::PlanePath::PyramidSpiral;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
  use constant _NumSeq_Turn_LSR_max => 1;
  use constant _NumSeq_Turn_Right_max => 0; # left or straight
  use constant _NumSeq_Turn_Right_non_decreasing => 1;
}
{ package Math::PlanePath::TriangleSpiral;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
  use constant _NumSeq_Turn_LSR_max => 1;
  use constant _NumSeq_Turn_Right_max => 0; # left or straight
  use constant _NumSeq_Turn_Right_non_decreasing => 1;

  use constant _NumSeq_Turn_oeis_anum =>
    { 'n_start=-1' =>
      { 'Left' => 'A023531',  # 1 at k*(k+3)/2
        'LSR'  => 'A023531',
        # OEIS-Other: A023531 planepath=TriangleSpiral,n_start=-1
        # OEIS-Other: A023531 planepath=TriangleSpiral,n_start=-1 turn_type=LSR
      },
    };
}
{ package Math::PlanePath::TriangleSpiralSkewed;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
  use constant _NumSeq_Turn_LSR_max => 1;
  use constant _NumSeq_Turn_Right_max => 0; # left or straight
  use constant _NumSeq_Turn_Right_non_decreasing => 1;

  use constant _NumSeq_Turn_oeis_anum =>
    {
     do {
       my $href = { 'Left' => 'A023531',  # 1 at k*(k+3)/2
                    'LSR'  => 'A023531',
                  };
       ('skew=left,n_start=-1' => $href,
        'skew=right,n_start=-1' => $href,
        'skew=up,n_start=-1' => $href,
        'skew=down,n_start=-1' => $href)
         # OEIS-Other: A023531 planepath=TriangleSpiralSkewed,n_start=-1
         # OEIS-Other: A023531 planepath=TriangleSpiralSkewed,n_start=-1 turn_type=LSR
         # OEIS-Other: A023531 planepath=TriangleSpiralSkewed,n_start=-1,skew=right
         # OEIS-Other: A023531 planepath=TriangleSpiralSkewed,n_start=-1,skew=up
         # OEIS-Other: A023531 planepath=TriangleSpiralSkewed,n_start=-1,skew=down
     },
    };
}
{ package Math::PlanePath::DiamondSpiral;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
  use constant _NumSeq_Turn_LSR_max => 1;
  use constant _NumSeq_Turn_Right_max => 0; # left or straight
  use constant _NumSeq_Turn_Right_non_decreasing => 1;
}
{ package Math::PlanePath::AztecDiamondRings;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
  use constant _NumSeq_Turn_Right_max => 0; # left or straight
  use constant _NumSeq_Turn_Right_non_decreasing => 1;
}
{ package Math::PlanePath::PentSpiral;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
  use constant _NumSeq_Turn_Right_max => 0; # left or straight
  use constant _NumSeq_Turn_Right_non_decreasing => 1;
}
{ package Math::PlanePath::PentSpiralSkewed;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
  use constant _NumSeq_Turn_Right_max => 0; # left or straight
  use constant _NumSeq_Turn_Right_non_decreasing => 1;
}
{ package Math::PlanePath::HexSpiral;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
  use constant _NumSeq_Turn_Right_max => 0; # left or straight
  use constant _NumSeq_Turn_Right_non_decreasing => 1;
}
{ package Math::PlanePath::HexSpiralSkewed;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
  use constant _NumSeq_Turn_Right_max => 0; # left or straight
  use constant _NumSeq_Turn_Right_non_decreasing => 1;
}
{ package Math::PlanePath::HeptSpiralSkewed;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
  use constant _NumSeq_Turn_Right_max => 0; # left or straight
  use constant _NumSeq_Turn_Right_non_decreasing => 1;
}
# { package Math::PlanePath::AnvilSpiral;
# }
# { package Math::PlanePath::OctagramSpiral;
# }
# { package Math::PlanePath::KnightSpiral;
# }
# { package Math::PlanePath::CretanLabyrinth;
# }
{ package Math::PlanePath::SquareArms;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
  use constant _NumSeq_Turn_LSR_max => 1;
  use constant _NumSeq_Turn_Right_max => 0; # left or straight
  use constant _NumSeq_Turn_Right_non_decreasing => 1;
}
{ package Math::PlanePath::DiamondArms;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
  use constant _NumSeq_Turn_LSR_max => 1;
  use constant _NumSeq_Turn_Right_max => 0; # left or straight
  use constant _NumSeq_Turn_Right_non_decreasing => 1;
}
{ package Math::PlanePath::HexArms;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
  use constant _NumSeq_Turn_LSR_max => 1;
  use constant _NumSeq_Turn_Right_max => 0; # left or straight
  use constant _NumSeq_Turn_Right_non_decreasing => 1;
}
{ package Math::PlanePath::SacksSpiral;
  use constant _NumSeq_Turn_Left_min => 1; # left always
  use constant _NumSeq_Turn_Left_max => 1;
  use constant _NumSeq_Turn_Left_non_decreasing => 1;
  use constant _NumSeq_Turn_LSR_min => 1;
  use constant _NumSeq_Turn_LSR_max => 1;
  use constant _NumSeq_Turn_LSR_non_decreasing => 1;
  use constant _NumSeq_Turn_Right_max => 0; # left always
  use constant _NumSeq_Turn_Right_non_decreasing => 1;

  use constant _NumSeq_Turn_oeis_anum =>
    { '' =>
      { 'Left' => 'A000012',  # left always, all ones
        'LSR'  => 'A000012',
        # OEIS-Other: A000012 planepath=SacksSpiral
        # OEIS-Other: A000012 planepath=SacksSpiral turn_type=LSR
      },
    };
}
{ package Math::PlanePath::VogelFloret;
  sub _NumSeq_Turn_Left_min {  # always left if rot<=0.5
    my ($self) = @_;
    return ($self->{'rotation_factor'} > 0.5 ? 0 : 1);
  }
  sub _NumSeq_Turn_Left_max {
    my ($self) = @_;
    return ($self->{'rotation_factor'} > 0.5 ? 0 : 1);
  }
  use constant _NumSeq_Turn_Left_non_decreasing => 1; # constant 0 or 1

  sub _NumSeq_Turn_Right_min {  # always right if rot>0.5
    my ($self) = @_;
    return ($self->{'rotation_factor'} > 0.5 ? 1 : 0);
  }
  sub _NumSeq_Turn_Right_max {
    my ($self) = @_;
    return ($self->{'rotation_factor'} > 0.5 ? 1 : 0);
  }
  use constant _NumSeq_Turn_Right_non_decreasing => 1; # constant 0 or 1

  sub _NumSeq_Turn_LSR_min {
    my ($self) = @_;
    return ($self->{'rotation_factor'} > 0.5 ? -1 : 1);
  }
  sub _NumSeq_Turn_LSR_max {
    my ($self) = @_;
    return ($self->{'rotation_factor'} > 0.5 ? -1 : 1);
  }
  use constant _NumSeq_Turn_LSR_non_decreasing => 1; # constant 1 or -1

  # sub _NumSeq_Turn_LSR_pred_hash {
  #   my ($self) = @_;
  #   return ($self->{'rotation_factor'} > 0.5 ? 1 : 0);
  # }
}
{ package Math::PlanePath::TheodorusSpiral;
  use constant _NumSeq_Turn_Left_min => 1; # left always
  use constant _NumSeq_Turn_Left_max => 1;
  use constant _NumSeq_Turn_Left_non_decreasing => 1;
  use constant _NumSeq_Turn_LSR_min => 1;
  use constant _NumSeq_Turn_LSR_max => 1;
  use constant _NumSeq_Turn_LSR_non_decreasing => 1;
  use constant _NumSeq_Turn_Right_max => 0; # left always
  use constant _NumSeq_Turn_Right_non_decreasing => 1;

  use constant _NumSeq_Turn_oeis_anum =>
    { '' =>
      { 'Left' => 'A000012',  # left always, all ones
        'LSR'  => 'A000012',
        # OEIS-Other: A000012 planepath=TheodorusSpiral
        # OEIS-Other: A000012 planepath=TheodorusSpiral turn_type=LSR
      },
    };
}
{ package Math::PlanePath::ArchimedeanChords;
  use constant _NumSeq_Turn_Left_min => 1; # left always
  use constant _NumSeq_Turn_Left_max => 1;
  use constant _NumSeq_Turn_Left_non_decreasing => 1;
  use constant _NumSeq_Turn_LSR_min => 1;
  use constant _NumSeq_Turn_LSR_max => 1;
  use constant _NumSeq_Turn_LSR_non_decreasing => 1;
  use constant _NumSeq_Turn_Right_max => 0; # left always
  use constant _NumSeq_Turn_Right_non_decreasing => 1;

  use constant _NumSeq_Turn_oeis_anum =>
    { '' =>
      { 'Left' => 'A000012',  # left always, all ones
        'LSR'  => 'A000012',
        # OEIS-Other: A000012 planepath=ArchimedeanChords
        # OEIS-Other: A000012 planepath=ArchimedeanChords turn_type=LSR
      },
    };
}
{ package Math::PlanePath::MultipleRings;

  # step=1 and step=2 are mostly 1 for left, but after a while each ring
  # endpoint is to the right

  sub _NumSeq_Turn_Left_max {
    my ($self) = @_;
    return ($self->{'step'} <= 0
            ? 0  # step == 0 is always straight ahead
            : 1);
  }

  sub _NumSeq_Turn_Right_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 0  # step == 0 is always straight ahead
            : 1);
  }

  sub _NumSeq_Turn_LSR_min {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 0  # step == 0 is always straight ahead
            : -1);
  }
  *_NumSeq_Turn_LSR_max = \&_NumSeq_Turn_Left_max;

  sub _NumSeq_Turn_Left_non_decreasing {
    my ($self) = @_;
    return ($self->{'step'} == 0);
  }
  *_NumSeq_Turn_Right_non_decreasing = \&_NumSeq_Turn_Left_non_decreasing;
  *_NumSeq_Turn_LSR_non_decreasing = \&_NumSeq_Turn_Left_non_decreasing;

  use constant _NumSeq_Turn_oeis_anum =>
    {
     # MultipleRings step=0 is trivial X=N,Y=0
     'step=0,ring_shape=circle' =>
     { Left => 'A000004',  # all-zeros
       LSR  => 'A000004',  # all zeros, straight
       # OEIS-Other: A000004 planepath=MultipleRings,step=0
       # OEIS-Other: A000004 planepath=MultipleRings,step=0 turn_type=LSR
     },
     'step=0,ring_shape=polygon' =>
     { Left => 'A000004',  # all-zeros
       LSR  => 'A000004',  # all zeros, straight
       # OEIS-Other: A000004 planepath=MultipleRings,step=0,ring_shape=polygon
       # OEIS-Other: A000004 planepath=MultipleRings,step=0,ring_shape=polygon turn_type=LSR
     },
    };
}
# { package Math::PlanePath::PixelRings;
#   # right turns between rings
# }
# { package Math::PlanePath::FilledRings;
# }
{ package Math::PlanePath::Hypot;
  sub _NumSeq_Turn_Left_min {
    my ($self) = @_;
    return ($self->{'points'} eq 'all'
            ? 1     # all, left always
            : 0);   # odd,even left or straight
  }
  sub _NumSeq_Turn_LSR_min {
    my ($self) = @_;
    return ($self->{'points'} eq 'all'
            ? 1     # all, left always
            : 0);   # odd,even left or straight
  }
  sub _NumSeq_Turn_Left_non_decreasing {
    my ($self) = @_;
    return ($self->{'points'} eq 'all'
            ? 1     # all, left always
            : 0);   # odd,even any
  }
  *_NumSeq_Turn_LSR_non_decreasing = \&_NumSeq_Turn_Left_non_decreasing;

  use constant _NumSeq_Turn_Right_max => 0; # always left or straight
  use constant _NumSeq_Turn_Right_non_decreasing => 1;
}
# { package Math::PlanePath::HypotOctant;
# }
{ package Math::PlanePath::TriangularHypot;
  sub _NumSeq_Turn_Left_min {
    my ($self) = @_;
    return ($self->{'points'} eq 'hex'
            ? 1     # hex, left always
            : 0);   # other, various left/right
  }
  *_NumSeq_Turn_Left_non_decreasing = \&_NumSeq_Turn_Left_min;

  sub _NumSeq_Turn_Right_max {
    my ($self) = @_;
    return ($self->{'points'} =~ /hex|even/
            ? 0     # even,hex, left or straight, so Right=0 always
            : 1);   # odd,all both left or right
  }
  sub _NumSeq_Turn_Right_non_decreasing {
    my ($self) = @_;
    return ($self->{'points'} =~ /hex|even/
            ? 1     # even,hex, left or straight, so Right=0 always
            : 0);   # odd,all both left or right
  }

  sub _NumSeq_Turn_LSR_min {
    my ($self) = @_;
    return ($self->{'points'} eq 'hex'
            ? 1     # hex, left always
            : $self->{'points'} =~ /even|hex_/
            ? 0     # even,hex, left or straight
            : -1);   # odd,all any
  }
  *_NumSeq_Turn_LSR_non_decreasing = \&_NumSeq_Turn_Left_min;
}
{ package Math::PlanePath::PythagoreanTree;
  {
    my %UAD_coordinates_always_right = (PQ => 1,
                                        AB => 1,
                                        AC => 1);
    sub _NumSeq_Turn_always_Right {
      my ($self) = @_;
      return ($self->{'tree_type'} eq 'UAD'
              && $UAD_coordinates_always_right{$self->{'coordinates'}});
    }
  }
  {
    my %UAD_coordinates_always_left = (BC => 1);
    sub _NumSeq_Turn_always_Left {
      my ($self) = @_;
      return ($self->{'tree_type'} eq 'UAD'
              && $UAD_coordinates_always_left{$self->{'coordinates'}});
    }
  }

  sub _NumSeq_Turn_Left_min {
    my ($self) = @_;
    return (_NumSeq_Turn_always_Left($self) ? 1 : 0);
  }
  sub _NumSeq_Turn_Left_max {
    my ($self) = @_;
    return (_NumSeq_Turn_always_Right($self) ? 0 : 1);
  }
  sub _NumSeq_Turn_Right_min {
    my ($self) = @_;
    return (_NumSeq_Turn_always_Right($self) ? 1 : 0);
  }
  sub _NumSeq_Turn_Right_max {
    my ($self) = @_;
    return (_NumSeq_Turn_always_Left($self) ? 0 : 1);
  }
  sub _NumSeq_Turn_LSR_min {
    my ($self) = @_;
    return (_NumSeq_Turn_always_Left($self) ? 1 : -1);
  }
  sub _NumSeq_Turn_LSR_max {
    my ($self) = @_;
    return (_NumSeq_Turn_always_Right($self) ? -1 : 1);
  }

  sub _NumSeq_Turn_Left_non_decreasing {
    my ($self) = @_;
    return (_NumSeq_Turn_always_Left($self)
            || _NumSeq_Turn_always_Right($self)
            ? 1 : 0);
  }
  *_NumSeq_Turn_Right_non_decreasing = \&_NumSeq_Turn_Left_non_decreasing;
  *_NumSeq_Turn_LSR_non_decreasing = \&_NumSeq_Turn_Left_non_decreasing;

  # A000004 all-zeros and A000012 all-ones are OFFSET=0 which doesn't match
  # start N=1 here for always turn left or right in UAD.
}
# { package Math::PlanePath::RationalsTree;
#   SB turn cf A021913 0,0,1,1
#              A133872 1,1,0,0
#              A057077 1,1,-1,-1
#              A087960 1,-1,-1,1
#   HCS turn left close to A010059 thue-morse or A092436
#            right A010060
#            LSR => 'A106400',  # thue-morse +/-1
#   CfracDigits radix=1 likewise
# }
# { package Math::PlanePath::FractionsTree;
# }
# { package Math::PlanePath::ChanTree;
#   # FIXME: k=4,5,6 are Right-only, maybe
#   # sub _NumSeq_Turn_Left_max {
#   #   my ($self) = @_;
#   #   return ($self->{'k'} >= 4
#   #           ? 0 # never Left
#   #           : 1);
#   # }
#   # sub _NumSeq_Turn_Right_min {
#   #   my ($self) = @_;
#   #   return ($self->{'k'} >= 4
#   #           ? 1 # always Right
#   #           : 0);
#   # }
#   # sub _NumSeq_Turn_LSR_max {
#   #   my ($self) = @_;
#   #   return ($self->{'k'} >= 4
#   #           ? -1 # always Right
#   #           : 1);
#   # }
# }
# { package Math::PlanePath::DiagonalRationals;
# }
# { package Math::PlanePath::FactorRationals;
# }
# { package Math::PlanePath::GcdRationals;
# }
# { package Math::PlanePath::PeanoCurve;
# # 'Math::PlanePath::PeanoCurve,radix=3' =>
# # {
# #  # Not quite, LSR here is 1,0,-1
# #  # A163536 relative direction 0=ahead,1=left,2=right OFFSET=1
# #  # SLR
# # },
# }
# { package Math::PlanePath::WunderlichSerpentine;
# }
# { package Math::PlanePath::HilbertCurve;
# 'Math::PlanePath::HilbertCurve' =>
# {
#  # Not quite, cf 1,0,-1 here
#  # A163542    relative direction ahead=0,left=1,right=2 OFFSET=1
#  # A163543    relative direction, transpose X,Y  ahead=0,right=1,left=2
#  # SLR  SRL
# },
# }
# { package Math::PlanePath::ZOrderCurve;
# }
{ package Math::PlanePath::GrayCode;
  # radix=2 TsF==Fs is always straight or left
  sub _NumSeq_Turn_Right_max {
    my ($self) = @_;
    if ($self->{'radix'} == 2
        && ($self->{'apply_type'} eq 'TsF'
            || $self->{'apply_type'} eq 'Fs')) {
      return 0; # never right
    }
    return 1;
  }
  sub _NumSeq_Turn_Right_non_decreasing {
    my ($self) = @_;
    if ($self->{'radix'} == 2
        && ($self->{'apply_type'} eq 'TsF'
            || $self->{'apply_type'} eq 'Fs')) {
      return 1; # never right
    }
    return 0;
  }
  sub _NumSeq_Turn_LSR_min {
    my ($self) = @_;
    if ($self->{'radix'} == 2
        && ($self->{'apply_type'} eq 'TsF'
            || $self->{'apply_type'} eq 'Fs')) {
      return 0; # never right
    }
    return -1;
  }

  # Not quite, A039963 is OFFSET=0 vs first turn at N=1 here
  # 'Math::PlanePath::GrayCode' =>
  # {
  #  Left => 'A039963',  # duplicated KochCurve
  #  LSR  => 'A039963',
  # },
  # Koch characteristic of A003159 ending even zeros
  # 'Math::PlanePath::GrayCode' =>
}
# { package Math::PlanePath::ImaginaryBase;
# }
# { package Math::PlanePath::ImaginaryHalf;
# }
# { package Math::PlanePath::CubicBase;
# }
# { package Math::PlanePath::Flowsnake;
# }
# { package Math::PlanePath::FlowsnakeCentres;
#   # inherit from Flowsnake
# }
# { package Math::PlanePath::GosperIslands;
# }
{ package Math::PlanePath::KochCurve;
  use constant _NumSeq_Turn_oeis_anum =>
    { '' =>
      { Left => 'A035263', # OFFSET=1 matches N=1
        # OEIS-Catalogue: A035263 planepath=KochCurve

        # Not quite, A096268 OFFSET=0 values 0,1,0,0,0,1
        # whereas here N=1 first turn values 0,1,0,0,0,1
        # Right => 'A096268',  # morphism
      },
    };
}
# { package Math::PlanePath::KochPeaks;
# }
# { package Math::PlanePath::KochSnowflakes;
# }
# { package Math::PlanePath::KochSquareflakes;
# }
# { package Math::PlanePath::QuadricCurve;
# }
# { package Math::PlanePath::QuadricIslands;
# }
# { package Math::PlanePath::SierpinskiTriangle;
# }
# { package Math::PlanePath::SierpinskiArrowhead;
# }
# { package Math::PlanePath::SierpinskiCurve;
#   use constant _NumSeq_Turn_oeis_anum =>
#   { 'arms=1' =>
#     {
#      # Not quite, A039963 numbered OFFSET=0 whereas first turn at N=1 here
#      Right => 'A039963',  # duplicated KochCurve turns
#     },
#   },
# }
# }
# { package Math::PlanePath::SierpinskiCurveStair;
# }
{ package Math::PlanePath::DragonCurve;
  use constant _NumSeq_Turn_oeis_anum =>
    { 'arms=1' =>
      {
       'LSR' => 'A034947', # Jacobi symbol (-1/n)
       # OEIS-Catalogue: A034947 planepath=DragonCurve turn_type=LSR

       # 'L1R0' => 'A014577', # left=1,right=0  OFFSET=0
       # 'L0R1' => 'A014707', # left=0,right=1  OFFSET=0
       # 'L1R2' => 'A014709', # left=1,right=2  OFFSET=0
       # 'L2R1' => 'A014710', # left=2,right=1  OFFSET=0
       # 'L1R3' => 'A099545', # left=1,right=3  OFFSET=1

       #  # Not quite, A014707 has OFFSET=0 cf first elem for N=1
       #  'Left' => 'A014707', # turn, 1=left,0=right
       #  # OEIS-Catalogue: A014707 planepath=DragonCurve

       #  # Not quite, A014577 has OFFSET=0 cf first elem for N=1
       #  'Right' => 'A014577', # turn, 0=left,1=right
       #  # OEIS-Catalogue: A014577 planepath=DragonCurve turn_type=Right
      },
    };
}
# { package Math::PlanePath::DragonRounded;
# }
# { package Math::PlanePath::DragonMidpoint;
# }
{ package Math::PlanePath::AlternatePaper;

  # A209615 is (-1)^e for each p^e prime=4k+3 or prime=2
  # 3*3 mod 4 = 1 mod 4
  # so picks out bit above lowest 1-bit, and factor -1 if an odd power-of-2
  # which is the AlternatePaper turn formula
  #
  use constant _NumSeq_Turn_oeis_anum =>
    { 'arms=1' =>
      { LSR => 'A209615',
        # OEIS-Catalogue: A209615 planepath=AlternatePaper turn_type=LSR

        # # Not quite, A106665 has OFFSET=0 cf first here i=1
        # 'Left' => 'A106665', # turn, 1=left,0=right
        # # OEIS-Catalogue: A106665 planepath=AlternatePaper i_offset=1
      },
    };
}
{ package Math::PlanePath::GosperSide;

  # Suspect not in OEIS:
  # Left or Right according to lowest non-zero ternary digit 1 or 2
  #
  use constant _NumSeq_Turn_oeis_anum =>
    { '' =>
      { 'Left' => 'A137893', # turn, 1=left,0=right, OFFSET=1
        # OEIS-Catalogue: A137893 planepath=GosperSide
        # OEIS-Other:     A137893 planepath=TerdragonCurve

        # Not quite, A080846 OFFSET=0 values 0,1,0,0,1 which are N=1 here
        # Right => 'A080846',
        # # OEIS-Catalogue: A080846 planepath=GosperSide turn_type=Right
        # # OEIS-Other: A080846 planepath=TerdragonCurve turn_type=Right
        # Or A189640 has extra initial 0.
      } };
}
{ package Math::PlanePath::TerdragonCurve;
  # GosperSide and TerdragonCurve same turn sequence, by diff angles
  use constant _NumSeq_Turn_oeis_anum =>
    { 'arms=1' => Math::PlanePath::GosperSide->_NumSeq_Turn_oeis_anum->{''} };
}
# { package Math::PlanePath::TerdragonRounded;
# }
# { package Math::PlanePath::TerdragonMidpoint;
# }
# { package Math::PlanePath::R5DragonCurve;
# # Not quite,    OFFSET=0 values 0,0,1,1,0
# # cf first turn here N=1 values 0,0,1,1,0
# # 'Math::PlanePath::R5DragonCurve' =>
# # { Right => 'A175337',
# #   # OEIS-Catalogue: A175337 planepath=R5DragonCurve turn_type=Right
# # },
# }
# { package Math::PlanePath::R5DragonMidpoint;
# }
# { package Math::PlanePath::CCurve;
# }
# { package Math::PlanePath::ComplexPlus;
# }
# { package Math::PlanePath::ComplexMinus;
# }
# { package Math::PlanePath::ComplexRevolving;
# }
{ package Math::PlanePath::Rows;
  # if width==1 then always straight ahead
  sub _NumSeq_Turn_Left_max {
    my ($self) = @_;
    return ($self->{'width'} > 1
            ? 1
            : 0);
  }
  sub _NumSeq_Turn_Left_non_decreasing {
    my ($self) = @_;
    return ($self->{'width'} > 1
            ? 0
            : 1);
  }
  *_NumSeq_Turn_Right_max = \&_NumSeq_Turn_Left_max;
  *_NumSeq_Turn_Right_non_decreasing = \&_NumSeq_Turn_Left_non_decreasing;

  sub _NumSeq_Turn_LSR_min {
    my ($self) = @_;
    return ($self->{'width'} > 1
            ? -1
            : 0);
  }
  sub _NumSeq_Turn_LSR_max {
    my ($self) = @_;
    return ($self->{'width'} > 1
            ? 1
            : 0);
  }
  sub _NumSeq_Turn_LSR_non_decreasing {
    my ($self) = @_;
    return ($self->{'width'} > 1
            ? 0
            : 1);
  }

  use constant _NumSeq_Turn_oeis_anum =>
    {
     'n_start=1,width=0' => # Rows width=0 is trivial X=N,Y=0
     { Left => 'A000004',  # all-zeros
       LSR  => 'A000004',  # all zeros, straight
       # OEIS-Other: A000004 planepath=Rows,width=0
       # OEIS-Other: A000004 planepath=Rows,width=0 turn_type=LSR
     },
    };
}
{ package Math::PlanePath::Columns;
  # if height==1 then always straight ahead
  sub _NumSeq_Turn_Left_max {
    my ($self) = @_;
    return ($self->{'height'} > 1 ? 1 : 0);
  }
  sub _NumSeq_Turn_Left_non_decreasing {
    my ($self) = @_;
    return ($self->{'height'} > 1
            ? 0
            : 1);
  }
  *_NumSeq_Turn_Right_max = \&_NumSeq_Turn_Left_max;
  *_NumSeq_Turn_Right_non_decreasing = \&_NumSeq_Turn_Left_non_decreasing;

  sub _NumSeq_Turn_LSR_min {
    my ($self) = @_;
    return ($self->{'height'} > 1 ? -1 : 0);
  }
  sub _NumSeq_Turn_LSR_max {
    my ($self) = @_;
    return ($self->{'height'} > 1 ? 1 : 0);
  }
  sub _NumSeq_Turn_LSR_non_decreasing {
    my ($self) = @_;
    return ($self->{'height'} > 1
            ? 0
            : 1);
  }

  use constant _NumSeq_Turn_oeis_anum =>
    {
     'n_start=1,height=0' => # Columns height=0 is trivial X=N,Y=0
     { Left => 'A000004',  # all-zeros
       LSR  => 'A000004',  # all zeros, straight
       # OEIS-Other: A000004 planepath=Columns,height=0
       # OEIS-Other: A000004 planepath=Columns,height=0 turn_type=LSR
     },
    };
}
{ package Math::PlanePath::Diagonals;
  use constant _NumSeq_Turn_oeis_anum =>
    { 'direction=down,n_start=0,x_start=0,y_start=0' =>
      { Left => 'A129184', # shift of triangle
        # OEIS-Catalogue: A129184 planepath=Diagonals,n_start=0
      },
      'direction=down,n_start=-1,x_start=0,y_start=0' =>
      { Right => 'A023531', # 1 at m(m+3)/2
        # OEIS-Other: A023531 planepath=Diagonals,n_start=-1 turn_type=Right
      },

      'direction=up,n_start=0,x_start=0,y_start=0' =>
      { Right => 'A129184', # shift of triangle
        # OEIS-Other: A129184 planepath=Diagonals,direction=up,n_start=0 turn_type=Right
      },
      'direction=up,n_start=-1,x_start=0,y_start=0' =>
      { Left => 'A023531', # 1 at m(m+3)/2
        # OEIS-Other: A023531 planepath=Diagonals,direction=up,n_start=-1
      },
    };
}
# { package Math::PlanePath::DiagonalsAlternating;
# }
# { package Math::PlanePath::DiagonalsOctant;
#   # down is left or straight, but also right at N=2,3,4
#   # up is straight or right, but also left at N=2,3,4
#   'Math::PlanePath::DiagonalsOctant,direction=down' =>
#   { Left => square or pronic starting from 1
#   },
#   'Math::PlanePath::DiagonalsOctant,direction=up' =>
#   { Left => square or pronic starting from 1
#   },
# }
# { package Math::PlanePath::Staircase;
# }
# { package Math::PlanePath::StaircaseAlternating;
# }
{ package Math::PlanePath::Corner;
  sub _NumSeq_Turn_Left_max {
    my ($self) = @_;
    return ($self->{'wider'} == 0 ? 0  # wider=0 right or straight always
            : 1);
  }
  sub _NumSeq_Turn_Left_non_decreasing {
    my ($self) = @_;
    return ($self->{'wider'} == 0 ? 1  # wider=0 right or straight so left=0
            : 0);
  }
  *_NumSeq_Turn_LSR_max = \&_NumSeq_Turn_Left_max;

  use constant _NumSeq_Turn_oeis_anum =>
    { 'wider=1,n_start=-1' =>
      { Left => 'A000007', # turn Left=1 at N=0 only
        # catalogued only unless/until a better implementation
        # OEIS-Catalogue: A000007 planepath=Corner,wider=1,n_start=-1
      },
      'wider=2,n_start=-1' =>
      { Left => 'A063524', # turn Left=1 at N=1 only
        # catalogued only unless/until a better implementation
        # OEIS-Catalogue: A063524 planepath=Corner,wider=2,n_start=-1
      },
      'wider=3,n_start=-1' =>
      { Left => 'A185012', # turn Left=1 at N=2 only
        # catalogued only unless/until a better implementation
        # OEIS-Catalogue: A185012 planepath=Corner,wider=3,n_start=-1
      },
      # A185013 Characteristic function of three.
      # A185014 Characteristic function of four.
      # A185015 Characteristic function of 5.
      # A185016 Characteristic function of 6.
      # A185017 Characteristic function of 7.
    };
}
{ package Math::PlanePath::PyramidRows;
  # if step==0 then always straight ahead
  sub _NumSeq_Turn_Left_max {
    my ($self) = @_;
    return ($self->{'step'} > 0
            ? 1
            : 0); # vertical only
  }
  sub _NumSeq_Turn_Left_non_decreasing {
    my ($self) = @_;
    return ($self->{'step'} > 0
            ? 0
            : 1); # vertical only
  }
  *_NumSeq_Turn_Right_max = \&_NumSeq_Turn_Left_max;
  *_NumSeq_Turn_Right_non_decreasing = \&_NumSeq_Turn_Left_non_decreasing;

  sub _NumSeq_Turn_LSR_min {
    my ($self) = @_;
    return ($self->{'step'} > 0
            ? -1
            : 0); # vertical only
  }
  sub _NumSeq_Turn_LSR_max {
    my ($self) = @_;
    return ($self->{'step'} > 0
            ? 1
            : 0); # vertical only
  }
  sub _NumSeq_Turn_LSR_non_decreasing {
    my ($self) = @_;
    return ($self->{'step'} > 0
            ? 0
            : 1); # vertical only
  }

  use constant _NumSeq_Turn_oeis_anum =>
    {
     # PyramidRows step=0 is trivial X=N,Y=0
     do {
       my $href= { Left => 'A000004',  # all-zeros, OFFSET=0
                   LSR  => 'A000004',  # all zeros straight
                 };
       ('step=0,align=centre,n_start=1' => $href,
        'step=0,align=right,n_start=1'  => $href,
        'step=0,align=left,n_start=1'   => $href,
       );
       # OEIS-Other: A000004 planepath=PyramidRows,step=0
       # OEIS-Other: A000004 planepath=PyramidRows,step=0 turn_type=LSR
       # OEIS-Other: A000004 planepath=PyramidRows,step=0,align=right
       # OEIS-Other: A000004 planepath=PyramidRows,step=0,align=left turn_type=LSR
     },

     # PyramidRows step=1
     do {
       my $href= { Left => 'A129184', # triangle 1s shift right
                 };
       ('step=1,align=centre,n_start=0' => $href,
        'step=1,align=right,n_start=0'  => $href,
        'step=1,align=left,n_start=0'   => $href,
       );
       # OEIS-Other: A129184 planepath=PyramidRows,step=1,n_start=0
       # OEIS-Other: A129184 planepath=PyramidRows,step=1,align=right,n_start=0
       # OEIS-Other: A129184 planepath=PyramidRows,step=1,align=left,n_start=0
     },
     do {
       my $href= { Right => 'A023531',  # 1 at n==m*(m+3)/2
                 };
       ('step=1,align=centre,n_start=-1' => $href,
        'step=1,align=right,n_start=-1'  => $href,
       );
       # OEIS-Other: A023531 planepath=PyramidRows,step=1,n_start=-1 turn_type=Right
       # OEIS-Other: A023531 planepath=PyramidRows,step=1,align=right,n_start=-1 turn_type=Right
     },
    };
}
{ package Math::PlanePath::PyramidSides;
  use constant _NumSeq_Turn_Left_max => 0; # right or straight
  use constant _NumSeq_Turn_Left_non_decreasing => 1; # right or straight
  use constant _NumSeq_Turn_LSR_max => 0; # right or straight
}
{ package Math::PlanePath::CellularRule;
  sub _NumSeq_Turn_Left_increasing {
    my ($self) = @_;
    return (defined $self->{'rule'}
            && ($self->{'rule'} & 0x17) == 0    # single cell only
            ? 1
            : 0);
  }
  *_NumSeq_Turn_Right_increasing = \&_NumSeq_Turn_Left_increasing;

  sub _NumSeq_Turn_LSR_increasing {
    my ($self) = @_;
    return (defined $self->{'rule'}
            && ($self->{'rule'} & 0x17) == 0    # single cell only
            ? 1
            : 0);
  }
}
{ package Math::PlanePath::CellularRule::Line;
  use constant _NumSeq_Turn_Left_max => 0; # straight ahead only
  use constant _NumSeq_Turn_Left_non_decreasing => 1; # straight ahead only
  use constant _NumSeq_Turn_Right_max => 0; # straight ahead only
  use constant _NumSeq_Turn_Right_non_decreasing => 1; # straight ahead only

  use constant _NumSeq_Turn_LSR_max => 0;
  use constant _NumSeq_Turn_LSR_min => 0;
  use constant _NumSeq_Turn_LSR_non_decreasing => 1; # straight ahead only
}
# { package Math::PlanePath::CellularRule::OddSolid;
# }
# { package Math::PlanePath::CellularRule54;
# }
# { package Math::PlanePath::CellularRule57;
# }
# { package Math::PlanePath::CellularRule190;
# }
# { package Math::PlanePath::CoprimeColumns;
# }
# { package Math::PlanePath::DivisibleColumns;
# }
# { package Math::PlanePath::File;
#   # File                   points from a disk file
#   # FIXME: analyze points for min/max etc
# }
# { package Math::PlanePath::QuintetCurve;
# }
# { package Math::PlanePath::QuintetCentres;
# }
# { package Math::PlanePath::DekkingCurve;
# }
# { package Math::PlanePath::DekkingCentres;
# }
# { package Math::PlanePath::CincoCurve;
# }
# { package Math::PlanePath::CornerReplicate;
# }
# { package Math::PlanePath::DigitGroups;
# }
# { package Math::PlanePath::FibonacciWordFractal;
# }
# { package Math::PlanePath::LTiling;
# }
# { package Math::PlanePath::WythoffArray;
# }
# { package Math::PlanePath::PowerArray;
# use constant _NumSeq_oeis_anum => 
#   {
#      # Math::PlanePath::PowerArray
#      # Not quite, A011765 0,0,0,1 repeating OFFSET=1
#      # cf n_start=1 is first turn at N=2
#      # Left  => 'A011765',
#      # Right => 'A011765',
#   };
# }

1;
__END__


=for stopwords Ryde Math-PlanePath NumSeq PlanePath SquareSpiral ie LSR dX,dY dx1,dy1 dx2,dy2

=head1 NAME

Math::NumSeq::PlanePathTurn -- turn sequence from PlanePath module

=head1 SYNOPSIS

 use Math::NumSeq::PlanePathTurn;
 my $seq = Math::NumSeq::PlanePathTurn->new (planepath => 'DragonCurve',
                                             turn_type => 'Left');
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This is a tie-in to present turns from a C<Math::PlanePath> module in the
form of a NumSeq sequence.

The C<turn_type> choices are

    "Left"     1=left  0=right or straight
    "Right"    1=right 0=left or straight
    "LSR"      1=left  0=straight -1=right

In each case the value at i is the turn which occurs at N=i,

            i+1
             ^
             |
             |
    i-1 ---> i     turn at i
                   first turn at i = n_start + 1

For multiple "arms" the turn follows that particular arm so it's i-arms, i,
i+arms.  i values start C<n_start()+arms_count()> so i-arms is C<n_start()>,
the first N on the path.  A single arm path beginning N=0 has its first turn
at i=1.

In "LSR" straight means either straight ahead or 180-degree reversal,
ie. the direction N to N+1 is along the same line as N-1 to N was.

"Left" means to the left side of the N-1 to N line, not straight or right.
Similarly "Right" means to the right side of the N-1 to N line, not straight
or left.

=head1 FUNCTIONS

See L<Math::NumSeq/FUNCTIONS> for behaviour common to all sequence classes.

=over 4

=item C<$seq = Math::NumSeq::PlanePathTurn-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.  The options are

    planepath          string, name of a PlanePath module
    planepath_object   PlanePath object
    turn_type          string, as described above

C<planepath> can be either the module part such as "SquareSpiral" or a
full class name "Math::PlanePath::SquareSpiral".

=item C<$value = $seq-E<gt>ith($i)>

Return the turn at N=$i in the PlanePath.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> occurs as a turn.  Often this is merely the
possible turn values 1,0,-1, etc, but some spiral paths for example only go
left or straight in which case only 1 and 0 occur and C<pred()> reflects
that.

=item C<$i = $seq-E<gt>i_start()>

Return the first index C<$i> in the sequence.  This is the position
C<rewind()> returns to.

This is C<$path-E<gt>n_start() - $path-E<gt>arms_count()> from the
PlanePath object.

=back

=head1 FORMULAS

=head2 Turn Left or Right

A turn left or right is identified by considering the dX,dY at N-1 and at N.

    N+1      *
             |   dx2,dy2
             |
             | 
             | 
    N        *
            /   dx1,dy1
           /
          /
    N-1  *

With the two vectors dx1,dy1 and dx2,dy2 at a common origin, if the dx2,dy2
is above the dx1,dy1 line then it's a turn to the left, or below is a turn
to the right

    dx2,dy2
       * 
       |   * dx1,dy1
       |  /
       | /
       |/
       o

At dx2 the Y value of the dx1,dy1 vector is

    cmpY = dx2 * dy1/dx1           if dx1 != 0

    left if dy2 > cmpY
            dy2 > dx2 * dy1/dx1
       so   dy2 * dx1 > dx2 * dy1

This comparison dy2*dx1 > dx2*dy1 works when dx1=0 too, ie. when dx1,dy1 is
vertical

    left if dy2 * 0 > dx2 * dy1
                  0 > dx2*dy1
    good, left if dx2 and dy1 opposite signs

So

    dy2*dx1 > dx2*dy1      left
    dy2*dx1 < dx2*dy1      right
    dy2*dx1 = dx2*dy1      straight, including 180 degree reverse

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::PlanePathCoord>,
L<Math::NumSeq::PlanePathDelta>,
L<Math::NumSeq::PlanePathN>

L<Math::NumberCruncher> has a C<Clockwise()> turn calculator

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
