// Problem 026: Reciprocal Cycles
// Find the value of d < 1000 for which 1/d contains the longest recurring cycle.
// Answer: 983

.global _solve
.align 4

// cycle_length(d) in x0, returns cycle length in x0
// Uses x9-x15 as scratch (caller-saved within our function)
// We inline this as a loop within _solve

// long long solve(void)
_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!

    // Allocate seen[1000] on stack (1000 * 4 = 4000 bytes, round to 4000, 16-aligned = 4000)
    // Actually we need 1000 ints = 4000 bytes. Round up to 4016 for 16-byte alignment.
    sub     sp, sp, #4016
    mov     x23, sp                  // x23 = seen array base

    mov     x19, #0                  // max_cycle = 0
    mov     x20, #0                  // result = 0
    mov     x21, #2                  // d = 2

.Ld_loop:
    cmp     x21, #1000
    b.ge    .Ld_done

    // Initialize seen[] to -1
    mov     x0, x23
    mov     x1, #1000
    mov     w2, #-1                  // 0xFFFFFFFF
.Linit_seen:
    str     w2, [x0], #4
    subs    x1, x1, #1
    b.ne    .Linit_seen

    // cycle_length(d=x21)
    mov     x9, #1                   // remainder = 1
    mov     x10, #0                  // position = 0

.Lcycle_loop:
    cbz     x9, .Lcycle_zero         // if remainder == 0, return 0

    // if seen[remainder] >= 0
    ldr     w11, [x23, x9, lsl #2]   // seen[remainder]
    cmn     w11, #1                  // compare with -1 (cmn is add, so -1 + 1 = 0 sets Z)
    b.eq    .Lcycle_not_seen         // if seen[remainder] == -1, not seen yet
    // Actually we need >= 0 check
    tbnz    w11, #31, .Lcycle_not_seen  // if bit 31 set (negative), not seen
    // return position - seen[remainder]
    sub     x22, x10, x11            // cycle length
    b       .Lcycle_done

.Lcycle_not_seen:
    // seen[remainder] = position
    str     w10, [x23, x9, lsl #2]
    // remainder = (remainder * 10) % d
    mov     x12, #10
    mul     x9, x9, x12
    udiv    x13, x9, x21
    msub    x9, x13, x21, x9        // remainder = remainder - (remainder/d)*d
    add     x10, x10, #1            // position++
    b       .Lcycle_loop

.Lcycle_zero:
    mov     x22, #0                  // cycle length = 0

.Lcycle_done:
    // x22 = cycle length for current d
    cmp     x22, x19
    b.le    .Lno_update
    mov     x19, x22                 // max_cycle = cycle
    mov     x20, x21                 // result = d
.Lno_update:
    add     x21, x21, #1
    b       .Ld_loop

.Ld_done:
    mov     x0, x20                  // return result

    add     sp, sp, #4016
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
