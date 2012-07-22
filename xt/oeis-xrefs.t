#!/usr/bin/perl -w

# Copyright 2012 Kevin Ryde

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


# Check that OEIS A-numbers listed in lib/Math/PlanePath/Foo.pm files have
# code exercising them in one of the xt/oeis/*-oeis.t scripts.
#
# Check that A-numbers are not duplicated among the .pm files, since that's
# often a cut-and-paste mistake.
#
# Check that A-numbers are not duplicated among xt/oeis/*-oeis.t scripts,
# since normally only need to exercise a claimed path sequence once.  Except
# often that's not true since the same sequence can arise in separate ways.
# But for now demand duplication is explicitly listed here.
#


use 5.005;
use strict;
use FindBin;
use ExtUtils::Manifest;
use File::Spec;
use File::Slurp;
use Test::More;

use lib 't','xt';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

# uncomment this to run the ### lines
#use Smart::Comments;

# new in 5.6, so unless got it separately with 5.005
eval { require Pod::Parser }
  or plan skip_all => "Pod::Parser not available -- $@";
plan tests => 1;

my $toplevel_dir = File::Spec->catdir ($FindBin::Bin, File::Spec->updir);
my $manifest_file = File::Spec->catfile ($toplevel_dir, 'MANIFEST');
my $manifest = ExtUtils::Manifest::maniread ($manifest_file);
my $bad = 0;

#------------------------------------------------------------------------------

my @module_filenames
  = grep {m{^lib/Math/PlanePath/.*\.pm$}} keys %$manifest;
@module_filenames = sort @module_filenames;
diag "module count ",scalar(@module_filenames);

my %allow_duplicate_xrefs
  = (
     A002262 => { 'lib/Math/PlanePath/Diagonals.pm' => 1,
                  'lib/Math/PlanePath/PyramidRows.pm' => 1 },
     A003056 => { 'lib/Math/PlanePath/Diagonals.pm' => 1,
                  'lib/Math/PlanePath/PyramidRows.pm' => 1 },
     A025581 => { 'lib/Math/PlanePath/Diagonals.pm' => 1,
                  'lib/Math/PlanePath/PyramidRows.pm' => 1 },

     A035263 => {'lib/Math/PlanePath/GrayCode.pm' => 1,
                 'lib/Math/PlanePath/KochCurve.pm' => 1 },

     A007814 => {'lib/Math/PlanePath/CCurve.pm' => 1,
                 'lib/Math/PlanePath/PowerArray.pm' => 1 },

     A003849 => {'lib/Math/PlanePath/FibonacciWordFractal.pm' => 1,
                 'lib/Math/PlanePath/WythoffArray.pm' => 1 },

     A001844 => {'lib/Math/PlanePath/AztecDiamondRings.pm' => 1,
                 'lib/Math/PlanePath/MultipleRings.pm' => 1 },

     A016754 => { 'lib/Math/PlanePath/MultipleRings.pm' => 1,
                  'lib/Math/PlanePath/SquareSpiral.pm' => 1 },


     A196199 => { 'lib/Math/PlanePath/Corner.pm' => 1,
                  'lib/Math/PlanePath/PyramidRows.pm' => 1,
                  'lib/Math/PlanePath/PyramidSides.pm' => 1 },

     A059906 => { 'lib/Math/PlanePath/CornerReplicate.pm' => 1,
                  'lib/Math/PlanePath/ZOrderCurve.pm' => 1 },

     A003159 => { 'lib/Math/PlanePath/CCurve.pm' => 1,
                  'lib/Math/PlanePath/KochCurve.pm' => 1,
                  'lib/Math/PlanePath/GrayCode.pm' => 1 },
     A036554 => { 'lib/Math/PlanePath/CCurve.pm' => 1,
                  'lib/Math/PlanePath/KochCurve.pm' => 1,
                  'lib/Math/PlanePath/GrayCode.pm' => 1 },


     A053615 => { 'lib/Math/PlanePath/SquareSpiral.pm' => 1,
                  'lib/Math/PlanePath/PyramidSpiral.pm' => 1,
                },

     A020650 => { 'lib/Math/PlanePath/FractionsTree.pm' => 1,
                  'lib/Math/PlanePath/RationalsTree.pm' => 1,
                },
     A020651 => { 'lib/Math/PlanePath/FractionsTree.pm' => 1,
                  'lib/Math/PlanePath/RationalsTree.pm' => 1,
                },
     A086592 => { 'lib/Math/PlanePath/FractionsTree.pm' => 1,
                  'lib/Math/PlanePath/RationalsTree.pm' => 1,
                },

     A054424 => { 'lib/Math/PlanePath/DiagonalRationals.pm' => 1,
                  'lib/Math/PlanePath/RationalsTree.pm' => 1,
                },
     A054425 => { 'lib/Math/PlanePath/DiagonalRationals.pm' => 1,
                  'lib/Math/PlanePath/RationalsTree.pm' => 1,
                },
     A054426 => { 'lib/Math/PlanePath/DiagonalRationals.pm' => 1,
                  'lib/Math/PlanePath/RationalsTree.pm' => 1,
                },

     # permutation coprime <-> SB
     A054427 => { 'lib/Math/PlanePath/CoprimeColumns.pm' => 1,
                  'lib/Math/PlanePath/RationalsTree.pm'  => 1,
                },

     # base 4 digits 0,1
     A000695 => {'lib/Math/PlanePath/CornerReplicate.pm'  => 1,
                 'lib/Math/PlanePath/HilbertCurve.pm'     => 1,
                 'lib/Math/PlanePath/ZOrderCurve.pm'      => 1,
                 'lib/Math/PlanePath/AlternatePaper.pm'   => 1,
                },
     # base 4 digits 0,2
     A062880 => { 'lib/Math/PlanePath/CornerReplicate.pm' => 1,
                  'lib/Math/PlanePath/HilbertCurve.pm'    => 1,
                  'lib/Math/PlanePath/ZOrderCurve.pm'     => 1,
                  'lib/Math/PlanePath/AlternatePaper.pm'  => 1,
                },
     # base 4 digits 0,3
     A001196 => { 'lib/Math/PlanePath/CornerReplicate.pm' => 1,
                  'lib/Math/PlanePath/ZOrderCurve.pm'     => 1,
                },

     A055086 => { 'lib/Math/PlanePath/DiagonalsOctant.pm' => 1 },
     A002620 => { 'lib/Math/PlanePath/DiagonalsOctant.pm' => 1 },
    );

