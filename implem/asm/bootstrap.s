.global main
.global WAIT

entrypoint:
    li sp, 0x9000
    j main

WAIT:
    j WAIT

