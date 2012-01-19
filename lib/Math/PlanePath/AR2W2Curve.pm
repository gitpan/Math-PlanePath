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


# http://www.springerlink.com/content/y1l60g7125038668/  [pay]
#
# Google Books LATIN'95 link: page 44 definition
# http://books.google.com.au/books?id=_aKhJUJunYwC&lpg=PA44&ots=ARyDkP_hjU&dq=%22Space-Filling%20Curves%20and%20Their%20Use%20in%20the%20Design%20of%20Geometric%20Data%20Structures%22&pg=PA44#v=onepage&q&f=false
#

package Math::PlanePath::AR2W2Curve;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 65;
use Math::PlanePath 54; # v.54 for _max()
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;


use constant n_start => 0;
use constant class_x_negative => 0;
use constant class_y_negative => 0;

use constant parameter_info_array =>
  [
   {
    name      => 'start_shape',
    share_key => 'start_shape_ar2w2',
    type      => 'enum',
    default   => 'A1',
    choices   => ['A1','D2',
                  'B2','B1rev',
                  'D1rev','A2rev',
                 ],
   },
  ];


# tables generated by tools/ar2w2-curve-table.pl
#
my @next_state
  = (224, 92,132,120, 228, 80,136,124, 232, 84,140,112, 236, 88,128,116,
     104,148, 76,240, 108,152, 64,244,  96,156, 68,248, 100,144, 72,252,
     92,160,120,196,  80,164,124,200,  84,168,112,204,  88,172,116,192,
     212,104,176, 76, 216,108,180, 64, 220, 96,184, 68, 208,100,188, 72,
     220,160, 64,116, 208,164, 68,120, 212,168, 72,124, 216,172, 76,112,
     100, 80,176,204, 104, 84,180,192, 108, 88,184,196,  96, 92,188,200,
     92, 96,128,244,  80,100,132,248,  84,104,136,252,  88,108,140,240,
     228,144,112, 76, 232,148,116, 64, 236,152,120, 68, 224,156,124, 72,
     32, 68, 12,116,  36, 72,  0,120,  40, 76,  4,124,  44, 64,  8,112,
     100, 28, 84, 48, 104, 16, 88, 52, 108, 20, 92, 56,  96, 24, 80, 60,
     92, 32,108, 12,  80, 36, 96,  0,  84, 40,100,  4,  88, 44,104,  8,
     28,124, 48, 76,  16,112, 52, 64,  20,116, 56, 68,  24,120, 60, 72,
     220, 32,172, 44, 208, 36,160, 32, 212, 40,164, 36, 216, 44,168, 40,
     60,188, 48,204,  48,176, 52,192,  52,180, 56,196,  56,184, 60,200,
     0,132, 12,244,   4,136,  0,248,   8,140,  4,252,  12,128,  8,240,
     228, 28,148, 16, 232, 16,152, 20, 236, 20,156, 24, 224, 24,144, 28);
my @digit_to_x
  = (0,1,0,1, 1,1,0,0, 1,0,1,0, 0,0,1,1,
     1,0,1,0, 0,0,1,1, 0,1,0,1, 1,1,0,0,
     0,0,1,1, 1,0,1,0, 1,1,0,0, 0,1,0,1,
     1,1,0,0, 0,1,0,1, 0,0,1,1, 1,0,1,0,
     0,0,1,1, 1,0,0,1, 1,1,0,0, 0,1,1,0,
     1,1,0,0, 1,0,0,1, 0,0,1,1, 0,1,1,0,
     0,0,1,1, 1,0,0,1, 1,1,0,0, 0,1,1,0,
     1,1,0,0, 1,0,0,1, 0,0,1,1, 0,1,1,0,
     0,0,1,1, 1,0,0,1, 1,1,0,0, 0,1,1,0,
     1,1,0,0, 1,0,0,1, 0,0,1,1, 0,1,1,0,
     0,0,1,1, 1,0,0,1, 1,1,0,0, 0,1,1,0,
     1,1,0,0, 1,0,0,1, 0,0,1,1, 0,1,1,0,
     0,0,1,1, 1,0,0,1, 1,1,0,0, 0,1,1,0,
     1,1,0,0, 1,0,0,1, 0,0,1,1, 0,1,1,0,
     0,0,1,1, 1,0,0,1, 1,1,0,0, 0,1,1,0,
     1,1,0,0, 1,0,0,1, 0,0,1,1, 0,1,1,0);
