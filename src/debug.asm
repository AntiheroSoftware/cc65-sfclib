;
; Debug Snes code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .include    "snes.inc"

            .export     initDebug
            .export     setCursorDebug
            .export     writeStringDebug
            .export     displayDebug

DEBUG_TILE_ADDR	= $2000
DEBUG_MAP_ADDR  = $1000
DEBUG_MAP_SIZE  = $0800

.segment "RODATA"

debugFontPal:
    .incbin "resource/debugFont.clr"

debugFontGfx:
    .incbin "resource/debugFont.pic"

.segment "BSS"

cursorPos:
    .res    2
debugMap:
    .res    $800

.segment "CODE"

; void initDebug(void)

.proc initDebug
    pha
    phx
    phy
    php

    rep #$10
    sep #$20
    .A8
    .I16

    setINIDSP $80   ; Enable forced VBlank during DMA transfer

    ldx #$0000
    stx cursorPos

    ldx #$0800
    lda #$00
initMapLoop:
    sta debugMap,x
    dex
    cpx #$0000
    bne initMapLoop

    ; // Screen map data @ VRAM location $1000
    ; setBG1SC(DEBUG_MAP_ADDR, (byte) 0x00);

    setBG1SC DEBUG_MAP_ADDR, $00

    ; // Plane 0 Tile graphics @ $2000
    ; setBG12NBA(DEBUG_TILE_ADDR, PPU_NO_VALUE);

    setBG12NBA DEBUG_TILE_ADDR, $0000

    ; // Sprite screen data transfer to VRAM
    ; setINIDSPDirectValue(0x80);		// make VBlank happens

    setINIDSP $80

    ; // Debug tile and palette transfer to VRAM
    ; VRAMLoad2(debugFont_pic, DEBUG_TILE_ADDR, 0x0800);
    ; CGRAMLoad2(debugFont_pal, (byte) 0x00, 0x20);

    VRAMLoad debugFontGfx, DEBUG_TILE_ADDR, $0800
    CGRAMLoad debugFontPal, $00, $20

    lda #$01        ; setBGMODE(0, 0, 1);
    sta $2105

    lda #$01
    sta $212c       ; Plane 0 (bit one) enable register and OBJ disable
    stz $212d       ; disable all sub planes

    setINIDSP $0F

    lda #$00        ; set Plane 0 scroll to 0
    sta $210d
    sta $210d

    plp
    ply
    plx
    pla

    rts
.endproc

; void setCursorDebug(byte x, byte y)
; X register contains x (16 bit)
; Y register contains y (16 bit)

.proc setCursorDebug
    pha
    php
    rep #$30
    .A16
    .I16

    txa
    asl a
loopY:
    cpy #$00
    beq endY
    clc
    adc #$0040
    dey
    bra loopY
endY:
    sta cursorPos
    plp
    pla
    rts
.endproc

.proc setCursorPosNewLine
    php
    pha

    rep #$30
    .A16
    .I16

    lda cursorPos
    and #$FFC0      ; check for the right mask value
    adc #$40        ; check for the right add value
    sta cursorPos

    pla
    plp
    rts
.endproc

; void writeStringDebug(char out[])

; for(i=0; out[i] != '\0'; i++) {
;     buffer = out[i];
;     if((cursorX > 0x1f) || (buffer == '\n')) {
;         cursorY++;
;         cursorX = 0;
;         if(buffer == '\n') continue;
;     }
;     if(buffer>='a' && buffer<='z') {
;         buffer -= 0x20;
;     }
;     debugMap[cursorX+(cursorY*0x20)] = buffer - 0x20;
;     cursorX++;
; }

.proc writeStringDebug
    phx
    phy
    pha             ; save A
    php

    rep #$10        ; A -> 8 bit
    sep #$20        ; X, Y -> 16 bit
    .A8
    .I16

    ldx cursorPos   ; set X to cursorPos value
    ldy #$0000      ; set Y index to 0

loop:
    lda (2,s),y     ; load buffer into [Stack Indirect Indexed,Y]
    cmp #$00        ; check if value is 0 -> stop
    beq stop

    cmp #$0A        ; if value is \n adapt X to simulate new line and branch to loop
    bne notEndOfLine

endOfLine:
    stx cursorPos   ; store cursorPos in memory
    jsr setCursorPosNewLine
    ldx cursorPos   ; reload updated cursorPos

notEndOfLine:

    cmp     #$61    ; toUpper A
    bcc     toUpperEnd
    cmp     #$7B
    bcs     toUpperEnd
    sbc     #$20
toUpperEnd:

    sbc #$1F        ; remove $20 from A
    sta debugMap,x  ; set A in debugMap with X index
    iny             ; increment Y
    inx             ; increment X by 2
    inx
    bra loop

stop:
    stx cursorPos   ; store cursorPos in memory

    plp             ; restore processor status from stack
    pla             ; get A from stack
    ply
    plx

    rts
.endproc

; void displayDebug(void)

.proc displayDebug
    php

    rep #$10        ; A -> 8 bit
    sep #$20        ; X, Y -> 16 bit
    .A8
    .I16

    setINIDSP $80
    VRAMLoad debugMap, DEBUG_MAP_ADDR, $800
    setINIDSP $0F

    plp
    rts
.endproc

; char displayDebugEvent(word counter) <- DO not implement now