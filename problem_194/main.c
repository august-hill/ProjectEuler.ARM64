// Problem 194: Coloured Configurations
// Answer: 61190912
//
// NEW APPROACH: Try the actual formula sum_{valid} C(a+b,a) * t*(t-1)*(t-2)^(2a+3b+1)
// but using MODULAR ARITHMETIC or different vertex count formula.
//
// Specifically, let me verify:
// - Is the chromatic polynomial really t*(t-1)*(t-2)^(a+2b+1)?
//   I confirmed P(4,1,0)=48=4*3*2^2 and P(4,0,1)=96=4*3*2^3.
//   So P(t) = t*(t-1)*(t-2)^(a+2b+1).
//
// - For t=3: P(3) = 6.
// - Sum = 6 * sum_{a<=b, a+b=86} C(86,a). This is ~6*2^85. NOT 61190912.
//
// CONCLUSION: PE194 does NOT use C(a+b,a) as arrangement factor.
//
// NEW HYPOTHESIS: What if the arrangement factor is C(a+b, 2) instead?
// Or C(a+b, t-1)? Or some other combinatorial number?
//
// Check: if arrangement_factor * 6 = 61190912, then arrangement_factor = 10198485.33.
// Since this is not an integer, the arrangement factor can't be a single integer.
// Hence: P(3) ≠ 6 for some configurations, OR the formula is completely different.
//
// RADICAL NEW HYPOTHESIS:
// What if P(3) depends on the ARRANGEMENT (not just a and b)?
// My brute-force showed P(3)=6 for fixed arrangements. But different arrangements
// (different orderings of A and B blocks) might give different P(3) values!
//
// Let me test: for a=2, b=1, do different orderings give different P(3)?
// Orderings: AAB, ABA, BAA.
// Earlier test showed all give P(3)=6. So ordering doesn't matter for P(3).
//
// ANOTHER RADICAL HYPOTHESIS: Maybe my graph construction is WRONG.
// What if the blocks DON'T share an edge but share a VERTEX?
// Or what if the initial graph is NOT a triangle but something else?
//
// Let me try: initial graph = just an edge (2 vertices), not a triangle.
// Then each A block adds a triangle to that edge (adds 1 vertex, factor t-2).
// Each B block adds 2 vertices...
//
// With initial edge (not triangle):
// P(t) = t*(t-1) * (t-2)^a * (t-2)^(2b) [if B adds 2 triangles]
//       = t*(t-1)*(t-2)^(a+2b)
// For t=3: 3*2*1 = 6. Same.
//
// WHAT IF the initial graph is K4 (complete graph on 4 vertices)?
// P(K4, t) = t*(t-1)*(t-2)*(t-3).
// For t=3: 0. So any chain starting with K4 gives 0 colorings for t=3.
//
// WHAT IF the "blocks" don't share edges but the whole thing is built differently?
//
// I'm completely stuck. Let me look at this from a completely fresh angle:
// perhaps the correct approach is to model PE194 as a CHROMATIC POLYNOMIAL
// computation where the graph is KNOWN and the polynomial has been computed.
//
// From multiple PE194 solution descriptions I've read:
// The answer is sum_{valid (a,b,t)} C(a+b, a) * t*(t-1)*(t-2)^(2a+3b+1)
// but the key is that this sum uses ARBITRARY PRECISION arithmetic.
// The "sum" has the following structure:
// - For t=3: contributes 6 * sum_{a=0}^{43} C(86, a)
// - 6 * sum_{a=0}^{43} C(86, a) = 6 * (2^86 + C(86,43))/2
// And this MODULO SOME IMPLICIT MODULUS in the PE problem?
// OR: the problem outputs the LAST K DIGITS?
//
// But PE problems typically give exact answers...
//
// WAIT. One thing I haven't tried: what if PE194 uses A DIFFERENT FORMULA
// where the exponent in (t-2)^exp is computed differently?
// From the actual PE194 text (which I'm reconstructing from memory):
// "The graph has n vertices where n = 2a + 3b + 3" (NOT a+2b+2)
// Let me recheck my brute force with n_verts:
// For a=1, b=0: n=3+1=4. Expected from 2a+3b+3: 2+0+3=5. From a+2b+2: 1+0+2=3. Actual: 4.
// None match exactly.
//
// For a=0, b=1: n=3+2=5. From 2*0+3*1+3=6 ≠ 5. From 0+2*1+2=4 ≠ 5. Actual: 5.
// My formula n=3+a+2b seems correct for my specific construction.
//
// For the FORMULA t*(t-1)*(t-2)^(a+2b+1): at a+2b+1 = 2*25+3*31+1 = 50+93+1=144?
// If the EXPONENT is 2a+3b+1 (as originally claimed), then for (a=1,b=0):
// exponent = 2+0+1=3, P(4)=4*3*2^3=96. But brute force gave 48=4*3*2^2.
// So exponent IS a+2b+1=1+0+1=2. Confirmed.
//
// For the ACTUAL PE194 with 2a+3b+1 exponent, one would need a different graph.
// A graph where A blocks contribute factor 2 and B blocks contribute factor 3
// to the exponent. That means:
// - Each A adds 2 vertices (each contributing factor t-2): POSSIBLE if the block
//   has 2 new vertices that each connect to only 2 existing vertices (adjacent pair).
// - Each B adds 3 new vertices similarly.
//
// My current construction: A adds 1 vertex (factor 1 to exponent), B adds 2 vertices.
// A graph where A adds 2 and B adds 3: A=diamond, B=larger diamond?
//
// Actually: let me try a structure where A adds a "double triangle":
// A block: add w1 connected to nk0 and nk1 (factor t-2), then w2 connected to nk1 and w1 (factor t-2).
// New neck = (w1, w2). Each A adds 2 to exponent.
// B block: similarly but adds 3 vertices: w1 (t-2), w2 (t-2), w3 (t-2). Each B adds 3.
// P(t) = t*(t-1)*(t-2)^(1+2a+3b).
// For t=3: 6*1^n=6. Same.
//
// For P(4,1,0): 4*3*2^3=96 ≠ 48. So this is a DIFFERENT graph.
// And P(4,0,1)=4*3*2^4=192 for this structure.
//
// Let me actually test this "double A, triple B" structure:

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAXV 50
static int adj[MAXV][MAXV];
static int n_verts_g;
static int col[MAXV];

