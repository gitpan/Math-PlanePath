#!/usr/bin/perl -w

# Copyright 2011, 2012 Kevin Ryde

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

# uncomment this to run the ### lines
#use Smart::Comments;



{
  # PlanePathCoord increasing
  require Math::NumSeq::PlanePathCoord;
  my $planepath;
  $planepath = "ImaginaryBase,radix=37";
 COORDINATE_TYPE: foreach my $coordinate_type ('X',
                                               'Y',
                                              ) {
    my $seq = Math::NumSeq::PlanePathCoord->new
      (
       planepath => $planepath,
       coordinate_type => $coordinate_type,
      );
    ### $seq

    my $i_start = $seq->i_start;
    my $prev_value;
    my $prev_i;
    my $i_limit = 100000;
    my $i_end = $i_start + $i_limit;
    for my $i ($i_start .. $i_end) {
      my $value = $seq->ith($i);
      next if ! defined $value;
      ### $value
      if (defined $prev_value && $value < $prev_value) {
        # print "$coordinate_type_type   decrease at i=$i  value=$value cf prev=$prev\n";
        my $path = $seq->{'planepath_object'};
        my ($prev_x,$prev_y) = $path->n_to_xy($prev_value);
        my ($x,$y) = $path->n_to_xy($value);
        print "$coordinate_type not i=$i value=$value cf prev_value=$prev_value\n";
        next COORDINATE_TYPE;
      }
      $prev_i = $i;
      $prev_value = $value;
    }
    print "$coordinate_type   all increasing (to i=$prev_i)\n";
  }
  exit 0;
}


{
  # axis increasing
  my $radix = 4;
  my $rsquared = $radix * $radix;
  my $re = '.' x $radix;

  require Math::NumSeq::PlanePathN;
  my $planepath;
  $planepath = "AlternatePaperMidpoint,arms=7";
  $planepath = "ImaginaryBase,radix=37";
  $planepath = "ImaginaryHalf,radix=37";
 LINE_TYPE: foreach my $line_type ('Y_axis',
                                   'Diagonal_SE',
                                   'Diagonal_SW',
                                   'Diagonal_NW',
                                   'Diagonal') {
    my $seq = Math::NumSeq::PlanePathN->new
      (
       planepath => $planepath,
       line_type => $line_type,
      );
    ### $seq

    my $i_start = $seq->i_start;
    my $prev_value = -1;
    my $prev_i = -1;
    my $i_limit = 100000;
    my $i_end = $i_start + $i_limit;
    for my $i ($i_start .. $i_end) {
      my $value = $seq->ith($i);
      next if ! defined $value;
      ### $value
      if ($value <= $prev_value) {
        # print "$line_type_type   decrease at i=$i  value=$value cf prev=$prev\n";
        my $path = $seq->{'planepath_object'};
        my ($prev_x,$prev_y) = $path->n_to_xy($prev_value);
        my ($x,$y) = $path->n_to_xy($value);
        print "$line_type not   N=$prev_value $prev_x,$prev_y  N=$value $x,$y\n";
        next LINE_TYPE;
      }
      $prev_i = $i;
      $prev_value = $value;
    }
    print "$line_type   all increasing (to i=$prev_i)\n";
  }
  exit 0;
}

