// Problem 017: Number Letter Counts
// Count letters used writing 1-1000 in British English.
// Answer: 21124
//
// Algorithm: Lookup tables for ones, teens, tens; handle hundreds and "and".

.global _solve
.align 4

.set HUNDRED_LEN, 7     // "hundred"
.set THOUSAND_LEN, 8    // "thousand"
.set AND_LEN, 3         // "and"

// long long solve(void)
_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!

    adrp    x19, ones@PAGE
    add     x19, x19, ones@PAGEOFF
    adrp    x20, teens@PAGE
    add     x20, x20, teens@PAGEOFF
    adrp    x21, tens@PAGE
    add     x21, x21, tens@PAGEOFF

    mov     x0, #0               // x0 = total sum
    mov     x22, #1              // x22 = i (1..1000)

.Lmain_loop:
    cmp     x22, #1000
    b.gt    .Lmain_done

    // letter_count(i) -> w1
    mov     w1, #0               // count for this number
    mov     w2, w22              // w2 = n (working copy)

    // Special case: 1000
    cmp     w2, #1000
    b.ne    .Lnot_thousand
    // "one" + "thousand" = 3 + 8 = 11
    ldrb    w3, [x19, #1]       // ones[1] = 3
    add     w1, w1, w3
    add     w1, w1, #THOUSAND_LEN
    b       .Ladd_to_sum

.Lnot_thousand:
    // Hundreds place
    cmp     w2, #100
    b.lt    .Lunder_hundred
    mov     w3, #100
    udiv    w4, w2, w3           // w4 = n / 100
    ldrb    w5, [x19, w4, uxtw] // ones[n/100]
    add     w1, w1, w5
    add     w1, w1, #HUNDRED_LEN  // + "hundred"
    msub    w2, w4, w3, w2       // w2 = n % 100
    cbz     w2, .Ladd_to_sum
    add     w1, w1, #AND_LEN    // + "and"

.Lunder_hundred:
    // Tens and ones
    cmp     w2, #20
    b.lt    .Lunder_twenty

    // n >= 20
    mov     w3, #10
    udiv    w4, w2, w3           // w4 = n/10
    ldrb    w5, [x21, w4, uxtw] // tens[n/10]
    add     w1, w1, w5
    msub    w4, w4, w3, w2       // w4 = n%10
    ldrb    w5, [x19, w4, uxtw] // ones[n%10]
    add     w1, w1, w5
    b       .Ladd_to_sum

.Lunder_twenty:
    cmp     w2, #10
    b.lt    .Lunder_ten

    // 10..19 -> teens[n-10]
    sub     w3, w2, #10
    ldrb    w5, [x20, w3, uxtw]
    add     w1, w1, w5
    b       .Ladd_to_sum

.Lunder_ten:
    // 0..9 -> ones[n]
    ldrb    w5, [x19, w2, uxtw]
    add     w1, w1, w5

.Ladd_to_sum:
    add     x0, x0, x1
    add     x22, x22, #1
    b       .Lmain_loop

.Lmain_done:
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

.data
.align 4
// ones[0..9]: "", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"
ones:
    .byte 0, 3, 3, 5, 4, 4, 3, 5, 5, 4

// teens[0..9]: "ten", "eleven", "twelve", "thirteen", "fourteen",
//              "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"
teens:
    .byte 3, 6, 6, 8, 8, 7, 7, 9, 8, 8

// tens[0..9]: "", "", "twenty", "thirty", "forty", "fifty",
//             "sixty", "seventy", "eighty", "ninety"
tens:
    .byte 0, 0, 6, 6, 5, 5, 5, 7, 6, 6
