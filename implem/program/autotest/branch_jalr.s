# TAG = JALR

# caclulates u(n+1) = 2*(u(n) + 1)

.text
    li x31, -1              


    la s0, funcs

    li a0, 1
    lw t0, 0(s0)
    jalr ra, 0(t0)
    mv x31, a0

    li a0, 1
    lw t0, 4(s0)
    jalr ra, 0(t0)
    mv x31, a0

    li a0, 1
    lw t0, 8(s0)
    jalr ra, 0(t0)
    mv x31, a0

    j end

f8:
    add a0, a0, a0
f4:
    add a0, a0, a0
f2:
    add a0, a0, a0              
    ret                        

end:
    li x30, 0xCCCCCCCC
    mv x31, x30  
    j end

.data
funcs:
    .word f2, f4, f8


	# max_cycle 120
	# pout_start
    # FFFFFFFF
    # 00000002
    # 00000004
    # 00000008
    # CCCCCCCC
    # pout_end

