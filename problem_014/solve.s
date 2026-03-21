// Problem 014: Longest Collatz Sequence
// Find starting number under 1 million with longest Collatz chain.
// Answer: 837799
//
// Algorithm: Brute force - compute chain length for each n < 1000000.

.global _solve
.align 4

.set LIMIT, 1000000

// long long solve(void)
_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!

    mov     x19, #0              // x19 = best_n
    mov     x20, #0              // x20 = best_len
    mov     x21, #1              // x21 = n (loop counter)

    movz    x22, #(LIMIT & 0xFFFF)
    movk    x22, #(LIMIT >> 16), lsl #16  // x22 = LIMIT

.Lmain_loop:
    cmp     x21, x22
    b.ge    .Lmain_done

    // Compute collatz_length(n)
    mov     x1, x21              // x1 = current value
    mov     x2, #1               // x2 = length

.Lcollatz:
    cmp     x1, #1
    b.eq    .Lcollatz_done

    tst     x1, #1               // check if even
    b.ne    .Lodd
    lsr     x1, x1, #1          // n /= 2
    b       .Lcollatz_inc
.Lodd:
    // n = 3*n + 1
    add     x1, x1, x1, lsl #1  // x1 = 3*n
    add     x1, x1, #1          // x1 = 3*n + 1
.Lcollatz_inc:
    add     x2, x2, #1
    b       .Lcollatz

.Lcollatz_done:
    cmp     x2, x20
    b.le    .Lnot_better
    mov     x20, x2              // best_len = length
    mov     x19, x21             // best_n = n

.Lnot_better:
    add     x21, x21, #1
    b       .Lmain_loop

.Lmain_done:
    mov     x0, x19

    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
