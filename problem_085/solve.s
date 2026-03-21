// Problem 085: Counting Rectangles
// Find the area of the grid with the nearest solution to containing 2,000,000 rectangles.
// Answer: 2772
//
// Algorithm: For each m, compute cm=m*(m+1)/2, iterate n>=m, count=cm*n*(n+1)/2.
// Track closest to 2000000.

.global _solve
.align 4

.set TARGET, 2000000

_solve:
    // No callee-saved needed, no function calls
    movz    x8, #(TARGET & 0xFFFF)
    movk    x8, #(TARGET >> 16), lsl #16   // x8 = target = 2000000

    mov     x9, #0               // best_area
    mov     x10, x8              // best_diff = target

    mov     x1, #1               // m
.Lm_loop:
    // cm = m*(m+1)/2
    add     x2, x1, #1
    mul     x3, x1, x2
    lsr     x3, x3, #1          // x3 = cm

    cmp     x3, x8
    b.gt    .Lm_done

    mov     x4, x1              // n = m
.Ln_loop:
    // count = cm * n*(n+1)/2
    add     x5, x4, #1
    mul     x6, x4, x5
    lsr     x6, x6, #1          // n*(n+1)/2
    mul     x7, x3, x6          // count

    // diff = |count - target|
    subs    x0, x7, x8
    cneg    x0, x0, mi          // abs(count - target)

    cmp     x0, x10
    b.ge    .Ldiff_skip
    mov     x10, x0             // best_diff = diff
    mul     x9, x1, x4          // best_area = m * n
.Ldiff_skip:

    cmp     x7, x8
    b.gt    .Lm_next

    add     x4, x4, #1
    b       .Ln_loop

.Lm_next:
    add     x1, x1, #1
    cmp     x1, #2000
    b.le    .Lm_loop

.Lm_done:
    mov     x0, x9
    ret
