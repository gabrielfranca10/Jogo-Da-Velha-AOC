.data
br1: .asciiz "\nTABULEIRO:\n"
newline: .asciiz "\n"
msg_linha: .asciiz "Linha (A-C): "
msg_coluna: .asciiz "Coluna (1-3): "
msg_invalida: .asciiz "Entrada invalida\n"
msg_ocupado: .asciiz "Posicao ocupada\n"
msg_vitoriaX: .asciiz "X venceu!\n"
msg_vitoriaO: .asciiz "O venceu!\n"
msg_empate: .asciiz "Empate!\n"
linha_str: .space 4
coluna_str: .space 4
tabuleiro: .space 9

.text
.globl main

main:
    la $t0, tabuleiro
    li $t1, 9
clear_loop:
    sb $zero, 0($t0)
    addi $t0, $t0, 1
    addi $t1, $t1, -1
    bgtz $t1, clear_loop

game_loop:
    jal print_board
    jal jogada_player
    jal checar_vitoria
    beq $v0, 1, fim_x
    beq $v0, 2, fim_o
    beq $v0, 3, fim_empate
    jal jogada_cpu
    jal checar_vitoria
    beq $v0, 1, fim_x
    beq $v0, 2, fim_o
    beq $v0, 3, fim_empate
    j game_loop

fim_x:
    li $v0, 4
    la $a0, msg_vitoriaX
    syscall
    j fim

fim_o:
    li $v0, 4
    la $a0, msg_vitoriaO
    syscall
    j fim

fim_empate:
    li $v0, 4
    la $a0, msg_empate
    syscall

fim:
    li $v0, 10
    syscall


print_board:
    li $v0, 4
    la $a0, br1
    syscall
    la $t0, tabuleiro
    li $t1, 0

linha_loop:
    lb $t2, 0($t0)
    beq $t2, $zero, pb1
    li $v0, 11
    move $a0, $t2
    syscall
    j pb1_end
pb1:
    li $v0, 11
    li $a0, '-'
    syscall
pb1_end:
    li $v0, 11
    li $a0, ' '
    syscall

    lb $t2, 1($t0)
    beq $t2, $zero, pb2
    li $v0, 11
    move $a0, $t2
    syscall
    j pb2_end
pb2:
    li $v0, 11
    li $a0, '-'
    syscall
pb2_end:
    li $v0, 11
    li $a0, ' '
    syscall

    lb $t2, 2($t0)
    beq $t2, $zero, pb3
    li $v0, 11
    move $a0, $t2
    syscall
    j pb3_end
pb3:
    li $v0, 11
    li $a0, '-'
    syscall
pb3_end:
    li $v0, 4
    la $a0, newline
    syscall

    addi $t0, $t0, 3
    addi $t1, $t1, 1
    blt $t1, 3, linha_loop

    jr $ra


jogada_player:
    li $v0, 4
    la $a0, msg_linha
    syscall
    li $v0, 8
    la $a0, linha_str
    li $a1, 3
    syscall

    li $v0, 4
    la $a0, msg_coluna
    syscall
    li $v0, 8
    la $a0, coluna_str
    li $a1, 3
    syscall

    lb $t0, linha_str
    lb $t1, coluna_str
    addi $t0, $t0, -65
    addi $t1, $t1, -49

    bltz $t0, jp_invalid
    bltz $t1, jp_invalid
    bgt $t0, 2, jp_invalid
    bgt $t1, 2, jp_invalid

    mul $t2, $t0, 3
    add $t2, $t2, $t1
    la $t3, tabuleiro
    add $t3, $t3, $t2
    lb $t4, 0($t3)
    bne $t4, $zero, jp_ocupado

    li $t5, 'X'
    sb $t5, 0($t3)
    jr $ra

jp_invalid:
    li $v0, 4
    la $a0, msg_invalida
    syscall
    j jogada_player

jp_ocupado:
    li $v0, 4
    la $a0, msg_ocupado
    syscall
    j jogada_player


jogada_cpu:
    la $t0, tabuleiro
    li $t1, 0

cpu_loop:
    lb $t2, 0($t0)
    beq $t2, $zero, cpu_place
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    blt $t1, 9, cpu_loop
    jr $ra

cpu_place:
    li $t3, 'O'
    sb $t3, 0($t0)
    jr $ra


checar_vitoria:
    la $t0, tabuleiro
    li $t1, 0

cv_linhas:
    lb $t2, 0($t0)
    lb $t3, 1($t0)
    lb $t4, 2($t0)
    beq $t2, $zero, cv_proxlinha
    beq $t2, $t3, cv_ok1
    j cv_proxlinha
cv_ok1:
    beq $t2, $t4, cv_ganhou
    j cv_proxlinha

cv_ganhou:
    beq $t2, 'X', cv_x
    beq $t2, 'O', cv_o

cv_proxlinha:
    addi $t0, $t0, 3
    addi $t1, $t1, 1
    blt $t1, 3, cv_linhas

    la $t0, tabuleiro
    li $t1, 0

cv_colunas:
    lb $t2, 0($t0)
    lb $t3, 3($t0)
    lb $t4, 6($t0)
    beq $t2, $zero, cv_proxcol
    beq $t2, $t3, cv_ok2
    j cv_proxcol
cv_ok2:
    beq $t2, $t4, cv_ganhou
    j cv_proxcol

cv_proxcol:
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    blt $t1, 3, cv_colunas

    la $t0, tabuleiro
    lb $t2, 0($t0)
    lb $t3, 4($t0)
    lb $t4, 8($t0)
    beq $t2, $zero, cv_diag2
    beq $t2, $t3, cv_okd1
    j cv_diag2
cv_okd1:
    beq $t2, $t4, cv_ganhou
    j cv_diag2

cv_diag2:
    lb $t2, 2($t0)
    lb $t3, 4($t0)
    lb $t4, 6($t0)
    beq $t2, $zero, cv_emp
    beq $t2, $t3, cv_okd2
    j cv_emp
cv_okd2:
    beq $t2, $t4, cv_ganhou

cv_emp:
    la $t0, tabuleiro
    li $t1, 9
cv_emp_loop:
    lb $t2, 0($t0)
    beq $t2, $zero, cv_notemp
    addi $t0, $t0, 1
    addi $t1, $t1, -1
    bgtz $t1, cv_emp_loop
    li $v0, 3
    jr $ra

cv_notemp:
    li $v0, 0
    jr $ra

cv_x:
    li $v0, 1
    jr $ra
cv_o:
    li $v0, 2
    jr $ra
