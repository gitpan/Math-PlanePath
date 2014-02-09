#!/usr/bin/perl -w

# Copyright 2011, 2012, 2013, 2014 Kevin Ryde

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


# Rationals tree inter-row area
# 2*area = A048487 a(n) = 5*2^n-4     T(4,n), array T given by A048483.
# area = A051633 5*2^n - 2.
# same A131051 Row sums of triangle A133805.
# A126284 5*2^n-4*n-5  total*2
#
# Rationals row total X+Y = 2*3^depth
# X+Y rows
# match 2,6,18,54,162,486,1458,4374,13122,39366,118098,354294
# A008776 Pisot sequences E(2,6), L(2,6), P(2,6), T(2,6).
#
# A001541
# alt paper
# A129284 A129150(n) / 4.
# A129285 A129151(n) / 27.
# A131128 Binomial transform of [1, 1, 5, 1, 5, 1, 5,...].
# # area to 2*4^k
# # A060867 Number of n X n matrices over GF(2) with rank 1.
#
# Math::PlanePath::AlternatePaper area:
# = alt midpoint unit squares
# A027383 Number of balanced strings of length n: let d(S)= #(1)'s in S - #(0)'s, then S is balanced if every substring T has -2<=d(T)<=2.
# partial sums of A016116
#  a(2n-1) = 2^(n+1)-2 = A000918(n+1).
#  a(2n) = 3*2^n-2     = A033484(n);
#  a(2n+1) = 2^(n+2)-2
#          = 4*2^n-2

# Math::PlanePath::GosperReplicate unit hexagons boundary
# A178674 = 3^n+3
# A017926 A229977 gosper perimeter

# CCurve right boundary even terms
# A131064  8,24,60,136,292,608

# CCurve right boundary diffs even terms
# 6,14,30,62,126
# A000918 2^n - 2.
# CCurve right boundary diffs odd terms
# 10,22,46,94,190
# A033484 3*2^n - 2.
# CCurve right boundary diffs
# 6,10,14,22,30,46,62,94,126,190
# A027383   3*2^n-2 and 4*2^n-2
# 

# R5DragonCurve boundary (by powers right  all):
# 53,161,485
# match 53,161,485
# A048473 a(0)=1, a(n) = 3*a(n-1) + 2; a(n) = 2*3^n - 1.
# A048473 ,1,5,17,53,161,485,1457,4373,13121,39365,118097,354293,1062881,3188645,9565937,28697813,86093441,258280325,774840977,2324522933,6973568801,20920706405,62762119217,188286357653,564859072961,
# A154992 A048473 prefixed by two zeros.
# A154992 ,0,0,1,5,17,53,161,485,1457,4373,13121,39365,118097,354293,1062881,3188645,9565937,28697813,86093441,258280325,774840977,2324522933,6973568801,20920706405,62762119217,188286357653,564859072961,
# A176086 Partial sums of A001394.
# A176086 ,1,5,17,53,161,485,1433,4229,12425,36485,106673,311957,909953,2654501,7728401,22503053,65425505,190239989,552507641,1604779373,4656679889,
# A216851 a(n) = T^(floor(log(n)/log(2)))(n) (see comment).
# A216851 ,1,1,5,1,4,5,17,1,11,4,13,5,5,17,53,1,10,11,11,4,4,13,40,5,44,5,47,17,17,53,161,1,29,10,10,11,11,11,101,4,107,4,37,13,13,40,121,5,14,44,44,5,5,47,47,17,49,17,152,53,53,161,485,1,28,29,29,10,10,10,

# TerdragonCurve boundary (by powers full  odd):
# 96,384,1536,6144
# match 96,384,1536,6144
# A002023 6*4^n.

# TerdragonCurve area (by powers left  even):
# 5,65,665,6305
# match 5,65,665,6305
# A118004 9^n-4^n.
# A118004 ,0,5,65,665,6305,58025,527345,4766585,42981185,387158345,3485735825,31376865305,282412759265,2541798719465,22876524019505,205890058352825,1853015893884545,16677164519797385,150094566577522385,

# TerdragonCurve boundary (by powers left  even):
# 12,48,192,768
# match 12,48,192,768
# A002001 a(n) = 3*4^(n-1), n>0; a(0)=1.
# A002001 ,1,3,12,48,192,768,3072,12288,49152,196608,786432,3145728,12582912,50331648,201326592,805306368,3221225472,12884901888,51539607552,206158430208,824633720832,3298534883328,13194139533312,
# A092898 Expansion of (1-4x+4x^2-4x^3)/(1-4x).
# A092898 ,1,0,4,12,48,192,768,3072,12288,49152,196608,786432,3145728,12582912,50331648,201326592,805306368,3221225472,12884901888,51539607552,206158430208,824633720832,3298534883328,13194139533312,52776558133248,
# A110594 a(1) = 4, a(2) = 12, for n>1: a(n) = 3*4^(n-1).
# A110594 ,4,12,48,192,768,3072,12288,49152,196608,786432,3145728,12582912,50331648,201326592,805306368,3221225472,12884901888,51539607552,206158430208,824633720832,3298534883328,13194139533312,52776558133248,
# A164346 a(n) = 3*4^n.
# A164346 ,3,12,48,192,768,3072,12288,49152,196608,786432,3145728,12582912,50331648,201326592,805306368,3221225472,12884901888,51539607552,206158430208,824633720832,3298534883328,13194139533312,52776558133248,
# A172452 Partial products of A004001.
# A172452 ,1,1,1,2,4,12,48,192,768,3840,23040,161280,1128960,9031680,72253440,578027520,4624220160,41617981440,416179814400,4577977958400,54935735500800,

# TerdragonCurve boundary (by powers left  odd):
# 24,96,384,1536
# match 24,96,384,1536
# A002023 6*4^n.

# TerdragonCurve boundary (by powers right diffs even):
# 12,48,192,768
# match 12,48,192,768
# A002001 a(n) = 3*4^(n-1), n>0; a(0)=1.


=pod

Each 


=cut


use 5.010;
use strict;
use Module::Load;
use Math::Libm 'hypot';

use lib 'xt';
use MyOEIS;

# uncomment this to run the ### lines
# use Smart::Comments;




