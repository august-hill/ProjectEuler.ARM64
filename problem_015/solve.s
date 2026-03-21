// Problem 015: Lattice Paths
// Count routes through 20x20 grid (only right/down moves).
// Answer: 137846528820
//
// Algorithm: C(2n, n) computed by interleaving multiply/divide.

.global _solve
.align 4

.set N, 20

// long long solve(void)
_solve:
    mov     x0, #1              // result = 1
    mov     x1, #1              // i = 1

.Lloop:
    cmp     x1, #N
    b.gt    .Ldone

    // result = result * (N + i) / i
    add     x2, x1, #N          // N + i
    mul     x0, x0, x2          // result * (N + i)
    udiv    x0, x0, x1          // / i

    add     x1, x1, #1
    b       .Lloop

.Ldone:
    ret
