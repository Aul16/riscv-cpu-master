# TAG = slti
	.text

	# Test: slti with Edge Cases
	li x31, 0         # Initialize x31 (result accumulator)

# Test Case 1: Positive number less than immediate
	li x29, 5         # Set x29 to a small positive value
	slti x30, x29, 10 # Set x30 to 1 if x29 < 10
	beq x30, x0, test_case_1_fail # Fail if x30 is not 1
	addi x31, x31, 1  # Pass: Increment x31 to signal success
test_case_1_fail:

# Test Case 2: Positive number greater than immediate
	li x29, 15        # Set x29 to a larger positive value
	slti x30, x29, 10 # Set x30 to 0 if x29 >= 10
	beq x30, x0, test_case_2_pass # Pass if x30 is 0
	li x31, 0xDEADBEEF # Fail: Set x31 to a known bad value
test_case_2_pass:

# Test Case 3: x29 equals the immediate
	li x29, 10        # Set x29 to the same value as the immediate
	slti x30, x29, 10 # Set x30 to 0 if x29 >= 10
	beq x30, x0, test_case_3_pass # Pass if x30 is 0
	li x31, 0xBADBAD   # Fail: Set x31 to a known bad value
test_case_3_pass:

# Test Case 4: Negative number less than immediate
	li x29, -5        # Set x29 to a negative value
	slti x30, x29, 0  # Set x30 to 1 if x29 < 0
	beq x30, x0, test_case_4_fail # Fail if x30 is not 1
	addi x31, x31, 2  # Pass: Increment x31 to signal success
test_case_4_fail:

# Test Case 5: Negative number greater than immediate
	li x29, -1        # Set x29 to -1
	slti x30, x29, -5 # Set x30 to 0 if x29 >= -5
	beq x30, x0, test_case_5_pass # Pass if x30 is 0
	li x31, 0xDEADDEAD # Fail: Set x31 to a known bad value
test_case_5_pass:

# Test Case 6: Maximum positive value
	li x29, 0x7FFFFFFF # Set x29 to maximum signed 32-bit value
	slti x30, x29, -1  # Set x30 to 0 if x29 >= -1
	beq x30, x0, test_case_6_pass # Pass if x30 is 0
	li x31, 0xBADDECAF # Fail: Set x31 to a known bad value
test_case_6_pass:

# Test Case 7: Minimum negative value
	li x29, 0x80000000 # Set x29 to minimum signed 32-bit value
	slti x30, x29, 0   # Set x30 to 1 if x29 < 0
	beq x30, x0, test_case_7_fail # Fail if x30 is not 1
	addi x31, x31, 4  # Pass: Increment x31 to signal success
test_case_7_fail:

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
