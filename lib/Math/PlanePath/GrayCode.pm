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



# math-image --path=GrayCode,apply_type=N --all --output=numbers_dash --size=28x19
# math-image --path=GrayCode,radix=3 --all --output=numbers_dash
# math-image --path=GrayCode,apply_type=Ts --all --output=numbers_dash


# A105529 ternary gray cyclic inverse
# A105530 ternary gray cyclic
# A128173 ternary gray reversing
#
# A098488 decimal gray modular
# A003100 decimal gray reflected
# A174025 decimal gray reflected inverse
#
# A014550 gray code, in binary
# A003188 gray code, in decimal
# A006068 gray code inverse, in decimal
# A055975 gray code first diffs
# A048641 gray code cumulative
# A048642 gray code partial products
# A099891 xor cumulative triangle
# A039963 period doubling morphism, gray N left turns (and LSR)
#
# A195467 anti-diagonal powers of gray permutation
# A173318 runs partial sums A005811
#
# A147995 strange hopping walk


package Math::PlanePath::GrayCode;
use 5.004;
use strict;
use Carp;

use vars '$VERSION', '@ISA';
$VERSION = 73;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_min = \&Math::PlanePath::_min;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

use Math::PlanePath::ZOrderCurve;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant n_start => 0;
use constant class_x_negative => 0;
use constant class_y_negative => 0;

use constant parameter_info_array =>
  [
   { name      => 'apply_type',
     type      => 'enum',
     default   => 'TsF',
     choices         => ['TsF','Ts','Fs','FsT','sT','sF'],
     choices_display => ['TsF','Ts','Fs','FsT','sT','sF'],
   },
   { name      => 'gray_type',
     type      => 'enum',
     default   => 'reflected',
     choices   => ['reflected','modular'],
     description => 'The type of Gray code.',
   },
   { name      => 'radix',
     share_key => 'radix_2',
     type      => 'integer',
     minimum   => 2,
     default   => 2,
     width     => 3,
   },
  ];

my %funcbase = (T  => '_digits_to_gray',
                F  => '_digits_from_gray',
                '' => '_noop');
my %inv = (T  => 'F',
           F  => 'T',
           '' => '');

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  ### $self

  if (! $self->{'radix'} || $self->{'radix'} < 2) {
    $self->{'radix'} = 2;
  }

  my $apply_type = ($self->{'apply_type'} ||= 'TsF');
  my $gray_type = ($self->{'gray_type'} ||= 'reflected');

  unless ($apply_type =~ /^([TF]?)s([TF]?)$/) {
    croak "Unrecognised apply_type \"$apply_type\"";
  }
  my $nf = $1;  # "T" or "F" or ""
  my $xyf = $2;

  $self->{'n_func'} = $self->can("$funcbase{$nf}_$gray_type")
    || croak "Unrecognised gray_type \"$self->{'gray_type'}\"";
  $self->{'xy_func'} = $self->can("$funcbase{$xyf}_$gray_type");

  $nf = $inv{$nf};
  $xyf = $inv{$xyf};

  $self->{'inverse_n_func'} = $self->can("$funcbase{$nf}_$gray_type");
  $self->{'inverse_xy_func'} = $self->can("$funcbase{$xyf}_$gray_type");

  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### GrayCode n_to_xy(): $n

  if ($n < 0) {
    return;
  }
  if (_is_infinite($n)) {
    return ($n,$n);
  }

  {
    # ENHANCE-ME: N and N+1 differ by not much ...
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
  my $digits = _digit_split($n,$radix);
  $self->{'n_func'}->($digits,$radix);

  my @xdigits;
  my @ydigits;
  while (@$digits) {
    push @xdigits, shift @$digits;
    push @ydigits, shift @$digits || 0;
  }
  my $xdigits = \@xdigits;
  my $ydigits = \@ydigits;
  $self->{'xy_func'}->($xdigits,$radix);
  $self->{'xy_func'}->($ydigits,$radix);

  return (_digit_join($xdigits,$radix),
          _digit_join($ydigits,$radix));
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### GrayCode xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($x < 0 || $y < 0) {
    return undef;
  }
  if (_is_infinite($x)) {
    return $x;
  }
  if (_is_infinite($y)) {
    return $y;
  }

  my $radix = $self->{'radix'};
  my $xdigits = _digit_split($x,$radix);
  my $ydigits = _digit_split($y,$radix);

  $self->{'inverse_xy_func'}->($xdigits,$radix);
  $self->{'inverse_xy_func'}->($ydigits,$radix);

  my @digits;
  for (;;) {
    (@$xdigits || @$ydigits) or last;
    push @digits, shift @$xdigits || 0;
    (@$xdigits || @$ydigits) or last;
    push @digits, shift @$ydigits || 0;
  }
  my $digits = \@digits;

  $self->{'inverse_n_func'}->($digits,$radix);

  return _digit_join($digits,$radix);
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = _round_nearest($x1);
  $y1 = _round_nearest($y1);
  $x2 = _round_nearest($x2);
  $y2 = _round_nearest($y2);

  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }  # x1 smaller
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }  # y1 smaller

  if ($y2 < 0 || $x2 < 0) {
    return (1, 0); # rect all negative, no N
  }

  my $radix = $self->{'radix'};
  my ($pow_max) = _round_down_pow (_max($x2,$y2), $radix);
  $pow_max *= $radix;
  return (0, $pow_max*$pow_max - 1);
}

