# include "trap.h"
.data
.globl result
result: .space 4
fib_N: .word 0x6

.globl main
.text
main:
    la      $s0,    fib_N
    lw      $a0,    0($s0)
    move    $v0,    $a0
    blt     $a0,    2,      done
    li      $t0,    0
    li      $v0,    1
fib:
    add     $t1,    $t0,    $v0
    move    $t0,    $v0
    move    $v0,    $t1
    sub     $a0,    $a0,    1
    bgt     $a0,    1,      fib
done:
    sw      $v0,    result
    HIT_GOOD_TRAP