;
; DMA Snes code for cc65 (SNES code)
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;
; Assume that A register is in 8-bit mode when using those macro
;

            .setcpu     "65816"

; TODO set all parameters see docs page 149

.macro setDMAParam value
    lda     #value
    sta     DMA_PARAM0
.endmacro

.macro setDMABBus BBusAddr
    lda     #BBusAddr
    sta     DMA_BBUS0
.endmacro

.macro setDMA srcBank, srcAddr, size
    lda     #<srcAddr
    sta     DMA_ABUS0L
    lda     #>srcAddr
    sta     DMA_ABUS0H
    lda     #srcBank
    sta     DMA_ABUS0B
    lda		#<size
    sta		DMA_SIZE0L
    lda		#>size
    sta     DMA_SIZE0H
.endmacro

.macro startDMA channels
    lda		#channels
    sta		CPU_MDMAEN
.endmacro