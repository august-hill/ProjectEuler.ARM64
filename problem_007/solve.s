// Problem 007: 10001st Prime
// Find the 10,001st prime number.
// Answer: 104743
//
// Algorithm: Sieve of Eratosthenes with safe overestimate for upper bound.

.global _solve
.global _malloc
.global _free
.align 4

.set TARGET, 10001
.set LIMIT, 150015         // TARGET * 15

// long long solve(void)
_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!

    // Allocate sieve: calloc-like via malloc + zero
    movz    x0, #(LIMIT & 0xFFFF)
    movk    x0, #(LIMIT >> 16), lsl #16
    add     x0, x0, #1          // LIMIT + 1
    bl      _malloc
    mov     x19, x0              // x19 = sieve (is_composite)

    // Zero the sieve
    mov     x1, x19
    movz    x2, #(LIMIT & 0xFFFF)
    movk    x2, #(LIMIT >> 16), lsl #16
    add     x2, x2, #1
.Lzero_loop:
    strb    wzr, [x1], #1
    subs    x2, x2, #1
    b.ne    .Lzero_loop

    // Sieve: for i = 2; i*i <= LIMIT; i++
    mov     x20, #2              // x20 = i
.Lsieve_outer:
    mul     x1, x20, x20
    movz    x2, #(LIMIT & 0xFFFF)
    movk    x2, #(LIMIT >> 16), lsl #16
    cmp     x1, x2
    b.gt    .Lsieve_done

    ldrb    w3, [x19, x20]
    cbnz    w3, .Lsieve_next     // if is_composite[i], skip

    // Mark multiples
    mov     x21, x1              // j = i*i
.Lsieve_inner:
    cmp     x21, x2
    b.gt    .Lsieve_next
    mov     w4, #1
    strb    w4, [x19, x21]       // is_composite[j] = true
    add     x21, x21, x20
    b       .Lsieve_inner

.Lsieve_next:
    add     x20, x20, #1
    b       .Lsieve_outer

.Lsieve_done:
    // Find 10001st prime
    mov     x20, #2              // i = 2
    mov     x21, #0              // count = 0
    mov     x22, #0              // result
    movz    x2, #(LIMIT & 0xFFFF)
    movk    x2, #(LIMIT >> 16), lsl #16
    movz    x3, #(TARGET & 0xFFFF)

.Lcount_loop:
    cmp     x20, x2
    b.gt    .Lcount_done
    cmp     x21, x3
    b.ge    .Lcount_done

    ldrb    w4, [x19, x20]
    cbnz    w4, .Lcount_next     // if composite, skip
    add     x21, x21, #1         // count++
    cmp     x21, x3
    b.ne    .Lcount_next
    mov     x22, x20             // result = i

.Lcount_next:
    add     x20, x20, #1
    b       .Lcount_loop

.Lcount_done:
    // Free sieve
    mov     x0, x19
    bl      _free

    mov     x0, x22              // return result

    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
