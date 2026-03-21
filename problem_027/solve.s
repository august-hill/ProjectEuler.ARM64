// Problem 027: Quadratic Primes
// Find the product of coefficients a and b for n^2 + an + b
// that produces the maximum number of primes for consecutive values of n.
// Answer: -59231

.global _solve
.global _malloc
.global _free
.align 4

.set PRIME_LIMIT, 1000000

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!

    // Allocate sieve: malloc(PRIME_LIMIT)
    movz    x0, #(PRIME_LIMIT & 0xFFFF)
    movk    x0, #(PRIME_LIMIT >> 16), lsl #16
    bl      _malloc
    mov     x19, x0                  // x19 = is_prime_sieve

    // Initialize to 1
    mov     x1, x19
    movz    x2, #(PRIME_LIMIT & 0xFFFF)
    movk    x2, #(PRIME_LIMIT >> 16), lsl #16
    mov     w3, #1
.Linit:
    strb    w3, [x1], #1
    subs    x2, x2, #1
    b.ne    .Linit

    // Mark 0 and 1 as not prime
    strb    wzr, [x19]
    strb    wzr, [x19, #1]

    // Sieve: sqrt(1000000) = 1000
    mov     x20, #2
.Lsieve_outer:
    mul     x1, x20, x20
    movz    x2, #(PRIME_LIMIT & 0xFFFF)
    movk    x2, #(PRIME_LIMIT >> 16), lsl #16
    cmp     x1, x2
    b.ge    .Lsieve_done
    ldrb    w3, [x19, x20]
    cbz     w3, .Lsieve_next
    mov     x21, x1
.Lsieve_inner:
    cmp     x21, x2
    b.ge    .Lsieve_next
    strb    wzr, [x19, x21]
    add     x21, x21, x20
    b       .Lsieve_inner
.Lsieve_next:
    add     x20, x20, #1
    b       .Lsieve_outer
.Lsieve_done:

    // Main search
    mov     x20, #0                  // max_n = 0
    mov     x21, #0                  // result = 0

    // a from -999 to 999
    mov     x22, #-999               // a
.La_loop:
    cmp     x22, #1000
    b.ge    .La_done

    // b from -1000 to 1000
    movn    x23, #999                // b = -1000
.Lb_loop:
    cmp     x23, #1001
    b.ge    .Lb_done

    // Count consecutive primes
    mov     x24, #0                  // n = 0
.Ln_loop:
    // val = n*n + a*n + b
    mul     x25, x24, x24           // n*n
    mul     x26, x22, x24           // a*n (signed)
    add     x25, x25, x26           // n*n + a*n
    add     x25, x25, x23           // + b = val

    // if val < 0, break
    tbnz    x25, #63, .Ln_done      // check sign bit

    // if val >= PRIME_LIMIT, break
    movz    x26, #(PRIME_LIMIT & 0xFFFF)
    movk    x26, #(PRIME_LIMIT >> 16), lsl #16
    cmp     x25, x26
    b.ge    .Ln_done

    // if !is_prime[val], break
    ldrb    w26, [x19, x25]
    cbz     w26, .Ln_done

    add     x24, x24, #1
    b       .Ln_loop
.Ln_done:

    // if n > max_n
    cmp     x24, x20
    b.le    .Lno_update
    mov     x20, x24                 // max_n = n
    mul     x21, x22, x23           // result = a * b
.Lno_update:
    add     x23, x23, #1
    b       .Lb_loop
.Lb_done:
    add     x22, x22, #1
    b       .La_loop
.La_done:

    mov     x22, x21                 // save result

    // Free sieve
    mov     x0, x19
    bl      _free

    mov     x0, x22                  // return result

    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
