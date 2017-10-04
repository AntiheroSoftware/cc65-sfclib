;
; Joypad Reader Snes code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .include    "snes.inc"
            .include    "snes-pad.inc"

            .import     initDebug
            .import     setCursorDebug
            .import     writeStringDebug
            .import     displayDebug

            .import     hextoa, stringBuffer

            .forceimport	__STARTUP__

            .export     _main
            .export     _IRQHandler
            .export     _NMIHandler
            .export     _preInit

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

.macro checkPad mask,xPos,yPos

    lda padPushData1
    ldx #xPos
    ldy #yPos
    jsr setCursorDebug
    bit #mask
    beq :+
    lda #pushStateString
    jsr writeStringDebug
    jmp :+++

:   lda padReleaseData1
    bit #mask
    beq :+
    lda #releaseStateString
    jsr writeStringDebug
    jmp :++

:   lda #noStateString
    jsr writeStringDebug
:

.endmacro

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

    checkPad PAD_RIGHT, $000D, $0004
    checkPad PAD_LEFT, $0014, $0004
    checkPad PAD_DOWN, $000C, $0005
    checkPad PAD_UP, $0012, $0005
    checkPad PAD_A, $000D, $0007
    checkPad PAD_B, $0011, $0007
    checkPad PAD_X, $0015, $0007
    checkPad PAD_Y, $0019, $0007
    checkPad PAD_L, $000D, $0008
    checkPad PAD_R, $0011, $0008
    checkPad PAD_START, $0011, $0009
    checkPad PAD_SELECT, $001A, $0009

    wai

    jmp infiniteMainLoop

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