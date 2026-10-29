.data
scores:     .word 4, 1, 6, 7, 0, 3, 5, 0, 4, 7, 2, 1
grade_tab:  .byte 0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3
            .align 2                               
hist:       .word 0, 0, 0, 0
s_min:      .asciiz "min="
s_max:      .asciiz " max="
s_g0:       .asciiz "g0="
s_g1:       .asciiz " g1="
s_g2:       .asciiz " g2="
s_g3:       .asciiz " g3="
nl:         .asciiz "\n"
t1: .asciiz "(a+b)*[c-{d/e}]"
t2: .asciiz "f(x[i]{j}))"
t3: .asciiz "{[(])}"
t4: .asciiz "((a)"
t5: .asciiz ""
t6: .asciiz "no brackets here"
t7: .asciiz "]"
t8: .asciiz "([)]"
tp: .asciiz "([{([{([{([{}])}])}])}])"
    .align 2
tests: .word t1, t2, t3, t4, t5, t6, t7, t8, tp
s_bo: .asciiz "Bo "
s_col: .asciiz ": ("
s_com: .asciiz ", "
s_end: .asciiz ")\n"
 
.text
main:
#nap tham so tinh max min
 
la $a0, scores
li $a1, 12
jal stats
move $s0, $v0
move $s1, $v1
 
#nap tham so goi histogram
 
la $a0, scores
li $a1, 12
la $a2, grade_tab
la $a3, hist
jal histogram
 
#in min max
 
li $v0, 4
la $a0, s_min
syscall
li $v0, 1
move $a0, $s0
syscall
li $v0, 4
la $a0, s_max
syscall
li $v0, 1
move $a0, $s1
syscall
li $v0, 4
la $a0, nl
syscall
 
#in goi histogram
 
la $s2, hist
li $v0, 4
la $a0, s_g0
syscall
li $v0, 1
lw $a0, 0($s2)
syscall
li $v0, 4
la $a0, s_g1
syscall
li $v0, 1
lw $a0, 4($s2)
syscall
li $v0, 4
la $a0, s_g2
syscall
li $v0, 1
lw $a0, 8($s2)
syscall
li $v0, 4
la $a0, s_g3
syscall
li $v0, 1
lw $a0, 12($s2)
syscall
li $v0, 4
la $a0, nl
syscall
 
#kiem tra ngoac
 
la   $s0, tests
li   $s1, 9
li   $s4, 0
main_loop:
beq  $s1, $zero, main_done
addi $s4, $s4, 1
lw   $a0, 0($s0)
jal  check_brackets
move $s2, $v0
move $s3, $v1
 
li   $v0, 4
la   $a0, s_bo
syscall
li   $v0, 1
move $a0, $s4
syscall
li   $v0, 4
la   $a0, s_col
syscall
li   $v0, 1
move $a0, $s2
syscall
li   $v0, 4
la   $a0, s_com
syscall
li   $v0, 1
move $a0, $s3
syscall
li   $v0, 4
la   $a0, s_end
syscall
 
addi $s0, $s0, 4
addi $s1, $s1, -1
j    main_loop
main_done:
li   $v0, 10
syscall
 
stats:
lw $v0, 0($a0)
move $v1, $v0
addi $a0, $a0, 4
addi $a1, $a1, -1
 
st_loop:
beq $a1, $zero, st_done
lw $t0, 0($a0)
slt $t1, $t0, $v0
beq $t1, $zero, st_notmin
move $v0, $t0
st_notmin:
slt $t1, $v1, $t0
beq $t1, $zero, st_next
move $v1, $t0
st_next:
addi $a0, $a0, 4
addi $a1, $a1, -1
j st_loop
st_done:
jr $ra
 
histogram:
hg_loop:
beq $a1, $zero, hg_done
lw $t0, 0($a0)      # s = a[i]
add $t1, $a2, $t0   # &grade_tab[s] (byte, khong nhan 4)
lbu $t2, 0($t1)     # g = grade_tab[s]
sll $t2, $t2, 2     # g * 4
add $t3, $a3, $t2   # &hist[g]
lw $t4, 0($t3)
addi $t4, $t4, 1
sw $t4, 0($t3)
addi $a0, $a0, 4
addi $a1, $a1, -1
j hg_loop
hg_done:
jr $ra
 
#$a0 = dia chi chuoi .asciiz
#$v0 = vi tri (tu 1), $v1 = ma loi (0, 1, 2, 3)
check_brackets:   #check_brackets: kiem tra ngoac () [] {} bang ngan xep $sp
move $t9, $sp
li   $t0, 0   #vi tri ky tu hien tai
cb_loop:
lbu  $t1, 0($a0)
beq  $t1, $zero, cb_end  #het chuoi
addi $t0, $t0, 1
addi $a0, $a0, 1
 
li   $t2, 40           #'('
beq  $t1, $t2, cb_push
li   $t2, 91           #'['
beq  $t1, $t2, cb_push
li   $t2, 123          #'{'
beq  $t1, $t2, cb_push
 
li   $t4, 40           #')'
li   $t2, 41
beq  $t1, $t2, cb_close
li   $t4, 91           #']'
li   $t2, 93
beq  $t1, $t2, cb_close
li   $t4, 123          #'}'
li   $t2, 125
beq  $t1, $t2, cb_close
j    cb_loop           #ky tu khac: bo qua
 
cb_push:
addi $sp, $sp, -4
sw   $t1, 0($sp)
j    cb_loop
 
cb_close:
beq  $sp, $t9, cb_err2  #ngan xep rong
lw   $t5, 0($sp)
addi $sp, $sp, 4        #pop
bne  $t5, $t4, cb_err1  #khac loai
j    cb_loop
 
cb_end:
bne  $sp, $t9, cb_err3  #con ngoac mo
li   $v0, 0
li   $v1, 0
jr   $ra
 
cb_err1:
move $v0, $t0
li   $v1, 1
move $sp, $t9           #khoi phuc $sp
jr   $ra
cb_err2:
move $v0, $t0
li   $v1, 2
move $sp, $t9
jr   $ra
cb_err3:
addi $v0, $t0, 1        #do dai chuoi + 1
li   $v1, 3
move $sp, $t9           #con phan tu tren ngan xep: bat buoc khoi phuc
jr   $ra