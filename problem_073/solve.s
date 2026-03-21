// Problem 73: Counting Fractions in a Range
// How many fractions between 1/3 and 1/2 with d <= 12000?
// Answer: 7295372

.global _solve
.align 4

// GCD subroutine: input x10, x11 -> result x10
.L73_gcd:
    cbz x11, .L73_gcd_done
    udiv x12, x10, x11
    msub x10, x12, x11, x10    // x10 = x10 % x11
    // swap x10, x11
    mov x12, x10
    mov x10, x11
    mov x11, x12
    b .L73_gcd
.L73_gcd_done:
    ret x30

_solve:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]

    mov x19, #0              // count = 0
    mov x20, #2              // d = 2
    mov x21, #12000          // limit
    mov x22, #3              // constant 3
    mov x23, #2              // constant 2

.L73_d_loop:
    cmp x20, x21
    b.gt .L73_done

    // n_min = d / 3 + 1
    udiv x1, x20, x22       // d / 3
    add x1, x1, #1          // n_min

    // n_max = (d % 2 == 0) ? d/2 - 1 : d/2
    udiv x2, x20, x23       // d / 2
    tst x20, #1             // test if d is odd
    b.ne .L73_odd
    sub x2, x2, #1          // even: n_max = d/2 - 1
    b .L73_n_loop_start
.L73_odd:
    // odd: n_max = d/2 (integer division already truncates)

.L73_n_loop_start:
    mov x24, x1             // n = n_min

.L73_n_loop:
    cmp x24, x2
    b.gt .L73_next_d

    // gcd(n, d)
    mov x10, x24
    mov x11, x20
    bl .L73_gcd
    cmp x10, #1
    b.ne .L73_next_n

    add x19, x19, #1        // count++

.L73_next_n:
    add x24, x24, #1
    b .L73_n_loop

.L73_next_d:
    add x20, x20, #1
    b .L73_d_loop

.L73_done:
    mov x0, x19

    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
