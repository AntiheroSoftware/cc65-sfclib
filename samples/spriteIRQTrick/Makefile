include ../Makefile.inc

all:
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) spriteIRQTrick.asm
	$(CC65_BIN)/ld65 -vm -m spriteIRQTrick.map -o spriteIRQTrick.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom32.cfg spriteIRQTrick.o $(SFC_LIB_PATH)/sfc.lib

clean:
	rm -rf spriteIRQTrick.sfc
