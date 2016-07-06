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

LEVEL_TILE_ADDR	    = $1000
LEVEL_MAP_ADDR      = $0000

.segment "BANK1"

levelTiles:
    .incbin "ressource/level.pic"

.segment "BANK2"

levelMap:
    .incbin "ressource/level.map"

levelMapInitial := levelMap+($0700*6)-$38
levelMapRestart := levelMap+($0700*1)
levelMapStart   := levelMap
levelMapEnd     := levelMap+($0700*7)

levelPal:
    .incbin "ressource/level0.pal"
    .incbin "ressource/level1.pal"
    .incbin "ressource/level2.pal"
    .incbin "ressource/level3.pal"
    .incbin "ressource/level4.pal"
    .incbin "ressource/level5.pal"

.segment "CODE"

.proc _main

    rep #$10
    sep #$20
    .A8
    .I16

    setINIDSP $80                   ; Enable forced VBlank during DMA transfer and brightness to 0

    setBG1SC LEVEL_MAP_ADDR, $01
    setBG12NBA LEVEL_TILE_ADDR, $0000

    VRAMLoad levelTiles, LEVEL_TILE_ADDR, $5000                 ; load tiles
    CGRAMLoad levelPal, $00, $C0                                ; load 5 palettes

	ldx #$001f
	ldy #.LOWORD(levelMapInitial)

loop:
	jsr displayLevelLine

	cpx #$003f
	beq stopLoop

	rep #$20
	.A16

	inx
	tya
	clc
	adc #$0038
	tay

	sep #$20
	.A8

	bra loop

stopLoop:

	sep #$20
	.A8

    lda #$02                        ; set BG mode 2
    sta $2105

    lda #$01                         ; Plane 0 (bit one) enable register
    sta $212c

    lda #$00                         ; All subPlane disable
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
	ldx scrollValue
    lda scrollDirection
    cmp #$01
    beq scrollRight

scrollLeft:
    dex 			                ; decrement scrollValue
    stx scrollValue
    txa
    and #%00000111
    bne scrollValueSet

    lda #$01
    sta doUpdate

    lda VRAMLine
    dec
    and #$3f
    sta VRAMLine

	rep #$20
	.A16

	lda MAPOffset
	sec
	sbc #$38
	sta MAPOffset

	cmp #.LOWORD(levelMapStart)
	bpl scrollValueSet

	sep #$20
	.A8

	lda #$01
	sta scrollDirection

	lda VRAMLine
	clc
	adc #$21
	sta VRAMLine

	ldx #.LOWORD(levelMapRestart)
	stx MAPOffset

    bra scrollValueSet

scrollRight:
    inx  			                ; increment scrollValue
    stx scrollValue
	txa
    and #%00000111
    bne scrollValueSet

    lda #$01
    sta doUpdate

    lda VRAMLine
    inc
    and #$3f
    sta VRAMLine

	rep #$20
	.A16

	lda MAPOffset
	clc
	adc #$38
	sta MAPOffset

	cmp #.LOWORD(levelMapEnd)
	bcc scrollValueSet

	sep #$20
	.A8

	lda #$00
	sta scrollDirection

	lda VRAMLine
	sec
	sbc #$21
	sta VRAMLine

	ldx #.LOWORD(levelMapInitial)
	stx MAPOffset

scrollValueSet:

	sep #$20
	.A8

	bra waitForVBlank

waitForVBlank:
    wai                             ; wait for next interrupt (NMI)
    jmp infiniteMainLoop

.endproc

;******************************************************************************
;*** Events *******************************************************************
;******************************************************************************

.segment "BSS"

VRAMLine:
	.res 2

MAPOffset:
	.res 2

scrollValue:
    .res    2

scrollDirection:
    .res    1

doUpdate:
	.res 1

.segment "RODATA"

VRAMOffset:
	.word $0000, $0001, $0002, $0003, $0004, $0005, $0006, $0007
	.word $0008, $0009, $000a, $000b, $000c, $000d, $000e, $000f
	.word $0010, $0011, $0012, $0013, $0014, $0015, $0016, $0017
	.word $0018, $0019, $001a, $001b, $001c, $001d, $001e, $001f
	.word $0400, $0401, $0402, $0403, $0404, $0405, $0406, $0407
	.word $0408, $0409, $040a, $040b, $040c, $040d, $040e, $040f
	.word $0410, $0411, $0412, $0413, $0414, $0415, $0416, $0417
	.word $0418, $0419, $041a, $041b, $041c, $041d, $041e, $041f

.segment "CODE"

.proc scrollInitEvent
    pha
    phx
    php

    lda #$ff                        ; init Y scroll
    sta $210e
    stz $210e

    lda #$1f
    sta VRAMLine
    lda #$00
    sta VRAMLine+1

	ldx #.LOWORD(levelMapInitial)
	stx MAPOffset

    lda #00                         ; init scrollDirection
    sta scrollDirection             ; 0 -> left ; 1 -> right
    sta doUpdate

    ldx #$0100                      ; init scrollValue
    stx scrollValue

    plp
    plx
    pla
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

    lda doUpdate
    cmp #$00
    beq noDMA

    ldx VRAMLine
	ldy MAPOffset
	jsr displayLevelLine

	lda #$00
	sta doUpdate

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

.proc displayLevelLine
	pha
	phx
	phy
	php

	rep #$20
	.A16

	txa
	asl
	tax

	sep #$20
	.A8

	lda #$81
	sta PPU_VMAINC

	phy
	ldy VRAMOffset,x

	sty PPU_VMADDL
	ply

	lda #$01
	sta DMA_PARAM0

	lda #$18
	sta DMA_BBUS0

	sty DMA_ABUS0L

	lda #$02						; static bank 2
	sta DMA_ABUS0B

	lda	#$38						; size of transfer is #$38
	sta	DMA_SIZE0L
	lda	#$00
	sta DMA_SIZE0H

	lda	#%00000001					; enable DMA 0
	sta	CPU_MDMAEN

	plp
	ply
	plx
	pla
	rts
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