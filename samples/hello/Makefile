include ../Makefile.inc

all:
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) hello.asm
	$(CC65_BIN)/ld65 -o hello.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom32.cfg hello.o $(SFC_LIB_PATH)/sfc.lib

clean:
	rm -rf hello.sfc
