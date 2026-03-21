// Problem 047: Distinct Prime Factors
// Find first of 4 consecutive integers each with 4 distinct prime factors.
// Answer: 134043

.global _solve
.global _malloc
.global _free
.align 4

.set LIMIT, 150000
.set CONSECUTIVE, 4

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!

    // Allocate sieve for primes up to LIMIT/2 = 75000
    mov     x0, #75001
    bl      _malloc
    mov     x19, x0                  // is_prime sieve

    // Initialize to 1
    mov     x1, x19
    mov     x2, #75001
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
    mov     x2, #75000
    cmp     x1, x2
    b.gt    .Lsieve_done
    ldrb    w3, [x19, x20]
    cbz     w3, .Lsieve_next
    mov     x21, x1
.Lsieve_inner:
    cmp     x21, x2
    b.gt    .Lsieve_next
    strb    wzr, [x19, x21]
    add     x21, x21, x20
    b       .Lsieve_inner
.Lsieve_next:
    add     x20, x20, #1
    b       .Lsieve_outer
.Lsieve_done:

    // Collect primes into array
    // Allocate primes array (at most ~7500 primes under 75000)
    mov     x0, #80000               // 10000 * 8
    bl      _malloc
    mov     x22, x0                  // primes array
    mov     x23, #0                  // prime_count

    mov     x20, #2
.Lcollect:
    cmp     x20, #75001
    b.ge    .Lcollect_done
    ldrb    w1, [x19, x20]
    cbz     w1, .Lcollect_next
    str     x20, [x22, x23, lsl #3]
    add     x23, x23, #1
.Lcollect_next:
    add     x20, x20, #1
    b       .Lcollect
.Lcollect_done:

    // Free sieve (don't need it anymore)
    mov     x0, x19
    bl      _free

    // Search for 4 consecutive with 4 distinct prime factors
    mov     x24, #0                  // consecutive count
    mov     x25, #0                  // result
    mov     x20, #2                  // i

.Li_loop:
    mov     x1, #LIMIT
    cmp     x20, x1
    b.ge    .Li_done

    // count_distinct_prime_factors(i)
    mov     x1, x20                  // n = i
    mov     x26, #0                  // factor count
    mov     x21, #0                  // prime index

.Lfactor_loop:
    cmp     x21, x23
    b.ge    .Lfactor_check_remain
    ldr     x2, [x22, x21, lsl #3]  // p = primes[j]
    mul     x3, x2, x2
    cmp     x3, x1
    b.gt    .Lfactor_check_remain

    // Check if n % p == 0
    udiv    x3, x1, x2
    msub    x4, x3, x2, x1
    cbnz    x4, .Lfactor_next

    // Found a factor
    add     x26, x26, #1
    // Remove all factors of p
.Lremove_factor:
    udiv    x3, x1, x2
    msub    x4, x3, x2, x1
    cbnz    x4, .Lfactor_next
    mov     x1, x3                   // n = n / p
    b       .Lremove_factor

.Lfactor_next:
    add     x21, x21, #1
    b       .Lfactor_loop

.Lfactor_check_remain:
    cmp     x1, #1
    b.le    .Lfactor_done
    add     x26, x26, #1            // remaining n > 1 is a prime factor
.Lfactor_done:

    // Check if factor count == CONSECUTIVE (4)
    cmp     x26, #CONSECUTIVE
    b.ne    .Lreset_count
    add     x24, x24, #1
    cmp     x24, #CONSECUTIVE
    b.eq    .Lfound_result
    b       .Li_next

.Lreset_count:
    mov     x24, #0
.Li_next:
    add     x20, x20, #1
    b       .Li_loop

.Lfound_result:
    sub     x25, x20, #CONSECUTIVE
    add     x25, x25, #1            // result = i - 4 + 1

.Li_done:
    mov     x20, x25                 // save result

    mov     x0, x22
    bl      _free

    mov     x0, x20

    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