{
  # boundary and area

  require Math::Geometry::Planar;
  require Math::NumSeq::PlanePathCoord;
  use lib 'xt'; require MyOEIS;
  foreach my $elem (
                    # curves with overlaps only
                    ['R5DragonCurve', 5],
                    ['TerdragonCurve', 3, 'triangular'],
                    ['AlternatePaper', 4],
                    ['AlternatePaper', 2],
                    ['CCurve', 2],
                    ['DragonCurve', 2],
                   ) {
    my ($name, $radix, $lattice_type) = @$elem;
    $lattice_type ||= 'square';

    print "$name\n";
    my $path = Math::NumSeq::PlanePathCoord::_planepath_name_to_object($name);
    my $n_start = $path->n_start;

    foreach my $inc_type ('powers','1') {
      foreach my $diffs ('', 'diffs') {
        foreach my $convex_type (($inc_type eq 'powers'
                                  ? ('right',
                                     'left')
                                  : ()),
                                 'full',
                                 'convex',
                                ) {
          my @areas;
          my @boundaries;
          for (my $level = ($inc_type eq 'powers' ? 3 : 3);
               ;
               $level++) {
            my $n_limit = ($inc_type eq 'powers' ? $radix**$level
                           : $n_start + $level);
            last if $n_limit > 100_000;
            last if @areas > 25;

            my $side = ($convex_type eq 'right' ? 'right'
                        : $convex_type eq 'left' ? 'left'
                        : 0);
            print "n_limit=$n_limit  side=$side\n";
            my $points = MyOEIS::path_boundary_points ($path, $n_limit,
                                                       lattice_type => $lattice_type,
                                                       side => $side);
            ### $n_limit
            ### $points

            my $area;
            my $convex_area;
            my $boundary;
            if (@$points <= 1) {
              $area = 0;
              $boundary = 0;
            } elsif (@$points == 2) {
              $area = 0;
              my $dx = $points->[0]->[0] - $points->[1]->[0];
              my $dy = $points->[0]->[1] - $points->[1]->[1];
              my $h = $dx*$dx + $dy*$dy*($lattice_type eq 'triangular' ? 3 : 0);
              $boundary = 2*sqrt($h);
            } else {
              my $polygon = Math::Geometry::Planar->new;
              $polygon->points($points);

              # if (@$points <= 16) {
              #   print "   ",points_str($points),"\n";
              # }

              if ($convex_type eq 'convex' && @$points >= 5) {
                $polygon = $polygon->convexhull2;
                $points = $polygon->points;
              }

              $area = $polygon->area;

              if ($lattice_type eq 'triangular') {
                foreach my $p (@$points) {
                  $p->[1] *= sqrt(3);
                  # $p->[0] *= 1/2;
                  # $p->[1] *= sqrt(3)/2;
                }
                $polygon->points($points);
              }
              $boundary = $polygon->perimeter;
            }

            if ($convex_type eq 'right' || $convex_type eq 'left') {
              $boundary = scalar(@$points) - 1;
              # my ($end_x,$end_y) = $path->n_to_xy($n_limit);
              # $boundary -= hypot($end_x,$end_y);
              # $boundary = float_error($boundary);
            }
            push @areas, $area;
            push @boundaries, $boundary;

            my $notint = ($boundary == int($boundary) ? '' : ' (not int)');
            print "$level $n_limit  area=$area boundary=$boundary$notint $convex_type\n";
            if (@$points <= 10) {
              print "   ",points_str($points),"\n";
            }

            if (0) {
              require Image::Base::GD;
              my $width = 800;
              my $height = 700;
              my $scale = 40;
              my $image = Image::Base::GD->new (-width => $width, -height => $height);
              $image->rectangle (0,0, $width-1,$height-1, 'black');
              foreach my $i (0 .. $#$points) {
                my ($x1,$y1) = @{$points->[$i-1]};
                my ($x2,$y2) = @{$points->[$i]};
                $x1 *= $scale;
                $y1 *= $scale;
                $x2 *= $scale;
                $y2 *= $scale;
                $y1 = $height/2 - $y1;
                $y2 = $height/2 - $y2;
                $x1 += $width/2;
                $x2 += $width/2;
                $image->line ($x1,$y1, $x2,$y2, 'white');
              }
              $image->save('/tmp/x.png');
              require IPC::Run;
              IPC::Run::run (['xzgv','/tmp/x.png']);
            }
          }

          if ($diffs) {
            foreach my $i (reverse 1 .. $#areas) {
              $areas[$i] -= $areas[$i-1];
            }
            foreach my $i (reverse 1 .. $#boundaries) {
              $boundaries[$i] -= $boundaries[$i-1];
            }
            shift @areas;
            shift @boundaries;
          }

          foreach my $alt_type ('even','odd','all') {
            my @areas = @areas;
            my @boundaries = @boundaries;

            if ($alt_type eq 'odd') {
              aref_keep_odds(\@areas);
              aref_keep_odds(\@boundaries);
            }
            if ($alt_type eq 'even') {
              aref_keep_evens(\@areas);
              aref_keep_evens(\@boundaries);
            }

            print "\n$name area (by $inc_type $convex_type $diffs $alt_type):\n";
            shift_off_zeros(\@areas);
            print join(',',@areas),"\n";
            print MyOEIS->grep_for_values(array => \@areas);

            print "\n$name boundary (by $inc_type $convex_type $diffs $alt_type):\n";
            shift_off_zeros(\@boundaries);
            print join(',',@boundaries),"\n";
            print MyOEIS->grep_for_values(array => \@boundaries);
            print "\n";
          }
        }
      }
    }
  }

  exit 0;

  sub points_str {
    my ($points) = @_;
    ### points_str(): $points
    my $count = scalar(@$points);
    return  "count=$count  ".join(' ',map{join(',',@$_)}@$points)
  }

  # shift any leading zeros off @$aref
  sub shift_off_zeros {
    my ($aref) = @_;
    while (@$aref && ! $aref->[0]) {
      shift @$aref;
    }
  }

  sub aref_keep_odds {
    my ($aref) = @_;
    @$aref = map { $_ & 1 ? $aref->[$_] : () } 0 .. $#$aref;
  }
  sub aref_keep_evens {
    my ($aref) = @_;
    @$aref = map { $_ & 1 ? () : $aref->[$_] } 0 .. $#$aref;
  }

  BEGIN {
    my @dir6_to_dx = (2, 1,-1,-2, -1, 1);
    my @dir6_to_dy = (0, 1, 1, 0, -1,-1);

    sub path_boundary_points_triangular {
      my ($path, $n_limit) = @_;
      my @points;
      my $x = 0;
      my $y = 0;
      my $dir6 = 4;
      my @n_list = ($path->n_start);
      for (;;) {
        ### at: "$x, $y  dir6 = $dir6"
        push @points, [$x,$y];
        $dir6 -= 2;  # rotate -120
        foreach (1 .. 6) {
          $dir6 %= 6;
          my $dx = $dir6_to_dx[$dir6];
          my $dy = $dir6_to_dy[$dir6];
          my @next_n_list = $path->xy_to_n_list($x+$dx,$y+$dy);
          ### @next_n_list
          if (any_consecutive(\@n_list, \@next_n_list, $n_limit)) {
            @n_list = @next_n_list;
            $x += $dx;
            $y += $dy;
            last;
          }
          $dir6++;  # +60
        }
        if ($x == 0 && $y == 0) {
          last;
        }
      }
      return \@points;
    }
  }

}
{
  # X,Y repeat count
  require Math::NumSeq::PlanePathCoord;
  use lib 'xt'; require MyOEIS;
  foreach my $elem (
                    # curves with overlaps only
                    ['DragonCurve', 2],
                    ['R5DragonCurve', 5],
                    ['CCurve', 2],
                    ['TerdragonCurve', 3, 'triangular'],
                    ['AlternatePaper', 4],
                    ['AlternatePaper', 2],
                   ) {
    my ($name, $radix, $lattice_type) = @$elem;
    $lattice_type ||= 'square';
    my $path = Math::NumSeq::PlanePathCoord::_planepath_name_to_object($name);

    print "$name\n";
    {
      my @values;
      foreach my $n (15 .. 40) {
        my ($x,$y) = $path->n_to_xy($n);
        my @n_list = $path->xy_to_n_list($x,$y);
        my $count = scalar(@n_list);
        push @values, $count;
      }
      print "\n$name counts:\n";
      shift_off_zeros(\@values);
      print join(',',@values),"\n";
      print MyOEIS->grep_for_values(array => \@values);
      array_diffs(\@values);
      print MyOEIS->grep_for_values(array => \@values, name => "diffs");
    }
    if (0) {
      my @values;
      foreach my $level (3 .. 8) {
        my $count = 0;
        my $n_hi = $radix**($level+1) - 1;
        last if $n_hi > 50_000;
        foreach my $n ($radix**$level .. $n_hi) {
          my ($x,$y) = $path->n_to_xy($n);
          my @n_list = $path->xy_to_n_list($x,$y);
          $count += scalar(@n_list);
        }
        push @values, $count;
      }
      # if ($diffs) {
      #   foreach my $i (reverse 1 .. $#areas) {
      #     $areas[$i] -= $areas[$i-1];
      #   }
      print "\n$name total in powers $radix\n";
      shift_off_zeros(\@values);
      print join(',',@values),"\n";
      print MyOEIS->grep_for_values(array => \@values);
      print "\n";
      array_diffs(\@values);
      print MyOEIS->grep_for_values(array => \@values, name => "diffs");
    }
  }
  exit 0;

  sub array_diffs {
    my ($aref) = @_;
    foreach my $i (0 .. $#$aref-1) {
      $aref->[$i] = $aref->[$i+1] - $aref->[$i];
    }
    $#$aref--;
  }
}

