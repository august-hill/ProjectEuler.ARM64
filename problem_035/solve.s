// Problem 035: Circular Primes
// How many circular primes are there below one million?
// Answer: 55

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

    // Allocate sieve
    movz    x0, #(LIMIT & 0xFFFF)
    movk    x0, #(LIMIT >> 16), lsl #16
    bl      _malloc
    mov     x19, x0                  // x19 = is_prime

    // Initialize to 1
    mov     x1, x19
    movz    x2, #(LIMIT & 0xFFFF)
    movk    x2, #(LIMIT >> 16), lsl #16
    mov     w3, #1
.Linit:
    strb    w3, [x1], #1
    subs    x2, x2, #1
    b.ne    .Linit

    strb    wzr, [x19]
    strb    wzr, [x19, #1]

    // Sieve: sqrt(1000000) = 1000
    mov     x20, #2
.Lsieve_outer:
    mul     x1, x20, x20
    mov     x2, #LIMIT
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

    // Count circular primes
    mov     x20, #0                  // count
    mov     x21, #2                  // n

.Ln_loop:
    movz    x2, #(LIMIT & 0xFFFF)
    movk    x2, #(LIMIT >> 16), lsl #16
    cmp     x21, x2
    b.ge    .Ln_done

    ldrb    w3, [x19, x21]
    cbz     w3, .Ln_next

    // is_circular_prime(n)?
    // First count digits
    mov     x22, x21                // temp
    mov     x23, #0                  // num_digits
    mov     x10, #10
.Lcount_digits:
    cbz     x22, .Lcount_done
    udiv    x22, x22, x10
    add     x23, x23, #1
    b       .Lcount_digits
.Lcount_done:

    // Check all rotations
    mov     x22, x21                // rotated = n
    mov     x24, #0                  // rotation count
    mov     x9, #1                   // will be set to 0 if not circular
.Lrotate_loop:
    cmp     x24, x23
    b.ge    .Lrotate_done

    // Check if rotated is prime and < LIMIT
    movz    x2, #(LIMIT & 0xFFFF)
    movk    x2, #(LIMIT >> 16), lsl #16
    cmp     x22, x2
    b.ge    .Lnot_circular
    ldrb    w3, [x19, x22]
    cbz     w3, .Lnot_circular

    // rotate: last_digit * 10^(digits-1) + rest/10
    udiv    x11, x22, x10           // rest = rotated / 10
    msub    x12, x11, x10, x22     // last = rotated % 10

    // multiplier = 10^(digits-1)
    mov     x13, #1
    sub     x14, x23, #1
.Lpow10:
    cbz     x14, .Lpow10_done
    mul     x13, x13, x10
    sub     x14, x14, #1
    b       .Lpow10
.Lpow10_done:

    mul     x12, x12, x13           // last * multiplier
    add     x22, x12, x11           // rotated = last * multiplier + rest

    add     x24, x24, #1
    b       .Lrotate_loop

.Lnot_circular:
    mov     x9, #0
.Lrotate_done:
    cbz     x9, .Ln_next
    add     x20, x20, #1            // count++

.Ln_next:
    add     x21, x21, #1
    b       .Ln_loop
.Ln_done:

    mov     x22, x20                // save count

    mov     x0, x19
    bl      _free

    mov     x0, x22

    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
