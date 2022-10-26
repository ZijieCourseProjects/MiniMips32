# include "trap.h"

.globl main
.text
main:
    li      $v0,    1
    li      $t0,    1
    li      $t1,    11
    li      $a0,    0
loop:
    mult    $v0,    $t0
    mflo    $v0
    addi    $t0,    $t0,    1
    bne     $t0,    $t1,    loop
    move    $s0,    $v0
    li      $t0,    10
loop2:
    div     $zero,  $v0,    $t0
    mflo    $v0
    subu    $t0,    $t0,    1
    bne     $t0,    $a0,    loop2
    beq     $v0,    0x1,    good
    li      $s1,    0x1

good:
    HIT_GOOD_TRAP



