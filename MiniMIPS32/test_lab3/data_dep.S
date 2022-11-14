#include "trap.h"
   .set noat
   .globl main
   .text
#数据相关的测试
main:
#普通指令的测试
    lui    $s0,0x1234       #$s0=0x12340000
    ori    $s0,$s0,0x5678       #$s0=0x12345678
    lui    $v0,0x8000       #$v0=0x80000000
    addi   $v0,$v0,0x1       #$v0=0x80000001
    add    $s1,$s0,$v0       #$s1=0x92345679
    addu   $s2,$s1,$v0       #$s2=0x1234567a
    addu   $s3,$s2,$v0       #$s3=0x9234567b
    addiu  $s4,$s3,0x7000       #$s4=0x9234c67b
    add    $at,$s4,$zero       #$at=0x9234c67b
    add    $s7,$at,$s2       #$s7=0xa4691cf5
    slt    $v1,$s3,$s4       #$v1=0x1
    slt    $t2,$s3,$s6       #$t2=0x1
    slti   $t3,$s6,0x0       #$t3=0x0
    addi   $t3,$zero,0x1234       #$t3=0x1234
    sub    $s3,$t3,$s1       #$s3=0x6dcbbbbb
    xor    $s4,$s3,$t3       #$s4=0x6dcba98f
    or     $s5,$s3,$s4       #$s5=0x6dcbbbbf
    and    $s6,$s3,$s4       #$s6=0x6dcba98b
    sltu   $v1,$s6,$s5       #$v1=1
    sltiu  $t2,$s5,0x0       #$t2=0
    sltu   $t3,$t2,$v1       #$t3=1
    lui   $s0,0x1234       #$s0=0x12340000
    ori   $s0,0x5678       #$s0=0x12345678
    lui   $v0,0x8000       #$v0=0x80000000
    add   $v0,$v0,$s0      #$v0=0x92345678
    add   $v0,$v0,$s0      #$v0=0xa468acf0
    add   $v0,$v0,$s0      #$v0=0xb69d0368
    add   $v0,$v0,$s0      #$v0=0xc8d159e0
#hilo寄存器相关指令测试
    mult  $s0,$v0       
    mfhi  $s1       #$s1=0xfc137034
    mflo  $s2       #$s2=0x77d36100
    mthi  $s2       
    mtlo  $s1
    mfhi  $s3       #$s3=0x77d36100
    mflo  $s4       #$s4=0xfc137034
    multu $s0,$v0
    mfhi  $s1       #$s1=0x0e47c6ac
    mflo  $s2       
    mthi  $s2       
    mtlo  $s1
    mfhi  $s3       
    mflo  $s4       #$s4=0x0e47c6ac


