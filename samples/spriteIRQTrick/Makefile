include ../Makefile.inc

all:
	ca65 -t none -I $(SFC_INC_PATH) spriteIRQTrick.asm
	ld65 -vm -m spriteIRQTrick.map -o spriteIRQTrick.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom32.cfg spriteIRQTrick.o $(SFC_LIB_PATH)/sfc.lib

clean:
	rm -rf spriteIRQTrick.sfc
