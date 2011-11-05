# Copyright 2011 Kevin Ryde

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

# math-image --values=PlanePath

package Math::NumSeq::PlanePathCoord;
use 5.004;
use strict;
use Carp;

use vars '$VERSION','@ISA';
$VERSION = 53;
use Math::NumSeq;
@ISA = ('Math::NumSeq');

# uncomment this to run the ### lines
#use Smart::Comments;


use constant description => Math::NumSeq::__('Coordinate values from a PlanePath');
use constant characteristic_smaller => 1;

use constant::defer parameter_info_array =>
  sub {
    return [
            _parameter_info_planepath(),
            { name    => 'coordinate_type',
              display => Math::NumSeq::__('Coordinate Type'),
              type    => 'enum',
              default => 'X',
              choices => ['X','Y','Sum','Radius','RSquared',
                         ],
              # description => Math::NumSeq::__(''),
            },
           ];
  };

use constant::defer _parameter_info_planepath => sub {
  # require Module::Util;
  # cf ...::Generator->path_choices() order
  # my @choices = sort map { s/.*:://;
  #                          if (length() > $width) { $width = length() }
  #                          $_ }
  #   Module::Util::find_in_namespace('Math::PlanePath');

  # my $choices = ...::Generator->path_choices_array;
  # foreach (@$choices) {
  #   if (length() > $width) { $width = length() }
  # }

  require File::Spec;
  require Scalar::Util;
  my $width = 0;
  my %names;

  foreach my $dir (@INC) {
    next if ! defined $dir || ref $dir;
    # next if ref $dir eq 'CODE'  # subr
    #   || ref $dir eq 'ARRAY'    # array of subr and more
    #     || Scalar::Util::blessed($dir);

    opendir DIR, File::Spec->catdir ($dir, 'Math', 'PlanePath') or next;
    while (my $name = readdir DIR) {
      $name =~ s/\.pm$// or next;
      if (length($name) > $width) { $width = length($name) }
      $names{$name} = 1;  # hash slice
    }
    closedir DIR;
  }
  my $choices = [ sort keys %names ];

  return { name    => 'planepath',
           display => Math::NumSeq::__('PlanePath Class'),
           type    => 'string',
           default => $choices->[0],
           choices => $choices,
           width   => $width + 20,
           # description => Math::NumSeq::__(''),
         };
};

