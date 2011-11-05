#!/usr/bin/perl -w

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


# Check that the supported fields described in each pod matches what the
# code says.

use 5.005;
use strict;
use FindBin;
use ExtUtils::Manifest;
use List::Util 'max';
use File::Spec;
use Test::More;

use lib 't','xt';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

# uncomment this to run the ### lines
#use Smart::Comments;

# new in 5.6, so unless got it separately with 5.005
eval { require Pod::Parser }
  or plan skip_all => "Pod::Parser not available -- $@";
plan tests => 5;

my $toplevel_dir = File::Spec->catdir ($FindBin::Bin, File::Spec->updir);
my $manifest_file = File::Spec->catfile ($toplevel_dir, 'MANIFEST');
my $manifest = ExtUtils::Manifest::maniread ($manifest_file);

my @lib_modules
  = map {m{^lib/Math/PlanePath/(.*)\.pm$} ? $1 : ()} keys %$manifest;
@lib_modules = sort @lib_modules;
diag "module count ",scalar(@lib_modules);

#------------------------------------------------------------------------------

{
  open FH, 'lib/Math/PlanePath.pm' or die $!;
  my $content = do { local $/; <FH> }; # slurp
  close FH or die;
  ### $content

  {
    $content =~ /=for my_pod see_also begin(.*)=for my_pod see_also end/s
      or die "see_also not matched";
    my $see_also = $1;

    my @see_also;
    while ($see_also =~ /L<Math::PlanePath::([^>]+)>/g) {
      push @see_also, $1;
    }
    @see_also = sort @see_also;

    my $s = join(', ',@see_also);
    my $l = join(', ',@lib_modules);
    is ($s, $l);

    my $j = "$s\n$l";
    $j =~ /^(.*)(.*)\n\1(.*)/ or die;
    my $sd = $2;
    my $ld = $3;
    if ($sd) {
      diag "see also: ",$sd;
      diag "library:  ",$ld;
    }
  }

  {
    $content =~ /=for my_pod list begin(.*)=for my_pod list end/s
      or die "class list not matched";
    my $list = $1;

    my @list;
    while ($list =~ /^    (\S+)/mg) {
      push @list, $1;
    }
    @list = sort @list;

    my $s = join(', ',@list);
    my $l = join(', ',@lib_modules);
    is ($s, $l);

    my $j = "$s\n$l";
    $j =~ /^(.*)(.*)\n\1(.*)/ or die;
    my $sd = $2;
    my $ld = $3;
    if ($sd) {
      diag "list:     ",$sd;
      diag "library:  ",$ld;
    }
  }

  {
    $content =~ /=for my_pod step begin(.*)=for my_pod step end/s
      or die "base list not matched";
    my $list = $1;

    $content =~ /=for my_pod base begin(.*)=for my_pod base end/s
      or die "step list not matched";
    $list .= $1;

    my @list = ('File',
                'Hypot', 'HypotOctant',
                'TriangularHypot', 'VogelFloret',
                'PythagoreanTree', 'RationalsTree');
    my %seen;
    while ($list =~ /([A-Z]\S+)/g) {
      my $elem = $1;
      next if $elem eq 'Base';
      next if $elem eq 'Path';
      next if $elem eq 'Step';
      next if $elem eq 'Fibonacci';
      $elem =~ s/,//;
      next if $seen{$elem}++;
      push @list, $elem;
    }
    @list = sort @list;

    my $s = join(', ',@list);
    my $l = join(', ',@lib_modules);
    is ($s, $l, 'step/base pod lists');

    my $j = "$s\n$l";
    $j =~ /^(.*)(.*)\n\1(.*)/ or die;
    my $sd = $2;
    my $ld = $3;
    if ($sd) {
      diag "list:     ",$sd;
      diag "library:  ",$ld;
    }
  }
}

#------------------------------------------------------------------------------

{
  open FH, 't/PlanePath-subclasses.t' or die $!;
  my $content = do { local $/; <FH> }; # slurp
  close FH or die;
  ### $content

  {
    $content =~ /# module list begin(.*)module list end/s
      or die "module list not matched";
    my $list = $1;

    my @list;
    my %seen;
    while ($list =~ /'([A-Z][^',]+)/ig) {
      next if $seen{$1}++;
      push @list, $1;
    }
    @list = sort @list;

    my $s = join(', ',@list);
    my $l = join(', ',@lib_modules);
    is ($s, $l);

    my $j = "$s\n$l";
    $j =~ /^(.*)(.*)\n\1(.*)/ or die;
    my $sd = $2;
    my $ld = $3;
    if ($sd) {
      diag "t list:  ",$sd;
      diag "library: ",$ld;
    }
  }

  {
    $content =~ /# rect_to_n_range exact begin(.*)# rect_to_n_range exact /s
      or die "rect_to_n_range exact not matched";
    my $list = $1;

    my %exact;
    while ($list =~ /^\s*'Math::PlanePath::([A-Z][^']+)/img) {
      $exact{$1} = 1;
    }

    my $good = 1;
    foreach my $module (@lib_modules) {
      next if $module eq 'FlowsnakeCentres'; # inherited
      next if $module eq 'QuintetCentres'; # inherited

      my $file = module_exact($module);
      my $t = $exact{$module} || 0;

      if ($file != $t) {
        diag "Math::PlanePath::$module  file $file t $t";
        $good = 0;
      }
    }
    ok ($good);

    sub module_exact {
      my ($module) = @_;

      my $filename = "lib/Math/PlanePath/$module.pm";
      open FH, $filename or die $!;
      my $content = do { local $/; <FH> }; # slurp
      close FH or die;
      ### $content

      $content =~ /^# (not )?exact\nsub rect_to_n_range /m
        or die "$filename no exact comment";
      return $1 ? 0 : 1;
    }
  }
}

exit 0;