{
  # boundary unit squares by powers

  require Math::NumSeq::PlanePathCoord;
  use lib 'xt'; require MyOEIS;
  foreach my $elem (
                    ['CCurve', 2],
                    ['GosperReplicate',7, 'triangular'],
                    ['Flowsnake',7, 'triangular'],
                    ['FlowsnakeCentres',7, 'triangular'],

                    ['PowerArray',2],
                    ['PowerArray,radix=3',3],

                    ['CubicBase',2, 'triangular'],
                    ['CubicBase,radix=3',3, 'triangular'],
                    ['TerdragonCurve', 3, 'triangular'],
                    ['TerdragonMidpoint', 3, 'triangular'],

                    ['QuintetCentres',5],
                    ['QuintetCurve',5],

                    ['AlternatePaperMidpoint', 2],
                    ['R5DragonCurve', 5],
                    ['ComplexPlus', 2],
                    ['ComplexMinus', 2],
                    ['DragonMidpoint', 2],

                    ['AlternatePaper', 2],
                    ['DragonCurve', 2],
                   ) {
    my ($name, $radix, $lattice_type) = @$elem;
    $lattice_type ||= 'square';

    print "$name  (lattice=$lattice_type)\n";
    my $path = Math::NumSeq::PlanePathCoord::_planepath_name_to_object($name);
    my $n_start = $path->n_start;

    my @boundaries;
    my $n = $n_start;
    my $boundary = 0;
    my $target = $radix;
    my $dboundary_func = ($lattice_type eq 'triangular'
                          ? \&path_n_to_dhexboundary
                          : \&path_n_to_dboundary);
    for (;; $n++) {
      ### at: "boundary=$boundary  now consider N=$n"
      last if @boundaries > 20;
      if ($n > $target) {
        print "$target  $boundary\n";
        push @boundaries, $boundary;
        $target *= $radix;
        last if $target > 10_000;
      }
      $boundary += $dboundary_func->($path,$n);
    }

    print "$name unit squares boundary\n";
    shift_off_zeros(\@boundaries);
    print join(',',@boundaries),"\n";
    print MyOEIS->grep_for_values(array => \@boundaries);
    print "\n";
  }

  exit 0;
}

{
  # permutation of transpose
  require MyOEIS;
  require Math::NumSeq::PlanePathCoord;
  my @choices = @{Math::NumSeq::PlanePathCoord->parameter_info_hash
    ->{'planepath'}->{'choices'}};
  @choices = grep {$_ ne 'BinaryTerms'} @choices; # bit slow yet
  my %seen;
  foreach my $path_name (@choices) {
    my $path_class = "Math::PlanePath::$path_name";
    Module::Load::load($path_class);
    my $parameters = parameter_info_list_to_parameters($path_class->parameter_info_list);
  PATH: foreach my $p (@$parameters) {
      my $name = "$path_name  ".join(',',@$p);
      my $path = $path_class->new (@$p);
      my @values;
      foreach my $n ($path->n_start+1 .. 35) {
        # my $value = (defined $path->tree_n_to_subheight($n) ? 1 : 0);

        my ($x,$y) = $path->n_to_xy($n) or next PATH;
        # # my $value = $path->xy_to_n($y,$x);  # transpose
        # my $value = $path->xy_to_n(-$x,$y);   # horiz mirror
        # my $value = $path->xy_to_n($x,-$y);   # vert mirror

        # ($x,$y) = ($y,-$x);  # rotate -90
        # ($x,$y) = ($y,$x);   # transpose
        # ($x,$y) = (-$y,$x);  # rotate +90
        my $value = $path->xy_to_n(-$y,-$x);   # mirror across opp diagonal

        next PATH if ! defined $value;
        push @values, $value;
      }
      print MyOEIS->grep_for_values(name => $name,
                                    array => \@values);
    }
  }
  exit 0;
}



