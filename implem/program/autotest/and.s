# TAG = and
	.text

	# Test 1: AND with zero
	lui x31, 1
    li x30, 0x12345678           # Load x30 with a non-zero value
    li x29, 0x0                  # Load x29 with zero
    and x31, x30, x29              # x31 = x30 & x29

    # Test 2: AND of zero with zero
	lui x31, 1
    li x30, 0x0                  # Load x30 with zero
    li x29, 0x0                  # Load x29 with zero
    and x31, x30, x29              # x31 = x30 & x29

    # Test 3: AND with alternating bits (0xAAAAAAAA)
    li x30, 0xFFFFFFFF           # Load x30 with all bits set
    li x29, 0xAAAAAAAA           # Load x29 with alternating 1s and 0s
    and x31, x30, x29              # x31 = x30 & x29

    # Test 4: AND with alternating bits complement (0x55555555)
    li x30, 0xFFFFFFFF           # Load x30 with all bits set
    li x29, 0x55555555           # Load x29 with alternating 0s and 1s
    and x31, x30, x29              # x31 = x30 & x29

    # Test 5: AND of value with its complement
    li x30, 0xAAAAAAAA           # Load x30 with alternating 1s and 0s
    li x29, 0x55555555           # Load x29 with complement of x30
    and x31, x30, x29              # x31 = x30 & x29

    # Test 6: AND with only the highest bit set
    li x30, 0x80000000           # Load x30 with highest bit set
    li x29, 0xFFFFFFFF           # Load x29 with all bits set
    and x31, x30, x29              # x31 = x30 & x29

    # Test 7: AND with only the lowest bit cleared
    li x30, 0xFFFFFFFE           # Load x30 with all but the lowest bit set
    li x29, 0x1                  # Load x29 with only the lowest bit set
    and x31, x30, x29              # x31 = x30 & x29

    # Test 8: AND with all bits set
    li x30, 0xFFFFFFFF           # Load x30 with all bits set
    li x29, 0xFFFFFFFF           # Load x29 with all bits set
    and x31, x30, x29              # x31 = x30 & x29

	# max_cycle 100
	# pout_start
	# 00001000
	# 00000000
	# 00001000
	# 00000000
	# AAAAAAAA
	# 55555555
	# 00000000
	# 80000000
	# 00000000
	# FFFFFFFF
	# pout_end
