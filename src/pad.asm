;
; Pad Snes code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .include    "snes.inc"

            .export     initPad
            .export     readPad1, readPad2, readPad3, readPad4

            .export     padPushData1, padFirstPushData1, padReleaseData1
            .export     padPushDataHigh1, padPushDataLow1, padFirstPushDataLow1, padFirstPushDataHigh1, padReleaseDataHigh1, padReleaseDataLow1
            .export     padPushData2, padReleaseData2
			.export     padPushDataHigh2, padPushDataLow2, padReleaseDataHigh2, padReleaseDataLow2
            .export     padPushData3, padReleaseData3
            .export     padPushDataHigh3, padPushDataLow3, padReleaseDataHigh3, padReleaseDataLow3
            .export     padPushData4, padReleaseData4
            .export     padPushDataHigh4, padPushDataLow4, padReleaseDataHigh4, padReleaseDataLow4

.segment "BSS"

; dummy  : dummy  : dummy  : dummy  : R      : L      : X      : A
; right  : left   : down   : up     : start  : select : Y      : B

padPushData1:
padPushDataLow1:
    .res    1
padPushDataHigh1:
	.res    1

padFirstPushData1:
padFirstPushDataLow1:
    .res    1
padFirstPushDataHigh1:
	.res    1

padReleaseData1:
padReleaseDataLow1:
    .res    1
padReleaseDataHigh1:
    .res    1

padPushData2:
padPushDataLow2:
    .res    1
padPushDataHigh2:
	.res    1

padReleaseData2:
padReleaseDataLow2:
    .res    1
padReleaseDataHigh2:
    .res    1

padPushData3:
padPushDataHigh3:
    .res    1
padPushDataLow3:
	.res    1

padReleaseData3:
padReleaseDataHigh3:
    .res    1
padReleaseDataLow3:
    .res    1

padPushData4:
padPushDataHigh4:
    .res    1
padPushDataLow4:
	.res    1

padReleaseData4:
padReleaseDataHigh4:
    .res    1
padReleaseDataLow4:
    .res    1

.segment "CODE"

.proc initPad
    php
    pha

    sep #$20
    .A8

    stz $4016

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
    and #$01
    bne waitForPadReady

    ldx padPushData1            ; save old pushed data to X
    stx padReleaseData1         ; and put it in place of released data

    lda CPU_STDCNTRL1H+((padNumber-1)*2)    ; read pad and put in memory
    sta padPushData1
    lda CPU_STDCNTRL1L+((padNumber-1)*2)    ; read pad and put in memory
    sta padPushData1+1

    rep #$20
    .A16

    ; Calculate first push data
    lda padPushData1
    eor padReleaseData1
    and padPushData1
    sta padFirstPushData1

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