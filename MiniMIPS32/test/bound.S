#include "trap.h"
   .set noat
   .globl main
   .text
   #测试addi,ori的边界
   #addi和ori、andi、xori等立即数虽都是16位,但取值范围不同
   addi  $t2,$zero,0x4     #$t2=0x4
   addi  $t3,$zero,0x3000  #$t3=0x3000
   lui   $s0,0xffff         #$s0=0xffff0000
   lui   $s1,0x7fff         #$s1=0x7fff0000
   lui   $t0,0x7fff         #$t0=0x7fff0000
   lui   $t1,0x8100         #$t1=0x81000000
   ori   $s0,0xffff         #$s0=0xffffffff
   ori   $s1,0xffff         #$s1=0x7fffffff
   addi  $t0,$t0,0x7fff     #$t0=0x7fff7fff
   addi  $t1,$t1,0x8000 #$t1=0x80ff8000
   #测试addu、addiu,subu他们允许溢出并能得到结果
   addu  $s5,$t0,$t0          #正溢出  $s5=0xfffefffe
   addu  $s4,$t1,$t1          #负溢出  $s4=0x01ff0000
   addiu $s3,$t1,0x8000   #负溢出  $s3=0x80ff0000
   addiu $s2,$s1,0x2          #正溢出  $s2=0x80000001
   subu  $s5,$t1,$s1          #负溢出  $s5=0x00ff8001
   subu  $s4,$t0,$t1          #正溢出  $s4=0xfeffffff
   #测试移位指令,立即数范围0-31,而寄存器可以任意设置
   sllv  $s2,$s0,$t2        #$s2=0xfffffff0
   sllv  $s3,$s0,$t3        #$s3=0xffffffff
   sll   $s4,$s0,0x4        #$s4=0xfffffff0
   sll   $s5,$s0,0x1f       #$s5=0x80000000
   srav  $s2,$t1,$t2        #$s2=0xf80ff800
   srav  $s3,$t1,$t3        #$s3=0x80ff8000
   sra   $s4,$t1,0x4        #$s4=0xf80ff800
   sra   $s5,$t1,0x1f       #$s5=0xffffffff
   srlv  $s2,$t1,$t2        #$s2=0x080ff800
   srlv  $s3,$t1,$t3       
   srl   $s4,$t1,0x4        #$s4=0x080ff800
   srl   $s5,$t1,0x1f       #$s5=0x1
   srav  $s2,$s1,$t2        #$s2=0x07ffffff
   srav  $s3,$s1,$t3        #$s3=0x7fffffff
   srl   $s4,$s1,0x4        #$s4=0x07ffffff
   srl   $s5,$s1,0x1f       #$s5=0x0




   
   
   
