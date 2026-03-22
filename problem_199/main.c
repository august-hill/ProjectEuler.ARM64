// Problem 199: Iterative Circle Packing
// Three equal circles inside a larger circle, with 10 iterations of filling gaps.
// Find fraction of area not covered, rounded to 8 decimal places.
// Answer: 0.00396087 (return as 396087 for bench, representing 0.00396087)
#include <math.h>

// Descartes Circle Theorem: if four mutually tangent circles have curvatures
// k1, k2, k3, k4: k4 = k1 + k2 + k3 + 2*sqrt(k1*k2 + k2*k3 + k1*k3)

// For three equal circles of radius r inside a circle of radius R:
// The arrangement: R = r * (1 + 2/sqrt(3))
// Or equivalently, r = R / (1 + 2/sqrt(3))
// Normalize: R = 1, so r = 1 / (1 + 2/sqrt(3))

// Curvature of outer circle: k0 = -1/R = -1 (negative because other circles are inside)
// Curvature of each inner circle: k1 = k2 = k3 = 1/r

// There are 4 initial gaps:
// 3 gaps between pairs of inner circles and the outer circle (symmetric)
// 1 gap in the center between the three inner circles

// For each gap, find the inscribed circle using Descartes' theorem,
// then recursively fill the 3 new gaps created.

static double total_area;

static void fill_gap(double k1, double k2, double k3, int depth) {
    if (depth == 0) return;
    // New circle curvature
    double k4 = k1 + k2 + k3 + 2.0 * sqrt(k1*k2 + k2*k3 + k1*k3);
    double r4 = 1.0 / k4;
    total_area += M_PI * r4 * r4;
    // Three new gaps: (k1,k2,k4), (k1,k3,k4), (k2,k3,k4)
    fill_gap(k1, k2, k4, depth - 1);
    fill_gap(k1, k3, k4, depth - 1);
    fill_gap(k2, k3, k4, depth - 1);
}

long long solve(void) {
    double R = 1.0;  // outer radius
    double r = R / (1.0 + 2.0 / sqrt(3.0)); // inner circle radius

    double k_outer = -1.0 / R; // negative curvature for outer
    double k_inner = 1.0 / r;

    double outer_area = M_PI * R * R;
    total_area = 3.0 * M_PI * r * r; // three inner circles

    // 3 symmetric outer gaps: between 2 inner circles and the outer circle
    // Curvatures: k_inner, k_inner, k_outer
    fill_gap(k_inner, k_inner, k_outer, 10);
    fill_gap(k_inner, k_inner, k_outer, 10);
    fill_gap(k_inner, k_inner, k_outer, 10);

    // 1 center gap: between all 3 inner circles
    // Curvatures: k_inner, k_inner, k_inner
    fill_gap(k_inner, k_inner, k_inner, 10);

    double fraction = (outer_area - total_area) / outer_area;
    // Round to 8 decimal places
    long long result = (long long)round(fraction * 1e8);
    return result;
}

#include "../bench.h"
int main(void) { euler_bench(199, solve); return 0; }
