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


# increment N+1 changes low 1111 to 10000
# X bits change 011 to 000, no carry, decreasing by number of low 1s
# Y bits change 011 to 100, plain +1


package Math::PlanePath::DigitGroups;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 65;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;


use constant n_start => 0;
use constant class_x_negative => 0;
use constant class_y_negative => 0;

use constant parameter_info_array => [{ name      => 'radix',
                                        share_key => 'radix_2',
                                        type      => 'integer',
                                        minimum   => 2,
                                        default   => 2,
                                        width     => 3,
                                      }];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  if (! $self->{'radix'} || $self->{'radix'} < 2) {
    $self->{'radix'} = 2;
  }
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### DigitGroups n_to_xy(): $n
  if ($n < 0) {
    return;
  }
  if (_is_infinite($n)) {
    return ($n,$n);
  }

  # what to do for fractions ?
  {
    my $int = int($n);
    ### $int
    if ($n != $int) {
      my $frac = $n - $int;  # inherit possible BigFloat/BigRat
      ### $frac
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int; # BigFloat int() gives BigInt, use that
  }

  my $radix = $self->{'radix'};
  ### $radix
  my $x = my $y = $n * 0;          # inherit bignum 0
  my $xpower = my $ypower = $x+1;  # inherit bignum 1
  my $digit;
  for (;;) {
    do {
      $digit = ($n % $radix);
      ### digit to x: $digit
      $x += $digit * $xpower;
      $n = int ($n / $radix) || return ($x, $y);
      $xpower *= $radix;
    } while ($digit);

    do {
      $digit = ($n % $radix);
      ### digit to y: $digit
      $y += $digit * $ypower;
      $n = int ($n / $radix) || return ($x, $y);
      $ypower *= $radix;
    } while ($digit);
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### DigitGroups xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);

  if (_is_infinite($x)) {
    return $x;
  }
  if (_is_infinite($y)) {
    return $y;
  }
  if ($x < 0 || $y < 0) {
    return undef;
  }

  if ($x == 0 && $y == 0) {
    return 0;
  }

  my $radix = $self->{'radix'};
  my $n = ($x * 0 * $y);   # inherit bignum
  my $power = $n+1;        # inherit bignum 1
  my $digit;
  while ($x || $y) {
    do {
      $digit = ($x % $radix);
      ### digit from x: $digit
      $n += $digit * $power;
      $power *= $radix;
      $x = int ($x / $radix);
    } while ($digit);

    do {
      $digit = ($y % $radix);
      ### digit from y: $digit
      $n += $digit * $power;
      $power *= $radix;
      $y = int ($y / $radix);
    } while ($digit);
  }
  return $n;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### DigitGroups rect_to_n_range() ...

  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }  # x1 smaller
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }  # y1 smaller

  if ($y2 < 0 || $x2 < 0) {
    return (1, 0); # rect all negative, no N
  }

  my $radix = $self->{'radix'};

  my ($power, $x2_level) = _round_down_pow ($x2, $radix);
  if (_is_infinite($x2_level)) {
    return (0,$x2_level);
  }

  ($power, my $y2_level) = _round_down_pow ($y2, $radix);
  if (_is_infinite($y2_level)) {
    return (0,$y2_level);
  }

  ($power, my $x1_level) = _round_down_pow ($x1, $radix);
  if (_is_infinite($x1_level)) {
    return (0,$x1_level);
  }

  ($power, my $y1_level) = _round_down_pow ($y1, $radix);
  if (_is_infinite($y1_level)) {
    return (0,$y1_level);
  }

  ### $x1_level
  ### $y1_level
  ### $x2_level
  ### $y2_level

  my $lo_level = ($x1_level < $y1_level ? $x1_level : $y1_level);
  my $hi_level = ($x2_level > $y2_level ? $x2_level : $y2_level);
  return ($lo_level == 0 ? 0 : ($radix*$radix + 1) * $radix ** (2*$lo_level),
          ($radix-1)*$radix**(3*$hi_level+2) + $radix**($hi_level+1) - 1);
}

1;
__END__

=for stopwords Ryde Math-PlanePath undrawn Radix cardinality bijection radix

