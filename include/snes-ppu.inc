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
    vramDstTmp = >vramDst
    bgSizeTmp = bgSize & $03
    lda #vramDstTmp | bgSizeTmp
    sta PPU_BG1SC
.endMacro

; void setBG2SC(word vramDst, byte bgSize)

.macro setBG2SC vramDst, bgSize
    vramDstTmp = >vramDst
    bgSizeTmp = bgSize & $03
    lda #vramDstTmp | bgSizeTmp
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
    vramDstBG1Tmp = >vramDstBG1 >> 4
    vramDstBG2Tmp = >vramDstBG2
    lda #vramDstBG1Tmp | vramDstBG2Tmp
    sta PPU_BG12NBA
.endmacro

; void setBG34NBA(word vramDstBG3, word vramDstBG4)

.macro setBG34NBA vramDstBG3, vramDstBG4
    vramDstBG3Tmp = >vramDstBG3 >> 4
    vramDstBG4Tmp = >vramDstBG4
    lda #vramDstBG3Tmp | vramDstBG4Tmp
    sta PPU_BG34NBA
.endmacro

; void setVMAINC(byte value)

.macro setVMAINC value
    lda #value
    sta PPU_VMAINC
.endmacro

; void setVMADD(word value)

.macro setVMADD vramDst
    lda		#<vramDst
    sta		PPU_VMADDL
    lda		#>vramDst
    sta		PPU_VMADDH
.endmacro

.macro setVMADDFromPointer vramDst
    lda		vramDst
    sta		PPU_VMADDL
    lda		vramDst+1
    sta		PPU_VMADDH
.endmacro

; void setCGADD(byte cgramDst)

.macro setCGADD cgramDst
    lda #cgramDst
    sta PPU_CGADD
.endmacro

; VRAMLoad((long) src, (word) vramDst, (word) size)

; TODO make an unique function that detects if a pointer of not ...
; dunno if possible with CA65

.macro VRAMLoad src, vramDst, size
    setVMAINC $80
    setVMADD vramDst
    setDMAParam $01
    setDMABBus $18
    setDMA .BANKBYTE(src), src, size
    startDMA $01
.endmacro

.macro VRAMLoadFromPointer src, vramDst, size
    setVMAINC $80
    setVMADDFromPointer vramDst
    setDMAParam $01
    setDMABBus $18
    setDMAFromPointer src, size
    startDMA $01
.endmacro

; CGRAMLoad((long) src, (word) cgramDst, (word) size)

.macro CGRAMLoad src, cgramDst, size
    setCGADD cgramDst
    setDMAParam $00
    setDMABBus $22
    setDMA .BANKBYTE(src), src, size
    startDMA $01
.endmacro
