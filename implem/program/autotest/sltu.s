# TAG = sltu
	.text

	# Test: sltu with Edge Cases
	li x31, 0         # Initialize x31 (result accumulator)

# Test Case 1: Positive number less than another positive number
	li x29, 5         # Set x29 to a small positive value
	li x30, 10        # Set x30 to a larger positive value
	sltu x28, x29, x30 # Set x28 to 1 if x29 < x30 (unsigned)
	beq x28, x0, test_case_1_fail # Fail if x28 is not 1
	addi x31, x31, 1  # Pass: Increment x31 to signal success
test_case_1_fail:

# Test Case 2: Positive number greater than another positive number
	li x29, 15        # Set x29 to a larger positive value
	li x30, 10        # Set x30 to a smaller positive value
	sltu x28, x29, x30 # Set x28 to 0 if x29 >= x30 (unsigned)
	beq x28, x0, test_case_2_pass # Pass if x28 is 0
	li x31, 0xDEADBEEF # Fail: Set x31 to a known bad value
test_case_2_pass:

# Test Case 3: x29 equals x30
	li x29, 10        # Set x29 to 10
	li x30, 10        # Set x30 to the same value
	sltu x28, x29, x30 # Set x28 to 0 if x29 >= x30 (unsigned)
	beq x28, x0, test_case_3_pass # Pass if x28 is 0
	li x31, 0xBADBAD   # Fail: Set x31 to a known bad value
test_case_3_pass:

# Test Case 4: Zero less than any positive number
	li x29, 0         # Set x29 to 0
	li x30, 1         # Set x30 to a positive value
	sltu x28, x29, x30 # Set x28 to 1 if x29 < x30 (unsigned)
	beq x28, x0, test_case_4_fail # Fail if x28 is not 1
	addi x31, x31, 2  # Pass: Increment x31 to signal success
test_case_4_fail:

# Test Case 5: Maximum unsigned 32-bit value
	li x29, 0xFFFFFFFF # Set x29 to maximum unsigned 32-bit value
	li x30, 0xFFFFFFFF # Set x30 to the same maximum value
	sltu x28, x29, x30 # Set x28 to 0 if x29 >= x30 (unsigned)
	beq x28, x0, test_case_5_pass # Pass if x28 is 0
	li x31, 0xDEADDEAD # Fail: Set x31 to a known bad value
test_case_5_pass:

# Test Case 6: Minimum value compared to maximum value
	li x29, 0         # Set x29 to the minimum unsigned value
	li x30, 0xFFFFFFFF # Set x30 to the maximum unsigned value
	sltu x28, x29, x30 # Set x28 to 1 if x29 < x30 (unsigned)
	beq x28, x0, test_case_6_fail # Fail if x28 is not 1
	addi x31, x31, 4  # Pass: Increment x31 to signal success
test_case_6_fail:

# Test Case 7: Maximum unsigned value compared to zero
	li x29, 0xFFFFFFFF # Set x29 to the maximum unsigned value
	li x30, 0         # Set x30 to zero
	sltu x28, x29, x30 # Set x28 to 0 if x29 >= x30 (unsigned)
	beq x28, x0, test_case_7_pass # Pass if x28 is 0
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
