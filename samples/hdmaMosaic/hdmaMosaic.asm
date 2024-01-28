;
; HDMA Spline Snes code for cc65
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

            .import     initEvents
            .import     addEvent
            .import     removeEvent
            .import     processEvents

            .export     hdmaInit
            .export     hdmaMem

SPLASH_TILE_ADDR	= $2000
SPLASH_MAP_ADDR     = $1000

.segment "RODATA"

splashTiles:
    .incbin "resource/splash.pic"

splashMap:
    .incbin "resource/splash.map"

splashPal:
    .incbin "resource/splash.clr"

hdmaTableWord:
    .word 1,1,1,1,2,2,2,3,3,4,5,6,7,7,8,8,9,9,9,10,10,10,10,9,9,9,8,8,7,7,6,5,4,3,3,2,2,2
    .word 1,1,1,1,2,2,2,3,3,4,5,6,7,7,8,8,9,9,9,10,10,10,10,9,9,9,8,8,7,7,6,5,4,3,3,2,2,2
    .word 1,1,1,1,2,2,2,3,3,4,5,6,7,7,8,8,9,9,9,10,10,10,10,9,9,9,8,8,7,7,6,5,4,3,3,2,2,2
    .word 1,1,1,1,2,2,2,3,3,4,5,6,7,7,8,8,9,9,9,10,10,10,10,9,9,9,8,8,7,7,6,5,4,3,3,2,2,2

hdmaTableByte:
    .byte 1,1,1,1,2,2,2,3,3,4,5,6,7,7,8,8,9,9,9,10,10,10,10,9,9,9,8,8,7,7,6,5,4,3,3,2,2,2
    .byte 1,1,1,1,2,2,2,3,3,4,5,6,7,7,8,8,9,9,9,10,10,10,10,9,9,9,8,8,7,7,6,5,4,3,3,2,2,2
    .byte 1,1,1,1,2,2,2,3,3,4,5,6,7,7,8,8,9,9,9,10,10,10,10,9,9,9,8,8,7,7,6,5,4,3,3,2,2,2
    .byte 1,1,1,1,2,2,2,3,3,4,5,6,7,7,8,8,9,9,9,10,10,10,10,9,9,9,8,8,7,7,6,5,4,3,3,2,2,2

.segment "BSS"

hdmaCount:
    .res 2

hdmaPos:
    .res 2

hdmaMem:
    .res 512

.segment "CODE"

.proc _main

    rep #$10
    sep #$20
    .A8
    .I16

    jsr initEvents

    lda #.BANKBYTE(hdmaEvent)
    ldx #.LOWORD(hdmaEvent)
    ldy #$0000
    jsr addEvent

    setINIDSP $80   ; Enable forced VBlank during DMA transfer

    setBG1SC SPLASH_MAP_ADDR, $00
    setBG12NBA SPLASH_TILE_ADDR, $0000

    VRAMLoad splashTiles, SPLASH_TILE_ADDR, $0980

    lda #$00
    sta $2121

    CGRAMLoad splashPal, $00, $20
    VRAMLoad splashMap, SPLASH_MAP_ADDR, $800

    lda #$01        ; setBGMODE(0, 0, 1);
    sta $2105

    lda #$01         ; ???
    sta $212c

    lda #$00         ; ???
    sta $212d

    setINIDSP $0F   ; Enable screen full brightness

    jsr hdmaInit

    lda #$80        ; Enable NMI
    sta CPU_NMITIMEN

infiniteMainLoop:
    wai
    jmp infiniteMainLoop

.endproc

.proc _IRQHandler
    rts
.endproc

.proc _NMIHandler
    jsr processEvents
    rts
.endproc

.proc _preInit
    rts
.endproc

;******************************************************************************
;*** Events *******************************************************************
;******************************************************************************

.segment "CODE"

.proc hdmaInit
    pha
    phx
    php

    lda #$00                        ; 1 byte value hdma (count,byte)
    sta $4300
    lda #$06                        ; Mosaic
    sta $4301
    ldx #hdmaMem
    stx $4302
    lda #.BANKBYTE(hdmaMem)
    sta $4304

    lda #%00000001
    sta $420c                       ; enable hdma channel 0 and 1

    ldx #$0000                      ; init the counters
    stx hdmaPos
    stx hdmaCount

    plp
    plx
    pla

    rts
.endproc

.proc hdmaEvent

    phx
    phy
    php

    rep #$10
    sep #$20
    .A8
    .I16

    lda #$01                        ; reset the hdma speed counter
    sta hdmaCount

    ldx #$0000                      ; we start the memory HDMA list at 0
    ldy hdmaPos

    lda #$4b                        ; start the effect at that line
    sta hdmaMem,x
    inx
    lda #$00
    sta hdmaMem,x
    inx

hdmaLoop:                           ; main loop for to fill the table
    lda #$01
    sta hdmaMem,x
    inx
    lda hdmaTableByte,y
    asl
    asl
    ;asl
    ;asl
    ora #$01
    and #%11110001
    iny
    sta hdmaMem,x
    inx

    cpx #$4c ; cpx #$99                        ; it's the end ?
    bne hdmaLoop

    lda #$01                        ; finish by setting an 0 offset
    sta hdmaMem,x
    inx
    lda #$00
    sta hdmaMem,x
    inx

    lda #$00                        ; set 0 to say it's over
    sta hdmaMem,x

    ldx hdmaPos
    inx
    cpx #$26 ;cpx #$4c
    bne nextPos
    ldx #$0000
nextPos:
    stx hdmaPos

    lda #$01                        ; continue event

    plp
    ply
    plx

    rtl
.endproc
