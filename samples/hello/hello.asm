;
; Hello world Snes code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .include    "snes.inc"

            .import     initDebug
            .import     setCursorDebug
            .import     writeStringDebug
            .import     displayDebug

            .forceimport	__STARTUP__

            .export     _main
            .export     _IRQHandler
            .export     _NMIHandler
            .export     _preInit

            .export helloString

.segment "RODATA"

helloString:
    .asciiz "Hello world test 123 !!!"
    .byte $00

.segment "CODE"

.proc _main

    jsr initDebug   ; init debug data for screen and debug vars

; addEvent(&oncePerVBlankReset, 1);
; addEventWithPriority(&NMIReadPad, 1, (char) 0x00);

; setCursorDebug(0,0);
; writeStringDebug("JOYPAD READER USING WDC v0.0.1\n\0");

    rep #$30
    .A16
    .I16

    lda #helloString
    jsr writeStringDebug

    ldx #$0002
    ldy #$0003
    jsr setCursorDebug

    lda #helloString
    jsr writeStringDebug

    ldx #$0005
    ldy #$0004
    jsr setCursorDebug

    lda #helloString
    jsr writeStringDebug

    jsr displayDebug

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