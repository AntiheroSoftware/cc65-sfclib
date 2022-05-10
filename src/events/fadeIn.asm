;
; Event Snes code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .include    "snes.inc"

            .export EVENT_FadeIn_Speed
            .export EVENT_InitFadeIn
            .export EVENT_FadeIn

.segment "BSS"

EVENT_FadeIn_Speed:
    .res    2

EVENT_FadeIn_Counter:
	.res	2

.segment "CODE"

.proc EVENT_InitFadeIn
    phx
    php

    rep #$10
    sep #$20
    .A8
    .I16

    ldx #$0000
    stx EVENT_FadeIn_Counter

    ldx #$0100
    stx EVENT_FadeIn_Speed

    plp
    plx

    rts
.endproc

.proc EVENT_FadeIn

    phx
    phy
    php

    rep #$30
    .A16
    .I16

    ldx EVENT_FadeIn_Speed
    txa
    clc
    adc EVENT_FadeIn_Counter
    sta EVENT_FadeIn_Counter
    xba

    rep #$10
    sep #$20
    .A8
    .I16

    sta PPU_INIDSP

    cmp #$0F
    bmi continueFadeIn

    lda #$00
    bra fadeInEventReturn

continueFadeIn:
    lda #$01

fadeInEventReturn:

    plp
    ply
    plx

    rtl
.endproc
