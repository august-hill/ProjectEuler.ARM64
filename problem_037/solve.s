// Problem 037: Truncatable Primes
// Find the sum of the only eleven primes that are both truncatable from left to right
// and right to left.
// Answer: 748317

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
    mov     x19, x0

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

    // Find truncatable primes
    mov     x20, #0                  // sum
    mov     x21, #0                  // count
    mov     x22, #11                 // p = 11
    mov     x10, #10

.Lp_loop:
    movz    x2, #(LIMIT & 0xFFFF)
    movk    x2, #(LIMIT >> 16), lsl #16
    cmp     x22, x2
    b.ge    .Lp_done
    cmp     x21, #11
    b.ge    .Lp_done

    ldrb    w3, [x19, x22]
    cbz     w3, .Lp_next

    // is_right_truncatable_prime: n/10, n/100, ...
    udiv    x23, x22, x10           // n = p / 10
.Lright_loop:
    cbz     x23, .Lright_ok
    ldrb    w3, [x19, x23]
    cbz     w3, .Lp_next
    udiv    x23, x23, x10
    b       .Lright_loop
.Lright_ok:

    // is_left_truncatable_prime: p % divisor
    // Find divisor > p, then /= 10
    mov     x23, #1
.Lfind_div:
    cmp     x23, x22
    b.gt    .Lfound_div
    mul     x23, x23, x10
    b       .Lfind_div
.Lfound_div:
    udiv    x23, x23, x10           // divisor = first power of 10 >= p, /10

.Lleft_loop:
    cmp     x23, #1
    b.le    .Lleft_ok
    // n = p % divisor
    udiv    x24, x22, x23
    msub    x24, x24, x23, x22     // p % divisor
    cbz     x24, .Lp_next           // if 0, not prime
    ldrb    w3, [x19, x24]
    cbz     w3, .Lp_next
    udiv    x23, x23, x10
    b       .Lleft_loop
.Lleft_ok:

    // Found a truncatable prime
    add     x20, x20, x22
    add     x21, x21, #1

.Lp_next:
    add     x22, x22, #1
    b       .Lp_loop
.Lp_done:

    mov     x22, x20                // save sum

    mov     x0, x19
    bl      _free

    mov     x0, x22

    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
