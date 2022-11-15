#include "trap.h"
   .set noat
   .globl main
   .text
   #跳转指令的测试,使用延迟槽
   #本次测试根据对比PC跳跃即可,部分语句执行两次,会将PC值前后放置,记录均为下一条的PC值
main:
    addi $s0,$zero,0x1      
    lui  $a0,0xbfc0     
    ori  $a0,0x0104    
    j    L0              #PC=0xbfc0070
    addi $s0,$s0,0x12
    nop
    

L3:

    ori  $t5,0xffff
    bgez $t5,L0
    nop
    lui  $s0,0x8000
    addi $t6,$zero,0x1
    bgez $t3,L0         #PC=0xbfc00070
    nop
    nop

L1:
    blez $s0,L2         #PC+4   PC=0xbfc000ac
    nop
    addi $s2,$s0,0x22
    beq  $s0,$s1,L2
    nop
    xor  $s3,$s2,$s0
    lui  $t0,0x1234
    ori  $t0,0x5678
    beq  $s6,$s7,L2       #PC=0xbfc00ac
    nop
    nop
L6:
    jalr   $v0,$a1       #PC=0xbfc000dc 即L5
    nop
    nop
L0:
    bgtz $t3,L1   #PC+4  PC=0xbfc00038
    nop
    jal  L1           #PC=0xbfc00038
    nop
    ori  $s1,$zero,0x34
L4:
    lui   $a1,0xbfc0
    addi  $a1,$a1,0x00dc
    bgezal $t1,L6
    nop
    lui   $at,0x0000  #nop
    bgezal $at,L6      #PC+4   PC=0xbfc00064
    nop
    jr    $a0          #PC=0xbfc00064 即L6
    nop
    nop
L2:
    bltz $t4,L4           #PC+4   PC=0xbfc00084
    nop
    lui  $t1,0x8765
    ori  $t1,0x4321
    add  $t3,$zero,$t0
    add  $t4,$zero,$t1
    bne  $t3,$t0,L3
    nop
    lui  $t5,0xffff
    bne  $t3,$t5,L3       #PC=0xbfc00018
    nop
    nop

L5:
    bltzal $t0,L4  
    nop
    nop
    addi  $at,0x0001
    bltzal $t1,L7       #PC+8
    nop
    nop

L7:
     jr    $a0          #PC=0xbfc00104 即L8
     nop
     nop
L8:
     nop
	