{
  # tree row totals

  require Math::NumSeq::PlanePathCoord;
  my @choices = @{Math::NumSeq::PlanePathCoord->parameter_info_hash
      ->{'planepath'}->{'choices'}};
  @choices = grep {$_ ne 'CellularRule'} @choices;
  @choices = grep {$_ ne 'UlamWarburtonAway'} @choices; # not working yet
  @choices = grep {$_ !~ /EToothpick|LToothpick|Surround|Peninsula/} @choices;

  my $num_choices = scalar(@choices);
  print "$num_choices choices\n";

  my @path_objects;
  my %path_fullnames;
  foreach my $name (@choices) {
    my $class = "Math::PlanePath::$name";
    ### $class
    Module::Load::load($class);

    my $parameters = parameter_info_list_to_parameters
      ($class->parameter_info_list);
    foreach my $p (@$parameters) {
      my $path_object = $class->new (@$p);
      push @path_objects, $path_object;
      $path_fullnames{$path_object} = "$name ".join(',',@$p);
    }
  }
  my $num_path_objects = scalar(@path_objects);
  print "total path objects $num_path_objects\n";

  my $start_t = time();
  my $t = $start_t-8;

  my $i = 0;
  # until ($path_objects[$i]->isa('Math::PlanePath::DragonCurve')) {
  #   $i++;
  # }

  for ( ; $i <= $#path_objects; $i++) {
    my $path = $path_objects[$i];
    next unless $path->x_negative || $path->y_negative;
    path_is_tree($path) or next;

    my $fullname = $path_fullnames{$path};
    print "$fullname  (",ref $path,")\n";

    my @x_total;
    my @y_total;
    my @sum_total;
    my @diff_total;
    my $target_depth = 0;
    my $target = $path->tree_depth_to_n_end($target_depth);
    for (my $n = $path->n_start; $n < 10_000; $n++) {
      my ($x,$y) = $path->n_to_xy($n);
      my $depth = $path->tree_n_to_depth($n);
      $x = abs($x);
      $y = abs($y);
      $x_total[$depth] += $x;
      $y_total[$depth] += $y;
      $sum_total[$depth] += $x + $y;
      $diff_total[$depth] += $x - $y;

      if ($n == $target) {
        print "$target_depth   $x_total[$target_depth] $y_total[$target_depth]\n";
        $target_depth++;
        last if $target_depth > 12;
        $target = $path->tree_depth_to_n_end($target_depth);
      }
    }
    $#x_total = $target_depth-1;
    $#y_total = $target_depth-1;
    $#sum_total = $target_depth-1;
    $#diff_total = $target_depth-1;

    print "X rows\n";
    print MyOEIS->grep_for_values(array => \@x_total);
    print "\n";

    print "Y rows\n";
    print MyOEIS->grep_for_values(array => \@y_total);
    print "\n";

    print "X+Y rows\n";
    print MyOEIS->grep_for_values(array => \@sum_total);
    print "\n";

    print "X-Y rows\n";
    print MyOEIS->grep_for_values(array => \@diff_total);
    print "\n";
  }
  exit 0;
}


{
  # boundary length by N, unit squares

  require Math::NumSeq::PlanePathCoord;
  my @choices = @{Math::NumSeq::PlanePathCoord->parameter_info_hash
      ->{'planepath'}->{'choices'}};
  @choices = grep {$_ ne 'CellularRule'} @choices;
  @choices = grep {$_ ne 'ArchimedeanChords'} @choices;
  @choices = grep {$_ ne 'TheodorusSpiral'} @choices;
  @choices = grep {$_ ne 'MultipleRings'} @choices;
  @choices = grep {$_ ne 'VogelFloret'} @choices;
  @choices = grep {$_ ne 'UlamWarburtonAway'} @choices;
  @choices = grep {$_ !~ /Hypot|ByCells|SumFractions|WythoffTriangle/} @choices;
  @choices = grep {$_ ne 'PythagoreanTree'} @choices;
  # @choices = grep {$_ ne 'PeanoHalf'} @choices;
  @choices = grep {$_ !~ /EToothpick|LToothpick|Surround|Peninsula/} @choices;
  #
  # @choices = grep {$_ ne 'CornerReplicate'} @choices;
  # @choices = grep {$_ ne 'ZOrderCurve'} @choices;
  # unshift @choices, 'CornerReplicate', 'ZOrderCurve';

  my $num_choices = scalar(@choices);
  print "$num_choices choices\n";

  @choices = ((grep {/Corner|Tri/} @choices),
              (grep {!/Corner|Tri/} @choices));

  my @path_objects;
  my %path_fullnames;
  foreach my $name (@choices) {
    my $class = "Math::PlanePath::$name";
    ### $class
    Module::Load::load($class);

    my $parameters = parameter_info_list_to_parameters
      ($class->parameter_info_list);
    foreach my $p (@$parameters) {
      my $path_object = $class->new (@$p);
      push @path_objects, $path_object;
      $path_fullnames{$path_object} = "$name ".join(',',@$p);
    }
  }
  my $num_path_objects = scalar(@path_objects);
  print "total path objects $num_path_objects\n";

  my $start_t = time();
  my $t = $start_t-8;

  my $i = 0;
  # until ($path_objects[$i]->isa('Math::PlanePath::DragonCurve')) {
  #   $i++;
  # }
  my $start_permutations = $i * ($num_path_objects-1);
  my $num_permutations = $num_path_objects * ($num_path_objects-1);

  for ( ; $i <= $#path_objects; $i++) {
    my $path = $path_objects[$i];
    my $fullname = $path_fullnames{$path};
    print "$fullname\n";

    my $x_minimum = $path->x_minimum;
    my $y_minimum = $path->y_minimum;

    my $str = '';
    my @values;
    my $boundary = 0;
    foreach my $n ($path->n_start .. 30) {
      # $boundary += path_n_to_dboundary($path,$n);
      # $boundary += path_n_to_dsticks($path,$n);
      # $boundary += path_n_to_dhexboundary($path,$n);
      $boundary += path_n_to_dhexsticks($path,$n);

      my $value = $boundary;
      $str .= "$value,";
      push @values, $value;
    }
    shift @values;
    if (defined (my $diff = constant_diff(@values))) {
      print "$fullname\n";
      print "  constant diff $diff\n";
      next;
    }
    print "$str\n";
    if (my $found = stripped_grep($str)) {
      print "$fullname  match\n";
      print "  (",substr($str,0,60),"...)\n";
      print $found;
      print "\n";
    }
  }
  exit 0;
}

