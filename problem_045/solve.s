// Problem 045: Triangular, Pentagonal, and Hexagonal
// Find next number after 40755 that is triangular, pentagonal, and hexagonal.
// Answer: 1533776805

.global _solve
.align 4

_solve:
    mov     x1, #1                   // p (pentagonal index)
    mov     x2, #1                   // h (hexagonal index)
    mov     x3, #1                   // pn
    mov     x4, #1                   // hn
    mov     x5, #40755

.L45_loop:
    cmp     x4, x3
    b.lt    .L45_adv_h
    b.gt    .L45_adv_p

    // pn == hn
    cmp     x4, x5
    b.gt    .L45_found

    // Advance both
    add     x1, x1, #1
    mov     x6, #3
    mul     x6, x1, x6
    sub     x6, x6, #1
    mul     x3, x1, x6
    lsr     x3, x3, #1

    add     x2, x2, #1
    lsl     x6, x2, #1
    sub     x6, x6, #1
    mul     x4, x2, x6
    b       .L45_loop

.L45_adv_h:
    add     x2, x2, #1
    lsl     x6, x2, #1
    sub     x6, x6, #1
    mul     x4, x2, x6
    b       .L45_loop

.L45_adv_p:
    add     x1, x1, #1
    mov     x6, #3
    mul     x6, x1, x6
    sub     x6, x6, #1
    mul     x3, x1, x6
    lsr     x3, x3, #1
    b       .L45_loop

.L45_found:
    mov     x0, x4
    ret
