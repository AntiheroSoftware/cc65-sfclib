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
pad1DataString:
    .asciiz "Joypad 1 data"
    .byte $00
direction1String:
    .asciiz "PAD => Right:  Left: "
    .byte $00
direction2String:
    .asciiz "       Down:   Up: "
    .byte $00
buttons1String:
    .asciiz "BUTTONS => A:  B:  X:  Y: "
    .byte $00
buttons2String:
    .asciiz "           L:  R: "
    .byte $00
buttons3String:
    .asciiz "           START:  SELECT: "
    .byte $00
pushStateString:
    .asciiz "*"
    .byte $00
releaseStateString:
    .asciiz "+"
    .byte $00
noStateString:
    .asciiz " "
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

    ldx #$0000
    ldy #$0002
    jsr setCursorDebug
    lda #pad1DataString
    jsr writeStringDebug

    ldx #$0000
    ldy #$0004
    jsr setCursorDebug
    lda #direction1String
    jsr writeStringDebug

    ldx #$0000
    ldy #$0005
    jsr setCursorDebug
    lda #direction2String
    jsr writeStringDebug

    ldx #$0000
    ldy #$0007
    jsr setCursorDebug
    lda #buttons1String
    jsr writeStringDebug

    ldx #$0000
    ldy #$0008
    jsr setCursorDebug
    lda #buttons2String
    jsr writeStringDebug

    ldx #$0000
    ldy #$0009
    jsr setCursorDebug
    lda #buttons3String
    jsr writeStringDebug

    jsr displayDebug

infiniteMainLoop:

    lda padPushData1
    jsr hextoa

    ldx #$0000
    ldy #$000B
    jsr setCursorDebug

    lda #stringBuffer
    jsr writeStringDebug

    lda padReleaseData1
    jsr hextoa

    ldx #$0000
    ldy #$000C
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