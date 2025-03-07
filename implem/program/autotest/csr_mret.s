# TAG = MRET

# place l'adresse de retour dans ra(x1)
.macro pseudo_ecall
    csrrs ra, mtvec, x0
    csrrw x0, mepc, ra
    auipc ra, 0
    addi ra, ra, 12
    mret
.endm

.text
    la x1, int_handler      # 1000
    csrrw x0, mtvec, x1     # 1004
    
    li x31, 1               # 1008
    pseudo_ecall            # 1010
    li x31, 2               # 1024
end:
    j end                   # 1028
    
int_handler:
    csrrw x0, mepc, ra      # 102C
    li x30, 0xEEEEEEEE      # 1030
    mv x31, x30             # 1038
    mret                    # 103C

	# max_cycle 200
	# pout_start
    # 00000001
    # EEEEEEEE
    # 00000002
    # pout_end

