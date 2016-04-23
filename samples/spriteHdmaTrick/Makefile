include ../Makefile.inc

all:
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) spriteHdmaTrick.asm
	$(CC65_BIN)/ld65 -vm -m spriteHdmaTrick.map -o spriteHdmaTrick.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom32.cfg spriteHdmaTrick.o $(SFC_LIB_PATH)/sfc.lib

clean:
	rm -rf spriteHdmaTrick.sfc
