#!/usr/bin/gnuplot

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


#------------------------------------------------------------------------------

# set terminal png
# set terminal xterm
# set parametric

# something evil happens with "xtics axis", need dummy xlabel
# set xlabel " " 0, -2
# set xrange [-0.5:39.5]
# set xtics axis 5
# set mxtics 5

# set ylabel "Weight (percent)"
#
#set yrange [-5:55]

# set for [i = 1:10] style line i lc rgb "blue"
# plot "foo.data" with lines

# plot for [n=2:10] a=n n,2*n with lines

# plot x,x*x with linespoints pointinterval 5
# plot [1:10] x,2*x with lines

#plot sin(t),t**2 with lines

# bit_above_lowest_0(n) = n & (1 + (n ^ (n-1)))

# num_bits(n) = (n==0 ? 0 : 1+num_bits(int(n/2)))
# dragon_pos(n) = dragon_pos_by_bits(int(n), num_bits(int(n)))

# 1,1              shift +90*b^bit
# 1,0 \rot+90
# 0,1 /            shift b^bit
# 0,0  
# dragon_pos_by_bits(n,bit) = (bit<0 ? 0                                  \
#   : ((n&(2**(bit+1)))                                                   \
#      ? (n&(2**bit)                                                      \
#         ? dragon_pos_by_bits(n,bit-1)         + {0,1}*{1,1}**bit        \
#         : dragon_pos_by_bits(n,bit-1) * {0,1}                           \
#        )                                                                \
#      : (n&(2**bit)                                                      \
#         ? dragon_pos_by_bits(n,bit-1) * {0,1} + {1,1}**bit              \
#         : dragon_pos_by_bits(n,bit-1)                                   \
#        )                                                                \
#      ))

# dragon_pos_by_bits(n,bit) = (bit<0 ? 0                                        \
#   : ((n&(2**(bit+1)))                                                         \
#      ? (n&(2**bit)                                                            \
#         ? dragon_pos_by_bits(n,bit-1)         + ((n&(2**bit)) ? ({1,1}**bit) * ((n&(2**(bit+1))) ? {0,1} : 1) \
#                      : 0)                                                    \
#         : dragon_pos_by_bits(n,bit-1) * ((n&(2**(bit+1))) != (n&(2**bit)) ? {0,1} : 1) + ((n&(2**bit)) ? ({1,1}**bit) * ((n&(2**(bit+1))) ? {0,1} : 1) \
#                      : 0)                                \
#        )                                                                      \
#      : (n&(2**bit)                                                            \
#         ? dragon_pos_by_bits(n,bit-1) * ((n&(2**(bit+1))) != (n&(2**bit)) ? {0,1} : 1) + ((n&(2**bit)) ? ({1,1}**bit) * ((n&(2**(bit+1))) ? {0,1} : 1) \
#                      : 0)                    \
#         : dragon_pos_by_bits(n,bit-1) * ((n&(2**(bit+1))) != (n&(2**bit)) ? {0,1} : 1)     + ((n&(2**bit)) ? ({1,1}**bit) * ((n&(2**(bit+1))) ? {0,1} : 1) \
#                      : 0)                                   \
#        )                                                                      \
#      ))

# dragon_pos_by_bits(n,pos) = (pos<0 ? 0                                  \
#   : dragon_pos_by_bits(n,pos-1)                                         \
#     * ((n&(2**(pos+1)))/2 != (n&(2**pos)) ? {0,1} : 1)                    \
#     + ((n&(2**pos)) ? ({1,1}**pos) * ((n&(2**(pos+1))) ? {0,1} : 1) \
#                     : 0))


# # return 0 or 1 for the bit at position "pos" in n
# # pos==0 is the least significant bit
# bit_at_pos(n,pos) = int(n/(2**pos)) & 1
# 
# bit_pair_at_pos(n,pos) = int(n/(2**pos)) & 3
# addfactor(pair) = (pair & 1                      \
#                            ? ((pair & 2) ? {0,1} : 1)      \
#                            : 0)
# multiplier(pair) = (((pair+1)&3) >= 2) ? {0,1} : 1

# dragon_pos_by_bits(n,pos) = (pos<0 ? 0           \
#   : ((pair = bit_pair_at_pos(n,pos)),             \
#      (dragon_pos_by_bits(n,pos-1)                 \
#      * multiplier(pair)                  \
#      + addfactor(pair) * ({1,1}**pos))))

# addfactor(pair) = (pair == 1   ? 1              \
#                    : pair == 3 ? {0,1}          \
#                    : 0) # pair==0 or pair==2
# multiplier(pair) = (pair == 0 || pair == 3 ? 1 : {0,1})
# 
# dragon_pos_by_bits(n,pos) = (pos<0 ? 0                  \
#   : dragon_pos_by_bits(n,pos-1)                         \
#     * multiplier(bit_pair_at_pos(n,pos))                \
#     + addfactor(bit_pair_at_pos(n,pos)) * ({1,1}**pos))

# addfactor(n,pos) = (bit_at_pos(n,pos)
#                     ? (bit_at_pos(n,pos+1) ? {0,1} : 1)
#                     : 0)
# multiplier(pair) = (bit_at_pos(n,pos) == bit_at_pos(n,pos+1) ? 1 : {0,1})
# 
# dragon_pos_by_bits(n,pos) = (pos<0 ? 0                  \
#   : addfactor(n,pos) * ({1,1}**pos)
#     + multiplier(n,pos) * dragon_pos_by_bits(n,pos-1))

# b={1,1}
# #plot real(b**t),imag(b**t) with points
# # plot int(t),(num_bits(int(t))) with linespoints

# set yrange [-1:length]
# set xrange [-10:10]
# set yrange [-10:10]

#------------------------------------------------------------------------------

# set xtics 1
# set ytics 1
# set grid xtics ytics
# plot t,high_bit_pos(NaN)
# pause mouse

#------------------------------------------------------------------------------

# unset parametric
# # factorial(n) = gamma(int(n)+1)
# 
# # plot from 0 to xmax
# # xmax = 4
# # set yrange [0:xmax!+1]
# # set bmargin 2
# # set ytics 0,2
# 
# 
# # Gnuplot has a builtin <code>!</code> factorial operator for use on
# # integers.
# 
# set xrange [0:4.95]
# set key left
# plot int(x)!
# 
# # If you wanted to write your own it can be done recursively.
# 
# # Using int(n) allows non-integer "n" inputs, with the factorial
# # calculated on int(n) in that case.
# # Arranging the condition as "n>=2" avoids infinite recursion if
# # n==NaN, since any comparison involving NaN is false.  Could change
# # "1" to an expression like "n*0+1" to propagate a NaN input to the
# # output too, if desired.
# #
# factorial(n) = (n >= 2 ? int(n)*factorial(n-1) : 1)
# set xrange [0:4.95]
# set key left
# plot factorial(x)
# 
# # plot (factorial(NaN))
# pause 100
# 
# # And the <code>gamma()</code> function for any real.
# 
# set xrange [0:5]
# plot gamma(x)

#------------------------------------------------------------------------------

# dragon_midpoint(n) = ((dragon(n) + dragon(n+1)) / {1,1} + {-0.5,0.5})
# set xtics 1
# set ytics 1
# # set mxtics 1
# set grid xtics ytics
# plot real(dragon_midpoint(t)),imag(dragon_midpoint(t)) with lines

pause 100