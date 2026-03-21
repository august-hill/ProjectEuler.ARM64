// Problem 100: Arranged Probability
// Find blue discs for first arrangement with over 10^12 total discs
// where P(two blue) = 1/2.
// Recurrence: b' = 3b + 2n - 2, n' = 4b + 3n - 3
// Answer: 756872327473

.global _solve
.align 4

_solve:
    // b = 15, n = 21
    mov x0, #15              // b
    mov x1, #21              // n

    // limit = 10^12 = 0xE8_D4A5_1000
    movz x2, #0x1000
    movk x2, #0xD4A5, lsl #16
    movk x2, #0x00E8, lsl #32

.L100_loop:
    cmp x1, x2
    b.gt .L100_done

    // new_b = 3*b + 2*n - 2
    mov x3, #3
    mul x3, x3, x0          // 3*b
    mov x4, #2
    mul x4, x4, x1          // 2*n
    add x3, x3, x4          // 3*b + 2*n
    sub x3, x3, #2          // 3*b + 2*n - 2

    // new_n = 4*b + 3*n - 3
    mov x4, #4
    mul x4, x4, x0          // 4*b
    mov x5, #3
    mul x5, x5, x1          // 3*n
    add x4, x4, x5          // 4*b + 3*n
    sub x4, x4, #3          // 4*b + 3*n - 3

    mov x0, x3               // b = new_b
    mov x1, x4               // n = new_n
    b .L100_loop

.L100_done:
    // Return b (already in x0)
    ret
