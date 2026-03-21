// Problem 044: Pentagon Numbers
// Find pair of pentagonal numbers where sum and difference are both pentagonal.
// Answer: 5482660

.global _solve
.align 4

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!

    // Allocate pentagonal array: 3000 * 8 = 24000 bytes
    mov     x0, #24000
    bl      _malloc
    mov     x19, x0                  // p[] array

    // Generate pentagonal numbers: p[n] = n*(3n-1)/2
    mov     x1, #0
.L44_gen:
    cmp     x1, #3000
    b.ge    .L44_gen_done
    mov     x2, #3
    mul     x2, x1, x2
    sub     x2, x2, #1
    mul     x2, x1, x2
    lsr     x2, x2, #1
    str     x2, [x19, x1, lsl #3]
    add     x1, x1, #1
    b       .L44_gen
.L44_gen_done:

    mov     x20, #1                  // j
.L44_j_loop:
    cmp     x20, #3000
    b.ge    .L44_not_found

    mov     x21, x20
    add     x21, x21, #1            // k = j + 1
.L44_k_loop:
    cmp     x21, #3000
    b.ge    .L44_k_done

    ldr     x22, [x19, x20, lsl #3] // p[j]
    ldr     x23, [x19, x21, lsl #3] // p[k]
    add     x24, x22, x23           // sum

    // Binary search for sum
    mov     x1, #0
    mov     x2, #2999
.L44_bs_sum:
    cmp     x1, x2
    b.gt    .L44_k_next
    add     x3, x1, x2
    lsr     x3, x3, #1
    ldr     x4, [x19, x3, lsl #3]
    cmp     x4, x24
    b.eq    .L44_sum_found
    b.lt    .L44_bs_sum_lt
    sub     x2, x3, #1
    b       .L44_bs_sum
.L44_bs_sum_lt:
    add     x1, x3, #1
    b       .L44_bs_sum
.L44_sum_found:

    // Binary search for diff
    sub     x24, x23, x22
    mov     x1, #0
    mov     x2, #2999
.L44_bs_diff:
    cmp     x1, x2
    b.gt    .L44_k_next
    add     x3, x1, x2
    lsr     x3, x3, #1
    ldr     x4, [x19, x3, lsl #3]
    cmp     x4, x24
    b.eq    .L44_diff_found
    b.lt    .L44_bs_diff_lt
    sub     x2, x3, #1
    b       .L44_bs_diff
.L44_bs_diff_lt:
    add     x1, x3, #1
    b       .L44_bs_diff
.L44_diff_found:
    mov     x20, x24
    mov     x0, x19
    bl      _free
    mov     x0, x20
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

.L44_k_next:
    add     x21, x21, #1
    b       .L44_k_loop
.L44_k_done:
    add     x20, x20, #1
    b       .L44_j_loop

.L44_not_found:
    mov     x20, #0
    mov     x0, x19
    bl      _free
    mov     x0, x20
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
