  .data
nguong: .word 50, 100, 200, 300, 400, 9999      # nguong tren moi bac
dong: .word 1780, 1840, 2130, 2680, 3030, 3180  # dong/kwh trong khi(a=9)
soBac: .word 6
msgNhap: .asciiz "Nhap so kWh (0..9999): "
msgSai: .asciiz "Gia tri khong hop le, nhap lai."
msgTien: .asciiz "Tien dien: "
msgDonVi: .asciiz "Dong"

  .text
  .globl main
main:

la $s3, nguong
la $s4, dong
la $t0, soBac
lw $s6, 0($t0)

# NHAP and KIEM TRA
Nhap: 

li $v0, 4
la $a0, msgNhap        # "Nhap so kWh (0..9999): "
syscall

li $v0, 5              # doc so nguyen co dau
syscall
addu $s0, $v0, $zero

slti $t0, $s0, 10000  # so sanh: x < 10000
beq $t0, $zero, Sai    # khong hop le thi den Sai

# TINH TOAN

add $s1, $zero, $zero  # tien = 0
add $s2, $zero, $zero  # truoc = 0
add $s5, $zero, $zero  # k = 0

VongLap:

slt $t0, $s5, $s6    # k < soBac
beq $t0, $zero, IN     # het bang thi thoat

slt $t0, $s2, $s0    # truoc < x
beq $t0, $zero, IN     # het dien thi thoat

sll $t1 , $s5, 	2      # $t1 = 4*k
add $t2, $t1, $s3 
lw $t2, 0($t2)         # tren = nguong[k]
add $t4, $t1, $s4
lw $t4, 0($t4)         # $t4 = dong[k]

add $t3, $s0, $zero    # cao = x
slt $t0, $t2, $s0
beq $t0, $zero, Giu    # tren < x neu tren >= x thi giu cao = x
add $t3, $t2 ,$zero    # nguoc lai cao = tren

Giu:

sub $t3, $t3, $s2      # phan = cao - truoc
mul $t3, $t3, $t4      # phan * dong[k]
add $s1, $s1, $t3      # tien = tien + thanh tien bac k

add $s2, $t2, $zero    # truoc = tren
addi $s5, $s5, 1
j VongLap


#XUAT

IN:

li $v0, 4
la $a0, msgTien
syscall                # "Tien dien:" 
 
li $v0, 1
add $a0, $s1, $zero
syscall                # so tien
 
li $v0, 4
la $a0, msgDonVi
syscall                # "Dong"
 
li $v0, 10
syscall               
# end

Sai:
li $v0, 4
la $a0, msgSai        
syscall
j Nhap                # nhap lai
