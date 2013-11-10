#!/usr/bin/m4

# Copyright 2013 Kevin Ryde

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


define(`seg_offset_y',`eval((($1 ^ $2) >> 1) & 1)')
define(`seg_offset_x',`seg_offset_y(eval($1+1), eval($2+1))')
define(`seg_to_even',`eval($1 - seg_offset_x($1,$2)),
                      eval($2 - seg_offset_y($1,$2))');
to even: seg_to_even(0,0)
x: seg_offset_x(0,0)
y: seg_offset_y(0,0)

# # forloop(`y',-8,7,
# #   `forloop(`x',-8,7,
# #     `seg_offset_y(x,y)')
# # ')
# # 
# # forloop(`y',-8,7,
# #   `forloop(`x',-8,7,
# #     `seg_offset_x(x,y)')
# # ')
# 
# isfinal: seg_is_final(0,0)
# to_even: seg_to_even(-2,0)
# vpred: vertex_pred(0,0)
# 
# forloop(`y',10,-10,
# `forloop(`x',-10,10,
#   `ifelse(vertex_pred(x,y),1, `+', ` ')dnl
# ifelse(seg_pred(vertex_to_seg_east(x,y)), 1, `--', `  ')')
# forloop(`x',-10,10,
#   `ifelse(seg_pred(vertex_to_seg_south(x,y)), 1, `|  ', `   ')')
# ')
# 
# forloop(`y',28,-12,
#   `forloop(`x',-32,32,
#     `ifelse(x.y,0.z0,`+',vertex_pred(x,y))')
# ')
# 
# seg_is_final(xy_div_iplus1(1,1))
# xy_div_iplus1(xy_div_iplus1(4,4))
# xy_div_iplus1(xy_div_iplus1(xy_div_iplus1(4,4)))
# xy_div_iplus1(xy_div_iplus1(xy_div_iplus1(xy_div_iplus1(4,4))))
# seg_is_final(xy_div_iplus1(xy_div_iplus1(xy_div_iplus1(xy_div_iplus1(xy_div_iplus1(4,4))))))
# 
# define(`y',8)
