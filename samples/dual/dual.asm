;
; Scroll Snes code for cc65
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

            .export     levelTiles
            .export     scoreTiles
            .export     levelMap
            .export     levelPal
            .export     scoreMap
            .export     scorePal

LEVEL_TILE_ADDR	    = $3000
LEVEL_MAP_ADDR      = $2000
LEVEL_MAP_ALT_ADDR  = $2400

SCORE_TILE_ADDR		= $1000
SCORE_MAP_ADDR		= $0000
SCORE_MAP_SIZE	    = $20*3*2

.segment "BANK1"

levelTiles:
    .incbin "ressource/level.pic"

.align  256

scoreTiles:
    .incbin "ressource/score.map.pic"

.segment "BANK2"

levelMap:
    .incbin "ressource/level.map"

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
    .incbin "ressource/level0.pal"
    .incbin "ressource/level1.pal"
    .incbin "ressource/level2.pal"
    .incbin "ressource/level3.pal"
    .incbin "ressource/level4.pal"
    .incbin "ressource/level5.pal"

.align  256

scoreMap:
    .incbin "ressource/score2.map"

scorePal:
    .incbin "ressource/score.map.pal"

.segment "CODE"

.proc _main

    rep #$10
    sep #$20
    .A8
    .I16

    setINIDSP $80                   ; Enable forced VBlank during DMA transfer and brightness to 0

    setBG1SC LEVEL_MAP_ADDR, $01
    setBG2SC SCORE_MAP_ADDR, $00
    setBG12NBA LEVEL_TILE_ADDR, SCORE_TILE_ADDR

    ; level tiles
    VRAMLoad levelTiles, LEVEL_TILE_ADDR, $5000                 ; load tiles
    VRAMLoad levelMapInitial, LEVEL_MAP_ADDR, $0700             ; load map
    VRAMLoad levelMapInitialAlt, LEVEL_MAP_ALT_ADDR, $0700      ; load second map
    CGRAMLoad levelPal, $00, $C0                                ; load 5 palettes

    ; score tiles
    VRAMLoad scoreTiles, SCORE_TILE_ADDR, $0C00
    VRAMLoad scoreMap, SCORE_MAP_ADDR, $C0
    CGRAMLoad scorePal, $60, $20

    lda #$02                        ; set BG mode 2
    sta $2105

    lda #$03                         ; Plane 0 (bit one) + Plane 1 (bit 2) enable register
    sta $212c

    ; 4 pixel scroll down for score BG
    lda #$fb
    sta $2110
    stz $2110

    lda $00                         ; All subPlane disable
    sta $212d

    setINIDSP $0f                   ; Disable forced VBlank + full brightness

    jsr initEvents
    jsr scrollInitEvent

    lda #.BANKBYTE(scrollEvent)
    ldx #.LOWORD(scrollEvent)
    ldy #$0000
    jsr addEvent

    lda #$80                        ; Enable NMI
    sta CPU_NMITIMEN

infiniteMainLoop:

    lda scrollDirection
    cmp #$01
    beq scrollRight

scrollLeft:
    ldx scrollValue                 ; decrement scrollValue
    dex
    stx scrollValue

    ldx mapPosition                 ; decrement mapPosition
    dex
    stx mapPosition

    jmp scrollValueSet

scrollRight:
    ldx scrollValue                 ; increment scrollValue
    inx
    stx scrollValue

    ldx mapPosition                 ; increment mapPosition
    inx
    stx mapPosition

scrollValueSet:
    lda mapPosition
    cmp #$ff
    beq pouet3
    jmp continue

pouet3:
    lda mapPosition+1
    cmp #$ff                        ; #$ff because of overflow in map position
    bne pouet
    lda #$01                        ; change direction to go right
    sta scrollDirection
    lda #$01                        ; force mapPosition/position to avoid bad VRAMLoad
    sta mapPosition+1
    jmp infiniteMainLoop

pouet:
    cmp #$07
    bne pouet2
    lda #$00                        ; change direction to go left
    sta scrollDirection
    lda #$05                        ; force mapPosition/position to avoid bad VRAMLoad
    sta mapPosition+1
    jmp infiniteMainLoop

pouet2:
    lda mapPosition+1               ; get screen position
    and #$01                        ; modulo 2
    bne evenTransfer

oddTransfer:
    lda mapPosition+1               ; get screen position

    rep #$20                        ; calculation index in levelMapTable from position in register A
    .A16
    and #$00ff
    asl
    asl
    tax                             ; put that index in register X
    sep #$20
    .A8

    lda levelMapTable,x
    sta levelDMASrc
    lda levelMapTable+1,x
    sta levelDMASrc+1
    lda levelMapTable+2,x
    sta levelDMASrc+2

    ldx #LEVEL_MAP_ALT_ADDR
    stx levelDMADst

    ldx #$0700
    stx levelDMASize

    ldx #$0000                      ; reset scrollValue to 0
    stx scrollValue

    jmp continue

