# TAG = blt
.data
n: 
    .word 16
bytes: 
    .half 2, 3, 5, 7, -1, 0x7FFF, -0x8000, 0xA

.text
    li x1, 16

    la x2, bytes    
    add x1, x2, x1   

    # mv x31, x2
    # mv x31, x1

    li x6, 8          

.loop:
    mv x3, x2
    sh x0, 0(x3)
    # nop
    lh x0, 0(x3)

    mv x31, x6

    #nop
    #nop

    addi x2, x2, 2       
    addi x6, x6, 1        

    blt x2, x1, .loop      

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

    # 00001040
    # 00001050