my @digit_to_y
  = (0,0,1,1, 0,1,0,1, 1,1,0,0, 1,0,1,0,
     1,1,0,0, 1,0,1,0, 0,0,1,1, 0,1,0,1,
     0,1,0,1, 0,0,1,1, 1,0,1,0, 1,1,0,0,
     1,0,1,0, 1,1,0,0, 0,1,0,1, 0,0,1,1,
     0,1,1,0, 0,0,1,1, 1,0,0,1, 1,1,0,0,
     0,1,1,0, 1,1,0,0, 1,0,0,1, 0,0,1,1,
     0,1,1,0, 0,0,1,1, 1,0,0,1, 1,1,0,0,
     0,1,1,0, 1,1,0,0, 1,0,0,1, 0,0,1,1,
     0,1,1,0, 0,0,1,1, 1,0,0,1, 1,1,0,0,
     0,1,1,0, 1,1,0,0, 1,0,0,1, 0,0,1,1,
     0,1,1,0, 0,0,1,1, 1,0,0,1, 1,1,0,0,
     0,1,1,0, 1,1,0,0, 1,0,0,1, 0,0,1,1,
     0,1,1,0, 0,0,1,1, 1,0,0,1, 1,1,0,0,
     0,1,1,0, 1,1,0,0, 1,0,0,1, 0,0,1,1,
     0,1,1,0, 0,0,1,1, 1,0,0,1, 1,1,0,0,
     0,1,1,0, 1,1,0,0, 1,0,0,1, 0,0,1,1);
my @yx_to_digit
  = (0,1,2,3, 2,0,3,1, 3,2,1,0, 1,3,0,2,
     3,2,1,0, 1,3,0,2, 0,1,2,3, 2,0,3,1,
     0,2,1,3, 1,0,3,2, 3,1,2,0, 2,3,0,1,
     3,1,2,0, 2,3,0,1, 0,2,1,3, 1,0,3,2,
     0,3,1,2, 1,0,2,3, 2,1,3,0, 3,2,0,1,
     3,0,2,1, 2,3,1,0, 1,2,0,3, 0,1,3,2,
     0,3,1,2, 1,0,2,3, 2,1,3,0, 3,2,0,1,
     3,0,2,1, 2,3,1,0, 1,2,0,3, 0,1,3,2,
     0,3,1,2, 1,0,2,3, 2,1,3,0, 3,2,0,1,
     3,0,2,1, 2,3,1,0, 1,2,0,3, 0,1,3,2,
     0,3,1,2, 1,0,2,3, 2,1,3,0, 3,2,0,1,
     3,0,2,1, 2,3,1,0, 1,2,0,3, 0,1,3,2,
     0,3,1,2, 1,0,2,3, 2,1,3,0, 3,2,0,1,
     3,0,2,1, 2,3,1,0, 1,2,0,3, 0,1,3,2,
     0,3,1,2, 1,0,2,3, 2,1,3,0, 3,2,0,1,
     3,0,2,1, 2,3,1,0, 1,2,0,3, 0,1,3,2);