=head1 NAME

Math::PlanePath::DigitGroups -- X,Y digits grouped by zeros

=head1 SYNOPSIS

 use Math::PlanePath::DigitGroups;

 my $path = Math::PlanePath::DigitGroups->new (radix => 2);
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path splits an N into X,Y by digit groups with a leading 0.  The
default is binary so for example

    N = 110111001011

is split into groups with a high 0 digit which go to X or Y alternately,

    11 0111 0 01 011
     X   Y  X  Y  X

    X = 11 0 011 = 110011
    Y = 0111 01  = 11101

The result is a one-to-one mapping between numbers NE<gt>=0 and pairs
XE<gt>=0,YE<gt>=0.

The default binary is

    11  |   38   77   86  155  166  173  182  311  550  333  342  347
    10  |   72  145  148  291  168  297  300  583  328  337  340  595
     9  |   66  133  138  267  162  277  282  535  322  325  330  555
     8  |  128  257  260  515  272  521  524 1031  320  545  548 1043
     7  |   14   29   46   59  142   93  110  119  526  285  302  187
     6  |   24   49   52   99   88  105  108  199  280  177  180  211
     5  |   18   37   42   75   82   85   90  151  274  165  170  171
     4  |   32   65   68  131   80  137  140  263  160  161  164  275
     3  |    6   13   22   27   70   45   54   55  262  141  150   91
     2  |    8   17   20   35   40   41   44   71  136   81   84   83
     1  |    2    5   10   11   34   21   26   23  130   69   74   43
    Y=0 |    0    1    4    3   16    9   12    7   64   33   36   19
        +-------------------------------------------------------------
           X=0    1    2    3    4    5    6    7    8    9   10   11

=head2 Radix

The C<radix =E<gt> $r> option selects a different base for the digit split.
For example C<radix =E<gt> 5> gives

   12  |  60  301  302  303  304  685 1506 1507 1508 1509 1310 1511
   11  |  55  276  277  278  279  680 1381 1382 1383 1384 1305 1386
   10  | 250 1251 1252 1253 1254 1275 6256 6257 6258 6259 1300 6261
    9  |  45  226  227  228  229  670 1131 1132 1133 1134 1295 1136
    8  |  40  201  202  203  204  665 1006 1007 1008 1009 1290 1011
    7  |  35  176  177  178  179  660  881  882  883  884 1285  886
    6  |  30  151  152  153  154  655  756  757  758  759 1280  761
    5  | 125  626  627  628  629  650 3131 3132 3133 3134  675 3136
    4  |  20  101  102  103  104  145  506  507  508  509  270  511
    3  |  15   76   77   78   79  140  381  382  383  384  265  386
    2  |  10   51   52   53   54  135  256  257  258  259  260  261
    1  |   5   26   27   28   29  130  131  132  133  134  255  136
   Y=0 |   0    1    2    3    4   25    6    7    8    9   50   11
       +-----------------------------------------------------------
         X=0    1    2    3    4    5    6    7    8    9   10   11

=head2 Real Line and Plane

This split is inspired by the digit grouping in the proof that the real line
is the same cardinality as the plane.  (By Cantor was it?)  In that proof a
bijection between interval n=(0,1) and pairs x=(0,1),y=(0,1) is made by
taking groups of fraction digits stopping at a non-zero digit.

Non-terminating fractions like 0.49999... are chosen over terminating
0.5000... so there's infinitely many non-zero digits going lower.  For the
integer form here the groupings are towards higher digits and there's
infinitely many zero digits going higher, hence grouping by zeros instead of
non-zeros.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::DigitGroups-E<gt>new ()>

=item C<$path = Math::PlanePath::DigitGroups-E<gt>new (radix =E<gt> $r)>

Create and return a new path object.  The optional C<radix> parameter gives
the base for digit splitting (the default is binary, radix 2).

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::ZOrderCurve>

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

# Local variables:
# compile-command: "math-image --path=DigitGroups,radix=2 --lines"
# End:
#
# math-image --path=DigitGroups --output=numbers_dash
# math-image --path=DigitGroups,radix=2 --all --output=numbers
#
