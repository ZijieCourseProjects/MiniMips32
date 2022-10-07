# include "trap.h"
.set noreorder
.set macro
.set at
.globl main
.text
main:
                                        # set stack pointer
    li      $sp,    0x80000000

# set up the stack
    addiu   $sp,    $sp,        -12
    move    $fp,    $sp
    li      $17,    0xa
    li      $2,     0x1
    sw      $2,     4($fp)              # a[0] = 1
    li      $2,     0x1
    sw      $2,     8($fp)              # a[1] = 1
    li      $2,     0x2
    sw      $2,     12($fp)             # a[2] = 2
    move    $16,    $0                  # i = 0
    j       $L2
    $L3:    
    addiu   $3,     $16,        1       # i+1
    li      $2,     3
    div     $3,     $2                  # (i+1) / 3
    mfhi    $2                          # get remainder
    sll     $2,     $2,         2       # remainder * 4
    addu    $2,     $fp,        $2      # $2 = &a[(i+1) % 3]
    addiu   $4,     $16,        2       # i+2
    li      $5,     3
    div     $4,     $5                  # (i+2) / 3
    mfhi    $4                          # get remainder
    sll     $4,     $4,         2       # remainder * 4
    addu    $4,     $fp,        $4      # $4 = &a[(i+2) % 3]

    div     $16,    $5
    mfhi    $5
    sll     $5,     $5,         2
    addu    $5,     $fp,        $5      # $5 = &a[i % 3]

    lw      $2,     0($2)               # a[(i+1) % 3]
    lw      $4,     0($4)               # a[(i+2) % 3]
    add     $2,     $2,         $4      # a[(i+1) % 3] + a[(i+2) % 3]
    sw      $2,     0($5)               # a[i % 3] = a[(i+1) % 3] + a[(i+2) % 3]
    addiu   $16,    $16,        1       # i++

    
    $L2:    
    slt     $2,     $16,        $17
    bne     $2,     $0,         $L3
    nop     

    HIT_GOOD_TRAP



