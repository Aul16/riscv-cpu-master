# TAG = lw
.text

    la x1, n
    lw x1, 0(x1)
    mv x31, x1

    la x2, bytes
    add x1, x2, x1

.loop:
    #reset $rs1, making bad LW implem fail
    nop

    lw x31, 0(x2)
    addi x2, x2, 4
    blt x2, x1, .loop

    li x30, 0xEEEEEEEE
    mv x31, x30

.data
n: 
    .word 64

bytes: 
    .word 0x123457FC, 0x7FD, 0x7FE, 0x800, 0x801, 0x802, 0x803, 0xEEE
    .word 0xEEF, 0x6FF, 0xEFE, 0x7FE, 0x7EF, 0x8FE, 0x5FF, 0x9FF

    # max_cycle 300
	# pout_start
	# 00000040
    # 123457FC
    # 000007FD
    # 000007FE
    # 00000800
    # 00000801
    # 00000802
    # 00000803
    # 00000EEE
    # 00000EEF
    # 000006FF
    # 00000EFE
    # 000007FE
    # 000007EF
    # 000008FE
    # 000005FF
    # 000009FF
    # EEEEEEEE
	# pout_end

