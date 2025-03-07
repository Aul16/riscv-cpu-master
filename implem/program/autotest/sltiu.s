# TAG = sltiu
	.text

	# Test: sltiu with Edge Cases
	li x31, 0         # Initialize x31 (result accumulator)

# Test Case 1: Positive number less than immediate
	li x29, 5         # Set x29 to a small positive value
	sltiu x30, x29, 10 # Set x30 to 1 if x29 < 10 (unsigned)
	beq x30, x0, test_case_1_fail # Fail if x30 is not 1
	addi x31, x31, 1  # Pass: Increment x31 to signal success
test_case_1_fail:

# Test Case 2: Positive number greater than immediate
	li x29, 15        # Set x29 to a larger positive value
	sltiu x30, x29, 10 # Set x30 to 0 if x29 >= 10 (unsigned)
	beq x30, x0, test_case_2_pass # Pass if x30 is 0
	li x31, 0xDEADBEEF # Fail: Set x31 to a known bad value
test_case_2_pass:

# Test Case 3: x29 equals the immediate
	li x29, 10        # Set x29 to the same value as the immediate
	sltiu x30, x29, 10 # Set x30 to 0 if x29 >= 10 (unsigned)
	beq x30, x0, test_case_3_pass # Pass if x30 is 0
	li x31, 0xBADBAD   # Fail: Set x31 to a known bad value
test_case_3_pass:

# Test Case 4: Zero less than immediate
	li x29, 0         # Set x29 to 0
	sltiu x30, x29, 1 # Set x30 to 1 if x29 < 1 (unsigned)
	beq x30, x0, test_case_4_fail # Fail if x30 is not 1
	addi x31, x31, 2  # Pass: Increment x31 to signal success
test_case_4_fail:

# Test Case 5: Maximum unsigned 32-bit value
	li x29, 0xFFFFFFFF # Set x29 to maximum unsigned 32-bit value
	sltiu x30, x29, 0xFFFFFFFF # Set x30 to 0 if x29 >= 0xFFFFFFFF (unsigned)
	beq x30, x0, test_case_5_pass # Pass if x30 is 0
	li x31, 0xDEADDEAD # Fail: Set x31 to a known bad value
test_case_5_pass:

# Test Case 6: Maximum unsigned value less than larger immediate
	li x29, 0xFFFFFFFF # Set x29 to maximum unsigned value
	sltiu x30, x29, 0x100 # Set x30 to 1 if x29 < 0x100000000
	bne x30, x0, test_case_6_fail # Fail if x30 is not 1
	addi x31, x31, 4  # Pass: Increment x31 to signal success
test_case_6_fail:

# Test Case 7: Small unsigned value
	li x29, 1         # Set x29 to 1
	sltiu x30, x29, 0 # Set x30 to 0 if x29 >= 0 (unsigned)
	beq x30, x0, test_case_7_pass # Pass if x30 is 0
	li x31, 0xBADDECAF # Fail: Set x31 to a known bad value
test_case_7_pass:

	# Signal end of test
	addi x31, x31, 8  # Increment x31 to indicate successful completion

	# max_cycle 200
	# pout_start
	# 00000000
	# 00000001
	# 00000003
	# 00000007
	# 0000000F
	# pout_end
