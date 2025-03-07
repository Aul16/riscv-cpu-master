# TAG = slt
	.text
	
	# Test : slt 2 < 1
	li x29, 2
	li x30, 1
	slt x31, x29, x30

	# Test : slt 1 < 2
	li x29, 1
	li x30, 2
	slt x31, x29, x30

	# Test : slt 1 < 1
	li x29, 1
	li x30, 1
	slt x31, x29, x30


	# max_cycle 50
	# pout_start
	# 00000000
	# 00000001
	# 00000000
	# pout_end
