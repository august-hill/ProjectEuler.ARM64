// Problem 011: Largest Product in a Grid
// Find the greatest product of four adjacent numbers in the 20x20 grid.
// Answer: 70600674
//
// Algorithm: Check all horizontal, vertical, and diagonal products of 4.

.global _solve
.align 4

.set SIZE, 20
.set SPAN, 4

// long long solve(void)
_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!

    adrp    x19, grid@PAGE
    add     x19, x19, grid@PAGEOFF   // x19 = grid base
    mov     w20, #0                   // w20 = max_product

    mov     w21, #0                   // w21 = i (row)
.Lrow:
    cmp     w21, #SIZE
    b.ge    .Ldone

    mov     w22, #0                   // w22 = j (col)
.Lcol:
    cmp     w22, #SIZE
    b.ge    .Lrow_next

    // Compute grid offset: (i * SIZE + j) * 4
    mov     w0, #SIZE
    mul     w1, w21, w0
    add     w1, w1, w22              // i*20 + j

    // Horizontal (right): if j <= SIZE - SPAN (j <= 16)
    mov     w2, #SIZE - SPAN
    cmp     w22, w2
    b.gt    .Lskip_horiz

    lsl     w3, w1, #2              // byte offset
    ldr     w4, [x19, w3, uxtw]     // grid[i][j]
    add     w3, w1, #1
    lsl     w3, w3, #2
    ldr     w5, [x19, w3, uxtw]     // grid[i][j+1]
    mul     w4, w4, w5
    add     w3, w1, #2
    lsl     w3, w3, #2
    ldr     w5, [x19, w3, uxtw]     // grid[i][j+2]
    mul     w4, w4, w5
    add     w3, w1, #3
    lsl     w3, w3, #2
    ldr     w5, [x19, w3, uxtw]     // grid[i][j+3]
    mul     w4, w4, w5
    cmp     w4, w20
    csel    w20, w4, w20, hi

.Lskip_horiz:
    // Vertical (down): if i <= SIZE - SPAN (i <= 16)
    cmp     w21, w2
    b.gt    .Lskip_vert

    lsl     w3, w1, #2
    ldr     w4, [x19, w3, uxtw]     // grid[i][j]
    add     w3, w1, #SIZE
    lsl     w3, w3, #2
    ldr     w5, [x19, w3, uxtw]     // grid[i+1][j]
    mul     w4, w4, w5
    add     w3, w1, #(SIZE*2)
    lsl     w3, w3, #2
    ldr     w5, [x19, w3, uxtw]     // grid[i+2][j]
    mul     w4, w4, w5
    add     w3, w1, #(SIZE*3)
    lsl     w3, w3, #2
    ldr     w5, [x19, w3, uxtw]     // grid[i+3][j]
    mul     w4, w4, w5
    cmp     w4, w20
    csel    w20, w4, w20, hi

.Lskip_vert:
    // Diagonal down-right: if i <= 16 && j <= 16
    mov     w2, #SIZE - SPAN
    cmp     w21, w2
    b.gt    .Lskip_diag_dr
    cmp     w22, w2
    b.gt    .Lskip_diag_dr

    lsl     w3, w1, #2
    ldr     w4, [x19, w3, uxtw]           // grid[i][j]
    add     w3, w1, #(SIZE + 1)
    lsl     w3, w3, #2
    ldr     w5, [x19, w3, uxtw]           // grid[i+1][j+1]
    mul     w4, w4, w5
    add     w3, w1, #(SIZE*2 + 2)
    lsl     w3, w3, #2
    ldr     w5, [x19, w3, uxtw]           // grid[i+2][j+2]
    mul     w4, w4, w5
    add     w3, w1, #(SIZE*3 + 3)
    lsl     w3, w3, #2
    ldr     w5, [x19, w3, uxtw]           // grid[i+3][j+3]
    mul     w4, w4, w5
    cmp     w4, w20
    csel    w20, w4, w20, hi

