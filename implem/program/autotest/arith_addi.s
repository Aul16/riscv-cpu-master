# TAG = addi
	.text

	lui x31, 0       
    addi x31, x31, 0x33

	lui x31, 0xFF      
    addi x31, x31, 0x33

    lui x31, 0x3BCDE
    addi x31, x31, 0x123
    addi x31, x31, 0x006

    li x1, -1
    mv x31, x1

    li x1, 0x345
    mv x31, x1

	# max_cycle 50
	# pout_start
    # 00000000
    # 00000033
    # 000FF000
    # 000FF033
    # 3BCDE000
    # 3BCDE123
    # 3BCDE129
    # FFFFFFFF
    # 00000345
    # pout_end