{
  require Math::NumSeq::PlanePathCoord;
  foreach my $path_type (@{Math::NumSeq::PlanePathCoord->parameter_info_array->[0]->{'choices'}}) {
    my $class = "Math::PlanePath::$path_type";
    ### $class
    eval "require $class; 1" or die;
    my @pinfos = $class->parameter_info_list;
    my $params = parameter_info_list_to_parameters(@pinfos);

  PAREF:
    foreach my $paref (@$params) {
      ### $paref
      my $path = $class->new(@$paref);
      my $seq = Math::NumSeq::PlanePathCoord->new(planepath_object => $path,
                                                  coordinate_type => 'RSquared');

      foreach (1 .. 10) {
        $seq->next;
      }
      foreach (1 .. 1000) {
        my ($i, $value) = $seq->next;
        if (! defined $i || $value < $i) {
          next PAREF;
        }
      }
      print "$path_type ",join(',',@$paref),"\n";
    }
  }
  exit 0;

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
        my $path_class = "Math::PlanePath::$choice";
        Module::Load::load($path_class);

        my @parameter_info_list = $path_class->parameter_info_list;

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

    if ($info->{'name'} eq 'arms') {
      print "  skip parameter $info->{'name'}\n";
      return;
    }

    if ($info->{'choices'}) {
      my @new_parameters;
      foreach my $p (@$parameters) {
        foreach my $choice (@{$info->{'choices'}}) {
          next if ($info->{'name'} eq 'rotation_type' && $choice eq 'custom');
          push @new_parameters, [ @$p, $info->{'name'}, $choice ];
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
      my $max = $info->{'minimum'}+10;
      if ($info->{'name'} eq 'straight_spacing') { $max = 2; }
      if ($info->{'name'} eq 'diagonal_spacing') { $max = 2; }
      if ($info->{'name'} eq 'radix') { $max = 17; }
      if ($info->{'name'} eq 'realpart') { $max = 3; }
      if ($info->{'name'} eq 'wider') { $max = 3; }
      if ($info->{'name'} eq 'modulus') { $max = 32; }
      if ($info->{'name'} eq 'polygonal') { $max = 32; }
      if ($info->{'name'} eq 'factor_count') { $max = 12; }
      if (defined $info->{'maximum'} && $max > $info->{'maximum'}) {
        $max = $info->{'maximum'};
      }
      if ($info->{'name'} eq 'power' && $max > 6) { $max = 6; }
      my @new_parameters;
      foreach my $choice ($info->{'minimum'} .. $max) {
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

}

{
  # max Dir4

  require Math::BaseCnv;

  # print 4-atan2(2,1)/atan2(1,1)/2,"\n";

  require Math::NumSeq::PlanePathDelta;
  my $realpart = 3;
  my $radix = $realpart*$realpart + 1;
  my $planepath = "HypotOctant,points=odd";
  $planepath = "FactorRationals";
  $planepath = "RationalsTree,tree_type=Drib";
  $planepath = "PythagoreanTree,coordinates=PQ,tree_type=FB";
  $planepath = "UlamWarburtonQuarter";
  $planepath = "UlamWarburton";
  $planepath = "GosperReplicate";
  $planepath = "QuintetReplicate";
  $planepath = "FractionsTree";
  $planepath = "PowerArray";
  my $seq = Math::NumSeq::PlanePathDelta->new (planepath => $planepath,
                                               delta_type => 'Dir4');
  my $dx_seq = Math::NumSeq::PlanePathDelta->new (planepath => $planepath,
                                                  delta_type => 'dX');
  my $dy_seq = Math::NumSeq::PlanePathDelta->new (planepath => $planepath,
                                                  delta_type => 'dY');
  my $max = -99;
  for (1 .. 10000000) {
    my ($i, $value) = $seq->next;

    # neg for minimum
    # $value = -$value; next unless $value;

    if ($value > $max) {
      my $dx = $dx_seq->ith($i);
      my $dy = $dy_seq->ith($i);
      my $ri = Math::BaseCnv::cnv($i,10,$radix);
      my $rdx = Math::BaseCnv::cnv($dx,10,$radix);
      my $rdy = Math::BaseCnv::cnv($dy,10,$radix);
      my $f = $dy && $dx/$dy;
      printf "%d %s %.5f  %s %s   %.3f\n", $i, $ri, $value, $rdx,$rdy, $f;
      $max = $value;
    }
  }

  exit 0;
}

{
  # max turn Left etc

  require Math::NumSeq::PlanePathTurn;
  require Math::NumSeq::PlanePathDelta;
  my $planepath;
  $planepath = "TriangularHypot,points=hex";
  $planepath = "TriangularHypot,points=hex_centred";
  $planepath = "TriangularHypot,points=hex_rotated";
  # my $seq = Math::NumSeq::PlanePathTurn->new (planepath => $planepath,
  #                                             turn_type => 'Right');

  $planepath = "FractionsTree";
  my $seq = Math::NumSeq::PlanePathDelta->new (planepath => $planepath,
                                              delta_type => 'Dir4');
  my $max = -99;
  my $min = 99;
  for (1 .. 1000000) {
    my ($i, $value) = $seq->next;
    # $value = -$value; next unless $value;
    if ($value > $max) {
      printf "%d %.5f new max\n", $i, $value;
      $max = $value;
    }
    if ($value < $min) {
      printf "%d %.5f new min\n", $i, $value;
      $min = $value;
    }
  }
  exit 0;
}


{
  my $pi = 4 * atan2(1,1);
  my %seen;
  foreach my $x (0 .. 100) {
    foreach my $y (0 .. 100) {
      my $factor;

      $factor = 1;

      $factor = sqrt(3);
      # next unless ($x&1) == ($y&1);

      $factor = sqrt(8);

      my $radians = atan2($y*$factor, $x);
      my $degrees = $radians / $pi * 180;
      my $frac = $degrees - int($degrees);
      if ($frac > 0.5) {
        $frac -= 1;
      }
      if ($frac < -0.5) {
        $frac += 1;
      }
      my $int = $degrees - $frac;
      next if $seen{$int}++;

      if ($frac > -0.001 && $frac < 0.001) {
        print "$x,$y   $int  ($degrees)\n";
      }
    }
  }
  exit 0;
}
