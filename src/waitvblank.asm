;
; Written by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;
; void waitvblank(void);
;

        .setcpu     "65816"
        .include    "snes.inc"
        .export     _waitvblank

.proc       _waitvblank

        php
        pha
	    sep		#$20
	    .A8
wait:   lda		CPU_RDNMI
	    and		#<$80
	    beq		wait
	    pla
	    plp
	    rts

.endproc

