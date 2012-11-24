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


# Maybe:
#
# I,J,K   TI,TJ,TK  Ti,Tj,Tk
# GF2Prod A051775,A051776  multiply with xor no carry
# NumOverlap       xy_to_n_list()  n_overlap_list()  n_num_overlap()
# NumSurround
# NumSurround4     NSEW
# NumSurroundDiag  diagonals
# NumSurround6     triangular
# NumSurround8
# NumPrev4
# Int = int(X/Y) cf A153036 SB integer part
# IntXY      towards 0  A004199 X>=0,Y>=0
# IntYX
# DivXY = X/Y fractional
# DivYX = Y/X fractional
# ExactDivXY = X/Y if X divisible by Y, or 0 if not A126988 X,Y>=1
# Frac = XmodY/Y fractional
# FracNum = abs(X) mod abs(Y)
# ModXY = X mod Y range 0 to abs(Y)-1
# ModYX
# Numerator = X / gcd(X,Y)         X/Y in least terms
# Denominator = Y / gcd(X,Y)
# LCM
# Theta360 angle matching Radius,RSquared
# Ttheta360 angle matching TRadius,TRSquared
# Chi(x) = 1 if x rational, 0 if irrational
# Dirichlet function D(x) = 1/b if rational x=a/b least terms, 0 if irrational
# Multiplicative distance A130836 X,Y>=1
#     sum abs(exponent-exponent) of each prime
#     A130849 total/2 muldist along diagonal

package Math::NumSeq::PlanePathCoord;
use 5.004;
use strict;
use Carp;
use constant 1.02; # various underscore constants below

#use List::Util 'max','min';
*max = \&Math::PlanePath::_max;
*min = \&Math::PlanePath::_min;

use vars '$VERSION','@ISA';
$VERSION = 93;
use Math::NumSeq;
@ISA = ('Math::NumSeq');

use Math::PlanePath;
*_divrem = \&Math::PlanePath::_divrem;

use Math::PlanePath::Base::Generic
  'is_infinite';

# uncomment this to run the ### lines
# use Smart::Comments;


sub description {
  my ($self) = @_;
  if (ref $self) {
    return "Coordinate $self->{'coordinate_type'} values from path $self->{'planepath'}";
  } else {
    # class method
    return 'Coordinate values from a PlanePath';
  }
}

use constant::defer parameter_info_array =>
  sub {
    my $choices = [
                   'X', 'Y',
                   'Sum', 'SumAbs',
                   'Product',
                   'DiffXY', 'DiffYX', 'AbsDiff',
                   'Radius', 'RSquared',
                   'TRadius', 'TRSquared',
                   'BitAnd', 'BitOr', 'BitXor',
                   'Min','Max',
                   'GCD',
                   'Depth', 'NumChildren',

                   # 'ModXY',
                   # 'Int',
                   # 'Numerator',
                   # 'Denominator',
                   # 'MinAbs',
                   # 'MaxAbs',
                   # 'MulDist',
                  ];
    return [
            _parameter_info_planepath(),
            { name            => 'coordinate_type',
              display         => 'Coordinate Type',
              type            => 'enum',
              default         => 'X',
              choices         => $choices,
              choices_display => $choices,
              description     => 'The coordinate or combination to take from the path.',
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

  # my @choices = Module::Find::findsubmod('Math::PlanePath');
  # @choices = grep {$_ ne 'Math::PlanePath'} @choices;

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
      # basename of .pm files, and not emacs .#Foo.pm lockfiles
      $name =~ s/^([^.].*)\.pm$/$1/
        or next;
      if (length($name) > $width) { $width = length($name) }
      $names{$name} = 1;  # hash slice
    }
    closedir DIR;
  }
  my $choices = [ sort keys %names ];

  return { name        => 'planepath',
           display     => 'PlanePath Class',
           type        => 'string',
           default     => $choices->[0],
           choices     => $choices,
           width       => $width + 5,
           description => 'PlanePath module name.',
         };
};

#------------------------------------------------------------------------------

sub oeis_anum {
  my ($self) = @_;
  ### PlanePathCoord oeis_anum() ...

  my $planepath_object = $self->{'planepath_object'};
  my $coordinate_type = $self->{'coordinate_type'};

  if ($planepath_object->isa('Math::PlanePath::Rows')) {
    if ($coordinate_type eq 'X') {
      return _oeis_anum_modulo($planepath_object->{'width'});
    }

  } elsif ($planepath_object->isa('Math::PlanePath::Columns')) {
    if ($coordinate_type eq 'Y') {
      return _oeis_anum_modulo($planepath_object->{'height'});
    }
  }

  {
    my $key = Math::NumSeq::PlanePathCoord::_planepath_oeis_anum_key($self->{'planepath_object'});
    my $i_start = $self->i_start;
    if ($i_start != $self->default_i_start) {
      ### $i_start
      ### cf n_start: $planepath_object->n_start
      $key .= ",i_start=$i_start";
    }

    ### planepath: ref $planepath_object
    ### $key
    ### whole table: $planepath_object->_NumSeq_Coord_oeis_anum
    ### key href: $planepath_object->_NumSeq_Coord_oeis_anum->{$key}

    if (my $anum = $planepath_object->_NumSeq_Coord_oeis_anum->{$key}->{$coordinate_type}) {
      return $anum;
    }
  }

  # all-zeros
  if (defined (my $values_min = $self->values_min)) {
    if (defined (my $values_max = $self->values_max)) {
      if ($values_min == 0 && $values_max == 0) {
        return 'A000004';  # all 0s
      }
      if ($values_min == 2 && $values_max == 2) {
        return 'A007395';  # all 2s
      }
    }
  }

  return undef;
}
sub _oeis_anum_modulo {
  my ($modulus) = @_;
  require Math::NumSeq::Modulo;
  return Math::NumSeq::Modulo->new(modulus=>$modulus)->oeis_anum;
}

sub _planepath_oeis_key {
  my ($path) = @_;
  ### PlanePathCoord _planepath_oeis_key() ...

  return join(',',
              ref($path),

              (map {
                # nasty hack to exclude SierpinskiCurveStair diagonal_length
                $_->{'name'} eq 'diagonal_length'
                  ? ()
                    : do {
                      my $value = $path->{$_->{'name'}};
                      if ($_->{'type'} eq 'boolean') {
                        $value = ($value ? 1 : 0);
                      }
                      ### $_
                      ### $value
                      ### gives: "$_->{'name'}=$value"
                      (defined $value ? "$_->{'name'}=$value" : ())
                    }
                  }
               $path->parameter_info_list,
               $path->_NumSeq_extra_parameter_info_list,
              ),
             );
}
sub _planepath_oeis_anum_key {
  my ($path) = @_;
  ### PlanePathCoord _planepath_oeis_key() ...
  return join(',',
              (map {
                # nasty hack to exclude SierpinskiCurveStair diagonal_length
                $_->{'name'} eq 'diagonal_length'
                  ? ()
                    : do {
                      my $value = $path->{$_->{'name'}};
                      if ($_->{'type'} eq 'boolean') {
                        $value = ($value ? 1 : 0);
                      }
                      ### $_
                      ### $value
                      ### gives: "$_->{'name'}=$value"
                      (defined $value ? "$_->{'name'}=$value" : ())
                    }
                  }
               $path->parameter_info_list,
               $path->_NumSeq_extra_parameter_info_list,
              ),
             );
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

  ### $self
  return $self;
}

sub _planepath_name_to_object {
  my ($name) = @_;
  ### PlanePathCoord _planepath_name_to_object(): $name
  ($name, my @args) = split /,+/, $name;
  $name = "Math::PlanePath::$name";
  ### $name
  require Module::Load;
  Module::Load::load ($name);
  return $name->new (map {/(.*?)=(.*)/} @args);

  # width => $options{'width'},
  # height => $options{'height'},
}

sub default_i_start {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'}
    # nasty hack allow no 'planepath_object' when SUPER::new() calls rewind()
    || return 0;
  return $planepath_object->n_start;
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
sub _coordinate_func_SumAbs {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  return abs($x) + abs($y);
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
  return $self->{'planepath_object'}->n_to_rsquared($n);
}

sub _coordinate_func_TRadius {
  my $rsquared;
  return (defined ($rsquared = _coordinate_func_TRSquared(@_))
          ? sqrt($rsquared)
          : undef);
}
sub _coordinate_func_TRSquared {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  return $x*$x + 3*$y*$y;
}

sub _coordinate_func_NumChildren {
  my ($self, $n) = @_;
  return $self->{'planepath_object'}->tree_n_num_children($n);
}
sub _coordinate_func_Depth {
  my ($self, $n) = @_;
  return $self->{'planepath_object'}->tree_n_to_depth($n);
}

use Math::PlanePath::GcdRationals;
sub _coordinate_func_GCD {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  $x = abs(int($x));
  $y = abs(int($y));
  if ($x == 0) {
    return $y;
  }
  if (is_infinite($x)) { return $x; }
  if (is_infinite($y)) { return $y; }
  return Math::PlanePath::GcdRationals::_gcd($x,$y);
}

#------------------------------------------------------------------------------
# UNTESTED
# math-image --values=PlanePathCoord,coordinate_type=NumSurround4,planepath=DragonCurve --path=DragonCurve --scale=10
sub _coordinate_func_NumSurround4 {
  my ($self, $n, $points) = @_;
  return _path_n_surround_count ($self->{'planepath_object'}, $n, 4);
}
sub _coordinate_func_NumSurround6 {
  my ($self, $n, $points) = @_;
  return _path_n_surround_count ($self->{'planepath_object'}, $n, 6);
}
sub _coordinate_func_NumSurround8 {
  my ($self, $n, $points) = @_;
  return _path_n_surround_count ($self->{'planepath_object'}, $n, 8);
}
{ my @surround;
  $surround[4] = [ 1,0, 0,1, -1,0, 0,-1 ];
  $surround[6] = [ 2,0, 1,1, -1,1,
                   -2,0, -1,-1, 1,-1 ];
  $surround[8] = [ 1,0, 0,1, -1,0, 0,-1,
                   1,1, -1,1, 1,-1, -1,-1 ];
  sub _path_n_surround_count {
    my ($path, $n, $points) = @_;
    ### _path_n_surround_count(): $n, $points
    my $aref = $surround[$points]
      || croak "_path_n_surround_count() unrecognised points ",$points;
    my ($x, $y) = $path->n_to_xy($n) or return undef;
    my $count = 0;
    for (my $i = 0; $i < @$aref; ) {
      my $dx = $aref->[$i++];
      $count += defined ($path->xy_to_n($x+$dx, $y+$aref->[$i++]));
    }
    return $count;
  }
}
use constant _INFINITY => do {
  my $x = 999;
  foreach (1 .. 20) {
    $x *= $x;
  }
  $x;
};
sub _coordinate_func_Int {
  my ($self, $n) = @_;
  ### _coordinate_func_Int(): $n
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  ### $x
  ### $y
  $y = abs($y) || return _INFINITY;   # X/0
  $x = abs($x);
  if ($y == int($y)) {
    my ($q) = _divrem($x,$y);
    return $q;
  } else {
    return int($x/$y);
  }
}
sub _coordinate_func_ModXY {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  $y = abs($y) || return 0;
  if ($y == int($y)) {
    my ($q,$r) = _divrem($x,$y);
    return $r;
  } else {
    return $x % $y;
  }
}

# Math::BigInt in perl 5.6.0 has and/or/xor
sub _op_and { $_[0] & $_[1] }
sub _op_or  { $_[0] | $_[1] }
sub _op_xor { $_[0] ^ $_[1] }
sub _coordinate_func_BitAnd {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  return _bitwise_by_parts($x,$y, \&_op_and);
}
sub _coordinate_func_BitOr {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  return _bitwise_by_parts($x,$y, \&_op_or);
}
sub _coordinate_func_BitXor {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  return _bitwise_by_parts($x,$y, \&_op_xor);
}
use constant 1.02 _UV_MAX_PLUS_1 => do {
  my $pow = 1.0;
  my $uv = ~0;
  while ($uv) {
    $uv >>= 1;
    $pow *= 2.0;
  }
  $pow
};
sub _bitwise_by_parts {
  my ($x, $y, $opfunc) = @_;
  ### _bitwise_by_parts(): $x, $y

  if (is_infinite($x)) { return $x; }
  if (is_infinite($y)) { return $y; }

  # Positive integers in UV range plain operator.
  # Any ref is Math::BigInt or whatever left to its operator overloads.
  if (ref $x || ref $y
      || ($x == int($x) && $y == int($y)
          && $x >= 0 && $y >= 0
          && $x < _UV_MAX_PLUS_1 && $x < _UV_MAX_PLUS_1)) {
    return &$opfunc($x,$y);
  }

  $x *= 65536.0;
  $x *= 65536.0;
  $x = int($x);
  $y *= 65536.0;
  $y *= 65536.0;
  $y = int($y);

  my @ret; # low to high
  while ($x >= 1 || $x < -1 || $y >= 1 || $y < -1) {
    ### $x
    ### $y

    my $xpart = $x % 65536.0;
    if ($xpart < 0) { $xpart += 65536.0; }
    $x = ($x - $xpart) / 65536.0;

    my $ypart = $y % 65536.0;
    if ($ypart < 0) { $ypart += 65536.0; }
    $y = ($y - $ypart) / 65536.0;

    ### xpart: $xpart . sprintf(' %04X',$xpart)
    ### ypart: $ypart . sprintf(' %04X',$ypart)
    push @ret, &$opfunc($xpart,$ypart);
  }
  my $ret = (&$opfunc($x<0,$y<0) ? -1 : 0);
  ### @ret
  ### $x
  ### $y
  ### $ret
  foreach my $rpart (reverse @ret) { # high to low
    $ret = 65536.0*$ret + $rpart;
  }
  ### ret joined: $ret
  $ret /= 65536.0;
  $ret /= 65536.0;
  ### ret final: $ret
  return $ret;
}
use constant 1.02 _IV_MIN => - (~0 >> 1) - 1;
sub _sign_extend {
  my ($n) = @_;
  return ($n - (- _IV_MIN)) + _IV_MIN;
}
use constant 1.02 _UV_NUMBITS => do {
  my $uv = ~0;
  my $count = 0;
  while ($uv) {
    $uv >>= 1;
    $count++;
    last if $count >= 1024;
  }
  $count
};
sub _frac_to_int {
  my ($x) = @_;
  $x -= int($x);
  return int(abs($x)*(2**_UV_NUMBITS()));
}
sub _int_to_frac {
  my ($x) = @_;
  return $x / (2**_UV_NUMBITS());
}

sub _coordinate_func_Numerator {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  my $g = Math::PlanePath::GcdRationals::_gcd(abs($x),abs($y))
    || return 0;
  return $x / $g;
}
sub _coordinate_func_Denominator {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  $y = abs($y);
  my $g = Math::PlanePath::GcdRationals::_gcd(abs($x),$y)
    || return 0;
  return $y / $g;
}
sub _coordinate_func_Min {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  return min($x,$y);
}
sub _coordinate_func_Max {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  return max($x,$y);
}
sub _coordinate_func_MinAbs {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  return min(abs($x),abs($y));
}
sub _coordinate_func_MaxAbs {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  return max(abs($x),abs($y));
}

use Math::PlanePath::GcdRationals;
sub _coordinate_func_MulDist {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  $x = int(abs($x));
  $y = int(abs($y));
  if (my $g = Math::PlanePath::GcdRationals::_gcd($x,$y)) {
    $x /= $g;
    $y /= $g;
  }
  unless ($x < (2.0**32) && $y < (2.0**32)) {
    return undef;
  }
  require Math::Factor::XS;
  return Math::Factor::XS::count_prime_factors($x) + Math::Factor::XS::count_prime_factors($y);
}

# count of differing bit positions
use Math::PlanePath::Base::Digits
  'bit_split_lowtohigh';
sub _coordinate_func_HammingDist {
  my ($self, $n) = @_;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($n)
    or return undef;
  if (is_infinite($x)) { return $x; }
  if (is_infinite($y)) { return $y; }
  $x = abs(int($x));
  $y = abs(int($y));
  my @xbits = bit_split_lowtohigh($x);
  my @ybits = bit_split_lowtohigh($y);
  my $ret = 0;
  while (@xbits || @ybits) {
    $ret += (shift @xbits ? 1 : 0) ^ (shift @ybits ? 1 : 0);
  }
  return $ret;
}


#------------------------------------------------------------------------------

sub characteristic_integer {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'};
  if (my $func = $planepath_object->can("_NumSeq_Coord_$self->{'coordinate_type'}_integer")) {
    return $planepath_object->$func();
  }
  if (defined (my $values_min = $self->values_min)
      && defined (my $values_max = $self->values_max)) {
    if ($values_min == int($values_min)
        && $values_max == int($values_max)
        && $values_min == $values_max) {
      return 1;
    }
  }
  return undef;
}

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
                   && $planepath_object->can("_NumSeq_Coord_Radius_increasing"))
               || ($self->{'coordinate_type'} eq 'TRSquared'
                   && $planepath_object->can("_NumSeq_Coord_TRadius_increasing"))))
     ? $planepath_object->$func()
     : undef); # unknown
}

