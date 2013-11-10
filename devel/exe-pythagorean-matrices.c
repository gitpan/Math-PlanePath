/* Copyright 2013 Kevin Ryde

   This file is part of Math-PlanePath.

   Math-PlanePath is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the Free
   Software Foundation; either version 3, or (at your option) any later
   version.

   Math-PlanePath is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
   or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
   for more details.

   You should have received a copy of the GNU General Public License along
   with Math-PlanePath.  If not, see <http://www.gnu.org/licenses/>.
*/

/* Search for matrix triplets which generate all P,Q pairs in Pythagorean
   triples style P>Q>=1, P!=Qmod2, gcd(P,Q)=1.

   UAD and FB are found, plus one more.
*/

/* #define NDEBUG */
#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <limits.h>

#define DEBUG(expr)  
#define xDEBUG(expr)  expr

/* Range of each term a,b,c,d in the matrices */
const int term_min = -5;
const int term_max = 5;

#define MAX_MATRICES 50000

#ifndef INLINE
#define INLINE
#endif

int
is_coprime_func (int x, int y)
{
  if (x < 1 || y < 1)
    return 0;
  
  if ((x & 1) == 0) {
    if ((y & 1) == 0) {
      return 0;
    }
  }
  
  for (;;) {
    if (x < y) { int tmp = x; x = y; y = tmp; }
    if (y == 1) { return 1; }

    x -= y;
    if (x == 0) { return 0; }
    
    while ((x & 1) == 0) {
      x >>= 1;
    }
    while ((y & 1) == 0) {
      y >>= 1;
    }
  }
}

int is_coprime_table[200][200];
void
make_coprime_table (void)
{
  int x,y;
  for (x = 0; x < 200; x++) {
    for (y = 0; y < 200; y++) {
      is_coprime_table[x][y] = is_coprime_func(x,y);
    }
  }
}

static INLINE int
is_coprime (int x, int y)
{
  if (x < 1 || y < 1 || x == y) return 0;
  if (x < 200 && y < 200) {
    return is_coprime_table[x][y];
  }
  return is_coprime_func(x,y);
}
void
print_is_coprime (void)
{
  int x,y;
  for (y = 10; y >= 0; y--) {
    for (x = 0; x <= 10; x++) {
      if (is_coprime(x,y)) {
        printf (" *");
      } else {
        printf (" .");
      }
    }
    printf ("\n");
  }
  return;
}

static INLINE int
pq_is_acceptable (int p, int q)
{
  return (p > q
	  && q >= 1
	  && (p & 1) != (q & 1)
	  && is_coprime(p,q));
}

static INLINE int
m_determinant (int a, int b, int c, int d)
{
  return (a*d - b*c);
}
static INLINE int
m_is_invertible (int a, int b, int c, int d)
{
  return (a*d != b*c);
}

static INLINE int
m_descend_p (int a, int b, int c, int d, int p, int q)
{
  return (a*p + b*q);
}
static INLINE int
m_descend_q (int a, int b, int c, int d, int p, int q)
{
  return (c*p + d*q);
}

int p_table[] = { 2, 3,5,4, 4,8,7,8,12,9,7,9,6, };
int q_table[] = { 1, 2,2,1, 3,3,2,5,5,2,4,4,1, };
const int num_pq_table = sizeof(p_table)/sizeof(p_table[0]);
static INLINE int
m_is_acceptable (int a, int b, int c, int d)
{
  int i;
  if (! m_is_invertible(a,b,c,d)) return 0;
  for (i = 0; i < num_pq_table; i++) {
    int p = p_table[i];
    int q = q_table[i];
    int dp = m_descend_p(a,b,c,d, p,q);
    int dq = m_descend_q(a,b,c,d, p,q);
    /* printf ("m %d,%d,%d,%d descend %d,%d -> %d,%d\n", a,b,c,d, p,q, dp,dq); */
    if (! pq_is_acceptable(dp,dq))
      return 0;
  }
  return 1;
}

const char *
m_name (int a, int b, int c, int d)
{
  if (a == 2 && b == -1 && c == 1 && d == 0) return "U";
  if (a == 2 && b ==  1 && c == 1 && d == 0) return "A";
  if (a == 1 && b ==  2 && c == 0 && d == 1) return "D";

  if (a == 1 && b ==  1 && c == 0 && d == 2)  return "K1";
  if (a == 2 && b ==  0 && c == 1 && d == -1) return "K2";
  if (a == 2 && b ==  0 && c == 1 && d == 1)  return "K3";

  return ".";
}