my %oeis_xrefs;

foreach my $module_filename (@module_filenames) {
  my $content = File::Slurp::read_file($module_filename, err_mode => 'croak');

  while ($content =~ /^ +((A\d{6,7} )+)/mg) {
    foreach my $anum (split / +/, $1) {
      if (exists $oeis_xrefs{$anum}) {
        unless ($allow_duplicate_xrefs{$anum}->{$module_filename}) {
          diag "$anum duplicate xref";
          diag "  in  $oeis_xrefs{$anum}";
          diag "  and $module_filename";
          $bad++;
        }
      }
      $oeis_xrefs{$anum} = $module_filename;
    }
  }
}

#------------------------------------------------------------------------------

my @xt_filenames
  = grep {m{^xt/.*-oeis\.t$}} keys %$manifest;
@xt_filenames = sort @xt_filenames;
diag "xt count ",scalar(@xt_filenames);

my %allow_duplicate_checks
  = (
     A025581 => { 'Diagonals-oeis.t' => 1,
                  'PyramidRows-oeis.t' => 1 },
     A002262 => { 'Diagonals-oeis.t' => 1,
                  'PyramidRows-oeis.t' => 1 },
     A003056 => { 'Diagonals-oeis.t' => 1,
                  'PyramidRows-oeis.t' => 1 },

     A035263 => {'GrayCode-oeis.t' => 1,
                 'KochCurve-oeis.t' => 1 },

     A007814 => {'CCurve-oeis.t' => 1,
                 'PowerArray-oeis.t' => 1 },

     A003849 => {'FibonacciWordFractal-oeis.t' => 1,
                 'WythoffArray-oeis.t' => 1 },

     A196199 => { 'Corner-oeis.t' => 1,
                  'PyramidRows-oeis.t' => 1,
                  'PyramidSides-oeis.t' => 1 },

     A059906 => { 'CornerReplicate-oeis.t' => 1,
                  'ZOrderCurve-oeis.t' => 1 },

     A003159 => { 'CCurve-oeis.t' => 1,
                  'KochCurve-oeis.t' => 1,
                  'GrayCode-oeis.t' => 1 },
     A036554 => { 'CCurve-oeis.t' => 1,
                  'KochCurve-oeis.t' => 1,
                  'GrayCode-oeis.t' => 1 },

     A053615 => { 'SquareSpiral-oeis.t' => 1,
                  'PyramidSpiral-oeis.t' => 1,
                },

     A020650 => { 'FractionsTree-oeis.t' => 1,
                  'RationalsTree-oeis.t' => 1,
                },
     A020651 => { 'FractionsTree-oeis.t' => 1,
                  'RationalsTree-oeis.t' => 1,
                },
     A086592 => { 'FractionsTree-oeis.t' => 1,
                  'RationalsTree-oeis.t' => 1,
                },

     # base 4 digits 0,1
     A000695 => { 'CornerReplicate-oeis.t' => 1,
                  'ZOrderCurve-oeis.t'     => 1,
                },
     # base 4 digits 0,2
     A062880 => { 'CornerReplicate-oeis.t' => 1,
                  'HilbertCurve-oeis.t'    => 1,
                  'ZOrderCurve-oeis.t'     => 1,
                },
     # base 4 digits 0,3
     A001196 => { 'CornerReplicate-oeis.t' => 1,
                  'ZOrderCurve-oeis.t'     => 1,
                },



     A060032 => { 'GosperSide-oeis.t' => 1,
                  'TerdragonCurve-oeis.t' => 1,
                },
     A062756 => { 'GosperSide-oeis.t' => 1,
                  'TerdragonCurve-oeis.t' => 1,
                },
     A189640 => { 'GosperSide-oeis.t' => 1,
                  'TerdragonCurve-oeis.t' => 1,
                },
     A189673 => { 'GosperSide-oeis.t' => 1,
                  'TerdragonCurve-oeis.t' => 1,
                },
     A137893 => { 'GosperSide-oeis.t' => 1,
                  'TerdragonCurve-oeis.t' => 1,
                },
     A080846 => { 'GosperSide-oeis.t' => 1,
                  'TerdragonCurve-oeis.t' => 1,
                },
     A060236 => { 'GosperSide-oeis.t' => 1,
                  'TerdragonCurve-oeis.t' => 1,
                },
     A038502 => { 'GosperSide-oeis.t' => 1,
                  'TerdragonCurve-oeis.t' => 1,
                },
     A026225 => { 'GosperSide-oeis.t' => 1,
                  'TerdragonCurve-oeis.t' => 1,
                },
     A026179 => { 'GosperSide-oeis.t' => 1,
                  'TerdragonCurve-oeis.t' => 1,
                },
    );

