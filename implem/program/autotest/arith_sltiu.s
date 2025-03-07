# TAG = sltiu
	.text
    li x3, -1
    mv x31, x3

    li x1, -0x800
    li x2, 0x7FF

    sltiu x31, x2, -0x800
    sltiu x31, x1, 0x7FF
    mv x31, x3

    li x1, 0x345
    li x2, 0x111

    sltiu x31, x1, 0x111
    sltiu x31, x2, 0x345
    mv x31, x3

    sltiu x31, x1, 0x345
    mv x31, x3

	# max_cycle 50
	# pout_start
    # FFFFFFFF
    # 00000001
    # 00000000
    # FFFFFFFF
    # 00000000
    # 00000001
    # FFFFFFFF
    # 00000000
    # FFFFFFFF
    # pout_end
