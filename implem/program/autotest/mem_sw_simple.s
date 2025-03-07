# TAG = sw
.data
bytes: 
    .word 0

.text
    la x2, bytes

    li x4, 0xFFFFFFFF
    mv x31, x4

    li x3, 0x7FF
    sw x3, 0(x2)            # 1020
    lw x31, 0(x2)           # 1024

    li x3, -0x800
    sw x3, 0(x2)
    lw x31, 0(x2)

    li x4, 0xCCCCCCCC
    mv x31, x4


	# max_cycle 400
	# pout_start
    # FFFFFFFF
    # 000007FF
    # FFFFF800
    # CCCCCCCC
	# pout_end
