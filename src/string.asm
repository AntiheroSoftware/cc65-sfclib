;
; String lib Snes code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
; original code from Ullrich von Bassewitz, 31.05.1998
;

            .setcpu     "65816"

	        .export		itoa, utoa, stringBuffer

.segment	"RODATA"

__hextab:
	.byte	$30
	.byte	$31
	.byte	$32
	.byte	$33
	.byte	$34
	.byte	$35
	.byte	$36
	.byte	$37
	.byte	$38
	.byte	$39
	.byte	$41
	.byte	$42
	.byte	$43
	.byte	$44
	.byte	$45
	.byte	$46

specval:
    .asciiz "-32768"

.segment "BSS"

stringBuffer:
    .res 8, $00

.segment "ZEROPAGE"

tmp1:
    .res 1
ptr2:
    .res 2
sreg:
    .res 2

.segment "CODE"

; reference code TODO remove
;
; char* itoa (int value, char* s, int radix);
; char* utoa (unsigned value, char* s, int radix);
;
; dopop:
;     sta     tmp1            ; will loose high byte
;     ldy     #0
;     lda     (sp),y
;     sta     ptr2
;     sta     ptr3
;     iny
;     lda     (sp),y
;     sta     ptr2+1
;     sta     ptr3+1
;     iny
;     lda     (sp),y
;     sta     sreg
;     iny
;     lda     (sp),y
;     sta     sreg+1
;     jmp     addysp1         ; Bump stack pointer

; tmp1 contains radix
; ptr2 and ptr3 contains string buffer address
; sreg contains value to convert

;******************************************************************************
;*** itoa *********************************************************************
;******************************************************************************
;*** A contains radix                                                       ***
;*** X contains value                                                       ***
;*** result goes into 'stringBuffer'                                        ***
;******************************************************************************

itoa:

    php

    .A8
    .I16
    rep     #$10
    sep     #$20

    sta     tmp1            ; save radix in tmp1
    stx     sreg
    ldx     #stringBuffer
    stx     ptr2

; We must handle $8000 in a special way, since it is the only negative
; number that has no positive 16-bit counterpart

    ldy     tmp1            ; get radix
    cpy     #10
    bne     utoa
    cmp     #$00
    bne     L2
    cpx     #$80
    bne     L2

    ldy     #$6
L1:
    lda     specval,y       ; copy -32768
    sta     (ptr2),y
    dey
    bpl     L1
    jmp     L10

; Check if the value is negative. If so, write a - sign and negate the
; number.

L2:     lda     sreg+1          ; get high byte
        bpl     utoa
        lda     #'-'
        ldy     #0
        sta     (ptr2),y        ; store sign
        inc     ptr2
        bne     L3
        inc     ptr2+1

L3:     lda     sreg
        eor     #$FF
        clc
        adc     #$01
        sta     sreg
        lda     sreg+1
        eor     #$FF
        adc     #$00
        sta     sreg+1
        jmp     utoa

;******************************************************************************
;*** utoa *********************************************************************
;******************************************************************************
;*** radix 16 ($10) conversion                                              ***
;*** X contains value                                                       ***
;*** result goes into 'stringBuffer'                                        ***
;******************************************************************************

; Convert to string by dividing and push the result onto the stack

utoa:
    lda     #$00
    pha                     ; sentinel (end of string)

; Divide sreg/tmp1 -> sreg, remainder in a

L5:
    ldy     #16             ; 16 bit
    lda     #0              ; remainder
L6:
    asl     sreg
    rol     sreg+1
    rol     a
    cmp     tmp1
    bcc     L7
    sbc     tmp1
    inc     sreg
L7:
    dey
    bne     L6

    tay                     ; get remainder into y
    lda     __hextab,y      ; get hex character
    pha                     ; save char value on stack

    lda     sreg
    ora     sreg+1
    bne     L5

; Get the characters from the stack into the string

    ldy     #0
L9:
    pla
    sta     stringBuffer,y
    beq     L10             ; jump if sentinel
    iny
    bne     L9              ; jump always

; Done!

L10:
    plp
    rts