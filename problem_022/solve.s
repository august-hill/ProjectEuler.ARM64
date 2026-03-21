// Problem 022: Names Scores
// Total of all name scores in the file.
// Answer: 871198282
//
// Algorithm: Read names from file, sort alphabetically, compute
// sum of (position * alphabetical_value) for each name.
// Uses C library functions for file I/O and sorting.

.global _solve
.global _fopen
.global _fgets
.global _fclose
.global _strtok
.global _strcmp
.global _qsort
.global _malloc
.global _free
.global _strlen
.align 4

.set MAX_NAMES, 6000
.set MAX_NAME_LEN, 20
.set BUFFER_SIZE, 100000

// long long solve(void)
_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!

    // Allocate: names array = MAX_NAMES * MAX_NAME_LEN = 120000 bytes
    movz    x0, #0xD4C0
    movk    x0, #0x1, lsl #16   // x0 = 120000
    bl      _malloc
    mov     x19, x0              // x19 = names array base

    // Allocate read buffer: 100000 bytes
    movz    x0, #(BUFFER_SIZE & 0xFFFF)
    movk    x0, #(BUFFER_SIZE >> 16), lsl #16
    bl      _malloc
    mov     x20, x0              // x20 = buffer

    mov     x21, #0              // x21 = name_count

    // fopen("problem_022/names.txt", "r")
    adrp    x0, filepath@PAGE
    add     x0, x0, filepath@PAGEOFF
    adrp    x1, mode_r@PAGE
    add     x1, x1, mode_r@PAGEOFF
    bl      _fopen
    mov     x22, x0              // x22 = FILE *f
    cbz     x22, .Lreturn_zero

    // fgets(buffer, BUFFER_SIZE, f)
    mov     x0, x20
    movz    x1, #(BUFFER_SIZE & 0xFFFF)
    movk    x1, #(BUFFER_SIZE >> 16), lsl #16
    mov     x2, x22
    bl      _fgets
    cbz     x0, .Lclose_file

    // fclose(f)
    mov     x0, x22
    bl      _fclose

    // Parse: strtok(buffer, ",") then loop strtok(NULL, ",")
    mov     x0, x20
    adrp    x1, comma@PAGE
    add     x1, x1, comma@PAGEOFF
    bl      _strtok
    // x0 = first token

.Lparse_loop:
    cbz     x0, .Lparse_done
    mov     x23, x0              // x23 = token

    // Skip leading quotes/spaces
    mov     x24, x23
.Lskip_start:
    ldrb    w1, [x24]
    cmp     w1, #'"'
    b.eq    .Lskip_start_inc
    cmp     w1, #' '
    b.eq    .Lskip_start_inc
    b       .Lskip_start_done
.Lskip_start_inc:
    add     x24, x24, #1
    b       .Lskip_start

.Lskip_start_done:
    // Find end, strip trailing quotes/spaces/newlines
    mov     x0, x24
    bl      _strlen
    add     x25, x24, x0
    sub     x25, x25, #1        // x25 = end pointer

.Lskip_end:
    cmp     x25, x24
    b.lt    .Lskip_end_done
    ldrb    w1, [x25]
    cmp     w1, #'"'
    b.eq    .Lskip_end_dec
    cmp     w1, #'\n'
    b.eq    .Lskip_end_dec
    cmp     w1, #' '
    b.eq    .Lskip_end_dec
    b       .Lskip_end_done
.Lskip_end_dec:
    sub     x25, x25, #1
    b       .Lskip_end

.Lskip_end_done:
    // Null-terminate
    add     x25, x25, #1
    strb    wzr, [x25]

    // Copy name into names[name_count]
    // dest = names + name_count * MAX_NAME_LEN
    mov     x0, #MAX_NAME_LEN
    mul     x1, x21, x0
    add     x1, x19, x1          // dest

    // strncpy-like copy
    mov     x2, #0
.Lcopy_name:
    cmp     x2, #(MAX_NAME_LEN - 1)
    b.ge    .Lcopy_done
    ldrb    w3, [x24, x2]
    strb    w3, [x1, x2]
    cbz     w3, .Lcopy_done
    add     x2, x2, #1
    b       .Lcopy_name

.Lcopy_done:
    strb    wzr, [x1, x2]        // null terminate
    add     x21, x21, #1

    // strtok(NULL, ",")
    mov     x0, #0
    adrp    x1, comma@PAGE
    add     x1, x1, comma@PAGEOFF
    bl      _strtok
    b       .Lparse_loop

.Lparse_done:
    // qsort(names, name_count, MAX_NAME_LEN, compare_names)
    mov     x0, x19              // base
    mov     x1, x21              // count
    mov     x2, #MAX_NAME_LEN   // element size
    adrp    x3, .Lcompare_fn@PAGE
    add     x3, x3, .Lcompare_fn@PAGEOFF
    bl      _qsort

    // Compute total score
    mov     x23, #0              // total = 0
    mov     x24, #0              // i = 0

.Lscore_loop:
    cmp     x24, x21
    b.ge    .Lscore_done

    // Compute name_value(names[i])
    mov     x0, #MAX_NAME_LEN
    mul     x1, x24, x0
    add     x1, x19, x1          // pointer to name

    mov     x2, #0               // value sum
.Lval_loop:
    ldrb    w3, [x1], #1
    cbz     w3, .Lval_done
    sub     w3, w3, #('A' - 1)
    add     x2, x2, x3
    b       .Lval_loop

.Lval_done:
    // score = (i + 1) * value
    add     x3, x24, #1
    mul     x2, x3, x2
    add     x23, x23, x2

    add     x24, x24, #1
    b       .Lscore_loop

.Lscore_done:
    mov     x25, x23             // save result

    // Free buffer
    mov     x0, x20
    bl      _free

    // Free names array
    mov     x0, x19
    bl      _free

    mov     x0, x25

    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

.Lclose_file:
    mov     x0, x22
    bl      _fclose
.Lreturn_zero:
    mov     x0, #0

    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

// Compare function for qsort: calls strcmp
// This is called by qsort, so x0 and x1 are the two elements
.Lcompare_fn:
    b       _strcmp               // tail call to strcmp

.data
filepath:
    .asciz "names.txt"
mode_r:
    .asciz "r"
comma:
    .asciz ","