my %oeis_anum
  = ('Math::PlanePath::HilbertCurve' =>
     { X => 'A059253',
       Y => 'A059252',
       Sum  => 'A059261',
       RSquared => 'A163547',
       # OEIS-Catalogue: A059253 planepath=HilbertCurve coordinate_type=X
       # OEIS-Catalogue: A059252 planepath=HilbertCurve coordinate_type=Y
       # OEIS-Catalogue: A059261 planepath=HilbertCurve coordinate_type=Sum
       # OEIS-Catalogue: A163547 planepath=HilbertCurve coordinate_type=RSquared

       Diff => 'A059285',
     },

     'Math::PlanePath::PeanoCurve,radix=3' =>
     { X => 'A163528',
       Y => 'A163529',
       Sum => 'A163530',
       RSquared => 'A163531',
       # OEIS-Catalogue: A163528 planepath=PeanoCurve coordinate_type=X
       # OEIS-Catalogue: A163529 planepath=PeanoCurve coordinate_type=Y
       # OEIS-Catalogue: A163530 planepath=PeanoCurve coordinate_type=Sum
       # OEIS-Catalogue: A163531 planepath=PeanoCurve coordinate_type=RSquared
     },

     # RationalsTree,tree_type=CW is Stern diatomic A002487, but starting
     # N=0 X=1,1,2 or Y=1,2 rather than from 0
     #
     'Math::PlanePath::RationalsTree,tree_type=SB' =>
     { 
      # X is A007305 but starting extra 0,1
      # Sum is A007306 Farey, but starting extra 1,1
      # cf permutation A054424 
      #
      Y => 'A047679', # SB denominator
       # OEIS-Catalogue: A047679 planepath=RationalsTree coordinate_type=Y
     },
     'Math::PlanePath::RationalsTree,tree_type=Bird' =>
     { X => 'A162909', # Bird tree numerators
       Y => 'A162910', # Bird tree denominators
       # OEIS-Catalogue: A162909 planepath=RationalsTree,tree_type=Bird coordinate_type=X
       # OEIS-Catalogue: A162910 planepath=RationalsTree,tree_type=Bird coordinate_type=Y
     },
     'Math::PlanePath::RationalsTree,tree_type=Drib' =>
     { X => 'A162911', # Drib tree numerators
       Y => 'A162912', # Drib tree denominators
       # OEIS-Catalogue: A162911 planepath=RationalsTree,tree_type=Drib coordinate_type=X
       # OEIS-Catalogue: A162912 planepath=RationalsTree,tree_type=Drib coordinate_type=Y
     },

     'Math::PlanePath::TheodorusSpiral' =>
     { RSquared => 'A001477',  # non-negatives, starting 0
     },

     # PyramidRows step=0 is trivial X=0,Y=N
     'Math::PlanePath::PyramidRows,step=0' =>
     { X        => 'A000004',  # all-zeros
       Radius   => 'A001477',  # integers 0 upwards
       RSquared => 'A000290',  # squares 0 upwards
     },
     # PyramidRows step=1
     'Math::PlanePath::PyramidRows,step=1' =>
     { X => 'A002262',  # 0, 0,1, 0,1,2, etc
       Y => 'A003056',  # 0, 1,1, 2,2,2, 3,3,3,3
     },

     # PyramidRows step=2
     'Math::PlanePath::PyramidRows,step=2' =>
     { X => 'A196199',  # -n to n
       Y => 'A000196',  # n appears 2n+1 times, starting 0
       Sum => 'A053186',  # square excess of n, ie. n-sqrt(n)^2
       # OEIS-Catalogue: A196199 planepath=PyramidRows coordinate_type=X
       # OEIS-Catalogue: A000196 planepath=PyramidRows coordinate_type=Y
       # OEIS-Catalogue: A053186 planepath=PyramidRows coordinate_type=Sum
     },

     # PyramidSides
     'Math::PlanePath::PyramidSides' =>
     { X => 'A196199',  # -n to n, same as PyramidRows
     },

     'Math::PlanePath::Diagonals' =>
     { X   => 'A002262',  # 0, 0,1, 0,1,2, etc
       Y   => 'A025581',  # 0, 1,0, 2,1,0, 3,2,1,0
       Sum => 'A003056',  # 0, 1,1, 2,2,2, 3,3,3,3
       RSquared => 'A048147', # x^2+y^2 by diagonals
       # OEIS-Catalogue: A048147 planepath=Diagonals coordinate_type=RSquared
     },

     'Math::PlanePath::CornerReplicate' =>
     { Y => 'A059906',  # alternate bits second, same as ZOrderCurve
     },

     'Math::PlanePath::ZOrderCurve,radix=2' =>
     { X => 'A059905',  # alternate bits first
       Y => 'A059906',  # alternate bits second
       # OEIS-Catalogue: A059905 planepath=ZOrderCurve coordinate_type=X
       # OEIS-Catalogue: A059906 planepath=ZOrderCurve coordinate_type=Y
     },

     'Math::PlanePath::DivisibleColumns' =>
     { X => 'A061017',  # n appears divisors(n) times
       Y => 'A027750',  # triangle divisors of n
       # OEIS-Catalogue: A061017 planepath=DivisibleColumns coordinate_type=X
       # OEIS-Catalogue: A027750 planepath=DivisibleColumns coordinate_type=Y
     },

     'Math::PlanePath::CoprimeColumns' =>
     { X => 'A038567',  # canonical int->rat, denominator
       Y => 'A038566',  # canonical int->rat, numerator
       # OEIS-Catalogue: A038567 planepath=CoprimeColumns coordinate_type=X
       # OEIS-Catalogue: A038566 planepath=CoprimeColumns coordinate_type=Y
     },
    );

sub oeis_anum {
  my ($self) = @_;
  ### oeis_anum(), path key: _planepath_oeis_key($self->{'planepath_object'})

  # ENHANCE-ME: Rows/Columns runs of 0,0,0,1,1,1, etc in other coord
  #
  my $planepath_object = $self->{'planepath_object'};
  if ($planepath_object->isa('Math::PlanePath::Rows')
      && $self->{'coordinate_type'} eq 'X') {
    return _oeis_modulo($planepath_object->{'width'});
  }
  if ($planepath_object->isa('Math::PlanePath::Columns')
      && $self->{'coordinate_type'} eq 'Y') {
    return _oeis_modulo($planepath_object->{'height'});
  }

  return $oeis_anum{_planepath_oeis_key($planepath_object)}
    -> {$self->{'coordinate_type'}};
}
sub _oeis_modulo {
  my ($modulus) = @_;
  require Math::NumSeq::Modulo;
  return Math::NumSeq::Modulo->new(modulus=>$modulus)->oeis_anum;
}

sub _planepath_oeis_key {
  my ($path) = @_;
  return join(',',
              ref($path),
              map {
                my $value = $path->{$_->{'name'}};
                ### $_
                ### $value
                ### gives: "$_->{'name'}=$value"
                (defined $value ? "$_->{'name'}=$value" : ())
              }
              $path->parameter_info_list);
}

sub new {
  my $class = shift;
  ### NumSeq-PlanePathCoord new(): @_

  my $self = $class->SUPER::new(@_);

  my $planepath_object = ($self->{'planepath_object'}
                          ||= _planepath_name_to_object($self->{'planepath'}));

  ### coordinate func: '_coordinate_func_'.$self->{'coordinate_type'}
  $self->{'coordinate_func'}
    = $planepath_object->can("_NumSeq_Coord_$self->{'coordinate_type'}_func")
      || $self->can("_coordinate_func_$self->{'coordinate_type'}")
        || croak "Unrecognised coordinate_type: ",$self->{'coordinate_type'};
  $self->rewind;
  return $self;
}

sub _planepath_name_to_object {
  my ($name) = @_;
  ($name, my @args) = split /,+/, $name;
  $name = "Math::PlanePath::$name";
  require Module::Load;
  Module::Load::load ($name);
  return $name->new (map {/(.*?)=(.*)/} @args);

  # width => $options{'width'},
  # height => $options{'height'},
}

sub i_start {
  my ($self) = @_;
  return $self->{'planepath_object'} && $self->{'planepath_object'}->n_start;
}
sub rewind {
  my ($self) = @_;
  $self->{'i'} = $self->i_start;
}
sub next {
  my ($self) = @_;
  ### NumSeq-PlanePath next(): "i=$self->{'i'}"
  my $i = $self->{'i'}++;
  if (defined (my $value = &{$self->{'coordinate_func'}}($self, $i))) {
    return ($i, $value);
  } else {
    return;
  }
}
sub ith {
  my ($self, $i) = @_;
  ### NumSeq-PlanePath ith(): $i
  return &{$self->{'coordinate_func'}}($self,$i);
}

sub _coordinate_func_X {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  return $x;
}
sub _coordinate_func_Y {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  return $y;
}
sub _coordinate_func_Sum {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  return $x+$y;
}
sub _coordinate_func_Radius {
  my $rsquared;
  return (defined ($rsquared = _coordinate_func_RSquared(@_))
          ? sqrt($rsquared)
          : undef);
}
sub _coordinate_func_RSquared {
  my ($self, $n) = @_;
  ### _coordinate_func_RSquared(): $n, $self->{'planepath_object'}->n_to_xy($n)
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  return $x*$x + $y*$y;
}


#------------------------------------------------------------------------------

sub characteristic_monotonic {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'};
  my $func;
  return
    (($func = ($planepath_object->can("_NumSeq_Coord_$self->{'coordinate_type'}_monotonic")
               || ($self->{'coordinate_type'} eq 'RSquared'
                   && $planepath_object->can("_NumSeq_Coord_Radius_monotonic"))))
     ? $planepath_object->$func()
     : undef); # unknown
}

sub values_min {
  my ($self) = @_;
  ### PlanePathCoord values_min(): "_NumSeq_Coord_$self->{'coordinate_type'}_min"
  ### func: $self->{'planepath_object'}->can("_NumSeq_Coord_$self->{'coordinate_type'}_min")

  my $planepath_object = $self->{'planepath_object'};
  my $func;
  return (($func = $planepath_object->can("_NumSeq_Coord_$self->{'coordinate_type'}_min"))
          ? $planepath_object->$func()
          : undef);
}
sub values_max {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'};
  my $func;
  return (($func = $planepath_object->can("_NumSeq_Coord_$self->{'coordinate_type'}_max"))
          ? $planepath_object->$func()
          : undef);
}

