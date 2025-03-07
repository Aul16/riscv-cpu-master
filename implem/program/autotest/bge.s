# TAG = bge
	.text

	# Test : Loop
	li x29, 11
	li x30, 1
	li x31, 0
loop:
	addi x29, x29, -1
	add x31, x31, x29
	bge x29, x30, loop
	addi x29, x29, -1
	bge x29, x30, loop


	# max_cycle 150
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
	# pout_end
