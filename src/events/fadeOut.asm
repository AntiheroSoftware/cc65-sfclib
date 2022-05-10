;
; Event Snes code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .include    "snes.inc"

            .export EVENT_FadeOut_Speed
            .export EVENT_InitFadeOut
            .export EVENT_FadeOut

.segment "BSS"

EVENT_FadeOut_Speed:
    .res    2

EVENT_FadeOut_Counter:
	.res	2

.segment "CODE"

.proc EVENT_InitFadeOut
    phx
    php

    rep #$10
    sep #$20
    .A8
    .I16

    ldx #$0F00
    stx EVENT_FadeOut_Counter

    ldx #$0100
    stx EVENT_FadeOut_Speed

    plp
    plx

    rts
.endproc

.proc EVENT_FadeOut

    phx
    phy
    php

    rep #$30
    .A16
    .I16

    ldx EVENT_FadeOut_Counter
    txa
    clc
    sbc EVENT_FadeOut_Speed
    sta EVENT_FadeOut_Counter
    xba

    rep #$10
    sep #$20
    .A8
    .I16

    sta PPU_INIDSP

    cmp #$0F
    bne continueFadeOut

    lda #$00
    bra fadeOutEventReturn

continueFadeOut:
    lda #$01

fadeOutEventReturn:

    plp
    ply
    plx

    rtl
.endproc
