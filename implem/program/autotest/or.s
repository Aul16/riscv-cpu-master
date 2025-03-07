# TAG = or
	.text

	# Test 1: OR with zero (identity property)
    li x30, 0xFFFFFFFF           # Load register x30 with all bits set
    li x29, 0x0                 # Load register x29 with zero
    or x31, x30, x29              # x31 = x30 | x29

	# Test 2: OR with alternating 1s (0xAAAAAAAA)
    li x30, 0xAAAAAAAA           # Load register x30 with alternating 1s
    li x29, 0x0                 # Load register x29 with zero
    or x31, x30, x29              # x31 = x30 | x29

    # Test 3: OR where both operands are the same
	lui x31, 1
    li x30, 0xAAAAAAAA           # Load register x30 with alternating 1s
    or x31, x30, x30              # x31 = x30 | x30

    # Test 4: OR with alternating 0s and 1s (0x55555555)
    li x30, 0xAAAAAAAA           # Load register x30 with alternating 1s
    li x29, 0x55555555          # Load register x29 with alternating 0s and 1s
    or x31, x30, x29              # x31 = x30 | x29

    # Test 5: OR with all bits set (-1 or 0xFFFFFFFF)
	lui x31, 1
    li x30, 0xAAAAAAAA           # Load register x30 with alternating 1s
    li x29, -1                  # Load register x29 with all bits set
    or x31, x30, x29              # x31 = x30 | x29

    # Test 6: OR with mixed values (positive and negative)
	lui x31, 1
    li x30, 0x7FFFFFFF          # Load register x30 with INT_MAX
    li x29, -1                  # Load register x29 with all bits set
    or x31, x30, x29              # x31 = x30 | x29

    # Test 7: OR with INT_MIN and zero
    li x30, 0x80000000          # Load register x30 with INT_MIN
    li x29, 0x0                 # Load register x29 with zero
    or x31, x30, x29              # x31 = x30 | x29

    # Test 8: OR with INT_MIN and all bits set
    li x30, 0x80000000          # Load register x30 with INT_MIN
    li x29, -1                  # Load register x29 with all bits set
    or x31, x30, x29              # x31 = x30 | x29

	# max_cycle 100
	# pout_start
	# FFFFFFFF
	# AAAAAAAA
	# 00001000
	# AAAAAAAA
	# FFFFFFFF
	# 00001000
	# FFFFFFFF
	# 00001000
	# FFFFFFFF
	# 80000000
	# FFFFFFFF
	# pout_end
