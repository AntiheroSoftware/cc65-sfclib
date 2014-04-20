;
; Event Snes code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .include    "snes.inc"

            .export     initEvents
            .export     addEvent
            .export     processEvents

;word callbackAddr
;word VBlankCounter
;byte priority
;byte previousEventIndex
;byte nextEventIndex
;byte padding

EVENT_MAX = $10
EVENT_FULL_SIZE = EVENT_MAX * 8

EVENT_STOP = $00
EVENT_CONTINUE = $01

.segment "BSS"

events:
    .res    EVENT_FULL_SIZE, $00
eventStart:
    .res    1, $00
eventCount:
    .res    1, $00
eventEnabled:
    .res    1, $00

.segment "CODE"

; void initEvents(void);

.proc initEvents
    pha
    phx
    php

    rep #$30
    .A16
    .I16

    lda #$0000
    ldx #$0000      ; set #$0000 as callback address
loopInitCallback:
    sta events,x
    cpx #(EVENT_MAX-$01)*$08
    beq endInitCallback
    inx
    inx
    inx
    inx
    inx
    inx
    inx
    inx
    bra loopInitCallback
endInitCallback:

    rep #$10
    sep #$20
    .A8
    .I16

    lda #$00
    sta eventCount
    sta eventCount

    lda #$01        ; enable event by default
    sta eventEnabled

    plp
    plx
    pla
    rts
.endproc

; event* addEvent(char (*callback)(word counter));
; event* addEventWithPriority(char (*callback)(word counter), char priority);

.proc addEvent
    ; A contains priority (mask #$00FF)
    ; X contains callback
    php

    rep #$10
    sep #$20
    .A8
    .I16

    pha             ; push priority
    phx             ; push callback adress

    ; check if we still have place for event
    lda eventCount
    cmp #EVENT_MAX
    bne slotShouldBeAvailable
    plx
    pla
    plp
    rts
slotShouldBeAvailable:

    rep #$30
    .A16
    .I16

    ; find first available slot
    ldx #$0000
loopSearchAvailableSlot:
    lda events,x
    cmp #$0000
    beq foundAvailableSlot
    cpx #(EVENT_MAX-$01)*$08
    beq endSearchAvailableSlot
    inx
    inx
    inx
    inx
    inx
    inx
    inx
    inx
    bra loopSearchAvailableSlot

endSearchAvailableSlot:
    rep #$10
    sep #$20
    .A8
    .I16
    plx
    pla
    plp
    rts

foundAvailableSlot:
    txy             ; save available slot in Y

    rep #$10
    sep #$20
    .A8
    .I16

    ; find position based on priority
    lda eventStart
    cmp #$00
    bne findPrioritySlotLoop
    ldx #$0000
    bra foundPrioritySlot
findPrioritySlotLoop:
    dec a
    asl a
    asl a
    asl a
    tax
    lda events+4,x              ; load priority
    cmp 4,S
    bpl getFoundPrioritySlot    ; priority is more than our will insert in front
    lda events+6,x              ; load next index
    bra findPrioritySlotLoop

getFoundPrioritySlot:
    lda events+5,x              ; load previous index
    dec a
    asl a
    asl a
    asl a
foundPrioritySlot:
    phx             ; exchange X and Y
    tyx             ; X will contain new event adress
    ply             ; Y will contain event adress that we need to insert in front

    ; init data
    pla             ; get high address of callback
    sta events,x
    pla             ; get low address of callback
    sta events+1,x  ; callback address
    lda #$00
    sta events+2,x
    sta events+3,x  ; VBlankCounter
    pla
    sta events+4,x  ; priority

    ; init next/previous indexes
    ; TODO
    lda #$00
    sta events+5,x  ; previous index
    sta events+6,x  ; next index

    inc eventCount  ; increment event count

    plp
    rts
.endproc

; void removeEvent(event *eventElement);

.proc removeEvent
    ; X contains event offset
    php
    pha

    rep #$10
    sep #$20
    .A8
    .I16

    ; TODO check if indexes are #$00
    ; TODO adjust event start if needed

    lda events+5,x  ; push previous index
    pha
    lda events+6,x  ; push next index
    pha
    lda #$00        ; clear callback
    sta events,x
    sta events+1,x

    lda events+5,x  ; load previous index
    dec a           ; calculate offset from index in A
    asl a
    asl a
    asl a
    tax             ; put calculated offset in X
    pla             ; get back next index
    lda events+6,x  ; adjust next index
    dec a           ; calculate offset from index in A
    asl a
    asl a
    asl a
    tax             ; put calculated offset in X
    pla             ; get back previous index
    lda events+6,x  ; adjust next index

    pla
    plp
    rts
.endproc

; void processEvents(void);

.proc processEvents
    pha
    phx
    php

    rep #$10
    sep #$20
    .A8
    .I16

    lda eventStart
    cmp #$00
    beq noMoreEvent

    rep #$30
    .A16
    .I16

    and #$00FF
    dec a
    asl a
    asl a
    asl a
    tax

eventLoop:
    lda events,x    ; check that callback adress is valid
    cmp #$0000
    beq noMoreEvent

    lda events+2,x  ; load VBlankCounter into A for calling the events
    jsr (events,x)  ; call the event

    cmp #EVENT_STOP
    bne eventContinue
    jsr removeEvent

eventContinue:
    inc events+2,x  ; increment VBlankCounter
    lda events+6,x
    and #$00FF      ; get next index
    cmp #$0000
    beq noMoreEvent ; if index is zero we stop
    dec a
    asl a
    asl a
    asl a           ; shift by 3 (multiply by 8)
    tax
    bra eventLoop

noMoreEvent:
    plp
    plx
    pla
    rts
.endproc

; void setEnabledEvent(int flag);

.proc setEnableEvent
    php
    sep #$20
    .A8
    sta eventEnabled
    plp
    rts
.endproc

; int isEnabledEvent(void);

.proc isEnabledEvent
    php
    lda eventEnabled
    rep #$20
    .A16
    and #$0001
    plp
    rts
.endproc