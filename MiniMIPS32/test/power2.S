#include "trap.h"
   .set noat
   .globl main
   .data 
wdata:  .word 0x00000040,0x00000080
   .text
main: 

    lui       $s6,0x8000        #$s6=0x80000000
    lui       $s0,0x1000        #$s0=0x10000000
    addi      $t0,$zero,0x1     #$t0=1
    nop
    addi      $s7,$s6,0x3000    #$s7=0x80003000
    lw        $t1,0x0($s0)        #$t1=0x40
    sub       $t2,$zero,$t0       #$t2=0xffffffff
    addu      $t6,$zero,$s0       #$t6=0x10000000
    nop
    sra       $t3,$t1,31         #$t3=0
    add       $t4,$t1,$t2        #$t4=0x3f
    addu      $s0,$t1,$t1        #$s0=0x80
    sltu      $s2,$zero,$t0      #$s2=1
    sltiu     $s1,$t3,1          #$s1=1
    xor       $t5,$t1,$t4        #$t5=0x7f
    nop
    xor       $s2,$s2,$t2        #$s2=0xfffffffe
    xor       $s1,$s1,$t2        #$s1=0xfffffffe
    xor       $s0,$s0,$t5        #$s0=0xff
    addu      $t5,$t5,$t0        #$t5=0x80
    sltu      $s2,$zero,$s2      #$s2=1
    addiu     $s1,$s1,1          #$s1=0xffffffff
    xor       $s0,$s0,$t2        #$s0=0xffffff00
    sb        $s0,0x0($t6)
    nop
    and       $s1,$s1,$s2        #$s1=1
    sb        $t2,0x2($t6)
    sltu      $s0,$zero,$s0      #$s0=1
    nop
    sltu      $s1,$zero,$s1      #$s1=1
    lw        $t6,0x0($t6)       #$t6=0x00ff0000
    nop
    nop
    and       $s1,$s1,$s0        #$s1=1
