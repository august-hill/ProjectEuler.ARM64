// Problem 012: Highly Divisible Triangular Number
// Find the first triangle number with over 500 divisors.
// Answer: 76576500
//
// Algorithm: For each n, compute triangle = n*(n+1)/2, count divisors
// by trial division up to sqrt(n).

.global _solve
.align 4

.set TARGET, 500

// long long solve(void)
_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!

    mov     x19, #1              // x19 = n

.Lmain_loop:
    // triangle = n * (n+1) / 2
    add     x1, x19, #1
    mul     x1, x19, x1
    lsr     x1, x1, #1          // x1 = triangle

    // Count divisors of triangle
    // Integer sqrt approximation: start from 1, count pairs
    mov     x2, #0              // x2 = count
    mov     x3, #1              // x3 = i

.Ldiv_loop:
    mul     x4, x3, x3          // i*i
    cmp     x4, x1
    b.gt    .Ldiv_done

    // if triangle % i == 0
    udiv    x5, x1, x3
    msub    x6, x5, x3, x1      // x6 = triangle % i
    cbnz    x6, .Ldiv_next

    cmp     x4, x1              // if i*i == triangle
    b.ne    .Ldiv_pair
    add     x2, x2, #1          // count++ (perfect square)
    b       .Ldiv_next
.Ldiv_pair:
    add     x2, x2, #2          // count += 2

.Ldiv_next:
    add     x3, x3, #1
    b       .Ldiv_loop

.Ldiv_done:
    cmp     x2, #TARGET
    b.gt    .Lfound

    add     x19, x19, #1
    b       .Lmain_loop

.Lfound:
    // Return triangle = n*(n+1)/2
    add     x0, x19, #1
    mul     x0, x19, x0
    lsr     x0, x0, #1

    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
