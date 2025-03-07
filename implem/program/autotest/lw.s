# TAG = lw
.text

    la x1, n
    lw x1, 0(x1)
    mv x31, x1

    la x2, bytes
    add x1, x2, x1

    mv x31, x2

.loop:
    lw x31, 0(x2)
    addi x2, x2, 4
    blt x2, x1, .loop

    li x31, -1

.data
n: 
    .word 32
bytes: 
    .word 2, 0x7FFF, -0x800, 0x7FF, 3, 5, -1,  -0x8000


	# max_cycle 300
	# pout_start
	# 00000020
    # 00001034
    # 00000002
    # 00007FFF
    # FFFFF800
    # 000007FF
    # 00000003
    # 00000005
    # FFFFFFFF
    # FFFF8000
    # FFFFFFFF
	# pout_end
