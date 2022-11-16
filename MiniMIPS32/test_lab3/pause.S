#include "trap.h"
   .set noat
   .globl main
   .data
wdata:  .word 0x00000000, 0x11111111, 0x22222222,0x33333333,0x12345678,0x87654321
hdata:  .half 0x4444, 0x5555, 0x6666, 0x7777
bdata:  .byte 0x88,0x99,0xaa,0xbb
udata:  .space 11
wdata1:  .word 0x12345678,0x89abcdef
   .text
main:
#多周期除法指令的测试
#正正相除
   lui  $s0,0x7fff      #$s0=0x7fff0000
   ori  $s0,0xffff      #$s0=0x7fffffff
   addi $s1,0x1234      #$s1=0x00001234
   div  $zero,$s0,$s1
   lui  $t0,0x8000      #$t0=0x80000000
   mfhi $t4             #$t4=0x74b
   mflo $t5             #$t5=0x70821
   divu $zero,$s0,$s1
   lui  $t1,0xffff      #$t1=0xffff0000
   mfhi $t6             #$t6=0x74b
   mflo $t7             #$t7=0x70821
#正负相除
   div  $zero,$s0,$t1
   mfhi $t4      #$t4=0xffff
   mflo $t5      #$t5=0xffff8001
   divu $zero,$s0,$t1
   mfhi $t6      #$t6=0x7fffffff
   mflo $t7      #$t7=0
#负正相除
   div  $zero,$t0,$s1
   mfhi $t4      #$t4=0xfffff8b4
   mflo $t5      #$t5=0xfff8f7df
   divu $zero,$t0,$s1
   mfhi $t6      #$t6=0x74c
   mflo $t7      #$t7=0x70821
#负负相除
   div  $zero,$t1,$t0
   mfhi $t4      #$t4=0xffff0000
   mflo $t5      #$t5=0
   divu $zero,$t1,$t0
   mfhi $t6      #$t6=0x7fff0000
   mflo $t7      #$t7=0x1

#存取指令的测试
   lui  $at,0x8000    #$at=0x80000000
   sw   $at,0x0($at)
   lw   $t4,0x0($at)  #$t4=0x80000000
   add  $t5,$zero,$t4  #$t5=0x80000000
   add  $t6,$zero,$t5  #$t6=0x80000000

   addi $a0,$at,0x4  #$a0=0x80000004
   sh   $a0,0x0($a0)
   lh   $a1,0x0($a0)  #$a1=0x4
   xor  $t4,$zero,$a1  #$t4=0x4
   addi $t5,$t4,0x1  #$t5=0x5
   addi $a0,$a0,0x4  #$a0=0x80000008
   sh   $a0,0x6($a0)
   lhu   $a1,0x6($a0)  #$a1=0x8
   add  $t4,$zero,$a1  #$t4=0x8
   addi $t5,$t4,0x1    #$t5=0x9

   ori  $t5,$t5,0xee  #$t5=0xef
   sb   $t5,0x5($a0)
   addi $s1,$s1,0x1234  #$s1=0x2468
   lb   $s1,0x5($a0)  #$s1=0xffffffef
   addu $s2,$s1,$s1  #$s2=0xffffffde
   addi $s1,$s1,0x1234  #$s1=0x1223
   lbu  $s1,0x5($a0)  #$s1=0xef
   addu $s2,$s1,$s1  #$s2=0x1de

   addi  $s1,$zero,0x1111  #$s1=0x1111
   addi  $at,$at,0x10  #$at=0x80000010
   sb    $s1,0x1($at)
   addu  $s1,$s1,$s1  #$s1=0x2222
   sb    $s1,0x0($at)
   add   $s1,$s1,$s1  #$s1=0x4444
   sh    $s1,0x2($at)
   addi  $s1,$s1,0x1111  #$s1=0x5555
   sw    $s1,0x4($at)
   lb    $t4,0x6($at)  #$t4=0x0
   xor   $t4,$t4,$t4
   lbu   $t5,0x7($at)  #$t5=0x0
   ori   $t5,$t5,0xee  #$t5=0xee
   lh    $t6,0x6($at)  #$t6=0x0
   sub   $t6,$zero,$t6
   lhu   $t7,0x4($at)  #$t7=0x5555
   add   $t7,$t7,$t6
   lw    $t4,0x0($at)  #$t4=0x44441122
   addu  $t4,$t4,$t3








