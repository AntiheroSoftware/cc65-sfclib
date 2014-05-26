;
; Joypad Reader Snes code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .include    "snes.inc"

            .import     initDebug
            .import     setCursorDebug
            .import     writeStringDebug
            .import     displayDebug

            .import     initPad
            .import     readPad1, readPad2
            .import     padPushData1, padReleaseData1

            .import     hextoa, stringBuffer

            .forceimport	__STARTUP__

            .export     _main
            .export     _IRQHandler
            .export     _NMIHandler
            .export     _preInit

.segment "BSS"

;stringBuffer:
;    .res    9, $00

.segment "RODATA"

titleString:
    .asciiz "Pad reader by Antihero Software"
    .byte $00

.segment "CODE"

.proc _main

    jsr initDebug   ; init debug data for screen and debug vars
    jsr initPad     ; init the pads

    rep #$30
    .A16
    .I16

    lda #titleString
    jsr writeStringDebug

    jsr displayDebug

infiniteMainLoop:

    lda padPushData1
    jsr hextoa

    ldx #$0000
    ldy #$0002
    jsr setCursorDebug

    lda #stringBuffer
    jsr writeStringDebug

    wai

    bra infiniteMainLoop

.endproc

.proc _IRQHandler
    rts
.endproc

.proc _NMIHandler

    jsr readPad1

    jsr displayDebug

    rts
.endproc

.proc _preInit
    rts
.endproc