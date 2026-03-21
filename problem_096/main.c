// Problem 96: Su Doku
// Answer: 24702
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "../bench.h"

typedef int Board[9][9];

static int get_possible(Board board, int r, int c) {
    int used = 0;
    for (int j = 0; j < 9; j++) used |= 1 << board[r][j];
    for (int i = 0; i < 9; i++) used |= 1 << board[i][c];
    int br = (r / 3) * 3, bc = (c / 3) * 3;
    for (int i = br; i < br + 3; i++)
        for (int j = bc; j < bc + 3; j++)
            used |= 1 << board[i][j];
    return ~used & 0x3FE;
}

static int popcount16(int x) {
    int count = 0;
    while (x) { count++; x &= x - 1; }
    return count;
}

static int solve_sudoku(Board board) {
    int min_opts = 10, best_r = -1, best_c = -1;
    for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
            if (board[r][c] == 0) {
                int opts = popcount16(get_possible(board, r, c));
                if (opts < min_opts) {
                    min_opts = opts; best_r = r; best_c = c;
                    if (opts == 1) goto found;
                }
            }
        }
    }
    found:
    if (best_r == -1) return 1;
    if (min_opts == 0) return 0;

    int possible = get_possible(board, best_r, best_c);
    for (int d = 1; d <= 9; d++) {
        if (possible & (1 << d)) {
            board[best_r][best_c] = d;
            if (solve_sudoku(board)) return 1;
            board[best_r][best_c] = 0;
        }
    }
    return 0;
}

static char filedata[16384];

static void load_file(void) {
    FILE *f = fopen("p096_sudoku.txt", "r");
    if (!f) { fprintf(stderr, "Cannot open p096_sudoku.txt\n"); exit(1); }
    int len = fread(filedata, 1, sizeof(filedata) - 1, f);
    filedata[len] = 0;
    fclose(f);
}

long long solve(void) {
    static int initialized = 0;
    if (!initialized) { load_file(); initialized = 1; }

    char *lines[600];
    int nlines = 0;
    char buf[16384];
    strcpy(buf, filedata);

    char *p = buf;
    while (*p) {
        lines[nlines++] = p;
        while (*p && *p != '\n') p++;
        if (*p == '\n') { *p = 0; p++; }
    }

    int total = 0;
    for (int puzzle = 0; puzzle < 50; puzzle++) {
        int base = puzzle * 10 + 1;
        Board board;
        for (int r = 0; r < 9; r++)
            for (int c = 0; c < 9; c++)
                board[r][c] = lines[base + r][c] - '0';
        solve_sudoku(board);
        total += board[0][0] * 100 + board[0][1] * 10 + board[0][2];
    }
    return total;
}

int main(void) { euler_bench(96, solve); return 0; }
