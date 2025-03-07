# TAG = addi
	.text

	# Test 1: ADDI with zero immediate
	li x30, 5
	addi x31, x30, 0

	# Test 2: ADDI with negative immediate
	li x30, 0
	addi x31, x30, -5

	# Test 3: ADDI result is zero
	li x30, 5
	addi x31, x30, -5

	# Test 4: ADDI with -1 immediate
	li x30, 0
	addi x31, x30, -1

	# Test 5: ADDI with maximum positive immediate
	li x30, 0
	addi x31, x30, 0x7FF

	# Test 6: ADDI with minimum negative immediate
	li x30, 0
	addi x31, x30, -0x800

	# Test 7: Overflow edge case
	li x30, 0x7FFFFFFF
	addi x31, x30, 1

	# Test 8: Underflow edge case
	li x30, -0x80000000
	addi x31, x30, -1

	# max_cycle 100
	# pout_start
	# 00000005
	# FFFFFFFB
	# 00000000
	# FFFFFFFF
	# 000007FF
	# FFFFF800
	# 80000000
	# 7FFFFFFF
	# pout_end
