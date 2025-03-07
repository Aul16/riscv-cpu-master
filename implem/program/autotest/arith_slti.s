# TAG = slti
	.text
    li x3, -1
    mv x31, x3

    li x1, -0x800
    li x2, 0x7FF

    slti x31, x2, -0x800
    slti x31, x1, 0x7FF
    mv x31, x3

    li x1, 0x345
    li x2, 0x111

    slti x31, x1, 0x111
    slti x31, x2, 0x345
    mv x31, x3


    slt x31, x1, 0x345
    mv x31, x3



	# max_cycle 50
	# pout_start
    # FFFFFFFF
    # 00000000
    # 00000001
    # FFFFFFFF
    # 00000000
    # 00000001
    # FFFFFFFF
    # 00000000
    # FFFFFFFF
    # pout_end
