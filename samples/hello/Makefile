include ../Makefile.inc

all:
	ca65 -t none -I $(SFC_INC_PATH) hello.asm
	ld65 -o hello.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom32.cfg hello.o $(SFC_LIB_PATH)/sfc.lib

clean:
	rm -rf hello.sfc
