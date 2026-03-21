// Problem 023: Non-abundant Sums
// Find the sum of all positive integers which cannot be written
// as the sum of two abundant numbers.
// Answer: 4179871
//
// Algorithm: Find all abundant numbers up to 28123, mark sums of
// pairs, sum unmarked numbers.

.global _solve
.global _malloc
.global _free
.align 4

.set LIMIT, 28123

// long long solve(void)
_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!

    // Allocate abundants array: 10000 * 4 = 40000 bytes
    mov     x0, #40000
    bl      _malloc
    mov     x19, x0              // x19 = abundants (int array)

    // Allocate expressible array: LIMIT + 1 bytes
    movz    x0, #(LIMIT + 1)
    bl      _malloc
    mov     x20, x0              // x20 = expressible (byte array)

    // Zero expressible array
    mov     x1, x20
    movz    x2, #(LIMIT + 1)
.Lzero:
    strb    wzr, [x1], #1
    subs    x2, x2, #1
    b.ne    .Lzero

    mov     x21, #0              // x21 = abundant_count

    // Find all abundant numbers from 12 to LIMIT
    mov     x22, #12             // x22 = i
.Lfind_loop:
    movz    x1, #(LIMIT & 0xFFFF)
    movk    x1, #(LIMIT >> 16), lsl #16
    cmp     x22, x1
    b.gt    .Lfind_done

    // sum_proper_divisors(i)
    mov     x0, x22
    bl      .Lspd
    // x0 = sum of proper divisors

    cmp     x0, x22
    b.le    .Lfind_next

    // It's abundant: abundants[count] = i
    lsl     x1, x21, #2
    str     w22, [x19, x1]
    add     x21, x21, #1

.Lfind_next:
    add     x22, x22, #1
    b       .Lfind_loop

.Lfind_done:
    // Mark all sums of pairs of abundant numbers
    mov     x22, #0              // i
.Lmark_i:
    cmp     x22, x21
    b.ge    .Lmark_done

    lsl     x1, x22, #2
    ldr     w23, [x19, x1]      // abundants[i]

    mov     x24, x22             // j = i
.Lmark_j:
    cmp     x24, x21
    b.ge    .Lmark_i_next

    lsl     x1, x24, #2
    ldr     w25, [x19, x1]      // abundants[j]

    add     w26, w23, w25       // sum = abundants[i] + abundants[j]
    movz    w1, #(LIMIT & 0xFFFF)
    movk    w1, #(LIMIT >> 16), lsl #16
    cmp     w26, w1
    b.gt    .Lmark_i_next        // break if sum > LIMIT

    // expressible[sum] = 1
    mov     w2, #1
    strb    w2, [x20, w26, uxtw]

    add     x24, x24, #1
    b       .Lmark_j

.Lmark_i_next:
    add     x22, x22, #1
    b       .Lmark_i

.Lmark_done:
    // Sum all non-expressible numbers
    mov     x0, #0               // result
    mov     x22, #1              // i = 1
    movz    x1, #(LIMIT & 0xFFFF)
    movk    x1, #(LIMIT >> 16), lsl #16

.Lsum_loop:
    cmp     x22, x1
    b.gt    .Lsum_done

    ldrb    w2, [x20, x22]
    cbnz    w2, .Lsum_next
    add     x0, x0, x22         // result += i

.Lsum_next:
    add     x22, x22, #1
    b       .Lsum_loop

.Lsum_done:
    mov     x25, x0             // save result

    // Free arrays
    mov     x0, x20
    bl      _free
    mov     x0, x19
    bl      _free

    mov     x0, x25

    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

// sum_proper_divisors(x0) -> x0
// Clobbers x9-x15
.Lspd:
    cmp     x0, #1
    b.le    .Lspd_zero

    mov     x9, x0              // n
    mov     x10, #1             // sum = 1
    mov     x11, #2             // i = 2

.Lspd_loop:
    mul     x12, x11, x11
    cmp     x12, x9
    b.gt    .Lspd_done

    udiv    x13, x9, x11
    msub    x14, x13, x11, x9
    cbnz    x14, .Lspd_next

    add     x10, x10, x11
    cmp     x13, x11
    b.eq    .Lspd_next
    add     x10, x10, x13

.Lspd_next:
    add     x11, x11, #1
    b       .Lspd_loop

.Lspd_done:
    mov     x0, x10
    ret

.Lspd_zero:
    mov     x0, #0
    ret
