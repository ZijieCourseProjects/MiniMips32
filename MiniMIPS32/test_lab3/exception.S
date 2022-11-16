#include "trap.h"
   .set noat
   .set noreorder
   .globl main
   .text
   #对异常处理进行测试
   main:
   lui $s0,0x1111
   lui  $s7,0x9999     
   addi $s0,$s0,0x1111
   lw  $s1,0x0($zero)    #加载异常 adel
   addi $s0,$s0,0x1111
   syscall               #sys
   addi $s0,$s0,0x1111
   sw  $s1,0x0($zero)    #存储异常 ades
   addi $s0,$s0,0x1111
   break                 #bp
   addi $s0,$s0,0x1111
    #未定义指令ffffffff ri 
   addi $s0,$s0,0x1111
   lui  $s2,0x7fff
   lui  $s3,0x7fff
   add  $s1,$s2,$s3      #ov

   j success
   nop
   



   .org 0x380
      mfc0 $a1, $13
      ori  $a2, $zero, 0x10        # adel
      beq  $a1, $a2, exc_eret
      nop
      mfc0 $a1, $13
      ori  $a2, $zero, 0x14        #ades
      beq  $a1, $a2, exc_eret  
      nop
      mfc0 $a1, $13
      ori  $a2, $zero, 0x20        # sys
      beq  $a1, $a2, exc_eret 
      nop
      mfc0 $a1, $13
      ori  $a2, $zero, 0x24        #bp
      beq  $a1, $a2, exc_eret 
      nop
      mfc0 $a1, $13
      ori  $a2, $zero, 0x28        #ri
      beq  $a1, $a2, exc_eret 
      nop 
      mfc0 $a1, $13
      ori  $a2, $zero, 0x30        #ov
      beq  $a1, $a2, exc_eret 
      nop

      j error
      nop

      error:
      lui  $a3,0xffff
      ori  $a3,$a3,0xffff
      j loop
      nop

      success:
      lui  $a3,0x6666
      ori  $a3,0x6666

      loop:
      j loop
      nop

      .org 0x600
      exc_eret:
      addiu $a3, $a3, 0x1
      mfc0  $t1, $14
      ori   $t0, $zero, 0x4
      add   $t1, $t1, $t0
      mtc0  $t1, $14
      nop

      .set mips32
      eret 
      .set mips1
      nop
      nop
      nop
