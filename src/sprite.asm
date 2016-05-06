;
; Sprite Snes code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .include    "snes.inc"

            .export     clearOAM
            .export     copyOAM

            .export     oamData

.segment "BSS"

oamData:
    .res 512+32

.segment "CODE"

.A8
.I16

.proc clearOAM
        php
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

        pla
        plx
        plp

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