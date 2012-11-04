
# parts=3 depth_to_n wrong



# Copyright 2012 Kevin Ryde

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


# math-image --path=ToothpickTree --all --output=numbers --size=80x50
# math-image --path=ToothpickTree --all --figure=eobar
#
# A160740 toothpick starting from 4 as cross
#
# A153001 toothpick converge of parts=3 added
#         endless row without exceptions at 2^k points
# A162795 number parallel to initial
# A162796 number opposite to initial
# A162797  opp/par difference
# A162793 added at an odd depth
# A162794 added at an even depth
#
# A160160,A160161,A162798 3-D toothpicks
#
# cf A160172 T-tooth
#
# cf Other
#    A160408, A160409 toothpick pyramid 3-D
#
#    A160406 45deg diagonals wedge
#    A160407   added
#      http://www.polprimos.com/imagenespub/poltp406.jpg
#
# A139250 total cells OFFSET=0 value=0
#    a(2^k) = A007583(k) = (2^(2n+1) + 1)/3
#    a(2^k-1) = A000969(2^k-2), A000969=floor (2*n+3)*(n+1)/3
# A139251 cells added
#   0, 1, 2,
#   4,  4,
#   4, 8, 12, 8,
#   4, 8, 12, 12, 16, 28, 32, 16,
#   4, 8, 12, 12, 16, 28, 32, 20, 16, 28, 36, 40, 60, 88, 80, 32,
#   4, 8, 12, 12, 16, 28, 32, 20, 16, 28, 36, 40, 60, 88, 80, 36, 16, 28, 36, 40, 60, 88, 84, 56, 60, 92, 112, 140, 208, 256, 192, 64,
#   4, 8, 12, 12, 16, 28, 32, 20, 16, 28

# A152968 (cells added)/2
# A152978 (cells added)/4, is quarter cells added too
# A139253 primes among total cells
#
# A139252 total segments
# A139560 new segments added, end-to-end meetings not counted
# A147614 grid points if length 2,
#           ie. counting endpoints too, without multiplicity
# A139252 count segments to level, end-to-end meetings coalesced
#
# A160570 triangle, row sums are toothpick cumulative
# A153007 triangular-toothpick
# A160552 A160762 A151548 toothpick
#
# cf A160808 count cells Fibonacci spiral
#    A160809 cells added Fibonacci spiral
#
#    A160164 "I"-toothpick
#    A187220 gull
#
#    A151567 another rule toothpicks

# "Q"
# A187210, A210838, A210841, A211001-A211003, A211010, A211020-A211024.
# A211000  A211011


package Math::PlanePath::ToothpickTree;
use 5.004;
use strict;
#use List::Util 'max','min';
*max = \&Math::PlanePath::_max;
*min = \&Math::PlanePath::_min;

use vars '$VERSION', '@ISA';
$VERSION = 92;
use Math::PlanePath;
@ISA = ('Math::PlanePath');

use Math::PlanePath::Base::Generic
  'is_infinite',
  'round_nearest';
use Math::PlanePath::Base::Digits
  'round_down_pow';

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 0;

use constant parameter_info_array =>
  [ { name            => 'parts',
      share_key       => 'parts_1to4',
      display         => 'Parts',
      type            => 'integer',
      default         => 4,
      width           => 1,
      minimum         => 1,
      maximum         => 4,
      description     => 'Which parts of the plane to fill, 1 to 4 quadrants.',
    },
  ];

sub new {
  my $self = shift->SUPER::new(@_);
  if (! defined $self->{'parts'}) {
    $self->{'parts'} = 4;
  }

  $self->{'horiz'} = 0;
  $self->{'endpoints_x'} = [ 0 ];
  $self->{'endpoints_y'} = [ 0 ];
  $self->{'endpoints_dir'} = [ 2 ];
  $self->{'xy_to_n'} = { '0,0' => 0 };
  $self->{'n_to_x'} = [ 0 ];
  $self->{'n_to_y'} = [ 0 ];
  $self->{'level_to_n'} = [ 0, 1 ];
  $self->{'level'} = 0;
  return $self;
}


