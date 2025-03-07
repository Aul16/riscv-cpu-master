# TAG = sll
	.text

	# Test 1: SLL with zero shift (identity property)
	li x30, 0xAAAAAAAA           # Load register x30 with alternating 1s
	li x29, 0                    # Load register x29 with zero shift amount
	sll x31, x30, x29            # x31 = x30 << x29

	# Test 2: SLL with a small shift value (1 bit)
	li x30, 0xAAAAAAAA           # Load register x30 with alternating 1s
	li x29, 1                    # Load register x29 with shift amount of 1
	sll x31, x30, x29            # x31 = x30 << x29

	# Test 3: SLL with a medium shift value (16 bits)
	li x30, 0xAAAAAAAA           # Load register x30 with alternating 1s
	li x29, 16                   # Load register x29 with shift amount of 16
	sll x31, x30, x29            # x31 = x30 << x29

	# Test 4: SLL with maximum shift value (31 bits)
	li x30, 0xAAAAAAAA           # Load register x30 with alternating 1s
	li x29, 31                   # Load register x29 with shift amount of 31
	sll x31, x30, x29            # x31 = x30 << x29

	# Test 5: SLL with overflow beyond word size (ignored)
	li x30, 0xAAAAAAAA           # Load register x30 with alternating 1s
	li x29, 32                   # Load register x29 with shift amount of 32
	sll x31, x30, x29            # x31 = x30 << x29 (shift amount modulo XLEN)

	# Test 6: SLL with zero register
	li x30, 0x0                 # Load register x30 with zero
	li x29, 5                    # Load register x29 with shift amount of 5
	sll x31, x30, x29            # x31 = x30 << x29

	# Test 7: SLL with all bits set (-1 or 0xFFFFFFFF)
	li x30, -1                  # Load register x30 with all bits set
	li x29, 4                    # Load register x29 with shift amount of 4
	sll x31, x30, x29            # x31 = x30 << x29

	# Test 8: SLL with INT_MIN (0x80000000)
	li x30, 0x80000000          # Load register x30 with INT_MIN
	li x29, 1                    # Load register x29 with shift amount of 1
	sll x31, x30, x29            # x31 = x30 << x29

	# max_cycle 100
	# pout_start
	# AAAAAAAA
	# 55555554
	# AAAA0000
	# 00000000
	# AAAAAAAA
	# 00000000
	# FFFFFFF0
	# 00000000
	# pout_end