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


# A006218 - cumulative count of divisors
#
#   Dirichlet:
#   n * (log(n) + 2*gamma - 1) + O(sqrt(n))  gamma=0.57721... Euler-Mascheroni
#
#   n * (log(n) + 2*gamma - 1) + O(log(n)*n^(1/3))
#
#   Chandrasekharan: bounds
#   n log(n) + (2 gamma - 1) n - 4 sqrt(n) - 1
#   <= a(n) <=
#   n log(n) + (2 gamma - 1) n + 4 sqrt(n)
#
# a(n)=2 * sum[ i=1 to floor(sqrt(n)) of floor(n/i) ] - floor(sqrt(n))^2
#
# cf A003988,A010766 - triangle with values floor(i/j)
#
# http://mathworld.wolfram.com/DirichletDivisorProblem.html

package Math::PlanePath::DivisibleColumns;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 49;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;
use constant x_negative => 0;
use constant y_negative => 0;

use constant parameter_info_array =>
  [ { name    => 'divisor_type',
      display => 'Divisor Type',
      type    => 'enum',
      choices => ['all','proper'],
      default => 'all',
      description => 'Divisor type, with "proper" meaning divisors d<X, so excluding d=X itself.',
    },
  ];


my @x_to_n = (0,0,1);
sub _extend {
  ### _extend(): $#x_to_n
  my $x = $#x_to_n;
  push @x_to_n, $x_to_n[$x] + _divisors($x);

  # if ($x > 2) {
  #   if (($x & 3) == 2) {
  #     $x >>= 1;
  #     $next_n += $x_to_n[$x] - $x_to_n[$x-1];
  #   } else {
  #     $next_n +=
  #   }
  # }
  ### last x: $#x_to_n
  ### second last: $x_to_n[$#x_to_n-2]
  ### last: $x_to_n[$#x_to_n-1]
  ### diff: $x_to_n[$#x_to_n-1] - $x_to_n[$#x_to_n-2]
  ### divisors of: $#x_to_n - 2
  ### divisors: _divisors($#x_to_n-2)
  ### assert: $x_to_n[$#x_to_n-1] - $x_to_n[$#x_to_n-2] == _divisors($#x_to_n-2)
}

sub new {
  my $self = shift->SUPER::new (@_);
  $self->{'proper'} = (($self->{'divisor_type'}||'') eq 'proper');
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### DivisibleColumns n_to_xy(): $n

  # $n<-0.5 works with Math::BigInt circa Perl 5.12, it seems
  if ($n < -0.5) {
    return;
  }
  if (_is_infinite($n)) {
    return ($n,$n);
  }

  my $frac;
  {
    my $int = int($n);
    if ($n == $int) {
      $frac = 0;
    } else {
      $frac = $n - $int; # -.5 <= $frac < 1
      $n = $int;         # BigFloat int() gives BigInt, use that
      if ($frac > .5) {
        $frac--;
        $n += 1;
        # now -.5 <= $frac < .5
      }
      ### $n
      ### $frac
      ### assert: $frac >= -.5
      ### assert: $frac < .5
    }
  }
  my $proper = $self->{'proper'};

  my $x;
  if ($proper) {
    $x = 2;
    ### proper adjusted n: $n
  } else {
    $x = 1;
  }

  for (;;) {
    while ($x > $#x_to_n) {
      _extend();
    }
    $n += $proper;
    ### consider: "n=$n x=$x  x_to_n=".$x_to_n[$x]
    if ($x_to_n[$x] > $n) {
      $x--;
      last;
    }
    $x++;
  }
  $n -= $x_to_n[$x];
  $n -= $proper;
  ### $x
  ### x_to_n: $x_to_n[$x]
  ### x_to_n next: $x_to_n[$x+1]
  ### remainder: $n

  my $y = 1;
  for (;;) {
    unless ($x % $y) {
      if (--$n < 0) {
        return ($x, $frac + $y);
      }
    }
    if (++$y > $x) {
      ### oops, not enough in this column
      return;
    }
  }
}

