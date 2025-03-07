# TAG = CSRRW
.text
    li x1, 0x20
    li x2, 0x72
    csrrw x0, mstatus, x1
    csrrw x31, mstatus, x2
    csrrw x31, mstatus, x2

    li x1, 0x120
    li x2, 0x172
    csrrw x0, mie, x1
    csrrw x31, mie, x2
    csrrw x31, mie, x2

    li x1, 0x220
    li x2, 0x272 # will become 270 because mepc must be 32bit-aligned
    csrrw x0, mepc, x1
    csrrw x31, mepc, x2
    csrrw x31, mepc, x2

    li x1, 0x320
    li x2, 0x372 # will become 270 because  mtvec must be 32bit-aligned
    csrrw x0, mtvec, x1
    csrrw x31, mtvec, x2
    csrrw x31, mtvec, x2

    li x31, -1

	# max_cycle 100
	# pout_start
    # 00000020
    # 00000072
    # 00000120
    # 00000172
    # 00000220
    # 00000270
    # 00000320
    # 00000370
    # FFFFFFFF
    # pout_end

