include ../Makefile.inc

all:
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) sprite.asm
	$(CC65_BIN)/ld65 -vm -m sprite.map -o sprite.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom32.cfg sprite.o $(SFC_LIB_PATH)/sfc.lib

clean:
	rm -rf sprite.sfc
