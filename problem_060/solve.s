// Problem 060: Prime Pair Sets
// Find lowest sum of 5 primes where any two concatenate to form a prime.
// Answer: 26033

.global _solve
.align 4

// This problem uses a large sieve (100M bits) and Miller-Rabin for larger numbers.
// Due to complexity, we use the same algorithm as the C version.

.set LIMIT, 10000
.set SIEVE_SIZE, 100000000
.set SIEVE_BYTES, 12500000    // SIEVE_SIZE / 8

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!

    // Allocate sieve: SIEVE_BYTES via calloc
    mov     x0, #1
    movz    x1, #0x00BE
    movk    x1, #0xBC, lsl #16  // 12500000 = 0xBEBC20
    movk    x1, #0x20
    // Actually let's use proper value
    mov     x0, #SIEVE_BYTES
    mov     x1, #1
    // calloc(SIEVE_BYTES, 1)
    mov     x0, #SIEVE_BYTES & 0xFFFF
    movk    x0, #(SIEVE_BYTES >> 16), lsl #16
    bl      _calloc
    mov     x19, x0             // x19 = sieve_data

    // Mark 0 and 1 as composite: set bits 0 and 1
    ldrb    w0, [x19]
    orr     w0, w0, #3
    strb    w0, [x19]

    // Sieve of Eratosthenes (bit-packed)
    mov     x20, #2
.L60_sieve:
    mul     x0, x20, x20
    mov     x1, #SIEVE_SIZE & 0xFFFF
    movk    x1, #(SIEVE_SIZE >> 16), lsl #16
    cmp     x0, x1
    b.ge    .L60_sieve_done

    // Check if x20 is prime (bit not set)
    lsr     x0, x20, #3
    ldrb    w1, [x19, x0]
    and     x2, x20, #7
    lsr     w1, w1, w2
    tst     w1, #1
    b.ne    .L60_sieve_next

    // Mark multiples
    mul     x21, x20, x20
.L60_mark:
    mov     x1, #SIEVE_SIZE & 0xFFFF
    movk    x1, #(SIEVE_SIZE >> 16), lsl #16
    cmp     x21, x1
    b.ge    .L60_sieve_next
    lsr     x0, x21, #3
    ldrb    w1, [x19, x0]
    and     x2, x21, #7
    mov     w3, #1
    lsl     w3, w3, w2
    orr     w1, w1, w3
    strb    w1, [x19, x0]
    add     x21, x21, x20
    b       .L60_mark

.L60_sieve_next:
    add     x20, x20, #1
    b       .L60_sieve
.L60_sieve_done:

    // Collect primes < LIMIT into array on stack
    // Max primes below 10000 ~ 1229
    sub     sp, sp, #(1232 * 8)
    mov     x20, sp              // primes array
    mov     x21, #0              // n = count

    mov     x22, #2