{
  # permutation between two paths

  require Math::NumSeq::PlanePathCoord;
  my @choices = @{Math::NumSeq::PlanePathCoord->parameter_info_hash
      ->{'planepath'}->{'choices'}};

  @choices = grep {$_ ne 'CellularRule'} @choices;
  @choices = grep {$_ ne 'Rows'} @choices;
  @choices = grep {$_ ne 'Columns'} @choices;
  @choices = grep {$_ ne 'ArchimedeanChords'} @choices;
  @choices = grep {$_ ne 'MultipleRings'} @choices;
  @choices = grep {$_ ne 'VogelFloret'} @choices;
  @choices = grep {$_ ne 'PythagoreanTree'} @choices;
  @choices = grep {$_ ne 'PeanoHalf'} @choices;
  @choices = grep {$_ !~ /EToothpick|LToothpick|Surround|Peninsula/} @choices;

  @choices = grep {$_ ne 'CornerReplicate'} @choices;
  @choices = grep {$_ ne 'ZOrderCurve'} @choices;
  unshift @choices, 'CornerReplicate', 'ZOrderCurve';

  @choices = ('PythagoreanTree');

  my $num_choices = scalar(@choices);
  print "$num_choices choices\n";

  my @path_objects;
  my %path_fullnames;
  foreach my $name (@choices) {
    my $class = "Math::PlanePath::$name";
    Module::Load::load($class);

    my $parameters = parameter_info_list_to_parameters
      ($class->parameter_info_list);
    foreach my $p (@$parameters) {
      my $path_object = $class->new (@$p);
      push @path_objects, $path_object;
      $path_fullnames{$path_object} = "$name ".join(',',@$p);
    }
  }
  my $num_path_objects = scalar(@path_objects);
  print "total path objects $num_path_objects\n";

  my $start_t = time();
  my $t = $start_t-8;

  my $i = 0;
  # until ($path_objects[$i]->isa('Math::PlanePath::DiamondArms')) {
  #   $i++;
  # }
  # while ($path_objects[$i]->isa('Math::PlanePath::PyramidSpiral')) {
  #   $i++;
  # }

  my $start_permutations = $i * ($num_path_objects-1);
  my $num_permutations = $num_path_objects * ($num_path_objects-1);

  open DEBUG, '>/tmp/permutations.out' or die;
  select DEBUG or die; $| = 1; # autoflush
  select STDOUT or die;

  for ( ; $i <= $#path_objects; $i++) {
    my $from_path = $path_objects[$i];
    my $from_fullname = $path_fullnames{$from_path};
    my $n_start = $from_path->n_start;

  PATH: foreach my $j (0 .. $#path_objects) {
      if (time()-$t < 0 || time()-$t > 10) {
        my $upto_permutation = $i*$num_path_objects + $j || 1;
        my $rem_permutation = $num_permutations
          - ($start_permutations + $upto_permutation);
        my $done_permutations = ($upto_permutation-$start_permutations);
        my $percent = 100 * $done_permutations / $num_permutations || 1;
        my $t_each = (time() - $start_t) / $done_permutations;
        my $done_per_second = $done_permutations / (time() - $start_t);
        my $eta = int($t_each * $rem_permutation);
        my $s = $eta % 60; $eta = int($eta/60);
        my $m = $eta % 60; $eta = int($eta/60);
        my $h = $eta;
        my $eta_str = sprintf '%d:%02d:%02d', $h,$m,$s;
        print "$upto_permutation / $num_permutations  est $eta_str  (each $t_each)\n";
        $t = time();
      }

      next if $i == $j;
      my $to_path = $path_objects[$j];
      next if $to_path->n_start != $n_start;
      my $to_fullname = $path_fullnames{$to_path};
      my $name = "$from_fullname -> $to_fullname";

      print DEBUG "$name\n";

      my $str = '';
      my @values;
      foreach my $n ($n_start+2 .. $n_start+50) {
        my ($x,$y) = $from_path->n_to_xy($n)
          or next PATH;
        my $pn = $to_path->xy_to_n($x,$y) // next PATH;
        $str .= "$pn,";
        push @values, $pn;
      }
      print MyOEIS->grep_for_values(name => $name,
                                    array => \@values);

      # if (defined (my $diff = constant_diff(@values))) {
      #   print "$from_fullname -> $to_fullname\n";
      #   print "  constant diff $diff\n";
      #   next PATH;
      # }
      # if (my $found = stripped_grep($str)) {
      #   print "$from_fullname -> $to_fullname\n";
      #   print "  (",substr($str,0,20),"...)\n";
      #   print $found;
      #   print "\n";
      # }
    }
  }
  exit 0;
}



BEGIN {
  my @dir4_to_dx = (1,0,-1,0);
  my @dir4_to_dy = (0,1,0,-1);

  sub path_n_to_dboundary {
    my ($path, $n) = @_;
    my ($x,$y) = $path->n_to_xy($n) or return 0;
    {
      my @n_list = $path->xy_to_n_list($x,$y);
      if ($n > $n_list[0]) {
        return 0;
      }
    }
    my $dboundary = 4;
    foreach my $i (0 .. $#dir4_to_dx) {
      my $an = $path->xy_to_n($x+$dir4_to_dx[$i], $y+$dir4_to_dy[$i]);
      $dboundary -= 2*(defined $an && $an < $n);
    }
    return $dboundary;
  }
  sub path_n_to_dsticks {
    my ($path, $n) = @_;
    my ($x,$y) = $path->n_to_xy($n) or return 0;
    my $dsticks = 4;
    foreach my $i (0 .. $#dir4_to_dx) {
      my $an = $path->xy_to_n($x+$dir4_to_dx[$i], $y+$dir4_to_dy[$i]);
      $dsticks -= (defined $an && $an < $n);
    }
    return $dsticks;
  }
}
BEGIN {
  my @dir6_to_dx = (2, 1,-1,-2, -1, 1);
  my @dir6_to_dy = (0, 1, 1, 0, -1,-1);

  # Return the change in boundary length when hexagon $n is added.
  # This is +6 if it's completely isolated, and 2 less for each neighbour
  # < $n since 1 side of the neighbour and 1 side of $n are then not
  # boundaries.
  #
  sub path_n_to_dhexboundary {
    my ($path, $n) = @_;
    my ($x,$y) = $path->n_to_xy($n) or return 0;
    my $dboundary = 6;
    foreach my $i (0 .. $#dir6_to_dx) {
      my $an = $path->xy_to_n($x+$dir6_to_dx[$i], $y+$dir6_to_dy[$i]);
      $dboundary -= 2*(defined $an && $an < $n);
    }
    ### $dboundary
    return $dboundary;
  }
  sub path_n_to_dhexsticks {
    my ($path, $n) = @_;
    my ($x,$y) = $path->n_to_xy($n) or return 0;
    my $dboundary = 6;
    foreach my $i (0 .. $#dir6_to_dx) {
      my $an = $path->xy_to_n($x+$dir6_to_dx[$i], $y+$dir6_to_dy[$i]);
      $dboundary -= (defined $an && $an < $n);
    }
    return $dboundary;
  }
}