my %oeis_checks = (# in PlanePathN
                   A051022 => 'ZOrderCurve-oeis.t',
                   A037314 => 'ZOrderCurve-oeis.t',
                   A084471 => 'DigitGroups-oeis.t',

                   # TODO: centred polygonals
                   A003154 => 'MultipleRings-oeis.t',
                   A069133 => 'MultipleRings-oeis.t',
                   A069128 => 'MultipleRings-oeis.t',
                   A069126 => 'MultipleRings-oeis.t',
                   A069099 => 'MultipleRings-oeis.t',
                   A069132 => 'MultipleRings-oeis.t',
                   A069125 => 'MultipleRings-oeis.t',
                   A069129 => 'MultipleRings-oeis.t',
                   A062786 => 'MultipleRings-oeis.t',
                   A005448 => 'MultipleRings-oeis.t',
                   A003215 => 'MultipleRings-oeis.t',
                   A060544 => 'MultipleRings-oeis.t',
                   A069131 => 'MultipleRings-oeis.t',
                   A069130 => 'MultipleRings-oeis.t',
                   A005891 => 'MultipleRings-oeis.t',
                   A069127 => 'MultipleRings-oeis.t',
                  );

foreach my $xt_filename (@xt_filenames) {
  my $content = File::Slurp::read_file($xt_filename, err_mode => 'croak');
  my (undef,undef,$xt_base_filename) = File::Spec->splitpath($xt_filename);

  while ($content =~ /^[^#]*\$anum = '(A\d{6,7})'/mg) {
    my $anum = $1;
    if (exists $oeis_checks{$anum}) {
      unless ($allow_duplicate_checks{$anum}->{$xt_base_filename}) {
        diag "$anum duplicate check";
        diag "  in  $oeis_checks{$anum}";
        diag "  and $xt_filename";
        $bad++;
      }
    }
    $oeis_checks{$anum} = $xt_filename;
  }
}

#------------------------------------------------------------------------------

foreach my $anum (keys %oeis_xrefs) {
  if (! $oeis_checks{$anum}) {
    diag "$anum xref not checked";
    diag "  from $oeis_xrefs{$anum}";
    $bad++;
  }
}

my %allow_check_not_xreffed
  = (A141481 => 1,
    );

foreach my $anum (keys %oeis_checks) {
  if (! $oeis_xrefs{$anum}) {
    unless ($allow_check_not_xreffed{$anum}) {
      diag "$anum check not xreffed";
      diag "  from $oeis_checks{$anum}";
      $bad++;
    }
  }
}

is ($bad, 0);
exit 0;
