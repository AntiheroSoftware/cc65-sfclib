;
; Sprite Snes code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .include    "snes.inc"

            .export     clearOAM
            .export     copyOAM
            .export 	  OAMDataUpdated
            .export     loadSprite8
            .export     loadSprite16
            .export     loadSprite32
            .export     loadSprite64

            .export     oamData

.segment "BSS"

oamData:
    .res 512+32

oamDataUpdated:
	.res 1

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

        lda #$00						              ; reset oamDataUpdated
		sta oamDataUpdated

        pla
        plx
        plp

        rts
.endproc

.proc copyOAM
    pha
    phx

    lda oamDataUpdated
    cmp #$00
    beq endCopyOAM

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

    lda #$00						            ; reset oamDataUpdated
    sta oamDataUpdated

endCopyOAM:

    plx
    pla
    rts
.endproc

.proc OAMDataUpdated
	php
	pha

	rep #$10
	sep #$20
	.A8
	.I16

	lda #$01
	sta oamDataUpdated

	pla
	plp
	rts
.endproc

.macro __updateXY XIncrement, YIncrement
  rep #$20
  .A16

  txa
  clc
  adc XIncrement
  tax

  tya
  clc
  adc YIncrement
  tay

  sep #$20
  .A8
.endmacro

.macro __DMALoadLine size
  ;setVMADD vramDst
  phy
  pla
  sta PPU_VMADDL
  pla
  sta PPU_VMADDH

  setDMAParam $01, 0
  setDMABBus $18, 0

  ;setDMA src, $0200, 0
  pla
  sta DMA_ABUS0B                    ; set DMA src bank
  pha                               ; Preserve A during X and Y updates

  phx
  pla
  sta DMA_ABUS0L
  pla
  sta DMA_ABUS0H

  lda #size                          ; set dma size
  sta DMA_SIZE0L
  lda #$00
  sta DMA_SIZE0H

  startDMA $01
.endmacro

; A -> src bank
; X -> src address
; Y -> vramDst
; Assume .A8 and .I16
.proc loadSprite64
  php
  pha

  setVMAINC $80

  __DMALoadLine $80
  __updateXY #$0200, #$0100
  __DMALoadLine $80
  __updateXY #$0200, #$0100
  __DMALoadLine $80
  __updateXY #$0200, #$0100
  __DMALoadLine $80
  __updateXY #$0200, #$0100
  __DMALoadLine $80
  __updateXY #$0200, #$0100
  __DMALoadLine $80
  __updateXY #$0200, #$0100
  __DMALoadLine $80
  __updateXY #$0200, #$0100
  __DMALoadLine $80

  pla
  plp
  rts
.endproc

; A -> src bank
; X -> src address
; Y -> vramDst
; Assume .A8 and .I16
.proc loadSprite32
  php
  pha

  setVMAINC $80

  __DMALoadLine $80
  __updateXY #$0200, #$0100
  __DMALoadLine $80
  __updateXY #$0200, #$0100
  __DMALoadLine $80
  __updateXY #$0200, #$0100
  __DMALoadLine $80

  pla
  plp
  rts
.endproc

; A -> src bank
; X -> src address
; Y -> vramDst
; Assume .A8 and .I16
.proc loadSprite16
  php
  pha

  setVMAINC $80

  __DMALoadLine $80
  __updateXY #$0200, #$0100
  __DMALoadLine $80

  pla
  plp
  rts
.endproc

; A -> src bank
; X -> src address
; Y -> vramDst
; Assume .A8 and .I16
.proc loadSprite8
  php
  pha

  setVMAINC $80

  __DMALoadLine $80

  pla
  plp
  rts
.endproc
