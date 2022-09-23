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
            .export     spriteInit

SPRITE_TILE_ZONE1_ADDR	= $1000
SPRITE_TILE_ZONE2_ADDR	= $2000
SPRITE_TILE_ZONE3_ADDR	= $3000
SPRITE_TILE_ZONE4_ADDR	= $4000

.segment "RODATA"

knife1Tiles:
    .incbin "resource/knife1.pic"

knife2Tiles:
    .incbin "resource/knife2.pic"

knife3Tiles:
    .incbin "resource/knife3.pic"

knife4Tiles:
    .incbin "resource/knife4.pic"

knifePal:
    .incbin "resource/knife.pal"

hdmaMem:
    .byte $74,%00000000,$10,%00001000,$10,%00010000,$10,%00011000,$00

.segment "ZEROPAGE"

spriteTrickIndex:
	.res 2

.segment "RODATA"

spriteTrickIRQVTimer:
	.byte $00, $74, $84, $94

spriteTrickIRQValue:
	.byte %00000000
	.byte %00001000
	.byte %00010000
	.byte %00011000

.segment "CODE"

.proc _main

    rep #$10
    sep #$20
    .A8
    .I16

    jsr initEvents

    setINIDSP $80   ; Enable forced VBlank during DMA transfer

    VRAMLoad knife1Tiles, SPRITE_TILE_ZONE1_ADDR, $0400
    VRAMLoad knife2Tiles, SPRITE_TILE_ZONE2_ADDR, $0400
    VRAMLoad knife3Tiles, SPRITE_TILE_ZONE3_ADDR, $0400
    VRAMLoad knife4Tiles, SPRITE_TILE_ZONE4_ADDR, $0400
    CGRAMLoad knifePal, $80, $20

    lda $00
    sta $2121

    lda #$01        ; setBGMODE(0, 0, 1);
    sta $2105

    lda #$10         ; enable sprite
    sta $212c

    lda #$00         ; no sub screen
    sta $212d

    jsr spriteInit

    setINIDSP $0F   ; Enable screen full brightness

    ldx #$00FF
    sta $4207
    ldx #$0000
    sta $4209

    ldx #$0000
    stx spriteTrickIndex

    ;lda #$80        ; Enable NMI
    lda #$B0        ; Enable NMI + IRQ V&H

    ;lda #$30        ; IRQ V&H
    sta CPU_NMITIMEN

infiniteMainLoop:
    wai
    jmp infiniteMainLoop

.endproc

.proc _IRQHandler

	pha
	phx

	lda $4211           ; clear interrupt flag

	ldx spriteTrickIndex
	lda spriteTrickIRQValue,X
	sta $2101

	inx
	cpx #$04
	bne :+

	ldx #$0000

:	stx spriteTrickIndex
	lda spriteTrickIRQVTimer,X
	sta $4209

	plx
	pla

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
;*** SpriteInit ***************************************************************
;******************************************************************************

.segment "CODE"

.proc spriteInit
    phx
    pha

    ldx #$0000
spriteClear:
    stz oamData,x
    inx
    lda#$e0
    sta oamData,x
    inx
    stz oamData,x
    inx
    stz oamData,x
    inx
    cpx #$0200
    bne spriteClear

spriteDataClear:
    stz oamData,x
    inx
    cpx #$0220
    bne spriteDataClear

    lda #$64
    sta oamData                     ; H pos of the first sprite
    lda #$64
    sta oamData+1                   ; V pos of the first sprite
    lda #$00
    sta oamData+2
    lda #%00110001                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+3

    lda #$64
    sta oamData+4                     ; H pos of the first sprite
    lda #$74
    sta oamData+5                   ; V pos of the first sprite
    lda #$00
    sta oamData+6
    lda #%00110001                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+7

    lda #$64
    sta oamData+8                     ; H pos of the first sprite
    lda #$84
    sta oamData+9                   ; V pos of the first sprite
    lda #$00
    sta oamData+10
    lda #%00110001                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+11

    lda #$64
    sta oamData+12                     ; H pos of the first sprite
    lda #$94
    sta oamData+13                   ; V pos of the first sprite
    lda #$00
    sta oamData+14
    lda #%00110001                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+15

    lda #%10101010
    sta oamData + $200

    lda #$00
    sta $2101                       ; set sprite address

    jsr OAMDataUpdated
    jsr copyOAM

    pla
    plx
    rts
.endproc
