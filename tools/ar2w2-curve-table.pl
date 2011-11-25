#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

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

use 5.010;
use strict;
use List::Util 'max';

# uncomment this to run the ### lines
#use Smart::Comments;


sub print_table {
  my ($name, $aref) = @_;
  print "my \@$name\n  = (";
  my $entry_width = max (map {defined $_ ? length : 0} @$aref);

  foreach my $i (0 .. $#$aref) {
    printf "%*s", $entry_width, $aref->[$i]//'undef';
    if ($i == $#$aref) {
      print ");\n";
    } else {
      print ",";
      if (($i % 16) == 15) {
        print "\n     ";
      } elsif (($i % 4) == 3) {
        print " ";
      }
    }
  }
}

  sub make_state {
    my ($part, $rev, $rot) = @_;

    $rev %= 2;
    $rot %= 4;
    return 4*($rot + 4*($rev + 2*$part));
  }

  use constant A1 => 0;
  use constant A2 => 1;
  use constant B1 => 2;
  use constant B2 => 3;
  use constant C1 => 4;
  use constant C2 => 5;
  use constant D1 => 6;
  use constant D2 => 7;

  sub dxdy_to_dir {
    my ($dx,$dy) = @_;
    if ($dx == 1) { return 0; }
    if ($dy == 1) { return 1; }
    if ($dx == -1) { return 2; }
    if ($dy == -1) { return 3; }
    warn "Unrecognised dxdy: $dx, $dy";
    return undef;
  }

  my @next_state;
  my @digit_to_x;
  my @digit_to_y;
  my @xy_to_digit;
  my @digit_to_dir;

  foreach my $part (A1, A2, B1, B2, C1, C2, D1, D2) {
    foreach my $rev (0, 1) {
      foreach my $rot (0, 1, 2, 3) {
        my $state = make_state ($part, $rev, $rot);

        foreach my $orig_digit (0, 1, 2, 3) {
          my $digit = $orig_digit;

          if ($rev) {
            $digit = 3-$digit;
          }

          my $xo = 0;
          my $yo = 0;
          my $new_rot = $rot;
          my $new_part = $part;
          my $new_rev = $rev;

          if ($part == A1) {
            if ($digit == 0) {
              $new_part = D2;
            } elsif ($digit == 1) {
              $xo = 1;
              $new_part = B1;
              $new_rot = $rot + 1;
              $new_rev ^= 1;
            } elsif ($digit == 2) {
              $yo = 1;
              $new_rot = $rot + 1;
              $new_part = C1;
            } elsif ($digit == 3) {
              $xo = 1;
              $yo = 1;
              $new_part = B2;
              $new_rot = $rot + 2;
              $new_rev ^= 1;
            }

          } elsif ($part == A2) {
            if ($digit == 0) {
              $new_part = B1;
              $new_rot = $rot - 1;
            } elsif ($digit == 1) {
              $yo = 1;
              $new_part = C2;
              $new_rot = $rot + 1;
            } elsif ($digit == 2) {
              $xo = 1;
              $new_rot = $rot + 2;
              $new_part = B2;
            } elsif ($digit == 3) {
              $xo = 1;
              $yo = 1;
              $new_part = D1;
              $new_rot = $rot + 1;
            }

          } elsif ($part == B1) {
            if ($digit == 0) {
              $new_part = D1;
              $new_rot = $rot - 1;
              $new_rev ^= 1;
            } elsif ($digit == 1) {
              $yo = 1;
              $new_part = C2;
            } elsif ($digit == 2) {
              $xo = 1;
              $yo = 1;
              $new_part = B1;
            } elsif ($digit == 3) {
              $xo = 1;
              $new_part = B2;
              $new_rot = $rot + 1;
            }

          } elsif ($part == B2) {
            if ($digit == 0) {
              $new_part = B1;
              $new_rot = $rot - 1;
              $new_rev ^= 1;
            } elsif ($digit == 1) {
              $yo = 1;
              $new_part = B2;
            } elsif ($digit == 2) {
              $xo = 1;
              $yo = 1;
              $new_part = C1;
            } elsif ($digit == 3) {
              $xo = 1;
              $new_part = D2;
              $new_rot = $rot + 1;
              $new_rev ^= 1;
            }

          } elsif ($part == C1) {
            if ($digit == 0) {
              $new_part = A2;
              $new_rot = $rot + 2;
              $new_rev ^= 1;
            } elsif ($digit == 1) {
              $yo = 1;
              $new_part = B1;
              $new_rot = $rot + 1;
            } elsif ($digit == 2) {
              $xo = 1;
              $yo = 1;
              $new_rot = $rot - 1;
              $new_part = A1;
            } elsif ($digit == 3) {
              $xo = 1;
              $new_part = B2;
              $new_rot = $rot - 1;
              $new_rev ^= 1;
            }

          } elsif ($part == C2) {
            if ($digit == 0) {
              $new_part = B1;
              $new_rot = $rot + 1;
              $new_rev ^= 1;
            } elsif ($digit == 1) {
              $yo = 1;
              $new_part = A2;
            } elsif ($digit == 2) {
              $xo = 1;
              $yo = 1;
              $new_rot = $rot - 1;
              $new_part = B2;
            } elsif ($digit == 3) {
              $xo = 1;
              $new_part = A1;
              $new_rot = $rot - 1;
            }

          } elsif ($part == D1) {
            if ($digit == 0) {
              $new_part = D1;
              $new_rot = $rot - 1;
              $new_rev ^= 1;
            } elsif ($digit == 1) {
              $yo = 1;
              $new_part = A2;
            } elsif ($digit == 2) {
              $xo = 1;
              $yo = 1;
              $new_rot = $rot - 1;
              $new_part = C2;
            } elsif ($digit == 3) {
              $xo = 1;
              $new_part = A2;
              $new_rot = $rot - 1;
            }

          } elsif ($part == D2) {
            if ($digit == 0) {
              $new_part = A1;
            } elsif ($digit == 1) {
              $yo = 1;
              $new_part = C1;
              $new_rot = $rot + 1;
            } elsif ($digit == 2) {
              $xo = 1;
              $yo = 1;
              $new_rot = $rot - 1;
              $new_part = A1;
            } elsif ($digit == 3) {
              $xo = 1;
              $new_part = D2;
              $new_rot = $rot - 1;
              $new_rev ^= 1;
            }

          } else {
            die;
          }

          ### base: "$xo, $yo"

          if ($rot & 2) {
            $xo ^= 1;
            $yo ^= 1;
          }
          if ($rot & 1) {
            ($xo,$yo) = ($yo^1,$xo);
          }
          ### rot to: "$xo, $yo"

          $digit_to_x[$state+$orig_digit] = $xo;
          $digit_to_y[$state+$orig_digit] = $yo;
          $xy_to_digit[$state + $xo*2+$yo] = $orig_digit;

          my $next_state = make_state
            ($new_part, $new_rev, $new_rot);
          $next_state[$state+$orig_digit] = $next_state;
        }

        foreach my $digit (0, 1, 2) {
          my $this_digit = $digit;
          my $next_digit = $digit + 1;
          if ($rev) {
            ($this_digit,$next_digit) = ($next_digit,$this_digit);
          }
          my $dx = $digit_to_x[$state+$next_digit]
            - $digit_to_x[$state+$this_digit];
          my $dy = $digit_to_y[$state+$next_digit]
            - $digit_to_y[$state+$this_digit];
          my $dir = dxdy_to_dir($dx,$dy);
          $digit_to_dir[$state+$digit+$rev] = $dir;
        }
      }
    }
  }

  ### @next_state
  ### @digit_to_x
  ### @digit_to_y
  ### next_state length: 4*(4*2*2 + 4*2)
  ### next_state length: scalar(@next_state)

  print_table ("next_state", \@next_state);
  print_table ("digit_to_x", \@digit_to_x);
  print_table ("digit_to_y", \@digit_to_y);
  print_table ("digit_to_dir", \@digit_to_dir);
  print_table ("xy_to_digit", \@xy_to_digit);

  my $invert_state = make_state (D2,  # part
                                 0,  # rev
                                 3,  # rot
                                 1); # transpose
  ### $invert_state

  print "\n";
  exit 0;