int matrices_a[MAX_MATRICES];
int matrices_b[MAX_MATRICES];
int matrices_c[MAX_MATRICES];
int matrices_d[MAX_MATRICES];
int matrices_det[MAX_MATRICES];
int num_matrices;
void
make_matrices (void)
{
  int a,b,c,d;
  for (a = term_min; a <= term_max; a++) {
    for (b = term_min; b <= term_max; b++) {
      for (c = term_min; c <= term_max; c++) {
	for (d = term_min; d <= term_max; d++) {
	  if (m_is_acceptable(a,b,c,d)) {
	    matrices_a[num_matrices] = a;
	    matrices_b[num_matrices] = b;
	    matrices_c[num_matrices] = c;
	    matrices_d[num_matrices] = d;
            matrices_det[num_matrices] = m_determinant(a,b,c,d);
	    num_matrices++;
	    if (num_matrices >= MAX_MATRICES) {
	      printf ("too many matrices, limit at %d\n", num_matrices);
	      return;
	    }
	  }
	}
      }
    }
  }

  if (1) {
    int i;
    for (i = 0; i < num_matrices; i++) {
      int a = matrices_a[i];
      int b = matrices_b[i];
      int c = matrices_c[i];
      int d = matrices_d[i];
      const char *name = m_name(a,b,c,d);
      if (name[0] != '.') {
        printf ("matrix %d,%d,%d,%d   %s\n", a,b,c,d, name);
      }
    }
  }
}

static INLINE int
m_can_upward (int a, int b, int c, int d, int det, int p, int q)
{
  int up_p = d*p - b*q;
  int up_q = - c*p + a*q;
  if (up_p % det || up_q % det) return 0;
  up_p /= det;
  up_q /= det;
  if (! pq_is_acceptable(up_p,up_q)) return 0;
  return 1;
}

static INLINE int
m3_coverage_good (int a1, int b1, int c1, int d1, int det1,
		  int a2, int b2, int c2, int d2, int det2,
		  int a3, int b3, int c3, int d3, int det3)
{
  {
    int i;
    DEBUG (printf ("m3_coverage_good() %d,%d,%d,%d  %d,%d,%d,%d  %d,%d,%d,%d %s%s%s\n",
                   a1,b1,c1,d1,
                   a2,b2,c2,d2,
                   a3,b3,c3,d3,
                   m_name(a1,b1,c1,d1), m_name(a2,b2,c2,d2), m_name(a3,b3,c3,d3)));

    for (i = 1; i < num_pq_table; i++) {
      int p = p_table[i];
      int q = q_table[i];

      if (! (m_can_upward(a1,b1,c1,d1,det1, p,q)
             || m_can_upward(a2,b2,c2,d2,det2, p,q)
             || m_can_upward(a3,b3,c3,d3,det3, p,q))) {
        DEBUG (printf ("no upward from %d,%d\n", p,q));
        return 0;
      }
    }
  }
  {
#define PENDING_TABLE_SIZE  (3*3*3*3*3*3)
#define SEEN_SEARCH_DEPTH   6
    
    static int seen[200][200];
    static int pending_p[PENDING_TABLE_SIZE];
    static int pending_q[PENDING_TABLE_SIZE];
    int num_pending = 1;
    pending_p[0] = 2;
    pending_q[0] = 1;
    seen[2][1] = 1;
    /* printf ("sizeof(seen) %d\n", sizeof(seen)); */
    memset (seen, '\0', sizeof(seen));
    
    int rep;
    for (rep = 1; rep <= SEEN_SEARCH_DEPTH; rep++) {
      if (0) {
        printf ("num_pending=%d\n", num_pending);
        int i;
        for (i = 0; i < num_pending; i++) {
          printf (" %d,%d", pending_p[i], pending_q[i]);
          printf ("\n");
        }
      }
                
      static int new_pending_p[PENDING_TABLE_SIZE];
      static int new_pending_q[PENDING_TABLE_SIZE];
      int num_new_pending = 0;

      int i;
      for (i = 0; i < num_pending; i++) {
        int p = pending_p[i];
        int q = pending_q[i];
        assert (p >= 0);
        assert (q >= 0);
        if (p < 200 && q < 200 && seen[p][q]++) {
          DEBUG (printf ("already seen %d,%d\n", p,q));
          return 0;
        }
        if (num_new_pending + 3 > PENDING_TABLE_SIZE) {
          printf ("oops, num_new_pending past PENDING_TABLE_SIZE = %d\n",
                  PENDING_TABLE_SIZE);
          abort ();
        }
        {
          int new_p = m_descend_p (a1,b1,c1,d1, p,q);
          int new_q = m_descend_q (a1,b1,c1,d1, p,q);
          if (! pq_is_acceptable(new_p,new_q)) {
            return 0;
          }
          new_pending_p[num_new_pending] = new_p;
          new_pending_q[num_new_pending] = new_q;
          num_new_pending++;
        }
        {
          int new_p = m_descend_p (a2,b2,c2,d2, p,q);
          int new_q = m_descend_q (a2,b2,c2,d2, p,q);
          if (! pq_is_acceptable(new_p,new_q)) {
            return 0;
          }
          new_pending_p[num_new_pending] = new_p;
          new_pending_q[num_new_pending] = new_q;
          num_new_pending++;
        }
        {
          int new_p = m_descend_p (a3,b3,c3,d3, p,q);
          int new_q = m_descend_q (a3,b3,c3,d3, p,q);
          if (! pq_is_acceptable(new_p,new_q)) {
            return 0;
          }
          new_pending_p[num_new_pending] = new_p;
          new_pending_q[num_new_pending] = new_q;
          num_new_pending++;
        }
      }

      assert (num_new_pending <= PENDING_TABLE_SIZE);
      memcpy (pending_p, new_pending_p, sizeof(pending_p[0])*num_new_pending);
      memcpy (pending_q, new_pending_q, sizeof(pending_q[0])*num_new_pending);
      num_pending = num_new_pending;
    }

    int i;
    for (i = 0; i < num_pq_table; i++) {
      int p = p_table[i];
      int q = q_table[i];

      if (p < 200 && q < 200 && ! seen[p][q]) {
        DEBUG (printf ("not seen %d,%d\n", p,q));
        return 0;
      }
    }
  }
  return 1;
}

