.import     initPad
.import     readPad1, readPad2, readPad3, readPad4

.import     padPushData1, padFirstPushData1, padReleaseData1
.import     padPushData2, padReleaseData2
.import     padPushData3, padReleaseData3
.import     padPushData4, padReleaseData4

.import     padPushDataHigh1, padPushDataLow1, padFirstPushDataLow1, padFirstPushDataHigh1, padReleaseDataHigh1, padReleaseDataLow1
.import     padPushDataHigh2, padPushDataLow2, padReleaseDataHigh2, padReleaseDataLow2
.import     padPushDataHigh3, padPushDataLow3, padReleaseDataHigh3, padReleaseDataLow3
.import     padPushDataHigh4, padPushDataLow4, padReleaseDataHigh4, padReleaseDataLow4

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

PAD_HIGH_A     = %10000000
PAD_HIGH_X     = %01000000
PAD_HIGH_L     = %00100000
PAD_HIGH_R     = %00010000

PAD_LOW_B      = %10000000
PAD_LOW_Y      = %01000000
PAD_LOW_SELECT = %00100000
PAD_LOW_START  = %00010000
PAD_LOW_UP     = %00001000
PAD_LOW_DOWN   = %00000100
PAD_LOW_LEFT   = %00000010
PAD_LOW_RIGHT  = %00000001