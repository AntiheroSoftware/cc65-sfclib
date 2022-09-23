;
; DMA Snes code for cc65 (SNES code)
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;
; Assume that A register is in 8-bit mode when using those macro
;

            .setcpu     "65816"

; TODO set all parameters see docs page 149

.macro setDMAParam value, dmaChannel
    .ifblank dmaChannel
      __dmaChannel .set 0
    .else
      __dmaChannel .set dmaChannel
    .endif
    lda     #value
    sta     .ident(.sprintf("DMA_PARAM%d", __dmaChannel))
.endmacro

.macro setDMABBus BBusAddr, dmaChannel
    .ifblank dmaChannel
      __dmaChannel .set 0
    .else
      __dmaChannel .set dmaChannel
    .endif
    lda     #BBusAddr
    sta     .ident(.sprintf("DMA_BBUS%d", __dmaChannel))
.endmacro

.macro setDMA src, size, dmaChannel
    .ifblank dmaChannel
      __dmaChannel .set 0
    .else
      __dmaChannel .set dmaChannel
    .endif
    .if (.match (.left (1, {src}), {(})) .and (.match (.right (1, {src}), {)}))
        lda     .mid(1, .tcount({src})-2, {src})
        sta     .ident(.sprintf("DMA_ABUS%dL", __dmaChannel))
        lda     .mid(1, .tcount({src})-2, {src})+1
        sta     .ident(.sprintf("DMA_ABUS%dH", __dmaChannel))
        lda     .mid(1, .tcount({src})-2, {src})+2
        sta     .ident(.sprintf("DMA_ABUS%dB", __dmaChannel))
    .else
        lda     #<src
        sta     .ident(.sprintf("DMA_ABUS%dL", __dmaChannel))
        lda     #>src
        sta     .ident(.sprintf("DMA_ABUS%dH", __dmaChannel))
        lda     #^src
        sta     .ident(.sprintf("DMA_ABUS%dB", __dmaChannel))
    .endif
    .if (.match (.left (1, {size}), {(})) .and (.match (.right (1, {size}), {)}))
        lda		  .mid(1, .tcount({size})-2, {size})
        sta		  .ident(.sprintf("DMA_SIZE%dL", __dmaChannel))
        lda		  .mid(1, .tcount({size})-2, {size})+1
        sta     .ident(.sprintf("DMA_SIZE%dH", __dmaChannel))
    .else
        lda		  #<size
        sta		  .ident(.sprintf("DMA_SIZE%dL", __dmaChannel))
        lda		  #>size
        sta     .ident(.sprintf("DMA_SIZE%dH", __dmaChannel))
    .endif
.endmacro

.macro startDMA channels
    lda		#channels
    sta		CPU_MDMAEN
.endmacro
