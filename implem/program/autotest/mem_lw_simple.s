# TAG = lw
.text
    li x1, 32

    la x2, bytes
    add x1, x2, x1

.loop:
    lw x31, 0(x2)
    addi x2, x2, 4
    blt x2, x1, .loop

    li x30, 0xEEEEEEEE
    mv x31, x30

.data
n: 
    .word 32
bytes: 
    .word 1, 2, 0x8FFF, 4, 5, 6, 7, 9

	# max_cycle 300
	# pout_start
    # 00000001
    # 00000002
    # 00008FFF
    # 00000004
    # 00000005
    # 00000006
    # 00000007
    # 00000009
    # EEEEEEEE
	# pout_end
