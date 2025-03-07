# TAG = sb
.data
bytes: 
    # .byte 2, 3, 5, 7, -1, 0x7FFF, -0x8000
    .byte 0, 0, 0, 0, 0, 0, 0, 0

.text
    li x1, 7
    mv x31, x1

    la x2, bytes    
    add x1, x2, x1   

    li x6, 8          
.loop:
    sb x6, 0(x2)       
    lb x31, 0(x2)       

    addi x2, x2, 1
    addi x6, x6, 1        

    blt x2, x1, .loop      

    li x31, -1              

trap:
    j trap


	# max_cycle 400
	# pout_start
	# 00000007
    # 00000008
    # 00000009
    # 0000000A
    # 0000000B
    # 0000000C
    # 0000000D
    # 0000000E
    # FFFFFFFF
	# pout_end
