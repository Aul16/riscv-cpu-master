# TAG = CSRRS

.macro test_reg r
    csrrw x0, \r, x1
    csrrs x31, \r, x2
    csrrw x31, \r, x2
    addi x1, x1, 0x100
.endm

.text
    li x1, 0x20
    li x2, 0x04

    test_reg mstatus
    test_reg mie
    test_reg mepc
    test_reg mtvec

    li x31, -1

	# max_cycle 100
	# pout_start
    # 00000020
    # 00000024
    # 00000120
    # 00000124
    # 00000220
    # 00000224
    # 00000320
    # 00000324
    # FFFFFFFF
    # pout_end