my @min_digit = (0,0,1, 0,0,1, 2,2,3, undef,undef,undef,   # 3* 0
                 2,0,0, 2,0,0, 3,1,1, undef,undef,undef,   # 3* 4
                 3,2,2, 1,0,0, 1,0,0, undef,undef,undef,   # 3* 8
                 1,1,3, 0,0,2, 0,0,2, undef,undef,undef,   # 3* 12
                 3,2,2, 1,0,0, 1,0,0, undef,undef,undef,   # 3* 16
                 1,1,3, 0,0,2, 0,0,2, undef,undef,undef,   # 3* 20
                 0,0,1, 0,0,1, 2,2,3, undef,undef,undef,   # 3* 24
                 2,0,0, 2,0,0, 3,1,1, undef,undef,undef,   # 3* 28
                 0,0,2, 0,0,2, 1,1,3, undef,undef,undef,   # 3* 32
                 1,0,0, 1,0,0, 3,2,2, undef,undef,undef,   # 3* 36
                 3,1,1, 2,0,0, 2,0,0, undef,undef,undef,   # 3* 40
                 2,2,3, 0,0,1, 0,0,1, undef,undef,undef,   # 3* 44
                 3,1,1, 2,0,0, 2,0,0, undef,undef,undef,   # 3* 48
                 2,2,3, 0,0,1, 0,0,1, undef,undef,undef,   # 3* 52
                 0,0,2, 0,0,2, 1,1,3, undef,undef,undef,   # 3* 56
                 1,0,0, 1,0,0, 3,2,2, undef,undef,undef,   # 3* 60
                 0,0,3, 0,0,2, 1,1,2, undef,undef,undef,   # 3* 64
                 1,0,0, 1,0,0, 2,2,3, undef,undef,undef,   # 3* 68
                 2,1,1, 2,0,0, 3,0,0, undef,undef,undef,   # 3* 72
                 3,2,2, 0,0,1, 0,0,1, undef,undef,undef,   # 3* 76
                 3,0,0, 2,0,0, 2,1,1, undef,undef,undef,   # 3* 80
                 2,2,3, 1,0,0, 1,0,0, undef,undef,undef,   # 3* 84
                 1,1,2, 0,0,2, 0,0,3, undef,undef,undef,   # 3* 88
                 0,0,1, 0,0,1, 3,2,2, undef,undef,undef,   # 3* 92
                 0,0,3, 0,0,2, 1,1,2, undef,undef,undef,   # 3* 96
                 1,0,0, 1,0,0, 2,2,3, undef,undef,undef,   # 3* 100
                 2,1,1, 2,0,0, 3,0,0, undef,undef,undef,   # 3* 104
                 3,2,2, 0,0,1, 0,0,1, undef,undef,undef,   # 3* 108
                 3,0,0, 2,0,0, 2,1,1, undef,undef,undef,   # 3* 112
                 2,2,3, 1,0,0, 1,0,0, undef,undef,undef,   # 3* 116
                 1,1,2, 0,0,2, 0,0,3, undef,undef,undef,   # 3* 120
                 0,0,1, 0,0,1, 3,2,2, undef,undef,undef,   # 3* 124
                 0,0,3, 0,0,2, 1,1,2, undef,undef,undef,   # 3* 128
                 1,0,0, 1,0,0, 2,2,3, undef,undef,undef,   # 3* 132
                 2,1,1, 2,0,0, 3,0,0, undef,undef,undef,   # 3* 136
                 3,2,2, 0,0,1, 0,0,1, undef,undef,undef,   # 3* 140
                 3,0,0, 2,0,0, 2,1,1, undef,undef,undef,   # 3* 144
                 2,2,3, 1,0,0, 1,0,0, undef,undef,undef,   # 3* 148
                 1,1,2, 0,0,2, 0,0,3, undef,undef,undef,   # 3* 152
                 0,0,1, 0,0,1, 3,2,2, undef,undef,undef,   # 3* 156
                 0,0,3, 0,0,2, 1,1,2, undef,undef,undef,   # 3* 160
                 1,0,0, 1,0,0, 2,2,3, undef,undef,undef,   # 3* 164
                 2,1,1, 2,0,0, 3,0,0, undef,undef,undef,   # 3* 168
                 3,2,2, 0,0,1, 0,0,1, undef,undef,undef,   # 3* 172
                 3,0,0, 2,0,0, 2,1,1, undef,undef,undef,   # 3* 176
                 2,2,3, 1,0,0, 1,0,0, undef,undef,undef,   # 3* 180
                 1,1,2, 0,0,2, 0,0,3, undef,undef,undef,   # 3* 184
                 0,0,1, 0,0,1, 3,2,2, undef,undef,undef,   # 3* 188
                 0,0,3, 0,0,2, 1,1,2, undef,undef,undef,   # 3* 192
                 1,0,0, 1,0,0, 2,2,3, undef,undef,undef,   # 3* 196
                 2,1,1, 2,0,0, 3,0,0, undef,undef,undef,   # 3* 200
                 3,2,2, 0,0,1, 0,0,1, undef,undef,undef,   # 3* 204
                 3,0,0, 2,0,0, 2,1,1, undef,undef,undef,   # 3* 208
                 2,2,3, 1,0,0, 1,0,0, undef,undef,undef,   # 3* 212
                 1,1,2, 0,0,2, 0,0,3, undef,undef,undef,   # 3* 216
                 0,0,1, 0,0,1, 3,2,2, undef,undef,undef,   # 3* 220
                 0,0,3, 0,0,2, 1,1,2, undef,undef,undef,   # 3* 224
                 1,0,0, 1,0,0, 2,2,3, undef,undef,undef,   # 3* 228
                 2,1,1, 2,0,0, 3,0,0, undef,undef,undef,   # 3* 232
                 3,2,2, 0,0,1, 0,0,1, undef,undef,undef,   # 3* 236
                 3,0,0, 2,0,0, 2,1,1, undef,undef,undef,   # 3* 240
                 2,2,3, 1,0,0, 1,0,0, undef,undef,undef,   # 3* 244
                 1,1,2, 0,0,2, 0,0,3, undef,undef,undef,   # 3* 248
                 0,0,1, 0,0,1, 3,2,2);
