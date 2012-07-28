# Copyright 2010, 2011, 2012 Kevin Ryde

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


package Math::PlanePath::Base::Generic;
use 5.004;
use strict;

use vars '$VERSION','@ISA','@EXPORT_OK';
$VERSION = 83;

use Exporter;
@ISA = ('Exporter');
@EXPORT_OK = ('round_nearest',

              # not documented yet
              'is_infinite',
              'floor');

# uncomment this to run the ### lines
#use Smart::Comments;


sub is_infinite {
  my ($x) = @_;
  return ($x != $x         # nan
          || ($x != 0 && $x == 2*$x));  # inf
}

# with a view to being friendly to BigRat/BigFloat
sub round_nearest {
  my ($x) = @_;
  ### round_nearest(): "$x", $x

  # BigRat through to perl 5.12.4 has some dodginess giving a bigint -0
  # which is considered !=0.  Adding +0 to numify seems to avoid the problem.
  my $int = int($x) + 0;
  if ($x == $int) {
    ### is an integer ...
    return $x;
  }
  $x -= $int;
  ### int:  "$int"
  ### frac: "$x"
  if ($x >= .5) {
    ### round up ...
    return $int + 1;
  }
  if ($x < -.5) {
    ### round down ...
    return $int - 1;
  }
  ### within +/- .5 ...
  return $int;
}

# With a view to being friendly to BigRat/BigFloat.
#
# For reference, POSIX::floor() in perl 5.12.4 is a bit bizarre on UV=64bit
# and NV=53bit double.  UV=2^64-1 rounds up to NV=2^64 which floor() then
# returns, so floor() in fact increases the value of what was an integer
# already.
#
sub floor {
  my ($x) = @_;
  ### floor(): "$x", $x
  my $int = int($x);
  if ($x == $int) {
    ### is an integer ...
    return $x;
  }
  $x -= $int;
  ### frac: "$x"
  if ($x >= 0) {
    ### frac is non-negative ...
    return $int;
  } else {
    ### frac is negative ...
    return $int-1;
  }
}

1;
__END__

=for stopwords Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::Base::Generic -- various path helpers

=for test_synopsis my $x

=head1 SYNOPSIS

 use Math::PlanePath::Base::Generic 'round_nearest';
 $x = round_nearest($x);

=head1 DESCRIPTION

This is a few generic helper functions for the PlanePath code.  They're
designed to work on plain Perl integers and floats and in some cases there's
some special support for C<Math::BigInt>.

=head1 EXPORTS

Nothing is exported by default but each function below can be as in the
usual L<Exporter> style,

    use Math::PlanePath::Base::Generic 'round_down_pow';

=head1 FUNCTIONS

=head2 Generic

=over 4

=item C<$x = round_nearest ($x)>

Return C<$x> rounded to the nearest integer.  If C<$x> is half way, such as
2.5 then it's round upwards to 3.

   $x = round_nearest($x);

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::Base::Digits>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2010, 2011, 2012 Kevin Ryde

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
