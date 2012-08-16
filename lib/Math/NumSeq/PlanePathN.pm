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
use constant 1.02;

use vars '$VERSION','@ISA';
$VERSION = 86;
use Math::NumSeq;
@ISA = ('Math::NumSeq');

use Math::NumSeq::PlanePathCoord;

# uncomment this to run the ### lines
#use Smart::Comments;


sub description {
  my ($self) = @_;
  if (ref $self) {
    return "N values on $self->{'line_type'} of path $self->{'planepath'}";
  } else {
    # class method
    return 'N values from a PlanePath';
  }
}

use constant::defer parameter_info_array =>
  sub {
    return [
            Math::NumSeq::PlanePathCoord::_parameter_info_planepath(),
            
            { name    => 'line_type',
              display => 'Line Type',
              type    => 'enum',
              default => 'X_axis',
              choices => ['X_axis','Y_axis',
                          'X_neg','Y_neg',
                          'Diagonal',
                          'Diagonal_NW',
                          'Diagonal_SW',
                          'Diagonal_SE',
                         ],
              description => 'The axis or line to take path N values from.',
            },
           ];
  };

my %oeis_anum =
  (
   'Math::PlanePath::TriangleSpiralSkewed' =>
   { X_axis      => 'A117625',
     X_neg       => 'A006137',
     Y_neg       => 'A064225',
     Diagonal    => 'A081589',
     Diagonal_SW => 'A038764',
     Diagonal_SE => 'A081267',
     # OEIS-Catalogue: A117625 planepath=TriangleSpiralSkewed
     # OEIS-Catalogue: A006137 planepath=TriangleSpiralSkewed line_type=X_neg
     # OEIS-Catalogue: A064225 planepath=TriangleSpiralSkewed line_type=Y_neg
     # OEIS-Catalogue: A081589 planepath=TriangleSpiralSkewed line_type=Diagonal
     # OEIS-Catalogue: A038764 planepath=TriangleSpiralSkewed line_type=Diagonal_SW
     # OEIS-Catalogue: A081267 planepath=TriangleSpiralSkewed line_type=Diagonal_SE
     # duplicate,
     # OEIS-Catalogue: A081274 planepath=TriangleSpiralSkewed line_type=Diagonal_SW
     #
     # # Not quite, starts OFFSET=0 value=3 but that is at Y=1 here
     # Y_axis      => 'A064226', # and duplicate in A081269
   },
   'Math::PlanePath::TriangleSpiralSkewed,n_start=0' =>
   { X_axis      => 'A051682', # 11-gonals per Math::NumSeq::Polygonal
     Diagonal_SE => 'A062728', # 11-gonal "second" per Math::NumSeq::Polygonal
     Diagonal_SW => 'A081266',
     # OEIS-Other: A051682 planepath=TriangleSpiralSkewed,n_start=0 # X_axis
     # OEIS-Other: A062728 planepath=TriangleSpiralSkewed,n_start=0 line_type=Diagonal_SE
     # OEIS-Catalogue: A081266 planepath=TriangleSpiralSkewed,n_start=0 line_type=Diagonal_SW
   },
   
   'Math::PlanePath::TriangleSpiral' =>
   { X_axis      => 'A117625', # step by 2 each time
     Y_neg       => 'A006137', # step by 2 each time
     Diagonal_SW => 'A064225',
     Diagonal_SE => 'A081267',
     # OEIS-Other: A117625 planepath=TriangleSpiral line_type=X_axis
     # OEIS-Other: A064225 planepath=TriangleSpiral line_type=Diagonal_SW
     # OEIS-Other: A081267 planepath=TriangleSpiral line_type=Diagonal_SE
     
     # # Not quite, starts value=3 at n=0 which is Y=1
     # Diagonal => 'A064226', # and duplicate in A081269
   },
   'Math::PlanePath::TriangleSpiral,n_start=0' =>
   { Y_axis      => 'A062741', # 3*pentagonal, Y even
     Diagonal_SE => 'A062728', # 11-gonal "second" per Math::NumSeq::Polygonal
     # OEIS-Catalogue: A062741 planepath=TriangleSpiral,n_start=0 line_type=Y_axis
     # OEIS-Other: A062728 planepath=TriangleSpiral,n_start=0 line_type=Diagonal_SE
     
     # but spaced 2 apart ...
     # X_axis      => 'A051682', # 11-gonals per Math::NumSeq::Polygonal
     # # OEIS-Other: A051682 planepath=TriangleSpiral,n_start=0 # X_axis
   },
   
   'Math::PlanePath::Hypot,points=all,n_start=0' =>
   { X_axis => 'A051132', # count points < n^2
     # OEIS-Catalogue: A051132 planepath=Hypot,n_start=0
   },
   
   'Math::PlanePath::HypotOctant,points=even' =>
   { Diagonal => 'A036702',  # count points |z|<=n for 0<=b<=a
     # OEIS-Catalogue: A036702 planepath=HypotOctant,points=even line_type=Diagonal
   },
   
   'Math::PlanePath::PyramidSpiral' =>
   { X_axis      => 'A054552', # square spiral spoke E, 4n^2 - 3n + 1
     Diagonal_SE => 'A033951', # square spiral spoke S, 4n^2 + 3n + 1
     # OEIS-Other: A054552 planepath=PyramidSpiral
     # OEIS-Other: A033951 planepath=PyramidSpiral line_type=Diagonal_SE
   },
   
   'Math::PlanePath::PowerArray,radix=2' =>
   { X_axis   => 'A000079',  # powers 2^X
     Y_axis   => 'A005408',  # odd 2n+1
     # OEIS-Other: A000079 planepath=PowerArray
     # OEIS-Other: A005408 planepath=PowerArray line_type=Y_axis
   },
   'Math::PlanePath::PowerArray,radix=3' =>
   { X_axis   => 'A000244',  # powers 3^X
     # OEIS-Other: A000244 planepath=PowerArray,radix=3
     #
     # Not quite, OFFSET=1 cf start Y=0 here
     # Y_axis => 'A001651', # non multiples of 3
   },
   'Math::PlanePath::PowerArray,radix=4' =>
   { X_axis   => 'A000302',  # powers 4^X
     # OEIS-Other: A000302 planepath=PowerArray,radix=4
   },
   'Math::PlanePath::PowerArray,radix=5' =>
   { X_axis   => 'A000351',  # powers 5^X
     # OEIS-Other: A000351 planepath=PowerArray,radix=5
   },
   'Math::PlanePath::PowerArray,radix=10' =>
   { X_axis   => 'A011557',  # powers 10^X
     # OEIS-Other: A011557 planepath=PowerArray,radix=10
   },
   
   'Math::PlanePath::Corner,wider=0' =>
   { Y_axis   => 'A002522',  # n^2+1
     # OEIS-Other: A002522 planepath=Corner line_type=Y_axis
   },
   'Math::PlanePath::Corner,wider=0,n_start=0' =>
   { X_axis   => 'A005563',  # (n+1)^2-1
     Y_axis   => 'A000290',  # squares
     Diagonal => 'A002378',  # pronic
     # OEIS-Other: A005563 planepath=Corner,n_start=0 line_type=X_axis
     # OEIS-Other: A000290 planepath=Corner,n_start=0 line_type=Y_axis
     # OEIS-Other: A002378 planepath=Corner,n_start=0 line_type=Diagonal
   },   
   'Math::PlanePath::Corner,wider=1,n_start=0' =>
   { Y_axis   => 'A002378',  # pronic
     Diagonal => 'A005563',  # (n+1)^2-1
     # OEIS-Other: A002378 planepath=Corner,wider=1,n_start=0 line_type=Y_axis
     # OEIS-Other: A005563 planepath=Corner,wider=1,n_start=0 line_type=Diagonal
   },   
   'Math::PlanePath::Corner,wider=2,n_start=0' =>
   { Y_axis   => 'A005563',  # (n+1)^2-1
     # OEIS-Other: A005563 planepath=Corner,wider=2,n_start=0 line_type=Y_axis
   },   

   # PyramidRows step=1
   do {
     my $href =
       { Y_axis   => 'A000124',  # triangular+1 = n*(n+1)/2+1
       };
     ('Math::PlanePath::PyramidRows,step=1,align=centre' => $href,
      'Math::PlanePath::PyramidRows,step=1,align=right'  => $href);

     # OEIS-Other: A000124 planepath=PyramidRows,step=1 line_type=Y_axis
     # OEIS-Other: A000124 planepath=PyramidRows,step=1,align=right line_type=Y_axis
   },
   'Math::PlanePath::PyramidRows,step=1,align=left' =>
   { Diagonal_NW => 'A000124',  # triangular+1 = n*(n+1)/2+1
     # OEIS-Other: A000124 planepath=PyramidRows,step=1,align=left line_type=Diagonal_NW
   },
   do {
     my $href =
       { Y_axis   => 'A000217',  # triangular
       };
     ('Math::PlanePath::PyramidRows,step=1,align=centre,n_start=0' => $href,
      'Math::PlanePath::PyramidRows,step=1,align=right,n_start=0'  => $href);

     # OEIS-Other: A000217 planepath=PyramidRows,step=1,n_start=0 line_type=Y_axis
     # OEIS-Other: A000217 planepath=PyramidRows,step=1,align=right,n_start=0 line_type=Y_axis
   },

   'Math::PlanePath::PyramidRows,step=2,align=centre' =>
   { Diagonal_NW => 'A002522',  # n^2+1
     # OEIS-Other: A002522 planepath=PyramidRows,step=2 line_type=Diagonal_NW
   },
   'Math::PlanePath::PyramidRows,step=2,align=centre,n_start=0' =>
   { Y_axis      => 'A002378', # pronic
     Diagonal    => 'A005563',
     Diagonal_NW => 'A000290', # squares
     # OEIS-Other: A002378 planepath=PyramidRows,step=2,n_start=0 line_type=Y_axis
     # OEIS-Other: A005563 planepath=PyramidRows,step=2,n_start=0 line_type=Diagonal
     # OEIS-Other: A000290 planepath=PyramidRows,step=2,n_start=0 line_type=Diagonal_NW
   },
   'Math::PlanePath::PyramidRows,step=2,align=right,n_start=0' =>
   { Y_axis   => 'A000290', # squares
     Diagonal => 'A002378', # pronic
     # OEIS-Other: A000290 planepath=PyramidRows,step=2,align=right,n_start=0 line_type=Y_axis
     # OEIS-Other: A002378 planepath=PyramidRows,step=2,align=right,n_start=0 line_type=Diagonal
   },
   'Math::PlanePath::PyramidRows,step=2,align=left,n_start=0' =>
   { Y_axis      => 'A005563',
     Diagonal_NW => 'A002378', # pronic
     # OEIS-Other: A005563 planepath=PyramidRows,step=2,align=left,n_start=0 line_type=Y_axis
     # OEIS-Other: A002378 planepath=PyramidRows,step=2,align=left,n_start=0 line_type=Diagonal_NW
   },
   'Math::PlanePath::PyramidRows,step=2,align=centre,n_start=2' =>
   { Diagonal_NW => 'A059100', # n^2+2
     # OEIS-Catalogue: A059100 planepath=PyramidRows,step=2,n_start=2 line_type=Diagonal_NW
   },
   'Math::PlanePath::PyramidRows,step=2,align=right,n_start=2' =>
   { Y_axis => 'A059100', # n^2+2
     # OEIS-Other: A059100 planepath=PyramidRows,step=2,align=right,n_start=2 line_type=Y_axis
   },

   'Math::PlanePath::PyramidRows,step=3,align=centre' =>
   { Y_axis      => 'A104249',
     Diagonal_NW => 'A143689',
     # OEIS-Catalogue: A104249 planepath=PyramidRows,step=3 line_type=Y_axis
     # OEIS-Catalogue: A143689 planepath=PyramidRows,step=3 line_type=Diagonal_NW
     # Not quite OFFSET=1 cf start i=0 here
     # Diagonal    => 'A005448',
     # # OEIS-Catalogue: A005448 planepath=PyramidRows,step=3 line_type=Diagonal
   },
   'Math::PlanePath::PyramidRows,step=3,align=right' =>
   { Y_axis   => 'A143689',
     Diagonal => 'A104249',
     # OEIS-Other: A143689 planepath=PyramidRows,step=3,align=right line_type=Y_axis
     # OEIS-Other: A104249 planepath=PyramidRows,step=3,align=right line_type=Diagonal
     
     # Not quite OFFSET=1 cf start i=0 here
     # Diagonal    => 'A005448',
     # # OEIS-Catalogue: A005448 planepath=PyramidRows,step=3 line_type=Diagonal
   },
   'Math::PlanePath::PyramidRows,step=3,align=centre,n_start=0' =>
   { Y_axis      => 'A005449', # second pentagonal n*(3n+1)/2
     Diagonal_NW => 'A000326', # pentagonal n(3n-1)/2
     # OEIS-Other: A005449 planepath=PyramidRows,step=3,n_start=0 line_type=Y_axis
     # OEIS-Other: A000326 planepath=PyramidRows,step=3,n_start=0 line_type=Diagonal_NW
   },
   'Math::PlanePath::PyramidRows,step=3,align=right,n_start=0' =>
   { Y_axis   => 'A000326', # pentagonal n(3n-1)/2
     Diagonal => 'A005449', # second pentagonal n*(3n+1)/2
     # OEIS-Other: A000326 planepath=PyramidRows,step=3,align=right,n_start=0 line_type=Y_axis
     # OEIS-Other: A005449 planepath=PyramidRows,step=3,align=right,n_start=0 line_type=Diagonal
   },

   'Math::PlanePath::PyramidRows,step=4,align=centre' =>
   { Y_axis      => 'A084849',
     Diagonal    => 'A001844',
     Diagonal_NW => 'A058331',
     # OEIS-Catalogue: A084849 planepath=PyramidRows,step=4 line_type=Y_axis
     # OEIS-Other: A001844 planepath=PyramidRows,step=4 line_type=Diagonal
     # OEIS-Other: A058331 planepath=PyramidRows,step=4 line_type=Diagonal_NW
   },
   'Math::PlanePath::PyramidRows,step=4,align=right' =>
   { Diagonal => 'A058331',
     # OEIS-Other: A058331 planepath=PyramidRows,step=4,align=right line_type=Diagonal
   },
   'Math::PlanePath::PyramidRows,step=4,align=left' =>
   { Diagonal_NW => 'A001844',
     # OEIS-Other: A001844 planepath=PyramidRows,step=4,align=left line_type=Diagonal_NW
   },
   'Math::PlanePath::PyramidRows,step=4,align=centre,n_start=0' =>
   { Y_axis      => 'A014105', # second hexagonal
     Diagonal    => 'A046092', # 4*triangular
     Diagonal_NW => 'A001105',
     # OEIS-Other:     A014105 planepath=PyramidRows,step=4,n_start=0 line_type=Y_axis
     # OEIS-Catalogue: A046092 planepath=PyramidRows,step=4,n_start=0 line_type=Diagonal
     # OEIS-Other:     A001105 planepath=PyramidRows,step=4,n_start=0 line_type=Diagonal_NW
   },
   'Math::PlanePath::PyramidRows,step=4,align=right,n_start=0' =>
   { Diagonal => 'A001105',
     # OEIS-Other: A001105 planepath=PyramidRows,step=4,align=right,n_start=0 line_type=Diagonal
   },
   'Math::PlanePath::PyramidRows,step=4,align=left,n_start=0' =>
   { Diagonal_NW => 'A046092', # 4*triangular
     # OEIS-Other: A046092 planepath=PyramidRows,step=4,align=left,n_start=0 line_type=Diagonal_NW
   },

   # TODO PyramidRows,step=5 n_start=0

   'Math::PlanePath::PyramidRows,step=5,align=centre' =>
   { Y_axis      => 'A116668',
     # OEIS-Other: A116668 planepath=PyramidRows,step=5 line_type=Y_axis
   },
   'Math::PlanePath::PyramidRows,step=6,align=centre' =>
   { Diagonal_NW => 'A056107',
     Y_axis      => 'A056108',
     Diagonal    => 'A056109',
     # OEIS-Other: A056107 planepath=PyramidRows,step=6 line_type=Diagonal_NW
     # OEIS-Other: A056108 planepath=PyramidRows,step=6 line_type=Y_axis
     # OEIS-Other: A056109 planepath=PyramidRows,step=6 line_type=Diagonal
   },
   'Math::PlanePath::PyramidRows,step=8,align=centre' =>
   { Diagonal_NW => 'A053755',
     # OEIS-Other: A053755 planepath=PyramidRows,step=8 line_type=Diagonal_NW
   },
   'Math::PlanePath::PyramidRows,step=9,align=centre' =>
   { Y_axis   => 'A006137',
     Diagonal => 'A038764',
     # OEIS-Other: A006137 planepath=PyramidRows,step=9 line_type=Y_axis
     # OEIS-Other: A038764 planepath=PyramidRows,step=9 line_type=Diagonal
   },
   
   'Math::PlanePath::PyramidSides' =>
   { X_neg    => 'A002522',
     Diagonal => 'A033951',
     # OEIS-Catalogue: A002522 planepath=PyramidSides line_type=X_neg
     # OEIS-Other:     A033951 planepath=PyramidSides line_type=Diagonal
     #
     # X_axis -- squares (x+1)^2, but starting i=0 value=1
   },
   
   # Diagonals X_axis -- triangular 1,3,6,etc, but starting i=0 value=1
   'Math::PlanePath::Diagonals,direction=down' =>
   { Y_axis   => 'A000124',  # triangular+1 = n*(n+1)/2+1
     Diagonal => 'A001844',  # centred squares 2n(n+1)+1
     # OEIS-Catalogue: A000124 planepath=Diagonals line_type=Y_axis
     # OEIS-Catalogue: A001844 planepath=Diagonals line_type=Diagonal
   },
   'Math::PlanePath::Diagonals,direction=up' =>
   { X_axis   => 'A000124',  # triangular+1 = n*(n+1)/2+1
     Diagonal => 'A001844',  # centred squares 2n(n+1)+1
     # OEIS-Other: A000124 planepath=Diagonals,direction=up line_type=X_axis
     # OEIS-Other: A001844 planepath=Diagonals,direction=up line_type=Diagonal
   },
   
   'Math::PlanePath::DiagonalsAlternating' =>
   { Diagonal => 'A001844',  # centred squares 2n(n+1)+1
     # OEIS-Other: A001844 planepath=DiagonalsAlternating line_type=Diagonal
     
     # Not quite, extra initial 1 or 0
     # X_axis => 'A128918',
     # Y_axis => 'A131179',
   },
   'Math::PlanePath::DiagonalsAlternating,n_start=0' =>
   { Diagonal => 'A046092',  # 2*triangular
     # OEIS-Other: A046092 planepath=DiagonalsAlternating,n_start=0 line_type=Diagonal
   },

   'Math::PlanePath::DiagonalsOctant,direction=down,n_start=0' =>
   { Diagonal => 'A005563', # n*(n+2)  0,3,8,15,24
     # OEIS-Other: A005563 planepath=DiagonalsOctant,n_start=0 line_type=Diagonal
   },
   'Math::PlanePath::DiagonalsOctant,direction=up,n_start=0' =>
   { Diagonal => 'A002378', # pronic n*(n+1)
     # OEIS-Other: A002378 planepath=DiagonalsOctant,direction=up,n_start=0 line_type=Diagonal
   },
   # 'Math::PlanePath::DiagonalsOctant,direction=down' =>
   # {
   # Not quite, starting i=0 for square=1 cf A000290 starts 0
   # # Diagonal => 'A000290', # squares
   #
   # Not quite, A033638 extra initial 1
   # # Diagonal => 'A033638', # quarter squares + 1
   # }
   # 'Math::PlanePath::DiagonalsOctant,direction=up,n_start=0' =>
   # {
   # # Not quite, extra initial 0
   # # Y_axis => 'A002620', # quarter squares
   #
   # # Not quite, A002061 extra initial 1
   # # Diagonal => 'A002061', # central polygonal n^2-n+1
   # }
   

   'Math::PlanePath::SierpinskiTriangle,align=triangular' =>
   { Diagonal_NW => 'A006046',
     # OEIS-Other: A006046 planepath=SierpinskiTriangle line_type=Diagonal_NW
     #
     # Not quite, starts OFFSET=1 value=2,4,8,10 so missing N=0 at Y=0
     # Diagonal => 'A074330', # Nright
   },
   'Math::PlanePath::SierpinskiTriangle,align=right' =>
   { Y_axis => 'A006046',
     # OEIS-Catalogue: A006046 planepath=SierpinskiTriangle,align=diagonal line_type=Y_axis
   },
   'Math::PlanePath::SierpinskiTriangle,align=left' =>
   { Diagonal_NW => 'A006046',
     # OEIS-Other: A006046 planepath=SierpinskiTriangle,align=left line_type=Diagonal_NW
   },
   'Math::PlanePath::SierpinskiTriangle,align=diagonal' =>
   { Y_axis => 'A006046',
     # OEIS-Other: A006046 planepath=SierpinskiTriangle,align=diagonal line_type=Y_axis
   },
   
   'Math::PlanePath::WythoffArray' =>
   {
    # but OFFSET=1 vs here start X=0
    # X_axis   => 'A000045', # Fibonaccis, but skip initial 0,1
    # Diagonal => 'A020941', # diagonal
    
    # but OFFSET=1 vs here start Y=0
    # Y_axis   => 'A003622', # spectrum of phi
    # # OEIS-Catalogue: A003622 planepath=WythoffArray line_type=Y_axis
   },
   
   # PeanoCurve
   do {
     my $href =
       { X_axis   => 'A163480', # axis same as initial direction
         Y_axis   => 'A163481', # axis opp to initial direction
         Diagonal => 'A163343',
       };
     ('Math::PlanePath::PeanoCurve,radix=3' => $href,
      'Math::PlanePath::GrayCode,apply_type=TsF,gray_type=reflected,radix=3' => $href,
      'Math::PlanePath::GrayCode,apply_type=FsT,gray_type=reflected,radix=3' => $href,
     );
     # OEIS-Catalogue: A163480 planepath=PeanoCurve
     # OEIS-Catalogue: A163481 planepath=PeanoCurve line_type=Y_axis
     # OEIS-Catalogue: A163343 planepath=PeanoCurve line_type=Diagonal

     # OEIS-Other: A163480 planepath=GrayCode,apply_type=TsF,radix=3
     # OEIS-Other: A163481 planepath=GrayCode,apply_type=TsF,radix=3 line_type=Y_axis
     # OEIS-Other: A163343 planepath=GrayCode,apply_type=TsF,radix=3 line_type=Diagonal

     # OEIS-Other: A163480 planepath=GrayCode,apply_type=FsT,radix=3
     # OEIS-Other: A163481 planepath=GrayCode,apply_type=FsT,radix=3 line_type=Y_axis
     # OEIS-Other: A163343 planepath=GrayCode,apply_type=FsT,radix=3 line_type=Diagonal
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
     Diagonal => 'A001196',  # base 4 digits 0,3 only
     # OEIS-Catalogue: A000695 planepath=ZOrderCurve
     # OEIS-Catalogue: A062880 planepath=ZOrderCurve line_type=Y_axis
     # OEIS-Catalogue: A001196 planepath=ZOrderCurve line_type=Diagonal
   },
   'Math::PlanePath::ZOrderCurve,radix=3' =>
   { X_axis => 'A037314',  # base 9 digits 0,1,2 only
     # OEIS-Catalogue: A037314 planepath=ZOrderCurve,radix=3 i_start=1
     # A037314 starts OFFSET=1 value=1, thus istart=1 here
   },
   'Math::PlanePath::ZOrderCurve,radix=10' =>
   { X_axis => 'A051022',  # base 10 insert 0s, for digits 0 to 9 base 100
     # OEIS-Catalogue: A051022 planepath=ZOrderCurve,radix=10
   },
   
   'Math::PlanePath::CornerReplicate' =>
   { X_axis   => 'A000695',  # base 4 digits 0,1 only
     Y_axis   => 'A001196',  # base 4 digits 0,3 only
     Diagonal => 'A062880',  # base 4 digits 0,2 only
     # OEIS-Other: A000695 planepath=CornerReplicate
     # OEIS-Other: A001196 planepath=CornerReplicate line_type=Y_axis
     # OEIS-Other: A062880 planepath=CornerReplicate line_type=Diagonal
   },

   # GrayCode radix=2 TsF==Fs reflected==modular
   do {
     my $href =
       { Y_axis => 'A001196',  # base 4 digits 0,3 only
       };
     ('Math::PlanePath::GrayCode,apply_type=TsF,gray_type=reflected,radix=2' => $href,
      'Math::PlanePath::GrayCode,apply_type=Fs,gray_type=reflected,radix=2' => $href,
      'Math::PlanePath::GrayCode,apply_type=TsF,gray_type=modular,radix=2' => $href,
      'Math::PlanePath::GrayCode,apply_type=Fs,gray_type=modular,radix=2' => $href,
     );
     # OEIS-Other: A001196 planepath=GrayCode,apply_type=TsF line_type=Y_axis
     # OEIS-Other: A001196 planepath=GrayCode,apply_type=Fs line_type=Y_axis
     # OEIS-Other: A001196 planepath=GrayCode,apply_type=TsF,gray_type=modular line_type=Y_axis
     # OEIS-Other: A001196 planepath=GrayCode,apply_type=Fs,gray_type=modular line_type=Y_axis
   },
   # GrayCode radix=2 Ts==FsT reflected==modular
   do {
     my $href =
       { Diagonal => 'A062880',  # base 4 digits 0,2 only
       };
     ('Math::PlanePath::GrayCode,apply_type=Ts,gray_type=reflected,radix=2' => $href,
      'Math::PlanePath::GrayCode,apply_type=Ts,gray_type=modular,radix=2' => $href,
      'Math::PlanePath::GrayCode,apply_type=FsT,gray_type=reflected,radix=2' => $href,
      'Math::PlanePath::GrayCode,apply_type=FsT,gray_type=modular,radix=2' => $href,
     );
     # OEIS-Other: A062880 planepath=GrayCode,apply_type=Ts line_type=Diagonal
     # OEIS-Other: A062880 planepath=GrayCode,apply_type=Ts,gray_type=modular line_type=Diagonal
     # OEIS-Other: A062880 planepath=GrayCode,apply_type=FsT line_type=Diagonal
     # OEIS-Other: A062880 planepath=GrayCode,apply_type=FsT,gray_type=modular line_type=Diagonal
   },

   # GrayCode radix=3 sT==sF reflected
   # N split then toGray giving Y=0 means N ternary 010202 etc
   # N split then toGray giving X=Y means N ternary pairs 112200
   do {
     my $href =
       { X_axis   => 'A163344',  # central Peano/4, base9 digits 0,1,2 only
         Diagonal => 'A163343',  # central diagonal of Peano, base9 0,4,8
       };
     ('Math::PlanePath::GrayCode,apply_type=sT,gray_type=reflected,radix=3' => $href,
      'Math::PlanePath::GrayCode,apply_type=sF,gray_type=reflected,radix=3' => $href,
     );
     # OEIS-Catalogue: A163344 planepath=GrayCode,apply_type=sT,radix=3 line_type=X_axis
     # OEIS-Other:     A163344 planepath=GrayCode,apply_type=sF,radix=3 line_type=X_axis

     # OEIS-Other: A163343 planepath=GrayCode,apply_type=sT,radix=3 line_type=Diagonal
     # OEIS-Other: A163343 planepath=GrayCode,apply_type=sF,radix=3 line_type=Diagonal
   },
   
   'Math::PlanePath::LTiling,L_fill=middle' =>
   { Diagonal => 'A062880',  # base 4 digits 0,2 only
     # OEIS-Other: A062880 planepath=LTiling line_type=Diagonal
   },
   
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
     Y_neg  => 'A001844', # centred squares 2n(n+1)+1
     # OEIS-Catalogue: A130883 planepath=DiamondSpiral
     # OEIS-Catalogue: A058331 planepath=DiamondSpiral line_type=Y_axis
     # OEIS-Other: A001844 planepath=DiamondSpiral line_type=Y_neg
   },
   
   # Not quite, starts at OFFSET=1
   # 'Math::PlanePath::DigitGroups,radix=2' =>
   # { X_axis => 'A084471', # 0 -> 00 in binary
   #   # OEIS-Catalogue: A084471 planepath=DigitGroups,radix=2
   # },

   'Math::PlanePath::FactorRationals' =>
   { Y_axis => 'A102631', # n^2/(squarefree kernel)
     # OEIS-Catalogue: A102631 planepath=FactorRationals line_type=Y_axis

     # # Not quite, OFFSET=0 value 0 whereas start i=1 value 1 here
     # X_axis => 'A000290',
     # # OEIS-Other: A000290 planepath=FactorRationals line_type=X_axis
   },

   'Math::PlanePath::HexSpiral,wider=0' =>
   { X_axis      => 'A056105', # first spoke 3n^2-2n+1
     Diagonal    => 'A056106', # second spoke 3n^2-n+1
     Diagonal_NW => 'A056107', # third spoke 3n^2+1
     X_neg       => 'A056108', # fourth spoke 3n^2+n+1
     Diagonal_SW => 'A056109', # fifth spoke 3n^2+2n+1
     Diagonal_SE => 'A003215', # centred hexagonal numbers
     # OEIS-Other: A056105 planepath=HexSpiral
     # OEIS-Other: A056106 planepath=HexSpiral line_type=Diagonal
     # OEIS-Other: A056107 planepath=HexSpiral line_type=Diagonal_NW
     # OEIS-Other: A056108 planepath=HexSpiral line_type=X_neg
     # OEIS-Other: A056109 planepath=HexSpiral line_type=Diagonal_SW
     # OEIS-Other: A003215 planepath=HexSpiral line_type=Diagonal_SE
   },

   'Math::PlanePath::HexSpiralSkewed,wider=0' =>
   { X_axis      => 'A056105', # first spoke 3n^2-2n+1
     Y_axis      => 'A056106', # second spoke 3n^2-n+1
     Diagonal_NW => 'A056107', # third spoke 3n^2+1
     X_neg       => 'A056108', # fourth spoke 3n^2+n+1
     Y_neg       => 'A056109', # fifth spoke 3n^2+2n+1
     Diagonal_SE => 'A003215', # centred hexagonal numbers
     # OEIS-Catalogue: A056105 planepath=HexSpiralSkewed
     # OEIS-Catalogue: A056106 planepath=HexSpiralSkewed line_type=Y_axis
     # OEIS-Catalogue: A056107 planepath=HexSpiralSkewed line_type=Diagonal_NW
     # OEIS-Catalogue: A056108 planepath=HexSpiralSkewed line_type=X_neg
     # OEIS-Catalogue: A056109 planepath=HexSpiralSkewed line_type=Y_neg
     # OEIS-Catalogue: A003215 planepath=HexSpiralSkewed line_type=Diagonal_SE
   },
   # wider=1 X_axis almost 3*n^2 but not initial X=0 value
   # wider=1 Y_axis almost A049451 twice pentagonal but not initial X=0
   # wider=2 Y_axis almost A028896 6*triangular but not initial Y=0

   # 'Math::PlanePath::HeptSpiralSkewed,wider=0' =>
   # {
   #  # Not quite, OFFSET=1
   #  # Y_axis => 'A140065', # (7n^2 - 17n + 12)/2 but starting Y=0 not n=1
   #  # Diagonal_NW => 'A140063',
   #  # Diagonal_SE => 'A069099',
   # },

   'Math::PlanePath::PentSpiral' =>
   { X_axis   => 'A192136', # (5*n^2-3*n+2)/2
     X_neg    => 'A116668', # (5n^2 + n + 2)/2
     Diagonal_SE => 'A005891', # centred pentagonal (5n^2+5n+2)/2
     # OEIS-Other: A192136 planepath=PentSpiral
     # OEIS-Other: A116668 planepath=PentSpiral line_type=X_neg
     # OEIS-Other: A005891 planepath=PentSpiralSkewed line_type=Diagonal_SE
   },
   'Math::PlanePath::PentSpiralSkewed' =>
   { X_axis   => 'A192136', # (5*n^2-3*n+2)/2
     X_neg    => 'A116668', # (5n^2 + n + 2)/2
     Diagonal_NW => 'A158187', # 10*n^2 + 1
     Diagonal_SE => 'A005891', # centred pentagonal (5n^2+5n+2)/2
     # OEIS-Catalogue: A192136 planepath=PentSpiralSkewed
     # OEIS-Catalogue: A116668 planepath=PentSpiralSkewed line_type=X_neg
     # OEIS-Catalogue: A158187 planepath=PentSpiralSkewed line_type=Diagonal_NW
     # OEIS-Catalogue: A005891 planepath=PentSpiralSkewed line_type=Diagonal_SE

     # Not quite, OFFSET=1
     # Y_axis => 'A140066', # (5n^2-11n+8)/2 but from Y=0 so using (n-1)
     # Y_neg  => 'A134238',
   },

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

   do {
     my $squarespiral
       = { X_axis      => 'A054552', # spoke E, 4n^2 - 3n + 1
           Y_neg       => 'A033951', # spoke S, 4n^2 + 3n + 1
           Diagonal_NW => 'A053755', # 4n^2 + 1
           Diagonal_SE => 'A016754', # (2n+1)^2
           # OEIS-Catalogue: A054552 planepath=SquareSpiral
           # OEIS-Catalogue: A033951 planepath=SquareSpiral line_type=Y_neg
           # OEIS-Catalogue: A053755 planepath=SquareSpiral line_type=Diagonal_NW
           # OEIS-Catalogue: A016754 planepath=SquareSpiral line_type=Diagonal_SE
           #
           # OEIS-Other: A054552 planepath=GreekKeySpiral,turns=0
           # OEIS-Other: A033951 planepath=GreekKeySpiral,turns=0 line_type=Y_neg
           # OEIS-Other: A053755 planepath=GreekKeySpiral,turns=0 line_type=Diagonal_NW
           # OEIS-Other: A016754 planepath=GreekKeySpiral,turns=0 line_type=Diagonal_SE

           # but these have OFFSET=1 whereas based from X=0 here
           # # Y_axis   => 'A054556', # spoke N
           # # X_neg   => 'A054567', # spoke W
           # # Diagonal => 'A054554', # spoke NE
           # # Diagonal_SW => 'A054569', # spoke NE
           # # # OEIS-Catalogue: A054556 planepath=SquareSpiral line_type=Y_axis
           # # # OEIS-Catalogue: A054554 planepath=SquareSpiral line_type=Diagonal
         };
     ('Math::PlanePath::SquareSpiral,wider=0'   => $squarespiral,
      'Math::PlanePath::GreekKeySpiral,turns=0' => $squarespiral,
     );
   },
   do {
     my $squarespiral
       = { X_axis      => 'A001107',
           Y_axis      => 'A033991',
           Y_neg       => 'A033954', # second 10-gonals
           Diagonal    => 'A002939',
           Diagonal_NW => 'A016742', # 10-gonals average, 4*n^2
           Diagonal_SW => 'A002943',
           # OEIS-Other: A001107 planepath=SquareSpiral,n_start=0 line_type=X_axis
           # OEIS-Catalogue: A033991 planepath=SquareSpiral,n_start=0 line_type=Y_axis
           # OEIS-Other: A033954 planepath=SquareSpiral,n_start=0 line_type=Y_neg
           # OEIS-Catalogue: A002939 planepath=SquareSpiral,n_start=0 line_type=Diagonal
           # OEIS-Other: A016742 planepath=SquareSpiral,n_start=0 line_type=Diagonal_NW
           # OEIS-Catalogue: A002943 planepath=SquareSpiral,n_start=0 line_type=Diagonal_SW
         };
     ('Math::PlanePath::SquareSpiral,wider=0,n_start=0' => $squarespiral,
     ) },

   'Math::PlanePath::SquareSpiral,wider=1' =>
   { Diagonal_SW => 'A069894',
     # OEIS-Catalogue: A069894 planepath=SquareSpiral,wider=1 line_type=Diagonal_SW
   },
   'Math::PlanePath::SquareSpiral,wider=1,n_start=0' =>
   { Diagonal_SW => 'A016754', # odd squares
     # OEIS-Other: A016754 planepath=SquareSpiral,wider=1,n_start=0 line_type=Diagonal_SW
   },

   'Math::PlanePath::AnvilSpiral,wider=0' =>
   { X_axis   => 'A033570', # odd pentagonals (2n+1)*(3n+1)
     Y_axis => 'A126587', # points within 3,4,5 triangle, starting value=3
     Diagonal => 'A033568', # odd second pentagonals
     # OEIS-Catalogue: A033570 planepath=AnvilSpiral
     # OEIS-Catalogue: A126587 planepath=AnvilSpiral line_type=Y_axis i_start=1
     # OEIS-Catalogue: A033568 planepath=AnvilSpiral line_type=Diagonal
   },
   # 'Math::PlanePath::AnvilSpiral,wider=2' =>
   # {
   #   Not quite, A033581 initial value=2 whereas path N=0
   #   #   Y_axis => 'A033581', # 6*n^2 is 14-gonals pairs average in Math::NumSeq::Polygonal
   #   #   # OEIS-Other: A033581 planepath=AnvilSpiral,wider=2 line_type=Y_axis
   # },

   'Math::PlanePath::AlternatePaper,arms=1' =>
   { X_axis   => 'A000695',  # base 4 digits 0,1 only
     Diagonal => 'A062880',  # base 4 digits 0,2 only
     # OEIS-Other: A000695 planepath=AlternatePaper
     # OEIS-Other: A062880 planepath=AlternatePaper line_type=Diagonal
   },

   'Math::PlanePath::Columns,height=2' =>
   { X_axis   => 'A005408',  # odd 2n+1
     # OEIS-Other: A005408 planepath=Columns,height=2 line_type=X_axis
   },
   'Math::PlanePath::Rows,width=2' =>
   { Y_axis   => 'A005408',  # odd 2n+1
     # OEIS-Other: A005408 planepath=Rows,width=2 line_type=Y_axis
   },

   'Math::PlanePath::Columns,height=3' =>
   { X_axis   => 'A016777',  # 3n+1
     # OEIS-Other: A016777 planepath=Columns,height=3 line_type=X_axis
   },
   'Math::PlanePath::Rows,width=3' =>
   { Y_axis   => 'A016777',  # 3n+1
     # OEIS-Catalogue: A016777 planepath=Rows,width=3 line_type=Y_axis
   },

   'Math::PlanePath::Columns,height=4' =>
   { X_axis   => 'A016813',  # 4n+1
     # OEIS-Other: A016813 planepath=Columns,height=4 line_type=X_axis
   },
   'Math::PlanePath::Rows,width=4' =>
   { Y_axis   => 'A016813',  # 4n+1
     # OEIS-Catalogue: A016813 planepath=Rows,width=4 line_type=Y_axis
   },

   'Math::PlanePath::Columns,height=5' =>
   { X_axis   => 'A016861',  # 5n+1
     # OEIS-Other: A016861 planepath=Columns,height=5 line_type=X_axis
   },
   'Math::PlanePath::Rows,width=5' =>
   { Y_axis   => 'A016861',  # 5n+1
     # OEIS-Catalogue: A016861 planepath=Rows,width=5 line_type=Y_axis
   },

   'Math::PlanePath::Columns,height=6' =>
   { X_axis   => 'A016921',  # 6n+1
     # OEIS-Other: A016921 planepath=Columns,height=6 line_type=X_axis
   },
   'Math::PlanePath::Rows,width=6' =>
   { Y_axis   => 'A016921',  # 6n+1
     # OEIS-Catalogue: A016921 planepath=Rows,width=6 line_type=Y_axis
   },

   'Math::PlanePath::Columns,height=7' =>
   { X_axis   => 'A016993',  # 7n+1
     # OEIS-Other: A016993 planepath=Columns,height=7 line_type=X_axis
   },
   'Math::PlanePath::Rows,width=7' =>
   { Y_axis   => 'A016993',  # 7n+1
     # OEIS-Catalogue: A016993 planepath=Rows,width=7 line_type=Y_axis
   },


   'Math::PlanePath::CellularRule,rule=5' =>
   { Y_axis   => 'A061925',  # ceil(n^2/2)+1
     # OEIS-Catalogue: A061925 planepath=CellularRule,rule=5 line_type=Y_axis
   },
   #
   # rule 84,116,212,244 two-wide right line
   do {
     my $tworight
       = { Diagonal   => 'A005408',  # odds 2n+1
         };
     ('Math::PlanePath::CellularRule,rule=84' => $tworight,
      'Math::PlanePath::CellularRule,rule=116' => $tworight,
      'Math::PlanePath::CellularRule,rule=212' => $tworight,
      'Math::PlanePath::CellularRule,rule=244' => $tworight,
     );
     
     # OEIS-Other: A005408 planepath=CellularRule,rule=84 line_type=Diagonal
     # OEIS-Other: A005408 planepath=CellularRule,rule=116 line_type=Diagonal
     # OEIS-Other: A005408 planepath=CellularRule,rule=212 line_type=Diagonal
     # OEIS-Other: A005408 planepath=CellularRule,rule=244 line_type=Diagonal
   },
   #
   # rule=50,58,114,122,178,179,186,242,250 pyramid every second point
   'Math::PlanePath::CellularRule::OddSolid' =>
   { Diagonal_NW => 'A000124',  # triangular+1
     #
     # Not quite, starts value=0
     # Diagonal => 'A000217', # triangular numbers but diff start
     #
     # OEIS-Other: A000124 planepath=CellularRule,rule=50 line_type=Diagonal_NW
     # OEIS-Other: A000124 planepath=CellularRule,rule=58 line_type=Diagonal_NW
     # OEIS-Other: A000124 planepath=CellularRule,rule=114 line_type=Diagonal_NW
     # OEIS-Other: A000124 planepath=CellularRule,rule=122 line_type=Diagonal_NW
     # OEIS-Other: A000124 planepath=CellularRule,rule=178 line_type=Diagonal_NW
     # OEIS-Other: A000124 planepath=CellularRule,rule=179 line_type=Diagonal_NW
     # OEIS-Other: A000124 planepath=CellularRule,rule=186 line_type=Diagonal_NW
     # OEIS-Other: A000124 planepath=CellularRule,rule=242 line_type=Diagonal_NW
     # OEIS-Other: A000124 planepath=CellularRule,rule=250 line_type=Diagonal_NW
   },
   'Math::PlanePath::CellularRule,rule=77' =>
   { Y_axis   => 'A000124',  # triangular+1
     # OEIS-Other: A000124 planepath=CellularRule,rule=77 line_type=Y_axis
   },
   'Math::PlanePath::CellularRule,rule=177' =>
   { Diagonal   => 'A000124',  # triangular+1
     # OEIS-Other: A000124 planepath=CellularRule,rule=177 line_type=Diagonal
   },
   'Math::PlanePath::CellularRule,rule=185' =>
   { Diagonal   => 'A002522',  # n^2+1
     # OEIS-Other: A002522 planepath=CellularRule,rule=185 line_type=Diagonal
   },
   'Math::PlanePath::CellularRule,rule=189' =>
   { Y_axis   => 'A002522',  # n^2+1
     # OEIS-Other: A002522 planepath=CellularRule,rule=189 line_type=Y_axis
   },
   # PyramidRows step=1,align=left
   # OEIS-Other: A000124 planepath=CellularRule,rule=206 line_type=Diagonal_NW
   # OEIS-Other: A000124 planepath=CellularRule,rule=238 line_type=Diagonal_NW

   do {
     my $solidgapright
       = { Diagonal   => 'A002522',  # n^2+1
         };
     ('Math::PlanePath::CellularRule,rule=209' => $solidgapright,
      'Math::PlanePath::CellularRule,rule=241' => $solidgapright,
     );
     # OEIS-Other: A002522 planepath=CellularRule,rule=209 line_type=Diagonal
     # OEIS-Other: A002522 planepath=CellularRule,rule=241 line_type=Diagonal
   },
   'Math::PlanePath::CellularRule,rule=229' =>
   { Y_axis   => 'A002522',  # n^2+1
     # OEIS-Other: A002522 planepath=CellularRule,rule=229 line_type=Y_axis
   },
   #
   # rule=6,38,134,166 left line 1,2
   # Diagonal_NW => 'A001651' except OFFSET=1 cf start Y=0 here
   #
   # rule=13 Y axis
   #
   # rule=20,52,148,180 (mirror image of rule 6)
   # Diagonal A032766 numbers 0 or 1 mod 3, but it starts offset=0 value=0
   #
   # rule=28,156
   # Y_axis A002620 quarter squares floor(n^2/4) but diff start
   # Diagonal A024206 quarter squares - 1, but diff start
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


   # CoprimeColumns X_axis -- cumulative totient but start X=1 value=0;
   #   Diagonal A015614 cumulative-1 but start X=1 value=1
   #
   # DivisibleColumns X_axis nearly A006218 but start X=1 cf OFFSET=0,
   #   Diagonal nearly A077597 but start X=1 cf OFFSET=0
   #
   # DiagonalRationals Diagonal -- cumulative totient but start X=1 value=1
   #
   # CellularRule190 -- A006578 triangular+quarter square, but starts
   # OFFSET=0 cf N=1 in PlanePath
   #
   # SacksSpiral X_axis -- squares (i-1)^2, starting from i=1 value=0
   #
   # GcdRationals -- X_axis triangular row, but starting X=1
   #
   # GcdRationals -- Y_axis A000124 triangular+1 but starting i=1 versus
   # OFFSET=0
   #
   # MPeaks -- X_axis A045944 matchstick n(3n+2) but initial N=3
   # MPeaks -- Diagonal,Y_axis hexagonal first,second spoke, but starting
   # from 3
   #
   # OctagramSpiral -- X_axis A125201 8*n^2-7*n+1 but initial N=1
   #
   # Rows,height=1 -- integers 1,2,3, etc, but starting i=0
   # MultipleRings,step=0 -- integers 1,2,3, etc, but starting i=0
  );

