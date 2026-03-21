// Problem 91: Right Triangles in Quadrants
// Count right triangles with O(0,0), P(x1,y1), Q(x2,y2), 0<=x,y<=50
// Answer: 14234

.global _solve
.align 4

_solve:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]

    mov x19, #0              // count
    mov x24, #50             // N

    mov x20, #0              // x1
.L91_x1:
    cmp x20, x24
    b.gt .L91_done

    mov x21, #0              // y1
.L91_y1:
    cmp x21, x24
    b.gt .L91_next_x1

    // skip if P = origin
    orr x0, x20, x21
    cbz x0, .L91_next_y1

    mov x22, #0              // x2
.L91_x2:
    cmp x22, x24
    b.gt .L91_next_y1

    mov x23, #0              // y2
.L91_y2:
    cmp x23, x24
    b.gt .L91_next_x2

    // skip if Q = origin
    orr x0, x22, x23
    cbz x0, .L91_next_y2

    // skip if P == Q
    cmp x20, x22
    b.ne .L91_not_same
    cmp x21, x23
    b.eq .L91_next_y2
.L91_not_same:

    // Avoid double counting: x1 > x2 skip; x1==x2 && y1>y2 skip
    cmp x20, x22
    b.gt .L91_next_y2
    b.lt .L91_check_right
    cmp x21, x23
    b.gt .L91_next_y2

.L91_check_right:
    // dot_o = x1*x2 + y1*y2
    mul x0, x20, x22
    mul x1, x21, x23
    add x0, x0, x1
    cbz x0, .L91_found

    // dot_p = (-x1)*(x2-x1) + (-y1)*(y2-y1)
    sub x1, x22, x20        // x2-x1
    neg x2, x20              // -x1
    mul x0, x2, x1
    sub x1, x23, x21        // y2-y1
    neg x2, x21              // -y1
    mul x1, x2, x1
    add x0, x0, x1
    cbz x0, .L91_found

    // dot_q = (-x2)*(x1-x2) + (-y2)*(y1-y2)
    sub x1, x20, x22        // x1-x2
    neg x2, x22              // -x2
    mul x0, x2, x1
    sub x1, x21, x23        // y1-y2
    neg x2, x23              // -y2
    mul x1, x2, x1
    add x0, x0, x1
    cbz x0, .L91_found

    b .L91_next_y2

.L91_found:
    add x19, x19, #1

.L91_next_y2:
    add x23, x23, #1
    b .L91_y2

.L91_next_x2:
    add x22, x22, #1
    b .L91_x2

.L91_next_y1:
    add x21, x21, #1
    b .L91_y1

.L91_next_x1:
    add x20, x20, #1
    b .L91_x1

.L91_done:
    mov x0, x19

    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
