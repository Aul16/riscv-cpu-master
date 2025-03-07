.text
    li sp, 0x8000

    # clear screen
    li a0, 0x7F7F00
    jal clear_vram


	ori a0, zero, 300
	ori a1, zero, 300
	ori a2, zero, 0x00FF
	ori a3, zero, 500
	jal trace_simple

	ori a0, zero, 40
	ori a1, zero, 0
	ori a2, zero, 0x00e0
	ori a3, zero, 1050
	jal trace_simple

    li a0, 100
    li a1, 100
    li a2, 150
    li a3, 130
    li a4, 0x7F0000
    call draw_square

    li a0, 400
    li a1, 400
    li a2, 100
    li a3, 0xFFFFFF
    call draw_circle

    li a0, 250
    li a1, 70
    li a2, 350
    li a3, 130
    li a4, 0
    call draw_square

    li a0, 300
    li a1, 100
    li a2, 350
    li a3, 70
    li a4, 0x00FFFF
    call draw_line

    li a0, 300
    li a1, 100
    li a2, 350
    li a3, 180
    li a4, 0xFF00FF
    call draw_line

    li a0, 300
    li a1, 100
    li a2, 250
    li a3, 130
    li a4, 0xFFFF00
    call draw_line

    li a0, 300
    li a1, 100
    li a2, 250
    li a3, 70
    li a4, 0xFF0000
    call draw_line


boucle:
	j   boucle


trace_simple:
# fonction tracant un segment du point [x=$a0,y=$a1] au point [x=$a3-1, y=$a1+($a3-$a0)-1] avec la couleur $a2
# contexte :
# $a0 =x
# $a1=y
# $a2=couleur
# $t2 = sauvegarde de $ra

	ori  t2, ra, 0 # Sauvegarde l'adresse de retour (ra) dans un registre qui ne sera pas utilise par la suite (t0)
for:                   # for(;$a0!=$a3;$a0++){ affiche_pixel($a0,$a1,$a2); $a1++;}
	beq  a3, a0, fin_for
	jal  affiche_pixel
	addi a0, a0, 1
	addi a1, a1, 1
	j    for
fin_for:
	ori  ra, t2, 0 # Restaure ra
	jr   ra

affiche_pixel:
# contexte :
# $a0 =x
# $a1=y
# $a2=couleur

# On calcule l'adresse du pixel à la coordonnée (x,y) : 0x8000 + (1920*y +x)*4 = 0x8000 + (y<<9)+ (y<<10) + (y<<11) + (y<<12) +(x<<2)
	li t0, 0x80000000
	sll t1, a0, 2
	add t0, t0, t1
	sll t1, a1, 9
	add t0, t0, t1
	sll t1, a1, 10
	add t0, t0, t1
	sll t1, a1, 11
	add t0, t0, t1
	sll t1, a1, 12
	add t0, t0, t1
	sw  a2, 0(t0)
	jr  ra


.include "asm/graphics.s"
