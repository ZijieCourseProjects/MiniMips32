#include "trap.h"
   .set noat
   .globl main
   .text
main: 
      lui     $s0,0x0fff
      lui     $s1,0x3eee
      lui     $s2,0x5bbb
      lui     $s3,0x0000
      lui     $t0,0xffff
      lui     $t1,0x8000
      lui     $t2,0xeeee
      lui     $t3,0x0000
      addiu   $s0,$s0,0x7fff
      addiu   $s1,$s1,0x7eee
      addiu   $s2,$s2,0x7bbb
      addiu   $s3,$s3,0x0001
      addiu   $t0,$t0,0x7fff
      addiu   $t1,$t1,0x0000
      addiu   $t2,$t2,0x7eee
      addiu   $t3,$t3,0x0000
      #++注以下内容都为前hi后lo
      mult    $s0,$s0   #0x00fff000  #0x20010001    
      mult    $s1,$s1   #0x0f7863ab  #0x89772544
      mult    $s2,$s0   #0x5bb89dd   #0x96670445
      mult    $s3,$s1   #0           #0x3eee7eee
      #--
      mult    $t0,$t0   #0           #0x40010001
      mult    $t1,$t1   #0x40000000  #0
      mult    $t0,$t1   #0x4000      #0x80000000
      mult    $t1,$t2   #0x888c089     #0
      #00
      mult    $t3,$s0   #0 #0
      mult    $t3,$s0   #0 #0
      mult    $s0,$t0   #0xfffff800  #0x30010001
      mult    $s1,$t1   #0xe088c089  #0
      mult    $t2,$s2   #0xf9e24715  #0x710d11da
      mult    $t1,$s3   #0xffffffff  #0x80000000
      #++
      multu    $s0,$s0  #0x00fff000  #0x2001001
      multu    $s1,$s1  #0x0f7863ab  #0x89772544
      multu    $s2,$s0  #0x5bb89dd   #0x96670445
      multu   $s3,$s1   #0           #0x3eee7eee
      #--
      multu    $t0,$t0  #0xfffefffe  #0x40010001
      multu    $t1,$t1  #0x40000000  #0
      multu    $t0,$t1  #0x7fffbfff  #0x80000000
      multu    $t1,$t2  #0x77773f77  #0
      #00
      multu    $t3,$s0  #0 #0
      multu    $t3,$s0  #0 #0
      multu    $s0,$t0  #0xfff77ff   #0x30010001
      multu    $s1,$t1  #0x1f773f77  #0
      multu    $t2,$s2  #0x559dc2d0  #0x710d11da
      multu    $t1,$s3  #0  #0x80000000