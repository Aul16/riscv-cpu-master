# TAG = bne
	.text

	# Test : Loop
	li x29, 0
	li x30, 10
	li x31, 0
loop:
	addi x29, x29, 1
	add x31, x31, x29
	bne x29, x30, loop


	# max_cycle 150
	# pout_start
	# 00000000
	# 00000001
	# 00000003
	# 00000006
	# 0000000A
	# 0000000F
	# 00000015
	# 0000001C
	# 00000024
	# 0000002D
	# 00000037
	# pout_end
