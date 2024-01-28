include ../Makefile.inc

all:
	ca65 -t none -I $(SFC_INC_PATH) hdmaMosaic.asm
	ld65 -vm -m hdmaMosaic.map -o hdmaMosaic.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom32.cfg hdmaMosaic.o $(SFC_LIB_PATH)/sfc.lib

clean:
	rm -rf hdma.sfc