use constant _UNTESTED__tree_level_start => 0;
sub _UNTESTED__tree_level_n_range {
  my ($self, $level) = @_;
  my $level_to_n = $self->{'level_to_n'};
  while ($#$level_to_n <= $level) {
    _extend($self);
  }
  return ($level_to_n->[$level], $level_to_n->[$level+1]-1);
}


my @dir_to_dx = (1,0,-1,0);
my @dir_to_dy = (0,1,0,-1);

sub _extend {
  my ($self) = @_;
  ### _extend(): $self
  my $xy_to_n = $self->{'xy_to_n'};
  my $endpoints_x = $self->{'endpoints_x'};
  my $endpoints_y = $self->{'endpoints_y'};
  my $endpoints_dir = $self->{'endpoints_dir'};
  my @extend_x;
  my @extend_y;
  my @extend_dir;
  my %extend;
  foreach my $i (0 .. $#$endpoints_x) {
    my $x = $endpoints_x->[$i];
    my $y = $endpoints_y->[$i];
    my $dir = ($endpoints_dir->[$i] - 1) & 3;  # -90
    foreach (-1, 1) {
      my $x = $x + $dir_to_dx[$dir];
      my $y = $y + $dir_to_dy[$dir];
      my $key = "$x,$y";
      unless ($xy_to_n->{$key}) {
        $extend{$key}++;
        push @extend_x, $x;
        push @extend_y, $y;
        push @extend_dir, $dir;
      }
      $dir ^= 2;  # +180
    }
  }
  @$endpoints_x = ();
  @$endpoints_y = ();
  @$endpoints_dir = ();
  foreach my $i (0 .. $#extend_x) {
    my $x = $extend_x[$i];
    my $y = $extend_y[$i];
    my $key = "$x,$y";
    next if $extend{$key} > 1;
    push @$endpoints_x, $x;
    push @$endpoints_y, $y;
    push @$endpoints_dir, $extend_dir[$i];
  }
  my $n_to_x = $self->{'n_to_x'};
  my $n_to_y = $self->{'n_to_y'};
  foreach my $i (0 .. $#$endpoints_x) {
    my $x = $endpoints_x->[$i];
    my $y = $endpoints_y->[$i];
    push @$n_to_x, $x;
    push @$n_to_y, $y;
    $xy_to_n->{"$x,$y"} = $#$n_to_x;
  }
  push @{$self->{'level_to_n'}}, $#$n_to_x + 1;
  $self->{'level'}++;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### ToothpickTree n_to_xy(): $n

  if ($n < 0) { return; }
  if (is_infinite($n)) { return ($n,$n); }

  {
    my $int = int($n);
    ### $int
    ### $n
    if ($n != $int) {
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $frac = $n - $int;  # inherit possible BigFloat
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int;       # BigFloat int() gives BigInt, use that
  }

  while ($#{$self->{'n_to_x'}} < $n) {
    _extend($self);
  }
  ### $self

  ### x: $self->{'n_to_x'}->[$n]
  ### y: $self->{'n_to_y'}->[$n]
  return ($self->{'n_to_x'}->[$n],
          $self->{'n_to_y'}->[$n]);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### ToothpickTree xy_to_n(): "$x, $y"

  $x = round_nearest ($x);
  $y = round_nearest ($y);

  my ($len,$level) = round_down_pow (max(abs($x), abs($y)-1),
                                     2);
  $len *= 4;
  if (is_infinite($len)) {
    return ($len);
  }
  while ($self->{'level'} <= $len) {
    _extend($self);
  }
  return $self->{'xy_to_n'}->{"$x,$y"};
}

# T(level) = 4 * T(level-1) + 2
# T(level) = 2 * (4^level - 1) / 3
# total = T(level) + 2
# N = (4^level - 1)*2/3
# 4^level - 1 = 3*N/2
# 4^level = 3*N/2 + 1
#
# len=2^level
# total = (len*len-1)*2/3 + 2

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### ToothpickTree rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = round_nearest ($x1);
  $y1 = round_nearest ($y1);
  $x2 = round_nearest ($x2);
  $y2 = round_nearest ($y2);

  my ($len,$level) = round_down_pow (max(abs($x1),  abs($x2),
                                         abs($y1)-1,abs($y2)-1),
                                     2);
  ### $level
  ### $len
  if (is_infinite($level)) {
    return (0,$level);
  }

  $len *= 4;
  return (0, ($len*$len-1)*2/3+2);
}