#------------------------------------------------------------------------------

use constant _noop_reflected => undef;
use constant _noop_modular   => undef;

sub _digit_split {
  my ($n, $radix) = @_;
  ### _digit_split(): $n
  my @ret;
  while ($n) {
    push @ret, $n % $radix;
    $n = int($n/$radix);
  }
  return \@ret;   # array[0] low digit
}

# $aref->[0] low digit
sub _digit_join {
  my ($aref, $radix) = @_;
  my $n = 0;
  while (defined (my $digit = pop @$aref)) {
    $n *= $radix;
    $n += $digit;
  }
  return $n;
}

# $aref->[0] low digit
sub _digits_to_gray_reflected {
  my ($aref, $radix) = @_;
  ### _digits_to_gray(): $aref

  $radix -= 1;
  my $reverse = 0;
  foreach my $digit (reverse @$aref) {  # high to low
    if ($reverse & 1) {
      $digit = $radix - $digit;  # radix-1 - digit
    }
    $reverse ^= $digit;
  }
}
# $aref->[0] low digit
sub _digits_to_gray_modular {
  my ($aref, $radix) = @_;

  my $offset = 0;
  foreach my $digit (reverse @$aref) {  # high to low
    $offset += ($digit = ($digit - $offset) % $radix); # mutate $aref->[i]
  }
}

# $aref->[0] low digit
sub _digits_from_gray_reflected {
  my ($aref, $radix) = @_;

  $radix -= 1;
  my $reverse = 0;
  foreach my $digit (reverse @$aref) {  # high to low
    if ($reverse & 1) {
      $reverse ^= $digit;        # before this reversal
      $digit = $radix - $digit;  # radix-1 - digit
    } else {
      $reverse ^= $digit;
    }
  }
}
# $aref->[0] low digit
sub _digits_from_gray_modular {
  my ($aref, $radix) = @_;
  ### _digits_from_gray_modular(): $aref

  my $offset = 0;
  foreach my $digit (reverse @$aref) {  # high to low
    $offset = ($digit = ($digit + $offset) % $radix); # mutate $aref->[i]
  }
}

1;
__END__

=for stopwords Ryde Math-PlanePath eg Radix radix ie

=head1 NAME

Math::PlanePath::GrayCode -- Gray code coordinates

=head1 SYNOPSIS

 use Math::PlanePath::GrayCode;

 my $path = Math::PlanePath::GrayCode->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is a mapping of N to X,Y using Gray codes.  The default is the form by
Christos Faloutsos which is an X,Y split in binary reflected Gray code.

      7  |  63-62 57-56 39-38 33-32
         |      |  |        |  |
      6  |  60-61 58-59 36-37 34-35
         |
      5  |  51-50 53-52 43-42 45-44
         |      |  |        |  |
      4  |  48-49 54-55 40-41 46-47
         |
      3  |  15-14  9--8 23-22 17-16
         |      |  |        |  |
      2  |  12-13 10-11 20-21 18-19
         |
      1  |   3--2  5--4 27-26 29-28
         |      |  |        |  |
     Y=0 |   0--1  6--7 24-25 30-31
         |
         +-------------------------
           X=0  1  2  3  4  5  6  7

N is converted to a Gray code, then split by bits to X,Y, and those X,Y
converted back from Gray to integer indices.  Stepping from N to N+1 changes
just one bit of the Gray code and therefore changes just one of X or Y each
time.

