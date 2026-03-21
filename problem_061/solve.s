// Problem 061: Cyclical Figurate Numbers
// Find sum of the only ordered set of six cyclic 4-digit figurate numbers.
// Answer: 28684

.global _solve
.align 4

// by_prefix[6][100][10] - figurate numbers indexed by type and first 2 digits
// by_prefix_count[6][100]
// Total: 6*100*10*4 = 24000 bytes for values, 6*100*4 = 2400 for counts

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!

    // Allocate arrays
    // by_prefix: 6 * 100 * 10 * 4 = 24000 bytes
    // by_prefix_count: 6 * 100 * 4 = 2400 bytes
    // chain: 6 * 8 = 48 bytes
    // used_type: 6 * 4 = 24 bytes (round to 32)
    // Total: ~26512, round to 26528
    mov     x0, #26528
    bl      _malloc
    mov     x19, x0             // base pointer

    // x19 + 0: by_prefix (24000 bytes)
    // x19 + 24000: by_prefix_count (2400 bytes)
    // x19 + 26400: chain (48 bytes)
    // x19 + 26448: used_type (32 bytes)

    // Zero everything
    mov     x0, x19
    mov     x1, #0
    mov     x2, #26528
    bl      _memset

    // init_figurates
    mov     x20, #3             // s = 3
.L61_init_s:
    cmp     x20, #9
    b.ge    .L61_init_done
    sub     x21, x20, #3        // idx = s - 3
    mov     x22, #1             // n = 1
.L61_init_n:
    // val = n * ((s-2)*n - (s-4)) / 2
    sub     x0, x20, #2         // s-2
    mul     x0, x0, x22         // (s-2)*n
    sub     x1, x20, #4         // s-4
    sub     x0, x0, x1          // (s-2)*n - (s-4)
    mul     x0, x22, x0         // n * (...)
    asr     x0, x0, #1          // / 2

    mov     x1, #10000
    cmp     x0, x1
    b.ge    .L61_next_s

    mov     x1, #1000
    cmp     x0, x1
    b.lt    .L61_next_n

    // prefix = val / 100
    mov     x1, #100
    udiv    x2, x0, x1          // prefix

    // count = by_prefix_count[idx][prefix]
    // offset = (idx * 100 + prefix) * 4
    mov     x3, #100
    mul     x3, x21, x3
    add     x3, x3, x2          // idx*100 + prefix
    add     x4, x19, #24000     // by_prefix_count base
    ldr     w5, [x4, x3, lsl #2]

    cmp     w5, #10
    b.ge    .L61_next_n

    // by_prefix[idx][prefix][count] = val
    // offset = (idx * 100 * 10 + prefix * 10 + count) * 4
    mov     x6, #1000
    mul     x6, x21, x6         // idx * 1000
    mov     x7, #10
    mul     x7, x2, x7          // prefix * 10
    add     x6, x6, x7
    add     x6, x6, x5          // + count
    str     w0, [x19, x6, lsl #2]

    add     w5, w5, #1
    str     w5, [x4, x3, lsl #2]

.L61_next_n:
    add     x22, x22, #1
    b       .L61_init_n
.L61_next_s:
    add     x20, x20, #1
    b       .L61_init_s
.L61_init_done:

    // Clear used_type
    add     x0, x19, #26448
    mov     x1, #0
    mov     x2, #32
    bl      _memset

    // Search
    mov     x0, #0              // depth
    bl      .L61_search
    mov     x20, x0             // result

    // Free
    mov     x0, x19
    bl      _free
    mov     x0, x20

    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

// search(x0=depth) -> x0 (sum or 0)
// Uses x19 as base pointer for all arrays
.L61_search:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!

    mov     x20, x0             // depth

    cmp     x20, #6
    b.ne    .L61_not_base

    // Base case: check chain[5] % 100 == chain[0] / 100
    add     x0, x19, #26400     // chain base
    ldr     w1, [x0, #20]       // chain[5]
    ldr     w2, [x0]            // chain[0]
    mov     w3, #100
    udiv    w4, w1, w3
    msub    w5, w4, w3, w1      // chain[5] % 100
    udiv    w6, w2, w3          // chain[0] / 100
    cmp     w5, w6
    b.ne    .L61_ret_zero

    // Sum all chain values
    mov     x0, #0
    add     x1, x19, #26400
    mov     x2, #0
.L61_sum_chain:
    cmp     x2, #6
    b.ge    .L61_ret_sum
    ldr     w3, [x1, x2, lsl #2]
    add     x0, x0, x3
    add     x2, x2, #1
    b       .L61_sum_chain
.L61_ret_sum:
    b       .L61_ret

.L61_ret_zero:
    mov     x0, #0
    b       .L61_ret

.L61_not_base:
    mov     x21, #0             // t = 0
.L61_type_loop:
    cmp     x21, #6
    b.ge    .L61_ret_zero

    // Check used_type[t]
    add     x0, x19, #26448
    ldr     w1, [x0, x21, lsl #2]
    cbnz    w1, .L61_next_type

    // Mark used
    mov     w1, #1
    str     w1, [x0, x21, lsl #2]

    cbnz    x20, .L61_not_depth0

    // depth == 0: iterate all prefixes and values
    mov     x22, #10            // prefix
.L61_prefix_loop:
    cmp     x22, #100
    b.ge    .L61_unmark

    // count = by_prefix_count[t][prefix]
    mov     x0, #100
    mul     x0, x21, x0
    add     x0, x0, x22
    add     x1, x19, #24000
    ldr     w23, [x1, x0, lsl #2]

    mov     x24, #0             // k
.L61_val_loop0:
    cmp     x24, x23
    b.ge    .L61_next_prefix

    // val = by_prefix[t][prefix][k]
    mov     x0, #1000
    mul     x0, x21, x0
    mov     x1, #10
    mul     x1, x22, x1
    add     x0, x0, x1
    add     x0, x0, x24
    ldr     w25, [x19, x0, lsl #2]

    // Check val % 100 >= 10
    mov     w0, #100
    udiv    w1, w25, w0
    msub    w2, w1, w0, w25
    cmp     w2, #10
    b.lt    .L61_next_val0

    // chain[0] = val
    add     x0, x19, #26400
    str     w25, [x0]

    mov     x0, #1
    bl      .L61_search
    cbnz    x0, .L61_found

.L61_next_val0:
    add     x24, x24, #1
    b       .L61_val_loop0

.L61_next_prefix:
    add     x22, x22, #1
    b       .L61_prefix_loop
    b       .L61_unmark

.L61_not_depth0:
    // needed = chain[depth-1] % 100
    add     x0, x19, #26400
    sub     x1, x20, #1
    ldr     w22, [x0, x1, lsl #2]  // chain[depth-1]
    mov     w0, #100
    udiv    w1, w22, w0
    msub    w22, w1, w0, w22    // needed = chain[depth-1] % 100

    cmp     w22, #10
    b.lt    .L61_unmark

    // count = by_prefix_count[t][needed]
    mov     x0, #100
    mul     x0, x21, x0
    add     x0, x0, x22
    add     x1, x19, #24000
    ldr     w23, [x1, x0, lsl #2]

    mov     x24, #0
.L61_val_loop:
    cmp     x24, x23
    b.ge    .L61_unmark

    mov     x0, #1000
    mul     x0, x21, x0
    mov     x1, #10
    mul     x1, x22, x1
    add     x0, x0, x1
    add     x0, x0, x24
    ldr     w25, [x19, x0, lsl #2]

    // Check val % 100 >= 10 (unless depth == 5)
    mov     w0, #100
    udiv    w1, w25, w0
    msub    w2, w1, w0, w25
    cmp     x20, #5
    b.eq    .L61_skip_suffix_check
    cmp     w2, #10
    b.lt    .L61_next_val
.L61_skip_suffix_check:

    // chain[depth] = val
    add     x0, x19, #26400
    str     w25, [x0, x20, lsl #2]

    add     x0, x20, #1
    bl      .L61_search
    cbnz    x0, .L61_found

.L61_next_val:
    add     x24, x24, #1
    b       .L61_val_loop

.L61_unmark:
    add     x0, x19, #26448
    str     wzr, [x0, x21, lsl #2]

.L61_next_type:
    add     x21, x21, #1
    b       .L61_type_loop

    mov     x0, #0
    b       .L61_ret

.L61_found:
    // Unmark before returning
    add     x1, x19, #26448
    str     wzr, [x1, x21, lsl #2]

.L61_ret:
    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
