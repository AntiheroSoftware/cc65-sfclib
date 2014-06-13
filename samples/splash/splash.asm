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

            .import     newinitEvents
            .import     newaddEvent
            .import     newremoveEvent
            .import     newprocessEvents

SPLASH_TILE_ADDR	= $2000
SPLASH_MAP_ADDR  = $1000

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

    jsr newinitEvents

    lda #$12
    ldx #$3456
    jsr newaddEvent

    setINIDSP $80   ; Enable forced VBlank during DMA transfer

    setBG1SC SPLASH_MAP_ADDR, $00
    setBG12NBA SPLASH_TILE_ADDR, $0000
    setINIDSP $80

    VRAMLoad splashTiles, SPLASH_TILE_ADDR, $0980

    lda $00
    sta $2121

    CGRAMLoad splashPal, $00, $20
    VRAMLoad splashMap, SPLASH_MAP_ADDR, $800

    setINIDSP $0F   ; Enable screen full brightness

    lda #$01        ; setBGMODE(0, 0, 1);
    sta $2105

    lda $01         ; ???
    sta $212c

    lda $00         ; ???
    sta $212d

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