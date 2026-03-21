// Problem 010: Summation of Primes
// Find the sum of all primes below two million.
// Answer: 142913828922
//
// Algorithm: Sieve of Eratosthenes, then sum unmarked entries.
// Uses stack-allocated sieve via mmap (2MB).

.global _solve
.global _malloc
.global _free
.align 4

.set LIMIT, 2000000

// long long solve(void)
_solve:
    stp     x29, x30, [sp, #-16]!   // save frame pointer and link register
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!   // save callee-saved registers
    stp     x21, x22, [sp, #-16]!

    // Allocate sieve: malloc(LIMIT)
    movz    x0, #(LIMIT & 0xFFFF)
    movk    x0, #(LIMIT >> 16), lsl #16
    bl      _malloc
    mov     x19, x0                  // x19 = sieve pointer

    // Initialize sieve to 1 (prime) using memset-like loop
    mov     x1, x19                  // dst
    movz    x2, #(LIMIT & 0xFFFF)
    movk    x2, #(LIMIT >> 16), lsl #16
    mov     w3, #1
.Linit_loop:
    strb    w3, [x1], #1
    subs    x2, x2, #1
    b.ne    .Linit_loop

    // Mark 0 and 1 as not prime
    strb    wzr, [x19]
    strb    wzr, [x19, #1]

    // Sieve: for i = 2; i*i < LIMIT; i++
    mov     x20, #2                  // x20 = i
.Lsieve_outer:
    mul     x1, x20, x20            // i*i
    movz    x2, #(LIMIT & 0xFFFF)
    movk    x2, #(LIMIT >> 16), lsl #16
    cmp     x1, x2
    b.ge    .Lsieve_done

    // if sieve[i] == 0, skip
    ldrb    w3, [x19, x20]
    cbz     w3, .Lsieve_next

    // Mark multiples: for j = i*i; j < LIMIT; j += i
    mov     x21, x1                  // x21 = j = i*i
.Lsieve_inner:
    cmp     x21, x2
    b.ge    .Lsieve_next
    strb    wzr, [x19, x21]          // sieve[j] = 0
    add     x21, x21, x20           // j += i
    b       .Lsieve_inner

.Lsieve_next:
    add     x20, x20, #1
    b       .Lsieve_outer

.Lsieve_done:
    // Sum all primes: for i = 2; i < LIMIT; i++ if sieve[i] sum += i
    mov     x0, #0                   // x0 = sum
    mov     x20, #2                  // x20 = i
    movz    x2, #(LIMIT & 0xFFFF)
    movk    x2, #(LIMIT >> 16), lsl #16
.Lsum_loop:
    cmp     x20, x2
    b.ge    .Lsum_done
    ldrb    w3, [x19, x20]
    cbz     w3, .Lsum_skip
    add     x0, x0, x20             // sum += i
.Lsum_skip:
    add     x20, x20, #1
    b       .Lsum_loop

.Lsum_done:
    // Save result
    mov     x22, x0

    // Free sieve
    mov     x0, x19
    bl      _free

    // Return sum
    mov     x0, x22

    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
