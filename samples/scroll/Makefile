include ../Makefile.inc

all:
	$(CC65_BIN)/ca65 -g -t none -I $(SFC_INC_PATH) scroll.asm
	$(CC65_BIN)/ld65 -vm -m scroll.map -o scroll.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom128.cfg scroll.o $(SFC_LIB_PATH)/sfc.lib

clean:
	rm -rf scroll.sfc
