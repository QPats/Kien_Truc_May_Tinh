.data
soNot: .word 15
nhacCu: .word 0
amLuong : .word 100
caodo: .word 64, 64, 65, 67, 67, 65, 64, 62, 60, 60, 62, 64, 64, 62, 62
dodai: .word 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 1, 4
msgTong: .asciiz "Tong du kien (ms): "
msgDo: .asciiz "Thoi gian do duoc (ms): "

.text
.globl main

main:

#Nap a và b
addi $s6, $zero, 9          #a = 9
addi $t0, $zero, 5          #b = 5
addi $t1, $zero, 10
mul $t1, $t1, $t0           #$t1 = 10 * b = 50
addi $s7, $t1, 150          #donvi = 150 + 10*b = 200 ms

#Nap du lieu
la $s0, caodo               #$s0 = dia chi caodo
la $s1, dodai               #$s1 = dia chi dodai
la $t0, soNot
lw $s2, 0($t0)
la $t0, amLuong
lw $t4, 0($t0) 
la $t0, nhacCu
lw $t5, 0($t0)

#Khoi tao bien
add $s3, $zero, $zero       #i = 0
add $s4, $zero, $zero       #tong = 0

li $v0, 30
syscall                     #doc dong ho he thong
addu $s5, $a0, $zero

#Vong lap
LOOP:
slt $t0, $s3, $s2           #i < n
beq $t0, $zero, Thoat       # het not thi thoat

sll $t1, $s3, 2
add $t2, $t1, $s0
lw $t2, 0($t2)              #$t2 = caodo[i]
add $t3, $t1, $s1
lw $t3, 0($t3)              #$t3 = dodai[i]

add $t2, $t2, $s6           #cao do = caodo[i] + a
mul $t3, $t3, $s7           #thoi luong = dodai[i]*donvi
add $s4, $s4, $t3           #tong += thoi luong

#In: cao do va ms
li $v0, 1
addu $a0, $t2, $zero
syscall                     #in cao do

li $v0, 11
li $a0, 32
syscall                     #dau cach

li $v0, 1
addu $a0, $t3, $zero
syscall                     #in ms

li $v0, 11
li $a0, 10
syscall                     #xuong dong

#Phat not syscall 33
addu $a0, $t2, $zero        #$a0 = cao do
addu $a1, $t3, $zero        #$a1 = thoi luong
addu $a2, $t5, $zero        #$a2 = nhac cu
addu $a3, $t4, $zero        #$a3 = am luong
li $v0, 31
syscall

# chờ hết độ dài nốt
addu $a0, $t3, $zero        #$a0 = do dai not
li $v0, 32
syscall


addi $s3, $s3, 1            #i++
j LOOP

Thoat:
li $v0, 30
syscall                     #doc dong ho he thong
subu $s5, $a0, $s5          #do duoc = lan2 - lan1

li $v0, 4
la $a0, msgTong
syscall

li $v0, 1
addu $a0, $s4, $zero
syscall                     #in tong du kien

li $v0, 11
li $a0, 10
syscall

li $v0, 4
la $a0, msgDo
syscall

li $v0, 1
addu $a0, $s5, $zero
syscall                     #in thoi gian do duoc

li $v0, 11
li $a0, 10
syscall

li $v0, 10
syscall                     #ket thuc