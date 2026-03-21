// Problem 71: Ordered Fractions
// Find numerator of fraction immediately left of 3/7 with d <= 1,000,000.
// Answer: 428570

.global _solve
.align 4

_solve:
    mov x0, #0              // best_n = 0
    mov x1, #1              // best_d = 1
    mov x2, #2              // d = 2
    movz x3, #0x4240
    movk x3, #0x000F, lsl #16   // limit = 1000000 (0xF4240)
    mov x4, #3              // constant 3
    mov x5, #7              // constant 7
    mov x6, #1              // constant 1

.L71_loop:
    cmp x2, x3
    b.gt .L71_done

    // n = (3 * d - 1) / 7
    mul x7, x4, x2          // x7 = 3 * d
    sub x7, x7, x6          // x7 = 3 * d - 1
    udiv x7, x7, x5         // x7 = n = (3*d - 1) / 7

    // Check: n * best_d > best_n * d  (cross multiply)
    mul x8, x7, x1          // x8 = n * best_d
    mul x9, x0, x2          // x9 = best_n * d
    cmp x8, x9
    b.le .L71_next

    mov x0, x7              // best_n = n
    mov x1, x2              // best_d = d

.L71_next:
    add x2, x2, #1          // d++
    b .L71_loop

.L71_done:
    ret
