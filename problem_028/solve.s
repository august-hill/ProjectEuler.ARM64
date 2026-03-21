// Problem 028: Number Spiral Diagonals
// What is the sum of the numbers on the diagonals in a 1001 by 1001 spiral?
// Answer: 669171001

.global _solve
.align 4

// long long solve(void)
_solve:
    // sum = 1 (center)
    mov     x0, #1

    // for n = 3; n <= 1001; n += 2
    mov     x1, #3                   // n

.Lloop:
    cmp     x1, #1001
    b.gt    .Ldone

    // sum += 4*n*n - 6*(n-1)
    mul     x2, x1, x1              // n*n
    lsl     x3, x2, #2              // 4*n*n
    sub     x4, x1, #1              // n-1
    mov     x5, #6
    mul     x4, x4, x5              // 6*(n-1)
    sub     x3, x3, x4              // 4*n*n - 6*(n-1)
    add     x0, x0, x3              // sum += ...

    add     x1, x1, #2
    b       .Lloop

.Ldone:
    ret
