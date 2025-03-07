# TAG = BNE
	.text
    li x3, -1
    mv x31, x3

    li x1, 0
    li x2, 0
loop:
    add x2, x2, x1
    addi x1, x1, 1
    
    andi x4, x2, 1
    bne x4, x0, .end
        mv x31, x2
.end:
    slti x4, x1, 11
    bne x4, x0, loop

    mv x31, x3


	# max_cycle 400
	# pout_start
    # FFFFFFFF
    # 00000000
    # 00000006
    # 0000000A
    # 0000001C
    # 00000024
    # FFFFFFFF
    # pout_end
