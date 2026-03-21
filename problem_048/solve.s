// Problem 048: Self Powers
// Find last 10 digits of 1^1 + 2^2 + 3^3 + ... + 1000^1000.
// Answer: 9110846700

.global _solve
.align 4

// MOD = 10^10 = 10000000000
// 10000000000 = 0x2_540B_E400

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!

    // Load MOD into x19
    movz    x19, #0xE400
    movk    x19, #0x540B, lsl #16
    movk    x19, #0x0002, lsl #32    // x19 = 10000000000

    mov     x20, #0                  // sum = 0
    mov     x21, #1                  // i = 1

.Li_loop:
    cmp     x21, #1000
    b.gt    .Li_done

    // mod_pow(i, i, MOD)
    // base = i % MOD, exp = i, result = 1
    udiv    x1, x21, x19
    msub    x22, x1, x19, x21       // base = i % MOD
    mov     x23, x21                 // exp = i
    mov     x24, #1                  // result = 1

.Lpow_loop:
    cbz     x23, .Lpow_done

    // if exp % 2 == 1
    tst     x23, #1
    b.eq    .Lpow_even

    // result = (result * base) % MOD
    // Need to handle potential overflow: result < 10^10, base < 10^10
    // Product can be up to ~10^20 which fits in 128 bits but not 64
    // Use umulh for high bits
    mul     x1, x24, x22            // low 64 bits
    umulh   x2, x24, x22            // high 64 bits
    // Now divide 128-bit (x2:x1) by x19
    // Since our values are < 10^10, product < 10^20 < 2^67
    // x2 will be small. We can use: result = (x2:x1) mod MOD
    // Do iterative: if x2 > 0, subtract MOD*2^64 equivalent
    // Simpler: use udiv on high part
    // Actually for mod: result = low - (low/mod)*mod, but only works if no overflow
    // Let's handle this properly:
    // If x2 == 0, just do x1 % MOD
    cbz     x2, .Lmod_simple1
    // x2:x1 is the 128-bit product. We need mod.
    // Since x2 < 10^10 and MOD = 10^10, we know x2 < MOD
    // (x2 * 2^64) % MOD + x1 % MOD, then mod again
    // 2^64 % 10^10 = 2^64 - 1*10^10 * floor(2^64/10^10)
    // 2^64 = 18446744073709551616
    // 18446744073709551616 / 10000000000 = 1844674407
    // 1844674407 * 10000000000 = 18446744070000000000
    // 2^64 mod 10^10 = 18446744073709551616 - 18446744070000000000 = 3709551616
    movz    x3, #0x1C00
    movk    x3, #0xDD1A, lsl #16     // 3709551616 = 0xDD1A1C00
    mul     x4, x2, x3              // x2 * (2^64 mod MOD) -- low bits
    umulh   x5, x2, x3              // high bits (should be small)
    add     x1, x1, x4              // add to low
    // Check carry
    cmp     x1, x4
    b.hs    .Lno_carry1
    add     x5, x5, #1
.Lno_carry1:
    // Now we have x5:x1, but x5 should be 0 or very small
    // Just take x1 % MOD (x5 contributes if nonzero)
    cbz     x5, .Lmod_simple1
    // This shouldn't happen for our range, but handle it
    mul     x6, x5, x3
    add     x1, x1, x6
.Lmod_simple1:
    udiv    x2, x1, x19
    msub    x24, x2, x19, x1        // result = product % MOD

    b       .Lpow_shift

.Lpow_even:
.Lpow_shift:
    // exp /= 2
    lsr     x23, x23, #1

    // base = (base * base) % MOD
    mul     x1, x22, x22
    umulh   x2, x22, x22
    cbz     x2, .Lmod_simple2
    movz    x3, #0x1C00
    movk    x3, #0xDD1A, lsl #16
    mul     x4, x2, x3
    umulh   x5, x2, x3
    add     x1, x1, x4
    cmp     x1, x4
    b.hs    .Lno_carry2
    add     x5, x5, #1
.Lno_carry2:
    cbz     x5, .Lmod_simple2
    mul     x6, x5, x3
    add     x1, x1, x6
.Lmod_simple2:
    udiv    x2, x1, x19
    msub    x22, x2, x19, x1        // base = base^2 % MOD

    b       .Lpow_loop
.Lpow_done:

    // sum = (sum + result) % MOD
    add     x20, x20, x24
    udiv    x1, x20, x19
    msub    x20, x1, x19, x20

    add     x21, x21, #1
    b       .Li_loop
.Li_done:

    mov     x0, x20

    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