On the Y axis the values use only digits 0,3 in base 4.  On the X axis the
values are 2k and 2k+1 where k uses only digits 0,3 in base 4.  It happens
too that a turn N-1,N,N+1 is always either left +90 or reverse 180, never
straight ahead or to the right.

=head2 Radix

The default is binary, or the C<radix =E<gt> $r> option can select another
radix.  This is used for both the Gray code and the digit splitting.  For
example C<radix =E<gt> 4>,

    radix => 4

      |
    127-126-125-124  99--98--97--96--95--94--93--92  67--66--65--64
                  |   |                           |   |
    120-121-122-123 100-101-102-103  88--89--90--91  68--69--70--71
      |                           |   |                           |
    119-118-117-116 107-106-105-104  87--86--85--84  75--74--73--72
                  |   |                           |   |
    112-113-114-115 108-109-110-111  80--81--82--83  76--77--78--79

     15--14--13--12  19--18--17--16  47--46--45--44  51--50--49--48
                  |   |                           |   |
      8-- 9--10--11  20--21--22--23  40--41--42--43  52--53--54--55
      |                           |   |                           |
      7-- 6-- 5-- 4  27--26--25--24  39--38--37--36  59--58--57--56
                  |   |                           |   |
      0-- 1-- 2-- 3  28--29--30--31--32--33--34--35  60--61--62--63

=head2 Apply Type

The C<apply_type =E<gt> $str> option controls how Gray codes are applied to
N and X,Y.  It can be one of

    "TsF"    to Gray, split, from Gray  (default)
    "Ts"     to Gray, split
    "Fs"     from Gray, split
    "FsT"    from Gray, split, to Gray
     "sT"    split, to Gray
     "sF"    split, from Gray

"T" means integer-to-Gray, "F" means integer-from-Gray, and omitted means no
transformation.  For example the following is "Ts" which means N to Gray
then split, leaving Gray coded values for X,Y.

    apply_type => "Ts"

     7  |  51--50  52--53  44--45  43--42
        |       |       |       |       |
     6  |  48--49  55--54  47--46  40--41
        |
     5  |  60--61  59--58  35--34  36--37  ...-66
        |       |       |       |       |       |
     4  |  63--62  56--57  32--33  39--38  64--65
        |
     3  |  12--13  11--10  19--18  20--21
        |       |       |       |       |
     2  |  15--14   8-- 9  16--17  23--22
        |
     1  |   3-- 2   4-- 5  28--29  27--26
        |       |       |       |       |
    Y=0 |   0-- 1   7-- 6  31--30  24--25
        |
        +---------------------------------
          X=0   1   2   3   4   5   6   7

This "Ts" is quite attractive because a step from N to N+1 changes just one
bit in X or Y alternately, giving 2-D single-digit changes.  For example
N=19 at X=4 then N=20 at X=6 is a single bit change in X.

N=0,2,8,10,etc on the leading diagonal X=Y is numbers using only digits 0,2
in base 4.  The Y axis N=0,3,15,12,etc is numbers using only digits 0,3 in
base 4, but in a Gray code order.

The "Fs", "FsT" and "sF" forms effectively treat the input N as a Gray code
and convert from it to integers, either before or after split.  For "Fs" the
effect is little Z parts in various orientations.

    apply_type => "sF"

     7  |  32--33  37--36  52--53  49--48
        |    /       \       /       \
     6  |  34--35  39--38  54--55  51--50
        |
     5  |  42--43  47--46  62--63  59--58
        |    \       /       \       /
     4  |  40--41  45--44  60--61  57--56
        |
     3  |   8-- 9  13--12  28--29  25--24
        |    /       \       /       \
     2  |  10--11  15--14  30--31  27--26
        |
     1  |   2-- 3   7-- 6  22--23  19--18
        |    \       /       \       /
    Y=0 |   0-- 1   5-- 4  20--21  17--16
        |
        +---------------------------------
          X=0   1   2   3   4   5   6   7

=head2 Gray Type

The C<gray_type> option selects what type of Gray code is used.  The choices
are

    "reflected"     increment to radix-1 then decrement (default)
    "modular"       cycle from radix-1 back to 0

