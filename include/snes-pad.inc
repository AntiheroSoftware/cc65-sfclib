.import     initPad
.import     readPad1, readPad2, readPad3, readPad4

.import     padPushData1, padReleaseData1
.import     padPushData2, padReleaseData2
.import     padPushData3, padReleaseData3
.import     padPushData4, padReleaseData4

; A X L R / / / / B Y SELECT START UP DOWN LEFT RIGHT

PAD_A      = %1000000000000000
PAD_X      = %0100000000000000
PAD_L      = %0010000000000000
PAD_R      = %0001000000000000
PAD_B      = %0000000010000000
PAD_Y      = %0000000001000000
PAD_SELECT = %0000000000100000
PAD_START  = %0000000000010000
PAD_UP     = %0000000000001000
PAD_DOWN   = %0000000000000100
PAD_LEFT   = %0000000000000010
PAD_RIGHT  = %0000000000000001