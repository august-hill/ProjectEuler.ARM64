// Problem 039: Integer Right Triangles
// For which value of p <= 1000, is the number of solutions maximised?
// Answer: 840

.global _solve
.align 4

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!

    // solutions[1001] on stack (1004 * 4 = 4016)
    sub     sp, sp, #4016
    mov     x19, sp

    // Zero out solutions[]
    mov     x0, x19
    mov     x1, #1004
.L39_zero:
    str     wzr, [x0], #4
    subs    x1, x1, #1
    b.ne    .L39_zero

    // for a = 1; a < 334
    mov     x20, #1
.L39_a_loop:
    cmp     x20, #334
    b.ge    .L39_a_done

    // for b = a; b < 500
    mov     x21, x20
.L39_b_loop:
    cmp     x21, #500
    b.ge    .L39_b_done

    // c_squared = a*a + b*b
    mul     x1, x20, x20
    madd    x23, x21, x21, x1   // x23 = c_squared

    // Integer sqrt: start from b+1, find c where c*c == c_squared
    // Actually, use a better approach: start from b, go up
    mov     x3, x21              // c starts at b
.L39_sqrt_loop:
    mul     x4, x3, x3
    cmp     x4, x23
    b.eq    .L39_found_sqrt
    b.hi    .L39_no_sqrt         // c*c > c_squared, no solution
    add     x3, x3, #1
    b       .L39_sqrt_loop

.L39_found_sqrt:
    // c = x3, p = a + b + c
    add     x5, x20, x21
    add     x5, x5, x3          // p
    cmp     x5, #1000
    b.gt    .L39_no_sqrt
    ldr     w6, [x19, x5, lsl #2]
    add     w6, w6, #1
    str     w6, [x19, x5, lsl #2]

.L39_no_sqrt:
    add     x21, x21, #1
    b       .L39_b_loop
.L39_b_done:
    add     x20, x20, #1
    b       .L39_a_loop
.L39_a_done:

    // Find p with max solutions
    mov     w20, #0              // max_solutions
    mov     x22, #0              // result
    mov     x21, #1
.L39_find_max:
    cmp     x21, #1001
    b.ge    .L39_find_done
    ldr     w1, [x19, x21, lsl #2]
    cmp     w1, w20
    b.le    .L39_find_next
    mov     w20, w1
    mov     x22, x21
.L39_find_next:
    add     x21, x21, #1
    b       .L39_find_max
.L39_find_done:

    mov     x0, x22
    add     sp, sp, #4016
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
