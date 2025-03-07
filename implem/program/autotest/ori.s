# TAG = ori
	.text

	# Test 1: ORI with zero (identity property)
	li x30, 0xAAAAAAAA           # Load register x30 with alternating 1s
	ori x31, x30, 0x0            # x31 = x30 | 0

	# Test 2: ORI with max immediate (0x7FF)
	li x30, 0xAAAAAAAA           # Load register x30 with alternating 1s
	ori x31, x30, 0x7FF          	 # x31 = x30 | 0xFFF

	# Test 3: ORI with alternating 0s and 1s (0x555)
	lui x31, 1
	li x30, 0xAAAAAAAA           # Load register x30 with alternating 1s
	ori x31, x30, 0x555          # x31 = x30 | 0x555

	# Test 4: ORI with a negative immediate (signed extension)
	li x30, 0x0                 # Load register x30 with zero
	ori x31, x30, -1            # x31 = x30 | -1 (all bits set)

	# Test 5: ORI with INT_MAX (0x7FFFFFFF)
	li x30, 0x7FFFFFFF          # Load register x30 with INT_MAX
	ori x31, x30, 0x0           # x31 = x30 | 0x0

	# Test 6: ORI with INT_MIN (0x80000000)
	li x30, 0x80000000          # Load register x30 with INT_MIN
	ori x31, x30, 0x7FF         # x31 = x30 | 0xFFF

	# Test 7: ORI with all bits set (-1 or 0xFFFFFFFF)
	li x30, 0xAAAAAAAA          # Load register x30 with alternating 1s
	ori x31, x30, -1            # x31 = x30 | -1 (all bits set)

	# Test 8: ORI with zero register and immediate
	li x30, 0x0                 # Load register x30 with zero
	ori x31, x30, 0x7FF         # x31 = x30 | 0xFFF

	# max_cycle 100
	# pout_start
	# AAAAAAAA
	# AAAAAFFF
	# 00001000
	# AAAAAFFF
	# FFFFFFFF
	# 7FFFFFFF
	# 800007FF
	# FFFFFFFF
	# 000007FF
	# pout_end
