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

use strict;
use warnings;


use Math::PlanePath;

# uncomment this to run the ### lines
use Smart::Comments;

{
  package Math::PlanePath;
  use constant n_start => 1;
  no warnings 'redefine';
  sub new {
    my $class = shift;
    my $self = bless { @_ }, $class;
    $self->rewind;
    return $self;
  }
  sub rewind {
    my ($self) = @_;
    $self->seek_to_n($self->n_start);
  }
  sub seek_to_n {
    my ($self, $n) = @_;
    $self->{'n'} = $n;
  }
  sub next {
    my ($self) = @_;
    my $n = $self->{'n'}++;
    return ($n, $self->n_to_xy($n));
  }
  sub peek {
    my ($self) = @_;
    my ($n,$x,$y) = $self->next;
    $self->seek_to_n($n);
    return ($n,$x,$y);
  }
}
{
  use Math::PlanePath::Rows;
  package Math::PlanePath::Rows;
  sub seek_to_n {
    my ($self, $n) = @_;
    $self->{'n'} = --$n;
    my $width = $self->{'width'};
    $self->{'px'} = ($n % $width) - 1;
    $self->{'py'} = int ($n / $width);
    ### seek_to_n: $self
  }
  sub next {
    my ($self) = @_;
    my $x = ++$self->{'px'};
    if ($x >= $self->{'width'}) {
      $x = $self->{'px'} = 0;
      $self->{'py'}++;
    }
    return (++$self->{'n'}, $x, $self->{'py'});
  }
  sub peek {
    my ($self) = @_;
    if ((my $x = $self->{'px'} + 1) < $self->{'width'}) {
      return ($self->{'n'}+1, $x, $self->{'py'});
    } else {
      return ($self->{'n'}+1, 0, $self->{'py'}+1);
    }
  }
}
{
  use Math::PlanePath::Diagonals;
  package Math::PlanePath::Diagonals;
  # N = (1/2 d^2 + 1/2 d + 1)
  #   = (1/2*$d**2 + 1/2*$d + 1)
  #   = ((0.5*$d + 0.5)*$d + 1)
  # d = -1/2 + sqrt(2 * $n + -7/4)
  sub seek_to_n {
    my ($self, $n) = @_;
    $self->{'n'} = $n;
    my $d = $self->{'d'} = int (-.5 + sqrt(2*$n - 1.75));
    $n -= $d*($d+1)/2 + 1;
    $self->{'px'} = $n - 1;
    $self->{'py'} = $d - $n + 1;
    ### Diagonals seek_to_n(): $self
  }
  sub next {
    my ($self) = @_;
    my $x = ++$self->{'px'};
    my $y = --$self->{'py'};
    if ($y < 0) {
      $x = $self->{'px'} = 0;
      $y = $self->{'py'} = ++$self->{'d'};
    }
    return ($self->{'n'}++, $x, $y);
  }
  sub peek {
    my ($self) = @_;
    if (my $y = $self->{'py'}) {
      return ($self->{'n'}, $self->{'px'}+1, $y-1);
    } else {
      return ($self->{'n'}, 0, $self->{'d'}+1);
    }
  }
}
{
  use Math::PlanePath::SquareSpiral;
  package Math::PlanePath::SquareSpiral;
  # N = (1/2 d^2 + 1/2 d + 1)
  #   = (1/2*$d**2 + 1/2*$d + 1)
  #   = ((0.5*$d + 0.5)*$d + 1)
  # d = -1/2 + sqrt(2 * $n + -7/4)
  sub seek_to_n {
    my ($self, $n) = @_;
    $self->{'n'} = $n;
    $self->{'side'} = 0;
    $self->{'grow'} = 1;
    $self->{'d'} = 1;
    $self->{'dx'} = 0;
    $self->{'dy'} = -1;
    $self->{'x'} = -1;
    $self->{'y'} = 0;
    ### Diagonals seek_to_n(): $self
  }
  sub next {
    my ($self) = @_;
    ### next(): $self
    unless ($self->{'side'}--) {
      ### turn grow: $self->{'grow'}
      $self->{'side'} = ($self->{'d'} += ($self->{'grow'} ^= 1));
      ($self->{'dx'},$self->{'dy'}) = (-$self->{'dy'},$self->{'dx'});
      ### side now: $self->{'side'}
      ### dx,dy now: "$self->{'dx'},$self->{'dy'}"
      ### grow now: $self->{'grow'}
    }
    ### return: 'n='.$self->{'n'}.' '.($self->{'x'} + $self->{'dx'}).','.($self->{'y'} + $self->{'dy'})
    return ($self->{'n'}++,
            ($self->{'x'} += $self->{'dx'}),
            ($self->{'y'} += $self->{'dy'}));
  }
  sub peek {
    my ($self) = @_;
    # ### peek(): $self
    my $dx = $self->{'dx'};
    my $dy = $self->{'dy'};
    unless ($self->{'side'}) {
      # ### turn
      ($dx,$dy) = (-$dy,$dx);
    }
    return ($self->{'n'},
            $self->{'x'} + $dx,
            $self->{'y'} + $dy);
  }
}

foreach my $class ('Math::PlanePath::SquareSpiral',
                   # 'Math::PlanePath::Diagonals',
                   # 'Math::PlanePath::Rows',
                  ) {
  my $path = $class->new (width => 5);
  foreach my $n_start_offset (0 .. 0) {
    my $want_n = $path->n_start;
    if ($n_start_offset) {
      $want_n += $n_start_offset;
      $path->seek_to_n ($want_n);
    }
    ### $class
    ### $n_start_offset
    foreach my $i (0 .. 100) {
      my ($peek_n, $peek_x, $peek_y) = $path->peek;
      my ($got_n, $got_x, $got_y) = $path->next;
      my ($want_x, $want_y) = $path->n_to_xy($want_n);

      if ($want_n != $got_n) {
        ### $want_n
        ### $got_n
        die "x";
      }
      if ($want_x != $got_x) {
        ### $want_n
        ### $want_x
        ### $got_x
        die "x";
      }
      if ($want_y != $got_y) {
        ### $want_n
        ### $want_y
        ### $got_y
        die "x";
      }

      if ($peek_n != $want_n) {
        ### $peek_n
        ### $want_n
        die "x";
      }
      if ($peek_x != $want_x) {
        ### $want_n
        ### $peek_x
        ### $want_x
        die "x";
      }
      if ($peek_y != $want_y) {
        ### $want_n
        ### $peek_y
        ### $want_y
        die "x";
      }

      $want_n++;
    }
  }
}
