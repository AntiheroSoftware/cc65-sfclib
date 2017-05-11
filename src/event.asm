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
            .export     removeAllEvent
            .export     processEvents
            .export     getEventCounter
            .export     isEventActive

            .export     eventsTable

EVENT_SIZE = 8
EVENT_NUMBER = 16
EVENT_TABLE_SIZE = EVENT_SIZE * EVENT_NUMBER

;******************************************************************************
;*** Event Structure **********************************************************
;******************************************************************************

; active (byte)
; counter (word)
; long jump instruction (4 bytes)
; rts opcode (byte)

.segment "BSS"

eventsTable:
    .res    EVENT_TABLE_SIZE
    .res    1                  ; rts

eventPointer:
	.res	2

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

    rep #$20
	.A16

	lda #$0000

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

    rep #$20
	.A16

	lda #$0000

    rep #$10
    sep #$20
    .A8
    .I16

    tya
    asl
    asl
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
;*** processEvents ************************************************************
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

	lda #$0000				; clear A register (mostly High Byte)
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
    txa
    adc #eventsTable+2
    sta eventPointer

	sep #$20
	.A8

    phx
    ldx #$0000
    jsr (eventPointer,x)   		; jump to event table entry
	plx

    cmp #$00
    bne noEventRemoval

    txa
    lsr
    jsr removeEvent
    jmp skipToNextEvent

noEventRemoval:

    iny
    rep #$20
    .A16
    tya
    sta eventsTable+1,x     ; increment counter in event table

    and #$00ff
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
;*** removeEvent **************************************************************
;******************************************************************************
;*** A contains slot address                                                ***
;******************************************************************************

.proc removeEvent
    pha
    phx
    php

    rep #$20
	.A16

	and #$000f
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

;******************************************************************************
;*** removeAllEvent ***********************************************************
;******************************************************************************
;*** No Parameters                                                          ***
;******************************************************************************

.proc removeAllEvent
    pha
    phx
    php

    rep #$20
	.A16

	and #$000f
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

;******************************************************************************
;*** getEventCounter **********************************************************
;******************************************************************************
;*** A contains slot address                                                ***
;******************************************************************************
;*** counter is returned in X register                                      ***
;******************************************************************************

.proc getEventCounter
	phy
	php

	asl								; calculate slot index
	asl
	asl
	tay								; set slot index in Y

	ldx eventsTable+1,y

	plp
	ply
	rts
.endproc

;******************************************************************************
;*** isEventActive ************************************************************
;******************************************************************************
;*** A contains slot address                                                ***
;******************************************************************************
;*** active flag is returned in A register                                  ***
;******************************************************************************

.proc isEventActive
	phy
	php

	rep #$20
	.A16

	and #$000f

	asl								; calculate slot index
	asl
	asl
	tay								; set slot index in Y

	rep #$10
	sep #$20
	.A8
	.I16

	lda eventsTable,y

	plp
	ply
	rts
.endproc