.L60_collect:
    cmp     x22, #LIMIT
    b.ge    .L60_collect_done
    // sieve_is_prime check
    lsr     x0, x22, #3
    ldrb    w1, [x19, x0]
    and     x2, x22, #7
    lsr     w1, w1, w2
    tst     w1, #1
    b.ne    .L60_collect_next
    str     x22, [x20, x21, lsl #3]
    add     x21, x21, #1
.L60_collect_next:
    add     x22, x22, #1
    b       .L60_collect
.L60_collect_done:
    // x21 = number of primes

    // Search for 5-element sets
    movz    x22, #0x3B9A
    movk    x22, #0xCA00        // best = 1000000000
    // Actually: 1000000000 = 0x3B9ACA00
    mov     x22, #0xCA00
    movk    x22, #0x3B9A, lsl #16

    // 5 nested loops - we need lots of registers
    // Store state on stack
    sub     sp, sp, #64          // local vars

    mov     x23, #0              // ai
.L60_ai:
    cmp     x23, x21
    b.ge    .L60_search_done
    ldr     x0, [x20, x23, lsl #3]  // a
    mov     x1, #5
    mul     x1, x0, x1
    cmp     x1, x22
    b.ge    .L60_search_done
    str     x0, [sp, #0]        // save a

    add     x24, x23, #1        // bi
.L60_bi:
    cmp     x24, x21
    b.ge    .L60_next_ai
    ldr     x1, [x20, x24, lsl #3]  // b
    ldr     x0, [sp, #0]        // a
    add     x2, x0, x1
    mov     x3, #5
    mul     x2, x2, x3
    mov     x3, #2
    udiv    x2, x2, x3
    cmp     x2, x22
    b.ge    .L60_next_ai
    str     x1, [sp, #8]        // save b

    // is_pair(a, b)?
    ldr     x0, [sp, #0]
    bl      .L60_is_pair
    cbz     x0, .L60_next_bi

    add     x25, x24, #1        // ci
.L60_ci:
    cmp     x25, x21
    b.ge    .L60_next_bi
    ldr     x2, [x20, x25, lsl #3]  // c
    ldr     x0, [sp, #0]        // a
    ldr     x1, [sp, #8]        // b
    add     x3, x0, x1
    add     x3, x3, x2
    mov     x4, #5
    mul     x3, x3, x4
    mov     x4, #3
    udiv    x3, x3, x4
    cmp     x3, x22
    b.ge    .L60_next_bi
    str     x2, [sp, #16]       // save c

    // is_pair(a,c) && is_pair(b,c)?
    ldr     x0, [sp, #0]
    ldr     x1, [sp, #16]
    bl      .L60_is_pair
    cbz     x0, .L60_next_ci
    ldr     x0, [sp, #8]
    ldr     x1, [sp, #16]
    bl      .L60_is_pair
    cbz     x0, .L60_next_ci

    add     x26, x25, #1        // di
.L60_di:
    cmp     x26, x21
    b.ge    .L60_next_ci
    ldr     x3, [x20, x26, lsl #3]  // d
    ldr     x0, [sp, #0]
    ldr     x1, [sp, #8]
    ldr     x2, [sp, #16]
    add     x4, x0, x1
    add     x4, x4, x2
    add     x4, x4, x3
    cmp     x4, x22
    b.ge    .L60_next_ci
    str     x3, [sp, #24]
    str     x4, [sp, #32]       // partial sum

    // is_pair(a,d), is_pair(b,d), is_pair(c,d)?
    ldr     x0, [sp, #0]
    ldr     x1, [sp, #24]
    bl      .L60_is_pair
    cbz     x0, .L60_next_di
    ldr     x0, [sp, #8]
    ldr     x1, [sp, #24]
    bl      .L60_is_pair
    cbz     x0, .L60_next_di
    ldr     x0, [sp, #16]
    ldr     x1, [sp, #24]
    bl      .L60_is_pair
    cbz     x0, .L60_next_di

    add     x27, x26, #1        // ei
.L60_ei:
    cmp     x27, x21
    b.ge    .L60_next_di
    ldr     x0, [x20, x27, lsl #3]  // e
    ldr     x4, [sp, #32]       // partial
    add     x5, x4, x0
    cmp     x5, x22
    b.ge    .L60_next_di
    str     x0, [sp, #40]
    str     x5, [sp, #48]

    // is_pair(a,e), is_pair(b,e), is_pair(c,e), is_pair(d,e)?
    ldr     x0, [sp, #0]
    ldr     x1, [sp, #40]
    bl      .L60_is_pair
    cbz     x0, .L60_next_ei
    ldr     x0, [sp, #8]
    ldr     x1, [sp, #40]
    bl      .L60_is_pair
    cbz     x0, .L60_next_ei
    ldr     x0, [sp, #16]
    ldr     x1, [sp, #40]
    bl      .L60_is_pair
    cbz     x0, .L60_next_ei
    ldr     x0, [sp, #24]
    ldr     x1, [sp, #40]
    bl      .L60_is_pair
    cbz     x0, .L60_next_ei

    ldr     x22, [sp, #48]      // best = sum

.L60_next_ei:
    add     x27, x27, #1
    b       .L60_ei
.L60_next_di:
    add     x26, x26, #1
    b       .L60_di
.L60_next_ci:
    add     x25, x25, #1
    b       .L60_ci
.L60_next_bi:
    add     x24, x24, #1
    b       .L60_bi
.L60_next_ai:
    add     x23, x23, #1
    b       .L60_ai

.L60_search_done:
    mov     x0, x22             // return best
    add     sp, sp, #64
    add     sp, sp, #(1232 * 8)

    // Free sieve
    str     x0, [sp, #-16]!
    mov     x0, x19
    bl      _free
    ldr     x0, [sp], #16

    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

// is_pair(x0=a, x1=b) -> x0 (1 if both concat are prime, 0 otherwise)
// Uses x19 (sieve) - must preserve callee-saved
.L60_is_pair:
    stp     x29, x30, [sp, #-16]!
    stp     x19, x20, [sp, #-16]!  // x19 already saved by caller
    // Actually x19 is the sieve pointer from the outer function
    // We need it but it's already in x19
    // Save a and b
    stp     x0, x1, [sp, #-16]!

    // concat(a, b): a * 10^(digits of b) + b
    bl      .L60_concat
    bl      .L60_check_prime
    cbz     x0, .L60_pair_no

    // concat(b, a)
    ldp     x0, x1, [sp]
    mov     x2, x0
    mov     x0, x1
    mov     x1, x2
    bl      .L60_concat
    bl      .L60_check_prime
    cbz     x0, .L60_pair_no

    mov     x0, #1
    b       .L60_pair_ret
.L60_pair_no:
    mov     x0, #0
.L60_pair_ret:
    add     sp, sp, #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

// concat(x0=a, x1=b) -> x0 = a * 10^(digits(b)) + b
.L60_concat:
    mov     x2, #1              // mult
    mov     x3, x1              // tmp = b
    mov     x4, #10
.L60_cat_loop:
    cbz     x3, .L60_cat_done
    mul     x2, x2, x4
    udiv    x3, x3, x4
    b       .L60_cat_loop
.L60_cat_done:
    mul     x0, x0, x2
    add     x0, x0, x1
    ret

// check_prime(x0=n) -> x0 (1 if prime, 0 if not)
// Uses sieve for n < SIEVE_SIZE, Miller-Rabin otherwise
.L60_check_prime:
    stp     x29, x30, [sp, #-16]!

    cmp     x0, #2
    b.lt    .L60_cp_no
    mov     x1, #SIEVE_SIZE & 0xFFFF
    movk    x1, #(SIEVE_SIZE >> 16), lsl #16
    cmp     x0, x1
    b.ge    .L60_miller_rabin

    // Sieve check
    lsr     x1, x0, #3
    ldrb    w2, [x19, x1]
    and     x3, x0, #7
    lsr     w2, w2, w3
    tst     w2, #1
    b.ne    .L60_cp_no
    mov     x0, #1
    ldp     x29, x30, [sp], #16
    ret

.L60_miller_rabin:
    // Simple trial division for our use case (numbers < ~10^10)
    // Actually implement Miller-Rabin with witnesses 2,3,5,7
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!

    mov     x20, x0             // n

    tst     x0, #1
    b.eq    .L60_mr_no

    // d = n-1, r = 0
    sub     x21, x20, #1        // d
    mov     x22, #0             // r
.L60_mr_factor:
    tst     x21, #1
    b.ne    .L60_mr_factored
    lsr     x21, x21, #1
    add     x22, x22, #1
    b       .L60_mr_factor
.L60_mr_factored:

    // Test witnesses 2, 3, 5, 7
    adrp    x23, .L60_witnesses@PAGE
    add     x23, x23, .L60_witnesses@PAGEOFF
    mov     x24, #0
.L60_mr_witness:
    cmp     x24, #4
    b.ge    .L60_mr_yes
    ldr     x0, [x23, x24, lsl #3]
    cmp     x0, x20
    b.ge    .L60_mr_next_w

    // x = mod_pow(a, d, n)
    mov     x1, x21             // exp = d
    mov     x2, x20             // mod = n
    bl      .L60_mod_pow
    // x0 = x

    cmp     x0, #1
    b.eq    .L60_mr_next_w
    sub     x1, x20, #1
    cmp     x0, x1
    b.eq    .L60_mr_next_w

    // Inner loop
    mov     x3, #0              // i
    mov     x4, #0              // found = false
.L60_mr_inner:
    sub     x5, x22, #1
    cmp     x3, x5
    b.ge    .L60_mr_inner_done
    // x = (x * x) % n - need 128-bit multiply
    // Use umulh for high bits
    mul     x1, x0, x0
    umulh   x2, x0, x0
    // Now divide x2:x1 by x20 to get remainder
    // For simplicity, use repeated subtraction if x2 > 0, else udiv
    cbz     x2, .L60_mr_simple_mod
    // 128-bit mod: this is complex. Let's use a simpler approach.
    // Since n < 10^10 and x < n, x*x < 10^20 which fits in 128 bits.
    // We need: (x2:x1) mod x20
    // Use: result = x2:x1 - (x2:x1 / x20) * x20
    // For 128/64 division: use floating point approximation
    // Actually on AArch64 we can use the approach:
    // q_hi = x2 / x20 (will give partial quotient since x2 < x20 likely)
    // remainder = x2:x1 - q * x20
    // This is getting complex. Let me use a helper.
    udiv    x5, x2, x20        // q_hi (upper / n)
    msub    x6, x5, x20, x2    // r_hi = x2 - q_hi * n
    // Now we have r_hi:x1, and r_hi < n
    // r_hi * 2^64 + x1 = r_hi * 2^64 + x1
    // Since r_hi < n < 2^34 (10^10), r_hi * 2^64 would overflow...
    // Better approach: use iterative reduction
    // x2:x1 mod x20
    // Split: x2 * 2^64 mod x20 + x1 mod x20
    // 2^64 mod x20 can be computed
    mov     x5, #0
    movk    x5, #0, lsl #16     // we need 2^64 mod n
    // 2^64 = (2^64 / n) * n + (2^64 mod n)
    // But we can't represent 2^64 in a register...
    // Alternative: use the fact that 2^64 mod n = -(n * floor(2^64/n) - 2^64)
    // = 2^64 - n * floor(2^64/n)
    // Actually, since we can't represent 2^64, let's compute differently:
    // 2^64 mod n: start with 2^63 mod n, then double
    mov     x5, #1
    lsl     x5, x5, #63        // 2^63
    udiv    x6, x5, x20
    msub    x5, x6, x20, x5    // 2^63 mod n
    lsl     x5, x5, #1         // 2^64 mod n (might overflow)
    cmp     x5, x20
    b.lo    .L60_mr_got_2_64
    sub     x5, x5, x20
.L60_mr_got_2_64:
    // Now: result = (x2 * (2^64 mod n)) mod n + x1 mod n
    // (x2 * x5) might overflow 64 bits, need 128-bit multiply again
    // This is recursive... let's just use a different approach.
    // Use mod_pow style multiplication (binary method)
    // Actually for this problem, n < 10^10 and a < n, so a < 10^10
    // a^2 < 10^20 which is < 2^67
    // So x2 is at most ~8, and x2 * 2^64 / n iterations are small
    // Just subtract n repeatedly from x2:x1
    // While x2 > 0: subtract n shifted appropriately
    // Simple: while (x2 > 0 || x1 >= x20): x2:x1 -= x20
    // But this could be slow. Better:
    // x1 = x1 mod x20 (fast since both 64-bit)
    // x2 = x2 * (2^64 mod x20) ... still recursive
    // Let's just do: while x2 > 0, subtract n from x2:x1
    // x2 is at most ~8 so this is fast
.L60_mr_sub_loop:
    cbz     x2, .L60_mr_simple_mod
    subs    x1, x1, x20
    b.cs    .L60_mr_sub_no_borrow
    sub     x2, x2, #1
.L60_mr_sub_no_borrow:
    b       .L60_mr_sub_loop

.L60_mr_simple_mod:
    udiv    x5, x1, x20
    msub    x0, x5, x20, x1    // x0 = x1 mod n

    sub     x1, x20, #1
    cmp     x0, x1              // x == n-1?
    b.eq    .L60_mr_found
    add     x3, x3, #1
    b       .L60_mr_inner

.L60_mr_found:
    mov     x4, #1
.L60_mr_inner_done:
    cbz     x4, .L60_mr_no

.L60_mr_next_w:
    add     x24, x24, #1
    b       .L60_mr_witness

.L60_mr_yes:
    mov     x0, #1
    b       .L60_mr_ret
.L60_mr_no:
    mov     x0, #0
.L60_mr_ret:
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

.L60_cp_no:
    mov     x0, #0
    ldp     x29, x30, [sp], #16
    ret

// mod_pow(x0=base, x1=exp, x2=mod) -> x0
.L60_mod_pow:
    mov     x3, #1              // result
    udiv    x4, x0, x2
    msub    x0, x4, x2, x0     // base %= mod
.L60_mp_loop:
    cbz     x1, .L60_mp_done
    tst     x1, #1
    b.eq    .L60_mp_no_mul
    // result = (result * base) % mod
    mul     x4, x3, x0
    umulh   x5, x3, x0
    // 128-bit mod
    cbz     x5, .L60_mp_simple1
.L60_mp_sub1:
    cbz     x5, .L60_mp_simple1
    subs    x4, x4, x2
    b.cs    .L60_mp_sub1
    sub     x5, x5, #1
    b       .L60_mp_sub1
.L60_mp_simple1:
    udiv    x6, x4, x2
    msub    x3, x6, x2, x4
.L60_mp_no_mul:
    lsr     x1, x1, #1
    // base = (base * base) % mod
    mul     x4, x0, x0
    umulh   x5, x0, x0
    cbz     x5, .L60_mp_simple2
.L60_mp_sub2:
    cbz     x5, .L60_mp_simple2
    subs    x4, x4, x2
    b.cs    .L60_mp_sub2
    sub     x5, x5, #1
    b       .L60_mp_sub2
.L60_mp_simple2:
    udiv    x6, x4, x2
    msub    x0, x6, x2, x4
    b       .L60_mp_loop
.L60_mp_done:
    mov     x0, x3
    ret

.data
.align 3
.L60_witnesses:
    .quad 2, 3, 5, 7
.text
