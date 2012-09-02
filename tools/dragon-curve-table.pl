#!/usr/bin/perl -w

# Copyright 2012 Kevin Ryde

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


# Usage: perl dragon-curve-table.pl
#
# Not working.
# Need coord=2 for long direction.


use 5.010;
use strict;
use List::Util 'max';

# uncomment this to run the ### lines
use Smart::Comments;


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
my @state_to_xpos;
my @state_to_xneg;
my @state_to_ypos;
my @state_to_yneg;

sub make_state {
  my ($rot, $rev, $digit) = @_;
  return $digit + 4*($rot + 4*$rev);
}
sub state_string {
  my ($state) = @_;
  my $digit = $state & 1;  $state >>= 1;
  my $rev = $state & 1;  $state >>= 1;
  my $rot = $state & 3;  $state >>= 2;
  return "rot=$rot  rev=$rev (digit=$digit)";
}

foreach my $rot (0 .. 3) {
  foreach my $rev (0, 1) {
    my $state = make_state ($rot, $rev, 0);
    ### $state

    foreach my $orig_digit (0, 1, 2, 3) {
      my $digit = $orig_digit;

      my $new_rev = $digit & 1;
      my $new_rot = $rot;

      my $x;
      my $y;
      if ($rev) {
        #
        #  *--3
        #     |
        #  1--2
        #  |
        #  0
        #
        #  0<--1   *
        #      |   ^
        #      v   |
        #      2<--3
        #
        if ($digit == 0) {
          $x = 0;
          $y = 0;
          $new_rev = 1;
        } elsif ($digit == 1) {
          $x = 1;
          $y = 0;
          $new_rev = 0;
          $new_rot--;
        } elsif ($digit == 2) {
          $x = 1;
          $y = -1;
          $new_rev = 1;
        } elsif ($digit == 3) {
          $x = 2;
          $y = -1;
          $new_rev = 0;
          $new_rot++;
        }
      } else {
        #
        #  *
        #  |
        #  3--2
        #     |  
        #  0--1
        #
        #  0   3<--*
        #  |   ^
        #  v   |
        #  1<--2
        #
        if ($digit == 0) {
          $x = 0;
          $y = 0;
          $new_rev = 0;
          $new_rot--;
        } elsif ($digit == 1) {
          $x = 0;
          $y = -1;
          $new_rev = 1;
        } elsif ($digit == 2) {
          $x = 1;
          $y = -1;
          $new_rev = 0;
          $new_rot++;
        } elsif ($digit == 3) {
          $x = 1;
          $y = 0;
          $new_rev = 1;
        }
      }
      if ($rot & 2) {
        $x = -$x;
        $y = -$y;
      }
      if ($rot & 1) {
        ($x,$y) = (-$y,$x); # rotate +90
      }
      ### rot to: "$x, $y"

      my $next_dx = $x;
      my $next_dy = $y;

      $state_to_xpos[$state+$orig_digit] = ($x > 0 ? $x : 0);
      $state_to_xneg[$state+$orig_digit] = ($x < 0 ? -$x : 0);
      $state_to_ypos[$state+$orig_digit] = ($y > 0 ? $y : 0);
      $state_to_yneg[$state+$orig_digit] = ($y < 0 ? -$y : 0);

      my $next_state = make_state
        ($new_rot, $new_rev, 0);
      $next_state[$state+$orig_digit] = $next_state;
    }
  }
}


### @next_state
### next_state length: 4*(4*2*2 + 4*2)

print "# next_state length ", scalar(@next_state), "\n";
print_table ("next_state", \@next_state);
print_table ("state_to_xpos", \@state_to_xpos);
print_table ("state_to_xneg", \@state_to_xneg);
print_table ("state_to_ypos", \@state_to_ypos);
print_table ("state_to_yneg", \@state_to_yneg);
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

      foreach my $digit (0 .. 1) {
        my $next_state = $next_state[$state+$digit];
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


use Math::PlanePath::Base::Digits
  'digit_split_lowtohigh',
  'digit_join_lowtohigh';

foreach my $int (0 .. 8) {
  ### $int

  my @digits = digit_split_lowtohigh($int,4);
  ### @digits

  my $state = (scalar(@digits) & 3) << 2;
  ### initial state: $state

  my @xpos;
  my @xneg;
  my @ypos;
  my @yneg;
  foreach my $i (reverse 0 .. $#digits) {
    ### at: "i=$i digit=$digits[$i] state=$state"
    $state += $digits[$i];
    $xpos[$i] = $state_to_xpos[$state];
    $xneg[$i] = $state_to_xneg[$state];
    $ypos[$i] = $state_to_ypos[$state];
    $yneg[$i] = $state_to_yneg[$state];
    $state = $next_state[$state];
  }

  ### @xpos
  ### @xneg
  ### @ypos
  ### @yneg
  my $x = (digit_join_lowtohigh(\@xpos,2)
           - digit_join_lowtohigh(\@xneg,2));
  my $y = (digit_join_lowtohigh(\@ypos,2)
           - digit_join_lowtohigh(\@yneg,2));
  print "$int  $x $y\n";
}

exit 0;

__END__
