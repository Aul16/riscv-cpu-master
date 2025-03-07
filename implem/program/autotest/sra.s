# TAG = sra
	.text

	lui x31, 0x800FE
	li x30, 0x1
	sra x31, x31, x30

	# max_cycle 50
	# pout_start
	# 800FE000
    # C007F000
	# pout_end
