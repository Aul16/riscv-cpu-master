# TAG = SRAI
.text
    li x1, 0x34500
    sra x31, x1, 8

    li x1, -256
    sra x31, x1, 8

	# max_cycle 50
	# pout_start
    # 00000345
    # FFFFFFFF
    # pout_end
