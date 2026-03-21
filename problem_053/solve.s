// Problem 053: Combinatoric Selections
// Count C(n,r) > 1,000,000 for 1 <= n <= 100.
// Answer: 4075

.global _solve
.align 4

.set LIMIT, 1000000
.set ROWS, 101

// Uses Pascal's triangle row by row.
// prev and curr arrays of 102 longs on stack.

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!

    // Allocate 2 arrays of 102 longs = 2 * 102 * 8 = 1632 bytes
    // prev = sp, curr = sp + 816
    .set ARR_SIZE, 816
    sub     sp, sp, #(ARR_SIZE * 2)
    mov     x19, sp              // x19 = prev
    add     x20, sp, #ARR_SIZE   // x20 = curr

    // Zero out prev
    mov     x0, x19
    mov     x1, #0
    mov     x2, #ARR_SIZE
    bl      _memset

    // prev[0] = 1
    mov     x0, #1
    str     x0, [x19]

    mov     x21, #0             // count = 0
    mov     x22, #1             // n = 1

.L53_n_loop:
    cmp     x22, #100
    b.gt    .L53_done

    // Zero out curr
    mov     x0, x20
    mov     x1, #0
    mov     x2, #ARR_SIZE
    bl      _memset

    // curr[0] = 1
    mov     x0, #1
    str     x0, [x20]

    mov     x23, #1             // r = 1
.L53_r_loop:
    cmp     x23, x22
    b.gt    .L53_r_done

    // curr[r] = prev[r-1] + prev[r]
    sub     x0, x23, #1
    ldr     x1, [x19, x0, lsl #3]  // prev[r-1]
    ldr     x2, [x19, x23, lsl #3] // prev[r]
    add     x3, x1, x2

    // Cap at LIMIT+1
    mov     x4, #16961
    movk    x4, #15, lsl #16         // x4 = 1000001
    cmp     x3, x4
    b.lt    .L53_no_cap
    mov     x3, x4              // cap at LIMIT+1
    add     x21, x21, #1        // count++
.L53_no_cap:
    str     x3, [x20, x23, lsl #3]
    add     x23, x23, #1
    b       .L53_r_loop

.L53_r_done:
    // Copy curr to prev (swap pointers)
    mov     x0, x19
    mov     x1, x20
    mov     x2, #ARR_SIZE
    bl      _memcpy

    add     x22, x22, #1
    b       .L53_n_loop

.L53_done:
    mov     x0, x21
    add     sp, sp, #(ARR_SIZE * 2)

    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