{
  # path classes with or without n_start
  require Math::NumSeq::PlanePathCoord;
  my @choices = @{Math::NumSeq::PlanePathCoord->parameter_info_hash
      ->{'planepath'}->{'choices'}};

  my (@with, @without);
  foreach my $name (@choices) {
    my $class = "Math::PlanePath::$name";
    Module::Load::load($class);
    my $href = $class->parameter_info_hash;
    if ($href->{'n_start'}) {
      push @with, $class;
    } else {
      push @without, $class;
    }
  }
  foreach my $aref (\@without, \@with) {
    foreach my $class (@$aref) {
      my @pnames = map {$_->{'name'}} $class->parameter_info_list;
      my $href = $class->parameter_info_hash;
      my $w = ($href->{'n_start'} ? 'with' : 'without');
      print "  $class [$w] ",join(',',@pnames),"\n";
      # print "    ",join(', ',keys %$href),"\n";
    }
    print "\n\n";
  }
  exit 0;
}

{
  require Math::PlanePath::DragonCurve;
  my $path = Math::PlanePath::DragonCurve->new;
  my @values;
  foreach my $n (3 .. 32) {
    my ($x,$y) = $path->n_to_xy(2*$n);
    # push @values,-$x-1;
    my $transitions = transitions($n);
    push @values, (($transitions%4)/2);
    # push @values, $transitions;
  }
  my $values = join(',',@values);
  print "$values\n";
  print MyOEIS->grep_for_values_aref(\@values);
  exit 0;

  # transitions(2n)/2 = A069010 Number of runs of 1's
  sub transitions {
    my ($n) = @_;
    my $count = 0;
    while ($n) {
      $count += (($n & 3) == 1 || ($n & 3) == 2);
      $n >>= 1;
    }
    return $count
  }
}


{
  # X,Y at N=2^k
  require Math::NumSeq::PlanePathCoord;
  my @choices = @{Math::NumSeq::PlanePathCoord->parameter_info_hash
      ->{'planepath'}->{'choices'}};
  @choices = grep {$_ ne 'CellularRule'} @choices;
  # @choices = grep {$_ ne 'Rows'} @choices;
  # @choices = grep {$_ ne 'Columns'} @choices;
  @choices = grep {$_ ne 'ArchimedeanChords'} @choices;
  @choices = grep {$_ ne 'TheodorusSpiral'} @choices;
  @choices = grep {$_ ne 'MultipleRings'} @choices;
  @choices = grep {$_ ne 'VogelFloret'} @choices;
  @choices = grep {$_ ne 'UlamWarburtonAway'} @choices;
  @choices = grep {$_ !~ /Hypot|ByCells|SumFractions|WythoffTriangle/} @choices;
  # @choices = grep {$_ ne 'PythagoreanTree'} @choices;
  # @choices = grep {$_ ne 'PeanoHalf'} @choices;
  @choices = grep {$_ !~ /EToothpick|LToothpick|Surround|Peninsula/} @choices;
  #
  # @choices = grep {$_ ne 'CornerReplicate'} @choices;
  # @choices = grep {$_ ne 'ZOrderCurve'} @choices;
  # unshift @choices, 'CornerReplicate', 'ZOrderCurve';

  my $num_choices = scalar(@choices);
  print "$num_choices choices\n";

  my @path_objects;
  my %path_fullnames;
  foreach my $name (@choices) {
    my $class = "Math::PlanePath::$name";
    ### $class
    Module::Load::load($class);

    my $parameters = parameter_info_list_to_parameters
      ($class->parameter_info_list);
    foreach my $p (@$parameters) {
      my $path_object = $class->new (@$p);
      push @path_objects, $path_object;
      $path_fullnames{$path_object} = "$name ".join(',',@$p);
    }
  }
  my $num_path_objects = scalar(@path_objects);
  print "total path objects $num_path_objects\n";

  my $start_t = time();
  my $t = $start_t-8;

  my $i = 0;
  until ($path_objects[$i]->isa('Math::PlanePath::DragonCurve')) {
    $i++;
  }
  my $start_permutations = $i * ($num_path_objects-1);
  my $num_permutations = $num_path_objects * ($num_path_objects-1);

  for ( ; $i <= $#path_objects; $i++) {
    my $path = $path_objects[$i];
    my $fullname = $path_fullnames{$path};
    print "$fullname\n";
    foreach my $coord_idx (0, 1) {
      my $fullname = $fullname." ".($coord_idx?'Y':'X');
      HALF: foreach my $half (0,1) {
        my $fullname = $fullname.($half?'/2':'');
        my $str = '';
        my @values;
        foreach my $k (1 .. 20) {
          my @coords = $path->n_to_xy(2**$k);
          my $value = $coords[$coord_idx];
          if ($half) { $value /= 2; }
          $str .= "$value,";
          push @values, $value;
        }
        shift @values;
        if (defined (my $diff = constant_diff(@values))) {
          print "$fullname\n";
          print "  constant diff $diff\n";
          next;
        }
        if (my $found = stripped_grep($str)) {
          print "$fullname  match\n";
          print "  (",substr($str,0,60),"...)\n";
          print $found;
          print "\n";
        }
      }
    }
  }
  exit 0;
}

{
  # tree row increments
  require Math::NumSeq::PlanePathCoord;
  my @choices = @{Math::NumSeq::PlanePathCoord->parameter_info_hash
      ->{'planepath'}->{'choices'}};

  # @choices = grep {$_ ne 'CellularRule'} @choices;
  # @choices = grep {$_ ne 'Rows'} @choices;
  # @choices = grep {$_ ne 'Columns'} @choices;
  # @choices = grep {$_ ne 'ArchimedeanChords'} @choices;
  @choices = grep {$_ ne 'MultipleRings'} @choices;
  @choices = grep {$_ ne 'VogelFloret'} @choices;
  @choices = grep {$_ !~ /ByCells/} @choices;
  # @choices = grep {$_ ne 'PythagoreanTree'} @choices;
  # @choices = grep {$_ ne 'PeanoHalf'} @choices;
  # @choices = grep {$_ !~ /EToothpick|LToothpick|Surround|Peninsula/} @choices;
  #
  # @choices = grep {$_ ne 'CornerReplicate'} @choices;
  # @choices = grep {$_ ne 'ZOrderCurve'} @choices;
  # unshift @choices, 'CornerReplicate', 'ZOrderCurve';

  my $num_choices = scalar(@choices);
  print "$num_choices choices\n";

  my @path_objects;
  my %path_fullnames;
  foreach my $name (@choices) {
    my $class = "Math::PlanePath::$name";
    ### $class
    Module::Load::load($class);

    my $parameters = parameter_info_list_to_parameters
      ($class->parameter_info_list);
    foreach my $p (@$parameters) {
      my $path_object = $class->new (@$p);
      push @path_objects, $path_object;
      $path_fullnames{$path_object} = "$name ".join(',',@$p);
    }
  }
  my $num_path_objects = scalar(@path_objects);
  print "total path objects $num_path_objects\n";

  my $start_t = time();
  my $t = $start_t-8;

  my $i = 0;
  # until ($path_objects[$i]->isa('Math::PlanePath::DiamondArms')) {
  #   $i++;
  # }

  my $start_permutations = $i * ($num_path_objects-1);
  my $num_permutations = $num_path_objects * ($num_path_objects-1);

  for ( ; $i <= $#path_objects; $i++) {
    my $path = $path_objects[$i];
    my $fullname = $path_fullnames{$path};
    my $n_start = $path->n_start;
    path_is_tree($path) or next;
    print "$fullname\n";

    # if (time()-$t < 0 || time()-$t > 10) {
    #   my $upto_permutation = $i*$num_path_objects + $j || 1;
    #   my $rem_permutation = $num_permutations
    #     - ($start_permutations + $upto_permutation);
    #   my $done_permutations = ($upto_permutation-$start_permutations);
    #   my $percent = 100 * $done_permutations / $num_permutations || 1;
    #   my $t_each = (time() - $start_t) / $done_permutations;
    #   my $done_per_second = $done_permutations / (time() - $start_t);
    #   my $eta = int($t_each * $rem_permutation);
    #   my $s = $eta % 60; $eta = int($eta/60);
    #   my $m = $eta % 60; $eta = int($eta/60);
    #   my $h = $eta;
    #   print "$upto_permutation / $num_permutations  est $h:$m:$s  (each $t_each)\n";
    #   $t = time();
    # }

    my $str = '';
    my @values;
    foreach my $depth (1 .. 50) {
      # my $value = $path->tree_depth_to_width($depth) // next;
      my $value = $path->tree_depth_to_n($depth) % 2;
      $str .= "$value,";
      push @values, $value;
    }
    if (defined (my $diff = constant_diff(@values))) {
      print "$fullname\n";
      print "  constant diff $diff\n";
      next;
    }
    if (my $found = stripped_grep($str)) {
      print "$fullname  match\n";
      print "  (",substr($str,0,60),"...)\n";
      print $found;
      print "\n";
    }
  }
  exit 0;

}


{
  require Math::NumSeq::PlanePathCoord;
  my @choices = @{Math::NumSeq::PlanePathCoord->parameter_info_hash
      ->{'planepath'}->{'choices'}};

  my $num_choices = scalar(@choices);
  print "$num_choices choices\n";

  my @path_objects;
  my %path_fullnames;
  foreach my $name (@choices) {
    my $class = "Math::PlanePath::$name";
    Module::Load::load($class);

    my $parameters = parameter_info_list_to_parameters
      ($class->parameter_info_list);
    foreach my $p (@$parameters) {
      my $path_object = $class->new (@$p);
      push @path_objects, $path_object;
      $path_fullnames{$path_object} = "$name ".join(',',@$p);
    }
  }
  my $num_path_objects = scalar(@path_objects);
  print "total path objects $num_path_objects\n";

  my %seen;
  foreach my $path (@path_objects) {
    print $path_fullnames{$path},"\n";

    my $any_x_neg = 0;
    my $any_y_neg = 0;
    my (@x,@y,@n);
    foreach my $n ($path->n_start+2 .. 50) {
      my ($x,$y) = $path->n_to_xy($n)
        or last;
      push @x, $x;
      push @y, $y;
      push @n, $n;
      $any_x_neg ||= ($x < 0);
      $any_y_neg ||= ($y < 0);
    }
    next unless $any_x_neg || $any_y_neg;

    foreach my $x_axis_pos ($any_y_neg ? -1 : (),
                            0, 1) {

      foreach my $x_axis_neg (($any_y_neg ? (-1) : ()),
                              0,
                              ($any_x_neg ? (1) : ())) {

        foreach my $y_axis_pos ($any_x_neg ? -1 : (),
                                0, 1) {

          foreach my $y_axis_neg ($any_x_neg ? (-1) : (),
                                  0,
                                  ($any_y_neg ? (1) : ())) {

            my $fullname = $path_fullnames{$path} . " Xpos=$x_axis_pos Xneg=$x_axis_neg Ypos=$y_axis_pos Yneg=$y_axis_neg";

            my @values;
            my $str = '';
            foreach my $i (0 .. $#x) {
              if (($x[$i]<=>0) == ($y[$i]<0 ? $y_axis_neg : $y_axis_pos)
                  && ($y[$i]<=>0) == ($x[$i]<0 ? $x_axis_neg : $x_axis_pos)
                 ) {
                push @values, $n[$i];
                $str .= "$n[$i],";
              }
            }
            next unless @values >= 5;

            if (my $prev_fullname = $seen{$str}) {
              print "$fullname\n";
              print "repeat of $prev_fullname";
              print "\n";
            } else {
              if (my $found = stripped_grep($str)) {
                print "$fullname\n";
                print "  (",substr($str,0,20),"...)\n";
                print $found;
                print "\n";
                print "\n";
                $seen{$str} = $fullname;
              }
            }
          }
        }
      }
    }
  }
  exit 0;
}


# sub stripped_grep {
#   my ($str) = @_;
#   my $find = `fgrep -e $str $ENV{HOME}/OEIS/stripped`;
#   my $ret = '';
#   foreach my $line (split /\n/, $find) {
#     $ret .= "$line\n";
#     my ($anum) = ($line =~ /^(A\d+)/) or die;
#     $ret .= `zgrep -e ^$anum $ENV{HOME}/OEIS/names.gz`;
#   }
#   return $ret;
# }

my $stripped;
sub stripped_grep {
  my ($str) = @_;
  if (! $stripped) {
    require File::Map;
    my $filename = "$ENV{HOME}/OEIS/stripped";
    File::Map::map_file ($stripped, $filename);
    print "File::Map file length ",length($stripped),"\n";
  }
  my $ret = '';
  my $pos = 0;
  for (;;) {
    $pos = index($stripped,$str,$pos);
    last if $pos < 0;
    my $start = rindex($stripped,"\n",$pos) + 1;
    my $end = index($stripped,"\n",$pos);
    my $line = substr($stripped,$start,$end-$start);
    $ret .= "$line\n";
    my ($anum) = ($line =~ /^(A\d+)/);
    $anum || die "$anum not found";
    $ret .= `zgrep -e ^$anum $ENV{HOME}/OEIS/names.gz`;
    $pos = $end;
  }
  return $ret;
}












#------------------------------------------------------------------------------

# ($inforef, $inforef, ...)
sub parameter_info_list_to_parameters {
  my @parameters = ([]);
  foreach my $info (@_) {
    info_extend_parameters($info,\@parameters);
  }
  return \@parameters;
}

