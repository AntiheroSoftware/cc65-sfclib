;
; HDMA Snes code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .include    "snes.inc"
            .include    "snes-pad.inc"

            .forceimport	__STARTUP__

            .export     _main
            .export     _IRQHandler
            .export     _NMIHandler
            .export     _preInit

            .import     initEvents
            .import     addEvent
            .import     removeEvent
            .import     processEvents

            .import     clearOAM
            .import     copyOAM
            .import     oamData

            ; TODO remove just for debug
            .export     hdmaMem
            .export     hdmaInit

            .export     setOam
            .export     copyOAMEvent
            .export     grabbingAnim
            .export     animFrameIndex
            .export     animFrameCounter
            .export     grabbingWalk


SPRITE_TILE_ALL_ADDR	= $0000
SPRITE_TILE_ZONE1_ADDR	= $1000
SPRITE_TILE_ZONE2_ADDR	= $2000
SPRITE_TILE_ZONE3_ADDR	= $3000
SPRITE_TILE_ZONE4_ADDR	= $4000

LEVEL_TILE_ADDR	    = $5000
LEVEL_MAP_ADDR      = $6400
LEVEL_MAP_ALT_ADDR  = $6800

SCORE_TILE_ADDR		= $7000
SCORE_MAP_ADDR		= $6C00
SCORE_MAP_SIZE	    = $20*3*2

.segment "BANK1"

levelTiles:
    .incbin "resource/level.pic"

.align  256

scoreTiles:
    .incbin "resource/score.pic"

.segment "BANK2"

levelMap:
    .incbin "resource/level.map"

levelMapInitial := levelMap+($0700*5)
levelMapInitialAlt := levelMap+($0700*6)

levelMap1 := levelMap+($0700*0)
levelMap2 := levelMap+($0700*1)
levelMap3 := levelMap+($0700*2)
levelMap4 := levelMap+($0700*3)
levelMap5 := levelMap+($0700*4)
levelMap6 := levelMap+($0700*5)
levelMap7 := levelMap+($0700*6)

levelPal:
    .incbin "resource/level0.pal"
    .incbin "resource/level1.pal"
    .incbin "resource/level2.pal"
    .incbin "resource/level3.pal"
    .incbin "resource/level4.pal"
    .incbin "resource/level5.pal"

.align  256

scoreMap:
    .incbin "resource/score.map"

scorePal:
    .incbin "resource/score.pal"

spritePal:
    .incbin "resource/1.clr"

.segment "BANK3"

spriteBank1Tiles:
    .incbin "resource/1.pic"

spriteBank2Tiles:
    .incbin "resource/2.pic"

spriteBank3Tiles:
    .incbin "resource/3.pic"

spriteBank4Tiles:
    .incbin "resource/4.pic"

.segment "RODATA"

hdmaMem:
    .byte $70,%00000000,$20,%00000000,$10,%00001000,$10,%00010000,$10,%00011000,$00

verticalOffsetTable:
    .byte $80, $90, $a0, $b0

;******************************************************************************
;*** Sprite definition ********************************************************
;******************************************************************************

;******************************************************************************
;*** Metasprites **************************************************************
;******************************************************************************
;*** Number of horizontal tiles                                             ***
;*** X offset                                                               ***
;*** Tile Number                                                            ***
;******************************************************************************

grabbingWalk1:

    ; 4 sprite blocks

    .byte   $01, $09, $00
    .byte   $01, $09, $00
    .byte   $01, $09, $00
    .byte   $01, $09, $00

grabbingWalk2:

    ; 6 sprite blocks

    .byte   $01, $09, $00
    .byte   $01, $08, $02
    .byte   $02, $02, $02, $11, $04
    .byte   $02, $02, $02, $11, $04

grabbingWalk3:

    ; 6 sprite blocks

    .byte   $01, $09, $00
    .byte   $01, $09, $04
    .byte   $02, $01, $06, $10, $08
    .byte   $02, $01, $06, $10, $08