# ENHANCE-ME: calculate by the bits of n, not by X,Y
sub tree_n_children {
  my ($self, $n) = @_;
  ### tree_n_children(): $n

  my ($x,$y) = $self->n_to_xy($n)
    or return; # before n_start(), no children

  my ($n1,$n2);
  if (($x + $y) % 2) {
    # odd, horizontal to children
    $n1 = $self->xy_to_n($x-1,$y);
    $n2 = $self->xy_to_n($x+1,$y);
  } else  {
    # even, vertical to children
    $n1 = $self->xy_to_n($x,$y-1);
    $n2 = $self->xy_to_n($x,$y+1);
  }
  ### $n1
  ### $n2
  if (($n1||0) > ($n2||0)) {
    ($n1,$n2) = ($n2,$n1); # sorted
  }
  return ((defined $n1 && $n1 > $n ? $n1 : ()),
          (defined $n2 && $n2 > $n ? $n2 : ()));
}
sub tree_n_parent {
  my ($self, $n) = @_;
  $n = int($n);
  if ($n < 1) {
    return undef;
  }
  my ($x,$y) = $self->n_to_xy($n)
    or return undef;
  if (($x + $y) % 2) {
    # horizontal to parent
    return min ($self->xy_to_n($x-1,$y) || $n,
                $self->xy_to_n($x+1,$y) || $n);
  } else {
    # vertical to parent
    return min ($self->xy_to_n($x,$y-1) || $n,
                $self->xy_to_n($x,$y+1) || $n);
  }
}

sub tree_n_to_depth {
  my ($self, $n) = @_;
  ### tree_n_to_depth(): "$n"

  if ($n < 0) {
    return undef;
  }
  $n = int($n);
  if ($n < 1) {
    ### initial point ...
    return 0;
  }

  my $parts = $self->{'parts'};
  my $depth_offset;
  if ($parts == 1) {
    $depth_offset = 2;

  } elsif ($parts == 2) {
    $n -= 1;
    $depth_offset = 1;

  } else {
    $n -= 1;
    if ($n < 2) {
      return 1;
    }
    $n -= 2;
    $depth_offset = 0;
  }

  if (is_infinite($n)) {
    return $n;
  }
  my ($depth) = _n0_to_depth_and_rem($n, $self->{'parts'});
  ### n0 depth: $depth
  return $depth - $depth_offset;
}

# 2    0  +1   A
# 3    1  +1   B only

# 4    2  +1   A
# 5    3  +2   B+1 = B+add(2)
# 6    5  +3       = add(3) + 2*add(2)
# 7    8  +2   last 2

# 8   10  +1   A
# 9   11  +2   B+1      add(2) + 2*add(1) = 1+2*0 = 1 needs extra +1
# 10  13  +3         add(3) + 2*add(2) = 3
# 11  16  +3
# 12  19  +4
# 13  23  +7         add(6) + 2*add(5) = 3+2*2 = 7
# 14  30  +8         add(7) + 2*add(6) = 3+2*2 = 7
# 15  38  +4                  2*add(7) = 2*2 = 4
# 16  42  +1   A
# 17  43  +2   B+1
# 18  45
# 19  48
# 20  51

