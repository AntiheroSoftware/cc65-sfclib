include ../Makefile.inc

all:
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) metasprite.asm
	$(CC65_BIN)/ld65 -vm -m metasprite.map -o metasprite.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom128.cfg metasprite.o $(SFC_LIB_PATH)/sfc.lib

clean:
	rm -rf metasprite.sfc
