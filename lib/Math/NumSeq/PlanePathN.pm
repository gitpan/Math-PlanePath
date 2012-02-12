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


package Math::NumSeq::PlanePathN;
use 5.004;
use strict;
use Carp;

use vars '$VERSION','@ISA';
$VERSION = 69;
use Math::NumSeq;
@ISA = ('Math::NumSeq');

use constant 1.02;
use Math::NumSeq::PlanePathCoord;

# uncomment this to run the ### lines
#use Smart::Comments;


sub description {
  my ($self) = @_;
  if (ref $self) {
    return "N values on $self->{'line_type'} of path $self->{'planepath'}";
  } else {
    # class method
    return Math::NumSeq::__('N values from a PlanePath');
  }
}

use constant::defer parameter_info_array =>
  sub {
    return [
            Math::NumSeq::PlanePathCoord::_parameter_info_planepath(),

            { name    => 'line_type',
              display => Math::NumSeq::__('Line Type'),
              type    => 'enum',
              default => 'X_axis',
              choices => ['X_axis','Y_axis',
                          'Diagonal',
                          # 'X_neg','Y_neg',
                          # 'NE','NW','SW','SE',
                         ],
              # description => Math::NumSeq::__(''),
            },
           ];
  };

my %oeis_anum
  = (
     'Math::PlanePath::PeanoCurve,radix=3' =>
     { X_axis   => 'A163480', # axis same as initial direction
       Y_axis   => 'A163481', # axis opp to initial direction
       Diagonal => 'A163343',
       # OEIS-Catalogue: A163480 planepath=PeanoCurve
       # OEIS-Catalogue: A163481 planepath=PeanoCurve line_type=Y_axis
       # OEIS-Catalogue: A163343 planepath=PeanoCurve line_type=Diagonal
     },

     'Math::PlanePath::HilbertCurve' =>
     { X_axis   => 'A163482',
       Y_axis   => 'A163483',
       Diagonal => 'A062880', # base 4 digits 0,2 only
       # OEIS-Catalogue: A163482 planepath=HilbertCurve
       # OEIS-Catalogue: A163483 planepath=HilbertCurve line_type=Y_axis
       # OEIS-Other: A062880 planepath=HilbertCurve line_type=Diagonal
     },

     'Math::PlanePath::ZOrderCurve,radix=2' =>
     { X_axis   => 'A000695',  # base 4 digits 0,1 only
       Y_axis   => 'A062880',  # base 4 digits 0,2 only
       # Diagonal => '',
       # OEIS-Catalogue: A000695 planepath=ZOrderCurve
       # OEIS-Catalogue: A062880 planepath=ZOrderCurve line_type=Y_axis
     },
     # A037314 starts OFFSET=1 value=1, so istart=1 here
     'Math::PlanePath::ZOrderCurve,radix=3' =>
     { X_axis => 'A037314',  # base 9 digits 0,1,2 only
       # OEIS-Catalogue: A037314 planepath=ZOrderCurve,radix=3 i_start=1
     },
     # but A051022 starts OFFSET=1 value=0, cf i=0 value=0
     # 'Math::PlanePath::ZOrderCurve,radix=10' =>
     # { X_axis => 'A051022',  # base 10 insert 0s
     #   # OEIS-Catalogue: A051022 planepath=ZOrderCurve,radix=10 i_start=1
     # },

     'Math::PlanePath::AztecDiamondRings' =>
     { X_axis => 'A001844',  # centred squares 2n(n+1)+1
       # OEIS-Other: A001844 planepath=AztecDiamondRings
       # Y_axis hexagonal numbers A000384, but starting i=0 value=1
     },

     'Math::PlanePath::ComplexMinus,realpart=1' =>
     { X_axis => 'A066321', # binary base i-1
       # OEIS-Catalogue: A066321 planepath=ComplexMinus
     },

     'Math::PlanePath::DiamondSpiral' =>
     { X_axis => 'A130883', # 2*n^2-n+1
       Y_axis => 'A058331', # 2*n^2 + 1
       # OEIS-Catalogue: A130883 planepath=DiamondSpiral
       # OEIS-Catalogue: A058331 planepath=DiamondSpiral line_type=Y_axis
     },

     # but OFFSET=1
     # 'Math::PlanePath::DigitGroups,radix=2' =>
     # { X_axis => 'A084471', # 0 -> 00 in binary
     #   # OEIS-Catalogue: A084471 planepath=DigitGroups,radix=2
     # },

     'Math::PlanePath::FactorRationals' =>
     { Y_axis => 'A102631', # n^2/(squarefree kernel)
       # OEIS-Catalogue: A102631 planepath=FactorRationals line_type=Y_axis
     },
     # FactorRationals X_axis -- squares, but starting from i=1

     'Math::PlanePath::HexSpiral,wider=0' =>
     { X_axis   => 'A056105', # first spoke 3n^2-2n+1
       Diagonal => 'A056106', # second spoke 3n^2-n+1
       # OEIS-Other: A056105 planepath=HexSpiral
       # OEIS-Other: A056106 planepath=HexSpiral line_type=Diagonal
     },

     'Math::PlanePath::HexSpiralSkewed,wider=0' =>
     { X_axis   => 'A056105', # first spoke 3n^2-2n+1
       Y_axis => 'A056106', # second spoke 3n^2-n+1
       # OEIS-Catalogue: A056105 planepath=HexSpiralSkewed
       # OEIS-Catalogue: A056106 planepath=HexSpiralSkewed line_type=Y_axis
     },
     # wider=1 X_axis almost 3*n^2 but not initial X=0 value
     # wider=1 Y_axis almost A049451 twice pentagonal but not initial X=0
     # wider=2 Y_axis almost A028896 6*triangular but not initial Y=0

     'Math::PlanePath::PentSpiral' =>
     { X_axis   => 'A192136', # (5*n^2-3*n+2)/2
       # OEIS-Catalogue: A192136 planepath=PentSpiral
     },
     # PentSpiralSkewed -- X_axis values of A140066 (5n^2-11n+8)/2 but from
     # X=0 so using (n-1)


     'Math::PlanePath::RationalsTree,tree_type=Bird' =>
     { X_axis   => 'A081254', # local max sumdisttopow2(m)/m^2
       # OEIS-Catalogue: A081254 planepath=RationalsTree,tree_type=Bird
     },
     'Math::PlanePath::RationalsTree,tree_type=Drib' =>
     { X_axis   => 'A086893', # pos of fibonacci F(n+1)/F(n) in Stern diatomic
       # OEIS-Catalogue: A086893 planepath=RationalsTree,tree_type=Drib

       # Drib Y_axis -- almost A061547 fibonacci F(n)/F(n+1), but start=1
     },
     # RationalsTree SB -- X_axis 2^n-1 but starting X=1
     # RationalsTree SB,CW -- Y_axis A000079 2^n but starting Y=1
     # RationalsTree AYT -- Y_axis A083318 2^n+1 but starting Y=1
     # RationalsTree Bird -- Y_axis almost A000975 no consecutive equal bits,
     #   but start=1

     # RationalsTree Drib -- Y_axis almost A061547 derangements or
     #    alternating bits plus pow4, but start=1 value=0

     'Math::PlanePath::SquareSpiral,wider=0' =>
     { X_axis   => 'A054552', # spoke E
       # OEIS-Catalogue: A054552 planepath=SquareSpiral
     },
     # but OFFSET=1 whereas based from X=0 here
     # # Y_axis   => 'A054556', # spoke N
     # # Diagonal => 'A054554', # spoke NE
     # # # OEIS-Catalogue: A054556 planepath=SquareSpiral line_type=Y_axis
     # # # OEIS-Catalogue: A054554 planepath=SquareSpiral line_type=Diagonal

     'Math::PlanePath::AlternatePaper' =>
     { X_axis   => 'A000695',  # base 4 digits 0,1 only
       Diagonal => 'A062880',  # base 4 digits 0,2 only
       # OEIS-Other: A000695 planepath=AlternatePaper
       # OEIS-Other: A062880 planepath=AlternatePaper line_type=Diagonal
     },

     'Math::PlanePath::CellularRule,rule=5' =>
     { Y_axis   => 'A061925',  # ceil(n^2/2)+1
       # OEIS-Catalogue: A061925 planepath=CellularRule,rule=5 line_type=Y_axis
     },
     # rule=13 Y axis
     #
     # rule=20,52,148,180 (mirror image of rule 6)
     # Diagonal A032766 numbers 0 or 1 mod 3, but it starts offset=0 value=0
     #
     # rule=28,156
     # Y_axis A002620 quarter squares floor(n^2/4) but diff start
     # Diagonal A024206 quarter squares - 1, but diff start
     #
     # rule=50,58,114,122,178,179,186,242,250
     # every second cell
     # Diagonal A000217 triangular numbers but diff start
     #
     # A000027 naturals integers 1 upwards, but OFFSET=1 cf start Y=0  here
     # # central column only
     # 'Math::PlanePath::CellularRule,rule=4' =>
     # { Y_axis   => 'A000027', # 1 upwards
     #   # OEIS-Other: A000027 planepath=CellularRule,rule=4 line_type=Y_axis
     # },
     #
     # # right line only 16,24,48,56,80,88,112,120,144,152,176,184,208,216,240,248
     # 'Math::PlanePath::CellularRule,rule=16' =>
     # { Y_axis   => 'A000027', # 1 upwards
     #   # OEIS-Other: A000027 planepath=CellularRule,rule=16 line_type=Diagonal
     # },
     # # OEIS-Other: A000027 planepath=CellularRule,rule=16 line_type=Diagonal


     # TriangleSpiral - cf A062728 SE diagonal OFFSET=1 but it starts n=0
     #
     # CoprimeColumns X_axis -- cumulative totient but start X=1 value=0;
     # Diagonal A015614 cumulative-1 but start X=1 value=1
     #
     # DivisibleColumns X_axis nearly A006218 but start X=1 cf OFFSET=0,
     # Diagonal nearly A077597 but start X=1 cf OFFSET=0
     #
     # DiagonalRationals Diagonal -- cumulative totient but start X=1
     # value=1
     #
     # CellularRule190 -- A006578 triangular+quarter square, but starts
     # OFFSET=0 cf N=1 in PlanePath
     #
     # SacksSpiral X_axis -- squares (i-1)^2, but starting from i=1 value=0
     #
     # GcdRationals -- X_axis triangular row, but starting X=1
     #
     # GcdRationals -- Y_axis A000124 triangular+1 but starting i=1 versus
     # OFFSET=0
     #
     # HeptSpiralSkewed -- Y_axis A140065 (7n^2 - 17n + 12)/2 but starting
     # Y=0 not n=1
     #
     # MPeaks -- X_axis A045944 matchstick n(3n+2) but initial N=3
     # MPeaks -- Diagonal,Y_axis hexagonal first,second spoke, but starting
     # from 3
     #
     # OctagramSpiral -- X_axis A125201 8*n^2-7*n+1 but initial N=1
     #
     # Rows,height=1 -- integers 1,2,3, etc, but starting i=0
     # MultipleRings,step=0 -- integers 1,2,3, etc, but starting i=0
     #
     # Diagonals X_axis -- triangular 1,3,6,etc, but starting i=0 value=1
     #
     # PyramidRows Diagonal -- squares 1,4,9,16, but i=0 value=1
     # PyramidRows,step=1 Diagonal -- triangular 1,3,6,10, but i=0 value=1
     # PyramidRows,step=0 Y_axis -- 1,2,3,4, but i=0 value=1
     #
     # Corner X_axis -- squares, but starting i=0 value=1
     # PyramidSides X_axis -- squares, but starting i=0 value=1
    );

sub oeis_anum {
  my ($self) = @_;
  return $oeis_anum{Math::NumSeq::PlanePathCoord::_planepath_oeis_key($self->{'planepath_object'})}
    ->{$self->{'line_type'}};
}

sub new {
  my $class = shift;
  ### NumSeq-PlanePathN new(): @_

  my $self = $class->SUPER::new(@_);

  my $planepath_object = ($self->{'planepath_object'}
                          ||= Math::NumSeq::PlanePathCoord::_planepath_name_to_object($self->{'planepath'}));

  my $line_type = $self->{'line_type'};
  $self->{'i_func'}
    = $self->can("i_func_$line_type")
      || croak "Unrecognised line_type: ",$line_type;
  $self->{'pred_func'}
    = $self->can("pred_func_$line_type")
      || croak "Unrecognised line_type: ",$line_type;

  if (my $func
      = $planepath_object->can("_NumSeq_${line_type}_step")) {
    $self->{'i_step'} = $planepath_object->$func();
  } elsif ($planepath_object->_NumSeq_A2()
           && ($line_type eq 'X_axis' || $line_type eq 'Y_axis')) {
    $self->{'i_step'} = 2;
  } else {
    $self->{'i_step'} = 1;
  }
  ### i_step: $self->{'i_step'}

  $self->rewind;
  return $self;
}

sub rewind {
  my ($self) = @_;
  $self->{'i'} = $self->i_start;
}

sub next {
  my ($self) = @_;
  ### NumSeq-PlanePath next(): $self->{'i'}." value ".&{$self->{'i_func'}}($self,$self->{'i'})

  if (defined (my $n = &{$self->{'i_func'}}($self,$self->{'i'}))) {
    return ($self->{'i'}++, $n);
  } else {
    return;
  }
}
sub ith {
  my ($self, $i) = @_;
  ### NumSeq-PlanePath ith(): $i

  my $planepath_object = $self->{'planepath_object'};
  return &{$self->{'i_func'}}($self, $i);
}

sub i_func_X_axis {
  my ($self, $i) = @_;
  my $path_object = $self->{'planepath_object'};
  return $path_object->xy_to_n ($i * $self->{'i_step'},
                                $path_object->_NumSeq_X_axis_at_Y);
}
sub i_func_Y_axis {
  my ($self, $i) = @_;
  my $path_object = $self->{'planepath_object'};
  return $path_object->xy_to_n ($path_object->_NumSeq_Y_axis_at_X,
                                $i * $self->{'i_step'});
}
sub i_func_Diagonal {
  my ($self, $i) = @_;
  my $path_object = $self->{'planepath_object'};
  return $path_object->xy_to_n ($i + $path_object->_NumSeq_Diagonal_X_offset,
                                $i);
}

sub i_func_X_neg {
  my ($self, $i) = @_;
  return $self->{'planepath_object'}->xy_to_n (-$i * $self->{'i_step'},
                                              0);
}
sub i_func_Y_neg {
  my ($self, $i) = @_;
  return $self->{'planepath_object'}->xy_to_n (0,
                                               -$i * $self->{'i_step'});
}

#------------------------------------------------------------------------------

sub pred {
  my ($self, $value) = @_;
  my $planepath_object = $self->{'planepath_object'};
  unless ($value == int($value)) {
    return 0;
  }
  my ($x,$y) = $planepath_object->n_to_xy($value)
    or return 0;
  return &{$self->{'pred_func'}} ($x,$y);
}
sub pred_func_X_axis {
  my ($x,$y) = @_;
  return ($x >= 0 && $y == 0);
}
sub pred_func_Y_axis {
  my ($x,$y) = @_;
  return ($x == 0 && $y >= 0);
}
sub pred_func_Diagonal {
  my ($x,$y) = @_;
  return ($x >= 0 && $x == $y);
}

#------------------------------------------------------------------------------

sub characteristic_increasing {
  my ($self) = @_;
  my $method = "_NumSeq_$self->{'line_type'}_increasing";
  my $planepath_object = $self->{'planepath_object'};
  return $planepath_object->can($method) && $planepath_object->$method();
}

sub default_i_start {
  my ($self) = @_;
  my $method = "_NumSeq_$self->{'line_type'}_i_start";
  my $planepath_object = $self->{'planepath_object'}
    # nasty hack allow no 'planepath_object' when SUPER::new() calls rewind()
    || return 0;
  if (my $func = $planepath_object->can($method)) {
    return $planepath_object->$func();
  } else {
    return 0; # default start i=0
  }
}
sub values_min {
  my ($self) = @_;
  my $method = "_NumSeq_$self->{'line_type'}_min";
  return $self->{'planepath_object'}->$method($self);
}
sub values_max {
  my ($self) = @_;
  my $method = "_NumSeq_$self->{'line_type'}_max";
  my $planepath_object = $self->{'planepath_object'};
  if (my $func = $planepath_object->can($method)) {
    return $self->{'planepath_object'}->$func($self);
  }
  return undef;
}

{ package Math::PlanePath;
  sub _NumSeq_X_axis_min {
    my ($path,$self) = @_;
    ### _NumSeq_X_axis_min() ...
    return $path->xy_to_n($self->i_start,
                          $path->_NumSeq_X_axis_at_Y);
  }
  sub _NumSeq_Y_axis_min {
    my ($path,$self) = @_;
    return $path->xy_to_n($path->_NumSeq_Y_axis_at_X,
                          $self->i_start);
  }
  sub _NumSeq_X_neg_min {
    my ($path,$self) = @_;
    return $path->xy_to_n(0,0);
  }
  sub _NumSeq_Y_neg_min {
    my ($path,$self) = @_;
    return $path->xy_to_n(0,0);
  }
  sub _NumSeq_Diagonal_min {
    my ($path,$self) = @_;
    my $i = $self->i_start;
    return $path->xy_to_n($i + $path->_NumSeq_Diagonal_X_offset,
                          $i);
  }

  use constant _NumSeq_X_axis_i_start => 0;
  use constant _NumSeq_Y_axis_i_start => 0;
  use constant _NumSeq_X_axis_at_Y => 0;
  use constant _NumSeq_Y_axis_at_X => 0;
  use constant _NumSeq_Diagonal_i_start => 0;
  use constant _NumSeq_Diagonal_X_offset => 0;

  # sub _NumSeq_pred_X_axis {
  #   my ($path, $value) = @_;
  #   return ($value == int($value)
  #           && ($path->x_negative || $value >= 0));
  # }
  # sub _NumSeq_pred_Y_axis {
  #   my ($path, $value) = @_;
  #   return ($value == int($value)
  #           && ($path->y_negative || $value >= 0));
  # }
}

{ package Math::PlanePath::SquareSpiral;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::PyramidSpiral;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::TriangleSpiral;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::TriangleSpiralSkewed;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::DiamondSpiral;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::PentSpiralSkewed;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::HexSpiral;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::HexSpiralSkewed;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::HeptSpiralSkewed;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::OctagramSpiral;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::AnvilSpiral;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
# { package Math::PlanePath::KnightSpiral;
# }
# { package Math::PlanePath::CretanLabyrinth;
# }
# { package Math::PlanePath::SquareArms;
# }
# { package Math::PlanePath::DiamondArms;
# }
# { package Math::PlanePath::HexArms;
# }
# { package Math::PlanePath::GreekKeySpiral;
# }
{ package Math::PlanePath::SacksSpiral;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
}
# { package Math::PlanePath::VogelFloret;
# }
# { package Math::PlanePath::TheodorusSpiral;
# }
# { package Math::PlanePath::ArchimedeanChords;
# }
{ package Math::PlanePath::MultipleRings;
  use constant _NumSeq_X_axis_increasing => 1;
}
{ package Math::PlanePath::PixelRings;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1; # where covered
}
{ package Math::PlanePath::Hypot;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::HypotOctant;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::TriangularHypot;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
# { package Math::PlanePath::PythagoreanTree;
# }
{ package Math::PlanePath::RationalsTree;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_X_axis_at_Y => 1;
  use constant _NumSeq_X_axis_i_start => 1;

  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Y_axis_at_X => 1;
  use constant _NumSeq_Y_axis_i_start => 1;
}
{ package Math::PlanePath::FractionsTree;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_X_offset => -1;
  use constant _NumSeq_Diagonal_i_start => 2;

  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Y_axis_at_X => 1;
  use constant _NumSeq_Y_axis_i_start => 2;
}
{ package Math::PlanePath::DiagonalRationals;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_axis_at_Y => 1;
  use constant _NumSeq_Y_axis_at_X => 1;
  use constant _NumSeq_X_axis_i_start => 1;
  use constant _NumSeq_Y_axis_i_start => 1;
}
{ package Math::PlanePath::FactorRationals;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_axis_at_Y => 1;
  use constant _NumSeq_Y_axis_at_X => 1;
  use constant _NumSeq_X_axis_i_start => 1;
  use constant _NumSeq_Y_axis_i_start => 1;
}
{ package Math::PlanePath::GcdRationals;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_axis_at_Y => 1;
  use constant _NumSeq_Y_axis_at_X => 1;
  use constant _NumSeq_X_axis_i_start => 1;
  use constant _NumSeq_Y_axis_i_start => 1;
}
{ package Math::PlanePath::PeanoCurve;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::HilbertCurve;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::ZOrderCurve;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
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
# { package Math::PlanePath::AlternatePaper;
# }
# { package Math::PlanePath::TerdragonCurve;
# }
# { package Math::PlanePath::TerdragonMidpoint;
# }
# { package Math::PlanePath::ComplexPlus;
# }
# { package Math::PlanePath::ComplexMinus;
# }
# { package Math::PlanePath::ComplexRevolving;
# }
{ package Math::PlanePath::Rows;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::Columns;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::Diagonals;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::Staircase;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::Corner;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::PyramidRows;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1; # when covered
}
{ package Math::PlanePath::PyramidSides;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::CellularRule;
  # ENHANCE-ME: more restrictive than this for many rules
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::CellularRule::LeftSolid;
  use constant _NumSeq_Y_axis_increasing => 1;
}
{ package Math::PlanePath::CellularRule54;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::CellularRule57;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::CellularRule190;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::CoprimeColumns;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_X_axis_i_start => 1;
  use constant _NumSeq_X_axis_at_Y => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_i_start => 1;
  use constant _NumSeq_Diagonal_X_offset => 1;
}
{ package Math::PlanePath::DivisibleColumns;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_X_axis_i_start => 1;
  use constant _NumSeq_X_axis_at_Y => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_i_start => 1;
}
# { package Math::PlanePath::File;
#   # File                   points from a disk file
#   # FIXME: analyze points for dx/dy min/max etc
# }
# { package Math::PlanePath::QuintetCurve;
# }
# { package Math::PlanePath::QuintetCentres;
#   # inherit QuintetCurve
# }

#------------------------------------------------------------------------------
{ package Math::PlanePath;
  use constant _NumSeq_A2 => 0;
}
{ package Math::PlanePath::PentSpiral;
  use constant _NumSeq_X_axis_step => 2;
}
{ package Math::PlanePath::TriangleSpiral;
  use constant _NumSeq_A2 => 1;
}
{ package Math::PlanePath::HexSpiral;
  use constant _NumSeq_A2 => 1;
}
{ package Math::PlanePath::HexArms;
  use constant _NumSeq_A2 => 1;
}
{ package Math::PlanePath::TriangularHypot;
  use constant _NumSeq_A2 => 1;
}
{ package Math::PlanePath::Flowsnake;
  use constant _NumSeq_A2 => 1;
  # and FlowsnakeCentres inherits
}

1;
__END__

=for stopwords Ryde PlanePath SquareSpiral

=head1 NAME

Math::NumSeq::PlanePathN -- sequence of N values from PlanePath module

=head1 SYNOPSIS

 use Math::NumSeq::PlanePathN;
 my $seq = Math::NumSeq::PlanePathN->new (planepath => 'SquareSpiral',
                                          line_type => 'X_axis');
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This module presents N values from a C<Math::PlanePath> as a sequence.  The
default is the X axis, or the C<line_type> parameter (a string) can choose
among

    "X_axis"        X axis
    "Y_axis"        Y axis
    "Diagonal"      leading diagonal X=Y

For example the SquareSpiral X axis starts i=0 with values 1, 2, 11, 28, 53,
86, etc.

The behaviour on paths which don't cover all points on the respective axis
is unspecified as yet, as is behaviour on paths with repeat points, such as
the DragonCurve.

=head1 FUNCTIONS

=over 4

=item C<$seq = Math::NumSeq::PlanePathN-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.  The options are

    planepath          string, name of a PlanePath module
    planepath_object   PlanePath object
    line_type          string, as described above

C<planepath> can be just the module part such as "SquareSpiral" or a full
class name "Math::PlanePath::SquareSpiral".

=item C<$value = $seq-E<gt>ith($i)>

Return the N value at C<$i> in the PlanePath.  C<$i> gives a position on the
respective C<line_type>, so the X,Y to lookup a C<$value=N> is

     X,Y     line_type
    -----    ---------
    $i,0     "X_axis"
    0,$i     "Y_axis"
    $i,$i    "Diagonal"

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> occurs in the sequence.  This means C<$value> is an
integer N on the respective C<line_type>.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::PlanePathCoord>,
L<Math::NumSeq::PlanePathDelta>

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
