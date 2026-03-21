// Problem 062: Cubic Permutations
// Find smallest cube where exactly 5 permutations of its digits are also cubes.
// Answer: 127035954683

.global _solve
.align 4

// Hash table approach: for each cube, compute digit signature,
// store in hash table, return first_cube when count reaches 5.

// Using digit count signature: sort digits as a string, hash it.
// Simpler approach: use digit frequency as a 40-bit key (4 bits per digit).

.set HASH_SIZE, 65536
.set MAX_ENTRIES, 50000

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!

    // Allocate:
    // hash_table: HASH_SIZE * 4 = 262144 bytes (int, -1 = empty)
    // entries: MAX_ENTRIES * 24 bytes (sig:8, first_cube:8, count:4, next:4)
    // Total: 262144 + 1200000 = ~1.5MB
    mov     x0, #(HASH_SIZE * 4 + MAX_ENTRIES * 24)
    bl      _malloc
    mov     x19, x0             // base

    // hash_table at x19, entries at x19 + HASH_SIZE*4
    mov     x20, x19                        // hash_table
    add     x21, x19, #(HASH_SIZE * 4)      // entries

    // Init hash_table to -1
    mov     x0, x20
    mov     w1, #0xFF           // memset with 0xFF makes all bytes 0xFF = -1 for int32
    mov     x2, #(HASH_SIZE * 4)
    bl      _memset

    mov     x22, #0             // entry_count = 0

    mov     x23, #1             // n = 1
.L62_loop:
    mov     x0, #100000
    cmp     x23, x0
    b.ge    .L62_not_found

    // cube = n * n * n
    mul     x24, x23, x23
    mul     x24, x24, x23       // cube

    // digit_signature(cube) -> x0
    mov     x0, x24
    bl      .L62_digit_sig
    mov     x25, x0             // sig

    // hash = sig & (HASH_SIZE - 1)
    and     x26, x25, #(HASH_SIZE - 1)

    // Search hash chain
    ldr     w0, [x20, x26, lsl #2]  // idx = hash_table[hash]
.L62_chain:
    cmn     w0, #1              // idx == -1?
    b.eq    .L62_insert

    // Check entries[idx].sig == sig
    mov     x1, #24
    mul     x1, x0, x1
    add     x2, x21, x1         // &entries[idx]
    ldr     x3, [x2]            // entries[idx].sig
    cmp     x3, x25
    b.ne    .L62_chain_next

    // Found: increment count
    ldr     w4, [x2, #16]       // count
    add     w4, w4, #1
    str     w4, [x2, #16]

    cmp     w4, #5
    b.ne    .L62_next_n

    // Return first_cube
    ldr     x0, [x2, #8]
    b       .L62_done

.L62_chain_next:
    ldr     w0, [x2, #20]       // next
    b       .L62_chain

.L62_insert:
    // New entry
    mov     x0, x22             // idx = entry_count
    mov     x1, #24
    mul     x1, x0, x1
    add     x2, x21, x1         // &entries[idx]

    str     x25, [x2]           // sig
    str     x24, [x2, #8]       // first_cube
    mov     w3, #1
    str     w3, [x2, #16]       // count = 1

    // next = hash_table[hash]
    ldr     w3, [x20, x26, lsl #2]
    str     w3, [x2, #20]
    // hash_table[hash] = entry_count
    str     w22, [x20, x26, lsl #2]

    add     x22, x22, #1

.L62_next_n:
    add     x23, x23, #1
    b       .L62_loop

.L62_not_found:
    mov     x0, #0

.L62_done:
    mov     x23, x0
    mov     x0, x19
    bl      _free
    mov     x0, x23

    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

// digit_sig(x0) -> x0 (packed digit counts, 4 bits per digit 0-9)
.L62_digit_sig:
    mov     x1, #0              // sig
    mov     x3, #10
.L62_ds_loop:
    cbz     x0, .L62_ds_done
    udiv    x2, x0, x3
    msub    x4, x2, x3, x0
    mov     x0, x2
    lsl     x5, x4, #2
    mov     x6, #1
    lsl     x6, x6, x5
    add     x1, x1, x6
    b       .L62_ds_loop
.L62_ds_done:
    mov     x0, x1
    ret
