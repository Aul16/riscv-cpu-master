# TAG = sub
	.text

	# Test 1: SUB with zero
	li x30, 5
	li x29, 0
	sub x31, x30, x29

	# Test 2: SUB zero from a positive number
	li x30, 3
	li x29, 0
	sub x31, x30, x29

	# Test 3: SUB resulting in a negative number
	li x30, 0
	li x29, 5
	sub x31, x30, x29

	# Test 4: SUB resulting in zero
	li x30, 5
	li x29, 5
	sub x31, x30, x29

	# Test 5: SUB with maximum positive number
	li x30, 0x7FFFFFFF
	li x29, 0
	sub x31, x30, x29

	# Test 6: SUB with minimum negative number
	li x30, -0x80000000
	li x29, 0
	sub x31, x30, x29

	# Test 7: SUB with potential underflow
	li x30, -0x7FFFFFFF
	li x29, 1
	sub x30, x30, x29
	sub x31, x30, x29

	# Test 8: SUB with potential overflow
	li x30, 0x7FFFFFFF
	li x29, -1
	sub x31, x30, x29

	# max_cycle 100
	# pout_start
	# 00000005
    # 00000003
	# FFFFFFFB
	# 00000000
	# 7FFFFFFF
	# 80000000
	# 7FFFFFFF
	# 80000000
	# pout_end
