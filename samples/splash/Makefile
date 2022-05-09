include ../Makefile.inc

all:
	ca65 -t none -I $(SFC_INC_PATH) splash.asm
	ld65 -m splash.map -o splash.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom32.cfg splash.o $(SFC_LIB_PATH)/sfc.lib

clean:
	rm -rf splash.sfc
