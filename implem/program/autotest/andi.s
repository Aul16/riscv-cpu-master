# TAG = andi
	.text

	# Test 1: ANDI with zero
	lui x31, 1
    li x30, 0x12345678           # Load x30 with a non-zero value
    andi x31, x30, 0x0

    # Test 2: ANDI of zero with zero
	lui x31, 1
    li x30, 0x0                  # Load x30 with zero
    andi x31, x30, 0x0

    # Test 3: ANDI with alternating bits (0xAAAAAAAA)
    li x30, 0xFFFFFFFF           # Load x30 with all bits set
	andi x31, x30, 0x0AA

    # Test 4: ANDI with alternating bits complement (0x55555555)
    li x30, 0xFFFFFFFF           # Load x30 with all bits set
    andi x31, x30, 0x555

    # Test 5: ANDI of value with its complement
    li x30, 0xAAAAAAAA           # Load x30 with alternating 1s and 0
    andi x31, x30, 0x555

    # Test 6: ANDI with only the lowest bit cleared
	lui x31, 1
    li x30, 0xFFFFFFFE           # Load x30 with all but the lowest bit set
	andi x31, x30, 0x1

    # Test 7: ANDI with all bits set
    li x30, 0xFFFFFFFF           # Load x30 with all bits set
    andi x31, x30, 0x0FF

	# max_cycle 100
	# pout_start
	# 00001000
	# 00000000
	# 00001000
	# 00000000
	# 000000AA
	# 00000555
	# 00000000
	# 00001000
	# 00000000
	# 000000FF
	# pout_end
