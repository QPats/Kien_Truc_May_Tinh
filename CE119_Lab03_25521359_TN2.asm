.data
bar:     .asciiz "|"
bar_nl:  .asciiz "|\n"
t1:      .asciiz "kien truc may tinh"
t2:      .asciiz "mips"
t3:      .asciiz ""
t4:      .asciiz "a bc def"
t5:      .asciiz "mot lenh jr tra quyen ve noi goi"
tests:   .word t5, t2, t3, t4, t1

.text
.globl main
main:
        la    $s0, tests          # con trỏ tới bảng địa chỉ chuỗi
        li    $s1, 5              # số chuỗi kiểm thử
m_loop:
        beq   $s1, $zero, m_end
        lw    $a0, 0($s0)
        jal   reverse_words
        li    $v0, 4
        la    $a0, bar
        syscall                   # in |
        lw    $a0, 0($s0)
        li    $v0, 4
        syscall                   # in chuỗi đã đảo
        la    $a0, bar_nl
        li    $v0, 4
        syscall                   # in |\n
        addi  $s0, $s0, 4
        addi  $s1, $s1, -1
        j     m_loop
m_end:
        li    $v0, 10
        syscall

# strlen: $a0 = địa chỉ chuỗi -> $v0 = độ dài. Thủ tục lá.
strlen:
        move  $v0, $zero
sl_loop:
        add   $t0, $a0, $v0
        lb    $t1, 0($t0)
        beq   $t1, $zero, sl_done
        addi  $v0, $v0, 1
        j     sl_loop
sl_done:
        jr    $ra

# rev_range: đảo tại chỗ [$a0, $a1], hai đầu đều tính. Thủ tục lá.
rev_range:
rr_loop:
        sltu  $t0, $a0, $a1       # so sánh không dấu
        beq   $t0, $zero, rr_done # a0 >= a1 thì xong (kể cả đoạn rỗng)
        lb    $t1, 0($a0)
        lb    $t2, 0($a1)
        sb    $t2, 0($a0)
        sb    $t1, 0($a1)
        addi  $a0, $a0, 1
        addi  $a1, $a1, -1
        j     rr_loop
rr_done:
        jr    $ra

# reverse_words: $a0 = địa chỉ chuỗi. Thủ tục không lá.
# $s0 = đầu chuỗi, $s1 = cuối chuỗi / cuối từ, $s2 = đầu từ hiện tại
reverse_words:
        addi  $sp, $sp, -16
        sw    $ra, 12($sp)
        sw    $s0, 8($sp)
        sw    $s1, 4($sp)
        sw    $s2, 0($sp)
        move  $s0, $a0
        jal   strlen              # $a0 vẫn là địa chỉ chuỗi
        beq   $v0, $zero, rw_done # chuỗi rỗng: không làm gì
        add   $s1, $s0, $v0
        addi  $s1, $s1, -1        # địa chỉ ký tự cuối
        move  $a0, $s0
        move  $a1, $s1
        jal   rev_range           # bước 1: đảo cả chuỗi
        move  $s2, $s0            # đầu từ đầu tiên
rw_loop:
        move  $t0, $s2            # quét tìm cuối từ
rw_scan:
        lb    $t1, 0($t0)
        beq   $t1, $zero, rw_last # gặp byte 0: từ cuối cùng
        li    $t2, 32
        beq   $t1, $t2, rw_word   # gặp dấu cách: hết một từ
        addi  $t0, $t0, 1
        j     rw_scan
rw_word:
        addi  $s1, $t0, -1        # cuối từ
        move  $a0, $s2
        move  $a1, $s1
        jal   rev_range           # bước 2: đảo lại từ này
        addi  $s2, $s1, 2         # bỏ qua dấu cách, sang từ kế
        j     rw_loop
rw_last:
        addi  $s1, $t0, -1
        move  $a0, $s2
        move  $a1, $s1
        jal   rev_range
rw_done:
        lw    $s2, 0($sp)
        lw    $s1, 4($sp)
        lw    $s0, 8($sp)
        lw    $ra, 12($sp)
        addi  $sp, $sp, 16
        jr    $ra