.text
main :
addiu $sp, $sp, -3000
sw $ra,2996($sp)
sw $fp,2992($sp)
move $fp,$sp
li $t0,5
sw $t0,2988($fp)
li $t0,7
sw $t0,2984($fp)
lw $t0,2988($fp)
lw $t1,2984($fp)
slt $t0,$t0,$t1
li $a0,0
ble $t0,$a0,L18
j L11
L11 :
lw $t0,2988($fp)
lw $t1,2984($fp)
seq $t0,$t0,$t1
li $a0,0
ble $t0,$a0,L18
j L16
L16 :
li $t0,15
sw $t0,2988($fp)
L18 :
lw $t0,2988($fp)
sw $t0,2980($fp)
move $sp,$fp
lw $fp,2992($sp)
lw $ra,2996($sp)
addiu $sp, $sp, 3000
j $ra