sub _divisors {
  my ($x) = @_;
  my $ret = 1;
  unless ($x % 2) {
    my $count = 1;
    do {
      $x /= 2;
      $count++;
    } until ($x % 2);
    $ret *= $count;
  }
  my $limit = int(sqrt($x));
  for (my $d = 3; $d <= $limit; $d+=2) {
    unless ($x % $d) {
      my $count = 1;
      do {
        $x /= $d;
        $count++;
      } until ($x % $d);
      my $limit = sqrt($x);
      $ret *= $count;
    }
  }
  if ($x > 1) {
    $ret *= 2;
  }
  return $ret;
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### DivisibleColumns xy_to_n(): "$x,$y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if (_is_infinite($x)) { return $x; }
  if (_is_infinite($y)) { return $y; }

  my $proper = $self->{'proper'};
  if ($proper) {
    if ($x < 2
        || $y < 1
        || $y > int($x/2)
        || ($x%$y)) {
      return undef;
    }
  } else {
    if ($x < 1
        || $y < 1
        || $y > $x
        || ($x%$y)) {
      return undef;
    }
  }

  while ($#x_to_n < $x) {
    _extend();
  }
  ### x_to_n: $x_to_n[$x]

  my $n = $x_to_n[$x] - ($proper ? $x-1 : 1);
  ### base n: $n

  for (my $i = 1+$proper; $i <= $y; $i++) {
    unless ($x % $i) {
      $n += 1;
    }
  }
  return $n;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### DivisibleColumns rect_to_n_range(): "$x1,$y1 $x2,$y2"

  $x1 = _round_nearest($x1);
  $y1 = _round_nearest($y1);
  $x2 = _round_nearest($x2);
  $y2 = _round_nearest($y2);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  ### rounded ...
  ### $x2
  ### $y2

  if ($self->{'proper'}) {
    if ($x2 < 2            # rect all negative
        || $y2 < 1         # rect all negative
        || 2*$y1 > $x2) {  # rect all above X=2Y octant
      ### outside proper divisors ...
      return (1, 0);
    }
    if ($x1 < 2) { $x1 = 2; }
  } else {
    if ($x2 < 1           # rect all negative
        || $y2 < 1        # rect all negative
        || $y1 > $x2) {   # rect all above X=Y diagonal
      ### outside all divisors ...
      return (1, 0);
    }
    if ($x1 < 1) { $x1 = 1; }
  }
  if (_is_infinite($x2)) {
    return (1, $x2);
  }

  my ($n_lo, $n_hi);
  if ($x1 <= $#x_to_n) {
    $n_lo = $x_to_n[$x1];
  } else {
    $n_lo = _divisors_cumulative($x1-1);
  }
  if ($x2 < $#x_to_n) {
    $n_hi = $x_to_n[$x2+1];
  } else {
    $n_hi = _divisors_cumulative($x2);
  }
  $n_hi -= 1;

  ### rect at: "x=".($x2+1)." x_to_n=".$x_to_n[$x2+1]

  if ($self->{'proper'}) {
    $n_lo -= $x1-1;
    $n_hi -= $x2;
  }
  return ($n_lo, $n_hi);
}

sub _divisors_cumulative {
  my ($x) = @_;
  my $total = 0;
  my $limit = int(sqrt($x));
  foreach my $i (1 .. $limit) {
    $total += int($x/$i);
  }
  return 2*$total - $limit*$limit;
}

1;
__END__

=for stopwords Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::DivisibleColumns -- X divisible by Y in columns

=head1 SYNOPSIS

 use Math::PlanePath::DivisibleColumns;
 my $path = Math::PlanePath::DivisibleColumns->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path visits points X,Y where X is divisible by Y going by columns from
Y=1 to YE<lt>=X.

    18 |                                                      57
    17 |                                                   51
    16 |                                                49
    15 |                                             44
    14 |                                          40
    13 |                                       36
    12 |                                    34
    11 |                                 28
    10 |                              26
     9 |                           22                         56
     8 |                        19                      48
     7 |                     15                   39
     6 |                  13                33                55
     5 |                9             25             43
     4 |             7          18          32          47
     3 |          4       12       21       31       42       54
     2 |       2     6    11    17    24    30    38    46    53
     1 |    0  1  3  5  8 10 14 16 20 23 27 29 35 37 41 45 50 52
    Y=0|
       +---------------------------------------------------------
       X=0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18

Starting N=0 at X=1,Y=1 means the values 1,3,5,8,etc horizontally on Y=1 are
the sums

     i=K
    sum   numdivisors(i)
     i=1

The current implementation is fairly slack and is slow on medium to large N.

=head1 Proper Divisors

C<divisor_type =E<gt> 'proper'> gives only proper divisors of X, meaning
that Y=X itself is excluded.

     9 |                                                      39   
     8 |                                                33         
     7 |                                          26               
     6 |                                    22                38   
     5 |                              16             29            
     4 |                        11          21          32         
     3 |                   7       13       20       28       37   
     2 |             3     6    10    15    19    25    31    36   
     1 |       0  1  2  4  5  8  9 12 14 17 18 23 24 27 30 34 35
    Y=0|
       +---------------------------------------------------------
       X=0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18

The pattern is the same, but the X=Y line skipped.  The high line going up
is at Y=X/2, when X is even, that being the highest proper divisor.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::DivisibleColumns-E<gt>new ()>

=item C<$path = Math::PlanePath::DivisibleColumns-E<gt>new (divisor_type =E<gt> 'proper')>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::CoprimeColumns>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2011 Kevin Ryde

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

# Local variables:
# compile-command: "math-image --path=DivisibleColumns --all"
# End:
#
# math-image --path=DivisibleColumns --output=numbers --all
# math-image --path=DivisibleColumns,divisor_type=proper --output=numbers --all --size=134
