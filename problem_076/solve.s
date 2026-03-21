// Problem 076: Counting Summations
// How many different ways can 100 be written as a sum of at least two positive integers?
// Answer: 190569291
//
// Algorithm: Coin-change style DP. dp[0]=1, for part=1..99, for i=part..100: dp[i]+=dp[i-part]

.global _solve
.align 4

.set TARGET, 100

// long long solve(void)
_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    // dp array: 101 * 8 = 808 bytes, round up to 816 (multiple of 16)
    sub     sp, sp, #816

    // Zero the dp array
    mov     x0, sp
    mov     x1, #0
    mov     x2, #101
.L76_zero_dp:
    str     x1, [x0], #8
    subs    x2, x2, #1
    b.ne    .L76_zero_dp

    // dp[0] = 1
    mov     x0, #1
    str     x0, [sp]

    // for part = 1; part < TARGET (100); part++
    mov     x19, #1

.L76_part_loop:
    cmp     x19, #TARGET
    b.ge    .L76_part_done

    // for i = part; i <= TARGET; i++
    mov     x20, x19
.L76_i_loop:
    cmp     x20, #TARGET
    b.gt    .L76_next_part

    // dp[i] += dp[i - part]
    sub     x1, x20, x19
    ldr     x2, [sp, x1, lsl #3]
    ldr     x3, [sp, x20, lsl #3]
    add     x3, x3, x2
    str     x3, [sp, x20, lsl #3]

    add     x20, x20, #1
    b       .L76_i_loop

.L76_next_part:
    add     x19, x19, #1
    b       .L76_part_loop

.L76_part_done:
    // return dp[TARGET]
    mov     x0, #TARGET
    ldr     x0, [sp, x0, lsl #3]

    add     sp, sp, #816
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