sub characteristic_non_decreasing {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'};
  if (my $func = ($planepath_object->can("_NumSeq_Coord_$self->{'coordinate_type'}_non_decreasing")
                  || ($self->{'coordinate_type'} eq 'RSquared'
                      && $planepath_object->can("_NumSeq_Coord_Radius_non_decreasing"))
                  || ($self->{'coordinate_type'} eq 'TRSquared'
                      && $planepath_object->can("_NumSeq_Coord_TRadius_non_decreasing")))) {
    return $planepath_object->$func();
  }
  if (defined (my $values_min = $self->values_min)) {
    if (defined (my $values_max = $self->values_max)) {
      if ($values_min == $values_max) {
        # constant seq is non-decreasing
        return 1;
      }
    }
  }
  # increasing means non_decreasing too
  return $self->characteristic_increasing;
}

{
  my %values_min = (X           => 'x_minimum',
                    Y           => 'y_minimum',
                    RSquared    => 'rsquared_minimum',
                    Numerator   => 'x_minimum',
                    Denominator => 'y_minimum',
                   );
  sub values_min {
    my ($self) = @_;
    my $planepath_object = $self->{'planepath_object'};
    if (my $method = ($values_min{$self->{'coordinate_type'}}
                      || $planepath_object->can("_NumSeq_Coord_$self->{'coordinate_type'}_min"))) {
      return $planepath_object->$method();
    }
    return undef;
  }
}
{
  my %values_max = (X => 'x_maximum',
                    Y => 'y_maximum',
                   );
  sub values_max {
    my ($self) = @_;
    my $planepath_object = $self->{'planepath_object'};
    if (my $method = ($values_max{$self->{'coordinate_type'}}
                      || $planepath_object->can("_NumSeq_Coord_$self->{'coordinate_type'}_max"))) {
      return $planepath_object->$method();
    }
    return undef;
  }
}

