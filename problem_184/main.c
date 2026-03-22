// Problem 184: Triangles Containing the Origin
// Answer: 1725323624056
#include <stdlib.h>
#include <string.h>
#include "../bench.h"

#define R 105

typedef struct { int x, y; } Pt;

static int pt_quadrant(Pt p) {
    if (p.y > 0) return (p.x >= 0) ? 0 : 1;
    if (p.y < 0) return (p.x <= 0) ? 2 : 3;
    return (p.x > 0) ? 0 : 2;
}

static int cmp_angle(const void *a, const void *b) {
    Pt p = *(const Pt *)a, q = *(const Pt *)b;
    int qp = pt_quadrant(p), qq = pt_quadrant(q);
    if (qp != qq) return qp - qq;
    long long cross = (long long)p.x * q.y - (long long)p.y * q.x;
    if (cross > 0) return -1;
    if (cross < 0) return 1;
    return 0;
}

long long solve(void) {
    long long r2 = (long long)R * R;

    int capacity = 40000;
    Pt *pts = (Pt *)malloc(capacity * sizeof(Pt));
    int n = 0;
    for (int x = -(R-1); x <= R-1; x++)
        for (int y = -(R-1); y <= R-1; y++)
            if ((long long)x*x + (long long)y*y < r2 && (x || y))
                pts[n++] = (Pt){x, y};

    qsort(pts, n, sizeof(Pt), cmp_angle);

    long long bad = 0;
    int j = 1;
    for (int i = 0; i < n; i++) {
        if (j <= i) j = i + 1;
        while (j < i + n) {
            int jj = j % n;
            long long cross = (long long)pts[i].x * pts[jj].y - (long long)pts[i].y * pts[jj].x;
            if (cross < 0) break;
            if (cross == 0) {
                long long dot = (long long)pts[i].x * pts[jj].x + (long long)pts[i].y * pts[jj].y;
                if (dot <= 0) break;
            }
            j++;
        }
        long long fi = j - i - 1;
        bad += fi * (fi - 1) / 2;
    }

    long long total_tri = (long long)n * (n - 1) * (n - 2) / 6;
    long long result = total_tri - bad;

    free(pts);
    return result;
}

int main(void) { euler_bench(184, solve); return 0; }
