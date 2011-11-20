# Copyright 2010, 2011 Kevin Ryde

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


# math-image --path=ZOrderCurve,radix=3 --all --output=numbers
# math-image --path=ZOrderCurve --values=Fibbinary --text
#
# increment N+1 changes low 1111 to 10000
# X bits change 011 to 000, no carry, decreasing by number of low 1s
# Y bits change 011 to 100, plain +1




package Math::PlanePath::ZOrderCurve;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 54;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;
use constant x_negative => 0;
use constant y_negative => 0;

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
  ### ZOrderCurve n_to_xy(): $n
  if ($n < 0) {
    return;
  }
  if (_is_infinite($n)) {
    return ($n,$n);
  }

  {
    # ENHANCE-ME: N and N+1 are either adjacent X or on a slope Y to Y+1 for
    # the base X, don't need the full calculation for N+1
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

  my $x = my $y = ($n * 0); # inherit
  my $radix = $self->{'radix'};
  if ($radix == 2) {
    my $bit = $x|1;  # inherit
    while ($n) {
      ### $x
      ### $y
      ### $n
      ### $bit
      if ($n & 1) {
        $x += $bit;
      }
      if ($n & 2) {
        $y += $bit;
      }
      $n >>= 2;
      $bit <<= 1;
    }
  } else {
    my $power = $x+1;  # inherit
    while ($n) {
      ### $x
      ### $y
      ### $n
      $x += ($n % $radix) * $power;
      $n = int ($n / $radix);
      $y += ($n % $radix) * $power;
      $n = int ($n / $radix);
      $power *= $radix;
    }
  }

  ### is: "$x,$y"
  return ($x, $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### ZOrderCurve xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($x < 0 || $y < 0
      || _is_infinite($x)
      || _is_infinite($y)) {
    return undef;
  }

  my $n = ($x * 0 * $y); # inherit bignum 0
  my $radix = $self->{'radix'};
  if ($radix == 2) {
    my $nbit = $n|1; # inherit
    while ($x || $y) {
      if ($x & 1) {
        $n |= $nbit;
      }
      $x >>= 1;
      $nbit <<= 1;

      if ($y & 1) {
        $n |= $nbit;
      }
      $y >>= 1;
      $nbit <<= 1;
    }
  } else {
    my $power = $n+1; # inherit bignum 1
    while ($x || $y) {
      $n += ($x % $radix) * $power;
      $x = int ($x / $radix);
      $power *= $radix;

      $n += ($y % $radix) * $power;
      $y = int ($y / $radix);
      $power *= $radix;
    }
  }
  return $n;
}

# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }  # x1 smaller
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }  # y1 smaller

  if ($y2 < 0 || $x2 < 0) {
    return (1, 0); # rect all negative, no N
  }

  if ($x1 < 0) { $x1 = 0; }
  if ($y1 < 0) { $y1 = 0; }

  # monotonic increasing in $x and $y directions, so this is exact
  return ($self->xy_to_n ($x1, $y1),
          $self->xy_to_n ($x2, $y2));
}

1;
__END__

  # my $xmod = 2 + ($self->{'wider'} || 0);
  # if (my $xmod = $self->{'wider'}) {
  # 
  #   $xmod += 2;
  #   ### $xmod
  # 
  #   my $xbit = 1;
  #   my $ybit = 1;
  #   while ($n) {
  #     ### $x
  #     ### $y
  #     ### $n
  #     ### $xbit
  #     ### $ybit
  #     $x += ($n % $xmod) * $xbit;
  #     $n = floor ($n / $xmod);
  #     $xbit *= $xmod;
  # 
  #     if ($n & 1) {
  #       $y += $ybit;
  #     }
  #     $n >>= 1;
  #     $ybit <<= 1;
  #   }
  # } else {

  # my $xmod = 2 + ($self->{'wider'} || 0);
  # 
  # my $n = 0;
  # my $npos = 1;
  # while ($x || $y) {
  #   if ($y & 1) {
  #     $n += $npos;
  #   }
  #   $y >>= 1;
  #   $npos <<= 1;
  # 
  # $n += ($x % $xmod) * $npos;
  #   $x = int ($x / $xmod);
  #   $npos *= $xmod;

=for stopwords Ryde Math-PlanePath Karatsuba undrawn fibbinary eg Radix radix

=head1 NAME

Math::PlanePath::ZOrderCurve -- alternate digits to X and Y

=head1 SYNOPSIS

 use Math::PlanePath::ZOrderCurve;

 my $path = Math::PlanePath::ZOrderCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

 # or another radix digits ...
 my $path3 = Math::PlanePath::ZOrderCurve->new (radix => 3);

=head1 DESCRIPTION

This path puts points in a self-similar Z pattern described by G.M. Morton,

      7  |   42  43  46  47  58  59  62  63
      6  |   40  41  44  45  56  57  60  61
      5  |   34  35  38  39  50  51  54  55
      4  |   32  33  36  37  48  49  52  53
      3  |   10  11  14  15  26  27  30  31
      2  |    8   9  12  13  24  25  28  29
      1  |    2   3   6   7  18  19  22  23
     Y=0 |    0   1   4   5  16  17  20  21  64  ...
         +--------------------------------
          X=0   1   2   3   4   5   6   7

