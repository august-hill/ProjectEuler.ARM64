// Problem 54: Poker Hands
// Answer: 376
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct { int value; char suit; } Card;
typedef struct { Card cards[5]; int rank; int rv[5]; int nrv; } Hand;

static char *poker_data = NULL;
static char **lines = NULL;
static int num_lines = 0;

static int parse_value(char c) {
    if (c >= '2' && c <= '9') return c - '0';
    if (c == 'T') return 10; if (c == 'J') return 11;
    if (c == 'Q') return 12; if (c == 'K') return 13;
    if (c == 'A') return 14; return 0;
}

static int cmp_desc(const void *a, const void *b) { return *(int*)b - *(int*)a; }
static int cmp_cards(const void *a, const void *b) { return ((Card*)b)->value - ((Card*)a)->value; }

static void detect_rank(Hand *h) {
    qsort(h->cards, 5, sizeof(Card), cmp_cards);
    int freq[15] = {0};
    for (int i = 0; i < 5; i++) freq[h->cards[i].value]++;
    int flush = 1;
    for (int i = 1; i < 5; i++) if (h->cards[i].suit != h->cards[0].suit) { flush = 0; break; }
    int straight = 1;
    for (int i = 0; i < 4; i++) if (h->cards[i].value - h->cards[i+1].value != 1) { straight = 0; break; }
    int f4[5]={0},n4=0, f3[5]={0},n3=0, f2[5]={0},n2=0, f1[5]={0},n1=0;
    for (int v = 2; v <= 14; v++) {
        if (freq[v]==4) f4[n4++]=v; else if (freq[v]==3) f3[n3++]=v;
        else if (freq[v]==2) f2[n2++]=v; else if (freq[v]==1) f1[n1++]=v;
    }
    qsort(f2, n2, sizeof(int), cmp_desc);
    qsort(f1, n1, sizeof(int), cmp_desc);
    h->nrv = 0;
    if (straight && flush) { h->rank = 9; h->rv[h->nrv++] = h->cards[0].value; }
    else if (n4) { h->rank = 8; h->rv[h->nrv++] = f4[0]; for(int i=0;i<n1;i++) h->rv[h->nrv++]=f1[i]; }
    else if (n3 && n2) { h->rank = 7; h->rv[h->nrv++] = f3[0]; h->rv[h->nrv++] = f2[0]; }
    else if (flush) { h->rank = 6; for(int i=0;i<5;i++) h->rv[h->nrv++]=h->cards[i].value; }
    else if (straight) { h->rank = 5; h->rv[h->nrv++] = h->cards[0].value; }
    else if (n3) { h->rank = 4; h->rv[h->nrv++] = f3[0]; for(int i=0;i<n1;i++) h->rv[h->nrv++]=f1[i]; }
    else if (n2==2) { h->rank = 3; for(int i=0;i<n2;i++) h->rv[h->nrv++]=f2[i]; for(int i=0;i<n1;i++) h->rv[h->nrv++]=f1[i]; }
    else if (n2==1) { h->rank = 2; h->rv[h->nrv++]=f2[0]; for(int i=0;i<n1;i++) h->rv[h->nrv++]=f1[i]; }
    else { h->rank = 1; for(int i=0;i<n1;i++) h->rv[h->nrv++]=f1[i]; }
}

static void parse_hand(Hand *h, char c[5][3]) {
    for (int i = 0; i < 5; i++) { h->cards[i].value = parse_value(c[i][0]); h->cards[i].suit = c[i][1]; }
    detect_rank(h);
}

static int hand_beats(Hand *a, Hand *b) {
    if (a->rank != b->rank) return a->rank > b->rank;
    int len = a->nrv < b->nrv ? a->nrv : b->nrv;
    for (int i = 0; i < len; i++) if (a->rv[i] != b->rv[i]) return a->rv[i] > b->rv[i];
    return 0;
}

static void load_data(void) {
    FILE *f = fopen("poker.txt", "r");
    if (!f) { fprintf(stderr, "Cannot open poker.txt\n"); exit(1); }
    fseek(f, 0, SEEK_END); long sz = ftell(f); fseek(f, 0, SEEK_SET);
    poker_data = malloc(sz + 1); fread(poker_data, 1, sz, f); poker_data[sz] = '\0'; fclose(f);
    num_lines = 0;
    for (char *p = poker_data; *p; p++) if (*p == '\n') num_lines++;
    lines = malloc(num_lines * sizeof(char*));
    int li = 0; lines[li++] = poker_data;
    for (char *p = poker_data; *p; p++)
        if (*p == '\n') { *p = '\0'; if (li < num_lines && *(p+1)) lines[li++] = p+1; }
}

long long solve(void) {
    static int inited = 0;
    if (!inited) { load_data(); inited = 1; }
    int wins = 0;
    for (int i = 0; i < num_lines; i++) {
        char c1[5][3], c2[5][3];
        sscanf(lines[i], "%2s %2s %2s %2s %2s %2s %2s %2s %2s %2s",
               c1[0],c1[1],c1[2],c1[3],c1[4], c2[0],c2[1],c2[2],c2[3],c2[4]);
        Hand h1, h2; parse_hand(&h1, c1); parse_hand(&h2, c2);
        if (hand_beats(&h1, &h2)) wins++;
    }
    return wins;
}

#include "../bench.h"
int main(void) { euler_bench(54, solve); return 0; }
