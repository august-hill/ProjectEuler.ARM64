// Problem 041: Pandigital Prime
// Find the largest n-digit pandigital prime.
// Answer: 7652413

.global _solve
.global _malloc
.global _free
.align 4

.set MAX_PANDIGITAL, 7654321

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!

    // Allocate sieve: MAX_PANDIGITAL + 1 bytes
    mov     x0, #MAX_PANDIGITAL
    add     x0, x0, #1
    bl      _malloc
    mov     x19, x0

    // Initialize to 1
    mov     x1, x19
    mov     x2, #MAX_PANDIGITAL
    add     x2, x2, #1
    mov     w3, #1
.Linit:
    strb    w3, [x1], #1
    subs    x2, x2, #1
    b.ne    .Linit
    strb    wzr, [x19]
    strb    wzr, [x19, #1]

    // Sieve
    mov     x20, #2
.Lsieve_outer:
    mul     x1, x20, x20
    mov     x2, #MAX_PANDIGITAL
    cmp     x1, x2
    b.gt    .Lsieve_done
    ldrb    w3, [x19, x20]
    cbz     w3, .Lsieve_next
    mov     x21, x1
.Lsieve_inner:
    cmp     x21, x2
    b.gt    .Lsieve_done_inner
    strb    wzr, [x19, x21]
    add     x21, x21, x20
    b       .Lsieve_inner
.Lsieve_done_inner:
.Lsieve_next:
    add     x20, x20, #1
    b       .Lsieve_outer
.Lsieve_done:

    // Search from MAX_PANDIGITAL down
    mov     x20, #MAX_PANDIGITAL
    mov     x22, #0                  // result
    mov     x10, #10

.Lsearch:
    cmp     x20, #2
    b.lt    .Lsearch_done

    ldrb    w3, [x19, x20]
    cbz     w3, .Lsearch_next

    // is_pandigital check
    // digits[10] = {1,0,0,0,0,0,0,0,1,1} initially (0,8,9 marked as used)
    // For the C version: digits[0]=true, digits[8]=true, digits[9]=true (pre-marked)
    // Then extract digits, mark them. Check no duplicates and all 1..k present.
    mov     x1, x20
    mov     x2, #0                   // bitmask of digits seen
    mov     x3, #0                   // k = digit count

.Lextract:
    cbz     x1, .Lcheck_pan
    udiv    x4, x1, x10
    msub    x5, x4, x10, x1         // digit
    mov     x6, #1
    lsl     x6, x6, x5
    tst     x2, x6
    b.ne    .Lsearch_next            // duplicate digit
    orr     x2, x2, x6
    add     x3, x3, #1
    mov     x1, x4
    b       .Lextract

.Lcheck_pan:
    // Check digit 0 is not present
    tst     x2, #1
    b.ne    .Lsearch_next

    // Check all digits 1..k are present
    // Build expected mask: bits 1..k set
    mov     x4, #0
    mov     x5, #1
.Lbuild_mask:
    cmp     x5, x3
    b.gt    .Lbuild_done
    mov     x6, #1
    lsl     x6, x6, x5
    orr     x4, x4, x6
    add     x5, x5, #1
    b       .Lbuild_mask
.Lbuild_done:
    cmp     x2, x4
    b.ne    .Lsearch_next

    // Found pandigital prime
    mov     x22, x20
    b       .Lsearch_done

.Lsearch_next:
    sub     x20, x20, #1
    b       .Lsearch
.Lsearch_done:

    mov     x20, x22                 // save result

    mov     x0, x19
    bl      _free

    mov     x0, x20

    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
