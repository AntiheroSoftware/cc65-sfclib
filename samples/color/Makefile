include ../Makefile.inc

all:
	ca65 -t none -I $(SFC_INC_PATH) color.asm
	ld65 -o color.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom32.cfg color.o $(SFC_LIB_PATH)/sfc.lib

clean:
	rm -rf color.sfc
