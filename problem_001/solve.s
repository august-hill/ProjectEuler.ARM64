// Problem 1: Multiples of 3 and 5
// Find the sum of all multiples of 3 or 5 below 1000.
// Answer: 233168

.global _solve
.align 4

_solve:
    mov x0, #0              // sum = 0
    mov x1, #1              // i = 1
    mov x2, #1000           // limit

.L1_loop:
    cmp x1, x2
    b.ge .L1_done

    // Check if divisible by 3
    mov x3, #3
    udiv x4, x1, x3
    msub x5, x4, x3, x1    // x5 = i % 3
    cbz x5, .L1_add

    // Check if divisible by 5
    mov x3, #5
    udiv x4, x1, x3
    msub x5, x4, x3, x1    // x5 = i % 5
    cbz x5, .L1_add

    b .L1_next

.L1_add:
    add x0, x0, x1          // sum += i

.L1_next:
    add x1, x1, #1          // i++
    b .L1_loop

.L1_done:
    ret
