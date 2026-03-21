// Problem 043: Sub-string Divisibility
// Find sum of 0-9 pandigitals with substring divisibility.
// Answer: 16695334890

.global _solve
.align 4

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!

    // digits[10] on stack (10 * 4 = 40, round to 48)
    // divisors[7] on stack (7 * 4 = 28, round to 32)
    sub     sp, sp, #80
    mov     x19, sp                  // digits array
    add     x20, sp, #48             // divisors array

    // Initialize digits = {0,1,2,3,4,5,6,7,8,9}
    mov     w0, #0
    str     w0, [x19, #0]
    mov     w0, #1
    str     w0, [x19, #4]
    mov     w0, #2
    str     w0, [x19, #8]
    mov     w0, #3
    str     w0, [x19, #12]
    mov     w0, #4
    str     w0, [x19, #16]
    mov     w0, #5
    str     w0, [x19, #20]
    mov     w0, #6
    str     w0, [x19, #24]
    mov     w0, #7
    str     w0, [x19, #28]
    mov     w0, #8
    str     w0, [x19, #32]
    mov     w0, #9
    str     w0, [x19, #36]

    // divisors = {2, 3, 5, 7, 11, 13, 17}
    mov     w0, #2
    str     w0, [x20, #0]
    mov     w0, #3
    str     w0, [x20, #4]
    mov     w0, #5
    str     w0, [x20, #8]
    mov     w0, #7
    str     w0, [x20, #12]
    mov     w0, #11
    str     w0, [x20, #16]
    mov     w0, #13
    str     w0, [x20, #20]
    mov     w0, #17
    str     w0, [x20, #24]

    mov     x21, #0                  // sum = 0

.Lperm_loop:
    // Check divisibility conditions
    mov     x22, #0                  // i = 0
    mov     x23, #1                  // valid = 1
.Lcheck_loop:
    cmp     x22, #7
    b.ge    .Lcheck_done

    // substr = digits[i+1]*100 + digits[i+2]*10 + digits[i+3]
    add     x1, x22, #1
    ldr     w2, [x19, x1, lsl #2]   // digits[i+1]
    mov     w3, #100
    mul     w2, w2, w3               // *100

    add     x1, x22, #2
    ldr     w4, [x19, x1, lsl #2]   // digits[i+2]
    mov     w3, #10
    mul     w4, w4, w3               // *10
    add     w2, w2, w4

    add     x1, x22, #3
    ldr     w4, [x19, x1, lsl #2]   // digits[i+3]
    add     w2, w2, w4              // substr

    // Check substr % divisors[i] == 0
    ldr     w5, [x20, x22, lsl #2]  // divisors[i]
    udiv    w6, w2, w5
    msub    w7, w6, w5, w2           // substr % divisor
    cbnz    w7, .Lnot_valid

    add     x22, x22, #1
    b       .Lcheck_loop

.Lnot_valid:
    mov     x23, #0
.Lcheck_done:
    cbz     x23, .Lskip_add

    // Build the number from digits
    mov     x24, #0                  // n = 0
    mov     x25, #0                  // i = 0
    // pow10 table: 9,8,7,6,5,4,3,2,1,0 -> 10^9..10^0
    mov     x26, #1                  // will compute 10^(9-i)
.Lbuild_num:
    cmp     x25, #10
    b.ge    .Lbuild_done
    ldr     w27, [x19, x25, lsl #2] // digits[i]

    // Compute 10^(9-i)
    mov     x26, #1
    mov     x28, #9
    sub     x28, x28, x25           // 9 - i
.Lpow10:
    cbz     x28, .Lpow10_done
    mov     x1, #10
    mul     x26, x26, x1
    sub     x28, x28, #1
    b       .Lpow10
.Lpow10_done:

    mul     x27, x27, x26
    add     x24, x24, x27

    add     x25, x25, #1
    b       .Lbuild_num
.Lbuild_done:
    add     x21, x21, x24           // sum += n

.Lskip_add:
    // next_permutation
    // Find k: largest index where digits[k] < digits[k+1]
    mov     x22, #8                  // k = n-2 = 8
.Lfind_k:
    tbnz    x22, #63, .Lperm_done   // k < 0
    ldr     w1, [x19, x22, lsl #2]
    add     x2, x22, #1
    ldr     w3, [x19, x2, lsl #2]
    cmp     w1, w3
    b.lt    .Lfound_k
    sub     x22, x22, #1
    b       .Lfind_k
.Lfound_k:

    // Find l: largest index where digits[k] < digits[l]
    mov     x23, #9
.Lfind_l:
    ldr     w1, [x19, x22, lsl #2]
    ldr     w3, [x19, x23, lsl #2]
    cmp     w1, w3
    b.lt    .Lfound_l
    sub     x23, x23, #1
    b       .Lfind_l
.Lfound_l:

    // Swap digits[k] and digits[l]
    ldr     w1, [x19, x22, lsl #2]
    ldr     w3, [x19, x23, lsl #2]
    str     w3, [x19, x22, lsl #2]
    str     w1, [x19, x23, lsl #2]

    // Reverse digits[k+1..9]
    add     x24, x22, #1            // start
    mov     x25, #9                  // end
.Lreverse:
    cmp     x24, x25
    b.ge    .Lreverse_done
    ldr     w1, [x19, x24, lsl #2]
    ldr     w3, [x19, x25, lsl #2]
    str     w3, [x19, x24, lsl #2]
    str     w1, [x19, x25, lsl #2]
    add     x24, x24, #1
    sub     x25, x25, #1
    b       .Lreverse
.Lreverse_done:

    b       .Lperm_loop
.Lperm_done:

    mov     x0, x21                  // return sum

    add     sp, sp, #80
    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
