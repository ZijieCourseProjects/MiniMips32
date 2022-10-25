# include "trap.h"


.globl main
.text
                                            # V0 V1 used as temp register
                                            # T0 used to count OVERFLOW
                                            # T1 used to count SYSCALL
                                            # T2 used to count the ADES
                                            # T3 used to count the ADEL
                                            # T4 used to count the BREAK
                                            # T5 used to count the RI
main:
    li      $v0,    0x7FFFFFFF
    li      $v1,    0x0000000F
    add     $v0,    $v0,        $v1         # hit the OVERFLOW by add
    li      $v0,    0x7FFFFFFF
    addi    $v0,    $v0,        0xf         # hit the OVERFLOW by addi
    li      $v0,    0x0000000F
    li      $v1,    0x80000000
    sub     $v0,    $v0,        $v1         # hit the OVERFLOW by sub
    syscall                                 # hit the SYSCALL
    break                                   # hit the BREAK
    li      $v0,    0x80000003
    lw      $v1,    0($v0)                  # hit the ADES
    li      $v0,    0x80000003
    sw      $v1,    0($v0)                  # hit the ADEL
    HIT_BAD_TRAP                            # hit the RI
    bne     $t0,    0x3,        end
    bne     $t1,    0x1,        end
    bne     $t2,    0x1,        end
    bne     $t3,    0x1,        end
    bne     $t4,    0x1,        end
    bne     $t5,    0x1,        end
    li      $s0,    1

end:
    HIT_GOOD_TRAP
.org 0x380
    mfc0    $s2,    $13
                                            # get the exception code
    srl     $s2,    $s2,        2
    andi    $s2,    $s2,        0x1F
    beq     $s2,    0x4,        ADEL_c
    beq     $s2,    0x5,        ADES_c
    beq     $s2,    0x8,        SYSCALL_c
    beq     $s2,    0x9,        BREAK_c
    beq     $s2,    0xA,        RI_c
    beq     $s2,    0xC,        OVERFLOW_c
BREAK_c:
    addi    $t4,    $t4,        1
    j       back
SYSCALL_c:
    addi    $t1,    $t1,        1
    j       back
OVERFLOW_c:
    addi    $t0,    $t0,        1
    j       back
ADES_c:
    addi    $t2,    $t2,        1
    j       back
ADEL_c:
    addi    $t3,    $t3,        1
    j       back
RI_c:
    addi    $t5,    $t5,        1
    j       back
                                            # default:
    addi    $s1,    $s1,        1
    j       back

back:
                                            # epc + 4
    mfc0    $s2,    $14
    addi    $s2,    $s2,        4
    mtc0    $s2,    $14
    eret
