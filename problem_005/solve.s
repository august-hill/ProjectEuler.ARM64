// Problem 005: Smallest Multiple
// Find the smallest positive number divisible by all numbers from 1 to 20.
// Answer: 232792560
//
// Algorithm: Iterative LCM using GCD (Euclidean algorithm).

.global _solve
.align 4

// long long solve(void)
_solve:
    mov     x0, #1              // x0 = result
    mov     x1, #2              // x1 = i

.Lloop:
    cmp     x1, #20
    b.gt    .Ldone

    // result = lcm(result, i) = result / gcd(result, i) * i
    // Compute gcd(result, i)
    mov     x2, x0              // x2 = a = result
    mov     x3, x1              // x3 = b = i
.Lgcd:
    cbz     x3, .Lgcd_done
    udiv    x4, x2, x3
    msub    x5, x4, x3, x2      // x5 = a % b
    mov     x2, x3
    mov     x3, x5
    b       .Lgcd

.Lgcd_done:
    // x2 = gcd(result, i)
    // result = result / gcd * i
    udiv    x0, x0, x2
    mul     x0, x0, x1

    add     x1, x1, #1
    b       .Lloop

.Ldone:
    ret
