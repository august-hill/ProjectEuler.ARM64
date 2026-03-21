// Problem 055: Lychrel Numbers
// How many Lychrel numbers are there below ten-thousand?
// Answer: 249

.global _solve
.align 4

// BigNum: 64 digits stored as bytes, least significant first
// Uses stack-allocated arrays

.set MAX_DIGITS, 64

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!

    mov     x19, #0             // count = 0
    mov     x20, #1             // n = 1

.L55_outer:
    mov     x0, #10000
    cmp     x20, x0
    b.ge    .L55_done

    // Check if n is Lychrel
    // Allocate space for val (64 bytes) + rev (64 bytes) = 128 bytes
    sub     sp, sp, #128
    mov     x21, sp              // x21 = val
    add     x22, sp, #64         // x22 = rev

    // bignum_from_int(val, n)
    mov     x0, x21
    mov     x1, #0
    mov     x2, #64
    bl      _memset
    mov     x0, x20
    mov     x1, x21
    mov     x23, #0             // val.len
    mov     x3, #10
.L55_from_int:
    cbz     x0, .L55_from_done
    udiv    x2, x0, x3
    msub    x4, x2, x3, x0
    strb    w4, [x1, x23]
    add     x23, x23, #1
    mov     x0, x2
    b       .L55_from_int
.L55_from_done:

    // 50 iterations
    mov     x24, #0             // iteration counter
    mov     x25, #0             // is_lychrel = true (0 = not yet palindrome)
.L55_iter:
    cmp     x24, #50
    b.ge    .L55_iter_done

    // Reverse val into rev
    mov     x0, #0              // i
.L55_reverse:
    cmp     x0, x23
    b.ge    .L55_rev_done
    sub     x1, x23, x0
    sub     x1, x1, #1          // j = len - 1 - i
    ldrb    w2, [x21, x1]
    strb    w2, [x22, x0]
    add     x0, x0, #1
    b       .L55_reverse
.L55_rev_done:

    // Add rev to val: val = val + rev
    mov     x0, #0              // i
    mov     x1, #0              // carry
.L55_add:
    cmp     x0, x23
    b.ge    .L55_add_carry
    ldrb    w2, [x21, x0]       // val[i]
    ldrb    w3, [x22, x0]       // rev[i]
    add     w2, w2, w3
    add     w2, w2, w1          // + carry
    mov     w3, #10
    udiv    w1, w2, w3          // carry = sum / 10
    msub    w4, w1, w3, w2      // digit = sum % 10
    strb    w4, [x21, x0]
    add     x0, x0, #1
    b       .L55_add
.L55_add_carry:
    cbz     w1, .L55_add_done
    strb    w1, [x21, x23]
    add     x23, x23, #1
    b       .L55_add_done
.L55_add_done:

    // Check palindrome
    mov     x0, #0              // i
    sub     x1, x23, #1         // j = len - 1
    mov     x25, #1             // assume palindrome
.L55_pal_check:
    cmp     x0, x1
    b.ge    .L55_pal_done
    ldrb    w2, [x21, x0]
    ldrb    w3, [x21, x1]
    cmp     w2, w3
    b.ne    .L55_not_pal
    add     x0, x0, #1
    sub     x1, x1, #1
    b       .L55_pal_check
.L55_not_pal:
    mov     x25, #0
.L55_pal_done:
    cbnz    x25, .L55_is_palindrome

    add     x24, x24, #1
    b       .L55_iter

.L55_is_palindrome:
    // Not Lychrel
    add     sp, sp, #128
    b       .L55_next_n

.L55_iter_done:
    // Is Lychrel (50 iterations without palindrome)
    add     x19, x19, #1
    add     sp, sp, #128

.L55_next_n:
    add     x20, x20, #1
    b       .L55_outer

.L55_done:
    mov     x0, x19

    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
