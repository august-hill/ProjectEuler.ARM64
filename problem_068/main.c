// Problem 68: Magic 5-gon Ring
// Answer: 6531031914842725
#include <stdio.h>
#include <string.h>
#include "../bench.h"

static int next_permutation(int *arr, int n) {
    int i = n - 1;
    while (i > 0 && arr[i - 1] >= arr[i]) i--;
    if (i == 0) return 0;
    int j = n - 1;
    while (arr[j] <= arr[i - 1]) j--;
    int tmp = arr[i - 1]; arr[i - 1] = arr[j]; arr[j] = tmp;
    for (int l = i, r = n - 1; l < r; l++, r--) {
        tmp = arr[l]; arr[l] = arr[r]; arr[r] = tmp;
    }
    return 1;
}

long long solve(void) {
    int perm[10] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    long long best = 0;

    do {
        int *outer = perm;
        int *inner = perm + 5;

        int target = outer[0] + inner[0] + inner[1];
        int valid = 1;
        for (int i = 1; i < 5; i++) {
            if (outer[i] + inner[i] + inner[(i + 1) % 5] != target) {
                valid = 0;
                break;
            }
        }

        if (valid) {
            int min_idx = 0;
            for (int i = 1; i < 5; i++) {
                if (outer[i] < outer[min_idx]) min_idx = i;
            }

            int digits[15];
            int dlen = 0;
            for (int k = 0; k < 5; k++) {
                int i = (min_idx + k) % 5;
                digits[dlen++] = outer[i];
                digits[dlen++] = inner[i];
                digits[dlen++] = inner[(i + 1) % 5];
            }

            int total_digits = 0;
            for (int i = 0; i < dlen; i++) {
                total_digits += (digits[i] >= 10) ? 2 : 1;
            }

            if (total_digits == 16) {
                long long num = 0;
                for (int i = 0; i < dlen; i++) {
                    if (digits[i] >= 10) {
                        num = num * 100 + digits[i];
                    } else {
                        num = num * 10 + digits[i];
                    }
                }
                if (num > best) best = num;
            }
        }
    } while (next_permutation(perm, 10));

    return best;
}

int main(void) { euler_bench(68, solve); return 0; }
