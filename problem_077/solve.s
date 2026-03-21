// Problem 077: Prime Summations
// What is the first value which can be written as the sum of primes in over 5000 ways?
// Answer: 71
//
// Algorithm: Sieve primes up to 1000, then for each target try coin-change DP with primes.

.global _solve
.global _malloc
.global _free
.align 4

.set SIEVE_LIMIT, 1000

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!

    // Allocate sieve on stack: 1000 bytes, round to 1008 (16-aligned)
    sub     sp, sp, #1008

    // Initialize sieve to 1
    mov     x0, sp
    mov     w1, #1
    mov     x2, #SIEVE_LIMIT
.Linit_sieve:
    strb    w1, [x0], #1
    subs    x2, x2, #1
    b.ne    .Linit_sieve

    // Mark 0,1 as not prime
    strb    wzr, [sp]
    strb    wzr, [sp, #1]

    // Sieve of Eratosthenes
    mov     x19, #2              // i
.Lsieve_outer:
    mul     x0, x19, x19
    mov     x1, #SIEVE_LIMIT
    cmp     x0, x1
    b.ge    .Lsieve_done
    ldrb    w2, [sp, x19]
    cbz     w2, .Lsieve_next_i
    // Mark multiples
    mov     x20, x0              // j = i*i
.Lsieve_inner:
    cmp     x20, x1
    b.ge    .Lsieve_next_i
    strb    wzr, [sp, x20]
    add     x20, x20, x19
    b       .Lsieve_inner
.Lsieve_next_i:
    add     x19, x19, #1
    b       .Lsieve_outer
.Lsieve_done:

    // Collect primes into array on stack (max ~168 primes < 1000, need 168*4=672 bytes)
    // Put primes array above sieve
    sub     sp, sp, #688         // 172*4 = 688, 16-aligned
    mov     x21, #0              // num_primes
    mov     x19, #2
    // x22 = base of primes array = sp
    // sieve is at sp + 688
.Lcollect:
    mov     x0, #SIEVE_LIMIT
    cmp     x19, x0
    b.ge    .Lcollect_done
    add     x1, sp, #688
    ldrb    w2, [x1, x19]
    cbz     w2, .Lcollect_skip
    str     w19, [sp, x21, lsl #2]
    add     x21, x21, #1
.Lcollect_skip:
    add     x19, x19, #1
    b       .Lcollect

.Lcollect_done:
    // x21 = num_primes
    // Now try increasing targets
    mov     x22, #2              // target

.Ltarget_loop:
    mov     x0, #SIEVE_LIMIT
    cmp     x22, x0
    b.ge    .Lreturn_zero

    // Allocate dp array: (target+1) * 8 bytes via malloc
    add     x0, x22, #1
    lsl     x0, x0, #3
    mov     x23, x0              // save size
    bl      _malloc
    mov     x24, x0              // x24 = dp pointer

    // Zero dp array
    mov     x0, x24
    mov     x1, #0
    add     x2, x22, #1
.Lzero_dp:
    str     x1, [x0], #8
    subs    x2, x2, #1
    b.ne    .Lzero_dp

    // dp[0] = 1
    mov     x0, #1
    str     x0, [x24]

    // For each prime <= target
    mov     x25, #0              // pi = 0
.Lprime_loop:
    cmp     x25, x21
    b.ge    .Lprime_done
    ldr     w19, [sp, x25, lsl #2] // p = primes[pi]
    cmp     x19, x22
    b.gt    .Lprime_done

    // for i = p; i <= target; i++
    mov     x20, x19
.Ldp_loop:
    cmp     x20, x22
    b.gt    .Lnext_prime
    sub     x1, x20, x19        // i - p
    ldr     x2, [x24, x1, lsl #3]  // dp[i-p]
    ldr     x3, [x24, x20, lsl #3] // dp[i]
    add     x3, x3, x2
    str     x3, [x24, x20, lsl #3]
    add     x20, x20, #1
    b       .Ldp_loop

.Lnext_prime:
    add     x25, x25, #1
    b       .Lprime_loop

.Lprime_done:
    // ways = dp[target]
    ldr     x26, [x24, x22, lsl #3]

    // Free dp
    mov     x0, x24
    bl      _free

    // if ways > 5000, return target
    mov     x0, #5000
    cmp     x26, x0
    b.gt    .Lfound

    add     x22, x22, #1
    b       .Ltarget_loop

.Lfound:
    mov     x0, x22
    b       .Lexit

.Lreturn_zero:
    mov     x0, #0

.Lexit:
    add     sp, sp, #688
    add     sp, sp, #1008
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
