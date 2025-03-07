.include "asm/util.s"

.global clear_vram
.global draw_square
.global draw_circle
.global draw_line

#================================================================================
#                          VRAM CONSTANTS
# ================================================================================
.equ SCREEN_W, 1920 
.equ SCREEN_H, 1080
.equ VRAM_START, 0x80000000


# ================================================================================
#                          GET VRAM OFFSET OF PIXEL
# ================================================================================
# ========= PARAMS =============
# a0 = x
# a1 = y
calc_offset:
    sll a0, a0, 2
    sll t0, a1, 7 + 2
    add a0, a0, t0
    sll t0, a1, 8 + 2
    add a0, a0, t0
    sll t0, a1, 9 + 2
    add a0, a0, t0
    sll t0, a1, 10 + 2
    add a0, a0, t0
    ret


# ================================================================================
#                        CLEAR SCREEN
# ================================================================================
# ========= PARAMS =============
# a0 = color (_8r8g8b8)
clear_vram:
    li t0, 0x80000000
    li t1, 0x80000000 + (SCREEN_W * SCREEN_H)*4 # total pixel count + 3
.loop:
    sw a0, 0(t0)
    addi t0, t0, 4
    bne t1, t0, .loop

    ret



# ================================================================================
#                        DRAW RECTANGE (FILLED IN)
# ================================================================================
# ========= PARAMS =============
# a0 = x1
# a1 = y1
# a2 = x2
# a3 = y2
# a4 = color
draw_square:
    addi sp, sp, -12
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw ra, 8(sp)

    sub s0, a2, a0
    sub s1, a3, a1

    # a0 = current offset
    call calc_offset
    li t0, VRAM_START
    add a0, a0, t0

    # t0 = needed width in bytes
    slli t0, s0, 2
    
    # t2 = line counter
    li t2, 0

    # t3 = screen width in bytes
    li t3, 1920 * 4

0:
    # t1 = end of line
    add t1, a0, t0 
1:
    sw a4, 0(a0)

    # while not EOL
    add a0, a0, 4
    bltu a0, t1, 1b
    addi t2, t2, 1

    bgeu t2, s1, 2f

    # goto next line
    sub a0, a0, t0
    add a0, a0, t3
    j 0b

2:
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 8
    ret


# ================================================================================
#                        DRAW CIRCLE (OUTLINE)
# ================================================================================
# ========= PARAMS =============
# a0 = x
# a1 = y
# a2 = r
# a3 = color
# ========= INFO =============
# https://en.wikipedia.org/wiki/Midpoint_circle_algorithm#Jesko's_Method
draw_circle:
    addi sp, sp, -4
    sw ra, 0(sp)

    sw a2, -4(sp)
    sw a3, -8(sp)
    call calc_offset
    li t0, VRAM_START
    add a0, a0, t0
    sw a2, -4(sp)
    sw a3, -8(sp)

    mv t0, a2 # t0 = dx
    mv t1, x0 # t1 = dy
    srl a2, a2, 4 # a2 = t1

0:
    call 2f # pixel(dx, dy)
    mv t4, t0
    mv t0, t1
    mv t1, t4 
    call 2f # pixel(dy, dx)
    mv t4, t0
    mv t0, t1
    mv t1, t4

    add t1, t1, 1       # y += 1
    add a2, a2, t1      # t1 = t1 + y  
    sub t2, a2, t0      # t2 = t1 - x
    blt t2, x0, 1f      # if (t2 > 0)
        mv a2, t2       #    t1 = t2
        add t0, t0, -1  #    x -= 1
1:
    bge t0, t1, 0b

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# t0 = dx
# t1 = dy
# a0 = center offset
# a3 = color
# [[ overwritten variables ]]
# t3, t4, t5, t6
2: # subroutine to draw the pixel (custom cc)
    mv t3, a0

    # calculate x part
    sll t4, t0, 2

    # calculate y part
    sll t5, t1, 7 + 2
    sll t6, t1, 8 + 2
    add t5, t5, t6
    sll t6, t1, 9 + 2
    add t5, t5, t6
    sll t6, t1, 10 + 2
    add t5, t5, t6

    # +x +y
    add t3, t3, t4
    add t3, t3, t5
    sw a3, 0(t3)

    # -x +y
    sub t3, t3, t4
    sub t3, t3, t4
    sw a3, 0(t3)

    # -x -y
    sub t3, t3, t5
    sub t3, t3, t5
    sw a3, 0(t3)

    # +x -y
    add t3, t3, t4
    add t3, t3, t4
    sw a3, 0(t3)

    ret


# ================================================================================
#                        DRAW LINE
# ================================================================================
# ========= PARAMS =============
# a0 = x1
# a1 = y1
# a2 = x2
# a3 = y2
# a4 = color
draw_line:
    # t0 = |x1 - x0|, t1 = |y1-y0|
    sub t0, a2, a0
    abs t0, t0
    mv t1, a1
    mv t2, a3
    minmax t1, t2
    sub t1, t2, t1
    abs t1, t1
    
    # a5 = steep flag, if enabled, swap X and Y
    slt a5, t1, t0

L_draw_line_steep:


L_draw_line_shallow:
    # flip x0,Y0 and X1, Y1 to get x0 <= x1
    bge a2, a0, 0f
        xorswap a0, a2
        xorswap a1, a3
0:
    addi sp, sp, -4
    sw ra, 0(sp)

    # a0 = current point
    addi sp, sp, -8
    sw a0, 0(sp)
    sw a1, 4(sp)
    call calc_offset
    li t5, VRAM_START
    add a0, a0, t5

    # t5 = x0, t6 = x0
    lw t5, 0(sp)
    lw t6, 4(sp)
    addi sp, sp, 8

0:

    # put 1 in a1 if y0 < y1, then forget about it
    slt a1, t6, a3
    minmax t6, a3

    # t0 = dx, t1 = dy
    sub t0, a2, t5
    sub t1, a3, t6

    # t2 = D
    sll t3, t1, 1
    sub t3, t3, t0

    # t0 = 2dx, t1 = 2dy
    sll t0, t0, 1
    sll t0, t0, 1

    # t3 = Y jump
    li t3, SCREEN_W
    sll t3, t3, 4
    # if y0 >= y1, jump backward
    bne x0, a1, 2f
        sub t3, x0, t3

    # a6 = X jump
    li a6, 4

2:
    sw a4, 0(a0)

    bge x0, t2, 3f
        add a0, a0, t3 # move Y
        sub t2, t2, t0
3:
    add t2, t2, t1

    # increment x
    add a0, a0, a6

    addi t5, t5, 1
    blt t5, a2, 2b

    lw ra, 0(sp)
    addi sp, sp, 4
    ret