void
matrix_triplets (void)
{
  int i1,i2,i3;
  for (i1 = 0; i1 < num_matrices; i1++) {
    int a1 = matrices_a[i1];
    int b1 = matrices_b[i1];
    int c1 = matrices_c[i1];
    int d1 = matrices_d[i1];
    int det1 = matrices_det[i1];
    for (i2 = i1+1; i2 < num_matrices; i2++) {
      int a2 = matrices_a[i2];
      int b2 = matrices_b[i2];
      int c2 = matrices_c[i2];
      int d2 = matrices_d[i2];
      int det2 = matrices_det[i2];
      for (i3 = i2+1; i3 < num_matrices; i3++) {
	int a3 = matrices_a[i3];
	int b3 = matrices_b[i3];
	int c3 = matrices_c[i3];
	int d3 = matrices_d[i3];
        int det3 = matrices_det[i3];

        if (m3_coverage_good (a1,b1,c1,d1,det1, a2,b2,c2,d2,det2, a3,b3,c3,d3,det3)) {
	  printf ("%d,%d,%d,%d  %d,%d,%d,%d  %d,%d,%d,%d   %s %s %s\n",
                  a1,b1,c1,d1, a2,b2,c2,d2, a3,b3,c3,d3,
                  m_name(a1,b1,c1,d1), m_name(a2,b2,c2,d2), m_name(a3,b3,c3,d3));
	}
      }
    }
  }
}

int
main (void)
{
  make_coprime_table();
  print_is_coprime();

  make_matrices();
  printf ("num_matrices %d\n", num_matrices);

  int a1 = 1;
  int b1 = 3;
  int c1 = 0;
  int d1 = 2;
  int a2 = 2;
  int b2 = -1;
  int c2 = 1;
  int d2 = 0;
  int a3 = 2;
  int b3 = 0;
  int c3 = 1;
  int d3 = -1;
  m3_coverage_good(a1,b1,c1,d1,m_determinant(a1,b1,c1,d1),
                   a2,b2,c2,d2,m_determinant(a2,b2,c2,d2),
                   a3,b3,c3,d3,m_determinant(a3,b3,c3,d3));
  matrix_triplets();
  return 0;
}

/* #if 0 */
/*  */
/*     my @p; */
/*     my @q; */
/*     my @pq; */
/*     { */
/*       my $path = Math::PlanePath::PythagoreanTree->new(coordinates => 'PQ'); */
/*       foreach my $i (0 .. 120) { */
/*         ($p[$i],$q[$i]) = $path->n_to_xy($path->n_start + $i); */
/*         $pq[$i] = "$p[$i],$q[$i]"; */
/*       } */
/*       $#pq = 13; */
/*     } */
/*     # { */
/* #   foreach my $p (2 .. 18) { */
/* #     foreach my $q (1 .. 18) { */
/* #       next unless pq_acceptable($p,$q); */
/* #       push @p, $p; */
/* #       push @q, $q; */
/* #       push @pq, "$p,$q"; */
/*       #     } */
/*     #   } */
/*     # } */
/*  */
/*  */
/*     print "matrices ",scalar(@matrices),"\n"; */
/*  */
/*     # (a b)(p)  inverse (d -b) */
/*       # (c d)(q)          (-c a) / det */
/* # det = ad-bc */
