# TAG = xor
	.text

	li x31, 0
	li x30, 0x79		# 000001111001
	li x29, 0x4B6		# 010010110110
	xor x31, x30, x29 	# 010011001111

	# max_cycle 50
	# pout_start
	# 00000000
    # 000004CF
	# pout_end
