.section    .start
.global     _start

_start:
    li      $sp, 0x8000
    jal     main
