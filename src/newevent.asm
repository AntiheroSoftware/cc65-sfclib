;
; Event Snes code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .include    "snes.inc"

            .export     newinitEvents
            .export     newaddEvent
            .export     newremoveEvents
            .export     newprocessEvents

EVENT_SIZE = 4
EVENT_NUMBER = 10
EVENT_TABLE_SIZE = EVENT_SIZE * EVENT_NUMBER

.segment "BSS"

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

    tya
    sta eventsTable,x

endSearchAvailableSlot:

    plp
    ply
    plx
    pla
    rts
.endproc

.proc newprocessEvents
    jsr eventsTable
    rts
.endproc

.proc newremoveEvents
    lda 4,S

    rts
.endproc