The first four points make a "Z" shape if written with Y going downwards
(inverted if drawn upwards as above),

     0---1       Y=0
        /
      /
     2---3       Y=1

Then groups of those are arranged as a further Z, etc, doubling in size each
time.

     0   1      4   5       Y=0
     2   3 ---  6   7       Y=1
             /
            /
           /
     8   9 --- 12  13       Y=2
    10  11     14  15       Y=3

Within an power of 2 square 2x2, 4x4, 8x8, 16x16 etc (2^k)x(2^k), all the N
values 0 to 2^(2*k)-1 are within the square.  The top right corner 3, 15,
63, 255 etc of each is the 2^(2*k)-1 maximum.

=head2 Power of 2 Values

Plotting N values related to powers of 2 can come out as interesting
patterns.  For example displaying the N's which have no digit 3 in their
base 4 representation gives

    * 
    * * 
    *   * 
    * * * * 
    *       * 
    * *     * * 
    *   *   *   * 
    * * * * * * * * 
    *               * 
    * *             * * 
    *   *           *   * 
    * * * *         * * * * 
    *       *       *       * 
    * *     * *     * *     * * 
    *   *   *   *   *   *   *   * 
    * * * * * * * * * * * * * * * * 

The 0,1,2 and not 3 makes a little 2x2 "L" at the bottom left, then
repeating at 4x4 with again the whole "3" position undrawn, and so on.  This
is the Sierpinski triangle (a rotated version of
L<Math::PlanePath::SierpinskiTriangle>).  The blanks are also a visual
representation of 1-in-4 cross-products saved by recursive use of the
Karatsuba multiplication algorithm.

Plotting the fibbinary numbers (eg. L<Math::NumSeq::Fibbinary>) which are N
values with no adjacent 1 bits in binary makes an attractive tree-like
pattern,

    *                                                               
    **                                                              
    *                                                               
    ****                                                            
    *                                                               
    **                                                              
    *   *                                                           
    ********                                                        
    *                                                               
    **                                                              
    *                                                               
    ****                                                            
    *       *                                                       
    **      **                                                      
    *   *   *   *                                                   
    ****************                                                
    *                               *                               
    **                              **                              
    *                               *                               
    ****                            ****                            
    *                               *                               
    **                              **                              
    *   *                           *   *                           
    ********                        ********                        
    *               *               *               *               
    **              **              **              **              
    *               *               *               *               
    ****            ****            ****            ****            
    *       *       *       *       *       *       *       *       
    **      **      **      **      **      **      **      **      
    *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   
    ****************************************************************

The horizontals arise from N=...0a0b0c for bits a,b,c so Y=...000 and
X=...abc, making those N values adjacent.  Similarly N=...a0b0c0 for a
vertical.

=head2 Radix

The radix parameter can do the same sort of N -> X/Y digit splitting in a
higher base.  For example radix 3 makes 3x3 groupings,

      5  |  33  34  35  42  43  44
      4  |  30  31  32  39  40  41
      3  |  27  28  29  36  37  38  45  ...
      2  |   6   7   8  15  16  17  24  25  26
      1  |   3   4   5  12  13  14  21  22  23
     Y=0 |   0   1   2   9  10  11  18  19  20
         +--------------------------------------
           X=0   1   2   3   4   5   6   7   8

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::ZOrderCurve-E<gt>new ()>

=item C<$path = Math::PlanePath::ZOrderCurve-E<gt>new (radix =E<gt> $r)>

Create and return a new path object.  The optional C<radix> parameter gives
the base for digit splitting (the default is binary, radix 2).

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.  The lines don't overlap, but the lines between bit
squares soon become rather long and probably of very limited use.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x,$y>.  Each integer N is
considered the centre of a unit square and an C<$x,$y> within that square
returns N.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

The returned range is exact, meaning C<$n_lo> and C<$n_hi> are the smallest
and biggest in the rectangle.

=back

=head1 FORMULAS

=head2 N to X,Y

The coordinate calculation is simple.  The bits of X and Y are every second
bit of N.  So if N = binary 101010 then X=000 and Y=111 in binary, which is
the N=42 shown above at X=0,Y=7.

With the C<radix> parameter the digits are treated likewise, in the given
radix rather than binary.

=head2 Rectangle to N Range

Within each row the N values increase as X increases, and within each column
N increases with increasing Y (for all C<radix> parameters).

So for a given rectangle the smallest N is at the lower left corner
(smallest X and smallest Y), and the biggest N is at the upper right
(biggest X and biggest Y).

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PeanoCurve>,
L<Math::PlanePath::HilbertCurve>,
L<Math::PlanePath::ImaginaryBase>,
L<Math::PlanePath::CornerReplicate>,
L<Math::PlanePath::DigitGroups>

C<http://www.jjj.de/fxt/#fxtbook> (section 1.31.2)

L<Algorithm::QuadTree>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2010, 2011 Kevin Ryde

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
