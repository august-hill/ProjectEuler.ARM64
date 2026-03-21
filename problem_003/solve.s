// Problem 003: Largest Prime Factor
// Find the largest prime factor of 600851475143.
// Answer: 6857
//
// Algorithm: Optimized trial division using 6k+/-1 pattern.

.global _solve
.align 4

// long long solve(void)
_solve:
    // Load n = 600851475143 = 0x8BE589EAC7 into x1
    movz    x1, #0xEAC7
    movk    x1, #0xE589, lsl #16
    movk    x1, #0x8B, lsl #32      // x1 = n = 600851475143
    mov     x0, #1                   // x0 = largest_factor

    // Check factor of 2
.Lcheck2:
    tst     x1, #1                   // n & 1
    b.ne    .Lcheck3
    mov     x0, #2                   // largest_factor = 2
    lsr     x1, x1, #1              // n /= 2
    b       .Lcheck2

    // Check factor of 3
.Lcheck3:
    mov     x3, #3
.Lloop3:
    udiv    x4, x1, x3              // x4 = n / 3
    msub    x5, x4, x3, x1          // x5 = n - (n/3)*3 = n % 3
    cbnz    x5, .Lloop6k
    mov     x0, #3                   // largest_factor = 3
    mov     x1, x4                   // n = n / 3
    b       .Lloop3

    // Check factors of form 6k+/-1, starting at i=5
.Lloop6k:
    mov     x2, #5                   // x2 = i

.Lcheck_i:
    mul     x3, x2, x2              // i*i
    cmp     x3, x1
    b.gt    .Lcheck_remainder

    // Check n % i
.Ldiv_i:
    udiv    x4, x1, x2
    msub    x5, x4, x2, x1          // x5 = n % i
    cbnz    x5, .Lcheck_i2
    mov     x0, x2                   // largest_factor = i
    mov     x1, x4                   // n /= i
    b       .Ldiv_i

.Lcheck_i2:
    // Check n % (i+2)
    add     x3, x2, #2              // x3 = i+2
.Ldiv_i2:
    udiv    x4, x1, x3
    msub    x5, x4, x3, x1          // x5 = n % (i+2)
    cbnz    x5, .Lnext_i
    mov     x0, x3                   // largest_factor = i+2
    mov     x1, x4                   // n /= (i+2)
    b       .Ldiv_i2

.Lnext_i:
    add     x2, x2, #6              // i += 6
    b       .Lcheck_i

.Lcheck_remainder:
    cmp     x1, #1
    b.le    .Ldone
    mov     x0, x1                   // largest_factor = n

.Ldone:
    ret
