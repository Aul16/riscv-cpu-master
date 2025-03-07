# TAG = SRL
.text
    li x1, 0x34500
    li x2, 8
    srl x31, x1, x2

    li x1, -256
    srl x31, x1, x2

	# max_cycle 50
	# pout_start
    # 00000345
    # 00FFFFFF
    # pout_end

