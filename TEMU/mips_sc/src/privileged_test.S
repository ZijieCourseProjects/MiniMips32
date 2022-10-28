# include "trap.h"

.globl main
.text
main:
    li $v0, 0xFFFFFFFF
    break
    beq $v0, 0, done

    .org 0x380
    li $v0, 0
    mfc0 $v1, $14
    add $v1, $v1, 4
    mtc0 $v1, $14
    ERET
    nop
    nop
    nop


done:
    HIT_GOOD_TRAP
