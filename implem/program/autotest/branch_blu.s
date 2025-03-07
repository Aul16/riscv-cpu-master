# TAG = BLTU
	.text
    li x3, -1
    mv x31, x3

    li x1, 0
    li x2, 0

    li x5, 11

loop:
    add x2, x2, x1
    addi x1, x1, 1
    
    andi x4, x2, 1
    bltu x0, x4, .end
        mv x31, x2
.end:
    bltu x1, x5, loop

    li x3, 0xEEEEEEEE
    mv x31, x3


	# max_cycle 400
	# pout_start
    # FFFFFFFF
    # 00000000
    # 00000006
    # 0000000A
    # 0000001C
    # 00000024
    # EEEEEEEE
    # pout_end
