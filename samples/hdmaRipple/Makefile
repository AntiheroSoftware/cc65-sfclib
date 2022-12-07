include ../Makefile.inc

all:
	ca65 -t none -I $(SFC_INC_PATH) hdmaRipple.asm
	ld65 -vm -m hdmaRipple.map -o hdmaRipple.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom32.cfg hdmaRipple.o $(SFC_LIB_PATH)/sfc.lib

clean:
	rm -rf hdma.sfc
