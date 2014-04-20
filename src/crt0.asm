;
; Startup code for cc65 (SNES version)
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
; based on code by Groepaz/Hitmen <groepaz@gmx.net>
; based on code by Ullrich von Bassewitz <uz@cc65.org>
;

        .setcpu          "65816"

        .import         _main
        .import         _preInit
        .import         _NMIHandler, _IRQHandler

        .import         initSnes

        .export         __STARTUP__ : absolute = 1
        ;.export         __ROMINFO__
        ;.export         __VECTORS__

        .include        "snes.inc"

.segment "STARTUP"

start:
    sei                           ; Disabled interrupts
    clc                           ; clear carry to switch to native mode
    xce                           ; Exchange carry & emulation bit. Now in native mode (full 65816)
    rep     #$18                  ; Binary mode (decimal mode off), X/Y 16 bit
    .I16
    ldx     #$1FFF                ; set stack to $1FFF
    txs

    rep     #$30
    .A16
    .I16

    ; TODO
    ; Init data used for heap
    ; see heap definition below
    ;stz    ___heap_top
    ;stz    ___mem_start

    jsr     _preInit

    jsr     initSnes

    cli                           ; Enable interrupts

    rep     #$30
    .A16
    .I16

; Hot fix for calling main routine that was generated with C compiler
; that don't really support 65816 and that is in 6502 instruction mode
    sep #$30
    .A8

    jsr     _main
    brk
	
; fix for bad 65816 brk add 1 byte
    .byte $00

;******************************************************************************
;*** IRQ, NMI and DIRQ handling routine                                     ***
;******************************************************************************

irq:
    rep	#$30
    .A16
    .I16
    pha
    phx
    phy
    jsr	_IRQHandler
    ply
    plx
    pla
    rti

nmi:
    .A16
    .I16
    rep #$30
    pha
    phx
    phy
    phd
    phb
    lda	#$0000
    sep #$30        ; X,Y,A are 8 bit numbers
    .A8
    .I8
    lda CPU_RDNMI   ; Read NMI
    .A16
    .I16
    rep	#$30
    jsr	_NMIHandler
    plb
    pld
    ply
    plx
    pla
    rti

dirq:
    rti

;******************************************************************************
;*** SNES ROM Registration Data                                             ***
;******************************************************************************

.segment "ROMINFO"

MAKER_CODE:         .byte   "FF"
GAME_CODE:          .byte   "SMWJ"
FIXED_VALUE0:       .byte   $00, $00, $00, $00, $00, $00, $00
EXPANSION_RAM_SIZE: .byte   $00
SPECIAL_VERSION:    .byte   $00
CARTRIDGE_TYPE_SUB: .byte   $00
GAME_TITLE:         .byte   "GAME TITLE          !"
                            ;012345678901234567890;
MAP_MODE:           .byte   $20
CARTRIDGE_SIZE:	    .byte   $00
ROM_SIZE:           .byte   $08
RAM_SIZE:           .byte   $00
DESTINATION_CODE:   .byte   $00
FIXED_VALUE1:	    .byte   $33
MASK_ROM_VERSION:   .byte   $00
COMPLEMENT_CHECK:   .byte   $00, $00
CHEKSUM:            .byte   $00, $00

;******************************************************************************
;*** SNES Interrupts and Reset vector                                       ***
;******************************************************************************

.segment "VECTORS"

; *** Native vector ***

N_COP:   .word   dirq
N_BRK:   .word   dirq
N_ABORT: .word   dirq
N_NMI:   .word   irq
N_RSRVD: .word   dirq
N_IRQ:   .word   irq

         .byte $00, $00, $00, $00 ; vectors padding

; *** Emulation vector ***

E_COP:   .word   dirq
E_RSRVD: .word   dirq
E_ABORT: .word   dirq
E_NMI:   .word   dirq
E_RESET: .word   start
E_IRQ:   .word   dirq

