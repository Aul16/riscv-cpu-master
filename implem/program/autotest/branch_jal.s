# TAG = JAL

# caclulates u(n+1) = 2*(u(n) + 1)

.text
    li x31, -1              

    mv a0, x0
    mv a1, x0
loop:
    addi a1, a1, 1                  
    addi a0, a0, 1           

    call double               
    mv x31, a1
    mv x31, a0                      

.end:
    li t0, 10
    slt t0, t0, a1          # $t0 = 10 < $a1 ? 1 : 0
    beq t0, x0, loop        # jmp if ($t0 == 0) aka. do while ($a1 <= 10)

    li x30, 0xCCCCCCCC
    mv x31, x30                  

double:
    add a0, a0, a0              
    ret                        

	# max_cycle 400
	# pout_start
    # FFFFFFFF
    # 00000001
    # 00000002
    # 00000002
    # 00000006
    # 00000003
    # 0000000e
    # 00000004
    # 0000001e
    # 00000005
    # 0000003e
    # 00000006
    # 0000007e
    # 00000007
    # 000000FE
    # 00000008
    # 000001FE
    # 00000009
    # 000003FE
    # 0000000A
    # 000007FE
    # 0000000B
    # 00000FFE
    # CCCCCCCC
    # pout_end
