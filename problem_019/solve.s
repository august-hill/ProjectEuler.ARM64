// Problem 019: Counting Sundays
// How many Sundays fell on the first of the month during the 20th century?
// Answer: 171
//
// Algorithm: Track day of week starting from Jan 1 1900 (Monday = 1).
// Advance through 1900, then count Sundays on 1st from 1901-2000.

.global _solve
.align 4

// long long solve(void)
_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!

    adrp    x19, days_in_month_tbl@PAGE
    add     x19, x19, days_in_month_tbl@PAGEOFF

    // Jan 1, 1900 was a Monday (day_of_week = 1, 0 = Sunday)
    mov     w20, #1              // w20 = day_of_week
    mov     w21, #0              // w21 = count

    // Advance through 1900 (year = 1900)
    mov     w1, #1               // month = 1
.Ladv_1900:
    cmp     w1, #12
    b.gt    .Ladv_1900_done

    // Get days_in_month(month, 1900)
    ldrb    w2, [x19, w1, uxtw] // days_in_month_tbl[month]
    // Check Feb leap year: 1900 is NOT a leap year (divisible by 100 but not 400)
    // So no adjustment needed for 1900

    add     w20, w20, w2
    mov     w3, #7
    udiv    w4, w20, w3
    msub    w20, w4, w3, w20     // day_of_week %= 7

    add     w1, w1, #1
    b       .Ladv_1900

.Ladv_1900_done:
    // Count Sundays on 1st from 1901 to 2000
    mov     w22, #1901           // w22 = year

.Lyear_loop:
    cmp     w22, #2000
    b.gt    .Lyear_done

    mov     w1, #1               // month = 1
.Lmonth_loop:
    cmp     w1, #12
    b.gt    .Lmonth_done

    // Check if day_of_week == 0 (Sunday)
    cbnz    w20, .Lnot_sunday
    add     w21, w21, #1         // count++
.Lnot_sunday:

    // Get days in month
    ldrb    w2, [x19, w1, uxtw]

    // Check if Feb and leap year
    cmp     w1, #2
    b.ne    .Lnot_feb

    // is_leap_year(year)?
    // (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
    mov     w3, #400
    udiv    w4, w22, w3
    msub    w5, w4, w3, w22
    cbz     w5, .Lis_leap        // year % 400 == 0 -> leap

    mov     w3, #100
    udiv    w4, w22, w3
    msub    w5, w4, w3, w22
    cbz     w5, .Lnot_feb        // year % 100 == 0 -> not leap

    mov     w3, #4
    udiv    w4, w22, w3
    msub    w5, w4, w3, w22
    cbnz    w5, .Lnot_feb        // year % 4 != 0 -> not leap

.Lis_leap:
    add     w2, w2, #1           // Feb has 29 days

.Lnot_feb:
    add     w20, w20, w2
    mov     w3, #7
    udiv    w4, w20, w3
    msub    w20, w4, w3, w20     // day_of_week %= 7

    add     w1, w1, #1
    b       .Lmonth_loop

.Lmonth_done:
    add     w22, w22, #1
    b       .Lyear_loop

.Lyear_done:
    mov     x0, x21              // zero-extend count

    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

.data
.align 4
// days_in_month_tbl[0..12]: index 0 unused, 1=Jan..12=Dec (non-leap)
days_in_month_tbl:
    .byte 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
