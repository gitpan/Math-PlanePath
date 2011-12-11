#!/usr/bin/perl -w

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

__END__

sub _log2_ceil {
  my ($x) = @_;
  my $exp = ceil (log(max(1, $x)) / log(2));
  return $exp + (2 ** ($exp+1) <= $x);
}

sub _log2_floor {
  my ($x) = @_;
  if ($x <= 1) { return 0; }

  # Math::BigInt and Math::BigRat overloaded log() return NaN, use integer
  # based blog()
  if (ref $x && ($x->isa('Math::BigInt') || $x->isa('Math::BigRat'))) {
    return $x->copy->blog(2);
  }

  my $exp = int(log($x)/log(2));
  my $pow = 2**$exp;
  ### x:   ref($x)."  $x"
  ### exp: ref($exp)."  $exp"
  ### pow: ref($pow)."  $pow"

  # check how $pow actually falls against $x, not sure should trust float
  # rounding in log()/log(3)
  # Crib: $x as first arg in case $x==BigFloat and $pow==BigInt
  if ($x < $pow) {
    ### hmm, int(log) too big, decrease...
    $exp -= 1;
  } elsif ($x >= 2*$pow) {
    ### hmm, int(log) too small, increase...
    $exp += 1;
  } else {
    ### int(log) ok ...
  }
  return ($exp);
}


my @x = (0, 1);
my @y = (0, 0);


  while ($#x < $n) {
    for my $x ($x[-1]) {
      for my $y ($y[-1]) {
        my $r = hypot($x,$y);
      }
    }
  }


  if ($n != $int) {
    my $x = $x[$int];
    my $y = $y[$int];
    return ($x + $frac * ($x[$int+1] - $x),
            $y + $frac * ($y[$int+1] - $y));
  } else {
    return ($x[$n],$y[$n]);
  }


  #   for my $i ($self->{'i'}) {
  #     for my $x ($self->{'x'}) {
  #       for my $y ($self->{'y'}) {
  #         if ($i > $n) {
  #           ### restart
  #           ### $i
  #           ### $n
  #           $i = 1;
  #           $x = 1;
  #           $y = 0;
  #         }
  #         for ( ; $i < $n; $i++) {
  #           my $r = hypot($x,$y);
  #           ### $i
  #           ### $x
  #           ### $y
  #           ### $r
  #           $x -= $y/$r;
  #           $y += $x/$r;
  #         }
  #         return ($x, $y);
  #       }
  #     }
  #   }

#------------------------------------------------------------------------------

sub _log4_floor {
  my ($n) = @_;
  my $exp = 0;
  while (($n /= 4) >= 1) {
    $exp++;
  }
  return $exp;
}
### assert: _log4_floor(3) == 0
### assert: _log4_floor(4) == 1
### assert: _log4_floor(5) == 1
### assert: _log4_floor(15) == 1
### assert: _log4_floor(16) == 2
### assert: _log4_floor(17) == 2

# KochSnowflakes _log4_floor()

require Math::PlanePath::KochSnowflakes;
{
  my $orig = Math::BigRat->new(4) ** 64;
  my $n    = Math::BigRat->new(4) ** 64;
  my $exp = Math::PlanePath::KochSnowflakes::_log4_floor($n);

  ok ($n, $orig, "_log4_floor() unmodified input");
  # ok ($pow == Math::BigRat->new(4.0) ** 64, 1,
  #     "_log4_floor() 4^64 + 1/3 power");
  ok ($exp, 64, "_log4_floor() 4^64 + 1/3 exp");
}
{
  my $orig = Math::BigRat->new(4) ** 64 + Math::BigRat->new('1/3');
  my $n    = Math::BigRat->new(4) ** 64 + Math::BigRat->new('1/3');
  my $exp = Math::PlanePath::KochSnowflakes::_log4_floor($n);

  ok ($n, $orig, "_log4_floor() unmodified input");
  # ok ($pow == Math::BigRat->new(4.0) ** 64, 1,
  #     "_log4_floor() 4^64 + 1/3 power");
  ok ($exp, 64, "_log4_floor() 4^64 + 1/3 exp");
}


# KochSnowflakes _log4_floor()

require Math::PlanePath::KochSnowflakes;
{
  my $orig = Math::BigFloat->new(4) ** 64;
  my $n    = Math::BigFloat->new(4) ** 64;
  my $exp = Math::PlanePath::KochSnowflakes::_log4_floor($n);

  ok ($n, $orig, "_log4_floor() unmodified input");
  # ok ($pow == Math::BigFloat->new(4.0) ** 64, 1,
  #     "_log4_floor() 4^64 + 1.25 power");
  ok ($exp, 64, "_log4_floor() 4^64 + 1.25 exp");
}
{
  my $orig = Math::BigFloat->new(4) ** 64 + 1.25;
  my $n    = Math::BigFloat->new(4) ** 64 + 1.25;
  my $exp = Math::PlanePath::KochSnowflakes::_log4_floor($n);

  ok ($n, $orig, "_log4_floor() unmodified input");
  # ok ($pow == Math::BigFloat->new(4.0) ** 64, 1,
  #     "_log4_floor() 4^64 + 1.25 power");
  ok ($exp, 64, "_log4_floor() 4^64 + 1.25 exp");
}


sub _round_up_pow2 {
  my ($x) = @_;
  ### _round_up_pow2(): $x
  if ($x < 1) {
    return (1,0);
  }
  # Math::BigInt and Math::BigRat overloaded log() return NaN, use integer
  # based blog()
  my $exp = (ref $x && ($x->isa('Math::BigInt') || $x->isa('Math::BigRat'))
             ? $x->copy->blog(2)
             : int(log($x)/log(2)));
  my $pow = 2 ** $exp;
  ### $exp
  ### $pow
  if ($pow < $x) {
    return (2*$pow, $exp+1)
  } else {
    return ($pow, $exp);
  }
}

# return ($pow, $exp) where $pow = 2**$exp >= $x
# FIXME: Math::BigInt log() returns nan
# for some places an estimate is enough here
sub _round_up_pow2 {
  my ($x) = @_;
  if ($x < 1) { $x = 1; }
  my $exp = ceil (log($x) / log(2));
  my $pow = 2 ** $exp;
  if ($pow < $x) {
    return (2*$pow, $exp+1)
  } else {
    return ($pow, $exp);
  }
}

