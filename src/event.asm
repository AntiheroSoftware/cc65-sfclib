;
; Event Snes code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .include    "snes.inc"

            .export     initEvents
            .export     addEvent
            .export     removeEvent
            .export     processEvents

EVENT_SIZE = 8
EVENT_NUMBER = 16
EVENT_TABLE_SIZE = EVENT_SIZE * EVENT_NUMBER

;******************************************************************************
;*** Event Structure **********************************************************
;******************************************************************************

; active (byte)
; counter (word)
; long jump instruction
; rts opcode

.segment "BSS"

eventsTable:
    .res    EVENT_TABLE_SIZE
    .res    1                  ; rts

.segment "CODE"

;******************************************************************************
;*** initEvents ***************************************************************
;******************************************************************************
;*** No Parameters                                                          ***
;******************************************************************************

.proc initEvents
    pha
    phx
    php

    rep #$10
    sep #$20
    .A8
    .I16

    ldx #$0000              ; set index
loopInitCallback:
    lda #$00
    sta eventsTable,x       ; set active to false
    lda #$22
    sta eventsTable+3,x     ; "JSL" instruction
    lda #$60
    sta eventsTable+7,x     ; "RTS" instruction opcode

    txa                     ; increment index
    clc
    adc #$08
    tax

    cpx #EVENT_TABLE_SIZE+8 ; check index
    bne loopInitCallback

    plp
    plx
    pla
    rts
.endproc

;******************************************************************************
;*** addEvent *****************************************************************
;******************************************************************************
;*** A contains bank                                                        ***
;*** X contains ptr                                                         ***
;*** Y contains slot                                                        ***
;******************************************************************************

.proc addEvent
    pha
    phx
    phy
    php

    pha

    rep #$10
    sep #$20
    .A8
    .I16

    tya
    asl
    tay

    lda #$01
    sta eventsTable,y       ; set active flag

    lda #$00
    sta eventsTable+1,y     ; init counter to #$0000 (high)
    sta eventsTable+2,y     ; init counter to #$0000 (low)

    pla
    sta eventsTable+6,y     ; set event bank address

    rep #$20
    .A16

    txa
    sta eventsTable+4,y     ; set event address

    plp
    ply
    plx
    pla
    rts
.endproc

;******************************************************************************
;*** processEvents *********************************************************
;******************************************************************************
;*** No Parameters                                                          ***
;******************************************************************************

.proc processEvents
    pha
    phx
    phy
    php

    rep #$30
    .A16
    .I16

    ldx #$0000              ; set index
loopProcessEvents:

    sep #$20
    .A8

    lda eventsTable,x       ; load active flag
    cmp #$01
    bne skipToNextEvent

    rep #$20
    .A16

    lda eventsTable+1,x     ; load counter into A reg
    tay                     ; save counter in Y reg
    jsr eventsTable+3       ; jump to event table entry

    sep #$20
    .A8

    cmp #$00
    bne noEventRemoval

    txa
    lsr
    jsr removeEvent

noEventRemoval:

    iny
    rep #$20
    .A16
    tya
    sta eventsTable+1,x       ; increment counter in event table
    sep #$20
    .A8

skipToNextEvent:

    txa                     ; increment index
    clc
    adc #$08
    tax

    cpx #EVENT_TABLE_SIZE+8 ; check index
    bne loopProcessEvents   ; loop

    plp
    ply
    plx
    pla
    rts
.endproc

;******************************************************************************
;*** removeEvent ***********************************************************
;******************************************************************************
;*** A contains slot address                                                ***
;******************************************************************************

.proc removeEvent
    pha
    phx
    php

    asl
    tax

    rep #$10
    sep #$20
    .A8
    .I16

    lda #$00            ; "NOP" instruction opcode
    sta eventsTable,x

    plp
    plx
    pla
    rts
.endproc