.Lskip_diag_dr:
    // Diagonal down-left: if i <= 16 && j >= 3
    cmp     w21, w2
    b.gt    .Lskip_diag_dl
    cmp     w22, #(SPAN - 1)
    b.lt    .Lskip_diag_dl

    lsl     w3, w1, #2
    ldr     w4, [x19, w3, uxtw]           // grid[i][j]
    add     w3, w1, #(SIZE - 1)
    lsl     w3, w3, #2
    ldr     w5, [x19, w3, uxtw]           // grid[i+1][j-1]
    mul     w4, w4, w5
    add     w3, w1, #(SIZE*2 - 2)
    lsl     w3, w3, #2
    ldr     w5, [x19, w3, uxtw]           // grid[i+2][j-2]
    mul     w4, w4, w5
    add     w3, w1, #(SIZE*3 - 3)
    lsl     w3, w3, #2
    ldr     w5, [x19, w3, uxtw]           // grid[i+3][j-3]
    mul     w4, w4, w5
    cmp     w4, w20
    csel    w20, w4, w20, hi

.Lskip_diag_dl:
    add     w22, w22, #1
    b       .Lcol

.Lrow_next:
    add     w21, w21, #1
    b       .Lrow

.Ldone:
    mov     x0, x20              // zero-extend to 64-bit

    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

.data
.align 4
grid:
    .long  8,  2, 22, 97, 38, 15,  0, 40,  0, 75,  4,  5,  7, 78, 52, 12, 50, 77, 91,  8
    .long 49, 49, 99, 40, 17, 81, 18, 57, 60, 87, 17, 40, 98, 43, 69, 48,  4, 56, 62,  0
    .long 81, 49, 31, 73, 55, 79, 14, 29, 93, 71, 40, 67, 53, 88, 30,  3, 49, 13, 36, 65
    .long 52, 70, 95, 23,  4, 60, 11, 42, 69, 24, 68, 56,  1, 32, 56, 71, 37,  2, 36, 91
    .long 22, 31, 16, 71, 51, 67, 63, 89, 41, 92, 36, 54, 22, 40, 40, 28, 66, 33, 13, 80
    .long 24, 47, 32, 60, 99,  3, 45,  2, 44, 75, 33, 53, 78, 36, 84, 20, 35, 17, 12, 50
    .long 32, 98, 81, 28, 64, 23, 67, 10, 26, 38, 40, 67, 59, 54, 70, 66, 18, 38, 64, 70
    .long 67, 26, 20, 68,  2, 62, 12, 20, 95, 63, 94, 39, 63,  8, 40, 91, 66, 49, 94, 21
    .long 24, 55, 58,  5, 66, 73, 99, 26, 97, 17, 78, 78, 96, 83, 14, 88, 34, 89, 63, 72
    .long 21, 36, 23,  9, 75,  0, 76, 44, 20, 45, 35, 14,  0, 61, 33, 97, 34, 31, 33, 95
    .long 78, 17, 53, 28, 22, 75, 31, 67, 15, 94,  3, 80,  4, 62, 16, 14,  9, 53, 56, 92
    .long 16, 39,  5, 42, 96, 35, 31, 47, 55, 58, 88, 24,  0, 17, 54, 24, 36, 29, 85, 57
    .long 86, 56,  0, 48, 35, 71, 89,  7,  5, 44, 44, 37, 44, 60, 21, 58, 51, 54, 17, 58
    .long 19, 80, 81, 68,  5, 94, 47, 69, 28, 73, 92, 13, 86, 52, 17, 77,  4, 89, 55, 40
    .long  4, 52,  8, 83, 97, 35, 99, 16,  7, 97, 57, 32, 16, 26, 26, 79, 33, 27, 98, 66
    .long 88, 36, 68, 87, 57, 62, 20, 72,  3, 46, 33, 67, 46, 55, 12, 32, 63, 93, 53, 69
    .long  4, 42, 16, 73, 38, 25, 39, 11, 24, 94, 72, 18,  8, 46, 29, 32, 40, 62, 76, 36
    .long 20, 69, 36, 41, 72, 30, 23, 88, 34, 62, 99, 69, 82, 67, 59, 85, 74,  4, 36, 16
    .long 20, 73, 35, 29, 78, 31, 90,  1, 74, 31, 49, 71, 48, 86, 81, 16, 23, 57,  5, 54
    .long  1, 70, 54, 71, 83, 51, 54, 69, 16, 92, 33, 48, 61, 43, 52,  1, 89, 19, 67, 48
