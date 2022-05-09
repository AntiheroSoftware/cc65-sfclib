include ../Makefile.inc

all:
	ca65 -t none -I $(SFC_INC_PATH) sprite.asm
	ld65 -vm -m sprite.map -o sprite.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom32.cfg sprite.o $(SFC_LIB_PATH)/sfc.lib

clean:
	rm -rf sprite.sfc