sub info_extend_parameters {
  my ($info, $parameters) = @_;
  my @new_parameters;

  if ($info->{'name'} eq 'planepath') {
    my @strings;
    foreach my $choice (@{$info->{'choices'}}) {
      # next unless $choice =~ /DiamondSpiral/;
      # next unless $choice =~ /Gcd/;
      # next unless $choice =~ /LCorn|RationalsTree/;
      next unless $choice =~ /dragon/i;
      # next unless $choice =~ /SierpinskiArrowheadC/;
      # next unless $choice eq 'DiagonalsAlternating';
      my $path_class = "Math::PlanePath::$choice";
      Module::Load::load($path_class);

      my @parameter_info_list = $path_class->parameter_info_list;

      {
        my $path = $path_class->new;
        if (defined $path->{'n_start'}
            && ! $path_class->parameter_info_hash->{'n_start'}) {
          push @parameter_info_list,{ name      => 'n_start',
                                      type      => 'enum',
                                      choices   => [0,1],
                                      default   => $path->default_n_start,
                                    };
        }
      }

      if ($path_class->isa('Math::PlanePath::Rows')) {
        push @parameter_info_list,{ name       => 'width',
                                    type       => 'integer',
                                    width      => 3,
                                    default    => '1',
                                    minimum    => 1,
                                  };
      }
      if ($path_class->isa('Math::PlanePath::Columns')) {
        push @parameter_info_list, { name       => 'height',
                                     type       => 'integer',
                                     width      => 3,
                                     default    => '1',
                                     minimum    => 1,
                                   };
      }

      my $path_parameters
        = parameter_info_list_to_parameters(@parameter_info_list);
      ### $path_parameters

      foreach my $aref (@$path_parameters) {
        my $str = $choice;
        while (@$aref) {
          $str .= "," . shift(@$aref) . '=' . shift(@$aref);
        }
        push @strings, $str;
      }
    }
    ### @strings
    foreach my $p (@$parameters) {
      foreach my $choice (@strings) {
        push @new_parameters, [ @$p, $info->{'name'}, $choice ];
      }
    }
    @$parameters = @new_parameters;
    return;
  }

  if ($info->{'choices'}) {
    my @new_parameters;
    foreach my $p (@$parameters) {
      foreach my $choice (@{$info->{'choices'}}) {
        next if ($info->{'name'} eq 'serpentine_type' && $choice eq 'Peano');
        next if ($info->{'name'} eq 'rotation_type' && $choice eq 'custom');
        push @new_parameters, [ @$p, $info->{'name'}, $choice ];
      }
      if ($info->{'name'} eq 'serpentine_type') {
        push @new_parameters, [ @$p, $info->{'name'}, '100_000_000' ];
        push @new_parameters, [ @$p, $info->{'name'}, '101_010_101' ];
        push @new_parameters, [ @$p, $info->{'name'}, '000_111_000' ];
        push @new_parameters, [ @$p, $info->{'name'}, '111_000_111' ];
      }
    }
    @$parameters = @new_parameters;
    return;
  }

  if ($info->{'type'} eq 'boolean') {
    my @new_parameters;
    foreach my $p (@$parameters) {
      foreach my $choice (0, 1) {
        push @new_parameters, [ @$p, $info->{'name'}, $choice ];
      }
    }
    @$parameters = @new_parameters;
    return;
  }

  if ($info->{'type'} eq 'integer'
      || $info->{'name'} eq 'multiples') {
    my @choices;
    if ($info->{'name'} eq 'radix') { @choices = (2,3,10,16); }
    if ($info->{'name'} eq 'n_start') { @choices = (0,1); }
    if ($info->{'name'} eq 'x_start'
        || $info->{'name'} eq 'y_start') { @choices = ($info->{'default'}); }

    if (! @choices) {
      my $min = $info->{'minimum'} // -5;
      my $max = $min + 10;
      if (# $module =~ 'PrimeIndexPrimes' &&
          $info->{'name'} eq 'level') { $max = 5; }
      # if ($info->{'name'} eq 'arms') { $max = 2; }
      if ($info->{'name'} eq 'rule') { $max = 255; }
      if ($info->{'name'} eq 'round_count') { $max = 20; }
      if ($info->{'name'} eq 'straight_spacing') { $max = 1; }
      if ($info->{'name'} eq 'diagonal_spacing') { $max = 1; }
      if ($info->{'name'} eq 'radix') { $max = 17; }
      if ($info->{'name'} eq 'realpart') { $max = 3; }
      if ($info->{'name'} eq 'wider') { $max = 1; }
      if ($info->{'name'} eq 'modulus') { $max = 32; }
      if ($info->{'name'} eq 'polygonal') { $max = 32; }
      if ($info->{'name'} eq 'factor_count') { $max = 12; }
      if ($info->{'name'} eq 'diagonal_length') { $max = 5; }
      if ($info->{'name'} eq 'height') { $max = 4; }
      if ($info->{'name'} eq 'width') { $max = 4; }
      if ($info->{'name'} eq 'k') { $max = 4; }

      if (defined $info->{'maximum'} && $max > $info->{'maximum'}) {
        $max = $info->{'maximum'};
      }
      if ($info->{'name'} eq 'power' && $max > 6) { $max = 6; }
      @choices = ($min .. $max);
    }

    my @new_parameters;
    foreach my $choice (@choices) {
      foreach my $p (@$parameters) {
        push @new_parameters, [ @$p, $info->{'name'}, $choice ];
      }
    }
    @$parameters = @new_parameters;
    return;
  }

  if ($info->{'name'} eq 'fraction') {
    ### fraction ...
    my @new_parameters;
    foreach my $p (@$parameters) {
      my $radix = p_radix($p) || die;
      foreach my $den (995 .. 1021) {
        next if $den % $radix == 0;
        my $choice = "1/$den";
        push @new_parameters, [ @$p, $info->{'name'}, $choice ];
      }
      foreach my $num (2 .. 10) {
        foreach my $den ($num+1 .. 15) {
          next if $den % $radix == 0;
          next unless _coprime($num,$den);
          my $choice = "$num/$den";
          push @new_parameters, [ @$p, $info->{'name'}, $choice ];
        }
      }
    }
    @$parameters = @new_parameters;
    return;
  }

  print "  skip parameter $info->{'name'}\n";
}

# return true if coprime
sub _coprime {
  my ($x, $y) = @_;
  ### _coprime(): "$x,$y"
  if ($y > $x) {
    ($x,$y) = ($y,$x);
  }
  for (;;) {
    if ($y <= 1) {
      ### result: ($y == 1)
      return ($y == 1);
    }
    ($x,$y) = ($y, $x % $y);
  }
}

sub p_radix {
  my ($p) = @_;
  for (my $i = 0; $i < @$p; $i += 2) {
    if ($p->[$i] eq 'radix') {
      return $p->[$i+1];
    }
  }
  return undef;
}

sub path_is_tree {
  my ($path) = @_;
  return $path->tree_n_num_children($path->n_start);
}

sub float_error {
  my ($x) = @_;
  if (abs($x - int($x)) < 0.000001) {
    return int($x);
  } else {
    return $x;
  }
}

__END__
