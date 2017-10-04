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

.macro setDMA src, size
    .if (.match (.left (1, {src}), {(})) .and (.match (.right (1, {src}), {)}))
        lda     .mid(1, .tcount({src})-2, {src})
        sta     DMA_ABUS0L
        lda     .mid(1, .tcount({src})-2, {src})+1
        sta     DMA_ABUS0H
        lda     .mid(1, .tcount({src})-2, {src})+2
        sta     DMA_ABUS0B
    .else
        lda     #<src
        sta     DMA_ABUS0L
        lda     #>src
        sta     DMA_ABUS0H
        lda     #^src
        sta     DMA_ABUS0B
    .endif
    .if (.match (.left (1, {size}), {(})) .and (.match (.right (1, {size}), {)}))
        lda		  .mid(1, .tcount({size})-2, {size})
        sta		  DMA_SIZE0L
        lda		  .mid(1, .tcount({size})-2, {size})+1
        sta     DMA_SIZE0H
    .else
        lda		  #<size
        sta		  DMA_SIZE0L
        lda		  #>size
        sta     DMA_SIZE0H
    .endif
.endmacro

.macro startDMA channels
    lda		#channels
    sta		CPU_MDMAEN
.endmacro
