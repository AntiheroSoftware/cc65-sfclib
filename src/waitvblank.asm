;
; Written by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;
; void waitvblank(void);
;

        .setcpu     "65816"
        .export     waitForVBlank

.A8
.I16

.proc waitForVBlank

	pha
:   lda $4212
	bmi :-
:   lda $4212
	bpl :-
	pla
	rts

.endproc

