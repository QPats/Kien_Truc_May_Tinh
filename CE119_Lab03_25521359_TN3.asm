.data
n:     .word 20
msg:   .asciiz "F(n) = "
.text
.globl main
main:
        la    $t0, n
        lw    $a0, 0($t0)
        jal   fib_opt             # đổi thành fib_iter để đo bản lặp
        move  $s0, $v0
        li    $v0, 4
        la    $a0, msg
        syscall
        move  $a0, $s0
        li    $v0, 1
        syscall
        li    $v0, 10
        syscall

fib_rec:
        addi  $sp, $sp, -12
        sw    $ra, 8($sp)
        sw    $s0, 4($sp)
        sw    $s1, 0($sp)
        move  $s0, $a0
        slti  $t0, $a0, 2
        beq   $t0, $zero, fr_rec
        move  $v0, $a0            # trường hợp cơ sở
        j     fr_done
fr_rec:
        addi  $a0, $s0, -1
        jal   fib_rec
        move  $s1, $v0            # giữ F(n-1)
        addi  $a0, $s0, -2
        jal   fib_rec
        addu  $v0, $s1, $v0
fr_done:
        lw    $s1, 0($sp)
        lw    $s0, 4($sp)
        lw    $ra, 8($sp)
        addi  $sp, $sp, 12
        jr    $ra

# fib_iter: tinh F(n) bang vong lap
# Tham so : $a0 = n    Tra ve : $v0 = F(n)
# Thanh ghi: $t0-$t3 (thu tuc la)
fib_iter:
        move  $v0, $zero        # a = F(0)
        li    $t0, 1            # b = F(1)
        move  $t1, $zero        # i = 0
fi_loop:
        slt   $t2, $t1, $a0
        beq   $t2, $zero, fi_done
        addu  $t3, $v0, $t0     # a + b
        move  $v0, $t0
        move  $t0, $t3
        addiu $t1, $t1, 1
        j     fi_loop
fi_done:
        jr    $ra


fib_opt:
        slti  $t0, $a0, 2
        beq   $t0, $zero, fo_rec
        move  $v0, $a0            # trường hợp cơ sở: không cấp khung
        jr    $ra                 # $sp chưa đổi nên return được ngay
fo_rec:
        addi  $sp, $sp, -12       # chỉ cấp khung khi thật sự đệ quy
        sw    $ra, 8($sp)
        sw    $s0, 4($sp)
        sw    $s1, 0($sp)
        move  $s0, $a0
        addi  $a0, $s0, -1
        jal   fib_opt
        move  $s1, $v0
        addi  $a0, $s0, -2
        jal   fib_opt
        addu  $v0, $s1, $v0
        lw    $s1, 0($sp)
        lw    $s0, 4($sp)
        lw    $ra, 8($sp)
        addi  $sp, $sp, 12
        jr    $ra