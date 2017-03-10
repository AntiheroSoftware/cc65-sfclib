;
; HDMA Snes code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .include    "snes.inc"
            .include    "snes-sprite.inc"

            .forceimport	__STARTUP__

            .export     _main
            .export     _IRQHandler
            .export     _NMIHandler
            .export     _preInit

            .import     initEvents
            .import     addEvent
            .import     removeEvent
            .import     processEvents

            ; TODO remove just for debug
            .export     hdmaMem
            .export     hdmaInit

            .export     setOAMFrame
            .export     setOAMFrameDMA
            .export     setOAMTranslate
            .export     copyOAMEvent
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
;*** Size in bytes (once)													***
;*** Frame properties (once)												***
;*** X offset                                                               ***
;*** Y offset                                                               ***
;*** Sprite Properties                                                      ***
;*** Tile Number                                                            ***
;******************************************************************************

grabbingWalk1:

    ; 4 sprite blocks (16 bytes)

	.byte 	$10
	.byte 	$00

    .byte   $09, $00, $00, $21
    .byte   $09, $10, $00, $21
    .byte   $09, $20, $00, $21
    .byte   $09, $30, $00, $21

grabbingWalk2:

    ; 6 sprite blocks (24 bytes)

    .byte 	$18
	.byte 	$00

    .byte   $09, $00, $00, $21
    .byte   $08, $10, $02, $21
    .byte   $02, $20, $02, $21
    .byte 	$11, $20, $04, $21
    .byte   $02, $30, $02, $21
    .byte 	$11, $30, $04, $21

grabbingWalk3:

    ; 6 sprite blocks (24 bytes)

    .byte 	$18
	.byte 	$00

    .byte   $09, $00, $00, $21
    .byte   $09, $10, $04, $21
    .byte   $01, $20, $06, $21
    .byte	$10, $20, $08, $21
    .byte   $01, $30, $06, $21
    .byte	$10, $30, $08, $21

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

    ;*** level tiles ***
    ;*******************

    VRAMLoad levelTiles, LEVEL_TILE_ADDR, $22e0                 ; load tiles
    VRAMLoad levelMapInitial, LEVEL_MAP_ADDR, $0700             ; load map
    VRAMLoad levelMapInitialAlt, LEVEL_MAP_ALT_ADDR, $0700      ; load second map
    CGRAMLoad levelPal, $00, $C0                                ; load 5 palettes

    ;*** score tiles ***
    ;*******************

    VRAMLoad scoreTiles, SCORE_TILE_ADDR, $0C00
    VRAMLoad scoreMap, SCORE_MAP_ADDR, $C0
    CGRAMLoad scorePal, $60, $20

	;*** sprite tiles ***
	;********************

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

    ;jsr hdmaInit

    ldx #$0000
    ldy #grabbingWalk2
    jsr setOAMFrame

    ldx #oamData
	ldy #grabbingWalk2
	jsr setOAMFrameDMA

	jsr setOAMTranslate

    lda #$00
    sta $2101                       ; set sprite address

	jsr OAMDataUpdated
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

    ;jsr grabbingAnim

    jsr OAMDataUpdated
	jsr copyOAM

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
;*** setOAMFrame ennemies with hdma trick *************************************
;******************************************************************************
;*** offsetOAM  (X register)                                                ***
;*** dataAddr   (Y register)                                                ***
;******************************************************************************

.proc setOAMFrame

	pha
	phx
	phy
    php

	ldx #$0000
	ldy #$0000

	lda #$00
	xba								; clear high byte of A register
    lda ($02,s),Y					; get size of frame

	sta tempValue1

	iny
	iny

copyLoop:
	lda ($02,s),Y
	sta oamData,X

	inx
	iny

	lda tempValue1
	dec
	sta tempValue1
	cmp #$00
	bne copyLoop

    plp
    ply
    plx
    pla
    rts

.endproc

;******************************************************************************
;*** setOAMFrameDMA ***********************************************************
;******************************************************************************
;*** offsetOAM  (X register)                                                ***
;*** dataAddr   (Y register)                                                ***
;******************************************************************************

.proc setOAMFrameDMA

	pha
	phx
	phy
	php

	lda #$00
	sta $2183

	stx $2181

	lda #$00
	xba							; clear high byte of A register
	lda ($02,s),Y				; get size of frame
	tax
	stx $4365					;Size

	iny
	iny

	stz $420b					;Disable DMA

	sty $4362					;Data offset
	stz $4364					;Data bank

	lda #$80
	sta $4361

	;*** Set mode, destination and start transfer

	ldx     #$00
	stx     $4360

	lda     #%01000000
	sta     $420b

	plp
	ply
	plx
	pla
	rts

.endproc

;******************************************************************************
;*** setOAMTranslate ennemies *************************************************
;******************************************************************************
;*** OAM sprite number (A register)                                         ***
;*** X translate (X register)                                               ***
;*** Y translate (Y register)                                               ***
;******************************************************************************

.proc setOAMTranslate

	pha
	phx
	phy
	php

	; TODO handle that correctly in function (NOT HARD CODED)
	lda #%10101010
	sta oamData + $200
	sta oamData + $201
	sta oamData + $202
	sta oamData + $203
	sta oamData + $204
	sta oamData + $205

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