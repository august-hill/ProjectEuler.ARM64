// Problem 031: Coin Sums
// How many different ways can 2 pounds be made using any number of coins?
// Answer: 73682

.global _solve
.align 4

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!

    // Allocate ways[201] on stack (201 * 4 = 804 bytes, round to 816 for 16-byte alignment)
    sub     sp, sp, #816
    mov     x19, sp                  // x19 = ways array

    // Zero out ways[]
    mov     x0, x19
    mov     x1, #204                 // 204 words (816/4)
.Lzero:
    str     wzr, [x0], #4
    subs    x1, x1, #1
    b.ne    .Lzero

    // ways[0] = 1
    mov     w0, #1
    str     w0, [x19]

    // Coins: 1, 2, 5, 10, 20, 50, 100, 200
    // Store coins on stack
    sub     sp, sp, #64
    mov     x20, sp                  // x20 = coins array
    mov     w0, #1
    str     w0, [x20, #0]
    mov     w0, #2
    str     w0, [x20, #4]
    mov     w0, #5
    str     w0, [x20, #8]
    mov     w0, #10
    str     w0, [x20, #12]
    mov     w0, #20
    str     w0, [x20, #16]
    mov     w0, #50
    str     w0, [x20, #20]
    mov     w0, #100
    str     w0, [x20, #24]
    mov     w0, #200
    str     w0, [x20, #28]

    // for c = 0; c < 8; c++
    mov     x1, #0                   // c
.Lcoin_loop:
    cmp     x1, #8
    b.ge    .Lcoin_done

    ldr     w2, [x20, x1, lsl #2]   // coin = coins[c]

    // for amount = coin; amount <= 200; amount++
    mov     x3, x2                   // amount = coin
.Lamount_loop:
    cmp     x3, #200
    b.gt    .Lamount_done

    // ways[amount] += ways[amount - coin]
    sub     x4, x3, x2              // amount - coin
    ldr     w5, [x19, x4, lsl #2]   // ways[amount - coin]
    ldr     w6, [x19, x3, lsl #2]   // ways[amount]
    add     w6, w6, w5
    str     w6, [x19, x3, lsl #2]

    add     x3, x3, #1
    b       .Lamount_loop
.Lamount_done:

    add     x1, x1, #1
    b       .Lcoin_loop
.Lcoin_done:

    // return ways[200]
    mov     x0, #200
    ldr     w0, [x19, x0, lsl #2]

    add     sp, sp, #64              // free coins
    add     sp, sp, #816             // free ways
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