For example in decimal,

    integer       Gray         Gray
               "reflected"   "modular"
    -------    -----------   ---------
       0            0            0
       1            1            1
       2            2            2
     ...          ...          ...
       8            8            8
       9            9            9
      10           19           19
      11           18           10
      12           17           11
      13           16           12
      14           15           13
     ...          ...          ...
      17           12           16
      18           11           17
      19           10           18

Notice on reaching "19" the reflected type runs the low digit down again, a
reverse or reflection of the preceding 0 up to 9.  The modular form instead
continues to increment the low digit, wrapping around from 9 to 0.

In binary modular and reflected are the same (see L</Equivalent
Combinations> below).  There's various other systematic ways to change a
single digit successively but many of them are implicitly based on a
pre-determined fixed number of bits or digits.

=head2 Equivalent Combinations

Some option combinations are equivalent,

    condition                  equivalent
    ---------                  ----------
    radix=2                    modular==reflected
                               and TsF==Fs, Ts==FsT

    radix>2 odd reflected      TsF==FsT, Ts==Fs, sT==sF
                               because T==F

    radix>2 even reflected     TsF==Fs, Ts==FsT

In binary radix=2 the "modular" and "reflected" Gray codes are the same
because there's only digits 0 and 1 so going forward or backward is the
same.

For odd radix and reflected Gray code, the "to Gray" and "from Gray"
operations are the same.  For example the following table is ternary
radix=3.  Notice how integer value 012 maps to Gray code 010, and in turn
integer 010 maps to Gray code 012.  All values are either 2-cycle pairs like
that or unchanged like 021.

    integer      Gray
              "reflected"       (written in ternary)
      000       000
      001       001
      002       002
      010       012
      011       011
      012       010
      020       020
      021       021
      022       022

For even radix and reflected Gray code, "TsF" is equivalent to "Fs", and
also "Ts" equivalent to "FsT".  This arises from the way the reversing
behaves when split across digits of two X,Y values.  (In higher dimensions
such as a split to 3-D X,Y,Z it's not the same.)

The net effect for distinct paths is

    condition         distinct combinations
    ---------         ---------------------
    radix=2           four TsF==Fs, Ts==FsT, sT, sF
    radix>2 odd       / three reflected TsF==FsT, Ts==Fs, sT==sF
                      \ six modular TsF, Ts, Fs, FsT, sT, sF
    radix>2 even      / four reflected TsF==Fs, Ts==FsT, sT, sF
                      \ six modular TsF, Ts, Fs, FsT, sT, sF

=head2 Peano Curve

In C<radix =E<gt> 3> and other odd radices the "reflected" Gray type gives
the Peano curve (see L<Math::PlanePath::PeanoCurve>).  The "reflected"
encoding is equivalent to Peano's "xk" and "yk" complementing.

     |
    53--52--51  38--37--36--35--34--33
             |   |                   |
    48--49--50  39--40--41  30--31--32
     |                   |   |
    47--46--45--44--43--42  29--28--27
                                     |
     6-- 7-- 8-- 9--10--11  24--25--26
     |                   |   |
     5-- 4-- 3  14--13--12  23--22--21
             |   |                   |
     0-- 1-- 2  15--16--17--18--19--20

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::GrayCode-E<gt>new ()>

=item C<$path = Math::PlanePath::GrayCode-E<gt>new (radix =E<gt> $r, apply_type =E<gt> $str, gray_type =E<gt> $str)>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=item C<$n = $path-E<gt>n_start ()>

Return the first N on the path, which is 0.

=back

=head1 OEIS

This path is in Sloane's Online Encyclopedia of Integer Sequences in a few
forms,

    http://oeis.org/A163233  (etc)

    A163233    "sF" N values by diagonals, same axis start
    A163234      inverse permutation
    A163235    "sF" N values by diagonals, opp axis start
    A163236      inverse permutation
    A163237    "sF" N values by diagonals, same axis, flip digits 2,3
    A163238      inverse permutation
    A163239    "sF" N values by diagonals, opp axis, flip digits 2,3
    A163240      inverse permutation

    A163242    "sF" N sums along diagonals
    A163478      sums divided by 3

The Gray code conversions themselves (not directly offered by the PlanePath
code here) are variously for instance binary A003188, ternary reflected
A128173 and modular A105530, decimal reflected A003100 and modular A098488.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::ZOrderCurve>,
L<Math::PlanePath::PeanoCurve>,
L<Math::PlanePath::CornerReplicate>

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