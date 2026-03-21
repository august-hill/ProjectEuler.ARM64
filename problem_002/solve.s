// Problem 002: Even Fibonacci Numbers
// Find the sum of all even-valued Fibonacci terms below 4 million.
// Answer: 4613732
//
// Algorithm: Even recurrence E(n) = 4*E(n-1) + E(n-2), starting a=2, b=8.

.global _solve
.align 4

.set LIMIT, 4000000

// long long solve(void)
_solve:
    // No callee-saved registers needed; leaf function
    mov     x0, #0              // x0 = sum
    mov     x1, #2              // x1 = a
    movz    x2, #8              // x2 = b
    movz    x3, #(LIMIT & 0xFFFF)
    movk    x3, #(LIMIT >> 16), lsl #16  // x3 = 4000000

.Lloop:
    cmp     x1, x3
    b.ge    .Ldone
    add     x0, x0, x1          // sum += a
    // temp = 4*b + a
    lsl     x4, x2, #2          // x4 = 4*b
    add     x4, x4, x1          // x4 = 4*b + a
    mov     x1, x2              // a = b
    mov     x2, x4              // b = temp
    b       .Lloop

.Ldone:
    ret