sub oeis_anum {
  my ($self) = @_;
  ### PlanePathN oeis_anum() ...
  my $key = Math::NumSeq::PlanePathCoord::_planepath_oeis_key($self->{'planepath_object'});

  ### $key
  ### hash: $oeis_anum{$key}

  return $oeis_anum{$key}->{$self->{'line_type'}};
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
           && ($line_type eq 'X_axis'
               || $line_type eq 'Y_axis'
               || $line_type eq 'X_neg'
               || $line_type eq 'Y_neg')) {
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
  ### NumSeq-PlanePath next(): $self->{'i'}

  my $i = $self->{'i'};
  my $n = &{$self->{'i_func'}} ($self, $i);
  if (! defined $n) {
    ### no value ...
    return;
  }
  # secret experimental automatic bigint to preserve precision
  if (! ref $n && $n > 0xFF_FFFF) {
    $n = &{$self->{'i_func'}}($self,_to_bigint($i))
  }
  return ($self->{'i'}++, $n);
}
sub _to_bigint {
  my ($n) = @_;
  # stringize to avoid UV->BigInt bug in Math::BigInt::GMP version 1.37
  return _bigint()->new("$n");
}
# or maybe check for new enough for uv->mpz fix
use constant::defer _bigint => sub {
  # Crib note: don't change the back-end if already loaded
  unless (Math::BigInt->can('new')) {
    require Math::BigInt;
    eval { Math::BigInt->import (try => 'GMP') };
  }
  return 'Math::BigInt';
};

