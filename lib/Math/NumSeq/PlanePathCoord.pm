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



# Taxi = abs(X)+abs(Y)   AbsSum SumAbs
# TRadius
# TRSquared   (x^2+3*y^2)/2
# TriangularRadius
# Ti = (X-Y)/2
# Tj = Y
# Tk = (Y-X)/2


package Math::NumSeq::PlanePathCoord;
use 5.004;
use strict;
use Carp;

use vars '$VERSION','@ISA';
$VERSION = 66;
use Math::NumSeq;
@ISA = ('Math::NumSeq');

# uncomment this to run the ### lines
#use Smart::Comments;


use constant 1.02; # various underscore constants below
use constant description => Math::NumSeq::__('Coordinate values from a PlanePath');

use constant::defer parameter_info_array =>
  sub {
    return [
            _parameter_info_planepath(),
            { name    => 'coordinate_type',
              display => Math::NumSeq::__('Coordinate Type'),
              type    => 'enum',
              default => 'X',
              choices => ['X','Y','Sum','Product',
                          'DiffXY','DiffYX','AbsDiff',
                          'Radius','RSquared',
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

#------------------------------------------------------------------------------

my %oeis_anum =
  (
   # ENHANCE-ME: Rows/Columns runs of 0,0,0,1,1,1, etc in other coord
   #

   # 'Math::PlanePath::SquareSpiral,wider=0' =>
   # {
   #  # OFFSET n=0 not N=1
   #  # Sum     => 'A180714', # X+Y of square spiral
   #  # # OEIS-Catalogue: A180714 planepath=SquareSpiral coordinate_type=Sum
   #
   #   # Not quite, A053615 starts n=0 but SquareSpiral starts N=1
   #   # AbsDiff => 'A053615', # 0..n..0, distance to pronic
   #   #
   #   # cf A053615 also Math::PlanePath::PyramidSpiral abs(X),
   #   # coordinate going up and down ...
   # },

   # 'Math::PlanePath::Corner,wider=0' =>
   # {
   #  # Not quite, A196199 starts n=0 but Corner starts N=1
   #  # DiffXY  => 'A196199', # -n to +n
   #
   #  # Not quite, A053615 starts n=0 but Corner starts N=1
   #  # AbsDiff => 'A053615', # 0..n..0
   # },

   # 'Math::PlanePath::Corner,wider=1' =>
   # AbsDiff almost A053188 because the perfect squares occur on the leading
   # diagonal X=Y.  But A053188 starts n=0 (with value 0), whereas planepath
   # here starts i=1 for N=1 being the first point.

   'Math::PlanePath::HilbertCurve' =>
   { X => 'A059253',
     Y => 'A059252',
     Sum  => 'A059261',
     DiffXY => 'A059285',
     RSquared => 'A163547',
     # OEIS-Catalogue: A059253 planepath=HilbertCurve coordinate_type=X
     # OEIS-Catalogue: A059252 planepath=HilbertCurve coordinate_type=Y
     # OEIS-Catalogue: A059261 planepath=HilbertCurve coordinate_type=Sum
     # OEIS-Catalogue: A059285 planepath=HilbertCurve coordinate_type=DiffXY
     # OEIS-Catalogue: A163547 planepath=HilbertCurve coordinate_type=RSquared
   },
   # HilbertSpiral going negative is mirror on X=-Y line, which is (-Y,-X),
   # and -Y-(-X) = X-Y same as plain HilbertCurve
   'Math::PlanePath::HilbertSpiral' =>
   { DiffXY   => 'A059285',
     # OEIS-Other: A059285 planepath=HilbertSpiral coordinate_type=DiffXY
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

   # 'Math::PlanePath::RationalsTree,tree_type=SB' =>
   # {
   #  # OFFSET n=0 cf N=1
   #  # Y => 'A047679', # SB denominator
   #  # # OEIS-Catalogue: A047679 planepath=RationalsTree coordinate_type=Y
   #  #
   #  # X is A007305 SB numerators but starting extra 0,1
   #  # Sum is A007306 Farey/SB denominators, but starting extra 1,1
   #  # Product is A119272 num*den, but starting extra 1,1
   #  # cf A054424 permutation
   # },
   'Math::PlanePath::RationalsTree,tree_type=CW' =>
   {
    # stern diatomic adjacent S(n)*S(n+1), or Conway's alimentary function
    Product => 'A070871',
    # OEIS-Catalogue: A070871 planepath=RationalsTree,tree_type=CW coordinate_type=Product
    #
    # CW X and Y is Stern diatomic A002487, but RationalsTree starts N=0
    #    X=1,1,2 or Y=1,2 rather than from 0
    # CW DiffYX is A070990 stern diatomic first diffs, but RationalsTree
    #    starts N=0 diff=0, whereas A070990 starts n=0 diff=1 one less term
    #
   },
   'Math::PlanePath::RationalsTree,tree_type=AYT' =>
   { X      => 'A020650', # AYT numerator
     Y      => 'A020651', # AYT denominator
     Sum    => 'A086592', # Kepler's tree denominators
     # OEIS-Catalogue: A020650 planepath=RationalsTree,tree_type=AYT coordinate_type=X
     # OEIS-Catalogue: A020651 planepath=RationalsTree,tree_type=AYT coordinate_type=Y
     # OEIS-Other: A086592 planepath=RationalsTree,tree_type=AYT coordinate_type=Sum
     #
     # DiffYX almost A070990 Stern diatomic first differences, but we have
     # an extra 0 at the start, and we start i=1 rather than n=0 too
   },
   'Math::PlanePath::RationalsTree,tree_type=Bird' =>
   { X   => 'A162909', # Bird tree numerators
     Y   => 'A162910', # Bird tree denominators
     # OEIS-Catalogue: A162909 planepath=RationalsTree,tree_type=Bird coordinate_type=X
     # OEIS-Catalogue: A162910 planepath=RationalsTree,tree_type=Bird coordinate_type=Y
   },
   'Math::PlanePath::RationalsTree,tree_type=Drib' =>
   { X => 'A162911', # Drib tree numerators
     Y => 'A162912', # Drib tree denominators
     # OEIS-Catalogue: A162911 planepath=RationalsTree,tree_type=Drib coordinate_type=X
     # OEIS-Catalogue: A162912 planepath=RationalsTree,tree_type=Drib coordinate_type=Y
   },

   'Math::PlanePath::FractionsTree,tree_type=Kepler' =>
   { X       => 'A020651', # numerators, same as AYT denominators
     Y       => 'A086592', # Kepler half-tree denominators
     DiffYX  => 'A020650', # AYT numerators
     AbsDiff => 'A020650', # AYT numerators
     # OEIS-Other: A020651 planepath=FractionsTree coordinate_type=X
     # OEIS-Catalogue: A086592 planepath=FractionsTree coordinate_type=Y
     # OEIS-Other: A020650 planepath=FractionsTree coordinate_type=DiffYX
     # OEIS-Other: A020650 planepath=FractionsTree coordinate_type=AbsDiff
     #
     # cf Sum A086593 every second denominator, but Sum from 1/2 value=3
     # skipping the initial value=2 in A086593
   },


   'Math::PlanePath::TheodorusSpiral' =>
   { RSquared => 'A001477',  # integers 0,1,2,3,etc
     # OEIS-Other: A001477 planepath=TheodorusSpiral coordinate_type=RSquared
   },

   # OFFSET n=0 whereas Diagonals starts from N=1
   # 'Math::PlanePath::Diagonals' =>
   # { X        => 'A002262',  # 0, 0,1, 0,1,2, etc
   #   Y        => 'A025581',  # 0, 1,0, 2,1,0, 3,2,1,0 descending
   #   Product  => 'A004247',  # 0, 0,0,0, 1, 0,0, 2,2, 0,0, 3,4,5, 0,0
   #   Sum      => 'A003056',  # 0, 1,1, 2,2,2, 3,3,3,3
   #   DiffYX   => 'A114327',  # Y-X by anti-diagonals
   #   AbsDiff  => 'A049581',  # abs(Y-X) by anti-diagonals
   #   RSquared => 'A048147',  # x^2+y^2 by diagonals
   #   # OEIS-Catalogue: A002262 planepath=Diagonals coordinate_type=X
   #   # OEIS-Catalogue: A025581 planepath=Diagonals coordinate_type=Y
   #   # OEIS-Catalogue: A003056 planepath=Diagonals coordinate_type=Sum
   #   # OEIS-Catalogue: A114327 planepath=Diagonals coordinate_type=DiffYX
   #   # OEIS-Catalogue: A049581 planepath=Diagonals coordinate_type=AbsDiff
   #   # OEIS-Catalogue: A048147 planepath=Diagonals coordinate_type=RSquared
   # },

   # PyramidRows step=0 is trivial X=0,Y=N
   'Math::PlanePath::PyramidRows,step=0' =>
   { X        => 'A000004',  # all-zeros
     Product  => 'A000004',  # all-zeros
     # OEIS-Other: A000004 planepath=PyramidRows,step=0 coordinate_type=X
     # OEIS-Other: A000004 planepath=PyramidRows,step=0 coordinate_type=Product

     # but starts N=1
     # RSquared => 'A000290',  # squares 0 upwards
     # # OEIS-Other: A000290 planepath=PyramidRows,step=0 coordinate_type=RSquared

     # But A001477 offset=0 where PyramidRows starts N=1
     # Y        => 'A001477',  # integers 0 upwards
     # Sum      => 'A001477',  # integers 0 upwards
     # DiffYX   => 'A001477',  # integers 0 upwards
     # AbsDiff  => 'A001477',  # integers 0 upwards
     # Radius   => 'A001477',  # integers 0 upwards
     # # OEIS-Other: A001477 planepath=PyramidRows,step=0 coordinate_type=Y
     # # OEIS-Other: A001477 planepath=PyramidRows,step=0 coordinate_type=Sum
     # # OEIS-Other: A001477 planepath=PyramidRows,step=0 coordinate_type=DiffYX
     # # OEIS-Other: A001477 planepath=PyramidRows,step=0 coordinate_type=AbsDiff
     # # OEIS-Other: A001477 planepath=PyramidRows,step=0 coordinate_type=Radius

     # # But A001489 offset=0 where PyramidRows starts N=1
     # DiffXY   => 'A001489',  # negative integers 0 downwards
     # # OEIS-Other: A001489 planepath=PyramidRows,step=0 coordinate_type=DiffXY
   },

   # OFFSET
   # 'Math::PlanePath::PyramidRows,step=1' =>
   # { Sum      => 'A051162',  # triangle X+Y for X=0 to Y inclusive
   #   RSquared => 'A069011',  # triangle X^2+Y^2 for X=0 to Y inclusive
   #   # OEIS-Catalogue: A051162 planepath=PyramidRows,step=1 coordinate_type=Sum
   #   # OEIS-Catalogue: A069011 planepath=PyramidRows,step=1 coordinate_type=RSquared
   #
   #   # X        => 'A002262',  # 0, 0,1, 0,1,2, etc (Diagonals)
   #   # Y        => 'A003056',  # 0, 1,1, 2,2,2, 3,3,3,3 (Diagonals)
   #   # DiffYX   => 'A025581',  # descending N to 0 (Diagonals)
   #   # # OEIS-Other: A002262 planepath=PyramidRows,step=1 coordinate_type=X
   #   # # OEIS-Other: A003056 planepath=PyramidRows,step=1 coordinate_type=Y
   #   # # OEIS-Other: A025581 planepath=PyramidRows,step=1 coordinate_type=DiffYX
   # },

   # OFFSET
   # # PyramidRows step=2
   # 'Math::PlanePath::PyramidRows,step=2' =>
   # { X   => 'A196199',  # -n to n
   #   Y   => 'A000196',  # n appears 2n+1 times, starting 0
   #   Sum => 'A053186',  # square excess of n, ie. n-sqrt(n)^2
   #   # OEIS-Catalogue: A196199 planepath=PyramidRows coordinate_type=X
   #   # OEIS-Catalogue: A000196 planepath=PyramidRows coordinate_type=Y
   #   # OEIS-Catalogue: A053186 planepath=PyramidRows coordinate_type=Sum
   # },

   # OFFSET
   # # PyramidRows step=3
   # 'Math::PlanePath::PyramidRows,step=3' =>
   # { Y   => 'A180447',  # n appears 3n+1 times, starting 0
   #   # OEIS-Catalogue: A180447 planepath=PyramidRows,step=3 coordinate_type=Y
   # },

   # PyramidSides
   # OFFSET
   # 'Math::PlanePath::PyramidSides' =>
   # { X => 'A196199',  # -n to n
   #   # OEIS-Other: A196199 planepath=PyramidSides coordinate_type=X
   # },

   # MultipleRings step=0 is trivial X=N,Y=0
   'Math::PlanePath::MultipleRings,step=0' =>
   { Y        => 'A000004',  # all-zeros
     Product  => 'A000004',  # all-zeros
     # OEIS-Other: A000004 planepath=MultipleRings,step=0 coordinate_type=Y
     # OEIS-Other: A000004 planepath=MultipleRings,step=0 coordinate_type=Product

     # OFFSET
     # X        => 'A001477',  # integers 0 upwards
     # Sum      => 'A001477',  # integers 0 upwards
     # AbsDiff  => 'A001477',  # integers 0 upwards
     # Radius   => 'A001477',  # integers 0 upwards
     # DiffXY   => 'A001477',  # integers 0 upwards
     # DiffYX   => 'A001489',  # negative integers 0 downwards
     # RSquared => 'A000290',  # squares 0 upwards
     # # OEIS-Other: A001477 planepath=MultipleRings,step=0 coordinate_type=X
     # # OEIS-Other: A001477 planepath=MultipleRings,step=0 coordinate_type=Sum
     # # OEIS-Other: A001477 planepath=MultipleRings,step=0 coordinate_type=AbsDiff
     # # OEIS-Other: A001477 planepath=MultipleRings,step=0 coordinate_type=Radius
     # # OEIS-Other: A001477 planepath=MultipleRings,step=0 coordinate_type=DiffXY
     # # OEIS-Other: A001489 planepath=MultipleRings,step=0 coordinate_type=DiffYX
     # # OEIS-Other: A000290 planepath=MultipleRings,step=0 coordinate_type=RSquared
   },

   'Math::PlanePath::ZOrderCurve,radix=2' =>
   { X => 'A059905',  # alternate bits first
     Y => 'A059906',  # alternate bits second
     # OEIS-Catalogue: A059905 planepath=ZOrderCurve coordinate_type=X
     # OEIS-Catalogue: A059906 planepath=ZOrderCurve coordinate_type=Y
   },
   'Math::PlanePath::ZOrderCurve,radix=3' =>
   { X => 'A163325',  # alternate ternary digits first
     Y => 'A163326',  # alternate ternary digits second
     # OEIS-Catalogue: A163325 planepath=ZOrderCurve,radix=3 coordinate_type=X
     # OEIS-Catalogue: A163326 planepath=ZOrderCurve,radix=3 coordinate_type=Y
   },
   'Math::PlanePath::ZOrderCurve,radix=10,i_start=1' =>
   {
    # i_start=1 per A080463 offset=1, it skips initial zero
    Sum => 'A080463',
    # OEIS-Catalogue: A080463 planepath=ZOrderCurve,radix=10 coordinate_type=Sum i_start=1
   },
   'Math::PlanePath::ZOrderCurve,radix=10,i_start=10' =>
   {
    # i_start=10 per A080464 offset=10, it skips all but one initial zeros
    Product => 'A080464',
    # OEIS-Catalogue: A080464 planepath=ZOrderCurve,radix=10 coordinate_type=Product i_start=10
    AbsDiff => 'A080465',
    # OEIS-Catalogue: A080465 planepath=ZOrderCurve,radix=10 coordinate_type=AbsDiff i_start=10
   },

   'Math::PlanePath::CornerReplicate' =>
   { Y => 'A059906',  # alternate bits second
     # OEIS-Other: A059906 planepath=CornerReplicate coordinate_type=Y
   },

   # OFFSET
   # 'Math::PlanePath::DivisibleColumns' =>
   # { X => 'A061017',  # n appears divisors(n) times
   #   Y => 'A027750',  # triangle divisors of n
   #   # OEIS-Catalogue: A061017 planepath=DivisibleColumns coordinate_type=X
   #   # OEIS-Catalogue: A027750 planepath=DivisibleColumns coordinate_type=Y
   # },

   # A027751 is almost proper divisor Y values, but has an extra 1 at the
   # start from reckoning by convention 1 as a proper divisor of 1 -- though
   # that's inconsistent with A032741 count of proper divisors being 0.
   #
   # 'Math::PlanePath::DivisibleColumns,divisor_type=proper' =>
   # { Y => 'A027751',  # proper divisors by rows
   #   # OEIS-Catalogue: A027751 planepath=DivisibleColumns,divisor_type=proper coordinate_type=Y
   # },

   # Not quite, A038566/A038567 starts n=1 for 1/1, but CoprimeColumns N=0
   # 'Math::PlanePath::CoprimeColumns' =>
   # { X => 'A038567',  # fractions denominator
   #   Y => 'A038566',  # fractions numerator
   #   # OEIS-Catalogue: A038567 planepath=CoprimeColumns coordinate_type=X
   #   # OEIS-Catalogue: A038566 planepath=CoprimeColumns coordinate_type=Y
   # },
   #
   'Math::PlanePath::CoprimeColumns,i_start=1' =>
   {
    DiffXY => 'A020653', # diagonals denominators, starting n=1
   },

   'Math::PlanePath::DiagonalRationals' =>
   { X       => 'A020652',  # numerators
     Y       => 'A020653',  # denominators
     # OEIS-Catalogue: A020652 planepath=DiagonalRationals coordinate_type=X
     # OEIS-Catalogue: A020653 planepath=DiagonalRationals coordinate_type=Y

     # but it has OFFSET=0 unlike num,den which are OFFSET=1 as per N=1
     # DiagonalRationals
     # AbsDiff => 'A157806', # abs(num-den)
   },

   'Math::PlanePath::FactorRationals' =>
   { X       => 'A071974',  # numerators
     Y       => 'A071975',  # denominators
     Product => 'A019554',  # replace squares by their root
     # OEIS-Catalogue: A071974 planepath=FactorRationals coordinate_type=X
     # OEIS-Catalogue: A071975 planepath=FactorRationals coordinate_type=Y
     # OEIS-Catalogue: A019554 planepath=FactorRationals coordinate_type=Product
   },

   'Math::PlanePath::GcdRationals' =>
   { Y => 'A054531',  # T(n,k) = n/GCD(n,k), being denominators
     # OEIS-Catalogue: A054531 planepath=GcdRationals coordinate_type=Y
   },

   'Math::PlanePath::Rows,width=1' =>
   { Product  => 'A000004', # all zeros
     # OEIS-Other: A000004 planepath=Rows,width=1 coordinate_type=Product

     # OFFSET
     # Y        => 'A001477', # integers 0 upwards
     # Sum      => 'A001477', # integers 0 upwards
     # # OEIS-Other: A001477 planepath=Rows,width=1 coordinate_type=Y
     # DiffXY   => 'A001489', # negative integers 0 downwards
     # DiffYX   => 'A001477', # integers 0 upwards
     # AbsDiff  => 'A001477', # integers 0 upwards
     # Radius   => 'A001477', # integers 0 upwards
     # RSquared => 'A000290', # squares 0 upwards
     # # OEIS-Other: A001477 planepath=Rows,width=1 coordinate_type=Sum
     # # OEIS-Other: A001489 planepath=Rows,width=1 coordinate_type=DiffXY
     # # OEIS-Other: A001477 planepath=Rows,width=1 coordinate_type=DiffYX
     # # OEIS-Other: A001477 planepath=Rows,width=1 coordinate_type=AbsDiff
     # # OEIS-Other: A001477 planepath=Rows,width=1 coordinate_type=Radius
     # # OEIS-Other: A000290 planepath=Rows,width=1 coordinate_type=RSquared
   },

   'Math::PlanePath::Columns,height=1' =>
   { Product  => 'A000004', # all zeros
     # OEIS-Other: A000004 planepath=Columns,height=1 coordinate_type=Product

     # OFFSET
     # X        => 'A001477', # integers 0 upwards
     # Sum      => 'A001477', # integers 0 upwards
     # DiffXY   => 'A001477', # integers 0 upwards
     # DiffYX   => 'A001489', # negative integers 0 downwards
     # AbsDiff  => 'A001477', # integers 0 upwards
     # Radius   => 'A001477', # integers 0 upwards
     # RSquared => 'A000290', # squares 0 upwards
     # # OEIS-Other: A001477 planepath=Columns,height=1 coordinate_type=X
     # # OEIS-Other: A001477 planepath=Columns,height=1 coordinate_type=Sum
     # # OEIS-Other: A001489 planepath=Columns,height=1 coordinate_type=DiffYX
     # # OEIS-Other: A001477 planepath=Columns,height=1 coordinate_type=DiffXY
     # # OEIS-Other: A001477 planepath=Columns,height=1 coordinate_type=AbsDiff
     # # OEIS-Other: A001477 planepath=Columns,height=1 coordinate_type=Radius
     # # OEIS-Other: A000290 planepath=Columns,height=1 coordinate_type=RSquared
   },

   'Math::PlanePath::Rows,width=2' =>
   {
    # OFFSET
    # X       => 'A000035', # 0,1 repeating
    # # OEIS-Other: A000035 planepath=Rows,width=2 coordinate_type=X

    # not quite, Rows starts N=1 but A004525 starts n=0
    # Y       => 'A004525', # 0,0,1,1,2,2,etc
    #
    # almost Product => 'A142150', but it's "0,0,1,0,2" whereas product has
    # extra 0 "0,0,0,1,0,2,0"
   },
   'Math::PlanePath::Columns,height=2' =>
   {
    # OFFSET
    # Y   => 'A000035', # 0,1 repeating
    # # OEIS-Other: A000035 planepath=Columns,height=2 coordinate_type=Y

    # not quite, Columns starts N=1 but A004525 starts n=0
    # X   => 'A004525', # 0,0,1,1,2,2,etc
   },
  );

sub oeis_anum {
  my ($self) = @_;
  ### PlanePathCoord oeis_anum() ...

  my $planepath_object = $self->{'planepath_object'};
  my $coordinate_type = $self->{'coordinate_type'};

  if ($planepath_object->isa('Math::PlanePath::Rows')) {
    my $width = $planepath_object->{'width'};
    if ($coordinate_type eq 'X') {
      return _oeis_modulo($width);
    }
  }
  if ($planepath_object->isa('Math::PlanePath::Columns')) {
    my $height = $planepath_object->{'height'};
    if ($coordinate_type eq 'Y') {
      return _oeis_modulo($height);
    }
  }

  my $key = _planepath_oeis_key($planepath_object);

  {
    my $i_start = $self->i_start;
    if ($i_start != $planepath_object->n_start) {
      $key .= ",i_start=$i_start";
    }
    ### $i_start
    ### n_start: $planepath_object->n_start
  }
  ### $key

  return $oeis_anum{$key}->{$coordinate_type};
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
              (map {
                my $value = $path->{$_->{'name'}};
                ### $_
                ### $value
                ### gives: "$_->{'name'}=$value"
                (defined $value ? "$_->{'name'}=$value" : ())
              }
               $path->parameter_info_list,
               ($path->isa('Math::PlanePath::Rows') ? ({name=>'width'}) : ()),
               ($path->isa('Math::PlanePath::Columns')? ({name=>'height'}) : ())));
}

#------------------------------------------------------------------------------

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
  ### _planepath_name_to_object(): $name
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
  return (defined $self->{'i_start'}
          ? $self->{'i_start'}
          # nasty hack allow no 'planepath_object' when SUPER::new() calls
          # rewind()
          : $self->{'planepath_object'} &&
          $self->{'planepath_object'}->n_start);
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
  return $x + $y;
}
sub _coordinate_func_Product {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  return $x * $y;
}
sub _coordinate_func_DiffXY {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  return $x - $y;
}
sub _coordinate_func_DiffYX {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  return $y - $x;
}
sub _coordinate_func_AbsDiff {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  return abs($x - $y);
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

sub characteristic_smaller {
  my ($self) = @_;
  ### characteristic_smaller() ...
  my $planepath_object = $self->{'planepath_object'};
  my $func;
  return
    (($func = ($planepath_object->can("_NumSeq_Coord_$self->{'coordinate_type'}_smaller")))
     ? $planepath_object->$func()
     : 1); # default is smaller
}

sub characteristic_increasing {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'};
  my $func;
  return
    (($func = ($planepath_object->can("_NumSeq_Coord_$self->{'coordinate_type'}_increasing")
               || ($self->{'coordinate_type'} eq 'RSquared'
                   && $planepath_object->can("_NumSeq_Coord_Radius_increasing"))))
     ? $planepath_object->$func()
     : undef); # unknown
}

sub characteristic_non_decreasing {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'};
  my $func;
  return
    (($func = ($planepath_object->can("_NumSeq_Coord_$self->{'coordinate_type'}_non_decreasing")
               || ($self->{'coordinate_type'} eq 'RSquared'
                   && $planepath_object->can("_NumSeq_Coord_Radius_non_decreasing"))))
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
  use constant _NumSeq_Coord_X_max => undef;
  use constant _NumSeq_Coord_Y_max => undef;

  sub _NumSeq_Coord_Sum_min {
    my ($self) = @_;
    ### _NumSeq_Coord_Sum_min() ...
    if (defined (my $x_min = $self->_NumSeq_Coord_X_min)
        && defined (my $y_min = $self->_NumSeq_Coord_Y_min)) {
      return $x_min + $y_min;
    } else {
      return undef;
    }
  }

  sub _NumSeq_Coord_Product_min {
    my ($self) = @_;
    my ($x_min, $y_min);
    if (defined ($x_min = $self->_NumSeq_Coord_X_min)
        && defined ($y_min = $self->_NumSeq_Coord_Y_min)
        && $x_min >= 0
        && $y_min >= 0) {
      return $x_min * $y_min;
    }
    return undef;
  }
  sub _NumSeq_Coord_Product_max {
    my ($self) = @_;
    my ($x_max, $y_min);
    ### X_max: $self->_NumSeq_Coord_X_max
    ### Y_min: $self->_NumSeq_Coord_Y_min
    if (defined ($x_max = $self->_NumSeq_Coord_X_max)
        && defined ($y_min = $self->_NumSeq_Coord_Y_min)
        && $x_max <= 0
        && $y_min >= 0) {
      # X all negative, Y all positive
      return $y_min * $x_max;
    }
    return undef;
  }

  sub _NumSeq_Coord_DiffXY_min {
    my ($self) = @_;
    if (defined (my $y_max = $self->_NumSeq_Coord_Y_max)
        && defined (my $x_min = $self->_NumSeq_Coord_X_min)) {
      return $x_min - $y_max;
    } else {
      return undef;
    }
  }
  sub _NumSeq_Coord_DiffXY_max {
    my ($self) = @_;
    if (defined (my $y_min = $self->_NumSeq_Coord_Y_min)
        && defined (my $x_max = $self->_NumSeq_Coord_X_max)) {
      return $x_max - $y_min;
    } else {
      return undef;
    }
  }

  sub _NumSeq_Coord_DiffYX_min {
    my ($self) = @_;
    if (defined (my $m = $self->_NumSeq_Coord_DiffXY_max)) {
      return - $m;
    } else {
      return undef;
    }
  }
  sub _NumSeq_Coord_DiffYX_max {
    my ($self) = @_;
    if (defined (my $m = $self->_NumSeq_Coord_DiffXY_min)) {
      return - $m;
    } else {
      return undef;
    }
  }

  sub _NumSeq_Coord_AbsDiff_min {
    my ($self) = @_;
    my $m;
    if (defined ($m = $self->_NumSeq_Coord_DiffXY_min)
        && $m >= 0) {
      return $m;
    }
    if (defined ($m = $self->_NumSeq_Coord_DiffXY_max)
        && $m <= 0) {
      return - $m;
    }
    return 0;
  }
  sub _NumSeq_Coord_AbsDiff_max {
    my ($self) = @_;
    if (defined (my $min = $self->_NumSeq_Coord_DiffXY_min)
        && defined (my $max = $self->_NumSeq_Coord_DiffXY_max)) {
      $min = abs($min);
      $max = abs($max);
      return ($min > $max ? $min : $max);
    }
    return undef;
  }

  sub _NumSeq_Coord_Radius_min {
    my ($path) = @_;
    return sqrt($path->_NumSeq_Coord_RSquared_min);
  }
  sub _NumSeq_Coord_RSquared_min {
    my ($self) = @_;
    if (defined (my $x_min = $self->_NumSeq_Coord_X_min)
        && defined (my $y_min = $self->_NumSeq_Coord_Y_min)) {
      return $x_min*$x_min + $y_min*$y_min;
    } else {
      return 0;
    }
  }
  # Radius and RSquare max normally infinite
  # sub _NumSeq_Coord_Radius_max {
  #   my ($path) = @_;
  #   if (my $coderef = $path->can('_NumSeq_Coord_RSquared_max')) {
  #     if (defined (my $max = $path->$coderef)) {
  #       return sqrt($max);
  #     }
  #   }
  #   return undef;
  # }

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
# { package Math::PlanePath::HexSpiral;
# }
# { package Math::PlanePath::HexSpiralSkewed;
# }
# { package Math::PlanePath::HeptSpiralSkewed;
# }
# { package Math::PlanePath::AnvilSpiral;
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
{ package Math::PlanePath::VogelFloret;
  sub _NumSeq_Coord_RSquared_min {
    my ($self) = @_;
    # starting N=1 at X=1,Y=0
    return $self->{'radius_factor'};
  }
  sub _NumSeq_Coord_RSquared_func {
    my ($seq, $i) = @_;
    ### VogelFloret RSquared: $i, $seq->{'planepath_object'}
    # exact value RSquared==$i, so as not to lose precision through sqrts
    # and sums in the main n_to_xy()
    return $i * $seq->{'planepath_object'}->{'radius_factor'};
  }
  use constant _NumSeq_Coord_Radius_increasing => 1; # sqrt(i)
}
{ package Math::PlanePath::TheodorusSpiral;
  sub _NumSeq_Coord_RSquared_func {
    my ($seq, $i) = @_;
    ### TheodorusSpiral RSquared: $i
    # exact value RSquared==$i, so as not to lose precision through sqrts
    # and sums in the main n_to_xy()
    return $i;
  }
  use constant _NumSeq_Coord_Radius_increasing => 1; # sqrt(i)
}
{ package Math::PlanePath::ArchimedeanChords;
  use constant _NumSeq_Coord_Radius_increasing => 1; # spiralling outwards
}
{ package Math::PlanePath::MultipleRings;
  sub _NumSeq_Coord_X_increasing {
    my ($self) = @_;
    # step==0 trivial on X axis
    return ($self->{'step'} == 0 ? 1 : 0);
  }
  sub _NumSeq_Coord_Radius_increasing {
    my ($self) = @_;
    # step==0 trivial on X axis
    return ($self->{'step'} == 0 ? 1 : 0);
  }
  use constant _NumSeq_Coord_Radius_non_decreasing => 1;

  sub _NumSeq_Coord_RSquared_smaller {
    my ($self) = @_;
    ### MultipleRings characteristic_smaller(): $self->{'step'}

    # step==0 on X axis RSquared is i^2, bigger than i.
    # step=1 is 0,1,1,4,4,4,9,9,9,9,16,16,16,16,16 etc k+1 repeats of k^2,
    # bigger than i from i=5 onwards
    return ($self->{'step'} <= 1 ? 0 : 1);
  }
}
# { package Math::PlanePath::PixelRings;
# }
{ package Math::PlanePath::Hypot;
  # in order of radius, so monotonic
  use constant _NumSeq_Coord_Radius_non_decreasing => 1;
}
{ package Math::PlanePath::HypotOctant;
  # in order of radius, so monotonic
  use constant _NumSeq_Coord_Radius_non_decreasing => 1;
  use constant _NumSeq_Coord_DiffXY_min => 0; # octant Y<=X so X-Y>=0
}
{ package Math::PlanePath::PythagoreanTree;
  my %_NumSeq_Coord_X_min = (PQ => 2,
                             AB => 3,
                             BA => 4,
                            );
  my %_NumSeq_Coord_Y_min = (PQ => 1,
                             AB => 4,
                             BA => 3,
                            );
  my %_NumSeq_Coord_DiffXY_min = (PQ => 1);
  sub _NumSeq_Coord_X_min {
    my ($self) = @_;
    return $_NumSeq_Coord_X_min{$self->{'coordinates'}};
  }
  sub _NumSeq_Coord_Y_min {
    my ($self) = @_;
    return $_NumSeq_Coord_Y_min{$self->{'coordinates'}};
  }
  sub _NumSeq_Coord_DiffXY_min {
    my ($self) = @_;
    return $_NumSeq_Coord_DiffXY_min{$self->{'coordinates'}};
  }
  # Not quite right.
  # sub _NumSeq_Coord_pred_R {
  #   my ($path, $value) = @_;
  #   return ($value >= 0
  #           && ($path->{'coordinate_type'} ne 'AB'
  #               || $value == int($value)));
  # }
}
{ package Math::PlanePath::RationalsTree;
  use constant _NumSeq_Coord_X_min => 1;
  use constant _NumSeq_Coord_Y_min => 1;
}
{ package Math::PlanePath::FractionsTree;
  use constant _NumSeq_Coord_X_min => 1;
  use constant _NumSeq_Coord_Y_min => 2;
  use constant _NumSeq_Coord_DiffXY_max => 0; # upper octant X<=Y so X-Y<=0
}
# { package Math::PlanePath::PeanoCurve;
# }
# { package Math::PlanePath::HilbertCurve;
# }
# { package Math::PlanePath::HilbertSpiral;
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
  use constant _NumSeq_Coord_DiffXY_min => 0; # triangular Y<=X so X-Y>=0
}
{ package Math::PlanePath::QuadricIslands;
}
{ package Math::PlanePath::SierpinskiTriangle;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y
  use constant _NumSeq_Coord_DiffXY_max => 0; # triangular X<=Y so X-Y<=0
}
{ package Math::PlanePath::SierpinskiArrowhead;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y
  use constant _NumSeq_Coord_DiffXY_max => 0; # triangular X<=Y so X-Y<=0
}
{ package Math::PlanePath::SierpinskiArrowheadCentres;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y
  use constant _NumSeq_Coord_DiffXY_max => 0; # triangular X<=Y so X-Y<=0
}
{ package Math::PlanePath::SierpinskiCurve;
  use constant _NumSeq_Coord_DiffXY_min => 0; # octant Y<=X so X-Y>=0
}
{ package Math::PlanePath::HIndexing;
  use constant _NumSeq_Coord_DiffXY_max => 0; # upper octant X<=Y so X-Y<=0
}
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
  sub _NumSeq_Coord_X_max {
    my ($self) = @_;
    return $self->{'width'} - 1;
  }
}
{ package Math::PlanePath::Columns;
  sub _NumSeq_Coord_Y_max {
    my ($self) = @_;
    return $self->{'height'} - 1;
  }
}
# { package Math::PlanePath::Diagonals;
# }
# { package Math::PlanePath::Staircase;
# }
# { package Math::PlanePath::StaircaseAlternating;
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
  sub _NumSeq_Coord_DiffXY_max {
    my ($self) = @_;
    # for step==0   X=0 so X-Y <= 0
    # for step==1,2 X<=Y so X-Y <= 0
    return ($self->{'step'} <= 2
            ? 0
            : undef);
  }
}
# { package Math::PlanePath::PyramidSides;
# }
{ package Math::PlanePath::CellularRule;
  # ENHANCE-ME: more restrictive than this for many rules
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y so X+Y>=0
  use constant _NumSeq_Coord_DiffXY_max => 0; # triangular X<=Y so X-Y<=0
}
{ package Math::PlanePath::CellularRule::Line;
  sub _NumSeq_Coord_X_max {  # cf X_min from x_negative()
    my ($path) = @_;
    return ($path->{'sign'} <= 0 ? 0 : undef);
  }

  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y so X+Y>=0
  sub _NumSeq_Coord_Sum_max {
    my ($path) = @_;
    return ($path->{'sign'} == -1 ? 0 : undef);
  }

  sub _NumSeq_Coord_DiffXY_min {
    my ($path) = @_;
    return ($path->{'sign'} == 1 ? 0 : undef);
  }
  use constant _NumSeq_Coord_DiffXY_max => 0; # triangular X<=Y so X-Y<=0
}
{ package Math::PlanePath::CellularRule::OddSolid;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y so X+Y>=0
  use constant _NumSeq_Coord_DiffXY_max => 0; # triangular X<=Y so X-Y<=0
}
{ package Math::PlanePath::CellularRule::LeftSolid;
  use constant _NumSeq_Coord_X_max => 0; # X<=0
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y so X+Y>=0
  use constant _NumSeq_Coord_DiffXY_max => 0; # triangular X<=Y so X-Y<=0
}
{ package Math::PlanePath::CellularRule54;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y so X+Y>=0
  use constant _NumSeq_Coord_DiffXY_max => 0; # triangular X<=Y so X-Y<=0
}
{ package Math::PlanePath::CellularRule190;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y so X+Y>=0
  use constant _NumSeq_Coord_DiffXY_max => 0; # triangular X<=Y so X-Y<=0
}
{ package Math::PlanePath::UlamWarburton;
}
{ package Math::PlanePath::UlamWarburtonQuarter;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular Y>=-X so X+Y>=0
  use constant _NumSeq_Coord_DiffXY_min => 0; # triangular Y<=X so X-Y>=0
}
{ package Math::PlanePath::CoprimeColumns;
  use constant _NumSeq_Coord_X_min => 1;
  use constant _NumSeq_Coord_Y_min => 1;
  use constant _NumSeq_Coord_DiffXY_min => 0; # octant Y<=X so X-Y>=0
}
{ package Math::PlanePath::DiagonalRationals;
  use constant _NumSeq_Coord_X_min => 1;
  use constant _NumSeq_Coord_Y_min => 1;
}
{ package Math::PlanePath::FactorRationals;
  use constant _NumSeq_Coord_X_min => 1;
  use constant _NumSeq_Coord_Y_min => 1;
}
{ package Math::PlanePath::GcdRationals;
  use constant _NumSeq_Coord_X_min => 1;
  use constant _NumSeq_Coord_Y_min => 1;
}
{ package Math::PlanePath::DivisibleColumns;
  # X=2,Y=1 when proper
  # X=1,Y=1 when not
  use constant _NumSeq_Coord_Y_min => 1;
  sub _NumSeq_Coord_X_min {
    my ($self) = @_;
    return ($self->{'proper'} ? 2 : 1);
  }
  sub _NumSeq_Coord_DiffXY_min {
    my ($self) = @_;
    # octant Y<=X so X-Y>=0
    return ($self->{'proper'} ? 1 : 0);
  }
}
# { package Math::PlanePath::File;
#   # File                   points from a disk file
#   # FIXME: analyze points for min/max maybe
# }
# { package Math::PlanePath::QuintetCurve;
#   # inherit from QuintetCentres
# }
# { package Math::PlanePath::QuintetCentres;
# }
# { package Math::PlanePath::BetaOmega;
# }
# { package Math::PlanePath::AR2W2Curve;
# }
# { package Math::PlanePath::CornerReplicate;
# }
# { package Math::PlanePath::DigitGroups;
# }
# { package Math::PlanePath::FibonacciWordFractal;
# }


#------------------------------------------------------------------------------
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
#   my $coordinate_type = $self->{'coordinate_type'};
#   if ($coordinate_type eq 'X') {
#     if ($planepath_object->x_negative) {
#       return 1;
#     } else {
#       return ($value >= 0);
#     }
#   } elsif ($coordinate_type eq 'Y') {
#     if ($planepath_object->y_negative) {
#       return 1;
#     } else {
#       return ($value >= 0);
#     }
#   } elsif ($coordinate_type eq 'Sum') {
#     if ($planepath_object->x_negative || $planepath_object->y_negative) {
#       return 1;
#     } else {
#       return ($value >= 0);
#     }
#   } elsif ($coordinate_type eq 'RSquared') {
#     # FIXME: only sum of two squares, and for triangular same odd/even
#     return ($value >= 0);
#   }
#
#   return undef;
# }


=for stopwords Ryde PlanePath Math-NumSeq DiffXY OEIS PlanePath NumSeq SquareSpiral PlanePath

=head1 NAME

Math::NumSeq::PlanePathCoord -- sequence of coordinate values from a PlanePath module

=head1 SYNOPSIS

 use Math::NumSeq::PlanePathCoord;
 my $seq = Math::NumSeq::PlanePathCoord->new (planepath => 'SquareSpiral',
                                              coordinate_type => 'X');
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This is a tie-in to present coordinates from a C<Math::PlanePath> module as
a NumSeq sequence.  The NumSeq "i" index is the PlanePath "N" value.

The C<coordinate_type> choices are

    "X"          X coordinate
    "Y"          Y coordinate
    "Sum"        X+Y sum
    "Product"    X*Y product
    "DiffXY"     X-Y difference
    "DiffYX"     Y-X difference (negative of DiffXY)
    "AbsDiff"    abs(Y-X) difference
    "Radius"     sqrt(X^2+Y^2) radius
    "RSquared"   X^2+Y^2 radius squared

"Sum" can be interpreted geometrically as a projection onto the X=Y leading
diagonal, or equivalently as a measure of which anti-diagonal stripe
contains the X,Y.

    \
     2
    \ \
     1 2
    \ \ \
     0 1 2

"DiffXY" similarly, but a projection onto the X=-Y opposite diagonal, or a
measure of which leading diagonal stripe has the X,Y.

        / / / /
      -1 0 1 2
      / / / /
    -1 0 1 2
      / / /
     0 1 2

=head1 OEIS

Some path coordinates are in Sloane's Online Encyclopedia of Integer
Sequences.  See each PlanePath module for details.

C<$seq-E<gt>oeis_anum()> returns the A-number in the usual way, if there's
one known.  This includes things like A000004 all-zeros for cases where a
coordinate is simple or even trivial.

Known A-numbers are presented through C<Math::NumSeq::OEIS::Catalogue> so
path related sequences can be created with C<Math::NumSeq::OEIS> in the
usual way.  A-numbers specific to the paths are catalogued, plus a few of
the simpler things not otherwise covered by NumSeq modules yet (such as
A002262 successive 0 to k runs 0, 0,1, 0,1,2, 0,1,2,3, which arises in the
Diagonals).

=head1 FUNCTIONS

See L<Math::NumSeq/FUNCTIONS> for the behaviour common to all path classes.

=over 4

=item C<$seq = Math::NumSeq::PlanePathCoord-E<gt>new (planepath =E<gt> $name, coordinate_type =E<gt> 'X')>

Create and return a new sequence object.  The options are

    planepath          string, name of a PlanePath module
    planepath_object   PlanePath object
    coordinate_type    string, as described above

C<planepath> can be just the module part such as "SquareSpiral" or a full
class name "Math::PlanePath::SquareSpiral".

=item C<$value = $seq-E<gt>ith($i)>

Return the coordinate at N=$i in the PlanePath.

=item C<$i = $seq-E<gt>i_start()>

Return the first index C<$i> in the sequence.  This is the position
C<rewind()> returns to.

This is C<$path-E<gt>n_start()> from the PlanePath, since the i numbering is
the N numbering of the underlying path.  For some of the OEIS generated
sequences there may be a higher C<i_start()> corresponding to a higher
starting point in the OEIS, though this is slightly experimental.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::PlanePathDelta>,
L<Math::NumSeq::OEIS>

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

# Local variables:
# compile-command: "math-image --values=PlanePathCoord"
# End:
