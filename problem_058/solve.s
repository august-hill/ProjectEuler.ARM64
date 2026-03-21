// Problem 058: Spiral Primes
// Side length of square spiral where prime ratio on diagonals < 10%.
// Answer: 26241

.global _solve
.align 4

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!

    mov     x19, #0             // prime_count = 0
    mov     x20, #1             // total_diagonals = 1
    mov     x21, #1             // n = 1

.L58_loop:
    // side = 2*n + 1
    lsl     x22, x21, #1
    add     x22, x22, #1
    // corner = side * side
    mul     x23, x22, x22

    // Check 3 corners (not the bottom-right which is a perfect square)
    mov     x24, #1             // i = 1
.L58_corner:
    cmp     x24, #4
    b.ge    .L58_corners_done
    // val = corner - 2*n*i
    lsl     x0, x21, #1         // 2*n
    mul     x0, x0, x24         // 2*n*i
    sub     x0, x23, x0         // corner - 2*n*i
    bl      .L58_is_prime
    add     x19, x19, x0        // prime_count += result
    add     x24, x24, #1
    b       .L58_corner
.L58_corners_done:

    add     x20, x20, #4        // total_diagonals += 4

    // Check: prime_count * 10 < total_diagonals
    mov     x0, x19
    mov     x1, #10
    mul     x0, x0, x1
    cmp     x0, x20
    b.ge    .L58_continue

    // Ratio below 10%
    mov     x0, x22             // return side
    b       .L58_done

.L58_continue:
    add     x21, x21, #1
    b       .L58_loop

.L58_done:
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

// is_prime(x0) -> x0 (1 if prime, 0 if not)
// Trial division
.L58_is_prime:
    cmp     x0, #2
    b.lt    .L58_not_prime
    b.eq    .L58_yes_prime
    tst     x0, #1
    b.eq    .L58_not_prime

    mov     x1, x0              // save n
    mov     x2, #3              // i = 3
.L58_trial:
    mul     x3, x2, x2
    cmp     x3, x1
    b.gt    .L58_yes_prime
    udiv    x3, x1, x2
    msub    x4, x3, x2, x1
    cbz     x4, .L58_not_prime
    add     x2, x2, #2
    b       .L58_trial

.L58_yes_prime:
    mov     x0, #1
    ret
.L58_not_prime:
    mov     x0, #0
    ret