{ package Math::PlanePath;
  sub _NumSeq_Coord_X_min {
    my ($self) = @_;
    return ($self->x_negative ? undef : 0);
  }

  sub _NumSeq_Coord_Y_min {
    my ($self) = @_;
    ### _NumSeq_Coord_Y_min() y_negative: $self->y_negative
    return ($self->y_negative ? undef : 0);
  }

  sub _NumSeq_Coord_Sum_min {
    my ($self) = @_;
    return ($self->x_negative || $self->y_negative
            ? undef
            : 0);  # X>=0 and Y>=0
  }

  sub _NumSeq_Coord_Radius_min {
    my ($path) = @_;
    return sqrt($path->_NumSeq_Coord_RSquared_min);
  }
  sub _NumSeq_Coord_Radius_max {
    my ($path) = @_;
    my $max = $path->_NumSeq_Coord_RSquared_max;
    return (defined $max ? sqrt($max) : undef);
  }
  use constant _NumSeq_Coord_RSquared_min => 0;
  use constant _NumSeq_Coord_RSquared_max => undef;

  sub _NumSeq_Coord_pred_X {
    my ($path, $value) = @_;
    return (($path->figure ne 'square' || $value == int($value))
            && ($path->x_negative || $value >= 0));
  }
  sub _NumSeq_Coord_pred_Y {
    my ($path, $value) = @_;
    return (($path->figure ne 'square' || $value == int($value))
            && ($path->y_negative || $value >= 0));
  }
  sub _NumSeq_Coord_pred_Sum {
    my ($path, $value) = @_;
    return (($path->figure ne 'square' || $value == int($value))
            && ($path->x_negative || $path->y_negative || $value >= 0));
  }
  sub _NumSeq_Coord_pred_R {
    my ($path, $value) = @_;
    return ($value >= 0);
  }
  sub _NumSeq_Coord_pred_RSquared {
    my ($path, $value) = @_;
    # whether x^2+y^2 ...
    return (($path->figure ne 'square' || $value == int($value))
            && $value >= 0);
  }
}

# { package Math::PlanePath::SquareSpiral;
# }
# { package Math::PlanePath::PyramidSpiral;
# }
# { package Math::PlanePath::TriangleSpiralSkewed;
# }
# { package Math::PlanePath::DiamondSpiral;
# }
# { package Math::PlanePath::PentSpiralSkewed;
# }
# { package Math::PlanePath::HexSpiralSkewed;
# }
# { package Math::PlanePath::HeptSpiralSkewed;
# }
# { package Math::PlanePath::OctagramSpiral;
# }
# { package Math::PlanePath::KnightSpiral;
# }
# { package Math::PlanePath::SquareArms;
# }
# { package Math::PlanePath::DiamondArms;
# }
# { package Math::PlanePath::GreekKeySpiral;
# }
# { package Math::PlanePath::SacksSpiral;
# }
# { package Math::PlanePath::VogelFloret;
# }
{ package Math::PlanePath::TheodorusSpiral;
  # exact value RSquare==$n, not through sqrts and sums in the main n_to_xy()
  sub _NumSeq_Coord_RSquared_func {
    my ($self, $n) = @_;
    ### TheodorusSpiral special RSquared: $n
    return $n;
  }
}
# { package Math::PlanePath::ArchimedeanChords;
# }
# { package Math::PlanePath::MultipleRings;
# }
# { package Math::PlanePath::PixelRings;
# }
{ package Math::PlanePath::Hypot;
  # in order of increasing radius, so monotonic
  use constant _NumSeq_Coord_Radius_monotonic => 1;
}
{ package Math::PlanePath::HypotOctant;
  # in order of increasing radius, so monotonic
  use constant _NumSeq_Coord_Radius_monotonic => 1;
}
{ package Math::PlanePath::PythagoreanTree;
  sub _NumSeq_Coord_pred_R {
    my ($path, $value) = @_;
    return ($value >= 0
            && ($path->{'coordinate_type'} ne 'AB' || $value == int($value)));
  }
}
# { package Math::PlanePath::RationalsTree;
# }
# { package Math::PlanePath::PeanoCurve;
# }
# { package Math::PlanePath::HilbertCurve;
# }
# { package Math::PlanePath::ZOrderCurve;
# }
# { package Math::PlanePath::ImaginaryBase;
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
{ package Math::PlanePath::QuadricCurve;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y
}
{ package Math::PlanePath::QuadricIslands;
}
{ package Math::PlanePath::SierpinskiTriangle;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y
}
{ package Math::PlanePath::SierpinskiArrowhead;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y
}
{ package Math::PlanePath::SierpinskiArrowheadCentres;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y
}
# { package Math::PlanePath::DragonCurve;
# }
# { package Math::PlanePath::DragonRounded;
# }
# { package Math::PlanePath::DragonMidpoint;
# }
# { package Math::PlanePath::ComplexMinus;
# }
# { package Math::PlanePath::Rows;
# }
# { package Math::PlanePath::Columns;
# }
# { package Math::PlanePath::Diagonals;
# }
# { package Math::PlanePath::Staircase;
# }
# { package Math::PlanePath::Corner;
# }
{ package Math::PlanePath::PyramidRows;
  sub _NumSeq_Coord_X_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 0    # X=0 vertical
            : undef);
  }
  sub _NumSeq_Coord_Sum_min {
    my ($self) = @_;
    return ($self->{'step'} <= 2
            ? 0    # triangular X>=-Y for step=2, vertical X>=0 step=1,0
            : undef);
  }
}
# { package Math::PlanePath::PyramidSides;
# }
{ package Math::PlanePath::CellularRule54;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y
}
{ package Math::PlanePath::CellularRule190;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y
}
{ package Math::PlanePath::UlamWarburton;
}
{ package Math::PlanePath::UlamWarburtonQuarter;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular Y>=-X
}
# { package Math::PlanePath::CoprimeColumns;
# }
# { package Math::PlanePath::DivisibleColumns;
# }
# { package Math::PlanePath::File;
#   # File                   points from a disk file
#   # FIXME: analyze points for min/max maybe
# }
# { package Math::PlanePath::QuintetCurve;
# }
# { package Math::PlanePath::QuintetCentres;
#   # inherit QuintetCurve
# }
# BetaOmega, CornerReplicate, DigitGroups, HIndexing, FibonacciWordFractal

