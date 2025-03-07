# TAG = lb


.text

    la x1, n                # 1000
    lw x1, 0(x1)            # 1008
    mv x31, x1              # 100C

    la x2, bytes            # 1010
    add x1, x2, x1          # 1018


.loop:
    lb x31, 0(x2)           # 1020
    addi x2, x2, 1          # 1024
    blt x2, x1, .loop       # 1028

    li x30, 0xEEEEEEEE
    mv x31, x30

.data
n: 
    .word 16                 # 1030
bytes: 
    .half 2, 9, 8, -1, 5, -0x800, 3, 0x7FF 

	# max_cycle 300
	# pout_start
	# 00000010
    # 00000002
    # 00000000
    # 00000009
    # 00000000
    # 00000008
    # 00000000
    # FFFFFFFF
    # FFFFFFFF
    # 00000005
    # 00000000
    # 00000000
    # FFFFFFF8
    # 00000003
    # 00000000
    # FFFFFFFF
    # 00000007
    # EEEEEEEE
	# pout_end


