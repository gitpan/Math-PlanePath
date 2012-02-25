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


# math-image --values=PlanePathTurn
#
# LSR
# Turn90
# Turn60 0,1,2,3, -1,-2,-3



package Math::NumSeq::PlanePathTurn;
use 5.004;
use strict;
use Carp;

use vars '$VERSION','@ISA';
$VERSION = 71;
use Math::NumSeq;
@ISA = ('Math::NumSeq');

use Math::PlanePath;
*_is_infinite = \&Math::PlanePath::_is_infinite;

use Math::NumSeq::PlanePathCoord;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant characteristic_smaller => 1;
use constant description => Math::NumSeq::__('Turns from a PlanePath');

use constant::defer parameter_info_array =>
  sub {
    return [
            Math::NumSeq::PlanePathCoord::_parameter_info_planepath(),
            {
             name    => 'turn_type',
             display => Math::NumSeq::__('Turn Type'),
             type    => 'enum',
             default => 'Left',
             choices => ['Left',
                         'LSR',
                        ],
             description => Math::NumSeq::__('Left is 1=left, 0=right or straight.
LSR is 1=left,0=straight,-1=right.'),
            },
           ];
  };

my %oeis_anum
  = (
     # 'Math::PlanePath::HilbertCurve' =>
     # {
     #  # cf 1,0,-1 here
     #  # A163542    relative direction (ahead=0,right=1,left=2)
     #  # A163543    relative direction, transpose X,Y
     # },

     # 'Math::PlanePath::PeanoCurve,radix=3' =>
     # {
     #  # cf 1,0,-1 here
     #  # A163536 relative direction 0=ahead,1=right,2=left
     # },

     'Math::PlanePath::DragonCurve,arms=1' =>
     {
      'LSR' => 'A034947', # Jacobi symbol (-1/n)
      # OEIS-Catalogue: A034947 planepath=DragonCurve turn_type=LSR

      #  # but A014707 has OFFSET=0 cf first elem for N=1
      #  'Right' => 'A014707', # turn, 1=left,0=right
      #  # OEIS-Catalogue: A014707 planepath=DragonCurve turn_type=Left

      #  # but A014577 has OFFSET=0 cf first elem for N=1
      #  'Right' => 'A014577', # turn, 0=left,1=right
      #  # OEIS-Catalogue: A014577 planepath=DragonCurve turn_type=Right
     },

     # but A106665 has OFFSET=0 cf first here i=1
     # 'Math::PlanePath::AlternatePaper' =>
     # {
     #  'Left' => 'A106665', # turn, 1=left,0=right
     #  # OEIS-Catalogue: A106665 planepath=AlternatePaper turn_type=Left
     # },

     # 'Math::PlanePath::TerdragonCurve,arms=1' =>
     # {
     # but A080846 has OFFSET=0 cf first here i=1
     #  'LR_01' => 'A080846', # turn, 0=left,1=right
     #  # OEIS-Catalogue: A080846 planepath=TerdragonCurve turn_type=LR_01
     # },

     'Math::PlanePath::SacksSpiral' =>
     { 'Left' => 'A000012',  # left always, all ones
       'LSR'  => 'A000012',
       # OEIS-Other: A000012 planepath=SacksSpiral
       # OEIS-Other: A000012 planepath=SacksSpiral turn_type=LSR
     },
     'Math::PlanePath::TheodorusSpiral' =>
     { 'Left' => 'A000012',  # left always, all ones
       'LSR'  => 'A000012',
       # OEIS-Other: A000012 planepath=TheodorusSpiral
       # OEIS-Other: A000012 planepath=TheodorusSpiral turn_type=LSR
     },
     'Math::PlanePath::ArchimedeanChords' =>
     { 'Left' => 'A000012',  # left always, all ones
       'LSR'  => 'A000012',
       # OEIS-Other: A000012 planepath=ArchimedeanChords
       # OEIS-Other: A000012 planepath=ArchimedeanChords turn_type=LSR
     },

     # PyramidRows step=0 is trivial X=N,Y=0
     'Math::PlanePath::PyramidRows,step=0' =>
     { Left => 'A000004',  # all-zeros
       LSR  => 'A000004',  # all zeros, straight
       # OEIS-Other: A000004 planepath=PyramidRows,step=0 turn_type=Left
       # OEIS-Other: A000004 planepath=PyramidRows,step=0 turn_type=LSR
     },
     # MultipleRings step=0 is trivial X=N,Y=0
     'Math::PlanePath::MultipleRings,step=0' =>
     { Left => 'A000004',  # all-zeros
       LSR  => 'A000004',  # all zeros, straight
       # OEIS-Other: A000004 planepath=MultipleRings,step=0 turn_type=Left
       # OEIS-Other: A000004 planepath=MultipleRings,step=0 turn_type=LSR
     },
     # Rows width=0 is trivial X=N,Y=0
     'Math::PlanePath::Rows,width=0' =>
     { Left => 'A000004',  # all-zeros
       LSR  => 'A000004',  # all zeros, straight
       # OEIS-Other: A000004 planepath=Rows,width=0 turn_type=Left
       # OEIS-Other: A000004 planepath=Rows,width=0 turn_type=LSR
     },
     # Columns height=0 is trivial X=N,Y=0
     'Math::PlanePath::Columns,height=0' =>
     { Left => 'A000004',  # all-zeros
       LSR  => 'A000004',  # all zeros, straight
       # OEIS-Other: A000004 planepath=Columns,height=0 turn_type=Left
       # OEIS-Other: A000004 planepath=Columns,height=0 turn_type=LSR
     },

     # but A129184 OFFSET=1 whereas N=2 first turn in Diagonals
     # 'Math::PlanePath::Diagonals,wider=0' =>
     # { Left => 'A129184',  # "right shift"
     #   # OEIS-Catalogue: A129184 planepath=Diagonals turn_type=Left
     # },

    );

sub oeis_anum {
  my ($self) = @_;
  ### PlanePathTurn oeis_anum() ...

  # my $key = Math::NumSeq::PlanePathCoord::_planepath_oeis_key($self->{'planepath_object'});
  # ### $key

  return $oeis_anum{Math::NumSeq::PlanePathCoord::_planepath_oeis_key($self->{'planepath_object'})} -> {$self->{'turn_type'}};
}

sub new {
  my $class = shift;
  ### PlanePathTurn new(): @_
  my $self = $class->SUPER::new(@_);

  my $planepath_object = ($self->{'planepath_object'}
                          ||= Math::NumSeq::PlanePathCoord::_planepath_name_to_object($self->{'planepath'}));


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
      or return;
    my ($prev_x, $prev_y) = $planepath_object->n_to_xy ($i-$arms)
      or return;
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

  if (_is_infinite($i)) {
    return undef;
  }

  my $planepath_object = $self->{'planepath_object'};
  my $n = $i + $planepath_object->n_start;
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
#
# cmpy = dx2 * dy1/dx1
# left if dy2 > cmpy
#         dy2 > dx2 * dy1/dx1
#         dy2 * dx1 > dx2 * dy1
#
sub _turn_func_Left {
  my ($dx,$dy, $next_dx,$next_dy) = @_;
  ### _turn_func_Left() ...
  my $a = $next_dy * $dx;
  my $b = $next_dx * $dy;
  return ($a > $b
          || $dx==-$next_dx && $dy==-$next_dy  # straight opposite 180
          ? 1
          : 0);
}
sub _turn_func_LSR {
  my ($dx,$dy, $next_dx,$next_dy) = @_;
  ### _turn_func_LSR() ...
  return ($next_dy * $dx <=> $next_dx * $dy || 0);
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
  if ($turn_type eq 'Left') {
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
  # increasing means non_decreasing too
  return $self->characteristic_increasing;
}

my $all_Left_predhash = { 0=>1, 1=>1 };
my $all_LSR_predhash = { 0=>1, 1=>1, -1=>1 };
my $straight_Left_predhash = { 0=>1 };
my $straight_LSR_predhash = { 0=>1 };

{ package Math::PlanePath;

  use constant 1.02; # for leading underscore
  use constant _NumSeq_Turn_Left_min => 0;
  use constant _NumSeq_Turn_Left_max => 1;
  use constant _NumSeq_Turn_LSR_min => -1;
  use constant _NumSeq_Turn_LSR_max => 1;
}

{ package Math::PlanePath::SquareSpiral;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
  use constant _NumSeq_Turn_LSR_max => 1;
}
{ package Math::PlanePath::PyramidSpiral;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
  use constant _NumSeq_Turn_LSR_max => 1;
}
{ package Math::PlanePath::TriangleSpiral;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
  use constant _NumSeq_Turn_LSR_max => 1;
}
{ package Math::PlanePath::TriangleSpiralSkewed;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
  use constant _NumSeq_Turn_LSR_max => 1;
}
{ package Math::PlanePath::DiamondSpiral;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
  use constant _NumSeq_Turn_LSR_max => 1;
}
{ package Math::PlanePath::AztecDiamondRings;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
}
{ package Math::PlanePath::PentSpiral;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
}
{ package Math::PlanePath::PentSpiralSkewed;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
}
{ package Math::PlanePath::HexSpiral;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
}
{ package Math::PlanePath::HexSpiralSkewed;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
}
{ package Math::PlanePath::HeptSpiralSkewed;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
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
}
{ package Math::PlanePath::DiamondArms;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
  use constant _NumSeq_Turn_LSR_max => 1;
}
{ package Math::PlanePath::HexArms;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
  use constant _NumSeq_Turn_LSR_max => 1;
}
# { package Math::PlanePath::GreekKeySpiral;
# }
{ package Math::PlanePath::SacksSpiral;
  use constant _NumSeq_Turn_Left_min => 1; # left always
  use constant _NumSeq_Turn_Left_max => 1;
  use constant _NumSeq_Turn_Left_non_decreasing => 1;
  use constant _NumSeq_Turn_LSR_min => 1;
  use constant _NumSeq_Turn_LSR_max => 1;
  use constant _NumSeq_Turn_LSR_non_decreasing => 1;
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
  use constant _NumSeq_Turn_Left_non_decreasing => 1;

  sub _NumSeq_Turn_LSR_min {
    my ($self) = @_;
    return ($self->{'rotation_factor'} > 0.5 ? -1 : 1);
  }
  sub _NumSeq_Turn_LSR_max {
    my ($self) = @_;
    return ($self->{'rotation_factor'} > 0.5 ? -1 : 1);
  }
  use constant _NumSeq_Turn_LSR_non_decreasing => 1;

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
}
{ package Math::PlanePath::ArchimedeanChords;
  use constant _NumSeq_Turn_Left_min => 1; # left always
  use constant _NumSeq_Turn_Left_max => 1;
  use constant _NumSeq_Turn_Left_non_decreasing => 1;
  use constant _NumSeq_Turn_LSR_min => 1;
  use constant _NumSeq_Turn_LSR_max => 1;
  use constant _NumSeq_Turn_LSR_non_decreasing => 1;
}
{ package Math::PlanePath::MultipleRings;
  sub _NumSeq_Turn_Left_max {
    my ($self) = @_;
    return ($self->{'step'} > 0
            ? 1
            : 0);  # horizontal only
  }
  sub _NumSeq_Turn_Left_non_decreasing {
    my ($self) = @_;
    return ($self->{'step'} > 0
            ? 0
            : 1);  # horizontal only
  }

  sub _NumSeq_Turn_LSR_min {
    my ($self) = @_;
    return ($self->{'step'} > 0
            ? -1
            : 0); # horizontal only
  }
  sub _NumSeq_Turn_LSR_max {
    my ($self) = @_;
    return ($self->{'step'} > 0
            ? 1
            : 0); # horizontal only
  }
  sub _NumSeq_Turn_LSR_non_decreasing {
    my ($self) = @_;
    return ($self->{'step'} > 0
            ? 0
            : 1);  # horizontal only
  }
}
{ package Math::PlanePath::PixelRings;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
}
# { package Math::PlanePath::FilledRings;
# }
{ package Math::PlanePath::Hypot;
  use constant _NumSeq_Turn_Left_min => 1; # left always
  use constant _NumSeq_Turn_Left_non_decreasing => 1; # left always
  use constant _NumSeq_Turn_LSR_min => 1; # left always
  use constant _NumSeq_Turn_LSR_non_decreasing => 1; # left always
}
# { package Math::PlanePath::HypotOctant;
# }
{ package Math::PlanePath::TriangularHypot;
  use constant _NumSeq_Turn_LSR_min => 0; # left or straight
}
# { package Math::PlanePath::PythagoreanTree;
# }
# { package Math::PlanePath::RationalsTree;
# }
# { package Math::PlanePath::FractionsTree;
# }
# { package Math::PlanePath::DiagonalRationals;
# }
# { package Math::PlanePath::FactorRationals;
# }
# { package Math::PlanePath::GcdRationals;
# }
# { package Math::PlanePath::PeanoCurve;
# }
# { package Math::PlanePath::HilbertCurve;
# }
# { package Math::PlanePath::ZOrderCurve;
# }
# { package Math::PlanePath::ImaginaryBase;
# }
# { package Math::PlanePath::Flowsnake;
# }
# { package Math::PlanePath::FlowsnakeCentres;
#   # inherit from Flowsnake
# }
# { package Math::PlanePath::GosperIslands;
# }
# { package Math::PlanePath::GosperSide;
# }
# { package Math::PlanePath::KochCurve;
# }
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
# { package Math::PlanePath::SierpinskiArrowheadCentres;
# }
# { package Math::PlanePath::DragonCurve;
# }
# { package Math::PlanePath::DragonRounded;
# }
# { package Math::PlanePath::DragonMidpoint;
# }
# { package Math::PlanePath::TerdragonCurve;
# }
# { package Math::PlanePath::TerdragonMidpoint;
# }
# { package Math::PlanePath::AlternatePaper;
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
}
# { package Math::PlanePath::Diagonals;
# }
# { package Math::PlanePath::DiagonalsAlternating;
# }
# { package Math::PlanePath::Staircase;
# }
# { package Math::PlanePath::StaircaseAlternating;
# }
{ package Math::PlanePath::Corner;
  use constant _NumSeq_Turn_Left_max => 0; # right or straight always
  use constant _NumSeq_Turn_Left_non_decreasing => 1; # right or straight
  use constant _NumSeq_Turn_LSR_max => 0; # right or straight
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
}
{ package Math::PlanePath::PyramidSides;
  use constant _NumSeq_Turn_Left_max => 0; # right or straight
  use constant _NumSeq_Turn_Left_non_decreasing => 1; # right or straight
  use constant _NumSeq_Turn_LSR_max => 0; # right or straight
}
{ package Math::PlanePath::CellularRule;
  sub _NumSeq_Turn_Left_increasing {
    my ($self) = @_;
    return (($self->{'rule'} & 0x17) == 0    # single cell only
            ? 1
            : 0);
  }

  sub _NumSeq_Turn_LSR_increasing {
    my ($self) = @_;
    return (($self->{'rule'} & 0x17) == 0    # single cell only
            ? 1
            : 0);
  }
}
{ package Math::PlanePath::CellularRule::Line;
  use constant _NumSeq_Turn_Left_max => 0; # straight ahead only
  use constant _NumSeq_Turn_Left_non_decreasing => 1; # straight ahead only

  use constant _NumSeq_Turn_LSR_max => 0;
  use constant _NumSeq_Turn_LSR_min => 0;
  use constant _NumSeq_Turn_LSR_non_decreasing => 1; # straight ahead only
}
# { package Math::PlanePath::CellularRule::OddSolid;
# }
# { package Math::PlanePath::CellularRule::LeftSolid;
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
#   # FIXME: analyze points for dx/dy min/max etc
# }
# { package Math::PlanePath::QuintetCurve;
# }
# { package Math::PlanePath::QuintetCentres;
# }
# { package Math::PlanePath::CornerReplicate;
# }
# { package Math::PlanePath::DigitGroups;
# }
# { package Math::PlanePath::FibonacciWordFractal;
# }
# { package Math::PlanePath::LTiling;
# }

1;
__END__


=for stopwords Ryde Math-PlanePath NumSeq PlanePath SquareSpiral ie

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

    "Left"     1=left 0=right or straight
    "LSR"      1=left 0=straight -1=right

In each case the value at i is turn which occurs at N=i, ie. between the
segments N=i-1 to N=i to N=i+1


            i+1
             |
             |
    i-1 ---- i    turn at i

For multiple "arms" the turn follows that particular arm so it's i-arms, i,
i+arms.  i values start C<n_start()+arms_count()> so i-arms is the first N
on the path.  For example a single arm path beginning N=0 has its first turn
at i=1.

=head1 FUNCTIONS

See L<Math::NumSeq/FUNCTIONS> for behaviour common to all sequence classes.

=over 4

=item C<$seq = Math::NumSeq::PlanePathTurn-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.  The options are

    planepath          string, name of a PlanePath module
    planepath_object   PlanePath object
    turn_type          string, as described above

C<planepath> can be just the module part such as "SquareSpiral" or a full
class name "Math::PlanePath::SquareSpiral".

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

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::PlanePathCoord>,
L<Math::NumSeq::PlanePathDelta>,
L<Math::NumSeq::PlanePathN>

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
