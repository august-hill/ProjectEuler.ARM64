// Problem 018: Maximum Path Sum I
// Find the maximum total from top to bottom of the triangle.
// Answer: 1074
//
// Algorithm: Dynamic programming, bottom-up. Copy bottom row into dp array,
// then for each row from second-to-last to top, dp[col] = tri[row][col] + max(dp[col], dp[col+1]).

.global _solve
.align 4

.set ROWS, 15

// long long solve(void)
_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!

    adrp    x19, triangle@PAGE
    add     x19, x19, triangle@PAGEOFF

    // Allocate dp[15] on stack (15 * 4 = 60 bytes, round to 64)
    sub     sp, sp, #64
    mov     x20, sp              // x20 = dp array

    // Copy last row into dp
    // Last row starts at offset: sum(1..14) * 4 = 105 * 4 = 420
    // Offset of row r in flat array: r*(r+1)/2
    // Row 14: 14*15/2 = 105, so offset = 105*4 = 420 bytes
    mov     w1, #0
.Lcopy_last:
    cmp     w1, #ROWS
    b.ge    .Lcopy_done
    // triangle[ROWS-1][i] is at offset (105 + i) * 4
    add     w2, w1, #105
    lsl     w2, w2, #2
    ldr     w3, [x19, w2, uxtw]
    lsl     w4, w1, #2
    str     w3, [x20, w4, uxtw]
    add     w1, w1, #1
    b       .Lcopy_last

.Lcopy_done:
    // Process rows from ROWS-2 (13) down to 0
    mov     w21, #(ROWS - 2)     // w21 = row

.Lrow_loop:
    cmp     w21, #0
    b.lt    .Lrow_done

    // Row offset in triangle: row*(row+1)/2
    add     w1, w21, #1
    mul     w1, w21, w1
    lsr     w1, w1, #1          // w1 = row_offset

    mov     w22, #0              // w22 = col
.Lcol_loop:
    cmp     w22, w21
    b.gt    .Lcol_done

    // Load triangle[row][col]
    add     w2, w1, w22
    lsl     w2, w2, #2
    ldr     w3, [x19, w2, uxtw] // triangle[row][col]

    // Load dp[col] and dp[col+1]
    lsl     w4, w22, #2
    ldr     w5, [x20, w4, uxtw] // dp[col]
    add     w6, w22, #1
    lsl     w6, w6, #2
    ldr     w7, [x20, w6, uxtw] // dp[col+1]

    // max(dp[col], dp[col+1])
    cmp     w5, w7
    csel    w5, w5, w7, ge

    // dp[col] = triangle[row][col] + max
    add     w3, w3, w5
    str     w3, [x20, w4, uxtw]

    add     w22, w22, #1
    b       .Lcol_loop

.Lcol_done:
    sub     w21, w21, #1
    b       .Lrow_loop

.Lrow_done:
    // Result is dp[0] (ldr w0 zero-extends to x0)
    ldr     w0, [x20]

    add     sp, sp, #64

    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

.data
.align 4
// Triangle stored as flat array of .long (row-major, variable length rows)
// Total elements: 15*16/2 = 120
triangle:
    .long 75
    .long 95, 64
    .long 17, 47, 82
    .long 18, 35, 87, 10
    .long 20,  4, 82, 47, 65
    .long 19,  1, 23, 75,  3, 34
    .long 88,  2, 77, 73,  7, 63, 67
    .long 99, 65,  4, 28,  6, 16, 70, 92
    .long 41, 41, 26, 56, 83, 40, 80, 70, 33
    .long 41, 48, 72, 33, 47, 32, 37, 16, 94, 29
    .long 53, 71, 44, 65, 25, 43, 91, 52, 97, 51, 14
    .long 70, 11, 33, 28, 77, 73, 17, 78, 39, 68, 17, 57
    .long 91, 71, 52, 38, 17, 14, 91, 43, 58, 50, 27, 29, 48
    .long 63, 66,  4, 68, 89, 53, 67, 30, 73, 16, 69, 87, 40, 31
    .long  4, 62, 98, 27, 23,  9, 70, 98, 73, 93, 38, 53, 60,  4, 23
