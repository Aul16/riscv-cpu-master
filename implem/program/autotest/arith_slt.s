# TAG = slt
	.text
    li x3, -1
    mv x31, x3

    li x1, -0x800
    li x2, 0x7FF

    slt x31, x2, x1
    slt x31, x1, x2
    mv x31, x3

    li x1, 0x345
    li x2, 0x111

    slt x31, x1, x2
    slt x31, x2, x1
    mv x31, x3

    slt x31, x1, x1
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
