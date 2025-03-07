# TAG = SRLI
.text
    li x1, 0x34500
    srl x31, x1, 8

    li x1, -256
    srl x31, x1, 8

	# max_cycle 50
	# pout_start
    # 00000345
    # 00FFFFFF
    # pout_end

