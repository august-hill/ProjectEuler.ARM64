// Problem 94: Almost Equilateral Triangles
// Sum of perimeters of almost equilateral triangles with integral area, perimeter <= 10^9.
// Answer: 518408346

.global _solve
.align 4

_solve:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]

    mov x19, #0              // total

    // limit = 1000000000
    movz x22, #0x3B9A, lsl #16
    movk x22, #0xCA00        // 1000000000

    // Case 1: sides a, a, a+1. Perimeter = 3a+1.
    // Recurrence: a_{n+1} = 14*a_n - a_{n-1} - 4
    mov x20, #1              // a_prev = 1
    mov x21, #5              // a_curr = 5

.L94_case1:
    // perimeter = 3*a_curr + 1
    mov x0, #3
    mul x0, x0, x21
    add x0, x0, #1
    cmp x0, x22
    b.gt .L94_case2_start

    add x19, x19, x0        // total += perimeter

    // a_next = 14*a_curr - a_prev - 4
    mov x1, #14
    mul x1, x1, x21          // 14 * a_curr
    sub x1, x1, x20          // - a_prev
    sub x1, x1, #4           // - 4
    mov x20, x21             // a_prev = a_curr
    mov x21, x1              // a_curr = a_next
    b .L94_case1

.L94_case2_start:
    // Case 2: sides a, a, a-1. Perimeter = 3a-1.
    // Recurrence: a_{n+1} = 14*a_n - a_{n-1} + 4
    mov x20, #1              // a_prev = 1
    mov x21, #17             // a_curr = 17

.L94_case2:
    // perimeter = 3*a_curr - 1
    mov x0, #3
    mul x0, x0, x21
    sub x0, x0, #1
    cmp x0, x22
    b.gt .L94_done

    add x19, x19, x0        // total += perimeter

    // a_next = 14*a_curr - a_prev + 4
    mov x1, #14
    mul x1, x1, x21
    sub x1, x1, x20
    add x1, x1, #4
    mov x20, x21
    mov x21, x1
    b .L94_case2

.L94_done:
    mov x0, x19

    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret
