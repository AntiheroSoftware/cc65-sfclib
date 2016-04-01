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

LEVEL_TILE_ADDR	= $1000
LEVEL_MAP_ADDR     = $0000

.segment "BANK1"

levelTiles:
    .incbin "ressource/level.pic"

.segment "BANK2"

levelMap:
    .incbin "ressource/level.map"

levelPal:
    .incbin "ressource/level.clr"

.segment "CODE"

.proc _main

    rep #$10
    sep #$20
    .A8
    .I16

    setINIDSP $80   ; Enable forced VBlank during DMA transfer and brightness to 0

    setBG1SC LEVEL_MAP_ADDR, $01
    setBG12NBA LEVEL_TILE_ADDR, $0000

    VRAMLoad levelTiles, LEVEL_TILE_ADDR, $5000

    ; // Copy first part of level
    ; map = level1_map+(0x380*5); // 5 screens, point to the last one
    ; VRAMLoadFromPtr(map, HEX_A(LEVEL_MAP), HEX_A(0700));
    ; map = level1_map+(0x380*6);
    ; VRAMLoadFromPtr(map, HEX_A(LEVEL_MAP_ALT), HEX_A(0700));

    VRAMLoad levelMap, LEVEL_MAP_ADDR, $0700

    CGRAMLoad levelPal, $00, $40

    lda #$03        ; set BG mode 3
    sta $2105

    lda $03         ; Plane 0 (bit one) , plane 1 (bit two) enable register
    sta $212c

    lda $00         ; All subPlane disable
    sta $212d

    setINIDSP $0f   ; Disable forced VBlank + full brightness

infiniteMainLoop:
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