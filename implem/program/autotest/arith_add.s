# TAG = add
	.text

    li x1, 0x345
    li x2, 0x111
    add x31, x1, x2
    add x31, x2, x31


	# max_cycle 50
	# pout_start
    # 00000456
    # 00000567
    # pout_end
