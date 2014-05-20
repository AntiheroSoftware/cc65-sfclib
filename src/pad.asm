;
; Pad Snes code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .include    "snes.inc"

            .export     initPad
            .export     readPad1, readPad2, readPad3, readPad4

.segment "BSS"

; right  : left   : down   : up     : start  : select : Y      : B
; dummy  : dummy  : dummy  : dummy  : R      : L      : X      : A

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
    ; padNumber = padNumber << 1;
    ; // if pad data still reading we wait
    ; while((*(byte*)0x4212 & 0x01)) { }
    ; test = (word) *(byte*)0x4218+padNumber << 8;
    ; test |= (word) *(byte*)0x4219+padNumber;
    ; status = (padStatus *) &test;
    ; return *status;

; CPU_HVBJOY      = $4212
; CPU_STDCNTRL1L  = $4218
; CPU_STDCNTRL1H  = $4219
; CPU_STDCNTRL2L  = $421A
; CPU_STDCNTRL2H  = $421B
; CPU_STDCNTRL3L  = $421C
; CPU_STDCNTRL3H  = $421D
; CPU_STDCNTRL4L  = $421E
; CPU_STDCNTRL4H  = $421F

    php
    pha
    phx

    rep #$10
    sep #$20
    .A8
    .I16

waitForPadReady:
    lda CPU_HVBJOY
    bit #$01
    beq waitForPadReady

    rep #$30
    .A16
    .I16

    ldx padPushData1            ; save old pushed data to X
    stx padReleaseData1         ; and put it in place of released data

    lda CPU_STDCNTRL1H+((padNumber-1)*2)    ; read pad and put in memory
    sta padPushData1

    ; TODO bit xor for release data

    plx
    pla
    plp

.endmacro

.proc readPad1
    m_readPad(1)
    rts
.endproc

.proc readPad2
    m_readPad(2)
    rts
.endproc

.proc readPad3
    m_readPad(3)
    rts
.endproc

.proc readPad4
    m_readPad(4)
    rts
.endproc