# TAG = sb
.data
n: 
    .word 16
bytes:
    .byte 0, 0x10, 0x20, 0x30, 0x40, 0x50, 0x60, 0x70

.text
    la x1, n                # 1000
    lw x1, 0(x1)            # 1008
    mv x31, x1              # 100C

    la x2, bytes            # 1010
    add x1, x2, x1          # 1018

    li x6, 8                # 101C
.loop:
    sb x6, 0(x2)            # 1020
    lb x31, 0(x2)           # 1024

    addi x2, x2, 4          # 1028
    addi x6, x6, 1          # 102C

    blt x2, x1, .loop       # 1030

    li x31, -1              # 1032



	# max_cycle 400
	# pout_start
	# 00000010
    # 00000008
    # 00000009
    # 0000000A
    # 0000000B
    # FFFFFFFF
	# pout_end
