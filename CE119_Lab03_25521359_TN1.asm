.data
msg:    .asciiz "Ket qua: "
.text
.globl main
main:
        li    $a0, 5            # x = 5
        jal   outer             # v0 = outer(5)
        move  $s0, $v0
        li    $v0, 4
        la    $a0, msg
        syscall
        move  $a0, $s0
        li    $v0, 1
        syscall
        li    $v0, 10
        syscall
# outer(x) = inner(x) + 1
outer:
        addi  $sp, $sp, -4      # cấp khung 1 word
        sw    $ra, 0($sp)       # cất địa chỉ trở về main
        jal   inner
        addi  $v0, $v0, 1
        lw    $ra, 0($sp)       # nạp lại đúng offset
        addi  $sp, $sp, 4       # thu hồi khung
        jr    $ra
# inner(x) = 2 * x
inner:
        add   $v0, $a0, $a0
        jr    $ra
