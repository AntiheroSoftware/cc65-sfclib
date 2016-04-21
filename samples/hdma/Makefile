include ../Makefile.inc

all:
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) hdma.asm
	$(CC65_BIN)/ld65 -vm -m hdma.map -o hdma.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom32.cfg hdma.o $(SFC_LIB_PATH)/sfc.lib

clean:
	rm -rf hdma.sfc
