# TAG = sh
.data
bytes: 
    .half 2, 3, 5, 7, -1, 0x7FFF, -0x8000, 0xA

.text
    li x6, 8

    la x2, bytes    
    add x1, x2, x1   

    sh x6, 0(x2)       
    lh x31, 0(x2)       
    addi x2, x2, 2
    addi x6, x6, 1

    sh x6, 0(x2)       
    lh x31, 0(x2)       
    addi x2, x2, 2
    addi x6, x6, 1

    sh x6, 0(x2)       
    lh x31, 0(x2)       
    addi x2, x2, 2
    addi x6, x6, 1

    sh x6, 0(x2)       
    lh x31, 0(x2)       
    addi x2, x2, 2
    addi x6, x6, 1

    sh x6, 0(x2)       
    lh x31, 0(x2)       
    addi x2, x2, 2
    addi x6, x6, 1

    sh x6, 0(x2)       
    lh x31, 0(x2)       
    addi x2, x2, 2
    addi x6, x6, 1

    sh x6, 0(x2)       
    lh x31, 0(x2)       
    addi x2, x2, 2
    addi x6, x6, 1

    sh x6, 0(x2)       
    lh x31, 0(x2)       
    addi x2, x2, 2
    addi x6, x6, 1


    li x31, -1              

trap:
    j trap



	# max_cycle 400
	# pout_start
    # 00000008
    # 00000009
    # 0000000A
    # 0000000B
    # 0000000C
    # 0000000D
    # 0000000E
    # 0000000F
    # FFFFFFFF
	# pout_end
