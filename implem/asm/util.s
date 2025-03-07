.macro xorswap r1, r2
    xor \r1, \r1, \r2
    xor \r2, \r1, \r2
    xor \r1, \r1, \r2
.endm


# sorts 2 registers
.macro minmax r1, r2
    blt \r1, \r2, Lmacro_minmax_end_\@
    xorswap \r1, \r2
Lmacro_minmax_end_\@:
.endm


.macro abs rd, rs
    mv \rd, \rs
    blt \rd, x0, Lmacro_abs_end_\@
    sub \rd, x0, \rd
Lmacro_abs_end_\@:
.endm
