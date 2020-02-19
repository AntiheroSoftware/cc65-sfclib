;
; HDMA Snes code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments
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
            .export     spriteInit

SPRITE_TILE_ADDR	= $0000
SHADOW_TILE_ADDR	= $0100

BACKGROUND_TILE_ADDR	= $2000
BACKGROUND_MAP_ADDR   = $1000

.segment "RODATA"

spriteTiles:
    .incbin "resource/main-sprite.pic"

spritePal:
    .incbin "resource/main-sprite.clr"

shadowSpriteTiles:
    .incbin "resource/main-shadow-sprite.pic"
    ;.incbin "resource/main-shadow-sprite-inverted.pic"

shadowSpritePal:
    .incbin "resource/main-shadow-sprite.clr"
    ;.incbin "resource/main-shadow-sprite-inverted.clr"

backgroundMap:
    .incbin "resource/background.map"

backgroundPal:
    .incbin "resource/background.clr"

.segment "BANK1"

backgroundTiles:
    .incbin "resource/background.pic"

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

    ;*** Setup background ***

    setBG1SC BACKGROUND_MAP_ADDR, $00
    setBG12NBA BACKGROUND_TILE_ADDR, $0000

    VRAMLoad backgroundTiles, BACKGROUND_TILE_ADDR, $1C80

    lda $00
    sta $2121

    CGRAMLoad backgroundPal, $00, $20
    VRAMLoad backgroundMap, BACKGROUND_MAP_ADDR, $780

    ;*** Setup sprites ***

    VRAMLoad spriteTiles, SPRITE_TILE_ADDR, $0100
    CGRAMLoad spritePal, $80, $10

    VRAMLoad shadowSpriteTiles, SHADOW_TILE_ADDR, $0100
    CGRAMLoad shadowSpritePal, $c0, $20

    lda #$01         ; setBGMODE(0, 0, 1);
    sta $2105

    lda #$01         ; main screen definition (OAM+BG1)
    sta $212c

    lda #$10         ; sub screen definition
    sta $212d

    lda #%00000010
    sta $2130

    lda #%01000001   ; 0 -> Sub / 1 -> Add
                     ; 0 -> 1/2 Disable / 1 -> 1/2 Enable

                     ; Currently I have a better effect with 1/2 enabled
    sta $2131

    lda #$00
    sta $2132

    jsr spriteInit

    setINIDSP $0F    ; Enable screen full brightness

    lda #$80         ; Enable NMI
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
    lda #$e0
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

    ;*************************
    ;*** Start main Sprite ***
    ;*************************

/*
    lda #$64
    sta oamData+32                     ; H pos of the first sprite
    lda #$64
    sta oamData+33                  ; V pos of the first sprite
    lda #$00
    sta oamData+34
    lda #%00110000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+35

    lda #$64
    sta oamData+36                   ; H pos of the first sprite
    lda #$6c
    sta oamData+37                  ; V pos of the first sprite
    lda #$02
    sta oamData+38
    lda #%00110000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+39

    lda #$64
    sta oamData+40                   ; H pos of the first sprite
    lda #$74
    sta oamData+41                   ; V pos of the first sprite
    lda #$04
    sta oamData+42
    lda #%00110000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+43

    lda #$64
    sta oamData+44                   ; H pos of the first sprite
    lda #$7c
    sta oamData+45                   ; V pos of the first sprite
    lda #$06
    sta oamData+46
    lda #%00110000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+47

    lda #$6c
    sta oamData+16                     ; H pos of the first sprite
    lda #$64
    sta oamData+17                   ; V pos of the first sprite
    lda #$01
    sta oamData+18
    lda #%00110000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+19

    lda #$6c
    sta oamData+20                   ; H pos of the first sprite
    lda #$6c
    sta oamData+21                   ; V pos of the first sprite
    lda #$03
    sta oamData+22
    lda #%00110000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+23

    lda #$6c
    sta oamData+24                   ; H pos of the first sprite
    lda #$74
    sta oamData+25                   ; V pos of the first sprite
    lda #$05
    sta oamData+26
    lda #%00110000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+27

    lda #$6c
    sta oamData+28                   ; H pos of the first sprite
    lda #$7c
    sta oamData+29                   ; V pos of the first sprite
    lda #$07
    sta oamData+30
    lda #%00110000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+31

    lda #%00000000
    sta oamData + $200

    lda #%00000000
    sta oamData + $201
*/
    ;***********************
    ;*** End main Sprite ***
    ;***********************

    ;***************************
    ;*** Start shadow Sprite ***
    ;***************************

    lda #$64
    sta oamData                     ; H pos of the first sprite
    lda #$64
    sta oamData+1                   ; V pos of the first sprite
    lda #$10
    sta oamData+2
    lda #%00111000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+3

    lda #$6c
    sta oamData+4                   ; H pos of the first sprite
    lda #$64
    sta oamData+5                   ; V pos of the first sprite
    lda #$11
    sta oamData+6
    lda #%00111000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+7

    lda #$64
    sta oamData+8                   ; H pos of the first sprite
    lda #$6c
    sta oamData+9                   ; V pos of the first sprite
    lda #$12
    sta oamData+10
    lda #%00111000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+11

    lda #$6c
    sta oamData+12                   ; H pos of the first sprite
    lda #$6c
    sta oamData+13                   ; V pos of the first sprite
    lda #$13
    sta oamData+14
    lda #%00111000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+15

    lda #$64
    sta oamData+48                     ; H pos of the first sprite
    lda #$74
    sta oamData+49                   ; V pos of the first sprite
    lda #$10
    sta oamData+50
    lda #%00111000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+51

    lda #$6c
    sta oamData+52                   ; H pos of the first sprite
    lda #$74
    sta oamData+53                   ; V pos of the first sprite
    lda #$11
    sta oamData+54
    lda #%00111000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+55

    lda #%00000000
    sta oamData + $202

    lda #%00000000
    sta oamData + $203

    ;*************************
    ;*** End shadow Sprite ***
    ;*************************

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

    ldx #$8000
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
