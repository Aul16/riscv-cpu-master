# TAG = auipc
	.text

	# Test 1: AUIPC with zero offset
	auipc x31, 0

	# Test 2: AUIPC with positive offset
	auipc x31, 0x1

	# Test 3: AUIPC with max positive offset
	auipc x31, 0x7FFFF

	li x10, 0x1

	# max_cycle 50
	# pout_start
	# 00001000
    # 00002004
	# 80000008
	# pout_end
