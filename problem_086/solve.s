// Problem 086: Cuboid Route
// Find least M such that the number of cuboid shortest routes exceeds one million.
// Answer: 1818
//
// Algorithm: For each M, iterate s=2..2M, check if M^2+s^2 is perfect square.

.global _solve
.align 4

_solve:
    mov     x9, #0               // count
    mov     x10, #1              // m

.Lm_loop:
    mov     x11, #2              // s

.Ls_loop:
    lsl     x0, x10, #1
    cmp     x11, x0
    b.gt    .Ls_done

    // sq = m*m + s*s
    mul     x1, x10, x10
    madd    x1, x11, x11, x1

    // Integer sqrt using FP: root = (int)sqrt((double)sq)
    ucvtf   d0, x1
    fsqrt   d0, d0
    fcvtzu  x2, d0               // root = (unsigned)sqrt(sq)

    // Check root*root == sq (try root and root+1 for rounding)
    mul     x3, x2, x2
    cmp     x3, x1
    b.eq    .Lperfect
    add     x2, x2, #1
    mul     x3, x2, x2
    cmp     x3, x1
    b.ne    .Ls_next

.Lperfect:
    // c_min = max(s - m, 1)
    subs    x4, x11, x10
    mov     x5, #1
    cmp     x4, x5
    csel    x4, x4, x5, gt

    // c_max = s / 2
    lsr     x5, x11, #1

    cmp     x5, x4
    b.lt    .Ls_next

    sub     x0, x5, x4
    add     x0, x0, #1
    add     x9, x9, x0

.Ls_next:
    add     x11, x11, #1
    b       .Ls_loop

.Ls_done:
    movz    x0, #0x4240
    movk    x0, #0xF, lsl #16
    cmp     x9, x0
    b.gt    .Lfound

    add     x10, x10, #1
    b       .Lm_loop

.Lfound:
    mov     x0, x10
    ret
