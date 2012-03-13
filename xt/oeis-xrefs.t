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
# checking code exercising them in one of the xt/*-oeis.t scripts.
#
# And check that A-numbers are not duplicated among the .pm files, since
# that's often a cut-and-paste mistake.
#
# And check that A-numbers are not duplicated among xt/*-oeis.t scripts,
# since normally only need to exercise a claimed path sequence once.
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
  = (A020650 => { 'lib/Math/PlanePath/FractionsTree.pm' => 1,
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
    );

my %oeis_xrefs;

foreach my $module_filename (@module_filenames) {
  my $content = File::Slurp::read_file($module_filename, err_mode => 'croak');

  while ($content =~ /^ +(A\d{6,7})/mg) {
    my $anum = $1;
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

#------------------------------------------------------------------------------

my @xt_filenames
  = grep {m{^xt/.*\.t$}} keys %$manifest;
@xt_filenames = sort @xt_filenames;
diag "xt count ",scalar(@xt_filenames);

my %allow_duplicate_checks
  = (A020650 => { 'xt/FractionsTree-oeis.t' => 1,
                  'xt/RationalsTree-oeis.t' => 1,
                },
     A020651 => { 'xt/FractionsTree-oeis.t' => 1,
                  'xt/RationalsTree-oeis.t' => 1,
                },
     A086592 => { 'xt/FractionsTree-oeis.t' => 1,
                  'xt/RationalsTree-oeis.t' => 1,
                },
    );

my %oeis_checks;

foreach my $xt_filename (@xt_filenames) {
  my $content = File::Slurp::read_file($xt_filename, err_mode => 'croak');

  while ($content =~ /^[^#]*\$anum = '(A\d{6,7})'/mg) {
    my $anum = $1;
    if (exists $oeis_checks{$anum}) {
      unless ($allow_duplicate_checks{$anum}->{$xt_filename}) {
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