sub _n0_to_depth_and_rem {
  my ($n, $parts) = @_;
  ### _n0_to_depth_and_rem(): "$n   parts=$parts"

  # if ($parts == 2) {
  #   if ($n < 1) {
  #     return (1, $n, \@added);
  #   }
  #   $n -= 1;
  # } elsif ($parts >= 3) {
  #   if ($n < 1) {
  #     return (0, $n, \@added);
  #   }
  #   $n -= 1;
  #   if ($n < 3) {
  #     return (1, $n, \@added);
  #   }
  #   $n -= 1;
  # }

  my $zero = $n*0;
  $parts += $zero;
  my @added = ('x',       # 0
               'x',       # 1
               $parts,    # 2     A
               $parts);   # 3     B only

  if ($n < $parts) {
    ### first point ...
    return (2, $n, \@added);
  }
  $n -= $parts;

  if ($n < $parts) {
    ### second point ...
    return (3, $n, \@added);
  }
  $n -= $parts;

  for (my $dbase = 4; ; $dbase *= 2) {
    ### at: "n=$n  dbase=$dbase addedlen=".scalar(@added)

    push @added, $parts;     # A
    if ($n < $parts) {
      ### stop at A, added: join(',',@added)
      return ($dbase, $n, \@added);
    }
    $n -= $parts;
    {
      my $add = 2*$parts;
      push @added, $add;     # B+1
      if ($n < $add) {
        return ($dbase+1, $n, \@added);
      }
      $n -= $add;
    }

    for my $i (2 .. $dbase-2) {
      my $add = $added[$i+1] + 2*$added[$i];
      push @added, $add;
      if ($n < $add) {
        return ($dbase+$i, $n, \@added);
      }
      $n -= $add;
    }

    {
      my $add = 2*$added[$dbase-1];
      push @added, $add;     # last of up,diag, no lower
      if ($n < $add) {
        return (2*$dbase-1, $n, \@added);
      }
      $n -= $add;
    }

    ### assert: scalar(@added) == 2*$dbase
  }
}


# T(2^k+rem) = T(2^k) + T(rem) + 2T(rem-1)   rem>=1
#          
sub tree_depth_to_n {
  my ($self, $depth) = @_;
  ### tree_depth_to_n(): $depth

  if ($depth < 0) {
    return undef;
  }
  $depth = int($depth);
  if ($depth < 2) {
    return $depth;  # 0 or 1, for any $parts
  }

  my $parts = $self->{'parts'};
  if ($parts == 1) {
    $depth += 2;
  } elsif ($parts == 2) {
    $depth += 1;
  }

  my ($pow,$exp) = round_down_pow ($depth, 2);
  if (is_infinite($exp)) {
    return $exp;
  }
  ### $pow
  ### $exp

  my $zero = $depth*0;
  my $n = $zero;
  my @powtotal = (1);
  {
    my $t = 2 + $zero;
    push @powtotal, $t;
    foreach (1 .. $exp) {
      $t = 4*$t + 2;
      push @powtotal, $t;
    }
    ### @powtotal
  }

  if ($depth < 1) {
    return $zero;
  }

  my @pending = ($depth);
  my @mult = (1 + $zero);

  while (--$exp >= 0) {
    last unless @pending;

    ### @pending
    ### @mult
    ### $exp
    ### $pow
    ### powtotal: $powtotal[$exp]

    my @new_pending;
    my @new_mult;

    # if (join(',',@pending) ne join(',',reverse sort {$a<=>$b} @pending)) {
    #   print " ",join(',',@pending),"\n";
    # }

    foreach my $depth (@pending) {
      my $mult = shift @mult;
      ### assert: $depth >= 2

      if ($depth == 2) {
        next;
      }
      if ($depth == 3) {
        $n += $mult;
        next;
      }

      if ($depth < $pow) {
        push @new_pending, $depth;
        push @new_mult, $mult;
        next;

        # Cannot stop here as @pending isn't necessarily sorted into
        # descending order.
        # @pending = (@new_pending, $depth, @pending);
        # @mult = (@new_mult, $mult, @mult);
        # $pow /= 2;
        # print "$pow   ",join(',',@pending),"\n";
        # next OUTER;
      }

      my $rem = $depth - $pow;

      ### $depth
      ### $mult
      ### $rem

      if ($rem >= $pow) {
        ### twice pow: $powtotal[$exp+1]
        $n += $powtotal[$exp+1] * $mult;
        next;
      }
      ### assert: $rem >= 0 && $rem < $pow

      $n += $mult * $powtotal[$exp];

      if ($rem == 0) {
        ### rem==0, so just the powtotal ...
        next;
      }

      if ($rem == 1) {
        ### rem==1 A of each part ...
        $n += $mult;

        # } elsif ($rem < 3) {
        #   ### rem==2 A+B+1 of each part ...
        #   $n += 3 * $mult;

      } else {
        # T(pow+rem) = T(pow) + T(rem) + 2T(rem-1) + 2
        $rem += 1;
        $n += 2*$mult;


        if (@new_pending && $new_pending[-1] == $rem) {
          # print "rem=$rem ",join(',',@new_pending),"\n";
          $new_mult[-1] += $mult;
        } else {
          push @new_pending, $rem;
          push @new_mult, $mult;
        }
        if ($rem -= 1) {
          push @new_pending, $rem;
          push @new_mult, 2*$mult;
        }
      }
    }
    @pending = @new_pending;
    @mult = @new_mult;
    $pow /= 2;
  }

  ### return: $n
  return $n * $parts + $parts-1;

  # $parts_depth_offset[$parts];
  # my @parts_depth_offset = (undef, 0, 1, 2, 3);
}


