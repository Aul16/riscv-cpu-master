# TAG = slli
	.text

	# Test 1: SLLI with zero shift (identity property)
	li x30, 0xAAAAAAAA           # Load register x30 with alternating 1s
	slli x31, x30, 0             # x31 = x30 << 0

	# Test 2: SLLI with a small shift (e.g., 1 bit)
	li x30, 0x1                 # Load register x30 with 1
	slli x31, x30, 1             # x31 = x30 << 1

	# Test 3: SLLI with maximum shift (31 bits for 32-bit values)
	li x30, 0x1                 # Load register x30 with 1
	slli x31, x30, 31            # x31 = x30 << 31

	# Test 4: SLLI causing overflow (bits shifted out of range)
	li x30, 0x80000000          # Load register x30 with INT_MIN
	slli x31, x30, 1             # x31 = x30 << 1

	# Test 5: SLLI with zero in the register
	lui x31, 1
	li x30, 0x0                 # Load register x30 with zero
	slli x31, x30, 10            # x31 = x30 << 10

	# Test 6: SLLI with a mid-range value and mid-range shift
	li x30, 0x12345678          # Load register x30 with a specific value
	slli x31, x30, 8             # x31 = x30 << 8

	# Test 7: SLLI with all bits set (-1 or 0xFFFFFFFF)
	li x30, -1                  # Load register x30 with all bits set
	slli x31, x30, 4             # x31 = x30 << 4

	# Test 8: SLLI with alternating bit pattern
	li x30, 0xAAAAAAAA           # Load register x30 with alternating 1s
	slli x31, x30, 2             # x31 = x30 << 2

	# max_cycle 100
	# pout_start
	# AAAAAAAA
	# 00000002
	# 80000000
	# 00000000
	# 00001000
	# 00000000
	# 34567800
	# FFFFFFF0
	# AAAAAAA8
	# pout_end