{ package Math::PlanePath;
  use constant _NumSeq_extra_parameter_info_list => ();
  use constant _NumSeq_Coord_NumSurround4_min => 0;
  use constant _NumSeq_Coord_NumSurround6_min => 0;
  use constant _NumSeq_Coord_NumSurround8_min => 0;
  use constant _NumSeq_Coord_NumSurround4 => 4;
  use constant _NumSeq_Coord_NumSurround6 => 6;
  use constant _NumSeq_Coord_NumSurround8 => 8;
  use constant _NumSeq_Coord_NumSurround4_integer => 1;  # always integers
  use constant _NumSeq_Coord_NumSurround6_integer => 1;
  use constant _NumSeq_Coord_NumSurround8_integer => 1;
  use constant _NumSeq_Coord_Int_min => 0;
  use constant _NumSeq_Coord_Int_max => undef;
  use constant _NumSeq_Coord_Int_integer => 1;
  use constant _NumSeq_Coord_GCD_min => 0;
  use constant _NumSeq_Coord_GCD_max => undef;
  use constant _NumSeq_Coord_GCD_integer => 1;
  use constant _NumSeq_Coord_oeis_anum => {};

  use constant _NumSeq_Coord_X_integer => 1;  # usually
  use constant _NumSeq_Coord_Y_integer => 1;
  sub _NumSeq_Coord_Sum_integer {
    my ($self) = @_;
    ### _NumSeq_Coord_Sum_integer() ...
    return ($self->_NumSeq_Coord_X_integer
            && $self->_NumSeq_Coord_Y_integer);
  }
  *_NumSeq_Coord_SumAbs_integer    = \&_NumSeq_Coord_Sum_integer;
  *_NumSeq_Coord_Product_integer   = \&_NumSeq_Coord_Sum_integer;
  *_NumSeq_Coord_DiffXY_integer    = \&_NumSeq_Coord_Sum_integer;
  *_NumSeq_Coord_AbsDiff_integer   = \&_NumSeq_Coord_Sum_integer;
  *_NumSeq_Coord_RSquared_integer  = \&_NumSeq_Coord_Sum_integer;
  *_NumSeq_Coord_TRSquared_integer = \&_NumSeq_Coord_Sum_integer;

  # fractional part treated bitwise
  *_NumSeq_Coord_BitAnd_integer    = \&_NumSeq_Coord_Sum_integer;
  *_NumSeq_Coord_BitOr_integer     = \&_NumSeq_Coord_Sum_integer;
  *_NumSeq_Coord_BitXor_integer    = \&_NumSeq_Coord_Sum_integer;

  sub _NumSeq_Coord_Sum_min {
    my ($self) = @_;
    ### _NumSeq_Coord_Sum_min() ...
    if (defined (my $x_minimum = $self->x_minimum)
        && defined (my $y_minimum = $self->y_minimum)) {
      return $x_minimum + $y_minimum;
    } else {
      return undef;
    }
  }
  sub _NumSeq_Coord_SumAbs_min {
    my ($self) = @_;
    my $x_minimum = $self->x_minimum || 0;
    if ($x_minimum < 0) { $x_minimum = 0; }
    my $y_minimum = $self->y_minimum || 0;
    if ($y_minimum < 0) { $y_minimum = 0; }
    return abs($x_minimum) + abs($y_minimum);
  }

  sub _NumSeq_Coord_Product_min {
    my ($self) = @_;
    my ($x_minimum, $y_minimum);
    if (defined ($x_minimum = $self->x_minimum)
        && defined ($y_minimum = $self->y_minimum)
        && $x_minimum >= 0
        && $y_minimum >= 0) {
      return $x_minimum * $y_minimum;
    }
    return undef;
  }
  sub _NumSeq_Coord_Product_max {
    my ($self) = @_;
    my ($x_max, $y_minimum);
    ### X_max: $self->x_maximum
    ### Y_min: $self->y_minimum
    if (defined ($x_max = $self->x_maximum)
        && defined ($y_minimum = $self->y_minimum)
        && $x_max <= 0
        && $y_minimum >= 0) {
      # X all negative, Y all positive
      return $y_minimum * $x_max;
    }
    return undef;
  }

  sub _NumSeq_Coord_DiffXY_min {
    my ($self) = @_;
    if (defined (my $y_maximum = $self->y_maximum)
        && defined (my $x_minimum = $self->x_minimum)) {
      return $x_minimum - $y_maximum;
    } else {
      return undef;
    }
  }
  sub _NumSeq_Coord_DiffXY_max {
    my ($self) = @_;
    if (defined (my $y_minimum = $self->y_minimum)
        && defined (my $x_max = $self->x_maximum)) {
      return $x_max - $y_minimum;
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
  sub _NumSeq_Coord_DiffYX_integer {
    my ($self) = @_;
    return $self->_NumSeq_Coord_Sum_integer;
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
    return sqrt($path->rsquared_minimum);
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

  sub _NumSeq_Coord_TRadius_min {
    my ($path) = @_;
    return sqrt($path->_NumSeq_Coord_TRSquared_min);
  }
  sub _NumSeq_Coord_TRSquared_min {
    my ($self) = @_;
    if (defined (my $x_minimum = $self->x_minimum)
        && defined (my $y_minimum = $self->y_minimum)) {
      return $x_minimum*$x_minimum + 3*$y_minimum*$y_minimum;
    } else {
      return 0; # _coordinate_func_TRSquared($self->n_to_xy($self->n_start));
    }
  }

  sub _NumSeq_Coord_BitAnd_min {
    my ($self) = @_;
    if (defined (my $x_minimum = $self->x_minimum)
        && defined (my $y_minimum = $self->y_minimum)) {
      return $x_minimum & $y_minimum;
    } else {
      return undef;
    }
  }
  sub _NumSeq_Coord_BitOr_min {
    my ($self) = @_;
    if (defined (my $x_minimum = $self->x_minimum)
        && defined (my $y_minimum = $self->y_minimum)) {
      # if the x and y minimums occur at the same N ...
      return $x_minimum | $y_minimum;
    } else {
      return undef;
    }
  }
  sub _NumSeq_Coord_BitXor_min {
    my ($self) = @_;
    if (defined (my $x_minimum = $self->x_minimum)
        && defined (my $y_minimum = $self->y_minimum)) {
      return $x_minimum ^ $y_minimum;
    }
    return undef;
  }

  sub _NumSeq_Coord_Min_min {
    my ($self) = @_;
    if (defined (my $x_minimum = $self->x_minimum)
        && defined (my $y_minimum = $self->y_minimum)) {
      return Math::NumSeq::PlanePathCoord::min($x_minimum, $y_minimum);
    }
    return undef;
  }
  sub _NumSeq_Coord_MinAbs_min {
    my ($self) = @_;
    if (defined (my $x_minimum = $self->x_minimum)
        && defined (my $y_minimum = $self->y_minimum)
        && defined (my $x_maximum = $self->x_maximum)
        && defined (my $y_maximum = $self->y_maximum)) {
      return Math::NumSeq::PlanePathCoord::min
        ($x_minimum, $y_minimum, -$x_maximum, -$y_maximum);
    }
    return undef;
  }
  sub _NumSeq_Coord_Max_max {
    my ($self) = @_;
    if (defined (my $x_maximum = $self->x_maximum)
        && defined (my $y_maximum = $self->y_maximum)) {
      return Math::NumSeq::PlanePathCoord::max($x_maximum, $y_maximum);
    }
    return undef;
  }
  sub _NumSeq_Coord_MaxAbs_max {
    my ($self) = @_;
    if (defined (my $x_minimum = $self->x_minimum)
        && defined (my $y_minimum = $self->y_minimum)
        && defined (my $x_maximum = $self->x_maximum)
        && defined (my $y_maximum = $self->y_maximum)) {
      return Math::NumSeq::PlanePathCoord::max
        (-$x_minimum, -$y_minimum, $x_maximum, $y_maximum);
    }
    return undef;
  }
  *_NumSeq_Coord_Min_integer    = \&_NumSeq_Coord_Sum_integer;
  *_NumSeq_Coord_MinAbs_integer = \&_NumSeq_Coord_Sum_integer;
  *_NumSeq_Coord_Max_integer    = \&_NumSeq_Coord_Sum_integer;
  *_NumSeq_Coord_MaxAbs_integer = \&_NumSeq_Coord_Sum_integer;

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
  sub _NumSeq_Coord_pred_SumAbs {
    my ($path, $value) = @_;
    return (($path->figure ne 'square' || $value == int($value))
            && $value >= 0);
  }
  sub _NumSeq_Coord_pred_Radius {
    my ($path, $value) = @_;
    return $path->_NumSeq_Coord_pred_RSquared($value*$value);
  }
  sub _NumSeq_Coord_pred_RSquared {
    my ($path, $value) = @_;
    # FIXME: this should be whether x^2+y^2 ...
    return (($path->figure ne 'square' || $value == int($value))
            && $value >= 0);
  }
  sub _NumSeq_Coord_pred_TRadius {
    my ($path, $value) = @_;
    return $path->_NumSeq_Coord_pred_RSquared($value*$value);
  }
  sub _NumSeq_Coord_pred_TRSquared {
    my ($path, $value) = @_;
    # FIXME: this should be whether x^2+3*y^2 occurs ...
    return (($path->figure ne 'square' || $value == int($value))
            && $value >= 0);
  }
  use constant _NumSeq_Coord_NumChildren_min => 0;
  use constant _NumSeq_Coord_NumChildren_max => 0;
  use constant _NumSeq_Coord_NumChildren_integer => 1;
  use constant _NumSeq_Coord_Depth_min => 0;
  use constant _NumSeq_Coord_Depth_max => 0;
  use constant _NumSeq_Coord_Depth_integer => 1;
  use constant _NumSeq_Coord_Depth_non_decreasing => 1; # usually
}

{ package Math::PlanePath::SquareSpiral;
  use constant _NumSeq_Coord_oeis_anum =>
    { 'wider=0,n_start=1' =>
      { X       => 'A174344',  # X
        # OEIS-Catalogue: A174344 planepath=SquareSpiral coordinate_type=X
      },
      'wider=0,n_start=0' =>
      { Sum     => 'A180714', # X+Y of square spiral
        AbsDiff => 'A053615', # 0..n..0, distance to pronic
        # OEIS-Catalogue: A180714 planepath=SquareSpiral,n_start=0 coordinate_type=Sum
        # OEIS-Other:     A053615 planepath=SquareSpiral,n_start=0 coordinate_type=AbsDiff
      },
    };
}
# { package Math::PlanePath::GreekKeySpiral;
# }
# { package Math::PlanePath::PyramidSpiral;
#    # '' =>
#    # {
#    #  # Not quite, starts OFFSET=0 not N=1
#    #  AbsX => 'A053615', # runs 0..n..0
#    # },
# }
# { package Math::PlanePath::TriangleSpiral;
# }
# { package Math::PlanePath::TriangleSpiralSkewed;
# }
{ package Math::PlanePath::DiamondSpiral;
  use constant _NumSeq_Coord_SumAbs_non_decreasing => 1; # diagonals pos,neg
  use constant _NumSeq_Coord_oeis_anum =>
    { 'n_start=0' =>
      { X => 'A010751', # up 1, down 2, up 3, down 4, etc
        # OEIS-Catalogue: A010751 planepath=DiamondSpiral,n_start=0
      },
    };
}
# { package Math::PlanePath::AztecDiamondRings;
# }
# { package Math::PlanePath::PentSpiralSkewed;
# }
{ package Math::PlanePath::HexSpiral;
  *_NumSeq_Coord_SumAbs_min = \&rsquared_minimum;
  *_NumSeq_Coord_AbsDiff_min = \&rsquared_minimum;
  *_NumSeq_Coord_TRSquared_min = \&rsquared_minimum;
  sub _NumSeq_Coord_GCD_min {
    my ($self) = @_;
    return $self->{'wider'} & 1;  # 1 if 0,0 not visited
  }
}
# { package Math::PlanePath::HexSpiralSkewed;
# }
# { package Math::PlanePath::HexArms;
# }
# { package Math::PlanePath::HeptSpiralSkewed;
# }
# { package Math::PlanePath::AnvilSpiral;
# }
# { package Math::PlanePath::OctagramSpiral;
# }
# { package Math::PlanePath::KnightSpiral;
# }
# { package Math::PlanePath::CretanLabyrinth;
# }
# { package Math::PlanePath::SquareArms;
# }
# { package Math::PlanePath::DiamondArms;
# }
{ package Math::PlanePath::SacksSpiral;
  use constant _NumSeq_Coord_X_integer => 0;
  use constant _NumSeq_Coord_Y_integer => 0;
  use constant _NumSeq_Coord_Radius_increasing => 1; # Radius==sqrt($i)
  use constant _NumSeq_Coord_RSquared_smaller => 0;  # RSquared==$i
  use constant _NumSeq_Coord_RSquared_integer => 1;

  use constant _NumSeq_Coord_oeis_anum =>
    { '' =>
      { RSquared => 'A001477',  # integers 0,1,2,3,etc
        # OEIS-Other: A001477 planepath=SacksSpiral coordinate_type=RSquared
      },
    };
}
{ package Math::PlanePath::VogelFloret;
  use constant _NumSeq_Coord_X_integer => 0;
  use constant _NumSeq_Coord_Y_integer => 0;
  sub _NumSeq_Coord_SumAbs_min {
    my ($self) = @_;
    my ($x,$y) = $self->n_to_xy($self->n_start);
    return abs($x)+abs($y);
  }
  use constant _NumSeq_AbsDiff_min_is_infimum => 1;

  sub _NumSeq_Coord_Radius_min {
    my ($self) = @_;
    # starting N=1 at R=radius_factor*sqrt(1), theta=something
    return $self->{'radius_factor'};
  }
  sub _NumSeq_Coord_TRSquared_min {
    my ($self) = @_;
    # starting N=1 at R=radius_factor*sqrt(1), theta=something
    my ($x,$y) = $self->n_to_xy($self->n_start);
    return $x*$x + 3*$y*$y;
  }
  sub _NumSeq_Coord_Radius_func {
    my ($seq, $i) = @_;
    ### VogelFloret Radius: $i, $seq->{'planepath_object'}
    # R=radius_factor*sqrt($n)
    # avoid sin/cos in the main n_to_xy()

    my $path = $seq->{'planepath_object'};
    my $rf = $path->{'radius_factor'};

    # promote BigInt $i -> BigFloat so that sqrt() doesn't round, and in
    # case radius_factor is not an integer
    if (ref $i && $i->isa('Math::BigInt') && $rf != int($rf)) {
      require Math::BigFloat;
      $i = Math::BigFloat->new($i);
    }

    return sqrt($i) * $rf;
  }
  use constant _NumSeq_Coord_Radius_increasing => 1; # Radius==sqrt($i)
  use constant _NumSeq_Coord_RSquared_smaller => 0;  # RSquared==$i
}
{ package Math::PlanePath::TheodorusSpiral;
  use constant _NumSeq_Coord_X_integer => 0;
  use constant _NumSeq_Coord_Y_integer => 0;
  use constant _NumSeq_Coord_Radius_increasing => 1; # Radius==sqrt($i)
  use constant _NumSeq_Coord_RSquared_smaller => 0;  # RSquared==$i
  use constant _NumSeq_Coord_RSquared_integer => 1;

  use constant _NumSeq_Coord_oeis_anum =>
    { '' =>
      { RSquared => 'A001477',  # integers 0,1,2,3,etc
        # OEIS-Other: A001477 planepath=TheodorusSpiral coordinate_type=RSquared
      },
    };
}
{ package Math::PlanePath::ArchimedeanChords;
  use constant _NumSeq_Coord_X_integer => 0;
  use constant _NumSeq_Coord_Y_integer => 0;
  use constant _NumSeq_Coord_Radius_increasing => 1; # spiralling outwards
}
{ package Math::PlanePath::MultipleRings;
  sub _NumSeq_Coord_Radius_min {
    my ($self) = @_;
    ### MultipleRings _NumSeq_Coord_Radius_min() ...
    my $step = $self->{'step'};
    if ($self->{'ring_shape'} eq 'polygon' && $step >= 3) {
      return $self->{'base_r'};
    }
    return ($step == 0
            ? 0  # step=0 along X axis starting X=0,Y=0
            : $step > 6
            ? 0.5 / sin((4*atan2(1,1)) / $step)  # pi/step
            : $self->{'base_r'} + 1);
  }
  *_NumSeq_Coord_SumAbs_min = \&_NumSeq_Coord_Radius_min;
  sub rsquared_minimum {
    my ($self) = @_;
    return $self->_NumSeq_Coord_Radius_min ** 2;
  }
  sub _NumSeq_Coord_TRadius_min {
    my ($self) = @_;
    return $self->_NumSeq_Coord_Radius_min;
  }
  sub _NumSeq_Coord_TRSquared_min {
    my ($self) = @_;
    return $self->rsquared_minimum;
  }

  sub _NumSeq_Coord_X_increasing {
    my ($self) = @_;
    # step==0 trivial on X axis
    return ($self->{'step'} == 0 ? 1 : 0);
  }
  *_NumSeq_Coord_Sum_increasing         = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_SumAbs_increasing      = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_DiffXY_increasing      = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_AbsDiff_increasing     = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_Radius_increasing      = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_Radius_integer         = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_TRadius_increasing     = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_TRadius_integer        = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_Y_non_decreasing       = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_Product_non_decreasing = \&_NumSeq_Coord_X_increasing;

  sub _NumSeq_Coord_SumAbs_non_decreasing {
    my ($self) = @_;
    # step==0 trivial on X axis
    # polygon step=4 same x+y in ring, others vary
    return ($self->{'step'} == 0
            || ($self->{'ring_shape'} eq 'polygon' && $self->{'step'} == 4)
            ? 1
            : 0);
  }
  sub _NumSeq_Coord_Radius_non_decreasing {
    my ($self) = @_;
    # step==0 trivial on X axis
    # circle is non-decreasing, polygon varies
    return ($self->{'step'} == 0 || $self->{'ring_shape'} eq 'circle');
  }
  sub _NumSeq_Coord_TRadius_non_decreasing {
    my ($self) = @_;
    # step==0 trivial on X axis
    return ($self->{'step'} == 0 ? 1 : 0);
  }

  sub _NumSeq_Coord_RSquared_smaller {
    my ($self) = @_;
    # step==0 on X axis RSquared is i^2, bigger than i.
    # step=1 is 0,1,1,4,4,4,9,9,9,9,16,16,16,16,16 etc k+1 repeats of k^2,
    # bigger than i from i=5 onwards
    return ($self->{'step'} <= 1 ? 0 : 1);
  }

  use constant _NumSeq_Coord_oeis_anum =>
    {
     # MultipleRings step=0 is trivial X=N,Y=0
     'step=0,ring_shape=circle' =>
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
    };
}
# { package Math::PlanePath::PixelRings;
# }
# { package Math::PlanePath::FilledRings;
# }
{ package Math::PlanePath::Hypot;
  sub _NumSeq_Coord_SumAbs_min {
    my ($self) = @_;
    return ($self->{'points'} eq 'odd'
            ? 1     # odd, origin 0,0 not included
            : 0);   # even,all origin 0,0
  }
  sub _NumSeq_Coord_AbsDiff_min {
    my ($self) = @_;
    return ($self->{'points'} eq 'odd'
            ? 1     # odd, line X=Y not included
            : 0);   # even,all includes X=Y
  }
  *_NumSeq_Coord_TRSquared_min = \&rsquared_minimum;
  *_NumSeq_Coord_GCD_min       = \&rsquared_minimum;

  # in order of radius so monotonic, but always have 4x duplicates or more
  use constant _NumSeq_Coord_Radius_non_decreasing => 1;
}
{ package Math::PlanePath::HypotOctant;
  *_NumSeq_Coord_Sum_min = \&x_minimum;
  *_NumSeq_Coord_SumAbs_min = \&x_minimum;
  *_NumSeq_Coord_DiffXY_min = \&x_minimum;
  *_NumSeq_Coord_AbsDiff_min = \&x_minimum;
  use constant _NumSeq_Coord_Int_min => 1;  # triangular X>=Y so X/Y >= 1

  *_NumSeq_Coord_TRSquared_min = \&rsquared_minimum;
  *_NumSeq_Coord_GCD_min       = \&rsquared_minimum;

  # in order of radius so monotonic, but can have duplicates
  use constant _NumSeq_Coord_Radius_non_decreasing => 1;
}
{ package Math::PlanePath::TriangularHypot;
  sub _NumSeq_Coord_SumAbs_min {
    my ($self) = @_;
    return ($self->{'points'} eq 'odd'
            ? 1     # odd, origin 0,0 not included
            : $self->{'points'} eq 'hex_centred'
            ? 2     # hex_centred, origin 0,0 not included
            : 0);   # others include origin 0,0
  }
  sub _NumSeq_Coord_AbsDiff_min {
    my ($self) = @_;
    return ($self->{'points'} eq 'odd'
            ? 1     # odd, line X=Y not included
            : 0);   # even,all includes X=Y
  }

  sub _NumSeq_Coord_TRSquared_min {
    my ($self) = @_;
    return ($self->{'points'} eq 'odd'
            ? 1     # odd at X=1,Y=0
            : $self->{'points'} eq 'hex_centred'
            ? 4     # hex_centred at X=2,Y=0 or X=1,Y=1
            : 0);   # even,all at X=0,Y=0
  }
  {
    my %GCD_min = (odd         => 1,   # X=0,Y=0 not visited
                   hex_centred => 1);
    sub _NumSeq_Coord_GCD_min {
      my ($self) = @_;
      return $GCD_min{$self->{'points'}};
    }
  }

  # in order of triangular radius so monotonic, but can have duplicates so
  # non-decreasing
  use constant _NumSeq_Coord_TRadius_non_decreasing => 1;
}
{ package Math::PlanePath::PythagoreanTree;
  {
    my %_NumSeq_Coord_DiffXY_min = (PQ => 1, # octant X>=Y+1 so X-Y>=1
                                   );
    sub _NumSeq_Coord_DiffXY_min {
      my ($self) = @_;
      return $_NumSeq_Coord_DiffXY_min{$self->{'coordinates'}};
    }
  }
  {
    my %_NumSeq_Coord_AbsDiff_min = (PQ => 1,
                                     AB => 1, # X=Y never occurs
                                     BA => 1, # X=Y never occurs
                                    );
    sub _NumSeq_Coord_AbsDiff_min {
      my ($self) = @_;
      return $_NumSeq_Coord_AbsDiff_min{$self->{'coordinates'}};
    }
  }
  {
    my %_NumSeq_Coord_Int_min = (PQ => 1, # octant X>=Y+1 so X/Y>=1
                                );
    sub _NumSeq_Coord_Int_min {
      my ($self) = @_;
      return $_NumSeq_Coord_Int_min{$self->{'coordinates'}};
    }
    *_NumSeq_Int_min_is_infimum = \&_NumSeq_Coord_Int_min;
  }
  use constant _NumSeq_Coord_BitXor_min => 1; # AB at X=21,Y=20,  PQ at X=3,Y=2

  sub _NumSeq_Coord_Radius_integer {
    my ($self) = @_;
    return ($self->{'coordinates'} eq 'AB'); # hypot
  }

  # Not quite right.
  # sub _NumSeq_Coord_pred_Radius {
  #   my ($path, $value) = @_;
  #   return ($value >= 0
  #           && ($path->{'coordinate_type'} ne 'AB'
  #               || $value == int($value)));
  # }

  use constant _NumSeq_Coord_GCD_min => 1;  # no common factor
  use constant _NumSeq_Coord_GCD_max => 1;  # no common factor
  use constant _NumSeq_Coord_NumChildren_min => 3;
  use constant _NumSeq_Coord_NumChildren_max => 3;
  use constant _NumSeq_Coord_Depth_max => undef;
}
{ package Math::PlanePath::RationalsTree;
  use constant _NumSeq_Coord_NumChildren_min => 2;
  use constant _NumSeq_Coord_NumChildren_max => 2;
  use constant _NumSeq_Coord_Depth_max => undef;
  use constant _NumSeq_Coord_GCD_min => 1;  # no common factor
  use constant _NumSeq_Coord_GCD_max => 1;  # no common factor
  use constant _NumSeq_Coord_BitAnd_min => 0;  # X=1,Y=2
  use constant _NumSeq_Coord_BitXor_min => 0;  # X=1,Y=1

  use constant _NumSeq_Coord_oeis_anum =>
    { 'tree_type=SB' =>
      { Depth => 'A000523', # floor(log2(n)) starting OFFSET=1
        # OEIS-Catalogue: A000523 planepath=RationalsTree coordinate_type=Depth

        # Not quite, OFFSET n=0 cf N=1 here
        # Y => 'A047679', # SB denominator
        # # OEIS-Catalogue: A047679 planepath=RationalsTree coordinate_type=Y
        #
        # X => 'A007305',   # SB numerators but starting extra 0,1
        # Sum => 'A007306', # Farey/SB denominators, but starting extra 1,1
        # Product => 'A119272', # num*den, but starting extra 1,1
        # cf A054424 permutation
      },
      'tree_type=CW' =>
      {
       # Stern diatomic adjacent S(n)*S(n+1), or Conway's alimentary function
       Product => 'A070871',
       Depth   => 'A000523', # floor(log2(n)) starting OFFSET=1
       # OEIS-Catalogue: A070871 planepath=RationalsTree,tree_type=CW coordinate_type=Product
       # OEIS-Other:     A000523 planepath=RationalsTree,tree_type=CW coordinate_type=Depth

       # CW X and Y is Stern diatomic A002487, but RationalsTree starts N=0
       #    X=1,1,2 or Y=1,2 rather than from 0
       # CW DiffYX is A070990 stern diatomic first diffs, but RationalsTree
       #    starts N=0 diff=0, whereas A070990 starts n=0 diff=1 one less term
       #
      },
      'tree_type=AYT' =>
      { X      => 'A020650', # AYT numerator
        Y      => 'A020651', # AYT denominator
        Sum    => 'A086592', # Kepler's tree denominators
        SumAbs => 'A086592', # Kepler's tree denominators
        Depth  => 'A000523', # floor(log2(n)) starting OFFSET=1
        # OEIS-Catalogue: A020650 planepath=RationalsTree,tree_type=AYT coordinate_type=X
        # OEIS-Catalogue: A020651 planepath=RationalsTree,tree_type=AYT coordinate_type=Y
        # OEIS-Other: A086592 planepath=RationalsTree,tree_type=AYT coordinate_type=Sum
        # OEIS-Other: A000523 planepath=RationalsTree,tree_type=AYT coordinate_type=Depth

        # DiffYX almost A070990 Stern diatomic first differences, but we have
        # an extra 0 at the start, and we start i=1 rather than n=0 too
      },
      'tree_type=HCS' =>
      {
       Depth  => 'A000523', # floor(log2(n)) starting OFFSET=1
       # OEIS-Other: A000523 planepath=RationalsTree,tree_type=HCS coordinate_type=Depth

       # # Not quite, OFFSET=0 value=1/1 corresponding to N=0 X=0/Y=1 here
       # Sum    => 'A071585', # rats>=1 is HCS num+den
       # Y      => 'A071766', # rats>=1 HCS denominator
       # # OEIS-Catalogue: A071585 planepath=RationalsTree,tree_type=HCS coordinate_type=X
       # # OEIS-Catalogue: A071766 planepath=RationalsTree,tree_type=HCS coordinate_type=Y
      },
      'tree_type=Bird' =>
      { X   => 'A162909', # Bird tree numerators
        Y   => 'A162910', # Bird tree denominators
        Depth  => 'A000523', # floor(log2(n)) starting OFFSET=1
        # OEIS-Catalogue: A162909 planepath=RationalsTree,tree_type=Bird coordinate_type=X
        # OEIS-Catalogue: A162910 planepath=RationalsTree,tree_type=Bird coordinate_type=Y
        # OEIS-Other: A000523 planepath=RationalsTree,tree_type=Bird coordinate_type=Depth
      },
      'tree_type=Drib' =>
      { X      => 'A162911', # Drib tree numerators
        Y      => 'A162912', # Drib tree denominators
        Depth  => 'A000523', # floor(log2(n)) starting OFFSET=1
        # OEIS-Catalogue: A162911 planepath=RationalsTree,tree_type=Drib coordinate_type=X
        # OEIS-Catalogue: A162912 planepath=RationalsTree,tree_type=Drib coordinate_type=Y
        # OEIS-Other:     A000523 planepath=RationalsTree,tree_type=Drib coordinate_type=Depth
      },
      'tree_type=L' =>
      {
       X => 'A174981', # numerator
       # OEIS-Catalogue: A174981 planepath=RationalsTree,tree_type=L coordinate_type=X

       # # Not quite, A002487 extra initial, so n=2 is denominator at N=0
       # Y    => 'A002487', # denominator, stern diatomic
       # # OEIS-Catalogue: A071585 planepath=RationalsTree,tree_type=HCS coordinate_type=Y

       # Not quite, A000523 is OFFSET=0
       # Depth  => 'A000523', # floor(log2(n)) starting OFFSET=1
      },
    };
}
{ package Math::PlanePath::FractionsTree;
  use constant _NumSeq_Coord_DiffXY_max => -1; # upper octant X<=Y-1 so X-Y<=-1
  use constant _NumSeq_Coord_NumChildren_min => 2;
  use constant _NumSeq_Coord_NumChildren_max => 2;
  use constant _NumSeq_Coord_Depth_max => undef;
  use constant _NumSeq_Coord_Int_max => 0;  # 0 < X/Y < 1
  use constant _NumSeq_Coord_GCD_min => 1;  # no common factor
  use constant _NumSeq_Coord_GCD_max => 1;  # no common factor
  use constant _NumSeq_Coord_BitXor_min => 1;  # X=2,Y=3

  use constant _NumSeq_Coord_oeis_anum =>
    { 'tree_type=Kepler' =>
      { X       => 'A020651', # numerators, same as AYT denominators
        Y       => 'A086592', # Kepler half-tree denominators
        DiffYX  => 'A020650', # AYT numerators
        AbsDiff => 'A020650', # AYT numerators
        Depth   => 'A000523', # floor(log2(n)) starting OFFSET=1
        # OEIS-Other:     A020651 planepath=FractionsTree coordinate_type=X
        # OEIS-Catalogue: A086592 planepath=FractionsTree coordinate_type=Y
        # OEIS-Other:     A020650 planepath=FractionsTree coordinate_type=DiffYX
        # OEIS-Other:     A020650 planepath=FractionsTree coordinate_type=AbsDiff
        # OEIS-Other:     A000523 planepath=FractionsTree coordinate_type=Depth

        # Not quite, Sum is from 1/2 value=3 skipping the initial value=2 in
        # A086593 (which would be 1/1).  Also is every second denominator, but
        # again no initial value=2.
        # Sum => 'A086593',
        # Y_odd => 'A086593',   # at N=1,3,5,etc
      },
    };
}
{ package Math::PlanePath::CfracDigits;
  use constant _NumSeq_Coord_DiffXY_max => -1; # upper octant X<=Y-1 so X-Y<=-1
  use constant _NumSeq_Coord_GCD_min => 1;  # no common factor
  use constant _NumSeq_Coord_GCD_max => 1;  # no common factor
  use constant _NumSeq_Coord_BitXor_min => 1; # X=2,Y=3

  # use constant _NumSeq_Coord_oeis_anum =>
  #   { 'radix=2' =>
  # {
  # },
  # };
}
{ package Math::PlanePath::ChanTree;
  sub _NumSeq_Coord_Sum_min {
    my ($self) = @_;
    return ($self->{'reduced'} || $self->{'k'} == 2
            ? 2    # X=1,Y=1 reduced or k=2 X=1,Y=1
            : 3);  # X=1,Y=2
  }
  *_NumSeq_Coord_SumAbs_min = \&_NumSeq_Coord_Sum_min;

  sub _NumSeq_Coord_AbsDiff_min {
    my ($self) = @_;
    return ($self->{'k'} & 1
            ? 1    # k odd, X!=Y since one odd one even
            : 0);  # k even, has X=Y in top row
  }

  sub _NumSeq_Coord_Product_min {
    my ($self) = @_;
    return ($self->{'reduced'} || $self->{'k'} == 2
            ? 1    # X=1,Y=1 reduced or k=2 X=1,Y=1
            : 2);  # X=1,Y=2
  }
  sub _NumSeq_Coord_TRSquared_min {
    my ($self) = @_;
    return ($self->{'k'} == 2
            || ($self->{'reduced'} && ($self->{'k'} & 1) == 0)
            ? 4    # X=1,Y=1 reduced k even, or k=2 top 1/1
            : 7);  # X=2,Y=1
  }

  use constant _NumSeq_Coord_GCD_min => 1;  # X,Y >= 1
  sub _NumSeq_Coord_GCD_max {
    my ($self) = @_;
    return ($self->{'k'} == 2       # k=2, RationalsTree CW above
            || $self->{'reduced'}
            ? 1
            : undef);  # other, unlimited
  }

  sub _NumSeq_Coord_NumChildren_min {
    my ($self) = @_;
    return $self->{'k'};
  }
  *_NumSeq_Coord_NumChildren_max = \&_NumSeq_Coord_NumChildren_min;
  use constant _NumSeq_Coord_Depth_max => undef; # unlimited

  use constant _NumSeq_Coord_BitAnd_min => 0; # X=1,Y=2
  sub _NumSeq_Coord_BitOr_min {
    my ($self) = @_;
    return ($self->{'k'} == 2 || $self->{'reduced'} ? 1  # X=1,Y=1
            : $self->{'k'} & 1 ? 3  # k odd  X=1,Y=2
            : 2);                   # k even X=2,Y=2
  }
  sub _NumSeq_Coord_BitXor_min {
    my ($self) = @_;
    return ($self->{'k'} == 2 || $self->{'reduced'} ? 0  # X=1,Y=1
            : $self->{'k'} & 1 ? 1  # k odd  X=2,Y=3
            : 0);                   # k even X=2,Y=2
  }

  use constant _NumSeq_Coord_oeis_anum =>
    {
     do { # k=2 same as CW
       my $cw = { Product => 'A070871',
                  Depth   => 'A000523', # floor(log2(n)) starting OFFSET=1
                  # OEIS-Other: A070871 planepath=ChanTree,k=2,n_start=1 coordinate_type=Product
                  # OEIS-Other: A000523 planepath=ChanTree,k=2,n_start=1 coordinate_type=Depth
                };
       (
        'k=2,n_start=1' => $cw,

        # 'k=2,reduced=0,points=even,n_start=1' => $cw,
        # 'k=2,reduced=1,points=even,n_start=1' => $cw,
        # 'k=2,reduced=0,points=all,n_start=1' => $cw,
        # 'k=2,reduced=1,points=all,n_start=1' => $cw,
       ),
     },
     # 'k=3,reduced=0,points=even,n_start=0' =>
     'k=3,n_start=0' =>
     { X => 'A191379',
       # OEIS-Catalogue: A191379 planepath=ChanTree
     },
    };
}

{ package Math::PlanePath::PeanoCurve;
  use constant _NumSeq_Coord_oeis_anum =>
    {
     # Same in GrayCode and WunderlichSerpentine
     'radix=3' =>
     { X        => 'A163528',
       Y        => 'A163529',
       Sum      => 'A163530',
       SumAbs   => 'A163530',
       RSquared => 'A163531',
       # OEIS-Catalogue: A163528 planepath=PeanoCurve coordinate_type=X
       # OEIS-Catalogue: A163529 planepath=PeanoCurve coordinate_type=Y
       # OEIS-Catalogue: A163530 planepath=PeanoCurve coordinate_type=Sum
       # OEIS-Other:     A163530 planepath=PeanoCurve coordinate_type=SumAbs
       # OEIS-Catalogue: A163531 planepath=PeanoCurve coordinate_type=RSquared
     },
    };
}
{ package Math::PlanePath::WunderlichSerpentine;
  use constant _NumSeq_Coord_oeis_anum =>
    {
     do {
       my $peano = { X        => 'A163528',
                     Y        => 'A163529',
                     Sum      => 'A163530',
                     SumAbs   => 'A163530',
                     RSquared => 'A163531',
                   };
       # OEIS-Other: A163528 planepath=WunderlichSerpentine,serpentine_type=Peano,radix=3 coordinate_type=X
       # OEIS-Other: A163529 planepath=WunderlichSerpentine,serpentine_type=Peano,radix=3 coordinate_type=Y
       # OEIS-Other: A163530 planepath=WunderlichSerpentine,serpentine_type=Peano,radix=3 coordinate_type=Sum
       # OEIS-Other: A163530 planepath=WunderlichSerpentine,serpentine_type=Peano,radix=3 coordinate_type=SumAbs
       # OEIS-Other: A163531 planepath=WunderlichSerpentine,serpentine_type=Peano,radix=3 coordinate_type=RSquared

       # ENHANCE-ME: with serpentine_type by bits too
       ('serpentine_type=Peano,radix=3' => $peano,
       )
     },
    };
}
{ package Math::PlanePath::HilbertCurve;
  use constant _NumSeq_Coord_oeis_anum =>
    { '' =>
      { X        => 'A059253',
        Y        => 'A059252',
        Sum      => 'A059261',
        SumAbs   => 'A059261',
        DiffXY   => 'A059285',
        RSquared => 'A163547',
        # OEIS-Catalogue: A059253 planepath=HilbertCurve coordinate_type=X
        # OEIS-Catalogue: A059252 planepath=HilbertCurve coordinate_type=Y
        # OEIS-Catalogue: A059261 planepath=HilbertCurve coordinate_type=Sum
        # OEIS-Other:     A059261 planepath=HilbertCurve coordinate_type=SumAbs
        # OEIS-Catalogue: A059285 planepath=HilbertCurve coordinate_type=DiffXY
        # OEIS-Catalogue: A163547 planepath=HilbertCurve coordinate_type=RSquared
      },
    };
}
{ package Math::PlanePath::HilbertSpiral;
  use constant _NumSeq_Coord_oeis_anum =>
    { '' =>
      {
       # HilbertSpiral going negative is mirror on X=-Y line, which is
       # (-Y,-X), so DiffXY = -Y-(-X) = X-Y same diff as plain HilbertCurve.
       DiffXY   => 'A059285',
       # OEIS-Other: A059285 planepath=HilbertSpiral coordinate_type=DiffXY
      },
    };
}
{ package Math::PlanePath::ZOrderCurve;
  use constant _NumSeq_Coord_oeis_anum =>
    { 'radix=2' =>
      { X => 'A059905',  # alternate bits first
        Y => 'A059906',  # alternate bits second
        # OEIS-Catalogue: A059905 planepath=ZOrderCurve coordinate_type=X
        # OEIS-Catalogue: A059906 planepath=ZOrderCurve coordinate_type=Y
      },
      'radix=3' =>
      { X => 'A163325',  # alternate ternary digits first
        Y => 'A163326',  # alternate ternary digits second
        # OEIS-Catalogue: A163325 planepath=ZOrderCurve,radix=3 coordinate_type=X
        # OEIS-Catalogue: A163326 planepath=ZOrderCurve,radix=3 coordinate_type=Y
      },
      'radix=10,i_start=1' =>
      {
       # i_start=1 per A080463 offset=1, it skips initial zero
       Sum    => 'A080463',
       SumAbs => 'A080463',
       # OEIS-Catalogue: A080463 planepath=ZOrderCurve,radix=10 coordinate_type=Sum i_start=1
       # OEIS-Other:     A080463 planepath=ZOrderCurve,radix=10 coordinate_type=SumAbs i_start=1
      },
      'radix=10,i_start=10' =>
      {
       # i_start=10 per A080464 OFFSET=10, it skips all but one initial zeros
       Product => 'A080464',
       # OEIS-Catalogue: A080464 planepath=ZOrderCurve,radix=10 coordinate_type=Product i_start=10

       AbsDiff => 'A080465',
       # OEIS-Catalogue: A080465 planepath=ZOrderCurve,radix=10 coordinate_type=AbsDiff i_start=10
      },
    };
}
  { package Math::PlanePath::GrayCode;
    use constant _NumSeq_Coord_oeis_anum =>
      {
       do {
         my $peano = { X        => 'A163528',
                       Y        => 'A163529',
                       Sum      => 'A163530',
                       SumAbs   => 'A163530',
                       RSquared => 'A163531',
                     };
         ('apply_type=TsF,gray_type=reflected,radix=3' => $peano,
          'apply_type=FsT,gray_type=reflected,radix=3' => $peano,
         ),

           # OEIS-Other: A163528 planepath=GrayCode,apply_type=TsF,radix=3 coordinate_type=X
           # OEIS-Other: A163529 planepath=GrayCode,apply_type=TsF,radix=3 coordinate_type=Y
           # OEIS-Other: A163530 planepath=GrayCode,apply_type=TsF,radix=3 coordinate_type=Sum
           # OEIS-Other: A163530 planepath=GrayCode,apply_type=TsF,radix=3 coordinate_type=SumAbs
           # OEIS-Other: A163531 planepath=GrayCode,apply_type=TsF,radix=3 coordinate_type=RSquared

           # OEIS-Other: A163528 planepath=GrayCode,apply_type=FsT,radix=3 coordinate_type=X
           # OEIS-Other: A163529 planepath=GrayCode,apply_type=FsT,radix=3 coordinate_type=Y
           # OEIS-Other: A163530 planepath=GrayCode,apply_type=FsT,radix=3 coordinate_type=Sum
           # OEIS-Other: A163530 planepath=GrayCode,apply_type=FsT,radix=3 coordinate_type=SumAbs
           # OEIS-Other: A163531 planepath=GrayCode,apply_type=FsT,radix=3 coordinate_type=RSquared

       },
      };
  }
# { package Math::PlanePath::ImaginaryBase;
# }
# { package Math::PlanePath::ImaginaryHalf;
# }
# { package Math::PlanePath::CubicBase;
# }
{ package Math::PlanePath::GosperIslands;
  use constant _NumSeq_Coord_SumAbs_min => 2; # minimum X=2,Y=0 or X=1,Y=1
  use constant _NumSeq_Coord_TRSquared_min => 4; # minimum X=1,Y=1
  use constant _NumSeq_Coord_GCD_min => 1; # X=0,Y=0 not visited
}
# { package Math::PlanePath::GosperSide;
# }
{ package Math::PlanePath::KochCurve;
  use constant _NumSeq_Coord_Int_min => 0;  # X>Y so X/Y>1
}
{ package Math::PlanePath::KochPeaks;
  use constant _NumSeq_Coord_AbsDiff_min  => 1; # X=Y never occurs
  use constant _NumSeq_Coord_SumAbs_min => 1; # minimum X=1,Y=0
  use constant _NumSeq_Coord_TRSquared_min => 1; # minimum X=1,Y=0
  use constant _NumSeq_Coord_GCD_min => 1;  # X=0,Y=0 not visited
}
{ package Math::PlanePath::KochSnowflakes;
  use constant _NumSeq_Coord_Y_integer => 0;
  use constant _NumSeq_Coord_BitAnd_integer => 1; # only Y non-integer
  use constant _NumSeq_Coord_SumAbs_min => 2/3; # minimum X=0,Y=2/3
  use constant _NumSeq_Coord_Radius_min   => 2/3; # minimum X=0,Y=2/3
  use constant _NumSeq_Coord_TRSquared_min => 3*4/9; # minimum X=0,Y=2/3
  use constant _NumSeq_Coord_TRadius_min => sqrt(_NumSeq_Coord_TRSquared_min);
}
{ package Math::PlanePath::KochSquareflakes;
  use constant _NumSeq_Coord_X_integer => 0;
  use constant _NumSeq_Coord_Y_integer => 0;
  use constant _NumSeq_Coord_Sum_integer => 1;
  use constant _NumSeq_Coord_SumAbs_integer => 1;
  use constant _NumSeq_Coord_DiffXY_integer => 1;
  use constant _NumSeq_Coord_DiffYX_integer => 1;
  use constant _NumSeq_Coord_AbsDiff_integer => 1;
  use constant _NumSeq_Coord_BitXor_integer => 1; # 0.5 xor 0.5 cancels out
  use constant _NumSeq_Coord_SumAbs_min => 1;
  use constant _NumSeq_Coord_TRSquared_min => 1; # X=0.5,Y=0.5
  use constant _NumSeq_Coord_TRSquared_integer => 1;
}
{ package Math::PlanePath::QuadricCurve;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y
  use constant _NumSeq_Coord_DiffXY_min => 0; # triangular Y<=X so X-Y>=0
  use constant _NumSeq_Coord_Int_min => 1;  # X>=Y so X/Y>=1
}
{ package Math::PlanePath::QuadricIslands;
  use constant _NumSeq_Coord_X_integer => 0;
  use constant _NumSeq_Coord_Y_integer => 0;
  use constant _NumSeq_Coord_Sum_integer => 1;    # 0.5 + 0.5 = integer
  use constant _NumSeq_Coord_SumAbs_integer => 1;
  use constant _NumSeq_Coord_DiffXY_integer => 1;
  use constant _NumSeq_Coord_DiffYX_integer => 1;
  use constant _NumSeq_Coord_AbsDiff_integer => 1;
  use constant _NumSeq_Coord_SumAbs_min => 1; # minimum X=1/2,Y=1/2
  use constant _NumSeq_Coord_TRSquared_min => 1; # X=1/2,Y=1/2
}
{ package Math::PlanePath::SierpinskiTriangle;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y
  sub _NumSeq_Coord_DiffXY_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'diagonal' ? undef
           : 0); # triangular X<=Y so X-Y<=0
  }
  sub _NumSeq_Coord_Y_non_decreasing {
    my ($self) = @_;
    return ($self->{'align'} ne 'diagonal'); # rows upwards, except diagonal
  }
  sub _NumSeq_Coord_Sum_non_decreasing {
    my ($self) = @_;
    return ($self->{'align'} eq 'diagonal'); # anti-diagonals
  }
  *_NumSeq_Coord_SumAbs_non_decreasing = \&_NumSeq_Coord_Sum_non_decreasing;

  # align=diagonal has X,Y no 1-bits in common, so BitAnd==0
  sub _NumSeq_Coord_BitAnd_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'diagonal' ? 0
           : undef);
  }
  sub _NumSeq_Coord_BitAnd_non_decreasing {
    my ($self) = @_;
    return ($self->{'align'} eq 'diagonal');
  }

  # align=right,diagonal has X,Y bitor accumulating ...
  sub _NumSeq_Coord_BitOr_non_decreasing {
    my ($self) = @_;
    return ($self->{'align'} eq 'right'
            || $self->{'align'} eq 'diagonal');
  }

  use constant _NumSeq_Coord_NumChildren_max => 2;
  use constant _NumSeq_Coord_Depth_max => undef;
  sub _NumSeq_Coord_Int_max {
    my ($self) = @_;
    return ($self->{'align'} eq 'diagonal' ? undef
           : 1); # triangular X<=Y so X/Y<=1
  }
}
{ package Math::PlanePath::SierpinskiArrowhead;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y
  *_NumSeq_Coord_DiffXY_max
    = \&Math::PlanePath::SierpinskiTriangle::_NumSeq_Coord_DiffXY_max;
  *_NumSeq_Coord_Int_max
    = \&Math::PlanePath::SierpinskiTriangle::_NumSeq_Coord_Int_max;
}
{ package Math::PlanePath::SierpinskiArrowheadCentres;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y
  *_NumSeq_Coord_DiffXY_max
    = \&Math::PlanePath::SierpinskiTriangle::_NumSeq_Coord_DiffXY_max;
  *_NumSeq_Coord_Int_max
    = \&Math::PlanePath::SierpinskiTriangle::_NumSeq_Coord_Int_max;
}
{ package Math::PlanePath::SierpinskiCurve;
  {
    my @Sum_min = (undef,
                   1,  # 1 arm, octant and X>=1 so X+Y>=1
                   1,  # 2 arms, X>=1 or Y>=1 so X+Y>=1
                   0,  # 3 arms, Y>=1 and X>=Y, so X+Y>=0
                  );   # more than 3 arm, Sum goes negative
    sub _NumSeq_Coord_Sum_min {
      my ($self) = @_;
      return $Sum_min[$self->arms_count];
    }
  }
  sub _NumSeq_Coord_DiffXY_min {
    my ($self) = @_;
    return ($self->arms_count == 1
            ? 1       # octant Y<=X-1 so X-Y>=1
            : undef); # more than 1 arm, DiffXY goes negative
  }
  sub _NumSeq_Coord_Int_min {
    my ($self) = @_;
    return ($self->arms_count == 1
            ? 1       # octant X>Y so X/Y>1
            : undef); # more than 1 arm
  }
  *_NumSeq_Int_min_is_infimum = \&_NumSeq_Coord_Int_min;

  use constant _NumSeq_Coord_SumAbs_min => 1;
  use constant _NumSeq_Coord_AbsDiff_min => 1; # X=Y never occurs
  use constant _NumSeq_Coord_TRSquared_min => 1; # minimum X=1,Y=0
  use constant _NumSeq_Coord_GCD_min => 1;  # X=0,Y=0 not visited
}
{ package Math::PlanePath::SierpinskiCurveStair;
  *_NumSeq_Coord_Sum_min = \&Math::PlanePath::SierpinskiCurve::_NumSeq_Coord_Sum_min;
  *_NumSeq_Coord_DiffXY_min = \&Math::PlanePath::SierpinskiCurve::_NumSeq_Coord_DiffXY_min;
  *_NumSeq_Coord_Int_min = \&Math::PlanePath::SierpinskiCurve::_NumSeq_Coord_Int_min;
  *_NumSeq_Coord_Int_is_infimum = \&Math::PlanePath::SierpinskiCurve::_NumSeq_Coord_Int_is_infimum;
  use constant _NumSeq_Coord_SumAbs_min => 1;
  use constant _NumSeq_Coord_AbsDiff_min => 1; # X=Y never occurs
  use constant _NumSeq_Coord_TRSquared_min => 1; # minimum X=1,Y=0
  use constant _NumSeq_Coord_GCD_min => 1;  # X=0,Y=0 not visited
}
{ package Math::PlanePath::HIndexing;
  use constant _NumSeq_Coord_DiffXY_max => 0; # upper octant X<=Y so X-Y<=0
  use constant _NumSeq_Coord_Int_max => 1; # upper octant X<=Y so X/Y<=1
}
{ package Math::PlanePath::DragonCurve;
  use constant _NumSeq_Coord_NumSurround4_min => 2;
  # use constant _NumSeq_Coord_NumSurround6_min => 0; # ???
  use constant _NumSeq_Coord_NumSurround8_min => 3;
}
{ package Math::PlanePath::DragonRounded;
  use constant _NumSeq_Coord_SumAbs_min => 1;
  use constant _NumSeq_Coord_AbsDiff_min  => 1; # X=Y doesn't occur
  use constant _NumSeq_Coord_TRSquared_min => 1; # minimum X=1,Y=0
  use constant _NumSeq_Coord_GCD_min => 1;  # X=0,Y=0 not visited
}
# { package Math::PlanePath::DragonMidpoint;
# }
{ package Math::PlanePath::AlternatePaper;
  use constant _NumSeq_Coord_oeis_anum =>
    { 'i_start=1' =>
      { DiffXY  => 'A020990', # GRS*(-1)^n cumulative
        AbsDiff => 'A020990',
        # X_undoubled => 'A020986', # GRS cumulative
        # Y_undoubled => 'A020990', # GRS*(-1)^n cumulative
      },
    };
}
# { package Math::PlanePath::TerdragonCurve;
# }
{ package Math::PlanePath::TerdragonRounded;
  use constant _NumSeq_Coord_SumAbs_min => 2; # X=2,Y=0
  use constant _NumSeq_Coord_TRSquared_min => 4; # either X=2,Y=0 or X=1,Y=1
  use constant _NumSeq_Coord_GCD_min => 1;  # X=0,Y=0 not visited
}
{ package Math::PlanePath::TerdragonMidpoint;
  use constant _NumSeq_Coord_SumAbs_min => 2; # X=2,Y=0 or X=1,Y=1
  use constant _NumSeq_Coord_TRSquared_min => 4; # either X=2,Y=0 or X=1,Y=1
  use constant _NumSeq_Coord_GCD_min => 1;  # X=0,Y=0 not visited
}
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
  use constant _NumSeq_extra_parameter_info_list =>
    { name => 'width',
      type => 'integer',
    };
  *_NumSeq_Coord_Int_max = \&x_maximum;

  sub _NumSeq_Coord_Y_increasing {
    my ($self) = @_;
    return ($self->{'width'} == 1
            ? 1    # X=N,Y=0 only
            : 0);
  }
  *_NumSeq_Coord_Radius_increasing      = \&_NumSeq_Coord_Y_increasing;
  *_NumSeq_Coord_Radius_integer         = \&_NumSeq_Coord_Y_increasing;
  *_NumSeq_Coord_DiffYX_increasing      = \&_NumSeq_Coord_Y_increasing;
  *_NumSeq_Coord_Sum_increasing         = \&_NumSeq_Coord_Y_increasing;
  *_NumSeq_Coord_SumAbs_increasing      = \&_NumSeq_Coord_Y_increasing;
  *_NumSeq_Coord_AbsDiff_increasing     = \&_NumSeq_Coord_Y_increasing;
  *_NumSeq_Coord_X_non_decreasing       = \&_NumSeq_Coord_Y_increasing;
  *_NumSeq_Coord_Product_non_decreasing = \&_NumSeq_Coord_Y_increasing;
  *_NumSeq_Coord_GCD_increasing         = \&_NumSeq_Coord_Y_increasing;

  sub _NumSeq_Coord_Sum_non_decreasing {
    my ($self) = @_;
    return ($self->{'width'} <= 2
            ? 1    # width=1 is X=0,Y=N only, or width=2 is X=0,1,Y=N/2
            : 0);
  }
  *_NumSeq_Coord_SumAbs_non_decreasing = \&_NumSeq_Coord_Sum_non_decreasing;
  *_NumSeq_Coord_Radius_non_decreasing = \&_NumSeq_Coord_Sum_non_decreasing;

  # width <= 2 one or two columns is increasing
  *_NumSeq_Coord_TRadius_increasing = \&_NumSeq_Coord_Sum_non_decreasing;

  use constant _NumSeq_Coord_Y_non_decreasing => 1; # rows upwards

  use constant _NumSeq_Coord_oeis_anum =>
    { 'n_start=1,width=1' =>
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

      # 'n_start=0,width=2' =>
      # { X       => 'A000035', # 0,1 repeating OFFSET=0
      #   # OEIS-Other: A000035 planepath=Rows,width=2,n_start=0 coordinate_type=X
      #   # sequence in Math::NumSeq::Modulo
      #
      #   Y       => 'A004526', # 0,0,1,1,2,2,etc OFFSET=0
      #   # OEIS-Other: A004526 planepath=Rows,width=2,n_start=0 coordinate_type=Y
      #   # sequence in Math::NumSeq::Runs "2rep"
      #
      #   # Not quite, A142150 OFFSET=0 starting 0,0,1,0,2 interleave integers
      #   # and 0 but Product here extra 0 start 0,0,0,1,0,2,0
      #   # Product => 'A142150'
      #
      #   # Not quite, GCD=>'A057979' but A057979 extra initial 1
      # },
    };
}
{ package Math::PlanePath::Columns;
  use constant _NumSeq_extra_parameter_info_list =>
    { name => 'height',
      type => 'integer',
    };

  sub _NumSeq_Coord_X_increasing {
    my ($self) = @_;
    return ($self->{'height'} == 1
            ? 1    # X=N,Y=0 only
            : 0);
  }
  *_NumSeq_Coord_Radius_increasing      = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_Radius_integer         = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_TRadius_increasing     = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_TRadius_integer        = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_DiffXY_increasing      = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_Sum_increasing         = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_SumAbs_increasing      = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_AbsDiff_increasing     = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_Y_non_decreasing       = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_Product_non_decreasing = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_GCD_increasing         = \&_NumSeq_Coord_X_increasing;
  use constant _NumSeq_Coord_X_non_decreasing => 1; # columns across

  sub _NumSeq_Coord_Sum_non_decreasing {
    my ($self) = @_;
    return ($self->{'height'} <= 2
            ? 1    # height=1 is X=N,Y=0 only, or height=2 is X=N/2,Y=0,1
            : 0);
  }
  *_NumSeq_Coord_SumAbs_non_decreasing = \&_NumSeq_Coord_Sum_non_decreasing;
  *_NumSeq_Coord_Radius_non_decreasing = \&_NumSeq_Coord_Sum_non_decreasing;


  use constant _NumSeq_Coord_oeis_anum =>
    { 'n_start=1,height=1' =>
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

      # 'n_start=0,height=2' =>
      # { X       => 'A004526', # 0,0,1,1,2,2,etc OFFSET=0
      #   # OEIS-Other: A004526 planepath=Rows,width=2,n_start=0 coordinate_type=X
      #
      #   Y       => 'A000035', # 0,1 repeating OFFSET=0
      #   # OEIS-Other: A000035 planepath=Rows,width=2,n_start=0 coordinate_type=Y
      # },
    };
}
{ package Math::PlanePath::Diagonals;
  use constant _NumSeq_extra_parameter_info_list =>
    { name => 'x_start',
      type => 'integer',
    },
    { name => 'y_start',
      type => 'integer',
    };
  use constant _NumSeq_Coord_Sum_non_decreasing => 1; # X+Y diagonals
  use constant _NumSeq_Coord_SumAbs_non_decreasing => 1; # X+Y diagonals

  use constant _NumSeq_Coord_oeis_anum =>
    { 'direction=down,n_start=1,x_start=0,y_start=0' =>
      { 
      },

      'direction=down,n_start=0,x_start=0,y_start=0' =>
      { X        => 'A002262',  # runs 0toN   0, 0,1, 0,1,2, etc
        Y        => 'A025581',  # runs Nto0   0, 1,0, 2,1,0, 3,2,1,0 descending
        Sum      => 'A003056',  # 0, 1,1, 2,2,2, 3,3,3,3
        SumAbs   => 'A003056',  #   same
        Product  => 'A004247',  # 0, 0,0,0, 1, 0,0, 2,2, 0,0, 3,4,5, 0,0
        DiffYX   => 'A114327',  # Y-X by anti-diagonals
        AbsDiff  => 'A049581',  # abs(Y-X) by anti-diagonals
        RSquared => 'A048147',  # x^2+y^2 by diagonals
        BitAnd   => 'A004198',  # X bitand Y
        BitOr    => 'A003986',  # X bitor Y, cf A006583 diagonal totals
        BitXor   => 'A003987',  # cf A006582 X xor Y diagonal totals
        GCD      => 'A109004',  # GCD(x,y) by diagonals, (0,0) at n=0
        Min      => 'A004197',  # X,Y>=0, runs 0toNto0,0toNNto0
        MinAbs   => 'A004197',
        Max      => 'A003984',
        MaxAbs   => 'A003984',
        HammingDist => 'A101080',
        # OEIS-Other: A002262 planepath=Diagonals,n_start=0 coordinate_type=X
        # OEIS-Other: A025581 planepath=Diagonals,n_start=0 coordinate_type=Y
        # OEIS-Other: A003056 planepath=Diagonals,n_start=0 coordinate_type=Sum
        # OEIS-Other: A003056 planepath=Diagonals,n_start=0 coordinate_type=SumAbs
        # OEIS-Catalogue: A004247 planepath=Diagonals,n_start=0 coordinate_type=Product
        # OEIS-Catalogue: A114327 planepath=Diagonals,n_start=0 coordinate_type=DiffYX
        # OEIS-Catalogue: A049581 planepath=Diagonals,n_start=0 coordinate_type=AbsDiff
        # OEIS-Catalogue: A048147 planepath=Diagonals,n_start=0 coordinate_type=RSquared
        # OEIS-Catalogue: A004198 planepath=Diagonals,n_start=0 coordinate_type=BitAnd
        # OEIS-Catalogue: A003986 planepath=Diagonals,n_start=0 coordinate_type=BitOr
        # OEIS-Catalogue: A003987 planepath=Diagonals,n_start=0 coordinate_type=BitXor
        # OEIS-Catalogue: A109004 planepath=Diagonals,n_start=0 coordinate_type=GCD
        # OEIS-Catalogue: A004197 planepath=Diagonals,n_start=0 coordinate_type=Min
        # OEIS-Other:     A004197 planepath=Diagonals,n_start=0 coordinate_type=MinAbs
        # OEIS-Catalogue: A003984 planepath=Diagonals,n_start=0 coordinate_type=Max
        # OEIS-Other:     A003984 planepath=Diagonals,n_start=0 coordinate_type=MaxAbs
        # OEIS-Catalogue: A101080 planepath=Diagonals,n_start=0 coordinate_type=HammingDist
      },
      'direction=up,n_start=0,x_start=0,y_start=0' =>
      { X        => 'A025581',  # \ opposite of direction="down"
        Y        => 'A002262',  # /
        Sum      => 'A003056',  # \
        SumAbs   => 'A003056',  # | same as direction="down'
        Product  => 'A004247',  # |
        AbsDiff  => 'A049581',  # |
        RSquared => 'A048147',  # /
        DiffXY   => 'A114327',  # transposed from direction="down"
        BitAnd   => 'A004198',  # X bitand Y
        BitOr    => 'A003986',  # X bitor Y, cf A006583 diagonal totals
        BitXor   => 'A003987',  # cf A006582 X xor Y diagonal totals
        GCD      => 'A109004',  # GCD(x,y) by diagonals, (0,0) at n=0
        # OEIS-Other: A025581 planepath=Diagonals,direction=up,n_start=0 coordinate_type=X
        # OEIS-Other: A002262 planepath=Diagonals,direction=up,n_start=0 coordinate_type=Y
        # OEIS-Other: A003056 planepath=Diagonals,direction=up,n_start=0 coordinate_type=Sum
        # OEIS-Other: A003056 planepath=Diagonals,direction=up,n_start=0 coordinate_type=SumAbs
        # OEIS-Other: A004247 planepath=Diagonals,direction=up,n_start=0 coordinate_type=Product
        # OEIS-Other: A114327 planepath=Diagonals,direction=up,n_start=0 coordinate_type=DiffXY
        # OEIS-Other: A049581 planepath=Diagonals,direction=up,n_start=0 coordinate_type=AbsDiff
        # OEIS-Other: A048147 planepath=Diagonals,direction=up,n_start=0 coordinate_type=RSquared
        # OEIS-Other: A004198 planepath=Diagonals,n_start=0 coordinate_type=BitAnd
        # OEIS-Other: A003986 planepath=Diagonals,n_start=0 coordinate_type=BitOr
        # OEIS-Other: A003987 planepath=Diagonals,n_start=0 coordinate_type=BitXor
        # OEIS-Other: A109004 planepath=Diagonals,n_start=0 coordinate_type=GCD
      },

      'direction=down,n_start=1,x_start=1,y_start=1' =>
      { Product => 'A003991', # X*Y starting (1,1) n=1
        GCD     => 'A003989', # GCD by diagonals starting (1,1) n=1
        Min     => 'A003983', # X,Y>=1
        MinAbs  => 'A003983',
        Max     => 'A051125', # X,Y>=1
        MaxAbs  => 'A051125',
        # OEIS-Catalogue: A003991 planepath=Diagonals,x_start=1,y_start=1 coordinate_type=Product
        # OEIS-Catalogue: A003989 planepath=Diagonals,x_start=1,y_start=1 coordinate_type=GCD
        # OEIS-Catalogue: A003983 planepath=Diagonals,x_start=1,y_start=1 coordinate_type=Min
        # OEIS-Other:     A003983 planepath=Diagonals,x_start=1,y_start=1 coordinate_type=MinAbs
        # OEIS-Catalogue: A051125 planepath=Diagonals,x_start=1,y_start=1 coordinate_type=Max
        # OEIS-Other:     A051125 planepath=Diagonals,x_start=1,y_start=1 coordinate_type=MaxAbs

        # cf A003990 LCM starting (1,1) n=1
        #    A003992 X^Y power starting (1,1) n=1
      },

      'direction=up,n_start=1,x_start=1,y_start=1' =>
      { Product => 'A003991', # X*Y starting (1,1) n=1
        GCD     => 'A003989', # GCD by diagonals starting (1,1) n=1
        Int     => 'A003988', # Int(X/Y) starting (1,1) n=1
        # OEIS-Other:     A003991 planepath=Diagonals,x_start=1,y_start=1 coordinate_type=Product
        # OEIS-Other:     A003989 planepath=Diagonals,x_start=1,y_start=1 coordinate_type=GCD
        # OEIS-Catalogue: A003988 planepath=Diagonals,direction=up,x_start=1,y_start=1 coordinate_type=Int
      },
    };
}
{ package Math::PlanePath::DiagonalsAlternating;
  use constant _NumSeq_Coord_Sum_non_decreasing => 1; # X+Y diagonals
  use constant _NumSeq_Coord_SumAbs_non_decreasing => 1; # X+Y diagonals

  use constant _NumSeq_Coord_oeis_anum =>
    { 'n_start=0' =>
      { Sum      => 'A003056',  # 0, 1,1, 2,2,2, 3,3,3,3
        SumAbs   => 'A003056',  #   same
        Product  => 'A004247',  # 0, 0,0,0, 1, 0,0, 2,2, 0,0, 3,4,5, 0,0
        AbsDiff  => 'A049581',  # abs(Y-X) by anti-diagonals
        RSquared => 'A048147',  # x^2+y^2 by diagonals
        BitAnd   => 'A004198',  # X bitand Y
        BitOr    => 'A003986',  # X bitor Y, cf A006583 diagonal totals
        BitXor   => 'A003987',  # cf A006582 X xor Y diagonal totals
        Min      => 'A004197',  # runs 0toNto0,0toNNto0
        MinAbs   => 'A004197',
        Max      => 'A003984',
        MaxAbs   => 'A003984',
        # OEIS-Other: A003056 planepath=DiagonalsAlternating,n_start=0 coordinate_type=Sum
        # OEIS-Other: A003056 planepath=DiagonalsAlternating,n_start=0 coordinate_type=SumAbs
        # OEIS-Other: A004247 planepath=DiagonalsAlternating,n_start=0 coordinate_type=Product
        # OEIS-Other: A049581 planepath=DiagonalsAlternating,n_start=0 coordinate_type=AbsDiff
        # OEIS-Other: A048147 planepath=DiagonalsAlternating,n_start=0 coordinate_type=RSquared
        # OEIS-Other: A004198 planepath=DiagonalsAlternating,n_start=0 coordinate_type=BitAnd
        # OEIS-Other: A003986 planepath=DiagonalsAlternating,n_start=0 coordinate_type=BitOr
        # OEIS-Other: A003987 planepath=DiagonalsAlternating,n_start=0 coordinate_type=BitXor
        # OEIS-Other: A004197 planepath=DiagonalsAlternating,n_start=0 coordinate_type=Min
        # OEIS-Other: A004197 planepath=DiagonalsAlternating,n_start=0 coordinate_type=MinAbs
        # OEIS-Other: A003984 planepath=DiagonalsAlternating,n_start=0 coordinate_type=Max
        # OEIS-Other: A003984 planepath=DiagonalsAlternating,n_start=0 coordinate_type=MaxAbs
      },
    };
}
{ package Math::PlanePath::DiagonalsOctant;
  use constant _NumSeq_Coord_DiffXY_max => 0; # octant X<=Y so X-Y<=0
  use constant _NumSeq_Coord_Sum_non_decreasing => 1; # X+Y diagonals
  use constant _NumSeq_Coord_SumAbs_non_decreasing => 1; # X+Y diagonals

  use constant _NumSeq_Coord_oeis_anum =>
    { 'direction=down,n_start=0' =>
      { X       => 'A055087',  # 0, 0,1, 0,1, 0,1,2, 0,1,2, etc
        Min     => 'A055087',  # X<=Y so Min=X
        MinAbs  => 'A055087',
        Sum     => 'A055086',  # reps floor(n/2)+1
        SumAbs  => 'A055086',  #   same
        DiffYX  => 'A082375',  # step=2 k to 0
        # OEIS-Catalogue: A055087 planepath=DiagonalsOctant,n_start=0 coordinate_type=X
        # OEIS-Other:     A055087 planepath=DiagonalsOctant,n_start=0 coordinate_type=Min
        # OEIS-Other:     A055087 planepath=DiagonalsOctant,n_start=0 coordinate_type=MinAbs
        # OEIS-Catalogue: A055086 planepath=DiagonalsOctant,n_start=0 coordinate_type=Sum
        # OEIS-Other:     A055086 planepath=DiagonalsOctant,n_start=0 coordinate_type=SumAbs
        # OEIS-Catalogue: A082375 planepath=DiagonalsOctant,n_start=0 coordinate_type=DiffYX
      },
      'direction=up,n_start=0' =>
      { Sum     => 'A055086',  # reps floor(n/2)+1
        SumAbs  => 'A055086',  #   same
        # OEIS-Other: A055086 planepath=DiagonalsOctant,direction=up,n_start=0 coordinate_type=Sum
        # OEIS-Other: A055086 planepath=DiagonalsOctant,direction=up,n_start=0 coordinate_type=SumAbs
      },
    };
}
# { package Math::PlanePath::MPeaks;
# }
# { package Math::PlanePath::Staircase;
# }
# { package Math::PlanePath::StaircaseAlternating;
# }
{ package Math::PlanePath::Corner;
  use constant _NumSeq_Coord_oeis_anum =>
    { 'wider=0,n_start=0' =>
      { DiffXY  => 'A196199', # runs -n to n
        AbsDiff => 'A053615', # runs 0..n..0
        Max     => 'A000196',
        MaxAbs  => 'A000196',
        # OEIS-Other:     A196199 planepath=Corner,n_start=0 coordinate_type=DiffXY
        # OEIS-Catalogue: A053615 planepath=Corner,n_start=0 coordinate_type=AbsDiff
        # OEIS-Other:     A000196 planepath=Corner,n_start=0 coordinate_type=Max
        # OEIS-Other:     A000196 planepath=Corner,n_start=0 coordinate_type=MaxAbs

        # Not quite, A053188 has extra initial 0
        # AbsDiff => 'A053188', # distance to nearest square
      },
    };
}
{ package Math::PlanePath::PyramidRows;
  sub _NumSeq_Coord_Sum_min {
    my ($self) = @_;
    # for align=right X>=0 so X+Y >= 0
    # for step==0   X=0 so X+Y >= 0
    # for step==1   X>=-Y so X+Y >= 0
    # for step==2 and align=centre   X>=-Y so X+Y >= 0
    return ($self->{'step'} <= 1
            || $self->{'align'} eq 'right'
            || ($self->{'step'} == 2 && $self->{'align'} eq 'centre')
            ? 0
            : undef);
  }
  sub _NumSeq_Coord_DiffXY_max {
    my ($self) = @_;
    # for step==0   X=0 so X-Y <= 0
    # for step==1   X<=Y so X-Y <= 0
    # for step==2 and align=left,centre   X<=Y so X-Y <= 0
    return ($self->{'step'} <= 1
            || ($self->{'step'} == 2 && $self->{'align'} ne 'right')
            ? 0
            : undef);
  }
  sub _NumSeq_Coord_Int_max {
    my ($self) = @_;
    return ($self->{'step'} <= 1 ? 0 : undef);
  }

  sub _NumSeq_Coord_Radius_integer {
    my ($self) = @_;
    return ($self->{'step'} == 0);
  }

  sub _NumSeq_Coord_Y_increasing {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 1       # column X=0,Y=N
            : 0);
  }
  *_NumSeq_Coord_Sum_increasing = \&_NumSeq_Coord_Y_increasing;
  *_NumSeq_Coord_SumAbs_increasing = \&_NumSeq_Coord_Y_increasing;
  *_NumSeq_Coord_DiffYX_increasing = \&_NumSeq_Coord_Y_increasing;
  *_NumSeq_Coord_AbsDiff_increasing = \&_NumSeq_Coord_Y_increasing;
  *_NumSeq_Coord_Radius_increasing = \&_NumSeq_Coord_Y_increasing;
  *_NumSeq_Coord_TRadius_increasing = \&_NumSeq_Coord_Y_increasing;
  *_NumSeq_Coord_BitAnd_increasing = \&_NumSeq_Coord_Y_increasing;
  *_NumSeq_Coord_BitOr_increasing = \&_NumSeq_Coord_Y_increasing;
  *_NumSeq_Coord_BitXor_increasing = \&_NumSeq_Coord_Y_increasing;
  *_NumSeq_Coord_GCD_increasing = \&_NumSeq_Coord_Y_increasing;

  use constant _NumSeq_Coord_Y_non_decreasing => 1; # rows upwards
  *_NumSeq_Coord_X_non_decreasing = \&_NumSeq_Coord_Y_increasing; # X=0 always
  *_NumSeq_Coord_Product_non_decreasing = \&_NumSeq_Coord_Y_increasing; # N*0=0


  use constant _NumSeq_Coord_oeis_anum =>
    {
     # PyramidRows step=0 is trivial X=0,Y=N
     do {
       my $href = { X        => 'A000004',  # all-zeros
                    Product  => 'A000004',  # all-zeros
                    # OEIS-Other: A000004 planepath=PyramidRows,step=0 coordinate_type=X
                    # OEIS-Other: A000004 planepath=PyramidRows,step=0 coordinate_type=Product

                    # but OFFSET=0 starting value 0, whereas N=1 for value 0 here
                    # RSquared => 'A000290',  # squares 0 upwards
                    # # OEIS-Other: A000290 planepath=PyramidRows,step=0 coordinate_type=RSquared

                    # But A001477 OFFSET=0 where PyramidRows starts N=1
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
                  };
       ('step=0,align=centre' => $href,
        'step=0,align=right'  => $href,
        'step=0,align=left'   => $href,
       );

     },

     # PyramidRows step=1
     # cf A050873 GCD triangle starting (1,1) n=1
     #    A051173 LCM triangle starting (1,1) n=1
     #    A003991 X*Y product starting (1,1) n=1
     #
     do {
       my $href =
         { X        => 'A002262',  # 0, 0,1, 0,1,2, etc (Diagonals)
           Y        => 'A003056',  # 0, 1,1, 2,2,2, 3,3,3,3 (Diagonals)
           DiffYX   => 'A025581',  # descending N to 0 (Diagonals)
           AbsDiff  => 'A025581',  #   absdiff same
           Sum      => 'A051162',  # triangle X+Y for X=0 to Y inclusive
           SumAbs   => 'A051162',  #   sumabs same
           RSquared => 'A069011',  # triangle X^2+Y^2 for X=0 to Y inclusive
         };
       ('step=1,align=centre,n_start=0' => $href,
        'step=1,align=right,n_start=0'  => $href,
       );
       # OEIS-Other: A002262 planepath=PyramidRows,step=1,n_start=0 coordinate_type=X
       # OEIS-Other: A003056 planepath=PyramidRows,step=1,n_start=0 coordinate_type=Y
       # OEIS-Other: A025581 planepath=PyramidRows,step=1,n_start=0 coordinate_type=DiffYX
       # OEIS-Other: A025581 planepath=PyramidRows,step=1,n_start=0 coordinate_type=AbsDiff
       # OEIS-Other: A051162 planepath=PyramidRows,step=1,n_start=0 coordinate_type=Sum
       # OEIS-Other: A051162 planepath=PyramidRows,step=1,n_start=0 coordinate_type=SumAbs
       # OEIS-Catalogue: A069011 planepath=PyramidRows,step=1,n_start=0 coordinate_type=RSquared

       # OEIS-Other: A002262 planepath=PyramidRows,step=1,align=right,n_start=0 coordinate_type=X
       # OEIS-Other: A003056 planepath=PyramidRows,step=1,align=right,n_start=0 coordinate_type=Y
       # OEIS-Other: A025581 planepath=PyramidRows,step=1,align=right,n_start=0 coordinate_type=DiffYX
       # OEIS-Other: A025581 planepath=PyramidRows,step=1,align=right,n_start=0 coordinate_type=AbsDiff
       # OEIS-Other: A051162 planepath=PyramidRows,step=1,align=right,n_start=0 coordinate_type=Sum
       # OEIS-Other: A051162 planepath=PyramidRows,step=1,align=right,n_start=0 coordinate_type=SumAbs
       # OEIS-Other: A069011 planepath=PyramidRows,step=1,align=right,n_start=0 coordinate_type=RSquared
     },

     # PyramidRows step=2
     'step=2,align=centre,n_start=0' =>
     { X   => 'A196199',  # runs -n to n
       Y   => 'A000196',  # n appears 2n+1 times, starting 0
       Sum => 'A053186',  # runs 0 to 2n
       # OEIS-Catalogue: A196199 planepath=PyramidRows,n_start=0 coordinate_type=X
       # OEIS-Catalogue: A000196 planepath=PyramidRows,n_start=0 coordinate_type=Y
       # OEIS-Other:     A053186 planepath=PyramidRows,n_start=0 coordinate_type=Sum
     },
     'step=2,align=right,n_start=0' =>
     { X       => 'A053186',  # runs 0 to 2n
       Y       => 'A000196',  # n appears 2n+1 times, starting 0
       DiffXY  => 'A196199',  # runs -n to n
       AbsDiff => 'A053615',  # 0..n..0, distance to pronic
       # OEIS-Other: A053186 planepath=PyramidRows,align=right,n_start=0 coordinate_type=X
       # OEIS-Other: A000196 planepath=PyramidRows,align=right,n_start=0 coordinate_type=Y
       # OEIS-Other: A196199 planepath=PyramidRows,align=right,n_start=0 coordinate_type=DiffXY
       # OEIS-Other: A053615 planepath=PyramidRows,align=right,n_start=0 coordinate_type=AbsDiff
     },
     'step=2,align=left,n_start=0' =>
     { X   => '',  # runs -2n+1 to 0
       Y   => 'A000196',  # n appears 2n+1 times, starting 0
       Sum => 'A196199',  # -n to n
       # OEIS-Other: A000196 planepath=PyramidRows,align=left,n_start=0 coordinate_type=Y
       # OEIS-Other: A196199 planepath=PyramidRows,align=left,n_start=0 coordinate_type=Sum
     },

     # PyramidRows step=3
     do {
       my $href =
         { Y   => 'A180447',  # n appears 3n+1 times, starting 0
         };
       ('step=3,align=centre,n_start=0' => $href,
        'step=3,align=left,n_start=0'   => $href,
        'step=3,align=right,n_start=0'  => $href,
       );
       # OEIS-Catalogue: A180447 planepath=PyramidRows,step=3,n_start=0 coordinate_type=Y
       # OEIS-Other: A180447 planepath=PyramidRows,step=3,align=right,n_start=0 coordinate_type=Y
       # OEIS-Other: A180447 planepath=PyramidRows,step=3,align=left,n_start=0 coordinate_type=Y
     },
    };
}
{ package Math::PlanePath::PyramidSides;
  use constant _NumSeq_Coord_SumAbs_non_decreasing => 1;

  use constant _NumSeq_Coord_oeis_anum =>
    { 'n_start=0' =>
      { X      => 'A196199',  # runs -n to n
        SumAbs => 'A000196',  # n appears 2n+1 times, starting 0
        # OEIS-Other: A196199 planepath=PyramidSides,n_start=0 coordinate_type=X
        # OEIS-Other: A000196 planepath=PyramidSides,n_start=0 coordinate_type=SumAbs
      },
    };
}
{ package Math::PlanePath::CellularRule;
  # ENHANCE-ME: more restrictive than this for many rules
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y so X+Y>=0
  use constant _NumSeq_Coord_DiffXY_max => 0; # triangular X<=Y so X-Y<=0
  use constant _NumSeq_Coord_Int_max => 0;

  # single cell
  # 111 -> any
  # 110 -> any
  # 101 -> any
  # 100 -> 0 initial
  # 011 -> any
  # 010 -> 0 initial
  # 001 -> 0 initial
  # 000 -> 0
  # so (rule & 0x17) == 0
  #
  # right 1,2 cell line 0x14,34,94,B4
  # 111 -> any
  # 110 -> 0
  # 101 -> any
  # 100 -> 1
  # 011 -> 0
  # 010 -> 1
  # 001 -> 0
  # 000 -> 0
  # so (rule & 0x5F) == 0x14
  #
  # right 2 cell line 0x54,74,D4,F4
  # 111 -> any
  # 110 -> 1
  # 101 -> any
  # 100 -> 1
  # 011 -> 0
  # 010 -> 1
  # 001 -> 0
  # 000 -> 0
  # so (rule & 0x5F) == 0x54
  #
  sub _NumSeq_Coord_X_increasing {
    my ($self) = @_;
    ### CellularRule _NumSeq_Coord_X_increasing() rule: $self->{'rule'}
    return (($self->{'rule'} & 0x17) == 0    # single cell only
            ? 1
            : 0);
  }
  sub _NumSeq_Coord_Sum_increasing {
    my ($self) = @_;
    return (($self->{'rule'} & 0x17) == 0        # single cell only
            || ($self->{'rule'} & 0x5F) == 0x14  # right line 1,2
            || ($self->{'rule'} & 0x5F) == 0x54  # right line 2
            ? 1
            : 0);
  }
  *_NumSeq_Coord_SumAbs_increasing = \&_NumSeq_Coord_Sum_increasing;
  *_NumSeq_Coord_Radius_increasing = \&_NumSeq_Coord_Sum_increasing;
  *_NumSeq_Coord_TRadius_increasing = \&_NumSeq_Coord_Radius_increasing;

  *_NumSeq_Coord_Y_increasing = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_Product_increasing = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_DiffXY_increasing = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_DiffYX_increasing = \&_NumSeq_Coord_X_increasing;
  *_NumSeq_Coord_AbsDiff_increasing = \&_NumSeq_Coord_X_increasing;

  sub _NumSeq_Coord_X_non_decreasing {
    my ($self) = @_;
    return (($self->{'rule'} & 0x17) == 0        # single cell only
            || ($self->{'rule'} & 0x5F) == 0x14  # right line 1,2
            || ($self->{'rule'} & 0x5F) == 0x54  # right line 2
            ? 1
            : 0);
  }
  sub _NumSeq_Coord_Product_non_decreasing {
    my ($self) = @_;
    return (($self->{'rule'} & 0x17) == 0        # single cell only
            || ($self->{'rule'} & 0x5F) == 0x14  # right line 1,2
            || ($self->{'rule'} & 0x5F) == 0x54  # right line 2
            ? 1
            : 0);
  }

  use constant _NumSeq_Coord_Y_non_decreasing => 1; # rows upwards

  use constant _NumSeq_Coord_oeis_anum =>
    {
     # rule=6,38,134,166 left 1,2
     # do {
     #   ('rule=38' => { Sum  => 'A022003',  # 1/999 decimal
     #                 },
     #   ),
     # },

     # rule=14,46,142,174 left 2
     # rule=84,116,212,244 right 2
     do {
       my $lr2 = { Y => 'A076938',  # 0,1,1,2,2,3,3,...
                   # OEIS-Other: A076938 planepath=CellularRule,rule=14 coordinate_type=Y
                   # OEIS-Other: A076938 planepath=CellularRule,rule=174 coordinate_type=Y
                 };
       ('rule=14' => $lr2,
        'rule=46' => $lr2,
        'rule=142' => $lr2,
        'rule=174' => $lr2,
        'rule=84' => $lr2,
        'rule=116' => $lr2,
        'rule=212' => $lr2,
        'rule=144' => $lr2,
       )
     },
    };
}
{ package Math::PlanePath::CellularRule::Line;
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

  sub _NumSeq_Coord_Radius_integer {
    my ($path) = @_;
    return ($path->{'sign'} == 0);
  }

  use constant _NumSeq_Coord_Y_increasing => 1;       # line upwards
  use constant _NumSeq_Coord_Radius_increasing => 1;  # line upwards
  use constant _NumSeq_Coord_TRadius_increasing => 1; # line upwards
  sub _NumSeq_Coord_TRadius_integer {
    my ($path) = @_;
    return ($path->{'sign'} != 0); # left or right sloping
  }

  sub _NumSeq_Coord_X_increasing {
    my ($path) = @_;
    return ($path->{'sign'} >= 1); # X=Y
  }
  sub _NumSeq_Coord_X_non_decreasing {
    my ($path) = @_;
    return ($path->{'sign'} >= 0); # X=0 or X=Y
  }

  sub _NumSeq_Coord_Sum_increasing {
    my ($path) = @_;
    return ($path->{'sign'} == -1
            ? 0   # X=-Y so X+Y=0
            : 1); # X=0 so X+Y=Y, or X=Y so X+Y=2Y
  }
  use constant _NumSeq_Coord_Sum_non_decreasing => 1; # line upwards
  use constant _NumSeq_Coord_SumAbs_increasing => 1;  # line upwards

  sub _NumSeq_Coord_Product_increasing {
    my ($path) = @_;
    return ($path->{'sign'} > 0
            ? 1   # X=Y so X*Y=Y^2
            : 0); # X=0 so X*Y=0, or X=-Y so X*Y=-(Y^2)
  }
  sub _NumSeq_Coord_Product_non_decreasing {
    my ($path) = @_;
    return ($path->{'sign'} >= 0
            ? 1   # X=Y so X*Y=Y^2
            : 0); # X=0 so X*Y=0, or X=-Y so X*Y=-(Y^2)
  }

  sub _NumSeq_Coord_DiffXY_non_decreasing {
    my ($path) = @_;
    return ($path->{'sign'} == 1
            ? 1   # X=Y so X-Y=0
            : 0); # X=0 so X-Y=-Y, or X=-Y so X-Y=-2*Y
  }

  sub _NumSeq_Coord_DiffYX_increasing {
    my ($path) = @_;
    return ($path->{'sign'} == 1
            ? 0   # X=Y so Y-X=0
            : 1); # X=0 so Y-X=Y, or X=-Y so Y-X=2*Y
  }
  *_NumSeq_Coord_AbsDiff_increasing = \&_NumSeq_Coord_DiffYX_increasing;
  use constant _NumSeq_Coord_DiffYX_non_decreasing  => 1; # Y-X >= 0 always
  use constant _NumSeq_Coord_AbsDiff_non_decreasing => 1; # Y-X >= 0 always
  use constant _NumSeq_Coord_GCD_increasing => 1; # GCD==Y

  # Not quite, CellularRule starts N=1 cf squares start n=0
  # use constant _NumSeq_Coord_oeis_anum =>
  #   { '' => { RSquared  => 'A001105',  # 2*n^2
  #             TRSquared => 'A016742',  # 4*n^2
  #             # OEIS-Other: A001105 planepath=CellularRule,rule=2 coordinate_type=RSquared
  #             # OEIS-Other: A016742 planepath=CellularRule,rule=2 coordinate_type=TRSquared
  #           },
  #   };
  #
  # CellularRule starts i=1 value=0, but A000027 is OFFSET=1 value=1
  # } elsif ($planepath_object->isa('Math::PlanePath::CellularRule::Line')) {
  #   # for all "rule" parameter values
  #   if ($coordinate_type eq 'Y'
  #       || ($planepath_object->{'sign'} == 0
  #           && ($coordinate_type eq 'Sum'
  #               || $coordinate_type eq 'DiffYX'
  #               || $coordinate_type eq 'AbsDiff'
  #               || $coordinate_type eq 'Radius'))) {
  #     return 'A000027'; # natural numbers 1,2,3
  #     # OEIS-Other: A000027 planepath=CellularRule,rule=2 coordinate_type=Y
  #     # OEIS-Other: A000027 planepath=CellularRule,rule=4 coordinate_type=Sum
  #     # OEIS-Other: A000027 planepath=CellularRule,rule=4 coordinate_type=DiffYX
  #     # OEIS-Other: A000027 planepath=CellularRule,rule=4 coordinate_type=AbsDiff
  #     # OEIS-Other: A000027 planepath=CellularRule,rule=4 coordinate_type=Radius
  #   }
}
{ package Math::PlanePath::CellularRule::OddSolid;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y so X+Y>=0
  use constant _NumSeq_Coord_DiffXY_max => 0; # triangular X<=Y so X-Y<=0
}
{ package Math::PlanePath::CellularRule54;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y so X+Y>=0
  use constant _NumSeq_Coord_DiffXY_max => 0; # triangular X<=Y so X-Y<=0
  use constant _NumSeq_Coord_Y_non_decreasing => 1; # rows upwards
}
{ package Math::PlanePath::CellularRule57;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y so X+Y>=0
  use constant _NumSeq_Coord_DiffXY_max => 0; # triangular X<=Y so X-Y<=0
  use constant _NumSeq_Coord_Y_non_decreasing => 1; # rows upwards
}
{ package Math::PlanePath::CellularRule190;
  use constant _NumSeq_Coord_Sum_min => 0;  # triangular X>=-Y so X+Y>=0
  use constant _NumSeq_Coord_DiffXY_max => 0; # triangular X<=Y so X-Y<=0
  use constant _NumSeq_Coord_Y_non_decreasing => 1; # rows upwards
}
{ package Math::PlanePath::UlamWarburton;
  use constant _NumSeq_Coord_NumChildren_max => 4;
  use constant _NumSeq_Coord_Depth_max => undef;
}
{ package Math::PlanePath::UlamWarburtonQuarter;
  use constant _NumSeq_Coord_NumChildren_max => 3;
  use constant _NumSeq_Coord_Depth_max => undef;
}
{ package Math::PlanePath::DiagonalRationals;
  use constant _NumSeq_Coord_Sum_non_decreasing => 1; # X+Y diagonals
  use constant _NumSeq_Coord_SumAbs_non_decreasing => 1; # X+Y diagonals
  use constant _NumSeq_Coord_BitAnd_min => 0;  # at X=1,Y=2
  use constant _NumSeq_Coord_GCD_min => 1;  # no common factor
  use constant _NumSeq_Coord_GCD_max => 1;  # no common factor

  use constant _NumSeq_Coord_oeis_anum =>
    { '' =>
      { X       => 'A020652',  # numerators
        Y       => 'A020653',  # denominators
        # OEIS-Catalogue: A020652 planepath=DiagonalRationals coordinate_type=X
        # OEIS-Catalogue: A020653 planepath=DiagonalRationals coordinate_type=Y

        # Not quite, A038567 has OFFSET=0 to include 0/1
        # Sum => 'A038567', # num+den, is den of fractions X/Y <= 1

        # Not quite, has OFFSET=0 unlike num,den which are OFFSET=1 as per N=1
        # DiagonalRationals
        # AbsDiff => 'A157806', # abs(num-den)
      },
    };
}
{ package Math::PlanePath::FactorRationals;
  use constant _NumSeq_Coord_BitAnd_min => 0;  # at X=1,Y=2
  use constant _NumSeq_Coord_GCD_min => 1;  # no common factor
  use constant _NumSeq_Coord_GCD_max => 1;  # no common factor

  use constant _NumSeq_Coord_oeis_anum =>
    { '' =>
      { X       => 'A071974',  # numerators
        Y       => 'A071975',  # denominators
        Product => 'A019554',  # replace squares by their root
        # OEIS-Catalogue: A071974 planepath=FactorRationals coordinate_type=X
        # OEIS-Catalogue: A071975 planepath=FactorRationals coordinate_type=Y
        # OEIS-Catalogue: A019554 planepath=FactorRationals coordinate_type=Product
      },
    };
}
{ package Math::PlanePath::GcdRationals;
  use constant _NumSeq_Coord_BitAnd_min => 0;  # at X=1,Y=2
  use constant _NumSeq_Coord_GCD_min => 1;  # no common factor
  use constant _NumSeq_Coord_GCD_max => 1;  # no common factor

  use constant _NumSeq_Coord_oeis_anum =>
    { 'pairs_order=rows' =>
      { Y => 'A054531',  # T(n,k) = n/GCD(n,k), being denominators
        # OEIS-Catalogue: A054531 planepath=GcdRationals coordinate_type=Y
      },
      'pairs_order=rows_reverse' =>
      { Y => 'A054531',  # same
        # OEIS-Other: A054531 planepath=GcdRationals,pairs_order=rows coordinate_type=Y
      },
    };
}
{ package Math::PlanePath::CoprimeColumns;
  use constant _NumSeq_Coord_DiffXY_min => 0; # octant Y<=X so X-Y>=0
  use constant _NumSeq_Coord_X_non_decreasing => 1; # columns across
  use constant _NumSeq_Coord_BitAnd_min => 0;  # at X=2,Y=1
  use constant _NumSeq_Coord_GCD_min => 1;  # no common factor
  use constant _NumSeq_Coord_GCD_max => 1;  # no common factor

  use constant _NumSeq_Coord_oeis_anum =>
    { # Not quite, A038566/A038567 starts OFFSET=1 value=1/1 but
     # CoprimeColumns starts N=0
     # '' =>
     # { X => 'A038567',  # fractions denominator
     #   Y => 'A038566',  # fractions numerator
     #   # OEIS-Catalogue: A038567 planepath=CoprimeColumns coordinate_type=X
     #   # OEIS-Catalogue: A038566 planepath=CoprimeColumns coordinate_type=Y
     # },

     'i_start=1' =>
     {
      DiffXY => 'A020653', # diagonals denominators, starting n=1
     },
    };
}
{ package Math::PlanePath::DivisibleColumns;
  use constant _NumSeq_Coord_X_non_decreasing => 1; # columns across
  sub _NumSeq_Coord_DiffXY_min {
    my ($self) = @_;
    # octant Y<=X so X-Y>=0
    return ($self->{'proper'} ? 1 : 0);
  }
  use constant _NumSeq_Coord_BitAnd_min => 0;  # at X=2,Y=1
  sub _NumSeq_Coord_BitXor_min {
    my ($self) = @_;
    # octant Y<=X so X-Y>=0
    return ($self->{'proper'} ? 2   # at X=3,Y=1
            :                   0); # at X=1,Y=1
  }
  use constant _NumSeq_Coord_GCD_min => 1;  # X=0,Y=0 not visited

  # A061017 starts OFFSET=1 value=1, cf DivisibleColumns starts N=0 value=1
  # A027750 starts OFFSET=1 cf DivisibleColumns starts N=0
  # '' =>
  # { X => 'A061017',  # n appears divisors(n) times
  #   Y => 'A027750',  # triangle divisors of n
  #   # OEIS-Catalogue: A061017 planepath=DivisibleColumns coordinate_type=X
  #   # OEIS-Catalogue: A027750 planepath=DivisibleColumns coordinate_type=Y
  # },

  # Not quite, A027751 proper divisor Y values, but has an extra 1 at the
  # start from reckoning by convention 1 as a proper divisor of 1
  # -- though that's inconsistent with A032741 count of proper divisors
  # being 0.
  #
  # 'divisor_type=proper' =>
  # { Y => 'A027751',  # proper divisors by rows
  #   # OEIS-Catalogue: A027751 planepath=DivisibleColumns,divisor_type=proper coordinate_type=Y
  # },
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
# { package Math::PlanePath::QuintetReplicate;
# }
# { package Math::PlanePath::AR2W2Curve;
# }
# { package Math::PlanePath::BetaOmega;
# }
# { package Math::PlanePath::KochelCurve;
# }
# { package Math::PlanePath::DekkingCurve;
# }
# { package Math::PlanePath::DekkingCentres;
# }
# { package Math::PlanePath::CincoCurve;
# }
# { package Math::PlanePath::SquareReplicate;
# }
{ package Math::PlanePath::CornerReplicate;
  use constant _NumSeq_Coord_oeis_anum =>
    { '' =>
      { Y      => 'A059906',  # alternate bits second (ZOrderCurve Y)
        BitXor => 'A059905',  # alternate bits first  (ZOrderCurve X)
        # OEIS-Other: A059906 planepath=CornerReplicate coordinate_type=Y
        # OEIS-Other: A059905 planepath=CornerReplicate coordinate_type=BitXor
      },
    };
}
# { package Math::PlanePath::DigitGroups;
# }
# { package Math::PlanePath::FibonacciWordFractal;
# }
{ package Math::PlanePath::LTiling;
  *_NumSeq_Coord_SumAbs_min   = \&rsquared_minimum;
  *_NumSeq_Coord_AbsDiff_min  = \&rsquared_minimum;
  *_NumSeq_Coord_Sum_min = \&rsquared_minimum;
  sub _NumSeq_Coord_TRSquared_min {
    my ($self) = @_;
    return ($self->{'L_fill'} eq 'upper' ? 3    # X=0,Y=1
            : ($self->{'L_fill'} eq 'left'
               || $self->{'L_fill'} eq 'ends') ? 1   # X=1,Y=0
            : 0);  # 'middle','all' X=0,Y=0
  }
  {
    my %GCD_min = (upper => 1,   # X=0,Y=0 not visited by these
                   left  => 1,
                   ends  => 1);
    sub _NumSeq_Coord_GCD_min {
      my ($self) = @_;
      return $GCD_min{$self->{'L_fill'}} || 0;
    }
  }
  {
    my %BitOr_min = (upper => 1,   # X=0,Y=0 not visited by these
                     left  => 1,
                     ends  => 1);
    sub _NumSeq_Coord_BitOr_min {
      my ($self) = @_;
      return $BitOr_min{$self->{'L_fill'}} || 0;
    }
  }
  *_NumSeq_Coord_BitXor_min = \&_NumSeq_Coord_BitOr_min;
}
{ package Math::PlanePath::WythoffArray;
  use constant _NumSeq_Coord_oeis_anum =>
    { '' =>
      {
       Y   => 'A019586', # row containing N
       # OEIS-Catalogue: A019586 planepath=WythoffArray coordinate_type=Y
      },
    };
}
{ package Math::PlanePath::PowerArray;
  use constant _NumSeq_Coord_oeis_anum =>
    { 'radix=2' =>
      { X => 'A007814', # base 2 count low 0s, starting n=1
        # main generator Math::NumSeq::DigitCountLow
        # OEIS-Other: A007814 planepath=PowerArray,radix=2

        # but A025480 starts OFFSET=0 for the k in n=(2k+1)*2^j-1
        # Y => 'A025480',
        # # OEIS-Almost: A025480 i_to_n_offset=-1 planepath=PowerArray,radix=2 coordinate_type=Y
      },
      'radix=3' =>
      { X => 'A007949', # k of greatest 3^k dividing n
        # OEIS-Other: A007949 planepath=PowerArray,radix=3
        # main generator Math::NumSeq::DigitCountLow
      },
      'radix=5' =>
      { X => 'A112765',
        # OEIS-Other: A112765 planepath=PowerArray,radix=5
      },
      'radix=6' =>
      { X => 'A122841',
        # OEIS-Other: A122841 planepath=PowerArray,radix=6
      },
      'radix=10' =>
      { X => 'A122840',
        # OEIS-Other: A112765 planepath=PowerArray,radix=5
      },
    };
}

{ package Math::PlanePath::LCornerTree;
  use constant _NumSeq_Coord_Depth_max => undef;
}
{ package Math::PlanePath::ToothpickTree;
  use constant _NumSeq_Coord_Depth_max => undef;
}


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
#     # FIXME: only sum of two squares, and for triangular same odd/even.
#     # Factorize or search ?
#     return ($value >= 0);
#   }
#
#   return undef;
# }


=for stopwords Ryde Math-PlanePath DiffXY OEIS PlanePath NumSeq SquareSpiral PlanePath SumAbs Manhatten ie TRadius TRSquared HexSpiral RSquared KochPeaks CoprimeColumns DiffYX CellularRule

=head1 NAME

Math::NumSeq::PlanePathCoord -- sequence of coordinate values from a PlanePath module

=head1 SYNOPSIS

 use Math::NumSeq::PlanePathCoord;
 my $seq = Math::NumSeq::PlanePathCoord->new
             (planepath => 'SquareSpiral',
              coordinate_type => 'X');
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This is a tie-in to present coordinates from a C<Math::PlanePath> module as
a NumSeq sequence.  The NumSeq "i" index is the PlanePath "N" value.

The C<coordinate_type> choices are

    "X"            X coordinate
    "Y"            Y coordinate
    "Sum"          X+Y sum
    "SumAbs"       abs(X)+abs(Y) sum
    "Product"      X*Y product
    "DiffXY"       X-Y difference
    "DiffYX"       Y-X difference (negative of DiffXY)
    "AbsDiff"      abs(X-Y) difference
    "Radius"       sqrt(X^2+Y^2) radial distance
    "RSquared"     X^2+Y^2 radius squared
    "TRadius"      sqrt(X^2+3*Y^2) triangular radius
    "TRSquared"    X^2+3*Y^2 triangular radius squared
    "BitAnd"       X bitand Y
    "BitOr"        X bitor Y
    "BitXor"       X bitxor Y
    "Min"          min(X,Y)
    "Max"          max(X,Y)
    "GCD"          greatest common divisor X,Y
    "Depth"        tree_n_to_depth()
    "NumChildren"  tree_n_num_children()

"Sum"=X+Y and "DiffXY=X-Y can be interpreted geometrically as coordinates on
45-degree diagonals.  Sum is a measure up along the leading diagonal and
DiffXY down along an anti-diagonal,

                 /
    \           /
     \   s=X+Y /
      \       ^\
       \     /  \
        \ | /    v
         \|/      * d=X-Y
       ---o----
         /|\
        / | \
       /  |  \
      /       \
     /         \
    /           \

Or "Sum" can be thought of as a count of which anti-diagonal stripe contains
X,Y or equivalently a projection onto the X=Y leading diagonal.

           Sum
    \     anti-diag
     2    numbering          / / / /   DiffXY
    \ \     X+Y            -1 0 1 2   diagonal
     1 2                   / / / /    numbering
    \ \ \                -1 0 1 2       X-Y
     0 1 2                 / / /
      \ \ \               0 1 2


"SumAbs"=abs(X)+abs(Y) is similar, but a projection onto the cross-diagonal
of whichever quadrant contains the X,Y.  It's also thought of as a
"taxi-cab" or Manhatten distance, being how far to travel through a
square-grid city to get to X,Y.  If a path uses only the first quadrant, so
XE<gt>=0,YE<gt>=0, then of course Sum and SumAbs are identical.

    SumAbs = taxi-cab distance, by any square-grid travel

    +-----o       +--o          o
    |             |             |
    |          +--+       +-----+
    |          |          |
    *          *          *

"DiffYX"=Y-X is simply the negative of DiffXY.  It's included to give
positive values on paths which are either above or below the X=Y leading
diagonal.  For example DiffXY is positive in CoprimeColumns which is below
X=Y, whereas DiffYX is positive in CellularRule which is above X=Y.

"TRadius" and "TRSquared" are designed for use with points on a triangular
lattice such as HexSpiral.  On the X axis TRSquared is the same as RSquared,
but any Y is scaled up by factor sqrt(3).  Most triangular paths use every
second X,Y point which makes TRSquared even, but some such as KochPeaks have
an offset 1 from the origin making it odd instead.

"BitAnd", "BitOr" and "BitXor" treat negative X or negative Y as infinite
twos-complement 1-bits, which means for example X=-1,Y=-2 has X bitand Y
= -2.

    ...11111111    X=-1
    ...11111110    Y=-2
    -----------
    ...11111110    X bitand Y = -2

This twos-complement is per C<Math::BigInt> (it has bitwise operations in
Perl 5.6 and up) and is arranged for ordinary scalars too.  If X or Y are
not integers then the fractional parts are treated bitwise too, though
currently only to limited precision.

=head1 FUNCTIONS

See L<Math::NumSeq/FUNCTIONS> for behaviour common to all sequence classes.

=over 4

=item C<$seq = Math::NumSeq::PlanePathCoord-E<gt>new (planepath =E<gt> $name, coordinate_type =E<gt> 'X')>

Create and return a new sequence object.  The options are

    planepath          string, name of a PlanePath module
    planepath_object   PlanePath object
    coordinate_type    string, as described above

C<planepath> can be either the module part such as "SquareSpiral" or a
full class name "Math::PlanePath::SquareSpiral".

=item C<$value = $seq-E<gt>ith($i)>

Return the coordinate at N=$i in the PlanePath.

=item C<$i = $seq-E<gt>i_start()>

Return the first index C<$i> in the sequence.  This is the position
C<rewind()> returns to.

This is C<$path-E<gt>n_start()> from the PlanePath, since the i numbering is
the N numbering of the underlying path.  For some of the
C<Math::NumSeq::OEIS> generated sequences there may be a higher C<i_start()>
corresponding to a higher starting point in the OEIS, though this is
slightly experimental.

=item C<$str = $seq-E<gt>oeis_anum()>

Return the A-number (a string) for C<$seq> in Sloane's Online Encyclopedia
of Integer Sequences, or return C<undef> if not in the OEIS or not known.

Known A-numbers are presented through C<Math::NumSeq::OEIS::Catalogue>
so PlanePath related sequences can be created with
C<Math::NumSeq::OEIS> by their A-number in the usual way.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::PlanePathDelta>,
L<Math::NumSeq::PlanePathTurn>,
L<Math::NumSeq::PlanePathN>,
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
