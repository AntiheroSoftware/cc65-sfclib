;
; Hello world Snes code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .include    "snes.inc"

            .forceimport	__STARTUP__

            .export     _main
            .export     _IRQHandler
            .export     _NMIHandler
            .export     _preInit

.segment "CODE"

.proc _main

    ldx     #$00
    lda     #$80
    sta     $2100
    ldx     #$00
    lda     #$F0
    sta     $2122
    ldx     #$00
    lda     #$00
    sta     $2122
    ldx     #$00
    lda     #$0F
    sta     $2100

infiniteMainLoop:
    bra infiniteMainLoop

.endproc

.proc _IRQHandler
    rts
.endproc

.proc _NMIHandler
    rts
.endproc

.proc _preInit
    rts
.endproc