sub ith {
  my ($self, $i) = @_;
  ### NumSeq-PlanePath ith(): $i
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
sub i_func_X_neg {
  my ($self, $i) = @_;
  ### i_func_X_neg(): $i
  my $path_object = $self->{'planepath_object'};
  return $path_object->xy_to_n (-$i * $self->{'i_step'},
                                $path_object->_NumSeq_X_axis_at_Y);
}
sub i_func_Y_neg {
  my ($self, $i) = @_;
  my $path_object = $self->{'planepath_object'};
  return $path_object->xy_to_n ($path_object->_NumSeq_Y_axis_at_X,
                                - $i * $self->{'i_step'});
}
sub i_func_Diagonal {
  my ($self, $i) = @_;
  my $path_object = $self->{'planepath_object'};
  return $path_object->xy_to_n ($i + $path_object->_NumSeq_Diagonal_X_offset,
                                $i);
}
sub i_func_Diagonal_NW {
  my ($self, $i) = @_;
  my $path_object = $self->{'planepath_object'};
  return $path_object->xy_to_n (-$i + $path_object->_NumSeq_Diagonal_X_offset,
                                $i);
}
sub i_func_Diagonal_SW {
  my ($self, $i) = @_;
  my $path_object = $self->{'planepath_object'};
  return $path_object->xy_to_n (-$i + $path_object->_NumSeq_Diagonal_X_offset,
                                -$i);
}
sub i_func_Diagonal_SE {
  my ($self, $i) = @_;
  my $path_object = $self->{'planepath_object'};
  return $path_object->xy_to_n ($i + $path_object->_NumSeq_Diagonal_X_offset,
                                -$i);
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
sub pred_func_X_neg {
  my ($x,$y) = @_;
  return ($x <= 0 && $y == 0);
}
sub pred_func_Y_neg {
  my ($x,$y) = @_;
  return ($x == 0 && $y <= 0);
}
sub pred_func_Diagonal {
  my ($x,$y) = @_;
  return ($x >= 0 && $x == $y);
}
sub pred_func_Diagonal_NW {
  my ($x,$y) = @_;
  return ($x <= 0 && $x == -$y);
}
sub pred_func_Diagonal_SW {
  my ($x,$y) = @_;
  return ($x <= 0 && $x == $y);
}
sub pred_func_Diagonal_SE {
  my ($x,$y) = @_;
  return ($x >= 0 && $x == -$y);
}

#------------------------------------------------------------------------------

use constant characteristic_integer => 1; # integer Ns

sub characteristic_increasing {
  my ($self) = @_;
  ### PlanePathN characteristic_increasing(): $self

  my $method = "_NumSeq_$self->{'line_type'}_increasing";
  my $planepath_object = $self->{'planepath_object'};

  ### planepath_object: ref $planepath_object
  ### $method
  ### can code: $planepath_object->can($method)
  ### result: $planepath_object->can($method) && $planepath_object->$method()

  return $planepath_object->can($method) && $planepath_object->$method();
}
sub characteristic_increasing_from_i {
  my ($self) = @_;
  ### PlanePathN characteristic_increasing_from_i(): $self

  my $planepath_object = $self->{'planepath_object'};
  my $method = "_NumSeq_$self->{'line_type'}_increasing_from_i";
  ### $method

  if ($method = $planepath_object->can($method)) {
    ### can: $method
    return $planepath_object->$method();
  }
  return ($self->characteristic('increasing')
          ? $self->i_start
          : undef);
}

sub characteristic_non_decreasing {
  my ($self) = @_;
  ### PlanePathN characteristic_non_decreasing() ...
  my $planepath_object = $self->{'planepath_object'};
  my $method = "_NumSeq_$self->{'line_type'}_non_decreasing";
  return (($planepath_object->can($method) && $planepath_object->$method())
          || $self->characteristic_increasing);
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
  *_NumSeq_X_neg_min = \&_NumSeq_X_axis_min;
  *_NumSeq_Y_neg_min = \&_NumSeq_Y_axis_min;

  sub _NumSeq_Diagonal_min {
    my ($path,$self) = @_;
    return $self->i_func_Diagonal ($self->i_start);
  }
  sub _NumSeq_Diagonal_NW_min {
    my ($path,$self) = @_;
    return $self->i_func_Diagonal_NW ($self->i_start);
  }
  sub _NumSeq_Diagonal_SW_min {
    my ($path,$self) = @_;
    return $self->i_func_Diagonal_SW ($self->i_start);
  }
  sub _NumSeq_Diagonal_SE_min {
    my ($path,$self) = @_;
    return $self->i_func_Diagonal_SE ($self->i_start);
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
  sub _NumSeq_X_neg_increasing {
    my ($self) = @_;
    return ($self->{'wider'} == 0);
  }
  sub _NumSeq_X_neg_increasing_from_i {
    my ($self) = @_;
    ### SquareSpiral _NumSeq_X_neg_increasing_from_i(): $self
    # wider=0 from X=0
    # wider=1 from X=-1
    # wider=2 from X=-1
    return int(($self->{'wider'}+1)/2);
  }
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;

  sub _NumSeq_X_neg_min { # not the value at X=0,Y=0 if wider>0
    my ($self) = @_;
    return $self->n_start;
  }
}
{ package Math::PlanePath::GreekKeySpiral;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  sub _NumSeq_X_neg_increasing {
    my ($self) = @_;
    return ($self->{'turns'} == 0);  # when SquareSpiral style
  }
  *_NumSeq_Y_neg_increasing = \&_NumSeq_X_neg_increasing;
  sub _NumSeq_Diagonal_increasing {
    my ($self) = @_;
    return ($self->{'turns'} <= 1);
  }
  sub _NumSeq_Diagonal_NW_increasing {
    my ($self) = @_;
    return ($self->{'turns'} == 0);
  }
  *_NumSeq_Diagonal_SW_increasing = \&_NumSeq_Diagonal_increasing;
  sub _NumSeq_Diagonal_SE_increasing {
    my ($self) = @_;
    return ($self->{'turns'} <= 2);
  }
}
{ package Math::PlanePath::PyramidSpiral;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::TriangleSpiral;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::TriangleSpiralSkewed;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::DiamondSpiral;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::DiamondArms;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::AztecDiamondRings;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::PentSpiral;
  use constant _NumSeq_X_axis_step => 2;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::PentSpiralSkewed;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::HexSpiral;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  *_NumSeq_X_neg_increasing
    = \&Math::PlanePath::SquareSpiral::_NumSeq_X_neg_increasing;
  *_NumSeq_X_neg_increasing_from_i
    = \&Math::PlanePath::SquareSpiral::_NumSeq_X_neg_increasing_from_i;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;

  use constant _NumSeq_X_neg_min => 1; # not at X=0,Y=0 when wider
}
{ package Math::PlanePath::HexSpiralSkewed;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  *_NumSeq_X_neg_increasing
    = \&Math::PlanePath::SquareSpiral::_NumSeq_X_neg_increasing;
  *_NumSeq_X_neg_increasing_from_i
    = \&Math::PlanePath::SquareSpiral::_NumSeq_X_neg_increasing_from_i;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;

  use constant _NumSeq_X_neg_min => 1; # not at X=0,Y=0 when wider
}
{ package Math::PlanePath::HexArms;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::HeptSpiralSkewed;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::OctagramSpiral;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::AnvilSpiral;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  *_NumSeq_X_neg_increasing
    = \&Math::PlanePath::SquareSpiral::_NumSeq_X_neg_increasing;
  *_NumSeq_X_neg_increasing_from_i
    = \&Math::PlanePath::SquareSpiral::_NumSeq_X_neg_increasing_from_i;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;

  use constant _NumSeq_X_neg_min => 1; # not at X=0,Y=0 when wider
}
{ package Math::PlanePath::KnightSpiral;
  use constant _NumSeq_Diagonal_increasing => 1; # low then high
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::CretanLabyrinth;
  use constant _NumSeq_X_axis_increasing => 1;
}
{ package Math::PlanePath::SquareArms;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::SacksSpiral;
  use constant _NumSeq_X_axis_increasing   => 1;
  use constant _NumSeq_Y_axis_increasing   => 1; # when touched
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1; # when touched
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::VogelFloret;
  use constant _NumSeq_X_axis_increasing   => 1; # when touched
  use constant _NumSeq_Y_axis_increasing   => 1; # when touched
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1; # when touched
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::TheodorusSpiral;
  use constant _NumSeq_X_axis_increasing   => 1; # when touched
  use constant _NumSeq_Y_axis_increasing   => 1; # when touched
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1; # when touched
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::ArchimedeanChords;
  use constant _NumSeq_X_axis_increasing   => 1; # when touched
  use constant _NumSeq_Y_axis_increasing   => 1; # when touched
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1; # when touched
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::MultipleRings;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1; # when touched
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1; # when touched
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::PixelRings;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1; # where covered
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::FilledRings;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::Hypot;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::HypotOctant;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::TriangularHypot;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
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

  use constant _NumSeq_Diagonal_increasing => 1;
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
  sub _NumSeq_X_axis_increasing {
    my ($self) = @_;
    return ($self->{'radix'} % 2);
  }
  *_NumSeq_Y_axis_increasing = \&_NumSeq_X_axis_increasing;
}
{ package Math::PlanePath::WunderlichSerpentine;
  sub _NumSeq_X_axis_increasing {
    my ($self) = @_;
    if ($self->{'radix'} % 2) {
      return 1;  # odd radix always increasing
    }
    # FIXME: depends on the serpentine_type bits
    return 0;
  }
  sub _NumSeq_Y_axis_increasing {
    my ($self) = @_;
    if ($self->{'radix'} % 2) {
      return 1;  # odd radix always increasing
    }
    # FIXME: depends on the serpentine_type bits
    return 0;
  }
}
{ package Math::PlanePath::HilbertCurve;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::HilbertSpiral;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
}
{ package Math::PlanePath::ZOrderCurve;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::GrayCode;

  # X axis increasing for:
  # radix=2 TsF,Fs
  # radix=3 reflected TsF,FsT
  #  radix=3 modular TsF,Fs
  # radix=4 reflected TsF,Fs
  #  radix=4 modular TsF,Fs
  # radix=5 reflected TsF,FsT
  #  radix=5 modular TsF,Fs
  #
  sub _NumSeq_X_axis_increasing {
    my ($self) = @_;
    if ($self->{'gray_type'} eq 'modular' || $self->{'radix'} == 2) {
      return ($self->{'apply_type'} eq 'TsF'
              || $self->{'apply_type'} eq 'Fs');
    }
    if ($self->{'radix'} & 1) {
      return ($self->{'apply_type'} eq 'TsF'
              || $self->{'apply_type'} eq 'FsT');
    } else {
      return ($self->{'apply_type'} eq 'TsF'
              || $self->{'apply_type'} eq 'Fs');
    }
  }
  *_NumSeq_Y_axis_increasing = \&_NumSeq_X_axis_increasing;

  # Diagonal increasing for:
  # radix=2 FsT,Ts
  # radix=3 reflected Ts,Fs
  #  radix=3 modular FsT
  # radix=4 reflected FsT,Ts
  #  radix=4 modular FsT
  # radix=5 reflected Ts,Fs
  #  radix=5 modular FsT
  sub _NumSeq_Diagonal_increasing {
    my ($self) = @_;
    if ($self->{'radix'} & 1) {
      if ($self->{'gray_type'} eq 'modular') {
        return ($self->{'apply_type'} eq 'FsT');  # odd modular
      } else {
        return ($self->{'apply_type'} eq 'Ts'
                || $self->{'apply_type'} eq 'Fs');  # odd reflected
      }
    }
    if ($self->{'gray_type'} eq 'reflected' || $self->{'radix'} == 2) {
      return ($self->{'apply_type'} eq 'FsT'
              || $self->{'apply_type'} eq 'Ts');  # even reflected
    } else {
      return ($self->{'apply_type'} eq 'FsT');  # even modular
    }
  }
}
# { package Math::PlanePath::ImaginaryBase;
# }
{ package Math::PlanePath::ImaginaryHalf;
  use constant _NumSeq_Y_axis_increasing => 1;
}
# { package Math::PlanePath::CubicBase;
# }
{ package Math::PlanePath::CincoCurve;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
}
{ package Math::PlanePath::BetaOmega;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
}
{ package Math::PlanePath::KochelCurve;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
}
{ package Math::PlanePath::AR2W2Curve;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::WunderlichMeander;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
}
# { package Math::PlanePath::Flowsnake;
# }
# { package Math::PlanePath::FlowsnakeCentres;
#   # inherit from Flowsnake
# }
# { package Math::PlanePath::GosperIslands;
# }
# { package Math::PlanePath::GosperSide;
# }
{ package Math::PlanePath::KochCurve;
  use constant _NumSeq_X_axis_increasing   => 1; # when touched
  use constant _NumSeq_Y_axis_increasing   => 1; # when touched
  use constant _NumSeq_Diagonal_increasing => 1; # when touched
}
{ package Math::PlanePath::KochPeaks;
  use constant _NumSeq_X_axis_increasing => 1; # when touched
  use constant _NumSeq_Y_axis_increasing => 1; # when touched
  use constant _NumSeq_X_neg_increasing  => 1; # when touched
  # Diagonal never touched
}
{ package Math::PlanePath::KochSnowflakes;
  use constant _NumSeq_X_axis_increasing   => 1; # when touched
  use constant _NumSeq_Y_axis_increasing   => 1; # when touched
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1; # when touched
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::KochSquareflakes;
  use constant _NumSeq_X_axis_increasing   => 1; # when touched
  use constant _NumSeq_Y_axis_increasing   => 1; # when touched
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1; # when touched
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::QuadricCurve;
  use constant _NumSeq_X_axis_increasing   => 1; # when touched
  use constant _NumSeq_Diagonal_increasing => 1; # two values only
}
{ package Math::PlanePath::QuadricIslands;
  use constant _NumSeq_X_axis_increasing   => 1; # when touched
  use constant _NumSeq_Y_axis_increasing   => 1;

  use constant _NumSeq_X_neg_increasing => 1;

  use constant _NumSeq_Y_neg_increasing        => 0;
  use constant _NumSeq_Y_neg_increasing_from_i => 1; # after 3,2,8
  use constant _NumSeq_Y_neg_min => 2; # at X=-1,Y=0 rather than X=0,Y=0
}
{ package Math::PlanePath::SierpinskiTriangle;
  use constant _NumSeq_X_axis_increasing   => 1; # for "diagonal" style
  use constant _NumSeq_Y_axis_increasing   => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
}
{ package Math::PlanePath::SierpinskiArrowhead;
  use constant _NumSeq_Y_axis_increasing   => 1; # when touched
  use constant _NumSeq_Diagonal_increasing => 1; # when touched
  use constant _NumSeq_Diagonal_NW_increasing => 1;
}
{ package Math::PlanePath::SierpinskiArrowheadCentres;
  use constant _NumSeq_Y_axis_increasing   => 1; # never touched ?
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
}
{ package Math::PlanePath::SierpinskiCurve;
  use constant _NumSeq_X_axis_increasing => 1; # when touched
  use constant _NumSeq_Y_axis_increasing => 1; # when touched
  use constant _NumSeq_X_neg_increasing => 1; # arms
  use constant _NumSeq_Y_neg_increasing => 1; # arms
  use constant _NumSeq_Diagonal_increasing => 1; # when touched
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::SierpinskiCurveStair;
  use constant _NumSeq_X_axis_increasing => 1; # when touched
  use constant _NumSeq_Y_axis_increasing => 1; # when touched
  use constant _NumSeq_X_neg_increasing => 1; # arms
  use constant _NumSeq_Y_neg_increasing => 1; # arms
  use constant _NumSeq_Diagonal_increasing => 1; # when touched
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::HIndexing;
  use constant _NumSeq_X_axis_increasing => 1; # when touched
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1; # when touched
}
# { package Math::PlanePath::DragonCurve;
# }
# { package Math::PlanePath::DragonRounded;
# }
# { package Math::PlanePath::DragonMidpoint;
# }
{ package Math::PlanePath::AlternatePaper;
  use constant _NumSeq_X_axis_increasing   => 1;
  use constant _NumSeq_Y_axis_increasing   => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1; # arms
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
  # selecting the smaller N on the negative axes gives increasing, maybe
  use constant _NumSeq_X_neg_increasing   => 1;
  use constant _NumSeq_Y_neg_increasing   => 1;
}
{ package Math::PlanePath::AlternatePaperMidpoint;
  use constant _NumSeq_X_axis_increasing   => 1;
  use constant _NumSeq_Y_axis_increasing   => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1; # arms
  use constant _NumSeq_Diagonal_SE_increasing => 1; # arms
}
# { package Math::PlanePath::TerdragonCurve;
# }
# { package Math::PlanePath::TerdragonRounded;
# }
# { package Math::PlanePath::TerdragonMidpoint;
# }
# { package Math::PlanePath::R5DragonCurve;
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
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Y_neg_min => undef; # negatives
  use constant _NumSeq_Y_neg_max => 1;     # negatives

  # secret negatives
  # (w-1)*(w-1)-1
  # = w^2-2w+1-1
  # = w(w-2)
  sub _NumSeq_Diagonal_SE_min {
    my ($self) = @_;
    return ($self->{'width'}-2)*$self->{'width'};
  }
}
{ package Math::PlanePath::Columns;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_X_neg_min => undef; # negatives
  use constant _NumSeq_X_neg_max => 1;     # negatives

  sub _NumSeq_Diagonal_NW_min {
    my ($self) = @_;
    # secret negatives
    return ($self->{'height'}-2)*$self->{'height'};
  }
}
{ package Math::PlanePath::Diagonals;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::DiagonalsAlternating;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::DiagonalsOctant;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::MPeaks;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_neg_increasing        => 0;
  use constant _NumSeq_X_neg_increasing_from_i => 1;
  use constant _NumSeq_X_neg_min => 1; # at X=-1,Y=0 rather than X=0,Y=0
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing_from_i => 1;
  use constant _NumSeq_Diagonal_NW_min => 2; # at X=-1,Y=1
}
{ package Math::PlanePath::Staircase;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::StaircaseAlternating;
  sub _NumSeq_X_axis_increasing {
    my ($self) = @_;
    return ($self->{'end_type'} eq 'square'
            ? 1
            : 0); # backs-up
  }
  *_NumSeq_Y_axis_increasing = \&_NumSeq_X_axis_increasing;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::Corner;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::PyramidRows;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1; # when covered, or single
  use constant _NumSeq_Diagonal_NW_increasing => 1;
}
{ package Math::PlanePath::PyramidSides;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
}
{ package Math::PlanePath::CellularRule;
  use constant _NumSeq_Y_axis_increasing   => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
}
{ package Math::PlanePath::CellularRule54;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
}
{ package Math::PlanePath::CellularRule57;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
}
{ package Math::PlanePath::CellularRule190;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
}
{ package Math::PlanePath::UlamWarburton;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_X_neg_increasing => 1;
  use constant _NumSeq_Y_neg_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
  use constant _NumSeq_Diagonal_NW_increasing => 1;
  use constant _NumSeq_Diagonal_SW_increasing => 1;
  use constant _NumSeq_Diagonal_SE_increasing => 1;
}
{ package Math::PlanePath::UlamWarburtonQuarter;
  use constant _NumSeq_X_axis_increasing => 1;
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
#   # FIXME: analyze points for min/max
# }
# { package Math::PlanePath::QuintetCurve;
# }
# { package Math::PlanePath::QuintetCentres;
#   # inherit QuintetCurve
# }
{ package Math::PlanePath::CornerReplicate;
  use constant _NumSeq_X_axis_increasing => 1;
  use constant _NumSeq_Y_axis_increasing => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::DigitGroups;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::FibonacciWordFractal;
  use constant _NumSeq_X_axis_increasing   => 1; # when touched
  use constant _NumSeq_Y_axis_increasing   => 1; # when touched
  use constant _NumSeq_Diagonal_increasing => 1; # when touched
}
{ package Math::PlanePath::LTiling;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::WythoffArray;
  use constant _NumSeq_X_axis_increasing   => 1;
  use constant _NumSeq_Y_axis_increasing   => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::PowerArray;
  use constant _NumSeq_X_axis_increasing   => 1;
  use constant _NumSeq_Y_axis_increasing   => 1;
  use constant _NumSeq_Diagonal_increasing => 1;
}

#------------------------------------------------------------------------------
{ package Math::PlanePath;
  use constant _NumSeq_A2 => 0;
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

=for stopwords Ryde Math-PlanePath SquareSpiral DragonCurve lookup PlanePath

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
    "X_neg"         X negative axis
    "Y_neg"         Y negative axis
    "Diagonal"      leading diagonal X=i, Y=i
    "Diagonal_NW"   north-west diagonal X=-i, Y=i
    "Diagonal_SW"   south-west diagonal X=-i, Y=-i
    "Diagonal_SE"   south-east diagonal X=i, Y=-i

For example the SquareSpiral X axis starts i=0 with values 1, 2, 11, 28, 53,
86, etc.

"X_neg", "Y_neg", "Diagonal_NW", etc, on paths which don't traverse negative
X or Y have just a single value from X=0,Y=0.

The behaviour on paths which visit only some of the points on the
respective axis is unspecified as yet, as is behaviour on paths with
repeat points, such as the DragonCurve.

=head1 FUNCTIONS

See L<Math::NumSeq/FUNCTIONS> for behaviour common to all sequence classes.

=over 4

=item C<$seq = Math::NumSeq::PlanePathN-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.  The options are

    planepath          string, name of a PlanePath module
    planepath_object   PlanePath object
    line_type          string, as described above

C<planepath> can be either the module part such as "SquareSpiral" or a
full class name "Math::PlanePath::SquareSpiral".

=item C<$value = $seq-E<gt>ith($i)>

Return the N value at C<$i> in the PlanePath.  C<$i> gives a position on the
respective C<line_type>, so the X,Y to lookup a C<$value=N> is

     X,Y       line_type
    -----      ---------
    $i, 0      "X_axis"
    0, $i      "Y_axis"
    -$i, 0     "X_neg"
    0, -$i     "Y_neg"
    $i, $i     "Diagonal"
    $i, -$i    "Diagonal_NW"
    -$i, -$i   "Diagonal_SW"
    $i, -$i    "Diagonal_SE"

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> occurs in the sequence.

This means C<$value> is an integer N which is on the respective
C<line_type>, ie. that C<($path-E<gt>n_to_xy($value)> is on the line type.

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