#------------------------------------------------------------------------------
1;
__END__

sub pred {
  my ($self, $value) = @_;

  my $planepath_object = $self->{'planepath_object'};
  my $figure = $planepath_object->figure;
  if ($figure eq 'square') {
    if ($value != int($value)) {
      return 0;
    }
  } elsif ($figure eq 'circle') {
    return 1;
  }

  my $coordinate_type = $self->{'coordinate_type'};
  if ($coordinate_type eq 'X') {
    if ($planepath_object->x_negative) {
      return 1;
    } else {
      return ($value >= 0);
    }
  } elsif ($coordinate_type eq 'Y') {
    if ($planepath_object->y_negative) {
      return 1;
    } else {
      return ($value >= 0);
    }
  } elsif ($coordinate_type eq 'Sum') {
    if ($planepath_object->x_negative || $planepath_object->y_negative) {
      return 1;
    } else {
      return ($value >= 0);
    }
  } elsif ($coordinate_type eq 'RSquared') {
    # FIXME: only sum of two squares, and for triangular same odd/even
    return ($value >= 0);
  }

  return undef;
}


=for stopwords Ryde PlanePath

=head1 NAME

Math::NumSeq::PlanePathCoord -- sequence of coordinate values from a PlanePath module

=head1 SYNOPSIS

 use Math::NumSeq::PlanePathCoord;
 my $seq = Math::NumSeq::PlanePathCoord->new (planepath => 'SquareSpiral',
                                              coordinate_type => 'X');
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This is a tie-in to present coordinates from a C<Math::PlanePath> module as
a NumSeq sequence.

=head1 FUNCTIONS

=over 4

=item C<$seq = Math::NumSeq::PlanePathCoord-E<gt>new (planepath =E<gt> $name, coordinate_type =E<gt> 'X')>

Create and return a new sequence object.  The C<planepath> option is the
name of one of the C<Math::PlanePath> modules.

C<coordinate_type> (a string) is what coordinate from the path is wanted.
The choices are

    "X"          X coordinate
    "Y"          Y coordinate
    "Sum"        X+Y sum
    "Radius"     sqrt(X^2+Y^2) radius 
    "RSquared"   X^2+Y^2 radius squared

=item C<$value = $seq-E<gt>ith($i)>

Return the coordinate at N=$i in the PlanePath.

=back

=head1 SEE ALSO

L<Math::NumSeq>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011 Kevin Ryde

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

# Local variables:
# compile-command: "math-image --values=PlanePathCoord"
# End:
