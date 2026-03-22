// Problem 144: Investigating Multiple Reflections of a Laser Beam
// Answer: 354
#include <math.h>

long long solve(void) {
    double x0 = 0.0, y0 = 10.1;
    double x1 = 1.4, y1 = -9.6;
    int count = 0;

    while (1) {
        double dx = x1 - x0;
        double dy = y1 - y0;

        double nx = 4.0 * x1, ny = y1;
        double dot = dx * nx + dy * ny;
        double nn = nx * nx + ny * ny;

        double rx = dx - 2.0 * dot / nn * nx;
        double ry = dy - 2.0 * dot / nn * ny;

        double a = 4.0 * rx * rx + ry * ry;
        double b = 8.0 * x1 * rx + 2.0 * y1 * ry;
        double c = 4.0 * x1 * x1 + y1 * y1 - 100.0;

        double disc = b * b - 4.0 * a * c;
        double t = (-b + sqrt(disc)) / (2.0 * a);
        if (fabs(t) < 1e-9) {
            t = (-b - sqrt(disc)) / (2.0 * a);
        }

        x0 = x1;
        y0 = y1;
        x1 = x0 + t * rx;
        y1 = y0 + t * ry;
        count++;

        if (y1 > 0 && fabs(x1) <= 0.01) {
            break;
        }
    }
    return count;
}

#include "../bench.h"
int main(void) { euler_bench(144, solve); return 0; }
