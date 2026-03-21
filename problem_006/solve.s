// Problem 006: Sum Square Difference
// Find the difference between the square of the sum and the sum of squares
// for the first 100 natural numbers.
// Answer: 25164150
//
// Algorithm: Direct formula: n*(n-1)*(n+1)*(3*n+2)/12

.global _solve
.align 4

.set N, 100

// long long solve(void)
_solve:
    mov     x0, #N              // n = 100
    sub     x1, x0, #1          // n-1 = 99
    add     x2, x0, #1          // n+1 = 101
    mov     x3, #3
    mul     x3, x3, x0
    add     x3, x3, #2          // 3*n+2 = 302

    mul     x0, x0, x1          // n*(n-1)
    mul     x0, x0, x2          // *( n+1)
    mul     x0, x0, x3          // *(3*n+2)
    mov     x1, #12
    udiv    x0, x0, x1          // / 12
    ret
