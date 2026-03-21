// Problem 84: Monopoly Odds
// Answer: 101524
#include <stdio.h>
#include <string.h>
#include "../bench.h"

#define GO  0
#define JAIL 10
#define G2J 30
#define CC1 2
#define CC2 17
#define CC3 33
#define CH1 7
#define CH2 22
#define CH3 36
#define C1  11
#define E3  24
#define H2  39
#define R1  5

static void apply_landing(double freq[40], int square, double prob) {
    if (square == G2J) {
        freq[JAIL] += prob;
    } else if (square == CC1 || square == CC2 || square == CC3) {
        freq[GO] += prob / 16.0;
        freq[JAIL] += prob / 16.0;
        freq[square] += prob * 14.0 / 16.0;
    } else if (square == CH1 || square == CH2 || square == CH3) {
        int next_r, next_u;
        if (square == CH1) { next_r = 15; next_u = 12; }
        else if (square == CH2) { next_r = 25; next_u = 28; }
        else { next_r = 5; next_u = 12; }
        int back3 = (square + 40 - 3) % 40;

        freq[GO] += prob / 16.0;
        freq[JAIL] += prob / 16.0;
        freq[C1] += prob / 16.0;
        freq[E3] += prob / 16.0;
        freq[H2] += prob / 16.0;
        freq[R1] += prob / 16.0;
        freq[next_r] += prob * 2.0 / 16.0;
        freq[next_u] += prob / 16.0;
        apply_landing(freq, back3, prob / 16.0);
        freq[square] += prob * 6.0 / 16.0;
    } else {
        freq[square] += prob;
    }
}

long long solve(void) {
    double dice_prob[9] = {0};
    for (int d1 = 1; d1 <= 4; d1++)
        for (int d2 = 1; d2 <= 4; d2++)
            dice_prob[d1 + d2] += 1.0 / 16.0;

    double freq[40] = {0};
    freq[0] = 1.0;

    for (int iter = 0; iter < 200; iter++) {
        double new_freq[40] = {0};
        for (int pos = 0; pos < 40; pos++) {
            if (freq[pos] == 0.0) continue;
            new_freq[JAIL] += freq[pos] * (1.0 / 64.0);
            double remaining = freq[pos] * (63.0 / 64.0);
            for (int sum = 2; sum <= 8; sum++) {
                int next = (pos + sum) % 40;
                apply_landing(new_freq, next, remaining * dice_prob[sum]);
            }
        }
        memcpy(freq, new_freq, sizeof(freq));
    }

    int top[3] = {-1, -1, -1};
    for (int t = 0; t < 3; t++) {
        int best = -1;
        for (int i = 0; i < 40; i++) {
            if (i == top[0] || i == top[1]) continue;
            if (best == -1 || freq[i] > freq[best]) best = i;
        }
        top[t] = best;
    }

    return top[0] * 10000 + top[1] * 100 + top[2];
}

int main(void) { euler_bench(84, solve); return 0; }