;******************************************************************************
;*** Animation frames *********************************************************
;******************************************************************************
;*** number of frames                                                       ***
;*** metasprite definition address                                          ***
;******************************************************************************

grabbingWalk:
    .byte $08
    .word grabbingWalk1
    .byte $08
    .word grabbingWalk2
    .byte $08
    .word grabbingWalk1
    .byte $08
    .word grabbingWalk3
    .byte $00

.segment "BSS"

animFrameIndex:
    .res 1

animFrameCounter:
    .res 1

.segment "ZEROPAGE"

functionArg1:
    .res 2

functionArg2:
    .res 2

functionArg3:
    .res 2

functionArg4:
    .res 2

functionArg5:
    .res 2

functionArg6:
    .res 2

functionArg7:
    .res 2

functionArg8:
    .res 2

tempValue1:
    .res 2

tempValue2:
    .res 2

tempValue3:
    .res 2

tempValue4:
    .res 2

tempValue5:
    .res 2

tempValue6:
    .res 2

tempValue7:
    .res 2

tempValue8:
    .res 2

.segment "CODE"

.proc _main

    rep #$10
    sep #$20
    .A8
    .I16

    jsr initEvents

    setINIDSP $80   ; Enable forced VBlank during DMA transfer

    setBG1SC LEVEL_MAP_ADDR, $01
    setBG2SC SCORE_MAP_ADDR, $00
    setBG12NBA LEVEL_TILE_ADDR, SCORE_TILE_ADDR

    ; level tiles
    VRAMLoad levelTiles, LEVEL_TILE_ADDR, $22e0                 ; load tiles
    VRAMLoad levelMapInitial, LEVEL_MAP_ADDR, $0700             ; load map
    VRAMLoad levelMapInitialAlt, LEVEL_MAP_ALT_ADDR, $0700      ; load second map
    CGRAMLoad levelPal, $00, $C0                                ; load 5 palettes

    ; score tiles
    VRAMLoad scoreTiles, SCORE_TILE_ADDR, $0C00
    VRAMLoad scoreMap, SCORE_MAP_ADDR, $C0
    CGRAMLoad scorePal, $60, $20

    VRAMLoad spriteBank1Tiles, SPRITE_TILE_ZONE1_ADDR, $2000
    VRAMLoad spriteBank2Tiles, SPRITE_TILE_ZONE2_ADDR, $2000
    VRAMLoad spriteBank3Tiles, SPRITE_TILE_ZONE3_ADDR, $2000
    VRAMLoad spriteBank4Tiles, SPRITE_TILE_ZONE4_ADDR, $2000
    CGRAMLoad spritePal, $80, $20

    lda $00
    sta $2121

    lda #$02                        ; set BG mode 2
    sta $2105

    lda #$13                        ; Plane 0 (bit one) + Plane 1 (bit 2) enable register + Sprite enable
    sta $212c

    ; 4 pixel scroll down for score BG
    lda #$fb
    sta $2110
    stz $2110

    lda #$00                        ; no sub screen
    sta $212d

    jsr clearOAM
    jsr hdmaInit

    ;ldx #$00
    ;stx functionArg1
    ;ldx #grabbingWalk2
    ;stx functionArg2
    ;lda #$60
    ;sta functionArg3
    ;jsr setOam

    ;ldx #$20
    ;stx functionArg1
    ;ldx #grabbingWalk1
    ;stx functionArg2
    ;lda #$40
    ;sta functionArg3
    ;jsr setOam

    ;ldx #$40
    ;stx functionArg1
    ;ldx #grabbingWalk3
    ;stx functionArg2
    ;lda #$20
    ;sta functionArg3
    ;jsr setOam

    lda #$00
    sta $2101                       ; set sprite address

    jsr copyOAM

    lda #.BANKBYTE(copyOAMEvent)
    ldx #.LOWORD(copyOAMEvent)
    ldy #$0000
    jsr addEvent

    setINIDSP $0F   ; Enable screen full brightness

    lda #$80        ; Enable NMI
    sta CPU_NMITIMEN

    lda #$00
    sta animFrameIndex
    sta animFrameCounter