# sub _UNTESTED__n_to_xy {
#   my ($n) = @_;
# 
#   my $zero = $n*0;
#   my @added = ($zero, 1+$zero, 2+$zero, 4+$zero);
# 
#   for (my $len = 4; $len <= 16; $len *= 2) {
#     ### at: "n=$n len=$len"
#     push @added, $len;
#     if ($n < $len) {
#       return ($len, $n);
#     }
#     $n -= $len;
# 
#     for my $i (1 .. $len-1) {
#       my $add = $added[$i+1] + 2*$added[$i];
#       push @added, $add;
#       if ($n < $add) {
#         return ($len+$i, $n);
#       }
#       $n -= $add;
#     }
#   }
# }

1;
__END__


# no good
# cumulative total a(2^k) = (2^(2n+1) + 1)/3 = 3,11,43,171
# N = (2^(2n+1) + 1)/3
# 3N = 2^(2n+1) + 1
# 2^(2n+1) = 3N - 1
# 2^(2n+2) = 6N-2
# len = 4^(n+1) = 6N-2
# cumul = (len/2 + 1)/3
#       = (len+2)/6
# my ($len,$level) = round_down_pow(6*$n-8);
# my @depth_bits;
# while ($level-- >= 0) {
#   my $cumul = ($len+2)/6;
#
#   if ($n >= $cumul) {
#     $n -= $cumul;
#     _divrem_mutate($n,4);
#     my $cumul = ($len/4+2)/6;
#     $n += $cumul;
#     push @depth_bits, 1;
#   } else {
#     push @depth_bits, 0;
#   }
#   $len /= 4;
# }


=for stopwords eg Ryde Math-PlanePath Nstart Nend

=head1 NAME

Math::PlanePath::ToothpickTree -- toothpick sequence

=head1 SYNOPSIS

 use Math::PlanePath::ToothpickTree;
 my $path = Math::PlanePath::ToothpickTree->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress ...>

X<Applegate, David>X<Pol, Omar E.>X<Sloane, Neil>This is the "toothpick"
sequence expanding through the plane by non-overlapping line segments, as
per

    David Applegate, Omar E. Pol, N. J. A. Sloane
    "The Toothpick Sequence and Other Sequences from Cellular Automata",
    Congressus Numerantium, Vol. 206 (2010), 157-191
    http://www.research.att.com/~njas/doc/tooth.pdf

Points are numbered by growth levels and anti-clockwise around within the
level.

=cut

# math-image --path=ToothpickTree --output=numbers --all --size=65x11

