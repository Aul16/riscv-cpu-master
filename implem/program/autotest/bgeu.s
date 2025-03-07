# TAG = bgeu
	.text

	# Test : Unsigned Loop with Edge Cases
	li x29, 11       # Initialize x29 to 0 (loop counter)
	li x30, 1        # Set loop limit (unsigned)
	li x31, 0        # Accumulator for the sum

# Main Loop
loop:
	addi x29, x29, -1   # Increment x29
	add x31, x31, x29  # Add x29 to the accumulator
	bgeu x29, x30, loop # Branch if x29 < x30 (unsigned comparison)

# Edge Case 1: x29 is 0 and x30 is non-zero
	li x29, 0          # Reset x29 to 0
	li x30, 5          # Set x30 to a small positive value
	bgeu x29, x30, edge_case_1_fail
	addi x31, x31, 1   # Pass: Increment x31 to signal success
edge_case_1_fail:

# Edge Case 2: x29 equals x30
	li x29, 5          # Set x29 to 5
	li x30, 5          # Set x30 to the same value
	bgeu x29, x30, edge_case_2_pass
	li x31, 0xDEADBEEF # If incorrect, set x31 to a known bad value
edge_case_2_pass:

# Edge Case 3: x29 < x30 with unsigned values
	li x29, 3          # Set x29 to a value less than x30
	li x30, 7          # Set x30 to a larger value
	bgeu x29, x30, edge_case_3_fail
	addi x31, x31, 2   # Pass: Increment x31 to signal success
edge_case_3_fail:

# Edge Case 4: Maximum unsigned value comparison
	li x29, 0xFFFFFFFF # Set x29 to maximum unsigned 32-bit value
	li x30, 0x7FFFFFFF # Set x30 to a smaller unsigned value
	bgeu x29, x30, edge_case_4_pass
	li x31, 0xBADBAD   # If incorrect, set x31 to a known bad value
edge_case_4_pass:

# Edge Case 5: Small values with wraparound
	li x29, 0          # Reset x29 to 0
	li x30, 0xFFFFFFFF # Set x30 to maximum unsigned value
	bgeu x29, x30, edge_case_5_fail
	addi x31, x31, 4   # Pass: Increment x31 to signal success
edge_case_5_fail:

	addi x31, x31, 0x8 # Increment x31 by 8 to signal end of test


	# max_cycle 200
	# pout_start
	# 00000000
	# 0000000A
	# 00000013
	# 0000001B
	# 00000022
	# 00000028
	# 0000002D
	# 00000031
	# 00000034
	# 00000036
	# 00000037
	# 00000037
	# 00000038
	# 0000003A
	# 0000003E
	# 00000046
	# pout_end
