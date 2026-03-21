// Problem 050: Consecutive Prime Sum
// Find prime < 1,000,000 that is sum of most consecutive primes.
// Answer: 997651

.global _solve
.global _malloc
.global _free
.align 4

.set LIMIT, 1000000

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!

    // Allocate is_prime sieve (LIMIT + 1 bytes)
    mov     x0, #LIMIT
    add     x0, x0, #1
    bl      _malloc
    mov     x19, x0

    // Initialize to 1
    mov     x1, x19
    mov     x2, #LIMIT
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
    mov     x2, #LIMIT
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

    // Collect primes into array (LIMIT/10 * 4 = 400000 bytes)
    mov     x0, #400000
    bl      _malloc
    mov     x22, x0                  // primes array (32-bit entries)
    mov     x23, #0                  // prime_count

    mov     x20, #2
.Lcollect:
    mov     x1, #LIMIT
    cmp     x20, x1
    b.gt    .Lcollect_done
    ldrb    w1, [x19, x20]
    cbz     w1, .Lcollect_next
    str     w20, [x22, x23, lsl #2]
    add     x23, x23, #1
.Lcollect_next:
    add     x20, x20, #1
    b       .Lcollect
.Lcollect_done:

    // Find longest consecutive prime sum
    mov     x24, #0                  // max_len
    mov     x25, #0                  // max_sum (result)

    mov     x20, #0                  // i (start index)
.Li_loop:
    cmp     x20, x23
    b.ge    .Li_done

    mov     x26, #0                  // sum = 0
    mov     x21, #0                  // j (length counter)

.Lj_loop:
    add     x1, x20, x21
    cmp     x1, x23
    b.ge    .Lj_done

    ldr     w2, [x22, x1, lsl #2]   // primes[i + j]
    add     x26, x26, x2            // sum += primes[i+j]

    mov     x1, #LIMIT
    cmp     x26, x1
    b.ge    .Lj_done

    // Check if sum is prime and j > max_len
    ldrb    w3, [x19, x26]
    cbz     w3, .Lj_next
    cmp     x21, x24
    b.le    .Lj_next
    mov     x24, x21                 // max_len = j
    mov     x25, x26                 // max_sum = sum

.Lj_next:
    add     x21, x21, #1
    b       .Lj_loop
.Lj_done:

    add     x20, x20, #1
    b       .Li_loop
.Li_done:

    mov     x20, x25                 // save result

    mov     x0, x22
    bl      _free
    mov     x0, x19
    bl      _free

    mov     x0, x20

    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