=pod

    --49--                          --48--           5
       |                               |
      44--38--  --37--  --36--  --35--43             4
       |   |       |       |       |   |
    --50- 27--17--26      25--16--24 -47--           3
           |   |               |   |
              12---8--  ---7--11                     2
           |   |   |       |   |   |
          28--18-  4---1---3 -15--23                 1
           |       |   |   |       |
                       0                        <- Y=0
           |       |   |   |       |
          29--19-  5---2---6 -22--34                -1
           |   |   |       |   |   |
              13---9--  --10--14                    -2
           |   |               |   |
    --51- 30--20--31      32--21--33 -54--          -3
       |   |       |       |       |   |
      45--39--  --40--  --41--  --42--46            -4
       |                               |
    --52--                          --53--          -5
                       ^
      -4   -3 -2  -1  X=0  1   2   3   4

Each X,Y point is the centre of a toothpick.  The toothpick is vertical on
"even" points X+Y==0 mod 2, or horizontal on "odd" points X+Y==1 mod 2.

                                                   ---8--- ---7---
                                  |       |           |       |
                ---1---           4---1---3           4---1---3
    |              |              |   |   |           |   |   |
    0      ->      0       ->         0        ->         0      
    |              |              |   |   |           |   |   |
                ---2---           5---2---6           5---2---6
                                  |       |           |       |
                                                   ---9--- --10---

The start is N=1 and points N=2 and N=3 are added to the two ends of that
toothpick.  Then points N=4,5,6,7 are added at those four ends.

For points N=4,5,6,7 a new toothpick is only added at each far ends, not the
"inner" positions X=1,Y=0 and X=-1,Y=0.  This is because those points are
the ends of two toothpicks and if they grew they would overlap.  X=1,Y=0 is
the end of toothpicks N=4 and N=7, and X=-1,Y=0 the ends of N=5,N=6.  The
rule is that when two ends meet like that nothing is added at that point.
The end of a toothpick is allowed to touch an existing toothpick.  The first
time this happens is N=16.  Its left end touches N=4.

N=2,4,8,12,17,25,36,44,49 etc on the stair-step diagonal X=Y and X=Y-1
extends indefinitely.  The quarters to either side of the diagonals are
filled in a self-similar fashion.  See
L<Math::PlanePath::ToothpickReplicate> for a digit-based replication.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for behaviour common to all path classes.

=over 4

=item C<$path = Math::PlanePath::ToothpickTree-E<gt>new ()>

=item C<$path = Math::PlanePath::ToothpickTree-E<gt>new (parts =E<gt> $integer)>

Create and return a new path object.

=back

=head2 Tree Methods

=over

=item C<@n_children = $path-E<gt>tree_n_children($n)>

Return the children of C<$n>, or an empty list if C<$n> has no children
(including when C<$n E<lt> 0>, ie. before the start of the path).

The children are the new toothpicks added at the ends of C<$n> in the next
level.  There can be 0, 1 or 2 points.  For example N=8 has a single child
12, or N=24 has no children, or N=2 has two children 4,5.  The way points
are numbered means when there's two children they're consecutive N values.

=item C<$n_parent = $path-E<gt>tree_n_parent($n)>

Return the parent node of C<$n>, or C<undef> if C<$n E<lt>= 0> (the start of
the path).

=back

=head1 OEIS

This cellular automaton is in Sloane's Online Encyclopedia of Integer
Sequences as

    http://oeis.org/A139250    (etc)

    parts=4
      A139250   total cells at given depth
      A139251   added cells at given depth

    parts=3
      A153006   total cells at given depth
      A152980   added cells at given depth

    parts=2
      A152998   total cells at given depth
      A152968   added cells at given depth

    parts=1
      A153000   total cells at given depth
      A152978   added cells at given depth

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::UlamWarburton>

Drawings by Omar Pol

    parts=4
    http://www.polprimos.com/imagenespub/poltp4d4.jpg
    http://www.polprimos.com/imagenespub/poltp283.jpg

    parts=3
    http://www.polprimos.com/imagenespub/poltp028.jpg

    parts=1
    http://www.polprimos.com/imagenespub/poltp016.jpg

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Copyright 2012 Kevin Ryde

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
