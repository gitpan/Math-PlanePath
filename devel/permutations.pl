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
  # between two paths
  require Math::NumSeq::PlanePathCoord;
  my $choices = Math::NumSeq::PlanePathCoord->parameter_info_hash
    ->{'planepath'}->{'choices'};
  my %seen;
  print "$#$choices choices\n";

  foreach my $from_name (@$choices) {
    my $from_class = "Math::PlanePath::$from_name";
    Module::Load::load($from_class);
    my $from_parameters = parameter_info_list_to_parameters($from_class->parameter_info_list);
    foreach my $from_p (@$from_parameters) {
      my $from_path = $from_class->new (@$from_p);
      my $from_fullname = "$from_name ".join(',',@$from_p);

      foreach my $to_name (@$choices) {
        my $to_class = "Math::PlanePath::$to_name";
        Module::Load::load($to_class);
        my $to_parameters = parameter_info_list_to_parameters($to_class->parameter_info_list);
      PATH: foreach my $to_p (@$to_parameters) {
          my $to_fullname = "$to_name ".join(',',@$to_p);
          next if $from_fullname eq $to_fullname;

          my $to_path = $to_class->new (@$to_p);
          my $str = '';
          my @values;
          foreach my $n ($from_path->n_start+1 .. 50) {
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
            print "\n";
          }
        }
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
                                      choices   => [0,1,2],
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

  if ($info->{'name'} eq 'arms') {
    # print "  skip parameter $info->{'name'}\n";
    # return;
  }

  if ($info->{'name'} eq 'n_start') {
    my @new_parameters;
    foreach my $p (@$parameters) {
      foreach my $n_start (0, 1, 2) {
        push @new_parameters, [ @$p, $info->{'name'}, $n_start ];
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
    my $min = $info->{'minimum'} // -5;
    my $max = $min + 10;
    if (# $module =~ 'PrimeIndexPrimes' &&
        $info->{'name'} eq 'level') { $max = 5; }
    if ($info->{'name'} eq 'rule') { $max = 255; }
    if ($info->{'name'} eq 'round_count') { $max = 20; }
    if ($info->{'name'} eq 'straight_spacing') { $max = 2; }
    if ($info->{'name'} eq 'diagonal_spacing') { $max = 2; }
    if ($info->{'name'} eq 'radix') { $max = 17; }
    if ($info->{'name'} eq 'realpart') { $max = 3; }
    if ($info->{'name'} eq 'wider') { $max = 3; }
    if ($info->{'name'} eq 'modulus') { $max = 32; }
    if ($info->{'name'} eq 'polygonal') { $max = 32; }
    if ($info->{'name'} eq 'factor_count') { $max = 12; }
    if ($info->{'name'} eq 'diagonal_length') { $max = 5; }
    if (defined $info->{'maximum'} && $max > $info->{'maximum'}) {
      $max = $info->{'maximum'};
    }
    if ($info->{'name'} eq 'power' && $max > 6) { $max = 6; }
    my @new_parameters;
    foreach my $choice ($min .. $max) {
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

