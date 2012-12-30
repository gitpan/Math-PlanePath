#!/usr/bin/perl -w

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


use 5.010;
use strict;
use Module::Load;

# uncomment this to run the ### lines
#use Smart::Comments;

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

{
  # between two paths
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
  until ($path_objects[$i]->isa('Math::PlanePath::PyramidSpiral')) {
    $i++;
  }
  while ($path_objects[$i]->isa('Math::PlanePath::PyramidSpiral')) {
    $i++;
  }

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
        print "$upto_permutation / $num_permutations  est $h:$m:$s  (each $t_each)\n";
        $t = time();
      }

      next if $i == $j;
      my $to_path = $path_objects[$j];
      next if $to_path->n_start != $n_start;
      my $to_fullname = $path_fullnames{$to_path};

      print DEBUG "$from_path $to_path\n";

      my $str = '';
      my @values;
      foreach my $n ($n_start+2 .. $n_start+50) {
        my ($x,$y) = $from_path->n_to_xy($n)
          or next PATH;
        my $pn = $to_path->xy_to_n($x,$y) // next PATH;
        $str .= "$pn,";
        push @values, $pn;
      }
      if (defined (my $diff = constant_diff(@values))) {
        print "$from_fullname -> $to_fullname\n";
        print "  constant diff $diff\n";
        next PATH;
      }
      if (my $found = stripped_grep($str)) {
        print "$from_fullname -> $to_fullname\n";
        print "  (",substr($str,0,20),"...)\n";
        print $found;
        print "\n";
      }
    }
  }
  exit 0;
}

