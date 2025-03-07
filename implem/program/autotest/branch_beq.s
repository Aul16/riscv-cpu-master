# TAG = BEQ
	.text
    li x3, -1               # 1000
    mv x31, x3              # 1004

    li x1, 0                # 1008
    li x2, 0                # 100C
loop:
    add x2, x2, x1          # 1010
    addi x1, x1, 1          # 1014
    
    andi x4, x2, 1          # 1018
    beq x4, x0, .end        # 101C
        mv x31, x2          # 1020
.end:
    li x7, 10               # 1024
    slt x4, x7, x1          # 1028
    beq x4, x0, loop        # 102c

    mv x31, x3              # 1030


	# max_cycle 400
	# pout_start
    # FFFFFFFF
    # 00000001
    # 00000003
    # 0000000F
    # 00000015
    # 0000002D
    # 00000037
    # FFFFFFFF
    # pout_end
