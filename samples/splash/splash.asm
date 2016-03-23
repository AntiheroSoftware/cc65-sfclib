;
; Splash Snes code for cc65
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

            .import     optinitEvents
            .import     optaddEvent
            .import     optremoveEvent
            .import     optprocessEvents

SPLASH_TILE_ADDR	= $2000
SPLASH_MAP_ADDR     = $1000

.segment "RODATA"

splashTiles:
    .incbin "resource/splash.pic"

splashMap:
    .incbin "resource/splash.map"

splashPal:
    .incbin "resource/splash.clr"

.segment "CODE"

.proc _main

    rep #$10
    sep #$20
    .A8
    .I16

    jsr optinitEvents

    lda #.BANKBYTE(fadeInEvent)
    ldx #.LOWORD(fadeInEvent)
    ldy #$0000
    jsr optaddEvent

    setINIDSP $80   ; Enable forced VBlank during DMA transfer

    setBG1SC SPLASH_MAP_ADDR, $00
    setBG12NBA SPLASH_TILE_ADDR, $0000
    setINIDSP $80

    VRAMLoad splashTiles, SPLASH_TILE_ADDR, $0980

    lda $00
    sta $2121

    CGRAMLoad splashPal, $00, $20
    VRAMLoad splashMap, SPLASH_MAP_ADDR, $800

    lda #$01        ; setBGMODE(0, 0, 1);
    sta $2105

    lda $01         ; ???
    sta $212c

    lda $00         ; ???
    sta $212d

    setINIDSP $00   ; Disable screen no brightness

    lda #$80        ; Enable NMI
    sta CPU_NMITIMEN

infiniteMainLoop:
    jmp infiniteMainLoop

.endproc

.proc _IRQHandler
    rts
.endproc

.proc _NMIHandler
    jsr optprocessEvents
    rts
.endproc

.proc _preInit
    rts
.endproc

;******************************************************************************
;*** Events *******************************************************************
;******************************************************************************

.segment "CODE"

.proc fadeInEvent

    phx
    phy
    php

    tax                     ; put A reg containing counter in X reg

    rep #$10
    sep #$20
    .A8
    .I16

    txa
    sta PPU_INIDSP

    cmp #$0F
    bne continueFadeIn

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

.proc fadeOutEvent
    rtl
.endproc