my @max_digit = (0,1,1, 2,3,3, 2,3,3, undef,undef,undef,   # 3* 0
                 2,2,0, 3,3,1, 3,3,1, undef,undef,undef,   # 3* 4
                 3,3,2, 3,3,2, 1,1,0, undef,undef,undef,   # 3* 8
                 1,3,3, 1,3,3, 0,2,2, undef,undef,undef,   # 3* 12
                 3,3,2, 3,3,2, 1,1,0, undef,undef,undef,   # 3* 16
                 1,3,3, 1,3,3, 0,2,2, undef,undef,undef,   # 3* 20
                 0,1,1, 2,3,3, 2,3,3, undef,undef,undef,   # 3* 24
                 2,2,0, 3,3,1, 3,3,1, undef,undef,undef,   # 3* 28
                 0,2,2, 1,3,3, 1,3,3, undef,undef,undef,   # 3* 32
                 1,1,0, 3,3,2, 3,3,2, undef,undef,undef,   # 3* 36
                 3,3,1, 3,3,1, 2,2,0, undef,undef,undef,   # 3* 40
                 2,3,3, 2,3,3, 0,1,1, undef,undef,undef,   # 3* 44
                 3,3,1, 3,3,1, 2,2,0, undef,undef,undef,   # 3* 48
                 2,3,3, 2,3,3, 0,1,1, undef,undef,undef,   # 3* 52
                 0,2,2, 1,3,3, 1,3,3, undef,undef,undef,   # 3* 56
                 1,1,0, 3,3,2, 3,3,2, undef,undef,undef,   # 3* 60
                 0,3,3, 1,3,3, 1,2,2, undef,undef,undef,   # 3* 64
                 1,1,0, 2,3,3, 2,3,3, undef,undef,undef,   # 3* 68
                 2,2,1, 3,3,1, 3,3,0, undef,undef,undef,   # 3* 72
                 3,3,2, 3,3,2, 0,1,1, undef,undef,undef,   # 3* 76
                 3,3,0, 3,3,1, 2,2,1, undef,undef,undef,   # 3* 80
                 2,3,3, 2,3,3, 1,1,0, undef,undef,undef,   # 3* 84
                 1,2,2, 1,3,3, 0,3,3, undef,undef,undef,   # 3* 88
                 0,1,1, 3,3,2, 3,3,2, undef,undef,undef,   # 3* 92
                 0,3,3, 1,3,3, 1,2,2, undef,undef,undef,   # 3* 96
                 1,1,0, 2,3,3, 2,3,3, undef,undef,undef,   # 3* 100
                 2,2,1, 3,3,1, 3,3,0, undef,undef,undef,   # 3* 104
                 3,3,2, 3,3,2, 0,1,1, undef,undef,undef,   # 3* 108
                 3,3,0, 3,3,1, 2,2,1, undef,undef,undef,   # 3* 112
                 2,3,3, 2,3,3, 1,1,0, undef,undef,undef,   # 3* 116
                 1,2,2, 1,3,3, 0,3,3, undef,undef,undef,   # 3* 120
                 0,1,1, 3,3,2, 3,3,2, undef,undef,undef,   # 3* 124
                 0,3,3, 1,3,3, 1,2,2, undef,undef,undef,   # 3* 128
                 1,1,0, 2,3,3, 2,3,3, undef,undef,undef,   # 3* 132
                 2,2,1, 3,3,1, 3,3,0, undef,undef,undef,   # 3* 136
                 3,3,2, 3,3,2, 0,1,1, undef,undef,undef,   # 3* 140
                 3,3,0, 3,3,1, 2,2,1, undef,undef,undef,   # 3* 144
                 2,3,3, 2,3,3, 1,1,0, undef,undef,undef,   # 3* 148
                 1,2,2, 1,3,3, 0,3,3, undef,undef,undef,   # 3* 152
                 0,1,1, 3,3,2, 3,3,2, undef,undef,undef,   # 3* 156
                 0,3,3, 1,3,3, 1,2,2, undef,undef,undef,   # 3* 160
                 1,1,0, 2,3,3, 2,3,3, undef,undef,undef,   # 3* 164
                 2,2,1, 3,3,1, 3,3,0, undef,undef,undef,   # 3* 168
                 3,3,2, 3,3,2, 0,1,1, undef,undef,undef,   # 3* 172
                 3,3,0, 3,3,1, 2,2,1, undef,undef,undef,   # 3* 176
                 2,3,3, 2,3,3, 1,1,0, undef,undef,undef,   # 3* 180
                 1,2,2, 1,3,3, 0,3,3, undef,undef,undef,   # 3* 184
                 0,1,1, 3,3,2, 3,3,2, undef,undef,undef,   # 3* 188
                 0,3,3, 1,3,3, 1,2,2, undef,undef,undef,   # 3* 192
                 1,1,0, 2,3,3, 2,3,3, undef,undef,undef,   # 3* 196
                 2,2,1, 3,3,1, 3,3,0, undef,undef,undef,   # 3* 200
                 3,3,2, 3,3,2, 0,1,1, undef,undef,undef,   # 3* 204
                 3,3,0, 3,3,1, 2,2,1, undef,undef,undef,   # 3* 208
                 2,3,3, 2,3,3, 1,1,0, undef,undef,undef,   # 3* 212
                 1,2,2, 1,3,3, 0,3,3, undef,undef,undef,   # 3* 216
                 0,1,1, 3,3,2, 3,3,2, undef,undef,undef,   # 3* 220
                 0,3,3, 1,3,3, 1,2,2, undef,undef,undef,   # 3* 224
                 1,1,0, 2,3,3, 2,3,3, undef,undef,undef,   # 3* 228
                 2,2,1, 3,3,1, 3,3,0, undef,undef,undef,   # 3* 232
                 3,3,2, 3,3,2, 0,1,1, undef,undef,undef,   # 3* 236
                 3,3,0, 3,3,1, 2,2,1, undef,undef,undef,   # 3* 240
                 2,3,3, 2,3,3, 1,1,0, undef,undef,undef,   # 3* 244
                 1,2,2, 1,3,3, 0,3,3, undef,undef,undef,   # 3* 248
                 0,1,1, 3,3,2, 3,3,2);
