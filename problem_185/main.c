// Problem 185: Number Mind
// Answer: 4640261571849533
#include <string.h>
#include "../bench.h"

#define N 16
#define NCLUES 22

static int clue_digits[NCLUES][N];
static int clue_correct[NCLUES];
static int secret[N];
static int found;
static long long answer;

static void init_clues(void) {
    static const char *gs[] = {
        "5616185650518293", "3847439647293047", "5855462940810587",
        "9742855507068353", "4296849643607543", "3174248439465858",
        "4513559094146117", "7890971548908067", "8157356344118483",
        "2615250744386899", "8690095851526254", "6375711915077050",
        "6913859173121360", "6442889055042768", "2321386104303845",
        "2326509471271448", "5251583379644322", "1748270476758276",
        "4895722652190306", "3041631117224635", "1841236454324589",
        "2659862637316867"
    };
    static const int cc[] = {2,1,3,3,3,1,2,3,1,2,3,1,1,2,0,2,2,3,1,3,3,2};
    for (int i = 0; i < NCLUES; i++) {
        for (int j = 0; j < N; j++)
            clue_digits[i][j] = gs[i][j] - '0';
        clue_correct[i] = cc[i];
    }
}

static int check_partial(int pos) {
    for (int c = 0; c < NCLUES; c++) {
        int matches = 0;
        for (int i = 0; i < pos; i++)
            if (secret[i] == clue_digits[c][i]) matches++;
        int remaining = N - pos;
        if (matches > clue_correct[c]) return 0;
        if (matches + remaining < clue_correct[c]) return 0;
    }
    return 1;
}

static void backtrack(int pos) {
    if (found) return;
    if (pos == N) {
        for (int c = 0; c < NCLUES; c++) {
            int matches = 0;
            for (int i = 0; i < N; i++)
                if (secret[i] == clue_digits[c][i]) matches++;
            if (matches != clue_correct[c]) return;
        }
        found = 1;
        answer = 0;
        for (int i = 0; i < N; i++) answer = answer * 10 + secret[i];
        return;
    }

    for (int d = 0; d <= 9; d++) {
        int valid = 1;
        for (int c = 0; c < NCLUES; c++) {
            if (clue_correct[c] == 0 && clue_digits[c][pos] == d) { valid = 0; break; }
        }
        if (!valid) continue;

        secret[pos] = d;
        if (check_partial(pos + 1))
            backtrack(pos + 1);
        if (found) return;
    }
}

long long solve(void) {
    static int initialized = 0;
    if (!initialized) { init_clues(); initialized = 1; }

    found = 0;
    answer = 0;
    memset(secret, 0, sizeof(secret));
    backtrack(0);
    return answer;
}

int main(void) { euler_bench(185, solve); return 0; }
