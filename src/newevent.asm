;
; Event Snes code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .include    "snes.inc"

            .export     newinitEvents
            .export     newaddEvent
            .export     newremoveEvent
            .export     newprocessEvents

EVENT_SIZE = 4
EVENT_COUNTER_SIZE = 1
EVENT_NUMBER = 10
EVENT_TABLE_SIZE = EVENT_SIZE * EVENT_NUMBER
EVENT_COUNTER_TABLE_SIZE = EVENT_COUNTER_SIZE * EVENT_NUMBER

.segment "BSS"

eventsCounterTable:
    .res    EVENT_COUNTER_TABLE_SIZE

eventsTable:
    .res    EVENT_TABLE_SIZE
    .res    1                  ; rts

.segment "CODE"

.proc newinitEvents
    pha
    phx
    php

    rep #$10
    sep #$20
    .A8
    .I16

    lda #$EA        ; "NOP" instruction opcode
    ldx #$0000      ; set #$0000 as callback address
loopInitCallback:
    sta eventsTable,x
    inx
    cpx #EVENT_TABLE_SIZE+4
    bne loopInitCallback

    lda #$60        ; "RTS" instruction opcode
    sta eventsTable,x

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
;*** Y contains slot address                                                ***
;******************************************************************************

.proc newaddEvent
    pha
    phx
    phy
    php

    rep #$10
    sep #$20
    .A8
    .I16

    phy             ; push Y with slot address for later
    txy

    ; find first available slot
    ldx #$0000
loopSearchAvailableSlot:
    lda eventsTable,x
    cmp #$EA        ; Check if there is a "NOP" instruction
    beq foundAvailableSlot
    cpx #EVENT_TABLE_SIZE
    beq endSearchAvailableSlot
    inx
    inx
    inx
    inx
    bra loopSearchAvailableSlot

foundAvailableSlot:

    lda #$20
    sta eventsTable,x
    inx

    rep #$20
    .A16

    ; TODO handle bank

    tya
    sta eventsTable,x

    dex                 ; get initital slot address
    txa
    plx                 ; get back slot address
    sta $0000,x

endSearchAvailableSlot:

    plp
    ply
    plx
    pla
    rts
.endproc

;******************************************************************************
;*** newprocessEvents *********************************************************
;******************************************************************************
;*** No Parameters                                                          ***
;******************************************************************************

.proc newprocessEvents
    jsr _incrementCounters
    jsr eventsTable
    rts
.endproc

;******************************************************************************
;*** newremoveEvent ***********************************************************
;******************************************************************************
;*** A contains slot address                                                ***
;******************************************************************************

.proc newremoveEvent
    phx
    php

    tax

    rep #$10
    sep #$20
    .A8
    .I16

    lda #$EA        ; "NOP" instruction opcode
    sta eventsTable,x
    inx
    sta eventsTable,x
    inx
    sta eventsTable,x

    plp
    plx
    rts
.endproc

;******************************************************************************
;*** _incrementCounters *******************************************************
;******************************************************************************
;*** No Parameters                                                          ***
;******************************************************************************

.proc _incrementCounters
    phy
    phx
    pha
    php

    ldx #$0000
    ldy #$0000
loopSearchActiveSlot:
    lda eventsTable,x
    cmp #$EA        ; Check if there is a "NOP" instruction
    beq lookNextActiveOne

    lda eventsCounterTable,y
    inc
    sta eventsCounterTable,y

lookNextActiveOne:

    cpy #EVENT_COUNTER_TABLE_SIZE
    beq endSearchActiveSlot

    inx
    inx
    inx
    iny
    bra loopSearchActiveSlot

endSearchActiveSlot:
    plp
    pla
    plx
    ply
    rts
.endproc