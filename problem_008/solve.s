// Problem 008: Largest Product in a Series
// Find the thirteen adjacent digits with the greatest product.
// Answer: 23514624000
//
// Algorithm: O(n) sliding window, split by zeros, divide/multiply sliding.

.global _solve
.align 4

.set K, 13

// long long solve(void)
_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!

    adrp    x19, digits@PAGE
    add     x19, x19, digits@PAGEOFF  // x19 = digits pointer
    mov     x20, #1000          // length of digits string
    mov     x21, #0             // x21 = max_product
    mov     x22, #0             // x22 = start

.Lsegment:
    // Check start <= n - k
    sub     x1, x20, #K
    cmp     x22, x1
    b.gt    .Ldone

    // Find zero in window [start, start+k)
    mov     x23, #-1            // zero_pos = -1
    mov     x1, x22             // i = start
    add     x2, x22, #K         // start + k
.Lfind_zero:
    cmp     x1, x2
    b.ge    .Lfind_zero_done
    ldrb    w3, [x19, x1]
    sub     w3, w3, #'0'
    cbnz    w3, .Lfind_zero_next
    mov     x23, x1             // zero_pos = i
.Lfind_zero_next:
    add     x1, x1, #1
    b       .Lfind_zero

.Lfind_zero_done:
    // If zero found, skip past it
    cmp     x23, #0
    b.lt    .Lno_zero
    add     x22, x23, #1        // start = zero_pos + 1
    b       .Lsegment

.Lno_zero:
    // Calculate initial product for window [start, start+k)
    mov     x24, #1             // product = 1
    mov     x1, x22
    add     x2, x22, #K
.Linit_prod:
    cmp     x1, x2
    b.ge    .Linit_prod_done
    ldrb    w3, [x19, x1]
    sub     x3, x3, #'0'
    mul     x24, x24, x3
    add     x1, x1, #1
    b       .Linit_prod

.Linit_prod_done:
    cmp     x24, x21
    csel    x21, x24, x21, hi   // max_product = max(product, max_product)

    // Slide: i from start+k to n-1
    add     x25, x22, #K        // x25 = i = start + k
.Lslide:
    cmp     x25, x20
    b.ge    .Lslide_done_end

    // Check for zero at position i
    ldrb    w3, [x19, x25]
    sub     w3, w3, #'0'
    cbz     w3, .Lslide_hit_zero

    // product = product / digits[i-k] * digits[i]
    sub     x1, x25, #K
    ldrb    w4, [x19, x1]
    sub     x4, x4, #'0'
    udiv    x24, x24, x4        // product /= old digit
    ldrb    w3, [x19, x25]
    sub     x3, x3, #'0'
    mul     x24, x24, x3        // product *= new digit

    cmp     x24, x21
    csel    x21, x24, x21, hi

    // Check if we reached end
    sub     x1, x20, #1
    cmp     x25, x1
    b.ne    .Lslide_next
    mov     x22, x20             // start = n (exit outer loop)
    b       .Lslide_done

.Lslide_next:
    add     x25, x25, #1
    b       .Lslide

.Lslide_hit_zero:
    add     x22, x25, #1        // start = i + 1
    b       .Lslide_done

.Lslide_done_end:
    mov     x22, x20            // start = n
.Lslide_done:
    b       .Lsegment

.Ldone:
    mov     x0, x21

    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

.data
digits:
    .ascii "73167176531330624919225119674426574742355349194934"
    .ascii "96983520312774506326239578318016984801869478851843"
    .ascii "85861560789112949495459501737958331952853208805511"
    .ascii "12540698747158523863050715693290963295227443043557"
    .ascii "66896648950445244523161731856403098711121722383113"
    .ascii "62229893423380308135336276614282806444486645238749"
    .ascii "30358907296290491560440772390713810515859307960866"
    .ascii "70172427121883998797908792274921901699720888093776"
    .ascii "65727333001053367881220235421809751254540594752243"
    .ascii "52584907711670556013604839586446706324415722155397"
    .ascii "53697817977846174064955149290862569321978468622482"
    .ascii "83972241375657056057490261407972968652414535100474"
    .ascii "82166370484403199890008895243450658541227588666881"
    .ascii "16427171479924442928230863465674813919123162824586"
    .ascii "17866458359124566529476545682848912883142607690042"
    .ascii "24219022671055626321111109370544217506941658960408"
    .ascii "07198403850962455444362981230987879927244284909188"
    .ascii "84580156166097919133875499200524063689912560717606"
    .ascii "05886116467109405077541002256983155200055935729725"
    .ascii "71636269561882670428252483600823257530420752963450"