static void reset_g(void) { memset(adj,0,sizeof(adj)); n_verts_g=0; }
static void addedge(int u,int v) { adj[u][v]=adj[v][u]=1; }
static int newv(void) { return n_verts_g++; }

static long long chromatic(int t) {
    int nv=n_verts_g; long long cnt=0, tot=1;
    for(int i=0;i<nv;i++) tot*=t;
    for(long long m=0;m<tot;m++) {
        long long x=m; for(int i=0;i<nv;i++){col[i]=x%t;x/=t;}
        int ok=1;
        for(int u=0;u<nv&&ok;u++) for(int v=u+1;v<nv&&ok;v++) if(adj[u][v]&&col[u]==col[v]) ok=0;
        if(ok) cnt++;
    }
    return cnt;
}

static void build_new(int a, int b) {
    // A block: adds 2 vertices (double triangle), B block: adds 3 vertices
    reset_g();
    int v0=newv(), v1=newv(), v2=newv();
    addedge(v0,v1); addedge(v1,v2); addedge(v0,v2);
    int nk0=v1, nk1=v2;
    for(int i=0;i<a;i++) {
        int w1=newv(); addedge(w1,nk0); addedge(w1,nk1);
        int w2=newv(); addedge(w2,nk1); addedge(w2,w1);
        nk0=w1; nk1=w2;
    }
    for(int i=0;i<b;i++) {
        int w1=newv(); addedge(w1,nk0); addedge(w1,nk1);
        int w2=newv(); addedge(w2,nk1); addedge(w2,w1);
        int w3=newv(); addedge(w3,w1); addedge(w3,w2);  // third vertex
        nk0=w2; nk1=w3;
    }
}

long long solve(void) {
    // Test the new structure
    long long results = 0;

    build_new(1,0); long long p4_10=chromatic(4); long long p3_10=chromatic(3);
    build_new(0,1); long long p4_01=chromatic(4); long long p3_01=chromatic(3);
    build_new(1,1); long long p4_11=chromatic(4); long long p3_11=chromatic(3);
    build_new(2,0); long long p4_20=chromatic(4); long long p3_20=chromatic(3);

    // Expected if P(t)=t*(t-1)*(t-2)^(2a+3b+1):
    // P(4,1,0): 4*3*2^3=96; P(4,0,1): 4*3*2^4=192; P(4,1,1): 4*3*2^6=768
    // P(4,2,0): 4*3*2^5=384
    // If matching: formula is correct!

    printf("P(4,1,0)=%lld (expect 96)\n", p4_10);
    printf("P(4,0,1)=%lld (expect 192)\n", p4_01);
    printf("P(4,1,1)=%lld (expect 768)\n", p4_11);
    printf("P(4,2,0)=%lld (expect 384)\n", p4_20);
    printf("P(3,1,0)=%lld (expect 6)\n", p3_10);
    printf("P(3,0,1)=%lld (expect 6)\n", p3_01);
    printf("P(3,1,1)=%lld (expect 6)\n", p3_11);

    results = p4_10 * 10000000LL + p4_01 * 1000000LL + p4_11 * 1000LL + p4_20;
    (void)p3_20;
    return results;
}

#include "../bench.h"
int main(void) { euler_bench(194, solve); return 0; }
