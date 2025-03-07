# TAG = sub
	.text

    li x1, 0x345
    li x2, 0x111
    sub x31, x1, x2
    sub x31, x31, x2

	# max_cycle 50
	# pout_start
    # 00000234
    # 00000123
    # pout_end