infiniteMainLoop:

    jsr grabbingAnim

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

.segment "CODE"

;******************************************************************************
;*** hdmaInit *****************************************************************
;******************************************************************************
;*** TODO explain trick *******************************************************
;******************************************************************************

.proc hdmaInit
    pha
    phx
    php

    lda #$00                        ; 1 byte value hdma (count,byte)
    sta $4300
    lda #$01                        ; sprite N select
    sta $4301
    ldx #hdmaMem
    stx $4302
    lda #.BANKBYTE(hdmaMem)
    sta $4304
    lda #01
    sta $420c                       ; enable hdma channel 0

    plp
    plx
    pla

    rts
.endproc

;******************************************************************************
;*** setOam ennemies with hdma trick ******************************************
;******************************************************************************
;*** offsetOAM  (functionArg1)                                              ***
;*** dataAddr   (functionArg2)                                              ***
;*** xPos       (functionArg3)                                              ***
;******************************************************************************

.proc setOam

    php

    ldx functionArg2
    phx

    ldy #$0000
    lda #$00
    sty tempValue2

    ldx functionArg1
lineLoop:
    pha
    phx
    tax
    lda verticalOffsetTable,x
    sta tempValue1
    plx
    pla
    cmp #$04
    beq endLineLoop
    pha
    lda ($02,s),y
    iny

blockLoop:
    cmp #$00
    beq endBlockLoop
    pha
    lda ($03,s),y
    iny
    clc
    adc functionArg3                ; add xPos
    sta oamData,x                   ; H (X) pos of the sprite
    lda tempValue1
    sta oamData+1,x                 ; V (Y) pos of the sprite
    lda ($03,s),y
    iny
    sta oamData+2,x                 ; Tile number

    lda #%00110001
    sta oamData+3,x                 ; no flip full priority palette 0 (8 global palette)

    inx
    inx
    inx
    inx

    pla
    dec
    inc tempValue2
    bra blockLoop

endBlockLoop:

    pla
    inc
    bra lineLoop

endLineLoop:

fillLoop:
    lda tempValue2
    cmp #$08
    beq endFillLoop

    lda #$e0
    sta oamData+1,x                 ; V (Y) pos of the sprite
    inx
    inx
    inx
    inx

    inc tempValue2
    bra fillLoop

endFillLoop:

    ; TODO handle that correctly in function (NOT HARD CODED)
    lda #%10101010
    sta oamData + $200
    sta oamData + $201
    sta oamData + $202
    sta oamData + $203
    sta oamData + $204
    sta oamData + $205

    plx

    plp
    rts

.endproc

.proc grabbingAnim

    pha
    phx
    phy
    php

    ldx #$0000
    txa

    lda animFrameIndex
    tay
    lda animFrameCounter
    cmp grabbingWalk,y              ; we did all frames for that index
    beq nextFrame
    cmp #$00                        ; first time we do that animation
    beq nextFrame

    inc
    sta animFrameCounter
    bra endAnim

nextFrame:

    lda #$01
    sta animFrameCounter

    lda animFrameIndex
    inc
    inc
    inc
    sta animFrameIndex
    tay
    lda grabbingWalk,y
    cmp #$00
    bne noLoop

    lda #$00
    sta animFrameIndex

noLoop:

    ldx #$00
    stx functionArg1                ; OAM index

    lda animFrameIndex
    tay
    iny
    ldx grabbingWalk,y
    stx functionArg2                ; metasprite definition

    lda #$60
    sta functionArg3                ; xPos
    jsr setOam

endAnim:

    plp
    ply
    plx
    pla

    rts

.endproc

.proc copyOAMEvent
    php

    rep #$10
    sep #$20
    .A8
    .I16

    jsr copyOAM
    lda #$01                        ; continue event value
    plp
    rtl
.endproc