include ../Makefile.inc

all:
	ca65 -t none -I $(SFC_INC_PATH) joypad.asm
	ld65 -o joypad.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom32.cfg joypad.o $(SFC_LIB_PATH)/sfc.lib

clean:
	rm -rf joypad.sfc
