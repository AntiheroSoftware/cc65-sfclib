;
; Pad Snes code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .include    "snes.inc"

            .export     initPad
            .export     readPad1, readPad2, readPad3, readPad4

            .export     padPushData1, padReleaseData1
            .export     padPushData2, padReleaseData2
            .export     padPushData3, padReleaseData3
            .export     padPushData4, padReleaseData4

.segment "BSS"

; dummy  : dummy  : dummy  : dummy  : R      : L      : X      : A
; right  : left   : down   : up     : start  : select : Y      : B

padPushData1:
    .res    2, $00
padReleaseData1:
    .res    2, $00

padPushData2:
    .res    2, $00
padReleaseData2:
    .res    2, $00

padPushData3:
    .res    2, $00
padReleaseData3:
    .res    2, $00

padPushData4:
    .res    2, $00
padReleaseData4:
    .res    2, $00

.segment "CODE"

.proc initPad
    php
    pha

    sep #$20
    .A8

    lda #$81            ; Enable pad reading and NMI
    sta CPU_NMITIMEN

    lda #$00            ; clear pads data
    sta padPushData1
    sta padPushData1+1
    sta padReleaseData1
    sta padReleaseData1+1
    sta padPushData2
    sta padPushData2+1
    sta padReleaseData2
    sta padReleaseData2+1
    sta padPushData3
    sta padPushData3+1
    sta padReleaseData3
    sta padReleaseData3+1
    sta padPushData4
    sta padPushData4+1
    sta padReleaseData4
    sta padReleaseData4+1

    pla
    plp
    rts
.endproc

.macro m_readPad padNumber

    pha
    phx
    php

    rep #$10
    sep #$20
    .A8
    .I16

waitForPadReady:
    lda CPU_HVBJOY
    bit #$01
    beq waitForPadReady

    ldx padPushData1            ; save old pushed data to X
    stx padReleaseData1         ; and put it in place of released data

    lda CPU_STDCNTRL1H+((padNumber-1)*2)    ; read pad and put in memory
    sta padPushData1
    lda CPU_STDCNTRL1L+((padNumber-1)*2)    ; read pad and put in memory
    sta padPushData1+1

    rep #$20
    .A16

    ; Calculate release data
    lda padPushData1
    eor #$FFFF
    and padReleaseData1
    sta padReleaseData1

    plp
    plx
    pla
    rts

.endmacro

.proc readPad1
    m_readPad(1)
.endproc

.proc readPad2
    m_readPad(2)
.endproc

.proc readPad3
    m_readPad(3)
.endproc

.proc readPad4
    m_readPad(4)
.endproc