evenTransfer:
    lda mapPosition+1               ; get screen position

    rep #$20                        ; calculation index in levelMapTable from position in register A
    .A16
    and #$00ff
    asl
    asl
    tax                             ; put that index in register X
    sep #$20
    .A8

    lda levelMapTable,x
    sta levelDMASrc

    lda levelMapTable+1,x
    sta levelDMASrc+1

    lda levelMapTable+2,x
    sta levelDMASrc+2

    ; levelDMADst = LEVEL_MAP;
    ldx #LEVEL_MAP_ADDR
    stx levelDMADst

    ldx #$0700
    stx levelDMASize

    ldx #$00ff                      ; reset scrollValue to 256 (#$00ff)
    stx scrollValue

continue:

    wai                             ; wait for next interrupt (NMI)
    jmp infiniteMainLoop
.endproc

;******************************************************************************
;*** Events *******************************************************************
;******************************************************************************

.segment "BSS"

levelDMASrc:
    .res    3

levelDMADst:
    .res    2

levelDMASize:
    .res    2

scrollValue:
    .res    2

mapPosition:
    .res    2

scrollDirection:
    .res    1

levelMapTable:
    .res    4*7

.segment "CODE"

.proc scrollInitEvent
    pha
    phx
    php

    lda #$ff                        ; init Y scroll
    sta $210e
    stz $210e

    lda #00                         ; init scrollDirection
    sta scrollDirection             ; 0 -> left ; 1 -> right

    ldx #$0100                      ; init scrollValue
    stx scrollValue

    ldx #$0600
    stx mapPosition

    jsr initLevelDMA

    ldx #$0000

    lda #.LOBYTE(levelMap1)
    sta levelMapTable,x
    lda #.HIBYTE(levelMap1)
    sta levelMapTable+1,x
    lda #.BANKBYTE(levelMap1)
    sta levelMapTable+2,x
    lda #$00
    sta levelMapTable+3,x

    inx
    inx
    inx
    inx

    lda #.LOBYTE(levelMap2)
    sta levelMapTable,x
    lda #.HIBYTE(levelMap2)
    sta levelMapTable+1,x
    lda #.BANKBYTE(levelMap2)
    sta levelMapTable+2,x
    lda #$00
    sta levelMapTable+3,x

    inx
    inx
    inx
    inx

    lda #.LOBYTE(levelMap3)
    sta levelMapTable,x
    lda #.HIBYTE(levelMap3)
    sta levelMapTable+1,x
    lda #.BANKBYTE(levelMap3)
    sta levelMapTable+2,x
    lda #$00
    sta levelMapTable+3,x

    inx
    inx
    inx
    inx

    lda #.LOBYTE(levelMap4)
    sta levelMapTable,x
    lda #.HIBYTE(levelMap4)
    sta levelMapTable+1,x
    lda #.BANKBYTE(levelMap4)
    sta levelMapTable+2,x
    lda #$00
    sta levelMapTable+3,x

    inx
    inx
    inx
    inx

    lda #.LOBYTE(levelMap5)
    sta levelMapTable,x
    lda #.HIBYTE(levelMap5)
    sta levelMapTable+1,x
    lda #.BANKBYTE(levelMap5)
    sta levelMapTable+2,x
    lda #$00
    sta levelMapTable+3,x

    inx
    inx
    inx
    inx

    lda #.LOBYTE(levelMap6)
    sta levelMapTable,x
    lda #.HIBYTE(levelMap6)
    sta levelMapTable+1,x
    lda #.BANKBYTE(levelMap6)
    sta levelMapTable+2,x
    lda #$00
    sta levelMapTable+3,x

    inx
    inx
    inx
    inx

    lda #.LOBYTE(levelMap7)
    sta levelMapTable,x
    lda #.HIBYTE(levelMap7)
    sta levelMapTable+1,x
    lda #.BANKBYTE(levelMap7)
    sta levelMapTable+2,x
    lda #$00
    sta levelMapTable+3,x

    inx
    inx
    inx
    inx

    plp
    plx
    pla
    rts
.endproc

.proc initLevelDMA
    stz levelDMASrc                 ; init levelDMA values
    stz levelDMASrc+1
    stz levelDMASrc+2
    stz levelDMADst
    stz levelDMADst+1
    stz levelDMASize
    stz levelDMASize+1
    rts
.endproc

.proc scrollEvent

    phx
    phy
    php

    tax                             ; put A reg containing counter in X reg

    rep #$10
    sep #$20
    .A8
    .I16

    ldy levelDMASize
    cpy #$00
    beq noDMA

    VRAMLoadFromPointer levelDMASrc, levelDMADst, levelDMASize
    jsr initLevelDMA                ; reset levelDMA values

noDMA:
    lda scrollValue
    sta $210d
    lda scrollValue+1
    sta $210d

    lda #$01                        ; continue event value

    plp
    ply
    plx

    rtl
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