# state length 256 in each of 4 tables
# grand total 2554

# cycle 0/224  part=A1 rot=0 digit=0 <-> part=D2 rot=0 digit=0
# cycle 224/0  part=D2 rot=0 digit=0 <-> part=A1 rot=0 digit=0
# cycle 56/220  part=A2rev rot=2 digit=0 <-> part=D1rev rot=3 digit=0
# cycle 220/56  part=D1rev rot=3 digit=0 <-> part=A2rev rot=2 digit=0
# cycle 92/96  part=B1rev rot=3 digit=0 <-> part=B2 rot=0 digit=0
# cycle 96/92  part=B2 rot=0 digit=0 <-> part=B1rev rot=3 digit=0
#
my %start_state = (A1    => [0, 224],
                   D2    => [224, 0],

                   B2    => [96, 92],
                   B1rev => [92, 96],

                   D1rev => [220, 56],
                   A2rev => [56, 220],
                  );

sub new {
  my $class = shift;
  return $class->SUPER::new (start_shape => 'A1', # default
                             @_);
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### AR2W2Curve n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  my $int = int($n);
  $n -= $int;

  my @digits;
  my $len = $int*0 + 1;   # inherit bignum 1
  do {
    push @digits, $int % 4;
    $len *= 2;
  } while (($int = int($int/4)) || ($#digits&1));
  ### digits: join(', ',@digits)."   count ".scalar(@digits)
  ### $len

  # $dir default if all $digit==3
  my ($state,$dir) = @{$start_state{$self->{'start_shape'}}};
  if ($#digits & 1) {
    ($state,$dir) = ($dir,$state);
  }

  ### initial ...
  ### $state
  ### $dir

  my $x = 0;
  my $y = 0;
  while (@digits) {
    $len /= 2;
    $state += (my $digit = pop @digits);
    if ($digit != 3) {
      $dir = $state;  # lowest non-3 digit
    }

    ### $len
    ### $state
    ### state: state_string($state)
    ### digit_to_x: $digit_to_x[$state]
    ### digit_to_y: $digit_to_y[$state]
    ### next_state: $next_state[$state]

    $x += $len * $digit_to_x[$state];
    $y += $len * $digit_to_y[$state];
    $state = $next_state[$state];
  }

  ### $dir
  ### frac: $n

  # with $n fractional part
  return ($n * ($digit_to_x[$dir+1] - $digit_to_x[$dir]) + $x,
          $n * ($digit_to_y[$dir+1] - $digit_to_y[$dir]) + $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### AR2W2Curve xy_to_n(): "$x, $y"

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

  my ($len, $level) = _round_down_pow (($x > $y ? $x : $y),
                                       2);
  ### $len
  ### $level

  my $n = ($x * 0 * $y);  # inherit bignum 0
  my $state = $start_state{$self->{'start_shape'}}->[$level & 1];
  while ($level-- >= 0) {
    ### at: "$x,$y  len=$len level=$level"
    ### assert: $x >= 0
    ### assert: $y >= 0
    ### assert: $x < 2*$len
    ### assert: $y < 2*$len

    my $xo = int ($x / $len);
    my $yo = int ($y / $len);
    ### assert: $xo >= 0
    ### assert: $xo <= 1
    ### assert: $yo >= 0
    ### assert: $yo <= 1

    $x %= $len;
    $y %= $len;
    ### xy bits: "$xo, $yo"

    my $digit = $yx_to_digit[$state + 2*$yo + $xo];
    $state = $next_state[$state+$digit];
    $n = 4*$n + $digit;
    $len /= 2;
  }

  ### assert: $x == 0
  ### assert: $y == 0

  return $n;
}

# exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### AR2W2Curve rect_to_n_range(): "$x1,$y1, $x2,$y2"

  $x1 = _round_nearest ($x1);
  $x2 = _round_nearest ($x2);
  $y1 = _round_nearest ($y1);
  $y2 = _round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  if ($x2 < 0 || $y2 < 0) {
    return (1, 0);
  }

  my ($len, $level) = _round_down_pow (_max($x2,$y2), 2);
  ### len/level: "$len  $level"
  if (_is_infinite($level)) {
    return (0, $level);
  }

  # At this point an easy over-estimate would be
  #    return (0, 4*$len*$len-1);


  my $n_min = my $n_max
    = my $y_min = my $y_max
      = my $x_min = my $x_max = 0;
  my $min_state = my $max_state
    = $start_state{$self->{'start_shape'}}->[$level & 1];
  ### $x_min
  ### $y_min

  while ($level >= 0) {
    ### $level
    ### $len
    {
      my $x_cmp = $x_min + $len;
      my $y_cmp = $y_min + $len;
      my $digit = $min_digit[3*$min_state
                             + ($x1 >= $x_cmp ? 2 : $x2 >= $x_cmp ? 1 : 0)
                             + ($y1 >= $y_cmp ? 6 : $y2 >= $y_cmp ? 3 : 0)];

      my $xr = ($x1 >= $x_cmp ? 2 : $x2 >= $x_cmp ? 1 : 0);
      my $yr = ($y1 >= $y_cmp ? 6 : $y2 >= $y_cmp ? 3 : 0);
      ### $min_state
      ### min_state: state_string($min_state)
      ### $xr
      ### $yr
      ### $digit

      $n_min = 4*$n_min + $digit;
      $min_state += $digit;
      if ($digit_to_x[$min_state]) { $x_min += $len; }
      if ($digit_to_y[$min_state]) { $y_min += $len; }
      $min_state = $next_state[$min_state];
    }
    {
      my $x_cmp = $x_max + $len;
      my $y_cmp = $y_max + $len;
      my $digit = $max_digit[3*$max_state
                             + ($x1 >= $x_cmp ? 2 : $x2 >= $x_cmp ? 1 : 0)
                             + ($y1 >= $y_cmp ? 6 : $y2 >= $y_cmp ? 3 : 0)];

      $n_max = 4*$n_max + $digit;
      $max_state += $digit;
      if ($digit_to_x[$max_state]) { $x_max += $len; }
      if ($digit_to_y[$max_state]) { $y_max += $len; }
      $max_state = $next_state[$max_state];
    }

    $len = int($len/2);
    $level--;
  }

  return ($n_min, $n_max);
}

1;
__END__

=for stopwords eg Ryde ie AR2W2Curve Math-PlanePath Asano Ranjan Roos Welzl Widmayer HilbertCurve ZOrderCurve Informatics

=head1 NAME

Math::PlanePath::AR2W2Curve -- 2x2 self-similar curve of four patterns

=head1 SYNOPSIS

 use Math::PlanePath::AR2W2Curve;
 my $path = Math::PlanePath::AR2W2Curve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is an integer version of the AR2W2 curve by Asano, Ranjan, Roos, Welzl
and Widmayer.

                                         |
      7     42--43--44  47--48--49  62--63
              \      |   |       |   |
      6     40--41  45--46  51--50  61--60
             |               |           |
      5     39  36--35--34  52  55--56  59
             |   |    /      |   |   |   |
      4     38--37  33--32  53--54  57--58
                          \
      3      6-- 7-- 8  10  31  28--27--26
             |       |/  |   |   |       |
      2      5-- 4   9  11  30--29  24--25
                 |       |           |
      1      2-- 3  13--12  17--18  23--22
              \      |       |   |       |
    Y=0 ->   0-- 1  14--15--16  19--20--21

            X=0  1   2   3   4   5   6   7

It makes a 2x2 expanding pattern with a mixture of "U" and "Z" shapes.  The
mixture is designed to improve some locality measures.

=head2 Shape Parts

There's four base patterns A to D.  A2 is a mirror image of A1, B2 a mirror
of B1, etc.  The start is A1, and above that D2, then A1 again, alternately.

                       ^---->                                ^
         2---3      C1 |  B2            1   3       C2    D1 |
    A1     \           |            A2  | \ |      ---->     |
         0---1          ^               0   2      ^    ---->
                    D2  | B1                       |B1    B2
                   ---->|                          |


         1---2      C2    B1             1---2      B2    C1
    B1   |   |     ---->---->        B2  |   |     ---->---->
         0   3     ^        |            0   3     ^        |
                   |D1    B2|                      |B1    D2|
                   |        v                      |        v

                      ^  \                            ^ |
         1---2      B1|   \A1            1---2     A2/  | B2
    C1   |   |        |    v         C2  |   |      /   v
         0   3       ^      |            0   3     ^      \
                    /A2   B2|                      |B1     \A1
                   /        v                      |        v

                      ^ |                              ^ \
        1---2      A2/  | C2              1---2     C1|  \A1
    D1  |   |       /   v            D2   |   |       |   v
        0   3      ^     \                0   3      ^      |
                   |D1    \A2                       /A1   D2|
                   |       v                       /        v

For parts filling on the right such as the B1 and B2 sub-parts of A1, the
numbering must be reversed..  This doesn't affect the shape of the curve as
such, but it matters for enumerating it as done here.

=head2 Start Shape

The default starting shape is the A1 "Z" part, and above that D2.  Notice
the starting sub-part of D2 is A1 and in turn the starting sub-part of A1 is
D2, so those two alternate at successive higher levels.  Their sub-parts end
up reaching all other parts (in all directions, and forward or reverse).

The C<start_shape =E<gt> $str> option can select a different starting shape.
The choices are

    "A1"       \ pair
    "D2"       /
    "B2"       \ pair
    "B1rev"    /
    "D1rev"    \ pair
    "A2rev"    /

B2 begins with a reversed B1 and in turn a B1 reverse begins with B2 (no
reverse), so those two alternate.  Similarly D1 reverse starts with A2
reverse, and A2 reverse starts with D1 reverse.

The curve is conceived by the authors as descending into ever-smaller
sub-parts and for that any of the patterns can be a top-level start.  But to
expand outwards as done here the starting part must be the start of the
pattern above it, and that's so only for the 6 listed.  The descent graph is

    D2rev ----->  D2<-->A2
    B2rev ----->

    C2rev --> A1rev ----->  B2<-->B1rev   <------ C2
              C1rev ----->                <------ A2 <-- C1

    B1 ----->  D1rev<-->A2rev
    D1 ----->

So for example B1 is not at the start of anything.  Or A1rev is at the start
of C2rev, but then nothing starts with C2rev.  Of the 16 total only the
three pairs shown "E<lt>--E<gt>" are cycles and can thus extend upwards
indefinitely.

=head1 FUNCTION

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::AR2W2Curve-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=item C<($n_lo, $n_hi) = $path-E<gt>rect_to_n_range ($x1,$y1, $x2,$y2)>

The returned range is exact, meaning C<$n_lo> and C<$n_hi> are the smallest
and largest in the rectangle.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::HilbertCurve>,
L<Math::PlanePath::ZOrderCurve>

Asano, Ranjan, Roos, Welzl and Widmayer "Space-Filling Curves and Their Use
in the Design of Geometric Data Structures", Theoretical Computer Science,
181(1):3-15, 1997.  And LATIN'95 Theoretical Informatics which is at Google
Books

    http://books.google.com.au/books?id=_aKhJUJunYwC&pg=PA36

=cut


# Local variables:
# compile-command: "math-image --path=AR2W2Curve --lines --scale=20"
# End:
#
# math-image --path=AR2W2Curve --all --output=numbers_dash
