// Problem 90: Cube Digit Pairs
// Answer: 1217
#include <stdio.h>
#include <stdbool.h>
#include "../bench.h"

static bool cubes[210][10];
static int cube_count = 0;

static void generate_cubes(void) {
    cube_count = 0;
    for (int a = 0; a < 5; a++)
    for (int b = a+1; b < 6; b++)
    for (int c = b+1; c < 7; c++)
    for (int d = c+1; d < 8; d++)
    for (int e = d+1; e < 9; e++)
    for (int f = e+1; f < 10; f++) {
        for (int i = 0; i < 10; i++) cubes[cube_count][i] = false;
        cubes[cube_count][a] = true;
        cubes[cube_count][b] = true;
        cubes[cube_count][c] = true;
        cubes[cube_count][d] = true;
        cubes[cube_count][e] = true;
        cubes[cube_count][f] = true;
        if (cubes[cube_count][6] || cubes[cube_count][9]) {
            cubes[cube_count][6] = true;
            cubes[cube_count][9] = true;
        }
        cube_count++;
    }
}

long long solve(void) {
    static int initialized = 0;
    if (!initialized) { generate_cubes(); initialized = 1; }

    int squares[][2] = {
        {0,1}, {0,4}, {0,9}, {1,6}, {2,5},
        {3,6}, {4,9}, {6,4}, {8,1}
    };
    int count = 0;
    for (int i = 0; i < cube_count; i++) {
        for (int j = i; j < cube_count; j++) {
            bool valid = true;
            for (int s = 0; s < 9; s++) {
                int d1 = squares[s][0], d2 = squares[s][1];
                if (!((cubes[i][d1] && cubes[j][d2]) || (cubes[i][d2] && cubes[j][d1]))) {
                    valid = false; break;
                }
            }
            if (valid) count++;
        }
    }
    return count;
}

int main(void) { euler_bench(90, solve); return 0; }
