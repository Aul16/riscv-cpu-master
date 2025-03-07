# TAG = add
	.text

	# Test 1: ADD with zero
    li x30, 5
    li x29, 0
    add x31, x30, x29

    # Test 2: ADD with negative number
    li x30, 0
    li x29, -5
    add x31, x30, x29

    # Test 3: ADD resulting in zero
    li x30, 5
    li x29, -5
    add x31, x30, x29

    # Test 4: ADD with -1
    li x30, 0
    li x29, -1
    add x31, x30, x29

    # Test 5: ADD with maximum positive value
    li x30, 0
    li x29, 0x7FFFFFFF
    add x31, x30, x29

    # Test 6: ADD with minimum negative value
    li x30, 0
    li x29, -0x80000000
    add x31, x30, x29

    # Test 7: Underflow edge case
    li x30, 0x80000000
    li x29, -1
    add x31, x30, x29

    # Test 8: Overflow edge case
    li x30, 0x7FFFFFFF
    li x29, 1
    add x31, x30, x29

	# max_cycle 100
	# pout_start
	# 00000005
	# FFFFFFFB
	# 00000000
	# FFFFFFFF
	# 7FFFFFFF
	# 80000000
	# 7FFFFFFF
	# 80000000
	# pout_end
