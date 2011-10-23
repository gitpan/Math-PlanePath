#!/usr/bin/perl

# Copyright 2010, 2011 Kevin Ryde

# This file is part of Math-PlanePath.
#
# Math-PlanePath is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-PlanePath is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-PlanePath.  If not, see <http://www.gnu.org/licenses/>.

use 5.004;
use strict;
use ExtUtils::MakeMaker;
use lib 'inc';
use MyMakeMakerExtras;

MyMakeMakerExtras::WriteMakefile
  (NAME         => 'Math::PlanePath',
   ABSTRACT     => 'Mathematical paths through the 2-D plane.',
   VERSION_FROM => 'lib/Math/PlanePath.pm',
   PREREQ_PM    => {
                    'Math::Libm' => 0, # for hypot() mainly
                    'List::Util' => 0,
                    'constant' => '1.02', # for leading underscore

                    # only for testing
                    'Test' => 0,
                   },
   AUTHOR       => 'Kevin Ryde <user42@zip.com.au>',
   LICENSE      => 'gpl',
   SIGN         => 1,
   MIN_PERL_VERSION => '5.004',

   META_MERGE =>
   { resources =>
     { homepage => 'http://user42.tuxfamily.org/math-planepath/index.html',
     },
     maximum_tests =>
     { description => 'Have "make test" do as much as possible.',
       requires => { 'Data::Float'  => 0,
                     'Math::BigInt' => 0,
                     'Math::BigInt::Lite' => 0,
                     'Math::BigFloat' => '1.993',
                     'Math::BigRat' => 0,
                   },
     },
     optional_features =>
     { maximum_devel =>
       { description => 'Stuff used variously in development.',
         requires => { 'Math::BigInt'     => 0,
                       'Math::BigRat'     => 0,
                       'Math::Polynomial' => 1,
                     },
       },
     },
   },
  );
