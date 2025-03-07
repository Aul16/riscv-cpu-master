# TAG = SRA
.text
    li x1, 0x34500
    li x2, 8
    sra x31, x1, x2

    li x1, -256
    sra x31, x1, x2

	# max_cycle 50
	# pout_start
    # 00000345
    # FFFFFFFF
    # pout_end
