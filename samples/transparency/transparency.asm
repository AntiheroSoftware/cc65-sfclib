;
; HDMA Snes code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments
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

SPRITE_TILE_ADDR	= $0000
SHADOW_TILE_ADDR	= $0100

BACKGROUND_TILE_ADDR	= $2000
BACKGROUND_MAP_ADDR   = $1000

.segment "RODATA"

spriteTiles:
    ;.incbin "resource/main-sprite.pic"
    .incbin "resource/black.pic"

spritePal:
    ;.incbin "resource/main-sprite.clr"
    .incbin "resource/black.clr"

shadowSpriteTiles:
    ;.incbin "resource/main-shadow-sprite.pic"
    ;.incbin "resource/main-shadow-sprite-inverted.pic"
    .incbin "resource/black-shadow.pic"

shadowSpritePal:
    ;.incbin "resource/main-shadow-sprite.clr"
    ;.incbin "resource/main-shadow-sprite-inverted.clr"
    .incbin "resource/black-shadow.clr"

backgroundMap:
    ;.incbin "resource/background.map"
    .incbin "resource/background-checker.map"

backgroundPal:
    ;.incbin "resource/background.clr"
    .incbin "resource/background-checker.clr"

.segment "BANK1"

backgroundTiles:
    ;.incbin "resource/background.pic"
    .incbin "resource/background-checker.pic"

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

    VRAMLoad spriteTiles, SPRITE_TILE_ADDR, $0120
    CGRAMLoad spritePal, $80, $20

    VRAMLoad shadowSpriteTiles, SHADOW_TILE_ADDR, $00c0
    CGRAMLoad shadowSpritePal, $c0, $20

    lda #$01         ; setBGMODE(0, 0, 1);
    sta $2105

    lda #$11         ; main screen definition (OAM+BG1)
    sta $212c

    lda #$01         ; sub screen definition (BG1)
    sta $212d

    lda #%00000010   ; enable add/sub from subscreen
    sta $2130

    lda #%01110001   ; 0 -> Sub / 1 -> Add
                     ; 0 -> 1/2 Disable / *1* -> 1/2 Enable
                     ; *back* / *oam* / bg4 / bg3 / bg2 / *bg1*
                     ; ps : I enable bg1 because of halving so subscreen keep
                     ; the right color. BG1 need a #0 color set to pure black
                     ; use --color-zero 00000000 with superfamiconv
    sta $2131

    lda #$00
    sta $2132

    lda #$e0         ; Set black for fixed color
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

    jsr clearOAM

    ;*************************
    ;*** Start main Sprite ***
    ;*************************

    lda #$60
    sta oamData+32                  ; H pos of the first sprite
    lda #$60
    sta oamData+33                  ; V pos of the first sprite
    lda #$00
    sta oamData+34
    lda #%00110000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+35

    lda #$68
    sta oamData+36                  ; H pos of the first sprite
    lda #$60
    sta oamData+37                  ; V pos of the first sprite
    lda #$01
    sta oamData+38
    lda #%00110000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+39

    lda #$60
    sta oamData+40                   ; H pos of the first sprite
    lda #$68
    sta oamData+41                   ; V pos of the first sprite
    lda #$02
    sta oamData+42
    lda #%00110000                   ; no flip full priority palette 0 (8 global palette)
    sta oamData+43

    lda #$68
    sta oamData+44                   ; H pos of the first sprite
    lda #$68
    sta oamData+45                   ; V pos of the first sprite
    lda #$03
    sta oamData+46
    lda #%00110000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+47

    lda #$60
    sta oamData+16                     ; H pos of the first sprite
    lda #$70
    sta oamData+17                   ; V pos of the first sprite
    lda #$04
    sta oamData+18
    lda #%00110000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+19

    lda #$68
    sta oamData+20                   ; H pos of the first sprite
    lda #$70
    sta oamData+21                   ; V pos of the first sprite
    lda #$05
    sta oamData+22
    lda #%00110000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+23

    lda #%00000000
    sta oamData + $200

    lda #%00000000
    sta oamData + $201

    ;***********************
    ;*** End main Sprite ***
    ;***********************

    ;***************************
    ;*** Start shadow Sprite ***
    ;***************************

    lda #$5b                        ; Sprite slot #0
    sta oamData                     ; H pos of the first sprite
    lda #$65
    sta oamData+1                   ; V pos of the first sprite
    lda #$10
    sta oamData+2
    lda #%00111000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+3

    lda #$63                        ; Sprite slot #1
    sta oamData+4                   ; H pos of the first sprite
    lda #$65
    sta oamData+5                   ; V pos of the first sprite
    lda #$11
    sta oamData+6
    lda #%00111000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+7

    lda #$6b                        ; Sprite slot #2
    sta oamData+8                   ; H pos of the first sprite
    lda #$65
    sta oamData+9                   ; V pos of the first sprite
    lda #$12
    sta oamData+10
    lda #%00111000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+11

    lda #$5b                        ; Sprite slot #3
    sta oamData+12                  ; H pos of the first sprite
    lda #$6d
    sta oamData+13                  ; V pos of the first sprite
    lda #$13
    sta oamData+14
    lda #%00111000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+15

    lda #$63                        ; Sprite slot #12
    sta oamData+48                  ; H pos of the first sprite
    lda #$6d
    sta oamData+49                  ; V pos of the first sprite
    lda #$14
    sta oamData+50
    lda #%00111000                  ; no flip full priority palette 0 (8 global palette)
    sta oamData+51

    lda #$6b                        ; Sprite slot #13
    sta oamData+52                  ; H pos of the first sprite
    lda #$6d
    sta oamData+53                  ; V pos of the first sprite
    lda #$15
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

    jsr OAMDataUpdated
    jsr copyOAM

    pla
    plx
    rts
.endproc
