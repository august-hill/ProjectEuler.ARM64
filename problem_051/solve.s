// Problem 051: Prime Digit Replacements
// Find smallest prime where replacing 3 digits gives 8 primes.
// Answer: 121313

.global _solve
.align 4

// Sieve of Eratosthenes up to 999999, then check 6-digit primes
// for 3-digit replacement patterns yielding 8 primes.

.set UPPER, 999999
.set LOWER, 99999

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!

    // Allocate sieve: UPPER+1 bytes
    mov     x0, #(UPPER + 1)
    bl      _malloc
    mov     x19, x0             // x19 = is_prime array

    // Initialize all to 1 (true)
    mov     x0, x19
    mov     w1, #1
    mov     x2, #(UPPER + 1)
    bl      _memset

    // Mark 0 and 1 as not prime
    strb    wzr, [x19]
    strb    wzr, [x19, #1]

    // Sieve
    mov     x20, #2             // i = 2
.L51_sieve_outer:
    mul     x0, x20, x20
    mov     x1, #UPPER
    cmp     x0, x1
    b.gt    .L51_sieve_done
    ldrb    w0, [x19, x20]
    cbz     w0, .L51_sieve_next_i
    mul     x21, x20, x20       // j = i*i
.L51_sieve_inner:
    mov     x1, #UPPER
    cmp     x21, x1
    b.gt    .L51_sieve_next_i
    strb    wzr, [x19, x21]
    add     x21, x21, x20
    b       .L51_sieve_inner
.L51_sieve_next_i:
    add     x20, x20, #1
    b       .L51_sieve_outer
.L51_sieve_done:

    // Now search for the answer
    // For each 6-digit prime p, extract digits, try all 3-position combos
    // where the 3 digits are equal, replace with 0-9 and count primes

    mov     x20, #(LOWER + 1)   // p = LOWER+1
.L51_outer:
    mov     x1, #UPPER
    cmp     x20, x1
    b.gt    .L51_not_found

    ldrb    w0, [x19, x20]
    cbz     w0, .L51_next_p

    // Extract 6 digits of x20 into stack buffer
    // digits[0] = hundred-thousands, digits[5] = ones
    sub     sp, sp, #16         // 6 bytes + padding
    mov     x0, x20
    mov     x1, #10
    // Extract digits (least significant first in x2-x7, then reverse)
    udiv    x2, x0, x1
    msub    x3, x2, x1, x0     // digit[5] = ones
    strb    w3, [sp, #5]
    mov     x0, x2
    udiv    x2, x0, x1
    msub    x3, x2, x1, x0
    strb    w3, [sp, #4]
    mov     x0, x2
    udiv    x2, x0, x1
    msub    x3, x2, x1, x0
    strb    w3, [sp, #3]
    mov     x0, x2
    udiv    x2, x0, x1
    msub    x3, x2, x1, x0
    strb    w3, [sp, #2]
    mov     x0, x2
    udiv    x2, x0, x1
    msub    x3, x2, x1, x0
    strb    w3, [sp, #1]
    strb    w2, [sp, #0]        // digit[0] = most significant (should be x2 after last div)
    // Actually x2 here is the remaining quotient which is the most significant digit
    // since we've divided 5 times by 10

    // Try all combinations (i,j,k) where i<j<k, 0<=i<4, i<j<5, j<k<6
    // and digits[i]==digits[j]==digits[k]
    mov     x21, #0             // i
.L51_loop_i:
    mov     x1, #4              // n-2 = 4 (since n=6)
    cmp     x21, x1
    b.ge    .L51_digits_done
    add     x22, x21, #1        // j = i+1
.L51_loop_j:
    mov     x1, #5              // n-1 = 5
    cmp     x22, x1
    b.ge    .L51_next_i
    add     x23, x22, #1        // k = j+1
.L51_loop_k:
    cmp     x23, #6             // n = 6
    b.ge    .L51_next_j

    // Check digits[i] == digits[j] == digits[k]
    ldrb    w0, [sp, x21]
    ldrb    w1, [sp, x22]
    cmp     w0, w1
    b.ne    .L51_next_k
    ldrb    w2, [sp, x23]
    cmp     w1, w2
    b.ne    .L51_next_k

    // Try replacing positions i,j,k with digits 0-9
    mov     x24, #0             // d = 0
    mov     x25, #0             // prime_count = 0
    mov     x26, #0             // first_prime = 0
.L51_try_digit:
    cmp     x24, #10
    b.ge    .L51_check_count

    // Build number with digit d at positions i,j,k
    // Copy digits to temp
    sub     sp, sp, #16
    ldrb    w0, [sp, #16]
    strb    w0, [sp, #0]
    ldrb    w0, [sp, #17]
    strb    w0, [sp, #1]
    ldrb    w0, [sp, #18]
    strb    w0, [sp, #2]
    ldrb    w0, [sp, #19]
    strb    w0, [sp, #3]
    ldrb    w0, [sp, #20]
    strb    w0, [sp, #4]
    ldrb    w0, [sp, #21]
    strb    w0, [sp, #5]

    // Replace positions i,j,k
    strb    w24, [sp, x21]
    strb    w24, [sp, x22]
    strb    w24, [sp, x23]

    // Convert digits to number
    ldrb    w0, [sp, #0]
    ldrb    w1, [sp, #1]
    ldrb    w2, [sp, #2]
    ldrb    w3, [sp, #3]
    ldrb    w4, [sp, #4]
    ldrb    w5, [sp, #5]
    add     sp, sp, #16

    // num = d0*100000 + d1*10000 + d2*1000 + d3*100 + d4*10 + d5
    mov     x6, #100000
    mul     x7, x0, x6
    mov     x6, #10000
    mul     x8, x1, x6
    add     x7, x7, x8
    mov     x6, #1000
    mul     x8, x2, x6
    add     x7, x7, x8
    mov     x6, #100
    mul     x8, x3, x6
    add     x7, x7, x8
    mov     x6, #10
    mul     x8, x4, x6
    add     x7, x7, x8
    add     x7, x7, x5

    // Check num > LOWER and is_prime[num]
    mov     x6, #LOWER
    cmp     x7, x6
    b.le    .L51_next_digit
    ldrb    w0, [x19, x7]
    cbz     w0, .L51_next_digit
    add     x25, x25, #1
    cbnz    x26, .L51_next_digit
    mov     x26, x7             // first_prime

.L51_next_digit:
    add     x24, x24, #1
    b       .L51_try_digit

.L51_check_count:
    cmp     x25, #8
    b.ne    .L51_next_k
    // Found! Return first_prime
    mov     x0, x26
    add     sp, sp, #16         // pop digits
    b       .L51_cleanup

.L51_next_k:
    add     x23, x23, #1
    b       .L51_loop_k
.L51_next_j:
    add     x22, x22, #1
    b       .L51_loop_j
.L51_next_i:
    add     x21, x21, #1
    b       .L51_loop_i

.L51_digits_done:
    add     sp, sp, #16         // pop digits

.L51_next_p:
    add     x20, x20, #1
    b       .L51_outer

.L51_not_found:
    mov     x0, #0

.L51_cleanup:
    mov     x27, x0             // save result
    mov     x0, x19
    bl      _free
    mov     x0, x27

    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
