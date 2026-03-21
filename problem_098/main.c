// Problem 98: Anagramic Squares
// Answer: 18769
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "../bench.h"

#define MAX_WORDS 2500
#define MAX_WORD_LEN 20

static char words[MAX_WORDS][MAX_WORD_LEN];
static int nwords;

static void load_words(void) {
    FILE *f = fopen("p098_words.txt", "r");
    if (!f) { fprintf(stderr, "Cannot open p098_words.txt\n"); exit(1); }
    char buf[65536];
    int len = fread(buf, 1, sizeof(buf) - 1, f);
    buf[len] = 0;
    fclose(f);

    nwords = 0;
    char *p = buf;
    while (*p) {
        if (*p == '"') {
            p++;
            int i = 0;
            while (*p && *p != '"') words[nwords][i++] = *p++;
            words[nwords][i] = 0;
            nwords++;
            if (*p == '"') p++;
        } else p++;
    }
}

static int are_anagrams(const char *a, const char *b) {
    if (strlen(a) != strlen(b)) return 0;
    int counts[26] = {0};
    for (int i = 0; a[i]; i++) counts[a[i] - 'A']++;
    for (int i = 0; b[i]; i++) counts[b[i] - 'A']--;
    for (int i = 0; i < 26; i++) if (counts[i]) return 0;
    return 1;
}

static long long isqrt_check(long long n) {
    long long r = (long long)sqrt((double)n);
    if (r * r == n) return r;
    if ((r+1)*(r+1) == n) return r+1;
    if (r > 0 && (r-1)*(r-1) == n) return r-1;
    return -1;
}

long long solve(void) {
    static int initialized = 0;
    if (!initialized) { load_words(); initialized = 1; }

    long long best = 0;

    for (int i = 0; i < nwords; i++) {
        for (int j = i + 1; j < nwords; j++) {
            if (!are_anagrams(words[i], words[j])) continue;

            int wlen = (int)strlen(words[i]);
            long long lo_sq = 1;
            for (int k = 1; k < wlen; k++) lo_sq *= 10;
            long long hi_sq = lo_sq * 10 - 1;

            long long lo = (long long)ceil(sqrt((double)lo_sq));
            long long hi = (long long)floor(sqrt((double)hi_sq));

            for (long long s = lo; s <= hi; s++) {
                long long sq = s * s;

                int letter_to_digit[26];
                int digit_to_letter[10];
                memset(letter_to_digit, -1, sizeof(letter_to_digit));
                memset(digit_to_letter, -1, sizeof(digit_to_letter));

                int valid = 1;
                long long tmp = sq;
                int digits[MAX_WORD_LEN];
                for (int k = wlen - 1; k >= 0; k--) {
                    digits[k] = (int)(tmp % 10);
                    tmp /= 10;
                }

                for (int k = 0; k < wlen; k++) {
                    int li = words[i][k] - 'A';
                    int di = digits[k];
                    if (letter_to_digit[li] == -1 && digit_to_letter[di] == -1) {
                        letter_to_digit[li] = di;
                        digit_to_letter[di] = li;
                    } else if (letter_to_digit[li] != di || digit_to_letter[di] != li) {
                        valid = 0; break;
                    }
                }
                if (!valid) continue;

                long long num2 = 0;
                for (int k = 0; k < wlen; k++) {
                    int li = words[j][k] - 'A';
                    if (letter_to_digit[li] == -1) { valid = 0; break; }
                    num2 = num2 * 10 + letter_to_digit[li];
                }
                if (!valid) continue;

                if (letter_to_digit[words[j][0] - 'A'] == 0) continue;

                if (isqrt_check(num2) >= 0) {
                    long long mx = sq > num2 ? sq : num2;
                    if (mx > best) best = mx;
                }
            }
        }
    }
    return best;
}

int main(void) { euler_bench(98, solve); return 0; }
