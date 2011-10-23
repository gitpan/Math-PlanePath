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


# math-image --path=CoprimeColumns --all --scale=10
# math-image --path=CoprimeColumns --output=numbers --all

package Math::PlanePath::CoprimeColumns;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 49;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use constant n_start => 0;
use constant x_negative => 0;
use constant y_negative => 0;

my @x_to_n = (0,0,1);
sub _extend {
  ### _extend(): $#x_to_n
  my $x = $#x_to_n;
  push @x_to_n, $x_to_n[$x] + _totient($x);

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
  ### totient of: $#x_to_n - 2
  ### totient: _totient($#x_to_n-2)
  ### assert: $x_to_n[$#x_to_n-1] - $x_to_n[$#x_to_n-2] == _totient($#x_to_n-2)
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### CoprimeColumns n_to_xy(): $n

  # $n<-0.5 is ok for Math::BigInt circa Perl 5.12, it seems
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
      $n = $int;  # BigFloat int() gives BigInt, use that
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

  my $x = 1;
  for (;;) {
    while ($x > $#x_to_n) {
      _extend();
    }
    if ($x_to_n[$x] > $n) {
      $x--;
      last;
    }
    $x++;
  }
  $n -= $x_to_n[$x];
  ### $x
  ### n base: $x_to_n[$x]
  ### n next: $x_to_n[$x+1]
  ### remainder: $n

  my $y = 1;
  for (;;) {
    if (_coprime($x,$y)) {
      if (--$n < 0) {
        return ($x, $frac + $y);
      }
    }
    if (++$y >= $x) {
      ### oops, not enough in this column
      return;
    }
  }
}

# A000010
sub _totient {
  my ($x) = @_;
  my $count = (1                            # y=1 always
               + ($x > 2 && ($x&1))         # y=2 if $x odd
               + ($x > 3 && ($x % 3) != 0)  # y=3
               + ($x > 4 && ($x&1))         # y=4 if $x odd
              );
  for (my $y = 5; $y < $x; $y++) {
    $count += _coprime($x,$y);
  }
  return $count;
}
sub _coprime {
  my ($x, $y) = @_;
  #### _coprime(): "$x,$y"
  if ($y > $x) {
    return 0;  # only interested in X>=Y for now
  }
  for (;;) {
    if ($y <= 1) {
      return ($y == 1);
    }
    ($x,$y) = ($y, $x % $y);
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### CoprimeColumns xy_to_n(): "$x,$y"
  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if (_is_infinite($x)) { return $x; }
  if (_is_infinite($y)) { return $y; }
  if ($x < 1
      || $y < 1
      || $y >= $x+($x==1)
      || ! _coprime($x,$y)) {
    return undef;
  }

  while ($#x_to_n < $x) {
    _extend();
  }
  my $n = $x_to_n[$x];
  ### base n: $n
  if ($y != 1) {
    foreach my $i (1 .. $y-1) {
      if (_coprime($x,$i)) {
        $n += 1;
      }
    }
  }
  return $n;
}

# Asymptotically
#     phisum(x) ~ 1/(2*zeta(2)) * x^2 + O(x ln x)
#               = 3/pi^2 * x^2 + O(x ln x)
# or by Walfisz
#     phisum(x) ~ 3/pi^2 * x^2 + O(x * (ln x)^(2/3) * (ln ln x)^4/3)
#
# but want an upper bound, so that for a given X at least enough N is
# covered ...
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### CoprimeColumns rect_to_n_range(): "$x1,$y1 $x2,$y2"

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  $x2 = _round_nearest($x2);
  $y2 = _round_nearest($y2);
  ### rounded ...
  ### $x2
  ### $y2

  if ($x2 < 1 || $y2 < 1
      # bottom right corner above X=Y diagonal, except X=1,Y=1 included
      || ($y1 >= $x2 + ($x2 == 1))) {
    ### outside ...
    return (1, 0);
  }
  if (_is_infinite($x2)) {
    return (1, $x2);
  }

  while ($#x_to_n <= $x2) {
    _extend();
  }

  ### rect use xy_to_n at: "x=".($x2+1)." y=1"
  if ($x1 < 0) { $x1 = 0; }
  return ($x_to_n[$x1], $x_to_n[$x2+1]-1);

  # return (1, .304*$x2*$x2 + 20);   # asympototically ?
}

1;
__END__

=for stopwords Ryde coprime coprimes coprimeness totient Math-PlanePath Euler's onwards

=head1 NAME

Math::PlanePath::CoprimeColumns -- coprime x,y by columns

=head1 SYNOPSIS

 use Math::PlanePath::CoprimeColumns;
 my $path = Math::PlanePath::CoprimeColumns->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path visits points X,Y which are coprime, meaning gcd(X,Y)=1, in
columns from Y=0 to YE<lt>=X.

    13 |                                          63
    12 |                                       57
    11 |                                    45 56 62
    10 |                                 41    55
     9 |                              31 40    54 61
     8 |                           27    39    53
     7 |                        21 26 30 38 44 52
     6 |                     17          37    51
     5 |                  11 16 20 25    36 43 50 60
     4 |                9    15    24    35    49
     3 |             5  8    14 19    29 34    48 59
     2 |          3     7    13    23    33    47
     1 |    0  1  2  4  6 10 12 18 22 28 32 42 46 58
    Y=0|
       +---------------------------------------------
       X=0  1  2  3  4  5  6  7  8  9 10 11 12 13 14

Since gcd(0,K)=0 the X axis itself X=0 is never visited, and since
gcd(K,K)=K the leading diagonal X=Y is not visited except X=1,Y=1.

The number of coprime pairs in each column is Euler's totient function
phi(X), and starting N=0 at X=1,Y=1 means the values 0,1,2,4,6,10,etc
horizontally along Y=1 are the totient sums

     i=K
    sum   phi(i)
     i=1

The pattern of coprimes or not within a column is the same read going up as
going down, since X,X-Y has the same coprimeness as X,Y.  This means
coprimes occur in pairs from X=3 onwards.  (When X is even the middle point
Y=X/2 is not coprime since it has common factor 2 from X=4 onwards.)  So
there's an even number of points in each column from X=2 onwards and the
totals horizontally along X=1 are even likewise.

The current implementation is pretty slack and is fairly slow on medium to
large N, but the resulting pattern is interesting.  Anything making a
straight line etc in the path will probably be related to totient sums in
some way.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::CoprimeColumns-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::RationalsTree>,
L<Math::PlanePath::PythagoreanTree>,
L<Math::PlanePath::DivisibleColumns>

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
