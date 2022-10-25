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
        lui $s3,0x1000     #$s3=0x10000000
	     lui $s0,0xffff     #$s0=0xffff0000
	     lui $s2,0x1000     #$s3=0x10000000
        lui $s2,0x1001     #$s3=0x10000000
        lui $s2,0x1002     #$s3=0x10000000
        lui $s2,0x1003     #$s3=0x10000000
        addi $s0,$s0,0x6fff  #$s0=0xffff6fff
        addi $s1,$zero,0x2   #$s1=0x2
        lw  $t0,0($s3)   #$t0=0x00000000
        lw  $t1,4($s3)     #$t1=0x11111111
        lh  $t2,6($s3)   #$t2=0x00001111
        lh  $t3,22($s3)     #$t3=0xffff8765
        lh  $t4,20($s3)  #$t4=0x00004321
        lhu $t5,6($s3)   #$t2=0x00001111
        lhu $t6,22($s3)     #$t3=0x00008765
        lhu $t7,20($s3)  #$t4=0x00004321
        lb  $t2,16($s3)  #$t2=0x00000078
        lb  $t3,23($s3)     #$t3=0xffffff87
        lb  $t4,32($s3)  #$t4=0xffffff88
        lbu $t5,16($s3)  #$t5=0x00000078
        lbu $t6,23($s3)     #$t6=0x00000087
        lbu $t7,32($s3)  #$t7=0x00000088
        sw  $t0,4($s3)    
        sw  $t1,0($s3)
        lw  $t0,0($s3)   #$t0=0x11111111
        lw  $t1,4($s3)     #$t1=0x00000000
        sh  $t2,20($s3)     
        sh  $t3,16($s3)
        lw  $t0,20($s3)  #$t0=0x87650078
        lw  $t1,16($s3)  #$t1=0x1234ff87
        sb  $t4,16($s3)
        sb  $t5,42($s3) 
        lw  $t0,16($s3)  #$t0=0x1234ff88
        lw  $t1,40($s3)  #$t1=0x78000000
        mthi $t3
        mtlo $t4
        mfhi $t0         #$t0=0xffffff87
        mflo $t1         #$t1=0xffffff88
        mult $s0,$s1
        mfhi $t0           #$t0=0xffffffff
        mflo $t1           #$t1=0xfffedffe



        
