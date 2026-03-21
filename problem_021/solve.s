// Problem 021: Amicable Numbers
// Evaluate the sum of all amicable numbers under 10000.
// Answer: 31626
//
// Algorithm: For each a < 10000, compute b = sum_proper_divisors(a).
// If b != a && b < 10000 && sum_proper_divisors(b) == a, add a to sum.

.global _solve
.align 4

.set LIMIT, 10000

// long long solve(void)
_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!

    mov     x19, #0              // x19 = total sum
    mov     x20, #2              // x20 = a

.La_loop:
    mov     x9, #LIMIT
    cmp     x20, x9
    b.ge    .La_done

    // b = sum_proper_divisors(a)
    mov     x0, x20
    bl      .Lsum_divisors
    mov     x21, x0              // x21 = b

    // if b == a, skip
    cmp     x21, x20
    b.eq    .La_next

    // if b >= 10000, skip
    mov     x9, #LIMIT
    cmp     x21, x9
    b.ge    .La_next

    // if sum_proper_divisors(b) == a
    mov     x0, x21
    bl      .Lsum_divisors
    cmp     x0, x20
    b.ne    .La_next

    add     x19, x19, x20       // sum += a

.La_next:
    add     x20, x20, #1
    b       .La_loop

.La_done:
    mov     x0, x19

    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

// sum_proper_divisors(x0) -> x0
// Uses x9-x15 (caller-saved temporaries)
.Lsum_divisors:
    // if n <= 1, return 0
    cmp     x0, #1
    b.le    .Lspd_zero

    mov     x9, x0              // x9 = n
    mov     x10, #1             // x10 = sum = 1
    mov     x11, #2             // x11 = i

    // Compute integer sqrt: find largest i where i*i <= n
    // We'll just iterate up

.Lspd_loop:
    mul     x12, x11, x11       // i*i
    cmp     x12, x9
    b.gt    .Lspd_done

    // if n % i == 0
    udiv    x13, x9, x11
    msub    x14, x13, x11, x9   // n % i
    cbnz    x14, .Lspd_next

    add     x10, x10, x11       // sum += i
    // other = n / i
    cmp     x13, x11             // if other != i
    b.eq    .Lspd_next
    add     x10, x10, x13       // sum += other

.Lspd_next:
    add     x11, x11, #1
    b       .Lspd_loop

.Lspd_done:
    mov     x0, x10
    ret

.Lspd_zero:
    mov     x0, #0
    ret
