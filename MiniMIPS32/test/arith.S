#include "trap.h"
   .set noat
   .globl main
   .text
main: 
      lui     $s1,0xffff         #$s1=0xffff0000
      lui     $t0,0xffff         #$t0=0xffff0000
      lui     $s3,0xffff         #$s3=0xffff0000
      addiu   $t1,$zero,0x1111   #$t1=0x1111
      addi    $s1,$s1,0x7fff     #$s1=0xffff7fff
      addi    $t0,$t0,0x7000     #$t0=0xffff7000
      addiu   $s3,$s3,0x7edc     #$s3=0xffff7edc
      nop
      add     $s0,$s1,$s1        #$s0=0xfffefffe
      add     $t2,$s1,$t0        #$t2=0xfffeefff
      addu    $s2,$s1,$s3        #$s2=0xfffefedb
      addu    $t2,$t0,$t1        #$t2=0xffff8111
      sub     $s4,$zero,$s1      #$s4=0x08001
      subu    $s5,$s1,$s0        #$s5=0x08001
      slt     $s4,$t1,$t0        #$s4=0
      sltu    $s5,$t1,$t0        #$s5=1
      slt     $s6,$s3,$s1        #$s6=1
      sltu    $s7,$s3,$s1        #$s7=1
      slti    $s4,$t1,0xff        #$s4=0
      sltiu   $s5,$t1,0xff        #$s5=0
      slti    $s6,$s1,0xff        #$s6=1
      sltiu   $s7,$s1,0xff        #$s7=0
      mult    $s1,$s1            #$lo=0x40010001
      multu   $s1,$s1            #$hi=0xfffefffe  $lo=0x40010001
      mult    $t1,$s6        #$lo=0x1111
      multu   $t1,$s6        
      lui     $s1,0x89ab        #$s1=0x89ab0000
      lui     $s0,0x1234        #$s0=0x12340000
      and     $s4,$t0,$s3        #$s4=0xffff7000
      and     $s5,$t1,$t2        #$s5=0x111
      andi    $s6,$t0,0x8000        #$s6=0
      andi    $s7,$t1,0x1000        #$s7=0x1000
      addi    $s1,$s1,0x7def        #$s1=0x89ab7def
      addi    $s0,$s0,0x5678        #$s0=12345678
      nor     $s4,$t0,$s3        #$s4=0x8123
      nor     $s5,$t0,$s3        #$s5=0x8123
      or      $s4,$s1,$t0        #$s4=0xffff7def
      or      $s5,$s1,$t0        #$s5=0xffff7def
      ori     $s6,$s1,0x8        #$s6=0x89ab7def
      ori     $s7,$s1,0x8        #$s7=0x89ab7def
      xor     $s4,$s0,$s1        #$s4=0x9b9f2b97
      nop
      xori    $s6,$s0,0x8        #$s6=0x12345670
      xori    $s7,$s1,0x0        #$s7=0x89ab7def
      addu    $s4,$s1,$s1        #$s4=0x1356fbde
      subu    $s5,$s0,$s1        #$s5=0x8888d889
      addi    $t0,$zero,0x3        #$t0=3
      addi    $t1,$zero,0x4        #$t1=4
      sll     $s4,$s0,3        #$s4=0x91a2b3c0
      sll     $s5,$s1,4        #$s5=0x9ab7def0
      sllv    $s6,$s0,$t0        #$s6=0x91a2b3c0
      sllv    $s7,$s1,$t1        #$s7=0x9ab7def0
      srav    $s4,$s0,$t0        #$s4=0x2468acf
      srav    $s5,$s1,$t1        #$s5=0xf89ab7de
      sra     $s5,$s0,0x3        #$s5=0x2468acf
      sra     $s6,$s1,0x4        #$s6=0xf89ab7de
      srlv    $s4,$s0,$t1        #$s4=0x1234567
      srlv    $s5,$s1,$t0        #$s5=0x11356fbd
      srl     $s5,$s0,0x4        #$s5=0x1234567
      srl     $s6,$s1,0x3        #$s6=0x11356fbd
#测试算术运算指令与逻辑运算指令