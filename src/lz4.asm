;
; LZ4 Unpack code for cc65
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
; based on code from Brutal Deluxe Software
; http://www.brutaldeluxe.fr/products/crossdevtools/lz4/index.html
;

            .setcpu     "65816"

            .export     LZ4_Unpack

; *****************************************************************************
; *** Need to be executed in ram (self modifiying code)  **********************
; *****************************************************************************

LZ4_Unpack:
            sta  LZ4_Literal_3+1   ; Uncompress a LZ4 Packed Data buffer (64 KB max)
            sep  #$20              ; A = Bank Src,Bank Dst
            .A8
            sta  LZ4_Match_5+1     ; X = Header Size = 1st Packed Byte offset
            sta  LZ4_Match_5+2     ; Y = Pack Data Size
            xba                    ;  => Return in A the length of unpacked Data
            sta  LZ4_ReadToken+3
            sta  LZ4_Match_1+3
            sta  LZ4_GetLength_1+3
            rep  #$30
            .A16
            .I16
            sty  LZ4_Limit+1

            ldy  #$0000            ; Init Target unpacked Data offset
LZ4_ReadToken:
            lda  $AA0000,X         ; Read Token Byte
            inx
            sta  LZ4_Match_2+1

LZ4_Literal:
            and  #$00F0            ; >>> Process Literal Bytes <<<
            beq  LZ4_Limit         ; No Literal
            cmp  #$00F0
            bne  LZ4_Literal_1
            jsr  LZ4_GetLengthLit  ; Compute Literal Length with next bytes
            bra  LZ4_Literal_2
LZ4_Literal_1:
            lsr                    ; Literal Length use the 4 bit
            lsr
            lsr
            lsr
LZ4_Literal_2:
            dec                    ; Copy A+1 Bytes
LZ4_Literal_3:
            mvn  $AA,$BB           ; Copy Literal Bytes from packed data buffer
            phk                    ; X and Y are auto incremented
            plb

LZ4_Limit:
            cpx  #$AAAA            ; End Of Packed Data buffer ?
            beq  LZ4_End

LZ4_Match:
            tya                    ; >>> Process Match Bytes <<<
            sec
LZ4_Match_1:
            sbc  $AA0000,X         ; Match Offset
            inx
            inx
            sta  LZ4_Match_4+1

LZ4_Match_2:
            lda  #$0000            ; Current Token Value
            and  #$000F
            cmp  #$000F
            bne  LZ4_Match_3
            jsr  LZ4_GetLengthMat  ; Compute Match Length with next bytes
LZ4_Match_3:
            clc
            adc  #$0003            ; Minimum Match Length is 4 (-1 for the MVN)

            phx
LZ4_Match_4:
            ldx  #$AAAA            ; Match Byte Offset
LZ4_Match_5:
            mvn  $BB,$BB           ; Copy Match Bytes from unpacked data buffer
            phk                    ; X and Y are auto incremented
            plb
            plx
            bra  LZ4_ReadToken

LZ4_End:
            tya                    ; A = Length of Unpack Data
            rts

; *****************************************************************************

LZ4_GetLengthLit:
            lda  #$000F            ; Compute Variable Length (Literal or Match)
LZ4_GetLengthMat:
            sta  LZ4_GetLength_2+1
LZ4_GetLength_1:
            lda  $AA0000,X         ; Read Length Byte
            inx
            and  #$00FF
            cmp  #$00FF
            bne  LZ4_GetLength_3
            clc
LZ4_GetLength_2:
            adc  #$000F
            sta  LZ4_GetLength_2+1
            bra  LZ4_GetLength_1
LZ4_GetLength_3:
            adc  LZ4_GetLength_2+1
            rts

; *****************************************************************************