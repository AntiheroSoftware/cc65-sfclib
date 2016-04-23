;
; HDMA Snes code for cc65
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

            ; TODO remove just for debug
            .export     oamData
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
    ;.byte $73,%00000000,$10,%00001000,$10,%00010000,$10,%00011000,$00
    .byte $74,%00000000,$10,%00001000,$10,%00010000,$10,%00011000,$00

.segment "BSS"

oamData:
    .res 512+32

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
    jsr hdmaInit

    setINIDSP $0F   ; Enable screen full brightness

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

    jsr copyOAM

    pla
    plx
    rts
.endproc

.proc copyOAM
    pha
    phx

    ldx #$0000
    stx $2102

    lda #$00
    sta $4370
    lda #$04
    sta $4371
    ldx #oamData
    stx $4372
    lda #.BANKBYTE(oamData)
    sta $4374
    ldx #$0220
    stx $4375

    lda #$80                        ; trigger DMA channel 7
    sta $420b

    plx
    pla
    rts
.endproc

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
    lda .BANKBYTE(hdmaMem)
    lda #01
    sta $420c                       ; enable hdma channel 0

    plp
    plx
    pla

    rts
.endproc