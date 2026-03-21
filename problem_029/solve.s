// Problem 029: Distinct Powers
// How many distinct terms are in the sequence a^b for 2<=a<=100 and 2<=b<=100?
// Answer: 9183

.global _solve
.global _malloc
.global _free
.global _qsort
.align 4

.set MAX_DIGITS, 250
.set BIGINT_SIZE, 256          // 250 bytes digits + 4 bytes len + 2 padding, round to 256
.set MAX_TERMS, 10000

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!

    // Allocate terms array: MAX_TERMS * BIGINT_SIZE = 10000 * 256 = 2560000
    movz    x0, #(2560000 & 0xFFFF)
    movk    x0, #(2560000 >> 16), lsl #16
    bl      _malloc
    mov     x19, x0                  // x19 = terms base
    mov     x20, #0                  // x20 = term_count

    // for a = 2; a <= 100; a++
    mov     x21, #2                  // a
.La_loop:
    cmp     x21, #100
    b.gt    .La_done

    // for b = 2; b <= 100; b++
    mov     x22, #2                  // b
.Lb_loop:
    cmp     x22, #100
    b.gt    .Lb_done

    // Calculate offset for terms[term_count]
    mov     x0, #BIGINT_SIZE
    mul     x23, x20, x0            // offset = term_count * BIGINT_SIZE
    add     x23, x19, x23           // x23 = &terms[term_count]

    // Zero out the BigInt (256 bytes)
    mov     x0, x23
    mov     x1, #BIGINT_SIZE
.Lzero_bigint:
    strb    wzr, [x0], #1
    subs    x1, x1, #1
    b.ne    .Lzero_bigint

    // result.digits[0] = 1, result.len = 1
    mov     w0, #1
    strb    w0, [x23]               // digits[0] = 1
    str     w0, [x23, #MAX_DIGITS]  // len = 1

    // for p = 0; p < b; p++  (multiply by a, b times)
    mov     x24, #0                  // p
.Lp_loop:
    cmp     x24, x22
    b.ge    .Lp_done

    // Multiply result by a
    ldr     w25, [x23, #MAX_DIGITS] // len
    mov     x26, #0                  // carry = 0
    mov     x27, #0                  // i = 0
.Lmul_loop:
    cmp     w27, w25
    b.ge    .Lmul_carry

    ldrb    w0, [x23, x27]          // digits[i]
    mul     w1, w0, w21             // digits[i] * a (w21 has a)
    add     w1, w1, w26             // + carry
    mov     w2, #10
    udiv    w26, w1, w2             // carry = prod / 10
    msub    w0, w26, w2, w1         // digits[i] = prod % 10
    strb    w0, [x23, x27]

    add     x27, x27, #1
    b       .Lmul_loop

.Lmul_carry:
    cbz     w26, .Lmul_done
    mov     w2, #10
    udiv    w3, w26, w2             // new_carry = carry / 10
    msub    w0, w3, w2, w26         // digit = carry % 10
    strb    w0, [x23, x27]          // digits[len] = digit
    add     w25, w25, #1
    add     x27, x27, #1
    mov     w26, w3                  // carry = new_carry
    b       .Lmul_carry

.Lmul_done:
    str     w25, [x23, #MAX_DIGITS] // update len

    add     x24, x24, #1
    b       .Lp_loop
.Lp_done:

    add     x20, x20, #1            // term_count++
    add     x22, x22, #1
    b       .Lb_loop
.Lb_done:
    add     x21, x21, #1
    b       .La_loop
.La_done:

    // qsort(terms, term_count, BIGINT_SIZE, compare_bigint)
    mov     x0, x19                  // terms
    mov     x1, x20                  // term_count
    mov     x2, #BIGINT_SIZE         // element size
    adrp    x3, _compare_bigint@PAGE
    add     x3, x3, _compare_bigint@PAGEOFF
    bl      _qsort

    // Count distinct
    mov     x21, #1                  // distinct = 1
    mov     x22, #1                  // i = 1
.Ldistinct_loop:
    cmp     x22, x20
    b.ge    .Ldistinct_done

    // Compare terms[i] with terms[i-1]
    mov     x0, #BIGINT_SIZE
    mul     x1, x22, x0
    add     x1, x19, x1             // &terms[i]
    sub     x2, x22, #1
    mul     x2, x2, x0
    add     x2, x19, x2             // &terms[i-1]

    // Compare lengths first
    ldr     w3, [x1, #MAX_DIGITS]   // terms[i].len
    ldr     w4, [x2, #MAX_DIGITS]   // terms[i-1].len
    cmp     w3, w4
    b.ne    .Lis_different

    // Compare digits from high to low
    sub     w5, w3, #1               // j = len - 1
.Lcmp_digits:
    tbnz    w5, #31, .Lis_same       // if j < 0, they're equal
    ldrb    w6, [x1, x5]
    ldrb    w7, [x2, x5]
    cmp     w6, w7
    b.ne    .Lis_different
    sub     w5, w5, #1
    b       .Lcmp_digits

.Lis_same:
    b       .Lnext_distinct
.Lis_different:
    add     x21, x21, #1
.Lnext_distinct:
    add     x22, x22, #1
    b       .Ldistinct_loop
.Ldistinct_done:

    mov     x22, x21                 // save distinct count

    // Free terms
    mov     x0, x19
    bl      _free

    mov     x0, x22                  // return distinct

    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

// int compare_bigint(const void *a, const void *b)
// Compare two BigInts for qsort
.align 4
_compare_bigint:
    ldr     w2, [x0, #MAX_DIGITS]   // a->len
    ldr     w3, [x1, #MAX_DIGITS]   // b->len
    subs    w4, w2, w3
    b.ne    .Lcmp_ret_diff

    // Same length, compare digits from high to low
    sub     w5, w2, #1               // i = len - 1
.Lcmp_loop:
    tbnz    w5, #31, .Lcmp_equal     // if i < 0
    ldrb    w6, [x0, x5]
    ldrb    w7, [x1, x5]
    subs    w4, w6, w7
    b.ne    .Lcmp_ret_diff
    sub     w5, w5, #1
    b       .Lcmp_loop

.Lcmp_equal:
    mov     w0, #0
    ret

.Lcmp_ret_diff:
    mov     w0, w4
    ret
