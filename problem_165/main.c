// Problem 165: Intersections
// Answer: 2868868
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "../bench.h"

#define N_SEG 5000

typedef struct { long long x, y; } Point;
typedef struct { long long px, py, pq; } IPoint;

static Point seg[N_SEG][2];
static IPoint *ipoints = NULL;
static int n_ipoints = 0;
static int ipoints_cap = 0;
static int initialized = 0;
static long long answer_cache = 0;

static long long gcd_ll(long long a, long long b) {
    if (a < 0) a = -a;
    if (b < 0) b = -b;
    while (b) { long long t = b; b = a % b; a = t; }
    return a;
}

static void generate_segments(void) {
    long long s = 290797;
    long long t[4 * N_SEG];
    for (int i = 0; i < 4 * N_SEG; i++) {
        s = (s * s) % 50515093LL;
        t[i] = s % 500;
    }
    for (int i = 0; i < N_SEG; i++) {
        seg[i][0].x = t[4*i];
        seg[i][0].y = t[4*i+1];
        seg[i][1].x = t[4*i+2];
        seg[i][1].y = t[4*i+3];
    }
}

static int ipoint_cmp(const void *a, const void *b) {
    const IPoint *ia = a, *ib = b;
    if (ia->pq != ib->pq) return ia->pq < ib->pq ? -1 : 1;
    if (ia->px != ib->px) return ia->px < ib->px ? -1 : 1;
    if (ia->py != ib->py) return ia->py < ib->py ? -1 : 1;
    return 0;
}

long long solve(void) {
    if (initialized) return answer_cache;
    initialized = 1;

    generate_segments();

    if (ipoints_cap == 0) {
        ipoints_cap = 1 << 20;
        ipoints = malloc(ipoints_cap * sizeof(IPoint));
    }
    n_ipoints = 0;

    for (int i = 0; i < N_SEG; i++) {
        long long ax = seg[i][0].x, ay = seg[i][0].y;
        long long bx = seg[i][1].x, by = seg[i][1].y;
        long long dx = bx - ax, dy = by - ay;

        for (int j = i + 1; j < N_SEG; j++) {
            long long cx = seg[j][0].x, cy = seg[j][0].y;
            long long ex = seg[j][1].x, ey = seg[j][1].y;
            long long fx = ex - cx, fy = ey - cy;

            long long denom = dx * fy - dy * fx;
            if (denom == 0) continue;

            long long t_num = (cx - ax) * fy - (cy - ay) * fx;
            long long u_num = (cx - ax) * dy - (cy - ay) * dx;

            if (denom > 0) {
                if (t_num <= 0 || t_num >= denom) continue;
                if (u_num <= 0 || u_num >= denom) continue;
            } else {
                if (t_num >= 0 || t_num <= denom) continue;
                if (u_num >= 0 || u_num <= denom) continue;
            }

            long long px = ax * denom + t_num * dx;
            long long py = ay * denom + t_num * dy;
            long long pq = denom;

            if (pq < 0) { px = -px; py = -py; pq = -pq; }
            long long g = gcd_ll(gcd_ll(px < 0 ? -px : px, py < 0 ? -py : py), pq);
            if (g > 0) { px /= g; py /= g; pq /= g; }

            if (n_ipoints >= ipoints_cap) {
                ipoints_cap *= 2;
                ipoints = realloc(ipoints, ipoints_cap * sizeof(IPoint));
            }
            ipoints[n_ipoints].px = px;
            ipoints[n_ipoints].py = py;
            ipoints[n_ipoints].pq = pq;
            n_ipoints++;
        }
    }

    qsort(ipoints, n_ipoints, sizeof(IPoint), ipoint_cmp);

    long long count = 0;
    for (int i = 0; i < n_ipoints; ) {
        int j = i + 1;
        while (j < n_ipoints && ipoint_cmp(&ipoints[i], &ipoints[j]) == 0) j++;
        count++;
        i = j;
    }

    answer_cache = count;
    return answer_cache;
}

int main(void) { euler_bench(165, solve); return 0; }
