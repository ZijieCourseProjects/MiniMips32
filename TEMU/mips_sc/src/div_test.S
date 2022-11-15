.set noreorder
.globl main
.text
main:
    li $v0, 0x100
    li $v1, 0x99
    div $zero, $v0, $v1

    mfhi $a0
    mflo $a1
    nop
