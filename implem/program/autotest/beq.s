# TAG = beq
	.text

	# Test : Loop
	li x31, 1
loop:
	addi x31, x31, -1
	beq x31, x0, loop


	# max_cycle 50
	# pout_start
	# 00000001
	# 00000000
	# FFFFFFFF
	# pout_end