{
  # transpose
  require Math::NumSeq::PlanePathCoord;
  my $choices = Math::NumSeq::PlanePathCoord->parameter_info_hash
    ->{'planepath'}->{'choices'};
  my %seen;
  foreach my $path_name (@$choices) {
    my $path_class = "Math::PlanePath::$path_name";
    Module::Load::load($path_class);
    my $parameters = parameter_info_list_to_parameters($path_class->parameter_info_list);
  PATH: foreach my $p (@$parameters) {
      print "$path_name  ",join(',',@$p),"\n";
      my $path = $path_class->new (@$p);
      my $str = '';
      my @values;
      foreach my $n ($path->n_start+1 .. 50) {
        my ($x,$y) = $path->n_to_xy($n) or next PATH;
        my $pn = $path->xy_to_n($y,$x);
        next PATH if ! defined $pn;
        $str .= "$pn,";
        push @values, $pn;
      }
      print "  (",substr($str,0,20),"...)\n";
      if (defined (my $diff = constant_diff(@values))) {
        print "  constant diff $diff\n";
        next PATH;
      }
      print stripped_grep($str);
      print "\n";
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

sub grep_for_values {
  my ($name, $values) = @_;
  # unless (system 'zgrep', '-F', '-e', $values, "$ENV{HOME}/OEIS/stripped.gz") {
  #   print "  match $values\n";
  #   print "  $name\n";
  #   print "\n"
  # }
  # unless (system 'fgrep', '-e', $values, "$ENV{HOME}/OEIS/oeis-grep.txt") {
  #   print "  match $values\n";
  #   print "  $name\n";
  #   print "\n"
  # }
  unless (system 'fgrep', '-e', $values, "$ENV{HOME}/OEIS/stripped") {
    print "  match $values\n";
    print "  $name\n";
    print "\n"
  }
}

# constant_diff($a,$b,$c,...)
# If all the given values have a constant difference then return that amount.
# Otherwise return undef.
#
sub constant_diff {
  my $diff = shift;
  my $value = shift;
  $diff = $value - $diff;
  while (@_) {
    my $next_value = shift;
    if ($next_value - $value != $diff) {
      return undef;
    }
    $value = $next_value;
  }
  return $diff;
}






__END__

upto PeanoCurve

GrayCode apply_type,TsF,gray_type,reflected,radix,2 -> GrayCode apply_type,FsT,gray_type,reflected,radix,2
  (2,3,5,4,7,6,10,11,8,...)
A064707 ,0,1,2,3,5,4,7,6,10,11,8,9,15,14,13,12,21,20,23,22,16,17,18,19,31,30,29,28,26,27,24,25,42,43,40,41,47,46,45,44,32,33,34,35,37,36,39,38,63,62,61,60,58,59,56,57,53,52,55,54,48,49,50,51,85,84,87,86,80,81,82,83,
A064707 Inverse square of permutation defined by A003188.
A100281 ,0,1,2,3,5,4,7,6,10,11,8,9,15,14,13,12,21,20,23,22,16,17,18,19,31,30,29,28,26,27,24,25,42,43,40,41,47,46,45,44,32,33,34,35,37,36,39,38,63,62,61,60,58,59,56,57,53,52,55,54,48,49,50,51,84,85,86,87,81,80,83,82,94,
A100281 A099896(A099896(n)).

PeanoCurve radix,2 -> GrayCode apply_type,sF,gray_type,reflected,radix,2
  (3,2,7,6,4,5,14,15,13...)
A099896 ,1,3,2,7,6,4,5,14,15,13,12,9,8,10,11,28,29,31,30,27,26,24,25,18,19,17,16,21,20,22,23,56,57,59,58,63,62,60,61,54,55,53,52,49,48,50,51,36,37,39,38,35,34,32,33,42,43,41,40,45,44,46,47,112,113,115,114,119,118,116,
A099896 A permutation of the natural numbers where a(n) = n XOR [n/2] XOR [n/4].



ZOrderCurve radix,2 -> GrayCode apply_type,TsF,gray_type,reflected,radix,2
  (3,2,6,7,5,4,12,13,15...)
A003188 ,0,1,3,2,6,7,5,4,12,13,15,14,10,11,9,8,24,25,27,26,30,31,29,28,20,21,23,22,18,19,17,16,48,49,51,50,54,55,53,52,60,61,63,62,58,59,57,56,40,41,43,42,46,47,45,44,36,37,39,38,34,35,33,32,96,97,99,98,102,103,101,
A003188 Decimal equivalent of Gray code for n.

ZOrderCurve radix,2 -> GrayCode apply_type,FsT,gray_type,reflected,radix,2
  (3,2,7,6,4,5,15,14,12...)
A006068 ,0,1,3,2,7,6,4,5,15,14,12,13,8,9,11,10,31,30,28,29,24,25,27,26,16,17,19,18,23,22,20,21,63,62,60,61,56,57,59,58,48,49,51,50,55,54,52,53,32,33,35,34,39,38,36,37,47,46,44,45,40,41,43,42,127,126,124,125,120,121,
A006068 a(n) is Gray-coded into n.

ZOrderCurve radix,3 -> GrayCode apply_type,Ts,gray_type,reflected,radix,3
  (2,5,4,3,6,7,8,17,16,...)
A128173 ,0,1,2,5,4,3,6,7,8,17,16,15,12,13,14,11,10,9,18,19,20,23,22,21,24,25,26,53,52,51,48,49,50,47,46,45,36,37,38,41,40,39,42,43,44,35,34,33,30,31,32,29,28,27,54,55,56,59,58,57,60,61,62,71,70,69,66,67,68,65,64,63,72,
A128173 Numbers in ternary Gray code order.

ZOrderCurve radix,3 -> GrayCode apply_type,Fs,gray_type,reflected,radix,3
  (2,5,4,3,6,7,8,17,16,...)
A128173 ,0,1,2,5,4,3,6,7,8,17,16,15,12,13,14,11,10,9,18,19,20,23,22,21,24,25,26,53,52,51,48,49,50,47,46,45,36,37,38,41,40,39,42,43,44,35,34,33,30,31,32,29,28,27,54,55,56,59,58,57,60,61,62,71,70,69,66,67,68,65,64,63,72,
A128173 Numbers in ternary Gray code order.

ZOrderCurve radix,10 -> GrayCode apply_type,TsF,gray_type,reflected,radix,10
  (2,3,4,5,6,7,8,9,19,1...)
A003100 ,0,1,2,3,4,5,6,7,8,9,19,18,17,16,15,14,13,12,11,10,20,21,22,23,24,25,26,27,28,29,39,38,37,36,35,34,33,32,31,30,40,41,42,43,44,45,46,47,48,49,59,58,57,56,55,54,53,52,51,50,60,61,62,63,64,65,66,67,68,69,79,78,77,
A003100 Decimal Gray code for n.

1629 / 247506  est 3:21:14  (each 0.049109883364027)
ZOrderCurve radix,10 -> GrayCode apply_type,Fs,gray_type,modular,radix,10
  (2,3,4,5,6,7,8,9,19,1...)
A098488 ,0,1,2,3,4,5,6,7,8,9,19,10,11,12,13,14,15,16,17,18,28,29,20,21,22,23,24,25,26,27,37,38,39,30,31,32,33,34,35,36,46,47,48,49,40,41,42,43,44,45,55,56,57,58,59,50,51,52,53,54,64,65,66,67,68,69,60,61,62,
A098488 Another decimal Gray code for n.


















DiamondArms  Xpos=-1 Xneg=-1 Ypos=-1 Yneg=-1
  (19,30,34,45,49,...)
A190692 ,4,8,15,19,30,34,45,49,56,60,64,71,75,86,90,101,105,112,116,120,127,131,142,146,157,161,168,172,183,187,198,202,209,213,217,224,228,239,243,254,258,265,269,273,280,284,295,299,310,314,321,325,336,340,351,355,366,370,377,381,392,396,407,411,418,422,426,433,437,448,
A190692 Positions of 3 in A190688.

DiamondSpiral n_start,0 Xpos=-1 Xneg=0 Ypos=-1 Yneg=0
  (3,4,10,12,21,24,36,4...)
A050187 ,0,3,4,10,12,21,24,36,40,55,60,78,84,105,112,136,144,171,180,210,220,253,264,300,312,351,364,406,420,465,480,528,544,595,612,666,684,741,760,820,840,903,924,990,1012,1081,1104,1176,
A050187 T(n,2), array T as in A050186; a count of aperiodic binary words.
A134170 ,1,2,3,4,10,12,21,24,36,40,60,60,84,84,112,112,144,144,180,180,
A134170 a(n)=the smallest natural number which, expressed in the form d*q+r for all d ranging from 1 to n, q>=r. In other words, when a(n) is divided by the numbers from 1 to n, the remainder is never more than the quotient.

DiamondSpiral n_start,0 Xpos=1 Xneg=-1 Ypos=0 Yneg=0
  (2,8,18,32,50,...)
A001105 ,0,2,8,18,32,50,72,98,128,162,200,242,288,338,392,450,512,578,648,722,800,882,968,1058,1152,1250,1352,1458,1568,1682,1800,1922,2048,2178,2312,2450,2592,2738,2888,3042,3200,3362,3528,3698,3872,4050,4232,4418,
A001105 2*n^2.
A168281 ,2,2,2,2,8,2,2,8,8,2,2,8,18,8,2,2,8,18,18,8,2,2,8,18,32,18,8,2,2,8,18,32,32,18,8,2,2,8,18,32,50,32,18,8,2,2,8,18,32,50,50,32,18,8,2,
A168281 Triangle T(n,m) = 2*(min(n+m-1,m))^2 read by rows.

GosperReplicate  Xpos=-1 Xneg=1 Ypos=-1 Yneg=-1
  (3,18,21,22,23,24,25,...)
A122300 ,0,1,2,3,4,6,5,7,8,9,10,14,16,19,11,15,12,17,20,13,18,21,22,23,24,25,26,27,37,38,42,44,53,51,47,56,60,28,29,39,43,52,30,40,31,45,46,34,54,57,61,33,41,32,48,55,35,49,58,62,36,50,59,63,64,65,66,67,68,69,70,71,
A122300 Row 2 of A122283 and A122284. An involution of nonnegative integers.
