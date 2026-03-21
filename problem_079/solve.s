// Problem 079: Passcode Derivation
// Given login attempts, find the shortest possible secret passcode.
// Answer: 73162890
//
// Algorithm: Build ordering constraints from digit triples, topological sort.
// Data: 50 login attempts hardcoded from p079_keylog.txt

.global _solve
.align 4

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!

    // Allocate on stack:
    // digits[10] : 10 bytes (which digits are present)
    // after[10][10] : 100 bytes (after[a][b] = a must come before b)
    // used[10] : 10 bytes
    // result_digits[10] : 10 bytes (but use 4-byte ints = 40 bytes)
    // Total: ~160 bytes, round to 176 (16-aligned)
    sub     sp, sp, #176

    // Layout:
    // sp+0:   digits[10]      (10 bytes)
    // sp+16:  after[10][10]   (100 bytes, at offset 16)
    // sp+120: used[10]        (10 bytes)
    // sp+132: result_digits   (40 bytes, 10 x 4-byte ints)

    // Zero everything
    mov     x0, sp
    mov     x1, #0
    mov     x2, #176
.Lzero:
    strb    w1, [x0], #1
    subs    x2, x2, #1
    b.ne    .Lzero

    // Process each attempt triple
    adr     x19, .Lattempts
    mov     x20, #50             // num attempts

.Lprocess_loop:
    cbz     x20, .Lprocess_done
    ldrb    w21, [x19]           // a
    ldrb    w22, [x19, #1]       // b
    ldrb    w23, [x19, #2]       // c

    // Mark digits present
    mov     w0, #1
    strb    w0, [sp, x21]
    strb    w0, [sp, x22]
    strb    w0, [sp, x23]

    // after[a][b] = 1
    mov     x0, #10
    madd    x1, x21, x0, x22    // a*10 + b
    add     x1, x1, #16
    strb    w0, [sp, x1]

    // after[a][c] = 1
    madd    x1, x21, x0, x23
    add     x1, x1, #16
    mov     w2, #1
    strb    w2, [sp, x1]

    // after[b][c] = 1
    madd    x1, x22, x0, x23
    add     x1, x1, #16
    strb    w2, [sp, x1]

    add     x19, x19, #3
    sub     x20, x20, #1
    b       .Lprocess_loop

.Lprocess_done:
    // Count total digits present
    mov     x24, #0              // total_digits
    mov     x0, #0
.Lcount_digits:
    cmp     x0, #10
    b.ge    .Lcount_done
    ldrb    w1, [sp, x0]
    add     x24, x24, x1
    add     x0, x0, #1
    b       .Lcount_digits
.Lcount_done:

    // Topological sort
    mov     x20, #0              // result_len

.Ltopo_loop:
    cmp     x20, x24
    b.ge    .Ltopo_done

    mov     x21, #0              // d = 0
.Lfind_no_pred:
    cmp     x21, #10
    b.ge    .Ltopo_done          // shouldn't happen

    // if !digits[d] || used[d], skip
    ldrb    w0, [sp, x21]
    cbz     w0, .Lnext_d
    add     x0, sp, #120
    ldrb    w0, [x0, x21]
    cbnz    w0, .Lnext_d

    // Check if any remaining digit must come before d
    mov     x22, #0              // o
    mov     w23, #0              // has_pred
.Lcheck_pred:
    cmp     x22, #10
    b.ge    .Lcheck_pred_done
    cmp     x22, x21
    b.eq    .Lnext_o
    ldrb    w0, [sp, x22]        // digits[o]
    cbz     w0, .Lnext_o
    add     x0, sp, #120
    ldrb    w0, [x0, x22]        // used[o]
    cbnz    w0, .Lnext_o
    // Check after[o][d]
    mov     x0, #10
    madd    x1, x22, x0, x21
    add     x1, x1, #16
    ldrb    w0, [sp, x1]
    cbnz    w0, .Lhas_pred
.Lnext_o:
    add     x22, x22, #1
    b       .Lcheck_pred
.Lhas_pred:
    mov     w23, #1
.Lcheck_pred_done:
    cbnz    w23, .Lnext_d

    // No predecessor found - add d to result
    add     x0, sp, #132
    str     w21, [x0, x20, lsl #2]
    add     x20, x20, #1
    // Mark used
    mov     w0, #1
    add     x1, sp, #120
    strb    w0, [x1, x21]
    b       .Ltopo_loop          // restart search

.Lnext_d:
    add     x21, x21, #1
    b       .Lfind_no_pred

.Ltopo_done:
    // Build result number
    mov     x0, #0               // result
    mov     x21, #0              // i
.Lbuild:
    cmp     x21, x20
    b.ge    .Lbuild_done
    mov     x1, #10
    mul     x0, x0, x1
    add     x2, sp, #132
    ldr     w3, [x2, x21, lsl #2]
    add     x0, x0, x3
    add     x21, x21, #1
    b       .Lbuild

.Lbuild_done:
    add     sp, sp, #176
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

// Hardcoded keylog data (50 triples, each 3 bytes)
.align 2
.Lattempts:
    .byte 3,1,9
    .byte 6,8,0
    .byte 1,8,0
    .byte 6,9,0
    .byte 1,2,9
    .byte 6,2,0
    .byte 7,6,2
    .byte 6,8,9
    .byte 7,6,2
    .byte 3,1,8
    .byte 3,6,8
    .byte 7,1,0
    .byte 7,2,0
    .byte 7,1,0
    .byte 6,2,9
    .byte 1,6,8
    .byte 1,6,0
    .byte 6,8,9
    .byte 7,1,6
    .byte 7,3,1
    .byte 7,3,6
    .byte 7,2,9
    .byte 3,1,6
    .byte 7,2,9
    .byte 7,2,9
    .byte 7,1,0
    .byte 7,6,9
    .byte 2,9,0
    .byte 7,1,9
    .byte 6,8,0
    .byte 3,1,8
    .byte 3,8,9
    .byte 1,6,2
    .byte 2,8,9
    .byte 1,6,2
    .byte 7,1,8
    .byte 7,2,9
    .byte 3,1,9
    .byte 7,9,0
    .byte 6,8,0
    .byte 8,9,0
    .byte 3,6,2
    .byte 3,1,9
    .byte 7,6,0
    .byte 3,1,6
    .byte 7,2,9
    .byte 3,8,0
    .byte 3,1,9
    .byte 7,2,8
    .byte 7,1,6
