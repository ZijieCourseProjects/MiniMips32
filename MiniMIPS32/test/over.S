#include "trap.h"
   .set noat
   .globl main
   .data 
wdata:  .word 0x7fffffff, 0x00000999
   .text
main: 
    #从内存中取出两个32位数,判断是否二者相加是否溢出,结果保存到v0,溢出为0,不溢出为1
    lui $s0,0x1000     #$s0=0x10000000
    addi $t3,$zero,0x1234  #$t3=0x1234
    addi $t4,$zero,0x5678  #$t4=0x5678
    lui  $s2,0x8000    #$s2=0x80000000
    lw  $t0,0x0($s0)   #$t0=0x7fffffff
    lw  $t1,0x4($s0)   #$t1=0x00000999
    add $t4,$t4,$t3    #$t4=0x68ac
    nop
    sra $t3,$t0,31    #$t3=0
    sra $t4,$t1,31    #$t4=0
    addu $t2,$t0,$t1   #$t2=0x80000998
    nop
    sb  $t3,0x9($s0)
    sb  $t4,0x10($s0)
    sw  $t2,0xc($s0)
    sra $t5,$t2,31    #$t5=0xffffffff
    sltiu $s2,$t3,1    #$s2=1
    sltiu $s3,$t4,1    #$s3=1
    sltiu $s4,$t2,1    #$s4=0
    sltiu $s5,$t5,1    #$s5=0
    and  $s2,$s2,$s3   #$s2=1
    and  $t3,$t3,$t4   #$t3=0
    or   $s4,$s4,$s5   #$s4=0
    lui  $t0,0x1000    #$t0=0x10000000
    and  $s2,$s2,$t5   #$s2=1
    and  $t1,$s2,$s3   #$t1=1
    and  $t3,$t3,$s4   #$t3=0
    nop
    sltiu $s2,$s2,1    #$s2=0
    ori   $t1,$t1,0xffff   #$t1=0xffff
    sltiu $t3,$t3,1        #$t3=1
    sltiu $s6,$t1,0x100    #$s6=0
    nop
    nop
    and  $v0,$s2,$t3    #$v0=0






