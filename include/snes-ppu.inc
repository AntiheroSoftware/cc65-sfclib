;
; PPU Snes code for cc65 (SNES code)
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;
; Assume that A register is in 8-bit mode when using those macro
;

            .setcpu     "65816"

; void setINIDSP(word value) {
; put value in register A (8-bit mode)

.macro setINIDSP value
    lda #value
    sta PPU_INIDSP
.endmacro

; void setBG1SC(word vramDst, byte bgSize)

.macro setBG1SC vramDst, bgSize
    lda #>vramDst | (bgSize & $03)
    sta PPU_BG1SC
.endMacro

; void setBG2SC(word vramDst, byte bgSize)

.macro setBG2SC vramDst, bgSize
    lda #>vramDst | (bgSize & $03)
    sta PPU_BG2SC
.endMacro

; void setBG3SC(word vramDst, byte bgSize)

.macro setBG3SC vramDst, bgSize
    vramDstTmp = >vramDst
    bgSizeTmp = bgSize & $03
    lda #vramDstTmp | bgSizeTmp
    sta PPU_BG3SC
.endMacro

; void setBG4SC(word vramDst, byte bgSize)

.macro setBG4SC vramDst, bgSize
    vramDstTmp = >vramDst
    bgSizeTmp = bgSize & $03
    lda #vramDstTmp | bgSizeTmp
    sta PPU_BG4SC
.endMacro

; void setBG12NBA(word vramDstBG1, word vramDstBG2)

.macro setBG12NBA vramDstBG1, vramDstBG2
    lda #(>vramDstBG1 >> 4) | >vramDstBG2
    sta PPU_BG12NBA
.endmacro

; void setBG34NBA(word vramDstBG3, word vramDstBG4)

.macro setBG34NBA vramDstBG3, vramDstBG4
    vramDstBG3Tmp = >vramDstBG3 >> 4
    vramDstBG4Tmp = >vramDstBG4
    lda #vramDstBG3Tmp | vramDstBG4Tmp
    sta PPU_BG34NBA
.endmacro

.macro setVMAINC value
    lda #value
    sta PPU_VMAINC
.endmacro

.macro setVMADD vramDst
    .if (.match (.left (1, {vramDst}), {(})) .and (.match (.right (1, {vramDst}), {)}))
        lda		.mid(1, .tcount({vramDst})-2, {vramDst})
        sta		PPU_VMADDL
        lda		.mid(1, .tcount({vramDst})-2, {vramDst})+1
        sta		PPU_VMADDH
    .else
        lda		#<vramDst
        sta		PPU_VMADDL
        lda		#>vramDst
        sta		PPU_VMADDH
    .endif
.endmacro

.macro setCGADD cgramDst
    lda #cgramDst
    sta PPU_CGADD
.endmacro

.macro setWMADD wramDst
    ldx #.LOWORD(wramDst)
    stx PPU_WMADDL
    lda #.BANKBYTE(wramDst)
    sta PPU_WMADDH
.endmacro

.macro VRAMLoad src, vramDst, size
    setVMAINC $80
    setVMADD vramDst
    setDMAParam $01
    setDMABBus $18
    setDMA src, size
    startDMA $01
.endmacro

.macro VRAMClear src, vramDst, size
    setVMAINC $80
    setVMADD vramDst
    setDMAParam $09
    setDMABBus $18
    setDMA src, size
    startDMA $01
.endmacro

; TODO change name or add param for transfer type

.macro VRAMLoad2 src, vramDst, size
    setVMAINC $81
    setVMADD vramDst
    setDMAParam $01
    setDMABBus $18
    setDMA src, size
    startDMA $01
.endmacro

.macro CGRAMLoad src, cgramDst, size
    setCGADD cgramDst
    setDMAParam $00
    setDMABBus $22
    setDMA src, size
    startDMA $01
.endmacro

.macro WRAMLoad src, wramDst, size
    setWMADD wramDst
    setDMAParam $00
    setDMABBus $80
    setDMA src, size
    startDMA $01
.endmacro

.macro WRAMClear src, wramDst, size
    setWMADD wramDst
    setDMAParam $08
    setDMABBus $80
    setDMA src, size
    startDMA $01
.endmacro
