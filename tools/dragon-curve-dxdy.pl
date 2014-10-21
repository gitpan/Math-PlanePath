#!/usr/bin/perl -w

# Copyright 2011, 2012 Kevin Ryde

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


# Usage: perl dragon-curve-dxdy.pl
#
# Print the state tables used for DragonCurve n_to_dxdy().  These are not
# the same as the tables for n_to_xy() which are in dragon-curve-table.pl.

use 5.010;
use strict;
use List::Util 'max';

# uncomment this to run the ### lines
#use Smart::Comments;


sub print_table {
  my ($name, $aref) = @_;
  print "my \@$name = (";
  my $entry_width = max (map {length($_//'')} @$aref);

  foreach my $i (0 .. $#$aref) {
    printf "%*s", $entry_width, $aref->[$i]//'undef';
    if ($i == $#$aref) {
      print ");\n";
    } else {
      print ",";
      if (($i % 16) == 15
          || ($entry_width >= 3 && ($i % 4) == 3)) {
        print "\n        ".(" " x length($name));
      } elsif (($i % 4) == 3) {
        print " ";
      }
    }
  }
}

  my @next_state;
my @state_to_dxdy;

sub make_state {
  my %param = @_;
  my $state = 0;
  $state <<= 1; $state |= delete $param{'nextturn'};   # high
  $state <<= 2; $state |= delete $param{'rot'};
  $state <<= 1; $state |= delete $param{'prevbit'};
  $state <<= 1; $state |= delete $param{'digit'};      # low
  if (%param) { die; }
  return $state;
}
sub state_string {
  my ($state) = @_;
  my $digit = $state & 1;  $state >>= 1;
  my $prevbit = $state & 1;  $state >>= 1;
  my $rot = $state & 3;  $state >>= 2;
  my $nextturn = $state & 1;  $state >>= 1;
  return "rot=$rot  prevbit=$prevbit (digit=$digit)";
}

foreach my $nextturn (0, 1) {
  foreach my $rot (0, 1, 2, 3) {
    foreach my $prevbit (0, 1) {
      my $state = make_state (nextturn => $nextturn,
                              rot      => $rot,
                              prevbit  => $prevbit,
                              digit    => 0);
      ### $state

      foreach my $orig_bit (0, 1) {
        my $bit = $orig_bit;

        my $new_nextturn = $nextturn;
        my $new_prevbit = $bit;
        my $new_rot = $rot;

        if ($bit != $prevbit) {   # count 0<->1 transitions
          $new_rot++;
          $new_rot &= 3;
        }
        if ($bit == 0) {
          $new_nextturn = $prevbit;  # bit above lowest 0
        }

        my $dx = 1;
        my $dy = 0;
        if ($rot & 2) {
          $dx = -$dx;
          $dy = -$dy;
        }
        if ($rot & 1) {
          ($dx,$dy) = (-$dy,$dx); # rotate +90
        }
        ### rot to: "$dx, $dy"

        my $next_dx = $dx;
        my $next_dy = $dy;
        if ($nextturn) {
          ($next_dx,$next_dy) = ($next_dy,-$next_dx); # right, rotate -90
        } else {
          ($next_dx,$next_dy) = (-$next_dy,$next_dx); # left, rotate +90
        }
        my $frac_dx = $next_dx - $dx;
        my $frac_dy = $next_dy - $dy;

        my $masked_state = $state & 0x1C;
        $state_to_dxdy[$masked_state]     = $dx;
        $state_to_dxdy[$masked_state + 1] = $dy;
        $state_to_dxdy[$masked_state + 2] = $frac_dx;
        $state_to_dxdy[$masked_state + 3] = $frac_dy;

        my $next_state = make_state
          (nextturn => $new_nextturn,
           rot      => $new_rot,
           prevbit  => $new_prevbit,
           digit    => 0);
        $next_state[$state+$orig_bit] = $next_state;
      }
    }
  }
}


### @next_state
### @state_to_dxdy
### next_state length: 4*(4*2*2 + 4*2)

print "# next_state length ", scalar(@next_state), "\n";
print_table ("next_state", \@next_state);
print_table ("state_to_dxdy", \@state_to_dxdy);
print "\n";

{
  my @pending_state = (0, 4, 8, 12);  # in 4 arm directions
  my $count = 0;
  my @seen_state;
  my $depth = 1;
  foreach my $state (@pending_state) {
    $seen_state[$state] = $depth;
  }
  while (@pending_state) {
    my @new_pending_state;
    foreach my $state (@pending_state) {
      $count++;
      ### consider state: $state

      foreach my $bit (0 .. 1) {
        my $next_state = $next_state[$state+$bit];
        if (! $seen_state[$next_state]) {
          $seen_state[$next_state] = $depth;
          push @new_pending_state, $next_state;
          ### push: "$next_state  depth $depth"
        }
      }
      $depth++;
    }
    @pending_state = @new_pending_state;
  }
  for (my $state = 0; $state < @next_state; $state += 2) {
    $seen_state[$state] ||= '-';
    my $state_string = state_string($state);
    print "# used state $state   depth $seen_state[$state]  $state_string\n";
  }
  print "used state count $count\n";
}

exit 0;
